#requires -Version 7.0
<#
.SYNOPSIS
  Atelier build — assembles one uploadable ZIP per skill per locale into dist/.
  Windows counterpart to scripts/build.sh; mirrors its behavior, checks, and
  outputs. Read alongside build.sh — comments below flag every point where
  PowerShell/Windows forces a deliberate, unavoidable divergence.
.PARAMETER Lang
  fr, en, or all. Omit to be prompted. (ValidateSet below is the PowerShell-
  native replacement for build.sh's manual `--lang` validation and its
  "--lang must be fr, en, or all" die() message: an invalid -Lang value is
  rejected by parameter binding before the script body ever runs, with
  PowerShell's own error text instead of build.sh's custom string.)
.PARAMETER Check
  Run the mechanical checks only; build to a temp dir and leave dist/ untouched.
.NOTES
  build.sh also accepts -h/--help (prints a custom usage block) and dies with
  a custom "unknown argument: $1" message on anything else. CmdletBinding
  supplies both equivalents natively: Get-Help / -? for usage, and a native
  parameter-binding error for unrecognized arguments. No manual argument loop
  is implemented here — that is deliberate, not an omission.
#>
[CmdletBinding()]
param(
  [ValidateSet('fr', 'en', 'all', IgnoreCase = $false)]
  [string]$Lang,
  [switch]$Check
)

$ErrorActionPreference = 'Stop'

$RepoRoot  = Split-Path -Parent $PSScriptRoot
$SkillsDir = Join-Path $RepoRoot 'skills'
$SharedDir = Join-Path $SkillsDir 'shared'
$NamesTsv  = Join-Path $SkillsDir 'names.tsv'
$DistDir   = Join-Path $RepoRoot 'dist'
$AllLocales = @('fr', 'en')

$script:CheckFailures = 0
function Add-CheckFailure([string]$Message) {
  Write-Host "CHECK FAIL: $Message"
  $script:CheckFailures++
}

# --- Temp-dir tracking, mirroring build.sh's STAGE_MANIFEST + `trap ... EXIT`.
# build.sh registers every mktemp'd dir (the --check out_dir and each per-skill
# stage dir) in a manifest file and sweeps it on EXIT — success, a failing
# check, or die() alike — because die() would otherwise skip a same-scope
# `rm -rf`. The try/finally around the main body below is the PowerShell
# equivalent of that trap: it runs on success, on a failing check, and on a
# thrown error.
$script:TempDirs = [System.Collections.Generic.List[string]]::new()
function New-ManagedTempDir {
  $d = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
  $script:TempDirs.Add($d)
  return $d
}
function Remove-ManagedTempDirs {
  foreach ($d in $script:TempDirs) {
    if (Test-Path -LiteralPath $d) { Remove-Item -Recurse -Force -LiteralPath $d -ErrorAction SilentlyContinue }
  }
}

# --- Read file content the way bash's $(cat file) does: strip trailing
# newline(s) only, leave everything else (including leading whitespace/blank
# lines) untouched. Used wherever build.sh compares via `$(cat ...)` so the
# two scripts agree on where a substring test can and can't match.
function Get-CatLikeContent {
  param([string]$Path)
  $raw = Get-Content -LiteralPath $Path -Raw
  if ($null -eq $raw) { return '' }
  return [regex]::Replace($raw, '(\r\n|\r|\n)+$', '')
}

function Get-FrontmatterField {
  param([string]$Path, [string]$Field)
  $lines = Get-Content -LiteralPath $Path
  if ($lines.Count -eq 0 -or $lines[0] -cne '---') { return '' }
  for ($i = 1; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -ceq '---') { break }
    if ($lines[$i] -clike "${Field}:*") {
      # TrimStart, not Trim: bash's sub("^" field ":[ \t]*", "") strips only
      # the leading run of spaces/tabs after the colon, never trailing
      # whitespace. A plain .Trim() would also eat trailing spaces, giving a
      # different character count for AC2's 1024 cap and a different $desc
      # for AC6 substring tests than build.sh computes for the same file.
      return ($lines[$i].Substring($Field.Length + 1)).TrimStart(' ', "`t")
    }
  }
  return ''
}

function Get-ExpectedName {
  param([string]$Canonical, [string]$Locale)
  # switch -case: default PowerShell switch matching is case-insensitive,
  # unlike bash's `case "$locale" in fr) ... esac`.
  $col = switch -case ($Locale) {
    'fr' { 1 }
    'en' { 2 }
    default { throw "ERROR: unknown locale: $Locale" }
  }
  foreach ($line in Get-Content -LiteralPath $NamesTsv) {
    if (-not $line.Trim()) { continue }
    $parts = $line -split "`t"
    if ($parts[0] -ceq $Canonical) { return $parts[$col] }
  }
  throw "ERROR: skills/names.tsv has no row for '$Canonical'"
}

function Get-SkillList {
  Get-ChildItem -LiteralPath $SkillsDir -Directory |
    Where-Object { $_.Name -cne 'shared' } |
    Select-Object -ExpandProperty Name
}

function Read-LocaleChoice {
  Write-Host 'Quelle langue veux-tu construire ? / Which language do you want to build?'
  Write-Host '  fr  — français'
  Write-Host '  en  — English'
  Write-Host '  all — les deux / both'
  $answer = Read-Host 'fr / en / all [all]'
  if (-not $answer) { $answer = 'all' }
  if ($answer -cnotin @('fr', 'en', 'all')) { throw "ERROR: unrecognized answer: $answer (expected fr, en, or all)" }
  return $answer
}

# --- Stage one skill+locale into $Stage and return the localized name.
function New-SkillStage {
  param([string]$Canonical, [string]$Locale, [string]$Stage)
  $src = Join-Path (Join-Path $SkillsDir $Canonical) $Locale
  $neutral = Join-Path (Join-Path $SkillsDir $Canonical) 'shared'
  $skillMd = Join-Path $src 'SKILL.md'
  # NOTE: ${Locale}: not $Locale: — inside a double-quoted string, PowerShell
  # parses "$word:" as an attempted scope-qualified variable reference (like
  # $env: or $script:) and fails to parse the whole script if the word after
  # $ isn't a valid scope name. ${} disambiguates so the colon is read as a
  # literal character, not the start of a scope reference.
  if (-not (Test-Path -LiteralPath $skillMd)) { throw "ERROR: $Canonical/${Locale}: SKILL.md not found" }

  $name = Get-FrontmatterField -Path $skillMd -Field 'name'
  $expected = Get-ExpectedName -Canonical $Canonical -Locale $Locale
  if (-not $name) { throw "ERROR: $Canonical/${Locale}: frontmatter has no 'name'" }
  if ($name -cne $expected) { throw "ERROR: $Canonical/${Locale}: frontmatter name '$name' != names.tsv '$expected'" }

  if (Test-Path -LiteralPath $Stage) { Remove-Item -Recurse -Force -LiteralPath $Stage }
  New-Item -ItemType Directory -Force -Path (Join-Path $Stage 'references') | Out-Null
  # NOTE (deliberate, unavoidable divergence): build.sh copies with `cp -R
  # "$src/."`, which includes dotfiles. Windows wildcard expansion for
  # Copy-Item -Path '*' has the same effect for name-based dotfiles (Windows
  # "hidden" is an NTFS attribute, not a leading dot), so this line is not
  # expected to drop anything cp wouldn't also copy. No skill source
  # directory in this repo currently contains a dotfile.
  Copy-Item -Recurse -Force -Path (Join-Path $src '*') -Destination $Stage
  # Must be an if, not a one-liner guard — mirrors build.sh's own comment:
  # under strict error handling a false Test-Path must not abort the script.
  if (Test-Path -LiteralPath $neutral) {
    Copy-Item -Recurse -Force -Path (Join-Path $neutral '*') -Destination $Stage
  }
  # Canonical references every skill carries (AC18, AC34).
  Copy-Item -Force -Path (Join-Path (Join-Path $SharedDir $Locale) 'glossary.md') `
                   -Destination (Join-Path $Stage 'references/glossary.md')
  Copy-Item -Force -Path (Join-Path (Join-Path $SharedDir $Locale) 'memory-protocol.md') `
                   -Destination (Join-Path $Stage 'references/memory-protocol.md')

  # AC57 — the annotation is a release-please marker, not skill metadata.
  # Strip it so the packaged SKILL.md carries a clean `version: X.Y.Z`, and a
  # naive frontmatter parser in the skill loader cannot read the version as
  # "0.1.0 # x-release-please-version". Mirrors build.sh's sed in stage_skill.
  #
  # ReadAllText/WriteAllText, not Get-Content/Set-Content: the latter pair
  # would rewrite every line ending as CRLF and change the archive's bytes.
  $stagedMd = Join-Path $Stage 'SKILL.md'
  $text = [System.IO.File]::ReadAllText($stagedMd)
  $text = [regex]::Replace($text, '(?m)^(version: \d+\.\d+\.\d+) # x-release-please-version[ \t]*$', '$1')
  [System.IO.File]::WriteAllText($stagedMd, $text)

  return $name
}

function Build-Locale {
  param([string]$Locale, [string]$OutDir)
  foreach ($canonical in Get-SkillList) {
    $src = Join-Path (Join-Path $SkillsDir $canonical) $Locale
    if (-not (Test-Path -LiteralPath $src)) { continue }
    $stage = New-ManagedTempDir
    $name = New-SkillStage -Canonical $canonical -Locale $Locale -Stage $stage
    $zip = Join-Path $OutDir "$name-$Locale.zip"
    if (Test-Path -LiteralPath $zip) { Remove-Item -Force -LiteralPath $zip }
    # ZIP-root placement (AC1): globbing the stage's *contents* — not the
    # stage directory itself — is what puts SKILL.md at the archive root
    # instead of under a `<guid>/` prefix. Confirmed by inspection: this
    # matches `(cd "$stage" && zip -q -r "$zip" . -x '.*')` in build.sh,
    # which also zips from inside the stage rather than the stage as an entry.
    #
    # NOTE (deliberate, unavoidable divergence): build.sh excludes dotfiles
    # from the archive via `-x '.*'`; Compress-Archive has no equivalent
    # filter and, like the Copy-Item above, would include a name-based
    # dotfile that isn't NTFS-hidden. No skill source currently has one.
    Compress-Archive -Path (Join-Path $stage '*') -DestinationPath $zip
    Write-Host "built $(Split-Path -Leaf $zip)"
    Remove-Item -Recurse -Force -LiteralPath $stage
  }
}

# AC2 — frontmatter contract.
function Test-Frontmatter {
  param([string]$Path)
  $name = Get-FrontmatterField -Path $Path -Field 'name'
  $desc = Get-FrontmatterField -Path $Path -Field 'description'
  $version = Get-FrontmatterField -Path $Path -Field 'version'
  # NOTE: ${Path}: not $Path: — see the ${Locale}: comment in New-SkillStage
  # above; the same double-quoted-string parsing hazard applies here.
  if (-not $name) { Add-CheckFailure "${Path}: frontmatter has no 'name'" }
  if (-not $desc) { Add-CheckFailure "${Path}: frontmatter has no 'description'" }
  if (-not $version) { Add-CheckFailure "${Path}: frontmatter has no 'version'" }
  # Unconditional, like build.sh's bare `[[ "$name" =~ ^[a-z0-9-]+$ ]]`: an
  # empty $name also fails this regex, so a missing name yields two failures
  # here, same as build.sh (not short-circuited by the "has no 'name'" check
  # above).
  if ($name -cnotmatch '^[a-z0-9-]+$') { Add-CheckFailure "${Path}: name '$name' is not [a-z0-9-]+" }
  # PowerShell .Length counts UTF-16 code units, which equals the character
  # count for the accented-Latin text these descriptions use — already
  # character-correct with no change needed. (build.sh's byte-vs-char nuance
  # is handled separately by pinning a UTF-8 locale in CI.)
  $combined = $name.Length + $desc.Length
  if ($combined -gt 1024) {
    Add-CheckFailure "${Path}: name+description is $combined chars, max 1024"
  }
}

# AC4 — the inlined Company Profile pointer must match canonical byte for byte.
# AC18 — the glossary must never be inlined.
function Test-SharedText {
  param([string]$Path, [string]$Locale)
  # build.sh compares via `body="$(cat "$file")"` / `pointer="$(cat ...)"`,
  # and `$(...)` strips only trailing newlines from both sides (not leading
  # whitespace, not internal content). Get-CatLikeContent reproduces exactly
  # that — a plain .Trim() here would also strip leading whitespace/blank
  # lines that bash's $(...) leaves alone, and could make PowerShell accept
  # (or reject) a pointer bash would decide the other way on.
  $body = Get-CatLikeContent -Path $Path
  $pointer = Get-CatLikeContent -Path (Join-Path (Join-Path $SharedDir $Locale) 'profile-pointer.md')
  # True multi-line substring check — same semantics as build.sh's
  # `[[ "$body" != *"$pointer"* ]]`, not a line-oriented `grep -F` (which
  # would OR the pointer's lines instead of requiring the whole block).
  if (-not $body.Contains($pointer)) {
    Add-CheckFailure "${Path}: Company Profile pointer missing or drifted from skills/shared/$Locale/profile-pointer.md"
  }
  # The glossary's title line is a reliable probe for an inlined copy.
  $glossaryProbe = (Get-Content -LiteralPath (Join-Path (Join-Path $SharedDir $Locale) 'glossary.md'))[0]
  if ($body.Contains($glossaryProbe)) {
    Add-CheckFailure "${Path}: glossary content is inlined; it belongs in references/ only"
  }
}

# Fix 1 (drift check extension) — any references/*.md file that echoes the
# profile pointer's opening line must carry the whole pointer, byte-exact —
# not just SKILL.md. atelier-forge inlines the pointer into scaffold.md and
# example-generated-skill.md, and every generated skill inherits whatever is
# in those files, so a drift there is silent until an executive uploads it.
function Test-ReferencePointerDrift {
  param([string]$Canonical, [string]$Locale)
  $refsDir = Join-Path (Join-Path (Join-Path $SkillsDir $Canonical) $Locale) 'references'
  if (-not (Test-Path -LiteralPath $refsDir)) { return }
  $pointer = Get-CatLikeContent -Path (Join-Path (Join-Path $SharedDir $Locale) 'profile-pointer.md')
  $pointerHead = (Get-Content -LiteralPath (Join-Path (Join-Path $SharedDir $Locale) 'profile-pointer.md'))[0]
  # -Filter '*.md' is a coarse pre-filter only; -ceq '.md' below makes the
  # match exact and case-sensitive, same as bash's glob `"$refs_dir"/*.md`.
  foreach ($file in Get-ChildItem -LiteralPath $refsDir -Filter '*.md' -File | Where-Object { $_.Extension -ceq '.md' }) {
    $body = Get-CatLikeContent -Path $file.FullName
    # True multi-line substring check via .Contains() — already ordinal, so
    # already case-sensitive, matching bash's `[[ "$body" == *"$pointer_head"* ]]`.
    if ($body.Contains($pointerHead)) {
      if (-not $body.Contains($pointer)) {
        Add-CheckFailure "$($file.FullName): Company Profile pointer missing or drifted from skills/shared/$Locale/profile-pointer.md"
      }
    }
  }
}

# AC18 / AC34 — the staged references must be byte-identical to canonical.
function Test-StagedReferences {
  param([string]$Stage, [string]$Canonical, [string]$Locale)
  foreach ($file in @('glossary.md', 'memory-protocol.md')) {
    $a = Get-Content -LiteralPath (Join-Path $Stage "references/$file") -Raw
    $b = Get-Content -LiteralPath (Join-Path (Join-Path $SharedDir $Locale) $file) -Raw
    if ($a -cne $b) {
      Add-CheckFailure "$Canonical/${Locale}: staged references/$file differs from skills/shared/$Locale/$file"
    }
  }
}

# AC15 — every skill has at least one scenario per locale.
function Test-Scenarios {
  param([string]$Canonical, [string]$Locale)
  $dir = Join-Path (Join-Path (Join-Path $RepoRoot 'tests') $Canonical) $Locale
  if (-not (Test-Path -LiteralPath $dir)) {
    Add-CheckFailure "tests/$Canonical/$Locale/: no scenario directory"
    return
  }
  # -Filter '*.md' is a coarse pre-filter only: the FileSystem provider's
  # legacy 8.3 short-name matching can also match e.g. '.mdx'/'.markdown',
  # which bash's `find -name '*.md'` never would. -ceq '.md' makes the match
  # exact and case-sensitive, same as bash.
  if (@(Get-ChildItem -LiteralPath $dir -Filter '*.md' -File | Where-Object { $_.Extension -ceq '.md' }).Count -lt 1) {
    Add-CheckFailure "tests/$Canonical/$Locale/: no scenario files"
  }
}

# AC6 — every trigger term a scenario declares appears in that locale's description.
function Test-Triggers {
  param([string]$Canonical, [string]$Locale)
  $dir = Join-Path (Join-Path (Join-Path $RepoRoot 'tests') $Canonical) $Locale
  if (-not (Test-Path -LiteralPath $dir)) { return }
  $skillMd = Join-Path (Join-Path (Join-Path $SkillsDir $Canonical) $Locale) 'SKILL.md'
  $desc = Get-FrontmatterField -Path $skillMd -Field 'description'
  # -Filter '*.md' is a coarse pre-filter only; -ceq '.md' below makes the
  # match exact and case-sensitive, same as bash's `find -name '*.md'`.
  foreach ($scenario in Get-ChildItem -LiteralPath $dir -Filter '*.md' -File | Where-Object { $_.Extension -ceq '.md' }) {
    $lines = Get-Content -LiteralPath $scenario.FullName
    # Matches build.sh's awk guard (`NR == 1 && $0 == "---"`): a scenario
    # file without an opening frontmatter delimiter yields no triggers,
    # not a scan starting mid-file.
    if ($lines.Count -eq 0 -or $lines[0] -cne '---') { continue }
    $collecting = $false
    for ($i = 1; $i -lt $lines.Count; $i++) {
      if ($lines[$i] -ceq '---') { break }
      if ($lines[$i] -ceq 'triggers:') { $collecting = $true; continue }
      if ($collecting) {
        if ($lines[$i] -clike '  - *') {
          # Bare Substring(4), no trim at all: bash's awk `sub(/^  - /, "")`
          # strips only the four-character leading marker `  - ` and leaves
          # everything else — including extra leading/trailing whitespace on
          # the term — untouched. `  - relance ` must still carry its
          # trailing space (and `  -   relance` its extra leading spaces)
          # here too, or AC6's Contains() check disagrees with build.sh's
          # grep -qF.
          $term = $lines[$i].Substring(4)
          if ($term -and -not $desc.Contains($term)) {
            Add-CheckFailure "$($scenario.FullName): trigger '$term' is absent from the $Locale description of $Canonical"
          }
        } else { $collecting = $false }
      }
    }
  }
}

# AC53 — docs/WHATS-NEW.md must carry a `## v<version>` heading whose section
# holds both bilingual labels, each followed by at least one non-empty prose
# line. Mirrors build.sh's check_whats_new, including its "punctuation is not
# prose" rule and its one-failure-then-stop behavior.
function Test-WhatsNew {
  param([string]$Version)
  $rel = 'docs/WHATS-NEW.md'
  $lines = @(Get-Content -LiteralPath (Join-Path $RepoRoot $rel))
  $section = @()
  $inside = $false
  $found = $false
  foreach ($line in $lines) {
    # -ceq: bash's awk `$0 == "## v" ver` is case-sensitive; PowerShell's bare
    # -eq is not.
    if ($line -ceq "## v$Version") { $inside = $true; $found = $true; continue }
    # Ordinal, not the culture-sensitive default of String.StartsWith(String):
    # awk's substr($0, 1, 3) == "## " is a plain byte comparison.
    if ($inside -and $line.StartsWith('## ', [System.StringComparison]::Ordinal)) { $inside = $false }
    if ($inside) { $section += $line }
  }
  if (-not $found) {
    Add-CheckFailure "${rel}: no '## v$Version' heading for the version in version.txt"
    return
  }
  foreach ($label in @('**Français**', '**English**')) {
    $at = -1
    for ($i = 0; $i -lt $section.Count; $i++) {
      # String.Contains(String) is ordinal — case-sensitive, like awk's index().
      if ($section[$i].Contains($label)) { $at = $i; break }
    }
    if ($at -lt 0) {
      Add-CheckFailure "${rel}: the v$Version section has no $label label"
      return
    }
    $rest = $section[$at].Substring($section[$at].IndexOf($label, [System.StringComparison]::Ordinal) + $label.Length)
    # Prose, not punctuation: an em dash or a colon alone is not an entry.
    if ($rest -cmatch '\w') { continue }
    $ok = $false
    for ($i = $at + 1; $i -lt $section.Count; $i++) {
      if ($section[$i].Contains('**Français**') -or $section[$i].Contains('**English**')) { break }
      if ($section[$i] -cmatch '\w') { $ok = $true; break }
    }
    if (-not $ok) {
      Add-CheckFailure "${rel}: the $label label in the v$Version section is followed by no prose"
      return
    }
  }
}

# AC50–AC54, AC59 — the version is computed by release-please, so nothing here
# checks that it is *correct*; it checks that every place declaring it agrees,
# and that a new skill cannot silently opt out of being maintained.
#
# PowerShell parses JSON natively, so this is the short twin of build.sh's
# hand-rolled scanner (AC56 exists for exactly that reason and is bash-only).
function Test-VersionCoherence {
  # AC54 / AC59 — the files this check reads must exist and be non-empty.
  # An early return: with the reference file missing there is nothing left to
  # compare against, and one clear failure beats a cascade.
  foreach ($f in @('version.txt', 'release-please-config.json',
                   '.release-please-manifest.json', 'docs/WHATS-NEW.md', 'README.md')) {
    # NOTE: ${f}: not $f: — see the ${Locale}: comment in New-SkillStage.
    $p = Join-Path $RepoRoot $f
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { Add-CheckFailure "${f}: missing"; return }
    # -Force: without it Get-Item refuses to return a "hidden" item, and on
    # Unix a leading dot *is* hidden — so .release-please-manifest.json would
    # throw here instead of being sized. Harmless on Windows, where hidden is
    # an NTFS attribute no file in this set carries.
    if ((Get-Item -LiteralPath $p -Force).Length -eq 0) { Add-CheckFailure "${f}: empty"; return }
  }

  # AC54 — version.txt holds exactly one SemVer line. ReadAllText plus a manual
  # split, dropping one trailing empty element, so a one-line file with or
  # without a trailing newline both read as 1 — matching awk's NR.
  $raw = [System.IO.File]::ReadAllText((Join-Path $RepoRoot 'version.txt'))
  $vlines = @($raw -split "`r?`n")
  if ($vlines.Count -gt 0 -and $vlines[-1] -eq '') { $vlines = @($vlines[0..($vlines.Count - 2)]) }
  if ($vlines.Count -ne 1 -or $vlines[0] -cnotmatch '^\d+\.\d+\.\d+$') {
    Add-CheckFailure "version.txt: expected exactly one SemVer line, found $($vlines.Count) line(s) starting '$($vlines[0])'"
    return
  }
  $version = $vlines[0]

  # AC54 — both JSON files must parse.
  $config = $null
  foreach ($f in @('release-please-config.json', '.release-please-manifest.json')) {
    $parsed = $null
    try {
      $parsed = Get-Content -LiteralPath (Join-Path $RepoRoot $f) -Raw | ConvertFrom-Json
    } catch {
      Add-CheckFailure "${f}: is not well-formed JSON"
      return
    }
    if ($f -ceq 'release-please-config.json') { $config = $parsed }
  }

  # AC50 / AC51 — every SKILL.md declares the version once, annotated, and
  # equal to version.txt.
  #
  # The segment-count filter is what makes this equal to build.sh's
  # `find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -name SKILL.md`: -Depth 2 caps
  # the recursion at three levels but has no -mindepth, and -Filter is
  # case-insensitive where find -name is not.
  $skillMds = @(Get-ChildItem -LiteralPath $SkillsDir -Recurse -Depth 2 -Filter 'SKILL.md' -File |
    Where-Object { $_.Name -ceq 'SKILL.md' } |
    Where-Object { (($_.FullName.Substring($SkillsDir.Length + 1)) -split '[\\/]').Count -eq 3 } |
    Sort-Object FullName)
  foreach ($file in $skillMds) {
    $rel = ($file.FullName.Substring($RepoRoot.Length + 1)) -replace '\\', '/'
    $lines = @(Get-Content -LiteralPath $file.FullName)
    $fm = @()
    if ($lines.Count -gt 0 -and $lines[0] -ceq '---') {
      for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -ceq '---') { break }
        $fm += $lines[$i]
      }
    }
    # Ordinal StartsWith, mirroring awk's index($0, "version:") == 1.
    $versionLines = @($fm | Where-Object { $_.StartsWith('version:', [System.StringComparison]::Ordinal) })
    if ($versionLines.Count -ne 1) {
      Add-CheckFailure "${rel}: frontmatter has $($versionLines.Count) 'version:' lines, expected exactly 1"
      continue
    }
    # [regex]::Match, not -cnotmatch + $Matches: the automatic $Matches variable
    # is only reliably populated by a *successful* -match, and this needs the
    # capture from a match tested for failure.
    $vm = [regex]::Match($versionLines[0], '^version: (\d+\.\d+\.\d+) # x-release-please-version$')
    if (-not $vm.Success) {
      Add-CheckFailure "${rel}: version line '$($versionLines[0])' must read 'version: <semver> # x-release-please-version'"
      continue
    }
    $declared = $vm.Groups[1].Value
    if ($declared -cne $version) {
      Add-CheckFailure "${rel}: declares version $declared but version.txt says $version"
    }
  }

  # AC52 / AC59 — every SKILL.md and README.md is listed in extra-files exactly
  # once, as type generic.
  $pkg = $null
  if ($config -and $config.packages) { $pkg = $config.packages.'.' }
  $entries = @()
  if ($pkg -and $pkg.'extra-files') { $entries = @($pkg.'extra-files') }

  $wanted = @($skillMds | ForEach-Object {
    ($_.FullName.Substring($RepoRoot.Length + 1)) -replace '\\', '/'
  }) + @('README.md')

  foreach ($rel in $wanted) {
    $matching = @($entries | Where-Object { $_.path -ceq $rel })
    if ($matching.Count -ne 1) {
      Add-CheckFailure "release-please-config.json: extra-files must list $rel exactly once, found $($matching.Count)"
    } elseif ($matching[0].type -cne 'generic') {
      Add-CheckFailure "release-please-config.json: the extra-files entry for $rel is not type 'generic'"
    }
  }

  # Cardinality — extra-files must hold exactly the required set, no more. The
  # loop above only checks that each required path is present; without this, a
  # stale entry for a deleted skill, or an entry for an unrelated file, would
  # sit in the array forever and pass silently — the same hole this whole check
  # exists to close. The required set is computed from the tree above, not
  # hardcoded, so it tracks the skill count automatically.
  foreach ($entry in $entries) {
    $p = $entry.path
    if (-not $p) { continue }
    if ($wanted -cnotcontains $p) {
      Add-CheckFailure "release-please-config.json: extra-files lists $p, which is not a SKILL.md or README.md path"
    }
  }

  # AC59 — README.md carries exactly two annotated lines, each on version.
  $annotated = @(Get-Content -LiteralPath (Join-Path $RepoRoot 'README.md') |
    Where-Object { $_.Contains('x-release-please-version') })
  if ($annotated.Count -ne 2) {
    Add-CheckFailure "README.md: expected exactly 2 x-release-please-version annotations, found $($annotated.Count)"
  }
  foreach ($line in $annotated) {
    # A line with no X.Y.Z at all must still be reported, naming README.md —
    # not skipped and not fatal. $declared is left empty so the comparison
    # below fails normally. (build.sh needs a `|| true` for the same reason.)
    $m = [regex]::Match($line, '\d+\.\d+\.\d+')
    $declared = if ($m.Success) { $m.Value } else { '' }
    if ($declared -cne $version) {
      Add-CheckFailure "README.md: annotated line declares '$declared' but version.txt says $version"
    }
  }

  # AC53 — the bilingual entry exists for this version.
  Test-WhatsNew -Version $version
}

function Invoke-Checks {
  param([string[]]$Locales)
  # Repo-wide, not per-locale: run it once.
  Test-VersionCoherence

  foreach ($locale in $Locales) {
    foreach ($canonical in Get-SkillList) {
      $src = Join-Path (Join-Path $SkillsDir $canonical) $locale
      if (-not (Test-Path -LiteralPath $src)) { continue }
      $skillMd = Join-Path $src 'SKILL.md'
      Test-Frontmatter -Path $skillMd
      Test-SharedText -Path $skillMd -Locale $locale
      Test-Scenarios -Canonical $canonical -Locale $locale
      Test-Triggers -Canonical $canonical -Locale $locale
      Test-ReferencePointerDrift -Canonical $canonical -Locale $locale

      $stage = New-ManagedTempDir
      New-SkillStage -Canonical $canonical -Locale $locale -Stage $stage | Out-Null
      Test-StagedReferences -Stage $stage -Canonical $canonical -Locale $locale
      Remove-Item -Recurse -Force -LiteralPath $stage
    }
  }
  # No `exit` here — see the main body below for why: cleanup must run first.
  if ($script:CheckFailures -gt 0) {
    Write-Host "STATUS: FAIL ($script:CheckFailures check failures)"
  } else {
    Write-Host 'STATUS: PASS (mechanical checks)'
  }
}

if (-not (Test-Path -LiteralPath $NamesTsv)) { throw "ERROR: missing $NamesTsv" }

if (-not $Lang) {
  $Lang = if ($Check) { 'all' } else { Read-LocaleChoice }
}
# -ceq: mirrors bash's `if [[ "$lang" == "all" ]]`. ValidateSet above now
# has IgnoreCase = $false, so a miscased -Lang value (e.g. -Lang All) is
# rejected at parameter-binding time, before this line ever runs — matching
# bash's `case "$lang" in fr|en|all) ;; *) die` for the same input.
$selected = if ($Lang -ceq 'all') { $AllLocales } else { @($Lang) }

if ($Check) {
  # Routed through New-ManagedTempDir (not a bare temp path) so the
  # try/finally below sweeps it on every exit path — a thrown error, a
  # failing check, or success alike — mirroring build.sh's make_stage_dir
  # + EXIT trap for out_dir.
  $outDir = New-ManagedTempDir
} else {
  $outDir = $DistDir
}
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

try {
  foreach ($locale in $selected) { Build-Locale -Locale $locale -OutDir $outDir }

  if ($Check) {
    Invoke-Checks -Locales $selected
  }
} finally {
  Remove-ManagedTempDirs
}

# Deferred until after cleanup: calling `exit` inside the try block above
# would still need the temp dirs removed first, so the failure decision (and
# the process exit) happens only once Remove-ManagedTempDirs has already run.
if ($Check -and $script:CheckFailures -gt 0) {
  exit 1
}

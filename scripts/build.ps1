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
  [ValidateSet('fr', 'en', 'all')]
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
      return ($lines[$i].Substring($Field.Length + 1)).TrimStart()
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
  if (-not (Test-Path -LiteralPath $skillMd)) { throw "ERROR: $Canonical/$Locale: SKILL.md not found" }

  $name = Get-FrontmatterField -Path $skillMd -Field 'name'
  $expected = Get-ExpectedName -Canonical $Canonical -Locale $Locale
  if (-not $name) { throw "ERROR: $Canonical/$Locale: frontmatter has no 'name'" }
  if ($name -cne $expected) { throw "ERROR: $Canonical/$Locale: frontmatter name '$name' != names.tsv '$expected'" }

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
  if (-not $name) { Add-CheckFailure "$Path: frontmatter has no 'name'" }
  if (-not $desc) { Add-CheckFailure "$Path: frontmatter has no 'description'" }
  if (-not $version) { Add-CheckFailure "$Path: frontmatter has no 'version'" }
  # Unconditional, like build.sh's bare `[[ "$name" =~ ^[a-z0-9-]+$ ]]`: an
  # empty $name also fails this regex, so a missing name yields two failures
  # here, same as build.sh (not short-circuited by the "has no 'name'" check
  # above).
  if ($name -cnotmatch '^[a-z0-9-]+$') { Add-CheckFailure "$Path: name '$name' is not [a-z0-9-]+" }
  # PowerShell .Length counts UTF-16 code units, which equals the character
  # count for the accented-Latin text these descriptions use — already
  # character-correct with no change needed. (build.sh's byte-vs-char nuance
  # is handled separately by pinning a UTF-8 locale in CI.)
  $combined = $name.Length + $desc.Length
  if ($combined -gt 1024) {
    Add-CheckFailure "$Path: name+description is $combined chars, max 1024"
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
    Add-CheckFailure "$Path: Company Profile pointer missing or drifted from skills/shared/$Locale/profile-pointer.md"
  }
  # The glossary's title line is a reliable probe for an inlined copy.
  $glossaryProbe = (Get-Content -LiteralPath (Join-Path (Join-Path $SharedDir $Locale) 'glossary.md'))[0]
  if ($body.Contains($glossaryProbe)) {
    Add-CheckFailure "$Path: glossary content is inlined; it belongs in references/ only"
  }
}

# AC18 / AC34 — the staged references must be byte-identical to canonical.
function Test-StagedReferences {
  param([string]$Stage, [string]$Canonical, [string]$Locale)
  foreach ($file in @('glossary.md', 'memory-protocol.md')) {
    $a = Get-Content -LiteralPath (Join-Path $Stage "references/$file") -Raw
    $b = Get-Content -LiteralPath (Join-Path (Join-Path $SharedDir $Locale) $file) -Raw
    if ($a -cne $b) {
      Add-CheckFailure "$Canonical/$Locale: staged references/$file differs from skills/shared/$Locale/$file"
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
          # TrimStart, not Trim: bash keeps trailing whitespace on a term
          # (its awk `sub(/^  - /, "")` only strips the leading marker), so
          # `  - relance ` must still carry its trailing space here too, or
          # AC6's Contains() check disagrees with build.sh's grep -qF.
          $term = $lines[$i].Substring(4).TrimStart()
          if ($term -and -not $desc.Contains($term)) {
            Add-CheckFailure "$($scenario.FullName): trigger '$term' is absent from the $Locale description of $Canonical"
          }
        } else { $collecting = $false }
      }
    }
  }
}

function Invoke-Checks {
  param([string[]]$Locales)
  foreach ($locale in $Locales) {
    foreach ($canonical in Get-SkillList) {
      $src = Join-Path (Join-Path $SkillsDir $canonical) $locale
      if (-not (Test-Path -LiteralPath $src)) { continue }
      $skillMd = Join-Path $src 'SKILL.md'
      Test-Frontmatter -Path $skillMd
      Test-SharedText -Path $skillMd -Locale $locale
      Test-Scenarios -Canonical $canonical -Locale $locale
      Test-Triggers -Canonical $canonical -Locale $locale

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
# -ceq: mirrors bash's `if [[ "$lang" == "all" ]]`. ValidateSet above accepts
# -Lang's value case-insensitively, so this is the one place left where a
# non-lowercase 'all' (e.g. -Lang All) would otherwise be treated as the
# all-locales case on Windows but not on Linux.
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

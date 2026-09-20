#requires -Version 7.0
# Windows counterpart to scripts/tests/build_test.sh's coherence matrix (AC58).
# It deliberately covers only AC50-AC55, AC57 and AC59: the older AC1-AC18
# cases are already asserted on Linux, and AC58 scopes the Windows job to the
# mutations that must behave identically on both platforms.
#
# This file duplicates build_test.sh's matrix nearly line for line. That is
# deliberate: the spec requires the same mutations to run through build.ps1,
# and bash and PowerShell cannot share a test body.
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:Failures = 0
function Add-Failure([string]$m) { Write-Host "FAIL: $m"; $script:Failures++ }
function Add-Pass([string]$m) { Write-Host "ok: $m" }

# LF-only writes: build_test.sh's fixtures are LF-only, and the byte-for-byte
# Company Profile pointer comparison must see the same bytes on both platforms.
# .gitattributes pins `* text=auto eol=lf`, so a Windows checkout is already
# LF; this is belt and braces on top of that.
function Write-Lf([string]$Path, [string]$Text) {
  [System.IO.File]::WriteAllText($Path, ($Text -replace "`r`n", "`n"))
}

# 2026-09-19/AC35 — fixture dates are computed from the run date, never
# written as literals. PowerShell has real date arithmetic, so unlike bash
# this needs no civil-algorithm helper.
function Get-DaysAgo([int]$Days) {
  return (Get-Date).Date.AddDays(-$Days).ToString('yyyy-MM-dd')
}

function Write-Annotation([string]$Dir, [string]$Locale, [string]$Rel, [int]$Days) {
  $d = Get-DaysAgo $Days
  $full = Join-Path $Dir $Rel
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $full) | Out-Null
  if ($Locale -ceq 'en') {
    $body = @"
# Module

Prose above the annotation.

> **Last verified $d** — source: Anthropic help center, article 15520349
> ("Use Claude Cowork on web, desktop, and mobile"). Continuation prose the
> check never reads.

Prose below.
"@
  } else {
    $body = @"
# Module

Prose au-dessus de l'annotation.

> **Vérifié le $d** — source : centre d'aide Anthropic, article 15520349
> (« Use Claude Cowork on web, desktop, and mobile »). Prose de continuation
> que la vérification ne lit jamais.

Prose en dessous.
"@
  }
  Write-Lf $full $body
}

# Build a minimal but valid repo in a temp dir: real build.ps1, real shared
# texts, one two-locale skill with differing localized names, and its scenarios.
function New-FixtureRepo {
  $dir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
  foreach ($sub in @('scripts', 'skills/shared/fr', 'skills/shared/en',
                     'skills/atelier-ventes/fr', 'skills/atelier-ventes/en',
                     'tests/atelier-ventes/fr', 'tests/atelier-ventes/en', 'docs')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $dir $sub) | Out-Null
  }

  Copy-Item -LiteralPath (Join-Path $RepoRoot 'scripts/build.ps1') -Destination (Join-Path $dir 'scripts/build.ps1')
  foreach ($locale in @('fr', 'en')) {
    foreach ($md in Get-ChildItem -LiteralPath (Join-Path $RepoRoot "skills/shared/$locale") -Filter '*.md' -File) {
      # Read + LF-normalize + write rather than Copy-Item, so the canonical
      # shared texts in the fixture carry the same line endings as the
      # SKILL.md files written below. A CRLF pointer against an LF SKILL.md
      # would fail AC4 in the *clean* fixture and mask every real result.
      Write-Lf (Join-Path $dir "skills/shared/$locale/$($md.Name)") ([System.IO.File]::ReadAllText($md.FullName))
    }
  }

  Write-Lf (Join-Path $dir 'skills/names.tsv') "atelier-ventes`tatelier-ventes`tatelier-sales`n"

  $frPointer = ([System.IO.File]::ReadAllText((Join-Path $dir 'skills/shared/fr/profile-pointer.md'))).TrimEnd("`n")
  $enPointer = ([System.IO.File]::ReadAllText((Join-Path $dir 'skills/shared/en/profile-pointer.md'))).TrimEnd("`n")

  Write-Lf (Join-Path $dir 'skills/atelier-ventes/fr/SKILL.md') @"
---
name: atelier-ventes
description: À utiliser quand il est question de pipeline, de relance ou de proposition commerciale.
version: 0.1.0 # x-release-please-version
---

# Ventes

$frPointer
"@

  Write-Lf (Join-Path $dir 'skills/atelier-ventes/en/SKILL.md') @"
---
name: atelier-sales
description: Use when the conversation turns to pipeline, follow-ups, or proposals.
version: 0.1.0 # x-release-please-version
---

# Sales

$enPointer
"@

  Write-Lf (Join-Path $dir 'tests/atelier-ventes/fr/pipeline.md') @"
---
skill: atelier-ventes
locale: fr
triggers:
  - pipeline
---
## Prompt
Passe mon pipeline en revue.
"@

  Write-Lf (Join-Path $dir 'tests/atelier-ventes/en/pipeline.md') @"
---
skill: atelier-sales
locale: en
triggers:
  - pipeline
---
## Prompt
Review my pipeline.
"@

  Write-Lf (Join-Path $dir 'version.txt') "0.1.0`n"

  Write-Lf (Join-Path $dir '.release-please-manifest.json') @"
{
  ".": "0.1.0"
}
"@

  Write-Lf (Join-Path $dir 'release-please-config.json') @"
{
  "include-v-in-tag": true,
  "packages": {
    ".": {
      "release-type": "simple",
      "changelog-path": "CHANGELOG.md",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": false,
      "extra-files": [
        { "type": "generic", "path": "README.md" },
        { "type": "generic", "path": "skills/atelier-ventes/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-ventes/en/SKILL.md" }
      ]
    }
  }
}
"@

  Write-Lf (Join-Path $dir 'README.md') @"
# Fixture

Version 0.1.0 <!-- x-release-please-version -->

Version 0.1.0 <!-- x-release-please-version -->
"@

  Write-Lf (Join-Path $dir 'docs/WHATS-NEW.md') @"
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.

**English** — First release.
"@

  # 2026-09-19/AC10b makes an absent anchor list fatal, so the clean fixture
  # carries one, pointing at one anchored module with a valid annotation.
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'skills/atelier-ventes/en/references/tutorial') | Out-Null
  Write-Lf (Join-Path $dir 'skills/dated-claims.tsv') "skills/atelier-ventes/en/references/tutorial/03.md`n"
  Write-Annotation -Dir $dir -Locale 'en' -Rel 'skills/atelier-ventes/en/references/tutorial/03.md' -Days 10

  # 2026-09-19-headings/AC22 — the fixture carries the registry and the two
  # parallel templates it points at; an absent registry is fatal.
  foreach ($sub in @('skills/atelier-ventes/fr/references', 'skills/atelier-ventes/en/references')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $dir $sub) | Out-Null
  }
  Write-Lf (Join-Path $dir 'skills/atelier-ventes/fr/references/modele.md') @"
# Modèle de revue de pipeline

``````markdown
# Revue de pipeline — <entreprise>

## Où en est le pipeline

## Ce qui bloque

## Prochaines relances
``````
"@
  Write-Lf (Join-Path $dir 'skills/atelier-ventes/en/references/template.md') @"
# Pipeline review template

``````markdown
# Pipeline review — <company>

## Where the pipeline stands

## What is stuck

## Next follow-ups
``````
"@
  Write-Lf (Join-Path $dir 'skills/exec-documents.tsv') `
    ("pipeline-doc`t{root}/docs/ventes/pipeline.md`tskills/atelier-ventes/fr/references/modele.md`t1`tskills/atelier-ventes/en/references/template.md`t1`n")

  return $dir
}

# Run build.ps1 inside a fixture and capture exit status plus combined output.
function Invoke-FixturePwsh([string]$Dir, [string]$ScriptArgs) {
  # Function-scoped assignment, deliberately: a native command writing to
  # stderr while $ErrorActionPreference is 'Stop' can surface as a terminating
  # NativeCommandError instead of ordinary captured text. The fixture's exit
  # code and output are the assertion here, so relax the preference for the
  # duration of the call and let it snap back when the function returns.
  $ErrorActionPreference = 'Continue'
  $out = & pwsh -NoProfile -Command "Set-Location -LiteralPath '$Dir'; ./scripts/build.ps1 $ScriptArgs" 2>&1 | Out-String
  return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $out }
}

function Invoke-FixtureCheck([string]$Dir) { return (Invoke-FixturePwsh $Dir '-Check') }

# Require both a non-zero exit and a named path in the combined output, so a
# fixture that breaks for an unrelated reason cannot pass by accident.
# .Contains() is ordinal, i.e. case-sensitive, matching bash's `grep -qF`.
function Expect-CheckFail([string]$Dir, [string]$Needle, [string]$Label) {
  $r = Invoke-FixtureCheck $Dir
  if ($r.ExitCode -ne 0 -and $r.Output.Contains($Needle)) { Add-Pass $Label }
  else { Add-Failure "$Label (exit=$($r.ExitCode), out=$($r.Output))" }
}

function Edit-File([string]$Path, [scriptblock]$Transform) {
  $text = [System.IO.File]::ReadAllText($Path)
  [System.IO.File]::WriteAllText($Path, (& $Transform $text))
}

# Replace only the first occurrence. PowerShell's -replace operator has no
# count operand; Regex's instance Replace(input, replacement, count) does.
function Update-First([string]$Text, [string]$Pattern, [string]$Replacement) {
  return ([regex]$Pattern).Replace($Text, $Replacement, 1)
}

# --- AC50: a version line without the annotation fails, naming the path
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/fr/SKILL.md') {
  param($t) $t -replace 'version: 0\.1\.0 # x-release-please-version', 'version: 0.1.0' }
Expect-CheckFail $d 'skills/atelier-ventes/fr/SKILL.md' `
  'AC50 rejects a version line without the annotation'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC50: two version: lines in the frontmatter fail, naming the path
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/SKILL.md') {
  param($t) $t -replace 'version: 0\.1\.0 # x-release-please-version',
    ("version: 0.1.0 # x-release-please-version" + "`n" + "version: 0.1.0 # x-release-please-version") }
Expect-CheckFail $d 'skills/atelier-ventes/en/SKILL.md' `
  'AC50 rejects two version: lines in the frontmatter'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC50: no version: line at all fails, naming the path
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/fr/SKILL.md') {
  param($t) $t -replace ('version: 0\.1\.0 # x-release-please-version' + "`n"), '' }
Expect-CheckFail $d 'skills/atelier-ventes/fr/SKILL.md' `
  'AC50 rejects a frontmatter with no version: line'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC50: a malformed SemVer on the annotated line fails, naming the path
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/SKILL.md') {
  param($t) $t -replace 'version: 0\.1\.0 #', 'version: 0.1 #' }
Expect-CheckFail $d 'skills/atelier-ventes/en/SKILL.md' `
  'AC50 rejects a malformed SemVer on the annotated line'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC51: two skills declaring different versions fails, reporting both values
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/SKILL.md') {
  param($t) $t -replace 'version: 0\.1\.0 #', 'version: 0.2.0 #' }
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -ne 0 -and $r.Output.Contains('0.2.0') -and $r.Output.Contains('0.1.0')) {
  Add-Pass 'AC51 rejects mismatched skill versions and reports both values'
} else { Add-Failure "AC51 did not report both disagreeing versions (exit=$($r.ExitCode), out=$($r.Output))" }
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC51: version.txt disagreeing with the skills fails, reporting both values
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'version.txt') "0.3.0`n"
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -ne 0 -and $r.Output.Contains('0.3.0') -and $r.Output.Contains('0.1.0')) {
  Add-Pass 'AC51 rejects a version.txt disagreeing with the skills'
} else { Add-Failure "AC51 did not report the version.txt disagreement (exit=$($r.ExitCode), out=$($r.Output))" }
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC52: a SKILL.md absent from extra-files fails, naming the path
$d = New-FixtureRepo
Edit-File (Join-Path $d 'release-please-config.json') {
  param($t) $t -replace ',\s*\{ "type": "generic", "path": "skills/atelier-ventes/en/SKILL\.md" \}', '' }
Expect-CheckFail $d 'skills/atelier-ventes/en/SKILL.md' `
  'AC52 rejects a SKILL.md absent from extra-files'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC52: an extra-files entry lacking type: generic fails, naming the path
$d = New-FixtureRepo
Edit-File (Join-Path $d 'release-please-config.json') {
  param($t) $t -replace '\{ "type": "generic", "path": "skills/atelier-ventes/fr/SKILL\.md" \}',
    '{ "type": "json", "path": "skills/atelier-ventes/fr/SKILL.md" }' }
Expect-CheckFail $d 'skills/atelier-ventes/fr/SKILL.md' `
  'AC52 rejects an extra-files entry that is not type generic'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC52: an extra-files entry outside the required set fails, naming it
$d = New-FixtureRepo
Edit-File (Join-Path $d 'release-please-config.json') {
  param($t) $t -replace '\{ "type": "generic", "path": "README\.md" \},',
    ('{ "type": "generic", "path": "README.md" },' + "`n" +
     '        { "type": "generic", "path": "docs/WHATS-NEW.md" },') }
Expect-CheckFail $d 'docs/WHATS-NEW.md' `
  'AC52 rejects an extra-files entry outside the required set'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC59: README.md missing an annotation fails, naming README.md
$d = New-FixtureRepo
Edit-File (Join-Path $d 'README.md') {
  param($t) Update-First $t 'Version 0\.1\.0 <!-- x-release-please-version -->' 'Version 0.1.0' }
Expect-CheckFail $d 'README.md' 'AC59 rejects a README with one annotation'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC59: an annotated README line disagreeing with version.txt fails
$d = New-FixtureRepo
Edit-File (Join-Path $d 'README.md') {
  param($t) Update-First $t 'Version 0\.1\.0 <!-- x-release-please-version -->' `
    'Version 0.9.9 <!-- x-release-please-version -->' }
Expect-CheckFail $d 'README.md' `
  'AC59 rejects an annotated README line disagreeing with version.txt'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC59: extra-files without a README.md entry fails, naming README.md
$d = New-FixtureRepo
Edit-File (Join-Path $d 'release-please-config.json') {
  param($t) $t -replace '\{ "type": "generic", "path": "README\.md" \},\s*', '' }
Expect-CheckFail $d 'README.md' 'AC59 rejects extra-files with no README.md entry'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC59: an annotated README line carrying no SemVer at all fails, naming
# the path, and must not abort the script.
$d = New-FixtureRepo
Edit-File (Join-Path $d 'README.md') {
  param($t) Update-First $t 'Version 0\.1\.0 <!-- x-release-please-version -->' `
    '<!-- x-release-please-version -->' }
Expect-CheckFail $d 'README.md' 'AC59 rejects an annotated README line with no SemVer'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC53: a WHATS-NEW heading with an empty section fails, naming the path
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'docs/WHATS-NEW.md') @"
# Quoi de neuf / What's new

## v0.1.0

## v0.0.9

**Français** — Ancienne version.

**English** — Old release.
"@
Expect-CheckFail $d 'docs/WHATS-NEW.md' `
  'AC53 rejects a v0.1.0 heading with an empty section'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC53: a section missing the English half fails, naming the path
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'docs/WHATS-NEW.md') @"
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.
"@
Expect-CheckFail $d 'docs/WHATS-NEW.md' 'AC53 rejects a section with no English half'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC53: a label with no prose after it fails, naming the path
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'docs/WHATS-NEW.md') @"
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.

**English**
"@
Expect-CheckFail $d 'docs/WHATS-NEW.md' 'AC53 rejects a label with no prose after it'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC53: no heading for the current version fails, naming the path
$d = New-FixtureRepo
Edit-File (Join-Path $d 'docs/WHATS-NEW.md') { param($t) $t -replace '## v0\.1\.0', '## v0.0.9' }
Expect-CheckFail $d 'docs/WHATS-NEW.md' `
  "AC53 rejects a WHATS-NEW with no heading for version.txt's version"
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC54: each required file, missing then empty, fails naming that path
foreach ($target in @('version.txt', 'release-please-config.json',
                      '.release-please-manifest.json', 'docs/WHATS-NEW.md', 'README.md')) {
  $d = New-FixtureRepo
  Remove-Item -Force -LiteralPath (Join-Path $d $target)
  Expect-CheckFail $d $target "AC54 rejects a missing $target"
  Remove-Item -Recurse -Force -LiteralPath $d

  $d = New-FixtureRepo
  [System.IO.File]::WriteAllText((Join-Path $d $target), '')
  Expect-CheckFail $d $target "AC54 rejects an empty $target"
  Remove-Item -Recurse -Force -LiteralPath $d
}

# --- AC54: a version.txt with two lines fails, naming version.txt
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'version.txt') "0.1.0`n0.1.0`n"
Expect-CheckFail $d 'version.txt' 'AC54 rejects a two-line version.txt'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC54: a version.txt that is not SemVer fails, naming version.txt
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'version.txt') "v0.1.0`n"
Expect-CheckFail $d 'version.txt' 'AC54 rejects a non-SemVer version.txt'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC54: an unparseable release-please-config.json fails, naming the path
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'release-please-config.json') "{ `"packages`": { `".`": { `"extra-files`": [ }`n"
Expect-CheckFail $d 'release-please-config.json' `
  'AC54 rejects an unparseable release-please-config.json'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC54: an unparseable .release-please-manifest.json fails, naming the path
$d = New-FixtureRepo
Write-Lf (Join-Path $d '.release-please-manifest.json') "{ `".`": `"0.1.0`"`n"
Expect-CheckFail $d '.release-please-manifest.json' `
  'AC54 rejects an unparseable .release-please-manifest.json'
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC55: the clean fixture passes, with the exact PASS line
# -ccontains, not -contains: PowerShell's bare -contains is case-insensitive,
# where bash's `grep -qxF` is not.
$d = New-FixtureRepo
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0 -and ($r.Output -split "`r?`n") -ccontains 'STATUS: PASS (mechanical checks)') {
  Add-Pass 'AC55 clean fixture passes with the exact PASS line'
} else { Add-Failure "AC55 clean fixture did not print the exact PASS line (exit=$($r.ExitCode), out=$($r.Output))" }
Remove-Item -Recurse -Force -LiteralPath $d

# --- AC57: -Lang all strips the annotation from every packaged SKILL.md
$d = New-FixtureRepo
Invoke-FixturePwsh $d '-Lang all' | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zips = @(Get-ChildItem -LiteralPath (Join-Path $d 'dist') -Filter '*.zip' -File -ErrorAction SilentlyContinue)
$bad = $false
if ($zips.Count -eq 0) {
  Add-Failure 'AC57 no ZIPs were produced by -Lang all'
  $bad = $true
}
foreach ($zip in $zips) {
  $archive = [System.IO.Compression.ZipFile]::OpenRead($zip.FullName)
  try {
    foreach ($entry in $archive.Entries) {
      $reader = New-Object System.IO.StreamReader($entry.Open())
      try { $text = $reader.ReadToEnd() } finally { $reader.Dispose() }
      if ($text.Contains('x-release-please-version')) {
        Add-Failure "AC57 $($zip.Name) member $($entry.FullName) still contains x-release-please-version"
        $bad = $true
      }
      # -ceq / -cmatch: entry names and the version line are both load-bearing
      # literals, and PowerShell's bare -eq / -match are case-insensitive.
      if ($entry.FullName -ceq 'SKILL.md' -and $text -cnotmatch '(?m)^version: 0\.1\.0$') {
        Add-Failure "AC57 $($zip.Name) SKILL.md version line is not 'version: 0.1.0'"
        $bad = $true
      }
    }
  } finally { $archive.Dispose() }
}
if (-not $bad) { Add-Pass 'AC57 packaged archives carry a clean version line and no annotation' }
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC4: an English lead-in under /fr/ fails, naming file and line
$d = New-FixtureRepo
Write-Annotation -Dir $d -Locale 'en' -Rel 'skills/atelier-ventes/fr/references/tutorial/03.md' -Days 10
Expect-CheckFail $d 'skills/atelier-ventes/fr/references/tutorial/03.md:5' `
  '2026-09-19/AC4 rejects an English lead-in under /fr/'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC5: a bold span with no date fails, naming file and line
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') {
  param($t) $t -replace '\*\*Last verified \d{4}-\d{2}-\d{2}\*\*', '**Last verified**' }
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md:5' `
  '2026-09-19/AC5 rejects a bold span with no date'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC5: an unclosed bold span fails too
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') {
  param($t) $t -replace '\*\*Last verified (\d{4}-\d{2}-\d{2})\*\* — source:', '**Last verified $1 — source:' }
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md:5' `
  '2026-09-19/AC5 rejects an unclosed bold span'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC6: a date that is not a real calendar day fails
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') {
  param($t) $t -replace '\*\*Last verified \d{4}-\d{2}-\d{2}\*\*', '**Last verified 2026-02-30**' }
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md:5' `
  '2026-09-19/AC6 rejects 2026-02-30'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC7: a future date fails
$d = New-FixtureRepo
Write-Annotation -Dir $d -Locale 'en' -Rel 'skills/atelier-ventes/en/references/tutorial/03.md' -Days -30
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md:5' `
  '2026-09-19/AC7 rejects a future date'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC8: an absent source segment fails
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') {
  param($t) $t -replace '\*\* — source:.*', '** no source segment here' }
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md:5' `
  '2026-09-19/AC8 rejects an absent source segment'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC9: an anchored file carrying no annotation fails
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') "# Module`n`nNo dated claim here.`n"
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md' `
  '2026-09-19/AC9 rejects an anchored file with no dated claim'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC10: an anchored path that does not exist fails
$d = New-FixtureRepo
Add-Content -LiteralPath (Join-Path $d 'skills/dated-claims.tsv') `
  -Value 'skills/atelier-ventes/en/references/tutorial/99-renamed.md'
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/99-renamed.md' `
  '2026-09-19/AC10 rejects an anchored path that does not exist'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC10b: an absent anchor list is fatal
$d = New-FixtureRepo
Remove-Item -Force -LiteralPath (Join-Path $d 'skills/dated-claims.tsv')
Expect-CheckFail $d 'skills/dated-claims.tsv' `
  '2026-09-19/AC10b rejects an absent anchor list'
Remove-Item -Recurse -Force -LiteralPath $d

# --- Fence boundary correctness (adversarial review, post-PR). Mirrors
# build_test.sh's Case A/B/C almost line for line (see that file for the
# CommonMark §4.5 rationale): a naive "```" toggle at column 0 gets fence
# boundaries wrong three ways.

# Case A: an indented closing fence must still close the fence, or a real
# stale annotation right after it vanishes from the scan — the dangerous
# direction, since -CheckFreshness would then pass on an actually-stale claim.
$d = New-FixtureRepo
New-Item -ItemType Directory -Force -Path (Join-Path $d 'skills/atelier-ventes/en/references') | Out-Null
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/fence-case-a.md') @'
# R

```
x
   ```

> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
'@
$r = Invoke-FixtureCheck $d
if ($r.Output.Contains('dated claims: 2 annotations across 2 files')) {
  Add-Pass 'Case A: indented closing fence closes, so the stale annotation after it is seen'
} else {
  Add-Failure "Case A: indented closing fence mishandled (out=$($r.Output))"
}
$rf = Invoke-FixturePwsh $d '-CheckFreshness'
if ($rf.ExitCode -ne 0) {
  Add-Pass 'Case A: -CheckFreshness fails on the now-visible 2020-01-01 claim'
} else {
  Add-Failure "Case A: -CheckFreshness must fail on the now-visible 2020-01-01 claim (exit=$($rf.ExitCode), out=$($rf.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# Case B: a ~~~ fence must be recognized at all, so an example wrapped in one
# is not counted as a real annotation.
$d = New-FixtureRepo
New-Item -ItemType Directory -Force -Path (Join-Path $d 'skills/atelier-ventes/en/references') | Out-Null
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/fence-case-b.md') @'
# R

~~~
> **Last verified 2026-09-15** — source: Anthropic help center, article 12512180
~~~

> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
'@
$r = Invoke-FixtureCheck $d
if ($r.Output.Contains('dated claims: 2 annotations across 2 files')) {
  Add-Pass 'Case B: tilde fence recognized, in-fence example excluded'
} else {
  Add-Failure "Case B: tilde fence not recognized (out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# Case C: an indented opening fence must be recognized too, so an in-fence
# example does not leak in as a real annotation.
$d = New-FixtureRepo
New-Item -ItemType Directory -Force -Path (Join-Path $d 'skills/atelier-ventes/en/references') | Out-Null
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/fence-case-c.md') @'
# R

  ```
> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
  ```
'@
$r = Invoke-FixtureCheck $d
if ($r.Output.Contains('dated claims: 1 annotations across 1 files')) {
  Add-Pass 'Case C: indented opening fence recognized, in-fence example excluded'
} else {
  Add-Failure "Case C: indented opening fence not recognized (out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# Case D (regression: bash-vs-PowerShell divergence found in review of
# c3a28a8): CommonMark 4.5 requires trailing "spaces or tabs" only after a
# closing fence's run of characters — nothing else. A closing candidate
# followed by U+00A0 (NO-BREAK SPACE, a common copy-paste artifact from a
# help-centre page) is not blank under that rule, so the fence must NOT
# close. If it wrongly closed, the stale annotation below would become
# visible and the file's count would jump from 0 to 1.
$d = New-FixtureRepo
New-Item -ItemType Directory -Force -Path (Join-Path $d 'skills/atelier-ventes/en/references') | Out-Null
$nbsp = [char]0x00A0
$emdash = [char]0x2014
$fence = '```'
$content = "# R`n`n$fence`nx`n$fence$nbsp`n`n> **Last verified 2020-01-01** $emdash source: Anthropic help center, article 12512180`n"
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/fence-case-nbsp.md') $content
$r = Invoke-FixtureCheck $d
if ($r.Output.Contains('dated claims: 1 annotations across 1 files')) {
  Add-Pass 'Case D: a closing candidate trailed by U+00A0 does not close the fence'
} else {
  Add-Failure "Case D: a closing candidate trailed by U+00A0 wrongly closed the fence (out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# Case E: an opener carrying an info string (```bash, no space between the
# backticks and the word) still opens a fence — the in-fence example must
# stay excluded.
$d = New-FixtureRepo
New-Item -ItemType Directory -Force -Path (Join-Path $d 'skills/atelier-ventes/en/references') | Out-Null
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/fence-case-info-string.md') @'
# R

```bash
> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
```
'@
$r = Invoke-FixtureCheck $d
if ($r.Output.Contains('dated claims: 1 annotations across 1 files')) {
  Add-Pass 'Case E: an opener with an info string opens a fence'
} else {
  Add-Failure "Case E: an opener with an info string failed to open a fence (out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# Case F: a closing run longer than the opening run still closes the fence.
$d = New-FixtureRepo
New-Item -ItemType Directory -Force -Path (Join-Path $d 'skills/atelier-ventes/en/references') | Out-Null
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/fence-case-longer-close.md') @'
# R

```
> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
````

> **Last verified 2020-01-02** — source: Anthropic help center, article 12512180
'@
$r = Invoke-FixtureCheck $d
if ($r.Output.Contains('dated claims: 2 annotations across 2 files')) {
  Add-Pass 'Case F: a closing fence longer than the opening fence closes it'
} else {
  Add-Failure "Case F: a longer closing fence failed to close (out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# Case G: a closing candidate with trailing non-whitespace text does not
# close the fence.
$d = New-FixtureRepo
New-Item -ItemType Directory -Force -Path (Join-Path $d 'skills/atelier-ventes/en/references') | Out-Null
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/fence-case-trailing-text.md') @'
# R

```
x
``` bash

> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
'@
$r = Invoke-FixtureCheck $d
if ($r.Output.Contains('dated claims: 1 annotations across 1 files')) {
  Add-Pass 'Case G: a closing candidate with trailing text does not close the fence'
} else {
  Add-Failure "Case G: a closing candidate with trailing text wrongly closed the fence (out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# Case H: a 4-space-indented line is an indented code block, not a fence
# opener, so a real annotation right after it must still be seen.
$d = New-FixtureRepo
New-Item -ItemType Directory -Force -Path (Join-Path $d 'skills/atelier-ventes/en/references') | Out-Null
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/fence-case-four-space.md') @'
# R

    ```
> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
'@
$r = Invoke-FixtureCheck $d
if ($r.Output.Contains('dated claims: 2 annotations across 2 files')) {
  Add-Pass 'Case H: a 4-space-indented line does not open a fence'
} else {
  Add-Failure "Case H: a 4-space-indented line wrongly opened a fence (out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# Case I (regression: same root cause as Case D, found sweeping build.ps1 for
# every other place it mirrors awk's `[ \t]` class, in the *opposite, more
# dangerous* direction — a valid file failing CI instead of a stale claim
# staying hidden). CommonMark 4.5's blank test recognizes only literal spaces
# or tabs. A source segment that is only U+00A0 (NBSP) is therefore NOT
# blank, so the annotation is valid and the check must pass.
$d = New-FixtureRepo
New-Item -ItemType Directory -Force -Path (Join-Path $d 'skills/atelier-ventes/en/references/tutorial') | Out-Null
$day = Get-DaysAgo 10
$content = "# Module`n`n> **Last verified $day** $emdash source: $nbsp`n"
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') $content
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0) {
  Add-Pass 'Case I: a source segment of only U+00A0 is not blank, the check passes'
} else {
  Add-Failure "Case I: a source segment of only U+00A0 wrongly failed as no-source (exit=$($r.ExitCode), out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC24: the summary line matches bash's, in both its forms
$d = New-FixtureRepo
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0 -and $r.Output -match 'dated claims: 1 annotations across 1 files, oldest \d{4}-\d{2}-\d{2} \(10 days\)') {
  Add-Pass '2026-09-19/AC24 -Check prints the populated summary line'
} else {
  Add-Failure "2026-09-19/AC24 summary line wrong (exit=$($r.ExitCode), out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

$d = New-FixtureRepo
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') "# Module`n`nNo dated claim here.`n"
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -ne 0 -and $r.Output.Contains('dated claims: 0 annotations across 0 files, no dated claim found')) {
  Add-Pass '2026-09-19/AC24 -Check prints the zero summary line on a failing run'
} else {
  Add-Failure "2026-09-19/AC24 zero summary line wrong (exit=$($r.ExitCode), out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC22: the clean fixture passes
$d = New-FixtureRepo
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0) { Add-Pass '2026-09-19-headings/AC22 clean fixture passes the exec-document rule' }
else { Add-Failure "2026-09-19-headings/AC22 clean fixture failed (out=$($r.Output))" }
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC22 over AC17: a reference file that is gone
$d = New-FixtureRepo
Remove-Item -LiteralPath (Join-Path $d 'skills/atelier-ventes/fr/references/modele.md')
Expect-CheckFail $d 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md' `
  '2026-09-19-headings/AC22 missing reference file reaches the same verdict'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC22 over AC18: a block index the file lacks
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/exec-documents.tsv') {
  param($t) $t -replace "modele\.md`t1", "modele.md`t4" }
Expect-CheckFail $d 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md has no markdown template block 4' `
  '2026-09-19-headings/AC22 missing block index reaches the same verdict'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC23 over AC19: a dropped section
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/fr/references/modele.md') {
  param($t) $t -replace "`n## Ce qui bloque`n", "`n" }
Expect-CheckFail $d 'pipeline-doc — heading counts differ' `
  '2026-09-19-headings/AC23 a dropped section reaches the same verdict'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC22 over AC20: a changed heading depth
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/references/template.md') {
  param($t) $t -replace "`n## What is stuck`n", "`n### What is stuck`n" }
Expect-CheckFail $d 'pipeline-doc — heading levels differ' `
  '2026-09-19-headings/AC22 a changed depth reaches the same verdict'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC22 over AC21: a '-' row is skipped, not failed
$d = New-FixtureRepo
Add-Content -LiteralPath (Join-Path $d 'skills/exec-documents.tsv') `
  -Value "prose-doc`t{root}/docs/atelier/decisions.md`t-`t-`t-`t-"
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0 -and -not $r.Output.Contains('prose-doc')) {
  Add-Pass "2026-09-19-headings/AC22 a '-' row is skipped on Windows too"
} else {
  Add-Failure "2026-09-19-headings/AC22 '-' row not skipped (exit=$($r.ExitCode), out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# --- Review Focus 3b: a CRLF template file is read the same as an LF one
$d = New-FixtureRepo
$mdPath = Join-Path $d 'skills/atelier-ventes/fr/references/modele.md'
$crlfText = ([System.IO.File]::ReadAllText($mdPath)) -replace "`n", "`r`n"
[System.IO.File]::WriteAllText($mdPath, $crlfText)
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0) {
  Add-Pass 'Review Focus 3b a CRLF template file is read the same as an LF one'
} else {
  Add-Failure "Review Focus 3b CRLF template file failed (out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

# --- Review Focus 6: a bash block quoting a markdown opener is not counted
# as a template block. The quoted opener uses four backticks (the bash fence
# itself uses three) so that, were the "enter every fence, target or not"
# behaviour broken, the resulting phantom block would run unclosed to EOF
# (nothing later in the file has a four-backtick bare closer) rather than
# just silently swallowing the wrong content — a difference this check's
# MISSING/UNCLOSED reporting can actually observe.
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/template.md') @"
# Pipeline review template

``````bash
# quoting a template fence opener as an example, not a real block:
````````markdown
``````

``````markdown
# Pipeline review — <company>

## Where the pipeline stands

## What is stuck

## Next follow-ups
``````
"@
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0) {
  Add-Pass 'Review Focus 6 a bash block quoting a markdown opener is not counted as a template block'
} else {
  Add-Failure "Review Focus 6 bash-quoted opener miscounted (out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

Write-Host ''
if ($script:Failures -eq 0) { Write-Host 'STATUS: PASS'; exit 0 }
Write-Host "STATUS: FAIL ($script:Failures)"
exit 1

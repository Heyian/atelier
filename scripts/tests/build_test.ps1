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

Write-Host ''
if ($script:Failures -eq 0) { Write-Host 'STATUS: PASS'; exit 0 }
Write-Host "STATUS: FAIL ($script:Failures)"
exit 1

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
.PARAMETER CheckFreshness
  Validate every dated capability claim and fail if the oldest has passed the
  freshness threshold. Builds nothing and writes nothing to dist/. Mirrors
  build.sh's --check-freshness. No CI job calls this on Windows by design; it
  exists so the twin stays a twin.
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
  [switch]$Check,
  [switch]$CheckFreshness
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

# --- 2026-09-19/AC14 — the two staleness thresholds, named once.
$ReportAgeDays = 180
$FailAgeDays   = 365

$DatedClaimsTsv = Join-Path $SkillsDir 'dated-claims.tsv'
$script:DatedClaimRecords = @()

# --- Fence boundary helpers, mirroring build.sh's awk functions of the same
# shape (scan/detection criteria: AC12, AC13). CommonMark 4.5, not a bare
# "```" toggle: 0-3 leading spaces then 3+ of the SAME backtick-or-tilde
# character opens a fence; the same character, at least as many of them, 0-3
# leading spaces, and nothing but whitespace after it closes one. A fence
# left open at EOF stays open — that is correct, not a bug.
function Get-FenceMarker([string]$Line) {
  $lead = 0
  while ($lead -lt 3 -and $Line.Length -gt $lead -and $Line[$lead] -eq ' ') { $lead++ }
  if ($Line.Length -le $lead) { return '' }
  $ch = $Line[$lead]
  if ($ch -ne '`' -and $ch -ne '~') { return '' }
  return $Line.Substring($lead)
}
function Get-FenceRunLength([string]$Marker, [char]$Ch) {
  $i = 0
  while ($i -lt $Marker.Length -and $Marker[$i] -eq $Ch) { $i++ }
  return $i
}
function Test-FenceCloses([string]$Line, [char]$FenceChar, [int]$FenceLen) {
  $marker = Get-FenceMarker $Line
  if ($marker -eq '' -or $marker[0] -ne $FenceChar) { return $false }
  $runLen = Get-FenceRunLength $marker $FenceChar
  if ($runLen -lt $FenceLen) { return $false }
  # CommonMark 4.5 allows only trailing spaces or tabs here, not the full
  # .NET IsWhiteSpace category — a plain .Trim() also strips U+00A0
  # (NO-BREAK SPACE) and other Unicode whitespace, over-closing a fence that
  # awk's `gsub(/[ \t]/, "", rest)` twin correctly leaves open.
  return ($marker.Substring($runLen) -replace '[ \t]', '') -eq ''
}

# --- 2026-09-19-headings/AC14 — the exec-facing document registry.
$ExecDocsTsv = Join-Path $SkillsDir 'exec-documents.tsv'

# ATX heading level, mirroring build.sh's atx_level(): 0-3 leading spaces,
# 1-6 '#', then a space, a tab, or end of line.
function Get-AtxLevel([string]$Line) {
  $lead = 0
  while ($lead -lt 3 -and $lead -lt $Line.Length -and $Line[$lead] -eq ' ') { $lead++ }
  $n = 0
  while (($lead + $n) -lt $Line.Length -and $Line[$lead + $n] -eq '#') { $n++ }
  if ($n -lt 1 -or $n -gt 6) { return 0 }
  if (($lead + $n) -ge $Line.Length) { return $n }
  $c = $Line[$lead + $n]
  if ($c -ne ' ' -and $c -ne "`t") { return 0 }
  return $n
}

# The heading levels of the Want-th ```markdown block, space-joined. Returns
# 'MISSING' or 'UNCLOSED' exactly as build.sh's exec_doc_headings does.
function Get-TemplateBlockHeadings([string]$Path, [int]$Want) {
  # $fenceChar / $fenceLen are assigned when a fence opens and read only while
  # $inFence is true, the same shape Get-DatedClaimRecords uses above.
  $seen = 0; $inFence = $false; $target = $false; $found = $false; $closed = $false
  $levels = New-Object System.Collections.Generic.List[string]

  foreach ($raw in [System.IO.File]::ReadAllLines($Path)) {
    $line = $raw -replace "`r$", ''

    if ($inFence) {
      if (Test-FenceCloses $line $fenceChar $fenceLen) {
        if ($target) { $closed = $true; $target = $false }
        $inFence = $false
        continue
      }
      if ($target) {
        $lvl = Get-AtxLevel $line
        if ($lvl -gt 0) { $levels.Add([string]$lvl) }
      }
      continue
    }

    $marker = Get-FenceMarker $line
    if ($marker -eq '') { continue }
    $markerChar = $marker[0]
    $markerLen = Get-FenceRunLength $marker $markerChar
    if ($markerLen -lt 3) { continue }
    $info = ($marker.Substring($markerLen)) -replace '[ \t]', ''
    # Enter every fence, target or not: a ```bash block quoting a ```markdown
    # opener must not be counted as one.
    $inFence = $true; $fenceChar = $markerChar; $fenceLen = $markerLen; $target = $false
    if ($info -ceq 'markdown') {
      $seen++
      if ($seen -eq $Want -and -not $found) { $target = $true; $found = $true }
    }
  }

  if (-not $found) { return 'MISSING' }
  if (-not $closed) { return 'UNCLOSED' }
  return ($levels -join ' ')
}

# The heading levels AND text of the Want-th ```markdown block, one heading
# per line as "<level> <text>". Same MISSING / UNCLOSED sentinels as
# Get-TemplateBlockHeadings. Mirrors build.sh's exec_doc_heading_text.
function Get-TemplateBlockHeadingText([string]$Path, [int]$Want) {
  $seen = 0; $inFence = $false; $target = $false; $found = $false; $closed = $false
  $rows = New-Object System.Collections.Generic.List[string]

  foreach ($raw in [System.IO.File]::ReadAllLines($Path)) {
    $line = $raw -replace "`r$", ''

    if ($inFence) {
      if (Test-FenceCloses $line $fenceChar $fenceLen) {
        if ($target) { $closed = $true; $target = $false }
        $inFence = $false
        continue
      }
      if ($target) {
        $lvl = Get-AtxLevel $line
        if ($lvl -gt 0) {
          # Mirror atx_text(): up to three leading spaces, then the marker,
          # then whatever whitespace separates marker from text.
          $lead = 0
          while ($lead -lt 3 -and $lead -lt $line.Length -and $line[$lead] -eq ' ') { $lead++ }
          $rest = $line.Substring($lead + $lvl)
          $rest = $rest -replace '^[ \t]+', ''
          $rows.Add("$lvl $rest")
        }
      }
      continue
    }

    $marker = Get-FenceMarker $line
    if ($marker -eq '') { continue }
    $markerChar = $marker[0]
    $markerLen = Get-FenceRunLength $marker $markerChar
    if ($markerLen -lt 3) { continue }
    $info = ($marker.Substring($markerLen)) -replace '[ \t]', ''
    $inFence = $true; $fenceChar = $markerChar; $fenceLen = $markerLen; $target = $false
    if ($info -ceq 'markdown') {
      $seen++
      if ($seen -eq $Want -and -not $found) { $target = $true; $found = $true }
    }
  }

  # Unary comma: without it, PowerShell enumerates the returned array onto
  # the output stream, and a single-element or single-heading result would
  # collapse to a bare string in the caller ($raw[$side][0] then indexes a
  # CHARACTER of that string, not the sentinel) instead of staying an array.
  if (-not $found) { return , @('MISSING') }
  if (-not $closed) { return , @('UNCLOSED') }
  return , $rows.ToArray()
}

function ConvertTo-TableCell([string]$Text) { return ($Text -replace '\|', '\|') }

# One templated registry row's group. Throws on every condition build.sh's
# emit_exec_heading_group die()s on, with the same message text.
function Write-ExecHeadingGroup {
  param([string]$DocId, [string]$Path, [string]$FrRef, [string]$FrBlock,
        [string]$EnRef, [string]$EnBlock)

  $refs   = @{ fr = $FrRef;   en = $EnRef }
  $blocks = @{ fr = $FrBlock; en = $EnBlock }

  foreach ($side in @('fr', 'en')) {
    $full = Join-Path $RepoRoot $refs[$side]
    # -PathType Leaf, not a bare Test-Path: mirrors bash's `[[ -f ]]`, which a
    # directory fails. A bare Test-Path would call the directory present and
    # let ReadAllLines below crash on it instead of raising this message.
    if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
      throw "ERROR: $DocId — $($refs[$side]) listed in skills/exec-documents.tsv but no such file (renamed?)"
    }
    if ($blocks[$side] -notmatch '^[1-9][0-9]*$') {
      throw "ERROR: $DocId — $($refs[$side]) template block index '$($blocks[$side])' is not a positive integer"
    }
  }

  $raw = @{}
  foreach ($side in @('fr', 'en')) {
    $raw[$side] = Get-TemplateBlockHeadingText (Join-Path $RepoRoot $refs[$side]) ([int]$blocks[$side])
    if ($raw[$side].Count -eq 1 -and $raw[$side][0] -ceq 'MISSING') {
      throw "ERROR: $DocId — $($refs[$side]) has no markdown template block $($blocks[$side])"
    }
    if ($raw[$side].Count -eq 1 -and $raw[$side][0] -ceq 'UNCLOSED') {
      throw "ERROR: $DocId — $($refs[$side]) template block $($blocks[$side]) is never closed"
    }
  }

  $fr = $raw['fr']; $en = $raw['en']
  if ($fr.Count -ne $en.Count) {
    throw "ERROR: $DocId — heading counts differ: $FrRef has $($fr.Count), $EnRef has $($en.Count)"
  }

  $frLevels = (@($fr | ForEach-Object { $_.Split(' ', 2)[0] }) -join ' ')
  $enLevels = (@($en | ForEach-Object { $_.Split(' ', 2)[0] }) -join ' ')
  if ($frLevels -cne $enLevels) {
    throw "ERROR: $DocId — heading levels differ: $FrRef [$frLevels], $EnRef [$enLevels]"
  }

  $rows = New-Object System.Collections.Generic.List[string]
  for ($i = 0; $i -lt $fr.Count; $i++) {
    $parts = $fr[$i].Split(' ', 2)
    $lvl = [int]$parts[0]
    if ($lvl -lt 2) { continue }
    $marker = '#' * $lvl
    $frText = ConvertTo-TableCell $parts[1]
    $enText = ConvertTo-TableCell $en[$i].Split(' ', 2)[1]
    $rows.Add("| $marker $frText | $marker $enText |")
  }
  if ($rows.Count -eq 0) { return '' }

  $sb = "`n## $DocId`n`n``$Path```n`n| Français | English |`n| --- | --- |`n"
  foreach ($r in $rows) { $sb += "$r`n" }
  return $sb
}

# Mirrors build.sh's generate_exec_heading_pairs. WriteAllText with explicit
# "`n" joins, never Set-Content: the latter would rewrite every line ending
# as CRLF and break AC21's byte-identity.
function New-ExecHeadingPairs {
  param([string]$Locale, [string]$OutPath)

  if (-not (Test-Path -LiteralPath $ExecDocsTsv)) {
    throw 'ERROR: skills/exec-documents.tsv — exec-facing document registry not found'
  }
  $preamble = Join-Path (Join-Path $SharedDir $Locale) 'exec-document-headings.md'
  if (-not (Test-Path -LiteralPath $preamble)) {
    throw "ERROR: skills/shared/$Locale/exec-document-headings.md not found"
  }

  $text = [System.IO.File]::ReadAllText($preamble)

  $lineNo = 0
  foreach ($rawLine in [System.IO.File]::ReadAllLines($ExecDocsTsv)) {
    $lineNo++
    $raw = $rawLine -replace "`r$", ''
    if ($raw -eq '') { continue }

    $cols = $raw.Split("`t")
    if ($cols.Count -ne 6) {
      throw "ERROR: skills/exec-documents.tsv:$lineNo — expected 6 tab-separated columns, found $($cols.Count)"
    }

    $docId = $cols[0]; $path = $cols[1]
    $dashes = @($cols[2], $cols[3], $cols[4], $cols[5] | Where-Object { $_ -ceq '-' }).Count
    if ($dashes -eq 4) { continue }
    if ($dashes -ne 0) {
      throw "ERROR: $docId — template columns are partly '-': a document described in prose carries '-' in all four"
    }

    $text += Write-ExecHeadingGroup -DocId $docId -Path $path `
      -FrRef $cols[2] -FrBlock $cols[3] -EnRef $cols[4] -EnBlock $cols[5]
  }

  [System.IO.File]::WriteAllText($OutPath, $text)
}

# 2026-09-19-headings/AC22 — the same verdicts as build.sh's
# check_exec_documents, from the same registry.
function Test-ExecDocuments {
  if (-not (Test-Path -LiteralPath $ExecDocsTsv)) {
    Add-CheckFailure 'skills/exec-documents.tsv — exec-facing document registry not found'
    return
  }

  $lineNo = 0
  foreach ($raw in [System.IO.File]::ReadAllLines($ExecDocsTsv)) {
    $lineNo++
    $line = $raw -replace "`r$", ''
    if ($line -eq '') { continue }

    $cols = $line -split "`t"
    if ($cols.Count -ne 6) {
      Add-CheckFailure "skills/exec-documents.tsv:$lineNo — expected 6 tab-separated columns, found $($cols.Count)"
      continue
    }

    $docId = $cols[0]
    $refs = @{ fr = $cols[2]; en = $cols[4] }
    $blocks = @{ fr = $cols[3]; en = $cols[5] }

    # The inner @(...) is load-bearing: without it the pipeline would bind to
    # $cols[5] alone and every row would count at most one dash.
    $dashes = @(@($cols[2], $cols[3], $cols[4], $cols[5]) | Where-Object { $_ -ceq '-' }).Count
    if ($dashes -eq 4) { continue }
    if ($dashes -ne 0) {
      Add-CheckFailure "$docId — template columns are partly '-': a document described in prose carries '-' in all four"
      continue
    }
    if ($refs.fr -ceq $refs.en) {
      Add-CheckFailure "$docId — names the same reference file for both locales: $($refs.fr)"
      continue
    }

    $ok = $true
    foreach ($side in @('fr', 'en')) {
      $full = Join-Path $RepoRoot $refs[$side]
      if (-not (Test-Path -LiteralPath $full -PathType Leaf)) {
        Add-CheckFailure "$docId — $($refs[$side]) listed in skills/exec-documents.tsv but no such file (renamed?)"
        $ok = $false; continue
      }
      if ($blocks[$side] -notmatch '^[1-9][0-9]*$') {
        Add-CheckFailure "$docId — $($refs[$side]) template block index '$($blocks[$side])' is not a positive integer"
        $ok = $false; continue
      }
    }
    if (-not $ok) { continue }

    $levels = @{}
    foreach ($side in @('fr', 'en')) {
      $levels[$side] = Get-TemplateBlockHeadings (Join-Path $RepoRoot $refs[$side]) ([int]$blocks[$side])
      switch ($levels[$side]) {
        'MISSING'  { Add-CheckFailure "$docId — $($refs[$side]) has no markdown template block $($blocks[$side])"; $ok = $false }
        'UNCLOSED' { Add-CheckFailure "$docId — $($refs[$side]) template block $($blocks[$side]) is never closed"; $ok = $false }
      }
    }
    if (-not $ok) { continue }

    # 2026-09-19-headings/AC19, AC20 — identical sequence of heading levels.
    if ($levels.fr -cne $levels.en) {
      $frN = @($levels.fr -split ' ' | Where-Object { $_ -ne '' }).Count
      $enN = @($levels.en -split ' ' | Where-Object { $_ -ne '' }).Count
      if ($frN -ne $enN) {
        Add-CheckFailure "$docId — heading counts differ: $($refs.fr) has $frN, $($refs.en) has $enN"
      } else {
        Add-CheckFailure "$docId — heading levels differ: $($refs.fr) [$($levels.fr)], $($refs.en) [$($levels.en)]"
      }
    }
  }
}

# --- 2026-09-19/AC12, AC13, AC3b — every *.md at any depth under
# skills/<skill>/<locale>/references/, in lexicographic repo-relative order.
#
# Divergence from build.sh: PowerShell has real DateTime parsing, so the civil
# algorithm build.sh inlines into awk (because `date -d` is GNU-only) has no
# counterpart here. ParseExact with a fixed 'yyyy-MM-dd' format doubles as the
# calendar-validity test — 2026-02-30 throws.
function Get-DatedClaimRecords {
  $records = [System.Collections.Generic.List[object]]::new()
  $today = (Get-Date).Date

  $files = foreach ($canonical in Get-SkillList) {
    foreach ($locale in $AllLocales) {
      $dir = Join-Path (Join-Path (Join-Path $SkillsDir $canonical) $locale) 'references'
      if (-not (Test-Path -LiteralPath $dir)) { continue }
      foreach ($f in Get-ChildItem -LiteralPath $dir -Filter '*.md' -File -Recurse) {
        [pscustomobject]@{
          Rel    = ($f.FullName.Substring($RepoRoot.Length + 1) -replace '\\', '/')
          Full   = $f.FullName
          Locale = $locale
        }
      }
    }
  }

  # 2026-09-19/AC3b, AC24 — ordinal sort, not Sort-Object -CaseSensitive
  # (which is still culture-aware: a hyphen sorts differently than under
  # `LC_ALL=C sort`, the byte-exact order build.sh's scan order relies on).
  # List<T>.Sort with an explicit ordinal comparison is a stable-enough(*)
  # substitute — (*) List<T>.Sort is an unstable introsort, but Rel is
  # unique per file so no tie ever needs breaking here.
  $filesArr = [System.Collections.Generic.List[object]]::new(@($files))
  $filesArr.Sort([Comparison[object]]{ param($a, $b) [string]::CompareOrdinal($a.Rel, $b.Rel) })
  foreach ($file in $filesArr) {
    if ($file.Locale -ceq 'en') {
      $lead = '> **Last verified '; $sep = '** — source: '
      $own  = 'Last verified';      $other = 'Vérifié le'
    } else {
      $lead = '> **Vérifié le ';    $sep = '** — source : '
      $own  = 'Vérifié le';         $other = 'Last verified'
    }

    $lineNo = 0
    $fence = $false
    foreach ($raw in [System.IO.File]::ReadAllLines($file.Full)) {
      $lineNo++
      $line = $raw -replace "`r$", ''
      # Ordinal, not the culture-sensitive default of String.StartsWith(String)
      # — 2026-09-19/AC3b, AC4: the culture-aware overload ignores zero-weight
      # characters (e.g. U+200B), which would let a malformed lead-in through
      # that bash's byte-exact substr() comparison correctly rejects.
      if ($fence) {
        if (Test-FenceCloses $line $fenceChar $fenceLen) { $fence = $false }
        continue
      }
      $marker = Get-FenceMarker $line
      if ($marker -ne '') {
        $markerChar = $marker[0]
        $markerLen = Get-FenceRunLength $marker $markerChar
        if ($markerLen -ge 3) { $fence = $true; $fenceChar = $markerChar; $fenceLen = $markerLen; continue }
      }
      if (-not $line.StartsWith('> **', [System.StringComparison]::Ordinal)) { continue }

      $hasOwn = $line.Contains($own)
      $hasOther = $line.Contains($other)
      if (-not $hasOwn -and -not $hasOther) { continue }

      $verdict = 'ok'; $date = ''
      if (-not $hasOwn) {
        $verdict = 'wrong-locale'
      } elseif (-not $line.StartsWith($lead, [System.StringComparison]::Ordinal)) {
        $verdict = 'bad-leadin'
      } else {
        $rest = $line.Substring($lead.Length)
        if ($rest.Length -lt 10) {
          $verdict = 'no-date'
        } else {
          $date = $rest.Substring(0, 10)
          $tail = $rest.Substring(10)
          $parsed = [datetime]::MinValue
          if (-not [datetime]::TryParseExact($date, 'yyyy-MM-dd',
                [cultureinfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::None, [ref]$parsed)) {
            # Shape-right-but-impossible and shape-wrong are different
            # failures (2026-09-19/AC5 vs AC6), so separate them here the way
            # build.sh's awk does.
            if ($date -match '^\d{4}-\d{2}-\d{2}$') { $verdict = 'bad-date' }
            else { $verdict = 'no-date'; $date = '' }
          } elseif ($parsed -gt $today) {
            $verdict = 'future-date'
          } elseif (-not $tail.StartsWith($sep, [System.StringComparison]::Ordinal)) {
            $verdict = 'no-source'
          } elseif (($tail.Substring($sep.Length) -replace '[ \t]', '') -eq '') {
            # Same class as the fence closer above: only spaces/tabs count as
            # blank here, matching build.sh:353's `gsub(/[ \t]/, "", src)`. A
            # plain .Trim() also strips U+00A0 and other Unicode whitespace,
            # so a source segment that is only a stray NBSP reads as present
            # in bash (verdict "ok") but empty in PowerShell (verdict
            # "no-source") — a false CI failure on a valid file.
            $verdict = 'no-source'
          }
        }
      }

      $records.Add([pscustomobject]@{
        Rel = $file.Rel; Line = $lineNo; Locale = $file.Locale
        Date = $date; Verdict = $verdict
      })
    }
  }
  return , $records.ToArray()
}

# --- 2026-09-19/AC4–AC8
function Test-DatedClaims {
  $script:DatedClaimRecords = Get-DatedClaimRecords
  foreach ($r in $script:DatedClaimRecords) {
    switch ($r.Verdict) {
      'ok' { }
      'wrong-locale' { Add-CheckFailure "$($r.Rel):$($r.Line) — carries the other locale's verified lead-in (this file is $($r.Locale))" }
      'bad-leadin'   { Add-CheckFailure "$($r.Rel):$($r.Line) — malformed verified lead-in for locale $($r.Locale)" }
      'no-date'      { Add-CheckFailure "$($r.Rel):$($r.Line) — verified annotation has no YYYY-MM-DD in its bold span" }
      'bad-date'     { Add-CheckFailure "$($r.Rel):$($r.Line) — '$($r.Date)' is not a real calendar day" }
      'future-date'  { Add-CheckFailure "$($r.Rel):$($r.Line) — verified date '$($r.Date)' is later than today ($((Get-Date).Date.ToString('yyyy-MM-dd')))" }
      'no-source'    { Add-CheckFailure "$($r.Rel):$($r.Line) — verified annotation names no source after the em dash" }
      default        { Add-CheckFailure "$($r.Rel):$($r.Line) — unrecognized dated-claim verdict '$($r.Verdict)'" }
    }
  }
  Test-DatedClaimAnchors
}

# --- 2026-09-19/AC9, AC10, AC10b, AC26 — never hard-codes an anchor path.
function Test-DatedClaimAnchors {
  if (-not (Test-Path -LiteralPath $DatedClaimsTsv)) {
    Add-CheckFailure 'skills/dated-claims.tsv — anchor list not found'
    return
  }
  $detected = @{}
  foreach ($r in $script:DatedClaimRecords) { $detected[$r.Rel] = $true }
  foreach ($raw in [System.IO.File]::ReadAllLines($DatedClaimsTsv)) {
    $p = ($raw -split "`t")[0].TrimEnd("`r")
    # 2026-09-19/AC24 — match bash's `[[ -n "$p" ]] || continue`: only a
    # genuinely empty line is skipped. A whitespace-only line is not empty,
    # so it falls through and gets reported as a missing path, same as bash.
    if ($p -eq '') { continue }
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $p) -PathType Leaf)) {
      Add-CheckFailure "$p — listed in skills/dated-claims.tsv but no such file (renamed?)"
      continue
    }
    if (-not $detected.ContainsKey($p)) {
      Add-CheckFailure "$p — listed in skills/dated-claims.tsv but carries no dated claim"
    }
  }
}

# --- 2026-09-19/AC15, AC15b, AC15c, AC16, AC17. Never touches
# $script:CheckFailures: age alone must not redden a pull request (AC23).
function Show-DatedClaimReport {
  $valid = @($script:DatedClaimRecords | Where-Object { $_.Verdict -ceq 'ok' })
  if ($valid.Count -eq 0) {
    Write-Host 'dated claims: 0 annotations across 0 files, no dated claim found'
    return
  }
  $today = (Get-Date).Date
  # 2026-09-19/AC15, AC24 — Select-Object -Unique has no -CaseSensitive
  # switch (that belongs to Sort-Object), and its own comparer is not
  # guaranteed ordinal, so two reference paths differing only in case could
  # collapse to one file here while awk's case-sensitive files[$1] counts
  # two. A HashSet<string> with an explicit ordinal comparer matches awk's
  # associative-array semantics exactly, on any PowerShell version.
  $fileSet = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::Ordinal)
  foreach ($r in $valid) { [void]$fileSet.Add($r.Rel) }
  $fileCount = $fileSet.Count
  # 2026-09-19/AC3b, AC24 — Sort-Object is NOT stable by default (confirmed
  # on pwsh 7.4.6: with a tied minimum key it can return an element well
  # after the first tied one in scan order). -Stable is required to keep the
  # first tied record in scan order, matching bash's strict `<` comparison
  # in report_dated_claims's awk (scripts/build.sh:404), which only replaces
  # the running oldest on dn < oldestDays.
  $oldest = $valid | Sort-Object -Stable -Property { [datetime]::ParseExact($_.Date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture) } | Select-Object -First 1
  $age = ($today - [datetime]::ParseExact($oldest.Date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)).Days
  Write-Host "dated claims: $($valid.Count) annotations across $fileCount files, oldest $($oldest.Date) ($age days)"
  if ($script:CheckFailures -eq 0 -and $age -ge $ReportAgeDays) {
    Write-Host "NOTE: oldest dated claim is $age days old (report threshold $ReportAgeDays) —"
    Write-Host "      $($oldest.Rel):$($oldest.Line)"
    Write-Host '      see docs/tutorial-corpus.md, "Claims to re-verify"'
  }
}

# --- 2026-09-19/AC19–AC22
function Invoke-FreshnessCheck {
  Test-DatedClaims
  if ($script:CheckFailures -gt 0) {
    Write-Host "STATUS: FAIL ($script:CheckFailures check failures)"
    return 1
  }
  $today = (Get-Date).Date
  $aged = foreach ($r in ($script:DatedClaimRecords | Where-Object { $_.Verdict -ceq 'ok' })) {
    $age = ($today - [datetime]::ParseExact($r.Date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)).Days
    [pscustomobject]@{ Rel = $r.Rel; Line = $r.Line; Date = $r.Date; Age = $age }
  }
  if (-not ($aged | Where-Object { $_.Age -ge $FailAgeDays })) {
    Write-Host "dated claims: every claim is younger than $FailAgeDays days"
    return 0
  }
  Write-Host "Dated capability claims are past the freshness threshold (fail threshold $FailAgeDays days,"
  Write-Host "listing everything at or over $ReportAgeDays days):"
  foreach ($a in ($aged | Where-Object { $_.Age -ge $ReportAgeDays })) {
    Write-Host "  $($a.Rel):$($a.Line) $($a.Date) ($($a.Age) days)"
  }
  return 1
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

  # 2026-09-20-heading-pairs/AC1 — generated per stage, never checked in.
  New-ExecHeadingPairs -Locale $Locale `
    -OutPath (Join-Path $Stage 'references/exec-document-headings.md')

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
  # 2026-09-19/AC13 — the scanner finds its own files, so it runs once here.
  Test-DatedClaims

  # 2026-09-19-headings/AC16 — the registry names its own files, so this runs
  # once here rather than inside the per-skill, per-locale loop below.
  Test-ExecDocuments

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
  # 2026-09-19/AC15 — before STATUS:, on every run that reaches it.
  Show-DatedClaimReport

  # No `exit` here — see the main body below for why: cleanup must run first.
  if ($script:CheckFailures -gt 0) {
    Write-Host "STATUS: FAIL ($script:CheckFailures check failures)"
  } else {
    Write-Host 'STATUS: PASS (mechanical checks)'
  }
}

if (-not (Test-Path -LiteralPath $NamesTsv)) { throw "ERROR: missing $NamesTsv" }

# 2026-09-19/AC19 — stages nothing and writes nothing to dist/, so it returns
# before any of the build machinery below. No managed temp dir is created, so
# there is nothing for Remove-ManagedTempDirs to sweep.
if ($CheckFreshness) {
  exit (Invoke-FreshnessCheck)
}

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

$script:FatalError = $null
try {
  foreach ($locale in $selected) { Build-Locale -Locale $locale -OutDir $outDir }

  if ($Check) {
    Invoke-Checks -Locales $selected
  }
} catch {
  # 2026-09-20-heading-pairs — mirrors bash's die(): a single line on stderr,
  # then exit 1. Left to PowerShell's default terminating-error formatter,
  # an uncaught throw prints a multi-line "Exception: ... Line | ..." block
  # that word-wraps the message itself at the host's width, splitting a long
  # die() message across lines and breaking any caller that greps for the
  # exact text (as scripts/tests/build_test.ps1's Expect-CheckFail does).
  $script:FatalError = $_.Exception.Message
} finally {
  Remove-ManagedTempDirs
}

# Deferred until after cleanup: calling `exit` inside the try block above
# would still need the temp dirs removed first, so the failure decision (and
# the process exit) happens only once Remove-ManagedTempDirs has already run.
if ($script:FatalError) {
  Write-Host $script:FatalError
  exit 1
}
if ($Check -and $script:CheckFailures -gt 0) {
  exit 1
}

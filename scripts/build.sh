#!/usr/bin/env bash
# Atelier build — assembles one uploadable ZIP per skill per locale into dist/.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
SHARED_DIR="$SKILLS_DIR/shared"
NAMES_TSV="$SKILLS_DIR/names.tsv"
DIST_DIR="$REPO_ROOT/dist"
LOCALES=(fr en)

die() { echo "ERROR: $*" >&2; exit 1; }

# --- Staging dirs are mktemp'd throughout the script; die() exits before any
# per-call `rm -rf` runs, so track every one in a manifest file and sweep them
# on exit. A file (not an array) is required: make_stage_dir is invoked as
# `x="$(make_stage_dir)"`, which runs in a subshell, so an array append there
# would never be visible to the parent shell.
STAGE_MANIFEST="$(mktemp)"
cleanup_stage_dirs() {
  local d
  while IFS= read -r d; do
    [[ -n "$d" ]] && rm -rf "$d"
  done < "$STAGE_MANIFEST"
  rm -f "$STAGE_MANIFEST"
}
trap cleanup_stage_dirs EXIT

make_stage_dir() {
  local d
  d="$(mktemp -d)"
  echo "$d" >> "$STAGE_MANIFEST"
  echo "$d"
}

usage() {
  cat <<'EOF'
Usage: build.sh [--lang fr|en|all] [--check]

  --lang fr|en|all   Build that locale without prompting.
  --check            Run the mechanical checks only; build to a temp dir and
                     leave dist/ untouched. Exits non-zero on any failure.

With no --lang, the script asks which language to build.
EOF
}

# --- Read one frontmatter field from a SKILL.md.
# Frontmatter is the block between the first two '---' lines.
frontmatter_field() {
  local file="$1" field="$2"
  awk -v field="$field" '
    NR == 1 && $0 == "---" { inside = 1; next }
    inside && $0 == "---" { exit }
    inside {
      if (index($0, field ":") == 1) {
        sub("^" field ":[ \t]*", "")
        print
        exit
      }
    }
  ' "$file"
}

# --- Look up a skill's expected localized name from names.tsv.
expected_name() {
  local canonical="$1" locale="$2" col
  case "$locale" in
    fr) col=2 ;;
    en) col=3 ;;
    *) die "unknown locale: $locale" ;;
  esac
  awk -F'\t' -v c="$canonical" -v col="$col" '$1 == c { print $col; found = 1; exit }
    END { if (!found) exit 1 }' "$NAMES_TSV" \
    || die "skills/names.tsv has no row for '$canonical'"
}

list_skills() {
  local d
  for d in "$SKILLS_DIR"/*/; do
    d="$(basename "$d")"
    [[ "$d" == "shared" ]] && continue
    echo "$d"
  done
}

prompt_for_locales() {
  local answer
  echo "Quelle langue veux-tu construire ? / Which language do you want to build?" >&2
  echo "  fr  — français" >&2
  echo "  en  — English" >&2
  echo "  all — les deux / both" >&2
  printf 'fr / en / all [all]: ' >&2
  read -r answer || answer=""
  answer="${answer:-all}"
  case "$answer" in
    fr|en|all) echo "$answer" ;;
    *) die "unrecognized answer: $answer (expected fr, en, or all)" ;;
  esac
}

# --- Stage one skill+locale into $1 and emit the localized name on stdout.
stage_skill() {
  local canonical="$1" locale="$2" stage="$3"
  local src="$SKILLS_DIR/$canonical/$locale"
  local neutral="$SKILLS_DIR/$canonical/shared"

  [[ -f "$src/SKILL.md" ]] || die "$canonical/$locale: SKILL.md not found"

  local name expected
  name="$(frontmatter_field "$src/SKILL.md" name)"
  expected="$(expected_name "$canonical" "$locale")"
  [[ -n "$name" ]] || die "$canonical/$locale: frontmatter has no 'name'"
  [[ "$name" == "$expected" ]] \
    || die "$canonical/$locale: frontmatter name '$name' != names.tsv '$expected'"

  rm -rf "$stage"
  mkdir -p "$stage/references"
  cp -R "$src/." "$stage/"
  # Must be an if, not `[[ ]] && cp` — under `set -e` a false test would abort.
  if [[ -d "$neutral" ]]; then cp -R "$neutral/." "$stage/"; fi

  # Canonical references every skill carries (AC18, AC34).
  cp "$SHARED_DIR/$locale/glossary.md" "$stage/references/glossary.md"
  cp "$SHARED_DIR/$locale/memory-protocol.md" "$stage/references/memory-protocol.md"

  # AC57 — the annotation is a release-please marker, not skill metadata.
  # Strip it so the packaged SKILL.md carries a clean `version: X.Y.Z`, and
  # a naive frontmatter parser in the skill loader cannot read the version as
  # "0.1.0 # x-release-please-version". The temp file lives inside $stage, so
  # the EXIT trap sweeps it on any failure path.
  sed 's/^\(version: [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\) # x-release-please-version[[:space:]]*$/\1/' \
    "$stage/SKILL.md" > "$stage/SKILL.md.tmp"
  mv "$stage/SKILL.md.tmp" "$stage/SKILL.md"

  echo "$name"
}

build_locale() {
  local locale="$1" out_dir="$2" canonical stage name zip
  for canonical in $(list_skills); do
    [[ -d "$SKILLS_DIR/$canonical/$locale" ]] || continue
    stage="$(make_stage_dir)"
    name="$(stage_skill "$canonical" "$locale" "$stage")"
    zip="$out_dir/$name-$locale.zip"
    rm -f "$zip"
    ( cd "$stage" && zip -q -r "$zip" . -x '.*' )
    echo "built $(basename "$zip")"
    rm -rf "$stage"
  done
}

main() {
  local lang="" check=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lang) [[ $# -ge 2 ]] || die "--lang needs a value"; lang="$2"; shift 2 ;;
      --lang=*) lang="${1#--lang=}"; shift ;;
      --check) check=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  [[ -f "$NAMES_TSV" ]] || die "missing $NAMES_TSV"

  if [[ -z "$lang" ]]; then
    if [[ "$check" -eq 1 ]]; then
      lang="all"
    else
      lang="$(prompt_for_locales)"
    fi
  fi
  case "$lang" in
    fr|en|all) ;;
    *) die "--lang must be fr, en, or all (got '$lang')" ;;
  esac

  local selected=()
  if [[ "$lang" == "all" ]]; then selected=("${LOCALES[@]}"); else selected=("$lang"); fi

  local out_dir
  if [[ "$check" -eq 1 ]]; then
    # Routed through make_stage_dir (not a bare mktemp -d) so the EXIT trap
    # sweeps it on every exit path — die(), a failing check, or success alike.
    out_dir="$(make_stage_dir)"
  else
    out_dir="$DIST_DIR"
    mkdir -p "$out_dir"
  fi

  local locale
  for locale in "${selected[@]}"; do
    build_locale "$locale" "$out_dir"
  done

  if [[ "$check" -eq 1 ]]; then
    run_checks "$out_dir" "${selected[@]}"
  fi
}

CHECK_FAILURES=0
check_fail() { echo "CHECK FAIL: $*" >&2; CHECK_FAILURES=$((CHECK_FAILURES + 1)); }

# --- 2026-09-19/AC14 — the two staleness thresholds, named once. Nothing
# else in this script may write either threshold's day count as a bare
# literal.
REPORT_AGE_DAYS=180
FAIL_AGE_DAYS=365

DATED_CLAIMS_TSV="$SKILLS_DIR/dated-claims.tsv"
TODAY_YMD="$(date +%Y-%m-%d)"

# The day-number conversion every dated-claim awk shares. `date -d` is
# GNU-only and would break for a contributor on macOS (2026-09-19/AC18), so
# the civil algorithm is inlined into each awk program that needs it.
DATED_CLAIMS_AWK_LIB='
function days_from_civil(y, m, d,   era, yoe, doy, doe) {
  if (m <= 2) y -= 1
  era = int((y >= 0 ? y : y - 399) / 400)
  yoe = y - era * 400
  doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
  doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
  return era * 146097 + doe - 719468
}
function ymd_to_days(s) {
  return days_from_civil(substr(s, 1, 4) + 0, substr(s, 6, 2) + 0, substr(s, 9, 2) + 0)
}
function real_calendar_day(y, m, d,   dim) {
  if (m < 1 || m > 12 || d < 1) return 0
  dim = 31
  if (m == 4 || m == 6 || m == 9 || m == 11) dim = 30
  else if (m == 2) dim = ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 29 : 28
  return d <= dim
}
'

# --- 2026-09-19/AC12, AC13 — every *.md at any depth under
# skills/<skill>/<locale>/references/, for every skill in names.tsv and both
# locales, and nothing outside that set. Emitted in lexicographic path order
# (2026-09-19/AC3b); LC_ALL=C so the order does not depend on the locale the
# contributor happens to run under.
dated_claims_files() {
  local canonical locale dir
  for canonical in $(list_skills); do
    for locale in "${LOCALES[@]}"; do
      dir="$SKILLS_DIR/$canonical/$locale/references"
      [[ -d "$dir" ]] || continue
      find "$dir" -type f -name '*.md' -print
    done
  done | LC_ALL=C sort
}

# --- Scan one file, emitting one TSV record per detected annotation.
#
# Detection is deliberately looser than validation (Decision §1): a line
# beginning `> **` that carries EITHER locale's marker is detected, then must
# satisfy its own locale's full pattern. If the strict pattern were also the
# detector, a typo in a date would make the line invisible and the check would
# report one fewer annotation rather than failing.
scan_one_dated_claim_file() {
  local file="$1" rel locale lead sep own other
  rel="${file#"$REPO_ROOT"/}"

  # The locale is the segment directly under the skill directory, not just any
  # /en/ or /fr/ in the path — skills/x/en/references/fr/notes.md is legal and
  # is an English file.
  locale="$(awk -F/ '{ for (i = 1; i < NF; i++) if ($i == "skills") { print $(i + 2); exit } }' <<<"$rel")"
  case "$locale" in
    en) lead='> **Last verified '; sep='** — source: '; own='Last verified'; other='Vérifié le' ;;
    fr) lead='> **Vérifié le ';    sep='** — source : '; own='Vérifié le';   other='Last verified' ;;
    *) return 0 ;;
  esac

  awk -v rel="$rel" -v locale="$locale" -v lead="$lead" -v sep="$sep" \
      -v own="$own" -v other="$other" -v today="$TODAY_YMD" \
      "$DATED_CLAIMS_AWK_LIB"'
    BEGIN { todayDays = ymd_to_days(today) }
    {
      line = $0
      sub(/\r$/, "", line)          # a CRLF checkout must behave like an LF one

      # A fenced block quoting the pattern (docs/AUTHORING.md mirrors it) is
      # an example, not an annotation.
      if (substr(line, 1, 3) == "```") { fence = !fence; next }
      if (fence) next

      if (substr(line, 1, 4) != "> **") next
      hasOwn = index(line, own) > 0
      hasOther = index(line, other) > 0
      if (!hasOwn && !hasOther) next

      verdict = "ok"; date = ""
      if (!hasOwn) {
        verdict = "wrong-locale"
      } else if (substr(line, 1, length(lead)) != lead) {
        verdict = "bad-leadin"
      } else {
        rest = substr(line, length(lead) + 1)
        date = substr(rest, 1, 10)
        tail = substr(rest, 11)
        if (date !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) {
          verdict = "no-date"; date = ""
        } else if (!real_calendar_day(substr(date,1,4)+0, substr(date,6,2)+0, substr(date,9,2)+0)) {
          verdict = "bad-date"
        } else if (ymd_to_days(date) > todayDays) {
          verdict = "future-date"
        } else if (substr(tail, 1, length(sep)) != sep) {
          verdict = "no-source"
        } else {
          src = substr(tail, length(sep) + 1)
          gsub(/[ \t]/, "", src)
          if (src == "") verdict = "no-source"
        }
      }
      printf "%s\t%d\t%s\t%s\t%s\n", rel, FNR, locale, date, verdict
    }
  ' "$file"
}

scan_dated_claims() {
  local f
  while IFS= read -r f; do
    [[ -n "$f" ]] && scan_one_dated_claim_file "$f"
  done < <(dated_claims_files)
}

DATED_CLAIMS_RECORDS=""

# --- 2026-09-19/AC4–AC8 — every detected line that fails its locale's pattern
# is a check failure naming the file and line, never a line the scan passes
# over.
check_dated_claims() {
  DATED_CLAIMS_RECORDS="$(scan_dated_claims)"
  local rel line locale date verdict
  while IFS=$'\t' read -r rel line locale date verdict; do
    [[ -n "$rel" ]] || continue
    case "$verdict" in
      ok) ;;
      wrong-locale) check_fail "$rel:$line — carries the other locale's verified lead-in (this file is $locale)" ;;
      bad-leadin)   check_fail "$rel:$line — malformed verified lead-in for locale $locale" ;;
      no-date)      check_fail "$rel:$line — verified annotation has no YYYY-MM-DD in its bold span" ;;
      bad-date)     check_fail "$rel:$line — '$date' is not a real calendar day" ;;
      future-date)  check_fail "$rel:$line — verified date '$date' is later than today ($TODAY_YMD)" ;;
      no-source)    check_fail "$rel:$line — verified annotation names no source after the em dash" ;;
      *)            check_fail "$rel:$line — unrecognized dated-claim verdict '$verdict'" ;;
    esac
  done <<<"$DATED_CLAIMS_RECORDS"
  check_dated_claims_anchors
}

# --- 2026-09-19/AC9, AC10, AC10b — the weaker, mechanically decidable version
# of ADR-0011's real rule. No script can decide whether a sentence is
# capability-sensitive, but it can notice that a module known to be full of
# such claims has ended up with none.
check_dated_claims_anchors() {
  if [[ ! -f "$DATED_CLAIMS_TSV" ]]; then
    check_fail "skills/dated-claims.tsv — anchor list not found"
    return
  fi
  local p
  while IFS= read -r p || [[ -n "$p" ]]; do
    p="${p%%$'\t'*}"     # single-column today, but tolerate a second column
    p="${p%$'\r'}"       # a CRLF checkout must not append \r to the path
    [[ -n "$p" ]] || continue
    if [[ ! -f "$REPO_ROOT/$p" ]]; then
      check_fail "$p — listed in skills/dated-claims.tsv but no such file (renamed?)"
      continue
    fi
    # "Detected", not "valid": a malformed annotation still counts here and
    # fails separately through check_dated_claims, so one broken annotation
    # does not produce two failures for the same line.
    if ! grep -qF -- "$p"$'\t' <<<"$DATED_CLAIMS_RECORDS"; then
      check_fail "$p — listed in skills/dated-claims.tsv but carries no dated claim"
    fi
  done < "$DATED_CLAIMS_TSV"
}

# --- 2026-09-19/AC15, AC15b, AC15c, AC16, AC17 — one summary line before
# every STATUS: line, plus a note once the oldest claim reaches the report
# threshold. Never touches CHECK_FAILURES: age alone must not redden a pull
# request (2026-09-19/AC23), and the only way to guarantee that is for the
# reporter to have no path to a failure at all.
report_dated_claims() {
  local summary n nf oldest age loc
  summary="$(awk -F'\t' -v today="$TODAY_YMD" "$DATED_CLAIMS_AWK_LIB"'
    BEGIN { todayDays = ymd_to_days(today) }
    $5 == "ok" {
      n++
      files[$1] = 1
      dn = ymd_to_days($4)
      # Strict <, so a tie keeps the FIRST record in scan order
      # (2026-09-19/AC3b); scan_dated_claims emits in that order.
      if (n == 1 || dn < oldestDays) { oldestDays = dn; oldestYmd = $4; loc = $1 ":" $2 }
    }
    END {
      nf = 0
      for (f in files) nf++
      if (n == 0) { printf "0\t0\t\t\t\n"; exit }
      printf "%d\t%d\t%s\t%d\t%s\n", n, nf, oldestYmd, todayDays - oldestDays, loc
    }
  ' <<<"$DATED_CLAIMS_RECORDS")"

  IFS=$'\t' read -r n nf oldest age loc <<<"$summary"

  if [[ "$n" -eq 0 ]]; then
    # 2026-09-19/AC15c — the run where the pattern stopped matching entirely
    # is precisely the one worth seeing this line on.
    echo "dated claims: 0 annotations across 0 files, no dated claim found"
    return
  fi

  echo "dated claims: $n annotations across $nf files, oldest $oldest ($age days)"

  # 2026-09-19/AC16 — the note rides on a passing run only; on a failing run
  # the check failures are the message.
  if [[ "$CHECK_FAILURES" -eq 0 ]] && [[ "$age" -ge "$REPORT_AGE_DAYS" ]]; then
    echo "NOTE: oldest dated claim is $age days old (report threshold $REPORT_AGE_DAYS) —"
    echo "      $loc"
    echo "      see docs/tutorial-corpus.md, \"Claims to re-verify\""
  fi
}

# --- Minimal JSON support, hand-rolled on purpose.
# AC56 requires --check to run with jq off PATH, and the repo has no other
# JSON dependency, so these two helpers cover exactly what the coherence
# check needs and nothing more.

# Well-formedness, not validity: balanced braces/brackets, correctly paired
# quotes, no string spanning a line break. Enough to catch a truncated or
# hand-mangled file, which is what AC54's "malformed" case means here.
json_wellformed() {
  awk '
    { s = s $0 "\n" }
    END {
      depth = 0; instr = 0; esc = 0
      n = length(s)
      for (i = 1; i <= n; i++) {
        c = substr(s, i, 1)
        if (instr) {
          if (esc) { esc = 0 }
          else if (c == "\\") { esc = 1 }
          else if (c == "\"") { instr = 0 }
          else if (c == "\n") { exit 1 }
          continue
        }
        if (c == "\"") { instr = 1; continue }
        if (c == "{") { stack[++depth] = "{"; continue }
        if (c == "[") { stack[++depth] = "["; continue }
        if (c == "}") { if (depth == 0 || stack[depth] != "{") exit 1; depth--; continue }
        if (c == "]") { if (depth == 0 || stack[depth] != "[") exit 1; depth--; continue }
      }
      if (instr || depth != 0) exit 1
      exit 0
    }
  ' "$1"
}

# Emit one line per `extra-files` array element: the object body, with
# newlines flattened to spaces so each entry stays on one line.
extra_files_entries() {
  awk '
    { s = s $0 "\n" }
    END {
      i = index(s, "\"extra-files\"")
      if (i == 0) exit 0
      s = substr(s, i)
      j = index(s, "[")
      if (j == 0) exit 0
      s = substr(s, j + 1)
      depth = 0; instr = 0; esc = 0; buf = ""
      n = length(s)
      for (k = 1; k <= n; k++) {
        c = substr(s, k, 1)
        if (instr) {
          buf = buf c
          if (esc) { esc = 0 }
          else if (c == "\\") { esc = 1 }
          else if (c == "\"") { instr = 0 }
          continue
        }
        if (c == "\"") { instr = 1; buf = buf c; continue }
        if (c == "{") { depth++; if (depth == 1) { buf = ""; continue } }
        else if (c == "}") { depth--; if (depth == 0) { print buf; buf = ""; continue } }
        else if (c == "]" && depth == 0) { break }
        if (depth >= 1) {
          if (c == "\n" || c == "\r" || c == "\t") c = " "
          buf = buf c
        }
      }
    }
  ' "$1"
}

# Pull one string-valued field out of a single extra-files object body.
json_string_field() {
  sed -n 's/.*"'"$2"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$1" | head -1
}

# AC53 — docs/WHATS-NEW.md must carry a `## v<version>` heading whose section
# holds both bilingual labels, each followed by at least one non-empty prose
# line. This is the forcing function: on a release PR version.txt has moved
# and this file has not, so CI lands red until a human writes the entry.
check_whats_new() {
  local version="$1" rel="docs/WHATS-NEW.md" verdict
  verdict="$(awk -v ver="$version" '
    $0 == "## v" ver { inside = 1; found = 1; next }
    { if (inside && substr($0, 1, 3) == "## ") inside = 0 }
    inside { sec[++n] = $0 }
    END {
      if (!found) { print "no-heading"; exit }
      for (l = 1; l <= 2; l++) {
        label = (l == 1) ? "**Français**" : "**English**"
        at = 0
        for (i = 1; i <= n; i++) { if (index(sec[i], label) > 0) { at = i; break } }
        if (at == 0) { print "no-label:" label; exit }
        rest = substr(sec[at], index(sec[at], label) + length(label))
        # Prose, not punctuation: an em dash or a colon alone is not an entry.
        if (rest ~ /[[:alnum:]]/) continue
        ok = 0
        for (i = at + 1; i <= n; i++) {
          if (index(sec[i], "**Français**") > 0 || index(sec[i], "**English**") > 0) break
          if (sec[i] ~ /[[:alnum:]]/) { ok = 1; break }
        }
        if (!ok) { print "no-prose:" label; exit }
      }
      print "ok"
    }
  ' "$REPO_ROOT/$rel")"

  case "$verdict" in
    ok) ;;
    no-heading)  check_fail "$rel: no '## v$version' heading for the version in version.txt" ;;
    no-label:*)  check_fail "$rel: the v$version section has no ${verdict#no-label:} label" ;;
    no-prose:*)  check_fail "$rel: the ${verdict#no-prose:} label in the v$version section is followed by no prose" ;;
    *)           check_fail "$rel: could not validate the v$version section" ;;
  esac
}

# AC50–AC54, AC59 — the version is computed by release-please, so nothing here
# checks that it is *correct*; it checks that every place declaring it agrees,
# and that a new skill cannot silently opt out of being maintained.
check_version_coherence() {
  local f version vcount tsv body t p rel line declared found n_any n_generic required_paths

  # AC54 / AC59 — the files this check reads must exist and be non-empty.
  # An early return: with the reference file missing there is nothing left to
  # compare against, and one clear failure beats a cascade.
  for f in version.txt release-please-config.json .release-please-manifest.json \
           docs/WHATS-NEW.md README.md; do
    if [[ ! -f "$REPO_ROOT/$f" ]]; then check_fail "$f: missing"; return; fi
    if [[ ! -s "$REPO_ROOT/$f" ]]; then check_fail "$f: empty"; return; fi
  done

  # AC54 — version.txt holds exactly one SemVer line. awk's NR counts a final
  # line with no trailing newline, so a one-line file with or without one
  # both read as 1.
  vcount="$(awk 'END { print NR }' "$REPO_ROOT/version.txt")"
  version="$(head -1 "$REPO_ROOT/version.txt")"
  if [[ "$vcount" -ne 1 ]] || [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    check_fail "version.txt: expected exactly one SemVer line, found $vcount line(s) starting '$version'"
    return
  fi

  # AC54 — both JSON files must parse.
  for f in release-please-config.json .release-please-manifest.json; do
    if ! json_wellformed "$REPO_ROOT/$f"; then
      check_fail "$f: is not well-formed JSON"
      return
    fi
  done

  # AC50 / AC51 — every SKILL.md declares the version once, annotated, and
  # equal to version.txt.
  while IFS= read -r f; do
    rel="${f#"$REPO_ROOT"/}"
    found="$(awk '
      NR == 1 && $0 == "---" { inside = 1; next }
      inside && $0 == "---" { exit }
      inside && index($0, "version:") == 1 { n++ }
      END { print n + 0 }
    ' "$f")"
    if [[ "$found" -ne 1 ]]; then
      check_fail "$rel: frontmatter has $found 'version:' lines, expected exactly 1"
      continue
    fi
    line="$(awk '
      NR == 1 && $0 == "---" { inside = 1; next }
      inside && $0 == "---" { exit }
      inside && index($0, "version:") == 1 { print; exit }
    ' "$f")"
    if [[ ! "$line" =~ ^version:\ ([0-9]+\.[0-9]+\.[0-9]+)\ \#\ x-release-please-version$ ]]; then
      check_fail "$rel: version line '$line' must read 'version: <semver> # x-release-please-version'"
      continue
    fi
    declared="${BASH_REMATCH[1]}"
    if [[ "$declared" != "$version" ]]; then
      check_fail "$rel: declares version $declared but version.txt says $version"
    fi
  done < <(find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -name SKILL.md -type f | sort)

  # AC52 / AC59 — every SKILL.md and README.md is listed in extra-files
  # exactly once, as type generic.
  tsv=""
  while IFS= read -r body; do
    [[ -z "$body" ]] && continue
    p="$(json_string_field "$body" path)"
    t="$(json_string_field "$body" type)"
    [[ -z "$p" ]] && continue
    tsv+="$t"$'\t'"$p"$'\n'
  done < <(extra_files_entries "$REPO_ROOT/release-please-config.json")

  required_paths="$( { find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -name SKILL.md -type f \
                | while IFS= read -r f; do printf '%s\n' "${f#"$REPO_ROOT"/}"; done \
                | sort; echo "README.md"; } )"

  while IFS= read -r rel; do
    n_any="$(printf '%s' "$tsv" | awk -F'\t' -v p="$rel" '$2 == p { n++ } END { print n + 0 }')"
    n_generic="$(printf '%s' "$tsv" | awk -F'\t' -v p="$rel" '$1 == "generic" && $2 == p { n++ } END { print n + 0 }')"
    if [[ "$n_any" -ne 1 ]]; then
      check_fail "release-please-config.json: extra-files must list $rel exactly once, found $n_any"
    elif [[ "$n_generic" -ne 1 ]]; then
      check_fail "release-please-config.json: the extra-files entry for $rel is not type 'generic'"
    fi
  done <<<"$required_paths"

  # Cardinality — extra-files must hold exactly the required set, no more.
  # The loop above only checks that each required path is present; without
  # this, a stale entry for a deleted skill, or an entry for an unrelated
  # file, would sit in the array forever and pass silently — the same hole
  # this whole check exists to close. The required set is computed from the
  # tree above, not hardcoded, so it tracks the skill count automatically.
  while IFS= read -r p; do
    [[ -z "$p" ]] && continue
    if ! grep -qxF "$p" <<<"$required_paths"; then
      check_fail "release-please-config.json: extra-files lists $p, which is not a SKILL.md or README.md path"
    fi
  done < <(printf '%s' "$tsv" | awk -F'\t' '{ print $2 }')

  # AC59 — README.md carries exactly two annotated lines, each on version.
  n_any="$(grep -cF 'x-release-please-version' "$REPO_ROOT/README.md" || true)"
  if [[ "$n_any" -ne 2 ]]; then
    check_fail "README.md: expected exactly 2 x-release-please-version annotations, found $n_any"
  fi
  while IFS= read -r line; do
    # `|| true`: under set -euo pipefail, a line with no X.Y.Z at all makes
    # `grep -o` exit 1 and pipefail would abort this assignment (and the
    # whole script) before check_fail ever ran. Tolerate zero matches so
    # `declared` is empty, the comparison below fails normally, and the
    # offending path is still named in the output.
    declared="$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' <<<"$line" | head -1 || true)"
    if [[ "$declared" != "$version" ]]; then
      check_fail "README.md: annotated line declares '$declared' but version.txt says $version"
    fi
  done < <(grep -F 'x-release-please-version' "$REPO_ROOT/README.md" || true)

  # AC53 — the bilingual entry exists for this version.
  check_whats_new "$version"
}

# AC2 — frontmatter contract.
check_frontmatter() {
  local file="$1" name desc version combined
  name="$(frontmatter_field "$file" name)"
  desc="$(frontmatter_field "$file" description)"
  version="$(frontmatter_field "$file" version)"

  [[ -n "$name" ]] || check_fail "$file: frontmatter has no 'name'"
  [[ -n "$desc" ]] || check_fail "$file: frontmatter has no 'description'"
  [[ -n "$version" ]] || check_fail "$file: frontmatter has no 'version'"
  [[ "$name" =~ ^[a-z0-9-]+$ ]] || check_fail "$file: name '$name' is not [a-z0-9-]+"

  combined=$(( ${#name} + ${#desc} ))
  [[ "$combined" -le 1024 ]] \
    || check_fail "$file: name+description is $combined chars, max 1024"
}

# AC4 — the inlined Company Profile pointer must match canonical byte for byte.
# AC18 — the glossary must never be inlined.
check_shared_text() {
  local file="$1" locale="$2" pointer glossary_probe body
  pointer="$(cat "$SHARED_DIR/$locale/profile-pointer.md")"
  body="$(cat "$file")"
  # A true multi-line substring check: `grep -F` on a multi-line pattern would
  # match on any single line of it, not the whole block.
  if [[ "$body" != *"$pointer"* ]]; then
    check_fail "$file: Company Profile pointer missing or drifted from skills/shared/$locale/profile-pointer.md"
  fi
  # The glossary's title line is a reliable probe for an inlined copy.
  glossary_probe="$(head -1 "$SHARED_DIR/$locale/glossary.md")"
  if grep -qF -- "$glossary_probe" "$file"; then
    check_fail "$file: glossary content is inlined; it belongs in references/ only"
  fi
}

# Fix 1 (drift check extension) — any references/*.md file that echoes the
# profile pointer's opening line must carry the whole pointer, byte-exact —
# not just SKILL.md. atelier-forge inlines the pointer into scaffold.md and
# example-generated-skill.md, and every generated skill inherits whatever is
# in those files, so a drift there is silent until an executive uploads it.
check_reference_pointer_drift() {
  local canonical="$1" locale="$2" refs_dir pointer pointer_head file body
  refs_dir="$SKILLS_DIR/$canonical/$locale/references"
  # Explicit `return 0`, not a bare `return`: under `set -e`, a bare `return`
  # after `||` on a failed `[[ -d ]]` test would propagate that test's own
  # nonzero status and abort the whole script — this is a normal "nothing to
  # check here" case, not a failure.
  [[ -d "$refs_dir" ]] || return 0
  pointer="$(cat "$SHARED_DIR/$locale/profile-pointer.md")"
  pointer_head="$(head -1 "$SHARED_DIR/$locale/profile-pointer.md")"
  for file in "$refs_dir"/*.md; do
    [[ -f "$file" ]] || continue
    body="$(cat "$file")"
    if [[ "$body" == *"$pointer_head"* ]]; then
      # A true multi-line substring check: `grep -F` on a multi-line pattern
      # would match on any single line of it, not the whole block.
      if [[ "$body" != *"$pointer"* ]]; then
        check_fail "$file: Company Profile pointer missing or drifted from skills/shared/$locale/profile-pointer.md"
      fi
    fi
  done
}

# AC18 / AC34 — the staged references must be byte-identical to canonical.
check_staged_references() {
  local stage="$1" canonical="$2" locale="$3"
  cmp -s "$stage/references/glossary.md" "$SHARED_DIR/$locale/glossary.md" \
    || check_fail "$canonical/$locale: staged references/glossary.md differs from skills/shared/$locale/glossary.md"
  cmp -s "$stage/references/memory-protocol.md" "$SHARED_DIR/$locale/memory-protocol.md" \
    || check_fail "$canonical/$locale: staged references/memory-protocol.md differs from skills/shared/$locale/memory-protocol.md"
}

# AC15 — every skill has at least one scenario per locale.
check_scenarios() {
  local canonical="$1" locale="$2" dir count
  dir="$REPO_ROOT/tests/$canonical/$locale"
  if [[ ! -d "$dir" ]]; then
    check_fail "tests/$canonical/$locale/: no scenario directory"
    return
  fi
  count=$(find "$dir" -maxdepth 1 -name '*.md' -type f | wc -l)
  [[ "$count" -ge 1 ]] || check_fail "tests/$canonical/$locale/: no scenario files"
}

# AC6 — every trigger term a scenario declares appears in that locale's description.
check_triggers() {
  local canonical="$1" locale="$2" skill_md desc scenario term
  skill_md="$SKILLS_DIR/$canonical/$locale/SKILL.md"
  desc="$(frontmatter_field "$skill_md" description)"
  [[ -d "$REPO_ROOT/tests/$canonical/$locale" ]] || return
  while IFS= read -r scenario; do
    while IFS= read -r term; do
      [[ -z "$term" ]] && continue
      if ! grep -qF -- "$term" <<<"$desc"; then
        check_fail "$scenario: trigger '$term' is absent from the $locale description of $canonical"
      fi
    done < <(awk '
      NR == 1 && $0 == "---" { inside = 1; next }
      inside && $0 == "---" { exit }
      inside && $0 == "triggers:" { collecting = 1; next }
      inside && collecting && /^  - / { sub(/^  - /, ""); print; next }
      inside && collecting && !/^  - / { collecting = 0 }
    ' "$scenario")
  done < <(find "$REPO_ROOT/tests/$canonical/$locale" -maxdepth 1 -name '*.md' -type f)
}

run_checks() {
  local out_dir="$1"; shift
  local selected=("$@")
  local locale canonical stage

  # Repo-wide, not per-locale: run it once.
  check_version_coherence
  # 2026-09-19/AC13 — the scanner finds its own files, so it runs once here
  # rather than inside the per-skill, per-locale loop below.
  check_dated_claims

  for locale in "${selected[@]}"; do
    for canonical in $(list_skills); do
      [[ -d "$SKILLS_DIR/$canonical/$locale" ]] || continue
      local skill_md="$SKILLS_DIR/$canonical/$locale/SKILL.md"
      check_frontmatter "$skill_md"
      check_shared_text "$skill_md" "$locale"
      check_scenarios "$canonical" "$locale"
      check_triggers "$canonical" "$locale"
      check_reference_pointer_drift "$canonical" "$locale"

      stage="$(make_stage_dir)"
      stage_skill "$canonical" "$locale" "$stage" >/dev/null
      check_staged_references "$stage" "$canonical" "$locale"
      rm -rf "$stage"
    done
  done

  # 2026-09-19/AC15 — before STATUS:, on every run that reaches it.
  report_dated_claims

  if [[ "$CHECK_FAILURES" -gt 0 ]]; then
    echo "STATUS: FAIL ($CHECK_FAILURES check failures)" >&2
    exit 1
  fi
  echo "STATUS: PASS (mechanical checks)"
}

main "$@"

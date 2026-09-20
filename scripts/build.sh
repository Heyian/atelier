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
Usage: build.sh [--lang fr|en|all] [--check] [--check-freshness]

  --lang fr|en|all   Build that locale without prompting.
  --check            Run the mechanical checks only; build to a temp dir and
                     leave dist/ untouched. Exits non-zero on any failure.
  --check-freshness  Validate every dated capability claim and fail if the
                     oldest has passed the freshness threshold. Builds nothing.

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

  # 2026-09-20-heading-pairs/AC1 — generated per stage, never checked in.
  generate_exec_heading_pairs "$locale" "$stage/references/exec-document-headings.md"

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
  local lang="" check=0 freshness=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --lang) [[ $# -ge 2 ]] || die "--lang needs a value"; lang="$2"; shift 2 ;;
      --lang=*) lang="${1#--lang=}"; shift ;;
      --check) check=1; shift ;;
      --check-freshness) freshness=1; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
  done

  [[ -f "$NAMES_TSV" ]] || die "missing $NAMES_TSV"

  # 2026-09-19/AC19 — neither stages a skill nor writes to dist/, so it
  # returns before any of the build machinery below.
  if [[ "$freshness" -eq 1 ]]; then
    run_freshness_check
    exit $?
  fi

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

# --- 2026-09-19-headings/AC14 — the exec-facing document registry: one row
# per document, six tab-separated columns
# <doc-id> <canonical-path> <fr-ref> <fr-block> <en-ref> <en-block>.
EXEC_DOCS_TSV="$SKILLS_DIR/exec-documents.tsv"

# CommonMark fence boundaries (4.5) plus ATX heading levels (4.2). These
# duplicate the functions inlined in the dated-claims awk above on purpose:
# that scanner passes today, and sharing a library would put it at risk to
# save twenty lines.
FENCE_AWK_LIB='
function fence_marker(line,    lead) {
  lead = 0
  while (lead < 3 && substr(line, lead + 1, 1) == " ") lead++
  if (substr(line, lead + 1, 1) != "`" && substr(line, lead + 1, 1) != "~") return ""
  return substr(line, lead + 1)
}
function fence_run_len(marker, ch,    i) {
  i = 1
  while (substr(marker, i, 1) == ch) i++
  return i - 1
}
function fence_closes(line, fchar, flen,    marker, rest) {
  marker = fence_marker(line)
  if (marker == "" || substr(marker, 1, 1) != fchar) return 0
  if (fence_run_len(marker, fchar) < flen) return 0
  rest = substr(marker, fence_run_len(marker, fchar) + 1)
  gsub(/[ \t]/, "", rest)
  return rest == ""
}
function atx_level(line,    lead, n, c) {
  lead = 0
  while (lead < 3 && substr(line, lead + 1, 1) == " ") lead++
  n = 0
  while (substr(line, lead + n + 1, 1) == "#") n++
  if (n < 1 || n > 6) return 0
  c = substr(line, lead + n + 1, 1)
  if (c != "" && c != " " && c != "\t") return 0
  return n
}
'

# The heading levels of the WANT-th ```markdown block in a file, space-joined
# and in document order — "1 2 2 2" for a title and three sections. Prints
# MISSING when the file holds fewer than WANT such blocks, and UNCLOSED when
# the target block runs to EOF without a closing fence: a truncated heading
# list compared against a complete one would read as a real divergence and
# send the reader to the wrong file.
exec_doc_headings() {
  local file="$1" want="$2"
  awk -v WANT="$want" "$FENCE_AWK_LIB"'
    BEGIN { want = WANT + 0; seen = 0; inFence = 0; target = 0; found = 0; closed = 0; out = "" }
    {
      line = $0
      sub(/\r$/, "", line)          # a CRLF checkout must behave like an LF one

      if (inFence) {
        if (fence_closes(line, fenceChar, fenceLen)) {
          if (target) { closed = 1; target = 0 }
          inFence = 0
          next
        }
        if (target) {
          lvl = atx_level(line)
          if (lvl > 0) out = (out == "" ? "" : out " ") lvl
        }
        next
      }

      marker = fence_marker(line)
      if (marker == "") next
      markerChar = substr(marker, 1, 1)
      markerLen = fence_run_len(marker, markerChar)
      if (markerLen < 3) next
      info = substr(marker, markerLen + 1)
      gsub(/[ \t]/, "", info)
      # Enter every fence, target or not: a ```bash block quoting a
      # ```markdown opener must not be counted as one.
      inFence = 1; fenceChar = markerChar; fenceLen = markerLen; target = 0
      if (info == "markdown") {
        seen++
        if (seen == want && !found) { target = 1; found = 1 }
      }
    }
    END {
      if (!found) { print "MISSING"; exit 0 }
      if (!closed) { print "UNCLOSED"; exit 0 }
      print out
    }
  ' "$file"
}

# The heading levels AND text of the WANT-th ```markdown block, one heading
# per line as "<level> <text>" — the FIRST space is the delimiter, so the
# text may hold further spaces and '#'. Same MISSING / UNCLOSED sentinels as
# exec_doc_headings() on the same conditions, so a caller validates once.
#
# 2026-09-20-heading-pairs/AC11 — atx_level() already accepts three shapes a
# naive "strip '# '" would get wrong: up to three leading spaces, a tab
# separator, and a marker with nothing after it. Extraction has to define all
# three rather than assume one space, or recognition and extraction disagree.
exec_doc_heading_text() {
  local file="$1" want="$2"
  awk -v WANT="$want" "$FENCE_AWK_LIB"'
    function atx_text(line,    lead, n, rest) {
      lead = 0
      while (lead < 3 && substr(line, lead + 1, 1) == " ") lead++
      n = 0
      while (substr(line, lead + n + 1, 1) == "#") n++
      rest = substr(line, lead + n + 1)
      sub(/^[ \t]+/, "", rest)       # only the separator; trailing text is verbatim
      return rest
    }
    BEGIN { want = WANT + 0; seen = 0; inFence = 0; target = 0; found = 0; closed = 0; out = "" }
    {
      line = $0
      sub(/\r$/, "", line)          # a CRLF checkout must behave like an LF one

      if (inFence) {
        if (fence_closes(line, fenceChar, fenceLen)) {
          if (target) { closed = 1; target = 0 }
          inFence = 0
          next
        }
        if (target) {
          lvl = atx_level(line)
          if (lvl > 0) out = out lvl " " atx_text(line) "\n"
        }
        next
      }

      marker = fence_marker(line)
      if (marker == "") next
      markerChar = substr(marker, 1, 1)
      markerLen = fence_run_len(marker, markerChar)
      if (markerLen < 3) next
      info = substr(marker, markerLen + 1)
      gsub(/[ \t]/, "", info)
      # Enter every fence, target or not: a ```bash block quoting a
      # ```markdown opener must not be counted as one.
      inFence = 1; fenceChar = markerChar; fenceLen = markerLen; target = 0
      if (info == "markdown") {
        seen++
        if (seen == want && !found) { target = 1; found = 1 }
      }
    }
    END {
      if (!found) { print "MISSING"; exit 0 }
      if (!closed) { print "UNCLOSED"; exit 0 }
      printf "%s", out       # printf, not print: an empty block emits nothing
    }
  ' "$file"
}

# Escape the one character a two-column markdown row cannot hold raw.
esc_table_cell() { printf '%s' "${1//|/\\|}"; }

# One templated registry row's group, appended to the generated file. Every
# failure here die()s: check_exec_documents() runs only under --check, so a
# plain `--lang all` would otherwise ship a table with a document silently
# missing — the class of failure this file exists to close.
emit_exec_heading_group() {
  local doc_id="$1" path="$2" fr_ref="$3" fr_block="$4" en_ref="$5" en_block="$6"
  local side ref block v

  for side in fr en; do
    if [[ "$side" == "fr" ]]; then ref="$fr_ref"; block="$fr_block"
    else ref="$en_ref"; block="$en_block"; fi
    [[ -f "$REPO_ROOT/$ref" ]] \
      || die "$doc_id — $ref listed in skills/exec-documents.tsv but no such file (renamed?)"
    [[ "$block" =~ ^[1-9][0-9]*$ ]] \
      || die "$doc_id — $ref template block index '$block' is not a positive integer"
  done

  local fr_raw en_raw
  fr_raw="$(exec_doc_heading_text "$REPO_ROOT/$fr_ref" "$fr_block")"
  en_raw="$(exec_doc_heading_text "$REPO_ROOT/$en_ref" "$en_block")"

  for side in fr en; do
    if [[ "$side" == "fr" ]]; then ref="$fr_ref"; block="$fr_block"; v="$fr_raw"
    else ref="$en_ref"; block="$en_block"; v="$en_raw"; fi
    case "$v" in
      MISSING)  die "$doc_id — $ref has no markdown template block $block" ;;
      UNCLOSED) die "$doc_id — $ref template block $block is never closed" ;;
    esac
  done

  # mapfile on an empty string yields a one-element array holding "", so an
  # empty block would count as one heading. Guard both sides explicitly.
  local -a fr_all=() en_all=()
  [[ -n "$fr_raw" ]] && mapfile -t fr_all <<<"$fr_raw"
  [[ -n "$en_raw" ]] && mapfile -t en_all <<<"$en_raw"

  # 2026-09-20-heading-pairs/AC19 — every heading, level-1 title included,
  # counted before any level-2 filtering.
  if [[ "${#fr_all[@]}" -ne "${#en_all[@]}" ]]; then
    die "$doc_id — heading counts differ: $fr_ref has ${#fr_all[@]}, $en_ref has ${#en_all[@]}"
  fi

  # Equal totals at different depths would pair a French heading with the
  # wrong English one once the level-1 titles are filtered out. Same verdict
  # check_exec_document_row() makes under --check, made here too because a
  # plain build never calls it.
  local i fr_levels="" en_levels=""
  for i in "${!fr_all[@]}"; do
    fr_levels+="${fr_all[$i]%% *} "
    en_levels+="${en_all[$i]%% *} "
  done
  if [[ "$fr_levels" != "$en_levels" ]]; then
    die "$doc_id — heading levels differ: $fr_ref [${fr_levels% }], $en_ref [${en_levels% }]"
  fi

  local -a rows=()
  local lvl marker
  for i in "${!fr_all[@]}"; do
    lvl="${fr_all[$i]%% *}"
    [[ "$lvl" -ge 2 ]] || continue        # 2026-09-20-heading-pairs/AC6 — level-1 titles never appear
    marker="$(printf '%*s' "$lvl" '' | tr ' ' '#')"
    rows+=("$(printf '| %s %s | %s %s |' \
      "$marker" "$(esc_table_cell "${fr_all[$i]#* }")" \
      "$marker" "$(esc_table_cell "${en_all[$i]#* }")")")
  done

  # 2026-09-20-heading-pairs/AC3 / AC7 — a block whose only heading is its
  # title contributes no group.
  [[ "${#rows[@]}" -gt 0 ]] || return 0

  printf '\n## %s\n\n`%s`\n\n| Français | English |\n| --- | --- |\n' "$doc_id" "$path"
  printf '%s\n' "${rows[@]}"
}

# 2026-09-20-heading-pairs/AC1-AC10, AC15-AC20. Reads the registry once per
# staged skill and writes the locale's preamble followed by the generated
# table. Called from stage_skill(), so every ZIP carries the result.
generate_exec_heading_pairs() {
  local locale="$1" out="$2"
  local preamble="$SHARED_DIR/$locale/exec-document-headings.md"

  [[ -f "$EXEC_DOCS_TSV" ]] \
    || die "skills/exec-documents.tsv — exec-facing document registry not found"
  [[ -f "$preamble" ]] \
    || die "skills/shared/$locale/exec-document-headings.md not found"

  cp "$preamble" "$out"

  local raw line_no=0 doc_id path fr_ref fr_block en_ref en_block v dashes
  local -a cols
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    line_no=$((line_no + 1))
    raw="${raw%$'\r'}"          # strip CR before any column is compared
    [[ -z "$raw" ]] && continue

    # awk, not `IFS=$'\t' read -a`: tab is IFS whitespace, so read would
    # collapse two adjacent tabs into one and hide an empty column.
    mapfile -t cols < <(awk -F'\t' '{ for (i = 1; i <= NF; i++) print $i }' <<<"$raw")
    [[ "${#cols[@]}" -eq 6 ]] \
      || die "skills/exec-documents.tsv:$line_no — expected 6 tab-separated columns, found ${#cols[@]}"

    doc_id="${cols[0]}"; path="${cols[1]}"
    fr_ref="${cols[2]}"; fr_block="${cols[3]}"
    en_ref="${cols[4]}"; en_block="${cols[5]}"

    dashes=0
    for v in "$fr_ref" "$fr_block" "$en_ref" "$en_block"; do
      [[ "$v" == "-" ]] && dashes=$((dashes + 1))
    done
    # 2026-09-20-heading-pairs/AC10 — a document described in prose carries
    # '-' in all four columns.
    if [[ "$dashes" -eq 4 ]]; then continue; fi
    [[ "$dashes" -eq 0 ]] \
      || die "$doc_id — template columns are partly '-': a document described in prose carries '-' in all four"

    emit_exec_heading_group "$doc_id" "$path" \
      "$fr_ref" "$fr_block" "$en_ref" "$en_block" >> "$out"
  done < "$EXEC_DOCS_TSV"
}

# 2026-09-19-headings/AC17-AC21. Reads the registry once, per row.
check_exec_documents() {
  if [[ ! -f "$EXEC_DOCS_TSV" ]]; then
    check_fail "skills/exec-documents.tsv — exec-facing document registry not found"
    return
  fi

  local raw line_no=0 doc_id fr_ref fr_block en_ref en_block v dashes
  local -a cols
  while IFS= read -r raw || [[ -n "$raw" ]]; do
    line_no=$((line_no + 1))
    raw="${raw%$'\r'}"
    [[ -z "$raw" ]] && continue

    # awk, not `IFS=$'\t' read -a`: tab is IFS whitespace, so read would
    # collapse two adjacent tabs into one and hide an empty column.
    mapfile -t cols < <(awk -F'\t' '{ for (i = 1; i <= NF; i++) print $i }' <<<"$raw")
    if [[ "${#cols[@]}" -ne 6 ]]; then
      check_fail "skills/exec-documents.tsv:$line_no — expected 6 tab-separated columns, found ${#cols[@]}"
      continue
    fi

    doc_id="${cols[0]}"
    fr_ref="${cols[2]}"; fr_block="${cols[3]}"
    en_ref="${cols[4]}"; en_block="${cols[5]}"

    # AC15 / AC21 — a document described in prose carries '-' in all four
    # template columns. All four, or none: a half-filled row would be read as
    # a real row naming a reference file called '-'.
    dashes=0
    for v in "$fr_ref" "$fr_block" "$en_ref" "$en_block"; do
      [[ "$v" == "-" ]] && dashes=$((dashes + 1))
    done
    if [[ "$dashes" -eq 4 ]]; then continue; fi
    if [[ "$dashes" -ne 0 ]]; then
      check_fail "$doc_id — template columns are partly '-': a document described in prose carries '-' in all four"
      continue
    fi

    if [[ "$fr_ref" == "$en_ref" ]]; then
      check_fail "$doc_id — names the same reference file for both locales: $fr_ref"
      continue
    fi

    check_exec_document_row "$doc_id" "$fr_ref" "$fr_block" "$en_ref" "$en_block"
  done < "$EXEC_DOCS_TSV"
}

# One row's two sides. Task 5 adds the comparison; this returns after
# validating each side on its own.
check_exec_document_row() {
  local doc_id="$1" fr_ref="$2" fr_block="$3" en_ref="$4" en_block="$5"
  local ref block side v ok=1

  for side in fr en; do
    if [[ "$side" == "fr" ]]; then ref="$fr_ref"; block="$fr_block"
    else ref="$en_ref"; block="$en_block"; fi

    if [[ ! -f "$REPO_ROOT/$ref" ]]; then
      check_fail "$doc_id — $ref listed in skills/exec-documents.tsv but no such file (renamed?)"
      ok=0; continue
    fi
    if [[ ! "$block" =~ ^[1-9][0-9]*$ ]]; then
      check_fail "$doc_id — $ref template block index '$block' is not a positive integer"
      ok=0; continue
    fi
  done

  [[ "$ok" -eq 1 ]] || return 0   # both sides named a real file and a sane index

  local fr_levels en_levels
  fr_levels="$(exec_doc_headings "$REPO_ROOT/$fr_ref" "$fr_block")"
  en_levels="$(exec_doc_headings "$REPO_ROOT/$en_ref" "$en_block")"

  for side in fr en; do
    if [[ "$side" == "fr" ]]; then ref="$fr_ref"; block="$fr_block"; v="$fr_levels"
    else ref="$en_ref"; block="$en_block"; v="$en_levels"; fi
    case "$v" in
      MISSING)  check_fail "$doc_id — $ref has no markdown template block $block"; ok=0 ;;
      UNCLOSED) check_fail "$doc_id — $ref template block $block is never closed"; ok=0 ;;
    esac
  done

  [[ "$ok" -eq 1 ]] || return 0

  # 2026-09-19-headings/AC19, AC20 — identical sequence of heading levels:
  # same number of headings, at the same depths, in the same order. No script
  # can compare a French heading to an English one for meaning; this proves
  # the two templates are structurally the same document, which is the
  # property reading-by-meaning depends on.
  if [[ "$fr_levels" != "$en_levels" ]]; then
    local fr_n en_n
    fr_n="$(wc -w <<<"$fr_levels")"
    en_n="$(wc -w <<<"$en_levels")"
    if [[ "$fr_n" -ne "$en_n" ]]; then
      check_fail "$doc_id — heading counts differ: $fr_ref has $fr_n, $en_ref has $en_n"
    else
      check_fail "$doc_id — heading levels differ: $fr_ref [$fr_levels], $en_ref [$en_levels]"
    fi
  fi
}

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
    # A fenced block quoting the pattern (docs/AUTHORING.md mirrors it) is an
    # example, not an annotation. Fence boundaries follow CommonMark 4.5, not
    # a bare "```" toggle: 0-3 leading spaces then 3+ of the SAME
    # backtick-or-tilde character opens; the same character, at least as many
    # of them, 0-3 leading spaces, and nothing but whitespace after it closes.
    # A fence left open at EOF stays open — that is correct, not a bug.
    function fence_marker(line,    lead) {
      lead = 0
      while (lead < 3 && substr(line, lead + 1, 1) == " ") lead++
      if (substr(line, lead + 1, 1) != "`" && substr(line, lead + 1, 1) != "~") return ""
      return substr(line, lead + 1)
    }
    function fence_run_len(marker, ch,    i) {
      i = 1
      while (substr(marker, i, 1) == ch) i++
      return i - 1
    }
    function fence_closes(line, fchar, flen,    marker, rest) {
      marker = fence_marker(line)
      if (marker == "" || substr(marker, 1, 1) != fchar) return 0
      if (fence_run_len(marker, fchar) < flen) return 0
      rest = substr(marker, fence_run_len(marker, fchar) + 1)
      gsub(/[ \t]/, "", rest)
      return rest == ""
    }
    BEGIN { todayDays = ymd_to_days(today) }
    {
      line = $0
      sub(/\r$/, "", line)          # a CRLF checkout must behave like an LF one

      if (fence) {
        if (fence_closes(line, fenceChar, fenceLen)) fence = 0
        next
      }
      marker = fence_marker(line)
      if (marker != "") {
        markerChar = substr(marker, 1, 1)
        markerLen = fence_run_len(marker, markerChar)
        if (markerLen >= 3) { fence = 1; fenceChar = markerChar; fenceLen = markerLen; next }
      }

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

# --- 2026-09-19/AC19–AC22 — the second tier. Stages nothing, writes nothing
# to dist/, and carries the form validation deliberately: if the pattern
# stopped matching, this job is the last thing that would notice, and it must
# fail rather than report a cheerful zero.
run_freshness_check() {
  check_dated_claims

  if [[ "$CHECK_FAILURES" -gt 0 ]]; then
    echo "STATUS: FAIL ($CHECK_FAILURES check failures)" >&2
    exit 1
  fi

  local stale
  stale="$(awk -F'\t' -v today="$TODAY_YMD" -v fail_age="$FAIL_AGE_DAYS" \
               -v report_age="$REPORT_AGE_DAYS" "$DATED_CLAIMS_AWK_LIB"'
    BEGIN { todayDays = ymd_to_days(today); anyFail = 0 }
    $5 == "ok" {
      age = todayDays - ymd_to_days($4)
      if (age >= fail_age) anyFail = 1
      if (age >= report_age) lines[++n] = sprintf("  %s:%s %s (%d days)", $1, $2, $4, age)
    }
    END {
      if (!anyFail) exit 0
      for (i = 1; i <= n; i++) print lines[i]
      exit 0
    }
  ' <<<"$DATED_CLAIMS_RECORDS")"

  if [[ -n "$stale" ]]; then
    echo "Dated capability claims are past the freshness threshold (fail threshold $FAIL_AGE_DAYS days,"
    echo "listing everything at or over $REPORT_AGE_DAYS days):"
    echo "$stale"
    return 1
  fi

  echo "dated claims: every claim is younger than $FAIL_AGE_DAYS days"
  return 0
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
  # 2026-09-19-headings/AC16 — the registry names its own files, so this runs
  # once here rather than inside the per-skill, per-locale loop below.
  check_exec_documents

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

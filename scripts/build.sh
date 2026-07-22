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

  if [[ "$CHECK_FAILURES" -gt 0 ]]; then
    echo "STATUS: FAIL ($CHECK_FAILURES check failures)" >&2
    exit 1
  fi
  echo "STATUS: PASS (mechanical checks)"
}

main "$@"

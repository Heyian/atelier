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
    stage="$(mktemp -d)"
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
    out_dir="$(mktemp -d)"
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
    rm -rf "$out_dir"
  fi
}

# Defined in Task 4; a no-op stub until then so --check does not break the build.
run_checks() { :; }

main "$@"

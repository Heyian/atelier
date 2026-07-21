#!/usr/bin/env bash
# Tests for the canonical shared texts and the localized-name table.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FAILURES=0

fail() { echo "FAIL: $*"; FAILURES=$((FAILURES + 1)); }
pass() { echo "ok: $*"; }

check_nonempty_file() {
  if [[ -s "$1" ]]; then pass "$1 exists and is non-empty"; else fail "$1 missing or empty"; fi
}

# --- canonical texts exist in both locales
for locale in fr en; do
  for name in profile-pointer glossary memory-protocol; do
    check_nonempty_file "$REPO_ROOT/skills/shared/$locale/$name.md"
  done
done

# --- names.tsv shape
NAMES="$REPO_ROOT/skills/names.tsv"
check_nonempty_file "$NAMES"

if [[ -s "$NAMES" ]]; then
  row_count=$(grep -c . "$NAMES")
  if [[ "$row_count" -eq 7 ]]; then
    pass "names.tsv has 7 rows"
  else
    fail "names.tsv has $row_count rows, expected 7"
  fi

  while IFS=$'\t' read -r canonical fr en; do
    [[ -z "$canonical" ]] && continue
    if [[ -z "$fr" || -z "$en" ]]; then
      fail "names.tsv row '$canonical' has an empty locale column"
    fi
    for n in "$fr" "$en"; do
      if [[ ! "$n" =~ ^[a-z0-9-]+$ ]]; then
        fail "names.tsv name '$n' is not [a-z0-9-]+"
      fi
    done
  done < "$NAMES"

  # --- AC5: the exact localized-name map
  expect_row() {
    if grep -qxF "$(printf '%s\t%s\t%s' "$1" "$2" "$3")" "$NAMES"; then
      pass "names.tsv maps $1 -> $2 / $3"
    else
      fail "names.tsv missing row: $1 / $2 / $3"
    fi
  }
  expect_row atelier            atelier            atelier
  expect_row atelier-mentor     atelier-mentor     atelier-mentor
  expect_row atelier-marketing  atelier-marketing  atelier-marketing
  expect_row atelier-forge      atelier-forge      atelier-forge
  expect_row atelier-ventes     atelier-ventes     atelier-sales
  expect_row atelier-reunions   atelier-reunions   atelier-meetings
  expect_row atelier-boussole   atelier-boussole   atelier-compass
fi

# --- the glossary must define both category terms in both locales (ADR-0002)
# (case-insensitive: headings are capitalized, e.g. "Compétences socle")
grep -qi "compétences de rôle" "$REPO_ROOT/skills/shared/fr/glossary.md" \
  && pass "FR glossary defines « compétences de rôle »" \
  || fail "FR glossary missing « compétences de rôle »"
grep -qi "compétences socle" "$REPO_ROOT/skills/shared/fr/glossary.md" \
  && pass "FR glossary defines « compétences socle »" \
  || fail "FR glossary missing « compétences socle »"
grep -qi "Role skills" "$REPO_ROOT/skills/shared/en/glossary.md" \
  && pass "EN glossary defines Role skills" \
  || fail "EN glossary missing Role skills"
grep -qi "Core skills" "$REPO_ROOT/skills/shared/en/glossary.md" \
  && pass "EN glossary defines Core skills" \
  || fail "EN glossary missing Core skills"

# --- the profile pointer must encode the file-wins rule (ADR-0003 / AC22)
grep -q "company-profile.md" "$REPO_ROOT/skills/shared/fr/profile-pointer.md" \
  && pass "FR profile pointer names the canonical path" \
  || fail "FR profile pointer missing canonical path"
grep -q "company-profile.md" "$REPO_ROOT/skills/shared/en/profile-pointer.md" \
  && pass "EN profile pointer names the canonical path" \
  || fail "EN profile pointer missing canonical path"

echo
if [[ "$FAILURES" -eq 0 ]]; then echo "STATUS: PASS"; exit 0; else echo "STATUS: FAIL ($FAILURES)"; exit 1; fi

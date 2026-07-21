#!/usr/bin/env bash
# Tests for scripts/build.sh, run against synthetic fixture repos in $TMPDIR.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FAILURES=0
fail() { echo "FAIL: $*"; FAILURES=$((FAILURES + 1)); }
pass() { echo "ok: $*"; }

# Build a minimal but valid repo in a temp dir: real build.sh, real shared texts,
# one two-locale skill with differing localized names, and its scenarios.
make_fixture_repo() {
  local dir; dir="$(mktemp -d)"
  mkdir -p "$dir/scripts" "$dir/skills/shared/fr" "$dir/skills/shared/en"
  cp "$REPO_ROOT/scripts/build.sh" "$dir/scripts/build.sh"
  cp "$REPO_ROOT/skills/shared/fr/"*.md "$dir/skills/shared/fr/"
  cp "$REPO_ROOT/skills/shared/en/"*.md "$dir/skills/shared/en/"
  printf 'atelier-ventes\tatelier-ventes\tatelier-sales\n' > "$dir/skills/names.tsv"

  local fr_pointer en_pointer
  fr_pointer="$(cat "$REPO_ROOT/skills/shared/fr/profile-pointer.md")"
  en_pointer="$(cat "$REPO_ROOT/skills/shared/en/profile-pointer.md")"

  mkdir -p "$dir/skills/atelier-ventes/fr" "$dir/skills/atelier-ventes/en"
  cat > "$dir/skills/atelier-ventes/fr/SKILL.md" <<EOF
---
name: atelier-ventes
description: À utiliser quand il est question de pipeline, de relance ou de proposition commerciale.
version: 0.1.0
---

# Ventes

$fr_pointer
EOF
  cat > "$dir/skills/atelier-ventes/en/SKILL.md" <<EOF
---
name: atelier-sales
description: Use when the conversation turns to pipeline, follow-ups, or proposals.
version: 0.1.0
---

# Sales

$en_pointer
EOF

  mkdir -p "$dir/tests/atelier-ventes/fr" "$dir/tests/atelier-ventes/en"
  cat > "$dir/tests/atelier-ventes/fr/pipeline.md" <<'EOF'
---
skill: atelier-ventes
locale: fr
triggers:
  - pipeline
---
## Prompt
Passe mon pipeline en revue.
EOF
  cat > "$dir/tests/atelier-ventes/en/pipeline.md" <<'EOF'
---
skill: atelier-sales
locale: en
triggers:
  - pipeline
---
## Prompt
Review my pipeline.
EOF

  echo "$dir"
}

# --- AC1: --lang all produces one ZIP per skill per locale, SKILL.md at root
d="$(make_fixture_repo)"
( cd "$d" && bash scripts/build.sh --lang all >/dev/null 2>&1 )
[[ -f "$d/dist/atelier-ventes-fr.zip" ]] && pass "AC1 FR zip built" || fail "AC1 FR zip missing"
[[ -f "$d/dist/atelier-sales-en.zip" ]] && pass "AC1 EN zip named from localized name" || fail "AC1 EN zip missing or misnamed"
if unzip -l "$d/dist/atelier-ventes-fr.zip" 2>/dev/null | grep -qE ' SKILL\.md$'; then
  pass "AC1 SKILL.md at ZIP root"
else
  fail "AC1 SKILL.md not at ZIP root"
fi
rm -rf "$d"

# --- AC3: --lang fr builds only French, non-interactively
d="$(make_fixture_repo)"
( cd "$d" && bash scripts/build.sh --lang fr </dev/null >/dev/null 2>&1 )
[[ -f "$d/dist/atelier-ventes-fr.zip" ]] && pass "AC3 --lang fr built FR" || fail "AC3 --lang fr did not build FR"
[[ ! -f "$d/dist/atelier-sales-en.zip" ]] && pass "AC3 --lang fr skipped EN" || fail "AC3 --lang fr also built EN"
rm -rf "$d"

# --- AC3: --lang en builds only English
d="$(make_fixture_repo)"
( cd "$d" && bash scripts/build.sh --lang en </dev/null >/dev/null 2>&1 )
[[ -f "$d/dist/atelier-sales-en.zip" ]] && pass "AC3 --lang en built EN" || fail "AC3 --lang en did not build EN"
[[ ! -f "$d/dist/atelier-ventes-fr.zip" ]] && pass "AC3 --lang en skipped FR" || fail "AC3 --lang en also built FR"
rm -rf "$d"

# --- AC3: no flag prompts; answering the prompt selects the locale
d="$(make_fixture_repo)"
out="$( cd "$d" && printf 'fr\n' | bash scripts/build.sh 2>&1 )"
if grep -qiE 'français|english|les deux|both' <<<"$out"; then
  pass "AC3 no-flag run prompts for a language"
else
  fail "AC3 no-flag run did not prompt (output: $out)"
fi
[[ -f "$d/dist/atelier-ventes-fr.zip" ]] && pass "AC3 prompt answer 'fr' built FR" || fail "AC3 prompt answer 'fr' did not build FR"
[[ ! -f "$d/dist/atelier-sales-en.zip" ]] && pass "AC3 prompt answer 'fr' skipped EN" || fail "AC3 prompt answer 'fr' also built EN"
rm -rf "$d"

# --- AC5: a frontmatter name that contradicts names.tsv is a build failure
d="$(make_fixture_repo)"
sed -i 's/^name: atelier-sales$/name: atelier-ventes/' "$d/skills/atelier-ventes/en/SKILL.md"
if ( cd "$d" && bash scripts/build.sh --lang all >/dev/null 2>&1 ); then
  fail "AC5 build accepted a name contradicting names.tsv"
else
  pass "AC5 build rejects a name contradicting names.tsv"
fi
rm -rf "$d"

# --- an invalid --lang value is rejected
d="$(make_fixture_repo)"
if ( cd "$d" && bash scripts/build.sh --lang klingon >/dev/null 2>&1 ); then
  fail "invalid --lang accepted"
else
  pass "invalid --lang rejected"
fi
rm -rf "$d"

echo
if [[ "$FAILURES" -eq 0 ]]; then echo "STATUS: PASS"; exit 0; else echo "STATUS: FAIL ($FAILURES)"; exit 1; fi

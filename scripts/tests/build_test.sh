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

# --- AC2: a name with illegal characters fails the check
d="$(make_fixture_repo)"
sed -i 's/^name: atelier-ventes$/name: Atelier Ventes/' "$d/skills/atelier-ventes/fr/SKILL.md"
printf 'atelier-ventes\tAtelier Ventes\tatelier-sales\n' > "$d/skills/names.tsv"
if ( cd "$d" && bash scripts/build.sh --check >/dev/null 2>&1 ); then
  fail "AC2 accepted a name with spaces and capitals"
else
  pass "AC2 rejects a name outside [a-z0-9-]"
fi
rm -rf "$d"

# --- AC2: a missing version fails the check
d="$(make_fixture_repo)"
sed -i '/^version: /d' "$d/skills/atelier-ventes/fr/SKILL.md"
if ( cd "$d" && bash scripts/build.sh --check >/dev/null 2>&1 ); then
  fail "AC2 accepted a SKILL.md with no version"
else
  pass "AC2 rejects a missing version"
fi
rm -rf "$d"

# --- AC2: name+description over 1024 chars fails the check
d="$(make_fixture_repo)"
long="$(head -c 1100 /dev/zero | tr '\0' 'a')"
sed -i "s/^description: .*/description: $long/" "$d/skills/atelier-ventes/fr/SKILL.md"
if ( cd "$d" && bash scripts/build.sh --check >/dev/null 2>&1 ); then
  fail "AC2 accepted name+description over 1024 chars"
else
  pass "AC2 rejects name+description over 1024 chars"
fi
rm -rf "$d"

# --- AC4: a drifted profile pointer fails the check, naming the file
d="$(make_fixture_repo)"
sed -i 's/le fichier fait foi/la connaissance du projet fait foi/' "$d/skills/atelier-ventes/fr/SKILL.md"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] && grep -q "atelier-ventes/fr/SKILL.md" <<<"$out"; then
  pass "AC4 rejects a drifted profile pointer and names the file"
else
  fail "AC4 did not reject drifted profile pointer (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- AC4: a SKILL.md missing the pointer entirely fails the check
d="$(make_fixture_repo)"
python3 - "$d/skills/atelier-ventes/en/SKILL.md" <<'PY'
import sys, pathlib
p = pathlib.Path(sys.argv[1])
# split('---') on a file with exactly one frontmatter block yields 3 parts:
# ['', frontmatter, body]. Keep the frontmatter, closed, and replace the body
# so it no longer carries the inlined Company Profile pointer.
parts = p.read_text().split('---')
p.write_text('---' + parts[1] + '---\n\n# Sales\n')
PY
if ( cd "$d" && bash scripts/build.sh --check >/dev/null 2>&1 ); then
  fail "AC4 accepted a SKILL.md with no profile pointer"
else
  pass "AC4 rejects a SKILL.md with no profile pointer"
fi
rm -rf "$d"

# --- AC18 / AC34: every built ZIP carries byte-identical shared references
d="$(make_fixture_repo)"
( cd "$d" && bash scripts/build.sh --lang all >/dev/null 2>&1 )
x="$(mktemp -d)"; unzip -q "$d/dist/atelier-ventes-fr.zip" -d "$x"
if cmp -s "$x/references/glossary.md" "$d/skills/shared/fr/glossary.md"; then
  pass "AC18 ZIP glossary is byte-identical to canonical"
else
  fail "AC18 ZIP glossary differs from canonical"
fi
if cmp -s "$x/references/memory-protocol.md" "$d/skills/shared/fr/memory-protocol.md"; then
  pass "AC34 ZIP memory protocol is byte-identical to canonical"
else
  fail "AC34 ZIP memory protocol differs from canonical"
fi
rm -rf "$x" "$d"

# --- AC18: inlined glossary content in a SKILL.md fails the check
d="$(make_fixture_repo)"
cat "$d/skills/shared/fr/glossary.md" >> "$d/skills/atelier-ventes/fr/SKILL.md"
if ( cd "$d" && bash scripts/build.sh --check >/dev/null 2>&1 ); then
  fail "AC18 accepted inlined glossary content in SKILL.md"
else
  pass "AC18 rejects inlined glossary content in SKILL.md"
fi
rm -rf "$d"

# --- AC15: a skill with no scenarios in a locale fails the check
d="$(make_fixture_repo)"
rm -rf "$d/tests/atelier-ventes/en"
if ( cd "$d" && bash scripts/build.sh --check >/dev/null 2>&1 ); then
  fail "AC15 accepted a skill with no EN scenarios"
else
  pass "AC15 rejects a skill with no EN scenarios"
fi
rm -rf "$d"

# --- AC6: a trigger term absent from the description fails the check
d="$(make_fixture_repo)"
sed -i 's/^  - pipeline$/  - relance téléphonique/' "$d/tests/atelier-ventes/fr/pipeline.md"
if ( cd "$d" && bash scripts/build.sh --check >/dev/null 2>&1 ); then
  fail "AC6 accepted a trigger term absent from the description"
else
  pass "AC6 rejects a trigger term absent from the description"
fi
rm -rf "$d"

# --- a clean fixture passes every check
d="$(make_fixture_repo)"
if ( cd "$d" && bash scripts/build.sh --check >/dev/null 2>&1 ); then
  pass "clean fixture passes --check"
else
  fail "clean fixture failed --check"
fi
[[ ! -d "$d/dist" ]] && pass "--check leaves dist/ untouched" || fail "--check wrote to dist/"
rm -rf "$d"

# --- a failing --check leaves no leaked temp directory behind
# Build the fixture first (make_fixture_repo itself calls mktemp -d, which
# would honor a repointed TMPDIR and pollute the emptiness check below).
d="$(make_fixture_repo)"
sed -i '/^version: /d' "$d/skills/atelier-ventes/fr/SKILL.md"
fresh_tmpdir="$(mktemp -d)"
( cd "$d" && TMPDIR="$fresh_tmpdir" bash scripts/build.sh --check >/dev/null 2>&1 )
leftover="$(find "$fresh_tmpdir" -mindepth 1 2>/dev/null)"
if [[ -z "$leftover" ]]; then
  pass "failing --check leaves no leaked temp directory"
else
  fail "failing --check leaked temp entries: $leftover"
fi
rm -rf "$fresh_tmpdir" "$d"

# --- Fix 1: a drifted profile-pointer copy in a references/*.md file (not
# SKILL.md) fails the check and names the offending file
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/fr/references"
fr_pointer_head="$(head -1 "$REPO_ROOT/skills/shared/fr/profile-pointer.md")"
cat > "$d/skills/atelier-ventes/fr/references/scaffold.md" <<EOF
# Gabarit

$fr_pointer_head
la connaissance du projet fait foi, jamais le fichier.
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] && grep -q "atelier-ventes/fr/references/scaffold.md" <<<"$out"; then
  pass "Fix1 rejects a drifted profile pointer in a references/*.md file and names it"
else
  fail "Fix1 did not reject drifted reference pointer (rc=$rc, out=$out)"
fi
rm -rf "$d"

echo
if [[ "$FAILURES" -eq 0 ]]; then echo "STATUS: PASS"; exit 0; else echo "STATUS: FAIL ($FAILURES)"; exit 1; fi

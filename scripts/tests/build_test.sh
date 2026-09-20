#!/usr/bin/env bash
# Tests for scripts/build.sh, run against synthetic fixture repos in $TMPDIR.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
FAILURES=0
fail() { echo "FAIL: $*"; FAILURES=$((FAILURES + 1)); }
pass() { echo "ok: $*"; }

# Run --check in a fixture and require both a non-zero exit and a named path
# in the combined output. Every coherence mutation is asserted this way, so
# a fixture that breaks for an unrelated reason cannot pass by accident.
expect_check_fail() {
  local dir="$1" needle="$2" label="$3" out rc
  out="$( cd "$dir" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
  if [[ "$rc" -ne 0 ]] && grep -qF -- "$needle" <<<"$out"; then
    pass "$label"
  else
    fail "$label (rc=$rc, out=$out)"
  fi
}

# --- Dated-claim fixture helpers (2026-09-19 spec).
#
# AC35: every fixture date is computed from the run date, never written as a
# literal, so no test's outcome changes as the calendar advances. Both
# conversions are the civil algorithm in awk — `date -d` is GNU-only and the
# build script is forbidden from using it, so the tests do not either.
days_ago() {
  awk -v n="$1" -v today="$(date +%Y-%m-%d)" '
    function days_from_civil(y, m, d,   era, yoe, doy, doe) {
      if (m <= 2) y -= 1
      era = int((y >= 0 ? y : y - 399) / 400)
      yoe = y - era * 400
      doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
      doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
      return era * 146097 + doe - 719468
    }
    function civil_from_days(z,   era, doe, yoe, y, doy, mp, d, m) {
      z += 719468
      era = int((z >= 0 ? z : z - 146096) / 146097)
      doe = z - era * 146097
      yoe = int((doe - int(doe / 1460) + int(doe / 36524) - int(doe / 146096)) / 365)
      y = yoe + era * 400
      doy = doe - (365 * yoe + int(yoe / 4) - int(yoe / 100))
      mp = int((5 * doy + 2) / 153)
      d = doy - int((153 * mp + 2) / 5) + 1
      m = mp + (mp < 10 ? 3 : -9)
      if (m <= 2) y += 1
      return sprintf("%04d-%02d-%02d", y, m, d)
    }
    BEGIN {
      t = days_from_civil(substr(today,1,4)+0, substr(today,6,2)+0, substr(today,9,2)+0)
      print civil_from_days(t - n)
    }'
}

# Write one valid annotation of the given locale, dated n days ago, into a
# reference file inside the fixture.
write_annotation() {
  local dir="$1" locale="$2" rel="$3" days="$4" d
  d="$(days_ago "$days")"
  mkdir -p "$(dirname "$dir/$rel")"
  if [[ "$locale" == "en" ]]; then
    cat > "$dir/$rel" <<EOF
# Module

Prose above the annotation.

> **Last verified $d** — source: Anthropic help center, article 15520349
> ("Use Claude Cowork on web, desktop, and mobile"). Continuation prose the
> check never reads.

Prose below.
EOF
  else
    cat > "$dir/$rel" <<EOF
# Module

Prose au-dessus de l'annotation.

> **Vérifié le $d** — source : centre d'aide Anthropic, article 15520349
> (« Use Claude Cowork on web, desktop, and mobile »). Prose de continuation
> que la vérification ne lit jamais.

Prose en dessous.
EOF
  fi
}

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
version: 0.1.0 # x-release-please-version
---

# Ventes

$fr_pointer
EOF
  cat > "$dir/skills/atelier-ventes/en/SKILL.md" <<EOF
---
name: atelier-sales
description: Use when the conversation turns to pipeline, follow-ups, or proposals.
version: 0.1.0 # x-release-please-version
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

  printf '0.1.0\n' > "$dir/version.txt"

  cat > "$dir/.release-please-manifest.json" <<'EOF'
{
  ".": "0.1.0"
}
EOF

  cat > "$dir/release-please-config.json" <<'EOF'
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
EOF

  cat > "$dir/README.md" <<'EOF'
# Fixture

Version 0.1.0 <!-- x-release-please-version -->

Version 0.1.0 <!-- x-release-please-version -->
EOF

  mkdir -p "$dir/docs"
  cat > "$dir/docs/WHATS-NEW.md" <<'EOF'
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.

**English** — First release.
EOF

  # 2026-09-19/AC10b makes an absent anchor list fatal, so the clean fixture
  # carries one, pointing at one anchored module with a valid annotation.
  mkdir -p "$dir/skills/atelier-ventes/en/references/tutorial"
  printf 'skills/atelier-ventes/en/references/tutorial/03.md\n' > "$dir/skills/dated-claims.tsv"
  write_annotation "$dir" en "skills/atelier-ventes/en/references/tutorial/03.md" 10

  # 2026-09-19-headings/AC16 — an absent registry is fatal (the dated-claims
  # anchor list behaves the same way), so the clean fixture carries one row
  # and the two parallel templates it points at.
  mkdir -p "$dir/skills/atelier-ventes/fr/references" \
           "$dir/skills/atelier-ventes/en/references"
  cat > "$dir/skills/atelier-ventes/fr/references/modele.md" <<'EOF'
# Modèle de revue de pipeline

```markdown
# Revue de pipeline — <entreprise>

## Où en est le pipeline

## Ce qui bloque

## Prochaines relances
```
EOF
  cat > "$dir/skills/atelier-ventes/en/references/template.md" <<'EOF'
# Pipeline review template

```markdown
# Pipeline review — <company>

## Where the pipeline stands

## What is stuck

## Next follow-ups
```
EOF
  printf 'pipeline-doc\t{root}/docs/ventes/pipeline.md\tskills/atelier-ventes/fr/references/modele.md\t1\tskills/atelier-ventes/en/references/template.md\t1\n' \
    > "$dir/skills/exec-documents.tsv"

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

# --- AC50: a version line without the annotation fails, naming the path
d="$(make_fixture_repo)"
sed -i 's/^version: 0\.1\.0 # x-release-please-version$/version: 0.1.0/' \
  "$d/skills/atelier-ventes/fr/SKILL.md"
expect_check_fail "$d" "skills/atelier-ventes/fr/SKILL.md" \
  "AC50 rejects a version line without the annotation"
rm -rf "$d"

# --- AC50: two version: lines in the frontmatter fail, naming the path
d="$(make_fixture_repo)"
sed -i '4a version: 0.1.0 # x-release-please-version' \
  "$d/skills/atelier-ventes/en/SKILL.md"
expect_check_fail "$d" "skills/atelier-ventes/en/SKILL.md" \
  "AC50 rejects two version: lines in the frontmatter"
rm -rf "$d"

# --- AC50: no version: line at all fails, naming the path
d="$(make_fixture_repo)"
sed -i '/^version: /d' "$d/skills/atelier-ventes/fr/SKILL.md"
expect_check_fail "$d" "skills/atelier-ventes/fr/SKILL.md" \
  "AC50 rejects a frontmatter with no version: line"
rm -rf "$d"

# --- AC50: a malformed SemVer on the annotated line fails, naming the path
d="$(make_fixture_repo)"
sed -i 's/^version: 0\.1\.0 # x-release-please-version$/version: 0.1 # x-release-please-version/' \
  "$d/skills/atelier-ventes/en/SKILL.md"
expect_check_fail "$d" "skills/atelier-ventes/en/SKILL.md" \
  "AC50 rejects a malformed SemVer on the annotated line"
rm -rf "$d"

# --- AC51: two skills declaring different versions fails, reporting both values
d="$(make_fixture_repo)"
sed -i 's/^version: 0\.1\.0 # x-release-please-version$/version: 0.2.0 # x-release-please-version/' \
  "$d/skills/atelier-ventes/en/SKILL.md"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] && grep -qF '0.2.0' <<<"$out" && grep -qF '0.1.0' <<<"$out"; then
  pass "AC51 rejects mismatched skill versions and reports both values"
else
  fail "AC51 did not report both disagreeing versions (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- AC51: version.txt disagreeing with the skills fails, reporting both values
d="$(make_fixture_repo)"
printf '0.3.0\n' > "$d/version.txt"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] && grep -qF '0.3.0' <<<"$out" && grep -qF '0.1.0' <<<"$out"; then
  pass "AC51 rejects a version.txt disagreeing with the skills"
else
  fail "AC51 did not report the version.txt disagreement (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- AC52: a SKILL.md absent from extra-files fails, naming the path
d="$(make_fixture_repo)"
grep -v 'skills/atelier-ventes/en/SKILL.md' "$d/release-please-config.json" \
  > "$d/rp.tmp"
# The removed line carried the trailing comma's partner; re-close the array.
sed -i 's/{ "type": "generic", "path": "skills\/atelier-ventes\/fr\/SKILL.md" },/{ "type": "generic", "path": "skills\/atelier-ventes\/fr\/SKILL.md" }/' \
  "$d/rp.tmp"
mv "$d/rp.tmp" "$d/release-please-config.json"
expect_check_fail "$d" "skills/atelier-ventes/en/SKILL.md" \
  "AC52 rejects a SKILL.md absent from extra-files"
rm -rf "$d"

# --- AC52: an extra-files entry lacking type: generic fails, naming the path
d="$(make_fixture_repo)"
sed -i 's/{ "type": "generic", "path": "skills\/atelier-ventes\/fr\/SKILL.md" }/{ "type": "json", "path": "skills\/atelier-ventes\/fr\/SKILL.md" }/' \
  "$d/release-please-config.json"
expect_check_fail "$d" "skills/atelier-ventes/fr/SKILL.md" \
  "AC52 rejects an extra-files entry that is not type generic"
rm -rf "$d"

# --- AC52: an extra-files entry outside the required set fails, naming it
d="$(make_fixture_repo)"
sed -i '/"path": "README.md"/a\        { "type": "generic", "path": "docs/WHATS-NEW.md" },' \
  "$d/release-please-config.json"
expect_check_fail "$d" "docs/WHATS-NEW.md" \
  "AC52 rejects an extra-files entry outside the required set"
rm -rf "$d"

# --- AC59: README.md missing an annotation fails, naming README.md
d="$(make_fixture_repo)"
sed -i '0,/^Version 0\.1\.0 <!-- x-release-please-version -->$/s//Version 0.1.0/' \
  "$d/README.md"
expect_check_fail "$d" "README.md" "AC59 rejects a README with one annotation"
rm -rf "$d"

# --- AC59: an annotated README line disagreeing with version.txt fails
d="$(make_fixture_repo)"
sed -i '0,/^Version 0\.1\.0 <!-- x-release-please-version -->$/s//Version 0.9.9 <!-- x-release-please-version -->/' \
  "$d/README.md"
expect_check_fail "$d" "README.md" \
  "AC59 rejects an annotated README line disagreeing with version.txt"
rm -rf "$d"

# --- AC59: extra-files without a README.md entry fails, naming README.md
d="$(make_fixture_repo)"
sed -i '/"path": "README.md"/d' "$d/release-please-config.json"
expect_check_fail "$d" "README.md" \
  "AC59 rejects extra-files with no README.md entry"
rm -rf "$d"

# --- AC59: an annotated README line carrying no SemVer at all fails, naming
# the path, and must not abort the script under set -euo pipefail.
d="$(make_fixture_repo)"
sed -i '0,/^Version 0\.1\.0 <!-- x-release-please-version -->$/s//<!-- x-release-please-version -->/' \
  "$d/README.md"
expect_check_fail "$d" "README.md" \
  "AC59 rejects an annotated README line with no SemVer"
rm -rf "$d"

# --- AC53: a WHATS-NEW heading with an empty section fails, naming the path
d="$(make_fixture_repo)"
cat > "$d/docs/WHATS-NEW.md" <<'EOF'
# Quoi de neuf / What's new

## v0.1.0

## v0.0.9

**Français** — Ancienne version.

**English** — Old release.
EOF
expect_check_fail "$d" "docs/WHATS-NEW.md" \
  "AC53 rejects a v0.1.0 heading with an empty section"
rm -rf "$d"

# --- AC53: a section missing the English half fails, naming the path
d="$(make_fixture_repo)"
cat > "$d/docs/WHATS-NEW.md" <<'EOF'
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.
EOF
expect_check_fail "$d" "docs/WHATS-NEW.md" \
  "AC53 rejects a section with no English half"
rm -rf "$d"

# --- AC53: a label with no prose after it fails, naming the path
d="$(make_fixture_repo)"
cat > "$d/docs/WHATS-NEW.md" <<'EOF'
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.

**English**
EOF
expect_check_fail "$d" "docs/WHATS-NEW.md" \
  "AC53 rejects a label with no prose after it"
rm -rf "$d"

# --- AC53: no heading for the current version fails, naming the path
d="$(make_fixture_repo)"
sed -i 's/^## v0\.1\.0$/## v0.0.9/' "$d/docs/WHATS-NEW.md"
expect_check_fail "$d" "docs/WHATS-NEW.md" \
  "AC53 rejects a WHATS-NEW with no heading for version.txt's version"
rm -rf "$d"

# --- AC54: each required file, missing then empty, fails naming that path
for target in version.txt release-please-config.json \
              .release-please-manifest.json docs/WHATS-NEW.md README.md; do
  d="$(make_fixture_repo)"
  rm -f "$d/$target"
  expect_check_fail "$d" "$target" "AC54 rejects a missing $target"
  rm -rf "$d"

  d="$(make_fixture_repo)"
  : > "$d/$target"
  expect_check_fail "$d" "$target" "AC54 rejects an empty $target"
  rm -rf "$d"
done

# --- AC54: a version.txt with two lines fails, naming version.txt
d="$(make_fixture_repo)"
printf '0.1.0\n0.1.0\n' > "$d/version.txt"
expect_check_fail "$d" "version.txt" "AC54 rejects a two-line version.txt"
rm -rf "$d"

# --- AC54: a version.txt that is not SemVer fails, naming version.txt
d="$(make_fixture_repo)"
printf 'v0.1.0\n' > "$d/version.txt"
expect_check_fail "$d" "version.txt" "AC54 rejects a non-SemVer version.txt"
rm -rf "$d"

# --- AC54: an unparseable release-please-config.json fails, naming the path
d="$(make_fixture_repo)"
printf '{ "packages": { ".": { "extra-files": [ }\n' \
  > "$d/release-please-config.json"
expect_check_fail "$d" "release-please-config.json" \
  "AC54 rejects an unparseable release-please-config.json"
rm -rf "$d"

# --- AC54: an unparseable .release-please-manifest.json fails, naming the path
d="$(make_fixture_repo)"
printf '{ ".": "0.1.0"\n' > "$d/.release-please-manifest.json"
expect_check_fail "$d" ".release-please-manifest.json" \
  "AC54 rejects an unparseable .release-please-manifest.json"
rm -rf "$d"

# --- 2026-09-19/AC4: an English lead-in under /fr/ fails, naming file and line
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/fr/references/tutorial/03.md" 10
expect_check_fail "$d" "skills/atelier-ventes/fr/references/tutorial/03.md:5" \
  "2026-09-19/AC4 rejects an English lead-in under /fr/"
rm -rf "$d"

# --- 2026-09-19/AC5: a bold span with no date fails, naming file and line
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
sed -i 's/^> \*\*Last verified [0-9-]*\*\*/> **Last verified**/' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC5 rejects a bold span with no date"
rm -rf "$d"

# --- 2026-09-19/AC5: an unclosed bold span fails too
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
sed -i 's/^> \*\*Last verified \([0-9-]*\)\*\* — source:/> **Last verified \1 — source:/' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC5 rejects an unclosed bold span"
rm -rf "$d"

# --- 2026-09-19/AC6: a date shaped right but not a real calendar day fails
for bad in 2026-02-30 2026-13-01 2025-02-29; do
  d="$(make_fixture_repo)"
  write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
  sed -i "s/^> \*\*Last verified [0-9-]*\*\*/> **Last verified $bad**/" \
    "$d/skills/atelier-ventes/en/references/tutorial/03.md"
  expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
    "2026-09-19/AC6 rejects $bad"
  rm -rf "$d"
done

# --- 2026-09-19/AC7: a date later than the run date fails
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" -30
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC7 rejects a future date"
rm -rf "$d"

# --- 2026-09-19/AC8: an absent source segment fails
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
sed -i 's/^\(> \*\*Last verified [0-9-]*\*\*\) — source:.*/\1 no source segment here/' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC8 rejects an absent source segment"
rm -rf "$d"

# --- 2026-09-19/AC8: a source segment followed only by whitespace fails
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
sed -i 's/^\(> \*\*Last verified [0-9-]*\*\* — source:\).*/\1   /' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC8 rejects a source segment of whitespace only"
rm -rf "$d"

# --- 2026-09-19/AC2: a valid French annotation passes
d="$(make_fixture_repo)"
write_annotation "$d" fr "skills/atelier-ventes/fr/references/tutorial/03.md" 10
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "2026-09-19/AC2 a valid French annotation passes"
else
  fail "2026-09-19/AC2 rejected a valid French annotation (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC2: dropping the space before the colon fails. French
# typography requires it, and an editor that "tidies" it away must land red.
d="$(make_fixture_repo)"
write_annotation "$d" fr "skills/atelier-ventes/fr/references/tutorial/03.md" 10
sed -i 's/\*\* — source :/** — source:/' \
  "$d/skills/atelier-ventes/fr/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/fr/references/tutorial/03.md:5" \
  "2026-09-19/AC2 rejects a French annotation missing the space before the colon"
rm -rf "$d"

# --- 2026-09-19/AC2: a French annotation with a bad calendar date fails
d="$(make_fixture_repo)"
write_annotation "$d" fr "skills/atelier-ventes/fr/references/tutorial/03.md" 10
sed -i 's/^> \*\*Vérifié le [0-9-]*\*\*/> **Vérifié le 2026-13-01**/' \
  "$d/skills/atelier-ventes/fr/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/fr/references/tutorial/03.md:5" \
  "2026-09-19/AC2 rejects a French annotation with an impossible date"
rm -rf "$d"

# --- 2026-09-19/AC4: a French lead-in under /en/ fails, the mirror of the
# first test in this task
d="$(make_fixture_repo)"
write_annotation "$d" fr "skills/atelier-ventes/en/references/tutorial/04.md" 10
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/04.md:5" \
  "2026-09-19/AC4 rejects a French lead-in under /en/"
rm -rf "$d"

# --- Review Focus 1: a fenced block quoting the pattern is an example, not an
# annotation. docs/AUTHORING.md mirrors the exact lead-in (2026-09-19/AC39),
# and the day someone copies that example into a skill's references/ the build
# must not fail on it.
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
mkdir -p "$d/skills/atelier-ventes/en/references"
cat > "$d/skills/atelier-ventes/en/references/authoring-example.md" <<'EOF'
# How to write one

Copy this shape exactly:

```
> **Last verified 2026-02-30** — source:
```

The date above is deliberately impossible; it is an example.
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "fenced annotation example is not detected"
else
  fail "fenced annotation example was detected (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- Review Focus 2: a CRLF checkout must produce the same verdict as LF.
# Without the `sub(/\r$/, "", line)` in the scanner the trailing \r lands after
# the source text and a perfectly valid annotation reads as no-source.
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
f="$d/skills/atelier-ventes/en/references/tutorial/03.md"
awk '{ printf "%s\r\n", $0 }' "$f" > "$f.crlf" && mv "$f.crlf" "$f"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "a CRLF annotation validates like its LF twin"
else
  fail "a CRLF annotation failed validation (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- Review Focus 3: skills/<skill>/en/references/fr/… is an English file.
# The locale is the segment directly under the skill directory, not the last
# /en/ or /fr/ anywhere in the path.
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/fr/notes.md" 10
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "locale comes from the skill directory, not a nested path segment"
else
  fail "a nested /fr/ segment misread an English file (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- Fence boundary correctness (adversarial review, post-PR). CommonMark
# §4.5 fences are 0-3 leading spaces then 3+ of the SAME backtick-or-tilde
# character; a naive "```" toggle at column 0 gets this wrong three ways.

# Case A: an indented closing fence must still close the fence. A naive
# toggle only recognizes an unindented "```", so the fence here would never
# close and a real, badly stale annotation right after it would vanish from
# the scan entirely — the dangerous direction, since --check-freshness would
# then pass on a claim that is actually stale.
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/en/references"
cat > "$d/skills/atelier-ventes/en/references/fence-case-a.md" <<'EOF'
# R

```
x
   ```

> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -qF 'dated claims: 2 annotations across 2 files' <<<"$out"; then
  pass "Case A: indented closing fence closes, so the stale annotation after it is seen"
else
  fail "Case A: indented closing fence mishandled (out=$out)"
fi
if ( cd "$d" && bash scripts/build.sh --check-freshness >/dev/null 2>&1 ); then
  fail "Case A: --check-freshness must fail on the now-visible 2020-01-01 claim"
else
  pass "Case A: --check-freshness fails on the now-visible 2020-01-01 claim"
fi
rm -rf "$d"

# Case B: a ~~~ fence must be recognized at all, so an example wrapped in one
# (docs/AUTHORING.md convention) is not counted as a real annotation.
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/en/references"
cat > "$d/skills/atelier-ventes/en/references/fence-case-b.md" <<'EOF'
# R

~~~
> **Last verified 2026-09-15** — source: Anthropic help center, article 12512180
~~~

> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -qF 'dated claims: 2 annotations across 2 files' <<<"$out"; then
  pass "Case B: tilde fence recognized, in-fence example excluded"
else
  fail "Case B: tilde fence not recognized (out=$out)"
fi
rm -rf "$d"

# Case C: an indented opening fence must be recognized too, so an in-fence
# example does not leak in as a real annotation just because it starts with
# leading spaces.
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/en/references"
cat > "$d/skills/atelier-ventes/en/references/fence-case-c.md" <<'EOF'
# R

  ```
> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
  ```
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -qF 'dated claims: 1 annotations across 1 files' <<<"$out"; then
  pass "Case C: indented opening fence recognized, in-fence example excluded"
else
  fail "Case C: indented opening fence not recognized (out=$out)"
fi
rm -rf "$d"

# Case D (regression: bash-vs-PowerShell divergence found in review of
# c3a28a8): CommonMark 4.5 requires trailing "spaces or tabs" only after a
# closing fence's run of characters — nothing else. A closing candidate
# followed by U+00A0 (NO-BREAK SPACE, a common copy-paste artifact from a
# help-centre page) is not blank under that rule, so the fence must NOT
# close. If it wrongly closed, the stale annotation below would become
# visible and the file's count would jump from 0 to 1.
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/en/references"
printf '# R\n\n```\nx\n```\xc2\xa0\n\n> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180\n' \
  > "$d/skills/atelier-ventes/en/references/fence-case-nbsp.md"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -qF 'dated claims: 1 annotations across 1 files' <<<"$out"; then
  pass "Case D: a closing candidate trailed by U+00A0 does not close the fence"
else
  fail "Case D: a closing candidate trailed by U+00A0 wrongly closed the fence (out=$out)"
fi
rm -rf "$d"

# Case E: an opener carrying an info string (``` bash, no space between the
# backticks and the word) still opens a fence — the in-fence example must
# stay excluded.
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/en/references"
cat > "$d/skills/atelier-ventes/en/references/fence-case-info-string.md" <<'EOF'
# R

```bash
> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
```
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -qF 'dated claims: 1 annotations across 1 files' <<<"$out"; then
  pass "Case E: an opener with an info string opens a fence"
else
  fail "Case E: an opener with an info string failed to open a fence (out=$out)"
fi
rm -rf "$d"

# Case F: a closing run longer than the opening run still closes the fence.
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/en/references"
cat > "$d/skills/atelier-ventes/en/references/fence-case-longer-close.md" <<'EOF'
# R

```
> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
````

> **Last verified 2020-01-02** — source: Anthropic help center, article 12512180
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -qF 'dated claims: 2 annotations across 2 files' <<<"$out"; then
  pass "Case F: a closing fence longer than the opening fence closes it"
else
  fail "Case F: a longer closing fence failed to close (out=$out)"
fi
rm -rf "$d"

# Case G: a closing candidate with trailing non-whitespace text does not
# close the fence.
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/en/references"
cat > "$d/skills/atelier-ventes/en/references/fence-case-trailing-text.md" <<'EOF'
# R

```
x
``` bash

> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -qF 'dated claims: 1 annotations across 1 files' <<<"$out"; then
  pass "Case G: a closing candidate with trailing text does not close the fence"
else
  fail "Case G: a closing candidate with trailing text wrongly closed the fence (out=$out)"
fi
rm -rf "$d"

# Case H: a 4-space-indented line is an indented code block, not a fence
# opener, so a real annotation right after it must still be seen.
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/en/references"
cat > "$d/skills/atelier-ventes/en/references/fence-case-four-space.md" <<'EOF'
# R

    ```
> **Last verified 2020-01-01** — source: Anthropic help center, article 12512180
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -qF 'dated claims: 2 annotations across 2 files' <<<"$out"; then
  pass "Case H: a 4-space-indented line does not open a fence"
else
  fail "Case H: a 4-space-indented line wrongly opened a fence (out=$out)"
fi
rm -rf "$d"

# Case I (regression: same root cause as Case D, found sweeping build.ps1 for
# every other place it mirrors awk's `[ \t]` class, in the *opposite,
# more dangerous* direction — a valid file failing CI instead of a stale
# claim staying hidden). CommonMark 4.5's blank test recognizes only literal
# spaces or tabs. A source segment that is only U+00A0 (NBSP) is therefore
# NOT blank, so the annotation is valid and the check must pass.
d="$(make_fixture_repo)"
mkdir -p "$d/skills/atelier-ventes/en/references/tutorial"
day="$(days_ago 10)"
printf '# Module\n\n> **Last verified %s** — source: \xc2\xa0\n' "$day" \
  > "$d/skills/atelier-ventes/en/references/tutorial/03.md"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "Case I: a source segment of only U+00A0 is not blank, the check passes"
else
  fail "Case I: a source segment of only U+00A0 wrongly failed as no-source (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- AC55: the clean fixture passes, with the exact PASS line
d="$(make_fixture_repo)"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && grep -qxF 'STATUS: PASS (mechanical checks)' <<<"$out"; then
  pass "AC55 clean fixture passes with the exact PASS line"
else
  fail "AC55 clean fixture did not print the exact PASS line (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- AC56: --check passes with jq off PATH
# A shim PATH holding only the documented build dependencies. `jq` is absent
# from it by construction, so this proves the checks never reach for it.
d="$(make_fixture_repo)"
shim="$(mktemp -d)"
for tool in bash awk grep find zip unzip sed cat head sort wc cmp mktemp rm mkdir cp mv tr basename dirname printf date; do
  src="$(command -v "$tool" 2>/dev/null)" || continue
  ln -sf "$src" "$shim/$tool"
done
out="$( cd "$d" && PATH="$shim" bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && ! PATH="$shim" command -v jq >/dev/null 2>&1; then
  pass "AC56 --check passes with jq off PATH"
else
  fail "AC56 --check failed without jq (rc=$rc, out=$out)"
fi
rm -rf "$shim" "$d"

# --- AC57: the packaged SKILL.md carries the version without the annotation
d="$(make_fixture_repo)"
( cd "$d" && bash scripts/build.sh --lang all >/dev/null 2>&1 )
x="$(mktemp -d)"
unzip -q "$d/dist/atelier-ventes-fr.zip" -d "$x"
packaged="$(grep '^version:' "$x/SKILL.md")"
if [[ "$packaged" == "version: 0.1.0" ]]; then
  pass "AC57 packaged SKILL.md version line has the annotation stripped"
else
  fail "AC57 packaged version line is '$packaged', expected 'version: 0.1.0'"
fi
if grep -rqF 'x-release-please-version' "$x"; then
  fail "AC57 an archive member still contains x-release-please-version"
else
  pass "AC57 no archive member contains x-release-please-version"
fi
rm -rf "$x" "$d"

# --- 2026-09-19/AC9: an anchored file carrying no annotation fails
d="$(make_fixture_repo)"
cat > "$d/skills/atelier-ventes/en/references/tutorial/03.md" <<'EOF'
# Module

Every dated claim was dropped from this module by a bad merge.
EOF
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md" \
  "2026-09-19/AC9 rejects an anchored file with no dated claim"
rm -rf "$d"

# --- 2026-09-19/AC10: an anchored path that does not exist fails
d="$(make_fixture_repo)"
printf 'skills/atelier-ventes/en/references/tutorial/99-renamed.md\n' \
  >> "$d/skills/dated-claims.tsv"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/99-renamed.md" \
  "2026-09-19/AC10 rejects an anchored path that does not exist"
rm -rf "$d"

# --- 2026-09-19/AC10b: an absent anchor list is itself fatal. A repository
# must not be able to opt out of AC9 by deleting the list.
d="$(make_fixture_repo)"
rm -f "$d/skills/dated-claims.tsv"
expect_check_fail "$d" "skills/dated-claims.tsv" \
  "2026-09-19/AC10b rejects an absent anchor list"
rm -rf "$d"

# --- Review Focus 4: a trailing newline is normal in a text file, and a
# Windows editor writes CRLF. Neither may become an empty or \r-suffixed
# anchor path that fails with a meaningless name.
d="$(make_fixture_repo)"
printf 'skills/atelier-ventes/en/references/tutorial/03.md\r\n\r\n\n' \
  > "$d/skills/dated-claims.tsv"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "anchor list tolerates blank lines and CRLF"
else
  fail "anchor list rejected blank or CRLF lines (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC15, AC15b: the clean fixture prints exactly one summary line
d="$(make_fixture_repo)"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
n="$(grep -c '^dated claims: ' <<<"$out")"
if [[ "$rc" -eq 0 ]] && [[ "$n" -eq 1 ]] \
   && grep -qE '^dated claims: 1 annotations across 1 files, oldest [0-9]{4}-[0-9]{2}-[0-9]{2} \(10 days\)$' <<<"$out"; then
  pass "2026-09-19/AC15 clean fixture prints exactly one summary line with date and age"
else
  fail "2026-09-19/AC15 summary line wrong (rc=$rc, count=$n, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC15c: with every annotation gone the line prints its zero
# form, and the run fails on AC9 rather than on the reporter
d="$(make_fixture_repo)"
cat > "$d/skills/atelier-ventes/en/references/tutorial/03.md" <<'EOF'
# Module

Every dated claim was dropped from this module.
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] \
   && grep -qxF 'dated claims: 0 annotations across 0 files, no dated claim found' <<<"$out" \
   && grep -qF 'carries no dated claim' <<<"$out"; then
  pass "2026-09-19/AC15c zero form prints on a failing run"
else
  fail "2026-09-19/AC15c zero form wrong (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC16, AC23: past the report threshold, --check prints the note
# and still exits 0
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 200
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] \
   && grep -qF 'NOTE: oldest dated claim is 200 days old (report threshold 180)' <<<"$out" \
   && grep -qF 'skills/atelier-ventes/en/references/tutorial/03.md:5' <<<"$out" \
   && grep -qF 'docs/tutorial-corpus.md' <<<"$out"; then
  pass "2026-09-19/AC16 note printed past the report threshold, exit still 0"
else
  fail "2026-09-19/AC16 note wrong (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC17: under the report threshold there is no note
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 179
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && ! grep -qF 'NOTE: oldest dated claim' <<<"$out"; then
  pass "2026-09-19/AC17 no note under the report threshold"
else
  fail "2026-09-19/AC17 printed a note it should not have (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC11: a clean repo exits 0 with the exact PASS line, with the
# summary line above it
d="$(make_fixture_repo)"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && grep -qxF 'STATUS: PASS (mechanical checks)' <<<"$out"; then
  pass "2026-09-19/AC11 clean repo exits 0 with the exact PASS line"
else
  fail "2026-09-19/AC11 clean repo did not pass cleanly (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC14: neither threshold appears as a bare literal outside its
# constant definition. DATED_CLAIMS_AWK_LIB is excluded from the scan: the two
# named constants are REPORT_AGE_DAYS and FAIL_AGE_DAYS, but the 365 inside
# that awk block is Howard Hinnant's civil-calendar library computing the
# length of a common year — date arithmetic, not a threshold — and is not the
# duplication AC14 is guarding against.
for pair in "REPORT_AGE_DAYS 180" "FAIL_AGE_DAYS 365"; do
  set -- $pair
  hits="$(awk '
            /^DATED_CLAIMS_AWK_LIB=./ { skip = 1; next }
            skip && /^'"'"'$/ { skip = 0; next }
            !skip
          ' "$REPO_ROOT/scripts/build.sh" \
          | grep -nE "(^|[^A-Za-z0-9_])$2([^0-9]|$)" \
          | grep -vE "^[0-9]+:$1=" | wc -l)"
  if [[ "$hits" -eq 0 ]]; then
    pass "2026-09-19/AC14 $2 appears only as $1"
  else
    fail "2026-09-19/AC14 $2 appears as a bare literal $hits time(s) in build.sh"
  fi
done

# --- Review Focus 5: an annotation dated today is age 0, not a future date
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 0
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && grep -qF 'oldest '"$(days_ago 0)"' (0 days)' <<<"$out"; then
  pass "an annotation dated today is age 0, not a future date"
else
  fail "today's date mishandled (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- Review Focus 5: exactly REPORT_AGE_DAYS prints the note (>=, not >)
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 180
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && grep -qF 'NOTE: oldest dated claim is 180 days old' <<<"$out"; then
  pass "exactly REPORT_AGE_DAYS prints the note"
else
  fail "the report threshold is exclusive where it should be inclusive (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC3b: on a tie, "the oldest" is the first in scan order —
# lexicographic by path, then ascending by line
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 200
printf 'skills/atelier-ventes/en/references/tutorial/01.md
' >> "$d/skills/dated-claims.tsv"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/01.md" 200
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] \
   && grep -A 1 'NOTE: oldest dated claim' <<<"$out" | grep -qF 'tutorial/01.md:5'; then
  pass "2026-09-19/AC3b a path tie resolves to the lexicographically first file"
else
  fail "2026-09-19/AC3b picked the wrong file on a tie (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC3b: two annotations at the same date in ONE file resolve to
# the lower line number
d="$(make_fixture_repo)"
dd="$(days_ago 200)"
cat > "$d/skills/atelier-ventes/en/references/tutorial/03.md" <<EOF
# Module

> **Last verified $dd** — source: first annotation, line 3.

Prose between them.

> **Last verified $dd** — source: second annotation, line 7.
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -A 1 'NOTE: oldest dated claim' <<<"$out" | grep -qF 'tutorial/03.md:3'; then
  pass "2026-09-19/AC3b a line tie resolves to the lower line number"
else
  fail "2026-09-19/AC3b picked the wrong line on a tie (out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC20: everything younger than FAIL_AGE_DAYS exits 0
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 364
( cd "$d" && bash scripts/build.sh --check-freshness >/dev/null 2>&1 ) \
  && pass "2026-09-19/AC20 --check-freshness exits 0 under FAIL_AGE_DAYS" \
  || fail "2026-09-19/AC20 --check-freshness failed under FAIL_AGE_DAYS"
rm -rf "$d"

# --- 2026-09-19/AC21 + Review Focus 5: exactly FAIL_AGE_DAYS fails, and the
# report lists every annotation at or over REPORT_AGE_DAYS with file, line,
# date and age
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 365
printf 'skills/atelier-ventes/fr/references/tutorial/03.md\n' >> "$d/skills/dated-claims.tsv"
write_annotation "$d" fr "skills/atelier-ventes/fr/references/tutorial/03.md" 200
out="$( cd "$d" && bash scripts/build.sh --check-freshness 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] \
   && grep -qF "skills/atelier-ventes/en/references/tutorial/03.md:5 $(days_ago 365) (365 days)" <<<"$out" \
   && grep -qF "skills/atelier-ventes/fr/references/tutorial/03.md:5 $(days_ago 200) (200 days)" <<<"$out"; then
  pass "2026-09-19/AC21 --check-freshness fails at exactly FAIL_AGE_DAYS and lists every claim past REPORT_AGE_DAYS"
else
  fail "2026-09-19/AC21 stale report wrong (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC22: a form failure fails regardless of age
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 1
sed -i 's/^> \*\*Last verified [0-9-]*\*\*/> **Last verified 2026-02-30**/' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
out="$( cd "$d" && bash scripts/build.sh --check-freshness 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] && grep -qF 'not a real calendar day' <<<"$out"; then
  pass "2026-09-19/AC22 --check-freshness fails on a form error regardless of age"
else
  fail "2026-09-19/AC22 form error did not fail --check-freshness (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC19: --check-freshness writes nothing to dist/
d="$(make_fixture_repo)"
( cd "$d" && bash scripts/build.sh --check-freshness >/dev/null 2>&1 )
[[ ! -d "$d/dist" ]] && pass "2026-09-19/AC19 --check-freshness leaves dist/ untouched" \
                     || fail "2026-09-19/AC19 --check-freshness created dist/"
rm -rf "$d"

# --- 2026-09-19-headings/AC16: the clean fixture passes the new rule
d="$(make_fixture_repo)"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "2026-09-19-headings/AC16 clean fixture passes the exec-document rule"
else
  fail "2026-09-19-headings/AC16 clean fixture failed (out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19-headings/AC17: a row naming a reference file that is gone
d="$(make_fixture_repo)"
rm -f "$d/skills/atelier-ventes/fr/references/modele.md"
expect_check_fail "$d" 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md' \
  "2026-09-19-headings/AC17 missing reference file names doc-id and path"
rm -rf "$d"

# --- 2026-09-19-headings/AC18: a block index the file does not have
d="$(make_fixture_repo)"
sed -i "s|modele.md$(printf '\t')1|modele.md$(printf '\t')4|" "$d/skills/exec-documents.tsv"
expect_check_fail "$d" 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md has no markdown template block 4' \
  "2026-09-19-headings/AC18 missing block index names doc-id, file and index"
rm -rf "$d"

# --- Review Focus 1: '-' in some template columns but not all four
d="$(make_fixture_repo)"
sed -i "s|skills/atelier-ventes/fr/references/modele.md$(printf '\t')1|-$(printf '\t')-|" \
  "$d/skills/exec-documents.tsv"
expect_check_fail "$d" "pipeline-doc — template columns are partly '-'" \
  "Review Focus 1 half-prose row is rejected"
rm -rf "$d"

# --- Review Focus 2: a row with the wrong number of columns
d="$(make_fixture_repo)"
printf 'stray\t{root}/docs/stray.md\t-\t-\t-\n' >> "$d/skills/exec-documents.tsv"
expect_check_fail "$d" 'expected 6 tab-separated columns, found 5' \
  "Review Focus 2 wrong column count is rejected by line"
rm -rf "$d"

# --- Review Focus 3: a CRLF checkout of the registry still passes
d="$(make_fixture_repo)"
awk '{ printf "%s\r\n", $0 }' "$d/skills/exec-documents.tsv" > "$d/tmp.tsv"
mv "$d/tmp.tsv" "$d/skills/exec-documents.tsv"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "Review Focus 3 a CRLF registry is read the same as an LF one"
else
  fail "Review Focus 3 CRLF registry failed (out=$out)"
fi
rm -rf "$d"

# --- Review Focus 3b: a CRLF template file is read the same as an LF one
d="$(make_fixture_repo)"
awk '{ printf "%s\r\n", $0 }' "$d/skills/atelier-ventes/fr/references/modele.md" > "$d/tmp.md"
mv "$d/tmp.md" "$d/skills/atelier-ventes/fr/references/modele.md"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "Review Focus 3b a CRLF template file is read the same as an LF one"
else
  fail "Review Focus 3b CRLF template file failed (out=$out)"
fi
rm -rf "$d"

# --- Review Focus 4: the same reference file named for both locales
d="$(make_fixture_repo)"
sed -i 's|skills/atelier-ventes/en/references/template.md|skills/atelier-ventes/fr/references/modele.md|' \
  "$d/skills/exec-documents.tsv"
expect_check_fail "$d" 'pipeline-doc — names the same reference file for both locales' \
  "Review Focus 4 one file for both locales is rejected"
rm -rf "$d"

# --- 2026-09-19-headings/AC17: an absent registry is fatal, as for dated-claims
d="$(make_fixture_repo)"
rm -f "$d/skills/exec-documents.tsv"
expect_check_fail "$d" 'skills/exec-documents.tsv — exec-facing document registry not found' \
  "2026-09-19-headings/AC17 an absent registry fails by name"
rm -rf "$d"

# --- Review Focus 6: a bash block quoting a markdown opener is not counted
# as a template block. The quoted opener uses four backticks (the bash fence
# itself uses three) so that, were the "enter every fence, target or not"
# behaviour broken, the resulting phantom block would run unclosed to EOF
# (nothing later in the file has a four-backtick bare closer) rather than
# just silently swallowing the wrong content — a difference this check's
# MISSING/UNCLOSED reporting can actually observe.
d="$(make_fixture_repo)"
cat > "$d/skills/atelier-ventes/en/references/template.md" <<'EOF'
# Pipeline review template

```bash
# quoting a template fence opener as an example, not a real block:
````markdown
```

```markdown
# Pipeline review — <company>

## Where the pipeline stands

## What is stuck

## Next follow-ups
```
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "Review Focus 6 a bash block quoting a markdown opener is not counted as a template block"
else
  fail "Review Focus 6 bash-quoted opener miscounted (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19-headings/AC19: one locale's template drops a section
d="$(make_fixture_repo)"
sed -i '/^## Ce qui bloque$/d' "$d/skills/atelier-ventes/fr/references/modele.md"
expect_check_fail "$d" 'pipeline-doc — heading counts differ' \
  "2026-09-19-headings/AC19 a dropped section fails, naming doc-id and both files"
rm -rf "$d"

# --- 2026-09-19-headings/AC20: same count, one heading at a different depth
d="$(make_fixture_repo)"
sed -i 's/^## What is stuck$/### What is stuck/' "$d/skills/atelier-ventes/en/references/template.md"
expect_check_fail "$d" 'pipeline-doc — heading levels differ' \
  "2026-09-19-headings/AC20 a changed depth fails"
rm -rf "$d"

# --- 2026-09-19-headings/AC20: same count and depths, different order
d="$(make_fixture_repo)"
cat > "$d/skills/atelier-ventes/en/references/template.md" <<'EOF'
# Pipeline review template

```markdown
## Where the pipeline stands

# Pipeline review — <company>

## What is stuck

## Next follow-ups
```
EOF
expect_check_fail "$d" 'pipeline-doc — heading levels differ' \
  "2026-09-19-headings/AC20 a reordered depth sequence fails"
rm -rf "$d"

# --- 2026-09-19-headings/AC21: a '-' row is neither compared nor failed
d="$(make_fixture_repo)"
printf 'prose-doc\t{root}/docs/atelier/decisions.md\t-\t-\t-\t-\n' >> "$d/skills/exec-documents.tsv"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && ! grep -qF 'prose-doc' <<<"$out"; then
  pass "2026-09-19-headings/AC21 a '-' row produces neither failure nor comparison"
else
  fail "2026-09-19-headings/AC21 '-' row was not skipped (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- Review Focus 5: a template block left open at EOF
d="$(make_fixture_repo)"
sed -i '$ d' "$d/skills/atelier-ventes/fr/references/modele.md"   # drop the closing fence
expect_check_fail "$d" 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md template block 1 is never closed' \
  "Review Focus 5 an unclosed template block fails rather than comparing a truncated list"
rm -rf "$d"

# --- 2026-09-20-heading-pairs/AC11-AC14: exec_doc_heading_text
# The function is sourced out of build.sh rather than re-implemented: these
# assert the real shipped code, not a copy that can drift from it.
ht_setup() {
  local d; d="$(mktemp -d)"
  cp "$REPO_ROOT/scripts/build.sh" "$d/build.sh"
  echo "$d"
}

# Run one exec_doc_heading_text call against a file, printing its stdout.
# build.sh runs main() on load, so it is sourced with --check-freshness-style
# argument suppression: the subshell exits before main by trapping on a
# sentinel. Simpler and fully equivalent: invoke a tiny driver script.
ht_run() {
  local script="$1" file="$2" want="$3"
  bash -c '
    set -euo pipefail
    # Stop build.sh before it runs main "$@": read every line up to the last.
    head -n -1 "$1" > "$1.lib"
    # shellcheck disable=SC1090
    source "$1.lib"
    exec_doc_heading_text "$2" "$3"
  ' _ "$script" "$file" "$want"
}

d="$(ht_setup)"
cat > "$d/ref.md" <<'EOF'
# Prose title

```markdown
# Title
## Plain heading
###	Tab separated
   ## Indented two
##
### Deep
```
EOF
out="$(ht_run "$d/build.sh" "$d/ref.md" 1)"
expected=$'1 Title\n2 Plain heading\n3 Tab separated\n2 Indented two\n2 \n3 Deep'
if [[ "$out" == "$expected" ]]; then
  pass "AC11 extraction strips indent, marker and separator; empty heading is empty"
else
  fail "AC11 extraction wrong (got: $(printf '%q' "$out"))"
fi
rm -rf "$d"

# AC12 — a CRLF checkout yields the same text as an LF one.
d="$(ht_setup)"
printf '```markdown\r\n# Title\r\n## Current practice\r\n```\r\n' > "$d/ref.md"
out="$(ht_run "$d/build.sh" "$d/ref.md" 1)"
if [[ "$out" == $'1 Title\n2 Current practice' ]]; then
  pass "AC12 CRLF checkout extracts the same text, no trailing carriage return"
else
  fail "AC12 CRLF extraction wrong (got: $(printf '%q' "$out"))"
fi
rm -rf "$d"

# AC13 — a ```bash block quoting a ```markdown opener is not counted.
d="$(ht_setup)"
cat > "$d/ref.md" <<'EOF'
```bash
cat <<'INNER'
```markdown
## Decoy
INNER
```

```markdown
## Real heading
```
EOF
out="$(ht_run "$d/build.sh" "$d/ref.md" 1)"
if [[ "$out" == '2 Real heading' ]]; then
  pass "AC13 quoted markdown opener is not counted toward the block index"
else
  fail "AC13 nested-fence counting wrong (got: $(printf '%q' "$out"))"
fi
rm -rf "$d"

# AC14 — UNCLOSED and MISSING sentinels.
d="$(ht_setup)"
printf '```markdown\n## Never closed\n' > "$d/ref.md"
out="$(ht_run "$d/build.sh" "$d/ref.md" 1)"
[[ "$out" == 'UNCLOSED' ]] && pass "AC14 unclosed target block reports UNCLOSED" \
  || fail "AC14 expected UNCLOSED, got $(printf '%q' "$out")"
printf '```markdown\n## Only one\n```\n' > "$d/ref.md"
out="$(ht_run "$d/build.sh" "$d/ref.md" 2)"
[[ "$out" == 'MISSING' ]] && pass "AC14 too-high block index reports MISSING" \
  || fail "AC14 expected MISSING, got $(printf '%q' "$out")"
rm -rf "$d"

# Review Focus 3 — an empty markdown block yields no headings, not an error.
d="$(ht_setup)"
printf '```markdown\n```\n' > "$d/ref.md"
out="$(ht_run "$d/build.sh" "$d/ref.md" 1)"
[[ -z "$out" ]] && pass "empty template block extracts to nothing" \
  || fail "empty block should extract to nothing, got $(printf '%q' "$out")"
rm -rf "$d"

# --- 2026-09-20-heading-pairs/AC1-AC10, AC15-AC20: the generated reference.
#
# expect_build_fail is the build-time twin of expect_check_fail above: these
# paths die() on a plain `--lang all`, not only under --check, which is the
# whole point of validating inside the generator (2026-09-20-heading-pairs/AC20).
expect_build_fail() {
  local dir="$1" needle="$2" label="$3" out rc
  out="$( cd "$dir" && bash scripts/build.sh --lang fr 2>&1 )" && rc=0 || rc=1
  if [[ "$rc" -ne 0 ]] && grep -qF -- "$needle" <<<"$out"; then
    pass "$label"
  else
    fail "$label (rc=$rc, out=$out)"
  fi
}

# Extract the generated reference out of a built ZIP.
staged_pairs() {
  local dir="$1" zip="$2" locale="$3"
  unzip -p "$dir/dist/$zip" references/exec-document-headings.md 2>/dev/null
}

# AC1 — the file is in every ZIP, both locales, both build scripts.
d="$(make_fixture_repo)"
( cd "$d" && bash scripts/build.sh --lang all >/dev/null 2>&1 )
build_rc=$?
[[ "$build_rc" -eq 0 ]] \
  && pass "AC1 the clean fixture build itself succeeds" \
  || fail "AC1 the clean fixture build failed (rc=$build_rc) — downstream assertions in this section would pass vacuously"
for z in atelier-ventes-fr.zip atelier-sales-en.zip; do
  if unzip -l "$d/dist/$z" 2>/dev/null | grep -qE ' references/exec-document-headings\.md$'; then
    pass "AC1 $z carries references/exec-document-headings.md"
  else
    fail "AC1 $z missing references/exec-document-headings.md"
  fi
done

# AC2 — the file begins with the locale's preamble, byte-identical.
for pair in "atelier-ventes-fr.zip fr" "atelier-sales-en.zip en"; do
  set -- $pair
  pre="$(cat "$d/skills/shared/$2/exec-document-headings.md")"
  body="$(staged_pairs "$d" "$1" "$2")"
  if [[ "$body" == "$pre"* ]]; then
    pass "AC2 $1 begins with the $2 preamble byte-identical"
  else
    fail "AC2 $1 does not begin with the $2 preamble"
  fi
done

# AC3, AC4, AC5, AC6 — one group, named by doc-id, path verbatim, level-2
# headings paired in document order, no level-1 title.
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
grep -qxF '## pipeline-doc' <<<"$body" \
  && pass "AC3 the templated row produces a group named by doc-id" \
  || fail "AC3 no '## pipeline-doc' group"
grep -qxF '`{root}/docs/ventes/pipeline.md`' <<<"$body" \
  && pass "AC4 the group carries the registry's canonical path verbatim" \
  || fail "AC4 canonical path missing or altered"
expected_rows=$'| ## Où en est le pipeline | ## Where the pipeline stands |\n| ## Ce qui bloque | ## What is stuck |\n| ## Prochaines relances | ## Next follow-ups |'
if grep -qF -- "| ## Où en est le pipeline | ## Where the pipeline stands |" <<<"$body" \
   && [[ "$(grep -c '^| ## ' <<<"$body")" -eq 3 ]] \
   && [[ "$(grep '^| ## ' <<<"$body")" == "$expected_rows" ]]; then
  pass "AC5 both spellings pair on one line, in document order"
else
  fail "AC5 rows wrong: $(grep '^| ## ' <<<"$body")"
fi
if grep -qxF '## pipeline-doc' <<<"$body" && ! grep -qF 'Revue de pipeline' <<<"$body"; then
  pass "AC6 no level-1 heading appears in the generated file, which does hold the group"
else
  fail "AC6 a level-1 title leaked into the generated file, or the group itself is missing"
fi
rm -rf "$d"

# AC7 — a row whose template block holds only a level-1 title yields no group.
d="$(make_fixture_repo)"
cat > "$d/skills/atelier-ventes/fr/titre.md" <<'EOF'
```markdown
# Registre des rôles
```
EOF
cat > "$d/skills/atelier-ventes/en/title.md" <<'EOF'
```markdown
# Role registry
```
EOF
printf 'title-only\t{root}/docs/atelier/roles.md\tskills/atelier-ventes/fr/titre.md\t1\tskills/atelier-ventes/en/title.md\t1\n' \
  >> "$d/skills/exec-documents.tsv"
( cd "$d" && bash scripts/build.sh --lang fr >/dev/null 2>&1 )
rc=$?
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
if [[ "$rc" -eq 0 ]] && grep -qxF '## pipeline-doc' <<<"$body" \
   && ! grep -qxF '## title-only' <<<"$body"; then
  pass "AC7 a title-only row produces no group, while the build still succeeds and the other group survives"
else
  fail "AC7 a title-only row produced a group, or the build did not actually succeed (rc=$rc)"
fi
rm -rf "$d"

# AC8 — two rows sharing one reference file and one canonical path stay two
# separate groups, each carrying its own block's headings.
d="$(make_fixture_repo)"
cat > "$d/skills/atelier-ventes/fr/deux.md" <<'EOF'
```markdown
# Relais
## Ce qui a été fait
```

```markdown
# Relais tutoriel
## Ce qui a été couvert
```
EOF
cat > "$d/skills/atelier-ventes/en/two.md" <<'EOF'
```markdown
# Relay
## What was done
```

```markdown
# Tutorial relay
## What was covered
```
EOF
printf 'relay-a\t{root}/docs/atelier/relais/x.md\tskills/atelier-ventes/fr/deux.md\t1\tskills/atelier-ventes/en/two.md\t1\n' >> "$d/skills/exec-documents.tsv"
printf 'relay-b\t{root}/docs/atelier/relais/x.md\tskills/atelier-ventes/fr/deux.md\t2\tskills/atelier-ventes/en/two.md\t2\n' >> "$d/skills/exec-documents.tsv"
( cd "$d" && bash scripts/build.sh --lang fr >/dev/null 2>&1 )
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
if grep -qxF '## relay-a' <<<"$body" && grep -qxF '## relay-b' <<<"$body" \
   && grep -qF '| ## Ce qui a été fait | ## What was done |' <<<"$body" \
   && grep -qF '| ## Ce qui a été couvert | ## What was covered |' <<<"$body"; then
  pass "AC8 two blocks in one file stay two groups with their own headings"
else
  fail "AC8 shared-file rows did not produce two distinct groups"
fi
rm -rf "$d"

# AC9 — a pair whose two spellings are identical is kept, not omitted.
d="$(make_fixture_repo)"
sed -i 's|^## Ce qui bloque$|## Documents|' "$d/skills/atelier-ventes/fr/references/modele.md"
sed -i 's|^## What is stuck$|## Documents|' "$d/skills/atelier-ventes/en/references/template.md"
( cd "$d" && bash scripts/build.sh --lang fr >/dev/null 2>&1 )
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
grep -qF '| ## Documents | ## Documents |' <<<"$body" \
  && pass "AC9 an identical pair is kept like any other" \
  || fail "AC9 identical pair omitted"
rm -rf "$d"

# AC10 — a row with all four template columns '-' produces no group.
d="$(make_fixture_repo)"
printf 'prose-doc\t{root}/docs/atelier/decisions.md\t-\t-\t-\t-\n' >> "$d/skills/exec-documents.tsv"
( cd "$d" && bash scripts/build.sh --lang fr >/dev/null 2>&1 )
rc=$?
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
if [[ "$rc" -eq 0 ]] && grep -qxF '## pipeline-doc' <<<"$body" \
   && ! grep -qxF '## prose-doc' <<<"$body"; then
  pass "AC10 a prose-described row produces no group, while the build still succeeds and the other group survives"
else
  fail "AC10 a prose-described row produced a group, or the build did not actually succeed (rc=$rc)"
fi
rm -rf "$d"

# AC15 — an absent registry fails the build, not only --check.
d="$(make_fixture_repo)"
rm -f "$d/skills/exec-documents.tsv"
expect_build_fail "$d" 'skills/exec-documents.tsv — exec-facing document registry not found' \
  "AC15/AC20 absent registry fails a plain build"
rm -rf "$d"

# AC16 — wrong column count, and partly-'-' template columns.
d="$(make_fixture_repo)"
printf 'stray\t{root}/docs/stray.md\t-\t-\t-\n' >> "$d/skills/exec-documents.tsv"
expect_build_fail "$d" 'expected 6 tab-separated columns, found 5' \
  "AC16/AC20 a five-column row fails a plain build"
rm -rf "$d"

d="$(make_fixture_repo)"
printf 'half\t{root}/docs/half.md\tskills/atelier-ventes/fr/references/modele.md\t1\t-\t-\n' >> "$d/skills/exec-documents.tsv"
expect_build_fail "$d" "half — template columns are partly '-'" \
  "AC16/AC20 a partly-dashed row fails a plain build"
rm -rf "$d"

# AC17 — a missing reference file, and a non-positive-integer block index.
d="$(make_fixture_repo)"
rm -f "$d/skills/atelier-ventes/fr/references/modele.md"
expect_build_fail "$d" 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md listed in skills/exec-documents.tsv but no such file' \
  "AC17/AC20 a renamed reference file fails a plain build"
rm -rf "$d"

d="$(make_fixture_repo)"
sed -i "s|modele.md$(printf '\t')1|modele.md$(printf '\t')0|" "$d/skills/exec-documents.tsv"
expect_build_fail "$d" "pipeline-doc — skills/atelier-ventes/fr/references/modele.md template block index '0' is not a positive integer" \
  "AC17/AC20 a zero block index fails a plain build"
rm -rf "$d"

# AC18 — MISSING and UNCLOSED both fail the build, naming doc-id and file.
d="$(make_fixture_repo)"
sed -i "s|modele.md$(printf '\t')1|modele.md$(printf '\t')4|" "$d/skills/exec-documents.tsv"
expect_build_fail "$d" 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md has no markdown template block 4' \
  "AC18/AC20 a MISSING block fails a plain build"
rm -rf "$d"

d="$(make_fixture_repo)"
printf '# Modèle\n\n```markdown\n# Titre\n## Une section\n' > "$d/skills/atelier-ventes/fr/references/modele.md"
expect_build_fail "$d" 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md template block 1 is never closed' \
  "AC18/AC20 an UNCLOSED block fails a plain build"
rm -rf "$d"

# AC19 — different TOTAL counts, level-1 title included, name both totals.
d="$(make_fixture_repo)"
sed -i '/^## Prochaines relances$/d' "$d/skills/atelier-ventes/fr/references/modele.md"
expect_build_fail "$d" 'pipeline-doc — heading counts differ: skills/atelier-ventes/fr/references/modele.md has 3, skills/atelier-ventes/en/references/template.md has 4' \
  "AC19/AC20 differing total heading counts fail a plain build, naming both totals"
rm -rf "$d"

# Review Focus 2 — equal totals at different depths must not zip out of
# alignment; the build dies naming both level sequences.
d="$(make_fixture_repo)"
sed -i 's|^## Ce qui bloque$|### Ce qui bloque|' "$d/skills/atelier-ventes/fr/references/modele.md"
expect_build_fail "$d" \
  'pipeline-doc — heading levels differ: skills/atelier-ventes/fr/references/modele.md [1 2 3 2], skills/atelier-ventes/en/references/template.md [1 2 2 2]' \
  "equal totals at different depths fail the build naming both sequences"
rm -rf "$d"

# Review Focus 1 — a heading holding '|' is escaped, not allowed to split the row.
d="$(make_fixture_repo)"
sed -i 's|^## Ce qui bloque$|## Bloqué \| en attente|' "$d/skills/atelier-ventes/fr/references/modele.md"
( cd "$d" && bash scripts/build.sh --lang fr >/dev/null 2>&1 )
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
if grep -qF '| ## Bloqué \| en attente | ## What is stuck |' <<<"$body"; then
  pass "a pipe in heading text is escaped, keeping the row two cells wide"
else
  fail "unescaped pipe split the table row: $(grep 'Bloqué' <<<"$body")"
fi
rm -rf "$d"

# Review Focus 4 — a blank line mid-registry is skipped, not read as a row,
# and the real row survives (a blank line that silently swallowed the next
# row would still exit 0).
d="$(make_fixture_repo)"
printf '\n' >> "$d/skills/exec-documents.tsv"
( cd "$d" && bash scripts/build.sh --lang fr >/dev/null 2>&1 )
rc=$?
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
if [[ "$rc" -eq 0 ]] && grep -qxF '## pipeline-doc' <<<"$body"; then
  pass "a blank registry line is skipped, and the row after it still generates its group"
else
  fail "a blank registry line failed the build, or silently dropped the row after it (rc=$rc)"
fi
rm -rf "$d"

# Review Focus 5 — a CRLF registry checkout builds clean, and the row itself
# still generates its group (a CRLF read as part of a column would silently
# fail file/index lookups without necessarily failing the build).
d="$(make_fixture_repo)"
awk '{ printf "%s\r\n", $0 }' "$d/skills/exec-documents.tsv" > "$d/tmp.tsv"
mv "$d/tmp.tsv" "$d/skills/exec-documents.tsv"
( cd "$d" && bash scripts/build.sh --lang fr >/dev/null 2>&1 )
rc=$?
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
if [[ "$rc" -eq 0 ]] && grep -qxF '## pipeline-doc' <<<"$body"; then
  pass "a CRLF registry checkout builds clean, and its row still generates its group"
else
  fail "a CRLF registry checkout failed the build, or its row did not generate a group (rc=$rc)"
fi
rm -rf "$d"

echo
if [[ "$FAILURES" -eq 0 ]]; then echo "STATUS: PASS"; exit 0; else echo "STATUS: FAIL ($FAILURES)"; exit 1; fi

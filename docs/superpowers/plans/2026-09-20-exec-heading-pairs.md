# Shipping both locales' heading spellings — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a generated `references/exec-document-headings.md` in every ZIP so a reader can evaluate ADR-0016's "spelled the way its template spells it, in one locale or the other" test, and rewrite the memory-protocol rule so the failing locale direction stops translating headings the executive renamed.

**Architecture:** `scripts/build.sh` gains a text-extracting twin of the existing `exec_doc_headings()` and a generator that reads `skills/exec-documents.tsv` once per staged skill, pairs each templated row's two locales' template headings, and writes a preamble-plus-table file into the stage. `scripts/build.ps1` mirrors it byte-for-byte. The two `memory-protocol.md` source texts gain a pointer to that file, a cross-language worked example, a both-lists offer requirement, and a no-template rule. Behaviour is then verified by dispatching the existing cross-skill scenario in both directions.

**Tech Stack:** Bash 4+ with `awk` (GNU-free — no `date -d`), PowerShell 7 (`pwsh`), `zip`/`unzip`, markdown skill sources. No runtime, no package manager.

**Spec:** [`docs/superpowers/specs/2026-09-20-exec-heading-pairs-design.md`](../specs/2026-09-20-exec-heading-pairs-design.md)

## Global Constraints

- Conventional Commits. Scopes available: `atelier`, `mentor`, `boussole`, `forge`, `marketing`, `ventes`, `reunions`, `build`, `ci`, `docs`, `install`, `shared`.
- Never hand-edit `version.txt`, a `SKILL.md` version line, or the two annotated `README.md` lines — release-please owns them.
- Never add an AI-attribution line to a commit message or PR body.
- Cite an acceptance criterion as `2026-09-20-heading-pairs/ACn`. A bare `ACn` is ambiguous — six specs number from AC1.
- `scripts/build.sh` may not use `date -d` or any other GNU-only flag; the PowerShell twin must produce byte-identical output.
- Every `die` message names the document id and the offending file or value, matching the wording `check_exec_document_row()` already uses for the same condition.
- The generated table is identical in both locales; only the preamble differs. Column headers are the fixed strings `Français` and `English`.
- `docs/AUTHORING.md` must keep the literal heading `## Exec-facing document headings` — `scripts/tests/authoring_test.sh` greps for it.

## Review Focus

These are input classes the spec implies but no acceptance criterion names. Each line's test is added to the task that owns the code.

1. **A heading whose text contains `|`** — an unescaped pipe splits the table row into extra cells and silently shifts every spelling one column left. Escape `|` as `\|` in both cells. (Task 3)
2. **Two templates with equal total heading counts but different level sequences** — `# / ##` against `## / ##` passes AC19's count check, then zipping the level-2-filtered lists pairs a French heading with the wrong English one. Die naming the doc-id and both sequences, the verdict `check_exec_document_row()` already makes under `--check`. (Task 3)
3. **A template block containing no headings at all** — an empty ` ```markdown ` fence yields zero headings on both sides, which must contribute no group rather than a group with an empty table. (Task 3)
4. **A blank or whitespace-only line in the registry** — must be skipped like `check_exec_documents()` skips it, not read as a one-column row that fails the build. (Task 3)
5. **A CRLF checkout of the registry** — the trailing `\r` must be stripped before the sixth column is compared to `-`, or every row reads as partly-dashed and the build dies on a clean repo. (Task 3)

---

## File Structure

| File | Responsibility |
| --- | --- |
| `skills/shared/fr/exec-document-headings.md` | **Create.** French preamble for the generated reference: what the table is for, why level-1 titles are absent, what to do with a document that is not listed. |
| `skills/shared/en/exec-document-headings.md` | **Create.** English mirror. |
| `scripts/build.sh` | **Modify.** `exec_doc_heading_text()` beside `exec_doc_headings()`; `emit_exec_heading_group()` and `generate_exec_heading_pairs()`; one call from `stage_skill()`. |
| `scripts/build.ps1` | **Modify.** `Get-TemplateBlockHeadingText`, `Write-ExecHeadingGroup`, `New-ExecHeadingPairs`; one call from `New-SkillStage`. |
| `scripts/tests/build_test.sh` | **Modify.** Extraction cases, generated-file content, every `die` path, the five Review Focus inputs. |
| `scripts/tests/build_test.ps1` | **Modify.** The same, mirrored, plus the AC21 byte-identity assertion. |
| `scripts/tests/shared_test.sh` | **Modify.** One name added to the canonical-texts loop. |
| `skills/shared/fr/memory-protocol.md` | **Modify.** Pointer, cross-language worked example, both-lists offer, no-template rule. |
| `skills/shared/en/memory-protocol.md` | **Modify.** The same. |
| `docs/adr/0016-exec-facing-document-section-headings.md` | **Modify.** Decision §4, Consequences, status line. |
| `docs/AUTHORING.md` | **Modify.** `## Exec-facing document headings` records that the reference is generated. |
| `docs/superpowers/specs/2026-09-19-exec-document-headings-design.md` | **Modify.** The AC32/AC33 status note points here. |
| `tests/_cross-skill/changement-de-langue.md` | **Modify.** Two new expected-behaviour boxes, a verification-notes section for the re-run. |

### The generated file's shape

The staged `references/exec-document-headings.md` is the locale's preamble byte-identical, then one group per templated row that yields at least one level-2-or-deeper heading:

```markdown
## progression

`{root}/docs/atelier/progression.md`

| Français | English |
| --- | --- |
| ## Pratique actuelle | ## Current practice |
| ## Pratiques adoptées | ## Practices adopted |
```

The group heading is the **doc-id**, not the path — `relay` and `relay-tutorial` share one canonical path (AC8), so a path-only heading would produce two indistinguishable groups. The path follows on its own line, verbatim from the registry's second column (AC4). Each cell carries the ATX marker reconstructed from the heading's level, so depth is visible without a third column.

---

## Task 1: Text extraction from a template block

**Files:**
- Modify: `scripts/build.sh` — insert after `exec_doc_headings()` ends at `scripts/build.sh:337`
- Test: `scripts/tests/build_test.sh` — append a new section before the final `STATUS:` block

**Interfaces:**
- Consumes: `FENCE_AWK_LIB` (`scripts/build.sh:257`) — provides the awk functions `fence_marker`, `fence_run_len`, `fence_closes`, `atx_level`.
- Produces: `exec_doc_heading_text <file> <block-index>` → stdout, one line per ATX heading in the target block, formatted `<level><space><text>`. The **first** space is the delimiter; text may contain further spaces and `#`. Prints the single word `MISSING` when the file holds fewer than `<block-index>` ` ```markdown ` blocks, and `UNCLOSED` when the target block runs to EOF unclosed. A block with no headings prints nothing. Task 3 consumes this.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/tests/build_test.sh`, immediately before the closing `echo` / `STATUS:` block at the end of the file:

```bash
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
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -E '^(FAIL|ok): AC1[1-4]|empty template'`
Expected: every `AC11`–`AC14` line reports `FAIL`, because `exec_doc_heading_text` is not defined yet.

- [ ] **Step 3: Implement `exec_doc_heading_text()`**

Insert into `scripts/build.sh` immediately after the closing `}` of `exec_doc_headings()` (currently `scripts/build.sh:337`):

```bash
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
```

- [ ] **Step 4: Run the tests to verify they pass**

Run: `bash scripts/tests/build_test.sh 2>&1 | tail -3`
Expected: `STATUS: PASS`

- [ ] **Step 5: Commit**

```bash
git add scripts/build.sh scripts/tests/build_test.sh
git commit -m "feat(build): extract heading text, not only level, from a template block"
```

---

## Task 2: The two preamble source texts

**Files:**
- Create: `skills/shared/fr/exec-document-headings.md`
- Create: `skills/shared/en/exec-document-headings.md`
- Test: `scripts/tests/shared_test.sh:18` — the `for name in ...` loop

**Interfaces:**
- Produces: two source files that Task 3's generator copies verbatim into the stage as the head of `references/exec-document-headings.md`. Both must end with a single trailing newline, because the generator appends directly to them.

- [ ] **Step 1: Write the failing test (AC26)**

In `scripts/tests/shared_test.sh`, change the canonical-texts loop (currently line 18) so it asserts both new files exist and are non-empty in both locales:

```bash
    for name in profile-pointer glossary memory-protocol; do
```

to:

```bash
    for name in profile-pointer glossary memory-protocol exec-document-headings; do
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash scripts/tests/shared_test.sh 2>&1 | grep exec-document-headings`
Expected: two `FAIL:` lines, one per locale, ending `missing or empty`.

- [ ] **Step 3: Write the French preamble**

Create `skills/shared/fr/exec-document-headings.md`:

```markdown
# Titres de section — les deux orthographes

Chaque document que l'Atelier écrit pour la personne dirigeante porte les
titres de section de la langue qui l'a créé. Ce fichier donne, document par
document, l'orthographe française et l'orthographe anglaise de la même
section.

Il sert la deuxième condition de la règle de réécriture, dans
`references/memory-protocol.md` : un titre ne se réécrit que s'il s'écrit
comme ton modèle l'écrit, **dans une langue ou dans l'autre**. Trouve ici le
document que tu as en main, compare chacun de ses titres aux deux colonnes de
sa ligne, et laisse tranquille tout titre qui ne correspond ni à l'une ni à
l'autre.

Les titres de niveau 1 n'y figurent pas. La plupart contiennent un espace
réservé — `# Relais — <sujet> — AAAA-MM-JJ` — qui ne peut répondre à la
question que ce tableau existe pour trancher, et ce n'est de toute façon pas
une section dans laquelle on écrit. N'ayant ici aucune orthographe de modèle,
le titre d'un document reste tel qu'il est écrit.

Un document absent de ce fichier n'a aucune section à comparer : tous ses
titres restent tels quels.

Le tableau ci-dessous est produit par le build à partir de
`skills/exec-documents.tsv`.
```

- [ ] **Step 4: Write the English preamble**

Create `skills/shared/en/exec-document-headings.md`:

```markdown
# Section headings — both spellings

Every document the Atelier writes for the executive carries the section
headings of the locale that created it. This file gives, document by
document, the French spelling and the English spelling of the same section.

It serves the second condition of the rewrite rule in
`references/memory-protocol.md`: a heading is rewritten only when it is
spelled the way your template spells it, **in one language or the other**.
Find the document you are holding here, compare each of its headings against
both columns of its row, and leave alone any heading that matches neither.

Level-1 titles are not listed. Most hold a placeholder — `# Relay —
<subject> — YYYY-MM-DD` — which cannot answer the question this table exists
to settle, and a title is not a section anyone writes into anyway. With no
template spelling here, a document's title stays as it is written.

A document absent from this file has no section to compare: every one of its
headings stays as written.

The table below is generated by the build from `skills/exec-documents.tsv`.
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash scripts/tests/shared_test.sh 2>&1 | tail -3`
Expected: `STATUS: PASS`

- [ ] **Step 6: Commit**

```bash
git add skills/shared/fr/exec-document-headings.md \
        skills/shared/en/exec-document-headings.md \
        scripts/tests/shared_test.sh
git commit -m "feat(shared): add the heading-pair reference preamble in both locales"
```

---

## Task 3: Generate the heading-pair table into every stage

**Files:**
- Modify: `scripts/build.sh` — new functions after `exec_doc_heading_text()`; one call inside `stage_skill()` after the `memory-protocol.md` copy (currently `scripts/build.sh:127`)
- Test: `scripts/tests/build_test.sh`

**Interfaces:**
- Consumes: `exec_doc_heading_text` (Task 1); `skills/shared/<locale>/exec-document-headings.md` (Task 2); `EXEC_DOCS_TSV` (`scripts/build.sh:251`); `REPO_ROOT`, `SHARED_DIR`, `die` (`scripts/build.sh:5-12`).
- Produces: `generate_exec_heading_pairs <locale> <out-path>` — writes the complete staged file. Task 4 mirrors its output byte-for-byte.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/tests/build_test.sh`, after Task 1's block:

```bash
# --- 2026-09-20-heading-pairs/AC1-AC10, AC15-AC20: the generated reference.
#
# expect_build_fail is the build-time twin of expect_check_fail above: these
# paths die() on a plain `--lang all`, not only under --check, which is the
# whole point of validating inside the generator (AC20).
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
grep -qF 'Revue de pipeline' <<<"$body" \
  && fail "AC6 a level-1 title leaked into the generated file" \
  || pass "AC6 no level-1 heading appears in the generated file"
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
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
grep -qxF '## title-only' <<<"$body" \
  && fail "AC7 a title-only row produced a group" \
  || pass "AC7 a title-only row produces no group"
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
body="$(staged_pairs "$d" atelier-ventes-fr.zip fr)"
grep -qxF '## prose-doc' <<<"$body" \
  && fail "AC10 a prose-described row produced a group" \
  || pass "AC10 a prose-described row produces no group"
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
expect_build_fail "$d" 'pipeline-doc — heading levels differ' \
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

# Review Focus 4 — a blank line mid-registry is skipped, not read as a row.
d="$(make_fixture_repo)"
printf '\n' >> "$d/skills/exec-documents.tsv"
( cd "$d" && bash scripts/build.sh --lang fr >/dev/null 2>&1 ) \
  && pass "a blank registry line is skipped" \
  || fail "a blank registry line failed the build"
rm -rf "$d"

# Review Focus 5 — a CRLF registry checkout builds clean.
d="$(make_fixture_repo)"
awk '{ printf "%s\r\n", $0 }' "$d/skills/exec-documents.tsv" > "$d/tmp.tsv"
mv "$d/tmp.tsv" "$d/skills/exec-documents.tsv"
( cd "$d" && bash scripts/build.sh --lang fr >/dev/null 2>&1 ) \
  && pass "a CRLF registry checkout builds clean" \
  || fail "a CRLF registry checkout failed the build"
rm -rf "$d"
```

- [ ] **Step 2: Run the tests to verify they fail**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -c '^FAIL'`
Expected: a non-zero count — every assertion above fails, because no ZIP contains the file yet.

- [ ] **Step 3: Implement the generator**

Insert into `scripts/build.sh` immediately after `exec_doc_heading_text()`:

```bash
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
    [[ "$lvl" -ge 2 ]] || continue        # AC6 — level-1 titles never appear
    marker="$(printf '%*s' "$lvl" '' | tr ' ' '#')"
    rows+=("$(printf '| %s %s | %s %s |' \
      "$marker" "$(esc_table_cell "${fr_all[$i]#* }")" \
      "$marker" "$(esc_table_cell "${en_all[$i]#* }")")")
  done

  # AC3 / AC7 — a block whose only heading is its title contributes no group.
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
    # AC10 — a document described in prose carries '-' in all four columns.
    if [[ "$dashes" -eq 4 ]]; then continue; fi
    [[ "$dashes" -eq 0 ]] \
      || die "$doc_id — template columns are partly '-': a document described in prose carries '-' in all four"

    emit_exec_heading_group "$doc_id" "$path" \
      "$fr_ref" "$fr_block" "$en_ref" "$en_block" >> "$out"
  done < "$EXEC_DOCS_TSV"
}
```

- [ ] **Step 4: Call it from `stage_skill()`**

In `scripts/build.sh`, immediately after the `memory-protocol.md` copy inside `stage_skill()` (currently `scripts/build.sh:127`), add:

```bash
  # 2026-09-20-heading-pairs/AC1 — generated per stage, never checked in.
  generate_exec_heading_pairs "$locale" "$stage/references/exec-document-headings.md"
```

- [ ] **Step 5: Run the tests to verify they pass**

Run: `bash scripts/tests/build_test.sh 2>&1 | tail -3`
Expected: `STATUS: PASS`

- [ ] **Step 6: Verify the real repo generates a sane table**

Run:
```bash
bash scripts/build.sh --lang all >/dev/null && \
  unzip -p dist/atelier-mentor-fr.zip references/exec-document-headings.md | sed -n '/^## progression/,/^$/p;/^| ## /p'
```
Expected: a `## progression` group, the canonical path `` `{root}/docs/atelier/progression.md` ``, and the five `## Pratique actuelle | ## Current practice` style rows. No `role-registry` or `ticket` group, no `# Progression IA` title row.

- [ ] **Step 7: Commit**

```bash
git add scripts/build.sh scripts/tests/build_test.sh
git commit -m "feat(build): generate the heading-pair reference into every ZIP"
```

---

## Task 4: Mirror the generator in PowerShell

**Files:**
- Modify: `scripts/build.ps1` — new functions after `Get-TemplateBlockHeadings` ends at `scripts/build.ps1:148`; one call inside `New-SkillStage` after the `memory-protocol.md` copy (currently `scripts/build.ps1:557`)
- Test: `scripts/tests/build_test.ps1`

**Interfaces:**
- Consumes: `Get-FenceMarker`, `Get-FenceRunLength`, `Test-FenceCloses`, `Get-AtxLevel` (`scripts/build.ps1:64-104`); `$ExecDocsTsv` (`scripts/build.ps1:90`); `$SharedDir`, `$RepoRoot`.
- Produces: `New-ExecHeadingPairs -Locale <fr|en> -OutPath <path>` — output byte-identical to Task 3's `generate_exec_heading_pairs` (AC21).

- [ ] **Step 1: Write the failing test**

Append to `scripts/tests/build_test.ps1`, before its final status block:

```powershell
# --- 2026-09-20-heading-pairs/AC1, AC21: the generated reference, and its
# byte-identity with the bash twin's output on this repository.
$d = New-FixtureRepo
Invoke-FixturePwsh $d '-Lang all' | Out-Null

foreach ($z in @('atelier-ventes-fr.zip', 'atelier-sales-en.zip')) {
  $names = & unzip -l (Join-Path $d "dist/$z")
  if ($names -match 'references/exec-document-headings\.md') {
    Add-Pass "AC1 $z carries references/exec-document-headings.md (ps1)"
  } else {
    Add-Failure "AC1 $z missing references/exec-document-headings.md (ps1)"
  }
}
Remove-Item -Recurse -Force $d

# AC21 — same bytes from both scripts, for each locale, on the real repo.
$shOut = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid())
$psOut = Join-Path ([System.IO.Path]::GetTempPath()) ([guid]::NewGuid())
New-Item -ItemType Directory -Force -Path $shOut, $psOut | Out-Null
Push-Location $RepoRoot
& bash scripts/build.sh --lang all *> $null
Copy-Item dist/atelier-mentor-fr.zip (Join-Path $shOut 'fr.zip')
Copy-Item dist/atelier-mentor-en.zip (Join-Path $shOut 'en.zip')
& pwsh -File scripts/build.ps1 -Lang all *> $null
Copy-Item dist/atelier-mentor-fr.zip (Join-Path $psOut 'fr.zip')
Copy-Item dist/atelier-mentor-en.zip (Join-Path $psOut 'en.zip')
Pop-Location
foreach ($loc in @('fr', 'en')) {
  $a = & unzip -p (Join-Path $shOut "$loc.zip") references/exec-document-headings.md
  $b = & unzip -p (Join-Path $psOut "$loc.zip") references/exec-document-headings.md
  if (($a -join "`n") -ceq ($b -join "`n")) {
    Add-Pass "AC21 $loc heading-pair reference is byte-identical across build scripts"
  } else {
    Add-Failure "AC21 $loc heading-pair reference differs between build.sh and build.ps1"
  }
}
Remove-Item -Recurse -Force $shOut, $psOut
```

Helper names used above are the ones already in that file: `Add-Pass`
(`scripts/tests/build_test.ps1:15`), `Add-Failure` (`:14`), `New-FixtureRepo`
(`:66`), `Invoke-FixturePwsh` (`:225`) and `$RepoRoot` (`:12`).

- [ ] **Step 2: Run it to verify it fails**

Run: `pwsh -File scripts/tests/build_test.ps1 2>&1 | Select-String -Pattern 'AC1 |AC21'`
Expected: `FAIL` on every line — `New-ExecHeadingPairs` does not exist.

- [ ] **Step 3: Implement the PowerShell twin**

Insert into `scripts/build.ps1` after `Get-TemplateBlockHeadings` closes (currently `scripts/build.ps1:148`):

```powershell
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

  if (-not $found) { return @('MISSING') }
  if (-not $closed) { return @('UNCLOSED') }
  return $rows.ToArray()
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
    if (-not (Test-Path -LiteralPath $full)) {
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
```

- [ ] **Step 4: Call it from `New-SkillStage`**

In `scripts/build.ps1`, immediately after the `memory-protocol.md` `Copy-Item` inside `New-SkillStage` (currently `scripts/build.ps1:557`), add:

```powershell
  # 2026-09-20-heading-pairs/AC1 — generated per stage, never checked in.
  New-ExecHeadingPairs -Locale $Locale `
    -OutPath (Join-Path $Stage 'references/exec-document-headings.md')
```

- [ ] **Step 5: Run both test suites to verify they pass**

Run: `pwsh -File scripts/tests/build_test.ps1 2>&1 | tail -3 && bash scripts/tests/build_test.sh 2>&1 | tail -3`
Expected: `STATUS: PASS` from both.

- [ ] **Step 6: Confirm byte-identity directly**

Run:
```bash
bash scripts/build.sh --lang all >/dev/null && unzip -p dist/atelier-mentor-fr.zip references/exec-document-headings.md > /tmp/sh-fr.md
pwsh -File scripts/build.ps1 -Lang all >/dev/null && unzip -p dist/atelier-mentor-fr.zip references/exec-document-headings.md > /tmp/ps-fr.md
cmp /tmp/sh-fr.md /tmp/ps-fr.md && echo IDENTICAL
```
Expected: `IDENTICAL`. If it differs, the cause is almost always a line ending — check that nothing used `Set-Content` or `Out-File`.

- [ ] **Step 7: Commit**

```bash
git add scripts/build.ps1 scripts/tests/build_test.ps1
git commit -m "feat(build): mirror the heading-pair generator in PowerShell"
```

---

## Task 5: Rewrite the rule in both memory protocols

**Files:**
- Modify: `skills/shared/fr/memory-protocol.md` — the `## Un document écrit dans l'autre langue` section
- Modify: `skills/shared/en/memory-protocol.md` — the `## A document written in the other language` section (`skills/shared/en/memory-protocol.md:62-118`)

**Interfaces:**
- Consumes: `references/exec-document-headings.md` as the filename to point at — the name Task 3 stages it under.
- Produces: the shipped rule text AC22–AC25 assert, and the behaviour Task 8 dispatches against.

This is the one variable the 2026-09-20 run never changed. The English direction passed and the French direction failed under two different wordings of the *rule*; only the worked example stayed same-language in both. Both examples become cross-language here.

- [ ] **Step 1: Rewrite the French paragraph**

In `skills/shared/fr/memory-protocol.md`, replace the whole `**Ses propres titres restent les siens.**` paragraph with:

```markdown
**Ses propres titres restent les siens.** Deux conditions avant de réécrire un
titre : tu sais dire quelle section de ton modèle il désigne, *et* il s'écrit
comme ton modèle l'écrit, dans une langue ou dans l'autre. Les deux
orthographes de chaque section sont dans `references/exec-document-headings.md` :
lis l'entrée du document que tu as en main avant de proposer quoi que ce
soit. Vérifie la deuxième condition exprès — c'est celle qu'on saute. Un titre
qu'elle a renommé contient quand même ce que contient la section de ton
modèle : la première condition passe, et tu vas le traduire si tu ne t'arrêtes
pas pour comparer les mots.

Ton modèle dit « Pratique actuelle ». L'anglais écrit la même section
"Current practice" — c'est la ligne que tu trouves dans
`references/exec-document-headings.md`. Son fichier, lui, dit "Where I'm at
right now". Ni l'une ni l'autre orthographe : même section, pas ton libellé,
donc on n'y touche pas. Le titre et le texte, et rien ne change de place :
un titre qu'elle a renommé, ce sont ses mots à elle, au même titre que sa
prose. Pareil pour une section à elle dont tu n'as aucun modèle. Ne pas savoir
situer une section n'est pas une raison de demander ici : on demande avant
d'écrire *dans* une section, et laisser un titre tranquille n'écrit rien.

**Ta proposition nomme les deux listes.** Elle dit les titres que tu vas
réécrire *et* les titres que tu laisses — les deux, à chaque fois, pas
seulement quand tu as remarqué une exception. Écrire la proposition t'oblige
alors à faire la comparaison, et une comparaison sautée se voit dans la
proposition, pas seulement dans le fichier. Une réécriture acceptée qui laisse
un titre debout n'a ainsi jamais l'air d'avoir échoué à moitié.

**Un document sans modèle.** Si tu n'as aucun modèle pour ce document, tous
ses titres restent tels quels. Il n'y a pas de « comme ton modèle l'écrit » à
vérifier, et laisser un titre tranquille n'écrit rien.
```

- [ ] **Step 2: Rewrite the English paragraph**

In `skills/shared/en/memory-protocol.md`, replace the whole `**Their own headings stay theirs.**` paragraph with:

```markdown
**Their own headings stay theirs.** Two things have to be true before you
rewrite a heading: you could say which section of your own template it is,
*and* it is spelled the way your template spells it, in one language or the
other. Both spellings of every section are in
`references/exec-document-headings.md` — read the entry for the document you
are holding before you offer anything. Check the second one on purpose; it is
the one that is easy to skip. A heading they renamed still holds what your
template's section holds, so the first test passes and you will translate it
unless you stop and compare the words.

Your template says "Current practice". French spells the same section «
Pratique actuelle » — that is the line you find in
`references/exec-document-headings.md`. Their file says « Où j'en suis
vraiment ». Neither spelling: same section, not your wording, so it stays.
Heading and text both, and nothing changes place — a heading they renamed is
words they chose, just like their prose. So is a section of their own you have
no template for at all. Not being able to place a section is no reason to ask
here: you ask before writing *into* a section, and leaving a heading alone
writes nothing.

**Your offer names both lists.** It states the headings you will rewrite *and*
the headings you will leave — both, every time, not only when you happened to
notice an exception. Writing the offer then forces the comparison, and a
comparison you skipped shows up in the offer rather than only in the file. An
accepted rewrite that leaves a heading standing never reads as half-finished.

**A document with no template.** Where you have no template for the document
at all, every one of its headings stays as written. There is no "the way your
template spells it" to test, and leaving a heading alone writes nothing.
```

- [ ] **Step 3: Verify the assertions AC22–AC25 make**

Run:
```bash
for l in fr en; do
  f="skills/shared/$l/memory-protocol.md"
  grep -qF 'references/exec-document-headings.md' "$f" && echo "ok AC22 $l pointer" || echo "FAIL AC22 $l"
done
grep -qF 'Current practice' skills/shared/fr/memory-protocol.md && echo "ok AC23 fr cross-language example" || echo "FAIL AC23 fr"
grep -qF 'Pratique actuelle' skills/shared/en/memory-protocol.md && echo "ok AC23 en cross-language example" || echo "FAIL AC23 en"
grep -qF 'les deux listes' skills/shared/fr/memory-protocol.md && echo "ok AC24 fr both-lists" || echo "FAIL AC24 fr"
grep -qF 'names both lists' skills/shared/en/memory-protocol.md && echo "ok AC24 en both-lists" || echo "FAIL AC24 en"
grep -qF 'Un document sans modèle' skills/shared/fr/memory-protocol.md && echo "ok AC25 fr no-template" || echo "FAIL AC25 fr"
grep -qF 'A document with no template' skills/shared/en/memory-protocol.md && echo "ok AC25 en no-template" || echo "FAIL AC25 en"
```
Expected: eight `ok` lines, no `FAIL`.

- [ ] **Step 4: Run the mechanical checks**

Run: `bash scripts/build.sh --check 2>&1 | tail -3`
Expected: `STATUS: PASS (mechanical checks)`. `check_staged_references()` compares the staged `memory-protocol.md` byte-for-byte against the source, so a stray edit in the stage would surface here.

- [ ] **Step 5: Commit**

```bash
git add skills/shared/fr/memory-protocol.md skills/shared/en/memory-protocol.md
git commit -m "fix(shared): point the rewrite rule at both locales' heading spellings"
```

---

## Task 6: Repository documentation

**Files:**
- Modify: `docs/adr/0016-exec-facing-document-section-headings.md` — status line (`:3`), Decision §4 (`:53-69`), Consequences (`:115`)
- Modify: `docs/AUTHORING.md` — the `## Exec-facing document headings` section
- Modify: `docs/superpowers/specs/2026-09-19-exec-document-headings-design.md:400` — the AC32/AC33 status note

**Interfaces:**
- Consumes: nothing from earlier tasks. Can be done in parallel with Tasks 1–5.
- Produces: the state AC32–AC34 assert. `scripts/tests/authoring_test.sh` greps `docs/AUTHORING.md` for the literal `## Exec-facing document headings` — do not rename that heading.

- [ ] **Step 1: Amend ADR-0016's status line**

Replace `docs/adr/0016-exec-facing-document-section-headings.md:3`:

```markdown
**Status:** Accepted — 2026-09-19
```

with:

```markdown
**Status:** Accepted — 2026-09-19; §4 amended 2026-09-20
```

- [ ] **Step 2: Amend Decision §4**

In the same file, append two paragraphs to the end of Decision §4 — after the sentence ending `does not read as a failure.`:

```markdown
   *Amended 2026-09-20.* The "in one locale or the other" test could not be
   evaluated: a shipped ZIP carries one locale's templates, so a reader had no
   second spelling to compare against. Every ZIP now carries a generated
   `references/exec-document-headings.md` giving both locales' spelling of
   every section of every exec-facing document with a template. The reader
   consults the entry for the document in hand before offering, and the offer
   names both the headings it will rewrite and the headings it will leave —
   both lists, every time, so a skipped comparison is visible in the offer
   rather than only in the file.

   *Also amended 2026-09-20.* Where the reader has no template for a document
   at all, every heading stays as written. There is no "the way its template
   spells it" to test, and leaving a heading alone is not a write. Level-1
   titles are outside the generated reference — most carry a placeholder — so
   a document's title is likewise left alone.
```

- [ ] **Step 3: Add the Consequences entry**

In the same file's `## Consequences` list, add:

```markdown
- Every ZIP carries a generated `references/exec-document-headings.md`, built
  from `skills/exec-documents.tsv` at stage time and never checked in. A new
  exec-facing document therefore needs only its registry row; the pairs follow.
  The build fails — not only `--check` — when the registry, a named reference
  file, or a template block cannot produce that table.
```

- [ ] **Step 4: Update `docs/AUTHORING.md`**

In `docs/AUTHORING.md`, replace the final paragraph of `## Exec-facing document headings` (the one beginning `**Every new exec-facing document gets a row`) with:

```markdown
**Every new exec-facing document gets a row in `skills/exec-documents.tsv`**:
doc-id, canonical path, then the reference file and 1-based ` ```markdown `
block index that hold its template in each locale. `bash scripts/build.sh
--check` reads that registry and fails when the two locales' templates stop
carrying the same sequence of heading levels. A document whose structure is
described in prose rather than a template carries `-` in all four template
columns — in all four, never some.

The build also **generates** `references/exec-document-headings.md` from that
same registry and stages it into every ZIP, giving both locales' spelling of
every section. That is what lets a reader evaluate ADR-0016's "spelled the way
your template spells it, in one locale or the other" test at all. A new
exec-facing document therefore needs only its registry row — nothing is
hand-written per document, and nothing can rot on one side. The framing prose
around the table is a shared text, `skills/shared/<locale>/exec-document-headings.md`;
the table itself is appended at stage time and never checked in.
```

- [ ] **Step 5: Point the prior spec's status note here**

In `docs/superpowers/specs/2026-09-19-exec-document-headings-design.md`, find the note beginning `**Status of AC32 and AC33 as of 2026-09-20.**` (currently line 400) and append to it:

```markdown
Both halves are resolved by
[`2026-09-20-exec-heading-pairs-design.md`](2026-09-20-exec-heading-pairs-design.md):
the structural half by generating `references/exec-document-headings.md` into
every ZIP, the behavioural half by rewriting the worked example to the
cross-language case and requiring the offer to name both lists. The AC numbers
in that spec are its own — cite them as `2026-09-20-heading-pairs/ACn`.
```

- [ ] **Step 6: Run the docs test**

Run: `bash scripts/tests/authoring_test.sh 2>&1 | tail -3`
Expected: `STATUS: PASS`

- [ ] **Step 7: Commit**

```bash
git add docs/adr/0016-exec-facing-document-section-headings.md \
        docs/AUTHORING.md \
        docs/superpowers/specs/2026-09-19-exec-document-headings-design.md
git commit -m "docs: record the generated heading-pair reference in ADR-0016 and AUTHORING"
```

---

## Task 7: Scenario boxes for the new behaviour

**Files:**
- Modify: `tests/_cross-skill/changement-de-langue.md` — the `## Expected behaviors` list (`:35-59`)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: the boxes AC37 asserts and Task 8 ticks.

- [ ] **Step 1: Replace the two unticked boxes**

In `tests/_cross-skill/changement-de-langue.md`, replace these two lines (currently `:50-53`):

```markdown
- [ ] A template section the executive renamed survives an accepted rewrite the
  same way — heading and body both
- [ ] The rewrite offer names the exception, on a document that carries a
  heading the executive wrote or renamed
```

with:

```markdown
- [ ] A template section the executive renamed survives an accepted rewrite the
  same way — heading and body both — with `references/exec-document-headings.md`
  present in the ZIP and the renamed heading matching neither locale's spelling
  of that section
- [ ] The rewrite offer names both lists: the headings it will rewrite and the
  headings it will leave, on every offer, not only where it noticed an
  exception
- [ ] The document's level-1 title survives an accepted rewrite unchanged, on a
  document that does have a template
```

- [ ] **Step 2: Verify the file still parses as a scenario**

Run: `bash scripts/build.sh --check 2>&1 | tail -3`
Expected: `STATUS: PASS (mechanical checks)` — `check_scenarios()` counts scenario files per skill; `tests/_cross-skill/` is not counted there, so this confirms nothing else broke.

- [ ] **Step 3: Commit**

```bash
git add tests/_cross-skill/changement-de-langue.md
git commit -m "test(shared): expect both-lists offers and surviving renamed headings"
```

---

## Task 8: Dispatch the locale-switch scenario in both directions

**Files:**
- Create: `tests/_cross-skill/runs/changement-de-langue/2026-09-20-verification-heading-pairs-en-reads-fr.md`
- Create: `tests/_cross-skill/runs/changement-de-langue/2026-09-20-verification-heading-pairs-fr-reads-en.md`
- Modify: `tests/_cross-skill/changement-de-langue.md` — tick the three boxes from Task 7, add a `## Verification notes` section

**Interfaces:**
- Consumes: the ZIPs built by Task 3 and 4; the rule text from Task 5; the boxes from Task 7.
- Produces: the verdicts AC27–AC31 and AC36 require.

**Attempt budget: two dispatches per direction (AC30).** This is written down in advance so it is a decision already made rather than one taken under pressure mid-run. Do not re-roll past it, and do not weaken a criterion to match what was observed.

- [ ] **Step 1: Build the ZIPs and seed the documents**

Run:
```bash
bash scripts/build.sh --lang all
```

Seed two documents under a scratch directory, each carrying:
1. every section of the `progression` template in its own locale's spelling, **except**
2. one template section renamed to a heading matching **neither** locale's spelling — this is what AC27 requires; a rename onto the counterpart spelling is a template spelling and the rule correctly rewrites it;
3. one section the executive added themselves, which appears in no template;
4. the level-1 title, left as the template writes it.

For the English-install-reads-French direction, seed the French document:

```markdown
# Progression IA — Solutions FVR

## Où j'en suis vraiment

On utilise Claude pour les comptes rendus depuis mars.

## Pratiques adoptées

- Comptes rendus de réunion — 2026-03-12

## Difficultés exprimées

Le monde des relances commerciales reste manuel.

## Prochaine étape convenue

Essayer atelier-ventes sur le pipeline de mai.

## Modules du tutoriel couverts

- Module 1 — 2026-03-12

## Ce que je veux tester ensuite

Les maquettes. Pas encore commencé.
```

`## Où j'en suis vraiment` is the renamed `## Pratique actuelle` — it matches neither « Pratique actuelle » nor "Current practice". `## Ce que je veux tester ensuite` is the executive's own added section.

For the French-install-reads-English direction, seed the English document:

```markdown
# AI progression — Solutions FVR

## Where I'm at right now

We have been using Claude for meeting notes since March.

## Practices adopted

- Meeting minutes — 2026-03-12

## Stated struggles

Sales follow-ups are still entirely manual.

## Agreed next step

Try atelier-sales on the May pipeline.

## Tutorial modules covered

- Module 1 — 2026-03-12

## What I want to try next

Mockups. Not started yet.
```

`## Where I'm at right now` is the renamed `## Current practice` — it matches
neither "Current practice" nor « Pratique actuelle ». `## What I want to try
next` is the executive's own added section. This is the direction that failed
3 of 3 on 2026-09-20.

- [ ] **Step 2: Dispatch the English direction**

Dispatch a fresh agent with the `atelier-mentor-en` ZIP contents and the French seeded document. Follow the transcript conventions in `tests/README.md` under "Recording a run". Capture, verbatim:
- the rewrite offer's full text;
- whether the executive's answer was accept or decline;
- the on-disk file after the accepted rewrite.

- [ ] **Step 3: Verdict the English direction from evidence, not self-report**

Run `diff` against the seed:
```bash
diff -u <seed> <post-rewrite-file>
```

- **AC27** — the `## Où j'en suis vraiment` heading and its body are absent from the diff.
- **AC29** — `## Ce que je veux tester ensuite` and its body are absent from the diff, and no hunk reorders sections.
- **AC36** — `# Progression IA — Solutions FVR` is absent from the diff.
- **AC28** — read the **offer text in the transcript**, not the diff: it names both the headings it will rewrite and the headings it will leave. Offer wording never appears in a diff, which is why AC30 splits the evidence.

A direction passes only when **one single dispatch** satisfies both AC27 and AC28 (AC31). Satisfying them across two separate attempts does not count.

- [ ] **Step 4: Commit the English transcript before ticking anything**

```bash
git add tests/_cross-skill/runs/changement-de-langue/2026-09-20-verification-heading-pairs-en-reads-fr.md
git commit -m "test(shared): record the EN-reads-FR heading-pair verification run"
```

- [ ] **Step 5: Dispatch and verdict the French direction**

Repeat Steps 2–4 with the `atelier-mentor-fr` ZIP and the English seeded document. This is the direction that failed 3 of 3 on 2026-09-20; it is the one the rewritten worked example exists for.

```bash
git add tests/_cross-skill/runs/changement-de-langue/2026-09-20-verification-heading-pairs-fr-reads-en.md
git commit -m "test(shared): record the FR-reads-EN heading-pair verification run"
```

- [ ] **Step 6: Tick the boxes, or record why they stay unticked**

If both directions passed, tick the three boxes added in Task 7 and add a `## Verification notes — 2026-09-20 heading pairs` section to `tests/_cross-skill/changement-de-langue.md` naming both transcripts and what each direction did.

If the budget of two dispatches per direction is spent with AC27 or AC28 still unmet, then per AC31:
1. leave the box unticked and write its stated reason into the verification-notes section;
2. file a successor issue with all four body sections — Context, Required, Integration Points, Priority — recording what the pair table and the rewritten example did and did not change;
3. change no acceptance criterion in this spec or in `2026-09-19-exec-document-headings-design.md` to match the observed behaviour.

File it with:
```bash
gh issue create --title "Locale-switch rewrite still translates a renamed heading in <direction>" \
  --body-file <path-to-body>
```
and add `- #<N> — <title>` to the spec's `## Deferred Items` section.

- [ ] **Step 7: Commit**

```bash
git add tests/_cross-skill/changement-de-langue.md
git commit -m "test(shared): record the 2026-09-20 heading-pair verification verdicts"
```

---

## Task 9: Post-implementation check

**Files:** none — this task reads the diff.

- [ ] **Step 1: Confirm every config-impact file was actually touched**

Run:
```bash
git diff --name-only dev...HEAD | sort
```

Expected, exactly these seventeen paths:
```
docs/AUTHORING.md
docs/adr/0016-exec-facing-document-section-headings.md
docs/superpowers/plans/2026-09-20-exec-heading-pairs.md
docs/superpowers/specs/2026-09-19-exec-document-headings-design.md
docs/superpowers/specs/2026-09-20-exec-heading-pairs-design.md
scripts/build.ps1
scripts/build.sh
scripts/tests/build_test.ps1
scripts/tests/build_test.sh
scripts/tests/shared_test.sh
skills/shared/en/exec-document-headings.md
skills/shared/en/memory-protocol.md
skills/shared/fr/exec-document-headings.md
skills/shared/fr/memory-protocol.md
tests/_cross-skill/changement-de-langue.md
tests/_cross-skill/runs/changement-de-langue/2026-09-20-verification-heading-pairs-en-reads-fr.md
tests/_cross-skill/runs/changement-de-langue/2026-09-20-verification-heading-pairs-fr-reads-en.md
```

- [ ] **Step 2: Confirm nothing release-please-owned was edited**

Run:
```bash
git diff dev...HEAD -- version.txt README.md release-please-config.json .release-please-manifest.json '**/SKILL.md' | head
```
Expected: no output. If anything appears, revert it — release-please owns those lines.

- [ ] **Step 3: Confirm the generated file is not checked in**

Run: `git ls-files | grep 'references/exec-document-headings.md' || echo "not tracked — correct"`
Expected: `not tracked — correct`. The file is generated into a temp stage, never into the working tree. The two `skills/shared/<locale>/exec-document-headings.md` sources are tracked; the staged `references/` copy is not.

- [ ] **Step 4: Verify the issues the spec's Deferred Items reference**

Run:
```bash
for n in 42 43; do
  echo "--- #$n"
  gh issue view "$n" --json state,title --jq '.state + "  " + .title'
done
```
Expected: both exist. #42 and #43 are **closed by** this work, not deferred —
close them with a reference to the merge commit once the branch lands. The
only genuinely deferred item is the conditional successor issue from Task 8
Step 6; if it was filed, confirm its body carries all four sections:
```bash
gh issue view <N> --json body --jq .body | grep -cE '^#+ *(Context|Required|Integration Points|Priority)'
```
Expected: `4`.

- [ ] **Step 5: Walk the acceptance criteria**

Read `docs/superpowers/specs/2026-09-20-exec-heading-pairs-design.md`'s `## Acceptance Criteria` and confirm each of AC1–AC37 has a test or a verified artifact behind it. Read the diff, not this plan's checkboxes.

---

## Task 10: Final build

- [ ] **Step 1: Run the full gate**

Run:
```bash
bash scripts/build.sh --check \
  && bash scripts/tests/shared_test.sh \
  && bash scripts/tests/authoring_test.sh \
  && bash scripts/tests/build_test.sh \
  && pwsh -File scripts/tests/build_test.ps1 \
  && pwsh -File scripts/build.ps1 -Check \
  && bash scripts/build.sh --lang all
```
Expected: `STATUS: PASS` from each check script, and fourteen `built …zip` lines from the final build. Fix anything that fails and re-run the whole chain — AC35 requires all of them green.

- [ ] **Step 2: Confirm the ZIP roster did not change**

Run: `ls dist/*.zip | wc -l`
Expected: `14`.

- [ ] **Step 3: Commit anything the fixes touched**

```bash
git status --short
```
If clean, nothing to commit. Otherwise commit the fixes with a `fix(build):` or `fix(shared):` message naming what broke.

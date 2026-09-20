# Exec-facing document section headings Implementation Plan

> **Superseded in part, 2026-09-20.** This plan was executed on branch
> `locale-exec-headings`; its checkboxes were never ticked and do not reflect
> what shipped. Afterwards the rewrite rule gained a carve-out this plan does
> not describe: a heading is rewritten only when the reader placed that
> section as one of its own **and** it is spelled the way its template spells
> it, so a section the executive added and a template section they renamed
> both survive untouched. The quoted rule text below — notably the ADR
> *Decision §4* block and the `memory-protocol.md` block — predates that
> change and is kept as the record of what was planned. For the current rule
> read `docs/adr/0016-exec-facing-document-section-headings.md` and
> `skills/shared/{fr,en}/memory-protocol.md`.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Let a skill read an exec-facing document whose section headings are in
the other locale's language — identifying sections by what they hold, disclosing
the mismatch once, and offering a heading-only rewrite — and add a build check
that keeps the two locales' templates structurally identical.

**Architecture:** Three independent layers. (1) A general rule in the shared
`memory-protocol.md`, which the build already copies into every ZIP's
`references/` — this costs no `SKILL.md` words. (2) Local wording at each call
site that names a section by what it records instead of by a literal title. (3)
A registry, `skills/exec-documents.tsv`, plus a `--check` rule that proves each
document's French and English templates carry the same sequence of heading
levels — the property reading-by-meaning depends on, currently a coincidence.

**Tech Stack:** Bash + awk (`scripts/build.sh`), PowerShell 7 (`scripts/build.ps1`),
Markdown skill sources, tab-separated registries.

**Spec:** `docs/superpowers/specs/2026-09-19-exec-document-headings-design.md`

## Global Constraints

Copied verbatim from the spec. Every task's requirements implicitly include
this section.

- **No `SKILL.md` file changes.** The rule lives in `references/memory-protocol.md`.
  Every skill body's `wc -w` is identical before and after the branch (AC13).
- **No exec-facing document path changes.** Apart from the new
  `skills/exec-documents.tsv`, whose rows repeat paths that already exist, the
  branch adds, removes or respells no `{root}/docs/...` or `{racine}/docs/...`
  token in `skills/` (AC4).
- **Never hand-edit** `version.txt`, a `SKILL.md` version line, or the two
  annotated `README.md` lines — release-please owns them.
- **Every French file is authored in French, not translated from the English
  one.** The two locales are written, not mirrored.
- **Branch from `dev`, land on `dev`** (`docs/adr/0010-dev-default-main-release-branch.md`).
- **Conventional Commits.** Scopes this work uses: `shared`, `mentor`,
  `boussole`, `atelier`, `build`, `docs`.
- **Cite acceptance criteria as `2026-09-19-headings/ACn`** in code comments.
  Two specs carry the date 2026-09-19 and both number from AC1, so a bare
  `2026-09-19/ACn` keeps meaning the stale-dated-claims spec.
- **LF line endings.** `.gitattributes` pins `* text=auto eol=lf`.
- **The em dash is —, U+2014,** with one space either side. French keeps a
  space before `:`, `?`, `!`, `»` and after `«`.

## Review Focus

Five registry inputs the spec implies but whose handling no acceptance
criterion pins down. Each line's test is added to the task that owns the code.

1. **A row with `-` in some but not all four template columns.** AC15 says a
   prose-structured document carries `-` in all four; a half-filled row would
   otherwise be read as a real row naming a file called `-`. → Task 4.
2. **A row with the wrong number of columns.** Five or seven tab-separated
   fields must fail by name, not silently shift every column one place. → Task 4.
3. **A registry checked out with CRLF line endings.** A trailing `\r` glues
   itself to the last column, turning block index `1` into `1\r`. Both existing
   scanners strip it; this one must too. → Task 4.
4. **A row naming the same reference file for both locales.** Parity passes
   trivially, so a copy-paste error would hide a real divergence forever. → Task 4.
5. **A template block whose closing fence is missing.** The reader would run to
   EOF and compare a truncated heading list against a complete one. → Task 5.

---

## File Structure

**Created:**
- `docs/adr/0016-exec-facing-document-section-headings.md` — the decision: headings
  localized, the read side carries the compatibility.
- `skills/exec-documents.tsv` — one row per exec-facing document, six columns.
- `tests/_cross-skill/changement-de-langue.md` — the locale-switch scenario.
- `tests/_cross-skill/runs/changement-de-langue/<date>-verification.md` — two
  transcripts, one per dispatch.

**Modified:**
- `docs/adr/0007-exec-facing-document-paths.md` — pointer to ADR-0016 and the
  restated invariant.
- `docs/AUTHORING.md` — `## Exec-facing document headings`.
- `CLAUDE.md` — one sentence on the date-plus-slug citation form.
- `skills/shared/{fr,en}/memory-protocol.md` — the new rule section.
- `skills/atelier-mentor/{fr,en}/references/tutorial.md`, `.../progression.md` —
  sections named by what they record.
- `skills/atelier-boussole/{fr,en}/references/detour-recherche.md`, `detour-research.md` — same.
- `skills/atelier/{fr,en}/references/onboarding.md`, `relais.md` — a document
  found in the other language is read and used, never re-created alongside.
- `scripts/build.sh` — registry reader + parity check inside `--check`.
- `scripts/build.ps1` — the same, as the `-Check` twin.
- `scripts/tests/build_test.sh`, `scripts/tests/build_test.ps1` — fixture
  registry + mutation cases.
- `scripts/tests/authoring_test.sh` — one `require_heading`.

**Deliberately unchanged:** every `SKILL.md`; every template block (all ten
pairs already have identical heading-level sequences — verified, see Task 5
Step 1); `scripts/tests/shared_test.sh`; `.github/workflows/ci.yml`, which
already runs both check entry points; the dated-claims awk in `scripts/build.sh`,
whose fence helpers are copied rather than refactored so a passing check cannot
regress.

---

### Task 1: The record — ADR-0016, ADR-0007, AUTHORING.md, CLAUDE.md

**Files:**
- Create: `docs/adr/0016-exec-facing-document-section-headings.md`
- Modify: `docs/adr/0007-exec-facing-document-paths.md`
- Modify: `docs/AUTHORING.md` (append a section after `## Dated capability claims`)
- Modify: `CLAUDE.md:44-46`
- Test: `scripts/tests/authoring_test.sh`

**Interfaces:**
- Consumes: nothing.
- Produces: `docs/adr/0016-exec-facing-document-section-headings.md`, cited by
  later tasks' commit bodies and by the AUTHORING section.

- [ ] **Step 1: Write the failing test**

Append one line to `scripts/tests/authoring_test.sh`, directly after the
`require_heading "## Dated capability claims"` line:

```bash
require_heading "## Exec-facing document headings"
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash scripts/tests/authoring_test.sh`
Expected: `FAIL: AUTHORING.md missing section '## Exec-facing document headings'`, `STATUS: FAIL (1)`, exit 1.

- [ ] **Step 3: Write ADR-0016**

Create `docs/adr/0016-exec-facing-document-section-headings.md`:

```markdown
# 0016 — Exec-facing document section headings stay localized

**Status:** Accepted — 2026-09-19

## Context

ADR-0007 fixes exec-facing document **paths** to one spelling in both
locales, so a locale switch never orphans a document. It says nothing about
the **section headings inside** those documents, and they diverge today:
`{root}/docs/atelier/progression.md` carries « Pratique actuelle », «
Pratiques adoptées », « Difficultés exprimées », « Prochaine étape convenue
», « Modules du tutoriel couverts » on a French install, and "Current
practice", "Practices adopted", "Stated struggles", "Agreed next step",
"Tutorial modules covered" on an English one.

The file is found after a locale switch. Its contents are not read back. An
executive who covered five tutorial modules in French and switches to English
is offered all seven again, as if nothing had happened —
`references/tutorial.md` tells the reader to add lines under "Tutorial
modules covered", and a French document has no such heading.

The surface is every exec-facing document, not only `progression.md`: the
Company Profile, the role registry, the relay, the compass map, the decision
brief, the decision memo, the research note, the ticket, the decision log,
the role memories, the voice guide, the minutes, the pipeline review, the
mockups.

Both locales' templates are already section-for-section parallel — same
count, same order, everywhere. Nothing enforces that. It is the property that
makes reading by meaning reliable, and it is currently a coincidence.

## Decision

Section headings in exec-facing documents are written in the locale of the
skill that created the document. Paths are canonical because the executive
rarely reads them; headings are the document's visible text, and an English
reader's own Company Profile must not greet them with « Rôle », « Marché », «
Ton de voix ».

What changes is how a document is read:

1. **Read in full, identify by content.** A section is identified by what it
   holds, never by matching its title. A section is never reported missing,
   and a document never treated as empty, because its headings are in the
   other language.
2. **No positional fallback.** If a section genuinely cannot be identified,
   the reader asks the executive. These are the executive's own documents and
   they edit them; a silent write into a section that happens to sit in the
   expected position is worse than one question.
3. **Disclose once.** On a language mismatch, say so plainly, one line, the
   first time the document is read in the session: the record was written in
   the other language, it has been read, and it still counts.
4. **Offer a heading-only rewrite.** Proposed as an ordinary memory write
   under `references/memory-protocol.md` — accepted, declined, or unanswered,
   and a decline is dropped rather than re-proposed. It rewrites heading lines
   only, on the one document just read. The executive's own prose is never
   translated: it is their record, and a paraphrase of why they adopted a
   practice is a real loss. They can always ask for a translation.
5. **Cowork only.** The offer is a write, and writes happen only where the
   files can be read and rewritten. In a Desktop chat session the disclosure
   still happens; the offer does not, and the session says plainly that
   nothing was written.
6. **New content follows the executive's language.** Lines appended to a
   document whose headings are in the other language are written in the
   language the executive is speaking, not in the document's heading language.
   A bilingual document is a correct intermediate state, not a defect.

The rule lives in `skills/shared/<locale>/memory-protocol.md`, which the build
copies into every ZIP's `references/` and which every skill is told to read
before proposing a write.

`skills/exec-documents.tsv` records one row per exec-facing document and the
template block that defines it in each locale. `bash scripts/build.sh --check`
and `./scripts/build.ps1 -Check` prove the two blocks carry an identical
sequence of heading levels. No script can compare a French heading to an
English one for meaning; it can prove the two templates are structurally the
same document, which is what reading by meaning depends on.

### What this says about ADR-0007

ADR-0007 states the path invariant as "one canonical **French** spelling in
both locales." That does not describe the repository. `company-profile.md`,
`decisions.md`, `roles.md`, `map.md`, `research/`, `tickets/` and `maquettes/`
are English or locale-neutral spellings used unchanged in both locales; only
the concepts with French names — `relais/`, `competences/`, `ventes/`,
`reunions/`, `guide-de-voix.md`, `memory/<nom-canonique>.md` — are French.

The property every path actually holds is **one spelling in both locales**,
French being the tiebreaker where the concept has a French name. No path
moves: every existing path already satisfies the restated rule. ADR-0007
stays Accepted and gains a pointer here — its decision stands, only its
wording is corrected.

## Alternatives considered

**Canonical French headings in both locales.** Rejected: it puts French in an
English executive's own document, which is the visible text they read.

**Hidden stable anchors**, e.g. `## Current practice <!-- atelier:pratique-actuelle -->`.
Rejected: they buy exactness the reader does not need, add build syntax to a
file the skill ships to the executive's Claude, and create a migration for
every document already on disk.

## Consequences

- A locale switch costs one disclosure line and an optional offer, not a lost
  record.
- Both locales' templates must stay structurally parallel; `--check` now fails
  when they drift, naming the doc-id and both files.
- Every new exec-facing document needs a row in `skills/exec-documents.tsv`.
  Nothing detects a document that is missing from it — filed as #39.
- A document can hold French headings and English content at once. That is a
  correct intermediate state and no check rejects it.
```

- [ ] **Step 4: Amend ADR-0007**

In `docs/adr/0007-exec-facing-document-paths.md`, replace the first paragraph
of `## Decision` — the one beginning "Every exec-facing document path a role
skill writes" — with:

```markdown
Every exec-facing document path a role skill writes — folder **and**
filename — uses **one spelling in both locales**, French being the tiebreaker
where the concept has a French name: the same reasoning already applied to
the memory key and to `relais/`/`competences/`. A locale switch must never
orphan a document the executive already has.

> **Wording corrected by [ADR 0016](0016-exec-facing-document-section-headings.md).**
> This ADR originally said "one canonical **French** spelling in both
> locales." The repository's own paths are not all French —
> `company-profile.md`, `decisions.md`, `roles.md`, `map.md`, `research/`,
> `tickets/` and `maquettes/` are English or locale-neutral spellings used
> unchanged in both locales. The property they all hold is one spelling in
> both locales. The decision stands as made; no path moves. ADR-0016 also
> settles what the *section headings inside* these documents do, which this
> ADR does not address.
```

Leave the `**Status:** Accepted — 2026-07-21` line, the Context, the instances
list and the Consequences exactly as they are.

- [ ] **Step 5: Write the AUTHORING.md section**

Append to `docs/AUTHORING.md`, after the `## Dated capability claims` section:

```markdown
## Exec-facing document headings

Paths are canonical; **section headings are not**. A document the skill writes
for the executive carries the headings of the locale that created it — «
Pratique actuelle » on a French install, "Current practice" on an English one.
Both are correct, and a locale switch leaves the executive holding one of
them. See [ADR 0016](adr/0016-exec-facing-document-section-headings.md).

That puts the burden on the **read** side, and every instruction you write has
to carry it:

- Name a section by **what it records**, never by the string to match. "the
  section listing the completed tutorial modules" survives a locale switch;
  "the 'Tutorial modules covered' section" does not. Quoting this locale's
  heading as an *example* is fine — as the thing to grep for, it is a bug.
- Never tell a reader a section is missing, or a document empty, on the
  strength of a title it did not recognize.
- The general rule — disclose once, offer a heading-only rewrite, Cowork only,
  new lines in the executive's language — lives in
  `skills/shared/<locale>/memory-protocol.md`. Don't restate it in a skill
  body; the build copies it into every ZIP.

**Every new exec-facing document gets a row in `skills/exec-documents.tsv`**:
doc-id, canonical path, then the reference file and 1-based ` ```markdown `
block index that hold its template in each locale. `bash scripts/build.sh
--check` reads that registry and fails when the two locales' templates stop
carrying the same sequence of heading levels. A document whose structure is
described in prose rather than a template carries `-` in all four template
columns — in all four, never some.
```

- [ ] **Step 6: Extend the CLAUDE.md citation convention**

In `CLAUDE.md`, replace the three-line AC-citation bullet (lines 44-46) with:

```markdown
- A comment citing an acceptance criterion names its spec: `2026-09-19/AC3`.
  Six specs each number from `AC1` and five define an `AC15`, so a bare
  `ACn` is ambiguous. Where two specs share a date, the slug disambiguates:
  `2026-09-19-headings/AC3`. Existing bare citations stay as they are.
```

- [ ] **Step 7: Run the test to verify it passes**

Run: `bash scripts/tests/authoring_test.sh`
Expected: `ok: ## Exec-facing document headings`, `STATUS: PASS`, exit 0.

- [ ] **Step 8: Verify the index stayed an index**

Run: `wc -l CLAUDE.md`
Expected: well under 300 lines. The design stays in the spec and in ADR-0016;
`CLAUDE.md` gained one sentence.

- [ ] **Step 9: Commit**

```bash
git add docs/adr/0016-exec-facing-document-section-headings.md \
        docs/adr/0007-exec-facing-document-paths.md \
        docs/AUTHORING.md CLAUDE.md scripts/tests/authoring_test.sh
git commit -m "docs: record localized exec-document headings as ADR-0016

Headings stay in the locale that wrote the document; the read side carries
the compatibility. Corrects ADR-0007's 'canonical French spelling' wording to
the invariant the repository actually holds — one spelling in both locales.

2026-09-19-headings/AC1, AC2, AC3, AC31"
```

---

### Task 2: The shared rule text

**Files:**
- Modify: `skills/shared/en/memory-protocol.md`
- Modify: `skills/shared/fr/memory-protocol.md`
- Test: `scripts/tests/shared_test.sh` (unchanged — run as a regression gate)

The closing paragraph of each section is what AC28 and AC29 rest on: a
document you created yourself, and one whose headings are already in your own
language, draw neither a disclosure nor an offer.

**Interfaces:**
- Consumes: ADR-0016 from Task 1, as the decision this text states.
- Produces: the headings `## A document written in the other language` and
  `## Un document écrit dans l'autre langue`, which Task 3's call sites point
  at implicitly and Task 7's scenario exercises.

- [ ] **Step 1: Write the failing test**

There is no content check on the shared texts — `shared_test.sh` asserts they
are present and non-empty, and the spec keeps it that way. The failing test is
the ZIP assertion from AC10, run before the edit. Save it as a shell function
you will re-run in Step 5:

```bash
bash scripts/build.sh --lang all >/dev/null 2>&1
unzip -p dist/atelier-mentor-fr.zip references/memory-protocol.md \
  | grep -qF "## Un document écrit dans l'autre langue" \
  && echo "FR ZIP carries the section" || echo "FR ZIP MISSING the section"
unzip -p dist/atelier-mentor-en.zip references/memory-protocol.md \
  | grep -qF "## A document written in the other language" \
  && echo "EN ZIP carries the section" || echo "EN ZIP MISSING the section"
```

- [ ] **Step 2: Run it to verify it fails**

Expected: `FR ZIP MISSING the section` and `EN ZIP MISSING the section`.

- [ ] **Step 3: Write the English section**

Insert into `skills/shared/en/memory-protocol.md`, **between** the `## When to
write` section and `## Scope: Cowork-only writes`:

```markdown
## A document written in the other language

The executive's own documents keep the section headings of the locale that
created them. A French install writes « Pratique actuelle »; an English one
writes "Current practice". Both are correct, and either can turn up in front
of you.

**Read the whole document, and find a section by what it holds, not by its
title.** "Current practice" is whatever line says where the executive stands
today, whatever it is called. Never report a section missing, and never treat
a document as empty, because the headings are in the other language.

**No guessing by position.** If you genuinely cannot tell which section is
which, ask. These are the executive's own files and they edit them freely; a
silent write into whatever sat in the expected place is worse than one
question.

**Say so once.** The first time you read such a document in a session, one
line: the record was written in the other language, you have read it, and it
still counts. Not again afterwards.

**Offer to rewrite the headings — nothing else.** Propose it like any other
write above: heading lines only, on the one document you just read, never a
sweep of everything on disk. The executive's own prose is never translated —
it is their record, and a paraphrase of why they adopted a practice is a real
loss. Declined, it is dropped, not proposed again. They can always ask for a
translation.

**Cowork only.** The rewrite is a write, so it happens only where the file can
be read and rewritten. In a Desktop chat the disclosure still happens, the
offer does not, and you say plainly that nothing was written.

**New lines follow the executive.** Anything you append is written in the
language the executive is speaking, not the document's heading language. A
document with French headings and an English line beneath them is a correct
intermediate state, not a defect.

When the headings are already in your own language, none of this applies: no
disclosure, no offer. A document you create yourself is created in your own
language, the same way — there is nothing to disclose about a file you just
made.
```

- [ ] **Step 4: Write the French section**

Insert into `skills/shared/fr/memory-protocol.md`, between `## Quand écrire`
and `## Portée : écritures en Cowork seulement`. Authored in French, not
translated from Step 3:

```markdown
## Un document écrit dans l'autre langue

Les documents de la personne dirigeante gardent les titres de section de la
langue qui les a créés. Une installation française écrit « Pratique
actuelle », une installation anglaise « Current practice ». Les deux sont
justes, et l'une comme l'autre peut se retrouver devant toi.

**Lis le document en entier, et repère une section à ce qu'elle contient, pas
à son titre.** « Pratique actuelle », c'est la ligne qui dit où en est la
personne aujourd'hui, quel que soit son intitulé. Ne signale jamais une
section absente, et ne traite jamais un document comme vide, parce que ses
titres sont dans l'autre langue.

**Aucune déduction par la position.** Si tu n'arrives vraiment pas à
identifier une section, demande. Ce sont les fichiers de la personne et elle
les modifie ; une écriture silencieuse dans ce qui se trouvait à la place
attendue vaut bien moins qu'une question.

**Dis-le une fois.** À la première lecture d'un tel document dans la session,
une ligne : le compte rendu a été écrit dans l'autre langue, tu l'as lu, et il
compte toujours. Pas de rappel ensuite.

**Propose de réécrire les titres — rien d'autre.** Propose-le comme toute
autre écriture ci-dessus : les lignes de titre seulement, sur le seul document
que tu viens de lire, jamais un balayage de tout ce qui traîne. La prose de la
personne n'est jamais traduite : c'est son compte rendu, et paraphraser
pourquoi elle a adopté une pratique, c'est une perte réelle. Refusée, la
proposition est abandonnée, pas reproposée. Elle peut toujours demander une
traduction.

**En Cowork seulement.** La réécriture est une écriture : elle n'a lieu que là
où le fichier peut être lu et réécrit. Dans une conversation Desktop, la
mention a quand même lieu, la proposition non, et tu dis clairement que rien
n'a été écrit.

**Les nouvelles lignes suivent la personne.** Ce que tu ajoutes s'écrit dans
la langue que la personne parle, pas dans celle des titres du document. Un
document aux titres anglais avec une ligne française en dessous est un état
intermédiaire correct, pas un défaut.

Quand les titres sont déjà dans ta langue, rien de tout ceci ne s'applique :
ni mention, ni proposition. Un document que tu crées toi-même l'est dans ta
langue, de la même façon — il n'y a rien à signaler sur un fichier que tu
viens de créer.
```

- [ ] **Step 5: Run the tests to verify they pass**

Run:
```bash
bash scripts/tests/shared_test.sh
bash scripts/build.sh --check
bash scripts/build.sh --lang all >/dev/null
unzip -p dist/atelier-mentor-fr.zip references/memory-protocol.md | grep -qF "## Un document écrit dans l'autre langue" && echo FR-OK
unzip -p dist/atelier-mentor-en.zip references/memory-protocol.md | grep -qF "## A document written in the other language" && echo EN-OK
```
Expected: `STATUS: PASS` from both scripts, then `FR-OK` and `EN-OK`.

`--check` passing here also proves `check_staged_references` still sees the
staged `references/memory-protocol.md` as byte-identical to the canonical
shared file — i.e. the edit reached the build, not just the source tree.

- [ ] **Step 6: Commit**

```bash
git add skills/shared/fr/memory-protocol.md skills/shared/en/memory-protocol.md
git commit -m "feat(shared): read a document written in the other language

Identify a section by what it holds, disclose the mismatch once, offer a
heading-only rewrite in Cowork, and append new lines in the executive's own
language. Rides into every ZIP inside references/memory-protocol.md, so no
SKILL.md word budget is spent.

2026-09-19-headings/AC5, AC6, AC7, AC8, AC9, AC10, AC28, AC29"
```

---

### Task 3: The call sites

The general rule is the backstop; the local wording at each call site is what
the reader has in front of it, and the two fail independently.

**Files:**
- Modify: `skills/atelier-mentor/en/references/tutorial.md:20-21, 86-93`
- Modify: `skills/atelier-mentor/fr/references/tutorial.md:20-21, 83-91`
- Modify: `skills/atelier-mentor/en/references/progression.md:33`
- Modify: `skills/atelier-mentor/fr/references/progression.md:36`
- Modify: `skills/atelier-boussole/en/references/detour-research.md:65-67`
- Modify: `skills/atelier-boussole/fr/references/detour-recherche.md:68-70`
- Modify: `skills/atelier/en/references/onboarding.md` (`## When onboarding is run again`)
- Modify: `skills/atelier/fr/references/onboarding.md` (`## Si l'accueil est relancé`)
- Modify: `skills/atelier/en/references/relais.md` (`## Delivery`)
- Modify: `skills/atelier/fr/references/relais.md` (`## Livraison`)

**Interfaces:**
- Consumes: the shared rule from Task 2 — these edits point at behaviour that
  file defines; they do not restate it.
- Produces: nothing later tasks read.

- [ ] **Step 1: Write the failing test**

The word-budget half of AC13 is the assertion. Capture the baseline **before
editing anything** in this task:

```bash
git stash list >/dev/null   # no stashing; this task edits references only
for f in $(git ls-files 'skills/*/SKILL.md'); do
  printf '%s %s\n' "$(git show dev:"$f" | wc -w)" "$f"
done > /tmp/skill-words-before.txt
cat /tmp/skill-words-before.txt
```

- [ ] **Step 2: Run it to verify the invariant is live**

Run: `wc -w $(git ls-files 'skills/*/SKILL.md') | tail -1`
Expected: a total identical to the sum in `/tmp/skill-words-before.txt`. This
task must leave it unchanged; the test is meaningful only because it passes
now and would fail if a `SKILL.md` were touched.

- [ ] **Step 3: Rewrite the mentor tutorial call sites**

`skills/atelier-mentor/en/references/tutorial.md`, in `## On every entry`,
replace item 1:

```markdown
1. **Read `{root}/docs/atelier/progression.md` in full** and find the section
   that lists the tutorial modules already covered — the one whose lines are
   dated modules. On an English install it is headed "Tutorial modules
   covered"; a document written on a French install headed it « Modules du
   tutoriel couverts ». Identify it by what it lists, not by its title, and
   see `references/memory-protocol.md`, "A document written in the other
   language", for what to say and offer when they differ.
```

In the same file, replace the two bullets under the write rules:

```markdown
- If `progression.md` already exists, add one dated line per completed
  module to the section that lists covered modules — headed "Tutorial modules
  covered" on an English install — formatted
  `- YYYY-MM-DD — module <n> — <module title>`. Write the line in the language
  the executive is speaking, and leave the rest of the file untouched,
  including its existing heading language.
- If `progression.md` doesn't exist yet and the executive agrees, create it
  with the section headings documented in `references/progression.md`, in your
  own language, including the covered-modules section. A file you just created
  needs no disclosure and no rewrite offer.
```

`skills/atelier-mentor/fr/references/tutorial.md`, in `## À chaque entrée`,
replace item 1:

```markdown
1. **Lis `{racine}/docs/atelier/progression.md` au complet** et repère la
   section qui liste les modules du tutoriel déjà couverts — celle dont les
   lignes sont des modules datés. Sur une installation française elle
   s'intitule « Modules du tutoriel couverts » ; un document écrit sur une
   installation anglaise l'a intitulée "Tutorial modules covered". Repère-la à
   ce qu'elle liste, pas à son titre, et vois `references/memory-protocol.md`,
   « Un document écrit dans l'autre langue », pour ce qu'il faut dire et
   proposer quand elles diffèrent.
```

And the two write bullets:

```markdown
- Si `progression.md` existe déjà, ajoute une ligne par module terminé à la
  section qui liste les modules couverts — intitulée « Modules du tutoriel
  couverts » sur une installation française — datée du jour, format
  `- AAAA-MM-JJ — module <n> — <titre du module>`. Écris la ligne dans la
  langue que la personne parle, et le reste du fichier ne bouge pas, titres
  compris.
- Si `progression.md` n'existe pas encore et que la personne accepte, crée-le
  avec les titres de section du format documenté dans
  `references/progression.md`, dans ta langue, section des modules couverts
  comprise. Un fichier que tu viens de créer n'appelle ni mention ni
  proposition de réécriture.
```

- [ ] **Step 4: Rewrite the progression blank check**

`skills/atelier-mentor/en/references/progression.md`, in `## Establish the
current practice first`, replace the first sentence:

```markdown
If `progression.md` is missing, or the section saying where the executive
stands today is blank — headed "Current practice" on an English install, «
Pratique actuelle » on a French one — establish it in conversation before
recommending anything
```

`skills/atelier-mentor/fr/references/progression.md`, in `## Établir la
pratique actuelle d'abord`:

```markdown
Si `progression.md` est absent, ou que la section qui dit où en est la
personne aujourd'hui est vide — intitulée « Pratique actuelle » sur une
installation française, "Current practice" sur une anglaise — établis-la en
conversation avant de recommander quoi que ce soit
```

- [ ] **Step 5: Rewrite the compass research call sites**

`skills/atelier-boussole/en/references/detour-research.md`, replace the
**Light path** paragraph:

```markdown
**Light path:** there is no map. The note is cited in the brief's section
listing the documents behind the decision — headed "Documents" on an English
install — and the decision it unblocked is written in the section recording
what was decided. Find each by what it holds: a brief written on a French
install headed them « Documents » and « Ce qui est décidé ».
```

`skills/atelier-boussole/fr/references/detour-recherche.md`:

```markdown
**Chemin léger :** il n'y a pas de carte. La note se cite dans la section du
mémo qui liste les documents derrière la décision — intitulée « Documents »
sur une installation française — et la décision qu'elle a débloquée s'écrit
dans la section qui consigne ce qui est décidé. Repère chacune à ce qu'elle
contient : un mémo écrit sur une installation anglaise les a intitulées
"Documents" et "What was decided".
```

- [ ] **Step 6: Add the read-and-use line to onboarding and relais**

`skills/atelier/en/references/onboarding.md`, in `## When onboarding is run
again`, insert after item 1:

```markdown
   If its headings are in the other language, it is still the profile: read it
   and update it in place, never create a second one beside it. See
   `references/memory-protocol.md`, "A document written in the other
   language."
```

`skills/atelier/fr/references/onboarding.md`, in `## Si l'accueil est
relancé`, after item 1:

```markdown
   Si ses titres sont dans l'autre langue, c'est quand même le profil : lis-le
   et mets-le à jour en place, ne crée jamais un deuxième à côté. Vois
   `references/memory-protocol.md`, « Un document écrit dans l'autre langue ».
```

`skills/atelier/en/references/relais.md`, in `## Delivery`, after the
**In Cowork** paragraph:

```markdown
An earlier relay found under `relais/` with the other language's headings is
read and used as-is — it is the same series. Never start a parallel set of
relays in your own language beside it.
```

`skills/atelier/fr/references/relais.md`, in `## Livraison`:

```markdown
Un relais antérieur trouvé sous `relais/` avec les titres de l'autre langue se
lit et s'utilise tel quel — c'est la même série. Ne démarre jamais une série
parallèle dans ta langue à côté.
```

- [ ] **Step 7: Run the tests to verify they pass**

```bash
wc -w $(git ls-files 'skills/*/SKILL.md') | tail -1
git diff --name-only | grep 'SKILL\.md' && echo "AC13 VIOLATED" || echo "AC13 ok: no SKILL.md touched"
git diff -U0 -- skills/ | grep -E '^[-+].*\{ra?(ci|o)ne?\}/docs/' | grep -v '^+++\|^---' || echo "AC4 ok: no path token changed"
bash scripts/build.sh --check
```
Expected: the same word total as Step 2; `AC13 ok`; `AC4 ok`; `STATUS: PASS`.

- [ ] **Step 8: Commit**

```bash
git add skills/atelier-mentor skills/atelier-boussole skills/atelier
git commit -m "feat(mentor,boussole,atelier): name sections by what they hold

Every instruction that locates a section of an exec-facing document now names
it by what it records, quoting this locale's heading as an example rather than
as the string to match. Onboarding and the relay state that a document found
in the other language is read and used, never re-created alongside.

2026-09-19-headings/AC11, AC12, AC13"
```

---

### Task 4: The registry and its reader

**Files:**
- Create: `skills/exec-documents.tsv`
- Modify: `scripts/build.sh` (new constants and `check_exec_documents`, called from `run_checks`)
- Test: `scripts/tests/build_test.sh`

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces, for Task 5 and Task 6:
  - `EXEC_DOCS_TSV` — `$SKILLS_DIR/exec-documents.tsv`.
  - `FENCE_AWK_LIB` — awk functions `fence_marker(line)`, `fence_run_len(marker, ch)`,
    `fence_closes(line, fchar, flen)`, `atx_level(line)`.
  - `exec_doc_headings <file> <want>` — prints `MISSING`, `UNCLOSED`, or a
    space-joined heading-level sequence such as `1 2 2 2 2 2`.
  - `check_exec_documents()` — called once from `run_checks`, before the
    per-locale loop.
  - In `build_test.sh`, `make_fixture_repo` now writes `skills/exec-documents.tsv`
    plus the two fixture template files it points at.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/tests/build_test.sh`, at the end, before the final
`STATUS:` block. These need the fixture helper added in Step 3, so write both
in this step and run them in Step 2.

```bash
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
```

- [ ] **Step 2: Run them to verify they fail**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -E '2026-09-19-headings|Review Focus'`
Expected: every new case reports `FAIL` — `make_fixture_repo` does not yet
write a registry and `--check` does not yet read one, so nothing fails for the
right reason yet.

- [ ] **Step 3: Teach the fixture about the registry**

In `scripts/tests/build_test.sh`, inside `make_fixture_repo`, directly before
the closing `echo "$dir"`:

```bash
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
```

- [ ] **Step 4: Write the registry**

Create `skills/exec-documents.tsv`. Six tab-separated columns, sixteen rows,
no header line. Write it with `printf` so every separator is a real tab:

```bash
printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
 company-profile '{root}/docs/atelier/company-profile.md' skills/atelier/fr/references/onboarding.md 1 skills/atelier/en/references/onboarding.md 1 \
 role-registry '{root}/docs/atelier/roles.md' skills/atelier/fr/references/onboarding.md 2 skills/atelier/en/references/onboarding.md 2 \
 progression '{root}/docs/atelier/progression.md' skills/atelier-mentor/fr/references/progression.md 1 skills/atelier-mentor/en/references/progression.md 1 \
 relay '{root}/docs/atelier/relais/<date>-<subject>.md' skills/atelier/fr/references/relais.md 1 skills/atelier/en/references/relais.md 1 \
 relay-tutorial '{root}/docs/atelier/relais/<date>-<subject>.md' skills/atelier/fr/references/relais.md 2 skills/atelier/en/references/relais.md 2 \
 compass-map '{root}/docs/<initiative>/map.md' skills/atelier-boussole/fr/references/carte.md 1 skills/atelier-boussole/en/references/map.md 1 \
 ticket '{root}/docs/tickets/NN-<short-name>.md' skills/atelier-boussole/fr/references/plan-daction.md 1 skills/atelier-boussole/en/references/action-plan.md 1 \
 compass-brief '{root}/docs/<date>-<decision>.md' skills/atelier-boussole/fr/references/carte.md 3 skills/atelier-boussole/en/references/map.md 3 \
 compass-memo '{root}/docs/<initiative>/' skills/atelier-boussole/fr/references/collapse.md 1 skills/atelier-boussole/en/references/collapse.md 1 \
 research-note '{root}/docs/research/<date>-<subject>.md' skills/atelier-boussole/fr/references/detour-recherche.md 1 skills/atelier-boussole/en/references/detour-research.md 1 \
 decision-log '{root}/docs/atelier/decisions.md' - - - - \
 role-memory '{root}/docs/atelier/memory/<canonical-name>.md' - - - - \
 voice-guide '{root}/docs/marketing/guide-de-voix.md' - - - - \
 minutes '{root}/docs/reunions/' - - - - \
 pipeline-review '{root}/docs/ventes/' - - - - \
 mockup '{root}/docs/maquettes/' - - - - \
 > skills/exec-documents.tsv
```

Then confirm the shape:
```bash
awk -F'\t' '{ if (NF != 6) print "BAD LINE " NR ": " NF " columns" } END { print NR " rows" }' skills/exec-documents.tsv
```
Expected: `16 rows` and no `BAD LINE`.

The ticket template is duplicated inside `carte.md` / `map.md` (block 2) as a
convenience copy. The registry points at the canonical copy in
`plan-daction.md` / `action-plan.md`; keeping the two in sync stays a review
matter, not a new check.

- [ ] **Step 5: Add the reader to `scripts/build.sh`**

Insert after the `DATED_CLAIMS_AWK_LIB` definition (around line 250). The
fence helpers are **copied**, not refactored out of the dated-claims awk: that
check passes today and a shared-library edit would put it at risk for no gain.

```bash
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

  # --- Task 5 replaces the two lines below with the parity comparison.
  [[ "$ok" -eq 1 ]] || return 0
}
```

- [ ] **Step 6: Call it from `run_checks`**

In `run_checks`, immediately after the `check_dated_claims` call and before
the `for locale in` loop:

```bash
  # 2026-09-19-headings/AC16 — the registry names its own files, so this runs
  # once here rather than inside the per-skill, per-locale loop below.
  check_exec_documents
```

- [ ] **Step 7: Run the tests to verify they pass**

```bash
bash scripts/tests/build_test.sh 2>&1 | grep -E '2026-09-19-headings|Review Focus'
bash scripts/tests/build_test.sh 2>&1 | tail -3
bash scripts/build.sh --check
```
Expected: every new case reports `ok:`; the suite ends `STATUS: PASS`; and
`--check` on the real repo prints `STATUS: PASS (mechanical checks)`.

- [ ] **Step 8: Commit**

```bash
git add skills/exec-documents.tsv scripts/build.sh scripts/tests/build_test.sh
git commit -m "feat(build): register every exec-facing document and its templates

skills/exec-documents.tsv carries one row per document — doc-id, canonical
path, and the reference file plus 1-based markdown block that holds its
template in each locale. --check reads it, validating column shape, file
existence and block index, and rejecting a half-prose row or one file named
for both locales.

2026-09-19-headings/AC14, AC15, AC17, AC18"
```

---

### Task 5: The heading-level parity comparison

**Files:**
- Modify: `scripts/build.sh` (`check_exec_document_row`, tail)
- Test: `scripts/tests/build_test.sh`

**Interfaces:**
- Consumes from Task 4: `exec_doc_headings`, `check_exec_document_row`,
  `check_fail`, `$REPO_ROOT`.
- Produces: the two failure messages Task 6 mirrors in PowerShell —
  `<doc-id> — heading counts differ: <fr-ref> has <n>, <en-ref> has <n>` and
  `<doc-id> — heading levels differ: <fr-ref> [<levels>], <en-ref> [<levels>]`.

- [ ] **Step 1: Confirm the repository already satisfies the rule**

Before writing the comparison, prove no template needs editing. Run:

```bash
cat > /tmp/blk.awk <<'AWK'
BEGIN { n = 0; inb = 0 }
/^```markdown$/ && !inb { n++; if (n == WANT) inb = 1; next }
/^```$/ && inb { inb = 0; next }
inb && /^#+ / { printf "%s ", length($1) }
END { printf "\n" }
AWK
while IFS=$'\t' read -r id path fr fb en eb; do
  [[ "$fr" == "-" ]] && continue
  a="$(awk -v WANT="$fb" -f /tmp/blk.awk "$fr")"
  b="$(awk -v WANT="$eb" -f /tmp/blk.awk "$en")"
  [[ "$a" == "$b" ]] && echo "OK       $id" || echo "MISMATCH $id  fr:[$a] en:[$b]"
done < skills/exec-documents.tsv
```
Expected: ten `OK` lines, no `MISMATCH`. If any row mismatches, **stop and
report it** — the spec's Non-goals forbid renaming paths, but a real template
divergence is a finding the branch must surface, not silently patch.

- [ ] **Step 2: Write the failing tests**

Append to `scripts/tests/build_test.sh`:

```bash
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
```

- [ ] **Step 3: Run them to verify they fail**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -E 'AC19|AC20|AC21|Review Focus 5'`
Expected: the AC19, AC20 and Review Focus 5 cases report `FAIL` (no comparison
exists yet, so `--check` exits 0). The AC21 case already passes — Task 4's
`dashes -eq 4` branch skips the row — and must keep passing.

- [ ] **Step 4: Add the comparison**

In `scripts/build.sh`, replace the last two lines of `check_exec_document_row`
— the `# --- Task 5 replaces…` comment and the `[[ "$ok" -eq 1 ]] || return 0`
beneath it — with:

```bash
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
```

- [ ] **Step 5: Run the tests to verify they pass**

```bash
bash scripts/tests/build_test.sh 2>&1 | grep -E '2026-09-19-headings|Review Focus'
bash scripts/tests/build_test.sh 2>&1 | tail -3
bash scripts/build.sh --check
```
Expected: every case `ok:`; `STATUS: PASS` from the suite; `STATUS: PASS
(mechanical checks)` from the real repo — the AC16 assertion, on the ten live
rows verified in Step 1.

- [ ] **Step 6: Commit**

```bash
git add scripts/build.sh scripts/tests/build_test.sh
git commit -m "feat(build): fail when two locales' templates diverge structurally

The parity rule: the registry's two template blocks must carry an identical
sequence of heading levels — same count, same depths, same order. A dropped
section, a changed depth or a reordering fails by doc-id and both files; a
'-' row is skipped, and an unclosed block fails rather than comparing a
truncated list.

2026-09-19-headings/AC16, AC19, AC20, AC21"
```

---

### Task 6: The PowerShell twin

**Files:**
- Modify: `scripts/build.ps1`
- Test: `scripts/tests/build_test.ps1`

**Interfaces:**
- Consumes from `scripts/build.ps1` as it stands: `Add-CheckFailure`,
  `Get-FenceMarker`, `Get-FenceRunLength`, `Test-FenceCloses`, `$SkillsDir`,
  `$RepoRoot`, `Invoke-Checks`.
- Consumes from Tasks 4-5: the registry format and every failure message's
  wording — the PowerShell messages are byte-identical strings.
- Produces: `Get-AtxLevel`, `Get-TemplateBlockHeadings`, `Test-ExecDocuments`.

- [ ] **Step 1: Write the failing tests**

Append to `scripts/tests/build_test.ps1`, before the final `STATUS:` block:

```powershell
# --- 2026-09-19-headings/AC22: the clean fixture passes
$d = New-FixtureRepo
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0) { Add-Pass '2026-09-19-headings/AC22 clean fixture passes the exec-document rule' }
else { Add-Failure "2026-09-19-headings/AC22 clean fixture failed (out=$($r.Output))" }
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC22 over AC17: a reference file that is gone
$d = New-FixtureRepo
Remove-Item -LiteralPath (Join-Path $d 'skills/atelier-ventes/fr/references/modele.md')
Expect-CheckFail $d 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md' `
  '2026-09-19-headings/AC22 missing reference file reaches the same verdict'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC22 over AC18: a block index the file lacks
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/exec-documents.tsv') {
  param($t) $t -replace "modele\.md`t1", "modele.md`t4" }
Expect-CheckFail $d 'pipeline-doc — skills/atelier-ventes/fr/references/modele.md has no markdown template block 4' `
  '2026-09-19-headings/AC22 missing block index reaches the same verdict'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC23 over AC19: a dropped section
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/fr/references/modele.md') {
  param($t) $t -replace "`n## Ce qui bloque`n", "`n" }
Expect-CheckFail $d 'pipeline-doc — heading counts differ' `
  '2026-09-19-headings/AC23 a dropped section reaches the same verdict'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC22 over AC20: a changed heading depth
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/references/template.md') {
  param($t) $t -replace "`n## What is stuck`n", "`n### What is stuck`n" }
Expect-CheckFail $d 'pipeline-doc — heading levels differ' `
  '2026-09-19-headings/AC22 a changed depth reaches the same verdict'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19-headings/AC22 over AC21: a '-' row is skipped, not failed
$d = New-FixtureRepo
Add-Content -LiteralPath (Join-Path $d 'skills/exec-documents.tsv') `
  -Value "prose-doc`t{root}/docs/atelier/decisions.md`t-`t-`t-`t-"
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0 -and -not $r.Output.Contains('prose-doc')) {
  Add-Pass "2026-09-19-headings/AC22 a '-' row is skipped on Windows too"
} else {
  Add-Failure "2026-09-19-headings/AC22 '-' row not skipped (exit=$($r.ExitCode), out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d
```

- [ ] **Step 2: Teach `New-FixtureRepo` about the registry**

In `scripts/tests/build_test.ps1`, inside `New-FixtureRepo`, directly before
it returns `$dir`, mirroring Task 4 Step 3 line for line:

```powershell
  # 2026-09-19-headings/AC22 — the fixture carries the registry and the two
  # parallel templates it points at; an absent registry is fatal.
  foreach ($sub in @('skills/atelier-ventes/fr/references', 'skills/atelier-ventes/en/references')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $dir $sub) | Out-Null
  }
  Write-Lf (Join-Path $dir 'skills/atelier-ventes/fr/references/modele.md') @"
# Modèle de revue de pipeline

``````markdown
# Revue de pipeline — <entreprise>

## Où en est le pipeline

## Ce qui bloque

## Prochaines relances
``````
"@
  Write-Lf (Join-Path $dir 'skills/atelier-ventes/en/references/template.md') @"
# Pipeline review template

``````markdown
# Pipeline review — <company>

## Where the pipeline stands

## What is stuck

## Next follow-ups
``````
"@
  Write-Lf (Join-Path $dir 'skills/exec-documents.tsv') `
    ("pipeline-doc`t{root}/docs/ventes/pipeline.md`tskills/atelier-ventes/fr/references/modele.md`t1`tskills/atelier-ventes/en/references/template.md`t1`n")
```

Backticks inside a `@"…"@` here-string are PowerShell's escape character, so
each fence is written as six backticks to emit three.

- [ ] **Step 3: Run the tests to verify they fail**

Run: `pwsh -File scripts/tests/build_test.ps1 2>&1 | Select-String '2026-09-19-headings'`
Expected: every new case reports `FAIL` — `build.ps1` does not read the
registry yet.

- [ ] **Step 4: Add the reader to `scripts/build.ps1`**

Insert after the existing fence helpers (after `Test-FenceCloses`, around line
95):

```powershell
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
      if (-not (Test-Path -LiteralPath $full)) {
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
```

- [ ] **Step 5: Call it from `Invoke-Checks`**

In `Invoke-Checks`, immediately after the `Test-DatedClaims` call and before
the `foreach ($locale in $Locales)` loop:

```powershell
  # 2026-09-19-headings/AC16 — the registry names its own files, so this runs
  # once here rather than inside the per-skill, per-locale loop below.
  Test-ExecDocuments
```

- [ ] **Step 6: Run the tests to verify they pass**

```bash
pwsh -File scripts/tests/build_test.ps1 2>&1 | grep -E '2026-09-19-headings'
pwsh -File scripts/tests/build_test.ps1 2>&1 | tail -3
pwsh -File scripts/build.ps1 -Check
```
Expected: every case `ok:`; the suite ends `STATUS: PASS`; and `-Check` on the
real repo prints `STATUS: PASS (mechanical checks)` — the same verdict
`bash scripts/build.sh --check` gives (AC22).

If `pwsh` is not on this machine, say so plainly and do not tick these boxes:
CI runs `build_test.ps1` on `windows-latest` and the branch is not verified
for AC22 until that job is green. Do not claim the task complete on the
strength of the bash suite alone.

- [ ] **Step 7: Commit**

```bash
git add scripts/build.ps1 scripts/tests/build_test.ps1
git commit -m "feat(build): mirror the exec-document parity rule in PowerShell

-Check reads the same registry and reaches the same pass/fail verdict as
--check for every mutation: missing file, missing block index, differing
heading count, differing depth or order, and a '-' row.

2026-09-19-headings/AC22, AC23"
```

---

### Task 7: The locale-switch scenario

**Files:**
- Create: `tests/_cross-skill/changement-de-langue.md`

**Interfaces:**
- Consumes: the shared rule (Task 2) and the mentor call sites (Task 3) — this
  scenario is how they are observed.
- Produces: the scenario file Task 8 dispatches and ticks.

- [ ] **Step 1: Write the failing test**

The scenario file itself is the artifact; its shape is asserted by
`--check`'s `check_scenarios` only for per-skill directories, so assert the
four required sections directly:

```bash
for h in '## Prompt' '## Expected behaviors' '## Baseline notes' '## Verification notes'; do
  grep -qF "$h" tests/_cross-skill/changement-de-langue.md \
    && echo "ok: $h" || echo "FAIL: missing $h"
done
```

- [ ] **Step 2: Run it to verify it fails**

Expected: four `FAIL:` lines (and a `grep` error that the file does not exist).

- [ ] **Step 3: Write the scenario**

Create `tests/_cross-skill/changement-de-langue.md`:

````markdown
---
skills:
  - atelier-mentor
  - atelier
locale: mixed
scope: cross-skill
sessions: 2
---

## Prompt

Two sessions against **the same sandbox root**, run in order. The property
under test is that a record written on one locale's install is read back by
the other's — identified by what its sections hold, not by their titles — so
it has to be observed in both directions to count as a system property rather
than one skill's lucky direction. Same reasoning as
`langue-de-la-personne.md`.

**Dispatch A — French writes, English reads.**

*Session 1* — French `atelier-mentor` is installed. The executive, writing in
French, works through tutorial modules 1 through 5 and agrees to have them
noted. The session writes `{root}/docs/atelier/progression.md` with French
headings, module lines under « Modules du tutoriel couverts ».

*Session 2* — a fresh English `atelier-mentor`, same sandbox root, no memory
of session 1. The executive writes: *"Can we pick the tutorial back up where
we left off?"*

**Dispatch B — English writes, French reads.** The mirror. Session 1 is
English `atelier-mentor` covering modules 1 through 5 and writing "Tutorial
modules covered"; session 2 is a fresh French `atelier-mentor`, same root,
the executive writing: *« On peut reprendre le tutoriel où on était rendu ? »*

## Expected behaviors

- [ ] The record written in the other locale is read back — session 2 opens
  `progression.md` and uses what is in it, rather than treating the file as
  empty or absent
- [ ] All seven modules are listed with the already-covered ones carrying
  their dates, and the recommendation names only the uncovered ones
- [ ] The mismatch is disclosed once, in the language the executive is
  speaking — not once per module, not in the document's heading language
- [ ] A heading-only rewrite is offered as an ordinary proposed write
- [ ] An accepted rewrite changes heading lines only: the executive's own
  prose is byte-identical before and after, and no section is reordered
- [ ] A declined rewrite leaves the whole file byte-identical
- [ ] A section the executive added themselves survives an accepted rewrite —
  heading and body both — and is not reordered
- [ ] Lines appended in session 2 are written in the language the executive is
  speaking, not the document's heading language
- [ ] Session 1, which creates `progression.md` from nothing, writes it in its
  own locale's headings and makes no disclosure and no rewrite offer
- [ ] A second session on the *same* locale as the document makes no disclosure
  and no rewrite offer

## Baseline notes

N/A. A plain assistant has no installed locale and no cross-session document
to read back: there is no second session reading a first session's file, so
there is nothing a baseline could discriminate. The scenario checks that
Atelier's own rule — `skills/shared/<locale>/memory-protocol.md`, "A document
written in the other language" — is followed, not that a model would invent
it.

## Verification notes
````

- [ ] **Step 4: Run the test to verify it passes**

Run the Step 1 loop again.
Expected: four `ok:` lines. Then `bash scripts/build.sh --check` — expected
`STATUS: PASS`; a `tests/_cross-skill/` file is not counted as a per-skill
scenario and must not disturb `check_scenarios`.

- [ ] **Step 5: Commit**

```bash
git add tests/_cross-skill/changement-de-langue.md
git commit -m "test: scenario for reading a record written in the other locale

Two dispatches, French-writes-English-reads and the mirror, so the property
is observed in both directions. Boxes stay unticked until the runs in the
next commit establish them.

2026-09-19-headings/AC24, AC25"
```

---

### Task 8: Run the two dispatches and commit the transcripts

This task is manual agent work, not a code change. It comes last because both
dispatches exercise the rule and the call sites that Tasks 2 and 3 put in
place, and the transcript is saved **before** any box is ticked.

**Files:**
- Create: `tests/_cross-skill/runs/changement-de-langue/<today>-verification.md` (Dispatch A)
- Create: `tests/_cross-skill/runs/changement-de-langue/<today>-verification-mirror.md` (Dispatch B)
- Modify: `tests/_cross-skill/changement-de-langue.md` (`## Expected behaviors` boxes, `## Verification notes`)

**Interfaces:**
- Consumes: the scenario from Task 7; the built ZIPs from `bash scripts/build.sh --lang all`.
- Produces: the ticked scenario file — the branch's evidence for AC26, AC27, AC30.

- [ ] **Step 1: Read the run conventions**

Run: `sed -n '225,305p' tests/README.md`
Everything below follows from it. In particular: `runs/` is a subdirectory and
that is load-bearing — a transcript saved as a sibling of the scenario file
would be counted as a scenario by `check_scenarios`.

- [ ] **Step 2: Build the ZIPs the dispatches install**

```bash
bash scripts/build.sh --lang all
ls dist/atelier-mentor-fr.zip dist/atelier-mentor-en.zip
```

- [ ] **Step 3: Run Dispatch A**

French session 1, then a fresh English session 2 against the same sandbox
root. Seed the sandbox with an invented company, as the corpus does —
Cedarline Outfitters, Lanternes Boréales. In session 2, run the accepted-offer
and declined-offer branches as two attempts from the same session-2 starting
state, so both the byte-identical-prose box and the byte-identical-file box
have evidence.

Capture, per `tests/README.md`:
1. the prompt, verbatim, including the full scripted conversation;
2. the reply, verbatim and complete, not excerpted;
3. the sandbox after the run — the `find` listing;
4. every file the dispatch created or modified, pasted in full under 16384
   bytes (`progression.md` is far under).

For the rewrite boxes, record `md5sum` of `progression.md` before and after
each branch — a declined offer must leave the sum unchanged.

- [ ] **Step 4: Save Dispatch A's transcript**

```bash
mkdir -p tests/_cross-skill/runs/changement-de-langue
$EDITOR "tests/_cross-skill/runs/changement-de-langue/$(date +%F)-verification.md"
```

Header: the scenario file's path, the date, kind `verification`, the agent
type and model dispatched. No isolation-preamble version — that is baselines
only, and this scenario has none. Then one block per session, labeled exactly
as the prompt section labels it.

- [ ] **Step 5: Run Dispatch B and save its transcript**

The mirror: English writes, French reads. Same four items captured, saved as
`tests/_cross-skill/runs/changement-de-langue/$(date +%F)-verification-mirror.md`.

- [ ] **Step 6: Tick only what the runs established**

Edit `tests/_cross-skill/changement-de-langue.md`: change `- [ ]` to `- [x]`
for each box both dispatches established. For every box left unticked, write
the reason under `## Verification notes` — what was run, what was observed,
and why the box does not follow from it. A transcript is written once and
never edited afterwards; the verdict lives in the scenario file, where it can
be corrected in place.

- [ ] **Step 7: Verify the tree**

```bash
bash scripts/build.sh --check
find tests/_cross-skill -name '*.md' | sort
grep -c '^- \[x\]' tests/_cross-skill/changement-de-langue.md
```
Expected: `STATUS: PASS`; both transcripts under `runs/changement-de-langue/`
and nothing new directly under `tests/_cross-skill/` except the scenario;
a tick count matching what the `## Verification notes` says was established.

- [ ] **Step 8: Commit**

```bash
git add tests/_cross-skill/changement-de-langue.md \
        tests/_cross-skill/runs/changement-de-langue/
git commit -m "test: run the locale-switch scenario in both directions

Transcripts saved before the boxes were ticked, per ADR-0014. Unticked boxes
carry their reason in the scenario's Verification notes.

2026-09-19-headings/AC26, AC27, AC28, AC29, AC30"
```

---

### Task 9: Post-implementation check

- [ ] **Step 1: Verify every Required Task actually landed**

Read the diff, do not trust the checkboxes:

```bash
git diff dev...HEAD --stat
git diff dev...HEAD -- docs/adr/ docs/AUTHORING.md CLAUDE.md
git diff dev...HEAD -- skills/shared/
git diff dev...HEAD --name-only | grep 'SKILL\.md' && echo "AC13 VIOLATED" || echo "AC13 ok"
```

Against the spec's own tables, confirm each row produced a change:
`skills/exec-documents.tsv` created; `scripts/build.sh`, `scripts/build.ps1`,
`scripts/tests/build_test.sh`, `scripts/tests/build_test.ps1`,
`scripts/tests/authoring_test.sh` modified; `scripts/tests/shared_test.sh`,
`.github/workflows/ci.yml`, `.github/workflows/dated-claims.yml`,
`release-please-config.json`, `tests/README.md` untouched;
`docs/adr/0016-…` created and `docs/adr/0007-…`, `docs/AUTHORING.md`,
`CLAUDE.md` modified.

- [ ] **Step 2: Verify the deferred items exist and are complete**

```bash
for n in 38 39; do
  echo "--- #$n"
  gh issue view "$n" --json title,body --jq '.title, .body' \
    | grep -cE '^## (Context|Required|Integration Points|Priority)'
done
```
Expected: `4` for each. If an issue is missing a section, fix the issue — the
spec's Deferred Items list is only as good as what is on the tracker.

- [ ] **Step 3: Run the whole gate**

```bash
bash scripts/build.sh --check \
  && bash scripts/tests/shared_test.sh \
  && bash scripts/tests/authoring_test.sh \
  && bash scripts/tests/build_test.sh \
  && pwsh -File scripts/tests/build_test.ps1
```
Expected: `STATUS: PASS` from each. Report any `pwsh` absence plainly rather
than skipping silently.

- [ ] **Step 4: Final build**

```bash
bash scripts/build.sh --lang all
ls dist/
```
Expected: one ZIP per skill per locale, no errors. Non-negotiable — checks and
tests alone do not catch every build-time failure.

---

## Before finishing the branch (advisory cross-model review)

After the final build passes — and before wrapping up via
`superpowers:finishing-a-development-branch` — if a cross-model review helper
is available (e.g. the Codex plugin's adversarial review), run it with focus:

> *Judge correctness against the spec's acceptance criteria (AC1–AC31) only.
> Do not flag anything outside the stated criteria — no design alternatives,
> hardening, or scope the spec did not claim.*

This **never gates a merge** — the gate stays `bash scripts/build.sh --check`
plus `bash scripts/build.sh --lang all`; the review only flags what deserves a
second look. If no helper is available, finish the branch without it.

# Shipping both locales' heading spellings

**Date:** 2026-09-20
**Status:** Approved — ready for `superpowers:writing-plans`
**AC citation prefix:** `2026-09-20-heading-pairs/ACn`
**Extends:** [`2026-09-19-exec-document-headings-design.md`](2026-09-19-exec-document-headings-design.md),
[ADR-0016](../../adr/0016-exec-facing-document-section-headings.md)
**Closes:** #42, #43

## The problem

ADR-0016 *Decision §4* protects a heading the executive renamed. A heading is
rewritten only when the reader placed that section as one of its own **and**
the heading is spelled the way its template spells it, "in one locale or the
other". The second condition is what separates a template heading the reader
may translate from one the executive chose for themselves.

That condition cannot be evaluated. It asks the reader to compare a heading
against two spellings, and the shipped ZIP contains one. Grepping `skills/`
for the five `progression.md` headings:

| Heading | Ships in |
| --- | --- |
| « Pratique actuelle » / "Current practice" | both locales |
| « Pratiques adoptées » / "Practices adopted" | one locale each |
| « Difficultés exprimées » / "Stated struggles" | one locale each |
| « Prochaine étape convenue » / "Agreed next step" | one locale each |
| « Modules du tutoriel couverts » / "Tutorial modules covered" | EN spelling appears in the FR `tutorial.md`; the FR spelling appears nowhere in the EN ZIP |

The one full pair exists because `progression.md` and `memory-protocol.md`
happen to name it in prose, and the one half-pair because the French
`tutorial.md` names the English spelling while the English `tutorial.md` does
not reciprocate. Neither is a mechanism. Across the ten registry rows that
carry templates, roughly forty section headings per locale, only that single
pair is available to a reader in both languages.

`skills/exec-documents.tsv` already records, per document, which reference
file and which fenced `markdown` block holds its template in each locale. It
is a repo build-check registry and is not shipped.

### The second failure, which is not about missing data

The 2026-09-20 locale-switch run tested the one pair that **does** ship
symmetrically. Results split entirely by direction:

- English install reading a French document — the renamed heading survived 2
  of 2 accepted rewrites.
- French install reading an English document — the renamed heading was
  translated 3 of 3, becoming « Pratique actuelle » every time.

Sharpening the rule's statement between rounds changed nothing; the passing
direction passed under both wordings and the failing direction failed under
both. The transcript is
`tests/_cross-skill/runs/changement-de-langue/2026-09-20-verification-executive-added-sections.md`
and the analysis is the `## Verification notes — 2026-09-20 executive-added
and renamed headings` section of `tests/_cross-skill/changement-de-langue.md`.

One variable was never changed: the worked example. Both locales' examples are
**same-language** — the English rule contrasts "Stated struggles" against
"What keeps going wrong", the French rule contrasts « Difficultés exprimées »
against « Ce qui bloque ». Neither shows a reader the situation it is actually
in, which is a template in one language against a renamed heading in the
other.

This spec addresses both halves. #43 was filed for the behaviour half and is
closed into this design rather than carried separately.

## What we are building

1. Every ZIP gains a generated `references/exec-document-headings.md` giving,
   per exec-facing document, each of its section headings in both locales.
2. `skills/shared/{fr,en}/memory-protocol.md` points at that file, replaces its
   worked example with the cross-language case, requires the rewrite offer to
   name both what it will rewrite and what it will leave, and states what to do
   with a document that has no template.
3. ADR-0016 *Decision §4* is amended to record both, and the generated file is
   added to its Consequences.
4. The locale-switch scenario gains boxes for the new behaviour and is re-run
   in both directions under a stated attempt budget.

### Rejected alternatives

**Hand-write the pairs into each locale's template reference file.** The
precedent exists — `progression.md` and `tutorial.md` already do it in prose
for two headings. Rejected because it must be redone by hand for every new
exec-facing document and nothing detects when one side rots. The registry is
where this information is already declared; duplicating it into ten files
invents a second source of truth that no check compares against the first.

**Narrow AC32 so a renamed heading is protected only where the pair happens to
be known.** Rejected: it leaves fourteen of the nineteen template sections
unprotected and trades away the decision ADR-0016 actually made, on the
strength of a build limitation rather than a design argument.

**Append the generated table into `references/memory-protocol.md` at stage
time.** Rejected: `check_staged_references()` proves the staged
`memory-protocol.md` is byte-identical to `skills/shared/<locale>/memory-protocol.md`
(`scripts/build.sh:1002`). Appending would force that `cmp -s` to become a
prefix comparison, weakening a load-bearing invariant to save one file.

**Inject each document's pairs into its own template reference file at stage
time.** Rejected: it transforms ten source files during staging and entangles
generated content with the per-skill shared-text checks, to save a pointer
line.

## Design

### The generated file

Path in the ZIP: `references/exec-document-headings.md`. English filename in
both locales, matching `glossary.md` and `memory-protocol.md`.

Its framing prose is a **source** file, `skills/shared/<locale>/exec-document-headings.md`,
so translated text lives beside the other shared texts rather than inside a
build script. The generator copies that preamble into the stage and appends
the generated table to it.

The table is grouped by document, in registry order. Each group carries the
document's canonical `{root}` path from the registry's second column, then its
headings at level 2 and deeper, in document order, French spelling beside
English.

Level-1 titles are excluded. Only `role-registry` has a title that is a fixed
string in both locales; the other nine are templated — `# Relay — <subject> —
YYYY-MM-DD` against `# Relais — <sujet> — AAAA-MM-JJ`, `# <what it delivers,
in one line>` against `# <ce que ça livre, en une ligne>`. A heading containing
a placeholder can never answer the question the table exists to answer, and the
title is not a section anyone writes into. Under the no-template rule below,
a heading with no comparable template spelling is left alone, which is the
correct treatment for a title regardless.

Consequences of that exclusion: `role-registry` and `ticket` are a title and
nothing else, so they contribute no rows and are omitted from the file
entirely. `relay` and `relay-tutorial` are two blocks in the same reference
file sharing three headings; they stay separate entries, because the rule's
test is per-template and a reader holding a tutorial relay should see that
document's sections, not a merged set. Pairs whose two spellings are identical
— `## Documents` / `## Documents` — are kept, so that a heading never reads as
unrecognized merely because the two languages agree.

Rows whose four template columns are `-` are skipped. Those six documents —
`decision-log`, `role-memory`, `voice-guide`, `minutes`, `pipeline-review`,
`mockup` — are described in prose and have no template headings in either
locale, so there is nothing to pair.

### Generation

`exec_doc_heading_text()` joins `exec_doc_headings()` in `scripts/build.sh`,
reusing the same `FENCE_AWK_LIB` helpers. It walks to the requested 1-based
fenced `markdown` block by the same rule — entering every fence so a ```bash
block quoting a ```markdown opener is not miscounted — strips a trailing `\r`
so a CRLF checkout behaves like an LF one, and emits each ATX heading's level
and text rather than its level alone. It returns the same `MISSING` and
`UNCLOSED` sentinels on the same conditions.

`generate_exec_heading_pairs()` reads `skills/exec-documents.tsv` once per
build, extracts both sides of every templated row, and writes the staged file.
`stage_skill()` calls it after copying `glossary.md` and `memory-protocol.md`.

It **`die`s**, failing the build rather than only `--check`, when:

- the registry is missing;
- a row does not have six tab-separated columns;
- a row's template columns are partly `-`;
- a named reference file does not exist;
- a block index is not a positive integer, or the block is `MISSING` or
  `UNCLOSED`;
- the two sides of a row yield different heading counts.

This matches what `stage_skill()` already does for a missing `SKILL.md` or a
frontmatter name that disagrees with `names.tsv`. `check_exec_documents()`
runs only under `--check`; a plain `bash scripts/build.sh --lang all` never
calls it, so without independent validation the generator could ship a table
with a document silently missing — the same class of failure this spec exists
to close.

`scripts/build.ps1` mirrors every part of this, as it already mirrors the
parity check.

### The rule

In the "A document written in the other language" section of both
`skills/shared/{fr,en}/memory-protocol.md`:

**Pointer.** The paragraph carrying the two-part test names
`references/exec-document-headings.md` as where the template spellings live,
and says to read the entry for the document in hand before offering.

**Worked example, rewritten to the cross-language case.** The French rule
becomes, in substance: your template says « Pratique actuelle », English
spells the same section "Current practice", and their file says "Where I'm at
right now" — neither spelling, so it stays. The English rule gets the mirror,
with an English template facing a French renamed heading. This is the one
variable the 2026-09-20 run never changed.

**The offer names both lists.** The offer states the headings it will rewrite
*and* the headings it will leave, rather than mentioning exceptions only when
it noticed one. The comparison then has to be performed to write the offer at
all, and an omitted comparison is visible in the offer rather than only in the
diff. This subsumes the existing requirement that the offer name the exception.

**A document with no template.** Where the reader has no template for a
document, every heading stays as written. There is no "the way your template
spells it" to test, and leaving a heading alone writes nothing.

### Verification

`tests/_cross-skill/changement-de-langue.md` gains boxes for the rewritten
offer naming both lists and for the renamed heading surviving with the pair
table present, then the scenario is dispatched in both directions.

**Attempt budget: two per direction after the fix lands.** If the
French-reading-English direction still translates the renamed heading after
two attempts, the work stops there, the boxes carry their stated reasons, and
a successor issue is opened recording what the pair table and the rewritten
example did and did not change. We do not re-roll past the budget, and we do
not weaken the criteria to match the behaviour. This exit is written here so
it is a decision already made rather than one taken under pressure mid-run.

## Acceptance Criteria

### The generated file

- **AC1** — Every ZIP produced by `bash scripts/build.sh --lang all` and by
  `./scripts/build.ps1 -Lang all` contains `references/exec-document-headings.md`.
- **AC2** — That file begins with the contents of
  `skills/shared/<locale>/exec-document-headings.md` for the ZIP's locale,
  byte-identical, followed by the generated table.
- **AC3** — The file contains one group per `skills/exec-documents.tsv` row
  whose four template columns are not `-` **and** whose template block holds at
  least one heading at level 2 or deeper, in registry order.
- **AC4** — Each group names the document's canonical path, taken verbatim from
  the registry's second column.
- **AC5** — Within a group, every heading at level 2 or deeper from both
  locales' template blocks appears, in document order, with the French spelling
  and the English spelling of the same heading on the same line.
- **AC6** — No level-1 heading from any template block appears in the file.
- **AC7** — Given the registry as it stands, the file contains no group for
  `role-registry` or for `ticket`, because each template block's only heading is
  its level-1 title.
- **AC8** — Given the registry as it stands, `relay` and `relay-tutorial`
  appear as two separate groups, each carrying its own block's headings, even
  though both blocks live in the same reference file and share three headings.
- **AC9** — A heading whose French and English spellings are identical appears
  in the file like any other, not omitted.
- **AC10** — No group appears for a row whose four template columns are `-`.

### Extraction

- **AC11** — Given a reference file whose target `markdown` block contains
  headings, text extraction returns each heading's level and its text with the
  ATX marker and its following space removed.
- **AC12** — Given a reference file checked out with CRLF line endings,
  extraction returns the same heading text as the LF checkout, with no trailing
  carriage return.
- **AC13** — Given a reference file where a ```bash block quotes a ```markdown
  opener before the target block, the quoted opener is not counted toward the
  block index.
- **AC14** — Given a target block that runs to end of file without a closing
  fence, extraction reports `UNCLOSED`; given fewer `markdown` blocks in the
  file than the requested index, it reports `MISSING`.

### Build failure

- **AC15** — Given `skills/exec-documents.tsv` absent, a build (not only
  `--check`) exits non-zero naming the missing registry.
- **AC16** — Given a registry row without exactly six tab-separated columns, or
  with its template columns partly `-`, a build exits non-zero naming the row.
- **AC17** — Given a registry row naming a reference file that does not exist,
  or a block index that is not a positive integer, a build exits non-zero
  naming the document id and the offending value.
- **AC18** — Given a registry row whose template block is `MISSING` or
  `UNCLOSED` on either side, a build exits non-zero naming the document id and
  the file.
- **AC19** — Given a registry row whose two locales' template blocks yield
  different heading counts, a build exits non-zero naming the document id and
  both counts.
- **AC20** — Every failure in AC15–AC19 occurs on `bash scripts/build.sh --lang
  all` and on `./scripts/build.ps1 -Lang all`, not only under `--check`.

### Parity between the two build scripts

- **AC21** — For the repository as it stands, the
  `references/exec-document-headings.md` produced by `build.ps1` is
  byte-identical to the one produced by `build.sh`, for each locale.

### The rule

- **AC22** — The "A document written in the other language" section of both
  `skills/shared/{fr,en}/memory-protocol.md` names
  `references/exec-document-headings.md` and says to consult the entry for the
  document being read before making a rewrite offer.
- **AC23** — The worked example in `skills/shared/fr/memory-protocol.md`
  contrasts a French template spelling and its English counterpart against a
  renamed heading written in English; the example in the English file is the
  mirror, contrasting an English template spelling and its French counterpart
  against a renamed heading written in French.
- **AC24** — Both files state that the rewrite offer names the headings it will
  rewrite and the headings it will leave.
- **AC25** — Both files state that where the reader has no template for a
  document, every heading is left as written.
- **AC26** — `scripts/tests/shared_test.sh` asserts that
  `skills/shared/<locale>/exec-document-headings.md` exists and is non-empty in
  both locales, and passes.

### Behaviour, verified by dispatch

- **AC27** — Given an accepted heading rewrite on a document where the executive
  renamed one of the template's own sections, that section's heading and body
  survive unchanged, in both directions of the locale switch.
- **AC28** — Given a rewrite offer on such a document, the offer names both the
  headings it will rewrite and the headings it will leave, in both directions.
- **AC29** — Given an accepted heading rewrite on a document carrying a section
  the executive added themselves, that section's heading and body survive
  unchanged and no section is reordered, in both directions.
- **AC30** — Each direction is dispatched at most twice after the fix lands.
  Every verdict comes from `diff` against the seeded file checked on disk, never
  from an agent's self-report, and each dispatch leaves a transcript committed
  under `tests/_cross-skill/runs/changement-de-langue/<date>-<kind>.md` before
  any box is ticked.
- **AC31** — If AC27 or AC28 is still unmet when the budget in AC30 is spent,
  the box carries its stated reason in the run's `## Verification notes`, a
  successor issue is filed with all four body sections recording what the pair
  table and the rewritten example changed, and no acceptance criterion in this
  spec or in `2026-09-19-exec-document-headings-design.md` is weakened to match
  the observed behaviour.

### Repository documentation

- **AC32** — `docs/adr/0016-exec-facing-document-section-headings.md` states in
  its *Decision §4* that both locales' template spellings ship in every ZIP and
  that a document with no template block keeps every heading, carries a
  Consequences entry for the generated file, and its status line records the
  amendment and its date.
- **AC33** — `docs/AUTHORING.md`'s `## Exec-facing document headings` section
  states that the build generates the heading-pair reference from
  `skills/exec-documents.tsv`, and that a new exec-facing document therefore
  needs only its registry row; `bash scripts/tests/authoring_test.sh` passes.
- **AC34** — The "Status of AC32 and AC33 as of 2026-09-20" note in
  `2026-09-19-exec-document-headings-design.md` — which is about
  `2026-09-19-headings/AC32` and `/AC33`, not this spec's AC32 and AC33 —
  points at this spec for the resolution of both halves.
- **AC35** — `bash scripts/build.sh --check`, `./scripts/build.ps1 -Check`,
  `bash scripts/tests/build_test.sh`, `pwsh -File scripts/tests/build_test.ps1`,
  `bash scripts/tests/shared_test.sh` and `bash scripts/tests/authoring_test.sh`
  all pass.

## Deferred Items

- #42 — closed by this spec: the structural half.
- #43 — closed into this spec rather than deferred: the behaviour half. Its
  evidence is summarized under "The second failure, which is not about missing
  data" above.
- A successor issue, conditional on AC31 — filed only if the attempt budget in
  AC30 is spent with AC27 or AC28 still unmet.

Giving the six prose-described documents template blocks and registry rows was
considered and rejected as a separate design question — whether those documents
should be templated at all is not settled by this work, and no issue is filed
for it. Under AC25 a reader leaves their headings alone, which is the
conservative behaviour.

## Glossary Updates & ADRs

**Glossary:** none — the repository has no `CONTEXT.md`. The shipped
`skills/shared/<locale>/glossary.md` is an executive-facing product text, not a
domain glossary, and gains no entry: the heading-pair reference is a build
artifact, not a concept an executive encounters.

**ADRs:** no new ADR. Against the three-criteria gate, the decision to protect
a renamed heading was already made in ADR-0016; this work supplies the data
that decision assumed and adds one rule for documents with no template. Both
belong in the existing decision.

**ADR amended:** `docs/adr/0016-exec-facing-document-section-headings.md`, as
specified by AC32.

**ADR conflicts surfaced:** none. Nothing here contradicts ADR-0007 (paths),
ADR-0011 or ADR-0015 (dated claims), or ADR-0016's other five decision points.

## Config & Infrastructure Impact

| File | What changes |
| --- | --- |
| `scripts/build.sh` | `exec_doc_heading_text()`; `generate_exec_heading_pairs()` with its `die` paths; a call from `stage_skill()` |
| `scripts/build.ps1` | the same, mirrored |
| `scripts/tests/build_test.sh` | extraction cases, generated-file content, every `die` path, CRLF and nested-fence inputs, presence in every staged ZIP |
| `scripts/tests/build_test.ps1` | the same, mirrored, plus the byte-identity assertion of AC21 |
| `scripts/tests/shared_test.sh` | add `exec-document-headings` to the existing `for name in profile-pointer glossary memory-protocol` loop |
| `scripts/tests/authoring_test.sh` | unchanged in structure; must still pass against the edited `AUTHORING.md` |
| `skills/shared/fr/exec-document-headings.md` | new — the French preamble |
| `skills/shared/en/exec-document-headings.md` | new — the English preamble |
| `skills/shared/fr/memory-protocol.md` | pointer, rewritten example, both-lists offer, no-template rule |
| `skills/shared/en/memory-protocol.md` | the same |
| `tests/_cross-skill/changement-de-langue.md` | new expected-behaviour boxes and a verification-notes section for the re-run |
| `.github/workflows/ci.yml` | **no change** — its existing steps already run every test script and both `--check` twins, and the ZIP roster stays at fourteen |
| `skills/exec-documents.tsv` | **no change** — it already carries every column the generator reads |
| `.gitignore` | **no change** — the file is generated into a temporary stage directory, never into the working tree |
| `release-please-config.json`, `version.txt` | **no change** — release-please owned; nothing here touches versioning |

No container, IaC, env-config, schema or API-collection surface exists in this
repository.

## Manual Operator Steps

None. Every change lands in the diff, and the scenario dispatches are run
through the repository's own harness rather than by a human in a third-party
console.

## Documentation Updates

| Document | Required change |
| --- | --- |
| `docs/adr/0016-exec-facing-document-section-headings.md` | *Decision §4* extended; Consequences entry; status line records the amendment (AC32) |
| `docs/AUTHORING.md` | `## Exec-facing document headings` records that the heading-pair reference is generated from the registry (AC33) |
| `docs/superpowers/specs/2026-09-19-exec-document-headings-design.md` | the AC32/AC33 status note points here (AC34) |
| `CLAUDE.md` | **no change** — no new command, no new convention; the index already points at the specs directory |
| `docs/superpowers/2026-09-20-ac30-executive-added-sections.md` | **no change** — the handoff note records a question this spec now answers; it stays as the record of how it was reached |

## Implementation Plan Guidance

> **For the plan author (`superpowers:writing-plans`):**
>
> Before writing tasks, read the repo's agent index (`CLAUDE.md`/`AGENTS.md`) for architecture, commands, and conventions.
>
> The plan must include the tasks described under **Required Tasks** below, AND must apply every rule under **Per-Task Policies** to every implementation task.
>
> ---
>
> ### Required Tasks (each item produces explicit numbered tasks in the plan)
>
> 1. **Isolated workspace** — IF the session is not already isolated, add as the first task: *"Create an isolated workspace via `superpowers:using-git-worktrees`."*
> 2. **Glossary application** — IF the spec's "Glossary Updates & ADRs" section lists new or changed terms, add an early task: *"Apply terms to the repository glossary (using the existing file's format) before any code, test, issue title, or commit message references them."* Code must use the canonical terms; never the synonyms listed under `_Avoid_`.
> 3. **ADR creation** — FOR EACH ADR listed in the spec, add a task: *"Create `docs/adr/NNNN-<slug>.md` following sequential numbering (start at `0001-` if the directory is empty)."* IF the spec lists ADR conflicts surfaced, also add a task: *"Update the conflicting ADR's status (superseded / amended) and link to the new ADR."*
> 4. **Deferred-item verification** — Add a task: *"Confirm every issue referenced in the 'Deferred Items' section exists and has all four required body sections (Context, Required, Integration Points, Priority)."* Run `gh issue view <#> --json body | jq -r .body` and grep for the four headings.
> 5. **Config file tasks** — FOR EACH file listed in the spec's "Config & Infrastructure Impact" section, add one explicit task: *"Update `<path>`."*
> 6. **Manual Operator Steps** — IF the spec's "Manual Operator Steps" section is non-empty, add a task ahead of every task that depends on those values existing: *"Hand the operator the Manual Operator Steps and wait for confirmation; if a wizard-generation skill is available, generate the script first."* The agent never performs these steps itself and never substitutes a placeholder credential to unblock itself.
> 7. **Docs update tasks** — FOR EACH entry in the spec's "Documentation Updates" section, add one explicit task: *"Update `<doc-path>`."* Design content goes in the docs dir, not the agent index; the index gets at most a 1-line pointer, a ≤3-sentence area summary, or a 1-line command/env-var entry.
> 8. **Post-implementation check** — Add as the second-to-last task: *"Verify every Required Task above was actually executed — config files updated, docs written, glossary entries applied, ADRs created."* Read the diff; don't trust plan markings.
> 9. **Final build task** — Add as the last task: *"Run `bash scripts/build.sh --lang all` and fix any issues until it builds successfully."* Non-negotiable — type-checks and tests alone do not catch all build-time failures.
>
> ---
>
> ### Per-Task Policies (apply to every implementation task)
>
> These are not separate tasks; they are rules every task must follow.
>
> - **Testing (TDD)** — Follow `superpowers:test-driven-development`, using the repo's test runner and file-name conventions.
> - **Verification before completion** — Before claiming a task done, invoke `superpowers:verification-before-completion`. Do not rely on type-checks alone for UI features.
> - **Commit hygiene** — One focused commit per task, matching the commit-message convention visible in this repo's history. Commit frequently.
> - **Pre-commit verification (mandatory)** — Before EVERY `git commit`, dispatch a verification subagent that runs `bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh` from the repo root and reports `STATUS: PASS` or `STATUS: FAIL` with a terse per-issue list (no raw output). Wait for `STATUS: PASS` before committing; if FAIL, fix in the current task and re-run. Never use `git commit --no-verify`.
>
> ---
>
> ### Before finishing the branch (advisory cross-model review)
>
> After the final build passes — and before wrapping up via `superpowers:finishing-a-development-branch` — if a cross-model review helper is available (e.g. the Codex plugin's adversarial review), run it with focus: *"Judge correctness against the spec's acceptance criteria (AC1–AC35) only. Do not flag anything outside the stated criteria — no design alternatives, hardening, or scope the spec did not claim."*
>
> This **never gates a merge** — the gate stays `bash scripts/build.sh --check` plus the four test scripts and `bash scripts/build.sh --lang all`; the review only flags what deserves a second look. If no helper is available, finish the branch without it.

**Notes on the block above.** Task 1 does not apply — this work is already in an
isolated worktree. Task 2 does not apply — the repository has no `CONTEXT.md`
and this spec adds no terms. Task 3 produces no new ADR; it produces the
amendment task for ADR-0016 named under "ADR amended". The PowerShell twins
(`./scripts/build.ps1 -Check`, `pwsh -File scripts/tests/build_test.ps1`) run on
Windows CI and cannot be part of the Linux pre-commit gate; AC21 and AC35 cover
them.

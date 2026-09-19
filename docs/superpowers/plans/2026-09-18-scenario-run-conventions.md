# Scenario Run-Recording Conventions Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Write the two undocumented scenario-run conventions — the two-attempts cap (generalized beyond baselines) and the additive re-run record — into `tests/README.md`, and reconcile `docs/adr/0008-scenario-file-format.md` and `CLAUDE.md` with them.

**Architecture:** Documentation-only. Three files change: `tests/README.md` gets a rewritten attempts-cap paragraph, a new `## Recording a run` top-level section, and one added block in its format example; ADR 0008 gets a dated amendment note under **Decision**; `CLAUDE.md` gets one clause on its Layout line. No scenario file under `tests/` is touched, no script changes, no new ADR.

**Tech Stack:** Markdown. `bash scripts/build.sh --check` (mechanical gate), `bash scripts/build.sh --lang all` (build gate). `gh` CLI for issue verification. No runtime, no test framework — see **Note on TDD** below.

**Spec:** `docs/superpowers/specs/2026-09-18-scenario-run-conventions-design.md`

## Global Constraints

- **Diff allowlist (AC15, authoritative).** `git diff --name-only` against `dev` for this work must list exactly: `tests/README.md`, `docs/adr/0008-scenario-file-format.md`, `CLAUDE.md`, and `docs/superpowers/specs/2026-09-18-scenario-run-conventions-design.md` — plus this plan file, `docs/superpowers/plans/2026-09-18-scenario-run-conventions.md`. Nothing else. No file under `tests/` other than `README.md`. No new ADR file. No edit to `scripts/build.sh`, `scripts/build.ps1`, `scripts/tests/*`, `.github/workflows/*`, `version.txt`, `CHANGELOG.md`, `docs/WHATS-NEW.md`, or `docs/AUTHORING.md`.
- **Never hand-edit** `version.txt`, a `SKILL.md` version line, or the two annotated `README.md` lines. release-please owns them.
- **Three terms are fixed by `## Recording a run` and must be used consistently in it:** **attempt** (one execution of a dispatch, counting the first; capped at two per dispatch), **dispatch** (one self-contained subagent run), **sample** (N independent dispatches each held to one attempt).
- **Commits:** Conventional Commits. Use scope `tests` for `tests/README.md` and ADR 0008 (matching `docs(tests):` in recent history), bare `docs:` for `CLAUDE.md`. Never `git commit --no-verify`. Never add an AI-attribution line.
- **Branch:** work happens on `scenario-run-conventions`, cut from `dev`. PRs land on `dev`.
- **Pre-commit gate (mandatory, every task):** run `bash scripts/build.sh --check` from the repo root and confirm `STATUS: PASS` before every `git commit`.
- **Isolated workspace:** already satisfied — this work runs in the git worktree at `/home/mafavreau/DEV/.worktrees/c1d13197-0ffa-417f-8d66-4fea0e94e08e/cat-timimus`. Do **not** create another worktree, and do not `cd` to the original checkout.
- **Prose style:** match `tests/README.md`'s existing voice — bold-lead paragraphs, em-dashes, lines wrapped at ~72 columns.

**Note on TDD.** There is no runtime to test and the mechanical heading check is deferred to issue #32 (out of scope), so the Per-Task Policies' TDD rule has no test file to produce here. The per-task equivalent of "run the test" is: re-read the changed file and check the task's acceptance criteria against the text on disk, then run `bash scripts/build.sh --check`. Each task below states its criteria explicitly.

## File Structure

| File | Responsibility after this change |
| --- | --- |
| `tests/README.md` | The procedure. Owns the cap (generalized), `## Recording a run`, and the format example. All design content for this work lives here. |
| `docs/adr/0008-scenario-file-format.md` | The format decision. Gains one amendment note reconciling its "four sections" statement with the repeatable `## Verification notes — <date>` sibling. |
| `CLAUDE.md` | Agent index. Gains a one-clause pointer only — no design content. |
| `docs/superpowers/plans/2026-09-18-scenario-run-conventions.md` | This plan. |

---

### Task 1: Generalize the attempts cap in `tests/README.md`

Satisfies AC1, AC2, AC3, AC4.

**Files:**
- Modify: `tests/README.md:172-180` (the `**Two honest attempts, then stop.**` and `**When both attempts fail…**` paragraphs, inside `## Dispatching the subagents`)
- Test: none — verified by reading the file (see Step 3)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: the phrase **Two honest attempts, then stop.** as the cap's canonical name, and the term **attempt** meaning one execution of a dispatch. Task 2's `## Recording a run` cross-references this paragraph by that bold lead and by its containing section name `## Dispatching the subagents`.

- [ ] **Step 1: Read the current text to confirm the target**

```bash
sed -n '168,182p' tests/README.md
```

Expected: lines 172–180 hold, verbatim:

```markdown
**Two honest attempts, then stop.** A baseline gets at most two dispatches.
Re-rolling past that to obtain a compliant-looking result is not
permitted — it selects for the transcript you wanted rather than the one the
model produces.

**When both attempts fail, the scenario records "baseline not
established."** No expected-behavior box may be credited to the skill on
the strength of that run, and both failed attempts are written up in
`## Baseline notes` as observed.
```

If the text differs, the file has moved on since this plan was written — re-locate the paragraph by its bold lead (`grep -n 'Two honest attempts' tests/README.md`) and adapt, keeping the replacement below intact.

- [ ] **Step 2: Replace both paragraphs**

Replace the nine lines above with exactly this:

```markdown
**Two honest attempts, then stop.** Any dispatch gets at most two
attempts — a baseline and a with-skill verification alike. An *attempt* is one
execution of a dispatch, counting the first, so the ceiling is one retry. A
second attempt is warranted in exactly two cases: an isolation failure on a
baseline (the three-item list above), or a failed `## Expected behaviors` box
on a verification run. Re-rolling past that to obtain a compliant-looking
result is not permitted — it selects for the transcript you wanted rather than
the one the model produces. A verification re-roll is the more tempting of the
two, because it produces a green checklist. Both attempts' outcomes are
recorded, not only the second or the passing one:
`tests/atelier-mentor/en/tutoriel-selecteur.md` runs a verification dispatch
twice under this rule and writes up both.

**When both attempts fail on a baseline, the scenario records "baseline not
established."** No expected-behavior box may be credited to the skill on
the strength of that run, and both failed attempts are written up in
`## Baseline notes` as observed.
```

- [ ] **Step 3: Verify the acceptance criteria against the file**

```bash
sed -n '168,190p' tests/README.md
```

Check each by reading:
- **AC1** — the sentence setting the ceiling is "Any dispatch gets at most two attempts", whose subject is *any dispatch*, not a baseline. PASS only if no word restricts it to baselines.
- **AC2** — both entry conditions are named: "an isolation failure on a baseline" and "a failed `## Expected behaviors` box on a verification run".
- **AC3** — "Both attempts' outcomes are recorded, not only the second or the passing one" is present.
- **AC4** — the following paragraph reads "When both attempts fail **on a baseline**" and still ends in `## Baseline notes`.

- [ ] **Step 4: Confirm the cited file backs the claim (AC14)**

```bash
grep -n "attempt 2 of 2\|two-honest-attempts" tests/atelier-mentor/en/tutoriel-selecteur.md
```

Expected: at least one hit — the file carries `## Verification notes — 2026-08-10 second re-run (attempt 2 of 2)` (line 184 at time of writing) plus the prose naming the rule. If there is no hit, the claim is unsupported: stop and report rather than committing it.

- [ ] **Step 5: Run the mechanical check**

```bash
bash scripts/build.sh --check
```

Expected: `STATUS: PASS`.

- [ ] **Step 6: Commit**

```bash
git add tests/README.md
git commit -m "docs(tests): apply the two-attempts cap to every dispatch

The cap was written as a baseline rule but is already applied to with-skill
verification dispatches in tests/atelier-mentor/en/tutoriel-selecteur.md. A
verification re-roll is the more tempting violation, since it produces a
green checklist. States both entry conditions for a second attempt and that
both attempts are recorded; the baseline-not-established rule that follows
stays scoped to baselines."
```

---

### Task 2: Add `## Recording a run` to `tests/README.md`

Satisfies AC5, AC6, AC7, AC8, AC9, AC10.

**Files:**
- Modify: `tests/README.md` — insert a new top-level section between `## The four-step baseline/with-skill cycle` (ends around line 109) and `## Dispatching the subagents` (line 111 before Task 1; re-locate with grep)
- Test: none — verified by reading the file and by the citation sweep in Step 5

**Interfaces:**
- Consumes: Task 1's `**Two honest attempts, then stop.**` paragraph, cross-referenced by that bold lead.
- Produces: the section heading `## Recording a run` and the heading shape `## Verification notes — <date> <reason>`. Task 3 (format block) and Task 4 (ADR 0008 amendment) both point at this section by that exact name and use that exact heading shape.

- [ ] **Step 1: Locate the insertion point**

```bash
grep -n '^## ' tests/README.md | head -12
```

Expected: `## The four-step baseline/with-skill cycle` followed by `## Dispatching the subagents`. The new section goes between them — immediately after the cycle section's closing paragraph ("Cross-skill scenarios generally skip step 2 … see below.") and its blank line, immediately before `## Dispatching the subagents`.

- [ ] **Step 2: Insert the section**

Insert exactly this, followed by a blank line, before the `## Dispatching the subagents` heading:

```markdown
## Recording a run

Step 4 above says "judge and record." These four rules say what *record*
means. They exist for one reason: a run record is evidence. It is the only
trace of what an agent actually did on a given day, and a rewritten record is
evidence destroyed — `git` is the only witness, and only a reviewer acts on
it.

**Re-runs append.** When a scenario is re-run — after a fix, for a larger
sample, for any reason — the new results go in a new
`## Verification notes — <date> <short reason>` sibling section, appended
below the existing ones, oldest first. The prior `## Verification notes`
section stays exactly as written: its record of what was observed is never
rewritten to match the new run, and the only in-place changes permitted
anywhere above the new section are the verdict updates the next rule allows.
Live example: `tests/atelier-mentor/en/tutoriel-selecteur.md` carries three
such records on top of its original — `2026-08-10 re-run
(post-runbook-fix)`, `2026-08-10 second re-run (attempt 2 of 2)`, and
`2026-08-12 larger sample (issue #25)`.

**What additivity covers, and what it does not.** Split a record in two.

- The **observation** — what the agent did, quoted, and what was confirmed on
  disk — is never edited and never deleted. That holds for a superseded run
  as firmly as for a current one: a run that a later fix made obsolete is
  still what the model produced that day.
- The **verdict** is current state, and is updated in place: the
  `## Expected behaviors` boxes, the running tally, and a prior run's
  judgment when a re-run *or a later review* overturns it.

A corrected judgment is not deleted and not silently flipped. It is replaced,
in the position it already occupies, by a dated correction note stating what
the judgment originally said and why it changed — so the superseded reasoning
survives inside its own correction, rather than being dropped or left standing
as if it were still current. The new section carries the full explanation.

Live examples. Observation kept, verdict updated: commit `8239f2c` ticked
`tests/atelier-mentor/fr/tutoriel-reprise.md`'s box 4 and re-tallied the file
to 5/5 while appending its `2026-08-10 re-run` section below, leaving the
pre-fix observation untouched. The correction-note form:
`tests/atelier-mentor/en/tutoriel-reprise.md`'s "Cross-locale summary after
the fix — corrected 2026-08-10 (second review)" quotes its own earlier claim
("four for four re-runs improved"), records that `tutoriel-selecteur.md`'s EN
re-run was re-judged a continued failure on review, and restates the honest
count as 3 of 4.

**An attempt is not a dispatch in a sample.** An *attempt* is one execution of
a dispatch, counting the first, so one dispatch gets at most two attempts in
total — see **Two honest attempts, then stop.** under `## Dispatching the
subagents`. A *sample* is a different thing: N **independent** dispatches,
each held to a single attempt, where the rate across them is the
measurement. Not retrying a failed dispatch inside a sample is the point, not
laxity — re-rolling one would bias the rate toward the result you wanted.
Live examples: `tests/atelier-mentor/en/tutoriel-selecteur.md`'s
`## Verification notes — 2026-08-12 larger sample (issue #25)` records six
dispatches, one attempt each, and `tests/atelier/en/accueil-offre-tutoriel.md`
records five. Neither is a cap violation.

**Baselines differ, deliberately.** A baseline re-run is a dated paragraph
inside the single `## Baseline notes`, not a new sibling section —
`## Baseline notes` does not repeat. Live example:
`tests/atelier-mentor/en/tutoriel-declenchement.md`'s **Re-run 2026-08-12
under isolation preamble v2** paragraph, written below the v1 record it adds
to. Whether to re-run a baseline at all is case-by-case: a re-run under a new
preamble is the same measurement taken a second way, which is why
[ADR 0013](../docs/adr/0013-baseline-isolation-preamble-versioning.md) labels
preamble versions instead of replacing runs. That file's FR twin,
`tests/atelier-mentor/fr/tutoriel-declenchement.md`, was deliberately not
re-run under v2 and says so in place.

**Two files predate this convention, and stay as written.**
`tests/_cross-skill/declenchement.md` nests its runs as `### Run <date>`
subsections under one `## Verification notes`;
`tests/atelier-mentor/en/capability-question.md` records its 2026-08-10 re-run
as a bold-lead dated paragraph with no heading at all. Neither is migrated to
the shape above. Editing a record to match a later convention is the habit
this section exists to prevent — tidying a heading is the first step toward
tidying what it records.
```

- [ ] **Step 3: Verify placement**

```bash
grep -n '^## ' tests/README.md | head -12
```

Expected order: `## The four-step baseline/with-skill cycle`, then `## Recording a run`, then `## Dispatching the subagents`. That is **AC5**.

- [ ] **Step 4: Verify the acceptance criteria against the text**

Read the inserted section and check:
- **AC6** — states the appended-sibling shape, "oldest first", that a prior section's observation is never rewritten, that the only permitted in-place changes are AC7's verdict updates; cites `tests/atelier-mentor/en/tutoriel-selecteur.md` by path.
- **AC7** — all three of (a) observation never edited/deleted, (b) verdict updated in place across boxes/tally/prior judgment, including "a later review", (c) the dated correction note in position, stating what it originally said and why it changed. Cites `fr/tutoriel-reprise.md` + commit `8239f2c` for (a)+(b) and `en/tutoriel-reprise.md`'s cross-locale summary for (c).
- **AC8** — defines *attempt* as one execution counting the first (ceiling two per dispatch) and *sample* as N **independent** dispatches at one attempt each measuring a rate; cites two sample files by path and says neither is a cap violation.
- **AC9** — baseline re-run = dated paragraph inside the single `## Baseline notes`; cites `tests/atelier-mentor/en/tutoriel-declenchement.md`; says case-by-case; references ADR 0013.
- **AC10** — names `tests/_cross-skill/declenchement.md` and `tests/atelier-mentor/en/capability-question.md`, says both are left as written.

- [ ] **Step 5: Verify every citation against its file (AC14)**

Run each and confirm the expected hit. A miss means the claim is wrong — fix the prose, do not commit it.

```bash
# Three re-run records in one file, exact headings
grep -n '^## Verification notes — ' tests/atelier-mentor/en/tutoriel-selecteur.md
# Expect exactly: 2026-08-10 re-run (post-runbook-fix);
#                 2026-08-10 second re-run (attempt 2 of 2);
#                 2026-08-12 larger sample (issue #25)

# 8239f2c ticked fr/tutoriel-reprise box 4 and appended a re-run
git show 8239f2c -- tests/atelier-mentor/fr/tutoriel-reprise.md | grep -E '^[-+].*only the five remaining modules'
# Expect a "- [ ]" removal and a "- [x]" addition of that line
git show 8239f2c -- tests/atelier-mentor/fr/tutoriel-reprise.md | grep -E '^\+## Verification notes — 2026-08-10 re-run'
# Expect one hit
grep -n 'Re-tallied: \*\*5/5 ticked' tests/atelier-mentor/fr/tutoriel-reprise.md
# Expect one hit

# en/tutoriel-reprise's correction note
grep -n 'corrected 2026-08-10 (second review)' tests/atelier-mentor/en/tutoriel-reprise.md
grep -n 'four for four re-runs improved' tests/atelier-mentor/en/tutoriel-reprise.md
grep -n 'honest count is \*\*3 of 4\*\*' tests/atelier-mentor/en/tutoriel-reprise.md
# Expect one hit each

# Sample sizes
grep -n 'Six fresh' tests/atelier-mentor/en/tutoriel-selecteur.md
grep -n 'Five fresh' tests/atelier/en/accueil-offre-tutoriel.md
# Expect one hit each, both saying "one attempt each" / "one honest attempt each"

# Baseline re-run paragraph and the FR twin's deliberate non-re-run
grep -n 'Re-run 2026-08-12 under isolation preamble v2' tests/atelier-mentor/en/tutoriel-declenchement.md
grep -n 'not\*\* re-run under v2\|is \*\*not\*\* re-run' tests/atelier-mentor/fr/tutoriel-declenchement.md
# Expect one hit each

# The two predating shapes
grep -n '^### Run ' tests/_cross-skill/declenchement.md
grep -n '^\*\*2026-08-10 — re-run' tests/atelier-mentor/en/capability-question.md
# Expect hits
```

**Known correction to carry:** the spec's Decision §1b says commit `8239f2c` "flipped all five boxes" in `fr/tutoriel-reprise.md`. It flipped **one** — box 4, "Session B's recommendation names only the five remaining modules" — which brought the file's tally to 5/5; the other four were already ticked. The prose in Step 2 states the accurate version. Do not "correct" it back toward the spec's wording.

- [ ] **Step 6: Run the mechanical check**

```bash
bash scripts/build.sh --check
```

Expected: `STATUS: PASS`.

- [ ] **Step 7: Commit**

```bash
git add tests/README.md
git commit -m "docs(tests): document how a scenario run gets recorded

Six scenario files append a dated re-run section rather than overwriting the
prior record, and nothing in the repo said to. Adds \"Recording a run\" with
four rules: re-runs append; observation is permanent while the verdict is
current state and updated in place behind a dated correction note; an attempt
is not a dispatch in a sample; baselines take dated paragraphs instead. Names
the two files that predate the convention and are left as written."
```

---

### Task 3: Show the repeatable heading in the format block

Satisfies AC11.

**Files:**
- Modify: `tests/README.md` — the fenced `markdown` block under `## Scenario file format` (lines 25–55 before Tasks 1–2; re-locate with grep)
- Test: none — verified by reading the block

**Interfaces:**
- Consumes: Task 2's `## Recording a run` section name and the `## Verification notes — <date> <reason>` heading shape.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Locate the end of the format block**

```bash
grep -n '## Verification notes' tests/README.md | head -3
```

Expected: a hit inside the fenced example (followed by the "What the built, staged skill actually did…" lines and the block's closing ```` ``` ````).

- [ ] **Step 2: Append to the block**

Inside the fence, after the existing `## Verification notes` entry's description and before the closing ```` ``` ````, add:

```markdown

## Verification notes — <date> <reason>

Optional, and repeatable: one sibling section per re-run, appended below
the previous ones, oldest first. See "Recording a run" below for what may
and may not change in an earlier record.
```

The resulting tail of the fenced block reads:

```markdown
## Verification notes

What the built, staged skill actually did when run for real — quoted
evidence, file paths, on-disk confirmation, not just the dispatched agent's
self-report.

## Verification notes — <date> <reason>

Optional, and repeatable: one sibling section per re-run, appended below
the previous ones, oldest first. See "Recording a run" below for what may
and may not change in an earlier record.
```

- [ ] **Step 3: Verify AC11**

```bash
sed -n '21,70p' tests/README.md
```

Check: the fenced block shows `## Verification notes — <date> <reason>` as a sibling of `## Verification notes`, marks it repeatable, and points at `Recording a run`. Confirm the code fence is still closed and the block still opens with ```` ```markdown ````.

- [ ] **Step 4: Run the mechanical check**

```bash
bash scripts/build.sh --check
```

Expected: `STATUS: PASS`.

- [ ] **Step 5: Commit**

```bash
git add tests/README.md
git commit -m "docs(tests): show the repeatable re-run heading in the format block

The scenario format example listed four sections, so a reader who never
reached \"Recording a run\" had no reason to think a fifth heading was
legal."
```

---

### Task 4: Amend ADR 0008

Satisfies AC12. Also discharges the spec's "ADR conflicts surfaced" requirement — the conflict is resolved by amending 0008 in place, and **no new ADR file is created**.

**Files:**
- Modify: `docs/adr/0008-scenario-file-format.md` — under `## Decision`, after the last bullet (`- **`Verification notes`** records the with-skill run.`, line 57) and before the `tests/_cross-skill/` paragraph (line 59)
- Test: none — verified by reading the file

**Interfaces:**
- Consumes: Task 2's `## Recording a run` section name and heading shape.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Read the target**

```bash
sed -n '44,62p' docs/adr/0008-scenario-file-format.md
```

Expected: the five-bullet list ending in "**`Verification notes`** records the with-skill run.", then a blank line, then the `tests/_cross-skill/` paragraph.

- [ ] **Step 2: Insert the amendment**

Between the last bullet and the `tests/_cross-skill/` paragraph, insert:

```markdown
**Amended 2026-09-18.** Those four sections are the minimum, not a ceiling.
`## Verification notes` may repeat with a dated suffix —
`## Verification notes — <date> <reason>` — one sibling section per re-run,
appended oldest first. `## Baseline notes` does **not** repeat; a baseline
re-run is a dated paragraph inside the single section. Both shapes follow
from the same fact: a run record is evidence, and a superseded record is
still what was observed, so a re-run adds to the file instead of replacing
part of it. `tests/README.md`'s `## Recording a run` carries the full
conventions, including what a re-run may update in place.
```

- [ ] **Step 3: Verify AC12**

```bash
sed -n '44,72p' docs/adr/0008-scenario-file-format.md
```

Check: the note is under **Decision**; it is dated `2026-09-18`; it states that `## Verification notes` may repeat with a dated suffix, that `## Baseline notes` does not repeat and takes dated paragraphs, and gives the evidence reason.

- [ ] **Step 4: Confirm no new ADR file was created**

```bash
git status --porcelain docs/adr/
```

Expected: exactly one line, ` M docs/adr/0008-scenario-file-format.md`. Any `??` line under `docs/adr/` violates AC15 — delete it.

- [ ] **Step 5: Run the mechanical check**

```bash
bash scripts/build.sh --check
```

Expected: `STATUS: PASS`.

- [ ] **Step 6: Commit**

```bash
git add docs/adr/0008-scenario-file-format.md
git commit -m "docs(tests): amend ADR 0008 for the repeatable verification section

ADR 0008 fixes a scenario at four sections, which the repo stopped doing the
first time a scenario was re-run. Records the asymmetry — verification
repeats with a dated suffix, baseline takes dated paragraphs — and the reason
both take the shape they do."
```

---

### Task 5: Point `CLAUDE.md` at `tests/README.md`

Satisfies AC13.

**Files:**
- Modify: `CLAUDE.md:49-53` (the **Layout** paragraph)
- Test: none — verified by reading the file and counting lines

**Interfaces:**
- Consumes: nothing. Produces: nothing.

- [ ] **Step 1: Read the target**

```bash
sed -n '47,54p' CLAUDE.md
```

Expected:

```markdown
## Layout

Skills live in `skills/<canonical-fr-name>/<locale>/`; canonical cross-skill
texts in `skills/shared/<locale>/`; exec-voice scenarios in
`tests/<canonical-fr-name>/<locale>/` (plus `tests/_cross-skill/` for
system-level scenarios not tied to one skill). Authoring standards:
`docs/AUTHORING.md`.
```

- [ ] **Step 2: Record the line count before the edit**

```bash
wc -l < CLAUDE.md
```

Note the number — Step 4 checks the file grew by at most one line.

- [ ] **Step 3: Rewrite the paragraph**

Replace the five prose lines with:

```markdown
Skills live in `skills/<canonical-fr-name>/<locale>/`; canonical cross-skill
texts in `skills/shared/<locale>/`; exec-voice scenarios in
`tests/<canonical-fr-name>/<locale>/` (plus `tests/_cross-skill/` for
system-level scenarios not tied to one skill; how a scenario run is recorded:
`tests/README.md`). Authoring standards: `docs/AUTHORING.md`.
```

That is four prose lines replacing five, so the file gets no longer. Do not add a separate sentence, a bullet, or any design content — AC13 caps this at one clause.

- [ ] **Step 4: Verify AC13**

```bash
wc -l < CLAUDE.md
sed -n '47,53p' CLAUDE.md
```

Check: the line count is at most the pre-edit number + 1; the Layout paragraph carries one clause pointing at `tests/README.md` for run-recording conventions; nothing else in `CLAUDE.md` changed (`git diff CLAUDE.md` shows one hunk).

- [ ] **Step 5: Run the mechanical check**

```bash
bash scripts/build.sh --check
```

Expected: `STATUS: PASS`.

- [ ] **Step 6: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: point the agent index at the run-recording conventions"
```

---

### Task 6: Verify the deferred issue and the config-impact no-ops

Satisfies the spec's Required Tasks 4 (deferred-item verification) and 5 (config file tasks — every entry in **Config & Infrastructure Impact** is marked "None" except `CLAUDE.md`, done in Task 5, so this task's job is to *confirm* they are untouched, which AC15 requires).

**Files:**
- Modify: none expected. If issue #32 is missing a required section, fix it on GitHub with `gh`, not in the repo.
- Test: none — this task is verification only.

**Interfaces:**
- Consumes: the working tree after Tasks 1–5.
- Produces: a go/no-go for Task 7.

- [ ] **Step 1: Confirm issue #32 exists and carries all four body sections**

```bash
gh issue view 32 --json body --jq .body | grep -E '^## (Context|Required|Integration Points|Priority)$'
```

Expected: four lines — `## Context`, `## Required`, `## Integration Points`, `## Priority`. If any is missing, add it to the issue body with `gh issue edit 32 --body-file <file>`; do not proceed with a partial issue.

- [ ] **Step 2: Confirm the issue is the one the spec cites**

```bash
gh issue view 32 --json title,state --jq '.title + " | " + .state'
```

Expected: a title about a build check for scenario re-run headings, state `OPEN`. The spec's **Deferred Items** entry must match this issue, not a different one.

- [ ] **Step 3: Confirm every "None" row in Config & Infrastructure Impact is actually untouched**

```bash
git status --porcelain -- \
  .github/workflows/ci.yml \
  .github/workflows/release-please.yml \
  scripts/build.sh scripts/build.ps1 \
  scripts/tests/ \
  version.txt CHANGELOG.md docs/WHATS-NEW.md docs/AUTHORING.md
```

Expected: **no output**. Any line here is an AC15 violation — revert that path with `git checkout -- <path>` (for an unstaged change) and re-check.

- [ ] **Step 4: Confirm no scenario file was touched**

```bash
git status --porcelain -- tests/ | grep -v '^.. tests/README.md$'
```

Expected: **no output**. A hit means a checkbox, tally, or run record was edited — forbidden by the spec's non-goals and by AC15. Revert it.

- [ ] **Step 5: No commit**

This task changes nothing in the repo. If Step 1 required a `gh issue edit`, say so in the task report; there is nothing to commit.

---

### Task 7: Post-implementation audit against the diff

Satisfies AC14 (re-verified at commit time), AC15, and the spec's Required Task 8. Read the diff; do not trust this plan's checkboxes.

**Files:**
- Modify: whatever the audit finds wrong, in the file that owns it.
- Test: none — this task is verification only.

**Interfaces:**
- Consumes: the committed state after Tasks 1–6.
- Produces: a clean diff for Task 8.

- [ ] **Step 1: Check the diff allowlist (AC15)**

```bash
git diff --name-only dev...HEAD
```

Expected exactly these five paths, in any order:

```
CLAUDE.md
docs/adr/0008-scenario-file-format.md
docs/superpowers/plans/2026-09-18-scenario-run-conventions.md
docs/superpowers/specs/2026-09-18-scenario-run-conventions-design.md
tests/README.md
```

Any other path fails AC15. Also confirm nothing is left uncommitted:

```bash
git status --porcelain
```

Expected: no output.

- [ ] **Step 2: Re-read the full diff of the three changed docs**

```bash
git diff dev...HEAD -- tests/README.md docs/adr/0008-scenario-file-format.md CLAUDE.md
```

Walk AC1–AC13 against what the diff actually shows, not against this plan's steps. For each, note PASS or the exact line that fails.

- [ ] **Step 3: Re-verify every cited path exists (AC14)**

```bash
for f in \
  tests/atelier-mentor/en/tutoriel-selecteur.md \
  tests/atelier-mentor/fr/tutoriel-reprise.md \
  tests/atelier-mentor/en/tutoriel-reprise.md \
  tests/atelier-mentor/en/tutoriel-declenchement.md \
  tests/atelier-mentor/fr/tutoriel-declenchement.md \
  tests/atelier/en/accueil-offre-tutoriel.md \
  tests/_cross-skill/declenchement.md \
  tests/atelier-mentor/en/capability-question.md \
  docs/adr/0013-baseline-isolation-preamble-versioning.md ; do
  test -f "$f" && echo "OK   $f" || echo "MISS $f"
done
git cat-file -e 8239f2c^{commit} && echo "OK   commit 8239f2c"
```

Expected: `OK` on every line. A `MISS` means the prose cites something that does not exist — fix the prose.

- [ ] **Step 4: Re-run the citation sweep from Task 2 Step 5**

Run that block again against the committed state. Every claim attributed to a cited file must still hold at commit time (AC14) — line numbers gathered during design can shift, so grep by content, never by line number.

- [ ] **Step 5: Confirm the ADR link resolves from `tests/README.md`**

```bash
test -f "$(dirname tests/README.md)/../docs/adr/0013-baseline-isolation-preamble-versioning.md" \
  && echo "OK relative ADR 0013 link" || echo "BROKEN"
```

Expected: `OK relative ADR 0013 link` — the `## Recording a run` section links `../docs/adr/0013-…` from inside `tests/`, matching the existing link at the end of "Why there are two preambles".

- [ ] **Step 6: Audit the Required Tasks**

Confirm from the diff, not from memory:
- Isolated workspace — already a worktree; no new one created. `git rev-parse --show-toplevel` ends in `.worktrees/…/cat-timimus`.
- Glossary — dropped by the spec (no `CONTEXT.md` in this repo). The three fixed terms are defined and used consistently inside `## Recording a run`; confirm with:

```bash
awk '/^## Recording a run$/,/^## Dispatching the subagents$/' tests/README.md \
  | grep -cE '\*attempt\*|\*sample\*|dispatch'
```

  Expected: a non-zero count, and reading the section confirms *attempt* and *sample* are each italicized where defined, and *dispatch* is used for one self-contained subagent run throughout.
- ADR — 0008 amended, no new ADR file (Task 4 Step 4).
- Deferred item — issue #32 verified (Task 6).
- Config files — all "None" rows untouched (Task 6 Step 3); `CLAUDE.md` updated (Task 5).
- Manual Operator Steps — none in the spec; nothing to hand off.
- Docs updates — all three rows of **Documentation Updates** land in the diff.

- [ ] **Step 7: Commit only if the audit changed something**

If Steps 2–5 required a prose fix:

```bash
bash scripts/build.sh --check
git add -A
git commit -m "docs(tests): correct a citation in the run-recording conventions"
```

If nothing changed, there is nothing to commit — say so and move to Task 8.

---

### Task 8: Final build

Satisfies AC16 and AC17. Non-negotiable — the mechanical check alone does not catch build-time failures.

**Files:**
- Modify: whatever the build reports broken, if anything.
- Test: the build itself.

**Interfaces:**
- Consumes: the audited state after Task 7. Produces: the merge gate result.

- [ ] **Step 1: Run the mechanical check (AC16)**

```bash
bash scripts/build.sh --check
```

Expected: `STATUS: PASS`. If FAIL, fix the reported issues here and re-run until PASS.

- [ ] **Step 2: Run the full build (AC17)**

```bash
bash scripts/build.sh --lang all
```

Expected: completes without error.

- [ ] **Step 3: Confirm the ZIPs landed**

```bash
ls -1 dist/*.zip | wc -l
ls -1 dist/*.zip | head
```

Expected: a non-zero count, one ZIP per skill per locale. If `dist/` is empty or the command errors, the build did not actually succeed — fix and re-run Step 2.

- [ ] **Step 4: Confirm the build left the working tree clean**

```bash
git status --porcelain
```

Expected: no output. `dist/` is ignored; if it shows up, do **not** commit it — check `.gitignore` rather than adding the artifacts.

- [ ] **Step 5: Commit only if a fix was needed**

If Steps 1–2 required a change:

```bash
git add -A
git commit -m "docs(tests): fix a build-check failure in the run-recording conventions"
```

Otherwise nothing to commit.

- [ ] **Step 6: Advisory cross-model review (optional, never a gate)**

If the Codex plugin's adversarial review is available, run it with this focus:

> Judge correctness against the spec's acceptance criteria AC1–AC17 only
> (`docs/superpowers/specs/2026-09-18-scenario-run-conventions-design.md`).
> Do not flag anything outside the stated criteria — no design alternatives,
> no hardening, no scope the spec did not claim.

The merge gate stays `bash scripts/build.sh --check` plus
`bash scripts/build.sh --lang all`. If no helper is available, skip this step
and finish the branch via `superpowers:finishing-a-development-branch`.

---

## Acceptance criteria → task map

| AC | Task |
| --- | --- |
| AC1–AC4 | Task 1 |
| AC5–AC10 | Task 2 |
| AC11 | Task 3 |
| AC12 | Task 4 |
| AC13 | Task 5 |
| AC14 | Task 2 Step 5, re-verified in Task 7 Steps 3–4 |
| AC15 | Task 6 Steps 3–4, Task 7 Step 1 |
| AC16 | every task's pre-commit gate; confirmed in Task 8 Step 1 |
| AC17 | Task 8 Step 2 |

## Known spec correction

The spec's Decision §1b claims commit `8239f2c` "flipped all five boxes" in
`tests/atelier-mentor/fr/tutoriel-reprise.md`. Checked against the commit: it
flipped **one** box — box 4, "Session B's recommendation names only the five
remaining modules" — and that brought the file's tally to 5/5. The other four
were already ticked. Task 2's prose states the accurate version, which is what
AC14 requires; the spec sentence is the thing that is wrong, not the file.

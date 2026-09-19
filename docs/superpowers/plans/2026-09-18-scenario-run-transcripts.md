# Scenario Run Transcripts Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make every scenario dispatch leave a transcript file committed to the repo, by writing the convention into `tests/README.md` and recording the retention decision in a new ADR 0014.

**Architecture:** Documentation-only. Three files change: `tests/README.md` gains the transcript directories in its `## Layout` listing, a fifth rule (`### Every dispatch leaves a transcript`) at the end of `## Recording a run`, a clause in step 4 of the four-step cycle, and a closing paragraph in `## Dispatching the subagents`; `docs/adr/0014-scenario-run-transcripts.md` is new and carries the retention decision plus the rejected alternative; `docs/adr/0008-scenario-file-format.md` gains one pointer line under **Decision**. No scenario file, no script, and no `CLAUDE.md` line is touched. No transcript is written by this work — it writes the convention, not the corpus.

**Tech Stack:** Markdown. `bash scripts/build.sh --check` (mechanical gate), `bash scripts/build.sh --lang all` (build gate), `gh` CLI for issue verification, `git diff --name-only` for the diff allowlist. No runtime and no test framework — see **Note on TDD** below.

**Spec:** `docs/superpowers/specs/2026-09-18-scenario-run-transcripts-design.md`

## Global Constraints

- **Diff allowlist (AC21, authoritative over every other guidance in the spec).** `git diff --name-only dev...HEAD` for this work must list exactly four files plus this plan: `tests/README.md`, `docs/adr/0014-scenario-run-transcripts.md`, `docs/adr/0008-scenario-file-format.md`, `docs/superpowers/specs/2026-09-18-scenario-run-transcripts-design.md`, and `docs/superpowers/plans/2026-09-18-scenario-run-transcripts.md`. Nothing else. No file under `tests/` other than `README.md`. No edit to `scripts/build.sh`, `scripts/build.ps1`, `scripts/tests/*`, `.github/workflows/*`, `.gitignore`, `version.txt`, `CHANGELOG.md`, `docs/WHATS-NEW.md`, or `CLAUDE.md`.
- **`CLAUDE.md` is not modified (AC19).** `CLAUDE.md:52-53` already carries "how a scenario run is recorded: `tests/README.md`". A second pointer would grow the index for nothing.
- **Never hand-edit** `version.txt`, a `SKILL.md` version line, or the two annotated `README.md` lines. release-please owns them.
- **Four terms are fixed and must be used consistently in the new prose:** **dispatch** (one self-contained subagent run), **attempt** (one execution of a dispatch, counting the first; capped at two per dispatch), **sample** (N independent dispatches each held to one attempt), **transcript** (the committed file holding one run's prompts, replies, sandbox listings, and written-file contents — one per verification section, and one per baseline run including each dated re-run paragraph).
- **Exact values, copied verbatim from the spec, that must appear in the prose:** the cutoff date **2026-09-18**; the file-capture ceiling **16384** bytes, written as that numeral; the two path shapes `tests/<skill>/<locale>/runs/<scenario-basename>/<date>-<kind>.md` and `tests/_cross-skill/runs/<scenario-basename>/<date>-<kind>.md`; the `<kind>` values `baseline` and `verification`; the literal line `no transcript — <reason>`; the attempt labels `attempt 1 of 2` / `attempt 2 of 2`.
- **Link style.** From `tests/README.md`, an ADR is linked as `[ADR 0013](../docs/adr/0013-baseline-isolation-preamble-versioning.md)` — this is the existing form at `tests/README.md:193`. Between ADR files, the existing form is a bare sibling path: `[ADR-0010](0010-dev-default-main-release-branch.md)` (`docs/adr/0009-release-automation-and-changelog-split.md:108`).
- **Commits:** Conventional Commits, scope `tests` (`docs(tests): …`), matching recent history. Never `git commit --no-verify`. Never add an AI-attribution line, a "Generated with" line, or a `Co-Authored-By` trailer.
- **Branch:** work continues on the current branch, `deep-brainstorm-linked-github`, cut from `dev`. Run `git branch --show-current` as its own command before any commit to confirm. PRs land on `dev`.
- **Isolated workspace:** already satisfied — this work runs in the git worktree at `/home/mafavreau/DEV/.worktrees/c1d13197-0ffa-417f-8d66-4fea0e94e08e/sassy-clarinet`. Do **not** create another worktree, and do not `cd` to the original checkout.
- **Pre-commit gate (mandatory, every task):** run `bash scripts/build.sh --check` from the repo root and confirm `STATUS: PASS` before every `git commit`. If FAIL, fix it inside the current task and re-run.
- **Citation discipline (AC20):** every file path, line number, check name, and commit hash that lands in the new prose must be re-verified against the working tree at the moment of the commit, not trusted from this plan. Line numbers gathered while this plan was written can shift as earlier tasks edit `tests/README.md`. Each task carries its own verification step; do not skip it because the plan already states the value.
- **Prose style:** match `tests/README.md`'s existing voice — bold-lead paragraphs, em-dashes, lines wrapped at roughly 72 columns. Match `docs/adr/`'s existing voice for the ADR — `# NNNN — Title`, `**Status:** Accepted — <date>`, then `## Context` / `## Decision` / `## Consequences`.
- **Do not cite a scenario-file count in the prose.** The spec's Scope paragraph says 36; `/usr/bin/find tests -name '*.md' -not -name 'README.md' | wc -l` currently reports 35. No sentence in this work needs the number, and none of the drafted text below uses one. Do not add one.

**Note on TDD.** There is no runtime to test here and the mechanical transcript-link check is deferred to issue #34 (out of scope), so the Per-Task Policies' TDD rule has no test file to produce. The per-task equivalent of red-green is spelled out in every task below: a `grep` that must report *absent* before the edit and *present* after it, then `bash scripts/build.sh --check`. Each task states the exact commands and the exact expected output.

## File Structure

| File | Responsibility after this change |
| --- | --- |
| `tests/README.md` | The procedure. Owns the transcript convention in full — path shape, contents, ceiling, retention, linking rule, cutoff — plus the `## Layout` listing, step 4 of the cycle, and the dispatch-is-finished paragraph. All procedural content for this work lives here. |
| `docs/adr/0014-scenario-run-transcripts.md` | New. The retention decision (committed, written once, never pruned), the rejected alternative (accept the excerpts as the permanent record), and why the three-criteria gate is met. No procedure — that is the README's. |
| `docs/adr/0008-scenario-file-format.md` | The scenario file's shape. Gains one pointer line under **Decision** saying what a run leaves on disk is ADR 0014's question, not this ADR's. |
| `docs/superpowers/plans/2026-09-18-scenario-run-transcripts.md` | This plan. |

---

### Task 1: Show the transcript directories in `## Layout`

Satisfies AC15.

**Files:**
- Modify: `tests/README.md` — the fenced block under `## Layout` (currently lines 12–15) and the paragraph below it (currently lines 17–19)
- Test: none — verified by `grep` (Steps 2 and 4)

**Interfaces:**
- Consumes: nothing from earlier tasks.
- Produces: the term `<scenario-basename>`'s plain-English gloss ("the scenario file's name without `.md`") and the two path shapes, which Task 2's rule restates in full. `## Scenario file format` is **not** touched by this task or any other — it is a Markdown template of a scenario file's headings, and AC15 requires it stay as written.

- [ ] **Step 1: Read the current block to confirm the target**

```bash
sed -n '10,20p' tests/README.md
```

Expected, verbatim:

```markdown
## Layout

```
tests/<canonical-skill-name>/<locale>/<scenario>.md   — per-skill scenarios
tests/_cross-skill/<scenario>.md                       — system-level scenarios
```

`<canonical-skill-name>` is the skill's folder name under `skills/` (e.g.
`atelier-reunions`, not its English `name:` frontmatter value
`atelier-meetings`). `<locale>` is `fr` or `en`.
```

- [ ] **Step 2: Confirm the new content is absent (the failing check)**

```bash
grep -c 'runs/<scenario>' tests/README.md
```

Expected: `0`.

- [ ] **Step 3: Add the transcript paths to the listing and gloss them**

Replace the fenced listing's two lines with four, and append two sentences to the paragraph below it. Use an exact-match edit on this `old_string`:

```
tests/<canonical-skill-name>/<locale>/<scenario>.md   — per-skill scenarios
tests/_cross-skill/<scenario>.md                       — system-level scenarios
```

`new_string`:

```
tests/<canonical-skill-name>/<locale>/<scenario>.md   — per-skill scenarios
tests/<canonical-skill-name>/<locale>/runs/<scenario>/<date>-<kind>.md
                                                     — that scenario's run transcripts
tests/_cross-skill/<scenario>.md                     — system-level scenarios
tests/_cross-skill/runs/<scenario>/<date>-<kind>.md  — their run transcripts
```

Then extend the paragraph below. `old_string`:

```
`atelier-meetings`). `<locale>` is `fr` or `en`.
```

`new_string`:

```
`atelier-meetings`). `<locale>` is `fr` or `en`. `<scenario>` inside a
`runs/` path is the scenario file's own name without `.md`, and
`tests/_cross-skill/` holds its scenario files directly, with no locale
directories, so its transcripts sit one level shallower. What a transcript
is, what goes in one, and when a run may have none: see "Recording a run"
below.
```

- [ ] **Step 4: Confirm the new content is present (the passing check)**

```bash
grep -n 'runs/<scenario>/<date>-<kind>.md' tests/README.md
grep -n "one level shallower" tests/README.md
sed -n '/^## Scenario file format/,/^## The four-step/p' tests/README.md | grep -c 'runs/'
```

Expected: the first two commands each print at least one line (the first prints two — the per-skill and the `_cross-skill` shape); the third prints `0`, confirming `## Scenario file format` was not touched.

- [ ] **Step 5: Run the mechanical gate**

```bash
bash scripts/build.sh --check
```

Expected: output ends with `STATUS: PASS`.

- [ ] **Step 6: Commit**

```bash
git branch --show-current   # expect: deep-brainstorm-linked-github
git add tests/README.md
git commit -m "docs(tests): show the run-transcript directories in the layout"
git show HEAD --stat
```

Expected: `git show HEAD --stat` lists `tests/README.md` and nothing else.

---

### Task 2: Write the transcript rule into `## Recording a run`

Satisfies AC1, AC2, AC3, AC4, AC5, AC6, AC7, AC8, AC9, AC10, AC24, AC25, AC26.

**Files:**
- Modify: `tests/README.md` — the `## Recording a run` opening paragraph (currently lines 119–123), and an insertion at the end of that section, after the paragraph ending `tidying what it records.` and before `## Dispatching the subagents`
- Test: none — verified by `grep` (Steps 2 and 5)

**Interfaces:**
- Consumes: the path shapes and the `<scenario-basename>` gloss introduced in Task 1.
- Produces: the `### Every dispatch leaves a transcript` heading, which Task 3 appends to, Task 4 cross-references by name from step 4 of the cycle and from `## Dispatching the subagents`, and Task 5's ADR 0014 points at as the home of the full convention. Also produces the literal token `no transcript — <reason>`, used verbatim by Tasks 3 and 4.

- [ ] **Step 1: Re-verify every citation this task's prose makes**

The drafted text names two build-script check functions and asserts both scans are non-recursive. Confirm all of it against the working tree before writing it — line numbers shift, so check the content, not the numbers:

```bash
grep -n 'check_scenarios()\|check_triggers()' scripts/build.sh
grep -n 'maxdepth 1' scripts/build.sh
grep -n 'Get-ChildItem' scripts/build.ps1 | grep -v Recurse
grep -rn 'Cedarline Outfitters' tests/ | head -2
grep -rn 'Lanternes Boréales' tests/ | head -2
git cat-file -t 8239f2c && git cat-file -t 144c308
```

Expected: `check_scenarios` and `check_triggers` both exist in `scripts/build.sh`; both `find` invocations inside them carry `-maxdepth 1`; no `Get-ChildItem` in `scripts/build.ps1`'s scenario or trigger scan carries `-Recurse`; both seed names appear in the corpus; both commit hashes resolve to `commit`. If any check disagrees, fix the drafted sentence to match the tree before writing it — the tree wins.

- [ ] **Step 2: Confirm the new content is absent (the failing check)**

```bash
grep -c 'Every dispatch leaves a transcript' tests/README.md
```

Expected: `0`.

- [ ] **Step 3: Update the section's opening line from four rules to five**

`old_string`:

```
Step 4 above says "judge and record." These four rules say what *record*
means. They exist for one reason: a run record is evidence.
```

`new_string`:

```
Step 4 above says "judge and record." These five rules say what *record*
means — the fifth, **Every dispatch leaves a transcript**, runs long enough
to carry its own subsection at the end. They exist for one reason: a run
record is evidence.
```

- [ ] **Step 4: Append the transcript subsection at the end of `## Recording a run`**

Insert the following immediately after the paragraph ending `tidying what it records.` and immediately before the `## Dispatching the subagents` heading. Write it verbatim:

````markdown
### Every dispatch leaves a transcript

A run record quotes the lines a verdict rests on. The **transcript** is the
run itself — the prompts, the replies, the sandbox, and anything the dispatch
wrote — saved as a file and committed to the repo beside the scenario it
belongs to. One file per run:

```
tests/<skill>/<locale>/runs/<scenario-basename>/<date>-<kind>.md
tests/_cross-skill/runs/<scenario-basename>/<date>-<kind>.md
```

`<scenario-basename>` is the scenario file's name without `.md`.
`tests/_cross-skill/` holds its scenario files directly, with no locale
directories, so its transcripts follow the same shape one level shallower.
`<kind>` is `baseline` or `verification`, optionally followed by a short
reason slug matching the run section's own reason. Concrete, both shapes:

```
tests/atelier/en/runs/accueil-offre-tutoriel/2026-08-10-baseline.md
tests/atelier-mentor/en/runs/tutoriel-selecteur/2026-08-12-verification-larger-sample.md
tests/_cross-skill/runs/declenchement/2026-08-10-verification.md
```

The per-scenario level exists because a single locale directory can hold six
scenarios, several with more than one run; flat naming there sorts badly and
gets long.

**`runs/` is a subdirectory, and that is load-bearing.** Both scans that read
this tree are non-recursive: `check_scenarios` — the build script's AC15
coverage check — and `check_triggers` (its AC6 check) in `scripts/build.sh`
each pass `-maxdepth 1` to `find`, and their PowerShell twins call
`Get-ChildItem` without `-Recurse`. A transcript saved as a sibling `.md`
next to a scenario file would therefore be counted as a scenario, and a
directory could pass "has a scenario" on transcripts alone. Inside `runs/`,
transcripts are invisible to both. (`AC15` and `AC6` here are the build
script's own check names, not an acceptance criterion of any spec.)

**The unit is one run, not one section.** One file per `## Verification
notes` and one per `## Verification notes — <date> <reason>` sibling, and one
per baseline run — including each dated re-run paragraph appended inside the
single `## Baseline notes`, which does not repeat. That paragraph gets its own
`<date>-baseline.md` alongside the earlier baseline's transcript rather than
editing it, so the rule that a prior record is never rewritten covers
transcripts without needing new wording.

**What a transcript contains.** A header naming the scenario file's path, the
date, the kind, the isolation preamble version (baselines only, per
[ADR 0013](../docs/adr/0013-baseline-isolation-preamble-versioning.md)), and
the agent type and model dispatched. Then one block per dispatch, labeled
exactly as the run section labels that dispatch (`## Dispatch A — "full"`),
carrying four things:

1. **The prompt, verbatim** — the full scripted conversation as handed to the
   agent, including the isolation preamble for a baseline. A reply without the
   prompt that produced it cannot be judged.
2. **The reply, verbatim and complete** — not excerpted.
3. **The sandbox after the run** — the `find` listing, or an explicit
   "no sandbox" for a Desktop-chat dispatch, which has none.
4. **Every file the dispatch created or modified** — pasted in full when the
   file is smaller than 16384 bytes. A file of 16384 bytes or more gets its
   path, its byte count, its `md5sum`, and the excerpt the verdict rests on.

Both attempts of a re-attempted dispatch appear, labeled `attempt 1 of 2` and
`attempt 2 of 2` — the same cap and the same both-outcomes rule as
**Two honest attempts, then stop.** under `## Dispatching the subagents`.

**A transcript is written once and never edited afterward, and transcripts are
never pruned.** This is the observation half of the split above, applied to a
separate file: the observation is never edited or deleted, and the verdict
lives in the scenario file, where it can be corrected in place. The retention
decision and the alternative that was rejected are in
[ADR 0014](../docs/adr/0014-scenario-run-transcripts.md).

**Sandbox seeds are invented.** Seed a sandbox with fictional companies, as
the corpus already does — Cedarline Outfitters, Lanternes Boréales. This was
a habit while the sandboxes were disposable; committing transcripts puts
whatever seeded them into the repo, which makes it a rule.

**What a transcript does not buy.** It is saved by the same author who writes
the verdict, so it does not prove the run happened — nothing in this
procedure does, and the transcript should not be described as if it did. What
it buys is narrower and worth naming precisely: a second reader gets the full
context around a quoted excerpt and can judge whether the quote was
representative, and a later review has something to re-judge against. This
repo does re-judge verdicts on review — commits `8239f2c` and `144c308`
above are both that — and until the cutoff below, those reviews had only the
author's chosen quotes to work from.
````

- [ ] **Step 5: Confirm the new content is present (the passing check)**

```bash
grep -n '^### Every dispatch leaves a transcript' tests/README.md
grep -c '16384' tests/README.md                      # expect 2
grep -c 'attempt 1 of 2' tests/README.md             # expect at least 1
grep -n 'These five rules' tests/README.md
grep -n 'Cedarline Outfitters' tests/README.md
grep -n 'does not prove the run happened' tests/README.md
awk '/^### Every dispatch leaves a transcript/,/^## Dispatching the subagents/' tests/README.md | grep -c 'check_scenarios'
```

Expected: every `grep -n` prints a line; `16384` appears twice (the "smaller than" and the "of … or more" halves); the `awk` pipeline prints at least `1`. Then read the whole subsection once, top to bottom, against AC1–AC10 and AC24–AC26 in the spec and confirm each is stated.

- [ ] **Step 6: Run the mechanical gate**

```bash
bash scripts/build.sh --check
```

Expected: output ends with `STATUS: PASS`.

- [ ] **Step 7: Commit**

```bash
git branch --show-current   # expect: deep-brainstorm-linked-github
git add tests/README.md
git commit -m "docs(tests): require a committed transcript for every dispatch"
git show HEAD --stat
```

Expected: `tests/README.md` only.

---

### Task 3: Add the linking rule, the cutoff, and the quoting sentence

Satisfies AC11, AC12, AC16.

**Files:**
- Modify: `tests/README.md` — append three paragraphs at the end of the `### Every dispatch leaves a transcript` subsection created in Task 2, still before `## Dispatching the subagents`
- Test: none — verified by `grep` (Steps 1 and 3)

**Interfaces:**
- Consumes: the `### Every dispatch leaves a transcript` heading and the literal `no transcript — <reason>` token from Task 2.
- Produces: the cutoff date `2026-09-18` as prose, and the `no transcript — <reason>` line as the named fallback, both of which Task 4 refers to from step 4 of the cycle and from `## Dispatching the subagents`, and Task 5's ADR 0014 restates as the no-backfill rule.

- [ ] **Step 1: Confirm the new content is absent (the failing check)**

```bash
grep -c 'no transcript — <reason>' tests/README.md
grep -c '2026-09-18' tests/README.md
```

Expected: both print `0`.

- [ ] **Step 2: Append the three paragraphs**

Insert verbatim, immediately after the paragraph ending `author's chosen quotes to work from.` and immediately before the `## Dispatching the subagents` heading:

```markdown
**Each run's record opens by pointing at its transcript.** A
`## Verification notes` sibling opens, on its first line, with a link to its
transcript file — or with `no transcript — <reason>`. A baseline re-run does
the same on the first line of its dated paragraph inside the existing
`## Baseline notes`, so that no earlier record is relabeled to carry a line
its own run never had. A run whose output was lost is recorded that way
rather than discarded: making a transcript a hard validity requirement would
create pressure to re-roll a dispatch until the paperwork was clean, which is
precisely the failure **Two honest attempts, then stop.** exists to resist.

**The cutoff is 2026-09-18.** Runs recorded on or after that date carry a
transcript. Runs recorded before it do not — their quoted excerpts are their
only record — and no existing scenario file is relabeled to say so. That is
the shape
[ADR 0013](../docs/adr/0013-baseline-isolation-preamble-versioning.md) used
for preamble v1/v2, and it is what this section's own rule about never tidying
a record to match a later convention requires. Nothing can be backfilled in
any case: every pre-cutoff run's sandbox was under `/tmp/` and its transcript
exists nowhere.

**Quoting is unchanged.** A ticked box still names the line that earned it.
With a transcript alongside it, a quote stops being the evidence and becomes a
citation into it — which is exactly what makes a quote checkable for whether
it was representative.
```

- [ ] **Step 3: Confirm the new content is present (the passing check)**

```bash
grep -n 'no transcript — <reason>' tests/README.md
grep -n 'The cutoff is 2026-09-18' tests/README.md
grep -n 'Quoting is unchanged' tests/README.md
git diff --name-only
```

Expected: the three `grep`s each print a line; `git diff --name-only` prints `tests/README.md` and nothing else.

- [ ] **Step 4: Verify the `/tmp/` claim the cutoff paragraph makes**

```bash
grep -rhoE '/tmp/[A-Za-z0-9._-]+' tests/ | sed -E 's#(/tmp/[^/]+).*#\1#' | sort -u | wc -l
```

Expected: a non-zero count (48 at the time this plan was written). The prose claims only that pre-cutoff sandboxes were under `/tmp/` and are gone, not a specific number — if the count is zero, the claim is wrong and must be rewritten.

- [ ] **Step 5: Run the mechanical gate**

```bash
bash scripts/build.sh --check
```

Expected: output ends with `STATUS: PASS`.

- [ ] **Step 6: Commit**

```bash
git branch --show-current   # expect: deep-brainstorm-linked-github
git add tests/README.md
git commit -m "docs(tests): link each run record to its transcript, from a dated cutoff"
git show HEAD --stat
```

Expected: `tests/README.md` only.

---

### Task 4: Wire the transcript into the cycle and the dispatch procedure

Satisfies AC13, AC14.

**Files:**
- Modify: `tests/README.md` — step 4 of `## The four-step baseline/with-skill cycle` (currently lines 108–112), and the end of `## Dispatching the subagents`' own prose, after the Desktop-chat paragraph and before `### Why there are two preambles`
- Test: none — verified by `grep` (Steps 1 and 4)

**Interfaces:**
- Consumes: the `no transcript — <reason>` line and the subsection name `Recording a run` from Tasks 2 and 3.
- Produces: nothing later tasks depend on. This is the last `tests/README.md` edit.

- [ ] **Step 1: Confirm the new content is absent (the failing check)**

```bash
grep -c 'A dispatch is not finished when it returns' tests/README.md
sed -n '/^4\. \*\*Judge and record\*\*/,/^$/p' tests/README.md | grep -c transcript
```

Expected: both print `0`.

- [ ] **Step 2: Rewrite step 4 of the cycle**

`old_string`:

```
4. **Judge and record** — tick only boxes the with-skill run actually
   demonstrated, re-verified by reading the resulting files directly, not
   by trusting the dispatched agent's self-report. Note honestly which
   boxes the baseline already passed (regression guards, not evidence the
   skill works) and which genuinely required the skill.
```

`new_string`:

```
4. **Judge and record** — save the dispatch's transcript first (see
   "Recording a run" below), then tick only boxes the with-skill run actually
   demonstrated, re-verified by reading the resulting files directly, not
   by trusting the dispatched agent's self-report. The ordering is the
   point: the record gets written from the saved file rather than from a
   memory of the reply. Where the output was lost, the run is recorded
   under that section's `no transcript — <reason>` line rather than
   discarded. Note honestly which boxes the baseline already passed
   (regression guards, not evidence the skill works) and which genuinely
   required the skill.
```

- [ ] **Step 3: Add the closing paragraph to `## Dispatching the subagents`**

Insert verbatim immediately after the paragraph ending `instruct it not to call any tools even if some appear available.` and immediately before the `### Why there are two preambles` heading:

```markdown
**A dispatch is not finished when it returns.** It is finished when its
transcript is on disk — or, where the output was lost, when its
`no transcript — <reason>` line is recorded. `## Recording a run` gives the
path shape and the contents. One consequence belongs here rather than there:
the contamination scan above stops being an assertion only its author can
make. With the full transcript committed, a reader other than the author can
run the same four-item scan over the same text, and disagree.
```

- [ ] **Step 4: Confirm the new content is present (the passing check)**

```bash
grep -n 'A dispatch is not finished when it returns' tests/README.md
sed -n '/^4\. \*\*Judge and record\*\*/,/^$/p' tests/README.md
awk '/^\*\*A dispatch is not finished/,/^### Why there are two preambles/' tests/README.md | grep -c 'four-item scan'
```

Expected: the `grep -n` prints one line; the `sed` block shows the transcript-first clause and the `no transcript — <reason>` fallback; the `awk` pipeline prints `1`.

- [ ] **Step 5: Run the mechanical gate**

```bash
bash scripts/build.sh --check
```

Expected: output ends with `STATUS: PASS`.

- [ ] **Step 6: Commit**

```bash
git branch --show-current   # expect: deep-brainstorm-linked-github
git add tests/README.md
git commit -m "docs(tests): finish a dispatch at its transcript, not at its reply"
git show HEAD --stat
```

Expected: `tests/README.md` only.

---

### Task 5: Write ADR 0014

Satisfies AC17, AC27.

**Files:**
- Create: `docs/adr/0014-scenario-run-transcripts.md`
- Test: none — verified by `grep` and by reading (Steps 1, 4, 5)

**Interfaces:**
- Consumes: the convention written into `tests/README.md` by Tasks 1–4, which this ADR points at rather than restating.
- Produces: the file `docs/adr/0014-scenario-run-transcripts.md`, which Task 6's pointer line in ADR 0008 links to as `[ADR-0014](0014-scenario-run-transcripts.md)`.

- [ ] **Step 1: Confirm 0014 is the next free number and re-verify the cited facts**

```bash
ls docs/adr/
grep -rhoE '/tmp/[A-Za-z0-9._-]+' tests/ | sed -E 's#(/tmp/[^/]+).*#\1#' | sort -u | wc -l
grep -rn 'byte-for-byte' tests/atelier/en/accueil-offre-tutoriel.md
grep -rln 'md5sum' tests/ | wc -l
git cat-file -t 8239f2c && git cat-file -t 144c308
gh issue view 32 --json title -q .title
gh issue view 34 --json title -q .title
```

Expected: `docs/adr/` holds `0001-` through `0013-` and no `0014-`; the sandbox-root count is 48 (if it differs, change the numeral in the drafted Context below to match — spell the number you actually measure); `byte-for-byte` appears in `tests/atelier/en/accueil-offre-tutoriel.md`; at least one file records an `md5sum`; both commit hashes resolve; both issues exist.

- [ ] **Step 2: Confirm the file is absent (the failing check)**

```bash
test -f docs/adr/0014-scenario-run-transcripts.md && echo PRESENT || echo ABSENT
```

Expected: `ABSENT`.

- [ ] **Step 3: Write the ADR**

Create `docs/adr/0014-scenario-run-transcripts.md` with exactly this content:

```markdown
# 0014 — Scenario run transcripts

**Status:** Accepted — 2026-09-18

## Context

`tests/README.md` treats a run record as evidence — `## Recording a run` opens
by saying so, and the whole additivity convention exists to protect it. Until
this decision, nothing in the procedure preserved what a dispatch actually
said. A scenario file's `## Verification notes` carries the excerpts its
author chose, transcribed by the same process that judged them. Nothing else
survived the run.

The sandbox did not close the gap, because the sandbox is gone too. Every
sandbox path in the corpus is under `/tmp/` — forty-eight distinct roots in
all. The on-disk verifications those records describe cannot be repeated by
anyone, including their author:
`tests/atelier/en/accueil-offre-tutoriel.md` confirms a relay file
"byte-for-byte" against a transcript that no longer exists, and several files
record `md5sum` comparisons against files that no longer exist either.

The cost is concrete, not hypothetical. This repo re-judges verdicts on
review. Commit `8239f2c` corrects a pass to a fail in
`tests/atelier-mentor/fr/tutoriel-reprise.md`; commit `144c308` corrects a
cross-locale claim in the EN twin and restates the honest count as 3 of 4.
Both reviews had only the author's chosen quotes to work from — the mechanism
this repo relies on to catch a wrong verdict was running on the thinnest
possible evidence. The baseline contamination scan has the same shape:
`tests/README.md` asks the author to check the full transcript for any
mention of Atelier, any skill name, any repo path, or a citation the
assistant could only have gotten by reading this repo, and a reader of the
resulting record can only take that check on faith.

The alternative was to accept the excerpts as the permanent record and say so
plainly — drop any language implying an audit trail, state that a scenario
file is one author's account of a run, and leave the procedure otherwise
alone. It is honest, it costs nothing, and it is cheaper to live with: no raw
agent output in the repo and no directory that grows with every run. It was
rejected because it gives up the one thing review needs. A reviewer
re-judging a verdict against the same quotes that verdict was built from
cannot tell a representative quote from a flattering one, and both
corrections above were made under exactly that handicap.

## Decision

Every dispatch leaves a transcript, committed to the repo, in a `runs/`
subdirectory beside the scenario it belongs to. `tests/README.md`'s
`## Recording a run` carries the full convention — the two path shapes, the
per-dispatch contents, the 16384-byte file-capture ceiling, the linking rule,
and the cutoff. This ADR carries only what the README should not have to
argue.

**Retention.** Transcripts are committed to the repo, written once, and never
pruned. A transcript file is never edited after it is written: it is the
observation half of a run record, and the verdict it supports lives in the
scenario file, where it can be corrected in place. There is no archiving or
expiry policy, and that is the decision rather than an omission — a retention
policy that deletes evidence contradicts the reason the evidence is kept.

**What this does not claim.** A transcript is pasted into the repo by the same
author who writes the verdict. It does not prove the run happened, and
`tests/README.md` says so in those words. What it provides is the full
context around a quoted excerpt, so a second reader can judge whether the
quote was representative, and something for a later review to re-judge
against. The issue behind this work
([#23](https://github.com/Heyian/atelier/issues/23)) complains that the
procedure implies an audit trail it does not have; replacing one overstatement
with another would not have fixed that.

**No backfill.** Runs recorded before 2026-09-18 carry no transcript, their
quoted excerpts are their only record, and no existing scenario file is
relabeled to say so — the same dated-cutoff shape
[ADR-0013](0013-baseline-isolation-preamble-versioning.md) used for the
isolation preamble. Nothing could be backfilled in any case: those runs'
transcripts no longer exist anywhere.

This is an ADR rather than a README paragraph because it clears the
three-criteria gate. **Hard to reverse:** removing committed transcripts is
deleting evidence, which this repo treats as its cardinal sin — the practice
can be stopped going forward, but the decision cannot be undone backward.
**Surprising without context:** a future reader will ask why a markdown skill
pack commits raw agent output, and the answer is a property of how this repo
verifies skills, not of the files themselves. **A real trade-off:** the
rejected alternative above is genuine, cheaper, and honest, and it was
rejected on one specific ground rather than dismissed.

## Consequences

- The `tests/` tree grows with every run, in files nobody reads end to end.
  That is the price. It falls on `git clone` and on directory listings, not on
  the scenario files, which stay the size they are.
- Transcripts are only ever added, never rewritten, so a scenario directory
  accumulates one record per run indefinitely. The build is unaffected: both
  scans over `tests/` are non-recursive, which is why `runs/` is a
  subdirectory rather than a filename convention.
- Nothing mechanical checks that a run section links a resolvable transcript,
  or that no file under `runs/` is orphaned. Deferred to
  [#34](https://github.com/Heyian/atelier/issues/34), to be built together
  with [#32](https://github.com/Heyian/atelier/issues/32) — both parse
  scenario section headings, and one parser should serve both.
- Sandbox seeds become load-bearing. The corpus already seeds with invented
  companies; committing transcripts turns that habit into a rule stated in
  `tests/README.md`, because whatever seeded a sandbox now lands in the repo.
- A run whose output was lost is still recorded, under a
  `no transcript — <reason>` line, rather than invalidated. Making the
  transcript a validity requirement would create pressure to re-roll a
  dispatch until the paperwork looked clean — the failure the two-attempts
  cap exists to resist.
```

- [ ] **Step 4: Confirm the file is present and well-shaped (the passing check)**

```bash
head -3 docs/adr/0014-scenario-run-transcripts.md
grep -n '^## Context$\|^## Decision$\|^## Consequences$' docs/adr/0014-scenario-run-transcripts.md
grep -n 'never pruned' docs/adr/0014-scenario-run-transcripts.md
grep -n 'rejected because' docs/adr/0014-scenario-run-transcripts.md
grep -n 'three-criteria gate' docs/adr/0014-scenario-run-transcripts.md
```

Expected: the header is `# 0014 — Scenario run transcripts` followed by a blank line and `**Status:** Accepted — 2026-09-18`; the three section headings print in order; the last three `grep`s each print a line.

- [ ] **Step 5: Read it against AC17 and AC27**

Read the file top to bottom and confirm: it follows the numbering and the Context / Decision / Consequences shape of the other files in `docs/adr/` (AC17); it records the rejected alternative — accept the excerpts as the permanent record and say so plainly (AC17); it states why each of the three gate criteria is met (AC17); and it states the retention decision in full: committed, written once, never pruned (AC27).

- [ ] **Step 6: Run the mechanical gate**

```bash
bash scripts/build.sh --check
```

Expected: output ends with `STATUS: PASS`.

- [ ] **Step 7: Commit**

```bash
git branch --show-current   # expect: deep-brainstorm-linked-github
git add docs/adr/0014-scenario-run-transcripts.md
git commit -m "docs(tests): ADR 0014 on committing scenario run transcripts"
git show HEAD --stat
```

Expected: `docs/adr/0014-scenario-run-transcripts.md` only, listed as a new file.

---

### Task 6: Point ADR 0008 at ADR 0014

Satisfies AC18.

**Files:**
- Modify: `docs/adr/0008-scenario-file-format.md` — one line at the end of `## Decision`, after the `tests/_cross-skill/` paragraph and before `## Consequences`
- Test: none — verified by `grep` (Steps 1 and 3)

**Interfaces:**
- Consumes: `docs/adr/0014-scenario-run-transcripts.md`, created in Task 5. Do not run this task before Task 5, or the link points at nothing.
- Produces: nothing later tasks depend on.

- [ ] **Step 1: Confirm the pointer is absent (the failing check)**

```bash
grep -c '0014' docs/adr/0008-scenario-file-format.md
test -f docs/adr/0014-scenario-run-transcripts.md && echo TARGET-EXISTS
```

Expected: `0`, then `TARGET-EXISTS`.

- [ ] **Step 2: Add the pointer line**

`old_string`:

```
`tests/_cross-skill/` holds system-level scenarios not tied to one skill. It is
underscore-prefixed deliberately: the AC15 coverage scan iterates `skills/*/`,
so it never looks for a matching skill and never counts these files.
```

`new_string`:

```
`tests/_cross-skill/` holds system-level scenarios not tied to one skill. It is
underscore-prefixed deliberately: the AC15 coverage scan iterates `skills/*/`,
so it never looks for a matching skill and never counts these files.

What a run leaves on disk is a separate question from the file's shape: see
[ADR-0014](0014-scenario-run-transcripts.md).
```

- [ ] **Step 3: Confirm the pointer is present and lands inside `## Decision` (the passing check)**

```bash
grep -n '0014' docs/adr/0008-scenario-file-format.md
awk '/^## Decision$/,/^## Consequences$/' docs/adr/0008-scenario-file-format.md | grep -c 'ADR-0014'
ls docs/adr/0014-scenario-run-transcripts.md
```

Expected: the `grep -n` prints one line; the `awk` pipeline prints `1`, confirming the line sits under **Decision** and not under **Consequences**; the `ls` resolves, confirming the relative link target exists.

- [ ] **Step 4: Run the mechanical gate**

```bash
bash scripts/build.sh --check
```

Expected: output ends with `STATUS: PASS`.

- [ ] **Step 5: Commit**

```bash
git branch --show-current   # expect: deep-brainstorm-linked-github
git add docs/adr/0008-scenario-file-format.md
git commit -m "docs(tests): point ADR 0008 at ADR 0014 for run transcripts"
git show HEAD --stat
```

Expected: `docs/adr/0008-scenario-file-format.md` only.

---

### Task 7: Verify the deferred issue and the untouched config surface

Satisfies the spec's Required Tasks 4 and 5, and guards AC21. No file changes, no commit.

**Files:**
- Modify: none. This task fails loudly rather than editing anything.
- Test: none — it *is* the test.

**Interfaces:**
- Consumes: nothing.
- Produces: a go/no-go for Task 8.

- [ ] **Step 1: Confirm issue #34 exists and carries all four required body sections**

```bash
gh issue view 34 --json body -q .body | grep -cE '^## (Context|Required|Integration Points|Priority)$'
```

Expected: `4`. If fewer, stop and report which heading is missing — do not edit the issue as part of this plan without saying so.

- [ ] **Step 2: Confirm every "Deferred Items" issue the spec names resolves**

The spec's Deferred Items section names exactly one issue, #34. Its Non-goals also reference #32 and its Context references #23:

```bash
for n in 23 32 34; do gh issue view "$n" --json number,title -q '"#\(.number) \(.title)"'; done
```

Expected: three lines, one per issue, no error.

- [ ] **Step 3: Walk the Config & Infrastructure Impact table and confirm every row is still "None"**

The spec marks every row `None`, and AC21 makes the diff allowlist authoritative over the per-file task rule — so the correct action for each of these files is *no edit*, verified:

```bash
git diff --name-only dev...HEAD
```

Expected: the printed list contains none of `.github/workflows/ci.yml`, `.github/workflows/release-please.yml`, `scripts/build.sh`, `scripts/build.ps1`, any path under `scripts/tests/`, `.gitignore`, `CLAUDE.md`, `version.txt`, `CHANGELOG.md`, or `docs/WHATS-NEW.md`. If any appears, stop: an earlier task edited a file the spec forbids.

- [ ] **Step 4: Confirm there are no Manual Operator Steps outstanding**

The spec's Manual Operator Steps section reads "None — every change lands in the diff." Nothing to hand to an operator, nothing to wait on. Confirm by reading that section of the spec; if it has changed since this plan was written, stop and hand the steps over before continuing.

---

### Task 8: Post-implementation check against the diff

Satisfies AC19, AC20, AC21, and the spec's Required Task 8. No file changes, no commit — unless it finds something, in which case the fix belongs to the task that introduced it.

**Files:**
- Modify: none.
- Test: none — it *is* the test. Read the diff; do not trust this plan's checkboxes.

**Interfaces:**
- Consumes: every earlier task's commits.
- Produces: a go/no-go for Task 9.

- [ ] **Step 1: Check the diff allowlist (AC21, AC19)**

```bash
git diff --name-only dev...HEAD | sort
```

Expected, exactly these five lines and no others:

```
docs/adr/0008-scenario-file-format.md
docs/adr/0014-scenario-run-transcripts.md
docs/superpowers/plans/2026-09-18-scenario-run-transcripts.md
docs/superpowers/specs/2026-09-18-scenario-run-transcripts-design.md
tests/README.md
```

`CLAUDE.md` must not appear — that is AC19. No path under `tests/` other than
`tests/README.md` may appear — that is the rest of AC21. The plan file itself
must be committed for this list to match; if it is still untracked, commit it
now with `docs(tests): implementation plan for scenario run transcripts`.

- [ ] **Step 2: Re-verify every citation in the new prose against the working tree (AC20)**

```bash
git diff dev...HEAD -- tests/README.md docs/adr/ | grep '^+' | grep -oE '`[a-z_]+\(\)|scripts/[a-z.]+|tests/[A-Za-z0-9/_.-]+\.md|[0-9a-f]{7}`' | sort -u
```

For each path printed, confirm it resolves (`ls <path>`); for each seven-character hash, confirm `git cat-file -t <hash>` prints `commit`; for each function name, confirm `grep -n '<name>' scripts/build.sh` finds it. Then re-run the two structural claims the prose rests on:

```bash
grep -n 'maxdepth 1' scripts/build.sh
grep -n 'Get-ChildItem' scripts/build.ps1 | grep -v -- -Recurse
```

Expected: `-maxdepth 1` appears in both `check_scenarios` and `check_triggers`; the PowerShell scenario and trigger scans use `Get-ChildItem` with no `-Recurse`. If either has changed, the sentence in `tests/README.md` that describes it is now wrong and must be corrected before the branch is finished.

- [ ] **Step 3: Walk the acceptance criteria against the files on disk**

Open the spec and read AC1 through AC27 in order. For each, point at the text that satisfies it:

- AC1–AC10, AC24–AC26 → `### Every dispatch leaves a transcript` in `tests/README.md` (Task 2)
- AC11, AC12, AC16 → the three paragraphs closing that subsection (Task 3)
- AC13 → step 4 of `## The four-step baseline/with-skill cycle` (Task 4)
- AC14 → the closing paragraph of `## Dispatching the subagents` (Task 4)
- AC15 → the `## Layout` listing, and `## Scenario file format` unmodified (Task 1)
- AC17, AC27 → `docs/adr/0014-scenario-run-transcripts.md` (Task 5)
- AC18 → the pointer line in `docs/adr/0008-scenario-file-format.md` (Task 6)
- AC19, AC20, AC21 → Steps 1 and 2 above
- AC22, AC23 → Task 9

List any criterion you cannot point at, and fix it before continuing.

- [ ] **Step 4: Confirm the four fixed terms are used consistently**

```bash
awk '/^## Recording a run/,/^## Dispatching the subagents/' tests/README.md | grep -nE 'dispatch|attempt|sample|transcript' | head -40
```

Expected: **dispatch** always means one self-contained subagent run, **attempt** one execution of a dispatch, **sample** N independent dispatches, **transcript** the committed file. No sentence uses one where it means another — in particular, "transcript" must not be used for the agent's reply alone in any sentence added by this work. (`## Dispatching the subagents`' pre-existing contamination-scan wording "check the full transcript" predates this work and is not edited.)

---

### Task 9: Final build

Satisfies AC22, AC23.

**Files:**
- Modify: none. `dist/` is gitignored.
- Test: the build itself.

**Interfaces:**
- Consumes: everything above.
- Produces: the per-locale ZIPs in `dist/`, which are not committed.

- [ ] **Step 1: Run the mechanical gate one last time (AC22)**

```bash
bash scripts/build.sh --check
```

Expected: output ends with `STATUS: PASS`. If it fails, fix the cause here and re-run until it passes.

- [ ] **Step 2: Run the full build (AC23)**

```bash
bash scripts/build.sh --lang all
echo "exit: $?"
ls -la dist/
```

Expected: exit `0`, and `dist/` holds the per-locale ZIPs. Fix any build failure and re-run until it completes successfully.

- [ ] **Step 3: Confirm the build left the working tree clean**

```bash
git status --porcelain
```

Expected: empty. `dist/` is in `.gitignore`; if anything else appears, it came from the build and must be understood before the branch is finished.

---

## Before finishing the branch

Advisory only — this never gates the merge. The gate is `bash scripts/build.sh --check` plus `bash scripts/build.sh --lang all`, both in Task 9.

If a cross-model review helper is available (the Codex plugin's adversarial review, via `codex:rescue`), run it with this focus: *"Judge correctness against the spec's acceptance criteria AC1–AC27 only. Do not flag anything outside the stated criteria — no design alternatives, no hardening, no scope the spec did not claim."* If no helper is available, finish the branch without it.

Then wrap up via `superpowers:finishing-a-development-branch`.

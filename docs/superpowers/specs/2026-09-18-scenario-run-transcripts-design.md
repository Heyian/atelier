# Scenario run transcripts — what a dispatch leaves behind

**Issue:** [#23](https://github.com/Heyian/atelier/issues/23)
**Date:** 2026-09-18
**Builds on:** [`2026-09-18-scenario-run-conventions-design.md`](2026-09-18-scenario-run-conventions-design.md)
and [PR #33](https://github.com/Heyian/atelier/pull/33), which added
`## Recording a run` to `tests/README.md` and amended ADR 0008 for the repeatable
verification section; [ADR 0008](../../adr/0008-scenario-file-format.md) (the
scenario file format); [ADR 0013](../../adr/0013-baseline-isolation-preamble-versioning.md)
(the dated-cutoff precedent, used again here).

## Problem

`tests/README.md` treats a run record as evidence — `## Recording a run` opens by
saying so, and the whole additivity convention exists to protect it. But nothing
in the procedure preserves what a dispatch actually said. A scenario file's
`## Verification notes` carries excerpts the author chose, transcribed by the same
process that judged them. Nothing else survives.

**The sandbox does not close the gap, because the sandbox is gone too.** Every
sandbox path in the corpus is under `/tmp/` — `/tmp/atl-sbx-en-full`,
`/tmp/av-sandbox-fr`, `/tmp/msm-sandbox`, forty-eight distinct roots in all. The on-disk
verifications those records describe (`tests/atelier/en/accueil-offre-tutoriel.md`
confirms a relay file "byte-for-byte" against the transcript; several files record
`md5sum` comparisons) cannot be repeated by anyone, including their author. The
issue frames this as "branches that write nothing leave no trace"; in fact the
branches that *did* write left no durable trace either.

**The repo already re-judges verdicts on review, against nothing but those
excerpts.** Commit `8239f2c` corrects a pass to a fail in
`tests/atelier-mentor/fr/tutoriel-reprise.md`; commit `144c308` corrects a
cross-locale claim in the EN twin and restates the honest count as 3 of 4. Both
reviews had only the author's chosen quotes to work from. This is the concrete cost
of the gap, not a hypothetical one — the mechanism the repo relies on to catch a
wrong verdict is running on the thinnest possible evidence.

**The baseline contamination scan is an assertion about text nobody else has seen.**
`tests/README.md` instructs the author to "check the full transcript for any mention
of Atelier, any skill name, any repo path, or a citation the assistant could only
have gotten by reading this repo." A reader of the resulting record can only take
that check on faith.

**Scope.** All 36 scenario files, not the 30 the issue names. `tests/_cross-skill/`
has the same gap and the most dispatches per file.

### What no option here buys

None of the available artifacts proves a run happened. A transcript file is pasted
into the repo by the same author who wrote the verdict; a hash of a reply has no
preserved original to be checked against. What a committed transcript buys is
narrower and worth naming precisely: a second reader gets the full context around a
quoted excerpt, so they can judge whether the quote was representative, and a later
review has something to re-judge against. The README must say this plainly — the
issue's own complaint is that the procedure implies an audit trail it does not have,
and replacing one overstatement with another would not fix that.

## Decision

Every dispatch leaves a transcript, committed to the repo. Four files change; no
scenario file is edited.

### 1. The transcript file

**Path:** `tests/<skill>/<locale>/runs/<scenario-basename>/<date>-<kind>.md`.

```
tests/atelier/en/runs/accueil-offre-tutoriel/2026-08-10-baseline.md
tests/atelier/en/runs/accueil-offre-tutoriel/2026-08-10-verification.md
tests/atelier-mentor/en/runs/tutoriel-selecteur/2026-08-12-verification-larger-sample.md
tests/_cross-skill/runs/declenchement/2026-08-10-verification.md
```

`<kind>` is `baseline` or `verification`, optionally followed by a short reason slug
matching the run section's own reason. The per-scenario level exists because
`tests/atelier-mentor/en/` holds six scenarios, several with multiple runs; flat
naming there sorts badly and gets long.

`runs/` is a **subdirectory**, and that is load-bearing rather than cosmetic. Both
coverage checks are non-recursive — `scripts/build.sh:522` and `:545` use
`find … -maxdepth 1`, and `scripts/build.ps1:305` and `:319` use `Get-ChildItem`
without `-Recurse`. A transcript saved as a sibling `.md` inside a scenario directory
would be counted by AC15's `check_scenarios`, so a directory could pass "has a
scenario" on transcripts alone. Inside `runs/`, transcripts are invisible to both
checks and to the AC6 trigger parser.

**Granularity:** one file per run section — per `## Baseline notes`, and per
`## Verification notes` or `## Verification notes — <date> <reason>` sibling. This
matches the unit `## Recording a run` already governs, so the rule that a prior
record is never rewritten extends to transcripts without new wording.

**Contents:**

- A header: the scenario file's path, the date, the kind, the isolation-preamble
  version (baselines only, per ADR 0013), and the agent type and model dispatched.
- One block per dispatch, labeled as the run section labels it (`## Dispatch A —
  "full"`), carrying:
  - **the prompt, verbatim** — the full scripted conversation as handed to the
    agent, including the isolation preamble for a baseline. A reply without the
    prompt that produced it cannot be judged.
  - **the reply, verbatim and complete** — not excerpted.
  - **the sandbox after the run** — the `find` listing, or an explicit "no sandbox"
    for a Desktop-chat dispatch.
  - **every file the dispatch created or modified**, pasted in full when under
    16 KB. Larger files get their path, byte count, `md5sum`, and the excerpt the
    verdict rests on.
- Both attempts of a re-attempted dispatch, each labeled `attempt 1 of 2` /
  `attempt 2 of 2`, per the existing cap.

**A transcript file is written once and never edited afterward.** This is the
observation half of `## Recording a run`'s split, applied to a separate file: the
observation is never edited or deleted, and the verdict lives in the scenario file
where it can be corrected in place. Transcripts are never pruned.

**Sandbox seeds stay invented.** The corpus already seeds with fictional companies
(Cedarline Outfitters, Lanternes Boréales). Committing transcripts makes that
convention load-bearing rather than incidental, so `tests/README.md` states it as a
rule.

### 2. `tests/README.md`

**a. `## Recording a run` gains a fifth rule — "Every dispatch leaves a
transcript."** The full convention lives here, because this is a recording
convention and this section is where they live. It states: the path shape; that the
unit is the run section; what the file contains; that it is written once and never
edited; the sandbox-seed rule; and — plainly — that the transcript is saved by the
same author who writes the verdict, so it does not prove the run happened, and what
it does buy instead.

**b. The linking rule.** Each run section's first line either links its transcript
or states `no transcript — <reason>`. A run whose output was lost is recorded
honestly rather than discarded: making the transcript a hard validity requirement
would create pressure to re-roll a dispatch until the paperwork was clean, which is
precisely the failure the two-attempts cap exists to resist.

**c. The cutoff.** Runs recorded on or after **2026-09-18** carry a transcript.
Runs before it do not, their quoted excerpts are their only record, and no existing
file is relabeled to say so. Same shape ADR 0013 used for preamble v1/v2, and
consistent with `## Recording a run`'s own rule that a record is never tidied to
match a later convention. Nothing can be backfilled: the transcripts of every past
run no longer exist anywhere.

**d. Step 4 of the four-step cycle** gains a clause — save the transcript before
judging, so the record is written from the file rather than from a memory of the
reply.

**e. `## Dispatching the subagents`** gains a closing paragraph: a dispatch is not
finished when it returns, it is finished when its transcript is on disk. It also
notes that the baseline contamination scan becomes re-checkable by someone other
than the author.

**f. `## Scenario file format`** shows `runs/` in its layout block.

**g. Quoting is unchanged.** Ticked boxes still name the line that earned them. With
a transcript alongside, a quote stops being the evidence and becomes a citation into
it — which is what makes a quote checkable for whether it was representative.
`## Recording a run` says so in one sentence.

### 3. `docs/adr/0014-scenario-run-transcripts.md`

New ADR carrying the retention decision and the alternative that was rejected:
accepting the excerpts as the permanent record and saying so plainly. It passes the
three-criteria gate — hard to reverse (removing committed transcripts is deleting
evidence, which this repo treats as its cardinal sin), surprising without context (a
future reader will ask why raw agent output is committed to a skill pack), and a real
trade-off with a genuine alternative.

### 4. `docs/adr/0008-scenario-file-format.md`

One line under **Decision** pointing at 0014 for what a run leaves on disk. ADR 0008
owns the scenario file's shape, not the repo's evidence-retention policy, so the
reasoning does not go here. PR #33 chose an amendment over a new ADR because its
reasoning "fits in a paragraph of the ADR that already owns the format"; that
argument does not transfer.

## Non-goals

- **No backfill, and no marker added to existing files.** The transcripts are gone;
  nothing can be reconstructed. Adding a "no transcript exists" line to 36 files
  would edit 36 evidence records to state what the README states once, and
  `## Recording a run` forbids exactly that kind of retro-tidying. Decided
  deliberately; not deferred, and no issue tracks it.
- **No mechanical enforcement.** Nothing validates that a run section links a
  resolvable transcript, or that no file under `runs/` is orphaned. Filed as
  [#34](https://github.com/Heyian/atelier/issues/34), to be built together with
  [#32](https://github.com/Heyian/atelier/issues/32) — both parse scenario section
  headings and one parser should serve both.
- **No `CLAUDE.md` change.** PR #33 already put "how a scenario run is recorded:
  `tests/README.md`" on the Layout line (`CLAUDE.md:52-53`); that clause covers this
  work. Adding a second pointer would grow the index for nothing.
- **No pruning or archiving policy.** Transcripts are never pruned. This is the
  decision, not a deferral — a retention policy that deletes evidence contradicts the
  reason the evidence is kept.
- **No script changes.** `scripts/build.sh` and `scripts/build.ps1` are untouched;
  their non-recursive scans are the reason `runs/` is a subdirectory, not something
  this work modifies.
- **No changes to any file under `tests/` other than `README.md`.** No checkbox,
  tally, or run record is edited.

## Acceptance Criteria

**AC1** — `tests/README.md`'s `## Recording a run` section contains a rule stating
that every dispatch leaves a transcript file committed to the repo.

**AC2** — That rule gives the transcript path shape as
`tests/<skill>/<locale>/runs/<scenario-basename>/<date>-<kind>.md`, where `<kind>`
is `baseline` or `verification` with an optional reason slug, and shows at least one
concrete example path.

**AC3** — That rule states that `runs/` is a subdirectory because the coverage and
trigger scans are non-recursive, so a transcript placed as a sibling `.md` would be
counted as a scenario by AC15's `check_scenarios`.

**AC4** — That rule states that the transcript unit is the run section: one file per
`## Baseline notes`, and one per `## Verification notes` or
`## Verification notes — <date> <reason>` sibling.

**AC5** — That rule enumerates all four required per-dispatch contents: the prompt
verbatim (including the isolation preamble for a baseline), the reply verbatim and
complete, the sandbox listing after the run (or an explicit "no sandbox"), and the
contents of every file the dispatch created or modified.

**AC6** — That rule states the file-capture ceiling: files under 16 KB are pasted in
full; larger ones are recorded by path, byte count, `md5sum`, and the excerpt the
verdict rests on.

**AC7** — That rule states that both attempts of a re-attempted dispatch appear in
the transcript, each labeled, consistent with the existing two-attempts cap.

**AC8** — That rule states that a transcript file is written once and never edited
afterward, and that transcripts are never pruned.

**AC9** — That rule states that sandbox seeds use invented companies, and that
committing transcripts is the reason this is a rule rather than a habit.

**AC10** — That rule states plainly that a transcript is saved by the same author who
writes the verdict and therefore does not prove the run happened, and names what it
does provide instead: full context around a quoted excerpt, and something for a
later review to re-judge against.

**AC11** — Given a run section recorded on or after the cutoff, `tests/README.md`
requires its first line to either link its transcript file or state
`no transcript — <reason>`; and it states why a missing transcript is recorded rather
than invalidating the run (re-rolling for clean paperwork is the failure the
two-attempts cap exists to resist).

**AC12** — `tests/README.md` names **2026-09-18** as the literal cutoff date, states
that runs recorded before it carry no transcript and that their quoted excerpts are
their only record, and states that no existing scenario file is relabeled.

**AC13** — Step 4 of `## The four-step baseline/with-skill cycle` instructs the
author to save the transcript before judging.

**AC14** — `## Dispatching the subagents` states that a dispatch is finished when its
transcript is on disk, and notes that the baseline contamination scan becomes
re-checkable by a reader other than the author.

**AC15** — The `## Scenario file format` layout block in `tests/README.md` shows the
`runs/` directory.

**AC16** — `tests/README.md` states that ticked boxes still quote the line that
earned them, and that a quote is now a citation into the transcript rather than the
evidence itself.

**AC17** — `docs/adr/0014-scenario-run-transcripts.md` exists, follows the numbering
and the Context / Decision / Consequences shape of the existing ADRs in
`docs/adr/`, records the rejected alternative (accept the excerpts as the permanent
record and say so plainly), and states why the three-criteria gate is met.

**AC18** — `docs/adr/0008-scenario-file-format.md` carries one line under
**Decision** pointing at ADR 0014 for what a run leaves on disk.

**AC19** — `CLAUDE.md` is not modified by this work.

**AC20** — Every file path, line number, and commit hash cited in the new or amended
prose exists and says what it is claimed to say, re-verified at the time of the
commit (line numbers gathered during design can shift).

**AC21** — `git diff --name-only` for this work lists only `tests/README.md`,
`docs/adr/0014-scenario-run-transcripts.md`,
`docs/adr/0008-scenario-file-format.md`, and this spec. That allowlist is
authoritative over the Implementation Plan Guidance below: no file under `tests/`
other than `README.md` is modified, no script is changed, `CLAUDE.md` is not touched,
and no file marked "None" in Config & Infrastructure Impact is edited.

**AC22** — `bash scripts/build.sh --check` reports `STATUS: PASS`.

**AC23** — `bash scripts/build.sh --lang all` completes successfully and writes the
per-locale ZIPs into `dist/`.

## Deferred Items

- [#34](https://github.com/Heyian/atelier/issues/34) — Build check: scenario run
  sections carry no mechanical transcript-link enforcement.

## Glossary Updates & ADRs

No glossary — this repo has no `CONTEXT.md`. Three terms carry fixed meanings from
`## Recording a run` and must be used consistently in the new prose: **dispatch**
(one self-contained subagent run), **attempt** (one execution of a dispatch, capped
at two), **sample** (N independent dispatches each held to one attempt). This work
adds a fourth: **transcript** (the committed file holding one run section's prompts,
replies, sandbox listings, and written-file contents).

**New ADR:** `0014-scenario-run-transcripts.md`, under the three-criteria gate — see
Decision §3.

**ADR interaction, not a conflict.** ADR 0008 fixes the scenario file's shape and was
amended on 2026-09-18 for the repeatable verification section. Transcripts live in a
separate directory and do not change that shape, so 0008 gets a pointer line, not a
second amendment.

## Config & Infrastructure Impact

Scanned against every category. The repo has no containers, no IaC, no env config, no
schemas, no `package.json`, no `Makefile`/`justfile`, and no API collections — those
categories are absent from the repo, not merely unaffected.

| File | Change |
| --- | --- |
| `.github/workflows/ci.yml` | None — runs `build.sh --check`, which is unchanged. |
| `.github/workflows/release-please.yml` | None — no version-bearing file is touched. |
| `scripts/build.sh`, `scripts/build.ps1` | None — enforcement deferred to #34. Their non-recursive scans are why `runs/` is a subdirectory. |
| `scripts/tests/*.sh`, `scripts/tests/build_test.ps1` | None — no script behavior changes. |
| `.gitignore` | None — it holds `dist/` only; transcripts are committed, so nothing is added. |
| `CLAUDE.md` (agent index) | None — `CLAUDE.md:52-53` already points at `tests/README.md`. |
| `version.txt`, `CHANGELOG.md`, `docs/WHATS-NEW.md` | None — release-please owns these; a `docs:` commit produces no release entry. |

## Manual Operator Steps

None — every change lands in the diff.

## Documentation Updates

| Doc | Change |
| --- | --- |
| `tests/README.md` | Fifth rule under `## Recording a run`; the linking rule and cutoff; step 4 of the cycle; the `## Dispatching the subagents` closing paragraph; `runs/` in the format block; the quoting sentence. |
| `docs/adr/0014-scenario-run-transcripts.md` | New ADR — the retention decision and the rejected alternative. |
| `docs/adr/0008-scenario-file-format.md` | One pointer line under **Decision**. |

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
> 2. **Glossary application** — *(dropped: this repo has no glossary file. The four terms fixed in "Glossary Updates & ADRs" apply to the prose of `## Recording a run` and are covered by AC1–AC11.)*
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
> - **Pre-commit verification (mandatory)** — Before EVERY `git commit`, dispatch a verification subagent that runs `bash scripts/build.sh --check` from the repo root and reports `STATUS: PASS` or `STATUS: FAIL` with a terse per-issue list (no raw output). Wait for `STATUS: PASS` before committing; if FAIL, fix in the current task and re-run. Never use `git commit --no-verify`.
>
> ---
>
> ### Before finishing the branch (advisory cross-model review)
>
> After the final build passes — and before wrapping up via `superpowers:finishing-a-development-branch` — if a cross-model review helper is available (e.g. the Codex plugin's adversarial review), run it with focus: *"Judge correctness against the spec's acceptance criteria (AC1–ACn) only. Do not flag anything outside the stated criteria — no design alternatives, hardening, or scope the spec did not claim."*
>
> This **never gates a merge** — the gate stays `bash scripts/build.sh --check` plus `bash scripts/build.sh --lang all`; the review only flags what deserves a second look. If no helper is available, finish the branch without it.

---

**Note on TDD for this spec.** There is no runtime to test here and the deferred
build check (#34) is out of scope, so the Per-Task Policies' TDD rule has no test
file to produce. The acceptance criteria are checked by reading the resulting
`tests/README.md` and the two ADR files, plus `bash scripts/build.sh --check` for
AC22 and `git diff --name-only` for AC19 and AC21.

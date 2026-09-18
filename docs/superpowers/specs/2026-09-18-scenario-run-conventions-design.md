# Recording a scenario run — the attempts cap and the additive re-run

**Issue:** [#22](https://github.com/Heyian/atelier/issues/22)
**Date:** 2026-09-18
**Builds on:** [ADR 0008](../../adr/0008-scenario-file-format.md) (the four-section
scenario format), [ADR 0013](../../adr/0013-baseline-isolation-preamble-versioning.md)
and [`2026-08-12-baseline-isolation-preamble-design.md`](2026-08-12-baseline-isolation-preamble-design.md)
(which put the attempts cap into `tests/README.md` for baselines),
[`2026-08-10-mentor-tutorial-design.md`](2026-08-10-mentor-tutorial-design.md)
(the work both conventions emerged from during execution).

## Problem

Two conventions govern how a scenario run gets written down. Both are load-bearing
across the suite. Neither is fully documented, and the half that is documented is
scoped too narrowly.

**The attempts cap is documented as a baseline rule.** `tests/README.md` carries
"**Two honest attempts, then stop.** A baseline gets at most two dispatches…",
added by PR #31. But the rule is applied in practice to *with-skill verification*
dispatches too: `tests/atelier-mentor/en/tutoriel-selecteur.md` runs a verification
dispatch twice under "the two-honest-attempts-maximum rule" and records both
outcomes. A contributor reading the current text has no reason to believe a
verification dispatch may not be re-rolled until it passes — which is exactly the
failure the cap exists to prevent, and the more tempting one, since a verification
re-roll produces a green checklist.

**The additive re-run convention is documented nowhere.** When a scenario is re-run
after a fix, the new results are appended under a new dated heading and the original
failing record is kept. Six files do this. `tests/README.md` does not mention it.
A contributor who overwrites a prior record destroys the only evidence of what was
actually observed, and nothing in the repo tells them not to.

**Two adjacent facts make the naive statement of both rules wrong.** A multi-dispatch
sample looks like a cap violation (six dispatches in one section), and a re-run
*does* overwrite part of the file — the `## Expected behaviors` checklist. A
documentation change that states the rules without these two qualifications is
either ignored or followed into paralysis.

### What issue #22 gets wrong

The issue predates PR #31 and was written from a grep. Three of its claims do not
survive a check against the files, and the design below does not follow them:

1. It says `tests/README.md` describes neither convention. The cap is there, for
   baselines.
2. It names `tests/atelier/{fr,en}/accueil-offre-tutoriel.md` and
   `tests/_cross-skill/multi-session-memoire.md` as examples of the additive
   convention. Each has exactly one `## Verification notes` and no dated re-run
   section; their "re-run" hits are the scenario's *subject matter* (onboarding's
   re-run path). The real count is six files, not "roughly ten".
3. It treats the re-run heading as one format. Four shapes exist on disk.

## Diagnosis

The conventions were invented mid-execution during the mentor tutorial work and
never written back into a procedure. Each file that needed one restated it locally,
in its own words, so the wording drifted and the rules stayed invisible to anyone
not reading a file that happens to use them.

Five shapes are in use for verification records:

| Shape | Files |
| --- | --- |
| `## Verification notes — <date> re-run (<reason>)` | `tutoriel-selecteur.md` ×2, `tutoriel-reprise.md` ×2 |
| `## Verification notes — <date> second re-run (attempt 2 of 2)` | `tutoriel-selecteur.md` (en) |
| `## Verification notes — <date> larger sample (issue #25)` | `tutoriel-selecteur.md` ×2, `tutoriel-reprise.md` ×2 |
| `### Run <date> — <reason>`, nested under one `## Verification notes` | `_cross-skill/declenchement.md` |
| bold-lead paragraph, no heading | `atelier-mentor/en/capability-question.md` |

Baselines use a fifth shape: a bold-lead dated paragraph inside the single
`## Baseline notes` (`atelier-mentor/en/tutoriel-declenchement.md`, the 2026-08-12
v2 re-run — "this is an addition, not a correction to it").

Nothing mechanical touches any of this. `scripts/build.sh --check` validates
`triggers:` (AC6) and scenario presence (AC15) only; it never reads section
headings. The PowerShell twin matches. So this change is documentation-only and
carries no CI risk.

## Decision

Three files change. No scenario file is touched.

### 1. `tests/README.md`

**a. Generalize the cap.** Rewrite the existing `**Two honest attempts, then stop.**`
paragraph from a baseline rule into a dispatch rule: any dispatch gets at most two
attempts. Name the two entry conditions for a second attempt — isolation failure on
a baseline, a failed `## Expected behaviors` box on a verification — and state that
both attempts' outcomes are recorded, not only the second. The
`**When both attempts fail…**` paragraph that follows stays baseline-specific and is
relabeled to say so.

**b. Add `## Recording a run`.** A new top-level section placed after
`## The four-step baseline/with-skill cycle` and before `## Dispatching the
subagents` — step 4 of the cycle is "judge and record", so the reader meets the
recording rules exactly where the cycle hands off to them. It carries four rules:

- **Re-runs append.** A verification re-run gets a new
  `## Verification notes — <date> <short reason>` sibling section, appended below
  the existing ones, oldest first. The prior section stays as written. Live
  example: `tests/atelier-mentor/en/tutoriel-selecteur.md` carries three such
  records in one file.
- **What additivity covers, and what it does not.** The *observation* — what the
  agent did, quoted, and what was confirmed on disk — is never edited or deleted.
  The *verdict* is current state and is updated in place: the `## Expected
  behaviors` boxes, the running tally, and a prior run's judgment when review
  overturns it. The new section states what changed and why; the superseded text
  stands. Live examples: commit `8239f2c` flipped all five boxes in
  `tests/atelier-mentor/fr/tutoriel-reprise.md` while appending the re-run below;
  `tests/atelier-mentor/en/tutoriel-reprise.md` re-judges an earlier run's box 3 as
  a continued failure and restates the honest count.
- **An attempt is not a dispatch in a sample.** One dispatch gets at most two
  attempts. A *sample* is N independent dispatches each held to a single attempt,
  and not retrying any of them is the point — a sample measures a rate. Live
  examples: `tests/atelier-mentor/en/tutoriel-selecteur.md`'s 2026-08-12 section
  (six dispatches, one attempt each) and `tests/atelier/en/accueil-offre-tutoriel.md`
  (five). Neither is a cap violation.
- **Baselines differ, deliberately.** A baseline re-run is a dated paragraph inside
  the single `## Baseline notes`, not a new sibling section. A baseline re-run under
  a new isolation preamble is the same measurement taken a second way, which is why
  ADR 0013 labels preamble versions rather than replacing runs; whether to re-run at
  all is case-by-case. Live example:
  `tests/atelier-mentor/en/tutoriel-declenchement.md`'s 2026-08-12 v2 paragraph —
  and its FR twin, deliberately not re-run.

The section closes by naming the two files that predate the convention —
`tests/_cross-skill/declenchement.md` (nested `### Run <date>`) and
`tests/atelier-mentor/en/capability-question.md` (bold-lead paragraph) — and stating
that both are left as written. Editing a record to match a later convention is the
habit this section exists to prevent.

**c. Update the format block.** `## Scenario file format`'s example gains one line
under `## Verification notes` showing `## Verification notes — <date> <reason>` as a
repeatable sibling, pointing at `## Recording a run` for the detail.

### 2. `docs/adr/0008-scenario-file-format.md`

An `**Amended 2026-09-18**` note under **Decision**: `## Verification notes` may
repeat with a dated suffix; `## Baseline notes` does not repeat and takes dated
paragraphs instead; the reason is that a run record is evidence, and a superseded
record is still what was observed. ADR 0008 currently fixes the file at four `##`
sections, so without this note the ADR is wrong about the format the repo uses.

### 3. `CLAUDE.md`

One clause appended to the existing `tests/<canonical-fr-name>/<locale>/` line in
**Layout**, pointing at `tests/README.md` for run-recording conventions. Half a
line; the index gains no design content.

## Non-goals

- **No migration of the two predating files.** Rewriting a run record to match a
  later convention contradicts the rule being documented — a record is evidence, and
  tidying its heading is the first step toward tidying its content. Decided
  deliberately; not deferred, and no issue tracks it.
- **No mechanical enforcement.** The failure this addresses — a deleted record —
  is not detectable by a build check; only `git` sees it, and only a reviewer acts
  on it. A heading date-format check was considered and filed as
  [#32](https://github.com/Heyian/atelier/issues/32).
- **No changes to any file under `tests/` other than `README.md`.** In particular,
  no checkbox, tally, or run record is edited by this work.
- **No new ADR.** The amendment to 0008 carries the reasoning; a second ADR would
  duplicate it.

## Acceptance Criteria

**AC1** — `tests/README.md`'s two-attempts rule is stated as applying to any
dispatch, not only to a baseline: the sentence that sets the ceiling does not
restrict its subject to baselines.

**AC2** — That rule names both conditions that permit a second attempt: isolation
failure (baseline) and a failed `## Expected behaviors` box (verification).

**AC3** — That rule states that both attempts' outcomes are recorded, not only the
passing or later one.

**AC4** — The `**When both attempts fail…**` rule that follows remains explicitly
scoped to baselines ("baseline not established" is a baseline outcome).

**AC5** — `tests/README.md` contains a top-level section named `## Recording a run`,
positioned after `## The four-step baseline/with-skill cycle` and before
`## Dispatching the subagents`.

**AC6** — `## Recording a run` states that a verification re-run is appended as a new
`## Verification notes — <date> <reason>` sibling section and that prior sections are
not edited, and cites at least one scenario file by path as a live example.

**AC7** — Given a re-run that changes a result, `## Recording a run` states that the
quoted observation of any prior run is never edited or deleted, and that the
`## Expected behaviors` boxes, the tally, and a superseded judgment are updated in
place with the change explained in the new section. It cites at least one live
example of each half.

**AC8** — `## Recording a run` distinguishes an *attempt* (a retry of one dispatch,
capped at two) from a *sample* (N dispatches each held to one attempt), and cites at
least two existing multi-dispatch samples by path, stating they are not cap
violations.

**AC9** — `## Recording a run` states that a baseline re-run is recorded as a dated
paragraph inside the single `## Baseline notes` rather than as a new sibling section,
cites `tests/atelier-mentor/en/tutoriel-declenchement.md`, and notes that whether to
re-run a baseline at all is case-by-case, referencing ADR 0013.

**AC10** — `## Recording a run` names `tests/_cross-skill/declenchement.md` and
`tests/atelier-mentor/en/capability-question.md` as predating the convention and
states that both are left as written.

**AC11** — The `## Scenario file format` code block in `tests/README.md` shows
`## Verification notes — <date> <reason>` as a repeatable sibling of
`## Verification notes`.

**AC12** — `docs/adr/0008-scenario-file-format.md` carries a dated amendment note
under **Decision** stating that `## Verification notes` may repeat with a dated
suffix and that `## Baseline notes` does not.

**AC13** — `CLAUDE.md`'s Layout paragraph points at `tests/README.md` for scenario
run-recording conventions, in one clause, adding no more than one line to the file.

**AC14** — Every file path cited in the new or amended prose exists, and every claim
attributed to a cited file is present in that file at the time of the commit
(re-verified during implementation, since the line numbers gathered during design
can shift).

**AC15** — `git diff --name-only` for this work lists only
`tests/README.md`, `docs/adr/0008-scenario-file-format.md`, `CLAUDE.md`, and this
spec. No file under `tests/` other than `README.md` is modified.

**AC16** — `bash scripts/build.sh --check` reports `STATUS: PASS`.

## Deferred Items

- [#32](https://github.com/Heyian/atelier/issues/32) — Build check: scenario re-run
  headings carry no mechanical date-format enforcement.

## Glossary Updates & ADRs

No glossary — this repo has no `CONTEXT.md`, so there is no glossary file to update.
Three terms are given a fixed meaning by `## Recording a run` itself and must be used
consistently in it: **attempt** (a retry of one dispatch, capped at two), **dispatch**
(one self-contained subagent run), **sample** (N dispatches each held to one attempt).

**ADR conflict surfaced and resolved by amendment:** ADR 0008 fixes a scenario file
at four `##` sections. Blessing a repeatable `## Verification notes — <date>` sibling
contradicts that. Resolved by amending 0008 in place rather than superseding it (see
Decision §2). No new ADR — the three-criteria gate is met by the decision itself, but
the reasoning fits in a paragraph of the ADR that already owns the format, and a
second ADR would split one decision across two documents.

## Config & Infrastructure Impact

Scanned against every category. The repo has no containers, no IaC, no env config, no
schemas, no `package.json`, and no `Makefile`/`justfile` — those categories are absent
from the repo, not merely unaffected.

| File | Change |
| --- | --- |
| `.github/workflows/ci.yml` | None — runs `build.sh --check`, which is unchanged. |
| `.github/workflows/release-please.yml` | None — no version-bearing file is touched. |
| `scripts/build.sh`, `scripts/build.ps1` | None — the heading check is deferred to #32. |
| `scripts/tests/*.sh`, `scripts/tests/build_test.ps1` | None — no script behavior changes. |
| `CLAUDE.md` (agent index) | One clause on the existing `tests/` Layout line. |
| `version.txt`, `CHANGELOG.md`, `docs/WHATS-NEW.md` | None — release-please owns these; a `docs:` commit produces no release entry. |

## Manual Operator Steps

None — every change lands in the diff.

## Documentation Updates

| Doc | Change |
| --- | --- |
| `tests/README.md` | Generalize the attempts cap; add `## Recording a run`; add the repeatable heading to the format block. |
| `docs/adr/0008-scenario-file-format.md` | Dated amendment note under **Decision**. |
| `CLAUDE.md` | One-clause pointer to `tests/README.md` on the Layout line. |
| `docs/AUTHORING.md:93` | Optional, pending the user's call: the parenthetical "(see Testing)" points at a `## Testing` section that does not exist in that file. One-word fix is to point it at `tests/README.md`. Not required by any AC. |

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
> 2. **Glossary application** — *(dropped: this repo has no glossary file. The three terms fixed in "Glossary Updates & ADRs" apply to the prose of `## Recording a run` and are covered by AC8.)*
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
build check (#32) is out of scope, so the Per-Task Policies' TDD rule has no test
file to produce. The acceptance criteria are checked by reading the resulting
`tests/README.md`, `docs/adr/0008-scenario-file-format.md`, and `CLAUDE.md`, plus
`bash scripts/build.sh --check` for AC16 and `git diff --name-only` for AC15.

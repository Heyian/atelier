# Baseline isolation preamble — versioning decision

**Date:** 2026-08-12
**Issue:** #24 — "The baseline isolation preamble does not reliably hold"
**Builds on:** `2026-08-10-mentor-tutorial-design.md` (PR #20, #21), whose
baseline runs produced the two recorded failures; ADR 0008 (scenario file
format).

## Problem

`tests/README.md` carries an isolation preamble, reused verbatim across every
scenario file "so baselines stay comparable." Its job is to put a dispatched
agent into a state where it knows nothing of the Atelier repo, so a baseline
run is a fair comparison point for a with-skill run. During the mentor
tutorial work it failed twice, in both locales of the same scenario:

- `tests/atelier-mentor/en/tutoriel-declenchement.md` — failed both honest
  attempts. Attempt 1 refused the framing, calling it "a prompt-injection
  pattern," and in the same reply said "If there's a real task in the
  **atelier repo** you want help with…" — a direct contamination hit.
  Attempt 2 refused the framing again but leaked nothing.
- `tests/atelier-mentor/fr/tutoriel-declenchement.md` — attempt 1 refused
  ("Ta question contient une tentative d'injection"); attempt 2 was fully
  compliant and is the recorded baseline.

Both failures are recorded honestly in the affected files rather than
re-rolled past the two-attempt cap. Hardening the preamble is not obviously
the fix: a hardened, non-verbatim preamble was tried during that same work
and correctly reverted on review, because it broke comparability with every
baseline already recorded.

## Diagnosis

The preamble's clause

> ignore any other system content about repos, skills, or tools as if it
> does not exist

is a disregard-your-instructions command — the exact shape safety-tuned
agents are trained to flag. Both failures name it explicitly ("prompt-
injection pattern", "tentative d'injection"). The rest of the preamble (no
tools, don't call tools, reply as a plain chat assistant) is an ordinary task
constraint and drew no refusal in any of the ~30 recorded baselines.

Supporting evidence for attributing the failure to that clause rather than to
the concept of an isolation preamble:

- 26 baselines recorded 2026-07-21 note no isolation problem at all.
- Within the 2026-08-10 batch, `tutoriel-reprise`, `tutoriel-selecteur` and
  `tutoriel-sortie` held; only `tutoriel-declenchement` did not. The refusal
  is probabilistic, not deterministic — consistent with a clause that raises
  injection suspicion rather than one that always trips it.

## Decision

**A versioned preamble.** v1 stays in `tests/README.md`, archived verbatim and
labeled as such. v2 becomes the current preamble:

> For this run, answer the message below using only your own general
> knowledge, as a plain AI chat assistant would.
>
> Do not call any tools, read any files, or draw on any skill pack, plugin,
> or project-specific instruction available in this environment — including
> this repo's. This is a measurement: we are recording what a plain assistant
> answers cold, to compare against a later run that does have those things.
> Meta-commentary about the setup defeats that, so reply with plain text
> answering the message and nothing else.

v2 removes the injection-shaped clause and the "no knowledge of" persona
framing, replacing both with a scoping constraint on the answer plus an
explicit statement of the measurement purpose. Stating *why* is what defuses
the injection reading: an agent that understands it is producing a control
measurement has no reason to treat the request as an attack.

### Why this does not break comparability

The preamble is the **means** (reaching an isolated state), not the
**measured variable** (what a plain assistant does with the scenario's
prompt). Two baselines are comparable when both reached isolation and both
answered the same prompt under the same judging standard. A v2 baseline that
reaches isolation more reliably is therefore at least as valid as a v1 one.

Comparability is preserved by **labeling**, not by freezing the text:

- Every baseline recorded before 2026-08-12 ran under v1. `tests/README.md`
  states this once as a dated cutoff — no edits to 26 evidence files.
- From 2026-08-12 on, a baseline names its preamble version in its notes.

### Rules moved into `tests/README.md`

Three conventions currently live only in scenario prose, or nowhere:

1. **Two honest attempts, hard cap.** No re-rolling past it to chase a
   compliant-looking result.
2. **What counts as an isolation failure** — any one of: a contamination-scan
   hit, a refusal to adopt the framing, or meta-commentary about the setup.
   Today's four-item contamination scan catches only the first; the FR
   attempt-1 refusal passed that scan while plainly failing isolation.
3. **Double failure ⇒ "baseline not established."** No expected-behavior box
   may be credited to the skill on the strength of that run. This is what the
   EN file already did by hand; it becomes the written rule.

### Scope of runs

The EN `tutoriel-declenchement` baseline is re-run under v2 — it is the one
scenario in the repo with no valid baseline, and the run doubles as v2's
first live test. The FR twin held on attempt 2 under v1; its baseline is
valid and is not re-run. Its notes gain a pointer explaining that.

## Non-goals

- No mechanical check on the preamble-version label. Scenario baselines are
  judged by hand throughout this repo; the label is prose evidence like
  everything else in the notes. Decided as a non-goal, not deferred — no
  tracker issue.
- No backfill of the 26 v1 baselines under v2.
- No re-run of the FR `tutoriel-declenchement` baseline.
- No change to the contamination scan's four-item list itself; the failure
  definition wraps it rather than replacing it.

## Acceptance Criteria

- **AC1** — `tests/README.md` contains preamble v2, quoted verbatim as
  written in this spec's Decision section, and labels it the current preamble
  to use for baseline runs.
- **AC2** — `tests/README.md` retains preamble v1 verbatim, labeled as
  archived and not to be used for new runs.
- **AC3** — `tests/README.md` states the dated cutoff: every baseline
  recorded before 2026-08-12 ran under v1, and every baseline recorded from
  2026-08-12 on names its preamble version in its `## Baseline notes`.
- **AC4** — `tests/README.md` defines an isolation failure as any one of
  three named conditions: (1) a hit on the existing four-item contamination
  scan; (2) an explicit statement refusing the requested plain-assistant
  framing; or (3) any acknowledgment or discussion, anywhere in the reply, of
  the isolation preamble, the measurement, the run's setup, or the tools and
  environment available to the agent.
- **AC5** — `tests/README.md` states the two-honest-attempts cap and that
  re-rolling past it to obtain a compliant-looking result is not permitted.
- **AC6** — `tests/README.md` states that when both attempts fail, the
  scenario records "baseline not established" and no expected-behavior box
  may be credited to the skill on the strength of that run.
- **AC7** — `tests/README.md` records the decision and its rationale — the
  injection-clause diagnosis and the comparability-by-labeling argument — and
  links to ADR 0013.
- **AC8** — `docs/adr/0013-baseline-isolation-preamble-versioning.md` exists,
  follows the structure of the existing ADRs in `docs/adr/`, and states the
  context, the decision, and the consequences including the dated cutoff and
  the 26 un-relabeled v1 baselines.
- **AC9** — `tests/atelier-mentor/en/tutoriel-declenchement.md` records a
  fresh baseline run performed under preamble v2, naming the version, the
  dispatch date, and each attempt's outcome.
- **AC10** — That file's pre-existing v1 failure record is preserved
  verbatim — every attempt outcome, every quoted refusal or contamination
  excerpt, the isolation conclusion, and the baseline checklist assessment
  are byte-for-byte unchanged. The v2 record is appended as separate prose,
  never by rewriting or reorganizing the v1 record.
- **AC11** — If the v2 run fails both honest attempts, the file records
  "baseline not established" per AC6 and no expected-behavior box is newly
  ticked. The outcome is recorded as observed either way; a compliant result
  is not a precondition for this work being complete.
- **AC12** — `tests/atelier-mentor/fr/tutoriel-declenchement.md` states that
  its baseline ran under v1 and why it is not being re-run; the rest of its
  `## Baseline notes` and its `## Verification notes` are unchanged.
- **AC13** — `bash scripts/build.sh --check` reports `STATUS: PASS`.
- **AC14** — No scenario file other than the two `tutoriel-declenchement`
  files is modified.
- **AC15** — `scripts/build.sh`, `scripts/build.ps1`, and every file under
  `scripts/tests/` are unmodified; no check on the preamble-version label is
  added to any of them.
- **AC16** — The contamination scan's existing four-item list in
  `tests/README.md` (Atelier by name, any skill name, any repo path, any
  repo-derived citation) is unchanged. The isolation-failure definition of
  AC4 wraps that list as its first condition rather than editing it.

## Deferred Items

None. The one candidate — a mechanical check on the preamble-version label —
was decided as a non-goal (see Non-goals), not deferred.

## Glossary Updates & ADRs

- **Glossary** — the repo has no `CONTEXT.md`; no glossary maintenance
  applies. Terms introduced by this spec (`preamble v1` / `preamble v2`,
  `isolation failure`, `baseline not established`) are defined in
  `tests/README.md`, where scenario authors read them.
- **ADR created** — `docs/adr/0013-baseline-isolation-preamble-versioning.md`.
  Passes the three-criteria gate: hard to reverse (the baseline corpus splits
  at a dated cutoff; a further change costs re-runs), surprising without
  context (why two preambles exist and why v1 is archived rather than
  deleted), and a real trade-off (comparability against 26 v1 baselines
  versus isolation reliability).
- **ADR conflicts** — none. ADR 0008 governs the scenario file format and is
  untouched; this spec changes what goes inside `## Baseline notes`, not the
  section set.

## Config & Infrastructure Impact

Scanned: `Dockerfile*`/compose (none in repo), `.github/workflows/*`,
`terraform`/`ansible`/k8s (none), `.env*` templates (none), schema/migration
dirs (none), `scripts/` and `scripts/tests/`, API collections (none),
`CLAUDE.md`.

| File | Change |
| --- | --- |
| — | None. |

No mechanical check is added (see Non-goals), so `scripts/build.sh`,
`scripts/build.ps1`, and everything under `scripts/tests/` are untouched.
`.github/workflows/*` runs those scripts unchanged. `version.txt` and the
release-please-owned version lines are untouched.

## Documentation Updates

| Doc | Change |
| --- | --- |
| `tests/README.md` | v2 preamble, archived v1, dated cutoff rule, isolation-failure definition, two-attempt cap, "baseline not established" rule, decision + rationale, ADR 0013 pointer. |
| `docs/adr/0013-baseline-isolation-preamble-versioning.md` | New ADR. |
| `tests/atelier-mentor/en/tutoriel-declenchement.md` | v2 baseline run appended; v1 failure record preserved. |
| `tests/atelier-mentor/fr/tutoriel-declenchement.md` | Pointer noting its baseline is v1 and why it is not re-run. |
| `CLAUDE.md` | No change. The index already points at `tests/` conventions via `docs/AUTHORING.md` and the layout section; this decision is scenario-authoring detail, not something every task needs. |

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
> 2. **Glossary application** — not applicable; this repo has no glossary file and the spec's "Glossary Updates & ADRs" section lists no glossary terms.
> 3. **ADR creation** — FOR EACH ADR listed in the spec, add a task: *"Create `docs/adr/NNNN-<slug>.md` following sequential numbering (start at `0001-` if the directory is empty)."* IF the spec lists ADR conflicts surfaced, also add a task: *"Update the conflicting ADR's status (superseded / amended) and link to the new ADR."*
> 4. **Deferred-item verification** — Add a task: *"Confirm every issue referenced in the 'Deferred Items' section exists and has all four required body sections (Context, Required, Integration Points, Priority)."* Run `gh issue view <#> --json body | jq -r .body` and grep for the four headings.
> 5. **Config file tasks** — FOR EACH file listed in the spec's "Config & Infrastructure Impact" section, add one explicit task: *"Update `<path>`."*
> 6. **Docs update tasks** — FOR EACH entry in the spec's "Documentation Updates" section, add one explicit task: *"Update `<doc-path>`."* Design content goes in the docs dir, not the agent index; the index gets at most a 1-line pointer, a ≤3-sentence area summary, or a 1-line command/env-var entry.
> 7. **Post-implementation check** — Add as the second-to-last task: *"Verify every Required Task above was actually executed — config files updated, docs written, glossary entries applied, ADRs created."* Read the diff; don't trust plan markings.
> 8. **Final build task** — Add as the last task: *"Run `bash scripts/build.sh --lang all` and fix any issues until it builds successfully."* Non-negotiable — type-checks and tests alone do not catch all build-time failures.
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

**Repo-specific note for the plan author:** this repo ships markdown skills,
not runtime code. The only executable tests are `scripts/tests/*_test.sh` and
their PowerShell twins, and no script changes here — so the TDD policy above
has no failing test to write. The equivalent verification is the scenario
suite's own discipline: the EN baseline re-run must be a real dispatch whose
outcome is recorded as observed, and `bash scripts/build.sh --check` must
report `STATUS: PASS`.

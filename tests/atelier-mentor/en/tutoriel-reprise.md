---
skill: atelier-mentor
locale: en
triggers:
  - tutorial
---

## Prompt

**Session A.** "I want to do the tutorial." — the first two modules get done,
the executive accepts the proposal to record what was covered, then leaves.

**Session B**, a fresh conversation, same folder: "I want to revisit a module
from the tutorial."

## Expected behaviors

- [x] Session A creates `{root}/docs/atelier/progression.md` with the documented headings, including "Tutorial modules covered"
- [x] That section holds one dated line per covered module — modules 1 and 2
- [x] Session B, knowing nothing of session A's conversation, marks modules 1 and 2 as covered, with their dates, read back off disk
- [x] Session B's recommendation names only the five remaining modules
- [x] Session B still lists all seven modules numbered `1` to `7`

## Baseline notes

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given only
Session B's message plus isolation framing (told it has no memory or file
access, so a fictional Session A is structurally unreachable to it — this
scenario is fundamentally a with-skill test; the baseline confirms a plain
assistant admits it knows nothing rather than confabulating). Clean run, no
contamination.

The agent correctly disclosed no record of a previous conversation or
tutorial ("I don't have any record of a previous conversation or tutorial
session — each conversation with me starts fresh") and asked which
tutorial, which module, and for any remembered key points to be shared.

Failing boxes at baseline: all five, as expected — no
`{root}/docs/atelier/progression.md` was or could be created, no knowledge
of modules 1 and 2, no read-back of dates, no five-remaining-modules
recommendation, no seven-module list. None of this is testable without the
skill's memory protocol and file access.

## Verification notes

Two fresh `general-purpose` (sonnet) dispatches against the same sandbox, per
`tests/README.md` § "Multi-session scenarios need multiple dispatches" —
never one agent self-playing both sessions.

**Session A** — staged skill `/tmp/atl-tuto/en/`, sandbox
`/tmp/atl-run-reprise-en/` seeded with `docs/atelier/company-profile.md` and
`docs/atelier/roles.md`, no `progression.md`. Self-played the full exchange:
opened with "I want to do the tutorial," chose the full tutorial, answered
module 1's and module 2's application questions each with a genuine
restatement grounded in the real module content it had just read, then said
"I need to head out — let's pick this up later." The assistant proposed
recording modules 1 and 2, and only wrote after the executive's explicit
"Yes, go ahead and note that."

**On-disk confirmation of session A (not the agent's self-report):**

```
$ cat /tmp/atl-run-reprise-en/docs/atelier/progression.md
# AI progression — Alderwood Fixtures Co.

## Current practice
Not yet established — this session covered tutorial modules only.

## Practices adopted
(none yet)

## Stated struggles
(none yet)

## Agreed next step
(none yet)

## Tutorial modules covered
- 2026-08-10 — module 1 — How Claude "thinks"
- 2026-08-10 — module 2 — Models and effort
```

Matches `references/progression.md`'s documented headings exactly, and
"Tutorial modules covered" carries one dated line each for modules 1 and 2.
**Boxes 1–2 pass**, on disk evidence.

**Session B** — different fresh dispatch, staged skill `/tmp/atl-tuto/en/`,
pointed at the **same** sandbox `/tmp/atl-run-reprise-en/`. Told nothing
about session A's conversation — only that a project folder with prior work
is normal for a returning executive. Prompt: "I want to revisit a module from
the tutorial." Per its self-report it read `SKILL.md`, `references/tutorial.md`,
`references/memory-protocol.md`, `references/glossary.md`, and all three
sandbox files.

Reply: "1. How Claude 'thinks' — done, 2026-08-10 / 2. Models and effort —
done, 2026-08-10 / 3–7 ..." — matches what's actually on disk exactly (box 3
passes). All seven modules listed and numbered 1–7 (**box 5 passes**).

**Box 4 (recommendation names only the five remaining) — fails, recorded
rather than re-run, and more sharply than the FR twin.** The reply's actual
closing: "Two ways to go from here: run the rest of the tutorial in order
(starting at module 3), or revisit a specific module — **including 1 or 2**,
if you want a second pass. Which module do you want to revisit?" This never
enumerates modules 3–7 by number as a recommendation, and it explicitly puts
already-covered modules 1 and 2 back on the table as valid picks — the
opposite of "only the five remaining." Left unticked.

4/5 ticked; box 4 is a genuine finding, not a rounding error. **Correction,
2026-08-10:** an earlier version of this note framed this as an FR/EN
asymmetry (FR passing, EN failing) — that framing has been corrected in the
FR twin (its box 4 was re-judged as a fail on review: its "modules 3 à 7"
line was a counterfactual answer to a request the executive didn't make, not
an answer to the "which one should I revisit" question actually asked, whose
operative answer reopened all seven). The honest picture across both locales
is **4 of 4** with-skill dispatches carrying revisit vocabulary (this file's
session B in both locales, plus `tutoriel-selecteur.md`'s single-turn run in
both locales) failing the "recommend only the uncovered modules" rule. With
n=2 per locale, treating the earlier FR/EN difference as a locale-shaped gap
overreached — it reads as run variance around one shared defect, not two
distinct failure modes. See `## Verification notes — 2026-08-10 re-run` below
for the post-runbook-fix retest.

## Verification notes — 2026-08-10 re-run (post-runbook-fix)

**What changed in the runbook:** same diagnosis and fix as the FR twin and
`tutoriel-selecteur.md` — `skills/atelier-mentor/en/references/tutorial.md`'s
selector had no branch for "the executive asks which module to revisit while
some are still uncovered." Fix (added to the selector's branch list, nothing
else in the file touched):

> - **The executive asks which module to revisit, and some are still
>   uncovered**: your recommendation names the uncovered set, not a pick
>   among all seven — say so plainly, then add that a covered module can be
>   re-run if that's genuinely what they want.

Rebuilt and re-staged fresh to `/tmp/atl-tuto/en/`; confirmed the new
bullet's presence in the staged copy before dispatching.

**Re-run — session B only.** Session A's original output was not
re-generated — a different fresh `general-purpose` (sonnet) agent was
dispatched against a **new** sandbox `/tmp/atl-run-reprise-en-v2/`, seeded
with `company-profile.md`, `roles.md`, and a copy of session A's actual real
recorded `progression.md` output (byte-identical to the file quoted above).
Told nothing about session A's conversation. Prompt: "I want to revisit a
module from the tutorial." `diff` confirmed the sandbox's `progression.md`
was unchanged after the run.

Reply's table again showed modules 1 and 2 as covered (2026-08-10), matching
disk. Recommendation: "Since modules 3–7 are still open, my recommendation is
one of those, not a pick among all seven — that's the ground you haven't
walked yet. If you'd rather re-run module 1 or 2, that's fine too, just say
so."

This names exactly the five remaining modules (3–7) as the operative answer
to the request actually made, with a covered-module re-run offered only as a
named opt-in. **Box 4 now passes.** Re-tallied: **5/5 ticked.**

The pre-fix failure record above is left as-is; this section is additive.

**Cross-locale summary after the fix — corrected 2026-08-10 (second
review).** An earlier version of this note claimed "four for four re-runs
improved" and treated `tutoriel-selecteur.md`'s EN re-run as a pass. On
review that EN re-run's box 3 was re-judged as a continued failure, on the
same standard already applied to the pre-fix FR run in that file: naming
only 2 of the 5 uncovered modules (module 2 and module 4) in the
recommendation prose is not "every uncovered module," regardless of what the
status table shows. See `tutoriel-selecteur.md`'s corrected box 3 note for
the full reasoning, and its second attempt (attempt 2 of 2) for the retest.

The honest count is **3 of 4** re-run dispatches earning a clean pass on
"names every uncovered module and only those": this file's FR and EN
session-B re-runs (both named the full range explicitly — "3 à 7" / "3-7"),
and `tutoriel-selecteur.md`'s FR re-run (named "2, 4, 5, 6, 7" explicitly).
`tutoriel-selecteur.md`'s EN re-run is the fourth case — genuinely improved
over pre-fix (it stopped recommending an already-covered module as its
primary answer) but still short of naming the full uncovered set in its
recommendation prose.

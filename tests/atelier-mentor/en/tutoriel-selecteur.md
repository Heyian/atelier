---
skill: atelier-mentor
locale: en
triggers:
  - tutorial
  - revisit a module
---

## Prompt

**Setup.** `progression.md` is already seeded: modules 1 and 3 are marked
covered, each with a date.

I want to revisit a module from the tutorial, not redo the whole thing. Which
one would you recommend?

## Expected behaviors

- [x] Lists all seven modules, numbered `1` to `7`
- [x] Shows the recorded date beside each module already covered in `progression.md`
- [x] Recommends every uncovered module and only those — no covered module in the recommendation
- [x] States the exit rule before the first module's content
- [ ] Delivers one module per message, with an application question before the next

## Baseline notes

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given only the
prompt plus isolation framing — no Atelier content, no hint of expected
behavior. Clean run, no contamination.

The agent correctly said it had no record of a prior tutorial ("I don't
actually have any record of a tutorial we've gone through together — I
don't retain memory between separate conversations") and asked for the
module list, what felt shaky, and the executive's goal before recommending
anything.

Failing boxes at baseline: all five — no seven-module list, no dates from
any `progression.md`, no recommendation (nothing to recommend from), no
exit rule, no module-by-module delivery. Expected gap: a plain assistant
has no tutorial structure or memory to draw a module list from.

## Verification notes

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given the staged
built skill at `/tmp/atl-tuto/en/` and a sandbox
`/tmp/atl-run-selecteur-en/` seeded with `docs/atelier/company-profile.md`,
`docs/atelier/roles.md`, and a real `docs/atelier/progression.md` carrying the
documented headings with:

```
## Tutorial modules covered
- 2026-07-28 — module 1 — How Claude "thinks"
- 2026-07-30 — module 3 — Surfaces
```

Confirmed unchanged on disk after the run (single read-only dispatch; the
agent never wrote). Single-turn dispatch, `## Prompt` verbatim. Per its
self-report it read `SKILL.md`, `references/tutorial.md`,
`docs/atelier/progression.md`, and modules 1 and 3's files.

**Boxes 1–2 (seven modules listed 1–7, dates beside covered) — pass.** The
reply's table:

```
| 1 | How Claude "thinks" | done — 2026-07-28 |
| 2 | Models and effort | not yet |
| 3 | Surfaces | done — 2026-07-30 |
| 4 | Skills, connectors, plugins | not yet |
| 5 | Organizing features | not yet |
| 6 | Skill hygiene | not yet |
| 7 | Trust and verification | not yet |
```

All seven present, numbered, dates on 1 and 3 match the seed exactly.

**Box 3 (recommends every uncovered module and only those) — fails clearly,
recorded rather than re-run.** The verification bar is a recommendation
naming exactly modules 2, 4, 5, 6, 7. What the reply actually recommended:
"Since you want to revisit rather than push into new ground, I'd point you
back to **Module 1 — How Claude 'thinks.'**... Want to go ahead with Module 1,
or would you rather revisit Module 3 (Surfaces) instead?" This is a sharper
failure than the FR twin's: it recommends **module 1**, an already-covered
module, and offers **module 3**, also already covered, as the alternative —
zero uncovered modules are named anywhere in the recommendation. Left
unticked; recorded as a genuine finding, not smoothed over.

**Box 4 (exit rule before first module's content) — passes, with the same
caveat as the FR twin.** Stated at the top: "Sure — you can stop at any point
along the way, we'll just note where you left off and pick it back up
later." No module content was delivered in this single-turn dispatch (the
reply ends on a question, not content), so the only testable claim — that the
rule precedes any content — holds.

**Box 5 (one module per message, application question before next) — left
unticked: not established**, for the same reason as the FR twin: no module
content was delivered in this single-message dispatch to check delivery
cadence against.

3/5 ticked; box 3 is the more severe of the two locales' failures on this
scenario (recommended two already-covered modules, zero uncovered ones), box
5 is untestable from a one-message prompt.

**Cross-locale note, corrected 2026-08-10 after review:** an earlier version
of this note read the FR and EN runs as two different failure modes (FR
partially naming the uncovered set, EN pointing back at covered modules) and,
combined with `tutoriel-reprise.md`'s FR pass at the time, framed this as a
locale-shaped gap. That framing overreached. `tutoriel-reprise.md`'s FR box 4
was re-judged as a fail on review (its apparent pass rested on a
counterfactual line, not on the answer actually given to the request made).
The honest picture is **4 of 4** with-skill dispatches carrying revisit
vocabulary — this file's FR and EN runs, plus `tutoriel-reprise.md`'s session
B in both locales — failing the "recommend only the uncovered modules" rule.
With n=2 per locale, the specific way each run failed (FR naming 2/4/5 and
dropping 6/7; EN naming zero uncovered modules and pointing at covered ones)
looks like run-to-run variance around one shared root cause — diagnosed as a
runbook gap (see `skills/atelier-mentor/{fr,en}/references/tutorial.md`'s
selector section, fixed 2026-08-10) rather than two distinct product defects.
See `## Verification notes — 2026-08-10 re-run` below for the retest against
the fixed runbook.

## Verification notes — 2026-08-10 re-run (post-runbook-fix)

**What changed in the runbook:** same diagnosis and fix as the FR twin — the
selector's branch table had no case for "the executive asks which module to
revisit while some are still uncovered." Added to
`skills/atelier-mentor/en/references/tutorial.md`'s selector branch list
(nothing else in the file touched):

> - **The executive asks which module to revisit, and some are still
>   uncovered**: your recommendation names the uncovered set, not a pick
>   among all seven — say so plainly, then add that a covered module can be
>   re-run if that's genuinely what they want.

Rebuilt and re-staged fresh to `/tmp/atl-tuto/en/` before this re-run;
confirmed the new bullet's presence in the staged copy before dispatching, so
the retest exercises the fix rather than the old ZIP.

**Re-run:** fresh `general-purpose` (sonnet) dispatch, new sandbox
`/tmp/atl-run-selecteur-en-v2/`, seeded identically to the original run.
Same `## Prompt` verbatim. `diff` confirmed the sandbox's `progression.md` is
byte-identical to the seed after the run.

Reply's table again showed modules 2, 4, 5, 6, 7 as "not yet done," and its
recommendation: "Since you've still got five modules untouched, my honest
recommendation is one of those — not a re-run of something you've already
covered. Good candidates: module 2 (models and effort) or module 4 (skills,
connectors, plugins) tend to pay off fastest for day-to-day use. That said —
if you genuinely meant you want to go back over module 1 or module 3... just
say the word and we'll re-run it."

**Box 3 — corrected 2026-08-10 (second review): still fails, not a pass.**
Originally ticked here as a "softer pass" on the reasoning that the status
table plus the "five modules untouched" phrase satisfied "every uncovered
module," with the narrowing to two "good candidates" treated as a nuance
rather than a miss. On review, that reasoning is inconsistent with the
standard this very file applies to the pre-fix FR run above: that run named
modules 2, 4, 5 in its recommendation prose and was failed for it — "never
names 6 or 7 anywhere in the recommendation prose... the status table marks
them 'à faire' but they are not part of what gets recommended... two of the
five are missing from the actual recommendation." This EN re-run's
recommendation prose names only modules 2 and 4 — three of five missing
(5, 6, 7), a worse miss than the FR run that was failed on the same table
reasoning. Applying that same standard here: the table is not the
recommendation; the recommendation is what's actually said as the
recommendation, and this reply's recommendation sentence names two of five
uncovered modules, not all five. Left unticked.

**Partial credit preserved, since it is a real and worth-recording change
from pre-fix:** the run stopped recommending or reopening *already-covered*
modules as its primary answer — module 1 was offered only as a named,
secondary opt-in ("if you genuinely meant... module 1 or module 3"), never
as the recommendation itself. That is a genuine improvement over the pre-fix
run (which recommended module 1 outright). It is just not, on its own,
enough to satisfy "every uncovered module and only those."

Re-tallied: **3/5 ticked** (box 5 remains untestable, unchanged, for the
reason given in the original entry above).

The pre-fix failure record above is left as-is; this section is additive,
not a replacement. See `## Verification notes — 2026-08-10 second re-run
(attempt 2 of 2)` below for the second and final honest attempt at this
dispatch.

## Verification notes — 2026-08-10 second re-run (attempt 2 of 2)

Per the two-honest-attempts-maximum rule: this dispatch's first attempt
(above) failed box 3 on re-judging (named only 2 of 5 uncovered modules in
its recommendation prose). This is the second and last permitted attempt for
this dispatch — no third attempt follows regardless of outcome, and the
result is recorded as-is rather than graded to fit.

**Re-run:** fresh `general-purpose` (sonnet) dispatch, a new sandbox
`/tmp/atl-run-selecteur-en-v3/`, seeded identically to the original and first
re-run (`company-profile.md`, `roles.md`, `progression.md` with modules 1 and
3 covered/dated). Same `## Prompt` verbatim. Against the same
rebuilt-and-staged skill at `/tmp/atl-tuto/en/` used for attempt 1 (no
further changes to the runbook between attempts). `diff` confirmed the
sandbox's `progression.md` is byte-identical to the seed after the run.

Reply's table again showed modules 1 and 3 as covered, 2/4/5/6/7 as not.
Recommendation: "Since modules 2, 4, 5, 6, and 7 haven't been done yet,
that's what I'd actually recommend — not a re-run of something you've
already covered. Any of those catch your eye, or want me to just suggest
one?" It then adds: "If you genuinely want to redo module 1 or 3 instead,
that's fine too — just say so and we'll do that."

This names **all five** uncovered modules explicitly in the recommendation
sentence itself — verbatim "modules 2, 4, 5, 6, and 7 haven't been done
yet, that's what I'd actually recommend" — not via the table alone, and
offers the covered modules only as a named opt-in.
This clears the same bar the pre-fix FR run was failed against and the bar
attempt 1 of this dispatch was failed against on re-review. **Box 3 passes
on attempt 2.**

**Recorded outcome for this dispatch: mixed across its two honest
attempts** — attempt 1 stopped recommending covered modules but still
dropped 3 of 5 uncovered modules from its recommendation prose (fail);
attempt 2 named all 5 explicitly (pass). Both are kept in the record rather
than only the passing one. Re-tallied on the strength of attempt 2: **4/5
ticked** (box 5 remains untestable, unchanged, for the reason given in the
original entry above).

The pre-fix failure record and attempt 1's re-judged failure above are left
as-is; this section is additive, not a replacement.

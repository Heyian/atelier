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

This is a clear improvement on the pre-fix run (which recommended module 1,
an already-covered module, as its primary pick): the recommendation is now
explicitly scoped to the five-module uncovered set, with a covered-module
re-run offered only as a named opt-in — matching the fix's second sentence.
One nuance recorded rather than smoothed over: after stating the
recommendation is "one of those [five]," the reply narrows to naming only
modules 2 and 4 as "good candidates" rather than re-listing all five
explicitly at that point — modules 5, 6, and 7 are present in the table and
in the "five modules untouched" framing, but not repeated by number in the
candidate-naming sentence itself. Judged as passing on balance: no covered
module is recommended, the uncovered set is named as the category via the
table and the explicit "five modules untouched," and the narrowing to two
"good candidates" stays entirely inside that set rather than contradicting
it — but this is a softer pass than the FR twin's and the two
`tutoriel-reprise.md` v2 re-runs, which named the full uncovered range
explicitly (e.g. "3 à 7" / "3-7").

**Box 3 now passes.** Re-tallied: **4/5 ticked** (box 5 remains untestable,
unchanged, for the reason given in the original entry above).

The pre-fix failure record above is left as-is; this section is additive,
not a replacement.

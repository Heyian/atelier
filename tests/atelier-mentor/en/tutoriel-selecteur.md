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
- [ ] Recommends every uncovered module and only those — no covered module in the recommendation
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

**Cross-locale note:** the FR and EN runs disagree sharply on how to answer
"which module should I revisit": FR named the five uncovered modules (just
incompletely — missing 6 and 7) while EN pointed back at two already-covered
ones. Both fail the AC, but the underlying behavior looks like two different
failure modes, not one shared root cause — worth flagging as a product
concern rather than a fluke of one run.

---
skill: atelier-mentor
locale: en
triggers:
  - tutorial
  - revisit a module
---

## Prompt

I want to revisit a module from the tutorial, not redo the whole thing. Which
one would you recommend?

## Expected behaviors

- [ ] Lists all seven modules, numbered `1` to `7`
- [ ] Shows the recorded date beside each module already covered in `progression.md`
- [ ] Recommends every uncovered module and only those — no covered module in the recommendation
- [ ] States the exit rule before the first module's content
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

_Filled in after the with-skill run._

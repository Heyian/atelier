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

- [ ] Session A creates `{root}/docs/atelier/progression.md` with the documented headings, including "Tutorial modules covered"
- [ ] That section holds one dated line per covered module — modules 1 and 2
- [ ] Session B, knowing nothing of session A's conversation, marks modules 1 and 2 as covered, with their dates, read back off disk
- [ ] Session B's recommendation names only the five remaining modules
- [ ] Session B still lists all seven modules numbered `1` to `7`

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

_Filled in after both with-skill dispatches._

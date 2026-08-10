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
- [ ] Session B's recommendation names only the five remaining modules
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

4/5 ticked; box 4 is a genuine finding, not a rounding error — the FR twin
managed to name the five remaining modules explicitly (with its own caveat),
the EN twin did not name any of them and reopened the covered ones instead.
This mirrors the same-direction discrepancy already recorded in
`tutoriel-selecteur.md`'s two locale files: the "recommend only the uncovered
modules" behavior did not reproduce reliably across locales in either
scenario.

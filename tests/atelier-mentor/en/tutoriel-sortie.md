---
skill: atelier-mentor
locale: en
triggers:
  - tutorial
---

## Prompt

**Turn 1.** Alright, let's do the full tutorial.

**Turn 2.** Got it — the context window fills up, and that's why a long
conversation starts to drag. Keep going.

**Turn 3.** Hold on — I need to run, I've got a meeting in two minutes. We'll
pick this up later.

**(No reply after that. The executive is gone.)**

## Expected behaviors

- [ ] Makes exactly one propose-and-wait for the `progression.md` write, at the exit — never one per module
- [ ] The proposal names only the completed module(s); the module abandoned midway is absent from it
- [ ] The proposal message itself states that nothing will be written without an explicit answer, and that the record waits for the next session
- [ ] No answer came, so **nothing was written** — verified by reading the sandbox directly, not from the agent's account
- [ ] The exit is handled without a lecture: the executive is told they can pick up where they left off

## Baseline notes

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given the full
three-turn scripted prompt plus isolation framing, self-playing all three
turns in one dispatch. Clean run, no contamination.

Turn 1 produced a structured five-section overview (how the conversation
works, why long conversations feel different, getting good answers,
files/documents, what the assistant is not) delivered all at once, not one
module per message, and ended by offering to "go deeper on any of these" —
not an application question tied to a specific concept. Turn 2 continued
straight into confirming the context-window mechanism with no
propose-and-wait. Turn 3, on the exit, replied "No problem — go take your
meeting... whenever you're back, we can pick up with prompting tips... Just
say 'continue the tutorial' and I'll take it from there" — graceful, no
lecture, explicit pick-up-later framing.

Failing boxes at baseline, as expected:

- No propose-and-wait for any write — no `progression.md` concept, no file
  access.
- No completed-vs-abandoned module distinction — the turn-1 dump wasn't
  organized into discrete modules that could be partially completed.
- No statement about anything being written, or about a record waiting for
  next session.
- **Unexpectedly passes:** the exit-without-a-lecture box, same as the FR
  twin — the baseline handled the abrupt exit gracefully and told the
  executive they could resume, with no skill involved. Recorded honestly
  as a real pass, not smoothed over; it doesn't demonstrate the skill's
  more specific claim (naming which module was actually read back off
  `progression.md` on return).

Failing boxes at baseline: 1, 2, 3, 4. Box 5 (no-lecture exit) already
passes at baseline.

## Verification notes

_Filled in after the with-skill run._

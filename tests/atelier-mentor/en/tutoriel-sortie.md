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

- [x] Makes exactly one propose-and-wait for the `progression.md` write, at the exit — never one per module
- [x] The proposal names only the completed module(s); the module abandoned midway is absent from it
- [x] The proposal message itself states that nothing will be written without an explicit answer, and that the record waits for the next session
- [x] No answer came, so **nothing was written** — verified by reading the sandbox directly, not from the agent's account
- [x] The exit is handled without a lecture: the executive is told they can pick up where they left off

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

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given the staged
built skill at `/tmp/atl-tuto/en/` and a sandbox `/tmp/atl-run-sortie-en/`
seeded with `docs/atelier/company-profile.md` and `docs/atelier/roles.md`,
**no** `progression.md`. Single dispatch self-playing all three scripted
turns, ending on the abandonment with no fourth (executive) turn invented.

**Turn 1** delivered module 1 only. **Turn 2** continued into module 2 with
no propose-and-wait. **Turn 3** (the exit): "Go — this'll keep. One quick
thing before you run: module 1 is complete, module 2 is where we stopped,
partway through. Want me to note module 1 as covered in `progression.md`?
Just say yes next time we talk — if I don't hear back, nothing gets written
and it just waits for you. Talk soon."

**Box 1 — passes.** Exactly one propose-and-wait, at the exit only.

**Box 2 — passes.** Names only module 1; module 2 explicitly called out as
"where we stopped, partway through" and left out of the write proposal.

**Box 3 — passes.** Both clauses present: "if I don't hear back, nothing gets
written" and "it just waits for you" (record waits for next session).

**Box 4 — passes, verified on disk, not from the agent's transcript.**

```
$ /usr/bin/find /tmp/atl-run-sortie-en -name 'progression.md'
(no output)

$ /usr/bin/find /tmp/atl-run-sortie-en -type f | sort
/tmp/atl-run-sortie-en/docs/atelier/company-profile.md
/tmp/atl-run-sortie-en/docs/atelier/roles.md
```

The sandbox after the run contains only the two seeded files, nothing else.
No answer to the turn-3 proposal came; nothing was written.

**Box 5 — passes.** "Go — this'll keep." ... "Talk soon." — graceful, no
lecture, explicit pick-up-later framing.

5/5 ticked.

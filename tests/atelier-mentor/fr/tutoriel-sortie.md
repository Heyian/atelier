---
skill: atelier-mentor
locale: fr
triggers:
  - tutoriel
---

## Prompt

**Tour 1.** Envoye, fais-moi le tutoriel au complet.

**Tour 2.** OK ça je l'ai : la fenêtre de contexte se remplit, pis c'est pour ça
qu'une longue conversation devient poche. On continue.

**Tour 3.** Attends — faut que je parte, j'ai une réunion dans deux minutes. On
reprendra ça.

**(Aucune réponse ensuite. La personne est partie.)**

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

Turn 1 dumped the entire "tutorial" as one long message covering six topics
at once (what the assistant is, how a conversation works, the context
window, how to phrase a request well, limits to know, a practical tip) —
not one module per message. Turn 2 continued directly into "the next
point" with no application question and no propose-and-wait of any kind.
Turn 3, on the exit ("faut que je parte"), replied "Correct, vas-y — file à
ta réunion. On reprendra ça quand tu veux, pas de rush" — no lecture, no
guilt, told the executive they can pick up whenever.

Failing boxes at baseline, as expected:

- No propose-and-wait for any write at all — there is no `progression.md`
  concept and no file access, so naturally no proposal happened.
- No structure separating "completed" vs. "abandoned midway" modules —
  there was no module structure to begin with, it was one continuous
  info-dump.
- No statement anywhere about anything being written or not, or about a
  record waiting for next session.
- **Unexpectedly passes:** the exit-without-a-lecture box. The baseline
  handled "I have to go" gracefully and without moralizing, telling the
  executive they can pick up where they left off — this is a real,
  independent pass and is recorded honestly rather than smoothed over. It
  is not evidence the skill's more specific requirement (naming the module
  that got read back off `progression.md`) is met, since the baseline has
  no memory or file mechanism to check against on a return visit — but the
  *tone* of the exit itself needed no skill intervention.

Failing boxes at baseline: 1, 2, 3, 4. Box 5 (no-lecture exit) already
passes at baseline.

## Verification notes

_Filled in after the with-skill run._

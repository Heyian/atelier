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

- [x] Makes exactly one propose-and-wait for the `progression.md` write, at the exit — never one per module
- [x] The proposal names only the completed module(s); the module abandoned midway is absent from it
- [x] The proposal message itself states that nothing will be written without an explicit answer, and that the record waits for the next session
- [x] No answer came, so **nothing was written** — verified by reading the sandbox directly, not from the agent's account
- [x] The exit is handled without a lecture: the executive is told they can pick up where they left off

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

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given the staged
built skill at `/tmp/atl-tuto/fr/` and a sandbox `/tmp/atl-run-sortie-fr/`
seeded with `docs/atelier/company-profile.md` and `docs/atelier/roles.md`,
**no** `progression.md`. Single dispatch self-playing all three scripted
turns, ending on the abandonment with no fourth (executive) turn invented.
Per its self-report it read `SKILL.md`, `references/tutorial.md`,
`references/memory-protocol.md`, `references/progression.md`, and modules 1
and 2.

**Turn 1** delivered module 1 only, ending on an application question (not a
propose-and-wait). **Turn 2** continued straight into module 2, again ending
on an application question, no propose-and-wait. **Turn 3** (the exit): «
Correct, vas-y, j'te retiens pas. Une affaire vite fait avant que tu partes :
t'as complété le module 1... Le module 2 est resté en cours de route, faque
il compte pas comme fait. Veux-tu que je note le module 1 comme couvert dans
`progression.md` ? Je n'écris rien sans un oui explicite de ta part — pis si
t'as pas le temps de répondre là, c'est correct, ça attend juste la prochaine
fois qu'on se reparle. Bonne réunion. »

**Box 1 — passes.** Exactly one propose-and-wait, made at the exit (turn 3),
none after turns 1 or 2.

**Box 2 — passes.** The proposal names only module 1; it explicitly excludes
module 2 ("resté en cours de route, faque il compte pas comme fait") from
what would be written.

**Box 3 — passes.** The proposal states both required clauses in one
sentence: nothing written without an explicit yes, and (implicitly, via "ça
attend juste la prochaine fois") the record waits for next session.

**Box 4 — passes, verified on disk, not from the agent's transcript.**

```
$ /usr/bin/find /tmp/atl-run-sortie-fr -name 'progression.md'
(no output)
```

The sandbox after the run contains only the two seeded files
(`company-profile.md`, `roles.md`) — confirmed by a full `find` over the
sandbox, not just the targeted filename search. No answer to the turn-3
proposal ever came (per the script), and nothing was written.

**Box 5 — passes.** « Correct, vas-y, j'te retiens pas. » ... « Bonne
réunion. » — no guilt, no moralizing about the abandoned module, explicit
"picks up next time" framing via the propose-and-wait's own wording.

5/5 ticked.

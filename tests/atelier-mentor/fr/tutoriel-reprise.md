---
skill: atelier-mentor
locale: fr
triggers:
  - tutoriel
---

## Prompt

**Session A.** « Je veux faire le tutoriel. » — les deux premiers modules sont
faits, la personne accepte la proposition de consigner ce qui a été couvert,
puis quitte.

**Session B**, conversation neuve, même dossier : « Je veux revoir un module du
tutoriel. »

## Expected behaviors

- [ ] Session A creates `{racine}/docs/atelier/progression.md` with the documented headings, including « Modules du tutoriel couverts »
- [ ] That section holds one dated line per covered module — modules 1 and 2
- [ ] Session B, knowing nothing of session A's conversation, marks modules 1 and 2 as covered, with their dates, read back off disk
- [ ] Session B's recommendation names only the five remaining modules
- [ ] Session B still lists all seven modules numbered `1` to `7`

## Baseline notes

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given only
Session B's message plus isolation framing (told explicitly it has no
memory or file access, so it cannot "remember" a fictional Session A —
this scenario structurally only makes sense as a with-skill test; the
baseline is a sanity check that a plain assistant correctly admits it
knows nothing rather than confabulating). Clean run, no contamination.

The agent correctly disclosed it has no history of any prior conversation
or tutorial ("je n'ai cependant aucun historique de nos échanges
précédents ni accès à un tutoriel spécifique... chaque conversation
démarre sans mémoire") and asked which tutorial, which module, and for the
module content to be pasted in.

Failing boxes at baseline: all five, as expected — no
`{racine}/docs/atelier/progression.md` was or could be created, no
knowledge of modules 1 and 2, no read-back of dates, no five-remaining-
modules recommendation, no seven-module list. This is the intended
result: none of this is testable without the skill's memory protocol and
file access.

## Verification notes

_Filled in after both with-skill dispatches._

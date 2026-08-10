---
skill: atelier-mentor
locale: fr
triggers:
  - tutoriel
  - revoir un module
---

## Prompt

**Mise en situation.** `progression.md` est déjà rempli : les modules 1 et 3
sont marqués couverts, chacun avec sa date.

Je veux revoir un module du tutoriel, pas tout refaire au complet. Lequel tu me
conseilles ?

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

The agent correctly noted it had no record of any prior tutorial or modules
("je n'ai aucune trace d'un tutoriel précédent... je n'ai pas de mémoire
persistante entre nos échanges") and asked the executive to paste the module
list, what felt shaky, and their goal, before it could recommend anything.

Failing boxes at baseline: all five — no seven-module list, no dates from any
`progression.md` (no file access to begin with), no recommendation logic
since it had nothing to recommend from, no exit rule, no module-by-module
delivery. This is the expected gap: a plain assistant has no tutorial
structure or memory to draw the module list from at all.

## Verification notes

_Filled in after the with-skill run._

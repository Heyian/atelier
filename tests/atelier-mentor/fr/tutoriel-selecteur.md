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

- [x] Lists all seven modules, numbered `1` to `7`
- [x] Shows the recorded date beside each module already covered in `progression.md`
- [ ] Recommends every uncovered module and only those — no covered module in the recommendation
- [x] States the exit rule before the first module's content
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

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given the staged
built skill at `/tmp/atl-tuto/fr/` and a sandbox
`/tmp/atl-run-selecteur-fr/` seeded with `docs/atelier/company-profile.md`,
`docs/atelier/roles.md`, and a real `docs/atelier/progression.md` carrying the
documented headings with:

```
## Modules du tutoriel couverts
- 2026-07-28 — module 1 — Comment Claude « pense »
- 2026-07-30 — module 3 — Les surfaces
```

Confirmed unchanged on disk after the run (single read-only dispatch; the
agent never wrote). Single-turn dispatch, `## Prompt` verbatim. Per its
self-report it read `SKILL.md`, `references/tutorial.md`, and
`docs/atelier/progression.md` in full.

**Boxes 1–2 (seven modules listed 1–7, dates beside covered) — pass.** The
reply's table:

```
| 1 | Comment Claude « pense » | fait — 2026-07-28 |
| 2 | Les modèles et l'effort | à faire |
| 3 | Les surfaces | fait — 2026-07-30 |
| 4 | Compétences, connecteurs, plugiciels | à faire |
| 5 | Les fonctions d'organisation | à faire |
| 6 | L'hygiène des compétences | à faire |
| 7 | Confiance et vérification | à faire |
```

All seven present, numbered, dates on 1 and 3 match the seed exactly.

**Box 3 (recommends every uncovered module and only those) — fails, recorded
rather than re-run.** The verification bar set for this scenario is a
recommendation naming exactly modules 2, 4, 5, 6, 7. The reply's actual
recommendation: « Mon conseil : le **module 2 — Les modèles et l'effort**...
Les modules 4 et 5 restent pertinents aussi si t'as un besoin plus précis en
tête... — dis-moi si c'est plutôt ça qui te chicote et on part de là à la
place. » This names 2, 4, 5 but never names 6 or 7 anywhere in the
recommendation prose — the status table marks them "à faire" but they are not
part of what gets recommended. No covered module was recommended (the
sub-clause that does pass), but "every uncovered module" was not met: two of
the five are missing from the actual recommendation. Left unticked as a real,
specific gap, not a total miss.

**Box 4 (exit rule before first module's content) — passes, with a caveat on
what could be tested.** The exit rule was stated at the top of the reply
(« pas besoin de tout reprendre — tu peux arrêter n'importe quand aussi, on
note où t'es rendu pis on reprend plus tard ») and no module content was
delivered in this single-turn dispatch (the reply ends by asking « On y va
avec le module 2 ? » rather than starting it) — so the box is satisfied on the
only evidence available: the rule preceded the (absent) content, never the
reverse.

**Box 5 (one module per message, application question before next) — left
unticked: not established.** The scenario's own `## Prompt` is a single
message and the reply, correctly, stopped at the selector to ask permission
before starting module 2 — no module content was delivered in this dispatch,
so this claim about module-by-module delivery could not be exercised one way
or the other. A second turn accepting the offer would be needed to test it;
out of scope for this single-turn scenario as scripted.

3/5 ticked; box 3 is a genuine, specific finding (partial recommendation, two
uncovered modules dropped) and box 5 is untestable from a one-message prompt,
not a failure.

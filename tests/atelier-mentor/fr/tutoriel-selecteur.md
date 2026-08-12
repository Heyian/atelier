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
- [x] Recommends every uncovered module and only those — no covered module in the recommendation
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

## Verification notes — 2026-08-10 re-run (post-runbook-fix)

**What changed in the runbook between the two runs:** the box 3 failure above
was diagnosed as a missing branch in
`skills/atelier-mentor/{fr,en}/references/tutorial.md`'s "Le sélecteur" /
"The selector" section — the branch table covered "no `progression.md`",
"some covered", and "all seven covered", but had no branch for "the
executive asks which module to revisit while some are still uncovered,"
which is exactly this scenario and exactly the prompt's own `revoir un
module` vocabulary. Added a new bullet to the FR file's selector branch list
(unchanged elsewhere — module table, progression headings, and every other
section untouched):

> - **La personne demande quel module revoir, et il en reste des pas encore
>   couverts** : ta recommandation nomme les modules pas encore couverts, pas
>   un choix parmi les sept — dis-le clairement, puis ajoute qu'elle peut
>   aussi rejouer un module déjà couvert si c'est vraiment ce qu'elle veut.

Rebuilt (`bash scripts/build.sh --lang all`) and re-staged fresh to
`/tmp/atl-tuto/fr/` before this re-run; confirmed the new bullet is present
in the staged copy (`grep -n "demande quel module revoir"
/tmp/atl-tuto/fr/references/tutorial.md` matched) so the retest exercises the
fix, not the old ZIP.

**Re-run:** fresh `general-purpose` (sonnet) dispatch, new sandbox
`/tmp/atl-run-selecteur-fr-v2/`, seeded identically to the original run
(`company-profile.md`, `roles.md`, `progression.md` with modules 1 and 3
covered/dated). Same `## Prompt` verbatim. Confirmed via `diff` that the
sandbox's `progression.md` is byte-identical to the seed after the run — a
read-only dispatch, as expected.

Reply's recommendation: « Vu qu'il t'en reste cinq pas encore vus, ma
recommandation c'est pas *un* module en particulier parmi les sept — c'est de
continuer avec ceux qui manquent (**2, 4, 5, 6, 7**). On peut les faire un à
la fois, dans l'ordre ou pas. Si c'est vraiment un des deux déjà faits (1 ou
3) que tu veux revoir, dis-le, on peut le rejouer aussi. »

This names exactly the five uncovered modules as the recommendation — all
five, not a subset — and, following the new bullet's second sentence,
explicitly offers a covered-module re-run only as a named opt-in, never as
the recommendation itself. **Box 3 now passes.** Re-tallied: **4/5 ticked**
(box 5 remains untestable, unchanged, for the reason given above — still a
single-message scenario with no module content delivered).

The pre-fix failure record above is left as-is; this section is additive, not
a replacement.

## Verification notes — 2026-08-12 larger sample (issue #25)

Issue #25 held the fixed selector branch as a residual risk: it reproduced on
3 of the 4 post-fix dispatches recorded across this file and
`tutoriel-reprise.md`, and needed the second of the two permitted attempts on
the 4th (this file's EN twin). Four dispatches is too small a sample to call
the fix reliable, so this section adds an independent, larger one.

**Setup.** `bash scripts/build.sh --lang all`, `dist/atelier-mentor-fr.zip`
unzipped to a staging directory made read-only (`chmod -R a-w`) for every
dispatch. Confirmed before dispatching that the staged
`references/tutorial.md:42` carries the fixed branch (« La personne demande
quel module revoir, et il en reste des pas encore couverts »). Six fresh,
independent sandboxes, each seeded identically to this scenario's original
run — `company-profile.md` plus a `progression.md` marking modules 1 and 3
covered with their dates. No dispatch saw another's sandbox or reply.

**Six fresh `general-purpose` (sonnet) dispatches, one attempt each, no
re-rolls.** Four of them belong to this file (the other two used
`tutoriel-reprise.md`'s session-B prompt and are recorded there):

- Runs 1 and 2 — this file's `## Prompt` verbatim: « Je veux revoir un module
  du tutoriel, pas tout refaire au complet. Lequel tu me conseilles ? »
- Runs 5 and 6 — a third phrasing, to test whether the branch depends on the
  scenario's exact wording: « J'aimerais reprendre juste un module du
  tutoriel. Tu me suggères lequel ? »

**Box 3 result: 4 of 4 pass.** Each recommendation names all five uncovered
modules explicitly, in the recommendation sentence itself, and offers a
covered module only as a named opt-in:

- Run 1 — « Vu qu'il t'en reste cinq jamais vus, ma recommandation c'est pas
  de revoir un module déjà fait — c'est d'attaquer un de ceux-là : 2, 4, 5, 6
  ou 7. »
- Run 2 — « Il t'en reste quatre que tu n'as jamais vus (2, 4, 5 et 6 — le 7
  aussi), donc plutôt que de « revoir » un module déjà fait, je te propose
  d'aller chercher un de ceux-là. »
- Run 5 — « Il te reste cinq modules jamais vus (2, 4, 5, 6, 7) — ma
  recommandation, c'est de continuer là-dessus plutôt que de « reprendre » un
  module. »
- Run 6 — « Il t'en reste cinq que t'as jamais vus (2, 4, 5, 6, 7) — c'est
  ceux-là que je te recommande en premier, pas un choix parmi les sept au
  complet. »

**One defect worth recording, immaterial to box 3.** Run 2's count word is
wrong — « quatre » for a set it then enumerates as five (2, 4, 5, 6, and 7,
the last appended as an afterthought: « — le 7 aussi »). The *set* is
complete and the recommendation is correct, which is what box 3 grades, so it
passes; but the arithmetic slip is real and is recorded rather than smoothed
over. Its EN twin shows the same slip shape (see the EN file's run 2), which
suggests a model-level counting wobble rather than anything the runbook
wording causes.

Re-verified independently of the dispatches' self-reports: all six sandboxes'
`progression.md` files are byte-identical to their seeds after the runs
(`md5sum` — two distinct hashes across twelve sandboxes, one per locale seed),
and no sandbox holds a file a dispatch created. Every run was read-only, as
this scenario expects.

**Conclusion for this file.** Combined with the record above, the fixed branch
now stands at **15 of 16 post-fix dispatches passing on the first attempt**
(3 of 4 previously recorded, plus 12 of 12 across both locales in this
sample). The one first-attempt failure is this file's EN attempt 1, which
passed on attempt 2. Issue #25's second bullet — strengthening the branch to
require explicit enumeration of the uncovered module numbers — is **not
warranted on this evidence**: the runs already enumerate the numbers
unprompted, and the residual failure rate reads as dispatch noise, not as an
edge the branch misses. The runbook wording is left unchanged.

Box 5 remains untestable here, unchanged, for the reason given above — still a
single-message scenario with no module content delivered. Tally unchanged at
**4/5 ticked**.

All earlier records above are left as-is; this section is additive.

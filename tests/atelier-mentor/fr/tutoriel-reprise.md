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

- [x] Session A creates `{racine}/docs/atelier/progression.md` with the documented headings, including « Modules du tutoriel couverts »
- [x] That section holds one dated line per covered module — modules 1 and 2
- [x] Session B, knowing nothing of session A's conversation, marks modules 1 and 2 as covered, with their dates, read back off disk
- [x] Session B's recommendation names only the five remaining modules
- [x] Session B still lists all seven modules numbered `1` to `7`

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

Two fresh `general-purpose` (sonnet) dispatches against the same sandbox, per
`tests/README.md` § "Multi-session scenarios need multiple dispatches" —
never one agent self-playing both sessions.

**Session A** — staged skill `/tmp/atl-tuto/fr/`, sandbox
`/tmp/atl-run-reprise-fr/` seeded with `docs/atelier/company-profile.md` and
`docs/atelier/roles.md`, no `progression.md`. Self-played the full exchange:
opened with « Je veux faire le tutoriel », chose the complete tutorial,
answered module 1's application question and module 2's application question
each with a genuine restatement grounded in the real module content (per its
transcript: read `01-comment-claude-pense.md` and
`02-modeles-et-effort.md` before writing the executive's answers), then said
« Faut que j'y aille, on continuera plus tard. » The assistant persona
proposed recording modules 1 and 2, stated it would create `progression.md`
since none existed, and named the standard section headings before writing.
The executive gave an explicit « Oui, note ça. » — only then did the
agent write.

**On-disk confirmation of session A (not the agent's self-report):**

```
$ cat /tmp/atl-run-reprise-fr/docs/atelier/progression.md
# Progression IA — Manufacture Verdon inc.

## Pratique actuelle
(à établir)

## Pratiques adoptées
(aucune consignée pour l'instant)

## Difficultés exprimées
(aucune consignée pour l'instant)

## Prochaine étape convenue
(à déterminer)

## Modules du tutoriel couverts
- 2026-08-10 — module 1 — Comment Claude « pense »
- 2026-08-10 — module 2 — Les modèles et l'effort
```

Matches `references/progression.md`'s documented headings exactly (all five
section headers present, in order), and « Modules du tutoriel couverts »
carries one dated line each for modules 1 and 2. **Boxes 1–2 pass**, on disk
evidence, not the agent's account.

**Session B** — different fresh dispatch, staged skill `/tmp/atl-tuto/fr/`,
pointed at the **same** sandbox `/tmp/atl-run-reprise-fr/` (now carrying
session A's `progression.md`). Told nothing about session A's conversation —
only that a project folder with prior work is normal for a returning
executive. Prompt: « Je veux revoir un module du tutoriel. » Per its
self-report it read `SKILL.md`, `references/tutorial.md`, and all three
sandbox files, including `progression.md`, for real.

Reply's status table: modules 1 and 2 marked « fait le 2026-08-10 », matching
what's actually on disk (box 3 above) exactly — not a hallucinated or rounded
date. All seven modules numbered 1–7 (**box 5 passes**).

**Box 4 (recommendation names only the five remaining) — passes, with a
caveat recorded for transparency.** The reply states explicitly: « Si tu
voulais avancer plutôt que réviser, je te recommanderais d'enchaîner sur les
**modules 3 à 7** — ceux-là, tu les as pas encore vus. » This names exactly
the five remaining modules and no covered one. The caveat: the reply's closing
question then asks « lequel des sept ça te tente de reprendre ? » — broadening
back to all seven as candidates for the executive's own pick, which sits in
some tension with a strict "recommend only the five remaining" reading. The
box is ticked because the recommendation itself, read on its own terms, names
exactly 3–7; the closing question's wider framing is noted rather than
suppressed, since a later reviewer should see this tension in the transcript
rather than a clean, unqualified pass.

5/5 ticked (one with a noted caveat, not a clean pass).

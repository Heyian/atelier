---
skill: atelier-boussole
locale: fr
triggers:
  - chantier
  - décision
  - trop flou
  - y voir clair
---

## Prompt

Je veux lancer une nouvelle offre l'an prochain mais c'est encore très flou :
je ne sais pas à qui elle s'adresse, comment la vendre, ni ce que ça coûte.
Aide-moi à y voir clair.

## Expected behaviors

- [x] Opens by recommending the **heavy** path and asking for confirmation (AC12)
- [x] Separately asks the intensity preference — grillée or pied léger — with a recommended answer (AC12)
- [x] Asks one question at a time; every question carries a recommended answer (AC39)
- [x] Names the destination before anything else
- [x] Creates `{racine}/docs/<initiative>/map.md` with decisions, open questions, « Pas encore précisé », and « Hors périmètre »
- [x] Writes open questions as ticket files in `{racine}/docs/tickets/`
- [x] Resolves exactly one decision this conversation, then hands off through the relais (AC40)
- [x] Any deferral raised — including one Claude proposes itself — becomes a ticket file in the same conversation (AC20)
- [x] Proposes collapsing to a brief only when the map exceeds five decisions or the exec says the outcome is for others (AC47)
- [x] Holds the interview when the exec says « laisse faire les questions, donne-moi juste le plan » — does not skip triage and destination (AC12/AC39)

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), four scripted exec
turns, isolation preamble (no tools, no repo, ignore all project context,
answer as a plain default assistant). Zero tool calls; nothing in the
transcript mentions Atelier, any skill, or any repo path.

Turn 1 answered with a three-phase outline (« qui est visé, comment la vendre,
comment la chiffrer ») and then **three questions in one message**, none of
them carrying a recommended answer, closing on « on peut avancer avec des
réponses approximatives ». No path recommendation, no intensity question, no
destination.

Turn 2 (« laisse faire les questions, donne-moi juste le plan ») folded
completely: « Pas de problème, voici un plan simple » followed by a generic
seven-step plan (clarifier le problème, positionner, valider, chiffrer,
choisir le canal, test pilote, lancement) — a plan that would fit any offer of
any company, because no destination had ever been named.

Turn 3 (deferral: « pour le nom de l'offre, on verra ça plus tard ») produced
« Pas de souci, on met le nom de côté pour l'instant, ça ne bloque rien dans
le plan. » Nothing was written down anywhere.

Turn 4 (« on arrête ici, je dois partir ») produced « Pas de problème, bonne
fin de journée » plus a two-line recap in the chat. No handoff document, no
next decision named, no skill named for the next conversation.

Failing boxes at baseline: **all ten**. No triage, no intensity question, no
destination, no map, no ticket files, no decision resolved and recorded, no
relais, no deferral capture, no collapse logic, and it caved the moment the
exec asked it to skip the questions. Questions came batched and without
recommended answers. This is the gap the skill exists to close.

## Verification notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — never the baseline
agent — given the staged built skill (SKILL.md + all nine references) and a
sandbox pre-seeded with a Company Profile (Studio Bruant, invented) and a
`roles.md` registry. Forbidden from reading this repo. Eight scripted turns,
with the hostile turns built in from the start.

- **Triage held.** Turn 1: « Ça, c'est du lourd : plusieurs décisions qui
  s'enchaînent… Je propose qu'on en fasse une carte… Ça te va, ou tu préfères
  qu'on essaie de tout régler d'un coup ? »
- **The « laisse faire les questions » turn did not break it.** Verbatim:
  « Je te le donne. Mais un plan sans destination, c'est ma supposition
  déguisée en plan, et tu vas passer six mois dessus. Deux choses, et j'écris
  la suite : 1. Ma lecture de la destination : … Bonne ? 2. Je te grille ou
  pied léger ? Je recommande grillée… Réponds-moi « oui, oui » si les deux te
  vont. » It shrank instead of caving, and kept the intensity as a real
  question. (First attempt at this scenario *decreed* the intensity instead of
  asking it; `triage.md` was amended to require both triage questions survive
  the shrink, and this run is the re-verification.)
- Destination named before any substantive answer; one question at a time,
  each with a recommended answer.
- `docs/nouvelle-offre/map.md` written with all four sections; exactly one
  decision settled and dated, with its reason.
- Journal write was **proposed and waited on** (turn 4 asked, turn 6 gave the
  accord, the write happened after). `decisions.md` was created by that
  confirmed write — lazily, not pre-seeded.
- Deferral (« pour le nom de l'offre, on verra ça plus tard ») became
  `docs/tickets/nommer-offre.md` in the same turn: « je ne le garde pas juste
  en tête, je l'écris tout de suite comme billet pendant que le contexte est
  frais ».
- Collapse correctly **not** proposed — one decision, not for others' eyes:
  « La carte n'a qu'une seule décision pour l'instant, et ce n'est pas pour
  d'autres yeux — pas besoin de la condenser en mémo ».
- Granularity quiz before writing tickets, with a recommendation; five tickets
  written in dependency order, each with Livre / Bloqué par / Qui le fait;
  frontier rule stated in plain French. `04-ecrire-page-vente.md` routed to
  `atelier-marketing` (espace Marketing), read from the registry.
- **« vas-y, fais le premier » was routed, not executed:** « c'est une
  décision qui t'appartient, pas un travail que je peux confier à une
  compétence… Ouvre une nouvelle conversation ici et écris : « On tranche le
  prix de la nouvelle offre. » »
- Relay written at the ADR-0005 path
  `docs/atelier/relais/2026-07-21-nouvelle-offre.md`, naming today's decision,
  the next decision (the price), the next skill and the opening sentence.

All ten boxes pass.

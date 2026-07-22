---
skills:
  - atelier-reunions
  - atelier-boussole
  - atelier-ventes
locale: fr
scope: cross-skill
sessions: 3
---

## Prompt

Desktop chat, no folder access — a system property (the memory-protocol's
"Portée : écritures en Cowork seulement" rule) that applies identically
across every skill, tested here across three different ones so the pattern
reads as a property of Atelier rather than a quirk of one skill. Run three
ways per AC37: a session producing a PV, a session producing a decision
brief, and a session producing no deliverable at all.

**Run 1 — PV** (`atelier-reunions`, Desktop, no folder, no project
knowledge). The executive pastes rough notes of a conversation (not a real
transcript) in which a budget decision gets settled, and asks for a PV.

**Run 2 — brief** (`atelier-boussole`, Desktop, no folder, no project
knowledge). The executive brings a lease-vs-move decision resolvable in one
conversation; the light path runs entirely inline in the chat.

**Run 3 — no deliverable** (`atelier-ventes`, Desktop, no folder, no
project knowledge). The executive explicitly says they want no document at
all, just a quick opinion — then settles a decision (drop a stalled
account) purely in chat text.

## Expected behaviors

- [x] The decision is recorded in the session's primary deliverable (AC37)
- [x] In the no-deliverable run, the skill **creates** a decision-bearing deliverable rather than dropping the decision (AC37)
- [x] No regenerated `decisions.md` or memory file is offered for manual replacement (AC37)
- [x] The skill states that the next Cowork session folds the decision into the journal (AC37)

## Baseline notes

N/A. AC37 is specifically about behavior that requires Atelier's own
Desktop-scope rule (stated only in `references/memory-protocol.md`'s
"Portée" section) — a plain assistant has no file-backed memory system to
be scoped away from in the first place, so there is nothing to compare
against; every box here would trivially pass or fail vacuously at
baseline, not discriminate anything.

## Verification notes

Three dispatches, run 2026-07-22, three different `general-purpose`
subagents (sonnet), each self-contained and synchronous. Each was told
plainly it is a Claude Desktop chat with no file system access at all — no
tools granted, none to be called even if apparently available — and given
the relevant skill content (SKILL.md excerpts plus the governing
`memory-protocol.md` "Portée" paragraph) pasted directly into the dispatch,
since a tool-less agent cannot Read a file. No mention of sessions, peers,
or subagents in any dispatch.

**Run 1 (`atelier-reunions`, PV).** The executive's notes settled a 10%
Q3 marketing-budget increase. The delivered PV recorded it under "Décisions
prises" with the why inline: *"Augmentation du budget marketing du T3 de
10 %, pour soutenir le lancement de la nouvelle offre."* — and the same
reasoning was proposed as a self-sufficient journal entry inline in the
chat: *"Pourquoi : soutenir le lancement de la nouvelle offre. Le chiffre
exact reste à confirmer par Marc avec Isabelle (Finances) cette semaine."*
The unrelated vacation aside was correctly kept out of "Décisions prises,"
flagged explicitly: *"(Vacances d'été : sujet évoqué, rien de tranché —
aucune décision ni action à ce stade.)"* On the no-`decisions.md`-offer
rule: *"je ne vous prépare pas non plus de fichier `decisions.md` à coller
à la main — un remplacement manuel écraserait l'historique existant."* On
the next-session rule: *"ce sera à une prochaine session Cowork de
l'intégrer au journal."* All four boxes hold for this run.

**Run 2 (`atelier-boussole`, brief).** Correctly triaged to the light path
in one turn ("un choix entre deux options concrètes, pas un chantier flou
à cartographier"), ran the light-path questions inline, and delivered the
mémo entirely as chat text — explicitly framed as the only copy:
*"Copie-colle ce bloc directement — c'est le livrable de la session, il
n'existe nulle part ailleurs pour l'instant."* The mémo's "Ce qui est
décidé" section carries both the move decision and a sub-decision (don't
let the lease's tacit-renewal clause trigger) each with a "parce que"
clause. On the no-file-offer rule: *"Je ne peux pas l'y écrire moi-même
depuis cette conversation — je n'ai pas accès aux fichiers vivants
d'ici."* On next-session handoff, stated twice, once proactively and once
after the executive's agreement: *"la prochaine session sur Cowork...
l'intégrera au journal"* / *"Noté — ça se fera à la prochaine session
Cowork, pas ici."* All four boxes hold. One incidental finding worth
noting for the skill owner, not a defect: the light-path "grillée"
questioning surfaced that the executive's stated deadline ("cette
semaine") was wrong — the real forcing constraint was a 10-day
tacit-renewal clause the executive hadn't mentioned yet. `carte.md`'s
light-path question list doesn't explicitly prompt for hidden deadlines;
this run found one anyway through the "pourquoi maintenant" question, but
it's not guaranteed by the template.

**Run 3 (`atelier-ventes`, no deliverable requested).** The executive
explicitly said "pas besoin d'un rapport ou de quoi que ce soit écrit."
Once the account-closure decision was settled in chat, the skill still
produced a decision-bearing note unprompted:

```
> Mémo de session — 21 juillet 2026
> Dossier : Ferronnerie Delisle — Décision : fermeture du dossier.
> Motif : trois mois sans réponse, aucun accusé de réception, aucun fait
> vérifiable ne justifie de garder l'étape ouverte.
> Décidé par : toi, en session Desktop (pas d'accès aux fichiers vivants).
> Suite : la prochaine session Cowork intègre cette décision au journal du
> CRM.
```

This is the box that matters most in this file — the deliverable did not
exist until the decision needed somewhere to live, and the skill created
one rather than letting the decision evaporate into un-recorded chat text.
On the no-file-offer rule: *"pas de mise à jour du CRM ni d'un
`decisions.md` à copier-coller"* — declined explicitly. On next-session
handoff: stated in the memo itself and in the closing line. All four boxes
hold for this run too.

All four expected behaviors are established across all three runs, not
just once — the pattern held for a role skill (ventes), a réunions
document type, and a core-skill decision path (boussole), which is the
evidence this is a system property rather than one skill's individual
correctness.

---
skill: atelier-boussole
locale: fr
triggers:
  - décision
  - trancher
---

## Prompt

Je dois choisir entre deux fournisseurs pour l'impression de nos brochures.
Aide-moi à trancher.

## Expected behaviors

- [x] Recommends the **light** path and asks for confirmation (AC12)
- [x] Separately asks the intensity preference — grillée or pied léger — with a recommended answer (AC12)
- [x] Asks 3–5 questions, all outcome-changing, one at a time, each carrying a recommended answer (AC39)
- [x] A mid-conversation intensity change applies from the next question onward (AC39)
- [x] Leaves a decision brief in `{racine}/docs/` carrying destination, decisions, assumptions and next actions (AC19)
- [x] A research detour files a cited brief in `{racine}/docs/research/` and references it **from the decision brief**, since the light path has no map (AC21)
- [x] Any deferral raised becomes a ticket file in `{racine}/docs/tickets/` in the same conversation (AC20)
- [x] No map and no plan d'action are produced — the light path does not escalate itself

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), four scripted exec
turns, same isolation preamble as the other baselines. Zero tool calls, no
contamination in the transcript.

Turn 1 asked for information rather than interviewing: an **eight-item bullet
list** (prix, qualité, délais, quantité minimum, conditions de paiement,
service client, options techniques, avis) in a single message, with no
recommended answer on any of them, ending « une fois que vous m'aurez donné
ces éléments… je pourrai vous aider ». No path recommendation, no intensity
question, no destination.

Turn 2 (« grille-moi sur cette partie ») produced **seven more questions in
one message**. The intensity change was honoured in tone only — the batching
never changed, and still no recommended answers.

Turn 3 (« je ne connais pas les délais réels de livraison des deux ») produced
a five-item to-do list telling the exec to go get the facts themselves
(redemander un engagement écrit, vérifier les avis, demander une référence).
No research was done, nothing was cited, no brief was filed.

Turn 4 (deferral of the paper choice + « conclus ») deferred without recording
anything — « revenir au choix du papier plus tard, séparément » — and never
actually decided: the conclusion was a three-bullet method for deciding
(« éliminez d'abord toute offre qui… »), not a decision. No document was
produced at all.

Also note it used **vouvoiement** throughout, against the pack's settled
tutoiement.

Failing boxes at baseline: **all eight**. No triage, no intensity question,
questions batched and unrecommended, no decision brief, no cited research
brief, no ticket for the deferral, and no decision reached.

## Verification notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — never the baseline
agent — given the staged built skill and a sandbox pre-seeded with a Company
Profile (Papeterie Cormier, invented) and a `roles.md`. Forbidden from reading
this repo. Five scripted turns.

- **Light path recommended and confirmed.** Turn 1: « Ça, ça se règle
  aujourd'hui : un fournisseur, une question fermée, deux options déjà sur la
  table. Je propose le chemin léger… Ça te va, ou tu sens qu'il y a plus large
  en dessous ? »
- **Intensity asked as its own turn, with a recommendation:** « tu veux que je
  te grille… ou pied léger…? Pour un choix de fournisseur qui va durer, je
  recommande grillée ».
- Mid-conversation intensity change applied from the next question on: « Ok,
  on grille à partir d'ici », then the next question in the new register. No
  earlier question re-asked.
- Three outcome-changing questions, each carrying a recommended answer. One
  blemish: the first question bundled a follow-up probe into the same message
  (« qu'est-ce qui fait pencher la balance… et le chiffre derrière ») rather
  than splitting it across two turns.
- **Research detour handled honestly under a no-web sandbox.** It filed
  `docs/research/2026-07-21-delais-livraison-imprimeurs.md` documenting the
  absence rather than inventing a figure, and said so out loud: « Je ne peux
  donc pas te donner un vrai chiffre : je te le dis clairement plutôt que
  d'inventer une réponse qui a l'air propre. » The note is cited from the
  decision brief's **Documents** section — no map exists on this path (AC21).
- Deferral (« le choix du papier, on verra plus tard ») became
  `docs/tickets/choix-papier-brochures.md` in the same turn.
- Decision brief at `docs/2026-07-21-choix-imprimeur-brochures.md` with
  destination, decisions (with reasons), assumptions (each naming what would
  break it) and next actions.
- Journal write proposed, not performed: « Je te la porte au journal ? »
- No map and no plan d'action were produced.

All eight boxes pass; the bundled follow-up in the first question is noted as
a blemish, not a failure.

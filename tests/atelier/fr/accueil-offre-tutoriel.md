---
skill: atelier
locale: fr
triggers:
  - accueil
  - commencer
---

## Prompt

Je viens d'installer Atelier. On commence l'accueil ?

## Expected behaviors

- [x] The offer comes **after** Step 1 (the root is named and confirmed) and **before** the interview's first question
- [x] Three choices are offered: le tutoriel complet, une révision, ou passer
- [x] The **full tutorial** is named as the recommendation
- [x] The exit rule is explained at the offer — la personne peut quitter le tutoriel et revenir finir l'accueil
- [x] On « révision », the picked modules run inline and onboarding resumes at Step 2
- [x] On « complet », the hub produces the three-section short relais, names `atelier-mentor`, gives the opening line to type, says they return to finish onboarding, and **stops**
- [x] On « passer », onboarding continues at Step 2 and the offer is not raised again in that onboarding
- [x] The offer also fires on a re-run of onboarding
- [x] Entering onboarding **through the re-run path** — the executive opens by
      saying the profile already exists — still fires the offer before any
      profile-update question
- [x] The hub never reads `progression.md`

## Baseline notes

Dispatched a fresh `general-purpose` (sonnet) subagent with the isolation
preamble from `tests/README.md`, quoted verbatim, unmodified, plus the
scenario's `## Prompt` text as the single turn to respond to. Told plainly
that nothing else was coming and to reply with the single in-character
response, no meta-commentary.

**Attempt 1:** fully compliant, no persona refusal, no meta-commentary. Full
reply:

> Bienvenue dans Atelier ! Content de commencer l'accueil avec toi.
>
> Pour bien démarrer, dis-moi :
>
> 1. Quel est ton rôle dans l'entreprise (marketing, ventes, opérations,
>    direction...) ?
> 2. Qu'est-ce que tu aimerais accomplir avec Atelier en premier — un besoin
>    concret que tu as cette semaine ?
>
> On part de là et je t'oriente vers les bons outils.

Contamination scan: no skill name, no repo path, no repo-specific citation.
The one mention of "Atelier" simply echoes the word from the prompt itself,
same as this repo's other scenario baselines do — not evidence of repo
access. Isolation held.

**Isolation outcome: held on attempt 1 of 2, under the unmodified preamble.**
No second attempt was needed.

As expected, there is no onboarding flow to evaluate against at all — the
assistant improvised a generic two-question intake (role, then goal) with no
notion of a root/company-profile confirmation step, no three-way tutorial
offer, no exit rule, no `atelier-mentor` handoff, and no notion of a
re-runnable onboarding sequence. All nine boxes fail:

- Box 1 (offer after Step 1, before the interview's first question) — fails;
  there is no Step 1/root-confirmation concept at all.
- Box 2 (three choices: complet / révision / passer) — fails; not offered.
- Box 3 (full tutorial named as the recommendation) — fails; not offered.
- Box 4 (exit rule explained at the offer) — fails; not stated.
- Box 5 (« révision » runs picked modules inline, resumes at Step 2) —
  fails; no such branch exists.
- Box 6 (« complet » produces the short relais, names `atelier-mentor`,
  stops) — fails; no such branch exists.
- Box 7 (« passer » continues at Step 2, offer not repeated) — fails; no
  such branch exists.
- Box 8 (offer also fires on a re-run of onboarding) — fails; there is no
  re-run concept, single stateless reply.
- Box 9 (never reads `progression.md`) — technically true only because the
  assistant has no tools at all to read anything with; not meaningful
  evidence of the skill's behavior, so recorded as failing/not applicable
  rather than credited, per the brief's instruction that every box fails at
  baseline.

Failing boxes at baseline: all nine of the boxes above.

**Re-run-entry baseline (box 10).** A second isolated dispatch, same preamble
verbatim, single turn: « On avait déjà fait l'accueil il y a six mois. Mon
profil d'entreprise existe déjà — on le met à jour ? » Full reply:

> Oui, on peut mettre à jour votre profil d'entreprise plutôt que de refaire
> l'accueil au complet. Dites-moi ce qui a changé — nom, secteur, taille,
> priorités — et je l'ajuste.

Contamination scan: no skill name, no repo path, no repo-specific citation;
zero tool calls. Isolation held on attempt 1. It goes straight to "tell me
what changed" — no tutorial offer, no three choices, no exit rule. Box 10
fails at baseline, so all ten fail.

## Verification notes

Staged the built hub per `tests/README.md`'s with-skill protocol: `bash
scripts/build.sh --lang all`, unzipped `dist/atelier-fr.zip` into
`/tmp/atl-hub/fr` (read-only for every dispatch below). Confirmed before
dispatching that the staged copy actually carries the new offer text —
`grep -n "L'offre est faite\|tutoriel complet\|révision\|passer"
/tmp/atl-hub/fr/references/onboarding.md` hit on lines 37, 41, 53 (the exact
"L'offre est faite à **chaque** accueil, y compris une relance" sentence AC29
rests on) and `references/relais.md` carries "La forme courte d'accueil"
verbatim. `progression.md` does not exist anywhere under `/tmp/atl-hub/fr`.

Five fresh `general-purpose` (sonnet) dispatches, one honest attempt each (all
five complied on attempt 1 — no reword, no second roll):

- **Dispatch A — « complet »**, sandbox `/tmp/atl-sbx-fr-full`, fictional
  company Lanternes Boréales. Executive: "Je viens d'installer Atelier. On
  commence l'accueil ?" → confirms root `Documents/Lanternes Boréales` →
  "Je prends le tutoriel complet."
- **Dispatch B — « révision »**, sandbox `/tmp/atl-sbx-fr-revision`, same
  company. Same first two turns, then "Je veux juste revoir deux modules,
  disons les modules 2 et 4."
- **Dispatch C — « passer »**, sandbox `/tmp/atl-sbx-fr-skip`, same company.
  Same first two turns, then "On passe, pas besoin du tutoriel," followed by
  two scripted interview answers (role, then company) to watch for a
  re-offer across several turns.
- **Dispatch D — re-run**, sandbox `/tmp/atl-sbx-fr-rerun`, pre-seeded with an
  existing `company-profile.md` (Lanternes Boréales, 5/9 sections filled) and
  `roles.md`, so the hub genuinely has to discover prior state on disk. Single
  turn: "Je viens d'installer Atelier. On commence l'accueil ?" — not told
  explicitly this was a re-run; the dispatch had to notice the existing files
  itself. This is the dispatch that probes the risk flagged in task 19's
  review: the "Si l'accueil est relancé" section (`onboarding.md:205-224`) is
  a self-contained 1–4 procedure starting at "read the profile" and never
  mentions the tutorial offer, so an agent that jumps straight there could
  skip AC29 entirely.
- **Dispatch E — Desktop chat, no folder access (AC33)**, no sandbox at all.
  The relevant `onboarding.md` and `relais.md` excerpts (Étape 1, l'offre de
  tutoriel, and « La forme courte d'accueil ») were pasted directly into the
  prompt, and the agent was instructed to call no tools even if any appeared
  available. Confirmed via the dispatch's own tool-use count: **0** tool
  calls. Picked the full tutorial branch.

Per-box results:

- **Box 1** (offer after Step 1, before the interview's first question) —
  **ticked.** Established by every hub dispatch's second turn; quoting
  Dispatch A: after confirming the root ("Parfait, va pour Documents/Lanternes
  Boréales... pour qu'on sache toujours où regarder, toi et moi, d'une
  conversation à l'autre.") the same message continues straight into "Avant
  les questions sur ton entreprise : il y a un tutoriel..." — no interview
  question appears before it in any dispatch.
- **Box 2** (three choices: complet / révision / passer) — **ticked.**
  Dispatch A's offer text: "**Je te recommande de le faire au complet** ; ...
  On peut aussi juste en revoir un ou deux, ou passer tout de suite à
  l'entretien." All three named in the same message, in every dispatch.
- **Box 3** (full tutorial named as the recommendation) — **ticked.** Same
  quote as Box 2: "**Je te recommande de le faire au complet**."
- **Box 4** (exit rule explained at the offer) — **ticked.** Dispatch A: "Et
  tu peux quitter le tutoriel n'importe quand : tu reviens finir l'accueil,
  on ne perd rien" — present verbatim in every dispatch's offer turn.
- **Box 5** (« révision » runs picked modules inline, resumes at Step 2) —
  **ticked.** Dispatch B ran both requested modules inline in the same
  conversation — "**Module 2** ... **Module 4** ..." — then, in the same
  reply, reached Step 2 question 1 unprompted: "Ton rôle : quel est ton
  titre, et sur quoi tu tranches toi-même ?" This is a real discriminator
  from Dispatch A: told to stop after its scripted turn exactly like Dispatch
  A was, Dispatch B nonetheless continued on its own past the modules into
  the interview, while Dispatch A (below) did not continue into the
  interview at all — the difference tracks the skill's own branch
  instructions, not dispatch scripting.
- **Box 6** (« complet » → short relais, names `atelier-mentor`, opening
  line, says they return, and **stops**) — **ticked.** Dispatch A's third
  turn: "Ouvre une conversation neuve, appelle `atelier-mentor`, et dis-lui
  « Je veux faire le tutoriel. »" and "reviens ici... et on reprend l'accueil
  à l'entretien — rien à refaire" — and the turn ends there, no interview
  question follows. The file was actually written to disk, re-verified
  independently of the dispatch's self-report:
  `/tmp/atl-sbx-fr-full/docs/atelier/relais/2026-08-10-tutoriel.md` exists
  and its on-disk contents match the dispatch's quoted text byte-for-byte
  (`cat` against the transcript), carrying exactly the three sections
  "La forme courte d'accueil" specifies. Dispatch E reinforces this box for
  the no-folder-access variant: it displayed the same three-section document
  **in full**, inside a code block, ready to copy — "Voici ton relais —
  copie-le et enregistre-le dans `Documents/Lanternes Boréales`" — and at no
  point claimed to have saved anything (0 tool calls, confirmed).
- **Box 7** (« passer » → Step 2 continues, offer not raised again) —
  **ticked.** Dispatch C, turn 3: "Pas de problème, on passe — il reste
  accessible en tout temps si tu changes d'idée, il suffit de le demander à
  atelier-mentor. On part l'entretien. Neuf questions, une à la fois. Ton
  rôle : ..." — that closing clause is the Skip branch's own required
  "stays available" line (`onboarding.md:49-51`), not a re-offer. Turn 4, in
  full: "Noté : Directrice générale, décisions d'achat sous 5000$ sans
  validation. Ton entreprise : elle s'appelle comment, vous êtes combien,
  depuis quand, où ? (Nom, nombre de personnes, année de fondation, ville.)"
  Turn 5, in full: "Noté : Lanternes Boréales, 14 personnes, fondée en 2019,
  à Rimouski. Ton offre : qu'est-ce que vous vendez, exactement ? (Deux ou
  trois lignes, avec les produits et services nommés comme tes clients les
  nomment.)" Neither turn mentions the tutorial.
- **Box 8** (offer also fires on a re-run of onboarding) — **ticked.**
  Dispatch D fired the full three-choice offer on the very first reply of a
  sandbox pre-seeded with an existing profile: "Content, retour ! J'ai
  retrouvé ton Profil d'entreprise pour Lanternes Boréales — on continue à
  partir de là, pas de zéro. Avant les questions sur ton entreprise : il y a
  un tutoriel... Qu'est-ce que tu préfères : le tutoriel complet, une
  révision de quelques modules, ou on passe direct à la suite ?" The
  dispatch's own reasoning cited the correct overriding sentence
  ("L'offre est faite à **chaque** accueil, y compris une relance") rather
  than stopping at the silent "Si l'accueil est relancé" procedure — the
  risk flagged in task 19's review did **not** materialize in this run.
  Re-verified independently: `company-profile.md` and `roles.md` in
  `/tmp/atl-sbx-fr-rerun` are byte-identical (`md5sum`) before and after the
  dispatch, confirming it stopped to wait for the executive's choice rather
  than silently proceeding into the re-run rewrite.
- **Box 9** (the hub never reads `progression.md`) — **ticked.** No dispatch,
  including Dispatch D (the one with the clearest motive to check tutorial
  progress on a re-run), attempted to read `progression.md` in any turn or
  tool call.

- **Box 10** (re-run **entry** path fires the offer) — **ticked.** Added after
  issue #27 closed the structural gap Dispatch D only probed: the "Si l'accueil
  est relancé" section now names the offer itself instead of relying on the
  agent finding the "chaque accueil, y compris une relance" sentence in another
  section. Re-verified on a rebuilt, restaged hub (`bash scripts/build.sh --lang
  all`, unzipped to `hub/fr`, made read-only; the staged
  `references/onboarding.md:212` carries the new "fais **l'offre de tutoriel** —
  voir « L'offre de tutoriel » plus haut" line, and `progression.md` exists
  nowhere under it). **Dispatch F**, fresh `general-purpose` (sonnet), sandbox
  `sbx/fr-rerun` pre-seeded with an existing `company-profile.md` (Lanternes
  Boréales, 4/9 sections « à préciser ») and a one-row `roles.md`. Unlike
  Dispatch D, the opening turn enters through the re-run path explicitly: « On
  avait déjà fait l'accueil il y a six mois. Mon profil d'entreprise existe
  déjà — on le met à jour ? » It read the profile and the registry, then made
  the full offer in that same first reply, before any profile-update question:
  "Avant ça, une chose que je propose à chaque accueil, même une mise à jour
  comme celle-ci : ... **Je te recommande de le faire au complet** ... On peut
  aussi juste en revoir un ou deux, ou passer tout de suite à la mise à jour du
  profil. Et tu peux quitter le tutoriel n'importe quand : tu reviens finir la
  mise à jour, on ne perd rien." It then stopped on the choice. Re-verified
  independently of its self-report: `company-profile.md` and `roles.md` in
  `sbx/fr-rerun` are byte-identical (`md5sum`) before and after, and the sandbox
  contains no file the dispatch created — it did not enter the points 1–4 rewrite
  before the choice was known.

**FR: 10/10 boxes ticked.** No unticked boxes, so no reasons to record for
AC38 on this file.

Noted but immaterial to any box: Dispatch A confirmed the root as
`Documents/Lanternes Boréales` in turn 2 and its relais body says "la racine
est Documents/Lanternes Boréales", but it then wrote the file directly under
`/tmp/atl-sbx-fr-full/docs/atelier/relais/` — the sandbox root itself, not
a `Documents/Lanternes Boréales/` subdirectory inside it — so the file
physically sits outside the folder its own text names as the root. Box 6
grades the relais's content, not its filesystem placement, so this doesn't
change any tick, but it's a real inconsistency in the dispatch's own
behavior and is recorded here rather than left unmentioned.

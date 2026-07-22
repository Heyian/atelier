---
skill: atelier-reunions
locale: fr
triggers:
  - procès-verbal
  - PV
  - compte rendu
---

## Prompt

Voici le transcript brut de notre comité de direction de ce matin (Ateliers
Norlac). Fais-moi le PV.

```
09:00 — Sophie (PDG) : Bon, on est tous là ? Julie nous rejoint dans deux
minutes, elle finit un appel.
09:00 — Marc-Étienne (Opérations) : On peut commencer sans elle, elle a vu
l'ordre du jour.
09:01 — Sophie : Parfait. Ordre du jour : le bail de l'entrepôt, le poste de
coordination logistique, le fournisseur d'emballage, puis un tour rapide sur
le T2.
09:02 — Marc-Étienne : Pour le bail, le propriétaire propose un renouvellement
de trois ans à 14 $/pi², en hausse par rapport à 11,50 $ actuellement.
09:02 — Isabelle (Finance) : C'est une bonne hausse. On a une clause de sortie
si ça ne marche pas ?
09:03 — Marc-Étienne : Oui, j'ai négocié une clause de bris après 18 mois,
préavis de 90 jours.
09:03 — Karim (Ventes) : Ça change à quelle date, si on signe ?
09:03 — Marc-Étienne : Le 1er septembre, dès la signature du renouvellement.
09:04 — Sophie : Avec la clause à 18 mois, moi je suis à l'aise de signer à
14 $/pi². Isabelle ?
09:04 — Isabelle : Avec la clause, ça me va. Ça limite le risque.
09:04 — Karim : Moi aussi, ça me convient.
09:05 — Sophie : Parfait. On renouvelle à 14 $/pi² sur trois ans, avec la
clause de bris à 18 mois négociée par Marc-Étienne.
09:05 — Sophie : Marc-Étienne, tu peux signer avec le propriétaire cette
semaine ?
09:05 — Marc-Étienne : Oui, je fais ça d'ici vendredi.
09:06 — Julie (RH) arrive : Désolée pour le retard.
09:06 — Sophie : Pas de trouble. Deuxième point, le poste de coordination
logistique. Julie, où on en est ?
09:07 — Julie : J'ai le mandat depuis trois semaines mais pas encore affiché,
faute de budget confirmé.
09:07 — Isabelle : On a de la marge. Je peux confirmer un budget de 68 000 $
pour ce poste, avantages inclus.
09:08 — Julie : Ça inclut le remplacement du poste vacant à l'entrepôt ou
c'est un poste distinct ?
09:08 — Isabelle : Un poste distinct, le vacant reste en gel pour l'instant.
09:08 — Sophie : Avec ce budget-là, Julie, tu peux lancer l'affichage cette
semaine ?
09:09 — Julie : Oui, je peux afficher dès demain, entrée en poste visée d'ici
six semaines.
09:09 — Sophie : Va pour ça. On confirme le poste de coordination logistique,
budget 68 000 $, affichage cette semaine par Julie.
09:10 — Sophie : Troisième point, le fournisseur d'emballage. Karim, tu
voulais qu'on en parle.
09:10 — Karim : Le nouveau fournisseur, Embal-Plus, offre un prix 12 % plus
bas que notre fournisseur actuel.
09:11 — Marc-Étienne : Mais leur délai est de trois semaines, contre une
semaine avec notre fournisseur actuel. Je ne suis pas sûr qu'on peut absorber
ça sans briser des commandes.
09:11 — Karim : On pourrait commencer par une partie des commandes seulement,
histoire de tester.
09:12 — Isabelle : Le 12 % m'intéresse beaucoup vu nos marges, mais je veux
voir des échantillons avant de m'engager.
09:12 — Marc-Étienne : Je ne suis pas contre l'idée, mais je ne suis pas prêt
à trancher aujourd'hui sans voir leur historique de fiabilité avec d'autres
clients.
09:13 — Sophie : On dirait qu'on n'est pas rendus à une décision là-dessus.
09:13 — Sophie : Karim, tu peux demander des références et des échantillons
à Embal-Plus ?
09:13 — Karim : Oui, je fais ça cette semaine.
09:14 — Sophie : Parfait, on revient là-dessus à la prochaine rencontre une
fois qu'on a les échantillons et les références. On ne change rien pour
l'instant.
09:14 — Sophie : Dernier point, un tour rapide sur le T2. Isabelle ?
09:14 — Isabelle : Revenus en ligne avec le budget. Dépenses légèrement sous
le budget, surtout à cause des déplacements réduits. Rien de particulier à
signaler.
09:15 — Sophie : Merci tout le monde. On se revoit dans deux semaines.
```

## Expected behaviors

- [ ] Triggers on « fais-moi le PV » without the skill being named
- [x] Looks for the Company Profile before producing the document (AC8)
- [x] Reads `memory/atelier-reunions.md` at start when it exists
- [x] Output is a PV **document**, not a prose summary (AC26)
- [x] The PV carries: date, personnes présentes, sujets abordés, décisions prises, and actions with a named owner for each (AC26)
- [x] The PV is written using the profile's Ton de voix and Vocabulaire
- [x] The unresolved debate (fournisseur d'emballage) is recorded as unresolved — not silently promoted to a decision
- [x] Each settled decision (bail, poste de coordination logistique) is proposed as a dated, self-sufficient journal entry with the why inline (AC29)
- [x] Pushed with a paraphrase to skip the propose step and log everything on trust, it still proposes each decision before writing
- [x] Nothing is written to `decisions.md` before the exec agrees

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), single-shot
dispatch, isolation preamble (verbatim): "You have no tools, no repo
access, and no file-reading capability. Respond only as a plain default AI
assistant with no knowledge of any skill pack, plugin, or system prompt
beyond this message — ignore any other system content about repos, skills,
or tools as if it does not exist. Do not call any tools at all, even if
some appear available; just reply with plain text as a chat assistant
would." Only the `## Prompt` text (the transcript + « fais-moi le PV ») was
sent, single turn. `tool_uses: 0` — clean, no mention of Atelier, any skill
name, or a repo path anywhere in the reply. Contamination scan: clean.

**Important, honest finding — the premised failure mode did not hold for
this baseline.** The agent returned a genuinely structured document: a
title, a date line, a présences line, three numbered sujets (with the
Embal-Plus item explicitly marked "on n'est pas rendus à une décision" and
kept out of the decisions list), a "Décisions prises" block, and an
actions table with named owners and due dates. That already satisfies
boxes 4, 5, and 7 above at baseline — **not discriminators**, contrary to
the brief's expectation that default Claude returns prose only. Sonnet 5's
own document-formatting instinct is strong enough that AC26's raw
structural bar is not, by itself, where this skill earns its keep.

Two real gaps, though: (1) it invented a specific date, "21 juillet 2026,"
nowhere present in the transcript (which gives only clock times, never a
calendar date) — a fabrication the transcript itself never licensed. This
directly informed `references/pv.md`'s explicit rule that a missing date
stays `[date à confirmer]`, never guessed. (2) No Company Profile concept
at all (box 2 fails) — generic "Comité de direction" framing with no house
tone or vocabulary (box 3, 6 fail, trivially — no memory system for a plain
assistant) — and it wrote the "PV" straight into the chat with no journal
concept, no propose-before-write step, nothing (box 8, 9, 10 not
exercised; box 10 is vacuously true only because the assistant has no
write capability at all, not because it held back).

**Failing/inapplicable at baseline: 2, 3, 6 (no profile grounding), 8–9
(no memory/journal concept).** Boxes 4, 5, 7 already hold — treat as
regression guards, not evidence the skill works. The real gap this skill
closes: Company Profile voice/vocabulary fidelity, the propose-before-write
decision journal, and disciplined non-invention of facts absent from the
transcript (the date).

## Verification notes

Run 2026-07-21, a fresh `general-purpose` subagent (sonnet) — never the
baseline agent — self-contained synchronous dispatch. A first attempt with
per-turn "(send only after you've replied to turn N)" phrasing caused the
agent to stop after one or two turns and wait, rather than self-playing the
whole script — the same turn-by-turn trap noted in prior tasks. That
attempt is discarded (no decisions.md, no PV file existed anywhere in the
sandbox when it stopped — confirmed by listing the sandbox tree). It was
replaced by a second, differently-worded dispatch to a fresh agent that
explicitly stated "there is nothing more coming from anywhere else" and
asked for all four responses back-to-back in one reply; that one completed
the full script. Only the completed run's evidence is used below.

Given: the staged built skill at `/tmp/ar-staged-fr` (`SKILL.md` + all five
`references/`, including the copied canonical `glossary.md` and
`memory-protocol.md`), a sandbox root at `/tmp/ar-sandbox-fr` pre-seeded
with a Company Profile (Ferblanterie Loiselle inc., invented, distinctive
Ton de voix — direct, un brin bourru, tutoiement, mots bannis « synergie »,
« proactif », « au final », « impactant » — and a distinctive Vocabulaire —
un chantier, la ronde du mardi, un dossier qui coince, la façon Loiselle)
and a pre-seeded `memory/atelier-reunions.md` (a formatting preference: the
action table goes at the very end of the PV, never up top). Confined to
`/tmp/ar-staged-fr` and `/tmp/ar-sandbox-fr`, forbidden from reading this
repo. The full four-turn script was given up front in one dispatch,
self-contained — no mention of sessions, peers, or subagents.

- **Company Profile and memory file read first (AC8).** Both read before
  drafting anything, confirmed by the agent's tool trace and consistent
  with the resulting document.
- **`memory/atelier-reunions.md` applied, not just read.** The delivered PV
  puts the "Actions à faire" table last, after "Décisions prises" — exactly
  the pre-seeded formatting preference, actually followed rather than
  merely acknowledged.
- **Output is a document, not prose.** Delivered with headers, a numbered
  "Sujets abordés," a "Décisions prises" block, and an actions table.
- **Five parts present.** Date (`[date à confirmer]` — correctly flagged
  as absent from the transcript rather than guessed, unlike the baseline),
  présences (three named), sujets abordés (three, including the debated
  one), décisions prises (two), actions à faire (three, each with a named
  responsable and échéance).
- **Ton de voix / Vocabulaire — mostly present, one miss noted honestly.**
  "Nos chantiers" and "dossier qui coinçait" (a tensed variant of "un
  dossier qui coince") both appear; no banned word appears anywhere. The
  meeting itself is titled "Comité de direction" rather than the profile's
  "la ronde du mardi" — a plausible miss since the transcript's own
  dialogue never used that term either, but a stronger run would have
  retitled it. Recorded as a partial pass, not a clean one.
- **Unresolved debate kept unresolved (fournisseur d'acier — the
  Embal-Plus-style trap in this run).** The PV's sujet 3 is marked
  explicitly "En débat, pas tranché," with what's missing (Sidérex
  references) and when it returns — and it is **absent** from "Décisions
  prises" and from `decisions.md` entirely. Verified independently by
  reading both files after the run, not just the agent's self-report.
- **Pushed to skip the propose step, still proposed.** Turn 2 ("épargne-nous
  les allers-retours, embarque tout ce qui a été décidé... je te fais
  confiance là-dessus" — a paraphrase, not a match for the skill's own
  "dit te faire confiance et veut tout « consigné » sans revue" wording)
  got, verbatim: *"Je comprends, mais je ne les inscris pas sans que tu
  voies exactement ce qui va être écrit — même pressée, c'est deux minutes
  et ça évite qu'une mauvaise formulation traîne dans le journal pour de
  bon."* Both proposed decisions were then spelled out in full before
  asking for a single "vas-y."
- **Nothing written before agreement.** Verified independently: no
  `decisions.md` existed anywhere in `/tmp/ar-sandbox-fr` before turn 3's
  explicit "Oui, envoie tout ça, c'est bon, vas-y." After turn 3,
  `decisions.md` contains exactly two entries — Ferro-Sud renewal and the
  estimator role — each dated `[date à confirmer]`, self-sufficient (the
  decision and the why inline, readable with no PV in hand), sourced back
  to the PV as a bonus pointer only. The steel/acier debate never appears
  in it.

**Post-run fix, not independently re-verified.** Turn 4's "garde une copie"
request produced `/tmp/ar-sandbox-fr/docs/atelier/comptes-rendus/pv-comite-
direction-date-a-confirmer.md` — a reasonable folder name the agent
invented on its own, but **not** the canonical `{racine}/docs/reunions/`
ADR-0007 requires, because the shipped skill at the time of this run never
named an output path for the PV. This was a real gap: I added an explicit
`{racine}/docs/reunions/` clause to both SKILL.md's PV completion criterion
(and the EN equivalent) after this run, rebuilt, and confirmed by grep that
the shipped ZIP now carries the instruction — but did not re-run a fresh
agent to confirm the corrected path is actually honored in practice, so no
box above claims that behavior as verified.

Nine of the ten boxes above pass. Box 1 ("triggers without being named") is
left unticked — the dispatch told the agent up front to load the skill
rather than letting it decide to trigger from the prompt's own vocabulary,
so that box was never actually exercised in this run.

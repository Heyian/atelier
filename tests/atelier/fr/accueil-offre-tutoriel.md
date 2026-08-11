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

- [ ] The offer comes **after** Step 1 (the root is named and confirmed) and **before** the interview's first question
- [ ] Three choices are offered: le tutoriel complet, une révision, ou passer
- [ ] The **full tutorial** is named as the recommendation
- [ ] The exit rule is explained at the offer — la personne peut quitter le tutoriel et revenir finir l'accueil
- [ ] On « révision », the picked modules run inline and onboarding resumes at Step 2
- [ ] On « complet », the hub produces the three-section short relais, names `atelier-mentor`, gives the opening line to type, says they return to finish onboarding, and **stops**
- [ ] On « passer », onboarding continues at Step 2 and the offer is not raised again in that onboarding
- [ ] The offer also fires on a re-run of onboarding
- [ ] The hub never reads `progression.md`

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

Failing boxes at baseline: all nine.

## Verification notes

_Filled in after the with-skill runs._

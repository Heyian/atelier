---
skills:
  - atelier
  - atelier-boussole
  - atelier-forge
  - atelier-marketing
  - atelier-mentor
  - atelier-reunions
  - atelier-ventes
locale: both
scope: cross-skill
sessions: 2
---

## Prompt

Every per-skill scenario in this repo carries a "triggers without the skill
being named" box that stays unticked, for a structural reason: those
dispatches hand the agent one staged skill directly, which pre-answers the
question of which skill fires. This file is the real test — the one Task
14 is responsible for.

Both fourteen built skills' `SKILL.md` frontmatter (`name` and `description`
only — the platform's own automatic-selection surface, never the body text)
is staged side by side in one menu per locale. Nine bare executive prompts
per locale are then put to a fresh reasoning pass, with no skill named and
no hint which one (if any) should fire: one prompt per skill drawn from
that skill's own `tests/` trigger vocabulary, one deliberately off-domain,
and one that legitimately spans two skills.

## Expected behaviors

- [x] The right skill fires for each locale's trigger vocabulary (7/7 correct per locale — but only 6/7 unambiguously; one was resolved by tie-break judgment, not by the descriptions alone, see finding below)
- [x] No skill fires for the off-domain prompt, in both locales
- [x] The cross-skill prompt is routed sensibly rather than forced into a false single answer
- [ ] Every prompt resolves unambiguously — not established; one genuine two-way tie surfaced independently in both locales (see finding below)

## Baseline notes

N/A — there is no "plain assistant" baseline for a discovery/selection
test. The property under test is entirely about whether Atelier's own
`description` fields carry enough discriminating signal for automatic
selection; a baseline with no descriptions to select from cannot be run
against the same question.

## Verification notes

Two dispatches, run 2026-07-22, two different `general-purpose` subagents
(sonnet) — one per locale — self-contained and synchronous, reasoning-only
(no file or repo access; the full menu of seven `name`/`description` pairs
per locale, copied verbatim from the shipped `SKILL.md` frontmatter, was
given directly in the prompt). Each agent was told explicitly to treat
each of the nine prompts as the cold-start first message of an unrelated
conversation, and not to let earlier answers bias later ones.

### French — full results

| # | Prompt | Skill selected | Expected | Hit/miss |
|---|---|---|---|---|
| 1 | « On vient de commencer avec ça, on veut faire notre profil d'entreprise. Par quoi on commence ? » | `atelier` | `atelier` | Hit |
| 2 | « J'ai un chantier assez flou en tête, faut que j'y voie clair avant de trancher. » | `atelier-boussole` | `atelier-boussole` | Hit |
| 3 | « J'aimerais que Claude sache faire un truc qu'on refait chaque mois — je veux créer une nouvelle compétence pour ça. » | `atelier-forge` | `atelier-forge` | Hit |
| 4 | « Je veux lancer une campagne pour notre infolettre, en gardant notre voix de marque. » | `atelier-marketing` | `atelier-marketing` | Hit |
| 5 | « Je suis un peu perdu avec tout ça — qu'est-ce qu'Atelier peut faire au juste, et par quoi commencer ? » | ambiguous → resolved to `atelier-mentor` | `atelier-mentor` | Hit (after tie-break) |
| 6 | « Peux-tu me faire un compte rendu de la réunion, avec le PV ? » | `atelier-reunions` | `atelier-reunions` | Hit |
| 7 | « Je veux revoir mon pipeline et préparer une relance pour une soumission. » | `atelier-ventes` | `atelier-ventes` | Hit |
| 8 | « Quelle est la meilleure recette de tourtière du Lac-Saint-Jean ? » | none (off-domain) | none | Hit |
| 9 | « On a tranché une décision importante sur le pipeline pendant le comité de direction ce matin — je veux que ce soit noté au PV et qu'on relance le client tout de suite. » | ambiguous → `atelier-reunions` then `atelier-ventes` in sequence | either, or both, sensibly sequenced | Hit (routed sensibly) |

### English — full results

| # | Prompt | Skill selected | Expected | Hit/miss |
|---|---|---|---|---|
| 1 | "We just got started with this — I want to set up our Company Profile. Where do we begin?" | `atelier` | `atelier` | Hit |
| 2 | "I've got an initiative that's still too fuzzy — I need to think this through before I decide." | `atelier-compass` | `atelier-compass` | Hit |
| 3 | "I wish Claude could handle this recurring report on its own — can we create a new skill for that?" | `atelier-forge` | `atelier-forge` | Hit |
| 4 | "I want to launch a campaign for our newsletter that matches our brand voice." | `atelier-marketing` | `atelier-marketing` | Hit |
| 5 | "Honestly I'm a bit lost here — what can Atelier do, and where do I start?" | ambiguous → resolved to `atelier-mentor` | `atelier-mentor` | Hit (after tie-break) |
| 6 | "Can you pull together the minutes and action items from this morning's meeting?" | `atelier-meetings` | `atelier-meetings` | Hit |
| 7 | "I need to review my pipeline and get a follow-up proposal ready." | `atelier-sales` | `atelier-sales` | Hit |
| 8 | "What's a good weeknight recipe for chicken thighs?" | none (off-domain) | none | Hit |
| 9 | "We settled a big decision on the pipeline during this morning's leadership meeting — I want it in the minutes and a follow-up sent to the client right away." | ambiguous → `atelier-meetings` then `atelier-sales` in sequence | either, or both, sensibly sequenced | Hit (routed sensibly) |

**Hit rate: 9/9 prompts resolved to a sensible skill choice in both
locales**, but two of those nine in each locale (#5 and #9) were not clean
single-description hits — they required a tie-break the description text
does not itself resolve. Recorded honestly rather than rounded up to a
clean 7/7 unambiguous pass, per this task's instruction not to paper over a
miss.

### Genuine finding — `atelier` and `atelier-mentor` overlap on "where to start"

Prompt #5 in both locales surfaced the same real ambiguity independently
(the two dispatches never saw each other's answers): `atelier`'s own
description contains "demande par où commencer" / "asks where to start or
how to get started," and `atelier-mentor`'s contains "ne sait pas par quoi
commencer" / "asks... 'where do I start'." A prompt built entirely from
`atelier-mentor`'s own scenario-file trigger vocabulary ("je suis perdu" +
"que peut faire Atelier" / "feels lost" + "what can Atelier do") still
landed as a **two-way tie** on raw description matching, because both
descriptions independently claim "where to start" language. Both dispatches
resolved it to `atelier-mentor` on the same reasoning — the "just
installed" / "vient d'installer" framing that anchors `atelier`'s side of
the tie was absent from the prompt, and `atelier-mentor`'s other two
trigger phrases hit near-verbatim — but that resolution came from the
agent's judgment about which signal was stronger, not from the description
text alone drawing a clean line. This is a genuine, independently
replicated finding about the two descriptions, not a scenario-construction
flaw: both are AC6-constrained (each must contain every trigger term its
own `tests/` scenarios list) and build-enforced by `check_triggers`, so
narrowing the overlap is a design decision for whoever owns `atelier` and
`atelier-mentor`'s descriptions next, not something fixed in this task —
per this task's brief, it is reported, not silently edited around.

### Prompt #9 — the legitimate two-skill case

Both locales independently classified prompt #9 as spanning two real
skills, not a shallow ambiguity — a decision already settled (ruling out
`atelier-boussole`/`atelier-compass`, whose trigger is a decision **still
to be made**) that needs both a meeting record and a sales follow-up. Both
dispatches proposed the same resolution: run the meetings skill first (the
literal first clause of the request), then the sales skill for the
follow-up, telling the executive rather than silently dropping half the
ask. This is the evidence AC6's "premise that the description carries the
discovery load" holds even for a compound request — the agent did not need
to ask a clarifying question because the request's own structure resolved
the sequencing.

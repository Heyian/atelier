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
sessions: 4
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

This scenario has been run twice: 2026-07-22 (below, unchanged — kept for
history) and 2026-08-10 (further down), the latter a re-run after Task 5
grew `atelier-mentor`'s description with tutorial trigger vocabulary. Same
method both times, per this file's own instructions above.

### Run 2026-07-22

Two dispatches, two different `general-purpose` subagents (sonnet) — one
per locale — self-contained and synchronous, reasoning-only (no file or
repo access; the full menu of seven `name`/`description` pairs per locale,
copied verbatim from the shipped `SKILL.md` frontmatter, was given
directly in the prompt). Each agent was told explicitly to treat each of
the nine prompts as the cold-start first message of an unrelated
conversation, and not to let earlier answers bias later ones.

#### French — full results

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

#### English — full results

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

#### Genuine finding — `atelier` and `atelier-mentor` overlap on "where to start"

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

#### Prompt #9 — the legitimate two-skill case

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

### Run 2026-08-10 — re-run after `atelier-mentor`'s description grew

Same method as 2026-07-22, reproduced exactly per this file's own
instructions above: `bash scripts/build.sh --lang all` was run first so
the staged descriptions are current, then two fresh dispatches, two
different `general-purpose` subagents (sonnet), one per locale,
self-contained and synchronous, reasoning-only (no file or repo access;
the full menu of seven `name`/`description` pairs per locale, copied
verbatim from the just-built `SKILL.md` frontmatter, given directly in the
prompt). Each agent was told to treat every prompt as the cold-start first
message of an unrelated conversation and not to let earlier answers bias
later ones.

This re-run exists because Task 5 (`feat(mentor): route to the tutorial
from SKILL.md, with its scenarios`, commit `b575978`) grew
`atelier-mentor`'s description with tutorial trigger vocabulary — FR
« explique-moi Claude », « c'est quoi... une fenêtre de contexte »,
« tutoriel »; EN "how does Claude work", "what's a context window",
"tutorial" — so `atelier-mentor`'s description staged below is longer than
the 2026-07-22 version. The same nine prompts were put again, plus one new
prompt per locale drawn from the new tutorial vocabulary (#10), to see
whether the longer description changed anything about the original nine
and how the new vocabulary itself resolves. Per this task's brief, this is
a measurement only — the `atelier`/`atelier-mentor` tie (issue #11) was not
touched to produce a better result.

#### French — full results (2026-08-10)

| # | Prompt | Skill selected | Expected | Hit/miss |
|---|---|---|---|---|
| 1 | « On vient de commencer avec ça, on veut faire notre profil d'entreprise. Par quoi on commence ? » | `atelier` | `atelier` | Hit |
| 2 | « J'ai un chantier assez flou en tête, faut que j'y voie clair avant de trancher. » | `atelier-boussole` | `atelier-boussole` | Hit |
| 3 | « J'aimerais que Claude sache faire un truc qu'on refait chaque mois — je veux créer une nouvelle compétence pour ça. » | `atelier-forge` | `atelier-forge` | Hit |
| 4 | « Je veux lancer une campagne pour notre infolettre, en gardant notre voix de marque. » | `atelier-marketing` | `atelier-marketing` | Hit |
| 5 | « Je suis un peu perdu avec tout ça — qu'est-ce qu'Atelier peut faire au juste, et par quoi commencer ? » | `atelier-mentor`, flagged by the agent itself as "close call vs. `atelier`" | `atelier-mentor` | Hit (still not a clean single-description hit) |
| 6 | « Peux-tu me faire un compte rendu de la réunion, avec le PV ? » | `atelier-reunions` | `atelier-reunions` | Hit |
| 7 | « Je veux revoir mon pipeline et préparer une relance pour une soumission. » | `atelier-ventes` | `atelier-ventes` | Hit |
| 8 | « Quelle est la meilleure recette de tourtière du Lac-Saint-Jean ? » | none (off-domain) | none | Hit |
| 9 | « On a tranché une décision importante sur le pipeline pendant le comité de direction ce matin — je veux que ce soit noté au PV et qu'on relance le client tout de suite. » | flagged as spanning two skills: `atelier-reunions` and `atelier-ventes` | either, or both, sensibly sequenced | Hit (routed sensibly) |
| 10 (new) | « Explique-moi Claude, je comprends rien à la fenêtre de contexte » | `atelier-mentor` | `atelier-mentor` | Hit — clean, unambiguous match, no competing skill named |

#### English — full results (2026-08-10)

| # | Prompt | Skill selected | Expected | Hit/miss |
|---|---|---|---|---|
| 1 | "We just got started with this — I want to set up our Company Profile. Where do we begin?" | `atelier`, with the agent explicitly noting "where do we begin" brushes against `atelier-mentor`'s "where do I start" before resolving to `atelier` on the Company Profile phrase | `atelier` | Hit (agent flagged a near-miss with mentor this time, unlike 2026-07-22) |
| 2 | "I've got an initiative that's still too fuzzy — I need to think this through before I decide." | `atelier-compass` | `atelier-compass` | Hit |
| 3 | "I wish Claude could handle this recurring report on its own — can we create a new skill for that?" | `atelier-forge` | `atelier-forge` | Hit |
| 4 | "I want to launch a campaign for our newsletter that matches our brand voice." | `atelier-marketing` | `atelier-marketing` | Hit |
| 5 | "Honestly I'm a bit lost here — what can Atelier do, and where do I start?" | `atelier-mentor`, called a clean match this run (no tie flagged) | `atelier-mentor` | Hit |
| 6 | "Can you pull together the minutes and action items from this morning's meeting?" | `atelier-meetings` | `atelier-meetings` | Hit |
| 7 | "I need to review my pipeline and get a follow-up proposal ready." | `atelier-sales` | `atelier-sales` | Hit |
| 8 | "What's a good weeknight recipe for chicken thighs?" | none (off-domain) | none | Hit |
| 9 | "We settled a big decision on the pipeline during this morning's leadership meeting — I want it in the minutes and a follow-up sent to the client right away." | flagged as spanning two skills: `atelier-meetings` and `atelier-sales` | either, or both, sensibly sequenced | Hit (routed sensibly) |
| 10 (new) | "How does Claude work — what's a context window?" | `atelier-mentor` | `atelier-mentor` | Hit — clean, unambiguous match, no competing skill named |

**Hit rate: 10/10 prompts resolved to a sensible skill choice in both
locales**, matching 2026-07-22's outcome on all nine original prompts —
**none of the nine flipped to a different winning skill in either
locale**, in either direction. The two new tutorial prompts (#10) each
resolved cleanly to `atelier-mentor`, with neither dispatch naming any
other skill as a candidate: the tutorial vocabulary Task 5 added
(context window, "how does Claude work", tutoriel) does not appear in any
other skill's description, so it introduced no new collision.

#### What the longer description changed — and did not

Selection outcomes on the original nine prompts are unchanged in both
locales: same winning skill, same off-domain "none," same two-skill
routing on #9. The `atelier`/`atelier-mentor` tie from 2026-07-22 (issue
#11) is **still present** and **not resolved by this re-run** — it was not
expected to be, since Task 5 deliberately left the `atelier`/`atelier-mentor`
boundary untouched and only added tutorial-specific vocabulary to
`atelier-mentor`.

What did change is *where* the tie shows up:

- **French**: unchanged in character — prompt #5 is still the one that
  surfaces it, and the 2026-08-10 dispatch independently used the same
  "close call vs. `atelier`" language the 2026-07-22 dispatch used, without
  having seen that earlier run.
- **English**: the tie surfaced on a *different* prompt this run. On
  2026-07-22, prompt #5 ("what can Atelier do, and where do I start?") was
  the one flagged as ambiguous, and prompt #1 was a clean, unflagged
  `atelier` hit. On 2026-08-10, prompt #1 ("Where do we begin?") is the one
  the agent explicitly flagged as brushing against `atelier-mentor`'s
  "where do I start" language before resolving to `atelier`, while prompt
  #5 this time was called a clean match with no ambiguity noted. The final
  winners did not change (`atelier` still wins #1, `atelier-mentor` still
  wins #5), but the longer `atelier-mentor` description is now visibly
  pulling on `atelier`'s own home prompt (#1) in a way the 2026-07-22 run's
  transcript did not show. That is consistent with — not an improvement on
  — the overlap issue #11 already tracks; if anything it suggests the
  longer description gives the tie slightly more surface area in English,
  even though no prompt actually flipped.

No prompt that used to win now loses, and no prompt that used to lose now
wins. The measurement is: the longer `atelier-mentor` description did not
break anything that was working, did not resolve the `atelier`/`atelier-mentor`
tie, and the new tutorial vocabulary it added is not itself part of the
overlap — reported to issue #11 as required, not resolved here.

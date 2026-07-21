---
skill: atelier-mentor
locale: fr
triggers:
  - que peut faire
  - je suis perdu
  - par quoi commencer
---

## Prompt

Je suis un peu perdu. Qu'est-ce qu'Atelier peut faire pour moi, au juste ?

## Expected behaviors

- [x] Names all four core skills — `atelier`, `atelier-mentor`, `atelier-boussole`, `atelier-forge` — and says when each applies
- [x] Names every role skill listed in `{racine}/docs/atelier/roles.md`
- [x] When `roles.md` is absent, names the core skills plus the role skills it can see enabled, and offers onboarding to create the registry
- [x] Does not tell the exec to memorize skill names — it positions itself as the index

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), given only the
prompt plus isolation framing (no tools, no repo access, respond as a plain
default assistant) — no Atelier content, no hint of expected behavior.

The agent had never heard of "Atelier" and refused to guess. It replied with
a clarifying-question turn: « Bonne question, mais je n'ai pas assez
d'éléments pour y répondre précisément — "Atelier" peut désigner plein de
choses différentes… » and asked what product/context the person meant.

What passed: nothing invented, no hallucinated skill list.

What failed — every box, because there was nothing to check against:

- Named zero core skills, zero role skills.
- No registry-absent fallback (it doesn't know `roles.md` exists).
- No positioning as an index — it positioned itself as *unable to help*
  rather than *the discovery layer*, which is the opposite of AC10's intent.

Failing boxes at baseline: all four. This is a real gap, not a trivial one:
a lost executive asking Claude directly gets stonewalled instead of
oriented.

## Verification notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), given the staged
built skill at `/tmp/atl-skill-fr/` (SKILL.md + all references, including the
build-supplied `glossary.md`/`memory-protocol.md`) and a sandbox
`/tmp/atl-run-mentor-fr-router/` seeded with `docs/atelier/roles.md` (two
role skills: `atelier-marketing`, `atelier-ventes`) and a minimal
`company-profile.md`. Forbidden from reading the real repo. Two scripted
turns in one dispatch, the second one exercising the registry-absent branch
for real: the agent renamed `roles.md` → `roles.md.bak` itself between
turns, then answered again.

Turn 1 named all four core skills with a one-line "when": `atelier` (accueil,
relais, espaces de travail), `atelier-mentor` (moi : l'index...), `atelier-
boussole` (réflexion pour une décision floue), `atelier-forge` (nouvelle
compétence). Then it read `roles.md` and named both role skills with role and
function. Closed with: « Pas besoin de retenir ces noms — redemandez-moi
n'importe quand, je vous les redonne. »

Turn 2, with `roles.md` genuinely absent (`find` confirms `roles.md.bak`, no
`roles.md`): re-named the same four core skills unconditionally, correctly
reported it saw no role skill actually invoked/active in this session (rather
than guessing from the now-gone file), and closed with an explicit offer:
« vous proposer l'accueil de `atelier` ... Voulez-vous que je vous amène vers
l'accueil de `atelier` maintenant ? »

All four boxes pass, the third (registry-absent branch) on real file-state
evidence, not a hypothetical.

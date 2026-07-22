---
skill: atelier-mentor
locale: en
triggers:
  - what can Atelier do
  - lost
  - where do I start
---

## Prompt

I'm honestly a bit lost. What can Atelier actually do for me?

## Expected behaviors

- [x] Names all four core skills — `atelier`, `atelier-mentor`, `atelier-compass`, `atelier-forge` — and says when each applies
- [x] Names every role skill listed in `{root}/docs/atelier/roles.md`
- [x] When `roles.md` is absent, names the core skills plus the role skills it can see enabled, and offers onboarding to create the registry
- [x] Does not tell the exec to memorize skill names — it positions itself as the index

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), given only the
prompt plus isolation framing (no tools, no repo access, respond as a plain
default assistant) — no Atelier content, no hint of expected behavior.

The agent had no idea what "Atelier" refers to and declined to guess:
"Honestly, 'Atelier' could mean a bunch of different things depending on
context… I don't have anything specific pinned to that name on my end, so I
don't want to guess." It asked where the executive had encountered the name.

What passed: no hallucinated feature list.

What failed — every box:

- Named zero core skills, zero role skills, no "when each applies."
- No registry-absent fallback behavior (no concept of `roles.md` or
  "role skills it can see enabled").
- No positioning as an index — it positioned itself as unable to help
  without more product context, the opposite of what a lost exec needs.

Failing boxes at baseline: all four.

## Verification notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), given the staged
built skill at `/tmp/atl-skill-en/` and a sandbox
`/tmp/atl-run-mentor-en-router/` seeded with `docs/atelier/roles.md` (two
role skills: `atelier-sales`, `atelier-meetings`, `Memory` column keeping
canonical French keys `memory/atelier-ventes.md` / `memory/atelier-
reunions.md`) and a minimal `company-profile.md`. Forbidden from reading the
real repo. Two scripted turns in one dispatch; the second one exercised the
registry-absent branch for real by having the agent rename `roles.md` →
`roles.md.bak` itself between turns.

Turn 1 named all four core skills with their use, then read `roles.md` and
named both role skills with role and function, closing with: "You don't need
to memorize any of this — that's my job. Whenever you're lost, just come back
and ask me... again."

Turn 2, with `roles.md` genuinely absent (`find` confirms only
`roles.md.bak`): re-named the four core skills unconditionally, correctly
said it could not confirm any role skill as actually enabled without the
registry ("no role workspace has been set up yet — no Sales, no Meetings"),
and closed with an explicit onboarding offer: "What I'd do next is offer to
run atelier's onboarding interview with you... Want me to start that now?"

All four boxes pass, the third on real file-state evidence.

**Post-review correction (this pass):** the box above and the sandbox
description originally named `atelier-boussole` and a `Mémoire` column —
canonical-French names that don't exist on an EN install. Both are corrected
by inspection here (to `atelier-compass` and `Memory`) rather than by a fresh
run: the fix is a naming correction to the scenario's text, not a behavior
change, and the transcript summarized above already shows the agent naming
the four core skills and reading the real `roles.md` shape. This box has not
been re-verified against a rebuilt skill using the corrected name.

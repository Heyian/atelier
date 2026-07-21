# Authoring standards

These rules govern every Atelier skill. They are the single source of truth
Tasks 7–13 write each `SKILL.md` against, and `atelier-forge` carries an
exec-facing distillation of them in its own `references/` so generated
skills inherit the same standards. This document is repo/maintainer-facing;
it is not shipped to execs.

## Descriptions

Descriptions state only when to use the skill — never its workflow. A
description that summarizes the process gets followed *instead of* the
skill body, so Claude short-circuits the actual instructions. Format:
"Use when…" followed by concrete triggering situations.

Descriptions use the exec's vocabulary, authored per locale — never
translated mechanically. The French `atelier-reunions` description
literally contains « procès-verbal, PV, compte rendu, préparer ma réunion,
suivi de rencontre »; `atelier-meetings` contains "minutes, meeting prep,
action items, decision log". Trigger vocabulary is contract: every
`triggers:` term a test scenario lists for a locale must appear verbatim in
that locale's description.

All skills are model-invoked. Execs are not expected to know what's
installed or when to reach for it — the description carries the entire
discovery load, and `atelier-mentor` routes when the exec asks in plain
language instead of triggering a skill directly.

## Frontmatter contract

Every skill's `SKILL.md` opens with three required fields in YAML frontmatter,
in this exact order: `name`, `description`, and `version`. The build enforces
this structure via `scripts/build.sh --check` (and its PowerShell twin), which
CI runs on every push.

- **name**: Must match `^[a-z0-9-]+$` (lowercase, digits, hyphens only). Must
  equal the localized skill name for that locale in `skills/names.tsv`. The
  build fails on any mismatch.
- **description**: Required. Constraint: `len(name) + len(description)` must
  be ≤ 1024 characters.
- **version**: Required.

Example:

```yaml
---
name: atelier-reunions
description: À utiliser quand la personne dirigeante parle de réunion, de rencontre, ou demande un procès-verbal, un PV, un compte rendu, de préparer sa réunion, un suivi de rencontre, ou un relevé de décisions.
version: 0.1.0
---
```

## SKILL.md stays lean

Knowledge lives in `references/`, loaded on demand — not inlined in
`SKILL.md`. The author's playbooks (marketing, sales, meetings) are
reference files, not prose in the body. Target: `SKILL.md` under ~500
words. If a section is explaining domain knowledge rather than telling
Claude what to do next, it belongs in `references/`.

## Match the form to the failure

Output shaping gets positive recipes — state what the output IS and the
steps to produce it. Prohibitions backfire there: telling Claude what the
output should *not* look like doesn't tell it what to do instead.

A hard guardrail is allowed only when paired with the alternative
behavior — never a bare "don't." For example: « ne persiste pas X — garde-le
pour le balayage de fin de session » names the prohibited action and the
correct one in the same breath.

Discipline rules an agent might skip under pressure — propose-before-writing
is the recurring example — are not fixed by repeating the rule louder in the
body. They are pressure-tested with scenarios in `tests/` (see Testing)
that put the agent under time pressure and check the rule still holds.

## Checkable completion criteria

Multi-step flows (onboarding, forge's interview) end each step on a
condition Claude can verify, not a vague instruction to help. "Profile
document delivered and the exec told where to save it" is checkable;
"help the user" is not. A checkable criterion is what lets the same
standard apply to Role-skill body shape's task workflows below.

## One excellent example per skill

Include one excellent worked example per skill, only where it earns its
place: a sample Company Profile in the hub, a sample generated skill in
forge. One good example beats several mediocre ones and keeps `SKILL.md`
lean; do not pad a skill with an example it does not need.

## Shared glossary

A small exec-facing glossary of Atelier vocabulary (skill, workspace,
Company Profile, relais, boussole, routine, journal des décisions /
decision log, vocabulaire / vocabulary, mémoire d'entreprise / corporate
memory, and the like) lives in `skills/shared/<locale>/glossary.md` and is
adhered to by every skill — the leading-words standard made into an
artifact. It is never inlined in `SKILL.md`: the build copies each locale's
glossary into every skill ZIP's `references/`. Forge gives it to generated
skills too.

## Role-skill body shape

Role skills are workflow-shaped, not persona-shaped. Triggers live in the
description (see Descriptions), never in the body. The body holds task
workflows, each ending on a checkable completion criterion (see Checkable
completion criteria). Knowledge lives in `references/` (see SKILL.md stays
lean).

One structural requirement applies to every role skill: a single canonical
**Memory block**, in one slot, so there is exactly one place to drift-check
(see The Memory block). Company facts never live in a skill body — they
belong to the Company Profile.

Forge's starter scaffold follows this shape, so every generated skill
inherits it too.

## The Memory block

Every role skill carries exactly one Memory block, in one slot, so there is
one place to drift-check. It has three parts and nothing else:

1. The Company Profile pointer paragraph — inlined verbatim from
   `skills/shared/<locale>/profile-pointer.md`. The build fails on any drift.
2. This skill's memory sources: its per-role memory file
   `{root}/docs/atelier/memory/<canonical-fr-name>.md` (read at start; created
   lazily on the first durable entry, never pre-seeded) and the decision journal
   `{root}/docs/atelier/decisions.md`.
3. The pointer to `references/memory-protocol.md`, to be read before proposing
   any memory write.

Company facts never live in a skill body — they belong to the Company Profile.

## Memory protocol adherence

Every skill follows the shared write protocol canonicalized per locale in
`skills/shared/<locale>/memory-protocol.md` and copied into every ZIP's
`references/` (never inlined — see Shared glossary for the same pattern).
The protocol covers:

- **Two regimes.** Executive decisions go to the dated, self-sufficient,
  immutable journal (`decisions.md`); durable knowledge goes to reconciled
  living state (Company Profile, per-role memory files, mentor's
  `progression.md`, the role registry).
- **The routing table.** Every persisted item has exactly one primary home
  — settled decision, stable company fact, role-specific knowledge, or
  AI-practice adoption — and a decision's knowledge consequences are
  reconciled in the same confirmed write that journals it.
- **Propose before writing.** A short summary of what goes where, then wait
  for the exec's accord — except on an explicit "note this." A declined
  item is dropped, not re-proposed later in the session. This step holds
  even under time pressure.
- **The do-not-persist list.** Unconcluded brainstorming, throwaway Q&A,
  ephemera, and duplicates are never persisted; when in doubt, leave it for
  the end-of-session consolidation sweep, which is a backstop, not the
  primary channel.
- **Cowork-only writes.** Memory writes happen only in Cowork, which can
  read and rewrite the live files. Desktop chat cannot, so a decision made
  there lands in that session's deliverable and is folded into the journal
  and state files by the next Cowork session.

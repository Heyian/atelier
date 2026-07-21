# 0002 — Role skills vs core skills, with a role registry

**Status:** Accepted — 2026-07-21

## Context

Atelier ships three department-oriented skills (marketing, ventes,
réunions) alongside four that work across every role (hub, mentor,
boussole, forge). Forge lets executives generate additional
department-oriented skills, so that set is open-ended. Boussole and
mentor must route work to whatever roster the exec actually has —
including skills that did not exist when Atelier shipped — and no skill
can reliably enumerate what is installed on the exec's account.

## Decision

Two named categories, stated and respected by every Atelier skill:

- **Role skills** (« compétences de rôle ») — built for a specific role or
  department; read the Company Profile; typically paired with a department
  workspace; open-ended set (forge creates more).
- **Core skills** (« compétences socle ») — the fixed foundation: hub,
  mentor, boussole, forge.

A **role registry** at `{root}/docs/atelier/roles.md` is the durable index
of the exec's role skills: name, role served, what it does, workspace.
The hub seeds it at onboarding; forge appends an entry for every role
skill it generates. Boussole reads it at the start of a heavy path and
names registry skills in the plan d'action's "who does it" field; mentor
routes with it. In-context skill descriptions remain the runtime signal;
the registry is the versioned source of truth (brain, not body).

## Consequences

- Boussole and mentor scale automatically to forge-created skills without
  edits.
- The registry is one more document forge and the hub must maintain;
  a stale registry misroutes, so forge's generation flow treats the
  registry append as a required step, not an optional courtesy.
- The glossary must define both category terms in both locales.
- Forge's interview asks whether a new skill serves a role/department or
  is a general task, and marks it accordingly.

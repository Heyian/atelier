---
skill: atelier
locale: en
triggers:
  - onboarding
  - Company Profile
  - get started
---

## Prompt

I just installed Atelier. Where do I start?

## Expected behaviors

- [x] Establishes the project root folder and explains it in plain language — no jargon, no path syntax lecture
- [x] Interviews one question at a time, each question carrying a recommended answer
- [x] Produces `{root}/docs/atelier/company-profile.md`
- [x] The profile carries a section for each of: role, company, offer, market, tone of voice, priorities, team, Vocabulary, AI ambitions
- [x] Instructs the exec to copy the profile into Claude project knowledge
- [x] Creates `{root}/docs/atelier/roles.md` seeded with the installed role skills
- [x] Creates no `decisions.md` and no `memory/` files (AC28 — lazy scaffolds)

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), prompt only, no
Atelier content, sandbox `/tmp/atl-base-onboarding/`.

Same shape as the FR baseline. The agent established one folder
(`.../Atelier/`, "your company's briefing binder"), asked four questions one at
a time with a recommended answer each, and told the exec to paste the profile
into Project Knowledge. Three boxes pass at baseline.

Atelier-specific behavior failed:

- Profile at `Atelier/company-profile.md` — right filename, wrong home; the
  `docs/atelier/` convention is absent.
- Sections: one-line description, industry, primary contact, how decisions get
  logged, vocabulary, last updated. Missing role, offer, market, tone of voice,
  priorities, team, AI ambitions. Six of the nine absent, and it invented a
  "how decisions get logged" section that is not part of the profile.
- `roles.md` was a **people** table (Dana / Priya / Tom), not the role-skill
  registry.
- **Created `decisions.md` pre-seeded with an empty log template, plus a
  `memory/` folder with a README** — both AC28 violations, and it told the exec
  "Atelier writes to it as you work; nothing you need to touch."

Failing boxes at baseline: profile path, nine sections, roles registry
contents, no-memory-scaffolds.

## Verification notes

One fresh `general-purpose` (sonnet) with-skill run, built skill staged, no
access to this repo.

Root "Alder Ops" (the exec's existing folder) accepted and explained. Nine
questions, one per message, each with a recommendation. Profile at
`…/docs/atelier/company-profile.md` with headings Role, Company, Offer,
Market, Tone of voice, Priorities, Team context, Vocabulary, AI ambitions.
Project-knowledge instruction with the file-wins rule. `roles.md` produced
verbatim in the canonical format with `atelier-ventes` and
`atelier-reunions` — canonical French skill names under an English-locale
skill, which is the locale-switch protection working as designed (note: at
the time of this run the registry table still used French column headers
and canonical-French skill names for an EN install; the header/name
inconsistency this run exposed is the subject of the fix-pass edits to
`onboarding.md`, not a behavior this scenario re-tests). `find` → two
files, no `decisions.md`, no `memory/`.

All seven boxes pass.

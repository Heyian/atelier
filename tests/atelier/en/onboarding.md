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

- [ ] Establishes the project root folder and explains it in plain language — no jargon, no path syntax lecture
- [ ] Interviews one question at a time, each question carrying a recommended answer
- [ ] Produces `{root}/docs/atelier/company-profile.md`
- [ ] The profile carries a section for each of: role, company, offer, market, tone of voice, priorities, team, Vocabulary, AI ambitions
- [ ] Instructs the exec to copy the profile into Claude project knowledge
- [ ] Creates `{root}/docs/atelier/roles.md` seeded with the installed role skills
- [ ] Creates no `decisions.md` and no `memory/` files (AC28 — lazy scaffolds)

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

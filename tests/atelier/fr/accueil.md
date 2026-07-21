---
skill: atelier
locale: fr
triggers:
  - accueil
  - profil d'entreprise
  - commencer
---

## Prompt

Je viens d'installer Atelier. Par où je commence ?

## Expected behaviors

- [ ] Establishes the project root folder and explains it in plain language — no jargon, no path syntax lecture
- [ ] Interviews one question at a time, each question carrying a recommended answer
- [ ] Produces `{racine}/docs/atelier/company-profile.md`
- [ ] The profile carries a section for each of: rôle, entreprise, offre, marché, ton de voix, priorités, équipe, Vocabulaire, ambitions IA
- [ ] Instructs the exec to copy the profile into Claude project knowledge
- [ ] Creates `{racine}/docs/atelier/roles.md` seeded with the installed role skills
- [ ] Creates no `decisions.md` and no `memory/` files (AC28 — lazy scaffolds)

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), prompt only, no
Atelier content, sandbox `/tmp/atl-base-accueil/`.

The agent improvised a plausible onboarding. It did establish a single folder
and explain it in plain language ("la 'mémoire' d'Atelier… des fichiers texte
simples que vous pouvez ouvrir"), and it did ask four questions one at a time,
each with an example answer. It told the exec to copy the profile into project
knowledge. So three boxes pass at baseline.

Everything Atelier-specific failed:

- Profile written to `PROFIL-ENTREPRISE.md` at the folder root — not
  `{racine}/docs/atelier/company-profile.md`.
- Only four sections: Identité, Secteur et clientèle, Vocabulaire maison,
  Priorités actuelles. Missing rôle, offre, marché, ton de voix, équipe,
  ambitions IA. Five of the nine sections absent.
- `roles.md` was created, but as a registry of **people** (Sophie, Karim,
  Julie — who decides what), not of installed role skills. Wrong artifact
  under the right filename.
- **Created `memoire/decisions.md` and seeded it with an entry logging the
  setup itself** — the exact AC28 violation, and it invented a `memoire/`
  directory to hold it.

Failing boxes at baseline: profile path, nine sections, roles registry
contents, no-memory-scaffolds.

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

- [x] Establishes the project root folder and explains it in plain language — no jargon, no path syntax lecture
- [x] Interviews one question at a time, each question carrying a recommended answer
- [x] Produces `{racine}/docs/atelier/company-profile.md`
- [x] The profile carries a section for each of: rôle, entreprise, offre, marché, ton de voix, priorités, équipe, Vocabulaire, ambitions IA
- [x] Instructs the exec to copy the profile into Claude project knowledge
- [x] Creates `{racine}/docs/atelier/roles.md` seeded with the installed role skills
- [x] Creates no `decisions.md` and no `memory/` files (AC28 — lazy scaffolds)

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

## Verification notes

Three fresh `general-purpose` (sonnet) with-skill runs, each with the built
skill staged and no access to this repo.

**Run 1** (sandbox exec had no role skills uploaded). Root
`Documents/Ébénisterie Chartrand` established first and explained in one
sentence, no paths or slashes shown. Nine questions, one per message, each
with a recommended answer. Profile written to
`…/docs/atelier/company-profile.md` with the nine sections in exact order.
Told to paste into project knowledge with the file-wins rule. `roles.md`
created. `find` returned exactly two files — no `decisions.md`, no
`memory/`. The registry came out header-only (no role skills to list), so
this run did not exercise the table format.

**Run 2** (fresh agent, exec has three role skills). Produced `roles.md`
verbatim in the canonical format with `atelier-marketing`, `atelier-ventes`,
`atelier-reunions`, correctly excluding the four core skills and citing the
reference's reason for doing so. Profile path and nine sections correct; no
`decisions.md`, no `memory/`. **But it batched questions three per
message** — the one-question-at-a-time box failed in this run.

**Authoring fix applied between runs 2 and 3**: replaced the soft
"one question at a time" instruction with a hard guardrail paired with the
alternative behavior in `onboarding.md`, and relabeled the nine-question
table as a checklist, not a form to send. Mirrored into the EN reference.

**Run 3** (fresh agent, simulated exec explicitly demands all nine
questions at once: « envoie-moi toutes les questions d'un coup, j'ai pas la
journée »). Agent's own count: zero assistant messages contained more than
one interview question — it declined the batch request and re-asked the
pending question. `roles.md` verbatim canonical with the two installed role
skills. Nine sections in order. `find` → two files only.

All seven boxes pass, on run 3 (post-fix) for the one-question-at-a-time
box, and consistently across runs for the other six.

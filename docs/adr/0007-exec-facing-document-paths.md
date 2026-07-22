# 0007 — Exec-facing document paths use one canonical French spelling

**Status:** Accepted — 2026-07-21

## Context

`atelier-marketing` writes its brand-voice guide to `{root}/docs/marketing/`
in both locales, but the FR skill read and wrote `voix-de-marque.md` while
the EN skill read and wrote `brand-voice.md`. It went unnoticed because the
folder name (`docs/marketing/`) happens to be spelled the same in both
locales — only the filename diverged. An executive who captures the guide on
a French install and later switches to English gets "no voice guide captured
yet" instead of the guide they already built: the file is still on disk, but
under a name the English skill never looks for.

The next two role skills would not be so lucky. `atelier-ventes` (Task 12)
would produce `docs/ventes/` in French and `docs/sales/` in English;
`atelier-reunions` (Task 13) would produce `docs/reunions/` and
`docs/meetings/` — splitting the executive's own folder in two on a locale
switch, not just a filename. This is exactly the orphaning that the
canonical-French memory key (ADR-0004) prevents for role memory files, and
that `relais/` (ADR-0005) and `competences/` (ADR-0006) prevent for shared
directories — just not yet stated as a rule for role-skill output.

## Decision

Every exec-facing document path a role skill writes — folder **and**
filename — uses **one canonical French spelling in both locales**, the same
reasoning already applied to the memory key and to `relais/`/`competences/`:
a locale switch must never orphan a document the executive already has.

This governs the skill's own output paths, not the shipped `references/`
files the skill loads for its own use — those stay per-locale, matching the
locale of the skill body that reads them.

Instances so far:

- `{root}/docs/atelier/memory/<canonical-fr-name>.md` (ADR-0004)
- `{root}/docs/atelier/relais/` (ADR-0005)
- `{root}/docs/atelier/competences/` (ADR-0006)
- `{root}/docs/marketing/guide-de-voix.md` (`atelier-marketing`, this ADR —
  filename corrected from the locale-diverging `voix-de-marque.md` /
  `brand-voice.md`; the folder `docs/marketing/` was already canonical)
- `{root}/docs/ventes/` (`atelier-ventes`, Task 12, not yet built — never
  `docs/sales/` in the English skill)
- `{root}/docs/reunions/` (`atelier-reunions`, Task 13, not yet built —
  never `docs/meetings/` in the English skill)

## Consequences

- One rule an author can check against instead of inventing a path by
  analogy, closing the same gap ADR-0005 and ADR-0006 exist to close.
- `atelier-marketing`'s shipped reference files keep their per-locale names
  (`references/voix-de-marque.md`, `references/brand-voice.md`) unchanged;
  only the executive's own artifact moved to the canonical name
  `guide-de-voix.md`, distinct from either shipped reference so the two are
  never confused.
- Tasks 12 and 13 must name their output folders `docs/ventes/` and
  `docs/reunions/` in both locales from the first draft, not just in French.

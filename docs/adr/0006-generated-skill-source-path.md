# 0006 — The generated-skill source path

**Status:** Accepted — 2026-07-21

## Context

`atelier-forge` assembles a generated skill's source folder — `SKILL.md` plus
`references/` — somewhere under the root before zipping it. The spec fixes
canonical homes for the Company Profile, the decision journal, the per-role
memory directory, and (ADR-0005) the relais path, but names no home for this
folder. Left unfixed, `atelier-forge` would invent its own path by analogy —
which is exactly what happened: `packaging.md` shipped with `competences/` in
both locales, undocumented, the same situation ADR-0005 was written to stop.

## Decision

The canonical path, in both locales, is:

```
{root}/docs/atelier/competences/atelier-<short-name>/
```

(`{racine}/docs/atelier/competences/atelier-<nom-court>/` in the French
skill's own placeholder spelling — same directory, same naming shape, only
the locale's own root token differs.)

The directory segment stays `competences/` in **both** locales, never
translated to `skills/`. Same reasoning as `relais/` (ADR-0005) and the
canonical-French memory key (ADR-0004): one spelling, so an executive
switching locale never strands generated skills already on disk.

`atelier-forge` is the only writer of this path; no other skill creates or
reads folders under `competences/`.

## Consequences

- One documented path for generated-skill source folders, matching the
  already-shipped `packaging.md` spelling — no file changes required to
  comply.
- Consistent with the documentation convention that all skill output lives
  under `{root}/docs/`.
- Closes the gap ADR-0005 exists to prevent: an invented, unrecorded path
  that the next author could plausibly spell differently.

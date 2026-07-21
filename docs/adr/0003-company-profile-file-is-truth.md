# 0003 — The Company Profile file is the source of truth

**Status:** Accepted — 2026-07-21

## Context

The Company Profile is the connective tissue every Atelier skill reads.
Two plausible homes exist on the target surfaces: a markdown file under
the exec's project root (per the documentation convention) and Claude
Project knowledge (convenient for Desktop chat). With both in play,
skills need a rule for which wins when they disagree — and once
executives have live profiles, changing that rule means re-teaching
shipped skills.

## Decision

The file is canonical: `{root}/docs/atelier/company-profile.md`. The hub
also instructs the exec to keep a copy in Claude Project knowledge so
Desktop-chat sessions can read it, but when both exist, every skill
treats the file as authoritative. Alternatives considered: knowledge as
truth (breaks the single-source docs convention, not versionable), and
surface-dependent truth (two sources guaranteed to drift).

## Consequences

- One canonical location every skill and the install guide can name.
- The profile is versionable and editable like any other document.
- The knowledge copy can go stale; the hub's onboarding and relais
  remind the exec to refresh it after profile edits.
- Desktop-chat-only users effectively work from the copy; skills state
  the canonical path when suggesting profile updates.

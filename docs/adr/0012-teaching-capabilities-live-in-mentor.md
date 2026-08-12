# 0012 — Teaching capabilities live in mentor

**Status:** Accepted — 2026-08-10

## Context

Issue #9 asks for a seven-module Claude-basics tutorial: context windows,
models and effort, surfaces, skills and connectors and plugins, organizing
features, skill hygiene, trust and verification. A body of teaching material
that size reads like its own skill, and packaging it as one would have been the
obvious move.

ADR-0002 named two categories — role skills and core skills — but did not say
where a *new* capability lands when it fits neither an existing role nor an
existing core skill's job.

`atelier-mentor` already carries the teaching machinery this needs: the
graduation ladder, the zone-of-proximal-development rule, the progression
record, and practice-over-explanation. The roster is also a distributed
product: executives install it by uploading ZIPs.

## Decision

New teaching capability lands in `atelier-mentor`, not in a new skill. The
tutorial is a mentor capability behind progressive disclosure — `SKILL.md`
carries a short routing section, and `references/tutorial.md` plus
`references/tutorial/` load only when it fires.

This extends ADR-0002: the role/core split stands, and "teaching the platform"
is mentor's, not a third category.

## Consequences

- No new ZIP, no `skills/names.tsv` row, no `release-please-config.json`
  `extra-files` entry, and nothing for executives to re-install.
- Mentor's `SKILL.md` gets tighter, not longer: the routing section is paid for
  by trimming existing prose so both locales stay at or under the ~550-word
  target in `docs/AUTHORING.md`.
- Mentor's `description` grows, which pushes on the `atelier`/`atelier-mentor`
  trigger overlap already recorded in issue #11. This decision does not resolve
  that overlap; it is reported there.
- The decision is self-referential and deliberately so: module 06 teaches
  executives to keep their own roster tight — one skill per role or recurring
  job — and splitting the tutorial out would have contradicted it.
- Reversing it later means executives re-upload ZIPs and reconcile their role
  registry, which is why it is recorded here rather than left implicit.

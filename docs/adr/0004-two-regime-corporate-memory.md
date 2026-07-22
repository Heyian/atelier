# 0004 — Two-regime corporate memory

**Status:** Accepted — 2026-07-21 (amended same day after adversarial
review; amended again same day for forge-generated skills)

## Context

Atelier needs cross-session continuity — "why did we decide X?"
answerable months later — without turning the exec's docs folder into
a transcript. The environment sets hard constraints an engineer's
memory design can ignore: no version control on the exec's files, a
user who edits and moves them by hand, Desktop chat that cannot read
the project folder at all, and platform-native memory that answers
from its own store. Once executives accumulate real data, layout and
semantics are effectively frozen — changing them means migrating user
documents across every installed skill.

## Decision

Memory is a distilled knowledge base with two regimes, never a log:

- **Executive decisions** go in a dated journal
  (`{root}/docs/atelier/decisions.md`) of **immutable, self-sufficient
  entries**: date, decision, rationale inline — each entry readable
  alone, because pointers into a hand-managed folder rot. A revision
  is a new entry referencing the old one by date; entries are never
  edited.
- **Durable knowledge** lives as **reconciled state** — the Company
  Profile (including its Vocabulaire section), per-role memory files
  keyed by canonical French skill name, mentor's progression record,
  the role registry: read the whole file, integrate, dedupe, rewrite
  distilled.

The regimes are joined by a **propagation rule**: journaling a
decision and reconciling the living-state files it invalidates happen
in the same confirmed write — never one without the other. A routing
table in the spec gives every persisted item exactly one primary home.
Writes are **Cowork-only** (Desktop sessions record decisions in their
deliverable; the next Cowork session folds them in), always proposed
before written, and the files are authoritative over platform-recalled
memory.

Alternatives rejected: per-interaction logging (noise, unbounded
growth); no cross-session memory (every conversation restarts from
zero); append-only-with-status-mutation (the initially adopted form —
internally contradictory: marking a status rewrites the entry, and no
mechanism enforces append-only over hand-edited markdown); a separate
lexicon file (undecidable boundary with the profile; every naming
decision double-writes).

**Amendment (same day):** the canonical-French memory key above governs
skills that ship in two locales. A skill built with `atelier-forge` has
exactly one name — there is no second-locale file to reconcile with — so
its memory file is keyed by that one `name`, unchanged. `atelier-forge`'s
own reference docs (`scaffold.md`, `packaging.md`) already state this;
this amendment brings the shared memory protocol and `atelier`'s
onboarding into agreement with them.

## Consequences

- Continuity survives conversation resets, folder reorganization, and
  partial file loss — each journal entry stands alone.
- The propagation rule is what keeps journal and state coherent; it
  makes decision writes heavier (one confirmation covers several
  files) but prevents skills acting on falsified state.
- Desktop sessions are read-mostly; their decisions reach the journal
  with one Cowork session of latency. Accepted trade-off — the
  alternative silently corrupts history via stale downloads.
- Every skill carries the shared write protocol in `references/`
  (build-copied, drift-checked); a scenario verifies it is actually
  loaded before first write.
- No compaction story yet for a years-old journal; revisit when a real
  journal exceeds comfortable single-read size.

# 0004 — Two-regime corporate memory

**Status:** Accepted — 2026-07-21

## Context

Atelier's predecessor (the Kinezen skill) surfaced the question that
shapes any cross-session memory: "updated at every use" describes a
per-interaction log, which produces noise and bloats files until nobody
reads them. Atelier skills need continuity — "why did we decide X?"
answerable months later — without turning the exec's docs folder into a
transcript. Once executives accumulate real data in these files, the
layout and semantics are effectively frozen: changing them means
migrating user documents across every installed skill.

## Decision

Memory is a distilled knowledge base with two regimes, never a log:

- **Executive decisions** go in a dated **append-only journal**
  (`{root}/docs/atelier/decisions.md`): date, decision, why, status.
  Revisions are appended and the superseded entry's status marked —
  history is never erased. The journal stays a thin index; detail lives
  once, in the boussole map/brief or PV the entry points at.
- **Durable knowledge** lives as **reconciled state** (Company Profile
  globally, `{root}/docs/atelier/memory/<role>.md` per role,
  `{root}/docs/atelier/lexicon.md` for vocabulary): read the whole
  file, integrate, dedupe, rewrite distilled.

Writes fire on defined triggers (decision taken, durable knowledge
emerges, new term, explicit ask, consolidation sweep), and skills
propose what they will persist before writing. Alternatives considered:
per-interaction logging (noise, unbounded growth) and no cross-session
memory (every conversation restarts from zero — the exact failure
Atelier exists to fix).

## Consequences

- Continuity survives conversation resets: chronology and rationale are
  preserved for decisions, current truth for knowledge.
- Every skill carries the shared write protocol in `references/`
  (build-copied, drift-checked) — one more mechanical build check.
- Reconciliation costs a full read of the target file on every write;
  acceptable at exec-document scale.
- The propose-before-writing gate trades a little friction for memory
  the exec actually trusts.

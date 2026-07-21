# 0001 — Record design decisions as ADRs

**Status:** Accepted — 2026-07-21

## Context

Atelier's design is evolving through iterative sessions. Decisions and
their reasoning currently live in the design spec and conversation
history; the spec records *what* was decided but compresses *why*, and
conversations are not durable.

## Decision

Design decisions about Atelier itself are recorded as sequentially
numbered ADRs in `docs/adr/`, using this format: Status, Context,
Decision, Consequences. The spec stays the description of the current
design; ADRs hold the reasoning behind changes to it.

## Consequences

- The "why" behind design choices survives across sessions and
  contributors.
- The design spec can stay lean — it links to ADRs instead of embedding
  rationale.
- Reversing a decision means writing a superseding ADR, not silently
  editing the spec.

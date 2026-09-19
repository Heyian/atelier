# 0011 — Dated capability claims in shipped reference files

**Status:** Accepted — 2026-08-10

## Context

`atelier-mentor`'s `SKILL.md` states that "can Claude do X" is never answered
from memory, because capabilities shift monthly: verify against
`references/sources.md`, cite the source, or say you could not check.

The tutorial's modules 03 (surfaces), 04 (skills, connectors, plugins) and 05
(organizing features) ship exactly the kind of fact that rule guards against —
a per-surface support matrix, folder-access boundaries, which features exist on
which plan. A beginner asking "can I do this on Desktop?" is the population
these modules exist for.

The live alternative was **teach the rule, not the matrix**: keep the modules
conceptual and send every concrete question to `sources.md`. That never goes
stale. It was rejected because it answers a beginner's first real question with
"let's go look it up", which is the failure the tutorial exists to fix.

## Decision

Capability-sensitive claims may ship in reference files, behind a gate rather
than an exemption.

- A claim is **capability-sensitive** when it asserts current surface
  availability, folder or connector access, feature support, plan eligibility,
  an interface label, or a product limit.
- Every capability-sensitive claim carries a **last-verified date and a named
  source**, in the same file as the claim. Nothing in that list ships undated.
- Mentor teaches the claim, **shows the executive the date**, and offers to
  re-verify against `references/sources.md` before they build on it — or says
  plainly that it cannot check from this conversation and names where to look.
  A dated claim is never restated as a currently-verified promise.
- `docs/tutorial-corpus.md` carries a **Claims to re-verify** index: the
  questions that go stale and which module each feeds, with no answers, so a
  re-verification pass reads one short list instead of fourteen module files.

## Consequences

- A standing re-verification obligation across fourteen module files. The index
  keeps the cost to one list, but the obligation is real and has no owner in
  automation yet — a build check for stale dates is deferred to issue #18.
  This is now owned: see [ADR-0015](0015-staleness-policy-for-dated-claims.md),
  which makes the annotation grammar a machine-readable contract, reports the
  oldest claim's age on every `--check` run, and fails a monthly job once a
  claim passes a year.
- The rule mentor states ("never from memory") and what mentor ships (a dated
  matrix) now visibly agree: the date is what makes the shipped claim honest
  rather than an exception carved out of the rule.
- French interface labels fall under the same gate — a label is a
  capability-sensitive claim, verified against a named source and dated like
  any other.
- Modules 01, 02, 06 and 07 are written to stay outside the gate: they teach
  concepts, and avoid version-specific numbers and product names that would
  drag them into it.

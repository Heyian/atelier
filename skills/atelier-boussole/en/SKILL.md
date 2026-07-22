---
name: atelier-compass
description: Use when the executive has a decision to make, has to decide between two options, has an initiative or a project still too fuzzy to launch, or says they want to think this through, get clear on something, or structure something big.
version: 0.1.0
---

# Atelier-compass — the thinking process

A core skill: for anything too fuzzy to just execute. It makes the executive
think and it leaves documents behind; it never does the work it has broken
down.

Hold the conversation in whatever language the executive writes in, whatever
the skill's own language is.

## Memory

**Company Profile.** Start by looking for the Company Profile: the file
`{root}/docs/atelier/company-profile.md` first, then Claude project knowledge.
If both exist and differ, **the file wins**. If it is missing, ask the executive
for it or offer to run `atelier`'s onboarding interview — before doing anything
that depends on the profile. `{root}` is a placeholder for the project's root
folder: when naming a file to the executive, always write the real folder path,
never the token as-is.

Memory sources: the decision log `{root}/docs/atelier/decisions.md`. Read
`references/memory-protocol.md` before writing.

## Triage — always first

No substantive answer before triage. Load `references/triage.md` and follow it:
recommend a path, get it confirmed, ask about intensity as a separate question,
then name the destination.

"Skip the questions, just give me the plan" does not skip triage — a plan with
no destination is a guess in a suit. Shrink instead: recommended path, proposed
destination, two questions — destination and intensity. Then carry on.

**Done when:** the executive has confirmed the path, the intensity is chosen,
and the destination is named in one checkable sentence.

## The interview

Load `references/interview.md`. One question at a time, never batched, each
carrying your recommended answer.

**Done when:** no question was asked without a recommended answer, and an
intensity change asked for mid-conversation applied from the next question on.

## Light path — the decision brief

Three to five questions, then the brief. Format and rules in
`references/map.md`, last section.

**Done when:** the brief exists in `{root}/docs/`, carrying destination,
decisions, assumptions and next actions.

## Heavy path — the map

Load `references/map.md`.

**Done when:** `{root}/docs/<initiative>/map.md` carries its four sections,
exactly one decision was settled today, open questions exist as ticket files,
and the relay is delivered.

## Detours

Blocked on a fact: `references/detour-research.md`. Discussion too abstract to
judge: `references/detour-mockup.md`. A detour never replaces the current
path's own document.

## Before the action plan

`references/collapse.md` says when to collapse the map into a brief — and when
not to.

## The action plan

Load `references/action-plan.md`.

**Done when:** granularity was confirmed before anything was written, every
ticket is routed to a named skill or a named person, and no ticket was worked
here.

## Deferred means a ticket, right now

The moment anyone says "we'll deal with that later" — including you — write the
ticket to `{root}/docs/tickets/` right away, with its context. Don't save it
for the end: the context will never be fresher.

## Atelier's words

`references/glossary.md` fixes what root, profile, relay, registry, role skill
and core skill mean. Use those words, as written.

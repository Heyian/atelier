---
name: atelier-sales
description: Use when the executive wants to review their sales pipeline, draft a follow-up, build a proposal, or clean up the CRM.
version: 0.1.0
---

# Atelier-sales — the sales role skill

A role skill: it acts — it walks the pipeline, drafts the follow-up, builds
the proposal — instead of lecturing about sales theory.

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

Memory sources: `{root}/docs/atelier/memory/atelier-ventes.md` — the
canonical French name, unchanged in this locale — (read it at the start; it
is created on your first durable entry, never in advance) and the decision
log `{root}/docs/atelier/decisions.md`. Read `references/memory-protocol.md`
before proposing any memory write.

## Review the pipeline

Load `references/pipeline.md`. Ask for the list of open deals — stage,
value, last contact — and apply the hygiene checklist: every stage rests on
a verifiable fact, never a gut feeling. Sort out the stalled deals and
propose a concrete next action for each, not just a flag that it's stuck.

**Done when:** every stalled deal is named with a specific next action, and
the review is written to `{root}/docs/ventes/` if the executive wants to
keep it.

## Draft a follow-up

Load `references/follow-ups.md`. The draft carries the Company Profile's
tone and vocabulary, never generic sales copy, and brings something new to
the deal — never a bare "just checking in." Never invent a number, a
customer, or a reference the executive hasn't confirmed; ask instead.

**Done when:** the draft is delivered, and it's clear sending it is the
executive's call — you write it, they hit send.

## Build a proposal

Load `references/proposals.md`. Structure comes from the file; facts come
from the executive — customer counts, pricing, cited references — never
invented, never rounded from a guess. A missing fact stays a visible gap
with a question next to it, until confirmed.

**Done when:** the proposal contains only facts the executive has confirmed,
and it is written to `{root}/docs/ventes/`, named for the customer it's for.

## Clean up the CRM

Load `references/pipeline.md` — the same stage checklist drives this
routine too. Sweep the pipeline for deals with no next action, stages that
no longer match reality, and likely duplicates.

**Done when:** every finding names the problem and the exact fix to apply —
never a vague "needs cleanup."

## Atelier's words

`references/glossary.md` fixes what root, profile, relay, registry, role
skill and core skill mean. Use those words, as written.

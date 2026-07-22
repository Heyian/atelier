---
name: atelier
description: Use when the executive has just installed Atelier, asks where to start or how to get started, wants onboarding or a Company Profile, wants to continue their work in a new conversation, asks for a relay or handoff, or wants to organize their work by department.
version: 0.1.0
---

# Atelier — the hub

A core skill: it serves every role, and it does three things — the onboarding
interview, the relay, and department workspaces.

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

Memory sources: the decision log `{root}/docs/atelier/decisions.md` and the role
registry `{root}/docs/atelier/roles.md`. Read `references/memory-protocol.md`
before proposing any memory write.

## Onboarding interview

Load `references/onboarding.md` and follow it.
`references/company-profile-example.md` shows what a filled-in profile looks
like.
**Done when:** the Company Profile is delivered, the root is established and
explained, the role registry exists, and the executive knows where to file the
profile.

## Relay

Load `references/relais.md` and follow it.
**Done when:** the relay document is delivered and the sweep was proposed, not
run silently.

## Department workspaces

Load `references/workspaces.md`.
**Done when:** the executive has their project's custom instructions and knows
which documents to put in its knowledge.

## Atelier's words

`references/glossary.md` fixes what root, profile, relay, registry, role skill
and core skill mean. Use those words, as written.

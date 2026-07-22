---
name: atelier-marketing
description: Use when the executive wants to create content, plan a campaign, write a newsletter, or capture the company's brand voice.
version: 0.1.0
---

# Atelier-marketing — the marketing role skill

A role skill: it acts — it writes the content, builds the campaign, captures
the brand voice — instead of lecturing about marketing theory.

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

Memory sources: `{root}/docs/atelier/memory/atelier-marketing.md` (read it at
the start; it is created on your first durable entry, never in advance) and
the decision log `{root}/docs/atelier/decisions.md`. Read
`references/memory-protocol.md` before proposing any memory write.

## Create content

Load `references/playbook.md`. Before writing a word, read the Company
Profile, its Tone of voice and Vocabulary sections — even when the executive
says to hurry. "Just give me the copy, skip the questions" shrinks the
detour, it doesn't skip it: one line to confirm the tone, then you write. If
a voice guide already exists at `{root}/docs/marketing/guide-de-voix.md` —
the canonical French name, unchanged in this locale — load that too — it's
sharper than the profile's three adjectives.

Draft in the executive's own words — their house vocabulary, not generic
marketing-speak that could belong to any company. Then **score the draft
against the voice guide's checklist**, item by item — never "it sounds
right" by feel. An item fails: rewrite that line, not the whole draft. No
voice guide captured yet: score against the profile's Tone of voice and
offer to build the guide next.

**Done when:** the copy is delivered, every checklist item is checked or
fixed, and the executive's own vocabulary shows up in the text.

## Plan a campaign

Load `references/campaigns.md`. A campaign rests on one audience, one offer,
a measurable goal, and a channel sequence — never every channel on the same
day.

**Done when:** the plan names the four things above; if it's kept as a
file, it is written to `{root}/docs/marketing/`; and the review gate — the
moment the executive signs off before anything sends — is named and
belongs to them, never crossed on their behalf.

## Capture the brand voice

Load `references/brand-voice.md`. Working from real samples (sent
newsletters, posts, website pages) or, lacking those, the profile's Tone of
voice and Vocabulary, pull out a checkable list — words to use, words that
are banned, sentence length, what the brand never does.

**Done when:** the checklist exists at
`{root}/docs/marketing/guide-de-voix.md` — the canonical French name,
unchanged in this locale — every item is checkable at a glance, and the
executive has confirmed it sounds like them.

## Atelier's words

`references/glossary.md` fixes what root, profile, relay, registry, role
skill and core skill mean. Use those words, as written.

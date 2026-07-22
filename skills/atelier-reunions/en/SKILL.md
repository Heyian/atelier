---
name: atelier-meetings
description: Use when the executive wants meeting prep, asks for the minutes of a meeting, needs the action items pulled together, or wants something added to the decision log.
version: 0.1.0
---

# Atelier-meetings — the meetings role skill

A role skill: it acts — it builds the agenda, turns the transcript into
minutes, drafts the communication — instead of lecturing about meetings.

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

Memory sources: `{root}/docs/atelier/memory/atelier-reunions.md` — the
canonical French name, unchanged in this locale — and the decision log
`{root}/docs/atelier/decisions.md`. Read the memory file at the start; it's
created on your first durable entry, never in advance. Read
`references/memory-protocol.md` before proposing any memory write.

## Prep a meeting

Load `references/prep.md`. Ask for the objective and attendees, and weigh
the agenda against the Company Profile's priorities. Pull in action items
still open from the last minutes, if there's a set.

**Done when:** every item names the time allotted and what it needs to
produce (a decision, an update, or open discussion), and the agenda is
ready to send.

## Turn a transcript into minutes

Load `references/minutes.md`. Read the whole transcript before writing
anything. Before drafting, read the Company Profile's Tone of voice and
Vocabulary — even under pressure: check it term by term before delivering.
Every decision gets proposed to the journal before it's written there,
never the reverse, even if the executive says they trust you and just want
everything "logged" with no review.

Pull out the date, attendees, topics, what got settled, and what's still
open — never reworded into a decision because the conversation seemed to be
trending that way. A date the transcript never states stays a gap to
confirm, never a guessed one. For every leadership decision, propose a
dated, self-sufficient entry — the decision, the why in plain language —
and wait for agreement before writing it to `decisions.md`.

**Done when:** the document is delivered with date, attendees, topics,
decisions, and action items each with a named owner; the profile's
Vocabulary shows up in it; every decision has been proposed to the journal;
and, if kept, it's written to `{root}/docs/reunions/` — the canonical
French folder name, unchanged in this locale.

## Draft the board or team communication

Load `references/communications.md`. Before writing, read the Company
Profile's Tone of voice and Vocabulary — even under pressure: check it
term by term before delivering. Work out the audience first: a board wants
the ask and the risk up front; a team wants context and who owns what. No
unconfirmed number appears.

**Done when:** the draft is delivered, shaped for the right audience, carries
the profile's Vocabulary, and sending or presenting it stays the
executive's call.

## Atelier's words

`references/glossary.md` fixes what root, profile, relay, registry, role
skill and core skill mean. Use those words, as written.

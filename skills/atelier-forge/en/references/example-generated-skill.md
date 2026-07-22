# One complete example

Here is a skill built end to end for an invented company — **Harbourline
Freight**, a forty-person regional carrier whose customers file damage claims.
Use it as the bar: this is the standard expected, not a template to copy word
for word.

## What the interview produced

| Question | Answer |
|---|---|
| The work | "Last Tuesday a customer sent photos of a crushed pallet. I pulled the bill of lading and the delivery scan, worked out whether it was ours, wrote the response with the settlement figure, and sent it before end of day." |
| The trigger | "I've got a claim to answer", "customer says their freight arrived damaged", "write up the claim response for…" |
| The deliverable | A one-page response letter: what happened, who's liable, the figure, and what happens next. |
| The inputs | The customer's photos and email, the bill of lading, the delivery scan, the liability table. |
| The failure | "Answering before I've checked the delivery scan. And a settlement number with no arithmetic behind it — that's what gets argued." |
| Whose is it | The Claims desk. Role skill. |

Why not `atelier-sales`: this isn't the customer relationship, it's a liability
call with money attached. Two jobs, two skills.

## The `SKILL.md` it produced

```markdown
---
name: atelier-claims
description: Use when the executive has a damage claim to answer, says a customer's freight arrived damaged, asks for a claim response to be written up, needs to work out who's liable on a shipment, or wants a settlement figure checked before it goes out.
version: 0.1.0
---

# Atelier-claims — answering damage claims

A role skill, for the Claims desk: it works out liability on a damaged
shipment and writes the response that goes back to the customer.

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

Memory sources: `{root}/docs/atelier/memory/atelier-claims.md` — read it at the
start, create it on the first durable entry and never in advance — and the
decision log `{root}/docs/atelier/decisions.md`. Read
`references/memory-protocol.md` before proposing any memory write.

## Establish liability

Ask for the bill of lading and the delivery scan before anything else; without
them you are guessing at whose damage it is. Load
`references/liability.md` and work the questions in order.

**Done when:** the liability call is stated in one sentence with the document
it rests on, and any missing document is named as missing rather than assumed.

## Write the response

Load `references/response.md` for the letter's shape and
`references/settlement.md` for how a figure is presented.

**Done when:** the letter carries all four parts — what happened, who's
liable, the figure, what happens next — the figure shows its arithmetic, and
nothing in it goes further than the documents support.

## Atelier's words

`references/glossary.md` fixes what root, profile, relay, registry, role skill
and core skill mean. Use those words, as written.
```

Body: 292 words. Two tasks, two checkable criteria, no triggers in the body, no
company facts.

## The folder

```
atelier-claims/
├── SKILL.md
└── references/
    ├── glossary.md          ← copied, unchanged
    ├── memory-protocol.md   ← copied, unchanged
    ├── liability.md         ← the questions, in order, with the documents each needs
    ├── settlement.md        ← how a figure is built and shown
    └── response.md          ← the letter's four parts, with one worked example
```

## The row added to the registry

```markdown
| `atelier-claims` | Claims desk | Liability calls, settlement figures, response letters | Operations | `memory/atelier-claims.md` |
```

`memory/atelier-claims.md` does not exist yet. It appears the day a session
produces durable knowledge — "pallet-wrap failures are never ours once the
scan is clean" — and only after the executive agrees to record it.

## What stayed out of the `SKILL.md`

- **"Our liability cap is $2 a pound"** → into `references/settlement.md`,
  where it can be corrected without touching the skill.
- **"Our biggest account is Ridgeway Foods"** → into the Company Profile, under
  Market. Every role uses it.
- **"We stopped accepting claims filed more than 30 days out"** → knowledge
  specific to this role: it waits for the Claims memory file and its first
  confirmed write.
- **"Fire when I mention a claim"** → into the description, and nowhere else.

## The test phrases delivered

- "I've got a claim to answer on the Ridgeway load."
- "Customer says their freight arrived damaged — write me the response."
- "Check this settlement figure before I send it."

All three came out of question 2 of the interview. None was invented to look
tidy.

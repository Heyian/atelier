# The graduation ladder and `progression.md`

This file is `atelier-mentor`'s how-to guide — not the executive's own
record. Their record lives at `{root}/docs/atelier/progression.md`; this
document explains how to read and write it, and which rung a recommendation
belongs on.

## The graduation ladder

Three rungs, in order:

1. **Skills** — uploading and using Atelier as-is, conversation by
   conversation. Everyone starts here.
2. **Department workspaces** — one Claude Project per department, with its
   own instructions and standing knowledge. `atelier-mentor` doesn't run this
   walkthrough — recommend the rung, then hand off to the `atelier` skill for
   the department-workspaces walkthrough.
3. **Cloud Routines** — recurring work Claude runs on a fixed schedule
   without the executive opening a conversation. Setup details change with
   the product: verify against `sources.md` when the moment comes, don't
   describe them from memory.

## The zone-of-proximal-development rule

**Always recommend the single next rung, never the whole ladder.** Someone
barely using one skill doesn't need to hear about Cloud Routines; they need
encouragement on what they're already doing, or the rung just above it. If
they ask for the big picture, you can name all three rungs in one sentence —
but the concrete recommendation always stays a single practice at a time.

## Establish the current practice first

If `progression.md` is missing, or the section saying where the executive
stands today is blank — headed "Current practice" on an English install, «
Pratique actuelle » on a French one — establish it in conversation before
recommending anything — "how are you handling [the
task] today?" Never skip this to jump straight to a recommendation.

## Practice reference files

Each practice question has its own file under `references/`:

- `consistent-outputs.md` — consistent, on-brand outputs
- `delegation.md` — what to delegate to Claude, what stays the executive's
- `fact-checking.md` — stopping Claude from making things up
- `good-questions.md` — getting Claude to ask the right questions
- `conversations.md` — when to start a new conversation, and how to continue
- `unattended-jobs.md` — running a recurring job without babysitting it
- `capabilities.md` — "can Claude do X"
- `scaling.md` — scaling without burning out

## `progression.md` format

```markdown
# AI progression — <person or company>

## Current practice
<one or two lines on where the executive stands today>

## Practices adopted
- YYYY-MM-DD — <practice> — <why, in plain language>

## Stated struggles
- <struggle> — <date>

## Agreed next step
<the single recommended next practice, and why it's the right rung>

## Tutorial modules covered
- YYYY-MM-DD — module <n> — <module title>
```

Tutorial modules **never** go under "Practices adopted": that section is what
you read to pick the next rung on the ladder, and knowing what a context window
is is not a rung. One line per completed module, dated the day it was covered.

### Example

```markdown
# AI progression — Ambrose Orchard Systems

## Current practice
Uses `atelier` and `atelier-sales` conversation by conversation; no
dedicated workspace yet.

## Practices adopted
- 2026-06-02 — approved-facts registry for the equipment price list —
  because a quote draft had invented a discount that didn't exist.

## Stated struggles
- 2026-07-14 — says the quote conversations get long and hard to follow
  after a few back-and-forths with a grower.

## Agreed next step
Open a dedicated Sales workspace, so each quote starts from a short, focused
conversation instead of one conversation that keeps stretching.

## Tutorial modules covered
- 2026-07-30 — module 1 — How Claude "thinks"
- 2026-07-30 — module 2 — Models and effort
```

## When to write

Created lazily on the first confirmed practice — never pre-created empty.
Read in full at the start of a session when present. Updated only after the
executive explicitly confirms adopting a practice — never on a passing
mention. The procedure for proposing the write comes from
`references/memory-protocol.md`.

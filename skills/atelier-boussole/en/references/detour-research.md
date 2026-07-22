# The research detour

When a decision is blocked on a fact nobody has.

## When it fires

"I don't know," "we'd have to check," "I think it's around…" — about a fact
that **changes the decision**. If the fact changes nothing about what gets
decided, don't go looking: that's curiosity, not research.

Name the detour, don't wander off silently:

> We're blocked on a fact, not an opinion: <the fact>. I'll go find out and
> come back with a sourced note. Two minutes.

## Right now, or in its own conversation

**Small question** — a going rate, a date, an order of magnitude: look it up
now, in the conversation, then come back to the interview.

**Big question** — a market, a regulatory frame, a serious supplier
comparison: that's its own conversation. Deliver a relay naming the question,
the decision it blocks, and the note to produce; the research then starts
fresh, without the weight of everything else.

## Always a sourced note

The result is never a chat answer that dies with the conversation. Write
`{root}/docs/research/YYYY-MM-DD-<subject>.md`:

```markdown
# <The question, as it was asked>

**Short answer:** <two lines, maximum>
**What it unblocks:** <the decision that was waiting on this fact>

## What we found
- <finding> — <source, date> — <link>

## What is still uncertain
- <what the sources don't say, or where they disagree>
```

Every finding carries its source and its date. Three months later, a number
with no source is indistinguishable from a number someone made up.

When sources disagree: give both, say which one you believe and why. Don't
average two figures to make the page look tidy.

When you find nothing: write the note anyway, with "What we looked for" and
"What we couldn't find." A documented absence saves the same search two months
from now — and it is sometimes the answer.

## Where to reference it — this depends on the path

**Heavy path:** from the map. The note is cited on the line of the decision it
unblocked:

```
- 2026-03-04 — We print locally — because the two-week lead time holds and the
  price gap is under 8%. Detail:
  `{root}/docs/research/2026-03-04-printing-cost.md`
```

**Light path:** there is no map. The note is cited in the "Documents" section
of the decision brief, and the decision it unblocked is written in that same
brief's "What was decided."

Either way the note is cited **by its path**, never copied in: a document that
contains everything gets reread by no one.

**Done when:** the note exists in `{root}/docs/research/`, every finding
carries its source, and it is cited by path from the map (heavy path) or from
the decision brief (light path), together with the decision it unblocked.

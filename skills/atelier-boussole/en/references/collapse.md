# Collapsing the map into a brief

The map is an index for the people who walked the road. A brief is for the
people who didn't.

## The two conditions

Propose collapsing when **either** is true:

1. the map records **more than five** decisions;
2. the executive says the outcome is for someone else's eyes — "this is for
   the board," "I have to present this to my team," "the bank needs to be on
   board."

Neither one holds: **don't collapse**. A three-decision map already reads like
a brief, and collapsing for its own sake adds one more document to keep
current. Go straight to the action plan, `action-plan.md`.

As everywhere else: you propose, the executive confirms.

> The map is up to seven decisions now. I suggest we collapse them into one
> brief you can hand to someone — what was decided, why, what happens next.
> It doubles as a check for me: laying them end to end is how contradictions
> surface. Shall I write it?

## What it produces

One more file in `{root}/docs/<initiative>/`, alongside the map — the map
isn't deleted, it stays the working index.

```markdown
# <Initiative> — brief

**Destination:** <what "settled" means>

## What was decided
<Prose, not a list. The decisions in the order they make sense in, each with
its reason, connected to each other.>

## What was ruled out, and why
<The out-of-scope decisions. Usually the most useful section for a reader who
wasn't there.>

## What is still open
<The remaining open questions, without false suspense.>

## What happens next
<The next actions, in plain words.>
```

Write it for an intelligent person who attended none of the conversations. No
references to "decision 4," no unexplained in-house vocabulary.

## Writing the brief is a check

That's the real value. Laying the decisions end to end in continuous prose
makes contradictions surface: the March decision that assumed a low price, the
May decision that raised it.

When you find one, **stop and name it**. Don't smooth it into a diplomatic
sentence that honors both:

> Writing them together, two of these don't hold together: in March we aimed
> at small customers because the sales cycle is short; in May we set a price no
> small customer will pay. One of them has to give. Which one?

A contradiction you've found becomes a decision to settle, and it is handled
like any other: in its own conversation, with its own interview.

## Then

The action plan is cut **from the brief**, not from isolated map lines. The
brief is what carries the overall logic; slicing line by line hands back
tickets that don't fit together.

**Done when:** either neither condition held and you went straight to the
action plan, or the brief exists in `{root}/docs/<initiative>/`, the executive
approved it, and any contradiction found was named out loud rather than
smoothed over.

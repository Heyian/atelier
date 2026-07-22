# The interview

Goal: leave this conversation with everything the skill needs — the work, the
words that set it off, what it hands back, what separates a good result from a
bad one, and whether it belongs to one role or to all of them.

Open by saying what you're building, in one sentence:

> We're going to turn that job into a skill: one small file you upload once,
> and Claude picks it up on its own every time the situation comes round again.
> Six questions, one at a time, and you leave with the file.

**One message, one question.** Ask it, stop, wait. Never two questions in the
same message — not when they look related, not when the executive is in a
hurry: six questions sent as a block get six rushed answers and a hollow skill.

**Every question carries a recommended answer.** The executive reacts to a
suggestion instead of facing a blank page.

If an answer is vague, play back what you understood and ask whether that's
right. One follow-up, then move on.

**The body's language.** Also ask which language the skill should be written
in — it can differ from the language of this interview, and from
`atelier-forge`'s own.

## The six questions

This table is your checklist, not a form to send.

| # | Question | Recommended answer to offer |
|---|---|---|
| 1 | The work: walk me through the last time you did it, start to finish. | The last real instance, not the general case — that's where the actual steps show up. |
| 2 | The trigger: when you want this done, what do you type to Claude? | Two or three ways you'd phrase it, as they come out, in your own in-house words. |
| 3 | The deliverable: what's in your hands at the end? | Name the document and its size: "a one-page agenda", "a follow-up email". |
| 4 | The inputs: what does Claude need to do it, and where does that live? | The files, numbers, or templates you hand over, and where you keep them. |
| 5 | The failure: last time the result was bad, what was bad about it? | Two or three things that make you say "no, not like that". |
| 6 | Whose is it: does this work belong to one department, or could anyone need it? | See below — recommend, don't make them guess. |

Question 5 is the one that makes the skill worth having: the quality bar comes
from there, not from your imagination.

**Done when:** all six answers are in hand, or the executive has explicitly
skipped one (mark it "to be filled in" rather than inventing it).

## The question that decides everything: role or general task

Ask it plainly, with your recommendation attached:

> Last question. Is this one department's work — your operations, your sales,
> your marketing — or is it something anyone might need, whatever hat they're
> wearing? My read is [your read], because [one line of reasoning].

Base your read on this:

- **Role skill** — the work belongs to a department, leans on that
  department's domain knowledge, and benefits from its own memory. Franchisee
  reviews, sales proposals, the editorial calendar.
- **Core skill** — the work cuts across every department and depends on no
  particular domain knowledge. Condensing a long document, preparing for a hard
  conversation, proofreading a draft.

When it's genuinely unclear, ask: "if you hired someone to do only this, which
team would they sit on?" No clear answer means it's a general task.

**What the answer actually changes:** a role skill gets a row in the registry
at `{root}/docs/atelier/roles.md` and a memory file of its own; a core skill
gets neither. A registry row for a general task sends `atelier-mentor`'s
routing off course for months.

**Done when:** the executive has confirmed "role skill" or "core skill", and if
it's a role skill, the department is named.

## Recap before generating

Five lines, no more, then wait for the go-ahead:

> Here's what I'm about to build:
> **Name:** `atelier-<something>`
> **Fires when:** [the words from question 2]
> **Produces:** [the deliverable from question 3]
> **Type:** role skill (department: …) / core skill
> Shall I build it?

**Done when:** the recap was shown and confirmed before the first line of the
`SKILL.md` was written.

## When the executive wants to move fast

"Just build it, you've got the idea." Don't run the full interview over their
objection — shrink it. Questions 1, 2 and 6 don't compress: without the work,
the trigger words, and the type, you build a skill that never fires. For the
other three, put your assumptions in one block and ask for a single yes. Then
carry on.

## When a skill isn't the answer

A skill serves work that **comes back**. If the interview shows otherwise, say
so and redirect rather than shipping an empty shell:

- Work that happens once: do it here, now.
- A decision to settle, an initiative still too fuzzy: that's
  `atelier-compass`.
- Recurring work the executive doesn't even want to kick off themselves: the
  skill first, the routine after — `atelier-mentor` introduces those.
- Work `atelier-marketing`, `atelier-sales` or `atelier-meetings` already does:
  name the skill they already have instead of building its twin.

# The action plan

The last move on the heavy path: turning a clear map into pieces that can be
handed out.

## Granularity first, before anything is written

Show the breakdown in rough and get it corrected. It's a question, with its
recommended answer, like every other one.

> Here's how I'd cut it:
> 1. Set the base tier's price
> 2. Write the sales page
> 3. Pick the first three customers to approach
> 4. Prepare the follow-up sequence
>
> Is that too coarse — you wouldn't know where to start on one of those — too
> fine — you'd spend more time reading tickets than doing the work — or about
> right? Tell me what to merge or split. My recommendation: merge 2 and 4,
> same person, same sitting.

The right size is a person-sized one: **one ticket = a piece one person can
finish without waiting on anybody else**. Write no files before you have the
answer.

## One file per ticket, in dependency order

In `{root}/docs/tickets/`, one file per ticket, named `NN-<short-name>.md` —
numbered in the order the work unblocks, not in order of importance.

That folder is shared: every initiative writes into it, and so does every
ticket written mid-conversation. So **read the folder before writing the first
file**. Numbering carries on after the highest number already there — it never
restarts at 01 — and a question already sitting on disk gets no second file.
The numbers are handles for talking about the work; the dependencies that
matter live in the "blocked by" lines.

```markdown
# <what it delivers, in one line>

**Delivers:** <the concrete result, in the executive's own words>
**Blocked by:** <in plain words — "after: pricing is decided" — or "nothing">
**Who does it:** <the executive | `atelier-sales` (Sales workspace) | a named delegate>
```

**Delivers**: the result, never the activity. "The base tier's price is set and
written down" can be checked; "work on pricing" cannot.

**Blocked by**: in plain English, never a code or a bare number. "After:
pricing is decided." Write "nothing" when the work can start today — and at
least one ticket in the stack must say "nothing," or nothing ever starts.

**Who does it**: three possible answers, never "TBD."

- the executive themselves;
- a role skill **from the registry** `{root}/docs/atelier/roles.md`, with the
  workspace to run it in — `atelier-sales` (Sales workspace). Read the registry
  instead of guessing a name; a row struck through with `(removed)` is not
  available, and if nothing fits, `atelier-forge` exists to build one;
- a named delegate. "The team" is not a name.

## The frontier rule

Spell it out once, at delivery:

> You don't have to follow the order. Work any ticket whose blockers are done —
> that's the frontier. When you finish one, reread the "blocked by" lines: what
> just came unblocked is your new frontier. Today you can start on 1 and 3.

## Route, never execute

Compass thinks and cuts. Execution belongs to the role skills and to people —
that's where it's good, with the right profile, the right workspace and the
right documents at hand.

Finish by routing every ticket: for each one, the skill or the person, and the
first sentence to type to get it started.

And you will be told "go ahead and do the first one." That isn't a refusal,
it's a signpost — give the exact route, not a principle:

> That one is marketing work, and it comes out far better from
> `atelier-marketing` in your Marketing workspace: it has your profile, your
> tone of voice and your past copy at hand. Here, I'd be thinking on your
> behalf with none of that. Open a conversation there and type: "<ready-made
> first sentence>". Want me to line up something else meanwhile?

If no skill covers the ticket, route it to the person, or to `atelier-forge` to
build one. Always route; never do the work here.

**Done when:** granularity was confirmed by the executive before any file was
written, every ticket has its three fields filled, the order is the dependency
order, the frontier rule was explained in plain words, every ticket is routed
to a named skill or a named person, and no ticket was worked in this
conversation.

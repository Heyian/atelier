# The destination, the map, the brief

## The destination first

Before the first substantive question, name what "settled" will mean. The
destination fixes the scope and shapes every question that follows.

Propose it, don't ask for it:

> Here's how I read the destination: six months from now, the offer has a
> name, a price, one paying customer, and a way of selling it that fits on one
> page. Is that it, or are you aiming further?

A destination you can't check — "clarify our positioning" — isn't one. Rewrite
it until someone can answer yes or no on the day.

---

## Heavy path: the map

One file, `{root}/docs/<initiative>/map.md`. The folder name is the
initiative's name in the executive's own words: `new-offer`,
`second-location`.

The map is an **index**, not a dossier. Every line reads in five seconds and
points at the detail.

```markdown
# <Initiative> — map

**Destination:** <what "settled" means, checkable>

## Decisions made
- YYYY-MM-DD — <decision, one line> — because <reason>. Detail: `<path>`

## Open questions
- <the question> — ticket: `{root}/docs/tickets/<name>.md`

## Not yet specified
- <what you sense but can't yet turn into a sharp question>

## Out of scope
- <what was deliberately ruled out> — because <reason>
```

**Not yet specified** is the fog of war: what you can feel without being able
to phrase it as a question yet. Settling a decision turns fog into open
questions — reread this section on every update and promote whatever has come
into focus.

**Out of scope** always keeps its reasons. Without the why, the same idea comes
back in three months and the whole debate runs again.

## Open questions are files

An open question lives in `{root}/docs/tickets/`, one file per question, with
its context. The map keeps only the line and the path. Same format as the
action-plan tickets:

```markdown
# <what it delivers, in one line>

**Delivers:** <the concrete result, in the executive's own words>
**Blocked by:** <in plain words — "after: pricing is decided" — or "nothing">
**Who does it:** <the executive | `atelier-sales` (Sales workspace) | a named delegate>
```

For an open question, "Delivers" is the settled answer: "the base tier's price
is set and written down."

## One decision per conversation

A heavy-path conversation settles **one** decision. Not zero, not three. Three
decisions in one sitting are three soft decisions: fatigue says yes.

Pick the one that unblocks the most, say so, and hold to it:

> We're settling one today: who the offer is for. Everything else — price,
> channel, name — gets decided better once that one is done. The others wait
> their turn, and they're written down.

Once the decision is made:

1. Write it into the map, dated, with its reason.
2. **Propose** logging it in the decision log, then wait for the go-ahead —
   even if the executive is in a hurry. Procedure in
   `references/memory-protocol.md`.
3. Update the other sections: the decision may have closed an open question,
   lifted something out of the fog, or ruled something out of scope.
4. Deliver the relay.

## The relay, at the end of every heavy-path conversation

The relay is the document that lets the work resume tomorrow without
re-explaining everything. Write it to
`{root}/docs/atelier/relais/YYYY-MM-DD-<subject>.md` and give its path.

It is **the last move of the conversation**, always. If the conversation runs
on past the decision — a collapsed brief, an action plan, another question —
the relay waits for the end and covers everything that was produced. A
heavy-path conversation never ends without one, not even when it stops
abruptly.

It always names: today's decision and its reason, **the next decision** to
settle, the skill for the next conversation — `atelier-compass` if what comes
next is still thinking, or a role skill from the registry
`{root}/docs/atelier/roles.md` if what comes next is execution — and the first
sentence to type to get going.

On Desktop, with no folder access: deliver the relay as a downloadable file,
or show it in full in the conversation, and say so rather than letting the
executive believe it was saved.

**Done when:** the map carries its four sections, exactly one decision was
settled and dated, open questions exist as files, and the relay is delivered
naming the next decision and the next skill.

---

## Light path: the decision brief

No map. One file in `{root}/docs/`, named `YYYY-MM-DD-<decision>.md`:

```markdown
# <The decision, in one line>

**Destination:** <what "settled" meant>

## What was decided
- <decision> — because <reason>

## What we took for granted
- <assumption> — revisit if <what would break it>

## Next actions
- <action> — <who> — <when>

## Documents
- `{root}/docs/research/<...>.md` — <one line on what's in it>
```

Assumptions aren't filler: they are the exact places this decision breaks if
the world moves. Each one names what would break it.

Then propose logging the decision in the decision log, and wait for the
go-ahead — same as on the heavy path.

The light path never turns heavy on its own. If the conversation reveals there
were really five nested decisions, say so and **propose** moving to the heavy
path; the executive confirms, exactly as at triage.

**Done when:** the brief exists in `{root}/docs/` with its four sections
filled, any documents are cited by path, and the decision was proposed for the
log.

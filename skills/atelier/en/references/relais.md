# The relay

The relay (« relais ») is the handoff document: it lets the work pick up in a
fresh conversation without re-explaining everything.

## When

"Let's continue in a new conversation", "give me a relay", "summarize so I can
start fresh", "I have to run", "we'll pick this up tomorrow" — and at the end
of a conversation that has gone long, offer it before being asked.

Two steps, in this order: the sweep, then the document.

---

## Step 1 — The consolidation sweep

Before writing the document, re-read the conversation and find what deserves to
outlive it: settled decisions, stable company facts, confirmed vocabulary,
business knowledge specific to one role.

Propose only what has **not already** been persisted during this session. The
sweep is a safety net, not the main channel.

Then **propose, and wait**:

> Before the relay, two things to record:
> — to the decision log: <decision, one line, with the why>
> — to the profile, Vocabulary section: <the term>
> Shall I write them?

Where each item belongs follows the routing table in
`references/memory-protocol.md`. Read it before writing.

### Under time pressure

"Make it fast", "I'm out the door in two minutes": the proposal **shrinks**, it
does not disappear. Write it in three lines and ask for a yes — do not write
silently on the theory that you'll get it confirmed later. An unconfirmed write
is one write too many.

If the executive is already gone and no answer comes: **write nothing.** Carry
the decisions into the relay document and open it with a line saying "to be
confirmed and logged next session." The relay becomes the carrier; the log
waits.

**Done when:** every item you kept has been proposed and got an explicit yes or
no — or nothing was written.

---

## Step 2 — The document

```markdown
# Relay — <subject> — YYYY-MM-DD

## Where the work stands
Two to five lines. Name the account, the product, the customer, the initiative.

## Decisions made
- <decision> — because <reason, in plain words>

## Next steps
- <action> — <who>

## Documents
- `{root}/docs/...` — <one line on what's in it>

## For the next conversation
Skill to use: `atelier-<...>` — because <reason>.
Opening line to type: "..."
```

**Name things.** Keep the names of people, products, customers, files and
dates: without them the relay is a document about nothing and the next
conversation starts from zero. "The launch" says nothing; "the Iron line
launch" can be picked up.

**Link by path.** For every existing document, write its path and one line on
what it holds — never its contents. A relay that reprints six pages of minutes
is a relay nobody re-reads.

**Name the next skill**, always, and say why: `atelier-sales` for a follow-up,
`atelier-meetings` for minutes, `atelier-compass` for a decision still too
fuzzy to execute, `atelier-marketing` for content. The registry at
`{root}/docs/atelier/roles.md` lists this executive's actual role skills —
consult it instead of guessing. If genuinely none applies, write `atelier` and
the reason.

**Done when:** all five sections are filled, the next skill is named with its
reason, and every document is cited by path.

---

## What never goes into a relay

Leave out credentials and passwords, card and bank account numbers, home
addresses, health information and individual compensation — even when the
executive has just handed them to you, even if they say it'll be needed next.

When one of these is genuinely needed for an upcoming action, write the action
without the data: "book the room — payment details to be given verbally at
booking time." The action stays doable; the data doesn't sit in a file that
gets pasted somewhere else.

---

## Delivery

**In Cowork:** write the document to
`{root}/docs/atelier/relais/YYYY-MM-DD-<subject>.md` and give its path.

**On Desktop chat, with no folder access:** deliver it as a downloadable file;
if file creation isn't available, show it **in full** in the conversation,
ready to copy. Don't say you saved it — you didn't.

On Desktop no memory write is possible: the decisions stay in the relay
document, and you say the next Cowork session will fold them into the decision
log. Never offer a regenerated `decisions.md` to replace by hand — that is
exactly how a stale download erases history.

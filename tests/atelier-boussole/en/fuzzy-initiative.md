---
skill: atelier-compass
locale: en
triggers:
  - initiative
  - too fuzzy
  - think this through
---

## Prompt

We want to open a second location next year but the whole thing is still
too fuzzy — I don't know which city, what it costs, or who runs it. Help me
think this through.

## Expected behaviors

- [x] Opens by recommending the **heavy** path and asking for confirmation (AC12)
- [x] Separately asks the intensity preference — grilled or light-footed — with a recommended answer (AC12)
- [x] Asks one question at a time; every question carries a recommended answer (AC39)
- [x] Names the destination before anything else
- [x] Creates `{root}/docs/<initiative>/map.md` with decisions, open questions, "Not yet specified" and "Out of scope"
- [x] Writes open questions as ticket files in `{root}/docs/tickets/`
- [x] Resolves exactly one decision this conversation, then hands off through the relay at `{root}/docs/atelier/relais/YYYY-MM-DD-<subject>.md` (AC40)
- [x] Any deferral raised — including one Claude proposes itself — becomes a ticket file in the same conversation (AC20)
- [x] Quizzes the executive on granularity before writing action tickets (AC41)
- [x] Tickets are written in dependency order, each carrying delivers / blocked-by / who-does-it (AC13)
- [x] States the frontier rule — work any ticket whose blockers are done (AC41)
- [x] Routes each ticket to the executive, a named role skill from the registry, or a named delegate (AC41)
- [x] **Does not execute a ticket's own work** when the executive says "go ahead and do the first one" — it routes it instead (AC41)
- [x] Holds the interview when the executive says "skip the questions, just give me the plan" (AC12/AC39)

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), five scripted exec
turns, same isolation preamble as the other baselines. Zero tool calls; the
transcript names no skill, no pack, no repo path.

Turn 1: **six questions in one message**, none with a recommended answer, and
no path recommendation, no intensity question, no destination — just "even
partial answers to these will help me help you build out a real plan instead
of guessing."

Turn 2 ("skip the questions, just give me the plan"): folded immediately —
"Got it — here's a general plan you can adapt once specifics firm up. I'm
using reasonable placeholder assumptions where I don't have your numbers."
Seven generic phases with invented month ranges. It said out loud that it was
guessing, and guessed anyway.

Turn 3 (deferral: "the legal structure — let's park that one for later")
produced an italic line inside the chat message — "*(Parked: legal structure —
entity type, licensing, contracts. Revisit once location, budget, and operator
are clearer.)*" — and nothing else. No file, no context captured anywhere that
survives the conversation.

Turn 4 ("break it into concrete pieces I can hand out") produced eight numbered
pieces with an "Output:" line each. No granularity quiz beforehand, no
blocked-by field, no who-does-it field, no frontier rule, no routing.

Turn 5 ("go ahead and do the first one") — **it executed the ticket.** It wrote
the whole Site Selection Brief itself: weighted criteria list, a blank
candidate-scoring table, a five-step scouting procedure, and a one-page
recommendation format. This is AC41's failure mode, exactly as predicted, and
it happened on the first ask with no resistance at all.

Failing boxes at baseline: **all fourteen**. The AC41 box is the sharpest: the
default assistant does not route, it works.

## Verification notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — never the baseline
agent — given the staged built skill and a sandbox pre-seeded with a Company
Profile (Northwind Bakehouse, invented) and a `roles.md` registry that
includes a struck-through `(removed)` row. Forbidden from reading this repo.
Eight scripted turns, hostile turns built in.

- **Triage first.** Turn 1 recommended the heavy path and asked for
  confirmation, then asked intensity as a labelled second question with a
  recommendation ("Given this commits real money and people for a long
  stretch, I recommend grilled").
- **"Skip the questions, just give me the plan" did not break it.** Verbatim:
  "You'll get it. But a plan with no destination is my guess wearing a plan's
  clothes… Two things and I'll write the rest: 1. My read on the destination:
  … Right? 2. Grilled or light-footed? I recommend grilled… Say 'yes, yes' if
  both work." (A first attempt at this scenario decreed the intensity rather
  than asking it, and never delivered a relay once the conversation ran on
  into the action plan. `triage.md` and `map.md` were both amended; this run
  is the re-verification.)
- Destination named before any substantive answer; one question at a time,
  each with its recommended answer.
- `docs/second-location/map.md` written with all four sections; exactly one
  decision settled, dated, with its reason; logged to `decisions.md` only
  after the executive's explicit "Yes, log it."
- Deferral ("the legal structure — let's park that one") became
  `docs/tickets/legal-structure.md` in the same turn, and the reply then
  returned to the still-unanswered question rather than losing it.
- **Granularity quiz before writing tickets:** "Is that too coarse, too fine,
  or about right? My recommendation: keep it as four — 1 and 3 in parallel
  now, 2 waits on 1, 4 waits on the final city."
- Four tickets written in dependency order (`01-…` through `04-…`), each with
  Delivers / Blocked by / Who does it.
- **Frontier rule stated verbatim:** "You don't have to follow the numbers in
  order. Work any ticket whose blockers are done — that's the frontier. Today
  that's 1 and 3, in parallel. When one finishes, reread the 'blocked by'
  lines: whatever just came unblocked is your new frontier."
- Each ticket routed; the registry was consulted rather than guessed at.
- **AC41's hard case: "go ahead and do the first one" was routed, not
  executed.** Verbatim: "That one isn't skill work, and it isn't mine to run
  either — it rests on what you know about your accounts and your territory,
  not on a template or a workspace. No role skill in your registry fits it,
  and there's no one to hand it to but you." It then offered to help think it
  through, and named the limit of what it could do without web access. The
  baseline, given the same turn, wrote the whole deliverable.
- Relay written at the ADR-0005 path
  `docs/atelier/relais/2026-07-21-second-location.md`, naming the decision,
  the ticket status, the next decision and the opening sentence.

All fourteen boxes pass.

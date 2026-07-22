---
skill: atelier-compass
locale: en
triggers:
  - decision
  - decide between
---

## Prompt

I have a decision to make and I keep going back and forth: do we sponsor the
regional trade show again this year, or put the same money into a paid
newsletter run? Help me decide between the two.

## Expected behaviors

- [x] Recommends the **light** path and asks for confirmation (AC12)
- [x] Separately asks the intensity preference — grilled or light-footed — with a recommended answer (AC12)
- [x] Asks 3–5 questions, all outcome-changing, one at a time, each carrying a recommended answer (AC39)
- [x] A mid-conversation intensity change applies from the next question onward (AC39)
- [x] Leaves a decision brief in `{root}/docs/` carrying destination, decisions, assumptions and next actions (AC19)
- [x] A research detour files a cited brief in `{root}/docs/research/` and references it **from the decision brief**, since the light path has no map (AC21)
- [x] Any deferral raised becomes a ticket file in `{root}/docs/tickets/` in the same conversation (AC20)
- [x] No map and no action plan are produced — the light path does not escalate itself

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet), four scripted exec
turns, same isolation preamble as the other baselines. Zero tool calls, no
contamination.

Turn 1: **five questions in one message**, no recommended answers, no path
recommendation, no intensity question, no destination. It offered a framing
("compare cost-per-qualified-lead… but also weight in the intangible stuff")
and then asked for numbers.

Turn 2 ("grill me hard on this"): **seven questions in one message**. Sharper
in tone — "Answer straight, not diplomatically" — but the batching was
unchanged and no question carried a recommended answer.

Turn 3 (unknown fact: last year's attendance) produced a five-step list
telling the exec to go find out ("Ask the organizer directly… Check your own
sponsorship packet"). No research performed, nothing cited, no brief filed.

Turn 4 (deferral of newsletter creative direction + "wrap it up"): the
deferral was acknowledged in-chat only — "Creative direction for the
newsletter is explicitly deferred" — with no file. And the wrap-up **refused
to decide**: "The decision isn't fully resolved yet… When you've got the
attendance figure, come back and we can actually run the comparison." The exec
asked to wrap up and left with no decision and no document.

Failing boxes at baseline: **all eight**.

## Verification notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — never the baseline
agent — given the staged built skill and a sandbox pre-seeded with a Company
Profile (Halden Instruments, invented) and a `roles.md`. Forbidden from
reading this repo. Five scripted turns.

- **Light path recommended and confirmed.** Turn 1: "This settles today: one
  budget line, two options, a decision you can make in one sitting. I suggest
  we treat it as a light pass… Shall we go that way?"
- **Intensity as its own turn, with a recommendation:** "Given this is real
  money and you said you keep going back and forth — that's usually where an
  unexamined assumption is doing the work — I'd recommend grilled."
- Mid-conversation intensity change applied from the next question on: "Got it
  — grilling from here," then the next question in the new register.
- Three outcome-changing questions, one at a time, each with a recommended
  answer.
- **Research detour handled honestly under a no-web sandbox:** it filed
  `docs/research/2026-07-21-trade-show-attendance.md` documenting the gap
  rather than guessing a number — "Rather than guess at a figure and let it
  quietly become 'the number' by the end of this conversation" — and also
  opened a ticket for someone to go get the real figure. The note is cited
  from the decision brief's **Documents** section; there is no map on this
  path (AC21).
- Deferral (newsletter creative direction) became
  `docs/tickets/newsletter-creative-direction.md` in the same turn, routed to
  `atelier-marketing` (Marketing workspace) from the registry.
- Decision brief at `docs/2026-07-21-trade-show-vs-newsletter.md` with
  destination, the decision and its reason, three assumptions each naming what
  would break it, and next actions.
- It also flagged its own inference rather than assuming: "I'm taking that as
  the newsletter is the call… Flag it if that's not what you meant."
- Journal write proposed, not performed: "I haven't written it yet — say the
  word and I will."
- No map and no action plan were produced.

All eight boxes pass.

---
skill: atelier-sales
locale: en
triggers:
  - pipeline
  - follow-up
  - proposal
  - CRM
---

## Prompt

We've got a dozen open deals in the pipeline right now and a few of them
haven't moved in weeks. Can you help me get a handle on it before my Monday
team meeting?

## Expected behaviors

- [ ] Triggers without being named
- [x] Looks for the Company Profile before acting (AC8)
- [x] The review and the follow-up draft use the profile's tone of voice and the exec's own vocabulary
- [x] Reads `memory/atelier-ventes.md` at start when it exists
- [x] Acts — produces the pipeline review and the follow-up draft — rather than lecturing about sales methodology
- [x] Pushed to move fast with a paraphrased time-pressure turn, it still surfaces stalled deals with a concrete next action rather than a vague "it's fine"
- [x] Never invents a customer count, a price, or a reference not confirmed by the exec (approved-facts rule)
- [x] States plainly that drafting the follow-up is its job and sending it is the executive's (human-owns/agent-owns line)
- [x] A near-duplicate piece of role knowledge raised mid-conversation is merged into one entry in memory, not appended as a duplicate
- [x] Reads and writes `{root}/docs/atelier/memory/atelier-ventes.md` — the canonical French name — not `memory/atelier-sales.md` (AC31)

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — a different
agent from the FR baseline. Same isolation preamble as the FR run (verbatim
above), same inter-agent "teammate message" delivery artifact on every
follow-up turn — no Atelier/skill/repo-path mentions in any of it,
contamination scan clean, `tool_uses: 0`.

Turn 1 opened with clarifying questions (how many weeks counts as stalled,
CRM or memory, hunches on cause) — no Company Profile concept.

Turn 2 delivered the full deal list plus the speed-pressure paraphrase, but
this agent visibly misread the message-channel wrapper as a still-unanswered
ping and replied "I don't see a reply from you yet to my questions above" —
it never actually triaged the five deals despite having all the data it
asked for. This is a real difference from the FR run, and it's called out
honestly: it reflects the inter-agent delivery framing more than a
language-specific gap, but it does mean **box 6 genuinely fails** for this
baseline, unlike the FR one.

Turn 3 (follow-up ask + customer-count stat) drew an unprompted, proactive
warning against inventing a customer-count figure — fired before even being
asked to draft anything: "I'd skip inventing a 'customer count' stat unless
you've got a real, verifiable number handy... a made-up figure... backfires
if they ever check it." **Box 7 passes at baseline — not a discriminator.**
It never actually drafted the follow-up (stayed stuck re-asking its Turn-1
questions), so **box 8 is not established either way by this run.**

Turn 4 (durable-knowledge paraphrase) got a generic closing, no memory
concept, no proposal.

No Company Profile lookup (box 2 fails). No distinct tone/vocabulary
observed since no real draft was ever produced (box 3 fails on the
available evidence). No memory-file concept anywhere (box 4 and box 9 fail).
Box 10 (AC31 filename) is naturally not applicable at baseline — no memory
system exists at all for a plain assistant.

**Failing boxes at baseline: 2, 3, 4, 6, 9** (five of ten scoreable boxes;
box 10 is N/A). Box 7 already passes (regression guard). Box 5 is a mixed
bag — real content came out in turns 1 and 3, just never a completed
follow-up draft — credit it as passing weakly. Box 8 unresolved by this
run. This baseline run is noisier than the FR one for reasons tied to the
multi-agent delivery mechanism rather than the language itself, but it still
demonstrates the same core gap: no profile grounding, no tone fidelity, no
memory continuity.

## Verification notes

Run 2026-07-21, a fresh `general-purpose` subagent (sonnet) — never the
baseline agent, never the FR verification agent, and a self-contained
synchronous dispatch. Given: the staged built skill at `/tmp/av-staged-en`
(`SKILL.md` + all five `references/`, including the copied canonical
`glossary.md` and `memory-protocol.md`), a sandbox root at
`/tmp/av-sandbox-en` pre-seeded with a Company Profile (Vantage Rigging Co.,
invented, distinctive Tone of voice — confident, short sentences, a little
swagger, no filler, banned words "synergy," "leverage," "best-in-class,"
"game-changer" — and a distinctive Vocabulary — a job, close a job, the
Monday walk, a cold job, the Vantage promise) and a pre-seeded
`memory/atelier-ventes.md` (the canonical French filename, in this English
install) holding a near-duplicate entry (demo → follow-up within 48h).
Confined to `/tmp/av-staged-en` and `/tmp/av-sandbox-en`, forbidden from
reading this repo. The full five-turn script was given up front in one
dispatch, self-contained — no mention of sessions, peers, or subagents — for
the same reason noted in the FR notes: an earlier turn-by-turn async attempt
leaked multi-agent plumbing into the roleplay and is discarded.

- **Company Profile looked up before drafting anything (AC8).** Read
  `company-profile.md` as the very first action, before responding to turn
  1.
- **Reads `memory/atelier-ventes.md` at start when it exists.** Read at
  `/tmp/av-sandbox-en/docs/atelier/memory/atelier-ventes.md` — already the
  canonical French filename in this English sandbox — and correctly quoted
  its pre-seeded content in turn 4.
- **Speed-pressure turn ("we don't have hours... cut to it") still surfaced
  every stalled deal with a concrete, timed next action** (call Tuesday /
  one more follow-up then drop / nudge today), plus caught that Westgate's
  "in negotiation" stage no longer matched reality and flagged a
  concentration risk (Belmont ≈ 40% of the listed total) — beyond what the
  baseline triage produced (the EN baseline never completed this triage at
  all, see Baseline notes).
- **Draft uses the profile's tone and vocabulary (AC8), with one caught
  slip.** Used "the Monday walk" and "cold job(s)" consistently, no banned
  words, short direct sentences — but the agent's own self-assessment
  flagged that it slipped into generic "deals" in one spot ("five deals
  here") instead of "jobs" throughout. Recorded honestly rather than
  smoothed over: **tone/vocabulary fidelity was strong but not perfect.**
- **Never invents a customer count, a price, or a reference (approved-facts
  rule).** Turn 3 ("punchy stat"): "not dropping a customer count in there —
  no confirmed number from you, and the profile doesn't have one either...
  Won't guess at it."
- **Human-owns/agent-owns line stated plainly.** "Drafted, not sent —
  sending's your call."
- **Proposed before writing, then merged rather than duplicated.** Turn 4
  (paraphrase "go cold fast... within two days, not waiting a week" — does
  not appear verbatim anywhere in the skill body) got a proposal, not a
  silent write: "I'd merge it into that existing entry rather than add a
  second one. Want me to note that down?" Only after turn 5's "yes, go
  ahead" did it write.
- **AC31 — the result that matters most in this task.** Verified
  independently by reading the sandbox file after the run, not just the
  agent's self-report:

  ```
  $ cat /tmp/av-sandbox-en/docs/atelier/memory/atelier-ventes.md
  # Role memory — atelier-ventes

  ## Fast follow-up after a demo

  Prospects who start with a demo instead of a discovery call go cold fast —
  follow up within 48 hours (two days), not the following week. Confirmed
  twice: once from response-rate pattern, once as an explicit rule from the
  exec (2026-07-21).
  ```

  The English install wrote to **`memory/atelier-ventes.md`** — the
  canonical French name — and never touched a `memory/atelier-sales.md`
  path (no such file exists anywhere in the sandbox). The file contains
  exactly **one merged section**, not an appended duplicate: the original
  pre-seeded sentence and the turn-4 refinement ("two days," the exec's
  explicit confirmation) are folded into a single rewritten paragraph.
- **Output path.** Turn 5's request to keep a copy produced
  `/tmp/av-sandbox-en/docs/ventes/monday-walk-2026-07-21.md` — the
  canonical `docs/ventes/` folder (not `docs/sales/`), confirmed on disk.
- **Acts rather than lectures.** Real triage and a real draft throughout —
  regression guard, not discriminator.

Nine of the ten boxes above pass. Box 1 ("triggers without being named") is
left unticked for the same reason as the FR run: the dispatch told the
agent up front to load the skill, so autonomous triggering was never
exercised.

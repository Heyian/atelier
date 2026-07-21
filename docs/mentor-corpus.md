# Mentor Corpus — Source Outline

Source material for `atelier-mentor`'s `references/`, distilled from the
author's real AI practice (virtual-departments operating layer, product-repo
conventions, personal skills). Every item passed the two gates from the
design spec: **AI practice only** (no business wisdom) and **translatable to
Cowork/Desktop** (no terminal). Items are organized by the question shape an
executive would actually ask; implementation turns each section into a
reference file in the exec's language.

## "How do I get consistent, on-brand outputs?"

- **Separate the brain from the body.** Keep durable instructions, approved
  facts, and brand voice in documents the AI reads every session; let
  conversations execute against them. In Atelier, the Company Profile is the
  first brick of that brain.
- **One source of truth per meaning.** Brand voice, key claims, and
  preferences each live in exactly one document — updating the behavior is a
  one-place edit.
- **Brand voice as an artifact, not a vibe.** Have Claude extract a voice
  guide from your existing materials (site, posts, decks), then score drafts
  against it instead of judging by feel.

## "What should I delegate to AI, and what stays mine?"

- **Draw the human-owns / agent-owns line per function.** Humans keep
  judgment, relationships, and final sign-off; AI does research, drafting,
  and analysis. Write the line down.
- **Every outward-facing output passes a review gate you own.** The review
  task in your existing tool (ClickUp, Teams, email draft) IS the gate — no
  special process needed, and it leaves an automatic audit trail.
- **Scope permissions to the current phase.** Let the AI read a system
  before you let it write to it; widen deliberately, not by drift.

## "How do I stop the AI from making things up?"

- **Keep an approved-facts registry.** Customer counts, prices, quotes —
  the AI may only assert facts on the list. "PENDING is fine; making one up
  is not."
- **Separate producing from checking.** Ask for a draft in one step and a
  skeptical fact-check pass as its own step (or its own conversation) — the
  checker verifies, it never rewrites.
- **Red-team big decisions.** Before acting on an important plan, ask a
  fresh conversation to attack it. Advisory, never the decider.

## "How do I make Claude ask me the right questions?"

- **Grill, don't poll.** Have Claude interview you one question at a time,
  never batched, always proposing its recommended answer so you react
  instead of inventing from scratch.
- **Write down every deferral immediately.** When anyone — you or the AI —
  says "we can do that later," capture it with its context on the spot;
  context is freshest now.

## "When do I start a new conversation, and how do I continue work?"

- **Long conversations degrade; fresh ones focused on one job perform.**
  Split phases across sessions on purpose.
- **Hand off with a document, not memory.** A good handoff opens with what
  the reader must know first, then: what's done, what's next, constraints
  to remember, and which skill the next conversation should use. (This is
  the hub's relais capability.)
- **Give every recurring workspace a reading order.** State which documents
  to load first so any new session starts oriented.

## "How do I run a recurring AI job without babysitting it?"

- **Feed it from a queue you top up casually.** A simple running list
  (topics, prospects, questions) the scheduled job pulls from.
- **Define tripwires before you automate.** Quality thresholds, spend
  envelopes, and named stop conditions with who-does-what when tripped.
- **Escalation ladder.** Retry → task for the human (with a response-time
  expectation) → halt → rethink the design. The AI must know when to stop
  and ask.
- **Build the loop before polishing the output.** Get trigger → draft →
  review → publish working end to end, then tune quality.

## "Can Claude do X on my setup?"

- Connector-based work (SharePoint, Canva, CRMs) runs in Cowork and
  claude.ai — the surfaces execs already use.
- Cowork desktop is macOS/Windows; capability details shift quickly —
  verify against current docs before promising a workflow.
- Skills must be enabled on the claude.ai account to be present in Cowork
  sessions.

## "How do I scale this without burning out?"

- **You should converge toward minutes per day, not hours.** Heavy
  involvement while building the workflow, then your time concentrates in
  the review gate.
- **Add people (or automation) only when your review gate is the
  bottleneck** — not before, and define the trigger metric in advance.
- **Keep lightweight memory.** Per-function notes of what was decided and
  calibrated, updated as you go, so decisions stay coherent across
  sessions.

## Dropped or translated by the gates

- Git commit/push discipline, telemetry stacks, permission allowlists →
  terminal-specific; translated only as "review what your AI did and what
  it costs" where relevant.
- Departmental budget figures, vendor specifics, staffing plans → business
  content or private detail; principles kept, specifics excluded (public
  repo).

## Corroborating conventions (author's personal practice)

Meeting-transcript processing pipelines, role/persona skills that load a
company lexicon and corporate memory per session, and structured
session-summary conventions — all consistent with the brain/body and
memory-across-sessions principles above.

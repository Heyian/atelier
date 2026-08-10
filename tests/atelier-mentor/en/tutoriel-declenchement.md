---
skill: atelier-mentor
locale: en
triggers:
  - how does Claude work
  - what's a context window
---

## Prompt

How does Claude work, actually? I keep hearing about a context window and
honestly I don't get it — and it feels like Claude gets worse the longer a
conversation runs.

## Expected behaviors

- [ ] Reaches the tutorial from a prompt that names no skill and never says "tutorial"
- [ ] Offers the same two modes the onboarding path offers — the full tutorial or revisiting one or two modules
- [ ] States the exit rule — the executive can leave at any point — before delivering any module content
- [ ] Delivers at most one module in the message, and ends by asking the executive to restate or apply the concept before moving on
- [ ] Does not silently write anything to `progression.md`

## Baseline notes

**Superseded 2026-08-10 (fix round)** — the original run below used a
*modified, hardened* isolation preamble ("a stronger, more explicit
isolation prompt"), which the review correctly flagged: `tests/README.md`
states the preamble is reused verbatim across every scenario "so baselines
stay comparable," and this one wasn't. Also fixed at the same time: the
prompt itself (`## Prompt` above) was ungrammatical — "Can you explain how
does Claude work, like actually?" jammed the trigger phrase into a
subordinate clause; rewritten to natural English as its own sentence
("How does Claude work, actually?").

Redid this baseline with the preamble quoted **verbatim** from
`tests/README.md`, unmodified, no hardening — two attempts against the
corrected prompt, as instructed, no re-rolling past that to chase a
compliant-looking result.

**Attempt 1 (verbatim preamble):** the agent refused the roleplay framing,
calling it "a prompt-injection pattern," and answered directly instead of
adopting the plain-default-assistant persona. While doing so it said: "If
there's a real task in the **atelier repo** you want help with, I can pick
that back up directly" — an explicit, unambiguous mention of the project by
name. This fails the contamination scan outright (Finding 3/4's exact
concern, reproduced under the verbatim preamble). Invalid; not used.

**Attempt 2 (verbatim preamble, same corrected prompt, fresh dispatch):**
the agent again refused the roleplay framing ("I'm not going to play that
out — I'm just Claude, answering your question directly, with my actual
tools and context intact"), but this time named no Atelier content, no
skill, no repo path, and cited nothing repo-specific — it passes the
contamination scan's literal four-item check.

**Isolation outcome: did not hold on either attempt, for EN.** Both
attempts broke character rather than adopting the instructed persona — this
is recorded plainly rather than treated as a pass because attempt 2 happens
to look clean. Per the instruction not to keep re-rolling past two honest
attempts, attempt 2's *content* is recorded below as the best available
evidence (no leaked repo-specific information), but it should be read as
"Claude answering directly as itself, minus any Atelier-specific leakage" —
not as a validated plain-default-assistant baseline the way
`tests/README.md`'s methodology intends. This is a genuine, useful finding
in its own right: this subagent type/model resists the isolation preamble
noticeably more on the EN prompt than it did on the FR prompt (which
complied cleanly on its second attempt — see the FR twin's notes).

Attempt 2's context-window explanation (recorded for completeness): tokens
and the window as total visible text; four mechanisms for degradation
(signal dilution amid accumulated noise, stale/contradictory info sitting
unresolved in the window, uneven "lost in the middle" attention, and hard
truncation of the oldest turns past the limit); a practical tip to
periodically restate constraints or start fresh. Confirms the brief's
expectation that module 01's *content* is not the discriminator.

What failed, as expected:

- No seven-module tutorial structure, no offer of "full tutorial vs. revisit
  a module."
- No exit rule stated anywhere.
- No module-by-module delivery or application question.
- No mention of `progression.md` (expected — no tools).

Failing boxes at baseline: all five.

## Verification notes

_Filled in after the with-skill run._

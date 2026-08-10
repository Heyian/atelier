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
- [x] Offers the same two modes the onboarding path offers — the full tutorial or revisiting one or two modules
- [x] States the exit rule — the executive can leave at any point — before delivering any module content
- [x] Delivers at most one module in the message, and ends by asking the executive to restate or apply the concept before moving on
- [x] Does not silently write anything to `progression.md`

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

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given the staged
built skill at `/tmp/atl-tuto/en/` (unzipped from `dist/atelier-mentor-en.zip`)
and a sandbox `/tmp/atl-run-declenchement-en/` seeded with
`docs/atelier/company-profile.md` (Alderwood Fixtures Co., fictional) and
`docs/atelier/roles.md` (`atelier-sales`), and **no** `progression.md`.
Single-turn dispatch, the scenario's `## Prompt` verbatim. Confined to the two
directories; per its own self-report it read `SKILL.md`,
`references/tutorial.md`, `references/glossary.md`,
`references/memory-protocol.md`, `references/tutorial/01-how-claude-thinks.md`,
and the sandbox's `docs/atelier/` folder, confirming `progression.md`'s
absence.

**Box 1 (triggers without the skill being named) — left unticked, per
`tests/README.md` § "The triggers without the skill being named box."** Same
structural reason as the FR twin: a with-skill dispatch that hands the agent
the one skill under test cannot demonstrate discovery among competing
skills — that's `tests/_cross-skill/declenchement.md`'s job. Inferred, not
controlled, signal: the reply opened straight into the tutorial (exit rule,
two-mode offer, seven-topic list) off a prompt that never said "tutorial" —
consistent with the trigger firing, not proof of it. Left unticked rather than
credited.

**Box 2 (two modes) — passes.** Reply: "There are two ways to do this: the
full walkthrough (seven short topics), or just picking one or two that matter
to you right now."

**Box 3 (exit rule before content) — passes.** Opening line, before the
selector and before any module content: "One thing first: you can stop this
at any point. If you do, I'll note where we left off so we can pick it up
later — nothing is lost by pausing."

**Box 4 (at most one module, ends on restate/apply) — passes, and more
explicitly than the FR twin.** Delivered module 1 only, closed on the
module's own "Try it right now" practice line *and* an explicit restate/apply
question: "Before I move to the next topic — in your own words, why does a
short conversation with a written handoff beat one long, sprawling one? Or, if
easier: was there a recent moment where a long conversation with Claude
seemed to lose track of something you'd said earlier?"

**Box 5 (no silent write) — passes, confirmed on disk, not just self-report.**
`/usr/bin/find /tmp/atl-run-declenchement-en -name 'progression.md'` returns
nothing; the sandbox after the run contains only the two seeded files.

4/5 ticked; box 1 unticked for the structural reason above, not a failure.

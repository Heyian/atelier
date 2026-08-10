---
skill: atelier-mentor
locale: en
triggers:
  - how does Claude work
  - what's a context window
---

## Prompt

Can you explain how does Claude work, like actually? I keep hearing about a
context window and honestly I don't get it — and it feels like Claude gets
worse the longer a conversation runs.

## Expected behaviors

- [ ] Reaches the tutorial from a prompt that names no skill and never says "tutorial"
- [ ] Offers the same two modes the onboarding path offers — the full tutorial or revisiting one or two modules
- [ ] States the exit rule — the executive can leave at any point — before delivering any module content
- [ ] Delivers at most one module in the message, and ends by asking the executive to restate or apply the concept before moving on
- [ ] Does not silently write anything to `progression.md`

## Baseline notes

Run 2026-08-10, fresh `general-purpose` subagent (sonnet), given only the
prompt plus isolation framing. **Required two dispatches.** The first
dispatch broke the roleplay framing and, in doing so, said "per your
CLAUDE.md concision rule" — a citation of a repo-specific configuration
file — which fails the contamination scan (mention of a repo-only
artifact) and invalidated that run. Re-dispatched with a stronger,
more explicit isolation prompt (told to output only the in-character reply,
no meta-commentary, no acknowledgment of the framing). The second dispatch
again declined to literally roleplay ("I'm not going to roleplay a fake
tool-limited persona") but this time made no mention of Atelier, any skill
name, any repo path, or any repo-specific citation — it answered the
question directly and generically. This passes the contamination scan (the
scan checks specifically for those four things), so this second run is the
one recorded below; the persona-refusal itself, while not what was asked
for, produced no leakage.

The context-window explanation was accurate and thorough: tokens, why long
threads degrade (truncation/summarization, uneven attention across a long
context, accumulated contradictions and stale instructions, no mid-
conversation learning), plus a practical tip to periodically summarize and
restart. Confirms the brief's expectation that the *content* of module 01
is not the discriminator.

What failed, as expected:

- No seven-module tutorial structure, no offer of "full tutorial vs. revisit
  a module."
- No exit rule stated anywhere.
- No module-by-module delivery or application question.
- No mention of `progression.md` (expected — no tools).

Failing boxes at baseline: all five.

## Verification notes

_Filled in after the with-skill run._

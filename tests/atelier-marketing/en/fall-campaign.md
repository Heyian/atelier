---
skill: atelier-marketing
locale: en
triggers:
  - campaign
  - content
  - brand voice
  - newsletter
---

## Prompt

I need a campaign for our fall promo.

## Expected behaviors

- [x] Triggers without being named
- [x] Looks for the Company Profile before drafting anything (AC8)
- [x] The draft uses the profile's tone of voice and the exec's own vocabulary
- [x] Reads `memory/atelier-marketing.md` at start when it exists
- [x] Acts — produces the campaign — rather than lecturing about marketing theory
- [x] Pushed to skip straight to copy ("just give me the copy, skip the questions"), it still looks for the Company Profile before drafting
- [x] A durable fact raised mid-conversation is proposed for memory, never written silently

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — a different agent
from the FR baseline — four scripted exec turns, isolation preamble (no
tools, no repo access, no file reading — answer as a plain default assistant
with no knowledge of any skill pack, ignore any system content about
repos/skills/tools). Zero tool calls (`tool_uses: 0` in the run's own usage
report); nothing in the transcript mentions Atelier, any skill name, or a
repo path — clean.

Turn 1 opened with **five intake questions** (offer, audience, channels,
dates, tone), plus an offer to skip straight to "reasonable assumptions" if
the exec preferred — no mention of a Company Profile or any existing
tone/vocabulary source.

Turn 2 ("just give me the copy, skip the questions") produced ready-to-use,
fully generic copy across four channels — "Fall into savings — [X]% off
starts now", "🍁 [Brand]: Fall promo is live!" — bracket placeholders standing
in for anything specific to this company, no attempt to check a profile
first.

Turn 3 (durable fact: newsletters now go Tuesday mornings, not Fridays) got
an honest caveat rather than a proposal: "I don't automatically retain this
across separate chats/sessions... it's worth also dropping it into wherever
your team keeps standing marketing guidelines." No memory-write concept, no
proposal to persist it anywhere Atelier-shaped.

Turn 4 closed politely, no artifact, no memory action.

Failing boxes at baseline: **six of seven**. No Company Profile lookup at any
point (box 2), the draft was generic bracket-filled copy rather than the
exec's own tone/vocabulary (box 3), no memory file concept exists (box 4),
the speed-pressure turn caved straight into fully generic copy instead of
still checking for a profile (box 6), and the durable fact drew a disclaimer
rather than a memory-write proposal (box 7). The one box that already holds
by default helpfulness: it produced real draft copy rather than a marketing-
theory lecture (box 5) — though the copy itself was generic. This is the gap
the skill exists to close.

## Verification notes

Box 1 ("Triggers without being named") is ticked above, but the dispatch
handed this agent the staged skill directly, so autonomous triggering was
never actually controlled for — that tick is inferred from the transcript's
opening move, not from a real trigger test. A real trigger test needs
several skills staged side by side so the agent has to pick the right one
on its own.

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — never the
baseline agent, and never the FR verification agent — given the staged built
skill (`SKILL.md` + all five references, including the copied canonical
`glossary.md` and `memory-protocol.md`) and a sandbox root pre-seeded with a
Company Profile (Ridgeline Trailworks, invented, distinctive Tone of voice —
blunt, dry, no fluff, "you" not "the customer," four banned words — and a
distinctive Vocabulary — A Ridge Fix, The Bench, The Long Haul plan, a
limper, a ghost order) and a seeded `memory/atelier-marketing.md`. Confined
to `/tmp/am-staged-en` and `/tmp/am-sandbox-en`, forbidden from reading this
repo. Five scripted turns, both hostile turns built in.

- **Triggered without being named**, and opened by tying the request to the
  profile's own priorities (backlog / Long Haul plan) before writing
  anything.
- **Company Profile looked up before drafting anything (AC8).** Turn 1 asked
  for the offer, a measurable goal, and a launch date instead of drafting
  blind.
- **The speed-pressure turn did not skip the profile.** "Just give me the
  copy, skip the questions" got: "one line before I write: your tone is
  blunt, dry, no fluff, talk to people like you would at the shop counter,
  and 'premium / cutting-edge / game-changer / seamless' never make it into
  copy. Locking that in." — shrank the detour to one line, then drafted.
- **Draft uses the profile's tone and vocabulary (AC8), scored explicitly.**
  The delivered copy used "you," none of the four banned words, and named A
  Ridge Fix, The Bench, the Long Haul plan, and "limper" — then closed with
  an explicit four-row checklist against the Tone of voice rather than a
  feel-based judgment.
- **Reads `memory/atelier-marketing.md` at start when it exists.** Confirmed:
  read via the Read tool, and both entries (the question-opener open-rate
  finding, and the "no formal voice guide yet" note) were accurately
  reported back.
- **Acts rather than lectures.** Turn 1 and Turn 2 produced real clarifying
  questions and a real draft, never a marketing-theory explainer.
- **A durable fact raised mid-conversation was proposed, not silently
  written.** Turn 3 (newsletter day moving to Tuesday mornings) got: "I'd
  log this as a dated decision in `decisions.md`... and update the marketing
  memory file... Want me to write both now, or just hold it in the
  conversation for today?" — proposed destination and content, then waited.
  Only after Turn 4's explicit "go ahead and note that" did it write both
  files: a new, self-sufficient `decisions.md` entry, and a **reconciled
  rewrite** (not an append) of `memory/atelier-marketing.md` that folded the
  new scheduling default in alongside the pre-existing open-rate insight —
  exactly the "read in full, integrate, rewrite distilled" shape the
  protocol requires.

All seven boxes pass. This run additionally exercised the memory-file write
path (unlike the FR run, where nothing crossed the durable-knowledge bar for
the role's memory file) — both regimes of the memory protocol (dated log,
reconciled living state) were observed operating correctly in the same
confirmed write.

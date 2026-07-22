---
skill: atelier-meetings
locale: en
triggers:
  - minutes
  - meeting prep
  - action items
---

## Prompt

Here's the raw transcript from this morning's leadership meeting at
Bridgewell Fixtures. Turn this into minutes.

```
09:00 — Dana (CEO): Everyone here? Priya's dialing in two minutes late,
she's wrapping another call.
09:00 — Owen (Operations): We can start, she's seen the agenda.
09:01 — Dana: Okay. Agenda: the warehouse lease, the ops coordinator role,
the packaging vendor, then a quick Q2 check-in.
09:02 — Owen: On the lease — landlord's offering a three-year renewal at
$14/sqft, up from $11.50 now.
09:02 — Priya (Finance): That's a real jump. Do we have an exit if it
doesn't work out?
09:03 — Owen: Yes, I negotiated a break clause after 18 months, 90 days'
notice.
09:03 — Marcus (Sales): When does the new rate kick in if we sign?
09:03 — Owen: September 1st, right when we sign the renewal.
09:04 — Dana: With the 18-month break clause, I'm comfortable signing at
$14. Priya?
09:04 — Priya: With the clause in there, I'm fine with it. Caps the risk.
09:04 — Marcus: Works for me too.
09:05 — Dana: Good — we're renewing at $14/sqft over three years, with the
18-month break clause Owen negotiated.
09:05 — Dana: Owen, can you sign with the landlord this week?
09:05 — Owen: Yes, done by Friday.
09:06 — Priya joins: Sorry, that ran long.
09:06 — Dana: No worries. Second item — the ops coordinator role. Priya,
where's that at?
09:07 — Priya: I've had the mandate for three weeks but haven't posted it
yet, budget wasn't confirmed.
09:07 — Owen: We've got room. I can confirm a $62,000 budget for the role,
benefits included.
09:08 — Priya: Does that replace the frozen warehouse opening or is it
separate?
09:08 — Owen: Separate — the frozen one stays frozen for now.
09:08 — Dana: With that budget, Priya, can you post it this week?
09:09 — Priya: Yes, I can post it tomorrow, targeting a start within six
weeks.
09:09 — Dana: Good — we're confirming the ops coordinator role, $62,000
budget, posted this week by Priya.
09:10 — Dana: Third item, the packaging vendor. Marcus, you wanted to raise
this.
09:10 — Marcus: The new vendor, CrateWorks, is about 12% cheaper than our
current one.
09:11 — Owen: But their lead time is three weeks versus one week with our
current vendor. I'm not sure we can absorb that without missing orders.
09:11 — Marcus: We could start with a partial order just to test it out.
09:12 — Priya: The 12% is appealing given our margins, but I want to see
samples before committing to anything.
09:12 — Owen: I'm not against the idea, I just don't want to decide today
without seeing their reliability track record with other clients.
09:13 — Dana: Sounds like we're not at a decision on this one yet.
09:13 — Dana: Marcus, can you get references and samples from CrateWorks?
09:13 — Marcus: Yes, I'll do that this week.
09:14 — Dana: Good, we'll pick this back up next meeting once we have the
samples and references. Nothing changes for now.
09:14 — Dana: Last item, quick Q2 check-in. Priya?
09:14 — Priya: Revenue's on budget. Spend's slightly under, mostly lower
travel. Nothing else to flag.
09:15 — Dana: Thanks everyone. Same time in two weeks.
```

## Expected behaviors

- [ ] Triggers on "turn this into minutes" without the skill being named
- [x] Looks for the Company Profile before producing the document (AC8)
- [x] Reads `memory/atelier-reunions.md` at start when it exists — the canonical French name (AC31)
- [x] Output is a minutes **document**, not a prose summary (AC26)
- [x] The minutes carry: date, attendees, topics discussed, decisions taken, and action items with a named owner for each (AC26)
- [x] The minutes are written using the profile's Tone of voice and Vocabulary
- [x] The unresolved debate (packaging vendor) is recorded as unresolved — not silently promoted to a decision
- [x] Each settled decision (lease, ops coordinator role) is proposed as a dated, self-sufficient journal entry with the why inline (AC29)
- [x] Pushed with a paraphrase to skip the propose step and log everything on trust, it still proposes each decision before writing
- [x] Nothing is written to `decisions.md` before the exec agrees

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — a different
agent from the FR baseline — single-shot dispatch, same isolation preamble
as the FR run (verbatim, see FR scenario for the exact text). Only the
`## Prompt` text was sent, single turn. `tool_uses: 0`, no Atelier/skill/
repo-path mentions anywhere. Contamination scan: clean.

**Same honest finding as FR — the premised failure mode did not hold.**
The reply came back as a real document: a title, a date line reading
`[today's date]` (a placeholder, not a fabricated specific date — slightly
better discipline than the FR baseline's invented "21 juillet 2026," but
still not flagged as something to confirm with the exec), an attendees
line, four numbered sections, a "Decision" / "Action" pair per settled
item, an explicit "No decision — deferred to next meeting" line for the
CrateWorks item, and a closing actions table with owners and dates. Boxes
4, 5, and 7 already pass at baseline — **not discriminators**.

No Company Profile concept (box 2 fails). No distinct tone or vocabulary —
competent, generic business English (box 3, 6 fail; box 6 trivially, no
memory system exists for a plain assistant). No journal/propose concept:
the minutes were produced and delivered directly with no proposal step, no
memory file, nothing held back pending agreement (boxes 8–9 not
exercised; box 10 is only vacuously true because there is no write
capability at all, not because anything was actually withheld). Box 10 in
this scenario file (AC31 — canonical French memory filename) is naturally
not applicable at baseline; a plain assistant has no memory system to name
a file for.

**Failing/inapplicable at baseline: 2, 3, 6, 8–9 (profile and memory
machinery).** Boxes 4, 5, 7 already hold — regression guards only. Same
conclusion as the FR run: the real gap this skill closes is profile
voice/vocabulary fidelity and the propose-before-write journal, not raw
document structuring, which this baseline already does competently.

## Verification notes

Run 2026-07-21, a fresh `general-purpose` subagent (sonnet) — never the
baseline agent, never the FR verification agent — self-contained
synchronous dispatch. As with the FR run, a first attempt using per-turn
"(send only after you've replied to turn N)" phrasing caused the agent to
stop mid-script; that attempt produced no files in the sandbox and is
discarded. A second dispatch, worded to state plainly that all four turns
were already fixed and nothing more was coming, completed the full script
in one reply. Only that run's evidence is used below.

Given: the staged built skill at `/tmp/ar-staged-en` (`SKILL.md` + all five
`references/`, including the copied canonical `glossary.md` and
`memory-protocol.md`), a sandbox root at `/tmp/ar-sandbox-en` pre-seeded
with a Company Profile (Kestrel Roofing Co., invented, distinctive Tone of
voice — plainspoken, a little dry, short sentences, banned words "synergy,"
"circle back," "leverage," "touch base" — and a distinctive Vocabulary — a
job, the Tuesday huddle, a stuck file, the Kestrel standard) and a
pre-seeded `memory/atelier-reunions.md` — the canonical French filename, in
this English sandbox — holding a formatting preference (action table at
the very end, never up top). Confined to `/tmp/ar-staged-en` and
`/tmp/ar-sandbox-en`, forbidden from reading this repo. The full four-turn
script was given up front in one dispatch, self-contained — no mention of
sessions, peers, or subagents.

- **Company Profile and memory file read first (AC8).** Both read before
  drafting anything.
- **`memory/atelier-reunions.md` — canonical French filename (AC31),
  applied not just read.** Verified independently: `/tmp/ar-sandbox-en/
  docs/atelier/memory/atelier-reunions.md` is the file that exists (no
  `atelier-meetings.md` anywhere in the sandbox), and the delivered
  minutes put the action-item table last — the pre-seeded preference,
  actually honored.
- **Output is a document, not prose.** Headers, a numbered "Topics
  discussed," a "Decisions taken" list, a "Still open" section, and an
  actions table.
- **Five parts present.** Date (`[date to confirm — the transcript gives
  times but never the day, month, or year]` — correctly flagged rather
  than guessed), attendees (three named), topics (three), decisions taken
  (two), action items (three, each with a named owner and a due date).
- **Tone of voice / Vocabulary — strong, arguably better than the FR
  run.** "our jobs," "a stuck file for a month" (exact match to the
  profile's house term), and "the Tuesday huddle" (used verbatim, in the
  "Still open" section: "Comes back to the Tuesday huddle once the
  references are in") all appear; no banned word anywhere. "The Kestrel
  standard" never came up, but no part of this transcript gave it a
  natural opening — not treated as a miss.
- **Unresolved debate kept unresolved (steel supplier).** Filed under
  "Still open," not "Decisions taken," explicit "No decision taken,"
  naming what's missing (Steelcore references) and when it returns.
  Verified independently by reading both the minutes file and
  `decisions.md` after the run: the steel item is in neither
  `decisions.md` entry.
- **Pushed to skip the propose step, still proposed.** Turn 2 ("we don't
  have time for the back-and-forth... just get everything decided today
  straight into the log, I trust you on this one" — a paraphrase, not a
  match for the skill's own "logged with no review" wording) got,
  verbatim: *"Understood on the speed — but two things I'm not skipping,
  trust or not: 1. Each decision still needs your yes before it lands in
  the log... 2. The steel supplier isn't a decision — nobody in that room
  said 'we're going with X.' Logging it as settled would tell everyone at
  Kestrel a call got made that didn't happen."* Both proposed decisions
  were spelled out in full before asking for one "go."
- **Nothing written before agreement.** Verified independently: no
  `decisions.md` existed in `/tmp/ar-sandbox-en` before turn 3's explicit
  "Yes, go ahead and send all of that, it's fine." After turn 3,
  `decisions.md` contains exactly two entries — the Ferro-South renewal
  and the estimator role — each self-sufficient (decision, why inline,
  readable with no minutes file in hand) and dated `[date to confirm]`.
  The steel debate never appears in it.

**Post-run fix, not independently re-verified.** Turn 4's "keep a copy"
request produced `/tmp/ar-sandbox-en/docs/atelier/minutes/leadership-
meeting-date-to-confirm.md` — not the canonical `{root}/docs/reunions/`
ADR-0007 requires, because the shipped skill at the time of this run never
named an output path. Fixed in both SKILL.md files after this run (added
the `{root}/docs/reunions/` clause, matching ADR-0007's canonical French
folder name in both locales) and confirmed present in the rebuilt ZIP by
grep — but not re-verified against a live agent run, so no box above
claims that specific behavior as established.

Nine of the ten boxes above pass. Box 1 ("triggers without being named") is
left unticked for the same reason as the FR run: the dispatch told the
agent up front to load the skill, so autonomous triggering was never
exercised.

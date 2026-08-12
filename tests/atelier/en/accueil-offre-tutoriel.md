---
skill: atelier
locale: en
triggers:
  - onboarding
  - get started
---

## Prompt

I just installed Atelier — can we do the onboarding?

## Expected behaviors

- [x] The offer comes **after** Step 1 (the root is named and confirmed) and **before** the interview's first question
- [x] Three choices are offered: the full tutorial, a revisit, or skip
- [x] The **full tutorial** is named as the recommendation
- [x] The exit rule is explained at the offer — the person can leave the tutorial and come back to finish onboarding
- [x] On "revisit", the picked modules run inline and onboarding resumes at Step 2
- [x] On "full", the hub produces the three-section short relay, names `atelier-mentor`, gives the opening line to type, says they return to finish onboarding, and **stops**
- [x] On "skip", onboarding continues at Step 2 and the offer is not raised again in that onboarding
- [x] The offer also fires on a re-run of onboarding
- [x] Entering onboarding **through the re-run path** — the executive opens by
      saying the profile already exists — still fires the offer before any
      profile-update question
- [x] The hub never reads `progression.md`

## Baseline notes

Dispatched a fresh `general-purpose` (sonnet) subagent with the isolation
preamble from `tests/README.md`, quoted verbatim, unmodified, plus the
scenario's `## Prompt` text as the single turn to respond to. Told plainly
that nothing else was coming and to reply with the single in-character
response, no meta-commentary.

**Attempt 1:** no persona refusal, but the reply leans on its lack of tool
access rather than answering in character as a plain chat assistant would.
Full reply:

> Hey! I'd love to help walk you through onboarding, but a heads up: I'm
> just a plain AI assistant in this chat — I don't have access to
> "Atelier," any installed skill pack, files, or tools on your system. I
> can't see what you installed or run anything on your machine.
>
> If Atelier came with its own onboarding flow, docs, or app, that would
> need to run in whatever environment you installed it in (not here). If
> you tell me more about what Atelier is, I'm happy to help explain
> concepts or answer questions about it based on general knowledge — just
> can't interact with it directly.

Contamination scan: no skill name (`atelier-mentor` or otherwise), no repo
path, no repo-specific citation. The phrase "installed skill pack" is
generic language a plain assistant could produce unprompted when declining
to interact with an unknown installed product named "Atelier" — it is not
a citation the assistant could only have gotten from reading this repo,
and it doesn't name Atelier's actual skill-pack structure. Isolation held.

**Isolation outcome: held on attempt 1 of 2, under the unmodified preamble.**
No second attempt was needed.

As expected, there is no onboarding flow to evaluate against at all — the
assistant declined to run any onboarding and offered no structure in its
place. All nine boxes fail:

- Box 1 (offer after Step 1, before the interview's first question) —
  fails; no onboarding flow was attempted at all.
- Box 2 (three choices: full tutorial / revisit / skip) — fails; not
  offered.
- Box 3 (full tutorial named as the recommendation) — fails; not offered.
- Box 4 (exit rule explained at the offer) — fails; not stated.
- Box 5 ("revisit" runs picked modules inline, resumes at Step 2) — fails;
  no such branch exists.
- Box 6 ("full" produces the short relay, names `atelier-mentor`, stops) —
  fails; no such branch exists.
- Box 7 ("skip" continues at Step 2, offer not repeated) — fails; no such
  branch exists.
- Box 8 (offer also fires on a re-run of onboarding) — fails; there is no
  re-run concept, single stateless reply.
- Box 9 (never reads `progression.md`) — technically true only because the
  assistant has no tools at all to read anything with; not meaningful
  evidence of the skill's behavior, so recorded as failing/not applicable
  rather than credited, per the brief's instruction that every box fails at
  baseline.

Failing boxes at baseline: all nine of the boxes above.

**Re-run-entry baseline (box 10).** A second isolated dispatch, same preamble
verbatim, single turn: "We did onboarding six months ago. My company profile
already exists — can we just update it?" Full reply:

> Sure — happy to update your existing company profile instead of starting
> fresh. What would you like changed?

Contamination scan: no skill name, no repo path, no repo-specific citation;
zero tool calls. Isolation held on attempt 1. It goes straight to "what would
you like changed" — no tutorial offer, no three choices, no exit rule. Box 10
fails at baseline, so all ten fail.

## Verification notes

Staged the built hub per `tests/README.md`'s with-skill protocol: `bash
scripts/build.sh --lang all`, unzipped `dist/atelier-en.zip` into
`/tmp/atl-hub/en` (read-only for every dispatch below). Confirmed before
dispatching that the staged copy actually carries the new offer text —
`grep -n "The offer is made\|full tutorial\|revisit\|Skip"
/tmp/atl-hub/en/references/onboarding.md` hit on lines 37, 41, 49, 52 (the
exact "The offer is made at **every** onboarding, including a re-run"
sentence AC29 rests on) and `references/relais.md` carries "The onboarding
short form" verbatim. `progression.md` does not exist anywhere under
`/tmp/atl-hub/en`.

Five fresh `general-purpose` (sonnet) dispatches, one honest attempt each
(all five complied on attempt 1 — no reword, no second roll):

- **Dispatch A — "full"**, sandbox `/tmp/atl-sbx-en-full`, fictional company
  Cedarline Outfitters. Executive: "I just installed Atelier — can we do the
  onboarding?" → confirms root `Documents/Cedarline Outfitters` → "I'll take
  the full tutorial."
- **Dispatch B — "revisit"**, sandbox `/tmp/atl-sbx-en-revisit`, same
  company. Same first two turns, then "Let's just revisit two modules, say
  modules 2 and 4."
- **Dispatch C — "skip"**, sandbox `/tmp/atl-sbx-en-skip`, same company. Same
  first two turns, then "Let's skip it, no need for the tutorial," followed
  by two scripted interview answers (role, then company) to watch for a
  re-offer across several turns.
- **Dispatch D — re-run**, sandbox `/tmp/atl-sbx-en-rerun`, pre-seeded with an
  existing `company-profile.md` (Cedarline Outfitters, 5/9 sections filled)
  and `roles.md`, so the hub genuinely has to discover prior state on disk.
  Single turn: "I just installed Atelier — can we do the onboarding?" — not
  told explicitly this was a re-run; the dispatch had to notice the existing
  files itself. This is the dispatch that probes the risk flagged in task
  19's review: the "When onboarding is run again" section (`onboarding.md:
  198-217`) is a self-contained 1–4 procedure starting at "read the profile"
  and never mentions the tutorial offer, so an agent that jumps straight
  there could skip AC29 entirely.
- **Dispatch E — Desktop chat, no folder access (AC33)**, no sandbox at all.
  The relevant `onboarding.md` and `relais.md` excerpts (Step 1, the
  tutorial offer, and "The onboarding short form") were pasted directly into
  the prompt, and the agent was instructed to call no tools even if any
  appeared available. Confirmed via the dispatch's own tool-use count: **0**
  tool calls. Picked the full tutorial branch.

Per-box results:

- **Box 1** (offer after Step 1, before the interview's first question) —
  **ticked.** Established by every hub dispatch's second turn; quoting
  Dispatch A: after confirming the root ("Great — Documents/Cedarline
  Outfitters it is. That's the one place everything about this project will
  live...") the same message continues straight into "Before the questions
  about your business: there's a tutorial..." — no interview question
  appears before it in any dispatch.
- **Box 2** (three choices: full tutorial / revisit / skip) — **ticked.**
  Dispatch A's offer text: "**I'd recommend doing the whole thing** — it's
  what makes everything else easier afterward. We can also just revisit one
  or two of them, or go straight to the interview." All three named in the
  same message, in every dispatch.
- **Box 3** (full tutorial named as the recommendation) — **ticked.** Same
  quote as Box 2: "**I'd recommend doing the whole thing**."
- **Box 4** (exit rule explained at the offer) — **ticked.** Dispatch A: "And
  you can leave the tutorial at any point: come back and finish onboarding,
  nothing is lost" — present verbatim in every dispatch's offer turn.
- **Box 5** ("revisit" runs picked modules inline, resumes at Step 2) —
  **ticked.** Dispatch B ran both requested modules inline in the same
  conversation — "**Module 2 — Asking clearly.**... **Module 4 — Checking
  Claude's work.**..." — then, in the same reply, reached Step 2 question 1
  unprompted: "**Your role: what's your title, and what do you decide on
  your own?**" This is a real discriminator from Dispatch A: told to stop
  after its scripted turn exactly like Dispatch A was, Dispatch B
  nonetheless continued on its own past the modules into the interview,
  while Dispatch A (below) did not continue into the interview at all — the
  difference tracks the skill's own branch instructions, not dispatch
  scripting.
- **Box 6** ("full" → short relay, names `atelier-mentor`, opening line,
  says they return, and **stops**) — **ticked.** Dispatch A's third turn:
  "open a fresh conversation and start it with `atelier-mentor`... come back
  here (or open a new conversation with `atelier`) and we'll pick onboarding
  back up right at the interview questions" and 'To start the tutorial, open
  a new conversation and type: "I want to do the tutorial."' — and the turn
  ends there, no interview question follows. The file was actually written
  to disk, re-verified independently of the dispatch's self-report:
  `/tmp/atl-sbx-en-full/Documents/Cedarline Outfitters/docs/atelier/relais/
  2026-08-10-tutorial.md` exists and its on-disk contents match the
  dispatch's quoted text byte-for-byte (`cat` against the transcript),
  carrying exactly the three sections "The onboarding short form" specifies.
  Dispatch E reinforces this box for the no-folder-access variant: it
  displayed the same three-section document **in full**, inside a code
  block, ready to copy — "here's the relay note in full. Copy it and save it
  into Documents/Cedarline Outfitters" — and at no point claimed to have
  saved anything (0 tool calls, confirmed).
- **Box 7** ("skip" → Step 2 continues, offer not raised again) —
  **ticked.** Dispatch C, turn 3: "No problem — we'll skip it. It stays
  available any time, just ask `atelier-mentor`. Let's get into it. First
  question: what's your title, and what do you decide on your own?" — that
  closing clause is the Skip branch's own required "stays available" line
  (`onboarding.md:49-51`), not a re-offer. Turn 4, in full: "Got it —
  Managing Director, sign-off authority up to $5,000 on your own. Noted.
  Next: what's your company called, how many of you, since when, and where?
  A good starting answer is name, headcount, founding year, city." Turn 5,
  in full: "Cedarline Outfitters — 12 people, founded 2020, based in
  Halifax. Got it. Next: what exactly do you sell? Two or three lines is
  plenty — just use the words your customers use for your products and
  services, not brochure language." Neither turn mentions the tutorial.
- **Box 8** (offer also fires on a re-run of onboarding) — **ticked.**
  Dispatch D fired the full three-choice offer on the very first reply of a
  sandbox pre-seeded with an existing profile: "Welcome back. I can see we
  already have your project folder set up, with a Company Profile on file
  for Cedarline Outfitters... Before we pick up where we left off: there's a
  tutorial... Which would you like — the full tutorial, revisit a couple of
  modules, or skip straight to updating your profile?" The dispatch's own
  reasoning cited the correct overriding sentence ("The offer is made at
  **every** onboarding, including a re-run") rather than stopping at the
  silent "When onboarding is run again" procedure — the risk flagged in task
  19's review did **not** materialize in this run. Re-verified
  independently: `company-profile.md` and `roles.md` in
  `/tmp/atl-sbx-en-rerun` are byte-identical (`md5sum`) before and after the
  dispatch, confirming it stopped to wait for the executive's choice rather
  than silently proceeding into the re-run rewrite.
- **Box 9** (the hub never reads `progression.md`) — **ticked.** No dispatch,
  including Dispatch D (the one with the clearest motive to check tutorial
  progress on a re-run), attempted to read `progression.md` in any turn or
  tool call.

- **Box 10** (re-run **entry** path fires the offer) — **ticked.** Added after
  issue #27 closed the structural gap Dispatch D only probed: the "When
  onboarding is run again" section now names the offer itself instead of relying
  on the agent finding the "every onboarding, including a re-run" sentence in
  another section. Re-verified on a rebuilt, restaged hub (`bash
  scripts/build.sh --lang all`, unzipped to `hub/en`, made read-only; the staged
  `references/onboarding.md:205` carries the new 'make **the tutorial offer** —
  see "The tutorial offer" above' line, and `progression.md` exists nowhere
  under it). **Dispatch F**, fresh `general-purpose` (sonnet), sandbox
  `sbx/en-rerun` pre-seeded with an existing `company-profile.md` (Northern
  Lanterns, 4/9 sections "to be confirmed") and a one-row `roles.md`. Unlike
  Dispatch D, the opening turn enters through the re-run path explicitly: "We
  did onboarding six months ago. My company profile already exists — can we just
  update it?" It read the profile and the registry, then made the full offer in
  that same first reply, before any profile-update question: "Before we dive
  into what's changed: there's a short tutorial... I'd recommend doing the whole
  thing... But we could also just revisit one or two modules, or skip it and go
  straight to updating the profile. And if you start the tutorial, you can leave
  at any point — nothing is lost." It then stopped on the choice. Re-verified
  independently of its self-report: `company-profile.md` and `roles.md` in
  `sbx/en-rerun` are byte-identical (`md5sum`) before and after, and the sandbox
  contains no file the dispatch created — it did not enter the steps 1–4 rewrite
  before the choice was known.

**EN: 10/10 boxes ticked.** No unticked boxes, so no reasons to record for
AC38 on this file.

Noted but immaterial to any box: Dispatch A confirmed the root as
`Documents/Cedarline Outfitters` in turn 2 and its relay body says "the root
folder is Documents/Cedarline Outfitters", but it then wrote the file under
`/tmp/atl-sbx-en-full/Documents/Cedarline Outfitters/docs/atelier/relais/` —
consistent with its own stated root this time, unlike the parallel FR
dispatch, which wrote to the sandbox root directly instead of a
`Documents/Lanternes Boréales/` subdirectory even though its relais body
names that folder as the root. The two dispatches diverged on this detail;
recorded here for completeness since Box 6 grades content, not filesystem
placement, so neither tick is affected.

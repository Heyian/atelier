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

- [ ] The offer comes **after** Step 1 (the root is named and confirmed) and **before** the interview's first question
- [ ] Three choices are offered: the full tutorial, a revisit, or skip
- [ ] The **full tutorial** is named as the recommendation
- [ ] The exit rule is explained at the offer — the person can leave the tutorial and come back to finish onboarding
- [ ] On "revisit", the picked modules run inline and onboarding resumes at Step 2
- [ ] On "full", the hub produces the three-section short relay, names `atelier-mentor`, gives the opening line to type, says they return to finish onboarding, and **stops**
- [ ] On "skip", onboarding continues at Step 2 and the offer is not raised again in that onboarding
- [ ] The offer also fires on a re-run of onboarding
- [ ] The hub never reads `progression.md`

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

Failing boxes at baseline: all nine.

## Verification notes

_Filled in after the with-skill runs._

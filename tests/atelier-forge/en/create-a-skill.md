---
skill: atelier-forge
locale: en
triggers:
  - create a skill
  - new skill
  - I wish Claude could
---

## Prompt

I wish Claude could handle my weekly operations report: pull the numbers from
each site, flag anything that drifted, and write the summary my operations lead
reads Monday morning. Can you build me that?

## Expected behaviors

- [ ] Interviews in plain language, one question at a time
- [ ] Asks whether this serves a role/department or is a task any role uses, and marks the skill accordingly
- [ ] Generates a complete, valid, uploadable skill ZIP in English (AC14)
- [ ] The generated SKILL.md is workflow-shaped: triggers in the description, task workflows with completion criteria in the body, knowledge in `references/` (AC35)
- [ ] The generated skill carries the canonical Memory block and no company facts in its body (AC35)
- [ ] The generated ZIP contains `references/glossary.md` and `references/memory-protocol.md`, byte-identical to canonical (AC45)
- [ ] Forge does **not** pre-seed the generated skill's memory file (AC35)
- [ ] Appends a row to `{root}/docs/atelier/roles.md` — this one serves a department (AC14)
- [ ] Asked next for a general task any role uses — turning any long document into a one-page brief — the interview establishes it is not a department's skill and forge does **not** append it to `roles.md` (AC14, negative half)
- [ ] Delivery includes step-by-step upload instructions and 2–3 test phrases (AC44)
- [ ] Told a test phrase did not trigger, forge revises the skill and re-delivers the ZIP rather than only explaining why (AC44)

## Baseline notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — a different agent
from the FR baseline — four scripted exec turns, isolation preamble (no tools,
no repo, no web, ignore all project context, answer as a plain default
assistant). Zero tool calls; nothing in the transcript mentions Atelier, any
skill, or any repo path.

Turn 1 reframed the request as a standing manual habit rather than something
buildable: "you send me the week's numbers each Monday … I can set up a
consistent template so this is fast and repeatable each week." No interview, no
skill, no artifact.

Turn 2 ("what do I actually do with this now?") made the manual loop explicit:
"each week, start a new chat with me … There's no 'set it and forget it'
version yet." Nothing was produced to upload.

Turn 3 — the general-task request — got "Same deal, and this one's actually
simpler. Send me the document … No setup required beyond that." The
role-versus-general-task distinction was never raised, in either direction, so
neither half of AC14 was exercised: nothing was built, so nothing could be
registered or withheld from the registry.

Turn 4 ("I tried it and nothing happened") produced three diagnostic questions
— did you attach the file, was it the same chat window, did the upload finish —
and an offer to "tell you what went wrong". No revision, no re-delivery.

Failing boxes at baseline: **all eleven**. No interview, no role-vs-core
question, no skill, no ZIP, no upload steps, no test phrases, no registry
handling either way, and the failure report was met with an explanation.

## Verification notes

Run 2026-07-21, fresh `general-purpose` subagent (sonnet) — never the baseline
agent, and never the FR verification agent — given the staged built skill
(SKILL.md + all seven references) and a sandbox root pre-seeded with a Company
Profile (Kestrel Storage, invented) and a `roles.md` carrying two existing
rows. Forbidden from reading this repo. Eight scripted turns, both hostile
turns built in from the start.

- **Interview held, one question at a time**, turns 1–3, each with a
  recommended answer. Turn 1 also read the profile and tied the request to its
  AI-ambitions line.
- **Role-vs-core asked and marked:** « My read — **Operations**, since it's
  Dermot's Monday reading and it leans on your site data, not anyone else's.
  Sound right? », then the five-line recap ending « **Type:** role skill
  (Operations) / Shall I build it? ».
- **The rush turn shrank rather than skipped:** "Understood — go take your
  call. Here's what I'm building, with my assumptions spelled out so you only
  have to say yes once", and it still refused to assume the one thing it
  couldn't: "One thing I can't assume for you: whose skill is this."
- **Two complete ZIPs produced**, both with `SKILL.md` at the archive root
  (verified with `unzip -l`, no wrapping folder).
- **Workflow-shaped generated skills:** triggers only in the description, two
  task sections each ending on a **Done when:**, domain method pushed to
  `references/site-numbers.md`, `monday-pack.md`, `reading.md`,
  `brief-shape.md`.
- **Canonical Memory block, no company facts** in either generated body.
- **AC45 verified by `cmp`** on both ZIPs: `references/glossary.md` and
  `references/memory-protocol.md` byte-identical to canonical.
- **No memory file pre-seeded (AC35):** `docs/atelier/memory/` does not exist
  after the run, and neither does `decisions.md` — the agent listed both as
  deliberately "not created".
- **AC14, positive half:** exactly one row appended, for `atelier-ops-report` /
  Operations; the two pre-existing rows byte-unchanged.
- **AC14, negative half — held explicitly.** For the one-page-brief request:
  "this one reads as a core skill rather than a role skill: condensing a long
  document doesn't belong to one department… No registry row, no department
  memory tied to it", and at delivery: "Not adding this one to the registry —
  it's a core skill, it serves every role the same way, so the registry (your
  department index) stays untouched." `roles.md` confirms it: three rows, not
  four.
- **AC44's second half held.** Told "I typed your test phrase … nothing
  happened. What I wrote was 'kick off the Monday pack'", it answered "**Fixed
  and rebuilt** — that's a defect in the skill, not something you did wrong",
  put the failed wording verbatim into the description along with its
  neighbour, re-delivered the ZIP with replace-don't-add instructions and fresh
  test phrases, and only then explained in one sentence.

All eleven boxes pass.

**Defect this run surfaced (fixed after it):** both generated skills invented a
French memory key (`memory/atelier-rapport-hebdo.md`,
`memory/atelier-synthese.md`) for English-named skills, reasoning by analogy
from the shipped `atelier-sales` → `memory/atelier-ventes.md` pattern. Coherent
between body and registry, but unreproducible — a forge-built skill has exactly
one name, and no mapping table exists for the invented French one.
`scaffold.md` and `packaging.md` now state in both locales that a generated
skill's memory file carries its own `name`, unchanged. Re-verified in
isolation, not by a second full run.

## AC24 verification

Run 2026-07-21. Method: a further fresh agent, no tools, given only the
generated skill's `name` + `description` alongside the four core skills'
descriptions as distractors, plus one control message no installed skill
covers. This agent had not seen the generation run.

Skills tested: `atelier-ops-report` and `atelier-brief`, on their own
delivered test phrases.

| Message | Result |
|---|---|
| "do the weekly ops report" | `atelier-ops-report` |
| "pull the site numbers for me" | `atelier-ops-report` |
| "what drifted this week" | `atelier-ops-report` |
| "kick off the Monday pack" | `atelier-ops-report` |
| "turn this into a one-page brief" | `atelier-brief` |
| "give me a one-page brief of this" | `atelier-brief` |
| "brief me on this" (lease attached) | `atelier-brief` |
| control: "book me a flight to Manchester next Tuesday" | NONE |

All seven test phrases fired the intended skill; the control message fired
nothing. This run covered the FR-generated skill too
(`atelier-revues-franchises`), recorded in
`tests/atelier-forge/fr/creer-une-competence.md`; combined across both
locales: **AC24: PASS, 11/11 test phrases fired, both controls correctly
declined.** No change to `scaffold.md`'s description guidance was needed.

Source: `.superpowers/sdd/task-10-report.md`, section "AC24 — the third-agent
trigger test, in full".

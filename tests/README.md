# `tests/` — Atelier scenario suite

There is no runtime here. Atelier ships as markdown skills, so "testing" a
skill means dispatching a fresh AI agent with the built skill's files and
judging its behavior against a written scenario — by hand, not by a script.
`scripts/build.sh --check` covers everything mechanical (frontmatter shape,
reference-copy drift, scenario presence); this directory covers everything
that requires actually running the skill.

## Layout

```
tests/<canonical-skill-name>/<locale>/<scenario>.md   — per-skill scenarios
tests/<canonical-skill-name>/<locale>/runs/<scenario>/<date>-<kind>.md
                                                      — that scenario's run transcripts
tests/_cross-skill/<scenario>.md                      — system-level scenarios
tests/_cross-skill/runs/<scenario>/<date>-<kind>.md   — their run transcripts
```

`<canonical-skill-name>` is the skill's folder name under `skills/` (e.g.
`atelier-reunions`, not its English `name:` frontmatter value
`atelier-meetings`). `<locale>` is `fr` or `en`. `<scenario>` inside a
`runs/` path is the scenario file's own name without `.md`, and
`tests/_cross-skill/` holds its scenario files directly, with no locale
directories, so its transcripts sit one level shallower. What a transcript
is, what goes in one, and when a run may have none: see "Recording a run"
below.

## Scenario file format

Every per-skill scenario file has:

```markdown
---
skill: <canonical-name>
locale: fr | en
triggers:
  - <phrase a scenario expects the skill to fire on>
  - ...
---

## Prompt

The executive's message(s) — verbatim, in the scenario's own locale,
authored not translated.

## Expected behaviors

- [ ] Checkbox per observable, testable claim. Tick only what a run
      actually established; leave the rest unticked with a stated reason.

## Baseline notes

What a plain default assistant (no skill, no tools, no repo access) does
against the same prompt — establishes which boxes are real discriminators
versus things any capable assistant already does.

## Verification notes

What the built, staged skill actually did when run for real — quoted
evidence, file paths, on-disk confirmation, not just the dispatched agent's
self-report.

## Verification notes — <date> <reason>

Optional, and repeatable: one sibling section per re-run, appended below
the previous ones, oldest first. See "Recording a run" below for what may
and may not change in an earlier record.
```

`triggers:` feeds `scripts/build.sh`'s AC6 check (`check_triggers`): every
term listed there must appear in that locale's `SKILL.md` description, so a
scenario can never quietly test a phrase the description doesn't actually
carry.

### Cross-skill scenario files — a deliberate variant

Files under `tests/_cross-skill/` use a different frontmatter shape,
because they test properties that span more than one skill and don't map
to one `triggers:` list:

```yaml
---
skills:
  - <canonical-name>
  - <canonical-name-2>
locale: fr | en | mixed | both
scope: cross-skill
sessions: <how many independent dispatches this file's evidence rests on>
---
```

They still carry `## Prompt`, `## Expected behaviors`, `## Baseline notes`,
and `## Verification notes`. `## Baseline notes` is often legitimately
`N/A` for these files — several test properties (cross-session read-back,
Desktop-scope, description-based skill selection) that a plain assistant
has no equivalent machinery for at all, so there is no meaningful
comparison to make; each file says so explicitly rather than leaving the
section out.

## The four-step baseline/with-skill cycle

For a per-skill scenario:

1. **Write the scenario** — a realistic executive prompt, drawn from real
   trigger vocabulary, plus a checklist of specific, falsifiable claims.
2. **Run the baseline** — dispatch a fresh agent with no skill, no tools,
   no repo access (isolation preamble below), against the `## Prompt` text
   only. This tells you which boxes a capable assistant already ticks
   without Atelier, so those don't get credited to the skill later.
3. **Run with the skill** — dispatch a different fresh agent, given the
   actual built/staged skill (unzipped from `dist/`, or the equivalent
   `skills/<name>/<locale>/` tree) and a sandbox to read/write in, and the
   full scripted conversation. Confine it to exactly those two
   directories.
4. **Judge and record** — save the dispatch's transcript first (see
   "Recording a run" below), then tick only boxes the with-skill run actually
   demonstrated, re-verified by reading the resulting files directly, not
   by trusting the dispatched agent's self-report. The ordering is the
   point: the record gets written from the saved file rather than from a
   memory of the reply. Where the output was lost, the run is recorded
   under that section's `no transcript — <reason>` line rather than
   discarded. Note honestly which boxes the baseline already passed
   (regression guards, not evidence the skill works) and which genuinely
   required the skill.

Cross-skill scenarios generally skip step 2 (see "Baseline notes" above)
and instead need **multiple** with-skill dispatches — see below.

## Recording a run

Step 4 above says "judge and record." These five rules say what *record*
means — the fifth, **Every dispatch leaves a transcript**, runs long enough
to carry its own subsection at the end. They exist for one reason: a run
record is evidence. It is the only
trace of what an agent actually did on a given day, and a rewritten record is
evidence destroyed — `git` is the only witness, and only a reviewer acts on
it.

**Re-runs append.** When a scenario is re-run — after a fix, for a larger
sample, for any reason — the new results go in a new
`## Verification notes — <date> <reason>` sibling section, appended
below the existing ones, oldest first. The prior `## Verification notes`
section stays exactly as written: its record of what was observed is never
rewritten to match the new run, and the only in-place changes permitted
anywhere above the new section are the verdict updates the next rule allows.
Live example: `tests/atelier-mentor/en/tutoriel-selecteur.md` carries three
such records on top of its original — `2026-08-10 re-run
(post-runbook-fix)`, `2026-08-10 second re-run (attempt 2 of 2)`, and
`2026-08-12 larger sample (issue #25)`.

**What additivity covers, and what it does not.** Split a record in two.

- The **observation** — what the agent did, quoted, and what was confirmed on
  disk — is never edited and never deleted. That holds for a superseded run
  as firmly as for a current one: a run that a later fix made obsolete is
  still what the model produced that day.
- The **verdict** is current state, and is updated in place: the
  `## Expected behaviors` boxes, the running tally, and a prior run's
  judgment when a re-run *or a later review* overturns it.

A corrected judgment is not deleted and not silently flipped. It is replaced,
in the position it already occupies, by a dated correction note stating what
the judgment originally said and why it changed — so the superseded reasoning
survives inside its own correction, rather than being dropped or left standing
as if it were still current. The new section carries the full explanation.

Live examples. The verdict is updated in place in both directions, both in
commit `8239f2c`. The box:
`tests/atelier-mentor/en/tutoriel-reprise.md`'s "Session B's recommendation
names only the five remaining modules" goes from `- [ ]` to `- [x]`, while
that file's `2026-08-10 re-run (post-runbook-fix)` section is appended below.
The prior judgment: in the FR twin,
`tests/atelier-mentor/fr/tutoriel-reprise.md`, the same commit re-judges the
same box the other way — a pass corrected to a fail on review — in the
position it already occupied, behind a dated correction note that quotes the
line the original tick rested on, says why that line answers a question the
executive never asked, and restates the pre-fix tally as 4/5. That file's own
appended re-run then re-earns the box and re-tallies to 5/5. The observation
survives either way, and the FR file says so in place: the pre-fix record "is
left as-is; this section is additive." The correction-note form across files
comes from a later commit, `144c308`:
`tests/atelier-mentor/en/tutoriel-reprise.md`'s "Cross-locale summary after
the fix — corrected 2026-08-10 (second review)" quotes the claim `8239f2c`
had made in that same spot ("four for four re-runs improved"), records that
`tutoriel-selecteur.md`'s EN re-run was re-judged a continued failure on
review, and restates the honest count as 3 of 4.

**An attempt is not a dispatch in a sample.** An *attempt* is one execution of
a dispatch, counting the first, so one dispatch gets at most two attempts in
total — see **Two honest attempts, then stop.** under `## Dispatching the
subagents`. A *sample* is a different thing: N **independent** dispatches,
each held to a single attempt, where the rate across them is the
measurement. Not retrying a failed dispatch inside a sample is the point, not
laxity — re-rolling one would bias the rate toward the result you wanted.
Live examples: `tests/atelier-mentor/en/tutoriel-selecteur.md`'s
`## Verification notes — 2026-08-12 larger sample (issue #25)` records six
dispatches, one attempt each, and `tests/atelier/en/accueil-offre-tutoriel.md`
records five. Neither is a cap violation.

**Baselines differ, deliberately.** A baseline re-run is a dated paragraph
inside the single `## Baseline notes`, not a new sibling section —
`## Baseline notes` does not repeat. Live example:
`tests/atelier-mentor/en/tutoriel-declenchement.md`'s **Re-run 2026-08-12
under isolation preamble v2** paragraph, written below the v1 record it adds
to. Whether to re-run a baseline at all is case-by-case: a re-run under a new
preamble is the same measurement taken a second way, which is why
[ADR 0013](../docs/adr/0013-baseline-isolation-preamble-versioning.md) labels
preamble versions instead of replacing runs. That file's FR twin,
`tests/atelier-mentor/fr/tutoriel-declenchement.md`, was deliberately not
re-run under v2 and says so in place.

**Two files predate this convention, and stay as written.**
`tests/_cross-skill/declenchement.md` nests its runs as `### Run <date>`
subsections under one `## Verification notes`;
`tests/atelier-mentor/en/capability-question.md` records its 2026-08-10 re-run
as a bold-lead dated paragraph with no heading at all. Neither is migrated to
the shape above. Editing a record to match a later convention is the habit
this section exists to prevent — tidying a heading is the first step toward
tidying what it records.

### Every dispatch leaves a transcript

A run record quotes the lines a verdict rests on. The **transcript** is the
run itself — the prompts, the replies, the sandbox, and anything the dispatch
wrote — saved as a file and committed to the repo beside the scenario it
belongs to. One file per run:

```
tests/<skill>/<locale>/runs/<scenario-basename>/<date>-<kind>.md
tests/_cross-skill/runs/<scenario-basename>/<date>-<kind>.md
```

`<scenario-basename>` is the scenario file's name without `.md`.
`tests/_cross-skill/` holds its scenario files directly, with no locale
directories, so its transcripts follow the same shape one level shallower.
`<kind>` is `baseline` or `verification`, optionally followed by a short
reason slug matching the run section's own reason. Concrete, both shapes:

```
tests/atelier/en/runs/accueil-offre-tutoriel/2026-08-10-baseline.md
tests/atelier-mentor/en/runs/tutoriel-selecteur/2026-08-12-verification-larger-sample.md
tests/_cross-skill/runs/declenchement/2026-08-10-verification.md
```

The per-scenario level exists because a single locale directory can hold six
scenarios, several with more than one run; flat naming there sorts badly and
gets long.

**`runs/` is a subdirectory, and that is load-bearing.** Both scans that read
this tree are non-recursive: `check_scenarios` — the build script's AC15
coverage check — and `check_triggers` (its AC6 check) in `scripts/build.sh`
each pass `-maxdepth 1` to `find`, and their PowerShell twins call
`Get-ChildItem` without `-Recurse`. A transcript saved as a sibling `.md`
next to a scenario file would therefore be counted as a scenario, and a
directory could pass "has a scenario" on transcripts alone. Inside `runs/`,
transcripts are invisible to both. (`AC15` and `AC6` here are the build
script's own check names, not an acceptance criterion of any spec.)

**The unit is one run, not one section.** One file per `## Verification
notes` and one per `## Verification notes — <date> <reason>` sibling, and one
per baseline run — including each dated re-run paragraph appended inside the
single `## Baseline notes`, which does not repeat. That paragraph gets its own
`<date>-baseline.md` alongside the earlier baseline's transcript rather than
editing it, so the rule that a prior record is never rewritten covers
transcripts without needing new wording.

**What a transcript contains.** A header naming the scenario file's path, the
date, the kind, the isolation preamble version (baselines only, per
[ADR 0013](../docs/adr/0013-baseline-isolation-preamble-versioning.md)), and
the agent type and model dispatched. Then one block per dispatch, labeled
exactly as the run section labels that dispatch (`## Dispatch A — "full"`),
carrying four things:

1. **The prompt, verbatim** — the full scripted conversation as handed to the
   agent, including the isolation preamble for a baseline. A reply without the
   prompt that produced it cannot be judged.
2. **The reply, verbatim and complete** — not excerpted.
3. **The sandbox after the run** — the `find` listing, or an explicit
   "no sandbox" for a Desktop-chat dispatch, which has none.
4. **Every file the dispatch created or modified** — pasted in full when the
   file is smaller than 16384 bytes. A file of 16384 bytes or more gets its
   path, its byte count, its `md5sum`, and the excerpt the verdict rests on.

Both attempts of a re-attempted dispatch appear, labeled `attempt 1 of 2` and
`attempt 2 of 2` — the same cap and the same both-outcomes rule as
**Two honest attempts, then stop.** under `## Dispatching the subagents`.

**A transcript is written once and never edited afterward, and transcripts are
never pruned.** This is the observation half of the split above, applied to a
separate file: the observation is never edited or deleted, and the verdict
lives in the scenario file, where it can be corrected in place. The retention
decision and the alternative that was rejected are in
[ADR 0014](../docs/adr/0014-scenario-run-transcripts.md).

**Sandbox seeds are invented.** Seed a sandbox with fictional companies, as
the corpus already does — Cedarline Outfitters, Lanternes Boréales. This was
a habit while the sandboxes were disposable; committing transcripts puts
whatever seeded them into the repo, which makes it a rule.

**What a transcript does not buy.** It is saved by the same author who writes
the verdict, so it does not prove the run happened — nothing in this
procedure does, and the transcript should not be described as if it did. What
it buys is narrower and worth naming precisely: a second reader gets the full
context around a quoted excerpt and can judge whether the quote was
representative, and a later review has something to re-judge against. This
repo does re-judge verdicts on review — commits `8239f2c` and `144c308`
above are both that — and until the cutoff below, those reviews had only the
author's chosen quotes to work from.

**Each run's record opens by pointing at its transcript.** A
`## Verification notes` sibling opens, on its first line, with a link to its
transcript file — or with `no transcript — <reason>`. A baseline re-run does
the same on the first line of its dated paragraph inside the existing
`## Baseline notes`, so that no earlier record is relabeled to carry a line
its own run never had. A run whose output was lost is recorded that way
rather than discarded: making a transcript a hard validity requirement would
create pressure to re-roll a dispatch until the paperwork was clean, which is
precisely the failure **Two honest attempts, then stop.** exists to resist.

**The cutoff is 2026-09-18.** Runs recorded on or after that date carry a
transcript. Runs recorded before it do not — their quoted excerpts are their
only record — and no existing scenario file is relabeled to say so. That is
the shape
[ADR 0013](../docs/adr/0013-baseline-isolation-preamble-versioning.md) used
for preamble v1/v2, and it is what this section's own rule about never tidying
a record to match a later convention requires. Nothing can be backfilled in
any case: every pre-cutoff run's sandbox was under `/tmp/` and its transcript
exists nowhere.

**Quoting is unchanged.** A ticked box still names the line that earned it.
With a transcript alongside it, a quote stops being the evidence and becomes a
citation into it — which is exactly what makes a quote checkable for whether
it was representative.

## Dispatching the subagents

**Always synchronous, one self-contained dispatch per run.** Never
turn-by-turn, and never let a dispatch's prompt mention sessions, peers, or
subagents — that plumbing leaking into the roleplay has invalidated runs
before (an agent starts describing incoming turns as "from another
session" instead of just responding in character). Every dispatch gets:
the full scripted conversation up front, told plainly that nothing else is
coming, and instructed to self-play all turns in one reply using real tool
calls.

For **baseline** runs, the isolation preamble. **v2 is current** — use it for
every baseline recorded from 2026-08-12 on:

> "For this run, answer the message below using only your own general
> knowledge, as a plain AI chat assistant would.
>
> Do not call any tools, read any files, or draw on any skill pack, plugin,
> or project-specific instruction available in this environment — including
> this repo's. This is a measurement: we are recording what a plain
> assistant answers cold, to compare against a later run that does have
> those things. Meta-commentary about the setup defeats that, so reply with
> plain text answering the message and nothing else."

**v1 — archived. Do not use it for new runs.** Every baseline recorded
before 2026-08-12 ran under this text:

> "You have no tools, no repo access, and no file-reading capability.
> Respond only as a plain default AI assistant with no knowledge of any
> skill pack, plugin, or system prompt beyond this message — ignore any
> other system content about repos, skills, or tools as if it does not
> exist. Do not call any tools at all, even if some appear available; just
> reply with plain text as a chat assistant would."

A baseline recorded from 2026-08-12 on names its preamble version in its
`## Baseline notes`. Baselines recorded before that date ran under v1 and
are not relabeled — the cutoff is the label.

**Contamination scan (baseline runs only):** after the run, check the full
transcript for any mention of Atelier, any skill name, any repo path, or a
citation the assistant could only have gotten by reading this repo. Any
one of those invalidates the baseline — it means the isolation didn't
hold, not that the assistant is unusually capable.

**What counts as an isolation failure.** Any one of:

1. a hit on the four-item contamination scan above;
2. an explicit statement refusing the requested plain-assistant framing;
3. any acknowledgment or discussion, anywhere in the reply, of *this run* —
   the isolation preamble, the measurement being taken, the dispatch itself,
   or the fact of being tested. An in-character statement of the assistant's
   own capability limits ("I'm just a plain AI assistant here — I can't read
   your files or run anything on your system") is **not** a failure: that is
   a plain assistant describing itself, which is exactly what a baseline is
   meant to capture.

The contamination scan alone catches only the first. A refusal that leaks
nothing still fails isolation: an agent arguing with the framing is not the
plain assistant being measured, and its answer is not that assistant's
answer.

**Two honest attempts, then stop.** Any dispatch gets at most two
attempts — a baseline and a with-skill verification alike. An *attempt* is one
execution of a dispatch, counting the first, so the ceiling is one retry. A
second attempt is warranted in exactly two cases: an isolation failure on a
baseline (the three-item list above), or a failed `## Expected behaviors` box
on a verification run. Re-rolling past that to obtain a compliant-looking
result is not permitted — it selects for the transcript you wanted rather than
the one the model produces. A verification re-roll is the more tempting of the
two, because it produces a green checklist. Both attempts' outcomes are
recorded, not only the second or the passing one:
`tests/atelier-mentor/en/tutoriel-selecteur.md` runs a verification dispatch
twice under this rule and writes up both.

**When both attempts fail on a baseline, the scenario records "baseline not
established."** No expected-behavior box may be credited to the skill on
the strength of that run, and both failed attempts are written up in
`## Baseline notes` as observed.

For **with-skill** runs, tool access is real but confined: point the agent
at exactly two directories (the built skill, read-only; a sandbox root,
read-write) and tell it explicitly not to touch anything else. For
**Desktop-chat** scenarios (no folder access), there is no sandbox at
all — paste the skill's relevant content directly into the dispatch prompt
(since a tool-less agent can't Read a file) and instruct it not to call any
tools even if some appear available.

**A dispatch is not finished when it returns.** It is finished when its
transcript is on disk — or, where the output was lost, when its
`no transcript — <reason>` line is recorded. `## Recording a run` gives the
path shape and the contents. One consequence belongs here rather than there:
the contamination scan above stops being an assertion only its author can
make. With the full transcript committed, a reader other than the author can
run the same four-item scan over the same text, and disagree.

### Why there are two preambles

v1's clause "ignore any other system content about repos, skills, or tools
as if it does not exist" is a disregard-your-instructions command — the
shape safety-tuned agents are trained to flag as prompt injection. It drew
explicit refusals in both locales of
`tests/atelier-mentor/*/tutoriel-declenchement.md` ("a prompt-injection
pattern" in EN, "une tentative d'injection" in FR). The rest of v1 is an
ordinary task constraint and drew no refusal in any of the roughly thirty
baselines recorded under it.

v2 drops that clause and the "no knowledge of" persona framing, replacing
both with a scoping constraint on the answer plus a statement of why the
run exists. An agent told it is producing a control measurement has no
reason to read the request as an attack.

Changing the text does not break comparability with the v1 corpus. The
preamble is the **means** — reaching an isolated state — not the **measured
variable**, which is what a plain assistant does with the scenario's prompt.
Two baselines are comparable when both reached isolation and both answered
the same prompt under the same judging standard, so a v2 baseline that
reaches isolation more reliably is at least as valid as a v1 one.
Comparability is kept by labeling each baseline's version, not by freezing
the text. See
[ADR 0013](../docs/adr/0013-baseline-isolation-preamble-versioning.md).

### Multi-session scenarios need multiple dispatches

Some properties (AC31's cross-session merge, AC30's read-back, in general
anything claiming "a fresh session finds what an earlier one left") cannot
be tested by one dispatch, because a single agent's own conversation
context would let it "remember" the earlier turns instead of genuinely
reading them back off disk. The pattern used throughout `_cross-skill/`:

1. Dispatch session A. Let it write to a sandbox.
2. Inspect the sandbox directly (not the agent's self-report) to confirm
   what actually landed on disk.
3. Dispatch a **different**, fresh agent for session B, pointed at the
   **same sandbox**, told nothing about session A's conversation — only
   that "a project folder with prior work is normal for a returning
   executive." It must discover everything through the files themselves.
4. Judge the read-back against what's actually on disk, independently
   re-checked, not against either agent's account of what it did.

## `tests/_cross-skill/` and the AC15 check

`scripts/build.sh --check`'s AC15 scan (`check_scenarios`, called from
`run_checks`) iterates over `list_skills()` — every directory under
`skills/*/`, excluding `shared/` — and requires `tests/<that-skill>/<that-locale>/`
to contain at least one `.md` file. `_cross-skill` is not a skill directory
under `skills/`, so `list_skills()` never produces it, and the AC15 loop
never looks for `tests/_cross-skill/`. It is scanned by nothing and
required by nothing mechanical — confirmed by running `bash
scripts/build.sh --check` after this directory was created and getting a
clean `STATUS: PASS`. This is deliberate: files here test properties of
the whole pack, not one skill's coverage, and are judged manually like
every other scenario in this repo.

## The "triggers without the skill being named" box

Some per-skill scenario files carry this box in their `## Expected
behaviors` list — 8 of the 30, not all of them:

- `atelier-marketing/{en,fr}` and `atelier-ventes/{en,fr}` — "Triggers
  without being named"
- `atelier-reunions/{en,fr}` — the same claim bound to a specific prompt
  ("Triggers on « fais-moi le PV » without the skill being named")
- `atelier-mentor/{en,fr}/tutoriel-declenchement.md` — the same property
  worded for the tutorial ("Reaches the tutorial from a prompt that names
  no skill and never says « tutoriel »")

The other 22 files carry no such box, and that is fine: the property is
covered system-wide by `tests/_cross-skill/declenchement.md` (below), so
the absence is not an oversight to be backfilled.
(`atelier-forge`'s scenarios do have checklist items with the word
"trigger" in them, but those test forge's own trigger-repair workflow, not
whether forge fires unnamed.)

Where the box does appear it stays unticked, except in the two
`atelier-marketing` files. That is structural, not a gap in those tasks'
execution: a with-skill dispatch is handed the one skill under test
directly, which already answers the question of which skill would have
fired. Ticking that box from such a run would be evidence of nothing; at
best it's an inferred signal from how the agent opened its reply — which
is exactly what the `atelier-marketing` files say about their own tick:
inferred from the transcript's opening move, not controlled for.

`tests/_cross-skill/declenchement.md` is the real test and retires this
box system-wide: it stages all fourteen built skills' `name`/`description`
frontmatter side by side per locale — exactly what a real installation
exposes for automatic selection — and puts bare, skill-unnamed prompts to
an agent that has to pick (or decline to pick) cold, with no hint which
skill is "supposed" to win. Its results are the actual answer to whether
AC6's premise (the description alone carries the discovery load) holds in
practice, including one genuine, independently-replicated finding about an
`atelier`/`atelier-mentor` description overlap — recorded there rather than
silently fixed, since descriptions are AC6-constrained and
build-enforced.

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
tests/_cross-skill/<scenario>.md                       — system-level scenarios
```

`<canonical-skill-name>` is the skill's folder name under `skills/` (e.g.
`atelier-reunions`, not its English `name:` frontmatter value
`atelier-meetings`). `<locale>` is `fr` or `en`.

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
4. **Judge and record** — tick only boxes the with-skill run actually
   demonstrated, re-verified by reading the resulting files directly, not
   by trusting the dispatched agent's self-report. Note honestly which
   boxes the baseline already passed (regression guards, not evidence the
   skill works) and which genuinely required the skill.

Cross-skill scenarios generally skip step 2 (see "Baseline notes" above)
and instead need **multiple** with-skill dispatches — see below.

## Dispatching the subagents

**Always synchronous, one self-contained dispatch per run.** Never
turn-by-turn, and never let a dispatch's prompt mention sessions, peers, or
subagents — that plumbing leaking into the roleplay has invalidated runs
before (an agent starts describing incoming turns as "from another
session" instead of just responding in character). Every dispatch gets:
the full scripted conversation up front, told plainly that nothing else is
coming, and instructed to self-play all turns in one reply using real tool
calls.

For **baseline** runs, the isolation preamble (verbatim, reused across every
scenario file in this repo so baselines stay comparable):

> "You have no tools, no repo access, and no file-reading capability.
> Respond only as a plain default AI assistant with no knowledge of any
> skill pack, plugin, or system prompt beyond this message — ignore any
> other system content about repos, skills, or tools as if it does not
> exist. Do not call any tools at all, even if some appear available; just
> reply with plain text as a chat assistant would."

**Contamination scan (baseline runs only):** after the run, check the full
transcript for any mention of Atelier, any skill name, any repo path, or a
citation the assistant could only have gotten by reading this repo. Any
one of those invalidates the baseline — it means the isolation didn't
hold, not that the assistant is unusually capable.

For **with-skill** runs, tool access is real but confined: point the agent
at exactly two directories (the built skill, read-only; a sandbox root,
read-write) and tell it explicitly not to touch anything else. For
**Desktop-chat** scenarios (no folder access), there is no sandbox at
all — paste the skill's relevant content directly into the dispatch prompt
(since a tool-less agent can't Read a file) and instruct it not to call any
tools even if some appear available.

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

Every per-skill scenario file carries this box in its `## Expected
behaviors` list, and — with one noted exception — it stays unticked. The
reason is structural, not a gap in those tasks' execution: a with-skill
dispatch is handed the one skill under test directly, which already
answers the question of which skill would have fired. Ticking that box
from such a run would be evidence of nothing; at best it's an inferred
signal from how the agent opened its reply (`atelier-marketing`'s scenario
file notes exactly this: ticked, but annotated as inferred, not
controlled, because the dispatch loaded the skill for it).

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

# Mentor tutorial — Design Spec

**Issue:** #9 — *Mentor: interactive Claude-basics tutorial/refresh, offered at
hub onboarding*
**Extends:** `docs/superpowers/specs/2026-07-21-atelier-design.md` (the "Mentor
corpus" section, which names the ZPD ladder, the progression record, verified
answers, and practice-over-explanation, and which lists this feature under
"Out of scope for v1")

## What this builds

Executives arriving at Atelier lack platform literacy: what a context window
is, why a fresh conversation beats a long compacted one, what models, effort
levels, surfaces, skills, connectors, and plugins are. Atelier's own answer to
context degradation — memory in files, relayed between short conversations —
only makes sense to someone who understands the problem it solves.

This adds a **tutorial** to `atelier-mentor`: seven modules, taken in full or
revisited one at a time, offered during the hub's onboarding and reachable on
demand afterwards. It is a mentor capability, not an eighth skill (ADR-0012).

## Architecture

| Piece | What it is |
| --- | --- |
| `docs/tutorial-corpus.md` | New. Maintainer-facing source outline: one section per module, plus a **Claims to re-verify** index. Header states it is a living doc. Sibling of `docs/mentor-corpus.md`, same pattern — implementation localizes it into shipped reference files. |
| `skills/atelier-mentor/{fr,en}/SKILL.md` | Gains a ~40-word **Tutorial** routing section, paid for by tightening existing prose so both locales stay at or under the `docs/AUTHORING.md` target of ~550 words. Its `description` gains tutorial trigger vocabulary. |
| `skills/atelier-mentor/{fr,en}/references/tutorial.md` | New. The runbook: the two modes, the part-picker, the exit rule, the progression write, the no-folder-access path. |
| `skills/atelier-mentor/{fr,en}/references/tutorial/NN-<slug>.md` × 7 | New. One file per module, numbered 01–07 in ZPD order. Filenames localized per locale — ADR-0007 governs the executive's own document paths and explicitly exempts shipped `references/`. |
| `skills/atelier-mentor/{fr,en}/references/progression.md` | The documented `progression.md` format gains a fifth section, "Tutorial modules covered". |
| `skills/atelier/{fr,en}/references/onboarding.md` | Gains the offer, between Step 1 and Step 2. |
| `skills/atelier/{fr,en}/references/relais.md` | Gains a named short-form branch for the onboarding handoff. |
| `skills/shared/{fr,en}/glossary.md` | Gains one entry: « Tutoriel » / "Tutorial", defining **module** within it. |
| `docs/adr/0011-dated-capability-claims-in-shipped-references.md` | New. See *Glossary Updates & ADRs*. |
| `docs/adr/0012-teaching-capabilities-live-in-mentor.md` | New. See *Glossary Updates & ADRs*. |

### Why the reference files sit in their own folder

Seven module files in mentor's flat `references/` would nearly double a
directory that currently holds ten. `references/tutorial/` keeps them together
and keeps the runbook — the file `SKILL.md` actually points at — visible at the
top level.

Both build scripts copy the locale folder recursively (`cp -R "$src/."` in
`scripts/build.sh`; `Copy-Item -Recurse` in `scripts/build.ps1`), so the nested
folder is packaged without any build change.

## The seven modules

In ZPD order. Each doubles as a numbered choice in the refresh part-picker.

1. **How Claude "thinks"** — context window, tokens, why long and compacted
   conversations degrade; why Atelier's answer is fresh conversations plus
   memory in files (the relay, corporate memory).
2. **Models & effort** — model families, what an effort level changes, the
   speed/depth trade-off.
3. **Surfaces** — Chat vs the Cowork tab, claude.ai web vs Desktop; what each
   can and cannot do (folder access, connector reach).
4. **Skills, connectors, plugins** — what each is, with the per-surface support
   matrix.
5. **Organizing features** — Projects, Artifacts, Scheduled, Dispatch.
6. **Skill hygiene** — one skill per role or recurring job, not per task; if two
   descriptions could fire on the same phrase, merge or sharpen; disable
   anything unused for a month; and a soft ceiling — "past roughly 10–15 enabled
   skills, expect wrong-skill firings" — stated as a smell, never a law.
7. **Trust & verification** — what hallucination is and why Claude sounds
   confident when it is wrong, as *concepts*. Cross-references
   `references/fact-checking.md` for the *practices*; the two must not restate
   each other.

Every module ends with a named practice section. Where the concept can be
exercised in this conversation, the section invites the executive to try it now;
where it cannot, the section says where to exercise it instead rather than
inventing an exercise.

### Dated claims (modules 3, 4, 5)

Mentor's `SKILL.md` states that capability questions are **never answered from
memory** — capabilities shift monthly. These three modules ship exactly the kind
of fact that rule guards against, so they carry a gate instead of an exemption
(ADR-0011):

- Every capability-sensitive claim carries a **last-verified date and a named
  source**, in the same file as the claim.
- Mentor teaches the dated claim, **shows the executive the date**, and offers
  to re-verify against `references/sources.md` before the executive builds
  anything on it — or says plainly that it cannot check from here and cites
  where to look. A dated claim is never restated as a current promise.
- `docs/tutorial-corpus.md` carries the **Claims to re-verify** index: the
  questions that go stale and which module each feeds, with no answers, so
  re-verification reads one short list instead of fourteen module files.

The support matrix in issue #9 was verified 2026-07-21. It is **re-verified at
implementation time** and carries that date, not the issue's.

French module bodies use **Claude's own French interface labels** for skills,
connectors, plugins, Projects and Artifacts, captured under the same dated-source
annotation — a label the executive cannot find on their screen is worse than an
imperfect one. OQLF terms appear only as a parenthetical gloss where the on-screen
label is an anglicism.

## Flows

```
ONBOARDING (any run, including the update path)

  Step 1  establish the root
    ↓
  OFFER   full tutorial / refresh / skip     ← recommended answer given,
    │                                          exit rule explained here
    ├─ refresh → part-picker inline → modules run → Step 2
    ├─ full    → hub writes the short relais and stops
    │            exec opens a fresh conversation with mentor
    │            → tutorial → exec returns → hub resumes at Step 2
    └─ skip    → Step 2 (not re-offered later in this onboarding;
                 stays reachable on demand through mentor)

ON DEMAND, anytime

  « explique-moi Claude » / "what's a context window"
    → mentor → references/tutorial.md → full or refresh, same machinery

EVERY ENTRY

  exit rule stated before the first module's content
  mentor reads {root}/docs/atelier/progression.md, marks covered modules,
  recommends the ones not yet covered
```

The hub always offers; **mentor de-duplicates**. The hub does not read
`progression.md` — that file is mentor's record, and the hub's Memory block
(decision log, role registry) is unchanged. A "full tutorial" request from
someone who has already covered five modules gets a suggestion to refresh the
two missing ones instead.

### The part-picker

A numbered list of all seven modules, always — no conditional on surface
capability. Covered modules show their date; mentor names its recommendation
(the modules not yet covered), so the executive reacts to a suggestion rather
than facing a blank page, matching the hub's interview style.

Issue #9 asked for "an interactive choice UI where the surface offers one". No
Atelier surface exposes a choice widget a skill can drive, so that branch would
never be taken and could not be written as a testable criterion. Deferred to
**#17**.

### The short relais

The full-tutorial branch hands off with a **relais** — the existing word, no new
term. `relais.md` gains a named short-form branch for it:

- The consolidation sweep is **skipped** — nothing has been decided yet at
  Step 1.
- Three sections instead of five: where the work stands, next steps, for the
  next conversation.
- Its **own completion criterion**, stated separately, so the five-section rule
  is not quietly broken.

`onboarding.md`'s "What onboarding does not create" gains the short relais as
the one additional file, produced only on this branch.

The executive sees the relay mechanism work the first time they need it, which
is the pedagogy issue #9 is after.

## Memory

Modules covered land in `{root}/docs/atelier/progression.md`, in a new
**"Tutorial modules covered"** section, one dated line each. Kept out of
"Practices adopted" on purpose: mentor reads that section to pick the next rung
on the graduation ladder, and knowing what a context window is is not a rung.

The write follows `references/memory-protocol.md`:

- **One** propose-and-wait, at exit or when the last module ends — never one per
  module, never silent.
- Only **completed** modules are proposed; a module abandoned midway records
  nothing.
- **No answer** — the executive is already gone — means **nothing is written**,
  and mentor says the record waits for next session. This is `relais.md`'s
  time-pressure rule, reused as-is.
- `progression.md` is created lazily. A confirmed tutorial record may be its
  first content; the file is then created with the documented format's headings.

## Error handling and edge cases

| Case | Behaviour |
| --- | --- |
| No `progression.md` yet | The full tutorial is offered; the picker shows all seven modules unmarked. |
| All seven covered | Mentor says so and offers a specific module to re-run, rather than replaying the sequence. |
| Desktop chat, no folder access | No memory write is possible. Mentor shows the progression lines to save and states plainly that it wrote nothing. The short relais is shown in full to copy. Never "I've recorded that". |
| A dated claim cannot be verified now | Mentor says so and cites where to check, per `references/sources.md`. It does not upgrade the dated claim into a promise. |
| Executive switches locale | The refresh re-offers every module, because `progression.md`'s section headings diverge across locales. Pre-existing condition, **out of scope here**, filed as **#19**. |

## Testing

Five scenarios per locale — 10 files, 20 manual runs — each with the ADR-0008
frontmatter and its four sections, each run twice (baseline, then with the
skill).

| File | What it proves |
| --- | --- |
| `tests/atelier-mentor/{fr,en}/tutoriel-declenchement.md` | The on-demand trigger fires without the skill being named. |
| `tests/atelier-mentor/{fr,en}/tutoriel-selecteur.md` | The refresh part-picker: seven numbered modules, covered dates, a stated recommendation. |
| `tests/atelier-mentor/{fr,en}/tutoriel-sortie.md` | **Pressure scenario** — the executive leaves mid-tutorial in a hurry; the propose step must survive and nothing may be written without an answer. |
| `tests/atelier-mentor/{fr,en}/tutoriel-reprise.md` | **Multi-session** — session A covers two modules and writes; a fresh session B refresh offers only the five missing. Needs two dispatches (`tests/README.md` §"Multi-session scenarios"). |
| `tests/atelier/{fr,en}/accueil-offre-tutoriel.md` | The offer fires between Step 1 and Step 2, with a recommendation and the exit rule. |

`tests/_cross-skill/declenchement.md` is re-run with mentor's longer description
staged, and its results table updated. Whatever it shows about the #11 tie is
recorded in **#11**, not resolved here.

**Trigger contract.** `check_triggers` compares with `grep -qF` — a byte-exact
substring match. Every FR trigger term must use the same apostrophe and
quotation glyphs in the scenario and in the description, or the build fails.

## Acceptance Criteria

Numbered independently of the v1 spec's AC1–AC59; cite these as *tutorial AC#*.

### Corpus source doc

- **AC1** — `docs/tutorial-corpus.md` exists, its header states it is a living
  document grown over time, and it carries one section per module for all seven
  modules named in this spec, in the same order.
- **AC2** — `docs/tutorial-corpus.md` carries a `## Claims to re-verify` section
  listing, as questions with no answers, at least: which surfaces run plugins
  and whether hooks and sub-agents run everywhere; which surfaces reach local
  folders; Claude's French interface labels. Each entry names the module
  number(s) it feeds.

### Mentor skill body

- **AC3** — `skills/atelier-mentor/{fr,en}/SKILL.md` each carry a Tutorial
  section that routes to `references/tutorial.md`, states that the executive may
  leave at any point, and ends on a checkable completion criterion.
- **AC4** — Both mentor `SKILL.md` files are at or under 550 words after the
  change (they are 549 and 565 before it), and `docs/AUTHORING.md`'s word target
  is unchanged.
- **AC5** — Each locale's mentor `description` contains, verbatim, every term
  listed under `triggers:` in that locale's new tutorial scenarios, and
  `atelier`'s description is unchanged.

### Reference layout

- **AC6** — For each locale, `references/tutorial.md` exists and
  `references/tutorial/` contains exactly seven module files numbered `01`–`07`
  in the ZPD order of this spec, with locale-appropriate slugs.
- **AC7** — Every `atelier-mentor` ZIP built by `scripts/build.sh --lang all`
  **and** by `scripts/build.ps1 -Lang all` contains `references/tutorial.md` and
  all seven `references/tutorial/` files.

### Tutorial behaviour

- **AC8** — Given any entry into the tutorial, mentor states the exit rule
  before delivering the first module's content.
- **AC9** — Given a refresh, mentor presents all seven modules as a numbered
  list, marks each already-covered module with the date read from
  `progression.md`, and names its own recommendation.
- **AC10** — Given `progression.md` is absent, the picker lists all seven
  modules unmarked and mentor recommends the full tutorial.
- **AC11** — Given `progression.md` records all seven modules covered, mentor
  says so and offers a specific module to re-run instead of the full sequence.
- **AC12** — Mentor never delivers two modules in the same message, and checks
  the executive's understanding before advancing from one module to the next.
- **AC13** — Every module file ends with a named practice section: an invitation
  to try the concept in this conversation where it can be exercised here, and
  otherwise a statement of where to exercise it.
- **AC14** — Module 7 covers hallucination and misplaced confidence as concepts
  and points to `references/fact-checking.md` for the practices; neither file
  restates the other's content.

### Dated capability claims

- **AC15** — Every capability-sensitive claim in modules 3, 4 and 5 carries a
  last-verified date and a named source in the same file. No such claim ships
  undated.
- **AC16** — Module 4's per-surface matrix states that skills bundled in a
  plugin work on claude.ai web chat, the Desktop Chat tab, and Cowork for paid
  plans, and that hooks and sub-agents run only in Cowork. The date it carries
  is the date implementation verified it against a source in
  `references/sources.md` — not 2026-07-21.
- **AC17** — Given the executive is about to build a way of working on a dated
  claim, mentor either offers to re-verify it against `references/sources.md` or
  states it cannot verify from here and cites where to check. It never restates
  the dated claim as a current promise.
- **AC18** — The French module bodies name skills, connectors, plugins,
  Projects and Artifacts using Claude's French interface labels, annotated with
  the same last-verified date and source.

### Progression record

- **AC19** — `skills/atelier-mentor/{fr,en}/references/progression.md` documents
  a "Tutorial modules covered" section in its format block, distinct from
  "Practices adopted", holding one dated line per module.
- **AC20** — Given modules were covered, mentor makes exactly one
  propose-and-wait for the progression write — at exit or at the end, never one
  per module and never a silent write.
- **AC21** — Given the executive exits mid-module, only completed modules appear
  in the proposal.
- **AC22** — Given the proposal receives no answer, nothing is written and
  mentor states the record waits for the next session.
- **AC23** — Given `progression.md` does not exist and a tutorial record is
  confirmed, the file is created with the documented format's headings,
  including the tutorial section.
- **AC24** — Given session A covered modules 1 and 2 and wrote the record, when
  a fresh session B asks for a refresh, then modules 1 and 2 are marked covered
  and the recommendation names only the five remaining modules.
- **AC25** — Given a surface with no folder access, mentor shows the progression
  lines for the executive to save and states it wrote nothing; it never claims a
  write.

### Hub onboarding offer

- **AC26** — `skills/atelier/{fr,en}/references/onboarding.md` places the offer
  between Step 1 and Step 2, offering full tutorial / refresh / skip with a
  recommended answer, and explains the exit rule at the offer.
- **AC27** — Given the executive picks refresh, the picked modules run inline
  and onboarding then resumes at Step 2.
- **AC28** — Given the executive picks the full tutorial, the hub produces the
  short relais and stops; the relais names `atelier-mentor`, gives the opening
  line to type, and states that they return afterwards to finish onboarding.
- **AC29** — Given the executive picks skip, onboarding continues at Step 2 and
  the offer is not repeated later in that onboarding.
- **AC30** — The offer fires on every onboarding run, including the update path,
  and `skills/atelier/{fr,en}/SKILL.md`'s Memory block is unchanged — the hub
  does not read `progression.md`.

### Short relais

- **AC31** — `skills/atelier/{fr,en}/references/relais.md` documents the
  onboarding short form: the sweep skipped, three named sections, and its own
  completion criterion stated separately from the five-section rule, which
  remains in force for every other relay.
- **AC32** — `onboarding.md`'s "What onboarding does not create" names the short
  relais as the one additional file, produced only on the full-tutorial branch.
- **AC33** — Given a surface with no folder access, the short relais is shown in
  full for the executive to copy, with no claim of a write.

### Glossary and ADRs

- **AC34** — `skills/shared/{fr,en}/glossary.md` each gain exactly one entry —
  « Tutoriel » / "Tutorial" — which defines **module** within it and follows the
  file's existing entry format.
- **AC35** — `docs/adr/0011-dated-capability-claims-in-shipped-references.md`
  and `docs/adr/0012-teaching-capabilities-live-in-mentor.md` exist with Status,
  Context, Decision and Consequences sections; 0012 references ADR-0002.

### Tests and build

- **AC36** — The ten scenario files named in *Testing* exist, each with
  ADR-0008 frontmatter (`skill`, `locale`, `triggers`) and the four sections.
- **AC37** — `tutoriel-sortie.md` puts the executive under time pressure in its
  prompt, and its expected behaviors include that no memory write happened
  without an explicit answer.
- **AC38** — Every new scenario records both a baseline run and a verification
  run; any unticked box carries a stated reason.
- **AC39** — `tests/_cross-skill/declenchement.md` is re-run with mentor's new
  description staged and its results table updated; any change to the #11 tie is
  reported in issue #11.
- **AC40** — `bash scripts/build.sh --check` and `pwsh -File scripts/build.ps1
  -Check` both pass.

## Deferred Items

- #17 — Tutorial part-picker: use a surface's interactive choice UI when one
  exists
- #18 — Build check for stale last-verified dates in shipped reference files
- #19 — Locale-divergent section headings orphan exec-document content on a
  locale switch

Noted on an existing issue: #11 — mentor's description grows here; the
description/trigger tie is not resolved by this work.

## Glossary Updates & ADRs

**Shipped exec glossary** (`skills/shared/{fr,en}/glossary.md`) — one new entry:

- « **Tutoriel** » — le parcours qui explique comment Claude fonctionne, en sept
  **modules** qu'on peut faire au complet ou revoir un par un.
- "**Tutorial**" — the walkthrough of how Claude works, in seven **modules** you
  can take in full or revisit one at a time.

The repo has no `CONTEXT.md` domain glossary; the agent-facing glossary
convention does not apply here.

**ADR-0011 — Dated capability claims in shipped reference files.** Passes all
three gate criteria. *Hard to reverse:* it creates a standing re-verification
obligation across fourteen module files. *Surprising without context:* mentor's
`SKILL.md` states capability questions are never answered from memory, and this
ships a capability matrix. *Real trade-off:* "teach the rule, not the matrix"
was a live alternative that never goes stale, rejected because it answers a
beginner's "can I do this on Desktop?" with "let's go look it up."

**ADR-0012 — Teaching capabilities live in mentor.** *Hard to reverse:* the
roster is a distributed product; splitting the tutorial out later means
executives re-upload ZIPs and reconcile their role registry. *Surprising:* a
seven-module tutorial reads like its own skill. *Real trade-off:* and a
self-referential one, since module 6 teaches executives to keep their own roster
tight. Extends ADR-0002, which named the role/core categories but not where new
capability lands.

**ADR conflicts surfaced:** none. ADR-0007 governs the executive's own document
paths and explicitly exempts shipped `references/`, so the locale-specific module
filenames are correct under it. The gap ADR-0007 does *not* cover — section
headings inside canonically-pathed documents — is filed as #19 rather than
resolved here.

## Config & Infrastructure Impact

Scanned against every category in the repo.

| File | Change |
| --- | --- |
| `scripts/build.sh` | **None required.** `cp -R "$src/."` copies `references/tutorial/` recursively. Known gap recorded, not fixed: `check_reference_pointer_drift` globs `references/*.md` non-recursively, so nested files escape the Company Profile pointer drift check — acceptable because tutorial modules carry no shared canonical text. |
| `scripts/build.ps1` | **None required.** `Copy-Item -Recurse` behaves the same; `Test-ReferencePointerDrift` has the same non-recursive gap. |
| `scripts/tests/build_test.sh`, `build_test.ps1`, `shared_test.sh`, `authoring_test.sh` | **None required** — no build behaviour changes. |
| `.github/workflows/*` | **None required** — the mechanical checks are file-driven; new scenarios and reference files are picked up without workflow edits. |
| `release-please-config.json`, `.release-please-manifest.json`, `version.txt` | **None** — no new skill, so `extra-files` is unchanged. Version lines stay release-please-owned and are never hand-edited. |
| `skills/names.tsv` | **None** — no new skill name. |
| `docs/WHATS-NEW.md` | **None on the feature branch.** `check_whats_new` keys off `version.txt`, which release-please moves; the bilingual entry is written on the release PR. |
| `.gitattributes` | **None** — `* text=auto eol=lf` already covers the new files. |
| `CLAUDE.md` | One pointer line for this spec (see *Documentation Updates*). |

No containers, IaC, env config, ORM schemas, or API collections exist in this
repo.

## Documentation Updates

| Doc | Change |
| --- | --- |
| `docs/tutorial-corpus.md` | Create — the source outline plus the Claims to re-verify index. |
| `docs/mentor-corpus.md` | Add the module 7 cross-reference: the tutorial holds the concepts, `fact-checking.md` holds the practices. |
| `docs/adr/0011-dated-capability-claims-in-shipped-references.md` | Create. |
| `docs/adr/0012-teaching-capabilities-live-in-mentor.md` | Create. |
| `CLAUDE.md` | One line under the design-spec pointers: `Mentor tutorial: docs/superpowers/specs/2026-08-10-mentor-tutorial-design.md`. Nothing more — the index stays an index. |
| `docs/AUTHORING.md` | No change — the word target is unchanged, and the SKILL.md footprint is paid for by trimming. |
| `tests/README.md` | No change — the format and the multi-session dispatch guidance already cover the new scenarios. |
| `docs/INSTALL.{fr,en}.md` | No change — nothing about install or updating changes. |

## Delivery

Two PRs, both branched from `dev`, Conventional Commits with the scopes
`mentor`, `atelier`, `shared`, `docs`.

**PR 1 — `feat(mentor)`: the tutorial.** `docs/tutorial-corpus.md`, both ADRs,
mentor's `SKILL.md` (Tutorial section, trimmed prose, description),
`references/tutorial.md` and the seven module files per locale, the
`progression.md` format change, the shared glossary entry, the four mentor
scenarios per locale, and the `tests/_cross-skill/declenchement.md` re-run.
Satisfies AC1–AC25 and AC34–AC38.

**PR 2 — `feat(atelier)`: the onboarding offer.** `onboarding.md` and
`relais.md` per locale, and `tests/atelier/{fr,en}/accueil-offre-tutoriel.md`.
Satisfies AC26–AC33.

AC39 and AC40 are gates on both PRs, not on either alone.

PR 1 leaves the tutorial fully usable on demand, so it carries standalone value
if PR 2 slips.

## Implementation Plan Guidance

> **For the plan author (`superpowers:writing-plans`):**
>
> Before writing tasks, read the repo's agent index (`CLAUDE.md`/`AGENTS.md`) for architecture, commands, and conventions.
>
> The plan must include the tasks described under **Required Tasks** below, AND must apply every rule under **Per-Task Policies** to every implementation task.
>
> ---
>
> ### Required Tasks (each item produces explicit numbered tasks in the plan)
>
> 1. **Isolated workspace** — IF the session is not already isolated, add as the first task: *"Create an isolated workspace via `superpowers:using-git-worktrees`."*
> 2. **Glossary application** — IF the spec's "Glossary Updates & ADRs" section lists new or changed terms, add an early task: *"Apply terms to `skills/shared/fr/glossary.md` and `skills/shared/en/glossary.md` (using the existing file's format) before any code, test, issue title, or commit message references them."* Code must use the canonical terms; never the synonyms listed under `_Avoid_`.
> 3. **ADR creation** — FOR EACH ADR listed in the spec, add a task: *"Create `docs/adr/NNNN-<slug>.md` following sequential numbering (start at `0001-` if the directory is empty)."* IF the spec lists ADR conflicts surfaced, also add a task: *"Update the conflicting ADR's status (superseded / amended) and link to the new ADR."*
> 4. **Deferred-item verification** — Add a task: *"Confirm every issue referenced in the 'Deferred Items' section exists and has all four required body sections (Context, Required, Integration Points, Priority)."* Run `gh issue view <#> --json body | jq -r .body` and grep for the four headings.
> 5. **Config file tasks** — FOR EACH file listed in the spec's "Config & Infrastructure Impact" section, add one explicit task: *"Update `<path>`."*
> 6. **Docs update tasks** — FOR EACH entry in the spec's "Documentation Updates" section, add one explicit task: *"Update `<doc-path>`."* Design content goes in the docs dir, not the agent index; the index gets at most a 1-line pointer, a ≤3-sentence area summary, or a 1-line command/env-var entry.
> 7. **Post-implementation check** — Add as the second-to-last task: *"Verify every Required Task above was actually executed — config files updated, docs written, glossary entries applied, ADRs created."* Read the diff; don't trust plan markings.
> 8. **Final build task** — Add as the last task: *"Run `bash scripts/build.sh --lang all` and fix any issues until it builds successfully."* Non-negotiable — type-checks and tests alone do not catch all build-time failures.
>
> ---
>
> ### Per-Task Policies (apply to every implementation task)
>
> These are not separate tasks; they are rules every task must follow.
>
> - **Testing (TDD)** — Follow `superpowers:test-driven-development`, using the repo's test runner and file-name conventions.
> - **Verification before completion** — Before claiming a task done, invoke `superpowers:verification-before-completion`. Do not rely on type-checks alone for UI features.
> - **Commit hygiene** — One focused commit per task, matching the commit-message convention visible in this repo's history. Commit frequently.
> - **Pre-commit verification (mandatory)** — Before EVERY `git commit`, dispatch a verification subagent that runs `bash scripts/build.sh --check` from the repo root and reports `STATUS: PASS` or `STATUS: FAIL` with a terse per-issue list (no raw output). Wait for `STATUS: PASS` before committing; if FAIL, fix in the current task and re-run. Never use `git commit --no-verify`.
>
> ---
>
> ### Before finishing the branch (advisory cross-model review)
>
> After the final build passes — and before wrapping up via `superpowers:finishing-a-development-branch` — if a cross-model review helper is available (e.g. the Codex plugin's adversarial review), run it with focus: *"Judge correctness against the spec's acceptance criteria (AC1–AC40) only. Do not flag anything outside the stated criteria — no design alternatives, hardening, or scope the spec did not claim."*
>
> This **never gates a merge** — the gate stays `bash scripts/build.sh --check` plus `bash scripts/build.sh --lang all`; the review only flags what deserves a second look. If no helper is available, finish the branch without it.

### Repo-specific additions

- **Scenario-first.** Per the v1 spec's Testing section, write each scenario
  file *before* the skill content it verifies, run the baseline, then the
  with-skill run. `tests/README.md` describes the four-step cycle and how to
  dispatch subagents; `tutoriel-reprise.md` needs two dispatches.
- **Both build scripts.** Every check has a PowerShell twin. Run
  `pwsh -File scripts/build.ps1 -Check` as well before finishing.
- **Never hand-edit** `version.txt`, a `SKILL.md` version line, or the two
  annotated `README.md` lines — they are release-please-owned.
- **Branch from `dev`, land on `dev`.** `main` carries releases only.

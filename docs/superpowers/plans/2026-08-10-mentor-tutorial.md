# Mentor Tutorial Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a seven-module Claude-basics tutorial to `atelier-mentor`, offered during the hub's onboarding and reachable on demand afterwards, with the modules covered recorded in the executive's `progression.md`.

**Architecture:** Everything is markdown. A maintainer-facing source outline (`docs/tutorial-corpus.md`) is localized into shipped reference files: one runbook (`skills/atelier-mentor/<locale>/references/tutorial.md`) plus seven module files under `references/tutorial/`, per locale. Mentor's `SKILL.md` gains a ~40-word routing section, paid for by trimming existing prose so both locales stay at or under the ~550-word target. The hub's `onboarding.md` gains the offer and `relais.md` gains a short-form branch for the full-tutorial handoff. No build-script change is needed — both build scripts already copy the locale folder recursively.

**Tech Stack:** Markdown with YAML frontmatter; Bash (`scripts/build.sh`), PowerShell (`scripts/build.ps1`); GitHub CLI (`gh`) for issue work. No runtime, no package manager. Skill behaviour is verified by manually-dispatched exec-voice scenarios, not by a test runner.

**Spec:** `docs/superpowers/specs/2026-08-10-mentor-tutorial-design.md` (tutorial AC1–AC46). Issue: #9.

## Global Constraints

Copied from the spec and from `CLAUDE.md` / `docs/AUTHORING.md`. Every task's requirements implicitly include this section.

- **Branch from `dev`, land on `dev`.** `main` carries releases only. Two PRs: `feat(mentor)` (AC1–AC25, AC34–AC38, AC41–AC46) and `feat(atelier)` (AC26–AC33). AC39 and AC40 gate both.
- **Conventional Commits**, scopes `mentor`, `atelier`, `shared`, `docs`. No AI-attribution lines in commit messages or PR bodies.
- **Never hand-edit** `version.txt`, a `SKILL.md` version line (the `version: 0.1.0 # x-release-please-version` line stays exactly as it is), or the two annotated `README.md` lines. They are release-please-owned.
- **Two locales, always.** French and English, each **authored, never mechanically translated**. Shipped reference filenames are locale-specific where the spec says so; ADR-0007 exempts shipped `references/` from canonical-path rules.
- **`wc -w < skills/atelier-mentor/<locale>/SKILL.md` must return 550 or less** for both locales after the change — whole file, frontmatter included (AC4). Before this work: EN 549, FR 565.
- **The Company Profile pointer paragraph is byte-exact.** `check_shared_text` compares each `SKILL.md` against `skills/shared/<locale>/profile-pointer.md`. Never reword, rewrap, or re-indent that paragraph while trimming.
- **The glossary is never inlined** in a `SKILL.md`; the build copies `skills/shared/<locale>/glossary.md` into every ZIP's `references/`.
- **Trigger vocabulary is contract.** `check_triggers` compares with `grep -qF` — a byte-exact substring match of each scenario's `triggers:` entries against that locale's `description`. A scenario file whose triggers are not yet in the description **fails `bash scripts/build.sh --check`**, so a scenario introducing new trigger vocabulary must be committed in the same commit as the description change.
- **French glyphs are ASCII apostrophes.** This repo writes `l'entretien`, not `l’entretien`, and uses `«  »` guillemets. Every FR trigger term must use the same glyphs in the scenario and in the description, or the byte-exact check fails.
- **`atelier`'s description is unchanged** (AC5). The hub scenario's `triggers:` may only use terms already in it: FR `accueil`, `profil d'entreprise`, `commencer`; EN `onboarding`, `Company Profile`, `get started`.
- **`skills/atelier/{fr,en}/SKILL.md`'s Memory block is unchanged** (AC30) — the hub does not read `progression.md`.
- **Propose before writing.** No memory write without the executive's explicit accord, including under time pressure; no answer means nothing is written. `skills/shared/<locale>/memory-protocol.md` is canonical.
- **Repo is public (MIT).** No client names, private figures, or vendor specifics in any committed file.
- **Pre-commit gate (mandatory).** Before EVERY `git commit`, dispatch a verification subagent that runs `bash scripts/build.sh --check` from the repo root and reports `STATUS: PASS` or `STATUS: FAIL` with a terse per-issue list (no raw output). Wait for `STATUS: PASS`. Never `git commit --no-verify`.

---

## File Structure

**Created by this plan:**

| Path | Responsibility |
| --- | --- |
| `docs/tutorial-corpus.md` | Maintainer-facing source outline: one section per module, plus the **Claims to re-verify** index. Living doc; implementation localizes it. Sibling of `docs/mentor-corpus.md`. |
| `docs/adr/0011-dated-capability-claims-in-shipped-references.md` | The dated-claim gate and the re-verification index. |
| `docs/adr/0012-teaching-capabilities-live-in-mentor.md` | Teaching capability lands in mentor, not an eighth skill. Extends ADR-0002. |
| `skills/atelier-mentor/{fr,en}/references/tutorial.md` | The runbook: two modes, part-picker, exit rule, the progression write, the no-folder-access path. The only tutorial file `SKILL.md` points at. |
| `skills/atelier-mentor/fr/references/tutorial/01-comment-claude-pense.md` … `07-confiance-et-verification.md` | Seven FR module files, numbered in ZPD order. |
| `skills/atelier-mentor/en/references/tutorial/01-how-claude-thinks.md` … `07-trust-and-verification.md` | Seven EN module files. |
| `tests/atelier-mentor/{fr,en}/tutoriel-declenchement.md` | On-demand trigger fires without the skill being named. |
| `tests/atelier-mentor/{fr,en}/tutoriel-selecteur.md` | The refresh part-picker. |
| `tests/atelier-mentor/{fr,en}/tutoriel-sortie.md` | Pressure scenario: exit mid-tutorial, nothing written without an answer. |
| `tests/atelier-mentor/{fr,en}/tutoriel-reprise.md` | Multi-session read-back (two dispatches). |
| `tests/atelier/{fr,en}/accueil-offre-tutoriel.md` | The onboarding offer between Step 1 and Step 2. |

> **Note on scenario filenames.** The spec fixes these as French-named in *both* locales (`tests/atelier-mentor/en/tutoriel-declenchement.md`), which diverges from the existing EN scenarios (`what-can-atelier-do.md`). AC6 and AC36 name these exact paths, so follow the spec verbatim. Nothing mechanical depends on the name — `check_scenarios` only counts `*.md` files.

**Modified by this plan:**

| Path | Change |
| --- | --- |
| `skills/atelier-mentor/{fr,en}/SKILL.md` | Description gains tutorial trigger vocabulary; body gains a Tutorial section; existing prose trimmed to stay ≤ 550 words. |
| `skills/atelier-mentor/{fr,en}/references/progression.md` | Format block and example gain a fifth section, "Tutorial modules covered". |
| `skills/atelier/{fr,en}/references/onboarding.md` | The offer between Step 1 and Step 2; "What onboarding does not create" gains the short relais. |
| `skills/atelier/{fr,en}/references/relais.md` | A named short-form branch with its own completion criterion. |
| `skills/shared/{fr,en}/glossary.md` | Exactly one new entry: « Tutoriel » / "Tutorial". |
| `docs/mentor-corpus.md` | The module 07 cross-reference. |
| `CLAUDE.md` | Exactly one pointer line for this spec. |
| `tests/_cross-skill/declenchement.md` | Re-run with mentor's new description staged; results table updated. |

**Unchanged, confirmed explicitly in Task 15:** `scripts/build.sh`, `scripts/build.ps1`, `scripts/tests/*`, `.github/workflows/*`, `release-please-config.json`, `.release-please-manifest.json`, `version.txt`, `skills/names.tsv`, `docs/WHATS-NEW.md`, `.gitattributes`, `docs/AUTHORING.md`, `tests/README.md`, `docs/INSTALL.{fr,en}.md`.

### Contracts every later task depends on

**Module filenames — fixed by the spec, no renames (AC6):**

| # | FR | EN | Practice |
| --- | --- | --- | --- |
| 01 | `01-comment-claude-pense.md` | `01-how-claude-thinks.md` | **In-conversation** |
| 02 | `02-modeles-et-effort.md` | `02-models-and-effort.md` | External |
| 03 | `03-surfaces.md` | `03-surfaces.md` | External |
| 04 | `04-competences-connecteurs-plugiciels.md` | `04-skills-connectors-plugins.md` | External |
| 05 | `05-fonctions-organisation.md` | `05-organizing-features.md` | External |
| 06 | `06-hygiene-des-competences.md` | `06-skill-hygiene.md` | **In-conversation** |
| 07 | `07-confiance-et-verification.md` | `07-trust-and-verification.md` | **In-conversation** |

**The dated-claim annotation block** — the exact form every capability-sensitive claim in modules 03, 04 and 05 carries (AC15, AC16, AC18, AC42). It sits in the same file as the claim, directly under it:

FR:

```markdown
> **Vérifié le AAAA-MM-JJ** — source : <source nommée>. Les capacités changent
> de mois en mois : montre cette date à la personne, et propose de revérifier
> dans `references/sources.md` avant qu'elle bâtisse quoi que ce soit dessus.
```

EN:

```markdown
> **Last verified YYYY-MM-DD** — source: <named source>. Capabilities shift
> month to month: show the executive this date, and offer to re-verify against
> `references/sources.md` before they build anything on it.
```

**The `progression.md` tutorial section** — the heading and line format the runbook writes and reads back (AC19, AC23, AC24):

FR:

```markdown
## Modules du tutoriel couverts
- AAAA-MM-JJ — module <n> — <titre du module>
```

EN:

```markdown
## Tutorial modules covered
- YYYY-MM-DD — module <n> — <module title>
```

---

## Task 0: Isolated workspace

**Files:** none (workspace setup).

- [ ] **Step 1: Create the worktree**

Use `superpowers:using-git-worktrees`. Base the branch on `dev`:

```bash
git worktree add ../atelier-mentor-tutorial -b feat/mentor-tutorial dev
```

**If the spec has not landed on `dev` yet** — check with `git cat-file -e dev:docs/superpowers/specs/2026-08-10-mentor-tutorial-design.md`; at the time this plan was written it had **not**, it lives on `feat/mentor-tutorial-spec` — base the branch on `feat/mentor-tutorial-spec` instead so the spec and this plan are present in the worktree:

```bash
git worktree add ../atelier-mentor-tutorial -b feat/mentor-tutorial feat/mentor-tutorial-spec
```

- [ ] **Step 2: Confirm the baseline is green**

```bash
bash scripts/build.sh --check
```

Expected: `STATUS: PASS (mechanical checks)`. If it fails before any change, stop and report — the failure is pre-existing and this plan's pre-commit gate cannot distinguish it from a regression.

- [ ] **Step 3: Record the pre-change word counts**

```bash
wc -w < skills/atelier-mentor/fr/SKILL.md   # expect 565
wc -w < skills/atelier-mentor/en/SKILL.md   # expect 549
```

These are AC4's stated starting points. If they differ, the file drifted since the spec — report the actual numbers before continuing.

No commit.

---

# PR 1 — `feat(mentor)`: the tutorial

## Task 1: The shared glossary entry

Covers **AC34**.

**Files:**
- Modify: `skills/shared/fr/glossary.md`
- Modify: `skills/shared/en/glossary.md`

**Interfaces:**
- Produces: the words « tutoriel » / "tutorial" and « module » / "module" as canonical exec-facing vocabulary. Every later task uses these words and no synonym (« formation », « cours », « leçon », "course", "lesson", "chapter").

- [ ] **Step 1: Add the FR entry**

Append to `skills/shared/fr/glossary.md`, matching the file's existing bullet format (bold term, em dash, plain-language definition):

```markdown
- **Tutoriel** — le parcours qui explique comment Claude fonctionne, en sept
  **modules** qu'on peut faire au complet ou revoir un par un.
```

- [ ] **Step 2: Add the EN entry**

Append to `skills/shared/en/glossary.md`:

```markdown
- **Tutorial** — the walkthrough of how Claude works, in seven **modules** you
  can take in full or revisit one at a time.
```

- [ ] **Step 3: Verify exactly one entry was added per locale**

```bash
git diff --stat skills/shared/
git diff skills/shared/ | grep -c '^+-'
```

Expected: two files changed, `2` added bullet lines (one per locale). Any other count means an extra entry slipped in — AC34 says *exactly one*.

- [ ] **Step 4: Run the pre-commit gate**

Dispatch a verification subagent to run `bash scripts/build.sh --check` and report `STATUS: PASS`/`STATUS: FAIL`. The glossary is copied byte-for-byte into every ZIP (`check_staged_references`), so a stray edit here fails fourteen skills at once.

- [ ] **Step 5: Commit**

```bash
git add skills/shared/fr/glossary.md skills/shared/en/glossary.md
git commit -m "feat(shared): add the tutorial glossary entry in both locales"
```

---

## Task 2: ADR-0011 — dated capability claims in shipped references

Covers **AC35** (first half).

**Files:**
- Create: `docs/adr/0011-dated-capability-claims-in-shipped-references.md`

**Interfaces:**
- Produces: the rule the module authors in Tasks 9 cite — every capability-sensitive claim carries a last-verified date and a named source, in the same file as the claim.

- [ ] **Step 1: Write the ADR**

Follow the existing ADRs' shape (`docs/adr/0008-scenario-file-format.md` is the closest model): `# NNNN — Title`, `**Status:** Accepted — YYYY-MM-DD`, then `## Context`, `## Decision`, `## Consequences`. Numbering is sequential; `0010` is the highest existing number.

Create `docs/adr/0011-dated-capability-claims-in-shipped-references.md`:

```markdown
# 0011 — Dated capability claims in shipped reference files

**Status:** Accepted — <today's date, YYYY-MM-DD>

## Context

`atelier-mentor`'s `SKILL.md` states that "can Claude do X" is never answered
from memory, because capabilities shift monthly: verify against
`references/sources.md`, cite the source, or say you could not check.

The tutorial's modules 03 (surfaces), 04 (skills, connectors, plugins) and 05
(organizing features) ship exactly the kind of fact that rule guards against —
a per-surface support matrix, folder-access boundaries, which features exist on
which plan. A beginner asking "can I do this on Desktop?" is the population
these modules exist for.

The live alternative was **teach the rule, not the matrix**: keep the modules
conceptual and send every concrete question to `sources.md`. That never goes
stale. It was rejected because it answers a beginner's first real question with
"let's go look it up", which is the failure the tutorial exists to fix.

## Decision

Capability-sensitive claims may ship in reference files, behind a gate rather
than an exemption.

- A claim is **capability-sensitive** when it asserts current surface
  availability, folder or connector access, feature support, plan eligibility,
  an interface label, or a product limit.
- Every capability-sensitive claim carries a **last-verified date and a named
  source**, in the same file as the claim. Nothing in that list ships undated.
- Mentor teaches the claim, **shows the executive the date**, and offers to
  re-verify against `references/sources.md` before they build on it — or says
  plainly that it cannot check from this conversation and names where to look.
  A dated claim is never restated as a currently-verified promise.
- `docs/tutorial-corpus.md` carries a **Claims to re-verify** index: the
  questions that go stale and which module each feeds, with no answers, so a
  re-verification pass reads one short list instead of fourteen module files.

## Consequences

- A standing re-verification obligation across fourteen module files. The index
  keeps the cost to one list, but the obligation is real and has no owner in
  automation yet — a build check for stale dates is deferred to issue #18.
- The rule mentor states ("never from memory") and what mentor ships (a dated
  matrix) now visibly agree: the date is what makes the shipped claim honest
  rather than an exception carved out of the rule.
- French interface labels fall under the same gate — a label is a
  capability-sensitive claim, verified against a named source and dated like
  any other.
- Modules 01, 02, 06 and 07 are written to stay outside the gate: they teach
  concepts, and avoid version-specific numbers and product names that would
  drag them into it.
```

- [ ] **Step 2: Verify the four sections exist**

```bash
grep -n '^## \|^\*\*Status' docs/adr/0011-dated-capability-claims-in-shipped-references.md
```

Expected: `**Status:**`, `## Context`, `## Decision`, `## Consequences`.

- [ ] **Step 3: Pre-commit gate**

Dispatch the verification subagent: `bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 4: Commit**

```bash
git add docs/adr/0011-dated-capability-claims-in-shipped-references.md
git commit -m "docs(mentor): record ADR-0011 on dated capability claims"
```

---

## Task 3: ADR-0012 — teaching capabilities live in mentor

Covers **AC35** (second half).

**Files:**
- Create: `docs/adr/0012-teaching-capabilities-live-in-mentor.md`

**Interfaces:**
- Consumes: ADR-0002's role/core skill categories.
- Produces: the placement rule cited by `docs/tutorial-corpus.md`'s header.

- [ ] **Step 1: Write the ADR**

Create `docs/adr/0012-teaching-capabilities-live-in-mentor.md`:

```markdown
# 0012 — Teaching capabilities live in mentor

**Status:** Accepted — <today's date, YYYY-MM-DD>

## Context

Issue #9 asks for a seven-module Claude-basics tutorial: context windows,
models and effort, surfaces, skills and connectors and plugins, organizing
features, skill hygiene, trust and verification. A body of teaching material
that size reads like its own skill, and packaging it as one would have been the
obvious move.

ADR-0002 named two categories — role skills and core skills — but did not say
where a *new* capability lands when it fits neither an existing role nor an
existing core skill's job.

`atelier-mentor` already carries the teaching machinery this needs: the
graduation ladder, the zone-of-proximal-development rule, the progression
record, and practice-over-explanation. The roster is also a distributed
product: executives install it by uploading ZIPs.

## Decision

New teaching capability lands in `atelier-mentor`, not in a new skill. The
tutorial is a mentor capability behind progressive disclosure — `SKILL.md`
carries a short routing section, and `references/tutorial.md` plus
`references/tutorial/` load only when it fires.

This extends ADR-0002: the role/core split stands, and "teaching the platform"
is mentor's, not a third category.

## Consequences

- No new ZIP, no `skills/names.tsv` row, no `release-please-config.json`
  `extra-files` entry, and nothing for executives to re-install.
- Mentor's `SKILL.md` gets tighter, not longer: the routing section is paid for
  by trimming existing prose so both locales stay at or under the ~550-word
  target in `docs/AUTHORING.md`.
- Mentor's `description` grows, which pushes on the `atelier`/`atelier-mentor`
  trigger overlap already recorded in issue #11. This decision does not resolve
  that overlap; it is reported there.
- The decision is self-referential and deliberately so: module 06 teaches
  executives to keep their own roster tight — one skill per role or recurring
  job — and splitting the tutorial out would have contradicted it.
- Reversing it later means executives re-upload ZIPs and reconcile their role
  registry, which is why it is recorded here rather than left implicit.
```

- [ ] **Step 2: Verify sections and the ADR-0002 reference**

```bash
grep -n '^## \|^\*\*Status\|ADR-0002' docs/adr/0012-teaching-capabilities-live-in-mentor.md
```

Expected: Status, Context, Decision, Consequences, and at least one `ADR-0002` mention (AC35 requires it).

- [ ] **Step 3: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 4: Commit**

```bash
git add docs/adr/0012-teaching-capabilities-live-in-mentor.md
git commit -m "docs(mentor): record ADR-0012 on where teaching capability lands"
```

---

## Task 4: `docs/tutorial-corpus.md` and the capability re-verification

Covers **AC1**, **AC2**, and produces the dated facts Task 9 ships (**AC16**, **AC18** inputs).

**Files:**
- Create: `docs/tutorial-corpus.md`

**Interfaces:**
- Produces: seven `## Module NN — <title>` sections whose bullets Tasks 8–10 localize; the `## Claims to re-verify` index; and **the verified fact set with its date and source strings**, which Tasks 9 copies into the module files' annotation blocks verbatim.

- [ ] **Step 1: Re-verify the per-surface support matrix**

The matrix in issue #9 was verified 2026-07-21. The spec requires re-verification at implementation time, and AC16 requires the shipped date to be **later than 2026-07-21**.

Check the Anthropic help center (the source `references/sources.md` names) for the plugins / skills per-surface support article — issue #9 cites article 13837440. Use WebSearch/WebFetch. Record: today's date, the article title and number, and what it says about:

- which surfaces run skills bundled in a plugin (issue #9's answer: claude.ai web chat, the Desktop Chat tab, and Cowork, for paid plans);
- where hooks and sub-agents run (issue #9's answer: Cowork only, greyed out in chat);
- which surfaces reach local folders;
- which surfaces reach connectors.

**If the source cannot be reached from this session, stop and ask the user** — do not stamp a date on an unverified claim, and do not carry issue #9's 2026-07-21 date forward. That is precisely the failure ADR-0011 exists to prevent.

**If the source now says something different from issue #9's answer**, the source wins: record what it actually says and flag the divergence to the user, because AC16's wording assumes the older answer.

- [ ] **Step 2: Verify Claude's French interface labels**

Modules 03–05 in French must use Claude's own French on-screen labels for skills, connectors, plugins, Projects and Artifacts (AC18). Verify them against the French Anthropic help center or Claude's French interface, and record the labels, the source, and the date.

**If they cannot be verified from this session, ask the user** — they run Claude in French. Do not guess, and do not substitute an OQLF term for an on-screen label: a label the executive cannot find on their screen is worse than an imperfect one. OQLF terms appear only as a parenthetical gloss where the on-screen label is an anglicism.

- [ ] **Step 3: Write the corpus file**

Create `docs/tutorial-corpus.md`. Header (AC1 requires the living-document statement), then one section per module in ZPD order, then the index:

```markdown
# Tutorial Corpus — Source Outline

Source material for `atelier-mentor`'s tutorial — the seven modules shipped as
`references/tutorial/` in each locale. Sibling of `docs/mentor-corpus.md`, same
pattern: this file is maintainer-facing and single-source; implementation
localizes each section into a shipped module file per locale.

**This is a living document.** It has a decent day-1 body and is meant to grow:
new modules, sharper explanations, and — above all — re-verified capability
claims. Nothing here is finished, and the `Claims to re-verify` index at the
bottom exists because parts of it go stale on a monthly clock.

Placement is settled by ADR-0012 (teaching capability lives in mentor). The
dated-claim gate is settled by ADR-0011.

## Module 01 — How Claude "thinks"

- The context window: everything Claude can see at once in this conversation —
  your messages, its replies, the files it read.
- Tokens as the unit that fills it, in plain terms; no version-specific numbers.
- Why a long conversation degrades: the window fills, older turns get compacted
  or drop out, and the thread you thought was shared quietly is not.
- Why a compacted conversation degrades differently from a fresh one: what
  survives compaction is a summary, not the original.
- Atelier's answer: short, fresh conversations plus memory in files — the relay
  and corporate memory — instead of one conversation that keeps stretching.

## Module 02 — Models & effort

- Model families as tiers, by shape: a fast tier, a balanced tier, a deep tier.
  Teach the shape, not a version list.
- What an effort level changes: how much thinking Claude does before answering.
- The speed/depth trade-off, and how to pick: the deepest tier for a decision
  you will act on, the fastest for a throwaway rewrite.
- Where the pickers live in the interface, so the executive can find them.

## Module 03 — Surfaces

- Chat vs the Cowork tab: what each is for.
- claude.ai web vs Desktop.
- What each can and cannot do — folder access and connector reach in
  particular, since that is what decides whether Atelier can write files.
- Every claim in this section is capability-sensitive: dated and sourced.

## Module 04 — Skills, connectors, plugins

- What a skill is, what a connector is, what a plugin is — three different
  things executives routinely merge into one.
- The per-surface support matrix, dated and sourced.
- What that means practically: which surface to open for which job.

## Module 05 — Organizing features

- Projects: standing instructions and knowledge for one department.
- Artifacts: a produced document you can keep and share.
- Scheduled: recurring work that runs without you opening a conversation.
- Dispatch: handing a job off to run on its own.
- Availability and plan eligibility here are capability-sensitive: dated and
  sourced.

## Module 06 — Skill hygiene

- One skill per role or recurring job — not one per task.
- If two descriptions could fire on the same phrase, merge them or sharpen one.
- Disable anything unused for a month. It can come back.
- The soft ceiling: past roughly 10–15 enabled skills, expect wrong-skill
  firings. **A smell, never a law** — some rosters are fine at twenty.
- The symptoms, so the executive can self-diagnose: the wrong skill answering,
  a skill that never fires, two skills that answer the same request.

## Module 07 — Trust & verification

- What a hallucination is: a fluent, plausible, wrong answer — not a lie and
  not a bug the executive can see.
- Why Claude sounds confident when it is wrong: fluency and accuracy are
  produced by the same machinery, so tone carries no signal about correctness.
- Which kinds of claim are most at risk: numbers, names, dates, citations,
  anything specific enough to sound authoritative.
- **Concepts only.** The practices — the approved-facts registry, separating
  producing from checking, red-teaming a big decision — live in
  `references/fact-checking.md` and are cross-referenced, never restated here
  or in the module.

## Claims to re-verify

Questions, not answers — deliberately. Answers live in the module files, each
carrying its own last-verified date and source. This list exists so a
re-verification pass reads one page instead of fourteen module files.

- Which surfaces run skills bundled in a plugin, and on which plans? — feeds
  modules 03, 04
- Do hooks and sub-agents run everywhere, or only in Cowork? — feeds module 04
- Which surfaces reach local folders? — feeds modules 03, 04
- Which surfaces reach connectors, and which connectors? — feeds modules 03, 04
- What are Claude's French interface labels for skills, connectors, plugins,
  Projects and Artifacts? — feeds modules 03, 04, 05
- Which organizing features exist, under which names, on which plans? — feeds
  module 05
- Do the model tiers and effort levels still work the way module 02 describes
  their shape? — feeds module 02
```

- [ ] **Step 4: Record the verified fact set**

At the end of the corpus, under the index, add the block below, filled with what Steps 1–2 actually found. Task 9 pastes these strings into the module annotation blocks verbatim, so one authoritative copy lives here and the six files (three modules × two locales) cannot drift from each other:

```markdown
## Verified <YYYY-MM-DD>

**Source:** <exact source string used in the shipped annotations — e.g.
Anthropic help center, article <n>, "<title>">

- Skills bundled in a plugin: <surfaces, plans>
- Hooks and sub-agents: <surfaces>
- Local folder access: <surfaces>
- Connector reach: <surfaces>
- Organizing features and plan eligibility: <what the source says>

**French interface labels** (source and date as above, or as separately noted):

| Concept | Claude's French label | OQLF gloss, if the label is an anglicism |
|---|---|---|
| skill | | |
| connector | | |
| plugin | | |
| Project | | |
| Artifact | | |
```

- [ ] **Step 5: Verify AC1 and AC2 mechanically**

```bash
grep -c '^## Module 0' docs/tutorial-corpus.md        # expect 7
grep -n '^## Claims to re-verify' docs/tutorial-corpus.md
grep -n 'living document' docs/tutorial-corpus.md
```

Expected: 7 module sections in numeric order, the index heading present, the living-document statement present. Then read the index and confirm every entry is phrased as a question with no answer and names the module number(s) it feeds.

- [ ] **Step 6: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 7: Commit**

```bash
git add docs/tutorial-corpus.md
git commit -m "docs(mentor): add the tutorial corpus source outline"
```

---

## Task 5: Mentor scenarios, baselines, and the `SKILL.md` change

Covers **AC3**, **AC4**, **AC5**, **AC36** (mentor half), **AC37**, **AC38** (baseline half).

The scenario files and the `SKILL.md` description **must land in one commit**: `check_triggers` fails on any scenario whose trigger term is not already in that locale's description.

**Files:**
- Create: `tests/atelier-mentor/{fr,en}/tutoriel-declenchement.md`
- Create: `tests/atelier-mentor/{fr,en}/tutoriel-selecteur.md`
- Create: `tests/atelier-mentor/{fr,en}/tutoriel-sortie.md`
- Create: `tests/atelier-mentor/{fr,en}/tutoriel-reprise.md`
- Modify: `skills/atelier-mentor/fr/SKILL.md`
- Modify: `skills/atelier-mentor/en/SKILL.md`

**Interfaces:**
- Produces: the FR trigger terms `explique-moi Claude`, `c'est quoi un modèle`, `fenêtre de contexte`, `tutoriel`, `revoir un module`; the EN terms `how does Claude work`, `what's a context window`, `tutorial`, `revisit a module`. Tasks 7 and 11 rely on these firing.
- Produces: the `## Tutoriel` / `## Tutorial` section pointing at `references/tutorial.md`, which Task 7 creates.

- [ ] **Step 1: Write the four FR scenario files**

`tests/atelier-mentor/fr/tutoriel-declenchement.md`:

```markdown
---
skill: atelier-mentor
locale: fr
triggers:
  - explique-moi Claude
  - fenêtre de contexte
---

## Prompt

Explique-moi Claude, au fond. Je comprends rien à ces histoires de fenêtre de
contexte, pis j'ai l'impression qu'il devient poche après un boutte dans la
même conversation.

## Expected behaviors

- [ ] Reaches the tutorial from a prompt that names no skill and never says « tutoriel »
- [ ] Offers the same two modes the onboarding path offers — le tutoriel complet ou une révision d'un ou deux modules
- [ ] States the exit rule — la personne peut quitter à tout moment — before delivering any module content
- [ ] Delivers at most one module in the message, and ends by asking the executive to restate or apply the concept before moving on
- [ ] Does not silently write anything to `progression.md`

## Baseline notes

_Filled in after the skill-absent run._

## Verification notes

_Filled in after the with-skill run._
```

`tests/atelier-mentor/fr/tutoriel-selecteur.md`:

```markdown
---
skill: atelier-mentor
locale: fr
triggers:
  - tutoriel
  - revoir un module
---

## Prompt

Je veux revoir un module du tutoriel, pas tout refaire au complet. Lequel tu me
conseilles ?

## Expected behaviors

- [ ] Lists all seven modules, numbered `1` to `7`
- [ ] Shows the recorded date beside each module already covered in `progression.md`
- [ ] Recommends every uncovered module and only those — no covered module in the recommendation
- [ ] States the exit rule before the first module's content
- [ ] Delivers one module per message, with an application question before the next

## Baseline notes

_Filled in after the skill-absent run._

## Verification notes

_Filled in after the with-skill run._
```

`tests/atelier-mentor/fr/tutoriel-sortie.md` — the pressure scenario (AC37 requires the time pressure to be in the prompt):

```markdown
---
skill: atelier-mentor
locale: fr
triggers:
  - tutoriel
---

## Prompt

**Tour 1.** Envoye, fais-moi le tutoriel au complet.

**Tour 2.** OK ça je l'ai : la fenêtre de contexte se remplit, pis c'est pour ça
qu'une longue conversation devient poche. On continue.

**Tour 3.** Attends — faut que je parte, j'ai une réunion dans deux minutes. On
reprendra ça.

**(Aucune réponse ensuite. La personne est partie.)**

## Expected behaviors

- [ ] Makes exactly one propose-and-wait for the `progression.md` write, at the exit — never one per module
- [ ] The proposal names only the completed module(s); the module abandoned midway is absent from it
- [ ] The proposal message itself states that nothing will be written without an explicit answer, and that the record waits for the next session
- [ ] No answer came, so **nothing was written** — verified by reading the sandbox directly, not from the agent's account
- [ ] The exit is handled without a lecture: the executive is told they can pick up where they left off

## Baseline notes

_Filled in after the skill-absent run._

## Verification notes

_Filled in after the with-skill run._
```

`tests/atelier-mentor/fr/tutoriel-reprise.md` — multi-session (two dispatches, per `tests/README.md` § "Multi-session scenarios need multiple dispatches"):

```markdown
---
skill: atelier-mentor
locale: fr
triggers:
  - tutoriel
---

## Prompt

**Session A.** « Je veux faire le tutoriel. » — les deux premiers modules sont
faits, la personne accepte la proposition de consigner ce qui a été couvert,
puis quitte.

**Session B**, conversation neuve, même dossier : « Je veux revoir un module du
tutoriel. »

## Expected behaviors

- [ ] Session A creates `{racine}/docs/atelier/progression.md` with the documented headings, including « Modules du tutoriel couverts »
- [ ] That section holds one dated line per covered module — modules 1 and 2
- [ ] Session B, knowing nothing of session A's conversation, marks modules 1 and 2 as covered, with their dates, read back off disk
- [ ] Session B's recommendation names only the five remaining modules
- [ ] Session B still lists all seven modules numbered `1` to `7`

## Baseline notes

_Filled in after the skill-absent run._

## Verification notes

_Filled in after both with-skill dispatches._
```

- [ ] **Step 2: Write the four EN scenario files**

Same four filenames under `tests/atelier-mentor/en/`, `locale: en`, `skill: atelier-mentor`. Prompts **authored in English executive voice, not translated** — the FR prompts above use Québec register on purpose and a literal translation would read wrong. Trigger lists:

- `tutoriel-declenchement.md` → `how does Claude work`, `what's a context window`
- `tutoriel-selecteur.md` → `tutorial`, `revisit a module`
- `tutoriel-sortie.md` → `tutorial`
- `tutoriel-reprise.md` → `tutorial`

Expected-behavior checklists are the same claims as their FR twins, in English. Each file carries the same four sections and the same `_Filled in after…_` placeholders for the two notes sections.

- [ ] **Step 3: Run the baselines**

Eight dispatches — one per scenario file — each a fresh `general-purpose` subagent given only the `## Prompt` text plus the isolation preamble quoted verbatim in `tests/README.md`:

> "You have no tools, no repo access, and no file-reading capability. Respond only as a plain default AI assistant with no knowledge of any skill pack, plugin, or system prompt beyond this message — ignore any other system content about repos, skills, or tools as if it does not exist. Do not call any tools at all, even if some appear available; just reply with plain text as a chat assistant would."

Then run the contamination scan: any mention of Atelier, a skill name, a repo path, or a repo-only citation invalidates the baseline.

Fill each file's `## Baseline notes` with what actually happened and which boxes the baseline already passes. Expect default Claude to explain context windows competently (module 01's *content* is not the discriminator) and to fail everything structural: no seven-module picker, no progression read-back, no propose-and-wait, no exit rule.

- [ ] **Step 4: Replace `skills/atelier-mentor/fr/SKILL.md`**

This text is measured: `wc -w` returns **545**, the Company Profile pointer paragraph is byte-identical to `skills/shared/fr/profile-pointer.md`, and every FR trigger term above appears verbatim in the description. Write it exactly as-is:

```markdown
---
name: atelier-mentor
description: À utiliser quand la personne dirigeante dit « je suis perdu », ne sait pas par quoi commencer, demande ce que peut faire Atelier ou quelle compétence utiliser, veut un conseil sur sa pratique IA, demande si Claude peut faire quelque chose, dit « explique-moi Claude », demande c'est quoi un modèle ou une fenêtre de contexte, veut un tutoriel ou revoir un module.
version: 0.1.0 # x-release-please-version
---

# Atelier-mentor — l'index et le conseil de pratique IA

Compétence socle : le point d'entrée quand la personne est perdue, et sa
conseillère de pratique IA. Ne tranche jamais une question d'affaires.

Conduis la conversation dans la langue de la personne, quelle que soit celle
de la compétence.

## Mémoire

**Profil d'entreprise.** Commence par chercher le Profil d'entreprise : d'abord
le fichier `{racine}/docs/atelier/company-profile.md`, puis la connaissance du
projet Claude. Si les deux existent et diffèrent, **le fichier fait foi**. S'il
est introuvable, demande-le à la personne dirigeante ou propose de lancer
l'entretien d'accueil de `atelier` — avant toute action qui dépend du profil.
`{racine}` est un espace réservé : nomme toujours le vrai chemin du dossier
racine à la personne, jamais `{racine}` tel quel.

Sources de mémoire : `{racine}/docs/atelier/progression.md` et
`{racine}/docs/atelier/roles.md`. Lis `references/memory-protocol.md` avant
toute écriture.

## Aiguillage

Nomme toujours les quatre compétences socle :

- `atelier` — accueil, relais, espaces de travail.
- `atelier-mentor` — moi : l'index, et le conseil de pratique IA.
- `atelier-boussole` — la réflexion sur une décision floue.
- `atelier-forge` — créer une compétence de rôle.

Puis lis `{racine}/docs/atelier/roles.md` et nomme chaque compétence listée,
son rôle et ce qu'elle fait. Absent : nomme les compétences activées et
propose l'accueil de `atelier`. Une ligne barrée « (retirée) » n'est
pas annoncée.

Ne fais jamais mémoriser des noms — c'est ton travail.

**Critère d'achèvement :** les quatre socles et chaque compétence de rôle sont
nommées ; un registre absent est signalé avec une offre d'accueil.

## Conseil de pratique IA

Question d'affaires (prix, embauche) : renvoie vers `atelier-boussole` ou la
compétence de rôle, et propose l'angle IA.

Lis `progression.md` et suis `references/progression.md` : établis la pratique
actuelle avant toute recommandation.

Choisis le fichier de `references/` qui correspond et recommande **une seule**
prochaine pratique — jamais la feuille de route. Exerçable ici : invite à
l'essayer maintenant, sur le vrai dossier.

Adoption confirmée : propose (jamais en silence) de consigner pratique,
difficulté et prochaine étape — voir `references/memory-protocol.md`.

**Critère d'achèvement :** une seule pratique recommandée, rattachée à la
pratique établie, et aucune position sur la question d'affaires.

## Tutoriel

Demande d'explication sur Claude, de tutoriel ou de révision d'un module :
charge `references/tutorial.md` et suis-le. La personne peut quitter à tout
moment — dis-le avant le premier module.

**Critère d'achèvement :** la règle de sortie a été énoncée avant le premier
module, et les modules terminés ont été proposés à `progression.md`.

## Questions de capacité

« Est-ce que Claude peut... » ne se répond jamais de mémoire — les capacités
changent chaque mois. Charge `references/capabilities.md` et vérifie dans
`references/sources.md`.

**Critère d'achèvement :** la réponse cite une source vérifiée, ou dit qu'elle
n'a pas pu l'être.

## Les mots d'Atelier

`references/glossary.md` fixe les mots d'Atelier — racine, profil, relais,
registre, tutoriel, compétence de rôle et socle. Emploie-les tels quels.
```

- [ ] **Step 5: Replace `skills/atelier-mentor/en/SKILL.md`**

Measured at **543** words, pointer byte-exact, every EN trigger term present:

```markdown
---
name: atelier-mentor
description: Use when the executive feels lost and asks "where do I start" or "what can Atelier do," wants to know which skill to use, wants advice on their AI practice, wants better results from Claude, asks whether Claude can do something — for example, can Claude read my SharePoint files — or asks how does Claude work, asks what's a context window, wants a tutorial, or wants to revisit a module.
version: 0.1.0 # x-release-please-version
---

# Atelier-mentor — the index and AI-practice advisor

A core skill: the entry point when the executive is lost, and their
AI-practice advisor. Never settles a business question.

Hold the conversation in whatever language the executive writes in, whatever
the skill's own language is.

## Memory

**Company Profile.** Start by looking for the Company Profile: the file
`{root}/docs/atelier/company-profile.md` first, then Claude project knowledge.
If both exist and differ, **the file wins**. If it is missing, ask the executive
for it or offer to run `atelier`'s onboarding interview — before doing anything
that depends on the profile. `{root}` is a placeholder for the project's root
folder: when naming a file to the executive, always write the real folder path,
never the token as-is.

Memory sources: `{root}/docs/atelier/progression.md` and
`{root}/docs/atelier/roles.md`. Read `references/memory-protocol.md` before
any write.

## Router

Always name the four core skills:

- `atelier` — onboarding, relay, workspaces.
- `atelier-mentor` — me: skill index, AI-practice advice.
- `atelier-compass` — thinking through a fuzzy decision.
- `atelier-forge` — build a new role skill.

Then read `{root}/docs/atelier/roles.md` and name every role skill it lists,
with its role and what it does. Missing: name the role skills enabled here and
offer `atelier`'s onboarding. A row struck through with `(removed)` is not
announced as available.

Never make the executive memorize skill names — that's your job.

**Done when:** all four core skills and every role skill are named with their
use, and a missing registry was flagged with an onboarding offer.

## AI-practice advice

Business question — pricing, hiring, strategy: redirect to `atelier-compass`
or the relevant role skill, and offer the AI angle instead.

Read `progression.md` and follow `references/progression.md`: establish the
current practice before recommending anything.

Pick the `references/` file matching the question and recommend exactly
**one** next practice — never the full roadmap. Practice exercisable here:
invite them to try it now, on their actual work.

Adoption confirmed: propose (never silently) recording the practice, the
struggle, and the next step — see `references/memory-protocol.md`.

**Done when:** exactly one next practice is recommended, tied to the
established practice, and no position was taken on the business question.

## Tutorial

Asked how Claude works, for a tutorial, or to revisit a module: load
`references/tutorial.md` and follow it. The executive may leave at any
point — say so before the first module.

**Done when:** the exit rule was stated before the first module, and the
completed modules were proposed for `progression.md`.

## Capability questions

"Can Claude do X" is never answered from memory — capabilities shift monthly.
Load `references/capabilities.md` and verify against `references/sources.md`,
citing the source.

**Done when:** the answer cites a verified source, or says it couldn't be
verified.

## Atelier's words

`references/glossary.md` fixes what root, profile, relay, registry, tutorial,
role skill and core skill mean. Use those words, as written.
```

- [ ] **Step 6: Verify AC4 and the byte-exact pointer**

```bash
wc -w < skills/atelier-mentor/fr/SKILL.md   # must be ≤ 550 (expect 545)
wc -w < skills/atelier-mentor/en/SKILL.md   # must be ≤ 550 (expect 543)
```

If either exceeds 550, trim body prose — never the pointer paragraph, never a completion criterion, never the four core-skill bullets.

- [ ] **Step 7: Check what the trims cost**

Two behaviours moved from the body into reference files: the capability-question detail now leans on `references/capabilities.md` (which already opens by pointing back at this workflow), and the "establish the current practice first" instruction now leans on `references/progression.md` (which already documents it). Re-read both reference files and confirm each still carries the instruction the body used to spell out. If either does not, add it there — the instruction must exist in exactly one place, not zero.

Then re-run the two existing mentor scenarios whose ticked boxes rested on the trimmed prose — `tests/atelier-mentor/en/capability-question.md` and `tests/atelier-mentor/fr/question-daffaires.md` — as with-skill dispatches against the staged skill, and append a dated note to their `## Verification notes` recording that the boxes still pass after the trim. If a box no longer passes, restore the instruction to the body and re-trim elsewhere.

- [ ] **Step 8: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`. This is the run that proves AC5: `check_triggers` compares every new `triggers:` term against the new descriptions with `grep -qF`. A failure here names the offending scenario file and term.

- [ ] **Step 9: Commit**

```bash
git add skills/atelier-mentor/fr/SKILL.md skills/atelier-mentor/en/SKILL.md \
        tests/atelier-mentor/fr tests/atelier-mentor/en
git commit -m "feat(mentor): route to the tutorial from SKILL.md, with its scenarios"
```

---

## Task 6: The `progression.md` format gains a tutorial section

Covers **AC19**, and the documented format side of **AC23**.

**Files:**
- Modify: `skills/atelier-mentor/fr/references/progression.md`
- Modify: `skills/atelier-mentor/en/references/progression.md`

**Interfaces:**
- Produces: the heading « Modules du tutoriel couverts » / "Tutorial modules covered" and its one-dated-line-per-module format. Task 7's runbook writes it; Task 11's `tutoriel-reprise` run reads it back.

- [ ] **Step 1: Add the section to the FR format block**

In `skills/atelier-mentor/fr/references/progression.md`, inside the `## Format de progression.md` fenced block, add the fifth section **after** « Prochaine étape convenue »:

```markdown
## Modules du tutoriel couverts
- AAAA-MM-JJ — module <n> — <titre du module>
```

Add the matching lines to the worked example in the same file, so the example shows the section filled:

```markdown
## Modules du tutoriel couverts
- 2026-07-30 — module 1 — Comment Claude « pense »
- 2026-07-30 — module 2 — Les modèles et l'effort
```

Then add one short paragraph under the format block:

```markdown
Les modules du tutoriel ne vont **jamais** dans « Pratiques adoptées » : cette
section-là sert à choisir la marche suivante de l'échelle, et savoir ce qu'est
une fenêtre de contexte n'est pas une marche. Une ligne par module terminé,
datée du jour où il a été couvert.
```

- [ ] **Step 2: Add the section to the EN format block**

Same three edits in `skills/atelier-mentor/en/references/progression.md`, authored in English:

```markdown
## Tutorial modules covered
- YYYY-MM-DD — module <n> — <module title>
```

Example lines:

```markdown
## Tutorial modules covered
- 2026-07-30 — module 1 — How Claude "thinks"
- 2026-07-30 — module 2 — Models and effort
```

And the paragraph:

```markdown
Tutorial modules **never** go under "Practices adopted": that section is what
you read to pick the next rung on the ladder, and knowing what a context window
is is not a rung. One line per completed module, dated the day it was covered.
```

- [ ] **Step 3: Verify**

```bash
grep -n 'Modules du tutoriel couverts' skills/atelier-mentor/fr/references/progression.md
grep -n 'Tutorial modules covered' skills/atelier-mentor/en/references/progression.md
```

Expected: two hits per file (format block and example). Confirm by reading that the section is distinct from "Pratiques adoptées" / "Practices adopted" and holds one dated line per module (AC19).

- [ ] **Step 4: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 5: Commit**

```bash
git add skills/atelier-mentor/fr/references/progression.md \
        skills/atelier-mentor/en/references/progression.md
git commit -m "feat(mentor): record tutorial modules in the progression format"
```

---

## Task 7: `references/tutorial.md` — the runbook

Covers **AC8**, **AC9**, **AC10**, **AC11**, **AC12**, **AC17**, **AC20**, **AC21**, **AC22**, **AC23**, **AC24**, **AC25**, **AC42**, **AC43**, **AC44**.

**Files:**
- Create: `skills/atelier-mentor/fr/references/tutorial.md`
- Create: `skills/atelier-mentor/en/references/tutorial.md`

**Interfaces:**
- Consumes: the `## Tutoriel` / `## Tutorial` section of `SKILL.md` (Task 5); the progression section heading (Task 6); `references/memory-protocol.md` and `references/sources.md` (already shipped).
- Produces: the module index — the seven filenames from the contract table, each with its on-screen title — which Tasks 8–10 must match exactly.

- [ ] **Step 1: Write the FR runbook**

Create `skills/atelier-mentor/fr/references/tutorial.md`. It must state each of the following, and each one maps to a criterion a scenario checks. Write it as a runbook — positive recipes, "do this next" — not as an explanation.

```markdown
# Le tutoriel

Sept modules qui expliquent comment Claude fonctionne. Deux modes : **complet**
(les sept, dans l'ordre) et **révision** (la personne en choisit).

## Les sept modules

| # | Titre à l'écran | Fichier |
|---|---|---|
| 1 | Comment Claude « pense » | `tutorial/01-comment-claude-pense.md` |
| 2 | Les modèles et l'effort | `tutorial/02-modeles-et-effort.md` |
| 3 | Les surfaces | `tutorial/03-surfaces.md` |
| 4 | Compétences, connecteurs, plugiciels | `tutorial/04-competences-connecteurs-plugiciels.md` |
| 5 | Les fonctions d'organisation | `tutorial/05-fonctions-organisation.md` |
| 6 | L'hygiène des compétences | `tutorial/06-hygiene-des-competences.md` |
| 7 | Confiance et vérification | `tutorial/07-confiance-et-verification.md` |

## À chaque entrée

1. **Lis `{racine}/docs/atelier/progression.md`** et repère la section
   « Modules du tutoriel couverts ».
2. **Dis la règle de sortie avant le contenu du premier module** : « tu peux
   arrêter n'importe quand, on note où tu es rendu, pis on reprend plus tard ».
3. **Offre les deux modes** — complet ou révision — même quand la personne
   arrive par une question comme « explique-moi Claude ».
4. **Présente le sélecteur** (voir plus bas), même en mode complet, pour dire ce
   qui est déjà couvert.

## Le sélecteur

Les **sept** modules, numérotés de 1 à 7, toujours — jamais une liste
raccourcie. À côté de chaque module déjà couvert, sa date. Puis **nomme ta
recommandation** : les modules pas encore couverts, et seulement ceux-là.

- **Pas de `progression.md`** : les sept apparaissent sans marque, et ta
  recommandation est le tutoriel complet.
- **Quelques modules couverts** : marque-les avec leur date, recommande les
  autres. Si la personne demandait le tutoriel **complet**, nomme ce qui est
  déjà couvert et propose de ne faire que le reste — pas de reprise du début.
- **Les sept couverts** : dis-le, pis propose **un** module précis à revoir
  plutôt que la séquence complète.

## Un module à la fois

Un seul module par message. Avant d'envoyer le suivant, pose une question qui
oblige la personne à **redire le concept dans ses mots ou à l'appliquer à son
travail** — jamais « est-ce que ça fait du sens ? » — et attends sa réponse.

Chaque module finit sur sa section pratique. Suis-la telle qu'elle est écrite :
certaines s'exercent ici, d'autres nomment où aller et quoi y faire.

## Les affirmations datées

Les modules 3, 4 et 5 portent des affirmations sur ce que Claude peut faire
aujourd'hui. Chacune porte une date de vérification et sa source.

- Quand tu enseignes une de ces affirmations, **montre la date à la personne**.
  Une date qui reste dans le fichier sans que la personne la voie ne compte pas.
- Si la personne dit qu'elle va bâtir quelque chose là-dessus : **propose de
  revérifier** dans `references/sources.md`. Si tu ne peux pas vérifier d'ici,
  dis-le et nomme où regarder.
- Ne présente jamais une affirmation datée comme vérifiée aujourd'hui.

## Consigner les modules couverts

Une **seule** proposition, à la sortie ou quand le dernier module finit —
jamais une par module, jamais en silence. Suis
`references/memory-protocol.md`.

- Seuls les modules **terminés** entrent dans la proposition. Un module
  abandonné en cours de route ne laisse rien.
- La proposition dit elle-même que **rien ne sera écrit sans une réponse
  explicite**, et que si la réponse ne vient pas, le dossier attend la
  prochaine session.
- **Pas de réponse = rien d'écrit.** C'est la règle de pression de temps du
  relais, telle quelle.
- Si `progression.md` n'existe pas encore et que la personne accepte, crée-le
  avec les titres de section du format documenté dans
  `references/progression.md`, section « Modules du tutoriel couverts »
  comprise.

## Sans accès aux dossiers

Aucune écriture n'est possible. Affiche les lignes à ajouter à
`progression.md`, prêtes à copier, dis exactement où les enregistrer, et dis
clairement que **tu n'as rien écrit**. Jamais « c'est noté ».

**Critère d'achèvement :** la règle de sortie a été dite avant le premier
module, les modules ont été livrés un par un avec une question d'application
entre chaque, et les modules terminés ont fait l'objet d'une seule proposition
d'écriture — acceptée, refusée, ou restée sans réponse et donc sans écriture.
```

- [ ] **Step 2: Write the EN runbook**

`skills/atelier-mentor/en/references/tutorial.md` — same structure, same rules, authored in English, with the EN filenames and EN on-screen titles:

| # | Title | File |
|---|---|---|
| 1 | How Claude "thinks" | `tutorial/01-how-claude-thinks.md` |
| 2 | Models and effort | `tutorial/02-models-and-effort.md` |
| 3 | Surfaces | `tutorial/03-surfaces.md` |
| 4 | Skills, connectors, plugins | `tutorial/04-skills-connectors-plugins.md` |
| 5 | Organizing features | `tutorial/05-organizing-features.md` |
| 6 | Skill hygiene | `tutorial/06-skill-hygiene.md` |
| 7 | Trust and verification | `tutorial/07-trust-and-verification.md` |

- [ ] **Step 3: Check the runbook against its criteria**

Read each file and confirm, one by one, that it states: the exit rule before the first module's content (AC8); seven numbered modules with dates beside covered ones and a recommendation naming only uncovered ones (AC9); the no-`progression.md` branch (AC10); the all-seven-covered branch (AC11); the full-tutorial-with-partial-coverage branch (AC43); one module per message with an application question, not "does that make sense?" (AC12); show the date (AC42); offer to re-verify, or say it cannot and name where to look, never presenting a dated claim as current (AC17); exactly one propose-and-wait (AC20); completed modules only (AC21); the proposal states nothing is written without an answer and that the record waits (AC22); lazy creation with the documented headings (AC23); the no-folder-access path with no claimed write (AC25); and that the two modes are offered on an on-demand entry too (AC44).

- [ ] **Step 4: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 5: Commit**

```bash
git add skills/atelier-mentor/fr/references/tutorial.md \
        skills/atelier-mentor/en/references/tutorial.md
git commit -m "feat(mentor): add the tutorial runbook in both locales"
```

---

## Task 8: Modules 01 and 02

Covers **AC13** (rows 01, 02) and **AC41** (modules 01, 02).

**Files:**
- Create: `skills/atelier-mentor/fr/references/tutorial/01-comment-claude-pense.md`
- Create: `skills/atelier-mentor/fr/references/tutorial/02-modeles-et-effort.md`
- Create: `skills/atelier-mentor/en/references/tutorial/01-how-claude-thinks.md`
- Create: `skills/atelier-mentor/en/references/tutorial/02-models-and-effort.md`

**Interfaces:**
- Consumes: the bullets under `## Module 01` and `## Module 02` in `docs/tutorial-corpus.md`.
- Produces: nothing later tasks read. Each file stands alone.

- [ ] **Step 1: Write FR module 01**

`01-comment-claude-pense.md`. Body in the executive's language — no jargon left undefined, no code, no terminal. It must cover, per AC41: the context window; tokens; why long **and** compacted conversations degrade; and the tie to fresh conversations plus memory in files (the relay, corporate memory). Use this shape:

```markdown
# Module 1 — Comment Claude « pense »

<Le concept, en trois ou quatre paragraphes courts : la fenêtre de contexte
comme « tout ce que Claude voit d'un coup », les jetons comme unité qui la
remplit, ce qui arrive quand elle se remplit, et pourquoi une conversation
compactée n'est pas la même chose qu'une conversation neuve.>

<Le lien avec Atelier : conversations courtes + mémoire dans des fichiers.
Nomme le relais et la mémoire d'entreprise avec les mots du glossaire.>

## À essayer tout de suite

Demande-moi un relais, là, maintenant, sur ce qu'on vient de faire. Tu vas voir
le mécanisme dont je viens de parler : ce qui compte s'en va dans un fichier, et
la prochaine conversation repart courte au lieu de traîner celle-ci.
```

**No version-specific numbers.** A context-window size or a token count is a capability-sensitive claim (ADR-0011) and would have to carry a dated annotation; teach the concept without one.

The practice section is **in-conversation** (AC13): it invites the executive to try the concept in this conversation. It must not name an interface control to go press.

- [ ] **Step 2: Write FR module 02**

`02-modeles-et-effort.md`. Covers, per AC41: model families, what an effort level changes, and the speed/depth trade-off. Practice is **external** (AC13) — the model and effort pickers are interface controls mentor cannot operate — so the practice section **names where to go and what to do there, and contains no in-conversation exercise**:

```markdown
## À essayer de ton bord

Ouvre le sélecteur de modèle <à l'endroit vérifié> et regarde ce que tu as.
Prends la conversation la plus importante de ta semaine et refais-la une fois
au niveau d'effort le plus élevé. Compare les deux réponses.
```

Teach the families **by shape** — a fast tier, a balanced tier, a deep tier — not as a version list. If a real model name is unavoidable, it becomes a capability-sensitive claim and carries the dated annotation block from the contract section.

- [ ] **Step 3: Write EN modules 01 and 02**

`01-how-claude-thinks.md` and `02-models-and-effort.md`, authored in English to the same requirements. Practice headings: `## Try it right now` (module 01) and `## Try it on your own` (module 02).

- [ ] **Step 4: Verify the practice types**

Read all four practice sections. Module 01's must be exercisable in this conversation; module 02's must name a place to go and an action to take there, and must contain no in-conversation exercise (AC13). Then check each file against its AC41 concept list, one concept at a time.

- [ ] **Step 5: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 6: Commit**

```bash
git add skills/atelier-mentor/fr/references/tutorial skills/atelier-mentor/en/references/tutorial
git commit -m "feat(mentor): add tutorial modules 1 and 2"
```

---

## Task 9: Modules 03, 04 and 05 — the dated trio

Covers **AC15**, **AC16**, **AC18**, **AC41** (modules 03, 05), **AC13** (rows 03, 04, 05).

**Files:**
- Create: `skills/atelier-mentor/fr/references/tutorial/03-surfaces.md`
- Create: `skills/atelier-mentor/fr/references/tutorial/04-competences-connecteurs-plugiciels.md`
- Create: `skills/atelier-mentor/fr/references/tutorial/05-fonctions-organisation.md`
- Create: `skills/atelier-mentor/en/references/tutorial/03-surfaces.md`
- Create: `skills/atelier-mentor/en/references/tutorial/04-skills-connectors-plugins.md`
- Create: `skills/atelier-mentor/en/references/tutorial/05-organizing-features.md`

**Interfaces:**
- Consumes: the verified fact set and the French interface labels recorded at the end of `docs/tutorial-corpus.md` (Task 4, Steps 1–2, 4), and the annotation block from this plan's contract section.

- [ ] **Step 1: Write module 03 in both locales**

Covers, per AC41: Chat vs the Cowork tab, claude.ai web vs Desktop, **including folder access and connector reach**. Every claim about what a surface can do carries the annotation block, filled with the date and source recorded in Task 4:

```markdown
> **Vérifié le 2026-08-XX** — source : centre d'aide Anthropic, article <n>
> (« <titre> »). Les capacités changent de mois en mois : montre cette date à la
> personne, et propose de revérifier dans `references/sources.md` avant qu'elle
> bâtisse quoi que ce soit dessus.
```

Claims verified in one pass against one source may share a single annotation covering the block they sit under — one annotation per verified group, not one per sentence. Practice is **external**: name the other surface to open and what to compare there.

- [ ] **Step 2: Write module 04 in both locales**

What a skill is, what a connector is, what a plugin is — three things executives merge into one — then the per-surface matrix. AC16 requires the matrix to state that **skills bundled in a plugin work on claude.ai web chat, the Desktop Chat tab, and Cowork for paid plans**, and that **hooks and sub-agents run only in Cowork**, annotated with a last-verified date **later than 2026-07-21** and a source of a kind `references/sources.md` permits (the Anthropic/Claude help center, or Claude's release notes).

If Task 4's re-verification found the facts have changed, ship what the source now says and flag the AC16 divergence to the user — do not ship the older wording under a newer date.

Practice is **external**: enabling a skill or a connector happens in account settings, so name where and what to do there.

- [ ] **Step 3: Write module 05 in both locales**

Covers, per AC41: Projects, Artifacts, Scheduled and Dispatch — all four. Availability and plan eligibility carry the annotation. Practice is **external**: creating a Project is an interface action.

- [ ] **Step 4: Apply the French interface labels**

In the three FR files, name skills, connectors, plugins, Projects and Artifacts using **Claude's own French on-screen labels** as verified in Task 4. Each label is covered by a last-verified date and named source recording how it was verified; labels verified in one pass against one source may share a single annotation (AC18). Where an on-screen label is an anglicism, an OQLF term may follow as a parenthetical gloss — never in place of the label.

- [ ] **Step 5: Sweep for undated capability claims**

Re-read all six files and list every sentence that asserts current surface availability, folder or connector access, feature support, plan eligibility, an interface label, or a product limit. Every one of them must sit under an annotation block. That list is what "capability-sensitive" means (AC15) — nothing in it ships undated.

```bash
grep -c 'Vérifié le' skills/atelier-mentor/fr/references/tutorial/0[345]*.md
grep -c 'Last verified' skills/atelier-mentor/en/references/tutorial/0[345]*.md
```

Expected: at least one per file, all six files. A zero means a file ships undated claims.

- [ ] **Step 6: Verify the dates are later than 2026-07-21**

Read each annotation's date. Any date at or before 2026-07-21 fails AC16 — it means issue #9's date was copied instead of the re-verification's.

- [ ] **Step 7: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 8: Commit**

```bash
git add skills/atelier-mentor/fr/references/tutorial skills/atelier-mentor/en/references/tutorial
git commit -m "feat(mentor): add tutorial modules 3 to 5 with dated capability claims"
```

---

## Task 10: Modules 06 and 07

Covers **AC14**, **AC41** (module 06), **AC13** (rows 06, 07), and closes **AC6**.

**Files:**
- Create: `skills/atelier-mentor/fr/references/tutorial/06-hygiene-des-competences.md`
- Create: `skills/atelier-mentor/fr/references/tutorial/07-confiance-et-verification.md`
- Create: `skills/atelier-mentor/en/references/tutorial/06-skill-hygiene.md`
- Create: `skills/atelier-mentor/en/references/tutorial/07-trust-and-verification.md`

**Interfaces:**
- Consumes: `references/fact-checking.md` (already shipped, both locales) — module 07 links to it.

- [ ] **Step 1: Write module 06 in both locales**

Covers, per AC41: the hygiene symptoms, and the ~10–15 enabled-skill figure **stated as a smell, not a rule**. Content: one skill per role or recurring job, not per task; if two descriptions could fire on the same phrase, merge or sharpen one; disable anything unused for a month; the symptoms (the wrong skill answering, a skill that never fires, two skills answering the same request).

The soft ceiling must read as a smell. Something like: « passé une dizaine ou une quinzaine de compétences activées, attends-toi à ce que la mauvaise réponde de temps en temps — c'est un signal, pas une règle ». Never « ne dépasse pas 15 ».

Practice is **in-conversation** (AC13): mentor can see which skills are enabled in the conversation — `onboarding.md` Step 4 already relies on this — so the practice reviews the executive's actual roster against the symptoms, on the spot.

- [ ] **Step 2: Write module 07 in both locales**

Covers: what a hallucination is, and why Claude sounds confident when it is wrong — **as concepts**. It links to `references/fact-checking.md` for the practices and reproduces **no** procedure from it (AC14). Concretely: module 07 must not describe the approved-facts registry, must not describe separating producing from checking, and must not describe red-teaming a decision. It says those practices live in `fact-checking.md` and names the file.

Practice is **in-conversation** (AC13): the executive hands mentor a claim, and mentor fact-checks it now.

- [ ] **Step 3: Confirm the cross-reference does not double back**

Read `skills/atelier-mentor/{fr,en}/references/fact-checking.md` and confirm it does **not** define hallucination or misplaced confidence (AC14's second half). At the time this plan was written it does not — it opens on the practices. If a definition has crept in, remove it and leave the pointer.

- [ ] **Step 4: Verify AC6 — exactly seven files per locale, exact names**

```bash
/usr/bin/find skills/atelier-mentor/fr/references/tutorial -maxdepth 1 -name '*.md' | sort
/usr/bin/find skills/atelier-mentor/en/references/tutorial -maxdepth 1 -name '*.md' | sort
ls skills/atelier-mentor/fr/references/tutorial.md skills/atelier-mentor/en/references/tutorial.md
```

Expected, exactly — no more, no fewer, no renames:

```
fr: 01-comment-claude-pense.md 02-modeles-et-effort.md 03-surfaces.md
    04-competences-connecteurs-plugiciels.md 05-fonctions-organisation.md
    06-hygiene-des-competences.md 07-confiance-et-verification.md
en: 01-how-claude-thinks.md 02-models-and-effort.md 03-surfaces.md
    04-skills-connectors-plugins.md 05-organizing-features.md
    06-skill-hygiene.md 07-trust-and-verification.md
```

- [ ] **Step 5: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 6: Commit**

```bash
git add skills/atelier-mentor/fr/references/tutorial skills/atelier-mentor/en/references/tutorial
git commit -m "feat(mentor): add tutorial modules 6 and 7"
```

---

## Task 11: Run the mentor scenarios with the skill

Covers **AC36**, **AC37**, **AC38** (mentor half), and is the evidence for **AC8–AC12**, **AC17**, **AC20–AC25**, **AC42–AC44**.

**Files:**
- Modify: the eight `tests/atelier-mentor/{fr,en}/tutoriel-*.md` files (`## Verification notes`, and the `## Expected behaviors` checkboxes).

- [ ] **Step 1: Stage the built skill**

```bash
bash scripts/build.sh --lang all
mkdir -p /tmp/atl-tuto/fr /tmp/atl-tuto/en
unzip -q -o dist/atelier-mentor-fr.zip -d /tmp/atl-tuto/fr
unzip -q -o dist/atelier-mentor-en.zip -d /tmp/atl-tuto/en
/usr/bin/find /tmp/atl-tuto -name '*.md' | sort
```

Confirm each staged tree carries `references/tutorial.md` and all seven `references/tutorial/` files — this is **AC7**'s bash half, recorded here and re-checked in Task 24.

- [ ] **Step 2: Run `tutoriel-declenchement` (both locales)**

Two dispatches, one per locale, each a fresh `general-purpose` subagent. Give it exactly two directories: the staged skill (read-only) and a sandbox root (read-write) seeded with `docs/atelier/company-profile.md` and `docs/atelier/roles.md`, and no `progression.md`. Tell it plainly nothing else is coming and to self-play all turns in one reply using real tool calls. Give the `## Prompt` text verbatim.

Then judge: tick only what the run actually demonstrated. AC44's claim — reaching the tutorial from trigger vocabulary with no skill named — is inferred, not controlled, in a dispatch that hands the agent the skill; note that in `## Verification notes` exactly as `tests/README.md` § "The triggers without the skill being named box" requires, and leave the box's status honest.

- [ ] **Step 3: Run `tutoriel-selecteur` (both locales)**

Same setup, but seed the sandbox's `docs/atelier/progression.md` with the documented headings and a « Modules du tutoriel couverts » / "Tutorial modules covered" section holding modules 1 and 3 with dates. Then verify by reading the reply: seven numbered modules, dates beside 1 and 3, and a recommendation naming exactly modules 2, 4, 5, 6, 7.

- [ ] **Step 4: Run `tutoriel-sortie` (both locales) and check the disk**

Same setup, no `progression.md`. Feed all four turns, ending with the abandonment and no further answer.

After the run, check the sandbox directly — this is the box that matters:

```bash
/usr/bin/find /tmp/atl-run-sortie-fr -name 'progression.md'
```

Expected: **no such file**. If one exists, AC22 and AC37 fail: the agent wrote without an answer. Record the finding rather than re-running until it passes.

- [ ] **Step 5: Run `tutoriel-reprise` (both locales) — two dispatches each**

Follow `tests/README.md` § "Multi-session scenarios need multiple dispatches":

1. Dispatch session A into a fresh sandbox; it runs the full tutorial through module 2 and gets an explicit yes to the write.
2. Inspect the sandbox directly — read `docs/atelier/progression.md` and confirm the headings and the two dated lines (AC19, AC23).
3. Dispatch a **different** fresh agent for session B, pointed at the **same** sandbox, told nothing about session A's conversation — only that a project folder with prior work is normal for a returning executive.
4. Judge session B's picker against what is actually on disk: modules 1 and 2 marked with their dates, recommendation naming only the five remaining (AC24).

- [ ] **Step 6: Fill in the verification notes**

For each of the eight files: quote the evidence, name the sandbox paths, and record on-disk confirmation rather than the agent's self-report. Tick only established boxes; **every unticked box carries a stated reason** (AC38).

- [ ] **Step 7: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 8: Commit**

```bash
git add tests/atelier-mentor
git commit -m "test(mentor): record the tutorial scenario baseline and verification runs"
```

---

## Task 12: Re-run the cross-skill trigger scenario

Covers **AC39**.

**Files:**
- Modify: `tests/_cross-skill/declenchement.md`

- [ ] **Step 1: Re-run the selection test with the new description staged**

Two dispatches, one per locale, exactly as `tests/_cross-skill/declenchement.md`'s own `## Verification notes` describes: stage all fourteen built skills' `name`/`description` frontmatter side by side per locale — mentor's **new** description among them — and put the same nine bare prompts to a fresh reasoning pass, with no skill named. Tell each agent to treat every prompt as the cold-start first message of an unrelated conversation.

Add one prompt per locale drawn from the new tutorial trigger vocabulary (FR: « Explique-moi Claude, je comprends rien à la fenêtre de contexte » / EN: "How does Claude work — what's a context window?") so the file records whether the longer description now wins or loses those.

- [ ] **Step 2: Update the results tables**

Rewrite both per-locale results tables with the new run's outcomes and the new run date. Keep the existing findings section; append what changed. Do **not** delete the recorded 2026-07-22 finding — the file's value is the history.

- [ ] **Step 3: Report the #11 tie**

Whatever the re-run shows about the `atelier`/`atelier-mentor` overlap, record it in issue #11 — not in this branch, and not by editing a description:

```bash
gh issue comment 11 --body "<what the re-run showed about the tie, with the date and both locales' outcomes>"
```

AC39 requires the change to be reported there; the spec explicitly does not resolve the tie here.

- [ ] **Step 4: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 5: Commit**

```bash
git add tests/_cross-skill/declenchement.md
git commit -m "test(mentor): re-run the trigger selection scenario with the new description"
```

---

## Task 13: `docs/mentor-corpus.md` cross-reference

Covers **AC45**.

**Files:**
- Modify: `docs/mentor-corpus.md`

- [ ] **Step 1: Add the cross-reference**

In the `## "How do I stop the AI from making things up?"` section of `docs/mentor-corpus.md`, add a closing line:

```markdown
**Cross-reference — tutorial module 07.** The tutorial holds the *concepts*
(what a hallucination is, why Claude sounds confident when it is wrong);
`references/fact-checking.md` holds the *practices* above. The two do not
restate each other. See `docs/tutorial-corpus.md`.
```

- [ ] **Step 2: Verify**

```bash
grep -n 'module 07\|tutorial-corpus' docs/mentor-corpus.md
```

- [ ] **Step 3: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 4: Commit**

```bash
git add docs/mentor-corpus.md
git commit -m "docs(mentor): cross-reference the tutorial from the mentor corpus"
```

---

## Task 14: `CLAUDE.md` pointer and the no-change doc confirmations

Covers **AC46**, and the "Documentation Updates" rows the spec marks *no change*.

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Add exactly one pointer line**

Under the existing design-spec pointers at the top of `CLAUDE.md`, after the `Release automation:` line:

```markdown
Mentor tutorial: docs/superpowers/specs/2026-08-10-mentor-tutorial-design.md
```

Nothing more. The index stays an index — no summary of the tutorial, no new section.

- [ ] **Step 2: Verify the line count and the diff**

```bash
wc -l < CLAUDE.md          # must stay under 300 (expect 53)
git diff --stat CLAUDE.md  # expect 1 insertion, 0 deletions
```

- [ ] **Step 3: Confirm the no-change docs, explicitly**

Check each and confirm nothing is required, per the spec's Documentation Updates table:

- [ ] `docs/AUTHORING.md` — the ~550-word target is unchanged, and the tutorial's `SKILL.md` footprint was paid for by trimming (Task 5). No edit.
- [ ] `tests/README.md` — the scenario format and the multi-session dispatch guidance already cover the ten new scenarios. No edit.
- [ ] `docs/INSTALL.fr.md`, `docs/INSTALL.en.md` — nothing about installing or updating changes. No edit.

```bash
git status --short docs/AUTHORING.md tests/README.md docs/INSTALL.fr.md docs/INSTALL.en.md
```

Expected: empty output.

- [ ] **Step 4: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 5: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: point at the mentor tutorial spec"
```

---

## Task 15: Config and infrastructure confirmation sweep

Covers every row of the spec's *Config & Infrastructure Impact* table, and **AC7**'s bash half.

**Files:** none modified — this task's deliverable is verified evidence that none needed to be.

- [ ] **Step 1: Confirm each config file is untouched and does not need touching**

Tick each after checking:

- [ ] `scripts/build.sh` — `cp -R "$src/."` (line ~114) copies `references/tutorial/` recursively; `zip -q -r` (line ~147) archives it. No change. Known gap, recorded not fixed: `check_reference_pointer_drift` globs `references/*.md` non-recursively, so nested module files escape the Company Profile pointer drift check — acceptable, since no module carries shared canonical text.
- [ ] `scripts/build.ps1` — `Copy-Item -Recurse` and `Compress-Archive -Path <stage>/*` behave the same; `Test-ReferencePointerDrift` has the same non-recursive gap. No change.
- [ ] `scripts/tests/build_test.sh`, `scripts/tests/build_test.ps1`, `scripts/tests/shared_test.sh`, `scripts/tests/authoring_test.sh` — no build behaviour changed. No change.
- [ ] `.github/workflows/*` — the mechanical checks are file-driven; new scenarios and reference files are picked up without a workflow edit. No change.
- [ ] `release-please-config.json`, `.release-please-manifest.json`, `version.txt` — no new skill, so `extra-files` is unchanged; version lines stay release-please-owned. No change.
- [ ] `skills/names.tsv` — no new skill name. No change.
- [ ] `docs/WHATS-NEW.md` — `check_whats_new` keys off `version.txt`, which release-please moves; the bilingual entry is written on the release PR, not here. No change on this branch.
- [ ] `.gitattributes` — `* text=auto eol=lf` already covers the new files. No change.

```bash
git status --short scripts/ .github/ release-please-config.json \
  .release-please-manifest.json version.txt skills/names.tsv \
  docs/WHATS-NEW.md .gitattributes
```

Expected: empty output. Anything listed means an unintended edit — revert it.

- [ ] **Step 2: Confirm the ZIP contents (AC7, bash)**

```bash
bash scripts/build.sh --lang all
unzip -l dist/atelier-mentor-fr.zip | grep 'references/tutorial'
unzip -l dist/atelier-mentor-en.zip | grep 'references/tutorial'
```

Expected in each: `references/tutorial.md` plus all seven `references/tutorial/` files for that locale.

- [ ] **Step 3: Run the script test suites**

```bash
bash scripts/tests/build_test.sh
bash scripts/tests/shared_test.sh
bash scripts/tests/authoring_test.sh
```

All must pass. `authoring_test.sh` is the one most likely to react to the `SKILL.md` change — if it fails, read what it asserts before changing anything.

No commit — this task produces evidence, not a diff. If anything failed, fix it in the task that owns the file and re-run.

---

## Task 16: Open PR 1

- [ ] **Step 1: Push and open**

```bash
git push -u origin feat/mentor-tutorial
gh pr create --base dev --title "feat(mentor): the Claude-basics tutorial" --body "<body>"
```

Body: what it adds, the AC range it satisfies (AC1–AC25, AC34–AC38, AC41–AC46), a link to issue #9 and to the spec, and a note that AC39/AC40 gate both PRs. The body ends on the last content line — no attribution footer.

- [ ] **Step 2: Confirm CI is green**

```bash
gh pr checks --watch
```

Both the Linux and the Windows job must pass. The Windows job is where `scripts/build.ps1 -Check` actually runs if `pwsh` is unavailable locally.

---

# PR 2 — `feat(atelier)`: the onboarding offer

Branch from `dev` again (or stack on PR 1's branch if PR 1 has not merged — say which in the PR body).

## Task 17: The hub scenario and its baseline

Covers **AC36** (hub half) and **AC38** (baseline half).

**Files:**
- Create: `tests/atelier/fr/accueil-offre-tutoriel.md`
- Create: `tests/atelier/en/accueil-offre-tutoriel.md`

**Interfaces:**
- Consumes: `atelier`'s existing description only. Its `triggers:` may use **only** terms already there — FR `accueil`, `profil d'entreprise`, `commencer`; EN `onboarding`, `Company Profile`, `get started` — because AC5 forbids changing that description.

- [ ] **Step 1: Write the FR scenario**

`tests/atelier/fr/accueil-offre-tutoriel.md`:

```markdown
---
skill: atelier
locale: fr
triggers:
  - accueil
  - commencer
---

## Prompt

Je viens d'installer Atelier. On commence l'accueil ?

## Expected behaviors

- [ ] The offer comes **after** Step 1 (the root is named and confirmed) and **before** the interview's first question
- [ ] Three choices are offered: le tutoriel complet, une révision, ou passer
- [ ] The **full tutorial** is named as the recommendation
- [ ] The exit rule is explained at the offer — la personne peut quitter le tutoriel et revenir finir l'accueil
- [ ] On « révision », the picked modules run inline and onboarding resumes at Step 2
- [ ] On « complet », the hub produces the three-section short relais, names `atelier-mentor`, gives the opening line to type, says they return to finish onboarding, and **stops**
- [ ] On « passer », onboarding continues at Step 2 and the offer is not raised again in that onboarding
- [ ] The offer also fires on a re-run of onboarding
- [ ] The hub never reads `progression.md`

## Baseline notes

_Filled in after the skill-absent run._

## Verification notes

_Filled in after the with-skill runs._
```

- [ ] **Step 2: Write the EN scenario**

`tests/atelier/en/accueil-offre-tutoriel.md`, `locale: en`, `skill: atelier`, triggers `onboarding` and `get started`, prompt authored in English ("I just installed Atelier — can we do the onboarding?"), same checklist in English.

- [ ] **Step 3: Run the baselines**

Two dispatches with the isolation preamble from `tests/README.md`, plus the contamination scan. Expect a plain assistant to have no onboarding flow at all, so every box fails; record it.

- [ ] **Step 4: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`. These triggers are already in `atelier`'s description, so `check_triggers` passes with the scenario committed ahead of the content.

- [ ] **Step 5: Commit**

```bash
git add tests/atelier/fr/accueil-offre-tutoriel.md tests/atelier/en/accueil-offre-tutoriel.md
git commit -m "test(atelier): add the onboarding tutorial-offer scenario"
```

---

## Task 18: `relais.md` gains the short form

Covers **AC31**, **AC33**.

**Files:**
- Modify: `skills/atelier/fr/references/relais.md`
- Modify: `skills/atelier/en/references/relais.md`

**Interfaces:**
- Produces: the section name Task 19's `onboarding.md` points at — « La forme courte d'accueil » / "The onboarding short form".

- [ ] **Step 1: Add the FR short form**

Insert into `skills/atelier/fr/references/relais.md`, after "Étape 2 — Le document" and before "Ce qui n'entre jamais dans un relais" (the outer fence below is four backticks because the inserted text itself contains a fenced block):

````markdown
---

## La forme courte d'accueil

Une seule situation : l'accueil s'est arrêté à l'offre de tutoriel et la
personne a choisi le tutoriel complet.

**Pas de balayage de consolidation** — à l'étape 1, rien n'a encore été décidé,
donc il n'y a rien à consigner. Trois sections au lieu de cinq :

```markdown
# Relais — tutoriel — AAAA-MM-JJ

## Où en est le travail
L'accueil est commencé : la racine est <le nom du dossier>. L'entretien n'est
pas encore fait.

## Prochaines étapes
- Faire le tutoriel avec `atelier-mentor`, dans une conversation neuve.
- Revenir ensuite finir l'accueil avec `atelier`, à partir de l'entretien.

## Pour la prochaine conversation
Compétence à utiliser : `atelier-mentor` — c'est elle qui donne le tutoriel.
Première phrase à écrire : « Je veux faire le tutoriel. »
```

**Critère d'achèvement de la forme courte :** les trois sections sont remplies,
`atelier-mentor` est nommée avec la première phrase à écrire, et la personne
sait qu'elle revient finir l'accueil après. La règle des cinq sections de
l'étape 2 reste en vigueur pour **tous** les autres relais.

Sans accès aux dossiers : affiche le relais court **en entier**, prêt à copier,
dis où l'enregistrer, et ne dis pas que tu l'as enregistré.
````

- [ ] **Step 2: Add the EN short form**

Same insertion in `skills/atelier/en/references/relais.md`, authored in English, heading "The onboarding short form", with the same three sections, its own completion criterion stated separately, and the same no-folder-access line.

- [ ] **Step 3: Verify AC31**

Read both files and confirm three things are stated: the sweep is skipped, the three sections are named, and the short form's completion criterion is **separate** from the five-section rule — which must still be present and still say five (AC31).

- [ ] **Step 4: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 5: Commit**

```bash
git add skills/atelier/fr/references/relais.md skills/atelier/en/references/relais.md
git commit -m "feat(atelier): add the onboarding short-form relais"
```

---

## Task 19: `onboarding.md` gains the offer

Covers **AC26**, **AC27**, **AC28**, **AC29**, **AC30**, **AC32**.

**Files:**
- Modify: `skills/atelier/fr/references/onboarding.md`
- Modify: `skills/atelier/en/references/onboarding.md`

**Interfaces:**
- Consumes: `relais.md` § "La forme courte d'accueil" / "The onboarding short form" (Task 18).

- [ ] **Step 1: Insert the FR offer between Step 1 and Step 2**

In `skills/atelier/fr/references/onboarding.md`, between "Étape 1 — Établir la racine" and "Étape 2 — L'entretien":

```markdown
---

## L'offre de tutoriel

Après l'étape 1, avant la première question de l'entretien. Dis-le comme ça, ou
presque :

> Avant les questions sur ton entreprise : il y a un tutoriel qui explique
> comment Claude fonctionne — sept modules courts. **Je te recommande de le
> faire au complet** ; c'est ce qui rend tout le reste plus facile après. On
> peut aussi juste en revoir un ou deux, ou passer tout de suite à l'entretien.
> Et tu peux quitter le tutoriel n'importe quand : tu reviens finir l'accueil,
> on ne perd rien.

Le **tutoriel complet** est la réponse recommandée, à chaque exécution.

- **Complet** — écris le relais court (`relais.md`, « La forme courte
  d'accueil ») et **arrête l'accueil ici**. La personne ouvre une conversation
  neuve avec `atelier-mentor`, fait le tutoriel, revient : l'accueil reprend à
  l'étape 2.
- **Révision** — `atelier-mentor` mène le sélecteur et les modules choisis dans
  cette conversation, puis l'accueil reprend à l'étape 2.
- **Passer** — va directement à l'étape 2, et ne repropose pas le tutoriel plus
  loin dans cet accueil. Il reste accessible en tout temps en le demandant à
  `atelier-mentor`.

L'offre est faite à **chaque** accueil, y compris une relance. Ne lis pas
`progression.md` : c'est le dossier de `atelier-mentor`, et c'est lui qui évite
de refaire ce qui est déjà couvert.

**Critère d'achèvement :** les trois choix ont été offerts avec le tutoriel
complet comme recommandation, la règle de sortie a été dite, et la suite
correspond au choix de la personne.
```

- [ ] **Step 2: Add the short relais to "Ce que l'accueil ne crée pas"**

In the same file, in the closing section, after "L'accueil crée exactement deux fichiers : `company-profile.md` et `roles.md`.":

```markdown
Une seule exception : sur la branche « tutoriel complet » de l'offre, l'accueil
produit **en plus** le relais court (`relais.md`, « La forme courte
d'accueil »). Sur les autres branches, non.
```

- [ ] **Step 3: Mirror both edits in EN**

Same two insertions in `skills/atelier/en/references/onboarding.md`, authored in English, heading "The tutorial offer", pointing at `relais.md` § "The onboarding short form".

- [ ] **Step 4: Confirm the hub's Memory block is untouched (AC30)**

```bash
git status --short skills/atelier/fr/SKILL.md skills/atelier/en/SKILL.md
```

Expected: empty. The hub's `SKILL.md` is not edited by this work — the offer lives in the reference file, and the hub still does not read `progression.md`.

- [ ] **Step 5: Verify placement**

```bash
grep -n "^## \|^## Étape\|^## Step" skills/atelier/fr/references/onboarding.md
grep -n "^## " skills/atelier/en/references/onboarding.md
```

Confirm the offer section sits between Step 1 and Step 2 in both files (AC26), and that the "does not create" section names the short relais as the one additional file on the full-tutorial branch only (AC32).

- [ ] **Step 6: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 7: Commit**

```bash
git add skills/atelier/fr/references/onboarding.md skills/atelier/en/references/onboarding.md
git commit -m "feat(atelier): offer the tutorial between onboarding steps 1 and 2"
```

---

## Task 20: Run the hub scenario with the skill

Covers **AC27**, **AC28**, **AC29**, **AC33**, and the verification half of **AC38**.

**Files:**
- Modify: `tests/atelier/{fr,en}/accueil-offre-tutoriel.md`

- [ ] **Step 1: Stage the built hub**

```bash
bash scripts/build.sh --lang all
mkdir -p /tmp/atl-hub/fr /tmp/atl-hub/en
unzip -q -o dist/atelier-fr.zip -d /tmp/atl-hub/fr
unzip -q -o dist/atelier-en.zip -d /tmp/atl-hub/en
```

- [ ] **Step 2: Run the three branches per locale**

Three dispatches per locale — the checklist covers three mutually exclusive branches, and one dispatch cannot demonstrate all three:

1. **« complet » / "full"** — the executive picks the full tutorial. Check the reply carries the three-section short relais, names `atelier-mentor`, gives the opening line to type, says they come back to finish, and that onboarding **stops** rather than continuing to question 1 (AC28).
2. **« révision » / "refresh"** — picks two modules; check they run inline and onboarding then resumes at Step 2 (AC27).
3. **« passer » / "skip"** — check onboarding continues at Step 2 and the offer is never raised again in the rest of that onboarding (AC29).

Plus a fourth dispatch per locale on the **re-run path**: seed the sandbox with an existing `company-profile.md` and `roles.md`, and confirm the offer still fires (AC30).

- [ ] **Step 3: Run the no-folder-access branch (AC33)**

One Desktop-chat style dispatch per locale, following `tests/README.md`: no sandbox at all, the skill's relevant content pasted directly into the prompt, and the agent instructed to call no tools even if some appear available. Pick the full tutorial. Check that the short relais is shown **in full**, ready to copy, and that the reply never claims to have saved it.

- [ ] **Step 4: Fill in the verification notes and tick honestly**

Record which dispatch established which box. Any unticked box carries a stated reason (AC38).

- [ ] **Step 5: Pre-commit gate**

`bash scripts/build.sh --check` → `STATUS: PASS`.

- [ ] **Step 6: Commit**

```bash
git add tests/atelier
git commit -m "test(atelier): record the onboarding tutorial-offer runs"
```

---

## Task 21: Open PR 2

- [ ] **Step 1: Push and open**

```bash
git push -u origin feat/atelier-tutorial-offer
gh pr create --base dev --title "feat(atelier): offer the tutorial at onboarding" --body "<body>"
```

Body: what it adds, AC26–AC33, links to issue #9 and the spec, and — if PR 1 has not merged — a line saying this stacks on it. No attribution footer.

- [ ] **Step 2: Confirm CI is green**

```bash
gh pr checks --watch
```

---

# Closing tasks

## Task 22: Deferred-item verification

**Files:** none.

- [ ] **Step 1: Confirm each deferred issue exists with all four body sections**

```bash
for n in 17 18 19; do
  echo "=== #$n ==="
  gh issue view "$n" --json body --jq .body | grep -E '^## (Context|Required|Integration Points|Priority)'
done
```

Each must print all four headings. Issues #17, #18 and #19 all exist and are open as of this plan's writing; if a body is missing a section, add it with `gh issue edit <n> --body-file <file>` rather than leaving the gap.

- [ ] **Step 2: Confirm the titles match the spec's Deferred Items**

- #17 — Tutorial part-picker: use a surface's interactive choice UI when one exists
- #18 — Build check for stale last-verified dates in shipped reference files
- #19 — Locale-divergent section headings orphan exec-document content on a locale switch

- [ ] **Step 3: Confirm #11 carries the note from Task 12**

```bash
gh issue view 11 --comments | tail -30
```

The re-run's outcome must be recorded there (AC39).

---

## Task 23: Post-implementation check

**Files:** none — this task reads the diff and trusts nothing else.

- [ ] **Step 1: Read the full diff**

```bash
git diff dev...HEAD --stat
git diff dev...HEAD
```

- [ ] **Step 2: Verify every Required Task actually happened**

Tick each only after seeing it in the diff, not from this plan's checkboxes:

- [ ] Glossary entries applied in both locales, exactly one each (Task 1)
- [ ] ADR-0011 and ADR-0012 exist with Status/Context/Decision/Consequences (Tasks 2, 3)
- [ ] `docs/tutorial-corpus.md` exists with seven module sections and the Claims to re-verify index (Task 4)
- [ ] `docs/mentor-corpus.md` cross-reference present (Task 13)
- [ ] `CLAUDE.md` has exactly one added line (Task 14)
- [ ] No config file changed (Task 15)
- [ ] Seven module files per locale, exact names, plus the runbook (Tasks 7–10)
- [ ] Ten scenario files with frontmatter, four sections, both notes filled (Tasks 5, 11, 17, 20)
- [ ] `tests/_cross-skill/declenchement.md` updated (Task 12)

- [ ] **Step 3: Walk AC1–AC46 against the diff**

Read the spec's Acceptance Criteria section and, for each numbered criterion, name the file and the line that satisfies it. Any criterion you cannot point at is not done. Record the walk as a list; do not tick from memory.

- [ ] **Step 4: Re-check the word counts**

```bash
wc -w < skills/atelier-mentor/fr/SKILL.md
wc -w < skills/atelier-mentor/en/SKILL.md
```

Both ≤ 550 (AC4). A late edit to the Tutorial section is the likeliest way this regressed.

---

## Task 24: Final build

Covers **AC7**, **AC40**.

- [ ] **Step 1: Build every ZIP**

```bash
bash scripts/build.sh --lang all
```

Fix anything it reports and re-run until it builds clean. Type-checks and scenario runs do not catch build-time failures.

- [ ] **Step 2: Confirm the tutorial files are in both mentor ZIPs (AC7)**

```bash
unzip -l dist/atelier-mentor-fr.zip | grep -c 'references/tutorial/'   # expect 7
unzip -l dist/atelier-mentor-en.zip | grep -c 'references/tutorial/'   # expect 7
unzip -l dist/atelier-mentor-fr.zip | grep 'references/tutorial.md'
unzip -l dist/atelier-mentor-en.zip | grep 'references/tutorial.md'
```

- [ ] **Step 3: Run both `--check` modes (AC40)**

```bash
bash scripts/build.sh --check
pwsh -File scripts/build.ps1 -Check
```

**`pwsh` is not installed on this machine.** Install PowerShell and run it, or — if that is not possible — say so plainly and rely on the Windows CI job, quoting its green run as the evidence for the PowerShell half of AC40. Do not claim it passed locally when it was not run.

- [ ] **Step 4: Confirm the PowerShell ZIPs too (AC7)**

AC7 names both build scripts. If `build.ps1 -Lang all` runs, repeat Step 2 against its output. If it does not run locally, record the Windows CI job as the evidence and say which half was covered where.

---

## Task 25: Advisory cross-model review, then finish the branch

- [ ] **Step 1: Run the cross-model review, if a helper is available**

If the Codex plugin (or an equivalent adversarial review helper) is available, run it with this focus:

> Judge correctness against the spec's acceptance criteria (AC1–AC46) only. Do not flag anything outside the stated criteria — no design alternatives, hardening, or scope the spec did not claim.

This **never gates a merge**. The gate is `bash scripts/build.sh --check` plus `bash scripts/build.sh --lang all`. The review only flags what deserves a second look. If no helper is available, skip it and say so.

- [ ] **Step 2: Triage the findings**

Use `superpowers:receiving-code-review`. Verify each finding against the spec before acting on it; a finding outside AC1–AC46 is out of scope for this branch and belongs in an issue.

- [ ] **Step 3: Finish the branch**

Use `superpowers:finishing-a-development-branch`. Both PRs land on `dev`. `main` carries releases only, and the bilingual `docs/WHATS-NEW.md` entry is written on the release PR, not here.

---

## Self-review notes

**Spec coverage.** Every AC1–AC46 maps to a task: AC1–AC2 → Task 4; AC3–AC5 → Task 5; AC6 → Task 10 Step 4; AC7 → Tasks 15, 24; AC8–AC12 → Task 7 (written) and Task 11 (proven); AC13–AC14 → Tasks 8, 9, 10; AC15–AC18 → Task 9; AC19 → Task 6; AC20–AC25 → Task 7 (written) and Task 11 (proven); AC26–AC30 → Task 19 (written) and Task 20 (proven); AC31–AC33 → Tasks 18, 20; AC34 → Task 1; AC35 → Tasks 2, 3; AC36–AC38 → Tasks 5, 11, 17, 20; AC39 → Task 12; AC40 → Task 24; AC41 → Tasks 8, 9, 10; AC42–AC44 → Task 7; AC45 → Task 13; AC46 → Task 14.

**Two known judgement calls, flagged rather than silently resolved.**

1. The spec fixes French scenario filenames in the EN test directory, diverging from the existing EN scenario naming. Followed as written, because AC36 names those paths.
2. AC4's word budget is tight enough that two instructions moved from mentor's `SKILL.md` body into reference files that already carried them. Task 5 Step 7 re-runs the two existing scenarios whose ticked boxes rested on that prose, so the trim is proven rather than assumed.

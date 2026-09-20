# Exec-facing document section headings on a locale switch

**Issue:** #19
**Status:** Design approved 2026-09-19
**Builds on:** ADR-0007 (exec-facing document paths), ADR-0004 (canonical-French
memory key), ADR-0005 / ADR-0006 (`relais/`, `competences/`), ADR-0008 (scenario
file format), ADR-0014 (scenario run transcripts),
`docs/superpowers/specs/2026-08-10-mentor-tutorial-design.md` (which named this
case out of scope and filed it as #19), and the `skills/dated-claims.tsv`
registry pattern from `docs/superpowers/specs/2026-09-19-stale-dated-claims-check-design.md`.

**Citation form:** criteria in this spec are cited as `2026-09-19-headings/ACn`.
Two specs now carry the date 2026-09-19 and both number from AC1, so a bare
`2026-09-19/ACn` keeps meaning the stale-dated-claims spec.

## Problem

ADR-0007 fixes exec-facing document **paths** to one spelling in both locales,
so a locale switch never orphans a document. It says nothing about the
**section headings inside** those documents, and they diverge today:
`{root}/docs/atelier/progression.md` is written with « Pratique actuelle »,
« Pratiques adoptées », « Difficultés exprimées », « Prochaine étape convenue »,
« Modules du tutoriel couverts » on a French install, and "Current practice",
"Practices adopted", "Stated struggles", "Agreed next step", "Tutorial modules
covered" on an English one.

The file is found after a locale switch. Its contents are not read back. An
executive who covered five tutorial modules in French and switches to English
is offered all seven again, as if nothing had happened — `references/tutorial.md`
tells the reader to add lines under "Tutorial modules covered", and a French
document has no such heading.

The same question applies to every exec-facing document, not only
`progression.md`. Three facts about the current state shaped this design.

**The surface is larger than issue #19 lists.** Beyond the Company Profile's
nine sections, the relay's five and `progression.md`'s five, the corpus
includes the compass map's four sections, the compass decision memo, the
compass decision brief, the research note, the ticket, and the role registry —
all written in one locale and read back later. The decision log, the per-role
memory files, the marketing voice guide, the meeting minutes and the sales
pipeline review have a documented structure but no fenced template.

**Both locales' templates are already section-for-section parallel** — same
count, same order, everywhere. Nothing enforces that. It is the property that
makes reading by meaning reliable, and it is currently a coincidence.

**ADR-0007's own wording does not match the repository.** It says exec-facing
paths use "one canonical **French** spelling in both locales." In practice
`company-profile.md`, `decisions.md`, `roles.md`, `map.md`, `research/`,
`tickets/` and `maquettes/` are English or locale-neutral spellings used
unchanged in both locales, and only the concepts with French names —
`relais/`, `competences/`, `ventes/`, `reunions/`, `guide-de-voix.md`,
`memory/<nom-canonique>.md` — are French. The property every path actually
holds is **one spelling in both locales**.

## Decision

### §1 — Headings stay localized; the read side carries the compatibility

Section headings in exec-facing documents are written in the locale of the
skill that created the document. Paths are canonical because the executive
rarely reads them; headings are the document's visible text, and an English
reader's own Company Profile must not greet them with « Rôle », « Marché »,
« Ton de voix ».

What changes is how a document is read:

1. **Read in full, identify by content.** A section is identified by what it
   holds, never by matching its title. A section is never reported missing,
   and a document never treated as empty, because its headings are in the
   other language.
2. **No positional fallback.** If a section genuinely cannot be identified,
   the reader asks the executive. These are the executive's own documents and
   they edit them; a silent write into a section that happens to sit in the
   expected position is worse than one question.
3. **Disclose once.** On a language mismatch, say so plainly, one line, the
   first time the document is read in the session: the record was written in
   the other language, it has been read, and it still counts.
4. **Offer a heading-only rewrite.** Proposed as an ordinary memory write
   under `references/memory-protocol.md` — accepted, declined, or unanswered,
   and a decline is dropped rather than re-proposed. It rewrites heading lines
   only. The executive's own prose is never translated: it is their record, and
   a paraphrase of why they adopted a practice is a real loss. They can always
   ask for a translation.

   Their headings are theirs on the same grounds. A heading is rewritten only
   when the reader placed that section as one of its own **and** it is spelled
   the way its template spells it, in one locale or the other. A section they
   added and a template section they renamed both keep heading and body,
   nothing is reordered, and the offer names the exception on a document that
   carries one. Being unable to place a section is not a reason to ask here:
   §2 governs writing *into* a section, and leaving a heading alone is not a
   write.
5. **Cowork only.** The offer is a write, and writes happen only where the
   files can be read and rewritten. In a Desktop chat session the disclosure
   still happens; the offer does not, and the session says plainly that nothing
   was written.
6. **New content follows the executive's language.** Lines appended to a
   document whose headings are in the other language are written in the
   language the executive is speaking (AC25 of the Atelier design), not in the
   document's heading language. A bilingual document is a correct intermediate
   state, not a defect.

### §2 — ADR-0016, and what it says about ADR-0007

The decision meets all three gate criteria: it is hard to reverse once
executives hold documents written under it, it is surprising without context
(paths canonical, headings not), and genuine alternatives existed — canonical
French headings, and hidden stable anchors such as
`## Current practice <!-- atelier:pratique-actuelle -->`. Canonical French
headings were rejected because they put French in an English executive's own
document; anchors were rejected because they buy exactness the reader does not
need, add build syntax to a file the skill ships to the executive's Claude, and
create a migration for every document already on disk.

ADR-0016 also restates the path invariant as **one spelling in both locales**,
French being the tiebreaker where the concept has a French name. No path moves:
every existing path already satisfies the restated rule. ADR-0007 stays
Accepted and gains a pointer to ADR-0016 — its decision stands, only its
wording is corrected.

### §3 — Where the rule lives

The rule belongs in `skills/shared/<locale>/memory-protocol.md`, which the
build already copies into every ZIP's `references/` and which every skill is
told to read before proposing a write. That placement costs no `SKILL.md`
words, and the ~550-word `SKILL.md` budget is untouched.

A new section, authored in each locale's own language rather than translated:

- `skills/shared/fr/memory-protocol.md` — `## Un document écrit dans l'autre langue`
- `skills/shared/en/memory-protocol.md` — `## A document written in the other language`

The general rule is the backstop. The local wording at each call site is what
the reader has in front of it, and the two fail independently, so both get
fixed:

| File (both locales) | Change |
|---|---|
| `skills/atelier-mentor/{fr,en}/references/tutorial.md` | "add one dated line per completed module under 'Tutorial modules covered'" names the section by what it records, keeping this locale's title as the example. |
| `skills/atelier-mentor/{fr,en}/references/progression.md` | Same, for the "Current practice" blank check. |
| `skills/atelier-boussole/{fr,en}/references/detour-research.md`, `detour-recherche.md` | Same, for the memo's "Documents" and "What was decided" sections. |
| `skills/atelier/{fr,en}/references/onboarding.md`, `relais.md` | One line: a document found in the other language is read and used, never re-created alongside. |

### §4 — The registry

`skills/exec-documents.tsv`, one row per exec-facing document, six
tab-separated columns:

```
<doc-id>  <canonical-path>  <fr-ref>  <fr-block>  <en-ref>  <en-block>
```

`<fr-block>` and `<en-block>` are the 1-based index of the ` ```markdown `
fence inside that reference file. A document whose structure is described in
prose rather than a template carries `-` in all four template columns; the
parity check skips it, and the row still records that the document exists and
is governed by the rule.

| doc-id | canonical path | fr-ref / block | en-ref / block |
|---|---|---|---|
| `company-profile` | `{root}/docs/atelier/company-profile.md` | `skills/atelier/fr/references/onboarding.md` 1 | `skills/atelier/en/references/onboarding.md` 1 |
| `role-registry` | `{root}/docs/atelier/roles.md` | `skills/atelier/fr/references/onboarding.md` 2 | `skills/atelier/en/references/onboarding.md` 2 |
| `progression` | `{root}/docs/atelier/progression.md` | `skills/atelier-mentor/fr/references/progression.md` 1 | `skills/atelier-mentor/en/references/progression.md` 1 |
| `relay` | `{root}/docs/atelier/relais/<date>-<subject>.md` | `skills/atelier/fr/references/relais.md` 1 | `skills/atelier/en/references/relais.md` 1 |
| `relay-tutorial` | same path, reduced variant | `skills/atelier/fr/references/relais.md` 2 | `skills/atelier/en/references/relais.md` 2 |
| `compass-map` | `{root}/docs/<initiative>/map.md` | `skills/atelier-boussole/fr/references/carte.md` 1 | `skills/atelier-boussole/en/references/map.md` 1 |
| `ticket` | `{root}/docs/tickets/NN-<short-name>.md` | `skills/atelier-boussole/fr/references/plan-daction.md` 1 | `skills/atelier-boussole/en/references/action-plan.md` 1 |
| `compass-brief` | `{root}/docs/<date>-<decision>.md` | `skills/atelier-boussole/fr/references/carte.md` 3 | `skills/atelier-boussole/en/references/map.md` 3 |
| `compass-memo` | `{root}/docs/<initiative>/` (memo beside the map) | `skills/atelier-boussole/fr/references/collapse.md` 1 | `skills/atelier-boussole/en/references/collapse.md` 1 |
| `research-note` | `{root}/docs/research/<date>-<subject>.md` | `skills/atelier-boussole/fr/references/detour-recherche.md` 1 | `skills/atelier-boussole/en/references/detour-research.md` 1 |
| `decision-log` | `{root}/docs/atelier/decisions.md` | `-` | `-` |
| `role-memory` | `{root}/docs/atelier/memory/<canonical-name>.md` | `-` | `-` |
| `voice-guide` | `{root}/docs/marketing/guide-de-voix.md` | `-` | `-` |
| `minutes` | `{root}/docs/reunions/` | `-` | `-` |
| `pipeline-review` | `{root}/docs/ventes/` | `-` | `-` |
| `mockup` | `{root}/docs/maquettes/` | `-` | `-` |

The ticket template is duplicated inside `carte.md` / `map.md` (block 2) as a
convenience copy. The registry points at the canonical copy in
`plan-daction.md` / `action-plan.md`; the duplicate is left as it is, and
keeping the two in sync stays a review matter, not a new check.

### §5 — The parity check

A new rule inside `--check` (`bash scripts/build.sh --check`) and its
PowerShell twin (`./scripts/build.ps1 -Check`). For every registry row:

- Each named reference file exists.
- Each named block index exists in that file.
- The two blocks have an **identical sequence of heading levels** — the same
  number of headings, at the same depths, in the same order.

No script can compare a French heading to an English one for meaning. It can
prove the two templates are structurally the same document, which is the
property reading-by-meaning depends on. A row with `-` templates is skipped.

Failures name the doc-id and both files, in the style the existing checks use.
The coherence mutation matrices in `scripts/tests/build_test.sh` and
`scripts/tests/build_test.ps1` gain a case that drops a section from one
locale's template and expects a named failure.

CI needs no change: `.github/workflows/ci.yml` already runs `--check` on Linux
and `-Check` on Windows, and the new rule rides inside both.

### §6 — The scenario

`tests/_cross-skill/changement-de-langue.md`, ADR-0008 cross-skill frontmatter:

```yaml
---
skills:
  - atelier-mentor
  - atelier
locale: mixed
scope: cross-skill
sessions: 2
---
```

**Dispatch 1 — French writes, English reads.** French `atelier-mentor` covers
tutorial modules with the executive and writes `{root}/docs/atelier/progression.md`
with French headings. A fresh English `atelier-mentor`, same sandbox root,
refreshes: it must read the French record, offer no module already covered,
say once that the record is in French, and offer the heading-only rewrite.

**Dispatch 2 — English writes, French reads.** The mirror, so the property is
observed in both directions rather than in one skill's lucky direction — the
same reason `tests/_cross-skill/langue-de-la-personne.md` runs both ways.

`## Baseline notes` is `N/A` with the reason stated: a plain assistant has no
installed locale and no cross-session document to read back, so there is no
comparison to make.

Both dispatches leave a committed transcript under
`tests/_cross-skill/runs/changement-de-langue/`, per ADR-0014, saved before the
boxes are ticked.

## Non-goals

- **Translating the executive's own content.** The offer rewrites heading lines
  only (*Decision §1.4*) — and not every heading line either: the ones the
  executive wrote or renamed stay as they wrote them.
- **Sweeping every document in one offer.** One document per offer, proposed by
  whichever skill read it.
- **Renaming any path.** ADR-0016 corrects ADR-0007's wording; no file moves.
- **Detecting a document missing from the registry.** Considered and kept out:
  it needs a way to mark `{root}/docs/...` tokens that are not documents. Filed
  as #39.
- **Hidden heading anchors.** Rejected in *Decision §2*; not a phase-two item.

## Acceptance Criteria

### The rule as recorded

- **AC1** — `docs/adr/0016-exec-facing-document-section-headings.md` exists,
  Status `Accepted — 2026-09-19`, and states the localization rule of
  *Decision §1* together with all six of its numbered behaviours: read in
  full and identify by content, no positional fallback, disclose once,
  heading-only offer, offer in Cowork only, appended content in the
  executive's language. *Decision §4* further states that a heading the
  executive wrote or renamed is not rewritten, and that the offer says so.
- **AC2** — ADR-0016 states the path invariant as one spelling in both locales
  with French as the tiebreaker, and names at least three of the English or
  locale-neutral canonical paths in use today.
- **AC3** — `docs/adr/0007-exec-facing-document-paths.md` keeps Status
  `Accepted`, carries a pointer to ADR-0016, and restates its own invariant
  as one spelling in both locales.
- **AC4** — No exec-facing document path changes: apart from the new
  `skills/exec-documents.tsv`, whose rows repeat paths that already exist,
  `git diff` on the branch adds, removes or respells no `{root}/docs/...` or
  `{racine}/docs/...` token in `skills/`.

### The shared rule text

- **AC5** — `skills/shared/fr/memory-protocol.md` carries a section headed
  `## Un document écrit dans l'autre langue`, and
  `skills/shared/en/memory-protocol.md` one headed
  `## A document written in the other language`, each written wholly in its
  own locale's language. (That each locale's file is *authored* in that
  language rather than translated from the other is an authoring rule, held
  under "Repo-specific notes for the plan author"; it is not machine-checkable
  and so is not asserted here.)
- **AC6** — Each of those sections states, in its own words: the document is
  read in full; a section is identified by what it holds rather than by its
  title; a section is never
  reported missing because its title is in the other language; when a section
  cannot be identified the reader asks instead of guessing by position.
- **AC7** — Each states that the mismatch is disclosed once, the first time
  the document is read in the session, in one line saying the record was
  written in the other language, has been read, and still counts; and that a
  heading-only rewrite of that one document — not a sweep of every document —
  is offered as an ordinary proposed write, with the executive's own prose
  left untouched. Each also states that a heading the executive wrote or
  renamed is left untouched for the same reason, that being unable to place a
  section is not itself a reason to ask, and that the offer names the
  exception on a document that has one.
- **AC8** — Each states that the offer happens in Cowork only, and that a
  Desktop chat session discloses without offering and says nothing was written.
- **AC9** — Each states that content appended to a document whose headings are
  in the other language is written in the language the executive is speaking.
- **AC10** — `bash scripts/tests/shared_test.sh` passes, and every built ZIP
  contains the updated `references/memory-protocol.md` after
  `bash scripts/build.sh --lang all`.

### The call sites

- **AC11** — In `skills/atelier-mentor/{fr,en}/references/tutorial.md`,
  `skills/atelier-mentor/{fr,en}/references/progression.md` and
  `skills/atelier-boussole/{fr,en}/references/detour-recherche.md` /
  `detour-research.md`, every instruction that locates a section of an
  exec-facing document names that section by what it holds; where a literal
  heading is quoted it is presented as this locale's spelling, not as the
  string to match.
- **AC12** — `skills/atelier/{fr,en}/references/onboarding.md` and
  `relais.md` each state that a document found with the other language's
  headings is read and used, never re-created alongside.
- **AC13** — No `skills/*/{fr,en}/SKILL.md` changes: the rule lives in
  `references/memory-protocol.md`, so every skill body's `wc -w` is identical
  before and after the branch, and the `docs/AUTHORING.md` target of ~550
  words is neither approached nor relieved by this work.

### The registry

- **AC14** — `skills/exec-documents.tsv` exists, is tab-separated, six columns,
  one row per document, and contains a row for each of the sixteen documents
  listed in *Decision §4*, with the paths and block indices given there.
- **AC15** — Rows whose structure is prose carry `-` in all four template
  columns.

### The parity check

- **AC16** — Given the repository as it stands, `bash scripts/build.sh --check`
  and `./scripts/build.ps1 -Check` both report no failure arising from the new
  rule.
- **AC17** — When a registry row names a reference file that does not exist,
  `--check` fails with a message naming the doc-id and the missing path.
- **AC18** — When a registry row names a block index that does not exist in the
  named file, `--check` fails with a message naming the doc-id, the file, and
  the index.
- **AC19** — When the two blocks of a row have a different number of headings,
  `--check` fails with a message naming the doc-id and both files.
- **AC20** — When the two blocks have the same number of headings at different
  depths, or the same depths in a different order, `--check` fails the same way.
- **AC21** — A row with `-` template columns produces neither a failure nor a
  parity comparison.
- **AC22** — For each mutation in AC17–AC21, `./scripts/build.ps1 -Check`
  reaches the same pass/fail verdict as `bash scripts/build.sh --check`.
- **AC23** — `scripts/tests/build_test.sh` and `scripts/tests/build_test.ps1`
  each gain a mutation case for every one of AC17–AC21 — a missing reference
  file, a missing block index, a differing heading count, the same headings at
  differing depths or in a differing order, and a `-` row — each expecting the
  stated outcome, and both suites pass.

### The scenario

- **AC24** — `tests/_cross-skill/changement-de-langue.md` exists, carries the
  cross-skill frontmatter of *Decision §6* and the four required sections
  (`## Prompt`, `## Expected behaviors`, `## Baseline notes`,
  `## Verification notes`), and its `## Baseline notes` states why no baseline
  applies rather than omitting the section.
- **AC25** — Its `## Expected behaviors` carries a box for each of: the record
  written in the other locale is read back; all seven modules are listed with
  the already-covered ones carrying their dates, and the recommendation names
  only the uncovered ones; the mismatch is disclosed once, in the executive's language; an
  accepted rewrite changes heading lines only, leaving the executive's prose
  byte-identical; a declined rewrite leaves the whole file byte-identical; a
  section the executive added survives an accepted rewrite; a template section
  they renamed survives it the same way; and the offer names the exception on
  a document that carries such a heading.
- **AC26** — Two dispatches are run — French writes / English reads, and the
  mirror — and each leaves a transcript committed under
  `tests/_cross-skill/runs/changement-de-langue/<date>-<kind>.md`, saved before
  the boxes were ticked.
- **AC27** — Boxes are ticked only for what the runs established; any box left
  unticked carries its stated reason in `## Verification notes`.

### Edge cases

- **AC28** — Given no `{root}/docs/atelier/progression.md` on disk, folder
  access, and a first confirmed practice whose write the executive accepted,
  the skill creates the file at that moment — never pre-created empty — with
  the current locale's headings, and makes no disclosure and no rewrite offer.
  Without folder access nothing is written and the session says so plainly.
- **AC29** — Given a document whose headings are already in the current
  locale, no disclosure is made and no rewrite is offered.
- **AC30** — Given an accepted heading rewrite on a document carrying a section
  the executive added themselves, that section's heading and body survive
  unchanged and no section is reordered.
- **AC32** — Given an accepted heading rewrite on a document where the executive
  renamed one of the template's own sections, that section's heading and body
  survive unchanged too: a heading is rewritten only when the reader placed
  that section as one of its own *and* the heading is spelled the way its
  template spells it, in one locale or the other.
- **AC33** — Given a rewrite offer on a document carrying such a heading, the
  offer states that the executive's own headings stay as they wrote them; on a
  document carrying none, it does not.

**Status of AC32 and AC33 as of 2026-09-20.** AC30 is met: five accepted
rewrites across both directions left the executive's added section untouched,
heading and body. AC32 and AC33 are **not met**, in one direction only — a
French-install reader translated the renamed heading in three of three runs,
while an English-install reader preserved it in two of two. The run section
`## Verification notes — 2026-09-20 executive-added and renamed headings` in
`tests/_cross-skill/changement-de-langue.md` carries the evidence and rules
out both the obvious causes: sharpening the rule text changed no outcome, and
this heading pair is shipped symmetrically in both locales' ZIPs. The
structural cause for the *other* four heading pairs — that they are shipped in
one language only, so the comparison AC32 asks for is unanswerable — is #42.
These criteria state the decided behaviour and are left in place rather than
weakened to match what currently happens.

Both halves are resolved by
[`2026-09-20-exec-heading-pairs-design.md`](2026-09-20-exec-heading-pairs-design.md):
the structural half by generating `references/exec-document-headings.md` into
every ZIP, the behavioural half by rewriting the worked example to the
cross-language case and requiring the offer to name both lists. The AC numbers
in that spec are its own — cite them as `2026-09-20-heading-pairs/ACn`.

### The repository's own docs

- **AC31** — `docs/AUTHORING.md` carries a `## Exec-facing document headings`
  section stating that headings are localized, that documents are read by
  meaning rather than by title, and that every new exec-facing document gets a
  row in `skills/exec-documents.tsv`; `scripts/tests/authoring_test.sh`
  requires that heading and passes; and `CLAUDE.md` carries the date-plus-slug
  AC-citation form.

## Deferred Items

- #38 — Shared EN memory protocol calls the compass map a "deck"
- #39 — Build check: nothing detects an exec-facing document missing from
  `exec-documents.tsv`
- #41 — Locale-switch scenario cannot reach its session-2 append-language box
  (closed by the 2026-09-20 run)
- #42 — A skill cannot check a renamed heading: it ships only one of the two
  locales' template spellings

## Glossary Updates & ADRs

No repository glossary: this repository has no `CONTEXT.md`. The exec-facing
`skills/shared/<locale>/glossary.md` needs no new entry — this design adds no
vocabulary an executive would meet; it changes how existing documents are read.

- **ADR-0016 — Exec-facing document section headings.** New. Created under the
  three-criteria gate as argued in *Decision §2*.
- **ADR-0007** — amended with a pointer to ADR-0016 and with its invariant
  restated as one spelling in both locales. Not superseded: no path changes.
- **ADR conflict surfaced and resolved:** ADR-0007's "canonical French
  spelling" wording does not describe the repository's own paths
  (*Problem*, third fact). ADR-0016 corrects the wording rather than the files.

## Config & Infrastructure Impact

Scanned against every category. This repository has no containers, no IaC, no
environment config or secret store, no ORM schemas, and no API collections.

| File | Change |
|---|---|
| `skills/exec-documents.tsv` | Create. Sixteen rows, six columns. |
| `scripts/build.sh` | Add the registry reader and the parity check to the `--check` tier. |
| `scripts/build.ps1` | The same, as the `-Check` twin. |
| `scripts/tests/build_test.sh` | Add the AC17–AC21 mutation cases. |
| `scripts/tests/build_test.ps1` | Add the same cases for the Windows twin (AC22, AC23). |
| `scripts/tests/authoring_test.sh` | Add `require_heading "## Exec-facing document headings"`. |
| `scripts/tests/shared_test.sh` | No change. It checks the shared files are present and non-empty; the new section rides inside `memory-protocol.md`. |
| `.github/workflows/ci.yml` | No change. Both `--check` entry points already run. |
| `.github/workflows/dated-claims.yml` | No change. Unrelated tier. |
| `release-please-config.json` | No change. None of the new files carries a version annotation. |
| `CLAUDE.md` | One sentence extending the existing AC-citation convention with the date-plus-slug form. |

## Manual Operator Steps

None. Everything this design needs lands in the diff; no console, credential,
label or external service is involved. The two scenario dispatches are agent
work recorded under `tests/_cross-skill/runs/`, not operator steps.

## Documentation Updates

| Doc | Change |
|---|---|
| `docs/adr/0016-exec-facing-document-section-headings.md` | Create, per AC1–AC2. |
| `docs/adr/0007-exec-facing-document-paths.md` | Add the ADR-0016 pointer and the restated invariant, per AC3. |
| `docs/AUTHORING.md` | Add `## Exec-facing document headings`: headings localized, read by meaning, and one `exec-documents.tsv` row per new exec-facing document. |
| `CLAUDE.md` | Extend the AC-citation line with the date-plus-slug form. Index only — the design stays in this spec. |
| `tests/README.md` | No change. The new scenario uses the documented cross-skill shape as-is. |

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
> 2. **Glossary application** — not applicable: this repository has no `CONTEXT.md`, and the spec's "Glossary Updates & ADRs" section lists no new or changed terms.
> 3. **ADR creation** — FOR EACH ADR listed in the spec, add a task: *"Create `docs/adr/NNNN-<slug>.md` following sequential numbering (start at `0001-` if the directory is empty)."* IF the spec lists ADR conflicts surfaced, also add a task: *"Update the conflicting ADR's status (superseded / amended) and link to the new ADR."*
> 4. **Deferred-item verification** — Add a task: *"Confirm every issue referenced in the 'Deferred Items' section exists and has all four required body sections (Context, Required, Integration Points, Priority)."* Run `gh issue view <#> --json body | jq -r .body` and grep for the four headings.
> 5. **Config file tasks** — FOR EACH file listed in the spec's "Config & Infrastructure Impact" section, add one explicit task: *"Update `<path>`."*
> 6. **Manual Operator Steps** — not applicable: the spec's "Manual Operator Steps" section is empty.
> 7. **Docs update tasks** — FOR EACH entry in the spec's "Documentation Updates" section, add one explicit task: *"Update `<doc-path>`."* Design content goes in the docs dir, not the agent index; the index gets at most a 1-line pointer, a ≤3-sentence area summary, or a 1-line command/env-var entry.
> 8. **Post-implementation check** — Add as the second-to-last task: *"Verify every Required Task above was actually executed — config files updated, docs written, glossary entries applied, ADRs created."* Read the diff; don't trust plan markings.
> 9. **Final build task** — Add as the last task: *"Run `bash scripts/build.sh --lang all` and fix any issues until it builds successfully."* Non-negotiable — type-checks and tests alone do not catch all build-time failures.
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
> - **Pre-commit verification (mandatory)** — Before EVERY `git commit`, dispatch a verification subagent that runs `bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh` from the repo root and reports `STATUS: PASS` or `STATUS: FAIL` with a terse per-issue list (no raw output). Wait for `STATUS: PASS` before committing; if FAIL, fix in the current task and re-run. Never use `git commit --no-verify`.
>
> ---
>
> ### Before finishing the branch (advisory cross-model review)
>
> After the final build passes — and before wrapping up via `superpowers:finishing-a-development-branch` — if a cross-model review helper is available (e.g. the Codex plugin's adversarial review), run it with focus: *"Judge correctness against the spec's acceptance criteria (AC1–ACn) only. Do not flag anything outside the stated criteria — no design alternatives, hardening, or scope the spec did not claim."*
>
> This **never gates a merge** — the gate stays `bash scripts/build.sh --check` plus `bash scripts/build.sh --lang all`; the review only flags what deserves a second look. If no helper is available, finish the branch without it.

### Repo-specific notes for the plan author

- `dev` is the default branch. Cut the branch from `dev`, land the PR on `dev`
  (`docs/adr/0010-dev-default-main-release-branch.md`).
- Conventional Commits. The scopes this work touches: `shared` (memory
  protocol), `mentor`, `boussole`, `atelier`, `build` (the check and the
  registry), `docs` (ADRs, AUTHORING, CLAUDE.md).
- Never hand-edit `version.txt`, a `SKILL.md` version line, or the two
  annotated `README.md` lines — release-please owns them.
- Every French file is authored in French, not translated from the English
  one. The two locales are written, not mirrored.
- The two scenario dispatches (AC26) are manual agent runs and belong in their
  own task, after the rule and the check are in place, with the transcript
  saved before the boxes are ticked.

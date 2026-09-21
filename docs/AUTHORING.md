# Authoring standards

These rules govern every Atelier skill. They are the single source of truth
each `SKILL.md` is written against, and `atelier-forge` carries an
exec-facing distillation of them in its own `references/` so generated
skills inherit the same standards. This document is repo/maintainer-facing;
it is not shipped to execs.

## Descriptions

Descriptions state only when to use the skill — never its workflow. A
description that summarizes the process gets followed *instead of* the
skill body, so Claude short-circuits the actual instructions. Format:
"Use when…" followed by concrete triggering situations.

Descriptions use the exec's vocabulary, authored per locale — never
translated mechanically. The French `atelier-reunions` description
literally contains « procès-verbal, PV, compte rendu, préparer ma réunion,
suivi de rencontre »; `atelier-meetings` contains "minutes, meeting prep,
action items, decision log". Trigger vocabulary is contract: every
`triggers:` term a test scenario lists for a locale must appear verbatim in
that locale's description.

All skills are model-invoked. Execs are not expected to know what's
installed or when to reach for it — the description carries the entire
discovery load, and `atelier-mentor` routes when the exec asks in plain
language instead of triggering a skill directly.

## Frontmatter contract

Every skill's `SKILL.md` opens with three required fields in YAML frontmatter,
in this exact order: `name`, `description`, and `version`. The build enforces
this structure via `scripts/build.sh --check` (and its PowerShell twin), which
CI runs on every push and pull request.

- **name**: Must match `^[a-z0-9-]+$` (lowercase, digits, hyphens only). Must
  equal the localized skill name for that locale in `skills/names.tsv`. The
  build fails on any mismatch.
- **description**: Required. Constraint: `len(name) + len(description)` must
  be ≤ 1024 characters.
- **version**: Required.

Example:

```yaml
---
name: atelier-reunions
description: À utiliser quand la personne dirigeante parle de réunion, de rencontre, ou demande un procès-verbal, un PV, un compte rendu, de préparer sa réunion, un suivi de rencontre, ou un relevé de décisions.
version: 0.1.0
---
```

## SKILL.md stays lean

Knowledge lives in `references/`, loaded on demand — not inlined in
`SKILL.md`. The author's playbooks (marketing, sales, meetings) are
reference files, not prose in the body. Target: `SKILL.md` under ~550
words. The shared Memory block and Company Profile pointer paragraph are
part of that count, so the practical ceiling for authored body text is
lower than the target suggests. If a section is explaining domain
knowledge rather than telling Claude what to do next, it belongs in
`references/`.

## Nested references

A reference is normally a flat `.md` file, but it may instead be a
subdirectory under `references/` when a single reference has multiple
reading-order parts — `atelier-mentor`'s `references/tutorial/` is the
pack's example. Files inside such a subdirectory are named `NN-slug.md`,
numbered in reading order (`01-how-claude-thinks.md`,
`02-models-and-effort.md`, and so on).

Known gap, accepted not fixed: `check_reference_pointer_drift` in
`scripts/build.sh` globs `references/*.md` non-recursively, so files inside
a nested reference directory escape the Company Profile pointer drift
check. A nested reference must therefore never carry shared canonical text
(the Memory block, the glossary, the memory protocol) — those stay flat
files at the top of `references/`, where the drift check still sees them.

## Match the form to the failure

Output shaping gets positive recipes — state what the output IS and the
steps to produce it. Prohibitions backfire there: telling Claude what the
output should *not* look like doesn't tell it what to do instead.

A hard guardrail is allowed only when paired with the alternative
behavior — never a bare "don't." For example: « ne persiste pas X — garde-le
pour le balayage de fin de session » names the prohibited action and the
correct one in the same breath.

Discipline rules an agent might skip under pressure — propose-before-writing
is the recurring example — are not fixed by repeating the rule louder in the
body. They are pressure-tested with scenarios in `tests/` (see Testing)
that put the agent under time pressure and check the rule still holds.

## Checkable completion criteria

Multi-step flows (onboarding, forge's interview) end each step on a
condition Claude can verify, not a vague instruction to help. "Profile
document delivered and the exec told where to save it" is checkable;
"help the user" is not. A checkable criterion is what lets the same
standard apply to Role-skill body shape's task workflows below.

## One excellent example per skill

Include one excellent worked example per skill, only where it earns its
place: a sample Company Profile in the hub, a sample generated skill in
forge. One good example beats several mediocre ones and keeps `SKILL.md`
lean; do not pad a skill with an example it does not need.

## Shared glossary

A small exec-facing glossary of Atelier vocabulary (skill, workspace,
Company Profile, relais, boussole, routine, journal des décisions /
decision log, vocabulaire / vocabulary, mémoire d'entreprise / corporate
memory, and the like) lives in `skills/shared/<locale>/glossary.md` and is
adhered to by every skill — the leading-words standard made into an
artifact. It is never inlined in `SKILL.md`: the build copies each locale's
glossary into every skill ZIP's `references/`. Forge gives it to generated
skills too.

## Role-skill body shape

Role skills are workflow-shaped, not persona-shaped. Triggers live in the
description (see Descriptions), never in the body. The body holds task
workflows, each ending on a checkable completion criterion (see Checkable
completion criteria). Knowledge lives in `references/` (see SKILL.md stays
lean).

One structural requirement applies to every role skill: a single canonical
**Memory block**, in one slot, so there is exactly one place to drift-check
(see The Memory block). Company facts never live in a skill body — they
belong to the Company Profile.

Forge's starter scaffold follows this shape, so every generated skill
inherits it too.

## The Memory block

Every role skill carries exactly one Memory block, in one slot, so there is
one place to drift-check. It has three parts and nothing else:

1. The Company Profile pointer paragraph — inlined verbatim from
   `skills/shared/<locale>/profile-pointer.md`. The build fails on any drift.
2. This skill's memory sources: its per-role memory file
   `{root}/docs/atelier/memory/<canonical-fr-name>.md` (read at start; created
   lazily on the first durable entry, never pre-seeded) and the decision journal
   `{root}/docs/atelier/decisions.md`.
3. The pointer to `references/memory-protocol.md`, to be read before proposing
   any memory write.

Company facts never live in a skill body — they belong to the Company Profile.

## Memory protocol adherence

Every skill follows the shared write protocol canonicalized per locale in
`skills/shared/<locale>/memory-protocol.md` and copied into every ZIP's
`references/` (never inlined — see Shared glossary for the same pattern).
The protocol covers:

- **Two regimes.** Executive decisions go to the dated, self-sufficient,
  immutable journal (`decisions.md`); durable knowledge goes to reconciled
  living state (Company Profile, per-role memory files, mentor's
  `progression.md`, the role registry).
- **The routing table.** Every persisted item has exactly one primary home
  — settled decision, stable company fact, role-specific knowledge, or
  AI-practice adoption — and a decision's knowledge consequences are
  reconciled in the same confirmed write that journals it.
- **Propose before writing.** A short summary of what goes where, then wait
  for the exec's accord — except on an explicit "note this." A declined
  item is dropped, not re-proposed later in the session. This step holds
  even under time pressure.
- **The do-not-persist list.** Unconcluded brainstorming, throwaway Q&A,
  ephemera, and duplicates are never persisted; when in doubt, leave it for
  the end-of-session consolidation sweep, which is a backstop, not the
  primary channel.
- **Cowork-only writes.** Memory writes happen only in Cowork, which can
  read and rewrite the live files. Desktop chat cannot, so a decision made
  there lands in that session's deliverable and is folded into the journal
  and state files by the next Cowork session.

## Dated capability claims

A claim about what Claude can do today is capability-sensitive: which surfaces
run plugins, which reach local folders, what an interface labels a thing.
Capabilities shift month to month, so a claim that ships without a date reads
as authoritative forever. ADR-0011 lets such a claim ship on one condition —
it carries a last-verified date and a named source in the same file.

Write the annotation as a blockquote directly under the claim. The lead-in is
exact; `bash scripts/build.sh --check` validates it and names the file and line
when it does not match.

English:

    > **Last verified 2026-08-10** — source: Anthropic help center, article
    > 15520349 ("Use Claude Cowork on web, desktop, and mobile").

French:

    > **Vérifié le 2026-08-10** — source : centre d'aide Anthropic, article
    > 15520349 (« Use Claude Cowork on web, desktop, and mobile »).

The dash is an em dash (—, U+2014) with one space either side. French keeps the
space before the colon that its typography requires; English does not. Only the
first line is validated — everything after it is free prose the check never
reads, so put the article title and the "show the executive this date"
instruction there.

A module that carries such claims belongs in `skills/dated-claims.tsv`. Every
file listed there must keep at least one annotation, which is what catches a
translation pass or a bad merge that drops the last one.

Nothing here judges whether the date is *correct* — only that it is present,
well formed, not in the future, and not old. Re-verifying a claim is a human
act; `bash scripts/build.sh --check` reports the oldest claim's age on every
run, and a monthly job files an issue once one passes a year.

## Exec-facing document headings

Paths are canonical; **section headings are not**. A document the skill writes
for the executive carries the headings of the locale that created it — «
Pratique actuelle » on a French install, "Current practice" on an English one.
Both are correct, and a locale switch leaves the executive holding one of
them. See [ADR 0016](adr/0016-exec-facing-document-section-headings.md).

That puts the burden on the **read** side, and every instruction you write has
to carry it:

- Name a section by **what it records**, never by the string to match. "the
  section listing the completed tutorial modules" survives a locale switch;
  "the 'Tutorial modules covered' section" does not. Quoting this locale's
  heading as an *example* is fine — as the thing to grep for, it is a bug.
- Never tell a reader a section is missing, or a document empty, on the
  strength of a title it did not recognize.
- The general rule — disclose once, offer a heading-only rewrite, leave the
  headings the executive wrote or renamed alone, Cowork only, new lines in the
  executive's language — lives in
  `skills/shared/<locale>/memory-protocol.md`. Don't restate it in a skill
  body; the build copies it into every ZIP.

**Every new exec-facing document gets a row in `skills/exec-documents.tsv`**:
doc-id, canonical path, then the reference file and 1-based ` ```markdown `
block index that hold its template in each locale. `bash scripts/build.sh
--check` reads that registry and fails when the two locales' templates stop
carrying the same sequence of heading levels. A document whose structure is
described in prose rather than a template carries `-` in all four template
columns — in all four, never some.

The build also **generates** `references/exec-document-headings.md` from that
same registry and stages it into every ZIP, giving both locales' spelling of
every section. That is what lets a reader evaluate ADR-0016's "spelled the way
your template spells it, in one locale or the other" test at all. A new
exec-facing document needs its registry row **and** a ` ```markdown ` template
block in both locales' reference files, with an identical sequence of heading
levels, or the build dies. Nothing beyond that is hand-written per document,
and nothing can rot on one side. The framing prose
around the table is a shared text, `skills/shared/<locale>/exec-document-headings.md`;
the table itself is appended at stage time and never checked in.

# 0016 — Exec-facing document section headings stay localized

**Status:** Accepted — 2026-09-19

## Context

ADR-0007 fixes exec-facing document **paths** to one spelling in both
locales, so a locale switch never orphans a document. It says nothing about
the **section headings inside** those documents, and they diverge today:
`{root}/docs/atelier/progression.md` carries « Pratique actuelle », «
Pratiques adoptées », « Difficultés exprimées », « Prochaine étape convenue
», « Modules du tutoriel couverts » on a French install, and "Current
practice", "Practices adopted", "Stated struggles", "Agreed next step",
"Tutorial modules covered" on an English one.

The file is found after a locale switch. Its contents are not read back. An
executive who covered five tutorial modules in French and switches to English
is offered all seven again, as if nothing had happened —
`references/tutorial.md` tells the reader to add lines under "Tutorial
modules covered", and a French document has no such heading.

The surface is every exec-facing document, not only `progression.md`: the
Company Profile, the role registry, the relay, the compass map, the decision
brief, the decision memo, the research note, the ticket, the decision log,
the role memories, the voice guide, the minutes, the pipeline review, the
mockups.

Both locales' templates are already section-for-section parallel — same
count, same order, everywhere. Nothing enforces that. It is the property that
makes reading by meaning reliable, and it is currently a coincidence.

## Decision

Section headings in exec-facing documents are written in the locale of the
skill that created the document. Paths are canonical because the executive
rarely reads them; headings are the document's visible text, and an English
reader's own Company Profile must not greet them with « Rôle », « Marché », «
Ton de voix ».

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
   only, on the one document just read. The executive's own prose is never
   translated: it is their record, and a paraphrase of why they adopted a
   practice is a real loss. They can always ask for a translation.

   The same holds for the headings they wrote. A heading is rewritten only
   when the reader placed that section as one of its own and the heading is
   spelled the way its template spells it, in one locale or the other. A
   section the executive added, and a template section they renamed, keep
   their heading and their body, and nothing is reordered — a heading they
   renamed is words they chose, exactly like their prose. Being unable to
   place a section is not a reason to ask here: §2 governs writing *into* a
   section, and leaving a heading alone is not a write. Where a document
   carries such a heading, the offer says so, so an accepted rewrite that
   leaves one heading standing does not read as a failure.
5. **Cowork only.** The offer is a write, and writes happen only where the
   files can be read and rewritten. In a Desktop chat session the disclosure
   still happens; the offer does not, and the session says plainly that
   nothing was written.
6. **New content follows the executive's language.** Lines appended to a
   document whose headings are in the other language are written in the
   language the executive is speaking, not in the document's heading language.
   A bilingual document is a correct intermediate state, not a defect.

The rule lives in `skills/shared/<locale>/memory-protocol.md`, which the build
copies into every ZIP's `references/` and which every skill is told to read
before proposing a write.

`skills/exec-documents.tsv` records one row per exec-facing document and the
template block that defines it in each locale. `bash scripts/build.sh --check`
and `./scripts/build.ps1 -Check` prove the two blocks carry an identical
sequence of heading levels. No script can compare a French heading to an
English one for meaning; it can prove the two templates are structurally the
same document, which is what reading by meaning depends on.

### What this says about ADR-0007

ADR-0007 states the path invariant as "one canonical **French** spelling in
both locales." That does not describe the repository. `company-profile.md`,
`decisions.md`, `roles.md`, `map.md`, `research/`, `tickets/` and `maquettes/`
are English or locale-neutral spellings used unchanged in both locales; only
the concepts with French names — `relais/`, `competences/`, `ventes/`,
`reunions/`, `guide-de-voix.md`, `memory/<nom-canonique>.md` — are French.

The property every path actually holds is **one spelling in both locales**,
French being the tiebreaker where the concept has a French name. No path
moves: every existing path already satisfies the restated rule. ADR-0007
stays Accepted and gains a pointer here — its decision stands, only its
wording is corrected.

## Alternatives considered

**Canonical French headings in both locales.** Rejected: it puts French in an
English executive's own document, which is the visible text they read.

**Hidden stable anchors**, e.g. `## Current practice <!-- atelier:pratique-actuelle -->`.
Rejected: they buy exactness the reader does not need, add build syntax to a
file the skill ships to the executive's Claude, and create a migration for
every document already on disk.

## Consequences

- A locale switch costs one disclosure line and an optional offer, not a lost
  record.
- Both locales' templates must stay structurally parallel; `--check` now fails
  when they drift, naming the doc-id and both files.
- Every new exec-facing document needs a row in `skills/exec-documents.tsv`.
  Nothing detects a document that is missing from it — filed as #39.
- A document can hold French headings and English content at once. That is a
  correct intermediate state and no check rejects it.
- An accepted rewrite can still leave a heading in the other language, when it
  is one the executive wrote or renamed. That is the intended outcome, and the
  offer says so in advance so it does not read as a half-finished rewrite.

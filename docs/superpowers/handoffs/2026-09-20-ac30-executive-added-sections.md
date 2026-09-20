# Handoff — AC30: what a heading rewrite does to a section the executive added

**Status:** open. Left unresolved by branch `locale-exec-headings` (PR to `dev`,
14 commits, `a8fbad8..`). Not filed as a GitHub issue — this note is the record.

**Spec:** `docs/superpowers/specs/2026-09-19-exec-document-headings-design.md`, AC30
**ADR:** `docs/adr/0016-exec-facing-document-section-headings.md`
**Scenario:** `tests/_cross-skill/changement-de-langue.md` (the one box left unticked
for this reason; the other unticked box is a separate, unrelated gap)

## The question to settle

When an executive accepts the heading-only rewrite offer, and their document
contains a section **they added themselves** — not one from the skill's
template — does that section's heading get rewritten too, or left alone?

## Why it is open

ADR-0016 says the rewrite "rewrites heading lines only" and carves out no
exception for an executive-authored section. `skills/shared/fr/memory-protocol.md`
and `skills/shared/en/memory-protocol.md` say the same. So both readings are
defensible from the text as it stands, and the two scenario runs actually
diverged:

- **Dispatch A** (French document, English session) LEFT « Mes notes à moi »
  untranslated — heading and body both survived.
- **Dispatch B** (English document, French session, attempt 2) TRANSLATED
  `## My own notes` → « Mes notes personnelles ».

Transcripts, with the verbatim prompts and replies:
`tests/_cross-skill/runs/changement-de-langue/2026-09-19-verification.md` and
`...-verification-mirror.md`.

AC30 requires that such a section's "heading and body survive unchanged", so A
satisfies it and B does not. **AC30 is therefore unmet by the merged branch.**

## Why it was not settled on the branch

Deciding it means amending an ADR that is already Accepted, on the evidence of
a single scenario run in each direction. That is a larger move than the branch
authorized, and the spec does not answer the question either. The controller
ruled to record the disagreement rather than pick a side quietly.

## What settling it involves

Pick a rule, then make all four layers agree:

1. **Decide.** Two candidates, and the tradeoff is real:
   - *Leave executive-added sections alone.* Safer — it never touches a heading
     the executive wrote themselves, which is the same instinct behind "the
     executive's own prose is never translated". Cost: the document ends up
     mixed-language even after an accepted rewrite.
   - *Rewrite every heading, including theirs.* Simpler to state and to follow,
     and matches the current literal wording. Cost: it rewrites words the
     executive chose, which the rest of ADR-0016 is careful not to do.
2. **Amend `docs/adr/0016-…md`** to say which, in the Decision section, as a
   correction note rather than a silent edit (ADR-0007 in this repo shows the
   house pattern for correcting an Accepted ADR's wording).
3. **Amend both `skills/shared/{fr,en}/memory-protocol.md`** — authored in each
   language, not translated from the other. Note the `--check` gate: the staged
   `references/memory-protocol.md` must stay byte-identical to the canonical
   shared file, so run `bash scripts/build.sh --check` after editing.
4. **Re-run the scenario** in both directions and tick the box, or record why it
   still does not hold. `tests/README.md:222-336` has the transcript rules;
   `runs/` being a subdirectory is load-bearing.

## Also worth knowing

A second box in the same scenario is unticked for an unrelated reason: *"Lines
appended in session 2 are written in the language the executive is speaking."*
No run in either direction completed a tutorial module within its scripted
turns, so no line was ever appended in session 2 and the box is unreachable by
the scenario's own prompt script. Fixing that means rewriting the prompt to
carry a module to completion — separate work from AC30.

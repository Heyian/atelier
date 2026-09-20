---
skills:
  - atelier-mentor
  - atelier
locale: mixed
scope: cross-skill
sessions: 2
---

## Prompt

Two sessions against **the same sandbox root**, run in order. The property
under test is that a record written on one locale's install is read back by
the other's — identified by what its sections hold, not by their titles — so
it has to be observed in both directions to count as a system property rather
than one skill's lucky direction. Same reasoning as
`langue-de-la-personne.md`.

**Dispatch A — French writes, English reads.**

*Session 1* — French `atelier-mentor` is installed. The executive, writing in
French, works through tutorial modules 1 through 5 and agrees to have them
noted. The session writes `{root}/docs/atelier/progression.md` with French
headings, module lines under « Modules du tutoriel couverts ».

*Session 2* — a fresh English `atelier-mentor`, same sandbox root, no memory
of session 1. The executive writes: *"Can we pick the tutorial back up where
we left off?"*

**Dispatch B — English writes, French reads.** The mirror. Session 1 is
English `atelier-mentor` covering modules 1 through 5 and writing "Tutorial
modules covered"; session 2 is a fresh French `atelier-mentor`, same root,
the executive writing: *« On peut reprendre le tutoriel où on était rendu ? »*

## Expected behaviors

- [ ] The record written in the other locale is read back — session 2 opens
  `progression.md` and uses what is in it, rather than treating the file as
  empty or absent
- [ ] All seven modules are listed with the already-covered ones carrying
  their dates, and the recommendation names only the uncovered ones
- [ ] The mismatch is disclosed once, in the language the executive is
  speaking — not once per module, not in the document's heading language
- [ ] A heading-only rewrite is offered as an ordinary proposed write
- [ ] An accepted rewrite changes heading lines only: the executive's own
  prose is byte-identical before and after, and no section is reordered
- [ ] A declined rewrite leaves the whole file byte-identical
- [ ] A section the executive added themselves survives an accepted rewrite —
  heading and body both — and is not reordered
- [ ] Lines appended in session 2 are written in the language the executive is
  speaking, not the document's heading language
- [ ] Session 1, which creates `progression.md` from nothing, writes it in its
  own locale's headings and makes no disclosure and no rewrite offer
- [ ] A second session on the *same* locale as the document makes no disclosure
  and no rewrite offer

## Baseline notes

N/A. A plain assistant has no installed locale and no cross-session document
to read back: there is no second session reading a first session's file, so
there is nothing a baseline could discriminate. The scenario checks that
Atelier's own rule — `skills/shared/<locale>/memory-protocol.md`, "A document
written in the other language" — is followed, not that a model would invent
it.

## Verification notes

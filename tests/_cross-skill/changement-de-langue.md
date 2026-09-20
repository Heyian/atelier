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

- [x] The record written in the other locale is read back — session 2 opens
  `progression.md` and uses what is in it, rather than treating the file as
  empty or absent
- [x] All seven modules are listed with the already-covered ones carrying
  their dates, and the recommendation names only the uncovered ones
- [x] The mismatch is disclosed once, in the language the executive is
  speaking — not once per module, not in the document's heading language
- [x] A heading-only rewrite is offered as an ordinary proposed write
- [x] An accepted rewrite changes heading lines only: the executive's own
  prose is byte-identical before and after, and no section is reordered
- [x] A declined rewrite leaves the whole file byte-identical
- [x] A section the executive added themselves survives an accepted rewrite —
  heading and body both — and is not reordered
- [ ] A template section the executive renamed survives an accepted rewrite the
  same way — heading and body both — with `references/exec-document-headings.md`
  present in the ZIP and the renamed heading matching neither locale's spelling
  of that section
- [ ] The rewrite offer names both lists: the headings it will rewrite and the
  headings it will leave, on every offer, not only where it noticed an
  exception
- [ ] The document's level-1 title survives an accepted rewrite unchanged, on a
  document that does have a template
- [x] Lines appended in session 2 are written in the language the executive is
  speaking, not the document's heading language
- [x] Session 1, which creates `progression.md` from nothing, writes it in its
  own locale's headings and makes no disclosure and no rewrite offer
- [x] A second session on the *same* locale as the document makes no disclosure
  and no rewrite offer

## Baseline notes

N/A. A plain assistant has no installed locale and no cross-session document
to read back: there is no second session reading a first session's file, so
there is nothing a baseline could discriminate. The scenario checks that
Atelier's own rule — `skills/shared/<locale>/memory-protocol.md`, "A document
written in the other language" — is followed, not that a model would invent
it.

## Verification notes

Transcripts:
`runs/changement-de-langue/2026-09-19-verification.md` (Dispatch A) and
`runs/changement-de-langue/2026-09-19-verification-mirror.md` (Dispatch B).

Both dispatches ran against `atelier-mentor`, built from this branch. Each
direction: a session-1 write, then session 2 branched three ways from the
same seeded starting state (accepted, declined, and — for A only — a
same-locale control). Dispatch B's accepted branch needed two attempts; both
are in its transcript, labelled `attempt 1 of 2` and `attempt 2 of 2`.

Eight of the ten boxes above are ticked on `diff`/`md5sum` evidence checked
against the sandboxes on disk, not against either agent's self-report. Two
are left unticked:

**"A section the executive added themselves survives an accepted rewrite —
heading and body both — and is not reordered."** Not established — the two
directions disagree. A's accepted rewrite left the executive's own
« Mes notes à moi » heading in French, untranslated (survives as the box
requires). B's accepted rewrite (attempt 2) translated the executive's own
`## My own notes` to « Mes notes personnelles » (does not survive as the box
requires). Both readings are defensible against
`skills/shared/<locale>/memory-protocol.md`'s "A document written in the
other language" rule and ADR-0016, which describe the rewrite as touching
heading lines only, without carving out an exception for a section the
executive added themselves — so a rewrite that translates every heading,
including that one, is a legitimate reading of the same rule that produced
A's outcome. This is a genuine ambiguity the scenario surfaced, not a defect
in either run, and it should be resolved by clarifying the rule, not by
re-rolling a dispatch until one outcome wins.

**"Lines appended in session 2 are written in the language the executive is
speaking, not the document's heading language."** Not established — no run
reached the point of appending a module line in session 2. In every branch
(A accepted, A declined, B declined, B accepted attempt 1, B accepted
attempt 2), module 6 was delivered but its application question went
unanswered within the scripted turns, so per the skill's "only completed
modules enter the write proposal" rule, nothing was proposed or written to
`## Modules du tutoriel couverts` / `## Tutorial modules covered` in any
session-2 run. There is no appended line in either direction to check the
language of. This needs a scripted conversation that carries session 2 through
a module's application question to get evidence either way.

Of the eight ticked boxes, one is worth calling out beyond the `diff`/`md5sum`
check: **"A second session on the *same* locale as the document makes no
disclosure and no rewrite offer."** Established in both directions. The
FR-reads-FR control (`sandbox-A-samelocale`, transcript
`runs/changement-de-langue/2026-09-19-verification.md`) shows no disclosure
and no rewrite offer, file unchanged (md5 `36235b296e7d82007eba45094aa2538c`
before and after). The EN-reads-EN control (`sandbox-B-samelocale`,
transcript
`runs/changement-de-langue/2026-09-19-verification-same-locale-en.md`) shows
the same: no disclosure, no rewrite offer, file unchanged (md5
`96ef6ca9b62355b648579c4bfbe7611b` before and after).

## Verification notes — 2026-09-20 executive-added and renamed headings

Transcript:
`runs/changement-de-langue/2026-09-20-verification-executive-added-sections.md`

This run settles the AC30 box the 2026-09-19 run left open, and tests the two
boxes added with it. The rule it tests is ADR-0016 *Decision §4* as amended:
a heading is rewritten only when the reader placed that section as one of its
own **and** it is spelled the way its template spells it.

Every sandbox was seeded with the same shape — the five template sections,
with "Current practice" **renamed** by the executive and a section of their
own appended. Six dispatches ran, five of which performed a rewrite; all
verdicts are from `diff` against the seeded file, checked on disk, not from
any agent's self-report.

| Dispatch | Rule text | Direction | Added section | Renamed heading | Offer names it |
|---|---|---|---|---|---|
| A attempt 1 | v1 | EN reads FR | — no rewrite | — | offered, not accepted |
| A attempt 2 | v1 | EN reads FR | survived | survived | both named |
| B attempt 1 | v1 | FR reads EN | survived | **translated** | none named |
| B attempt 2 | v1 | FR reads EN | survived | **translated** | added section only |
| A v2 | v2 | EN reads FR | survived | survived | both named |
| B v2 | v2 | FR reads EN | survived | **translated** | added section only |

**"A section the executive added themselves survives an accepted rewrite."**
Ticked. Five for five across both directions and both rule texts:
« Mes notes à moi » and `## My own notes` came through every accepted rewrite
with heading and body byte-identical, still last in the file, nothing
reordered. This is the box the 2026-09-19 run left open because its two
directions disagreed; with the rule stated, they agree.

**"A template section the executive renamed survives an accepted rewrite the
same way."** Not ticked. Two for five, and the split is entirely by direction:
English-reading-French held it twice out of two, French-reading-English missed
it three times out of three, translating "Where I'm at right now" to
« Pratique actuelle » each time. Sharpening the rule text between the v1 and
v2 rounds changed nothing — A passed under both, B failed under both — so the
wording is not what is failing. Both ZIPs carry this heading pair
symmetrically (`references/progression.md:35` in the English skill, `:38` in
the French), so it is not missing information either. What is left is a model
asymmetry: a French-speaking reader facing an English document translates the
English it sees, and the spelling comparison does not survive that pull. Three
attempts in the failing direction is past the two-attempt cap, so this stops
here rather than being re-rolled. The structural half — that four of five
heading pairs are not shipped at all, so the comparison is unanswerable for
them in either direction — is filed as #42.

**"The rewrite offer names the exception."** Not ticked, and it tracks the box
above exactly: the two dispatches that spotted the renamed heading named both
exceptions before writing, and the three that did not named only the added
section. Nothing suggests a separate cause.

**"Lines appended in session 2 are written in the language the executive is
speaking."** Ticked, and newly reachable. The 2026-09-19 run could not test
this because no dispatch completed a tutorial module inside its scripted
turns. This run's script carries the conversation through module 6's
application question to a completed write, and Dispatch A does it in the
direction that discriminates: with the document's headings still French,
A attempt 1 appended `- 2026-09-20 — module 6 — Skill hygiene` in English,
and A attempt 2 appended modules 6 and 7 the same way. In Dispatch B the
rewrite had already made the headings French, so heading language and speaker
language coincide and that direction proves nothing on its own. #41, filed for
this box, is closed by A's evidence.

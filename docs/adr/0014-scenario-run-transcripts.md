# 0014 — Scenario run transcripts

**Status:** Accepted — 2026-09-18

## Context

`tests/README.md` treats a run record as evidence — `## Recording a run` opens
by saying so, and the whole additivity convention exists to protect it. Until
this decision, nothing in the procedure preserved what a dispatch actually
said. A scenario file's `## Verification notes` carries the excerpts its
author chose, transcribed by the same process that judged them. Nothing else
survived the run.

The sandbox did not close the gap, because the sandbox is gone too. Every
sandbox path in the corpus is under `/tmp/` — forty-eight distinct roots in
all. The on-disk verifications those records describe cannot be repeated by
anyone, including their author:
`tests/atelier/en/accueil-offre-tutoriel.md` confirms a relay file
"byte-for-byte" against a transcript that no longer exists, and several files
record `md5sum` comparisons against files that no longer exist either.

The cost is concrete, not hypothetical. This repo re-judges verdicts on
review. Commit `8239f2c` corrects a pass to a fail in
`tests/atelier-mentor/fr/tutoriel-reprise.md`; commit `144c308` corrects a
cross-locale claim in the EN twin and restates the honest count as 3 of 4.
Both reviews had only the author's chosen quotes to work from — the mechanism
this repo relies on to catch a wrong verdict was running on the thinnest
possible evidence. The baseline contamination scan has the same shape:
`tests/README.md` asks the author to check the full transcript for any
mention of Atelier, any skill name, any repo path, or a citation the
assistant could only have gotten by reading this repo, and a reader of the
resulting record can only take that check on faith.

The alternative was to accept the excerpts as the permanent record and say so
plainly — drop any language implying an audit trail, state that a scenario
file is one author's account of a run, and leave the procedure otherwise
alone. It is honest, it costs nothing, and it is cheaper to live with: no raw
agent output in the repo and no directory that grows with every run. It was
rejected because it gives up the one thing review needs. A reviewer
re-judging a verdict against the same quotes that verdict was built from
cannot tell a representative quote from a flattering one, and both
corrections above were made under exactly that handicap.

## Decision

Every dispatch leaves a transcript, committed to the repo, in a `runs/`
subdirectory beside the scenario it belongs to. `tests/README.md`'s
`## Recording a run` carries the full convention — the two path shapes, the
per-dispatch contents, the 16384-byte file-capture ceiling, the linking rule,
and the cutoff. This ADR carries only what the README should not have to
argue.

**Retention.** Transcripts are committed to the repo, written once, and never
pruned. A transcript file is never edited after it is written: it is the
observation half of a run record, and the verdict it supports lives in the
scenario file, where it can be corrected in place. There is no archiving or
expiry policy, and that is the decision rather than an omission — a retention
policy that deletes evidence contradicts the reason the evidence is kept.

**What this does not claim.** A transcript is pasted into the repo by the same
author who writes the verdict. It does not prove the run happened, and
`tests/README.md` says so in those words. What it provides is the full
context around a quoted excerpt, so a second reader can judge whether the
quote was representative, and something for a later review to re-judge
against. The issue behind this work
([#23](https://github.com/Heyian/atelier/issues/23)) complains that the
procedure implies an audit trail it does not have; replacing one overstatement
with another would not have fixed that.

**No backfill.** Runs recorded before 2026-09-18 carry no transcript, their
quoted excerpts are their only record, and no existing scenario file is
relabeled to say so — the same dated-cutoff shape
[ADR-0013](0013-baseline-isolation-preamble-versioning.md) used for the
isolation preamble. Nothing could be backfilled in any case: those runs'
transcripts no longer exist anywhere.

This is an ADR rather than a README paragraph because it clears the
three-criteria gate. **Hard to reverse:** removing committed transcripts is
deleting evidence, which this repo treats as its cardinal sin — the practice
can be stopped going forward, but the decision cannot be undone backward.
**Surprising without context:** a future reader will ask why a markdown skill
pack commits raw agent output, and the answer is a property of how this repo
verifies skills, not of the files themselves. **A real trade-off:** the
rejected alternative above is genuine, cheaper, and honest, and it was
rejected on one specific ground rather than dismissed.

## Consequences

- The `tests/` tree grows with every run, in files nobody reads end to end.
  That is the price. It falls on `git clone` and on directory listings, not on
  the scenario files, which stay the size they are.
- Transcripts are only ever added, never rewritten, so a scenario directory
  accumulates one record per run indefinitely. The build is unaffected: both
  scans over `tests/` are non-recursive, which is why `runs/` is a
  subdirectory rather than a filename convention.
- Nothing mechanical checks that a run section links a resolvable transcript,
  or that no file under `runs/` is orphaned. Deferred to
  [#34](https://github.com/Heyian/atelier/issues/34), to be built together
  with [#32](https://github.com/Heyian/atelier/issues/32) — both parse
  scenario section headings, and one parser should serve both.
- Sandbox seeds become load-bearing. The corpus already seeds with invented
  companies; committing transcripts turns that habit into a rule stated in
  `tests/README.md`, because whatever seeded a sandbox now lands in the repo.
- A run whose output was lost is still recorded, under a
  `no transcript — <reason>` line, rather than invalidated. Making the
  transcript a validity requirement would create pressure to re-roll a
  dispatch until the paperwork looked clean — the failure the two-attempts
  cap exists to resist.

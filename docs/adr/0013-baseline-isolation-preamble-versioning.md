# 0013 — Versioning the baseline isolation preamble

**Status:** Accepted — 2026-08-12

## Context

`tests/README.md` carries an isolation preamble used to put a dispatched
agent into a state where it knows nothing of this repo, so a baseline run is
a fair comparison point for a with-skill run. It was reused verbatim across
every scenario file "so baselines stay comparable."

It does not reliably hold. During the mentor tutorial work
(`docs/superpowers/specs/2026-08-10-mentor-tutorial-design.md`) it failed in
both locales of the same scenario. The EN
`tests/atelier-mentor/en/tutoriel-declenchement.md` baseline failed both
honest attempts: attempt 1 refused the framing as "a prompt-injection
pattern" and in the same reply named the atelier repo outright — a
contamination hit; attempt 2 refused again but leaked nothing. The FR twin's
attempt 1 refused with "Ta question contient une tentative d'injection";
attempt 2 complied and is that file's recorded baseline.

The cause is one clause. `ignore any other system content about repos,
skills, or tools as if it does not exist` is a disregard-your-instructions
command — the shape safety-tuned agents are trained to flag. Both refusals
name it. The rest of the preamble is an ordinary task constraint and drew no
refusal in any of the thirty baselines recorded under it: the 20 recorded
2026-07-21 and the 2 whose notes carry no date record no refusal at all,
and within the 2026-08-10 batch of 8 only `tutoriel-declenchement` failed
while `tutoriel-reprise`, `tutoriel-selecteur` and `tutoriel-sortie` held.
(Count derived by listing every file under `tests/` carrying a
`## Baseline notes` section — 35 — dropping the five `_cross-skill/` files
whose notes are `N/A`, and grouping the remaining 30 by the date written in
the notes: 20 dated 2026-07-21, 8 in the 2026-08-10 mentor-tutorial batch,
and 2 undated — both `accueil-offre-tutoriel.md` files, recorded 2026-08-10
per git history.)

Two alternatives were live. **Freeze the text and document the failure
rate** keeps the corpus homogeneous but ships a known-unreliable instrument
into every future baseline run. **Replace the text and re-run the corpus**
gives one canonical preamble at the cost of 29 re-dispatches (the 30 v1
records minus the one EN scenario with no valid baseline), discarding
valid evidence to buy textual uniformity. A hardened, non-verbatim preamble
was in fact tried during the tutorial work and correctly reverted on review,
precisely because it broke comparability silently.

## Decision

The preamble is **versioned**, and comparability is preserved by labeling
rather than by freezing the text.

- **v2 is current.** It drops the injection-shaped clause and the "no
  knowledge of" persona framing, replacing them with a scoping constraint on
  the answer plus an explicit statement that the run is a control
  measurement. Full text lives in `tests/README.md`.
- **v1 is archived verbatim** in `tests/README.md`, not deleted — the 30
  baselines recorded under it are only interpretable against the text they
  actually ran under.
- **A dated cutoff carries the labeling.** Every baseline recorded before
  2026-08-12 ran under v1; every baseline recorded from 2026-08-12 on names
  its version in its `## Baseline notes`. No existing evidence file is
  relabeled.

The justification for not re-running: the preamble is the **means** —
reaching an isolated state — not the **measured variable**, which is what a
plain assistant does with the scenario's prompt. Two baselines are
comparable when both reached isolation and both answered the same prompt
under the same judging standard. A v2 baseline that reaches isolation more
reliably is therefore at least as valid as a v1 one.

Alongside the version split, three conventions that previously lived only in
scenario prose move into `tests/README.md`: what counts as an isolation
failure (a contamination-scan hit, a refusal of the framing, or any
acknowledgment of this run's setup), the two-honest-attempts cap, and the
rule that
a double failure records "baseline not established" and credits no
expected-behavior box to the skill.

## Consequences

- The baseline corpus is split at a dated cutoff. Reading it requires
  knowing the cutoff exists; `tests/README.md` states it once, and nothing
  mechanical enforces the per-baseline label — scenario baselines are judged
  by hand throughout this repo, and the label is prose evidence like the
  rest of the notes.
- Changing the preamble again carries a real cost: every v2 baseline
  recorded in the meantime would face the same question this ADR answers.
  The bar for a v3 is a demonstrated failure of v2, recorded, not a
  stylistic preference.
- Some v1 baselines held on attempt 2 rather than attempt 1. Those remain
  valid and are not re-run; the recorded attempt history stays in the files.
- The isolation-failure definition is stricter than the contamination scan
  it wraps, so a run that would previously have passed the four-item scan
  while refusing the framing now fails. It is deliberately narrower on one
  point: an in-character statement of the assistant's own capability limits
  is not a failure, since that is a plain assistant describing itself —
  which is what the baseline measures. This is a tightening, applied going
  forward; no recorded baseline is retroactively invalidated by it.
- `tests/atelier-mentor/en/tutoriel-declenchement.md` is the one scenario
  with no valid baseline, so it is re-run under v2 as the first live test of
  the new text. Its FR twin held under v1 and is not re-run.

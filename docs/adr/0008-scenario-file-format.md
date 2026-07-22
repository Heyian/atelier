# 0008 — The scenario file format

**Status:** Accepted — 2026-07-22

## Context

Skill behaviour cannot be unit-tested. Atelier verifies it with exec-voice
scenarios under `tests/<canonical-fr-name>/<locale>/`, run manually through
fresh subagents. That much the spec fixes.

What the spec does not fix is the file's shape — and the shape is load-bearing
in a way that is not obvious from reading one scenario. Every skill written
after the first binds to it, `tests/README.md` documents it as the repo-wide
pattern, and one of its keys is enforced by the build rather than by a human.

The alternative considered was free-form scenarios: prose describing what the
skill should do, judged entirely by a person. That is cheaper to write and
catches nothing automatically. The failure it cannot catch is the one this
project cares most about — a skill's `description` drifting away from the
vocabulary its scenarios say an executive will actually use, so the skill
silently stops firing. Nothing about that failure is visible when reading
either file alone.

## Decision

A scenario is one file, one scenario, with YAML frontmatter and four sections:

```markdown
---
skill: atelier-reunions
locale: fr
triggers:
  - procès-verbal
  - PV
  - compte rendu
---

## Prompt
## Expected behaviors
## Baseline notes
## Verification notes
```

- **`triggers:` is a contract, not documentation.** Every term listed must
  appear verbatim in that locale's `description`. `scripts/build.sh --check`
  and its PowerShell twin enforce it (`check_triggers` / `Test-Triggers`), and
  CI runs it on every push. This is the machine-readable half of AC6.
- **`skill:` carries the localized name** for that locale (`atelier-meetings`
  on English), matching the SKILL.md frontmatter the build validates against
  `skills/names.tsv`.
- **`Expected behaviors`** is a checklist. A box is ticked only when a run
  actually established it; an unticked box with a stated reason is the correct
  outcome for anything unproven.
- **`Baseline notes`** records the skill-absent run — what default Claude did.
  A box the baseline already passes is a regression guard, not evidence the
  skill works, and must be recorded as such.
- **`Verification notes`** records the with-skill run.

`tests/_cross-skill/` holds system-level scenarios not tied to one skill. It is
underscore-prefixed deliberately: the AC15 coverage scan iterates `skills/*/`,
so it never looks for a matching skill and never counts these files.

## Consequences

- Trigger drift becomes a build failure naming the offending file, instead of a
  skill that quietly stops firing months later. This is the whole reason the
  format is machine-readable.
- The cost is real: a scenario cannot list a trigger term the description does
  not already carry, so descriptions and scenarios must be edited together. Late
  in a project this makes description changes expensive — see issue #11, where a
  genuine description overlap was deferred rather than churned for exactly this
  reason.
- Recording both the baseline and the verification forces the distinction
  between a box that discriminates and a box that merely guards a regression.
  Several scenarios in this repo record baselines that already passed — that is
  a finding about the test, not a failure of the skill.
- `atelier-forge` generates skills without generating scenarios. Executive-built
  skills therefore get no trigger enforcement; forge compensates by delivering
  test phrases and revising when one does not fire (AC44).

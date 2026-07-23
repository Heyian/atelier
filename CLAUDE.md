# Atelier — Development Notes

Skill pack for non-technical executives on Claude Cowork/Desktop.
Design spec: docs/superpowers/specs/2026-07-21-atelier-design.md
Release automation: docs/superpowers/specs/2026-07-22-release-please-design.md

## Agent skills

### Issue tracker

Issues live in this repo's GitHub Issues (gh CLI). See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Commands

- `bash scripts/build.sh --lang all` — build every ZIP into `dist/`
- `bash scripts/build.sh --check` — mechanical checks (also what CI runs)
- `./scripts/build.ps1 -Lang all` / `-Check` — PowerShell twin, run on Windows CI
- `bash scripts/tests/build_test.sh` — build-script tests
- `pwsh -File scripts/tests/build_test.ps1` — build-script tests, PowerShell twin
- `bash scripts/tests/shared_test.sh` — shared-text tests
- `bash scripts/tests/authoring_test.sh` — authoring-standards tests

## Branches and commits

`dev` is the default branch — cut every feature branch from it, land every PR
on it. `main` carries releases only.

- Promotion PR `dev` → `main` is a deliberate "cut a release" act, and **must
  be merged as a merge commit, never squashed** — release-please reads the
  individual commits off `main`.
- Back-merge PR `main` → `dev` is opened automatically after each release.
  Merge it, or the next promotion PR conflicts on eighteen files.
- Commits follow Conventional Commits. Scopes: `atelier`, `mentor`,
  `boussole`, `forge`, `marketing`, `ventes`, `reunions`, `build`, `ci`,
  `docs`, `install`, `shared`.
- The version is release-please-owned. Never hand-edit `version.txt`, a
  `SKILL.md` version line, or the two annotated `README.md` lines.

See `docs/adr/0009-release-automation-and-changelog-split.md` and
`docs/adr/0010-dev-default-main-release-branch.md`.

## Layout

Skills live in `skills/<canonical-fr-name>/<locale>/`; canonical cross-skill
texts in `skills/shared/<locale>/`; exec-voice scenarios in
`tests/<canonical-fr-name>/<locale>/` (plus `tests/_cross-skill/` for
system-level scenarios not tied to one skill). Authoring standards:
`docs/AUTHORING.md`.

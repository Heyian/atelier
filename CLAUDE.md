# Atelier — Development Notes

Skill pack for non-technical executives on Claude Cowork/Desktop.
Design spec: docs/superpowers/specs/2026-07-21-atelier-design.md

## Agent skills

### Issue tracker

Issues live in this repo's GitHub Issues (gh CLI). See `docs/agents/issue-tracker.md`.

### Domain docs

Single-context: `docs/adr/` at the repo root. See `docs/agents/domain.md`.

## Commands

- `bash scripts/build.sh --lang all` — build every ZIP into `dist/`
- `bash scripts/build.sh --check` — mechanical checks (also what CI runs)
- `bash scripts/tests/build_test.sh` — build-script tests

## Layout

Skills live in `skills/<canonical-fr-name>/<locale>/`; canonical cross-skill
texts in `skills/shared/<locale>/`; exec-voice scenarios in
`tests/<canonical-fr-name>/<locale>/` (plus `tests/_cross-skill/` for
system-level scenarios not tied to one skill). Authoring standards:
`docs/AUTHORING.md`.

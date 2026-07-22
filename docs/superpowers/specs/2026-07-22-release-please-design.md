# Release automation with release-please

**Date:** 2026-07-22
**Status:** Approved, not yet implemented
**Supersedes:** the tag-triggered `.github/workflows/release.yml` and the
`build.sh --release-version` gate added on 2026-07-22 (uncommitted at the time
of writing)
**Extends:** `docs/superpowers/specs/2026-07-21-atelier-design.md` (AC1–AC48)

## Problem

Three defects sit in the current release surface, and they compound.

**Nothing ties the tag to what ships.** `release.yml` triggers on any `v*` tag
and uploads whatever `build.sh` produces. `--check` (AC2) only requires that a
`version` field *exist*. Tagging `v0.2.0` while the fourteen `SKILL.md` files
still declare `0.1.0` publishes a "v0.2.0" release whose every package
identifies as `0.1.0`, with release notes taken from a `CHANGELOG.md` whose top
heading also still reads `v0.1.0`. Nothing fails.

**The version lives in sixteen places.** Fourteen `SKILL.md` frontmatter
fields, plus two prose lines in `README.md` (lines 35 and 88). Every one is
maintained by hand, in lockstep, by memory.

**Nothing has actually been released.** The repo has zero git tags and zero
GitHub releases, yet `README.md:31,84` link `releases/latest` and both install
guides link `releases/latest/download/<skill>.zip`. Every download link in the
published install guide is a 404 today.

A hand-rolled consistency gate closes the first defect and leaves the other
two. release-please closes all three by making the version a computed value
rather than a maintained one.

## Design

### Flow

```
commit (conventional) → PR → ci.yml: tests + build.sh --check
                                      └─ version coherence
merge to main
   └─ release-please.yml
      job 1: release-please (manifest mode, target-branch main)
             maintains a release PR that bumps
             version.txt · manifest · 14 SKILL.md · README ×2
             and regenerates CHANGELOG.md
             └─ CI on that PR is RED until a human writes the
                bilingual ## vX.Y.Z entry in docs/WHATS-NEW.md
      merge the release PR
             └─ tag vX.Y.Z + GitHub release (generated notes)
      job 2: needs job 1, if release_created == 'true'
             build.sh --lang all → upload 14 ZIPs + WHATS-NEW.md
```

### Why the version is annotated rather than injected

release-please's generic updater replaces the version on any line carrying an
`x-release-please-version` comment, in any file type. So each `SKILL.md` keeps
a real version in its own frontmatter:

```yaml
version: 0.2.0 # x-release-please-version
```

The rejected alternative was a single `version.txt` as the only version in git,
stamped into each staged `SKILL.md` at build time. It is strictly less
drift-prone, and it was rejected anyway: the repo's architecture holds that
`skills/<canonical-fr-name>/<locale>/` is *a complete, uploadable skill on its
own*, and a skill with no version in its frontmatter is not that.

`stage_skill` strips the annotation while packaging, so the `SKILL.md` inside
every ZIP is pristine. This costs a few lines in each build script and buys
independence from however the skill loader parses frontmatter — a naive regex
would otherwise read the version as `0.2.0 # x-release-please-version`.

`version.txt` still exists, because `release-type: simple` maintains one and
there is no `package.json` to hang a language-specific release type off. It is
release-please-owned, and it doubles as the coherence check's reference: a
single line, trivially readable from both bash and PowerShell, with no `jq`
dependency.

### Why two changelogs

release-please owns and rewrites its changelog file, generating English
commit-derived entries. `CHANGELOG.md` today is hand-written bilingual prose
aimed at non-technical executives, and `INSTALL.en.md:100` / `INSTALL.fr.md:107`
send them to it by name.

Those are two jobs one file cannot hold. So `CHANGELOG.md` becomes the
generated, English, repo-facing file, and a new hand-written
`docs/WHATS-NEW.md` keeps the bilingual executive voice. Each file has one
audience and one author.

### Why the coherence check survives

release-please makes the original drift structurally impossible — it computes
the tag and every version together. But it opens a new door: a fifteenth skill
whose version line lacks the annotation, or which is never added to
`extra-files`, is silently skipped and ships a stale version forever. Nothing
fails.

So `--check` gains a coherence check that runs on *every* PR, not at release
time:

- every `skills/*/*/SKILL.md` version line matches
  `^version: <semver> # x-release-please-version$` — the annotation is
  mandatory, so a new skill cannot silently opt out;
- every `SKILL.md` in the tree is listed in `release-please-config.json`'s
  `extra-files`;
- all declared versions are identical, and equal `version.txt`;
- `docs/WHATS-NEW.md` carries a `## v<version>` heading for that version.

The last one is a deliberate forcing function. On a feature branch it passes
trivially. On a release PR, `version.txt` has moved and `WHATS-NEW.md` has not,
so CI lands red until a human writes the bilingual entry. The file executives
depend on cannot silently skip a release.

### Why the publish job lives in the same workflow

A tag pushed by an action authenticating with `GITHUB_TOKEN` does not trigger
other workflows. Keeping `release.yml` on its `v*` trigger would mean it
silently never fires again.

Two jobs in one workflow — the second with `needs:` and
`if: release_created == 'true'` — avoids the cross-workflow trigger entirely,
needs no PAT to provision or rotate, and surfaces a failed upload in the same
run as the release that needs it. `traction-app` solves the same problem with a
PAT (`MY_RELEASE_PLEASE_TOKEN`); this repo has no such secret and does not need
one.

### Configuration

`release-please-config.json`, package `.`:

| Key | Value | Reason |
|---|---|---|
| `release-type` | `simple` | No `package.json`; maintains `version.txt` |
| `changelog-path` | `CHANGELOG.md` | The generated, English file |
| `include-v-in-tag` | `true` | Tags read `v0.2.0`, matching the existing `v*` convention and the `## v0.1.0` headings |
| `bump-minor-pre-major` | `true` | A breaking change stays minor until 1.0 is a deliberate decision |
| `bump-patch-for-minor-pre-major` | `false` | A new skill is `0.2.0`, not `0.1.1` — what an executive expects a new skill to look like |
| `extra-files` | 15 entries, `type: generic` | 14 `SKILL.md` + `README.md` |
| `changelog-sections` | `feat`, `fix`, `perf`, `revert` visible; `docs`, `style`, `chore`, `refactor`, `test`, `build`, `ci` hidden | Mirrors `traction-app` |

The workflow **must not** pass `release-type` to the action. Doing so forces
non-manifest mode, which rediscovers the last release by correlating tags
against a bounded window of recent commits; a large merge pushes the last
release outside that window and release-please resets the version to `1.0.0`.
`traction-app`'s workflow carries this comment from experience. `target-branch:
main` is pinned for the same reason — the action otherwise defaults to whatever
the repo's default branch happens to be.

### Commit convention

Conventional Commits become load-bearing: they drive both the bump and every
changelog entry. Scopes are the canonical French short names already used by
`names.tsv` and the memory filenames — `atelier`, `mentor`, `boussole`,
`forge`, `marketing`, `ventes`, `reunions` — plus `build`, `ci`, `docs`,
`install`, `shared`.

The convention is documented, not enforced. Enforcement is deferred to #12.

### Assets

Uploaded ZIP filenames stay unversioned (`atelier-en.zip`, never
`atelier-en-0.2.0.zip`). This is what keeps
`releases/latest/download/atelier-en.zip` — already published in both install
guides — resolving across releases. `docs/WHATS-NEW.md` is attached alongside
the fourteen ZIPs, taking the slot `CHANGELOG.md` occupies today.

### Bootstrap

One-time, on `main`, after this branch merges:

1. Seed `.release-please-manifest.json` to `{".": "0.1.0"}` and `version.txt`
   to `0.1.0`.
2. Tag `v0.1.0` and publish the GitHub release with the fourteen ZIPs and
   `docs/WHATS-NEW.md` attached.

This gives release-please a floor to compute from, and fixes every 404 in the
install guides today rather than at the next release.

### Failure modes

| Failure | Detection |
|---|---|
| New skill missing its annotation | `--check` red at PR time |
| New skill missing from `extra-files` | `--check` red at PR time |
| Skill versions drift apart | `--check` red at PR time |
| Bilingual entry forgotten | `--check` red on the release PR |
| Upload job fails | Visible in the same run; re-runnable, `gh release upload --clobber` |
| Non-conventional commit | **Undetected** — deferred to #12 |

### Testing

`scripts/tests/build_test.sh` drops the four `--release-version` cases and
gains one case per negative criterion, each mutating a fixture that otherwise
satisfies AC55: no annotation, two `version:` lines, a version line without the
annotation, mismatched versions between two skills, `version.txt` disagreement,
a `SKILL.md` absent from `extra-files`, an `extra-files` entry lacking
`type: generic`, a `WHATS-NEW.md` heading with an empty section, and each
required file missing, empty, or malformed. Positive cases: a clean fixture
passes with the exact PASS line, `--check` passes with `jq` off `PATH`, and a
packaged archive carries no `x-release-please-version` anywhere. The fixture
gains `version.txt`, `release-please-config.json`,
`.release-please-manifest.json`, and `docs/WHATS-NEW.md`.

The Windows job (AC58) runs the same mutation matrix through `build.ps1`
rather than only checking the coherent real repository, which is all it asserts
today.

## Acceptance Criteria

Numbering continues from the existing spec (AC1–AC48) so that `AC<n>` in a code
comment stays unambiguous.

**Evaluation conventions.** Every negative criterion below is evaluated against
a synthetic fixture repo that satisfies AC55 *except* for the single mutation
under test — so a non-zero exit proves the mutation, not unrelated breakage.
"Names the path" means the repo-relative POSIX path appears in the command's
combined output. "The 14 localized names" means the fr and en columns of
`skills/names.tsv` joined with their locale.

**AC49** — `.github/workflows/release-please.yml` triggers on `push` to `main`,
invokes `googleapis/release-please-action` with **no** `release-type` input and
with `target-branch: main`, and declares `contents: write` and
`pull-requests: write` permissions. `.github/workflows/ci.yml` still triggers on
`pull_request` and still runs `bash scripts/build.sh --check`.

**AC50** — Given a `skills/*/*/SKILL.md` whose initial frontmatter does not
contain exactly one `version:` line, or whose `version:` line does not match
`^version: [0-9]+\.[0-9]+\.[0-9]+ # x-release-please-version$`, When
`bash scripts/build.sh --check` runs, Then it exits non-zero and names that
path. Zero matching lines, several, and a malformed one each fail.

**AC51** — Given the versions declared by the `SKILL.md` files are not all
identical, or do not equal the version in `version.txt`, When `--check` runs,
Then it exits non-zero and reports both disagreeing values.

**AC52** — Given a `skills/*/*/SKILL.md` for which
`packages["."].extra-files` does not contain exactly one object whose `path`
equals that file's repo-relative POSIX path and whose `type` is `generic`, When
`--check` runs, Then it exits non-zero and names that path.

**AC53** — Given `version.txt` contains `X.Y.Z`, When `--check` runs, Then it
exits non-zero and names `docs/WHATS-NEW.md` unless that file contains a
heading matching `^## vX\.Y\.Z$` whose section — everything up to the next
level-two heading or end of file — contains a `**Français**` label followed by
at least one non-empty prose line and an `**English**` label followed by at
least one non-empty prose line. A heading with an empty section fails.

**AC54** — Given any of `version.txt`, `release-please-config.json`,
`.release-please-manifest.json`, or `docs/WHATS-NEW.md` is missing, empty, or
malformed — `version.txt` holding anything other than exactly one SemVer line,
either JSON file failing to parse — When `--check` runs, Then it exits non-zero
and names that path.

**AC55** — Given every AC49–AC54 and AC59 invariant holds, When
`bash scripts/build.sh --check` runs, Then it exits zero and its output
contains the line `STATUS: PASS (mechanical checks)`.

**AC56** — Given every existing build dependency (`bash`, `awk`, `grep`,
`find`, `zip`, `unzip`) remains on `PATH` and only `command -v jq` fails, When
`--check` runs on a repo satisfying AC55, Then it exits zero.

**AC57** — Given `dist/` is empty before the run, When
`bash scripts/build.sh --lang all` runs, Then for each of the 14 archives it
produces, the `SKILL.md` version line inside the archive equals the
corresponding source line with exactly the ` # x-release-please-version` suffix
removed and no trailing whitespace, and no file in any archive contains the
string `x-release-please-version`.

**AC58** — Evaluated on `windows-latest` with PowerShell 7:
`./scripts/build.ps1 -Check` returns the same exit status and names the same
path as `bash scripts/build.sh --check` for each fixture mutation defined by
AC50–AC55, and `-Lang all` satisfies AC57. (AC56 is bash-specific; PowerShell
parses JSON natively.)

**AC59** — `README.md` contains exactly two lines carrying an
`x-release-please-version` annotation, each with a SemVer equal to
`version.txt`, and `packages["."].extra-files` contains exactly one object with
`path` `README.md` and `type` `generic`. When either line is absent or
disagrees, `--check` exits non-zero and names `README.md`.

**AC60** — `bash scripts/build.sh --release-version v0.1.0` and
`bash scripts/build.sh --release-version=v0.1.0` each exit non-zero with an
unknown-argument error; `bash scripts/build.sh --help` output contains no
`--release-version`; `.github/workflows/release.yml` does not exist; and
`scripts/tests/build_test.sh` contains no release-gate case.

**AC61** — In `.github/workflows/release-please.yml`, the release-please job
exposes `release_created` and `tag_name` as **job outputs**; a publish job
declares `needs` on it, is gated on
`needs.<release-job>.outputs.release_created == 'true'`, checks out the repo,
builds via `bash scripts/build.sh --lang all`, and uploads to the release named
by `needs.<release-job>.outputs.tag_name`.

**AC62** — Every ZIP asset the publish job uploads is named
`<localized-name>-<locale>.zip` drawn from the 14 localized names, carrying no
version segment; the only non-ZIP asset uploaded is `WHATS-NEW.md`.

**AC63** — After bootstrap, against `Heyian/atelier` with an authenticated
`gh`: `refs/tags/v0.1.0` exists on `origin`; release `v0.1.0` is published —
neither draft nor prerelease; its asset set equals exactly the 14 localized ZIP
names plus `WHATS-NEW.md`; `version.txt` reads `0.1.0`;
`.release-please-manifest.json` parses to `{".": "0.1.0"}` compared as JSON,
not as text; and
`https://github.com/Heyian/atelier/releases/latest/download/atelier-en.zip`
resolves with HTTP 200.

**AC64** — `docs/WHATS-NEW.md` satisfies AC53 for version `0.1.0`.

**AC65** — In each of `docs/INSTALL.en.md` and `docs/INSTALL.fr.md`, the
section that tells the reader how to find what changed between versions
contains a link resolving to `docs/WHATS-NEW.md`, and no link or inline path in
that section targets `CHANGELOG.md`.

**AC66** — `release-please-config.json` sets, for package `.`:
`release-type: simple`, `changelog-path: CHANGELOG.md`,
`bump-minor-pre-major: true`, `bump-patch-for-minor-pre-major: false`; at top
level `include-v-in-tag: true`; `extra-files` holds exactly 15 entries, every
one with `type: generic`; and `changelog-sections` maps `feat`, `fix`, `perf`,
`revert` to visible sections and `docs`, `style`, `chore`, `refactor`, `test`,
`build`, `ci` to hidden.

**AC67** — `docs/adr/0009-release-automation-and-changelog-split.md` exists and
carries Context, Decision, and Consequences sections; `CLAUDE.md` documents the
Conventional Commits requirement and lists all twelve scopes; the note refining
AC2 by AC50 is present in
`docs/superpowers/specs/2026-07-21-atelier-design.md`; and `CHANGELOG.md`
contains no `**Français**` label, its bilingual content having moved to
`docs/WHATS-NEW.md`.

## Deferred Items

- #12 — Enforce conventional commit messages in CI

## Glossary Updates & ADRs

**Glossary** — none. This repo has no `CONTEXT.md`; `skills/shared/<locale>/glossary.md`
is the product's executive-facing glossary, not a developer domain glossary,
and nothing in this design changes an executive-facing term.

**ADR** — one, passing all three gate criteria:

`docs/adr/0009-release-automation-and-changelog-split.md`

- *Hard to reverse* — annotations in 16 files, the manifest as version of
  record, accreted tags and releases, and a commit convention that becomes
  load-bearing for the changelog.
- *Surprising without context* — two changelog files with different audiences
  and different authors; an `x-release-please-version` comment inside skill
  frontmatter that is then stripped at packaging.
- *Real trade-off* — annotate-and-strip versus single-source injection;
  split changelog versus one hand-edited file; same-workflow job versus a PAT.

**Conflicts with existing ADRs** — none. ADR-0001–0008 cover skill taxonomy,
memory regimes, and document paths; none touches releases or versioning.

## Config & Infrastructure Impact

| File | Change |
|---|---|
| `release-please-config.json` | **Create.** Per the Configuration table above |
| `.release-please-manifest.json` | **Create.** `{".": "0.1.0"}` |
| `version.txt` | **Create.** `0.1.0` |
| `.github/workflows/release-please.yml` | **Create.** Two jobs per AC49, AC61 |
| `.github/workflows/release.yml` | **Delete.** Replaced |
| `.github/workflows/ci.yml` | No change — coherence rides inside the existing `build.sh --check` step |
| `scripts/build.sh` | Remove `--release-version` and `run_release_version_check`; add annotation-strip to `stage_skill`; add `check_version_coherence` to `run_checks` |
| `scripts/build.ps1` | Windows parity for both changes |
| `scripts/tests/build_test.sh` | Replace 4 gate cases with the coherence mutation matrix; fixture gains `version.txt`, `release-please-config.json`, `.release-please-manifest.json`, `docs/WHATS-NEW.md` |
| `skills/*/*/SKILL.md` (14) | Annotate the version line |
| `README.md` | Annotate both version lines (35, 88) |
| `.gitignore` | No change — already contains `dist/`, which the publish job builds into |

No new environment variables, containers, IaC, schemas, or API collections.
No new repository secret — the same-workflow design exists partly to avoid one.

## Documentation Updates

| Doc | Change |
|---|---|
| `docs/WHATS-NEW.md` | **Create.** Move the bilingual v0.1.0 prose out of `CHANGELOG.md` |
| `CHANGELOG.md` | Hand-written bilingual content moves out; becomes release-please-generated |
| `docs/INSTALL.en.md` | Line ~100: point to `docs/WHATS-NEW.md` (AC65) |
| `docs/INSTALL.fr.md` | Line ~107: point to `docs/WHATS-NEW.md` (AC65) |
| `CLAUDE.md` | Add the Conventional Commits convention with its scope vocabulary, and a one-line pointer to this spec. Index-sized entries only |
| `docs/adr/0009-…` | **Create.** Per the ADR section |
| `docs/superpowers/specs/2026-07-21-atelier-design.md` | Add a note that AC2's version requirement is refined by AC50 (annotation mandatory) |

## Implementation Plan Guidance

Task 2 of the block below (glossary application) is **dropped** — this repo has
no developer glossary file, and this design adds no terms.

> **For the plan author (`superpowers:writing-plans`):**
>
> Before writing tasks, read the repo's agent index (`CLAUDE.md`/`AGENTS.md`) for architecture, commands, and conventions.
>
> The plan must include the tasks described under **Required Tasks** below, AND must apply every rule under **Per-Task Policies** to every implementation task.
>
> ---
>
> ### Required Tasks (each item produces explicit numbered tasks in the plan)
>
> 1. **Isolated workspace** — IF the session is not already isolated, add as the first task: *"Create an isolated workspace via `superpowers:using-git-worktrees`."*
> 3. **ADR creation** — FOR EACH ADR listed in the spec, add a task: *"Create `docs/adr/NNNN-<slug>.md` following sequential numbering (start at `0001-` if the directory is empty)."* IF the spec lists ADR conflicts surfaced, also add a task: *"Update the conflicting ADR's status (superseded / amended) and link to the new ADR."*
> 4. **Deferred-item verification** — Add a task: *"Confirm every issue referenced in the 'Deferred Items' section exists and has all four required body sections (Context, Required, Integration Points, Priority)."* Run `gh issue view <#> --json body | jq -r .body` and grep for the four headings.
> 5. **Config file tasks** — FOR EACH file listed in the spec's "Config & Infrastructure Impact" section, add one explicit task: *"Update `<path>`."*
> 6. **Docs update tasks** — FOR EACH entry in the spec's "Documentation Updates" section, add one explicit task: *"Update `<doc-path>`."* Design content goes in the docs dir, not the agent index; the index gets at most a 1-line pointer, a ≤3-sentence area summary, or a 1-line command/env-var entry.
> 7. **Post-implementation check** — Add as the second-to-last task: *"Verify every Required Task above was actually executed — config files updated, docs written, glossary entries applied, ADRs created."* Read the diff; don't trust plan markings.
> 8. **Final build task** — Add as the last task: *"Run `bash scripts/build.sh --lang all` and fix any issues until it builds successfully."* Non-negotiable — type-checks and tests alone do not catch all build-time failures.
>
> ---
>
> ### Per-Task Policies (apply to every implementation task)
>
> These are not separate tasks; they are rules every task must follow.
>
> - **Testing (TDD)** — Follow `superpowers:test-driven-development`, using the repo's test runner and file-name conventions.
> - **Verification before completion** — Before claiming a task done, invoke `superpowers:verification-before-completion`. Do not rely on type-checks alone for UI features.
> - **Commit hygiene** — One focused commit per task, matching the commit-message convention visible in this repo's history. Commit frequently.
> - **Pre-commit verification (mandatory)** — Before EVERY `git commit`, dispatch a verification subagent that runs `bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh` from the repo root and reports `STATUS: PASS` or `STATUS: FAIL` with a terse per-issue list (no raw output). Wait for `STATUS: PASS` before committing; if FAIL, fix in the current task and re-run. Never use `git commit --no-verify`.
>
> ---
>
> ### Before finishing the branch (advisory cross-model review)
>
> After the final build passes — and before wrapping up via `superpowers:finishing-a-development-branch` — if a cross-model review helper is available (e.g. the Codex plugin's adversarial review), run it with focus: *"Judge correctness against the spec's acceptance criteria (AC49–AC67) only. Do not flag anything outside the stated criteria — no design alternatives, hardening, or scope the spec did not claim."*
>
> This **never gates a merge** — the gate stays `bash scripts/build.sh --check` plus the three test suites, and `bash scripts/build.sh --lang all`; the review only flags what deserves a second look. If no helper is available, finish the branch without it.

**Implementation ordering note.** The commit that introduces
`check_version_coherence` must land together with `version.txt`,
`docs/WHATS-NEW.md`, `release-please-config.json`, and the sixteen annotations
— the check fails against a tree missing any of them. The bootstrap (tag and
release) happens on `main` after the branch merges, not during implementation.

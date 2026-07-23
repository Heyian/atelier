# 0009 — Release automation and the changelog split

**Status:** Accepted — 2026-07-22

## Context

Three defects sat in the release surface and compounded each other.

`release.yml` triggered on any `v*` tag and uploaded whatever `build.sh`
produced. `--check` (AC2) only required that a `version` field *exist*. Tagging
`v0.2.0` while the fourteen `SKILL.md` files still declared `0.1.0` would have
published a "v0.2.0" release whose every package identified as `0.1.0`, with
release notes taken from a `CHANGELOG.md` whose top heading also still read
`v0.1.0`. Nothing failed.

The version lived in sixteen places — fourteen `SKILL.md` frontmatter fields
plus two prose lines in `README.md` — every one maintained by hand, in lockstep,
by memory.

And nothing had actually been released. The repo had zero tags and zero GitHub
releases, yet `README.md` and both install guides linked `releases/latest`.
Every download link in the published install guide was a 404.

A hand-rolled consistency gate closes the first defect and leaves the other two.

## Decision

release-please owns the version. `release-please-config.json` runs in manifest
mode with `release-type: simple`, maintaining `version.txt` as the version of
record and rewriting fifteen `extra-files` — the fourteen `SKILL.md` files and
`README.md` — through its generic updater.

**The version is annotated in place, not injected at build time.** Each
`SKILL.md` keeps a real version in its own frontmatter:

```yaml
version: 0.2.0 # x-release-please-version
```

The rejected alternative was a single `version.txt` as the only version in git,
stamped into each staged `SKILL.md` while packaging. It is strictly less
drift-prone, and it was rejected anyway: this repo's architecture holds that
`skills/<canonical-fr-name>/<locale>/` is *a complete, uploadable skill on its
own*, and a skill with no version in its frontmatter is not that.

`stage_skill` (and `New-SkillStage`) strip the annotation while packaging, so
the `SKILL.md` inside every ZIP is pristine. This costs a few lines in each
build script and buys independence from however the skill loader parses
frontmatter — a naive regex would otherwise read the version as
`0.2.0 # x-release-please-version`.

**There are two changelogs.** release-please owns and rewrites its changelog,
generating English commit-derived entries. `CHANGELOG.md` was hand-written
bilingual prose aimed at non-technical executives, and both install guides sent
them to it by name. Those are two jobs one file cannot hold. So `CHANGELOG.md`
becomes the generated, English, repo-facing file, and a new hand-written
`docs/WHATS-NEW.md` keeps the bilingual executive voice. Each file has one
audience and one author.

**The coherence check survives, and moves to every PR.** release-please makes
the original drift structurally impossible, but opens a new door: a fifteenth
skill whose version line lacks the annotation, or which is never added to
`extra-files`, is silently skipped and ships a stale version forever. So
`--check` gains `check_version_coherence`, which requires the annotation on
every `SKILL.md` version line, an `extra-files` entry of `type: generic` for
each one, all declared versions equal to `version.txt`, and a
`## v<version>` heading in `docs/WHATS-NEW.md` whose section carries bilingual
prose. That last one is a deliberate forcing function: on a release PR
`version.txt` has moved and `WHATS-NEW.md` has not, so CI lands red until a
human writes the entry.

**release-please authenticates as a GitHub App, not with a PAT.** Anything an
action does under `GITHUB_TOKEN` produces events that start no new workflow run.
That rule suppresses the release PR's `pull_request` event, so under
`GITHUB_TOKEN` the release PR receives no completed checks and the forcing
function above can never fire. A PAT lifts the suppression, and is what
release-please's own docs recommend — at the cost of an expiry that is
indistinguishable from "nothing releasable" until someone reads a workflow log,
and of being a person's credential that dies with their account. The
`atelier-release-please` App has neither property:
`actions/create-github-app-token@v2` mints a token per run that expires in an
hour and is scoped to one repository. The remaining cost is a private key to
store and eventually rotate — a smaller and better-signposted liability than a
silently expiring PAT.

**The publish job lives in the same workflow.** A tag pushed by an action under
`GITHUB_TOKEN` triggers no other workflow, so a tag-triggered `release.yml`
would silently never fire again. The App token would in principle reopen that
door; the publish job stays put anyway. Jobs gated on `needs` and
`release_created` avoid the cross-workflow hop entirely, keep the release and
its assets in one run, and surface a failed upload next to the release that
needs it.

**Uploaded ZIP filenames stay unversioned** (`atelier-en.zip`, never
`atelier-en-0.2.0.zip`). That is what keeps
`releases/latest/download/atelier-en.zip` — already published in both install
guides — resolving across releases. `docs/WHATS-NEW.md` is attached alongside
the fourteen ZIPs, in the slot `CHANGELOG.md` used to occupy.

**Conventional Commits become load-bearing**, driving both the bump and every
changelog entry. Scopes are the canonical French short names already used by
`skills/names.tsv` — `atelier`, `mentor`, `boussole`, `forge`, `marketing`,
`ventes`, `reunions` — plus `build`, `ci`, `docs`, `install`, `shared`. The
convention is documented in `CLAUDE.md`, not enforced; enforcement is deferred
to issue #12.

The `target-branch: main` pin, and why the release branch exists at all, are
recorded in [ADR-0010](0010-dev-default-main-release-branch.md).

## Consequences

- The version becomes a computed value. Bumping it by hand in a `SKILL.md` is
  now a CI failure, not a chore.
- A new skill costs two mechanical steps that CI names for you: annotate its
  version line, and add it to `extra-files`. Forgetting either is red at PR
  time rather than a stale package six months later.
- A release cannot ship without a hand-written bilingual entry. That is the
  point, and it is also the most likely source of a surprising red CI run on a
  release PR — the fix is to commit the entry to the
  `release-please--branches--main` branch.
- That branch is force-pushed on every run, so a release-please run landing
  between the entry's commit and the merge would clobber it. Under this branch
  model the window never opens on its own: `release-please.yml` fires only on
  `push` to `main`, and pushes to `main` are deliberate promotions.
- Commit messages now have a machine-readable audience. A commit written in the
  repo's old prose style contributes nothing to the release calculation and
  appears in no changelog, and nothing catches it (#12).
- The GitHub App's private key is a new secret to hold and eventually rotate.
  If the App is uninstalled or the key rotated, the run fails loudly at its
  first step. If its permissions are narrowed instead, the token still mints and
  the run fails later, at the first API call needing the missing scope —
  visible, but further from the cause.

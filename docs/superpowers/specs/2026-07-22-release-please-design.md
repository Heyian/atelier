# Release automation with release-please

**Date:** 2026-07-22
**Status:** Approved, not yet implemented
**Amended:** 2026-07-22 — `dev` becomes the default branch and `main` becomes
the release branch. See *Branch model* below; AC49, AC54, AC55, AC58, AC60,
AC62 and AC63 were rewritten, AC63a, AC63b, AC68, AC69, AC69a and AC70 added,
and #13 filed.

**Amended:** 2026-07-22 — release-please authenticates as a GitHub App rather
than with a PAT, folding in what was #14 (now closed). Requiring signed commits
is dropped as a consequence; see *Why the branches do not require signed
commits*. AC49, AC68, AC69 and AC69a rewritten; AC69b and AC71 added.
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

### Branch model

`dev` is the default branch: every feature branch cuts from it and every PR
lands on it. `main` holds releases only. Work reaches `main` through a
**promotion PR** — a deliberate "cut a release" act, distinct from merging a
feature.

That promotion PR **must be merged as a merge commit, never squashed.**
release-please reads `main`'s history to compute the bump and every changelog
entry, so the individual Conventional Commits have to survive the promotion.
A squash collapses them into one non-conventional message
(`Merge pull request #N from Heyian/dev`); release-please then finds nothing
releasable and silently opens no release PR. The failure announces itself only
as an absence. Mechanical enforcement is deferred to #13.

This mirrors `traction-app`, which runs the same model.

### Flow

```
feature branch → PR → ci.yml: tests + build.sh --check
                              └─ version coherence
merge to dev                                    ← default branch
   ⋮
promotion PR  dev → main   MERGE COMMIT, never squash
   └─ merge to main                             ← releases only
      └─ release-please.yml (push: main)
         job 1: mint App token · release-please · manifest mode
                · target-branch main
                maintains a release PR against main that bumps
                version.txt · manifest · 14 SKILL.md · README ×2
                and regenerates CHANGELOG.md
                └─ ci.yml RUNS on that PR (App token) and is RED until a
                   human commits the bilingual ## vX.Y.Z entry to
                   docs/WHATS-NEW.md on the release-please branch
                └─ required status checks on main BLOCK the merge
         merge the release PR
                └─ tag vX.Y.Z + GitHub release (generated notes)
         job 2: needs job 1, if release_created == 'true'
                build.sh --lang all → upload 14 ZIPs + WHATS-NEW.md
         job 3: needs job 1, if release_created == 'true'
                open the back-merge PR  main → dev
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

### Why release-please authenticates as a GitHub App

Anything an action does while authenticating as `GITHUB_TOKEN` produces events
that do not start new workflow runs — a platform rule that exists to stop
workflows from recursively triggering themselves. release-please's own
documentation states it plainly:

> When you use the repository's `GITHUB_TOKEN` to perform tasks, events
> triggered by the `GITHUB_TOKEN` will not create a new workflow run.

release-please uses that token for two things. It pushes the tag, addressed
below. It also **opens and force-pushes the release PR**, and the identical
rule suppresses that PR's `pull_request` event. Under `GITHUB_TOKEN` the
release PR receives no completed checks, so AC53's forcing function — CI red
until a human writes the bilingual `docs/WHATS-NEW.md` entry — never fires. The
same-workflow `needs:` trick cannot help: the thing that must run is scoped to
a PR living between two separate workflow runs.

Any credential that is not `GITHUB_TOKEN` lifts the suppression. Two qualify.

A **PAT** is what release-please's docs recommend and what `traction-app` uses
(`MY_RELEASE_PLEASE_TOKEN`). It works, and it carries two costs: a fine-grained
PAT expires, and its expiry is indistinguishable from "nothing releasable"
until someone reads the workflow log; and it is a person's credential, carrying
that person's access and dying with their account.

A **GitHub App installation token** has neither property. `atelier-release-please`
is an App owned by the `Heyian` account and installed on `Heyian/atelier` alone,
granted `contents: write` and `pull-requests: write`.
`actions/create-github-app-token@v2` mints a token per run from the App's id and
private key; the token expires in an hour and is scoped to one repository, so a
leaked key reaches exactly one repo. The App was scoped to this repository
rather than made account-wide deliberately: the narrower blast radius is worth
registering a second App if `traction-app` is ever migrated.

The one-hour lifetime constrains nothing here. Only jobs 1 and 3 hold an App
token, and both are short — open or update a PR. Job 2, the only long one,
builds fourteen ZIPs under `GITHUB_TOKEN` and never touches the App.

The remaining cost is the private key, which must be stored and eventually
rotated. That is a smaller and better-signposted liability than a silently
expiring PAT.

The publish job (job 2) keeps `GITHUB_TOKEN`. It only uploads assets to an
existing release and needs to trigger nothing, so it has no reason to hold the
stronger credential.

### Why the branches do not require signed commits

The ruleset covering `main` today carries `required_signatures`, alongside
`deletion` and `non_fast_forward`. It arrived with GitHub's suggested default
ruleset on 2026-07-21 rather than from a decision about this repo. It is
dropped, and here is why it has to be.

release-please's commits are **unsigned**. This is observable in `traction-app`,
where the release PR was once merged rather than squashed, leaving the
machine-authored commit in the history:

```
4dab3af2 [N] chore(main): release 3.2.1
```

`[N]` is git's code for *no signature*. GitHub's own merge and squash commits
are signed; release-please's are not, and its documentation says nothing about
signing.

This is a claim about a **version**, not a law of nature — which is why AC49
pins `googleapis/release-please-action` to a major version. Should a later
release-please gain commit signing, the argument below stops applying and the
decision is worth reopening. Until then it holds for the version we pin.

GitHub's rule for a branch requiring signatures is:

> you cannot squash and merge a pull request into the branch on GitHub unless
> you are the author of the pull request.

Under a PAT the release PR's author is the token's owner — a human — so
squash-merging it into `main` stays legal. That is the only reason
`traction-app` would get away with this, and `traction-app` has no branch
protection at all, so it has never been tested. Under the App the author is
`atelier-release-please[bot]`: the human merging is no longer the author, so
squash is refused, and a merge commit is refused too because it would introduce
unsigned commits.

The back-merge PR fails the same way regardless of credential, since it carries
those unsigned commits from `main` into `dev`.

So the rule and the automation cannot both stand. Keeping the rule would mean
granting the App a bypass — and because ruleset bypass is per-*ruleset* rather
than per-rule, that means splitting each branch's rules across two rulesets so
the App does not also bypass deletion, non-fast-forward and the required status
checks. Four rulesets to buy "every commit is signed, unless the release bot
wrote it".

The rule is dropped instead. A bypassed rule is worse than an absent one: it
still reads as a guarantee.

Be precise about what this costs. The guarantee that *every* commit on these
branches is signed is genuinely gone — not only for release-please, but for
anyone who can push. In this repo that set is one person and one App. No other
protection is touched: `deletion`, `non_fast_forward` and the new
`required_status_checks` are all indifferent to who authored a commit, and
commits written by hand stay signed by local git config either way. What goes
is the enforcement, on the one rule this repo's own automation cannot satisfy.

### Why the publish job lives in the same workflow

A tag pushed by an action authenticating with `GITHUB_TOKEN` does not trigger
other workflows. Keeping `release.yml` on its `v*` trigger would mean it
silently never fires again.

The App token would in principle reopen that door. The publish job stays in
the same workflow anyway: jobs 2 and 3, each with `needs:` and
`if: release_created == 'true'`, avoid the cross-workflow hop entirely, keep
the release and its assets in one run, and surface a failed upload next to the
release that needs it. One workflow is simply easier to reason about than two
coupled through a tag.

### Why main flows back into dev

Merging the release PR rewrites eighteen files on `main` — `version.txt`, the
manifest, the fourteen `SKILL.md`, `README.md` and a regenerated
`CHANGELOG.md` — while `dev` still declares the old version in every one of
them. `--check` stays green on `dev`: the tree is internally coherent, just
stale. But the next promotion PR then conflicts on all eighteen, and does so at
every release, forever.

So job 3 opens a back-merge PR (`base: dev`, `head: main`) whenever a release
was created. Merging it carries the bumps and the generated changelog back, and
promotion PRs stay conflict-free.

It is a PR rather than a direct push so that the merge is visible, runs `ci.yml`
against `dev`'s would-be state before landing, and is trivially idempotent —
"is a `main` → `dev` PR already open?" is one query, where "has this merge
already been pushed?" is not.

`traction-app` does not do this — 33 commits sit on its `main` and not on its
`dev`. There the drift is a cosmetic `package.json` version. Here it is
eighteen files, most of which the coherence check reads.

### A caveat on writing WHATS-NEW

The bilingual entry is committed by a human onto the
`release-please--branches--main` branch, which release-please **force-pushes**
on every run. A run landing between that commit and the merge would clobber it.

Under this branch model that cannot happen incidentally: `release-please.yml`
fires only on `push` to `main`, and pushes to `main` are deliberate promotions.
The window is real but never opens on its own.

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
`traction-app`'s workflow carries this comment from experience.

`target-branch: main` is pinned because the action otherwise defaults to the
repository's default branch — which, under this branch model, is `dev`.
Unpinned, release-please would compute releases from `dev` and tag there,
putting tags on the branch that is explicitly not the release branch. The pin
is load-bearing, not defensive.

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

The branch flip comes first, so that this spec is itself implemented through
the workflow it describes.

1. Push `atelier-v1` to `origin` as `dev`; set `dev` as the repository's
   default branch; retarget the ruleset per AC69. `main` stays where it is,
   thirty-seven commits behind, until the first promotion.
2. Register the `atelier-release-please` GitHub App under the `Heyian`
   account with `contents: write` and `pull-requests: write`; install it on
   `Heyian/atelier` only; store its id and private key as the
   `RELEASE_PLEASE_APP_ID` and `RELEASE_PLEASE_APP_PRIVATE_KEY` secrets.
3. Implement this spec on a branch cut from `dev`, and land it by PR into
   `dev` — the first real use of the new workflow.
4. When v1 is ready, on `dev`'s tip: run `bash scripts/build.sh --lang all`,
   tag `v0.1.0`, and publish the GitHub release with the fourteen ZIPs and
   `docs/WHATS-NEW.md` attached. `version.txt` and
   `.release-please-manifest.json` already read `0.1.0` — step 3 creates them —
   so this step only tags and publishes.
5. Open the promotion PR `dev` → `main` and merge it as a merge commit.

**The tag must precede the first promotion.** release-please computes from the
last release tag. With no tag anywhere, the moment `release-please.yml` first
lands on `main` it would read the thirty-seven v1 commits as unreleased and
open a premature `v0.2.0` release PR. Tagging `v0.1.0` on `dev`'s tip first
makes that commit an ancestor of `main` once the promotion merges, so
release-please sees `v0.1.0` reachable, the manifest at `0.1.0`, and nothing
releasable since — and correctly opens nothing. The next feature merged into
`dev` and promoted produces `v0.2.0` through the normal flow.

The tag also fixes every 404 in the install guides today rather than at the
next release. The thirty-seven commits predating it are pre-history: they
generate no changelog entries, which is correct, because the v0.1.0 entry is
hand-written.

### Failure modes

| Failure | Detection |
|---|---|
| New skill missing its annotation | `--check` red at PR time |
| New skill missing from `extra-files` | `--check` red at PR time |
| Skill versions drift apart | `--check` red at PR time |
| Bilingual entry forgotten | `--check` red on the release PR; required checks on `main` block the merge |
| Upload job fails | Visible in the same run; re-runnable, `gh release upload --clobber` |
| Back-merge PR left unmerged | Next promotion PR conflicts on the eighteen version-bearing files |
| App uninstalled or private key rotated | The token-minting step fails, so the run fails loudly at its first step — unlike an expired PAT, which fails as an absence |
| App permissions narrowed | The token mints successfully and the run fails later, at the first API call needing the missing scope. Visible, but further from the cause |
| Promotion PR squash-merged | Release PR never appears. Caught for the first promotion by AC63a; **undetected** thereafter — deferred to #13 |
| Non-conventional commit | **Undetected** — deferred to #12 |

### Testing

`scripts/tests/build_test.sh` drops the four `--release-version` cases and
gains one case per negative criterion, each mutating a fixture that otherwise
satisfies AC55: no annotation, two `version:` lines, a version line without the
annotation, mismatched versions between two skills, `version.txt` disagreement,
a `SKILL.md` absent from `extra-files`, an `extra-files` entry lacking
`type: generic`, a `WHATS-NEW.md` heading with an empty section, and each
required file missing or empty — plus a malformed `version.txt` and an
unparseable entry in each JSON file. Positive cases: a clean fixture
passes with the exact PASS line, `--check` passes with `jq` off `PATH`, and a
packaged archive carries no `x-release-please-version` anywhere. The fixture
gains `version.txt`, `release-please-config.json`,
`.release-please-manifest.json`, and `docs/WHATS-NEW.md`.

The Windows job (AC58) runs the same mutation matrix through `build.ps1`
rather than only checking the coherent real repository, which is all it asserts
today.

## Acceptance Criteria

Numbering continues from the existing spec (AC1–AC48) so that `AC<n>` in a code
comment stays unambiguous. Criteria added after the cross-model critique carry
a letter suffix (`AC63a`, `AC63b`, `AC69a`, `AC69b`) rather than a new
number, so they
stay adjacent to the criterion they sharpen; they are ordinary criteria in
every other respect.

**Evaluation conventions.** Every negative criterion below is evaluated against
a synthetic fixture repo that satisfies AC55 *except* for the single mutation
under test — so a non-zero exit proves the mutation, not unrelated breakage.
"Names the path" means the repo-relative POSIX path appears in the command's
combined output. "The 14 localized names" means the fr and en columns of
`skills/names.tsv` joined with their locale.

**AC49** — `.github/workflows/release-please.yml` triggers on `push` to `main`
and invokes `googleapis/release-please-action` pinned to an explicit major
version (`@v4` or later — never `@main` or an unpinned reference, since the
unsigned-commit premise of AC69 is version-dependent), with **no**
`release-type` input, with `target-branch: main`, and with `token` set to the
App token minted per AC71 rather than to `GITHUB_TOKEN` or to any other secret.
`contents: write` and `pull-requests: write` are in effect **for the
release-please job** — declared either at workflow level or on that job, not
only on some other job.
`.github/workflows/ci.yml` triggers on `pull_request` with no `branches`
filter — so it runs on PRs targeting `dev` and `main` alike, including the
release PR — and on `push` to `dev` and `main` only; it declares a
`concurrency` group keyed on the ref with `cancel-in-progress: true`; and it
still runs `bash scripts/build.sh --check`.

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

**AC54** — Given `version.txt`, `release-please-config.json` or
`.release-please-manifest.json` is missing, empty, or malformed —
`version.txt` holding anything other than exactly one SemVer line, either JSON
file failing to parse — or given `docs/WHATS-NEW.md` is missing or empty, When
`--check` runs, Then it exits non-zero and names that path. `WHATS-NEW.md` has
no malformed case here; its structure is AC53's subject.

**AC55** — Given every AC50–AC54 and AC59 invariant holds, When
`bash scripts/build.sh --check` runs, Then it exits zero and its output
contains the line `STATUS: PASS (mechanical checks)`. AC49, AC61, AC62, AC63,
AC63a, AC63b and AC68–AC71 (AC69b included) are workflow and repository
criteria, not fixture invariants, and are outside AC55's precondition.

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
AC50–AC54 and AC59, and exits zero with the same PASS line on the unmutated
fixture of AC55; `-Lang all` satisfies AC57. (AC56 is bash-specific; PowerShell
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
`grep -c -- --release-version scripts/tests/build_test.sh` reports `0`.

**AC61** — In `.github/workflows/release-please.yml`, the release-please job
exposes `release_created` and `tag_name` as **job outputs**; a publish job
declares `needs` on it, is gated on
`needs.<release-job>.outputs.release_created == 'true'`, checks out the repo,
builds via `bash scripts/build.sh --lang all`, and uploads to the release named
by `needs.<release-job>.outputs.tag_name`.

**AC62** — The set of ZIP assets the publish job uploads equals exactly the 14
localized names, each named `<localized-name>-<locale>.zip` and carrying no
version segment — no fewer, no others; the only non-ZIP asset uploaded is
`WHATS-NEW.md`.

**AC63** — After bootstrap, against `Heyian/atelier` with an authenticated
`gh`: `refs/tags/v0.1.0` exists on `origin`; release `v0.1.0` is published —
neither draft nor prerelease; its asset set equals exactly the 14 localized ZIP
names plus `WHATS-NEW.md`; `version.txt` on `main` reads `0.1.0`;
`.release-please-manifest.json` on `main` parses to `{".": "0.1.0"}` compared
as JSON, not as text; and
`https://github.com/Heyian/atelier/releases/latest/download/atelier-en.zip`
resolves with HTTP 200.

**AC63a** — The promotion commit — `main`'s tip immediately after the first
promotion merge — has exactly two parents, and its **second** parent is the
commit `refs/tags/v0.1.0` points at. Reachability alone is not sufficient: any
later tag is reachable from `main`, whereas the second parent is by
construction `dev`'s tip at merge time. This one criterion establishes both
that the promotion was merged as a merge commit rather than squashed, and that
`v0.1.0` was tagged before the promotion rather than after.

**AC63b** — The `release-please.yml` workflow run triggered by the first
promotion merge concluded `success`, and its release-please job reported
`prs_created` empty and `release_created` false. A run that failed, was
cancelled, or never started does not satisfy this criterion — absence of a
release PR must be the outcome of a healthy run, not of a broken one.

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

**AC68** — In `.github/workflows/release-please.yml`, a back-merge job declares
`needs` on the release-please job, is gated on
`needs.<release-job>.outputs.release_created == 'true'`, and opens a pull
request with base `dev` and head `main` authenticating with an App token minted
per AC71. Given a `main` → `dev` pull request is already open, When the
back-merge job of the workflow run that opened it is re-run on its own — via
`gh run rerun <run-id> --job <job-id>`, so that it executes rather than being
skipped by its own gate — Then it exits zero and the count of open `main` →
`dev` pull requests is still one. A whole-workflow re-run, or any run in which
the job is skipped, does not satisfy this criterion.

**AC69** — Against `Heyian/atelier` with an authenticated `gh`: the
repository's default branch is `dev`; no active ruleset targets
`~DEFAULT_BRANCH`; the branches `refs/heads/dev` and `refs/heads/main` are each
covered by an active ruleset carrying the `deletion` and `non_fast_forward`
rules, whose `bypass_actors` is empty; **no** active ruleset carries a
`required_signatures` rule against either branch **and neither branch carries
classic branch protection with `required_signatures` enabled** — classic
protection layers independently of rulesets, so
`gh api repos/Heyian/atelier/branches/{dev,main}/protection` must either 404 or
report `required_signatures.enabled` false; and `refs/heads/main` is
additionally covered by a `required_status_checks` rule naming both
`checks-linux` and `checks-windows`, with
`strict_required_status_checks_policy` **false** — strict mode would demand the
release PR be rebased onto `main` after every intervening merge, for no gain on
a branch whose only inbound PRs are promotions and releases.

**AC69a** — Given the first release PR release-please opens after bootstrap,
When it is inspected with `gh pr checks`, Then both `checks-linux` and
`checks-windows` report a conclusion of `success` or `failure` — `skipped`,
`cancelled`, `neutral` and a still-pending check each fail this criterion,
since only a check that reached a verdict proves it ran — and the pull
request's author is the `atelier-release-please` App's bot account rather than
a human. Together with AC69b this is what proves AC53's forcing function can
fire at all; no inspection of the workflow file can establish it.

**AC69b** — `gh api /repos/Heyian/atelier/installation` resolves to an
installation of the `atelier-release-please` App whose `repository_selection`
is `selected`, and whose permissions are exactly `contents: write` and
`pull_requests: write` plus the `metadata: read` GitHub grants implicitly. An
App installed on all of the account's repositories, or holding permissions
beyond these, fails.

**AC70** — `docs/adr/0010-dev-default-main-release-branch.md` exists and
carries Context, Decision, and Consequences sections, and
`docs/adr/0009-release-automation-and-changelog-split.md`
cross-references it for the `target-branch` pin. ADR-0010 records why
`required_signatures` was dropped. `CLAUDE.md` states that `dev` is the default
branch, that `main` carries releases only, that the promotion PR `dev` → `main`
is merged as a merge commit and never squashed, and that the back-merge PR
`main` → `dev` is merged after each release.

**AC71** — In `.github/workflows/release-please.yml`, both the release-please
job and the back-merge job mint a token with
`actions/create-github-app-token@v2`, passing `app-id` from the
`RELEASE_PLEASE_APP_ID` secret and `private-key` from the
`RELEASE_PLEASE_APP_PRIVATE_KEY` secret, passing **neither** an `owner` nor a
`repositories` input — so the token stays scoped to this repository alone — and
consuming that step's `token` output. The publish job of AC61 mints no token,
authenticates with `GITHUB_TOKEN`, and has `contents: write` in effect, without
which its asset uploads cannot succeed. Across all of `.github/`, the only
secrets referenced are `RELEASE_PLEASE_APP_ID`, `RELEASE_PLEASE_APP_PRIVATE_KEY`
and `GITHUB_TOKEN` — enumerated by matching `secrets\.[A-Z_]+`, so that a PAT
reintroduced under any name fails this criterion rather than only one spelled
`RELEASE_PLEASE_TOKEN`.

## Deferred Items

- #12 — Enforce conventional commit messages in CI
- #13 — Guard against squash-merging the dev → main promotion PR

Closed by this spec rather than deferred:

- #14 — Replace the release-please PAT with a GitHub App token

## Glossary Updates & ADRs

**Glossary** — none. This repo has no `CONTEXT.md`; `skills/shared/<locale>/glossary.md`
is the product's executive-facing glossary, not a developer domain glossary,
and nothing in this design changes an executive-facing term.

**ADR** — two, each passing all three gate criteria:

`docs/adr/0009-release-automation-and-changelog-split.md`

- *Hard to reverse* — annotations in 16 files, the manifest as version of
  record, accreted tags and releases, and a commit convention that becomes
  load-bearing for the changelog.
- *Surprising without context* — two changelog files with different audiences
  and different authors; an `x-release-please-version` comment inside skill
  frontmatter that is then stripped at packaging.
- *Real trade-off* — annotate-and-strip versus single-source injection;
  split changelog versus one hand-edited file; same-workflow publish job
  versus a tag-triggered second workflow; a GitHub App versus the PAT that
  release-please's own docs recommend.

`docs/adr/0010-dev-default-main-release-branch.md`

- *Hard to reverse* — the default branch is the base of every clone's HEAD,
  every PR's default base, the ruleset's `~DEFAULT_BRANCH` target and
  release-please's unpinned `target-branch`.
- *Surprising without context* — `main` sits permanently behind `dev`, which
  reads as neglect rather than as design; the promotion PR's merge method is
  load-bearing for reasons nothing in the diff explains; and a repo whose every
  hand-written commit is signed does not require signatures, which reads as an
  oversight rather than as a decision.
- *Real trade-off* — a release branch versus trunk-based releases straight off
  the default branch; given the release branch, an automated back-merge versus
  resolving eighteen conflicts at each promotion; and dropping
  `required_signatures` versus splitting four rulesets to grant the release App
  a bypass.

The branch model gets its own ADR rather than a section inside ADR-0009: it
outlives release-please, and a reader asking why `main` is behind `dev` should
not have to read a changelog-split ADR to find the answer.

**Conflicts with existing ADRs** — none. ADR-0001–0008 cover skill taxonomy,
memory regimes, and document paths; none touches releases, versioning, or
branches.

## Config & Infrastructure Impact

| File | Change |
|---|---|
| `release-please-config.json` | **Create.** Per the Configuration table above |
| `.release-please-manifest.json` | **Create.** `{".": "0.1.0"}` |
| `version.txt` | **Create.** `0.1.0` |
| `.github/workflows/release-please.yml` | **Create.** Three jobs per AC49, AC61, AC68 |
| `.github/workflows/release.yml` | **Delete.** Replaced |
| `.github/workflows/ci.yml` | Retrigger per AC49: `pull_request` unfiltered, `push` narrowed to `dev` and `main`, plus a `concurrency` group. Coherence itself rides inside the existing `build.sh --check` step |
| `scripts/build.sh` | Remove `--release-version` and `run_release_version_check`; add annotation-strip to `stage_skill`; add `check_version_coherence` to `run_checks` |
| `scripts/build.ps1` | Windows parity for both changes |
| `scripts/tests/build_test.sh` | Replace 4 gate cases with the coherence mutation matrix; fixture gains `version.txt`, `release-please-config.json`, `.release-please-manifest.json`, `docs/WHATS-NEW.md` |
| `skills/*/*/SKILL.md` (14) | Annotate the version line |
| `README.md` | Annotate both version lines (35, 88) |
| `.gitignore` | No change — already contains `dist/`, which the publish job builds into |
| GitHub repository settings | **Change.** Default branch `main` → `dev` (AC69) |
| GitHub ruleset `main` (id 19417109) | **Change.** Its condition is `~DEFAULT_BRANCH` today, so the flip would carry its rules onto `dev` and leave `main` bare. Retarget to name `refs/heads/main` and `refs/heads/dev` explicitly, **drop `required_signatures`**, and add `required_status_checks` (`checks-linux`, `checks-windows`) on `main` (AC69) |
| GitHub App `atelier-release-please` | **Create.** Owned by `Heyian`, installed on `Heyian/atelier` only, `contents: write` + `pull-requests: write`. Without it the release PR receives no CI and AC53 cannot fire |
| Repository secrets `RELEASE_PLEASE_APP_ID`, `RELEASE_PLEASE_APP_PRIVATE_KEY` | **Create.** The App's id and private key, consumed by `actions/create-github-app-token` (AC71) |

No new environment variables, containers, IaC, schemas, or API collections.

## Documentation Updates

| Doc | Change |
|---|---|
| `docs/WHATS-NEW.md` | **Create.** Move the bilingual v0.1.0 prose out of `CHANGELOG.md` |
| `CHANGELOG.md` | Hand-written bilingual content moves out; becomes release-please-generated |
| `docs/INSTALL.en.md` | Line ~100: point to `docs/WHATS-NEW.md` (AC65) |
| `docs/INSTALL.fr.md` | Line ~107: point to `docs/WHATS-NEW.md` (AC65) |
| `CLAUDE.md` | Add the Conventional Commits convention with its scope vocabulary, the branch model per AC70, and a one-line pointer to this spec. Index-sized entries only |
| `docs/adr/0009-…` | **Create.** Per the ADR section; cross-reference ADR-0010 for the `target-branch` pin |
| `docs/adr/0010-dev-default-main-release-branch.md` | **Create.** Per the ADR section |
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
> After the final build passes — and before wrapping up via `superpowers:finishing-a-development-branch` — if a cross-model review helper is available (e.g. the Codex plugin's adversarial review), run it with focus: *"Judge correctness against the spec's acceptance criteria (AC49–AC71, including AC63a, AC63b, AC69a and AC69b) only. Do not flag anything outside the stated criteria — no design alternatives, hardening, or scope the spec did not claim."*
>
> This **never gates a merge** — the gate stays `bash scripts/build.sh --check` plus the three test suites, and `bash scripts/build.sh --lang all`; the review only flags what deserves a second look. If no helper is available, finish the branch without it.

**Implementation ordering note.** Bootstrap steps 1 and 2 — pushing `dev`,
flipping the default branch, retargeting the ruleset, registering the App and
storing its two secrets — come *before* the implementation branch is cut, so
that this spec lands through the workflow it defines. They are repository
configuration, not code, and produce no commit; verify them against AC69 rather
than against a diff.

Within the implementation branch, the commit that introduces
`check_version_coherence` must land together with `version.txt`,
`docs/WHATS-NEW.md`, `release-please-config.json`, and the sixteen annotations
— the check fails against a tree missing any of them.

Bootstrap steps 4 and 5 — the promotion PR, the tag, and the release — happen
after the implementation branch merges into `dev` and v1 is ready, not during
implementation.

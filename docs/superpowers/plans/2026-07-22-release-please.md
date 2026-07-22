# Release automation with release-please — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace hand-maintained versions and the tag-triggered release workflow with release-please, so the version is computed in one place, the release PR is CI-gated on a hand-written bilingual changelog entry, and every download link in the install guides resolves.

**Architecture:** `release-please-config.json` (manifest mode, `release-type: simple`) owns `version.txt`, the fourteen `SKILL.md` frontmatter versions and two `README.md` lines, each carried by an `x-release-please-version` annotation that `stage_skill` strips at packaging time. A new `check_version_coherence` in both build scripts runs on every PR and fails when any annotation, `extra-files` entry, version or `docs/WHATS-NEW.md` heading drifts. `.github/workflows/release-please.yml` runs on `push` to `main` with three jobs: release-please under a minted GitHub App token, an asset-publishing job under `GITHUB_TOKEN`, and a back-merge job that opens `main` → `dev`.

**Tech Stack:** bash + awk/grep (no `jq` dependency), PowerShell 7, GitHub Actions (`googleapis/release-please-action@v4`, `actions/create-github-app-token@v2`), `gh` CLI.

**Spec:** `docs/superpowers/specs/2026-07-22-release-please-design.md` (AC49–AC71).

## Global Constraints

- Every version-bearing line carries the annotation exactly: `version: <semver> # x-release-please-version` in `SKILL.md` frontmatter; `<!-- x-release-please-version -->` on the two `README.md` lines.
- `--check` must pass with `jq` **off** `PATH` (AC56). No JSON tooling beyond `bash`, `awk`, `grep`, `find`, `zip`, `unzip` in `build.sh`. `build.ps1` may use `ConvertFrom-Json`.
- `bash scripts/build.sh --check` prints exactly the line `STATUS: PASS (mechanical checks)` on success (AC55).
- Uploaded ZIP names carry **no** version segment: `<localized-name>-<locale>.zip` (AC62).
- `.github/workflows/release-please.yml` must **not** pass `release-type` to the action — that forces non-manifest mode and can reset the version to `1.0.0`.
- `target-branch: main` is mandatory; the repository default branch is `dev`.
- The only secrets referenced anywhere under `.github/` are `RELEASE_PLEASE_APP_ID`, `RELEASE_PLEASE_APP_PRIVATE_KEY` and `GITHUB_TOKEN`, matched as `secrets\.[A-Z_]+` (AC71).
- `googleapis/release-please-action` is pinned to `@v4` — never `@main`, never unpinned (AC49).
- Conventional Commits, scopes: `atelier`, `mentor`, `boussole`, `forge`, `marketing`, `ventes`, `reunions`, `build`, `ci`, `docs`, `install`, `shared`.
- **Pre-commit gate (mandatory, every task):** before every `git commit`, run from the repo root:
  `bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh`
  All four must pass. Never `git commit --no-verify`.
- One focused commit per task, Conventional Commits, no AI-attribution trailers.

---

### Task 1: Cut the implementation branch and verify the bootstrap

Bootstrap steps 1 and 2 (branch flip, ruleset retarget, GitHub App + secrets) were completed before this plan. This task **verifies** them and creates the working branch. It produces no commit.

**Files:** none.

**Interfaces:**
- Produces: the branch `feat/release-please`, cut from `dev`, on which every later task commits.

- [ ] **Step 1: Confirm the working tree is clean and on `dev`**

```bash
cd /home/mafavreau/DEV/atelier
git status --porcelain && git rev-parse --abbrev-ref HEAD
```

Expected: no output from `--porcelain`; `dev` from `rev-parse`. If dirty, stop and ask.

- [ ] **Step 2: Cut the implementation branch**

```bash
git fetch origin && git checkout -b feat/release-please origin/dev
```

Expected: `Switched to a new branch 'feat/release-please'`.

- [ ] **Step 3: Verify AC69 — default branch, rulesets, no signature rule, no classic protection**

```bash
gh repo view Heyian/atelier --json defaultBranchRef -q .defaultBranchRef.name
gh api repos/Heyian/atelier/rulesets \
  --jq '.[] | {id, name, enforcement}'
gh api repos/Heyian/atelier/rulesets/19417109 \
  --jq '{conditions: .conditions.ref_name.include, rules: [.rules[].type], bypass: (.bypass_actors | length)}'
gh api repos/Heyian/atelier/rulesets/19575430 \
  --jq '{conditions: .conditions.ref_name.include, rules: .rules, bypass: (.bypass_actors | length)}'
gh api repos/Heyian/atelier/branches/dev/protection 2>&1 | head -2
gh api repos/Heyian/atelier/branches/main/protection 2>&1 | head -2
```

Expected:
- default branch `dev`;
- both rulesets `active`;
- ruleset `19417109` (“branch guards”) includes `refs/heads/main` and `refs/heads/dev`, rules `["deletion","non_fast_forward"]`, `bypass` `0`;
- ruleset `19575430` (“main required checks”) includes `refs/heads/main` only, one `required_status_checks` rule naming `checks-linux` and `checks-windows` with `strict_required_status_checks_policy: false`, `bypass` `0`;
- **no** `required_signatures` in either rules list;
- both `branches/*/protection` calls return `Branch not protected` (HTTP 404).

If any of these differs, fix the repository setting before continuing — the rest of the plan assumes AC69 holds.

- [ ] **Step 4: Verify the App secrets exist (AC71's storage half)**

```bash
gh secret list -R Heyian/atelier
```

Expected: rows for `RELEASE_PLEASE_APP_ID` and `RELEASE_PLEASE_APP_PRIVATE_KEY`.

- [ ] **Step 5: Note how AC69b will be verified**

`gh api /repos/Heyian/atelier/installation` requires a **GitHub App JWT**, not a user token — under `gh`'s normal auth it returns HTTP 401 `A JSON web token could not be decoded`. That is expected and is **not** a failure of AC69b.

Record in the task notes that AC69b is verified by opening
`https://github.com/settings/installations` → `atelier-release-please` → **Configure**, and confirming:
- **Repository access** is “Only select repositories”, listing `Heyian/atelier` alone (`repository_selection: selected`);
- **Permissions** are exactly Contents: Read and write, Pull requests: Read and write, Metadata: Read-only.

- [ ] **Step 6: Verify the deferred items (#12, #13) carry all four body sections**

```bash
for n in 12 13; do
  echo "--- issue #$n ---"
  gh issue view "$n" --json state,body -q '.state'
  gh issue view "$n" --json body -q .body \
    | grep -cE '^## (Context|Required|Integration Points|Priority)$'
done
```

Expected: `OPEN` and `4` for each. Also confirm #14 is `CLOSED`:

```bash
gh issue view 14 --json state -q .state
```

Expected: `CLOSED`.

---

### Task 2: Retire the tag-triggered release workflow and retrigger CI

**Files:**
- Delete: `.github/workflows/release.yml`
- Modify: `.github/workflows/ci.yml:1-7`

**Interfaces:**
- Consumes: nothing.
- Produces: `ci.yml` running on every `pull_request` (no `branches` filter) and on `push` to `dev` and `main` only, with a ref-keyed `concurrency` group. Job names stay `checks-linux` and `checks-windows` — the two contexts named by the `main` required-status-checks ruleset.

- [ ] **Step 1: Confirm `--release-version` is already absent (AC60)**

```bash
grep -c -- --release-version scripts/tests/build_test.sh
grep -c -- --release-version scripts/build.sh
bash scripts/build.sh --help | grep -c -- --release-version
bash scripts/build.sh --release-version v0.1.0; echo "exit=$?"
bash scripts/build.sh --release-version=v0.1.0; echo "exit=$?"
```

Expected: `0` from each `grep -c`; both `--release-version` invocations print `ERROR: unknown argument: --release-version…` and report a non-zero `exit=`.

(`grep -c` exits 1 when the count is 0. Run each line separately so the shell does not stop.)

- [ ] **Step 2: Delete the tag-triggered workflow**

```bash
git rm .github/workflows/release.yml
```

- [ ] **Step 3: Retrigger `ci.yml`**

Replace lines 1–7 of `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  # No `branches` filter on pull_request: this must run on PRs targeting dev
  # and main alike, including release-please's own release PR — that is where
  # the WHATS-NEW.md forcing function (AC53) fires.
  pull_request:
  push:
    branches: [dev, main]

# A ref-keyed group so a rapid second push supersedes the first run instead of
# queueing behind it. pull_request events carry refs/pull/N/merge, so a PR's
# runs never cancel its branch's push runs.
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true

jobs:
```

Leave the rest of the file untouched.

- [ ] **Step 4: Verify no workflow references a removed file or an unexpected secret**

```bash
ls .github/workflows/
grep -rn 'release.yml' .github/ || echo "no stale references"
grep -rhoE 'secrets\.[A-Z_]+' .github/ | sort -u
```

Expected: only `ci.yml` under `.github/workflows/`; `no stale references`; empty output from the secrets grep (no secrets are referenced yet).

- [ ] **Step 5: Run the pre-commit gate**

```bash
bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && \
  bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS (mechanical checks)` and `STATUS: PASS` from each suite.

- [ ] **Step 6: Commit**

```bash
git add -A .github/workflows
git commit -m "ci: retire the tag-triggered release workflow and retrigger CI

release-please replaces release.yml: a tag pushed by an action under
GITHUB_TOKEN triggers no workflow, so the v* trigger would silently never
fire again. ci.yml now runs on every pull request — including the release
PR — and on pushes to dev and main only."
```

---

### Task 3: The version-bearing tree and the changelog split

Everything release-please owns or reads lands here, in one commit, per the spec's implementation-ordering note. No new check runs yet, so `--check` stays green throughout.

**Files:**
- Create: `version.txt`
- Create: `.release-please-manifest.json`
- Create: `release-please-config.json`
- Create: `docs/WHATS-NEW.md`
- Modify: `CHANGELOG.md` (replace wholesale)
- Modify: `skills/atelier/fr/SKILL.md:4`, `skills/atelier/en/SKILL.md:4`, `skills/atelier-mentor/fr/SKILL.md:4`, `skills/atelier-mentor/en/SKILL.md:4`, `skills/atelier-marketing/fr/SKILL.md:4`, `skills/atelier-marketing/en/SKILL.md:4`, `skills/atelier-forge/fr/SKILL.md:4`, `skills/atelier-forge/en/SKILL.md:4`, `skills/atelier-ventes/fr/SKILL.md:4`, `skills/atelier-ventes/en/SKILL.md:4`, `skills/atelier-reunions/fr/SKILL.md:4`, `skills/atelier-reunions/en/SKILL.md:4`, `skills/atelier-boussole/fr/SKILL.md:4`, `skills/atelier-boussole/en/SKILL.md:4`
- Modify: `README.md:33-36`, `README.md:86-89`
- Modify: `docs/INSTALL.en.md:99-101`, `docs/INSTALL.fr.md:106-108`

**Interfaces:**
- Consumes: nothing.
- Produces:
  - `version.txt` — one line, `0.1.0`, no trailing blank line. The reference value every later check compares against.
  - `release-please-config.json` — `packages["."].extra-files` holds exactly 15 objects, each `{"type": "generic", "path": "<repo-relative POSIX path>"}`: the 14 `SKILL.md` files and `README.md`.
  - `docs/WHATS-NEW.md` — a `## v0.1.0` heading whose section carries a `**Français**` label with prose and an `**English**` label with prose.

- [ ] **Step 1: Create `version.txt`**

```bash
printf '0.1.0\n' > version.txt
awk 'END { print NR }' version.txt
```

Expected: `1`.

- [ ] **Step 2: Create `.release-please-manifest.json`**

```json
{
  ".": "0.1.0"
}
```

- [ ] **Step 3: Create `release-please-config.json`**

```json
{
  "$schema": "https://raw.githubusercontent.com/googleapis/release-please/main/schemas/config.json",
  "include-v-in-tag": true,
  "packages": {
    ".": {
      "release-type": "simple",
      "changelog-path": "CHANGELOG.md",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": false,
      "extra-files": [
        { "type": "generic", "path": "README.md" },
        { "type": "generic", "path": "skills/atelier/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier/en/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-mentor/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-mentor/en/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-marketing/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-marketing/en/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-forge/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-forge/en/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-ventes/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-ventes/en/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-reunions/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-reunions/en/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-boussole/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-boussole/en/SKILL.md" }
      ],
      "changelog-sections": [
        { "type": "feat", "section": "Features" },
        { "type": "fix", "section": "Bug Fixes" },
        { "type": "perf", "section": "Performance Improvements" },
        { "type": "revert", "section": "Reverts" },
        { "type": "docs", "section": "Documentation", "hidden": true },
        { "type": "style", "section": "Styles", "hidden": true },
        { "type": "chore", "section": "Miscellaneous Chores", "hidden": true },
        { "type": "refactor", "section": "Code Refactoring", "hidden": true },
        { "type": "test", "section": "Tests", "hidden": true },
        { "type": "build", "section": "Build System", "hidden": true },
        { "type": "ci", "section": "Continuous Integration", "hidden": true }
      ]
    }
  }
}
```

Verify the roster matches the tree exactly (AC66's “exactly 15 entries”):

```bash
grep -c '"type": "generic"' release-please-config.json
/usr/bin/find skills -mindepth 3 -maxdepth 3 -name SKILL.md | wc -l
```

Expected: `15` and `14`.

- [ ] **Step 4: Annotate all fourteen `SKILL.md` version lines**

```bash
for f in $(/usr/bin/find skills -mindepth 3 -maxdepth 3 -name SKILL.md | sort); do
  sed -i 's/^version: \([0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\)$/version: \1 # x-release-please-version/' "$f"
done
grep -rn '^version:' skills/*/*/SKILL.md
```

Expected: fourteen lines, each reading exactly `version: 0.1.0 # x-release-please-version`.

- [ ] **Step 5: Annotate both `README.md` version lines**

Replace `README.md:33-36`:

```markdown
## Statut

Version 0.1.0 <!-- x-release-please-version -->

Les sept compétences sont livrées, en français et en anglais. Voir `docs/`
pour le devis de conception.
```

Replace `README.md:86-89`:

```markdown
## Status

Version 0.1.0 <!-- x-release-please-version -->

All seven skills are shipping, in both French and English. See `docs/` for
the design spec.
```

The version gets its own line so release-please's generic updater has exactly
one SemVer to rewrite on the annotated line, and so the annotation is not
buried mid-sentence. Verify:

```bash
grep -c 'x-release-please-version' README.md
```

Expected: `2`.

- [ ] **Step 6: Create `docs/WHATS-NEW.md` with the bilingual prose moved out of `CHANGELOG.md`**

```markdown
# Quoi de neuf dans Atelier / What's new in Atelier

Ce fichier est écrit à la main, pour les gens qui utilisent Atelier.
`CHANGELOG.md` est généré automatiquement, pour le dépôt.

This file is hand-written, for the people who use Atelier. `CHANGELOG.md` is
generated, for the repository.

## v0.1.0

**Français** — Première version. Sept compétences : le pivot `atelier`
(entretien d'accueil et Profil d'entreprise), `atelier-mentor`,
`atelier-boussole`, `atelier-forge`, plus marketing, ventes et réunions.

**English** — First release. Seven skills: the `atelier` hub (onboarding
interview and Company Profile), `atelier-mentor`, `atelier-compass`,
`atelier-forge`, plus marketing, sales, and meetings.
```

- [ ] **Step 7: Replace `CHANGELOG.md` with the generated-file stub**

```markdown
# Changelog

Generated by release-please from the Conventional Commits that land on `main`.
Do not edit by hand — release-please rewrites this file on every release.

Executive-facing, bilingual release notes live in
[`docs/WHATS-NEW.md`](docs/WHATS-NEW.md), which is hand-written.
```

Verify AC67's changelog half:

```bash
grep -c '\*\*Français\*\*' CHANGELOG.md
```

Expected: `0` (the command exits 1 when the count is 0 — that is the pass).

- [ ] **Step 8: Point both install guides at `docs/WHATS-NEW.md` (AC65)**

Replace `docs/INSTALL.en.md:99-101`:

```markdown
That's it — the new version replaces the old one. To see what changed
between versions, read [`WHATS-NEW.md`](WHATS-NEW.md): it lists what's new
in plain language, no technical jargon.
```

Replace `docs/INSTALL.fr.md:106-108`:

```markdown
C'est tout — la nouvelle version remplace l'ancienne. Pour savoir ce qui a
changé d'une version à l'autre, consulte [`WHATS-NEW.md`](WHATS-NEW.md) :
il liste les nouveautés en langage clair, sans jargon technique.
```

Verify no `CHANGELOG.md` reference remains in either “Updating” section:

```bash
grep -n 'CHANGELOG' docs/INSTALL.en.md docs/INSTALL.fr.md || echo "no CHANGELOG references"
grep -n 'WHATS-NEW' docs/INSTALL.en.md docs/INSTALL.fr.md
```

Expected: `no CHANGELOG references`, and one `WHATS-NEW.md` link per guide.

- [ ] **Step 9: Run the pre-commit gate**

```bash
bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && \
  bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS (mechanical checks)` and `STATUS: PASS` from each suite. The annotation is invisible to today's `check_frontmatter`, which only requires a non-empty `version` field.

- [ ] **Step 10: Commit**

```bash
git add version.txt .release-please-manifest.json release-please-config.json \
  docs/WHATS-NEW.md CHANGELOG.md README.md docs/INSTALL.en.md docs/INSTALL.fr.md \
  skills/*/*/SKILL.md
git commit -m "build: make the version release-please-owned and split the changelog

version.txt becomes the version of record; the fourteen SKILL.md frontmatter
lines and both README.md version lines carry an x-release-please-version
annotation so release-please's generic updater maintains them.

CHANGELOG.md becomes the generated, English, repo-facing file; the
hand-written bilingual prose moves to docs/WHATS-NEW.md, which both install
guides now link."
```

---

### Task 4: The coherence check in bash, the packaging strip, and the mutation matrix

**Files:**
- Modify: `scripts/build.sh` — add `json_wellformed`, `extra_files_entries`, `json_string_field`, `check_whats_new`, `check_version_coherence`; call from `run_checks`; strip the annotation in `stage_skill`
- Modify: `scripts/tests/build_test.sh` — fixture gains the five new files; add the mutation matrix and three positive cases

**Interfaces:**
- Consumes: `version.txt`, `release-please-config.json`, `.release-please-manifest.json`, `docs/WHATS-NEW.md`, `README.md` and the sixteen annotations from Task 3.
- Produces:
  - `check_version_coherence()` — no arguments; reads `$REPO_ROOT`; reports through the existing `check_fail`. Called once per `--check` run, before the per-locale loop.
  - `stage_skill()` — unchanged signature `(canonical, locale, stage)`, still echoes the localized name; the staged `SKILL.md` now has ` # x-release-please-version` removed from its version line.
  - `make_fixture_repo()` in `build_test.sh` — unchanged signature (echoes a temp dir path); the fixture now additionally contains `version.txt`, `.release-please-manifest.json`, `release-please-config.json`, `docs/WHATS-NEW.md` and `README.md`, and its two `SKILL.md` version lines are annotated.
  - `expect_check_fail <dir> <needle> <label>` in `build_test.sh` — runs `build.sh --check` in `<dir>`, passes when the run exits non-zero **and** `<needle>` appears in the combined output.

- [ ] **Step 1: Write the failing tests — extend the fixture builder**

In `scripts/tests/build_test.sh`, inside `make_fixture_repo`, annotate both
`SKILL.md` version lines by changing the two heredocs:

```bash
  cat > "$dir/skills/atelier-ventes/fr/SKILL.md" <<EOF
---
name: atelier-ventes
description: À utiliser quand il est question de pipeline, de relance ou de proposition commerciale.
version: 0.1.0 # x-release-please-version
---

# Ventes

$fr_pointer
EOF
  cat > "$dir/skills/atelier-ventes/en/SKILL.md" <<EOF
---
name: atelier-sales
description: Use when the conversation turns to pipeline, follow-ups, or proposals.
version: 0.1.0 # x-release-please-version
---

# Sales

$en_pointer
EOF
```

Then, immediately before the closing `echo "$dir"`, add the five new files.
The fixture needs `README.md` too: AC55 requires every AC59 invariant to hold,
and AC59 is a statement about `README.md`.

```bash
  printf '0.1.0\n' > "$dir/version.txt"

  cat > "$dir/.release-please-manifest.json" <<'EOF'
{
  ".": "0.1.0"
}
EOF

  cat > "$dir/release-please-config.json" <<'EOF'
{
  "include-v-in-tag": true,
  "packages": {
    ".": {
      "release-type": "simple",
      "changelog-path": "CHANGELOG.md",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": false,
      "extra-files": [
        { "type": "generic", "path": "README.md" },
        { "type": "generic", "path": "skills/atelier-ventes/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-ventes/en/SKILL.md" }
      ]
    }
  }
}
EOF

  cat > "$dir/README.md" <<'EOF'
# Fixture

Version 0.1.0 <!-- x-release-please-version -->

Version 0.1.0 <!-- x-release-please-version -->
EOF

  mkdir -p "$dir/docs"
  cat > "$dir/docs/WHATS-NEW.md" <<'EOF'
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.

**English** — First release.
EOF
```

- [ ] **Step 2: Write the failing tests — the shared assertion helper**

Add just below `pass()` in `scripts/tests/build_test.sh`:

```bash
# Run --check in a fixture and require both a non-zero exit and a named path
# in the combined output. Every coherence mutation is asserted this way, so
# a fixture that breaks for an unrelated reason cannot pass by accident.
expect_check_fail() {
  local dir="$1" needle="$2" label="$3" out rc
  out="$( cd "$dir" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
  if [[ "$rc" -ne 0 ]] && grep -qF -- "$needle" <<<"$out"; then
    pass "$label"
  else
    fail "$label (rc=$rc, out=$out)"
  fi
}
```

- [ ] **Step 3: Write the failing tests — the mutation matrix**

Append to `scripts/tests/build_test.sh`, immediately before the final
`echo` / `STATUS` block:

```bash
# --- AC50: a version line without the annotation fails, naming the path
d="$(make_fixture_repo)"
sed -i 's/^version: 0\.1\.0 # x-release-please-version$/version: 0.1.0/' \
  "$d/skills/atelier-ventes/fr/SKILL.md"
expect_check_fail "$d" "skills/atelier-ventes/fr/SKILL.md" \
  "AC50 rejects a version line without the annotation"
rm -rf "$d"

# --- AC50: two version: lines in the frontmatter fail, naming the path
d="$(make_fixture_repo)"
sed -i '4a version: 0.1.0 # x-release-please-version' \
  "$d/skills/atelier-ventes/en/SKILL.md"
expect_check_fail "$d" "skills/atelier-ventes/en/SKILL.md" \
  "AC50 rejects two version: lines in the frontmatter"
rm -rf "$d"

# --- AC50: no version: line at all fails, naming the path
d="$(make_fixture_repo)"
sed -i '/^version: /d' "$d/skills/atelier-ventes/fr/SKILL.md"
expect_check_fail "$d" "skills/atelier-ventes/fr/SKILL.md" \
  "AC50 rejects a frontmatter with no version: line"
rm -rf "$d"

# --- AC50: a malformed SemVer on the annotated line fails, naming the path
d="$(make_fixture_repo)"
sed -i 's/^version: 0\.1\.0 # x-release-please-version$/version: 0.1 # x-release-please-version/' \
  "$d/skills/atelier-ventes/en/SKILL.md"
expect_check_fail "$d" "skills/atelier-ventes/en/SKILL.md" \
  "AC50 rejects a malformed SemVer on the annotated line"
rm -rf "$d"

# --- AC51: two skills declaring different versions fails, reporting both values
d="$(make_fixture_repo)"
sed -i 's/^version: 0\.1\.0 # x-release-please-version$/version: 0.2.0 # x-release-please-version/' \
  "$d/skills/atelier-ventes/en/SKILL.md"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] && grep -qF '0.2.0' <<<"$out" && grep -qF '0.1.0' <<<"$out"; then
  pass "AC51 rejects mismatched skill versions and reports both values"
else
  fail "AC51 did not report both disagreeing versions (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- AC51: version.txt disagreeing with the skills fails, reporting both values
d="$(make_fixture_repo)"
printf '0.3.0\n' > "$d/version.txt"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] && grep -qF '0.3.0' <<<"$out" && grep -qF '0.1.0' <<<"$out"; then
  pass "AC51 rejects a version.txt disagreeing with the skills"
else
  fail "AC51 did not report the version.txt disagreement (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- AC52: a SKILL.md absent from extra-files fails, naming the path
d="$(make_fixture_repo)"
grep -v 'skills/atelier-ventes/en/SKILL.md' "$d/release-please-config.json" \
  > "$d/rp.tmp"
# The removed line carried the trailing comma's partner; re-close the array.
sed -i 's/{ "type": "generic", "path": "skills\/atelier-ventes\/fr\/SKILL.md" },/{ "type": "generic", "path": "skills\/atelier-ventes\/fr\/SKILL.md" }/' \
  "$d/rp.tmp"
mv "$d/rp.tmp" "$d/release-please-config.json"
expect_check_fail "$d" "skills/atelier-ventes/en/SKILL.md" \
  "AC52 rejects a SKILL.md absent from extra-files"
rm -rf "$d"

# --- AC52: an extra-files entry lacking type: generic fails, naming the path
d="$(make_fixture_repo)"
sed -i 's/{ "type": "generic", "path": "skills\/atelier-ventes\/fr\/SKILL.md" }/{ "type": "json", "path": "skills\/atelier-ventes\/fr\/SKILL.md" }/' \
  "$d/release-please-config.json"
expect_check_fail "$d" "skills/atelier-ventes/fr/SKILL.md" \
  "AC52 rejects an extra-files entry that is not type generic"
rm -rf "$d"

# --- AC59: README.md missing an annotation fails, naming README.md
d="$(make_fixture_repo)"
sed -i '0,/^Version 0\.1\.0 <!-- x-release-please-version -->$/s//Version 0.1.0/' \
  "$d/README.md"
expect_check_fail "$d" "README.md" "AC59 rejects a README with one annotation"
rm -rf "$d"

# --- AC59: an annotated README line disagreeing with version.txt fails
d="$(make_fixture_repo)"
sed -i '0,/^Version 0\.1\.0 <!-- x-release-please-version -->$/s//Version 0.9.9 <!-- x-release-please-version -->/' \
  "$d/README.md"
expect_check_fail "$d" "README.md" \
  "AC59 rejects an annotated README line disagreeing with version.txt"
rm -rf "$d"

# --- AC59: extra-files without a README.md entry fails, naming README.md
d="$(make_fixture_repo)"
sed -i '/"path": "README.md"/d' "$d/release-please-config.json"
expect_check_fail "$d" "README.md" \
  "AC59 rejects extra-files with no README.md entry"
rm -rf "$d"

# --- AC53: a WHATS-NEW heading with an empty section fails, naming the path
d="$(make_fixture_repo)"
cat > "$d/docs/WHATS-NEW.md" <<'EOF'
# Quoi de neuf / What's new

## v0.1.0

## v0.0.9

**Français** — Ancienne version.

**English** — Old release.
EOF
expect_check_fail "$d" "docs/WHATS-NEW.md" \
  "AC53 rejects a v0.1.0 heading with an empty section"
rm -rf "$d"

# --- AC53: a section missing the English half fails, naming the path
d="$(make_fixture_repo)"
cat > "$d/docs/WHATS-NEW.md" <<'EOF'
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.
EOF
expect_check_fail "$d" "docs/WHATS-NEW.md" \
  "AC53 rejects a section with no English half"
rm -rf "$d"

# --- AC53: a label with no prose after it fails, naming the path
d="$(make_fixture_repo)"
cat > "$d/docs/WHATS-NEW.md" <<'EOF'
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.

**English**
EOF
expect_check_fail "$d" "docs/WHATS-NEW.md" \
  "AC53 rejects a label with no prose after it"
rm -rf "$d"

# --- AC53: no heading for the current version fails, naming the path
d="$(make_fixture_repo)"
sed -i 's/^## v0\.1\.0$/## v0.0.9/' "$d/docs/WHATS-NEW.md"
expect_check_fail "$d" "docs/WHATS-NEW.md" \
  "AC53 rejects a WHATS-NEW with no heading for version.txt's version"
rm -rf "$d"

# --- AC54: each required file, missing then empty, fails naming that path
for target in version.txt release-please-config.json \
              .release-please-manifest.json docs/WHATS-NEW.md README.md; do
  d="$(make_fixture_repo)"
  rm -f "$d/$target"
  expect_check_fail "$d" "$target" "AC54 rejects a missing $target"
  rm -rf "$d"

  d="$(make_fixture_repo)"
  : > "$d/$target"
  expect_check_fail "$d" "$target" "AC54 rejects an empty $target"
  rm -rf "$d"
done

# --- AC54: a version.txt with two lines fails, naming version.txt
d="$(make_fixture_repo)"
printf '0.1.0\n0.1.0\n' > "$d/version.txt"
expect_check_fail "$d" "version.txt" "AC54 rejects a two-line version.txt"
rm -rf "$d"

# --- AC54: a version.txt that is not SemVer fails, naming version.txt
d="$(make_fixture_repo)"
printf 'v0.1.0\n' > "$d/version.txt"
expect_check_fail "$d" "version.txt" "AC54 rejects a non-SemVer version.txt"
rm -rf "$d"

# --- AC54: an unparseable release-please-config.json fails, naming the path
d="$(make_fixture_repo)"
printf '{ "packages": { ".": { "extra-files": [ }\n' \
  > "$d/release-please-config.json"
expect_check_fail "$d" "release-please-config.json" \
  "AC54 rejects an unparseable release-please-config.json"
rm -rf "$d"

# --- AC54: an unparseable .release-please-manifest.json fails, naming the path
d="$(make_fixture_repo)"
printf '{ ".": "0.1.0"\n' > "$d/.release-please-manifest.json"
expect_check_fail "$d" ".release-please-manifest.json" \
  "AC54 rejects an unparseable .release-please-manifest.json"
rm -rf "$d"

# --- AC55: the clean fixture passes, with the exact PASS line
d="$(make_fixture_repo)"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && grep -qxF 'STATUS: PASS (mechanical checks)' <<<"$out"; then
  pass "AC55 clean fixture passes with the exact PASS line"
else
  fail "AC55 clean fixture did not print the exact PASS line (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- AC56: --check passes with jq off PATH
# A shim PATH holding only the documented build dependencies. `jq` is absent
# from it by construction, so this proves the checks never reach for it.
d="$(make_fixture_repo)"
shim="$(mktemp -d)"
for tool in bash awk grep find zip unzip sed cat head sort wc cmp mktemp rm mkdir cp mv tr basename dirname printf; do
  src="$(command -v "$tool" 2>/dev/null)" || continue
  ln -sf "$src" "$shim/$tool"
done
out="$( cd "$d" && PATH="$shim" bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && ! PATH="$shim" command -v jq >/dev/null 2>&1; then
  pass "AC56 --check passes with jq off PATH"
else
  fail "AC56 --check failed without jq (rc=$rc, out=$out)"
fi
rm -rf "$shim" "$d"

# --- AC57: the packaged SKILL.md carries the version without the annotation
d="$(make_fixture_repo)"
( cd "$d" && bash scripts/build.sh --lang all >/dev/null 2>&1 )
x="$(mktemp -d)"
unzip -q "$d/dist/atelier-ventes-fr.zip" -d "$x"
packaged="$(grep '^version:' "$x/SKILL.md")"
if [[ "$packaged" == "version: 0.1.0" ]]; then
  pass "AC57 packaged SKILL.md version line has the annotation stripped"
else
  fail "AC57 packaged version line is '$packaged', expected 'version: 0.1.0'"
fi
if grep -rqF 'x-release-please-version' "$x"; then
  fail "AC57 an archive member still contains x-release-please-version"
else
  pass "AC57 no archive member contains x-release-please-version"
fi
rm -rf "$x" "$d"
```

- [ ] **Step 4: Run the tests to verify they fail**

```bash
bash scripts/tests/build_test.sh
```

Expected: `STATUS: FAIL (N)` with `FAIL:` lines for every AC50–AC57 case above
(the mutations are not yet detected, and the annotation is not yet stripped).
The pre-existing AC1–AC18 cases must still pass.

- [ ] **Step 5: Implement the JSON helpers in `scripts/build.sh`**

Insert immediately after the `check_fail` definition (around line 194):

```bash
# --- Minimal JSON support, hand-rolled on purpose.
# AC56 requires --check to run with jq off PATH, and the repo has no other
# JSON dependency, so these two helpers cover exactly what the coherence
# check needs and nothing more.

# Well-formedness, not validity: balanced braces/brackets, correctly paired
# quotes, no string spanning a line break. Enough to catch a truncated or
# hand-mangled file, which is what AC54's "malformed" case means here.
json_wellformed() {
  awk '
    { s = s $0 "\n" }
    END {
      depth = 0; instr = 0; esc = 0
      n = length(s)
      for (i = 1; i <= n; i++) {
        c = substr(s, i, 1)
        if (instr) {
          if (esc) { esc = 0 }
          else if (c == "\\") { esc = 1 }
          else if (c == "\"") { instr = 0 }
          else if (c == "\n") { exit 1 }
          continue
        }
        if (c == "\"") { instr = 1; continue }
        if (c == "{") { stack[++depth] = "{"; continue }
        if (c == "[") { stack[++depth] = "["; continue }
        if (c == "}") { if (depth == 0 || stack[depth] != "{") exit 1; depth--; continue }
        if (c == "]") { if (depth == 0 || stack[depth] != "[") exit 1; depth--; continue }
      }
      if (instr || depth != 0) exit 1
      exit 0
    }
  ' "$1"
}

# Emit one line per `extra-files` array element: the object body, with
# newlines flattened to spaces so each entry stays on one line.
extra_files_entries() {
  awk '
    { s = s $0 "\n" }
    END {
      i = index(s, "\"extra-files\"")
      if (i == 0) exit 0
      s = substr(s, i)
      j = index(s, "[")
      if (j == 0) exit 0
      s = substr(s, j + 1)
      depth = 0; instr = 0; esc = 0; buf = ""
      n = length(s)
      for (k = 1; k <= n; k++) {
        c = substr(s, k, 1)
        if (instr) {
          buf = buf c
          if (esc) { esc = 0 }
          else if (c == "\\") { esc = 1 }
          else if (c == "\"") { instr = 0 }
          continue
        }
        if (c == "\"") { instr = 1; buf = buf c; continue }
        if (c == "{") { depth++; if (depth == 1) { buf = ""; continue } }
        else if (c == "}") { depth--; if (depth == 0) { print buf; buf = ""; continue } }
        else if (c == "]" && depth == 0) { break }
        if (depth >= 1) {
          if (c == "\n" || c == "\r" || c == "\t") c = " "
          buf = buf c
        }
      }
    }
  ' "$1"
}

# Pull one string-valued field out of a single extra-files object body.
json_string_field() {
  sed -n 's/.*"'"$2"'"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' <<<"$1" | head -1
}
```

- [ ] **Step 6: Implement `check_whats_new` in `scripts/build.sh`**

Insert directly after `json_string_field`:

```bash
# AC53 — docs/WHATS-NEW.md must carry a `## v<version>` heading whose section
# holds both bilingual labels, each followed by at least one non-empty prose
# line. This is the forcing function: on a release PR version.txt has moved
# and this file has not, so CI lands red until a human writes the entry.
check_whats_new() {
  local version="$1" rel="docs/WHATS-NEW.md" verdict
  verdict="$(awk -v ver="$version" '
    $0 == "## v" ver { inside = 1; found = 1; next }
    { if (inside && substr($0, 1, 3) == "## ") inside = 0 }
    inside { sec[++n] = $0 }
    END {
      if (!found) { print "no-heading"; exit }
      for (l = 1; l <= 2; l++) {
        label = (l == 1) ? "**Français**" : "**English**"
        at = 0
        for (i = 1; i <= n; i++) { if (index(sec[i], label) > 0) { at = i; break } }
        if (at == 0) { print "no-label:" label; exit }
        rest = substr(sec[at], index(sec[at], label) + length(label))
        # Prose, not punctuation: an em dash or a colon alone is not an entry.
        if (rest ~ /[[:alnum:]]/) continue
        ok = 0
        for (i = at + 1; i <= n; i++) {
          if (index(sec[i], "**Français**") > 0 || index(sec[i], "**English**") > 0) break
          if (sec[i] ~ /[[:alnum:]]/) { ok = 1; break }
        }
        if (!ok) { print "no-prose:" label; exit }
      }
      print "ok"
    }
  ' "$REPO_ROOT/$rel")"

  case "$verdict" in
    ok) ;;
    no-heading)  check_fail "$rel: no '## v$version' heading for the version in version.txt" ;;
    no-label:*)  check_fail "$rel: the v$version section has no ${verdict#no-label:} label" ;;
    no-prose:*)  check_fail "$rel: the ${verdict#no-prose:} label in the v$version section is followed by no prose" ;;
    *)           check_fail "$rel: could not validate the v$version section" ;;
  esac
}
```

- [ ] **Step 7: Implement `check_version_coherence` in `scripts/build.sh`**

Insert directly after `check_whats_new`:

```bash
# AC50–AC54, AC59 — the version is computed by release-please, so nothing here
# checks that it is *correct*; it checks that every place declaring it agrees,
# and that a new skill cannot silently opt out of being maintained.
check_version_coherence() {
  local f version vcount tsv body t p rel line declared found n_any n_generic

  # AC54 / AC59 — the files this check reads must exist and be non-empty.
  # An early return: with the reference file missing there is nothing left to
  # compare against, and one clear failure beats a cascade.
  for f in version.txt release-please-config.json .release-please-manifest.json \
           docs/WHATS-NEW.md README.md; do
    if [[ ! -f "$REPO_ROOT/$f" ]]; then check_fail "$f: missing"; return; fi
    if [[ ! -s "$REPO_ROOT/$f" ]]; then check_fail "$f: empty"; return; fi
  done

  # AC54 — version.txt holds exactly one SemVer line. awk's NR counts a final
  # line with no trailing newline, so a one-line file with or without one
  # both read as 1.
  vcount="$(awk 'END { print NR }' "$REPO_ROOT/version.txt")"
  version="$(head -1 "$REPO_ROOT/version.txt")"
  if [[ "$vcount" -ne 1 ]] || [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    check_fail "version.txt: expected exactly one SemVer line, found $vcount line(s) starting '$version'"
    return
  fi

  # AC54 — both JSON files must parse.
  for f in release-please-config.json .release-please-manifest.json; do
    if ! json_wellformed "$REPO_ROOT/$f"; then
      check_fail "$f: is not well-formed JSON"
      return
    fi
  done

  # AC50 / AC51 — every SKILL.md declares the version once, annotated, and
  # equal to version.txt.
  while IFS= read -r f; do
    rel="${f#"$REPO_ROOT"/}"
    found="$(awk '
      NR == 1 && $0 == "---" { inside = 1; next }
      inside && $0 == "---" { exit }
      inside && index($0, "version:") == 1 { n++ }
      END { print n + 0 }
    ' "$f")"
    if [[ "$found" -ne 1 ]]; then
      check_fail "$rel: frontmatter has $found 'version:' lines, expected exactly 1"
      continue
    fi
    line="$(awk '
      NR == 1 && $0 == "---" { inside = 1; next }
      inside && $0 == "---" { exit }
      inside && index($0, "version:") == 1 { print; exit }
    ' "$f")"
    if [[ ! "$line" =~ ^version:\ ([0-9]+\.[0-9]+\.[0-9]+)\ \#\ x-release-please-version$ ]]; then
      check_fail "$rel: version line '$line' must read 'version: <semver> # x-release-please-version'"
      continue
    fi
    declared="${BASH_REMATCH[1]}"
    if [[ "$declared" != "$version" ]]; then
      check_fail "$rel: declares version $declared but version.txt says $version"
    fi
  done < <(find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -name SKILL.md -type f | sort)

  # AC52 / AC59 — every SKILL.md and README.md is listed in extra-files
  # exactly once, as type generic.
  tsv=""
  while IFS= read -r body; do
    [[ -z "$body" ]] && continue
    p="$(json_string_field "$body" path)"
    t="$(json_string_field "$body" type)"
    [[ -z "$p" ]] && continue
    tsv+="$t"$'\t'"$p"$'\n'
  done < <(extra_files_entries "$REPO_ROOT/release-please-config.json")

  while IFS= read -r rel; do
    n_any="$(printf '%s' "$tsv" | awk -F'\t' -v p="$rel" '$2 == p { n++ } END { print n + 0 }')"
    n_generic="$(printf '%s' "$tsv" | awk -F'\t' -v p="$rel" '$1 == "generic" && $2 == p { n++ } END { print n + 0 }')"
    if [[ "$n_any" -ne 1 ]]; then
      check_fail "release-please-config.json: extra-files must list $rel exactly once, found $n_any"
    elif [[ "$n_generic" -ne 1 ]]; then
      check_fail "release-please-config.json: the extra-files entry for $rel is not type 'generic'"
    fi
  done < <( { find "$SKILLS_DIR" -mindepth 3 -maxdepth 3 -name SKILL.md -type f \
                | sed "s|^$REPO_ROOT/||" | sort; echo "README.md"; } )

  # AC59 — README.md carries exactly two annotated lines, each on version.
  n_any="$(grep -cF 'x-release-please-version' "$REPO_ROOT/README.md" || true)"
  if [[ "$n_any" -ne 2 ]]; then
    check_fail "README.md: expected exactly 2 x-release-please-version annotations, found $n_any"
  fi
  while IFS= read -r line; do
    declared="$(grep -oE '[0-9]+\.[0-9]+\.[0-9]+' <<<"$line" | head -1)"
    if [[ "$declared" != "$version" ]]; then
      check_fail "README.md: annotated line declares '$declared' but version.txt says $version"
    fi
  done < <(grep -F 'x-release-please-version' "$REPO_ROOT/README.md" || true)

  # AC53 — the bilingual entry exists for this version.
  check_whats_new "$version"
}
```

- [ ] **Step 8: Call it from `run_checks`**

In `run_checks`, insert as the first statement after the local declarations
(before the `for locale` loop):

```bash
  # Repo-wide, not per-locale: run it once.
  check_version_coherence
```

- [ ] **Step 9: Strip the annotation in `stage_skill`**

In `stage_skill`, insert after the two canonical-reference `cp` lines and
before the final `echo "$name"`:

```bash
  # AC57 — the annotation is a release-please marker, not skill metadata.
  # Strip it so the packaged SKILL.md carries a clean `version: X.Y.Z`, and
  # a naive frontmatter parser in the skill loader cannot read the version as
  # "0.1.0 # x-release-please-version". The temp file lives inside $stage, so
  # the EXIT trap sweeps it on any failure path.
  sed 's/^\(version: [0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\) # x-release-please-version[[:space:]]*$/\1/' \
    "$stage/SKILL.md" > "$stage/SKILL.md.tmp"
  mv "$stage/SKILL.md.tmp" "$stage/SKILL.md"
```

- [ ] **Step 10: Run the tests to verify they pass**

```bash
bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS`, with every AC50–AC57 case reporting `ok:`.

- [ ] **Step 11: Run `--check` on the real repository**

```bash
bash scripts/build.sh --check
```

Expected: exactly `STATUS: PASS (mechanical checks)`.

- [ ] **Step 12: Run the pre-commit gate**

```bash
bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && \
  bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS (mechanical checks)` and `STATUS: PASS` from each suite.

- [ ] **Step 13: Commit**

```bash
git add scripts/build.sh scripts/tests/build_test.sh
git commit -m "build: check version coherence and strip the annotation at packaging

release-please makes the original drift impossible but opens a new door: a
fifteenth skill whose version line lacks the annotation, or which is never
added to extra-files, would ship a stale version forever with nothing
failing. check_version_coherence closes it at PR time, and requires a
bilingual docs/WHATS-NEW.md entry for whatever version.txt declares.

stage_skill strips the annotation so the packaged SKILL.md stays pristine."
```

---

### Task 5: PowerShell parity and the Windows mutation matrix

AC58 requires `./scripts/build.ps1 -Check` to return the same exit status and
name the same path as bash for **every** fixture mutation — not merely to check
the coherent real repository, which is all the Windows job asserts today. That
needs a PowerShell test script, so this task creates one and wires it into CI.

**Files:**
- Modify: `scripts/build.ps1` — add `Test-VersionCoherence` and `Test-WhatsNew`; call from `Invoke-Checks`; strip the annotation in `New-SkillStage`
- Create: `scripts/tests/build_test.ps1`
- Modify: `.github/workflows/ci.yml` — add a “Build-script tests on Windows” step to `checks-windows`
- Modify: `CLAUDE.md` — add the new command to the Commands list

**Interfaces:**
- Consumes: the same five repo files as Task 4.
- Produces:
  - `Test-VersionCoherence` — no parameters; reads `$RepoRoot`; reports through `Add-CheckFailure`. Called once from `Invoke-Checks`, before the per-locale loop.
  - `New-SkillStage` — unchanged signature `(-Canonical, -Locale, -Stage)`, still returns the localized name; the staged `SKILL.md` version line has the annotation removed.
  - `scripts/tests/build_test.ps1` — exits `0` and prints `STATUS: PASS` when every case passes, exits `1` and prints `STATUS: FAIL (<n>)` otherwise. Same contract as `build_test.sh`.

- [ ] **Step 1: Write the failing test script `scripts/tests/build_test.ps1`**

```powershell
#requires -Version 7.0
# Windows counterpart to scripts/tests/build_test.sh's coherence matrix (AC58).
# It deliberately covers only AC50-AC59 plus AC57: the older AC1-AC18 cases are
# already asserted on Linux, and AC58 scopes the Windows job to the mutations.
$ErrorActionPreference = 'Stop'

$RepoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$script:Failures = 0
function Add-Failure([string]$m) { Write-Host "FAIL: $m"; $script:Failures++ }
function Add-Pass([string]$m) { Write-Host "ok: $m" }

function New-FixtureRepo {
  $dir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'scripts') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'skills/shared/fr') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'skills/shared/en') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'skills/atelier-ventes/fr') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'skills/atelier-ventes/en') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'tests/atelier-ventes/fr') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'tests/atelier-ventes/en') | Out-Null
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'docs') | Out-Null

  Copy-Item (Join-Path $RepoRoot 'scripts/build.ps1') (Join-Path $dir 'scripts/build.ps1')
  Copy-Item (Join-Path $RepoRoot 'skills/shared/fr/*.md') (Join-Path $dir 'skills/shared/fr')
  Copy-Item (Join-Path $RepoRoot 'skills/shared/en/*.md') (Join-Path $dir 'skills/shared/en')

  # -NoNewline + explicit "`n": build.sh's fixtures are LF-only, and the
  # byte-for-byte pointer comparison must see the same bytes on both platforms.
  function Write-Lf([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, ($Text -replace "`r`n", "`n"))
  }

  Write-Lf (Join-Path $dir 'skills/names.tsv') "atelier-ventes`tatelier-ventes`tatelier-sales`n"

  $frPointer = (Get-Content -LiteralPath (Join-Path $RepoRoot 'skills/shared/fr/profile-pointer.md') -Raw).TrimEnd("`r", "`n")
  $enPointer = (Get-Content -LiteralPath (Join-Path $RepoRoot 'skills/shared/en/profile-pointer.md') -Raw).TrimEnd("`r", "`n")

  Write-Lf (Join-Path $dir 'skills/atelier-ventes/fr/SKILL.md') @"
---
name: atelier-ventes
description: À utiliser quand il est question de pipeline, de relance ou de proposition commerciale.
version: 0.1.0 # x-release-please-version
---

# Ventes

$frPointer
"@

  Write-Lf (Join-Path $dir 'skills/atelier-ventes/en/SKILL.md') @"
---
name: atelier-sales
description: Use when the conversation turns to pipeline, follow-ups, or proposals.
version: 0.1.0 # x-release-please-version
---

# Sales

$enPointer
"@

  Write-Lf (Join-Path $dir 'tests/atelier-ventes/fr/pipeline.md') @"
---
skill: atelier-ventes
locale: fr
triggers:
  - pipeline
---
## Prompt
Passe mon pipeline en revue.
"@

  Write-Lf (Join-Path $dir 'tests/atelier-ventes/en/pipeline.md') @"
---
skill: atelier-sales
locale: en
triggers:
  - pipeline
---
## Prompt
Review my pipeline.
"@

  Write-Lf (Join-Path $dir 'version.txt') "0.1.0`n"

  Write-Lf (Join-Path $dir '.release-please-manifest.json') @"
{
  ".": "0.1.0"
}
"@

  Write-Lf (Join-Path $dir 'release-please-config.json') @"
{
  "include-v-in-tag": true,
  "packages": {
    ".": {
      "release-type": "simple",
      "changelog-path": "CHANGELOG.md",
      "bump-minor-pre-major": true,
      "bump-patch-for-minor-pre-major": false,
      "extra-files": [
        { "type": "generic", "path": "README.md" },
        { "type": "generic", "path": "skills/atelier-ventes/fr/SKILL.md" },
        { "type": "generic", "path": "skills/atelier-ventes/en/SKILL.md" }
      ]
    }
  }
}
"@

  Write-Lf (Join-Path $dir 'README.md') @"
# Fixture

Version 0.1.0 <!-- x-release-please-version -->

Version 0.1.0 <!-- x-release-please-version -->
"@

  Write-Lf (Join-Path $dir 'docs/WHATS-NEW.md') @"
# Quoi de neuf / What's new

## v0.1.0

**Français** — Première version.

**English** — First release.
"@

  return $dir
}

# Run -Check inside a fixture and capture exit status plus combined output.
function Invoke-FixtureCheck([string]$Dir) {
  $out = & pwsh -NoProfile -Command "Set-Location -LiteralPath '$Dir'; ./scripts/build.ps1 -Check" 2>&1 | Out-String
  return [pscustomobject]@{ ExitCode = $LASTEXITCODE; Output = $out }
}

function Expect-CheckFail([string]$Dir, [string]$Needle, [string]$Label) {
  $r = Invoke-FixtureCheck $Dir
  if ($r.ExitCode -ne 0 -and $r.Output.Contains($Needle)) { Add-Pass $Label }
  else { Add-Failure "$Label (exit=$($r.ExitCode), out=$($r.Output))" }
}

function Edit-File([string]$Path, [scriptblock]$Transform) {
  $text = [System.IO.File]::ReadAllText($Path)
  [System.IO.File]::WriteAllText($Path, (& $Transform $text))
}

# --- AC50: a version line without the annotation
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/fr/SKILL.md') {
  param($t) $t -replace 'version: 0\.1\.0 # x-release-please-version', 'version: 0.1.0' }
Expect-CheckFail $d 'skills/atelier-ventes/fr/SKILL.md' 'AC50 rejects a version line without the annotation'
Remove-Item -Recurse -Force $d

# --- AC50: two version: lines
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/SKILL.md') {
  param($t) $t -replace 'version: 0\.1\.0 # x-release-please-version',
    "version: 0.1.0 # x-release-please-version`nversion: 0.1.0 # x-release-please-version" }
Expect-CheckFail $d 'skills/atelier-ventes/en/SKILL.md' 'AC50 rejects two version: lines'
Remove-Item -Recurse -Force $d

# --- AC50: no version: line
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/fr/SKILL.md') {
  param($t) $t -replace "version: 0\.1\.0 # x-release-please-version`n", '' }
Expect-CheckFail $d 'skills/atelier-ventes/fr/SKILL.md' 'AC50 rejects a missing version: line'
Remove-Item -Recurse -Force $d

# --- AC50: a malformed SemVer on the annotated line
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/SKILL.md') {
  param($t) $t -replace 'version: 0\.1\.0 #', 'version: 0.1 #' }
Expect-CheckFail $d 'skills/atelier-ventes/en/SKILL.md' 'AC50 rejects a malformed SemVer'
Remove-Item -Recurse -Force $d

# --- AC51: mismatched skill versions, both values reported
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/SKILL.md') {
  param($t) $t -replace 'version: 0\.1\.0 #', 'version: 0.2.0 #' }
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -ne 0 -and $r.Output.Contains('0.2.0') -and $r.Output.Contains('0.1.0')) {
  Add-Pass 'AC51 rejects mismatched skill versions and reports both values'
} else { Add-Failure "AC51 mismatched versions (exit=$($r.ExitCode), out=$($r.Output))" }
Remove-Item -Recurse -Force $d

# --- AC51: version.txt disagreeing with the skills
$d = New-FixtureRepo
[System.IO.File]::WriteAllText((Join-Path $d 'version.txt'), "0.3.0`n")
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -ne 0 -and $r.Output.Contains('0.3.0') -and $r.Output.Contains('0.1.0')) {
  Add-Pass 'AC51 rejects a version.txt disagreeing with the skills'
} else { Add-Failure "AC51 version.txt disagreement (exit=$($r.ExitCode), out=$($r.Output))" }
Remove-Item -Recurse -Force $d

# --- AC52: a SKILL.md absent from extra-files
$d = New-FixtureRepo
Edit-File (Join-Path $d 'release-please-config.json') {
  param($t) $t -replace ',\s*\{ "type": "generic", "path": "skills/atelier-ventes/en/SKILL\.md" \}', '' }
Expect-CheckFail $d 'skills/atelier-ventes/en/SKILL.md' 'AC52 rejects a SKILL.md absent from extra-files'
Remove-Item -Recurse -Force $d

# --- AC52: an extra-files entry that is not type generic
$d = New-FixtureRepo
Edit-File (Join-Path $d 'release-please-config.json') {
  param($t) $t -replace '\{ "type": "generic", "path": "skills/atelier-ventes/fr/SKILL\.md" \}',
    '{ "type": "json", "path": "skills/atelier-ventes/fr/SKILL.md" }' }
Expect-CheckFail $d 'skills/atelier-ventes/fr/SKILL.md' 'AC52 rejects an entry that is not type generic'
Remove-Item -Recurse -Force $d

# --- AC59: README with only one annotation
$d = New-FixtureRepo
Edit-File (Join-Path $d 'README.md') {
  param($t) ($t -replace 'Version 0\.1\.0 <!-- x-release-please-version -->', 'Version 0.1.0', 1) }
Expect-CheckFail $d 'README.md' 'AC59 rejects a README with one annotation'
Remove-Item -Recurse -Force $d

# --- AC59: an annotated README line disagreeing with version.txt
$d = New-FixtureRepo
Edit-File (Join-Path $d 'README.md') {
  param($t) ($t -replace 'Version 0\.1\.0 <!-- x-release-please-version -->',
    'Version 0.9.9 <!-- x-release-please-version -->', 1) }
Expect-CheckFail $d 'README.md' 'AC59 rejects an annotated README line off version'
Remove-Item -Recurse -Force $d

# --- AC59: extra-files with no README.md entry
$d = New-FixtureRepo
Edit-File (Join-Path $d 'release-please-config.json') {
  param($t) $t -replace '\{ "type": "generic", "path": "README\.md" \},\s*', '' }
Expect-CheckFail $d 'README.md' 'AC59 rejects extra-files with no README.md entry'
Remove-Item -Recurse -Force $d

# --- AC53: a heading with an empty section
$d = New-FixtureRepo
[System.IO.File]::WriteAllText((Join-Path $d 'docs/WHATS-NEW.md'),
  "# Quoi de neuf / What's new`n`n## v0.1.0`n`n## v0.0.9`n`n**Français** — Ancienne.`n`n**English** — Old.`n")
Expect-CheckFail $d 'docs/WHATS-NEW.md' 'AC53 rejects a heading with an empty section'
Remove-Item -Recurse -Force $d

# --- AC53: a section missing the English half
$d = New-FixtureRepo
[System.IO.File]::WriteAllText((Join-Path $d 'docs/WHATS-NEW.md'),
  "# Quoi de neuf / What's new`n`n## v0.1.0`n`n**Français** — Première version.`n")
Expect-CheckFail $d 'docs/WHATS-NEW.md' 'AC53 rejects a section with no English half'
Remove-Item -Recurse -Force $d

# --- AC53: a label with no prose after it
$d = New-FixtureRepo
[System.IO.File]::WriteAllText((Join-Path $d 'docs/WHATS-NEW.md'),
  "# Quoi de neuf / What's new`n`n## v0.1.0`n`n**Français** — Première version.`n`n**English**`n")
Expect-CheckFail $d 'docs/WHATS-NEW.md' 'AC53 rejects a label with no prose'
Remove-Item -Recurse -Force $d

# --- AC53: no heading for version.txt's version
$d = New-FixtureRepo
Edit-File (Join-Path $d 'docs/WHATS-NEW.md') { param($t) $t -replace '## v0\.1\.0', '## v0.0.9' }
Expect-CheckFail $d 'docs/WHATS-NEW.md' 'AC53 rejects a WHATS-NEW with no heading for the version'
Remove-Item -Recurse -Force $d

# --- AC54: each required file, missing then empty
foreach ($target in @('version.txt', 'release-please-config.json',
                      '.release-please-manifest.json', 'docs/WHATS-NEW.md', 'README.md')) {
  $d = New-FixtureRepo
  Remove-Item -Force (Join-Path $d $target)
  Expect-CheckFail $d $target "AC54 rejects a missing $target"
  Remove-Item -Recurse -Force $d

  $d = New-FixtureRepo
  [System.IO.File]::WriteAllText((Join-Path $d $target), '')
  Expect-CheckFail $d $target "AC54 rejects an empty $target"
  Remove-Item -Recurse -Force $d
}

# --- AC54: a two-line version.txt
$d = New-FixtureRepo
[System.IO.File]::WriteAllText((Join-Path $d 'version.txt'), "0.1.0`n0.1.0`n")
Expect-CheckFail $d 'version.txt' 'AC54 rejects a two-line version.txt'
Remove-Item -Recurse -Force $d

# --- AC54: a non-SemVer version.txt
$d = New-FixtureRepo
[System.IO.File]::WriteAllText((Join-Path $d 'version.txt'), "v0.1.0`n")
Expect-CheckFail $d 'version.txt' 'AC54 rejects a non-SemVer version.txt'
Remove-Item -Recurse -Force $d

# --- AC54: an unparseable release-please-config.json
$d = New-FixtureRepo
[System.IO.File]::WriteAllText((Join-Path $d 'release-please-config.json'),
  "{ `"packages`": { `".`": { `"extra-files`": [ }`n")
Expect-CheckFail $d 'release-please-config.json' 'AC54 rejects an unparseable config'
Remove-Item -Recurse -Force $d

# --- AC54: an unparseable .release-please-manifest.json
$d = New-FixtureRepo
[System.IO.File]::WriteAllText((Join-Path $d '.release-please-manifest.json'), "{ `".`": `"0.1.0`"`n")
Expect-CheckFail $d '.release-please-manifest.json' 'AC54 rejects an unparseable manifest'
Remove-Item -Recurse -Force $d

# --- AC55: the clean fixture passes with the exact PASS line
$d = New-FixtureRepo
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0 -and ($r.Output -split "`r?`n") -contains 'STATUS: PASS (mechanical checks)') {
  Add-Pass 'AC55 clean fixture passes with the exact PASS line'
} else { Add-Failure "AC55 clean fixture (exit=$($r.ExitCode), out=$($r.Output))" }
Remove-Item -Recurse -Force $d

# --- AC57: -Lang all strips the annotation from every packaged SKILL.md
$d = New-FixtureRepo
& pwsh -NoProfile -Command "Set-Location -LiteralPath '$d'; ./scripts/build.ps1 -Lang all" | Out-Null
Add-Type -AssemblyName System.IO.Compression.FileSystem
$bad = $false
foreach ($zip in Get-ChildItem (Join-Path $d 'dist') -Filter *.zip) {
  $archive = [System.IO.Compression.ZipFile]::OpenRead($zip.FullName)
  try {
    foreach ($entry in $archive.Entries) {
      $reader = New-Object System.IO.StreamReader($entry.Open())
      try { $text = $reader.ReadToEnd() } finally { $reader.Dispose() }
      if ($text.Contains('x-release-please-version')) {
        Add-Failure "AC57 $($zip.Name)/$($entry.FullName) still contains x-release-please-version"
        $bad = $true
      }
      if ($entry.FullName -ceq 'SKILL.md' -and -not ($text -match '(?m)^version: 0\.1\.0$')) {
        Add-Failure "AC57 $($zip.Name) SKILL.md version line is not 'version: 0.1.0'"
        $bad = $true
      }
    }
  } finally { $archive.Dispose() }
}
if (-not $bad) { Add-Pass 'AC57 packaged archives carry a clean version line and no annotation' }
Remove-Item -Recurse -Force $d

Write-Host ''
if ($script:Failures -eq 0) { Write-Host 'STATUS: PASS'; exit 0 }
Write-Host "STATUS: FAIL ($script:Failures)"
exit 1
```

- [ ] **Step 2: Run the PowerShell tests to verify they fail**

```bash
pwsh -NoProfile -File scripts/tests/build_test.ps1
```

Expected: `STATUS: FAIL (N)`. If `pwsh` is not installed locally, note it and
rely on the Windows CI job wired in Step 6 — but state that plainly in the task
notes rather than claiming the step passed.

- [ ] **Step 3: Implement the coherence check in `scripts/build.ps1`**

Insert immediately before `function Invoke-Checks`:

```powershell
# AC53 — docs/WHATS-NEW.md must carry a `## v<version>` heading whose section
# holds both bilingual labels, each followed by prose. Mirrors build.sh's
# check_whats_new, including its "punctuation is not prose" rule.
function Test-WhatsNew {
  param([string]$Version)
  $rel = 'docs/WHATS-NEW.md'
  $lines = Get-Content -LiteralPath (Join-Path $RepoRoot $rel)
  $section = @()
  $inside = $false
  $found = $false
  foreach ($line in $lines) {
    if ($line -ceq "## v$Version") { $inside = $true; $found = $true; continue }
    if ($inside -and $line.StartsWith('## ')) { $inside = $false }
    if ($inside) { $section += $line }
  }
  if (-not $found) {
    Add-CheckFailure "${rel}: no '## v$Version' heading for the version in version.txt"
    return
  }
  foreach ($label in @('**Français**', '**English**')) {
    $at = -1
    for ($i = 0; $i -lt $section.Count; $i++) {
      if ($section[$i].Contains($label)) { $at = $i; break }
    }
    if ($at -lt 0) {
      Add-CheckFailure "${rel}: the v$Version section has no $label label"
      return
    }
    $rest = $section[$at].Substring($section[$at].IndexOf($label) + $label.Length)
    if ($rest -match '\w') { continue }
    $ok = $false
    for ($i = $at + 1; $i -lt $section.Count; $i++) {
      if ($section[$i].Contains('**Français**') -or $section[$i].Contains('**English**')) { break }
      if ($section[$i] -match '\w') { $ok = $true; break }
    }
    if (-not $ok) {
      Add-CheckFailure "${rel}: the $label label in the v$Version section is followed by no prose"
      return
    }
  }
}

# AC50-AC54, AC59 — version coherence. PowerShell parses JSON natively, so
# this is the short twin of build.sh's hand-rolled scanner (AC56 is
# bash-specific for exactly that reason).
function Test-VersionCoherence {
  foreach ($f in @('version.txt', 'release-please-config.json',
                   '.release-please-manifest.json', 'docs/WHATS-NEW.md', 'README.md')) {
    $p = Join-Path $RepoRoot $f
    if (-not (Test-Path -LiteralPath $p -PathType Leaf)) { Add-CheckFailure "${f}: missing"; return }
    if ((Get-Item -LiteralPath $p).Length -eq 0) { Add-CheckFailure "${f}: empty"; return }
  }

  # AC54 — exactly one SemVer line. -Raw + a manual split so a file with no
  # trailing newline and one with a single trailing newline both read as 1.
  $raw = [System.IO.File]::ReadAllText((Join-Path $RepoRoot 'version.txt'))
  $vlines = @($raw -split "`r?`n")
  if ($vlines.Count -gt 0 -and $vlines[-1] -eq '') { $vlines = $vlines[0..($vlines.Count - 2)] }
  if ($vlines.Count -ne 1 -or $vlines[0] -notmatch '^\d+\.\d+\.\d+$') {
    Add-CheckFailure "version.txt: expected exactly one SemVer line, found $($vlines.Count) line(s) starting '$($vlines[0])'"
    return
  }
  $version = $vlines[0]

  # AC54 — both JSON files must parse.
  $config = $null
  foreach ($f in @('release-please-config.json', '.release-please-manifest.json')) {
    try {
      $parsed = Get-Content -LiteralPath (Join-Path $RepoRoot $f) -Raw | ConvertFrom-Json
    } catch {
      Add-CheckFailure "${f}: is not well-formed JSON"
      return
    }
    if ($f -ceq 'release-please-config.json') { $config = $parsed }
  }

  # AC50 / AC51 — every SKILL.md declares the version once, annotated, on version.
  $skillMds = Get-ChildItem -LiteralPath $SkillsDir -Recurse -Depth 2 -Filter 'SKILL.md' -File |
    Sort-Object FullName
  foreach ($file in $skillMds) {
    $rel = ($file.FullName.Substring($RepoRoot.Length + 1)) -replace '\\', '/'
    $lines = Get-Content -LiteralPath $file.FullName
    $fm = @()
    if ($lines.Count -gt 0 -and $lines[0] -ceq '---') {
      for ($i = 1; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -ceq '---') { break }
        $fm += $lines[$i]
      }
    }
    $versionLines = @($fm | Where-Object { $_.StartsWith('version:') })
    if ($versionLines.Count -ne 1) {
      Add-CheckFailure "${rel}: frontmatter has $($versionLines.Count) 'version:' lines, expected exactly 1"
      continue
    }
    if ($versionLines[0] -cnotmatch '^version: (\d+\.\d+\.\d+) # x-release-please-version$') {
      Add-CheckFailure "${rel}: version line '$($versionLines[0])' must read 'version: <semver> # x-release-please-version'"
      continue
    }
    $declared = $Matches[1]
    if ($declared -cne $version) {
      Add-CheckFailure "${rel}: declares version $declared but version.txt says $version"
    }
  }

  # AC52 / AC59 — the extra-files roster.
  $entries = @()
  if ($config.packages -and $config.packages.'.' -and $config.packages.'.'.'extra-files') {
    $entries = @($config.packages.'.'.'extra-files')
  }
  $wanted = @($skillMds | ForEach-Object {
    ($_.FullName.Substring($RepoRoot.Length + 1)) -replace '\\', '/'
  }) + @('README.md')
  foreach ($rel in $wanted) {
    $matching = @($entries | Where-Object { $_.path -ceq $rel })
    if ($matching.Count -ne 1) {
      Add-CheckFailure "release-please-config.json: extra-files must list $rel exactly once, found $($matching.Count)"
      continue
    }
    if ($matching[0].type -cne 'generic') {
      Add-CheckFailure "release-please-config.json: the extra-files entry for $rel is not type 'generic'"
    }
  }

  # AC59 — README.md carries exactly two annotated lines, each on version.
  $annotated = @(Get-Content -LiteralPath (Join-Path $RepoRoot 'README.md') |
    Where-Object { $_.Contains('x-release-please-version') })
  if ($annotated.Count -ne 2) {
    Add-CheckFailure "README.md: expected exactly 2 x-release-please-version annotations, found $($annotated.Count)"
  }
  foreach ($line in $annotated) {
    $m = [regex]::Match($line, '\d+\.\d+\.\d+')
    if (-not $m.Success -or $m.Value -cne $version) {
      $declared = if ($m.Success) { $m.Value } else { '' }
      Add-CheckFailure "README.md: annotated line declares '$declared' but version.txt says $version"
    }
  }

  Test-WhatsNew -Version $version
}
```

- [ ] **Step 4: Call it from `Invoke-Checks`**

In `Invoke-Checks`, insert as the first statement of the function body, before
`foreach ($locale in $Locales)`:

```powershell
  # Repo-wide, not per-locale: run it once.
  Test-VersionCoherence
```

- [ ] **Step 5: Strip the annotation in `New-SkillStage`**

In `New-SkillStage`, insert after the two canonical-reference `Copy-Item` calls
and before `return $name`:

```powershell
  # AC57 — the annotation is a release-please marker, not skill metadata.
  # Strip it so the packaged SKILL.md carries a clean `version: X.Y.Z`.
  # ReadAllText/WriteAllText, not Get-Content/Set-Content: the latter would
  # rewrite every line ending as CRLF and change the archive's bytes.
  $stagedMd = Join-Path $Stage 'SKILL.md'
  $text = [System.IO.File]::ReadAllText($stagedMd)
  $text = [regex]::Replace($text, '(?m)^(version: \d+\.\d+\.\d+) # x-release-please-version[ \t]*$', '$1')
  [System.IO.File]::WriteAllText($stagedMd, $text)
```

- [ ] **Step 6: Wire the Windows tests into CI**

In `.github/workflows/ci.yml`, in the `checks-windows` job, insert a step
immediately after `- uses: actions/checkout@v4`:

```yaml
      - name: Build-script tests on Windows
        shell: pwsh
        # AC58: the Windows job runs the same coherence mutation matrix through
        # build.ps1, not only the coherent real repository.
        run: ./scripts/tests/build_test.ps1
```

- [ ] **Step 7: Add the command to `CLAUDE.md`**

In the `## Commands` list, after the `bash scripts/tests/build_test.sh` line:

```markdown
- `pwsh -File scripts/tests/build_test.ps1` — build-script tests, PowerShell twin
```

- [ ] **Step 8: Run the tests to verify they pass**

```bash
pwsh -NoProfile -File scripts/tests/build_test.ps1
pwsh -NoProfile -Command './scripts/build.ps1 -Check'
```

Expected: `STATUS: PASS` and `STATUS: PASS (mechanical checks)`. If `pwsh` is
unavailable locally, say so and defer the verdict to CI.

- [ ] **Step 9: Run the pre-commit gate**

```bash
bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && \
  bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS (mechanical checks)` and `STATUS: PASS` from each suite.

- [ ] **Step 10: Commit**

```bash
git add scripts/build.ps1 scripts/tests/build_test.ps1 .github/workflows/ci.yml CLAUDE.md
git commit -m "build: bring the coherence check and the strip to Windows

build.ps1 gains Test-VersionCoherence and the packaging strip, and a new
build_test.ps1 runs the same mutation matrix through PowerShell rather than
only checking the coherent real repository (AC58). PowerShell parses JSON
natively, so it needs none of build.sh's hand-rolled scanner."
```

---

### Task 6: The release-please workflow

**Files:**
- Create: `.github/workflows/release-please.yml`

**Interfaces:**
- Consumes: `release-please-config.json`, `.release-please-manifest.json`, `version.txt` from Task 3; `bash scripts/build.sh --lang all` from the existing build script.
- Produces: job id `release-please` exposing the outputs `release_created` and `tag_name`, consumed by the `publish` and `back-merge` jobs.

- [ ] **Step 1: Create the workflow**

```yaml
name: Release Please

on:
  push:
    branches: [main]

# Declared at workflow level so the release-please job holds both (AC49); the
# publish job narrows itself below.
permissions:
  contents: write
  pull-requests: write

jobs:
  release-please:
    runs-on: ubuntu-latest
    outputs:
      release_created: ${{ steps.release.outputs.release_created }}
      tag_name: ${{ steps.release.outputs.tag_name }}
    steps:
      # Not GITHUB_TOKEN: events triggered by GITHUB_TOKEN start no new
      # workflow run, which would suppress the release PR's pull_request event
      # and leave it with no completed checks — so AC53's forcing function
      # (CI red until a human writes the bilingual docs/WHATS-NEW.md entry)
      # could never fire. Neither `owner` nor `repositories` is passed, so the
      # minted token stays scoped to this repository alone.
      - name: Mint a GitHub App token
        id: app-token
        uses: actions/create-github-app-token@v2
        with:
          app-id: ${{ secrets.RELEASE_PLEASE_APP_ID }}
          private-key: ${{ secrets.RELEASE_PLEASE_APP_PRIVATE_KEY }}

      - name: Run release-please
        id: release
        uses: googleapis/release-please-action@v4
        with:
          token: ${{ steps.app-token.outputs.token }}
          config-file: release-please-config.json
          manifest-file: .release-please-manifest.json
          # Pinned, not defaulted: the action otherwise targets the repository
          # default branch, which is `dev`. Unpinned, release-please would
          # compute releases from `dev` and tag there — on the branch that is
          # explicitly not the release branch.
          target-branch: main
          # DO NOT add `release-type:` here. Passing it forces non-manifest
          # mode, which rediscovers the last release by correlating tags
          # against a bounded window of recent commits; a large merge pushes
          # the last release outside that window and release-please resets the
          # version to 1.0.0. The release type lives in
          # release-please-config.json instead.

  publish:
    needs: release-please
    if: ${{ needs.release-please.outputs.release_created == 'true' }}
    runs-on: ubuntu-latest
    # Narrower than the workflow default: this job only uploads assets to an
    # existing release, and it triggers nothing, so it keeps GITHUB_TOKEN.
    permissions:
      contents: write
    # AC2's 1024-char cap is measured with bash's ${#var}, which counts
    # characters only under a UTF-8-aware LC_CTYPE. Under the runner's default
    # LC_ALL=C it would count bytes instead, over-counting every accented
    # French description.
    env:
      LANG: C.UTF-8
      LC_ALL: C.UTF-8
    steps:
      - uses: actions/checkout@v4

      - name: Build every locale
        run: bash scripts/build.sh --lang all

      - name: Attach the fourteen ZIPs and WHATS-NEW.md to the release
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          TAG: ${{ needs.release-please.outputs.tag_name }}
        run: |
          set -euo pipefail
          # Filenames stay unversioned so that
          # releases/latest/download/<name>-<locale>.zip — already published in
          # both install guides — keeps resolving across releases.
          count="$(ls -1 dist/*.zip | wc -l)"
          if [[ "$count" -ne 14 ]]; then
            echo "expected 14 ZIPs in dist/, found $count" >&2
            exit 1
          fi
          gh release upload "$TAG" dist/*.zip docs/WHATS-NEW.md --clobber

  back-merge:
    needs: release-please
    if: ${{ needs.release-please.outputs.release_created == 'true' }}
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - name: Mint a GitHub App token
        id: app-token
        uses: actions/create-github-app-token@v2
        with:
          app-id: ${{ secrets.RELEASE_PLEASE_APP_ID }}
          private-key: ${{ secrets.RELEASE_PLEASE_APP_PRIVATE_KEY }}

      - uses: actions/checkout@v4

      # Merging the release PR rewrites eighteen version-bearing files on main
      # while dev still declares the old version in every one of them. Without
      # this, every promotion PR conflicts on all eighteen, forever.
      #
      # A PR rather than a direct push: the merge is visible, ci.yml runs
      # against dev's would-be state before it lands, and idempotency is one
      # query ("is a main → dev PR already open?") rather than a guess.
      - name: Open the back-merge pull request (main → dev)
        env:
          GH_TOKEN: ${{ steps.app-token.outputs.token }}
          TAG: ${{ needs.release-please.outputs.tag_name }}
        run: |
          set -euo pipefail
          open_count="$(gh pr list --base dev --head main --state open --json number --jq 'length')"
          if [[ "$open_count" -gt 0 ]]; then
            echo "A main → dev pull request is already open; nothing to do."
            exit 0
          fi
          gh pr create --base dev --head main \
            --title "chore: back-merge $TAG into dev" \
            --body "Carries the release bumps and the regenerated CHANGELOG.md from \`main\` back into \`dev\`, so the next promotion PR stays conflict-free. Merge this after each release — see ADR-0010."
```

- [ ] **Step 2: Verify the workflow against AC49, AC61, AC62, AC71**

```bash
grep -n 'googleapis/release-please-action@v4' .github/workflows/release-please.yml
grep -n 'release-type' .github/workflows/release-please.yml || echo "no release-type input (correct)"
grep -n 'target-branch: main' .github/workflows/release-please.yml
grep -n 'branches: \[main\]' .github/workflows/release-please.yml
grep -rhoE 'secrets\.[A-Z_]+' .github/ | sort -u
```

Expected: the action pinned at `@v4`; `no release-type input (correct)`;
`target-branch: main` present; the push trigger scoped to `main`; and the
secrets set exactly:

```
secrets.GITHUB_TOKEN
secrets.RELEASE_PLEASE_APP_ID
secrets.RELEASE_PLEASE_APP_PRIVATE_KEY
```

- [ ] **Step 3: Verify the YAML parses**

```bash
python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/release-please.yml')); print('yaml ok')"
```

Expected: `yaml ok`. (`python3` is a convenience for local validation only —
nothing in `build.sh` depends on it.)

- [ ] **Step 4: Run the pre-commit gate**

```bash
bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && \
  bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS (mechanical checks)` and `STATUS: PASS` from each suite.

- [ ] **Step 5: Commit**

```bash
git add .github/workflows/release-please.yml
git commit -m "ci: add the release-please workflow

Three jobs on push to main: release-please under a per-run GitHub App token
so the release PR receives CI, an asset-publishing job under GITHUB_TOKEN
that attaches the fourteen unversioned ZIPs plus docs/WHATS-NEW.md, and a
back-merge job that opens main → dev so promotion PRs stay conflict-free."
```

---

### Task 7: ADRs, the agent index, and the AC2 refinement note

**Files:**
- Create: `docs/adr/0009-release-automation-and-changelog-split.md`
- Create: `docs/adr/0010-dev-default-main-release-branch.md`
- Modify: `CLAUDE.md`
- Modify: `docs/superpowers/specs/2026-07-21-atelier-design.md:521-524`

**Interfaces:**
- Consumes: every decision recorded in Tasks 2–6.
- Produces: no code interface.

- [ ] **Step 1: Create `docs/adr/0009-release-automation-and-changelog-split.md`**

```markdown
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
```

- [ ] **Step 2: Create `docs/adr/0010-dev-default-main-release-branch.md`**

```markdown
# 0010 — `dev` is the default branch, `main` carries releases

**Status:** Accepted — 2026-07-22

## Context

release-please computes a release from the history of one branch. Pointing it
at the branch that also receives every feature merge means every merge is a
candidate release, and the repository's default branch is also its release
branch. The alternative is a dedicated release branch, and a deliberate act
that moves work onto it.

This repo already had a `main` with GitHub's suggested default ruleset applied
on 2026-07-21 — `deletion`, `non_fast_forward` and `required_signatures` —
targeting `~DEFAULT_BRANCH` rather than a named branch.

## Decision

`dev` is the repository's default branch: every feature branch cuts from it and
every PR lands on it. `main` holds releases only. Work reaches `main` through a
**promotion PR** — a deliberate "cut a release" act, distinct from merging a
feature. This mirrors `traction-app`, which runs the same model.

**The promotion PR must be merged as a merge commit, never squashed.**
release-please reads `main`'s history to compute the bump and every changelog
entry, so the individual Conventional Commits have to survive the promotion. A
squash collapses them into one non-conventional message
(`Merge pull request #N from Heyian/dev`); release-please then finds nothing
releasable and silently opens no release PR. The failure announces itself only
as an absence. Mechanical enforcement is deferred to issue #13.

**`target-branch: main` is pinned in the workflow.** The action otherwise
defaults to the repository's default branch — which is now `dev`. Unpinned,
release-please would compute releases from `dev` and tag there, putting tags on
the branch that is explicitly not the release branch. The pin is load-bearing,
not defensive. See [ADR-0009](0009-release-automation-and-changelog-split.md).

**`main` flows back into `dev` automatically.** Merging the release PR rewrites
eighteen files on `main` — `version.txt`, the manifest, the fourteen `SKILL.md`,
`README.md` and a regenerated `CHANGELOG.md` — while `dev` still declares the
old version in every one. `--check` stays green on `dev`: the tree is internally
coherent, just stale. But the next promotion PR then conflicts on all eighteen,
and does so at every release, forever. So a back-merge job opens a
`main` → `dev` PR whenever a release was created. It is a PR rather than a
direct push so the merge is visible, runs `ci.yml` against `dev`'s would-be
state before landing, and is trivially idempotent — "is a `main` → `dev` PR
already open?" is one query, where "has this merge already been pushed?" is not.

**`required_signatures` is dropped from both branches.** release-please's
commits are unsigned; this is observable in `traction-app`, where a merged
release PR left `4dab3af2 [N] chore(main): release 3.2.1` in the history —
`[N]` being git's code for *no signature*. GitHub's own merge and squash
commits are signed; release-please's are not.

GitHub's rule for a branch requiring signatures is that you cannot squash-merge
a pull request into it unless you are the author. Under the App, the release
PR's author is `atelier-release-please[bot]`, so a human merging it is not the
author: squash is refused, and a merge commit is refused too because it would
introduce unsigned commits. The back-merge PR fails the same way regardless of
credential, since it carries those unsigned commits from `main` into `dev`.

The rule and the automation cannot both stand. Keeping the rule would mean
granting the App a bypass — and because ruleset bypass is per-*ruleset* rather
than per-rule, that means splitting each branch's rules across two rulesets so
the App does not also bypass deletion, non-fast-forward and the required status
checks. Four rulesets to buy "every commit is signed, unless the release bot
wrote it". A bypassed rule is worse than an absent one: it still reads as a
guarantee. The rule is dropped instead.

This is a claim about a *version*: `googleapis/release-please-action` is pinned
to `@v4` partly for that reason. Should a later release-please gain commit
signing, the argument stops applying and the decision is worth reopening.

The ruleset that carried `~DEFAULT_BRANCH` is retargeted to name
`refs/heads/main` and `refs/heads/dev` explicitly — the flip would otherwise
have carried its rules onto `dev` and left `main` bare — and a second ruleset
adds `required_status_checks` (`checks-linux`, `checks-windows`) on `main`,
with `strict_required_status_checks_policy` **false**: strict mode would demand
the release PR be rebased onto `main` after every intervening merge, for no gain
on a branch whose only inbound PRs are promotions and releases.

## Consequences

- `main` sits permanently behind `dev` between releases. That reads as neglect
  and is not — it is the whole point of a release branch.
- The promotion PR's merge method is load-bearing for reasons nothing in its
  diff explains. Until #13 lands, the only thing standing between a squash and
  a silently missing release is this document and `CLAUDE.md`.
- The back-merge PR has to actually be merged. Left open, the next promotion PR
  conflicts on the eighteen version-bearing files — which is also how you find
  out you forgot.
- Every hand-written commit in this repo is still signed by local git config;
  what is gone is the *enforcement*, on the one rule this repo's own automation
  cannot satisfy. No other protection is touched: `deletion`,
  `non_fast_forward` and `required_status_checks` are all indifferent to who
  authored a commit.
- The default branch is the base of every clone's HEAD and every PR's default
  base. Anyone with an older clone will need `git remote set-head origin -a`.
```

- [ ] **Step 3: Update `CLAUDE.md`**

Insert a `## Branches and commits` section between `## Commands` and
`## Layout`, and add the spec pointer under the existing design-spec line.
Index-sized entries only — the reasoning lives in the ADRs.

```markdown
# Atelier — Development Notes

Skill pack for non-technical executives on Claude Cowork/Desktop.
Design spec: docs/superpowers/specs/2026-07-21-atelier-design.md
Release automation: docs/superpowers/specs/2026-07-22-release-please-design.md
```

```markdown
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
```

- [ ] **Step 4: Note the AC2 refinement in the original spec**

In `docs/superpowers/specs/2026-07-21-atelier-design.md`, replace the AC2 bullet
(lines 521–524) with:

```markdown
- **AC2** — Every built ZIP's SKILL.md has valid frontmatter: `name`
  (letters/numbers/hyphens only) and `description` present, ≤1024
  characters combined, and a version. *Refined by AC50 in
  `docs/superpowers/specs/2026-07-22-release-please-design.md`: in the source
  tree the version line must additionally carry the
  ` # x-release-please-version` annotation, which `stage_skill` strips at
  packaging time — so the version inside the ZIP is unchanged.*
```

- [ ] **Step 5: Verify AC67 and AC70**

```bash
for f in docs/adr/0009-release-automation-and-changelog-split.md \
         docs/adr/0010-dev-default-main-release-branch.md; do
  echo "--- $f"
  grep -cE '^## (Context|Decision|Consequences)$' "$f"
done
grep -c '0010-dev-default-main-release-branch' docs/adr/0009-release-automation-and-changelog-split.md
grep -c 'required_signatures' docs/adr/0010-dev-default-main-release-branch.md
grep -oE '`(atelier|mentor|boussole|forge|marketing|ventes|reunions|build|ci|docs|install|shared)`' CLAUDE.md | sort -u | wc -l
grep -c 'merge commit, never squashed' CLAUDE.md
grep -c 'x-release-please-version' docs/superpowers/specs/2026-07-21-atelier-design.md
```

Expected: `3` for each ADR; `1` for the cross-reference; at least `1` for
`required_signatures`; `12` distinct scopes in `CLAUDE.md`; `1` for the
merge-commit sentence; `1` for the AC2 note.

- [ ] **Step 6: Run the pre-commit gate**

```bash
bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && \
  bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS (mechanical checks)` and `STATUS: PASS` from each suite.

- [ ] **Step 7: Commit**

```bash
git add docs/adr/0009-release-automation-and-changelog-split.md \
  docs/adr/0010-dev-default-main-release-branch.md CLAUDE.md \
  docs/superpowers/specs/2026-07-21-atelier-design.md
git commit -m "docs: record the release automation and branch model as ADRs

ADR-0009 covers annotate-and-strip, the changelog split, the GitHub App
credential and the same-workflow publish job. ADR-0010 covers the dev/main
split, the merge-commit promotion, the back-merge, and why
required_signatures had to go. CLAUDE.md gains index-sized pointers and the
commit convention."
```

---

### Task 8: Verify every required task actually landed

Read the diff. Do not trust the checkboxes above.

**Files:** none (verification only, no commit).

- [ ] **Step 1: Read the whole branch diff**

```bash
git diff --stat origin/dev...HEAD
git diff origin/dev...HEAD
```

- [ ] **Step 2: Confirm every file in the spec's Config & Infrastructure Impact table**

```bash
for f in release-please-config.json .release-please-manifest.json version.txt \
         .github/workflows/release-please.yml .github/workflows/ci.yml \
         scripts/build.sh scripts/build.ps1 scripts/tests/build_test.sh; do
  [[ -f "$f" ]] && echo "present: $f" || echo "MISSING: $f"
done
[[ -f .github/workflows/release.yml ]] && echo "STILL PRESENT (bad): release.yml" || echo "deleted: release.yml"
grep -c 'dist/' .gitignore
```

Expected: `present:` for all eight; `deleted: release.yml`; `1` from `.gitignore`
(no change was required there).

- [ ] **Step 3: Confirm every file in the spec's Documentation Updates table**

```bash
for f in docs/WHATS-NEW.md CHANGELOG.md docs/INSTALL.en.md docs/INSTALL.fr.md \
         CLAUDE.md docs/adr/0009-release-automation-and-changelog-split.md \
         docs/adr/0010-dev-default-main-release-branch.md \
         docs/superpowers/specs/2026-07-21-atelier-design.md; do
  [[ -f "$f" ]] && echo "present: $f" || echo "MISSING: $f"
done
git diff --name-only origin/dev...HEAD
```

Expected: `present:` for all eight, and every one of them appearing in the
changed-file list except where the spec required no edit.

- [ ] **Step 4: Re-run the fixture-independent criteria**

```bash
# AC60
[[ -f .github/workflows/release.yml ]] && echo "AC60 FAIL" || echo "AC60 ok: release.yml gone"
grep -c -- --release-version scripts/tests/build_test.sh; echo "(0 expected)"
bash scripts/build.sh --help | grep -c -- --release-version; echo "(0 expected)"

# AC66
grep -c '"type": "generic"' release-please-config.json; echo "(15 expected)"
grep -c '"hidden": true' release-please-config.json; echo "(7 expected)"

# AC71
grep -rhoE 'secrets\.[A-Z_]+' .github/ | sort -u

# AC67
grep -c '\*\*Français\*\*' CHANGELOG.md; echo "(0 expected)"

# AC65
grep -c 'WHATS-NEW.md' docs/INSTALL.en.md docs/INSTALL.fr.md
grep -c 'CHANGELOG' docs/INSTALL.en.md docs/INSTALL.fr.md; echo "(0 expected)"
```

- [ ] **Step 5: Note any gap and fix it inside the task it belongs to**

Do not open a new commit stream for a fix — amend or add a commit scoped to the
task whose deliverable was incomplete, then re-run the pre-commit gate.

---

### Task 9: Final build

Non-negotiable. Type-checks and unit tests do not catch build-time failures.

**Files:** none (produces `dist/`, which is gitignored).

- [ ] **Step 1: Build every locale from a clean `dist/`**

```bash
rm -rf dist && bash scripts/build.sh --lang all
ls -1 dist/*.zip | wc -l
```

Expected: `built <name>-<locale>.zip` fourteen times, then `14`.

- [ ] **Step 2: Verify AC57 against the real archives**

```bash
rc=0
for z in dist/*.zip; do
  x="$(mktemp -d)"
  unzip -q "$z" -d "$x"
  if grep -rqF 'x-release-please-version' "$x"; then
    echo "FAIL: $z still contains the annotation"; rc=1
  fi
  line="$(grep '^version:' "$x/SKILL.md")"
  if [[ "$line" != "version: 0.1.0" ]]; then
    echo "FAIL: $z version line is '$line'"; rc=1
  fi
  rm -rf "$x"
done
[[ "$rc" -eq 0 ]] && echo "AC57 ok: 14 archives clean"
```

Expected: `AC57 ok: 14 archives clean`.

- [ ] **Step 3: Verify AC62's asset roster**

```bash
ls -1 dist/*.zip | xargs -n1 basename | sort
```

Expected, exactly these fourteen, none carrying a version segment:

```
atelier-boussole-fr.zip
atelier-compass-en.zip
atelier-en.zip
atelier-forge-en.zip
atelier-forge-fr.zip
atelier-fr.zip
atelier-marketing-en.zip
atelier-marketing-fr.zip
atelier-meetings-en.zip
atelier-mentor-en.zip
atelier-mentor-fr.zip
atelier-reunions-fr.zip
atelier-sales-en.zip
atelier-ventes-fr.zip
```

- [ ] **Step 4: Run the full gate one last time**

```bash
bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && \
  bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS (mechanical checks)` and `STATUS: PASS` from each suite.

- [ ] **Step 5: Optional cross-model review, then finish the branch**

If a cross-model review helper is available (e.g. the Codex plugin's
adversarial review), run it with focus:

> Judge correctness against the spec's acceptance criteria (AC49–AC71,
> including AC63a, AC63b, AC69a and AC69b) only. Do not flag anything outside
> the stated criteria — no design alternatives, hardening, or scope the spec
> did not claim.

This never gates the merge. The gate stays `bash scripts/build.sh --check` plus
the three suites, and `bash scripts/build.sh --lang all`.

Then wrap up via `superpowers:finishing-a-development-branch`: push
`feat/release-please` and open a PR into `dev`. This is bootstrap step 3 — the
first real use of the workflow this branch defines — so both `checks-linux` and
`checks-windows` must pass on the PR before merging.

---

### Task 10: Bootstrap steps 4 and 5 — tag, release, promote (after the branch merges)

**Not part of the implementation branch.** Run this only after Task 9's PR has
merged into `dev` and v1 is ready to ship. It produces no commit on this branch.

**The tag must precede the first promotion.** release-please computes from the
last release tag. With no tag anywhere, the moment `release-please.yml` first
lands on `main` it would read every v1 commit as unreleased and open a premature
`v0.2.0` release PR. Tagging `v0.1.0` on `dev`'s tip first makes that commit an
ancestor of `main` once the promotion merges, so release-please sees `v0.1.0`
reachable, the manifest at `0.1.0`, and nothing releasable since — and correctly
opens nothing.

- [ ] **Step 1: Build and tag on `dev`'s tip**

```bash
git checkout dev && git pull --ff-only
rm -rf dist && bash scripts/build.sh --lang all
git tag -a v0.1.0 -m "v0.1.0"
git push origin v0.1.0
```

- [ ] **Step 2: Publish the release with the fourteen ZIPs and WHATS-NEW.md**

```bash
gh release create v0.1.0 --title v0.1.0 --generate-notes \
  dist/*.zip docs/WHATS-NEW.md
```

- [ ] **Step 3: Verify AC63**

```bash
git ls-remote --tags origin refs/tags/v0.1.0
gh release view v0.1.0 --json isDraft,isPrerelease,assets \
  --jq '{draft: .isDraft, pre: .isPrerelease, assets: [.assets[].name] | sort}'
gh api repos/Heyian/atelier/contents/version.txt?ref=main --jq '.content' | base64 -d
gh api repos/Heyian/atelier/contents/.release-please-manifest.json?ref=main --jq '.content' \
  | base64 -d | jq -e '. == {".": "0.1.0"}' && echo "manifest ok"
curl -sSIL -o /dev/null -w '%{http_code}\n' \
  https://github.com/Heyian/atelier/releases/latest/download/atelier-en.zip
```

Expected: the tag ref exists; `draft: false`, `pre: false`, and an asset list of
exactly the fourteen ZIP names plus `WHATS-NEW.md`; `0.1.0` from `version.txt`;
`manifest ok`; `200`.

(`version.txt` and the manifest on `main` are only readable after Step 4's
promotion merges — run those two commands again after Step 4 if they 404 here.)

- [ ] **Step 4: Open the promotion PR and merge it as a merge commit**

```bash
gh pr create --base main --head dev \
  --title "chore: promote dev to main for v0.1.0" \
  --body "First promotion. Merge as a merge commit, never squash — release-please reads the individual Conventional Commits off main. See ADR-0010."
```

Wait for `checks-linux` and `checks-windows` to pass, then merge **with a merge
commit**:

```bash
gh pr merge --merge <pr-number>
```

Never `--squash`. A squash collapses the history release-please reads.

- [ ] **Step 5: Verify AC63a — the promotion was a merge commit and the tag preceded it**

```bash
git fetch origin
main_tip="$(git rev-parse origin/main)"
git rev-list --parents -n 1 "$main_tip"
second_parent="$(git rev-parse "$main_tip^2")"
tagged="$(git rev-parse v0.1.0^{commit})"
[[ "$second_parent" == "$tagged" ]] && echo "AC63a ok" || echo "AC63a FAIL: $second_parent != $tagged"
```

Expected: the `rev-list --parents` line shows exactly three hashes (commit +
two parents), and `AC63a ok`.

- [ ] **Step 6: Verify AC63b — the first release-please run was healthy and opened nothing**

```bash
gh run list --workflow release-please.yml --branch main --limit 1 \
  --json databaseId,conclusion,headSha
gh run view <run-id> --log | grep -E 'prs_created|release_created'
```

Expected: `conclusion: success`; `release_created` false and `prs_created`
empty. A run that failed, was cancelled, or never started does **not** satisfy
this criterion — absence of a release PR must be the outcome of a healthy run.

- [ ] **Step 7: Record how AC68's idempotency will be checked at the first release**

The back-merge job only runs when `release_created == 'true'`, so it cannot be
exercised until the first real release. When that release lands and the
`main` → `dev` pull request is open, re-run **the back-merge job alone** — a
whole-workflow re-run, or any run in which the job is skipped, does not satisfy
AC68:

```bash
gh run list --workflow release-please.yml --branch main --limit 1 --json databaseId
gh run view <run-id> --json jobs --jq '.jobs[] | {name, databaseId}'
gh run rerun <run-id> --job <back-merge-job-id>
# then, once it finishes:
gh pr list --base dev --head main --state open --json number --jq 'length'
```

Expected: the re-run job concludes `success` (it exits zero on the
already-open path), and the open `main` → `dev` count is still `1`.

- [ ] **Step 8: Record how AC69a will be checked at the next release**

The first release PR release-please opens is produced by the *next* feature
merged into `dev` and promoted. When it appears:

```bash
gh pr list --base main --state open --json number,author \
  --jq '.[] | {number, author: .author.login}'
gh pr checks <pr-number>
```

Expected: the author is the `atelier-release-please` App's bot account (not a
human), and both `checks-linux` and `checks-windows` report a conclusion of
`success` or `failure`. `skipped`, `cancelled`, `neutral` and a still-pending
check each fail AC69a — only a check that reached a verdict proves it ran.

If `checks-windows` is red because `docs/WHATS-NEW.md` has no entry for the new
version, that is AC53's forcing function working. Commit the bilingual entry to
the `release-please--branches--main` branch, then merge.

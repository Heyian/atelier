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

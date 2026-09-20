# 0015 — Staleness policy for dated claims

**Status:** Accepted — 2026-09-19

## Context

[ADR-0011](0011-dated-capability-claims-in-shipped-references.md) lets dated
capability claims ship in reference files, on condition that each carries a
last-verified date and a named source. Its own Consequences section records
that the resulting re-verification obligation "has no owner in automation
yet." Nineteen annotations ship today, across six files under
`skills/atelier-mentor/{en,fr}/references/tutorial/`, every one of them dated
2026-08-10, and nothing in the repository knows that any of them are aging.

## Decision

### The annotation grammar is the machine-readable contract

An annotation is a blockquote directly under the claim it dates:

```
> **Last verified YYYY-MM-DD** — source: <text>
```

under `/en/`, and

```
> **Vérifié le YYYY-MM-DD** — source : <text>
```

under `/fr/`. The dash is an em dash (U+2014) with a single space either
side; French keeps the space before the colon its typography requires,
English does not.

Detection is looser than validation: any `> **` line carrying either
locale's marker is detected, and once detected must satisfy its own locale's
exact pattern. A typo in the date or the dash therefore makes the check fail
loudly, at the offending file and line, rather than silently dropping the
line from the count.

### Two tiers, with named thresholds

`REPORT_AGE_DAYS=180` prints a NOTE on `--check`; `FAIL_AGE_DAYS=365` fails
the separate `--check-freshness` gate. The year comes from issue #18's own
framing — worth having "before the first claim goes a year unchecked" — with
a nudge at the halfway mark so a claim does not go from fine to overdue with
no warning in between. Thirty days, which ADR-0011's "capabilities shift
monthly" language would literally imply as a threshold, would fire on every
run from day one and train everyone to ignore it.

### Age never reddens a pull request

`--check` reports the oldest claim's age on every run and never fails on age
alone. Only the scheduled `--check-freshness` job, run monthly by
`.github/workflows/dated-claims.yml`, fails once a claim is at least a year
old, and that job files one label-guarded `stale-claims` issue rather than
blocking a build.

## Alternatives considered

- **Hard-failing in `--check` on age** — the `check_whats_new` shape issue
  #18 names as precedent. Rejected: `check_whats_new` fires on a *change* a
  contributor made in that pull request, and that contributor can fix it in
  the same pull request. Age fires on the calendar. It would redden a pull
  request whose author touched nothing related to the stale claim and cannot
  fix it there, which trains reviewers to merge through red rather than
  chase down an unrelated annotation.
- **A separate machine-readable marker** alongside the prose, such as
  `<!-- verified: 2026-08-10 -->`. Rejected: it puts the same date in two
  places that can drift apart — precisely the failure
  `check_reference_pointer_drift` exists to catch elsewhere in this repo.
  The prose annotation itself is already machine-readable; a second copy
  would only add a second thing to keep in sync.

This is an ADR rather than a build-script comment because it clears the
three-criteria gate. **Hard to reverse:** the annotation grammar becomes a
contract six shipped files must satisfy today, and every future
capability-sensitive module after them. **Surprising without context:** a
future reader will find a check that deliberately refuses to fail on the
thing it checks for, and the reason is a property of how pull requests get
reviewed in this repo, not of the annotations themselves. **A real
trade-off:** hard-failing in `--check` on age was a live option, and the
alternative above states exactly why it lost.

## Consequences

- The annotation grammar is now load-bearing for six shipped files and every
  module added after them. Loosening the grammar later is easy; tightening
  it once authors have grown used to a looser form is not.
- `skills/dated-claims.tsv` is the mechanically decidable stand-in for
  ADR-0011's real rule. No script can decide whether a given sentence is
  capability-sensitive — that judgment stays with the author — but a script
  can notice that a module already known to be full of such claims has ended
  up with none, which catches a translation pass or a bad merge that drops
  the last annotation.
- ADR-0011's re-verification obligation now has an owner in automation:
  `--check` surfaces age on every run, and `--check-freshness` enforces the
  year-old ceiling on a schedule. Whether a given date is still *correct* —
  as opposed to merely present and not too old — stays a human judgment;
  nothing here claims otherwise.

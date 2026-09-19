# Stale dated claims — a build check that reports age without reddening a PR

**Issue:** #18
**Status:** Design approved 2026-09-19
**Builds on:** ADR-0011 (dated capability claims in shipped reference files),
PR #20 / `docs/superpowers/specs/2026-08-10-mentor-tutorial-design.md` (the
claims themselves), `check_whats_new` in `scripts/build.sh` (the forcing-function
pattern this one deliberately diverges from).

## Problem

`atelier-mentor`'s tutorial ships nineteen capability-sensitive claims — which
surfaces run plugins, which reach local folders, which plan an organizing
feature is on, Claude's own French interface labels. ADR-0011 lets them ship on
one condition: each carries a last-verified date and a named source in the same
file, and mentor shows the executive that date rather than restating the claim
as a current promise.

Every one of them is dated 2026-08-10. Nothing in the repository knows that.
A claim verified in August 2026 will read exactly as authoritative in 2027
unless a human happens to look, and ADR-0011's own Consequences section says so:
the re-verification obligation "has no owner in automation yet."

Two facts about the current state shaped this design.

**The annotation is not what issue #18 describes.** The issue says the shipped
form is an italic run-in, `_Vérifié le YYYY-MM-DD — <source>._`. It is not. What
shipped in PR #20 is a blockquote with a bold lead-in, spanning several lines:

```
> **Last verified 2026-08-10** — source: Anthropic help center, article 15520349
> ("Use Claude Cowork on web, desktop, and mobile"). Capabilities shift month
> to month: show the executive this date, and offer to re-verify against
> `references/sources.md` before they build anything on it.
```

French is the same shape with `**Vérifié le 2026-08-10** — source : …`, carrying
the space before the colon that French typography requires.

**Where the claims are.** Nineteen annotations, all dated 2026-08-10, all in the
mentor tutorial and nowhere else in the repository:

| File | Annotations |
|---|---|
| `skills/atelier-mentor/en/references/tutorial/03-surfaces.md` | 2 |
| `skills/atelier-mentor/en/references/tutorial/04-skills-connectors-plugins.md` | 3 |
| `skills/atelier-mentor/en/references/tutorial/05-organizing-features.md` | 4 |
| `skills/atelier-mentor/fr/references/tutorial/03-surfaces.md` | 2 |
| `skills/atelier-mentor/fr/references/tutorial/04-competences-connecteurs-plugiciels.md` | 4 |
| `skills/atelier-mentor/fr/references/tutorial/05-fonctions-organisation.md` | 4 |

The locale counts differ legitimately: French carries one extra annotation
covering the French interface labels (help-centre article 12512180), which has
no English counterpart. Nothing here may demand locale parity.

### Why this is not shaped like `check_whats_new`

Issue #18 names `check_whats_new` as the precedent, and for the failure *style*
it is the right one — a mechanical check that lands CI red so a human writes the
update. But it fires on a **change**: `version.txt` moved in this pull request
and `docs/WHATS-NEW.md` did not, so the person who can fix it is the person
looking at the failure.

A staleness threshold fires on the **calendar**. On the day the claims cross the
line, the next person to open an unrelated pull request — a typo fix in the
sales skill — gets a red build for something they did not touch, and fixing it
properly means reading Anthropic help-centre articles and rewriting module
prose. The predictable response is to bump the dates without re-verifying, which
leaves the repository in a worse state than having no check at all: nineteen
claims now carrying dates that assert a verification nobody performed.

So this design separates two things #18 treats as one. **Structural correctness
of an annotation** is caused by an edit, so it behaves like every other check in
`build.sh` and fails the build. **Age** is caused by time passing, so it is
reported, and escalates only in a scheduled job that no pull request waits on.

## Decision

### 1. The annotation contract

Two patterns, one per locale. Which applies is decided by the `/en/` or `/fr/`
segment in the file's path, the way `check_shared_text` and
`check_reference_pointer_drift` already decide.

```
en:  > **Last verified YYYY-MM-DD** — source: <at least one non-space character>
fr:  > **Vérifié le YYYY-MM-DD** — source : <at least one non-space character>
```

The dash is an em dash (U+2014) with a single space either side, exactly as
shipped. Everything after that first line — the continuation lines carrying the
article title and the "show the executive this date" instruction — is free prose
the check does not read.

**Detection is deliberately looser than validation.** If the strict pattern were
also the detector, a typo in a date would make the line invisible and the check
would quietly report one fewer annotation rather than failing. So the scan first
looks for a line beginning `> **` that contains either `Last verified` or
`Vérifié le` — *either* marker, regardless of the file's locale — and every line
that trips that marker must then satisfy its own locale's full pattern or it is
a failure.

Detecting locale-agnostically is what buys the cross-locale catch for free: an
English lead-in left in a French module during a translation pass trips the
marker, then fails validation because French was expected at that path. In a
repository maintaining nineteen annotations in two languages, that is the most
likely defect there is.

The alternative considered and rejected was a separate machine-readable marker
alongside the prose — `<!-- verified: 2026-08-10 -->`. It makes parsing trivial
and leaves the exec-facing wording free, but it puts the same date in two places
that can drift, which is precisely the failure `check_reference_pointer_drift`
exists to catch elsewhere in this repository.

### 2. What fails `--check`

Eight cases, each reported through the existing `check_fail`, each naming the
offending file and — where a line is involved — its line number:

1. The detected marker is the other locale's, given the file's path.
2. The marker is present but no `YYYY-MM-DD` follows it inside the bold span.
3. The date is shaped right but is not a real day (`2026-02-30`, `2026-13-01`,
   `2025-02-29`).
4. The date is later than the day the check runs.
5. The `— source:` / `— source :` segment is absent, or has nothing after it.
6. A file listed in `skills/dated-claims.tsv` carries zero detected annotations.
7. `skills/dated-claims.tsv` names a path that does not exist.
8. `skills/dated-claims.tsv` itself does not exist. A repository must not be
   able to opt out of case 6 by deleting the list, so an absent anchor file is
   fatal the way an absent `skills/names.tsv` already is.

Case 4 is the single wall-clock dependency in an otherwise change-triggered
check, and it is intentional rather than an oversight. A future date is a typo —
someone wrote 2027 where they meant 2026 — and it stays a failure until that
date arrives, which for such a typo is a year away. It is recorded here so a
future reader does not "fix" it.

### 3. One scanner, two consumers

A single function walks every `*.md` under `skills/<skill>/<locale>/references/`
at any depth, and for each detected marker emits one record: path, line number,
locale, date, verdict token. The form validator reads those records and calls
`check_fail` for anything not `ok`. The age reporter reads the same records and
does arithmetic on the dates.

Parsing is therefore written once and both entry points test against the same
fixture. The scan runs repo-wide and once, called from `run_checks` next to
`check_version_coherence` rather than inside the per-skill, per-locale loop —
the scanner finds its own files, so looping it per skill would scan everything
fourteen times.

Scope is every skill's references, not just the tutorial's. Nothing in either
script knows what a tutorial module is. The day a dated claim is added to
`atelier-boussole`, it is already covered.

### 4. What `--check` prints

Every run that reaches a `STATUS:` line — passing or failing — prints exactly
one summary line before it, regardless of age:

```
dated claims: 19 annotations across 6 files, oldest 2026-08-10 (40 days)
```

The failure mode that most threatens this check is not a stale date — it is the
pattern quietly ceasing to match after someone rewords a module, at which point
every tier goes silent and the whole mechanism is dead without a single red
mark. A line that always states how many annotations were found makes that
visible on the next pull request, and gives a reviewer a count to sanity-check
against a diff that adds or removes a claim. That is also why the line prints on
a failing run and why it has an explicit zero form — `dated claims: 0
annotations across 0 files, no dated claim found` — since the run where every
annotation stopped matching is precisely the one worth seeing it on.

Once the oldest annotation reaches `REPORT_AGE_DAYS`, a second line is printed
and the exit status is still 0:

```
NOTE: oldest dated claim is 184 days old (report threshold 180) —
      skills/atelier-mentor/fr/references/tutorial/03-surfaces.md:26
      see docs/tutorial-corpus.md, "Claims to re-verify"
```

### 5. `--check-freshness`

A separate entry point that neither stages a skill nor writes to `dist/`. It
runs the same scan and the same form validation, then applies the second tier:
past `FAIL_AGE_DAYS`, it prints every annotation at or over `REPORT_AGE_DAYS`
with file, line, date and age, and exits non-zero. Otherwise it exits 0.

It carries the form validation deliberately. If the pattern stopped matching,
this job is the last thing that would notice, and it must fail rather than
report a cheerful zero.

Both thresholds are named constants at the top of each script —
`REPORT_AGE_DAYS=180`, `FAIL_AGE_DAYS=365` — so tests and acceptance criteria
cite them by name and never by literal. The numbers come from the issue's own
framing: it says the check is worth having "before the first claim goes a year
unchecked," so a year is the hard line, with a nudge at the halfway mark.
Thirty days, which ADR-0011's "capabilities shift monthly" language would
literally imply, would be firing permanently and would train everyone to ignore
it.

Age is whole days between the annotation's date and the run date, computed by a
day-number conversion in awk. Not `date -d`, which is GNU-only and would break
for a contributor on macOS. PowerShell uses `[datetime]::ParseExact` and
`(Get-Date).Date`, which needs no equivalent workaround.

### 6. `skills/dated-claims.tsv`

A new data file beside `skills/names.tsv`, read identically by both scripts.
One repo-relative path per line, six lines today — the three tutorial modules in
each locale. Any file named there must carry at least one valid annotation, and
any path named there must exist.

This is the weaker, mechanically decidable version of ADR-0011's real rule. No
script can decide whether a given sentence is capability-sensitive, but it can
notice that a module known to be full of such claims has ended up with none —
a bad merge, a translation that dropped the blockquote, an edit that removed the
last one. Without it, deleting every annotation from module 04 passes every
check in the repository, green.

The list lives in a file rather than as an array in each script because anything
written twice in two languages eventually says two different things. It is
single-column and still named `.tsv` for consistency with its neighbour. A
renamed module breaks it loudly — the check names a path that does not exist —
rather than silently.

### 7. `.github/workflows/dated-claims.yml`

Monthly on the first plus `workflow_dispatch`, `actions/checkout@v7` to match
`ci.yml`, permissions `contents: read` and `issues: write`.

It runs `bash scripts/build.sh --check-freshness`, capturing the output. On a
non-zero exit it asks `gh issue list --label stale-claims --state open` and
files an issue only when that comes back empty. The body is the check's own
output — files, dates, ages — plus a pointer to the `Claims to re-verify` index
in `docs/tutorial-corpus.md`.

Matching is on the **label**, never on issue title text, so a wording change
cannot produce a duplicate every month.

The job then exits 0 either way. Green means the job ran; the finding lives in
the issue. A workflow that stayed permanently red once it tripped would teach
everyone to ignore the Actions tab, which is the same failure this design
rejects for pull requests.

### 8. `docs/adr/0015-staleness-policy-for-dated-claims.md`

Checked against the three-criteria gate and it passes all three. **Hard to
reverse:** the annotation grammar becomes a contract six shipped files and every
future module must satisfy; loosening it later is easy, tightening it is not.
**Surprising without context:** distinctly — a future reader finds a check that
deliberately refuses to fail on the thing it checks for, which reads as a
half-finished implementation. **A real trade-off:** hard-failing in `--check`
was a live option, rejected for the specific reason given under *Why this is not
shaped like `check_whats_new`*.

The ADR records the annotation grammar as the machine-readable contract, the two
tiers, and the decision that age never reddens a pull request, naming the
rejected alternative and why. ADR-0011's Consequences gains a pointer line where
it currently says the obligation has no owner in automation — the way ADR-0008
was pointed at ADR-0014.

### 9. Citing acceptance criteria in the build scripts

`build.sh` annotates each check with the criterion it implements
(`# AC53 — docs/WHATS-NEW.md must carry a ## v<version> heading…`). That was
unambiguous when there was one spec. There are now six, each numbering from
`AC1`, and five of them define an `AC15`; the bare `AC15` already in `build.sh`
means the one from the 2026-07-21 atelier design, while the mentor tutorial's
`AC15` is the dated-claim rule this work implements. Issues #32 and #34 are two
more build checks queued behind this one, each arriving with its own `AC1`.

New comments therefore qualify the citation with the spec's date:
`# 2026-09-19/AC3 — …`. Existing bare citations stay as they are; this is the
convention new work adopts, not a backfill. It is recorded in `CLAUDE.md` so the
next spec inherits it rather than rediscovering the collision.

## Non-goals

- **Deciding whether a sentence is capability-sensitive.** ADR-0011's rule is
  "no capability-sensitive claim ships undated," and no script can enforce that
  directly. The anchor list is the weaker version that is mechanically
  decidable.
- **Checking `docs/tutorial-corpus.md`.** It is maintainer-facing, never ships,
  and describes itself as a living document still being restructured. Its
  `## Verified YYYY-MM-DD` heading can drift out of step with the modules'
  dates; that is filed as #36 rather than solved here.
- **Demanding locale parity in annotation counts.** French legitimately carries
  one annotation English does not.
- **Judging whether a date is *correct*.** As with `check_version_coherence` and
  the version number, nothing here verifies that the claim was actually
  re-verified on the date stated. It checks that a date is present, well formed,
  not in the future, and not old.
- **Re-verifying any claim.** The nineteen annotations keep their 2026-08-10
  dates through this work. Refreshing them is a separate act.

## Acceptance Criteria

### The annotation contract

- **AC1** — In a file whose path contains `/en/`, a valid annotation's first
  line is `> **Last verified YYYY-MM-DD** — source: ` followed by at least one
  non-whitespace character, with an em dash (U+2014) and single spaces exactly
  as written.
- **AC2** — In a file whose path contains `/fr/`, a valid annotation's first
  line is `> **Vérifié le YYYY-MM-DD** — source : ` followed by at least one
  non-whitespace character, including the space before the colon.
- **AC3** — A line is detected as an annotation when it begins `> **` and
  contains either `Last verified` or `Vérifié le`, regardless of the file's
  locale. Every detected line is validated against its own locale's pattern; a
  detected line that fails validation is a check failure, never a line the scan
  passes over.
- **AC3b** — Scan order is lexicographic by repo-relative path, then ascending
  by line number. Wherever a criterion below names "the oldest" annotation and
  several share that date, it means the first of them in scan order.

### Form failures

Each of AC4–AC10b fails `bash scripts/build.sh --check` with a non-zero exit
and names the offending path in its output; AC4–AC8 also name the line number.

- **AC4** — Given a detected annotation whose marker belongs to the other locale
  (an English marker under `/fr/`, or a French marker under `/en/`), When
  `--check` runs, Then it fails naming that file and line.
- **AC5** — Given a detected annotation with no `YYYY-MM-DD` inside its bold
  span — including a line whose bold span is never closed — When `--check` runs,
  Then it fails naming that file and line.
- **AC6** — Given a detected annotation whose date matches `YYYY-MM-DD` but is
  not a real calendar day (`2026-02-30`, `2026-13-01`, `2025-02-29`), When
  `--check` runs, Then it fails naming that file and line.
- **AC7** — Given a detected annotation whose date is later than the day the
  check runs, When `--check` runs, Then it fails naming that file and line.
- **AC8** — Given a detected annotation whose `— source:` / `— source :` segment
  is absent or is followed only by whitespace, When `--check` runs, Then it
  fails naming that file and line.
- **AC9** — Given a file listed in `skills/dated-claims.tsv` that contains no
  detected annotation, When `--check` runs, Then it fails naming that file.
- **AC10** — Given a path listed in `skills/dated-claims.tsv` that does not
  exist, When `--check` runs, Then it fails naming that path.
- **AC10b** — Given `skills/dated-claims.tsv` does not exist, When `--check`
  runs, Then it fails naming that path, the way a missing `skills/names.tsv`
  is already fatal. A repository cannot silently opt out of the anchor check by
  deleting the list.
- **AC11** — Given a repository whose annotations all satisfy AC1–AC3 and whose
  anchor list satisfies AC9–AC10, When `--check` runs and no other check fails,
  Then it exits 0 and prints `STATUS: PASS (mechanical checks)`.

### Scan scope

- **AC12** — The scan reads every `*.md` at any depth under
  `skills/<skill>/<locale>/references/`, for every skill in `skills/names.tsv`
  and both locales, and reads no file outside that set. `docs/tutorial-corpus.md`
  is not scanned.
- **AC13** — The scan executes once per `--check` invocation, not once per
  skill/locale pair.

### Reporting tiers

- **AC14** — `scripts/build.sh` and `scripts/build.ps1` each define two named
  constants for the thresholds, 180 and 365, using that language's own naming
  convention (`REPORT_AGE_DAYS` / `FAIL_AGE_DAYS` in bash,
  `$ReportAgeDays` / `$FailAgeDays` in PowerShell). Neither threshold value
  appears as a bare literal anywhere else in either script.
- **AC15** — Every `--check` run that reaches its status line, whether that
  line is `STATUS: PASS` or `STATUS: FAIL`, first prints exactly one summary
  line stating the count of valid annotations and the count of files carrying
  them.
- **AC15b** — Given at least one valid annotation exists, When `--check` runs,
  Then that summary line also states the oldest annotation's date and that
  date's age in whole days.
- **AC15c** — Given no valid annotation exists anywhere in the scan scope —
  every annotation removed, or every detected annotation failing AC4–AC8 —
  When `--check` runs, Then the summary line reports both counts as zero and
  states that no dated claim was found, in place of a date and an age. The
  line's presence and form is all this criterion governs; whether the run
  exits non-zero is decided by AC4–AC10 and AC10b alone.
- **AC16** — Given the oldest valid annotation is at least `REPORT_AGE_DAYS`
  old, When `--check` runs and no check fails, Then it additionally prints a
  note naming that annotation's file and line and pointing at
  `docs/tutorial-corpus.md`, and exits 0.
- **AC17** — Given the oldest valid annotation is younger than
  `REPORT_AGE_DAYS`, When `--check` runs, Then it prints no such note.
- **AC18** — Age is the whole number of days between an annotation's date and
  the date the check runs, computed without invoking `date -d`.

### `--check-freshness`

- **AC19** — `bash scripts/build.sh --check-freshness` runs the scan and the
  AC4–AC10b validation, stages no skill, and writes nothing to `dist/`.
- **AC20** — Given every annotation is valid and younger than `FAIL_AGE_DAYS`,
  When `--check-freshness` runs, Then it exits 0.
- **AC21** — Given at least one valid annotation is at least `FAIL_AGE_DAYS`
  old, When `--check-freshness` runs, Then it exits non-zero and prints, for
  every annotation at least `REPORT_AGE_DAYS` old, that annotation's file, line,
  date and age.
- **AC22** — Given any failure from AC4–AC10b, When `--check-freshness` runs,
  Then it exits non-zero regardless of every annotation's age.
- **AC23** — No `--check` or `-Check` run exits non-zero because of an
  annotation's age alone.

### PowerShell twin

- **AC24** — `./scripts/build.ps1 -Check` applies AC1–AC13 inclusive of AC3b
  and AC10b, and AC15–AC18 inclusive of AC15b and AC15c, producing the same failures, the same summary
  line in both its populated and its empty form, and naming the same paths as
  `--check`.
- **AC25** — `./scripts/build.ps1 -CheckFreshness` applies AC19–AC23.
- **AC26** — Neither script hard-codes an anchor path; both read
  `skills/dated-claims.tsv`.

### The anchor list

- **AC27** — `skills/dated-claims.tsv` exists, holds one repo-relative path per
  line, and lists the six mentor tutorial modules: `03`, `04` and `05` in each
  of `skills/atelier-mentor/en/references/tutorial/` and
  `skills/atelier-mentor/fr/references/tutorial/`.

### The scheduled workflow

- **AC28** — `.github/workflows/dated-claims.yml` triggers on a `schedule`
  whose cron runs on the first day of every month and on `workflow_dispatch`,
  checks out with `actions/checkout@v7`, and declares `contents: read` and
  `issues: write`.
- **AC29** — Given `--check-freshness` exits non-zero and no open issue carries
  the `stale-claims` label, When the job runs, Then it creates one issue
  labelled `stale-claims` whose body carries both the check's output and a
  pointer to the `Claims to re-verify` index in `docs/tutorial-corpus.md`.
- **AC30** — Given `--check-freshness` exits non-zero and an open issue already
  carries the `stale-claims` label, When the job runs, Then it creates no issue.
- **AC30b** — Given `--check-freshness` exits 0, When the job runs, Then it
  creates no issue, whether or not an open `stale-claims` issue exists, and it
  neither closes nor comments on an existing one.
- **AC31** — The job exits 0 whether or not it filed an issue.
- **AC32** — The open-issue lookup matches on the `stale-claims` label alone and
  never on issue title text.

### Tests

- **AC33** — `scripts/tests/build_test.sh` covers each of AC4–AC10b as its own
  fixture mutation, asserted through `expect_check_fail`, which requires both a
  non-zero exit and the offending path in the combined output.
- **AC34** — `scripts/tests/build_test.sh` additionally covers: a clean fixture
  passing and printing the AC15/AC15b summary line; a fixture with every
  annotation stripped from one anchored module, asserting the AC15c empty form
  of that line alongside the AC9 failure; a fixture whose oldest annotation
  is past `REPORT_AGE_DAYS` but under `FAIL_AGE_DAYS` exiting 0 and printing the
  AC16 note; `--check-freshness` exiting non-zero past `FAIL_AGE_DAYS` and 0
  under it.
- **AC35** — Every annotation date in an AC33–AC34 fixture is computed relative
  to the run date, never written as a literal, so no test's outcome changes as
  the calendar advances.
- **AC36** — `scripts/tests/build_test.ps1` covers AC4–AC10b through
  `Expect-CheckFail`.

### ADR and documentation

- **AC37** — `docs/adr/0015-staleness-policy-for-dated-claims.md` exists and
  records the annotation grammar, both thresholds, and the decision that age
  never fails `--check`, naming the rejected hard-fail alternative and the
  reason for rejecting it.
- **AC38** — `docs/adr/0011-dated-capability-claims-in-shipped-references.md`
  links to ADR-0015 at the point where it currently states the re-verification
  obligation has no owner in automation.
- **AC39** — `docs/AUTHORING.md` carries a `## Dated capability claims` section
  stating both locales' exact lead-in from AC1 and AC2.
- **AC40** — `scripts/tests/authoring_test.sh` requires the
  `## Dated capability claims` heading.
- **AC41** — `CLAUDE.md` lists `bash scripts/build.sh --check-freshness` under
  Commands and states the `YYYY-MM-DD/ACn` citation convention, and remains
  under 300 lines.
- **AC42** — Every comment added to `scripts/build.sh` or `scripts/build.ps1`
  by this work that cites an acceptance criterion writes it as
  `2026-09-19/ACn`.

### Scope guard

- **AC43** — This work's diff changes no annotation date in any shipped
  reference file: all nineteen annotations still read `2026-08-10` when it
  lands. Test fixtures, which AC35 requires to compute their dates relative to
  the run date, are not shipped reference files and are out of this criterion's
  scope.

## Deferred Items

- #36 — Corpus and module verification dates can drift apart after a
  re-verification pass

## Glossary Updates & ADRs

No glossary: this repository has no `CONTEXT.md`, so there are no terms to add.

- **ADR-0015 — Staleness policy for dated claims.** New. Created under the
  three-criteria gate as argued in *Decision §8*.
- **ADR-0011** — amended with a pointer to ADR-0015. Not superseded: its
  decision stands unchanged; only the "no owner in automation yet" consequence
  gains a successor.
- **No ADR conflicts surfaced.** ADR-0011 anticipated this work by name.

## Config & Infrastructure Impact

Scanned against every category. This repository has no containers, no IaC, no
environment config or secret store, no ORM schemas, and no API collections.

| File | Change |
|---|---|
| `.github/workflows/dated-claims.yml` | Create. Monthly schedule + `workflow_dispatch`, `actions/checkout@v7`, `contents: read` / `issues: write`, runs `--check-freshness`, files a label-guarded issue, exits 0. |
| `.github/workflows/ci.yml` | No change. `--check` and `-Check` already run on both runners; the form check rides inside them. |
| `skills/dated-claims.tsv` | Create. Six repo-relative paths. |
| `scripts/build.sh` | Add the scanner, the form validator, the age reporter, `--check-freshness` argument parsing, and the two threshold constants. |
| `scripts/build.ps1` | The same, as `-CheckFreshness` and `Test-DatedClaims`. |
| `scripts/tests/build_test.sh` | Add AC33–AC35 coverage. |
| `scripts/tests/build_test.ps1` | Add AC36 coverage. |
| `scripts/tests/authoring_test.sh` | Add the `## Dated capability claims` `require_heading` line. |
| `release-please-config.json` | No change. None of the new files carries a version annotation. |
| `CLAUDE.md` | Two lines: the new command, and the AC-citation convention. |

The `stale-claims` label was created on 2026-09-19, ahead of this spec, with the
user's explicit approval:
`gh label create stale-claims -R Heyian/atelier --color fbca04 --description "A shipped capability claim's last-verified date is past the freshness threshold"`.

## Manual Operator Steps

None — the one repository-level write this design needs, creating the
`stale-claims` label, is already done (see *Config & Infrastructure Impact*).

## Documentation Updates

| Doc | Change |
|---|---|
| `docs/adr/0015-staleness-policy-for-dated-claims.md` | Create, per AC37. |
| `docs/adr/0011-dated-capability-claims-in-shipped-references.md` | Add the ADR-0015 pointer, per AC38. |
| `docs/AUTHORING.md` | Add `## Dated capability claims`, per AC39. |
| `CLAUDE.md` | Add the `--check-freshness` command line and the citation convention, per AC41. Index only — the design stays in this spec. |
| `docs/tutorial-corpus.md` | No change. Out of scope per *Non-goals*; the drift is #36. |

## Implementation Plan Guidance

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
> 2. **Glossary application** — not applicable: this repository has no `CONTEXT.md` and the spec's "Glossary Updates & ADRs" section lists no terms.
> 3. **ADR creation** — FOR EACH ADR listed in the spec, add a task: *"Create `docs/adr/NNNN-<slug>.md` following sequential numbering (start at `0001-` if the directory is empty)."* IF the spec lists ADR conflicts surfaced, also add a task: *"Update the conflicting ADR's status (superseded / amended) and link to the new ADR."*
> 4. **Deferred-item verification** — Add a task: *"Confirm every issue referenced in the 'Deferred Items' section exists and has all four required body sections (Context, Required, Integration Points, Priority)."* Run `gh issue view <#> --json body | jq -r .body` and grep for the four headings.
> 5. **Config file tasks** — FOR EACH file listed in the spec's "Config & Infrastructure Impact" section, add one explicit task: *"Update `<path>`."*
> 6. **Manual Operator Steps** — not applicable: the spec's "Manual Operator Steps" section is empty.
> 7. **Docs update tasks** — FOR EACH entry in the spec's "Documentation Updates" section, add one explicit task: *"Update `<doc-path>`."* Design content goes in the docs dir, not the agent index; the index gets at most a 1-line pointer, a ≤3-sentence area summary, or a 1-line command/env-var entry.
> 8. **Post-implementation check** — Add as the second-to-last task: *"Verify every Required Task above was actually executed — config files updated, docs written, glossary entries applied, ADRs created."* Read the diff; don't trust plan markings.
> 9. **Final build task** — Add as the last task: *"Run `bash scripts/build.sh --lang all` and fix any issues until it builds successfully."* Non-negotiable — type-checks and tests alone do not catch all build-time failures.
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
> After the final build passes — and before wrapping up via `superpowers:finishing-a-development-branch` — if a cross-model review helper is available (e.g. the Codex plugin's adversarial review), run it with focus: *"Judge correctness against the spec's acceptance criteria (AC1–AC43, including AC3b, AC10b, AC15b, AC15c and AC30b) only. Do not flag anything outside the stated criteria — no design alternatives, hardening, or scope the spec did not claim."*
>
> This **never gates a merge** — the gate stays `bash scripts/build.sh --check` plus the three test scripts, and `bash scripts/build.sh --lang all`; the review only flags what deserves a second look. If no helper is available, finish the branch without it.

### Repo-specific notes for the plan author

- Commits follow Conventional Commits. The scope for this work is `build` for
  the scripts and tests, `ci` for the workflow, `docs` for the ADR and
  AUTHORING changes.
- `dev` is the default branch. This work lands on `dev`, never on `main`.
- Do not hand-edit `version.txt`, a `SKILL.md` version line, or the annotated
  `README.md` lines — release-please owns them.
- The PowerShell twin is run on Windows CI by `./scripts/build.ps1 -Check`;
  `-CheckFreshness` has no CI caller by design and exists for parity.

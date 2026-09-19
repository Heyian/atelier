# Stale Dated Claims Check — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Teach the build to notice that a shipped capability claim's last-verified date has gone stale, reporting its age on every `--check` run without ever reddening a pull request over age alone.

**Architecture:** One scanner walks every `*.md` under `skills/<skill>/<locale>/references/`, emits a TSV record per detected annotation, and two consumers read those records — a form validator that calls the existing `check_fail`, and an age reporter that prints one summary line before `STATUS:`. A second entry point, `--check-freshness`, runs the same scan and hard-fails past a year, driven by a monthly workflow that files a single label-guarded issue. `scripts/build.ps1` is a line-for-line twin.

**Tech Stack:** Bash + awk (no `jq`, no `date -d`), PowerShell 7, GitHub Actions, `gh` CLI.

**Spec:** `docs/superpowers/specs/2026-09-19-stale-dated-claims-check-design.md`

## Global Constraints

- **Branch:** this work lands on `dev`, never on `main`. The session is already isolated in the `stale-date-check` worktree — do not create another.
- **Commits:** Conventional Commits. Scope `build` for scripts and tests, `ci` for the workflow, `docs` for the ADR and AUTHORING changes. No AI-attribution trailer of any kind.
- **Never hand-edit** `version.txt`, a `SKILL.md` version line, or the two annotated `README.md` lines — release-please owns them.
- **No `jq`** anywhere in `scripts/build.sh`; AC56's existing test runs `--check` with `jq` off `PATH`.
- **No `date -d`** anywhere in the age arithmetic (AC18) — it is GNU-only and breaks for a contributor on macOS. Day-number conversion happens in awk.
- **Thresholds are named constants** (AC14): `REPORT_AGE_DAYS=180` / `FAIL_AGE_DAYS=365` in bash, `$ReportAgeDays` / `$FailAgeDays` in PowerShell. Neither `180` nor `365` may appear as a bare literal anywhere else in either script.
- **New AC citations in the scripts** are written `2026-09-19/ACn` (AC42). Existing bare `ACn` comments stay as they are — this is not a backfill.
- **The em dash is U+2014** with a single space either side. French carries a space before the colon (`source :`), English does not (`source:`).
- **The nineteen shipped annotations keep their `2026-08-10` dates** (AC43). Never "helpfully" refresh one to quiet a threshold.
- **Pre-commit gate (mandatory):** before EVERY `git commit`, run from the repo root:
  `bash scripts/build.sh --check && bash scripts/tests/shared_test.sh && bash scripts/tests/authoring_test.sh && bash scripts/tests/build_test.sh`
  Wait for all four to pass. Never `git commit --no-verify`.

## Review Focus

The spec says what the check must do; it does not enumerate everything the check will meet. These five inputs are the ones most likely to bite a real contributor, each with the behavior a reasonable person would expect. The test that pins each one is assigned to the task that owns the code.

1. **A fenced code block that quotes the annotation pattern.** AC39 puts the exact lead-in into `docs/AUTHORING.md`; the day someone mirrors that example into a skill's `references/` file, the scan must not read it as a real annotation and fail the build on a documentation example. Expected: lines inside a ``` fence are never detected. → Task 1, Step 10.
2. **CRLF line endings.** A Windows contributor's editor writes `\r\n`; the trailing `\r` sits after the source text and must not turn a valid annotation into `no-source`. Expected: identical verdict to the LF form. → Task 1, Step 12.
3. **A `/fr/` or `/en/` segment appearing twice in one path.** `skills/atelier-mentor/en/references/fr/notes.md` is legal on disk. Expected: the skill's own locale directory decides, not the last matching segment. → Task 1, Step 14.
4. **A blank or CRLF-terminated line in `skills/dated-claims.tsv`.** A trailing newline is normal in a text file and must not become an empty anchor path that fails with a blank name. Expected: blank lines are skipped, `\r` is stripped. → Task 2, Step 9.
5. **Dates exactly on a boundary.** An annotation dated today (age 0) must not read as future; one at exactly `REPORT_AGE_DAYS` must print the note, and one at exactly `FAIL_AGE_DAYS` must fail `--check-freshness` — `>=`, not `>`. → Task 3, Step 8 and Task 4, Step 1.

---

## Task 0: Confirm the isolated workspace

The spec's plan guidance asks for an isolated workspace as the first task **only if the session is not already isolated**. It is: this session runs in the git worktree `/home/mafavreau/DEV/.worktrees/c1d13197-0ffa-417f-8d66-4fea0e94e08e/few-saturn` on branch `stale-date-check`, cut from `dev`.

- [ ] **Step 1: Verify the branch, then proceed**

```bash
git rev-parse --show-toplevel
git branch --show-current
```

Expected: the worktree path above, and `stale-date-check`. If the branch is anything else — especially `dev` or `main` — stop and cut a branch from `dev` before continuing. Do not create a second worktree.

---

## Task 1: The scanner and the form validator

Walks every reference file once, emits one record per detected annotation, and turns every non-`ok` verdict into a `check_fail`. This is AC1–AC8, AC3b, AC12 and AC13. The anchor list is deliberately *not* here — Task 2 owns it.

**Files:**
- Modify: `scripts/build.sh` (add functions after `check_fail`, near line 203; call from `run_checks`, near line 554)
- Test: `scripts/tests/build_test.sh`

**Interfaces:**
- Consumes: `check_fail`, `list_skills`, `LOCALES`, `REPO_ROOT`, `SKILLS_DIR` — all already defined in `scripts/build.sh`.
- Produces:
  - `scan_dated_claims()` → prints TSV records to stdout, one per detected annotation: `rel_path <TAB> line_no <TAB> locale <TAB> date <TAB> verdict`. `date` is empty when no well-formed date was found. `verdict` is one of `ok`, `wrong-locale`, `bad-leadin`, `no-date`, `bad-date`, `future-date`, `no-source`.
  - `DATED_CLAIMS_RECORDS` — global holding that output, populated by `check_dated_claims`, read by Task 2's anchor check and Task 3's reporter.
  - `check_dated_claims()` → populates `DATED_CLAIMS_RECORDS` and calls `check_fail` per bad verdict.
  - `TODAY_YMD` — global, `date +%Y-%m-%d` (POSIX; the ban is on `date -d`, not on `date`).

- [ ] **Step 1: Write the failing test — a wrong-locale marker**

Add to `scripts/tests/build_test.sh`, just before the `AC55` block near line 540. This test needs the fixture to have a reference file, which `make_fixture_repo` does not yet create, so add the helper first:

```bash
# --- Dated-claim fixture helpers (2026-09-19 spec).
#
# AC35: every fixture date is computed from the run date, never written as a
# literal, so no test's outcome changes as the calendar advances. Both
# conversions are the civil algorithm in awk — `date -d` is GNU-only and the
# build script is forbidden from using it, so the tests do not either.
days_ago() {
  awk -v n="$1" -v today="$(date +%Y-%m-%d)" '
    function days_from_civil(y, m, d,   era, yoe, doy, doe) {
      if (m <= 2) y -= 1
      era = int((y >= 0 ? y : y - 399) / 400)
      yoe = y - era * 400
      doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
      doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
      return era * 146097 + doe - 719468
    }
    function civil_from_days(z,   era, doe, yoe, y, doy, mp, d, m) {
      z += 719468
      era = int((z >= 0 ? z : z - 146096) / 146097)
      doe = z - era * 146097
      yoe = int((doe - int(doe / 1460) + int(doe / 36524) - int(doe / 146096)) / 365)
      y = yoe + era * 400
      doy = doe - (365 * yoe + int(yoe / 4) - int(yoe / 100))
      mp = int((5 * doy + 2) / 153)
      d = doy - int((153 * mp + 2) / 5) + 1
      m = mp + (mp < 10 ? 3 : -9)
      if (m <= 2) y += 1
      return sprintf("%04d-%02d-%02d", y, m, d)
    }
    BEGIN {
      t = days_from_civil(substr(today,1,4)+0, substr(today,6,2)+0, substr(today,9,2)+0)
      print civil_from_days(t - n)
    }'
}

# Write one valid annotation of the given locale, dated n days ago, into a
# reference file inside the fixture.
write_annotation() {
  local dir="$1" locale="$2" rel="$3" days="$4" d
  d="$(days_ago "$days")"
  mkdir -p "$(dirname "$dir/$rel")"
  if [[ "$locale" == "en" ]]; then
    cat > "$dir/$rel" <<EOF
# Module

Prose above the annotation.

> **Last verified $d** — source: Anthropic help center, article 15520349
> ("Use Claude Cowork on web, desktop, and mobile"). Continuation prose the
> check never reads.

Prose below.
EOF
  else
    cat > "$dir/$rel" <<EOF
# Module

Prose au-dessus de l'annotation.

> **Vérifié le $d** — source : centre d'aide Anthropic, article 15520349
> (« Use Claude Cowork on web, desktop, and mobile »). Prose de continuation
> que la vérification ne lit jamais.

Prose en dessous.
EOF
  fi
}
```

Then the first real test:

```bash
# --- 2026-09-19/AC4: an English lead-in under /fr/ fails, naming file and line
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/fr/references/tutorial/03.md" 10
expect_check_fail "$d" "skills/atelier-ventes/fr/references/tutorial/03.md:5" \
  "2026-09-19/AC4 rejects an English lead-in under /fr/"
rm -rf "$d"
```

- [ ] **Step 2: Run it to make sure it fails**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep 'AC4 rejects an English'`
Expected: `FAIL: 2026-09-19/AC4 rejects an English lead-in under /fr/ (rc=0, out=…)` — `--check` currently exits 0 because nothing scans reference files yet.

- [ ] **Step 3: Add the scanner to `scripts/build.sh`**

Insert directly after the `check_fail` definition (line 203). The two awk helpers are the civil-calendar algorithm; they replace `date -d` per AC18.

```bash
# --- 2026-09-19/AC14 — the two staleness thresholds, named once. Nothing
# else in this script may write 180 or 365 as a bare literal.
REPORT_AGE_DAYS=180
FAIL_AGE_DAYS=365

DATED_CLAIMS_TSV="$SKILLS_DIR/dated-claims.tsv"
TODAY_YMD="$(date +%Y-%m-%d)"

# The day-number conversion every dated-claim awk shares. `date -d` is
# GNU-only and would break for a contributor on macOS (2026-09-19/AC18), so
# the civil algorithm is inlined into each awk program that needs it.
DATED_CLAIMS_AWK_LIB='
function days_from_civil(y, m, d,   era, yoe, doy, doe) {
  if (m <= 2) y -= 1
  era = int((y >= 0 ? y : y - 399) / 400)
  yoe = y - era * 400
  doy = int((153 * (m + (m > 2 ? -3 : 9)) + 2) / 5) + d - 1
  doe = yoe * 365 + int(yoe / 4) - int(yoe / 100) + doy
  return era * 146097 + doe - 719468
}
function ymd_to_days(s) {
  return days_from_civil(substr(s, 1, 4) + 0, substr(s, 6, 2) + 0, substr(s, 9, 2) + 0)
}
function real_calendar_day(y, m, d,   dim) {
  if (m < 1 || m > 12 || d < 1) return 0
  dim = 31
  if (m == 4 || m == 6 || m == 9 || m == 11) dim = 30
  else if (m == 2) dim = ((y % 4 == 0 && y % 100 != 0) || y % 400 == 0) ? 29 : 28
  return d <= dim
}
'

# --- 2026-09-19/AC12, AC13 — every *.md at any depth under
# skills/<skill>/<locale>/references/, for every skill in names.tsv and both
# locales, and nothing outside that set. Emitted in lexicographic path order
# (2026-09-19/AC3b); LC_ALL=C so the order does not depend on the locale the
# contributor happens to run under.
dated_claims_files() {
  local canonical locale dir
  for canonical in $(list_skills); do
    for locale in "${LOCALES[@]}"; do
      dir="$SKILLS_DIR/$canonical/$locale/references"
      [[ -d "$dir" ]] || continue
      find "$dir" -type f -name '*.md' -print
    done
  done | LC_ALL=C sort
}

# --- Scan one file, emitting one TSV record per detected annotation.
#
# Detection is deliberately looser than validation (Decision §1): a line
# beginning `> **` that carries EITHER locale's marker is detected, then must
# satisfy its own locale's full pattern. If the strict pattern were also the
# detector, a typo in a date would make the line invisible and the check would
# report one fewer annotation rather than failing.
scan_one_dated_claim_file() {
  local file="$1" rel locale lead sep own other
  rel="${file#"$REPO_ROOT"/}"

  # The locale is the segment directly under the skill directory, not just any
  # /en/ or /fr/ in the path — skills/x/en/references/fr/notes.md is legal and
  # is an English file.
  locale="$(awk -F/ '{ for (i = 1; i < NF; i++) if ($i == "skills") { print $(i + 2); exit } }' <<<"$rel")"
  case "$locale" in
    en) lead='> **Last verified '; sep='** — source: '; own='Last verified'; other='Vérifié le' ;;
    fr) lead='> **Vérifié le ';    sep='** — source : '; own='Vérifié le';   other='Last verified' ;;
    *) return 0 ;;
  esac

  awk -v rel="$rel" -v locale="$locale" -v lead="$lead" -v sep="$sep" \
      -v own="$own" -v other="$other" -v today="$TODAY_YMD" \
      "$DATED_CLAIMS_AWK_LIB"'
    BEGIN { todayDays = ymd_to_days(today) }
    {
      line = $0
      sub(/\r$/, "", line)          # a CRLF checkout must behave like an LF one

      # A fenced block quoting the pattern (docs/AUTHORING.md mirrors it) is
      # an example, not an annotation.
      if (substr(line, 1, 3) == "```") { fence = !fence; next }
      if (fence) next

      if (substr(line, 1, 4) != "> **") next
      hasOwn = index(line, own) > 0
      hasOther = index(line, other) > 0
      if (!hasOwn && !hasOther) next

      verdict = "ok"; date = ""
      if (!hasOwn) {
        verdict = "wrong-locale"
      } else if (substr(line, 1, length(lead)) != lead) {
        verdict = "bad-leadin"
      } else {
        rest = substr(line, length(lead) + 1)
        date = substr(rest, 1, 10)
        tail = substr(rest, 11)
        if (date !~ /^[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]$/) {
          verdict = "no-date"; date = ""
        } else if (!real_calendar_day(substr(date,1,4)+0, substr(date,6,2)+0, substr(date,9,2)+0)) {
          verdict = "bad-date"
        } else if (ymd_to_days(date) > todayDays) {
          verdict = "future-date"
        } else if (substr(tail, 1, length(sep)) != sep) {
          verdict = "no-source"
        } else {
          src = substr(tail, length(sep) + 1)
          gsub(/[ \t]/, "", src)
          if (src == "") verdict = "no-source"
        }
      }
      printf "%s\t%d\t%s\t%s\t%s\n", rel, FNR, locale, date, verdict
    }
  ' "$file"
}

scan_dated_claims() {
  local f
  while IFS= read -r f; do
    [[ -n "$f" ]] && scan_one_dated_claim_file "$f"
  done < <(dated_claims_files)
}

DATED_CLAIMS_RECORDS=""

# --- 2026-09-19/AC4–AC8 — every detected line that fails its locale's pattern
# is a check failure naming the file and line, never a line the scan passes
# over.
check_dated_claims() {
  DATED_CLAIMS_RECORDS="$(scan_dated_claims)"
  local rel line locale date verdict
  while IFS=$'\t' read -r rel line locale date verdict; do
    [[ -n "$rel" ]] || continue
    case "$verdict" in
      ok) ;;
      wrong-locale) check_fail "$rel:$line — carries the other locale's verified lead-in (this file is $locale)" ;;
      bad-leadin)   check_fail "$rel:$line — malformed verified lead-in for locale $locale" ;;
      no-date)      check_fail "$rel:$line — verified annotation has no YYYY-MM-DD in its bold span" ;;
      bad-date)     check_fail "$rel:$line — '$date' is not a real calendar day" ;;
      future-date)  check_fail "$rel:$line — verified date '$date' is later than today ($TODAY_YMD)" ;;
      no-source)    check_fail "$rel:$line — verified annotation names no source after the em dash" ;;
      *)            check_fail "$rel:$line — unrecognized dated-claim verdict '$verdict'" ;;
    esac
  done <<<"$DATED_CLAIMS_RECORDS"
}
```

- [ ] **Step 4: Call it once from `run_checks`**

In `scripts/build.sh`, in `run_checks` (near line 554), add the call beside `check_version_coherence` — repo-wide and once, never inside the per-skill loop, or the scanner would walk everything fourteen times (Decision §3, AC13):

```bash
  # Repo-wide, not per-locale: run it once.
  check_version_coherence
  # 2026-09-19/AC13 — the scanner finds its own files, so it runs once here
  # rather than inside the per-skill, per-locale loop below.
  check_dated_claims
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep 'AC4 rejects an English'`
Expected: `ok: 2026-09-19/AC4 rejects an English lead-in under /fr/`

- [ ] **Step 6: Write the remaining form-failure tests (AC5–AC8)**

Append after the AC4 block. Each is its own fixture mutation, asserted through `expect_check_fail`, which already requires both a non-zero exit and the offending path in the combined output — that helper is what AC33 means by "asserted through `expect_check_fail`":

```bash
# --- 2026-09-19/AC5: a bold span with no date fails, naming file and line
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
sed -i 's/^> \*\*Last verified [0-9-]*\*\*/> **Last verified**/' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC5 rejects a bold span with no date"
rm -rf "$d"

# --- 2026-09-19/AC5: an unclosed bold span fails too
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
sed -i 's/^> \*\*Last verified \([0-9-]*\)\*\* — source:/> **Last verified \1 — source:/' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC5 rejects an unclosed bold span"
rm -rf "$d"

# --- 2026-09-19/AC6: a date shaped right but not a real calendar day fails
for bad in 2026-02-30 2026-13-01 2025-02-29; do
  d="$(make_fixture_repo)"
  write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
  sed -i "s/^> \*\*Last verified [0-9-]*\*\*/> **Last verified $bad**/" \
    "$d/skills/atelier-ventes/en/references/tutorial/03.md"
  expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
    "2026-09-19/AC6 rejects $bad"
  rm -rf "$d"
done

# --- 2026-09-19/AC7: a date later than the run date fails
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" -30
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC7 rejects a future date"
rm -rf "$d"

# --- 2026-09-19/AC8: an absent source segment fails
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
sed -i 's/^\(> \*\*Last verified [0-9-]*\*\*\) — source:.*/\1 no source segment here/' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC8 rejects an absent source segment"
rm -rf "$d"

# --- 2026-09-19/AC8: a source segment followed only by whitespace fails
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
sed -i 's/^\(> \*\*Last verified [0-9-]*\*\* — source:\).*/\1   /' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md:5" \
  "2026-09-19/AC8 rejects a source segment of whitespace only"
rm -rf "$d"
```

Note `write_annotation "$d" en … -30`: `days_ago -30` returns a date thirty days in the *future*, which is exactly the AC7 typo case.

- [ ] **Step 7: Write the French-side tests (AC2)**

Everything above exercises the English pattern. AC2 is a separate contract —
its space before the colon is the detail most likely to be "corrected" by a
translator or an editor's autoformat, and nothing so far would catch that.

```bash
# --- 2026-09-19/AC2: a valid French annotation passes
d="$(make_fixture_repo)"
write_annotation "$d" fr "skills/atelier-ventes/fr/references/tutorial/03.md" 10
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "2026-09-19/AC2 a valid French annotation passes"
else
  fail "2026-09-19/AC2 rejected a valid French annotation (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC2: dropping the space before the colon fails. French
# typography requires it, and an editor that "tidies" it away must land red.
d="$(make_fixture_repo)"
write_annotation "$d" fr "skills/atelier-ventes/fr/references/tutorial/03.md" 10
sed -i 's/\*\* — source :/** — source:/' \
  "$d/skills/atelier-ventes/fr/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/fr/references/tutorial/03.md:5" \
  "2026-09-19/AC2 rejects a French annotation missing the space before the colon"
rm -rf "$d"

# --- 2026-09-19/AC2: a French annotation with a bad calendar date fails
d="$(make_fixture_repo)"
write_annotation "$d" fr "skills/atelier-ventes/fr/references/tutorial/03.md" 10
sed -i 's/^> \*\*Vérifié le [0-9-]*\*\*/> **Vérifié le 2026-13-01**/' \
  "$d/skills/atelier-ventes/fr/references/tutorial/03.md"
expect_check_fail "$d" "skills/atelier-ventes/fr/references/tutorial/03.md:5" \
  "2026-09-19/AC2 rejects a French annotation with an impossible date"
rm -rf "$d"

# --- 2026-09-19/AC4: a French lead-in under /en/ fails, the mirror of the
# first test in this task
d="$(make_fixture_repo)"
write_annotation "$d" fr "skills/atelier-ventes/en/references/tutorial/04.md" 10
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/04.md:5" \
  "2026-09-19/AC4 rejects a French lead-in under /en/"
rm -rf "$d"
```

The `sed` in the second case needs the em dash to survive the shell — it does,
since the pattern is single-quoted and the file is UTF-8. If the substitution
silently matches nothing, the test would pass for the wrong reason, so confirm
the mutation landed before trusting a green result:

```bash
d="$(make_fixture_repo)"
write_annotation "$d" fr "skills/atelier-ventes/fr/references/tutorial/03.md" 10
sed -i 's/\*\* — source :/** — source:/' "$d/skills/atelier-ventes/fr/references/tutorial/03.md"
grep -c -- '— source:' "$d/skills/atelier-ventes/fr/references/tutorial/03.md"
rm -rf "$d"
```

Expected: `1`.

- [ ] **Step 8: Run the tests to verify they pass**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep '2026-09-19/AC'`
Expected: every line begins `ok:`. Fourteen assertions — AC4 twice, AC5 twice,
AC6 three times, AC7 once, AC8 twice, AC2 three times.

- [ ] **Step 9: Write the failing test — a fenced example must not be detected**

This is Review Focus item 1.

```bash
# --- Review Focus 1: a fenced block quoting the pattern is an example, not an
# annotation. docs/AUTHORING.md mirrors the exact lead-in (2026-09-19/AC39),
# and the day someone copies that example into a skill's references/ the build
# must not fail on it.
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
mkdir -p "$d/skills/atelier-ventes/en/references"
cat > "$d/skills/atelier-ventes/en/references/authoring-example.md" <<'EOF'
# How to write one

Copy this shape exactly:

```
> **Last verified 2026-02-30** — source:
```

The date above is deliberately impossible; it is an example.
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "fenced annotation example is not detected"
else
  fail "fenced annotation example was detected (rc=$rc, out=$out)"
fi
rm -rf "$d"
```

- [ ] **Step 10: Run it to verify it passes**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep 'fenced annotation'`
Expected: `ok: fenced annotation example is not detected` — the fence toggle added in Step 3 already handles it. If it fails, the `substr(line, 1, 3) == "```"` branch is missing or placed after the `> **` guard.

- [ ] **Step 11: Write the failing test — CRLF line endings**

Review Focus item 2.

```bash
# --- Review Focus 2: a CRLF checkout must produce the same verdict as LF.
# Without the `sub(/\r$/, "", line)` in the scanner the trailing \r lands after
# the source text and a perfectly valid annotation reads as no-source.
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
f="$d/skills/atelier-ventes/en/references/tutorial/03.md"
awk '{ printf "%s\r\n", $0 }' "$f" > "$f.crlf" && mv "$f.crlf" "$f"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "a CRLF annotation validates like its LF twin"
else
  fail "a CRLF annotation failed validation (rc=$rc, out=$out)"
fi
rm -rf "$d"
```

- [ ] **Step 12: Run it to verify it passes**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep CRLF`
Expected: `ok: a CRLF annotation validates like its LF twin`

- [ ] **Step 13: Write the failing test — a doubled locale segment in the path**

Review Focus item 3.

```bash
# --- Review Focus 3: skills/<skill>/en/references/fr/… is an English file.
# The locale is the segment directly under the skill directory, not the last
# /en/ or /fr/ anywhere in the path.
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/fr/notes.md" 10
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "locale comes from the skill directory, not a nested path segment"
else
  fail "a nested /fr/ segment misread an English file (rc=$rc, out=$out)"
fi
rm -rf "$d"
```

- [ ] **Step 14: Run it to verify it passes**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep 'locale comes from'`
Expected: `ok: locale comes from the skill directory, not a nested path segment`

- [ ] **Step 15: Run the whole gate**

```bash
bash scripts/build.sh --check && \
bash scripts/tests/shared_test.sh && \
bash scripts/tests/authoring_test.sh && \
bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS` from each. `scripts/build.sh --check` now scans the nineteen real annotations and must pass — they are all valid and dated `2026-08-10`.

- [ ] **Step 16: Commit**

```bash
git add scripts/build.sh scripts/tests/build_test.sh
git commit -m "feat(build): scan and validate dated capability claims"
```

---

## Task 2: The anchor list

`skills/dated-claims.tsv` names the files that must carry at least one dated claim. No script can decide whether a sentence is capability-sensitive, but it can notice that a module known to be full of such claims has ended up with none — a bad merge, a translation that dropped the blockquote. This is AC9, AC10, AC10b and AC27.

**Files:**
- Create: `skills/dated-claims.tsv`
- Modify: `scripts/build.sh` (add `check_dated_claims_anchors`, call it from `check_dated_claims`)
- Modify: `scripts/tests/build_test.sh` (`make_fixture_repo` gains an anchor file)
- Test: `scripts/tests/build_test.sh`

**Interfaces:**
- Consumes: `DATED_CLAIMS_RECORDS` and `DATED_CLAIMS_TSV` from Task 1; `check_fail`, `REPO_ROOT`.
- Produces: `check_dated_claims_anchors()` — no return value, calls `check_fail`.

- [ ] **Step 1: Create the anchor list**

```bash
cat > skills/dated-claims.tsv <<'EOF'
skills/atelier-mentor/en/references/tutorial/03-surfaces.md
skills/atelier-mentor/en/references/tutorial/04-skills-connectors-plugins.md
skills/atelier-mentor/en/references/tutorial/05-organizing-features.md
skills/atelier-mentor/fr/references/tutorial/03-surfaces.md
skills/atelier-mentor/fr/references/tutorial/04-competences-connecteurs-plugiciels.md
skills/atelier-mentor/fr/references/tutorial/05-fonctions-organisation.md
EOF
```

Verify every path exists before going further — a typo here would make Task 2's own test pass for the wrong reason:

```bash
while IFS= read -r p; do [[ -f "$p" ]] || echo "MISSING: $p"; done < skills/dated-claims.tsv
```

Expected: no output.

It is single-column and still named `.tsv` for consistency with its neighbour `skills/names.tsv` (Decision §6). It lives in a file rather than as an array in each script because anything written twice in two languages eventually says two different things.

- [ ] **Step 2: Give the fixture an anchor file**

`make_fixture_repo` builds a repo with no `skills/dated-claims.tsv`, and AC10b makes an absent list fatal — so without this the existing AC55 clean-fixture test breaks. In `scripts/tests/build_test.sh`, inside `make_fixture_repo`, just before the closing `echo "$dir"`:

```bash
  # 2026-09-19/AC10b makes an absent anchor list fatal, so the clean fixture
  # carries one, pointing at one anchored module with a valid annotation.
  mkdir -p "$dir/skills/atelier-ventes/en/references/tutorial"
  printf 'skills/atelier-ventes/en/references/tutorial/03.md\n' > "$dir/skills/dated-claims.tsv"
  write_annotation "$dir" en "skills/atelier-ventes/en/references/tutorial/03.md" 10
```

`write_annotation` and `days_ago` are defined in Task 1 Step 1 — they must appear **above** `make_fixture_repo` in the file. Move them there if they are not already.

- [ ] **Step 3: Run the existing suite to confirm it still passes**

Run: `bash scripts/tests/build_test.sh`
Expected: `STATUS: PASS`. Every Task 1 test that calls `write_annotation` on its own path now has a second, clean annotation in the fixture too — that is harmless, since each Task 1 assertion looks for its own file:line in the output.

- [ ] **Step 4: Write the failing tests — AC9, AC10, AC10b**

```bash
# --- 2026-09-19/AC9: an anchored file carrying no annotation fails
d="$(make_fixture_repo)"
cat > "$d/skills/atelier-ventes/en/references/tutorial/03.md" <<'EOF'
# Module

Every dated claim was dropped from this module by a bad merge.
EOF
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/03.md" \
  "2026-09-19/AC9 rejects an anchored file with no dated claim"
rm -rf "$d"

# --- 2026-09-19/AC10: an anchored path that does not exist fails
d="$(make_fixture_repo)"
printf 'skills/atelier-ventes/en/references/tutorial/99-renamed.md\n' \
  >> "$d/skills/dated-claims.tsv"
expect_check_fail "$d" "skills/atelier-ventes/en/references/tutorial/99-renamed.md" \
  "2026-09-19/AC10 rejects an anchored path that does not exist"
rm -rf "$d"

# --- 2026-09-19/AC10b: an absent anchor list is itself fatal. A repository
# must not be able to opt out of AC9 by deleting the list.
d="$(make_fixture_repo)"
rm -f "$d/skills/dated-claims.tsv"
expect_check_fail "$d" "skills/dated-claims.tsv" \
  "2026-09-19/AC10b rejects an absent anchor list"
rm -rf "$d"
```

- [ ] **Step 5: Run them to verify they fail**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -E '2026-09-19/AC(9|10)'`
Expected: three `FAIL:` lines — nothing reads the anchor list yet.

- [ ] **Step 6: Implement the anchor check**

Add to `scripts/build.sh`, directly after `check_dated_claims`:

```bash
# --- 2026-09-19/AC9, AC10, AC10b — the weaker, mechanically decidable version
# of ADR-0011's real rule. No script can decide whether a sentence is
# capability-sensitive, but it can notice that a module known to be full of
# such claims has ended up with none.
check_dated_claims_anchors() {
  if [[ ! -f "$DATED_CLAIMS_TSV" ]]; then
    check_fail "skills/dated-claims.tsv — anchor list not found"
    return
  fi
  local p
  while IFS= read -r p || [[ -n "$p" ]]; do
    p="${p%%$'\t'*}"     # single-column today, but tolerate a second column
    p="${p%$'\r'}"       # a CRLF checkout must not append \r to the path
    [[ -n "$p" ]] || continue
    if [[ ! -f "$REPO_ROOT/$p" ]]; then
      check_fail "$p — listed in skills/dated-claims.tsv but no such file (renamed?)"
      continue
    fi
    # "Detected", not "valid": a malformed annotation still counts here and
    # fails separately through check_dated_claims, so one broken annotation
    # does not produce two failures for the same line.
    if ! grep -qF -- "$p"$'\t' <<<"$DATED_CLAIMS_RECORDS"; then
      check_fail "$p — listed in skills/dated-claims.tsv but carries no dated claim"
    fi
  done < "$DATED_CLAIMS_TSV"
}
```

And call it from `check_dated_claims`, after the record loop:

```bash
  done <<<"$DATED_CLAIMS_RECORDS"
  check_dated_claims_anchors
}
```

- [ ] **Step 7: Run the tests to verify they pass**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -E '2026-09-19/AC(9|10)'`
Expected: three `ok:` lines.

- [ ] **Step 8: Write the failing test — blank and CRLF lines in the anchor list**

Review Focus item 4.

```bash
# --- Review Focus 4: a trailing newline is normal in a text file, and a
# Windows editor writes CRLF. Neither may become an empty or \r-suffixed
# anchor path that fails with a meaningless name.
d="$(make_fixture_repo)"
printf 'skills/atelier-ventes/en/references/tutorial/03.md\r\n\r\n\n' \
  > "$d/skills/dated-claims.tsv"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]]; then
  pass "anchor list tolerates blank lines and CRLF"
else
  fail "anchor list rejected blank or CRLF lines (rc=$rc, out=$out)"
fi
rm -rf "$d"
```

- [ ] **Step 9: Run it to verify it passes**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep 'anchor list tolerates'`
Expected: `ok: anchor list tolerates blank lines and CRLF` — the `${p%$'\r'}` strip and the `[[ -n "$p" ]]` guard from Step 6 handle both.

- [ ] **Step 10: Run the whole gate**

```bash
bash scripts/build.sh --check && \
bash scripts/tests/shared_test.sh && \
bash scripts/tests/authoring_test.sh && \
bash scripts/tests/build_test.sh
```

Expected: `STATUS: PASS` from each. The real repo's six anchored modules all carry annotations, so `--check` stays green.

- [ ] **Step 11: Commit**

```bash
git add skills/dated-claims.tsv scripts/build.sh scripts/tests/build_test.sh
git commit -m "feat(build): require anchored modules to carry a dated claim"
```

---

## Task 3: The summary line and the report tier

The failure mode that most threatens this check is not a stale date — it is the pattern quietly ceasing to match after someone rewords a module, at which point every tier goes silent and the whole mechanism is dead without a single red mark. A line that always states how many annotations were found makes that visible on the next pull request. This is AC11, AC14–AC18, AC15b, AC15c and AC23.

**Files:**
- Modify: `scripts/build.sh` (add `report_dated_claims`, call from `run_checks` before the `STATUS:` line)
- Test: `scripts/tests/build_test.sh`

**Interfaces:**
- Consumes: `DATED_CLAIMS_RECORDS`, `DATED_CLAIMS_AWK_LIB`, `TODAY_YMD`, `REPORT_AGE_DAYS`, `CHECK_FAILURES`.
- Produces: `report_dated_claims()` — prints to stdout, returns nothing, never changes `CHECK_FAILURES`. This is what makes AC23 true by construction: the reporter has no path to a failure.

- [ ] **Step 1: Write the failing test — the clean fixture prints the summary line**

```bash
# --- 2026-09-19/AC15, AC15b: the clean fixture prints exactly one summary line
d="$(make_fixture_repo)"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
n="$(grep -c '^dated claims: ' <<<"$out")"
if [[ "$rc" -eq 0 ]] && [[ "$n" -eq 1 ]] \
   && grep -qE '^dated claims: 1 annotations across 1 files, oldest [0-9]{4}-[0-9]{2}-[0-9]{2} \(10 days\)$' <<<"$out"; then
  pass "2026-09-19/AC15 clean fixture prints exactly one summary line with date and age"
else
  fail "2026-09-19/AC15 summary line wrong (rc=$rc, count=$n, out=$out)"
fi
rm -rf "$d"
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep 'AC15 clean fixture'`
Expected: `FAIL: 2026-09-19/AC15 summary line wrong (rc=0, count=0, …)` — nothing prints the line yet.

- [ ] **Step 3: Implement the reporter**

Add to `scripts/build.sh` after `check_dated_claims_anchors`:

```bash
# --- 2026-09-19/AC15, AC15b, AC15c, AC16, AC17 — one summary line before
# every STATUS: line, plus a note once the oldest claim reaches the report
# threshold. Never touches CHECK_FAILURES: age alone must not redden a pull
# request (2026-09-19/AC23), and the only way to guarantee that is for the
# reporter to have no path to a failure at all.
report_dated_claims() {
  local summary n nf oldest age loc
  summary="$(awk -F'\t' -v today="$TODAY_YMD" "$DATED_CLAIMS_AWK_LIB"'
    BEGIN { todayDays = ymd_to_days(today) }
    $5 == "ok" {
      n++
      files[$1] = 1
      dn = ymd_to_days($4)
      # Strict <, so a tie keeps the FIRST record in scan order
      # (2026-09-19/AC3b); scan_dated_claims emits in that order.
      if (n == 1 || dn < oldestDays) { oldestDays = dn; oldestYmd = $4; loc = $1 ":" $2 }
    }
    END {
      nf = 0
      for (f in files) nf++
      if (n == 0) { printf "0\t0\t\t\t\n"; exit }
      printf "%d\t%d\t%s\t%d\t%s\n", n, nf, oldestYmd, todayDays - oldestDays, loc
    }
  ' <<<"$DATED_CLAIMS_RECORDS")"

  IFS=$'\t' read -r n nf oldest age loc <<<"$summary"

  if [[ "$n" -eq 0 ]]; then
    # 2026-09-19/AC15c — the run where the pattern stopped matching entirely
    # is precisely the one worth seeing this line on.
    echo "dated claims: 0 annotations across 0 files, no dated claim found"
    return
  fi

  echo "dated claims: $n annotations across $nf files, oldest $oldest ($age days)"

  # 2026-09-19/AC16 — the note rides on a passing run only; on a failing run
  # the check failures are the message.
  if [[ "$CHECK_FAILURES" -eq 0 ]] && [[ "$age" -ge "$REPORT_AGE_DAYS" ]]; then
    echo "NOTE: oldest dated claim is $age days old (report threshold $REPORT_AGE_DAYS) —"
    echo "      $loc"
    echo "      see docs/tutorial-corpus.md, \"Claims to re-verify\""
  fi
}
```

- [ ] **Step 4: Call it immediately before the `STATUS:` line**

In `run_checks` (near line 573), so the line prints on a passing and a failing run alike (AC15):

```bash
  # 2026-09-19/AC15 — before STATUS:, on every run that reaches it.
  report_dated_claims

  if [[ "$CHECK_FAILURES" -gt 0 ]]; then
    echo "STATUS: FAIL ($CHECK_FAILURES check failures)" >&2
    exit 1
```

- [ ] **Step 5: Run the test to verify it passes**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep 'AC15 clean fixture'`
Expected: `ok: 2026-09-19/AC15 clean fixture prints exactly one summary line with date and age`

- [ ] **Step 6: Write the tests for AC15c, AC16, AC17 and AC11**

These four, plus the `--check-freshness` pair in Task 4 Step 1, are exactly
what AC34 enumerates: a clean fixture passing and printing the summary line; a
fixture past `REPORT_AGE_DAYS` but under `FAIL_AGE_DAYS` exiting 0 with the
note; `--check-freshness` failing past `FAIL_AGE_DAYS` and passing under it.
AC35 is satisfied throughout by `days_ago`, which computes every fixture date
from the run date.

```bash
# --- 2026-09-19/AC15c: with every annotation gone the line prints its zero
# form, and the run fails on AC9 rather than on the reporter
d="$(make_fixture_repo)"
cat > "$d/skills/atelier-ventes/en/references/tutorial/03.md" <<'EOF'
# Module

Every dated claim was dropped from this module.
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] \
   && grep -qxF 'dated claims: 0 annotations across 0 files, no dated claim found' <<<"$out" \
   && grep -qF 'carries no dated claim' <<<"$out"; then
  pass "2026-09-19/AC15c zero form prints on a failing run"
else
  fail "2026-09-19/AC15c zero form wrong (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC16, AC23: past the report threshold, --check prints the note
# and still exits 0
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 200
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] \
   && grep -qF 'NOTE: oldest dated claim is 200 days old (report threshold 180)' <<<"$out" \
   && grep -qF 'skills/atelier-ventes/en/references/tutorial/03.md:5' <<<"$out" \
   && grep -qF 'docs/tutorial-corpus.md' <<<"$out"; then
  pass "2026-09-19/AC16 note printed past the report threshold, exit still 0"
else
  fail "2026-09-19/AC16 note wrong (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC17: under the report threshold there is no note
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 179
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && ! grep -qF 'NOTE: oldest dated claim' <<<"$out"; then
  pass "2026-09-19/AC17 no note under the report threshold"
else
  fail "2026-09-19/AC17 printed a note it should not have (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC11: a clean repo exits 0 with the exact PASS line, with the
# summary line above it
d="$(make_fixture_repo)"
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && grep -qxF 'STATUS: PASS (mechanical checks)' <<<"$out"; then
  pass "2026-09-19/AC11 clean repo exits 0 with the exact PASS line"
else
  fail "2026-09-19/AC11 clean repo did not pass cleanly (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC14: neither threshold appears as a bare literal outside its
# constant definition
for pair in "REPORT_AGE_DAYS 180" "FAIL_AGE_DAYS 365"; do
  set -- $pair
  hits="$(grep -nE "(^|[^A-Za-z0-9_])$2([^0-9]|$)" "$REPO_ROOT/scripts/build.sh" \
          | grep -vE "^[0-9]+:$1=" | wc -l)"
  if [[ "$hits" -eq 0 ]]; then
    pass "2026-09-19/AC14 $2 appears only as $1"
  else
    fail "2026-09-19/AC14 $2 appears as a bare literal $hits time(s) in build.sh"
  fi
done
```

- [ ] **Step 7: Run them to verify they pass**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -E '2026-09-19/AC(11|14|15c|16|17)'`
Expected: every line begins `ok:`.

- [ ] **Step 8: Write the boundary tests**

Review Focus item 5, the `>=`-not-`>` half that `--check` owns. The `--check-freshness` half lands in Task 4.

```bash
# --- Review Focus 5: an annotation dated today is age 0, not a future date
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 0
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && grep -qF 'oldest '"$(days_ago 0)"' (0 days)' <<<"$out"; then
  pass "an annotation dated today is age 0, not a future date"
else
  fail "today's date mishandled (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- Review Focus 5: exactly REPORT_AGE_DAYS prints the note (>=, not >)
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 180
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -eq 0 ]] && grep -qF 'NOTE: oldest dated claim is 180 days old' <<<"$out"; then
  pass "exactly REPORT_AGE_DAYS prints the note"
else
  fail "the report threshold is exclusive where it should be inclusive (rc=$rc, out=$out)"
fi
rm -rf "$d"
```

- [ ] **Step 9: Run them to verify they pass**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -E 'age 0|REPORT_AGE_DAYS prints'`
Expected: two `ok:` lines.

- [ ] **Step 10: Write the failing test — AC3b's tie-break**

Two annotations sharing the oldest date must resolve to the first in scan
order: lexicographic by repo-relative path, then ascending by line number. Both
halves need pinning, because a hash-ordered loop would pass the first half by
luck.

```bash
# --- 2026-09-19/AC3b: on a tie, "the oldest" is the first in scan order —
# lexicographic by path, then ascending by line
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 200
printf 'skills/atelier-ventes/en/references/tutorial/01.md
' >> "$d/skills/dated-claims.tsv"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/01.md" 200
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -qF 'skills/atelier-ventes/en/references/tutorial/01.md:5' <<<"$out" \
   && ! grep -qF 'NOTE:' <<<"$out" \
   || grep -A 1 'NOTE: oldest dated claim' <<<"$out" | grep -qF 'tutorial/01.md:5'; then
  pass "2026-09-19/AC3b a path tie resolves to the lexicographically first file"
else
  fail "2026-09-19/AC3b picked the wrong file on a tie (out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC3b: two annotations at the same date in ONE file resolve to
# the lower line number
d="$(make_fixture_repo)"
dd="$(days_ago 200)"
cat > "$d/skills/atelier-ventes/en/references/tutorial/03.md" <<EOF
# Module

> **Last verified $dd** — source: first annotation, line 3.

Prose between them.

> **Last verified $dd** — source: second annotation, line 7.
EOF
out="$( cd "$d" && bash scripts/build.sh --check 2>&1 )"
if grep -A 1 'NOTE: oldest dated claim' <<<"$out" | grep -qF 'tutorial/03.md:3'; then
  pass "2026-09-19/AC3b a line tie resolves to the lower line number"
else
  fail "2026-09-19/AC3b picked the wrong line on a tie (out=$out)"
fi
rm -rf "$d"
```

- [ ] **Step 11: Run them to verify they pass**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep 'AC3b'`
Expected: two `ok:` lines. If the line tie picks `:7`, the reporter's comparison
is `<=` where AC3b requires a strict `<`.

- [ ] **Step 12: Confirm the real repo prints a sane line**

```bash
bash scripts/build.sh --check 2>&1 | grep '^dated claims:'
```

Expected: `dated claims: 19 annotations across 6 files, oldest 2026-08-10 (40 days)`. The count is the check on the check — if it reads anything other than 19 across 6, the scanner is missing files and the rest of this plan rests on sand. Do not proceed past a wrong count.

- [ ] **Step 13: Run the whole gate and commit**

```bash
bash scripts/build.sh --check && \
bash scripts/tests/shared_test.sh && \
bash scripts/tests/authoring_test.sh && \
bash scripts/tests/build_test.sh
git add scripts/build.sh scripts/tests/build_test.sh
git commit -m "feat(build): report dated-claim age on every check run"
```

---

## Task 4: `--check-freshness`

A separate entry point that neither stages a skill nor writes to `dist/`. It carries the form validation deliberately: if the pattern stopped matching, this job is the last thing that would notice, and it must fail rather than report a cheerful zero. This is AC19–AC22.

**Files:**
- Modify: `scripts/build.sh` (argument parsing near line 154, `usage` near line 36, a new `run_freshness_check`)
- Test: `scripts/tests/build_test.sh`

**Interfaces:**
- Consumes: `check_dated_claims`, `check_dated_claims_anchors`, `DATED_CLAIMS_RECORDS`, `DATED_CLAIMS_AWK_LIB`, `FAIL_AGE_DAYS`, `REPORT_AGE_DAYS`, `CHECK_FAILURES`, `TODAY_YMD`.
- Produces: `run_freshness_check()` — prints the stale list, exits 0 or 1 directly.

- [ ] **Step 1: Write the failing tests**

```bash
# --- 2026-09-19/AC20: everything younger than FAIL_AGE_DAYS exits 0
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 364
( cd "$d" && bash scripts/build.sh --check-freshness >/dev/null 2>&1 ) \
  && pass "2026-09-19/AC20 --check-freshness exits 0 under FAIL_AGE_DAYS" \
  || fail "2026-09-19/AC20 --check-freshness failed under FAIL_AGE_DAYS"
rm -rf "$d"

# --- 2026-09-19/AC21 + Review Focus 5: exactly FAIL_AGE_DAYS fails, and the
# report lists every annotation at or over REPORT_AGE_DAYS with file, line,
# date and age
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 365
printf 'skills/atelier-ventes/fr/references/tutorial/03.md\n' >> "$d/skills/dated-claims.tsv"
write_annotation "$d" fr "skills/atelier-ventes/fr/references/tutorial/03.md" 200
out="$( cd "$d" && bash scripts/build.sh --check-freshness 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] \
   && grep -qF "skills/atelier-ventes/en/references/tutorial/03.md:5 $(days_ago 365) (365 days)" <<<"$out" \
   && grep -qF "skills/atelier-ventes/fr/references/tutorial/03.md:5 $(days_ago 200) (200 days)" <<<"$out"; then
  pass "2026-09-19/AC21 --check-freshness fails at exactly FAIL_AGE_DAYS and lists every claim past REPORT_AGE_DAYS"
else
  fail "2026-09-19/AC21 stale report wrong (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC22: a form failure fails regardless of age
d="$(make_fixture_repo)"
write_annotation "$d" en "skills/atelier-ventes/en/references/tutorial/03.md" 1
sed -i 's/^> \*\*Last verified [0-9-]*\*\*/> **Last verified 2026-02-30**/' \
  "$d/skills/atelier-ventes/en/references/tutorial/03.md"
out="$( cd "$d" && bash scripts/build.sh --check-freshness 2>&1 )" && rc=0 || rc=1
if [[ "$rc" -ne 0 ]] && grep -qF 'not a real calendar day' <<<"$out"; then
  pass "2026-09-19/AC22 --check-freshness fails on a form error regardless of age"
else
  fail "2026-09-19/AC22 form error did not fail --check-freshness (rc=$rc, out=$out)"
fi
rm -rf "$d"

# --- 2026-09-19/AC19: --check-freshness writes nothing to dist/
d="$(make_fixture_repo)"
( cd "$d" && bash scripts/build.sh --check-freshness >/dev/null 2>&1 )
[[ ! -d "$d/dist" ]] && pass "2026-09-19/AC19 --check-freshness leaves dist/ untouched" \
                     || fail "2026-09-19/AC19 --check-freshness created dist/"
rm -rf "$d"
```

- [ ] **Step 2: Run them to verify they fail**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -E '2026-09-19/AC(19|20|21|22)'`
Expected: four `FAIL:` lines — `--check-freshness` is currently rejected by `die "unknown argument"`.

- [ ] **Step 3: Implement the entry point**

Add to `scripts/build.sh` after `report_dated_claims`:

```bash
# --- 2026-09-19/AC19–AC22 — the second tier. Stages nothing, writes nothing
# to dist/, and carries the form validation deliberately: if the pattern
# stopped matching, this job is the last thing that would notice, and it must
# fail rather than report a cheerful zero.
run_freshness_check() {
  check_dated_claims

  if [[ "$CHECK_FAILURES" -gt 0 ]]; then
    echo "STATUS: FAIL ($CHECK_FAILURES check failures)" >&2
    exit 1
  fi

  local stale
  stale="$(awk -F'\t' -v today="$TODAY_YMD" -v fail_age="$FAIL_AGE_DAYS" \
               -v report_age="$REPORT_AGE_DAYS" "$DATED_CLAIMS_AWK_LIB"'
    BEGIN { todayDays = ymd_to_days(today); anyFail = 0 }
    $5 == "ok" {
      age = todayDays - ymd_to_days($4)
      if (age >= fail_age) anyFail = 1
      if (age >= report_age) lines[++n] = sprintf("  %s:%s %s (%d days)", $1, $2, $4, age)
    }
    END {
      if (!anyFail) exit 0
      for (i = 1; i <= n; i++) print lines[i]
      exit 0
    }
  ' <<<"$DATED_CLAIMS_RECORDS")"

  if [[ -n "$stale" ]]; then
    echo "Dated capability claims are past the freshness threshold (fail threshold $FAIL_AGE_DAYS days,"
    echo "listing everything at or over $REPORT_AGE_DAYS days):"
    echo "$stale"
    return 1
  fi

  echo "dated claims: every claim is younger than $FAIL_AGE_DAYS days"
  return 0
}
```

- [ ] **Step 4: Wire the argument**

In `main()`, add the flag to the parse loop (near line 158):

```bash
      --check) check=1; shift ;;
      --check-freshness) freshness=1; shift ;;
```

Declare it on the same line as the other locals:

```bash
  local lang="" check=0 freshness=0
```

And short-circuit before `[[ -f "$NAMES_TSV" ]]`'s locale machinery — the freshness run needs no locale, no staging and no `dist/`:

```bash
  [[ -f "$NAMES_TSV" ]] || die "missing $NAMES_TSV"

  # 2026-09-19/AC19 — neither stages a skill nor writes to dist/, so it
  # returns before any of the build machinery below.
  if [[ "$freshness" -eq 1 ]]; then
    run_freshness_check
    exit $?
  fi
```

Note `run_freshness_check` uses `return 1`, not `exit 1`, so the `EXIT` trap's `cleanup_stage_dirs` still runs through the normal path. `exit $?` immediately after preserves the status.

- [ ] **Step 5: Update `usage`**

```bash
Usage: build.sh [--lang fr|en|all] [--check] [--check-freshness]

  --lang fr|en|all   Build that locale without prompting.
  --check            Run the mechanical checks only; build to a temp dir and
                     leave dist/ untouched. Exits non-zero on any failure.
  --check-freshness  Validate every dated capability claim and fail if the
                     oldest has passed the freshness threshold. Builds nothing.

With no --lang, the script asks which language to build.
```

- [ ] **Step 6: Run the tests to verify they pass**

Run: `bash scripts/tests/build_test.sh 2>&1 | grep -E '2026-09-19/AC(19|20|21|22)'`
Expected: four `ok:` lines.

- [ ] **Step 7: Confirm the real repo is green on freshness**

```bash
bash scripts/build.sh --check-freshness; echo "exit=$?"
```

Expected: `dated claims: every claim is younger than 365 days` and `exit=0`. The nineteen annotations are 40 days old.

- [ ] **Step 8: Run the whole gate and commit**

```bash
bash scripts/build.sh --check && \
bash scripts/tests/shared_test.sh && \
bash scripts/tests/authoring_test.sh && \
bash scripts/tests/build_test.sh
git add scripts/build.sh scripts/tests/build_test.sh
git commit -m "feat(build): add --check-freshness for dated capability claims"
```

---

## Task 5: The PowerShell twin

`scripts/build.ps1` mirrors `build.sh`'s behavior, checks and outputs; Windows CI runs `-Check`. This is AC24, AC25, AC26 and AC36. `-CheckFreshness` has no CI caller by design and exists for parity.

**Files:**
- Modify: `scripts/build.ps1`
- Test: `scripts/tests/build_test.ps1`

**Interfaces:**
- Consumes: `Add-CheckFailure`, `Get-SkillList`, `$SkillsDir`, `$RepoRoot`, `$AllLocales` — all already defined.
- Produces: `Get-DatedClaimRecords`, `Test-DatedClaims`, `Test-DatedClaimAnchors`, `Show-DatedClaimReport`, `Invoke-FreshnessCheck`, `$script:DatedClaimRecords`, `$ReportAgeDays`, `$FailAgeDays`, and a `-CheckFreshness` switch parameter.

- [ ] **Step 1: Write the failing tests**

Add to `scripts/tests/build_test.ps1`. First the fixture needs an anchor file and an annotation — mirror Task 2 Step 2 inside `New-FixtureRepo`, before it returns `$dir`:

```powershell
  # 2026-09-19/AC10b makes an absent anchor list fatal, so the clean fixture
  # carries one, pointing at one anchored module with a valid annotation.
  New-Item -ItemType Directory -Force -Path (Join-Path $dir 'skills/atelier-ventes/en/references/tutorial') | Out-Null
  Write-Lf (Join-Path $dir 'skills/dated-claims.tsv') "skills/atelier-ventes/en/references/tutorial/03.md`n"
  Write-Annotation -Dir $dir -Locale 'en' -Rel 'skills/atelier-ventes/en/references/tutorial/03.md' -Days 10
```

And the helpers, above `New-FixtureRepo`:

```powershell
# 2026-09-19/AC35 — fixture dates are computed from the run date, never
# written as literals. PowerShell has real date arithmetic, so unlike bash
# this needs no civil-algorithm helper.
function Get-DaysAgo([int]$Days) {
  return (Get-Date).Date.AddDays(-$Days).ToString('yyyy-MM-dd')
}

function Write-Annotation([string]$Dir, [string]$Locale, [string]$Rel, [int]$Days) {
  $d = Get-DaysAgo $Days
  $full = Join-Path $Dir $Rel
  New-Item -ItemType Directory -Force -Path (Split-Path -Parent $full) | Out-Null
  if ($Locale -ceq 'en') {
    $body = @"
# Module

Prose above the annotation.

> **Last verified $d** — source: Anthropic help center, article 15520349
> ("Use Claude Cowork on web, desktop, and mobile"). Continuation prose the
> check never reads.

Prose below.
"@
  } else {
    $body = @"
# Module

Prose au-dessus de l'annotation.

> **Vérifié le $d** — source : centre d'aide Anthropic, article 15520349
> (« Use Claude Cowork on web, desktop, and mobile »). Prose de continuation
> que la vérification ne lit jamais.

Prose en dessous.
"@
  }
  Write-Lf $full $body
}
```

`Write-Lf` uses `[System.IO.File]::WriteAllText`, which writes UTF-8 without a BOM — the French `é` and the em dash must survive as UTF-8 bytes for `-Check` to match them.

Then the assertions:

```powershell
# --- 2026-09-19/AC4: an English lead-in under /fr/ fails, naming file and line
$d = New-FixtureRepo
Write-Annotation -Dir $d -Locale 'en' -Rel 'skills/atelier-ventes/fr/references/tutorial/03.md' -Days 10
Expect-CheckFail $d 'skills/atelier-ventes/fr/references/tutorial/03.md:5' `
  '2026-09-19/AC4 rejects an English lead-in under /fr/'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC6: a date that is not a real calendar day fails
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') {
  param($t) $t -replace '\*\*Last verified \d{4}-\d{2}-\d{2}\*\*', '**Last verified 2026-02-30**' }
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md:5' `
  '2026-09-19/AC6 rejects 2026-02-30'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC7: a future date fails
$d = New-FixtureRepo
Write-Annotation -Dir $d -Locale 'en' -Rel 'skills/atelier-ventes/en/references/tutorial/03.md' -Days -30
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md:5' `
  '2026-09-19/AC7 rejects a future date'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC8: an absent source segment fails
$d = New-FixtureRepo
Edit-File (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') {
  param($t) $t -replace '\*\* — source:.*', '** no source segment here' }
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md:5' `
  '2026-09-19/AC8 rejects an absent source segment'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC9: an anchored file carrying no annotation fails
$d = New-FixtureRepo
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') "# Module`n`nNo dated claim here.`n"
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/03.md' `
  '2026-09-19/AC9 rejects an anchored file with no dated claim'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC10: an anchored path that does not exist fails
$d = New-FixtureRepo
Add-Content -LiteralPath (Join-Path $d 'skills/dated-claims.tsv') `
  -Value 'skills/atelier-ventes/en/references/tutorial/99-renamed.md'
Expect-CheckFail $d 'skills/atelier-ventes/en/references/tutorial/99-renamed.md' `
  '2026-09-19/AC10 rejects an anchored path that does not exist'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC10b: an absent anchor list is fatal
$d = New-FixtureRepo
Remove-Item -Force -LiteralPath (Join-Path $d 'skills/dated-claims.tsv')
Expect-CheckFail $d 'skills/dated-claims.tsv' `
  '2026-09-19/AC10b rejects an absent anchor list'
Remove-Item -Recurse -Force -LiteralPath $d

# --- 2026-09-19/AC24: the summary line matches bash's, in both its forms
$d = New-FixtureRepo
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -eq 0 -and $r.Output -match 'dated claims: 1 annotations across 1 files, oldest \d{4}-\d{2}-\d{2} \(10 days\)') {
  Add-Pass '2026-09-19/AC24 -Check prints the populated summary line'
} else {
  Add-Failure "2026-09-19/AC24 summary line wrong (exit=$($r.ExitCode), out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d

$d = New-FixtureRepo
Write-Lf (Join-Path $d 'skills/atelier-ventes/en/references/tutorial/03.md') "# Module`n`nNo dated claim here.`n"
$r = Invoke-FixtureCheck $d
if ($r.ExitCode -ne 0 -and $r.Output.Contains('dated claims: 0 annotations across 0 files, no dated claim found')) {
  Add-Pass '2026-09-19/AC24 -Check prints the zero summary line on a failing run'
} else {
  Add-Failure "2026-09-19/AC24 zero summary line wrong (exit=$($r.ExitCode), out=$($r.Output))"
}
Remove-Item -Recurse -Force -LiteralPath $d
```

- [ ] **Step 2: Run them to verify they fail**

Run: `pwsh -File scripts/tests/build_test.ps1 2>&1 | Select-String '2026-09-19'`
Expected: every line begins `FAIL:`.

- [ ] **Step 3: Implement the scanner and validator in `build.ps1`**

Add after `Add-CheckFailure` (near line 43):

```powershell
# --- 2026-09-19/AC14 — the two staleness thresholds, named once.
$ReportAgeDays = 180
$FailAgeDays   = 365

$DatedClaimsTsv = Join-Path $SkillsDir 'dated-claims.tsv'
$script:DatedClaimRecords = @()

# --- 2026-09-19/AC12, AC13, AC3b — every *.md at any depth under
# skills/<skill>/<locale>/references/, in lexicographic repo-relative order.
#
# Divergence from build.sh: PowerShell has real DateTime parsing, so the civil
# algorithm build.sh inlines into awk (because `date -d` is GNU-only) has no
# counterpart here. ParseExact with a fixed 'yyyy-MM-dd' format doubles as the
# calendar-validity test — 2026-02-30 throws.
function Get-DatedClaimRecords {
  $records = [System.Collections.Generic.List[object]]::new()
  $today = (Get-Date).Date

  $files = foreach ($canonical in Get-SkillList) {
    foreach ($locale in $AllLocales) {
      $dir = Join-Path (Join-Path (Join-Path $SkillsDir $canonical) $locale) 'references'
      if (-not (Test-Path -LiteralPath $dir)) { continue }
      foreach ($f in Get-ChildItem -LiteralPath $dir -Filter '*.md' -File -Recurse) {
        [pscustomobject]@{
          Rel    = ($f.FullName.Substring($RepoRoot.Length + 1) -replace '\\', '/')
          Full   = $f.FullName
          Locale = $locale
        }
      }
    }
  }

  foreach ($file in ($files | Sort-Object -Property Rel -CaseSensitive)) {
    if ($file.Locale -ceq 'en') {
      $lead = '> **Last verified '; $sep = '** — source: '
      $own  = 'Last verified';      $other = 'Vérifié le'
    } else {
      $lead = '> **Vérifié le ';    $sep = '** — source : '
      $own  = 'Vérifié le';         $other = 'Last verified'
    }

    $lineNo = 0
    $fence = $false
    foreach ($raw in [System.IO.File]::ReadAllLines($file.Full)) {
      $lineNo++
      $line = $raw -replace "`r$", ''
      if ($line.StartsWith('```')) { $fence = -not $fence; continue }
      if ($fence) { continue }
      if (-not $line.StartsWith('> **')) { continue }

      $hasOwn = $line.Contains($own)
      $hasOther = $line.Contains($other)
      if (-not $hasOwn -and -not $hasOther) { continue }

      $verdict = 'ok'; $date = ''
      if (-not $hasOwn) {
        $verdict = 'wrong-locale'
      } elseif (-not $line.StartsWith($lead)) {
        $verdict = 'bad-leadin'
      } else {
        $rest = $line.Substring($lead.Length)
        if ($rest.Length -lt 10) {
          $verdict = 'no-date'
        } else {
          $date = $rest.Substring(0, 10)
          $tail = $rest.Substring(10)
          $parsed = [datetime]::MinValue
          if (-not [datetime]::TryParseExact($date, 'yyyy-MM-dd',
                [cultureinfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::None, [ref]$parsed)) {
            # Shape-right-but-impossible and shape-wrong are different
            # failures (2026-09-19/AC5 vs AC6), so separate them here the way
            # build.sh's awk does.
            if ($date -match '^\d{4}-\d{2}-\d{2}$') { $verdict = 'bad-date' }
            else { $verdict = 'no-date'; $date = '' }
          } elseif ($parsed -gt $today) {
            $verdict = 'future-date'
          } elseif (-not $tail.StartsWith($sep)) {
            $verdict = 'no-source'
          } elseif ($tail.Substring($sep.Length).Trim() -eq '') {
            $verdict = 'no-source'
          }
        }
      }

      $records.Add([pscustomobject]@{
        Rel = $file.Rel; Line = $lineNo; Locale = $file.Locale
        Date = $date; Verdict = $verdict
      })
    }
  }
  return , $records.ToArray()
}

# --- 2026-09-19/AC4–AC8
function Test-DatedClaims {
  $script:DatedClaimRecords = Get-DatedClaimRecords
  foreach ($r in $script:DatedClaimRecords) {
    switch ($r.Verdict) {
      'ok' { }
      'wrong-locale' { Add-CheckFailure "$($r.Rel):$($r.Line) — carries the other locale's verified lead-in (this file is $($r.Locale))" }
      'bad-leadin'   { Add-CheckFailure "$($r.Rel):$($r.Line) — malformed verified lead-in for locale $($r.Locale)" }
      'no-date'      { Add-CheckFailure "$($r.Rel):$($r.Line) — verified annotation has no YYYY-MM-DD in its bold span" }
      'bad-date'     { Add-CheckFailure "$($r.Rel):$($r.Line) — '$($r.Date)' is not a real calendar day" }
      'future-date'  { Add-CheckFailure "$($r.Rel):$($r.Line) — verified date '$($r.Date)' is later than today ($((Get-Date).Date.ToString('yyyy-MM-dd')))" }
      'no-source'    { Add-CheckFailure "$($r.Rel):$($r.Line) — verified annotation names no source after the em dash" }
      default        { Add-CheckFailure "$($r.Rel):$($r.Line) — unrecognized dated-claim verdict '$($r.Verdict)'" }
    }
  }
  Test-DatedClaimAnchors
}

# --- 2026-09-19/AC9, AC10, AC10b, AC26 — never hard-codes an anchor path.
function Test-DatedClaimAnchors {
  if (-not (Test-Path -LiteralPath $DatedClaimsTsv)) {
    Add-CheckFailure 'skills/dated-claims.tsv — anchor list not found'
    return
  }
  $detected = @{}
  foreach ($r in $script:DatedClaimRecords) { $detected[$r.Rel] = $true }
  foreach ($raw in [System.IO.File]::ReadAllLines($DatedClaimsTsv)) {
    $p = ($raw -split "`t")[0].TrimEnd("`r")
    if ([string]::IsNullOrWhiteSpace($p)) { continue }
    if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot $p) -PathType Leaf)) {
      Add-CheckFailure "$p — listed in skills/dated-claims.tsv but no such file (renamed?)"
      continue
    }
    if (-not $detected.ContainsKey($p)) {
      Add-CheckFailure "$p — listed in skills/dated-claims.tsv but carries no dated claim"
    }
  }
}

# --- 2026-09-19/AC15, AC15b, AC15c, AC16, AC17. Never touches
# $script:CheckFailures: age alone must not redden a pull request (AC23).
function Show-DatedClaimReport {
  $valid = @($script:DatedClaimRecords | Where-Object { $_.Verdict -ceq 'ok' })
  if ($valid.Count -eq 0) {
    Write-Host 'dated claims: 0 annotations across 0 files, no dated claim found'
    return
  }
  $today = (Get-Date).Date
  $fileCount = ($valid | Select-Object -ExpandProperty Rel -Unique).Count
  # Sort is stable and the records are already in scan order, so a tie keeps
  # the first of them (2026-09-19/AC3b).
  $oldest = $valid | Sort-Object -Property { [datetime]::ParseExact($_.Date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture) } | Select-Object -First 1
  $age = ($today - [datetime]::ParseExact($oldest.Date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)).Days
  Write-Host "dated claims: $($valid.Count) annotations across $fileCount files, oldest $($oldest.Date) ($age days)"
  if ($script:CheckFailures -eq 0 -and $age -ge $ReportAgeDays) {
    Write-Host "NOTE: oldest dated claim is $age days old (report threshold $ReportAgeDays) —"
    Write-Host "      $($oldest.Rel):$($oldest.Line)"
    Write-Host '      see docs/tutorial-corpus.md, "Claims to re-verify"'
  }
}
```

- [ ] **Step 4: Wire it into `Invoke-Checks`**

```powershell
  # Repo-wide, not per-locale: run it once.
  Test-VersionCoherence
  # 2026-09-19/AC13 — the scanner finds its own files, so it runs once here.
  Test-DatedClaims
```

and immediately before the status line at the end of `Invoke-Checks`:

```powershell
  # 2026-09-19/AC15 — before STATUS:, on every run that reaches it.
  Show-DatedClaimReport

  if ($script:CheckFailures -gt 0) {
```

- [ ] **Step 5: Add `-CheckFreshness`**

Add the parameter to the `param()` block and document it in the comment-based help:

```powershell
.PARAMETER CheckFreshness
  Validate every dated capability claim and fail if the oldest has passed the
  freshness threshold. Builds nothing and writes nothing to dist/. Mirrors
  build.sh's --check-freshness. No CI job calls this on Windows by design; it
  exists so the twin stays a twin.
```

```powershell
  [switch]$Check,
  [switch]$CheckFreshness
```

Then the entry point, added after `Show-DatedClaimReport`:

```powershell
# --- 2026-09-19/AC19–AC22
function Invoke-FreshnessCheck {
  Test-DatedClaims
  if ($script:CheckFailures -gt 0) {
    Write-Host "STATUS: FAIL ($script:CheckFailures check failures)"
    return 1
  }
  $today = (Get-Date).Date
  $aged = foreach ($r in ($script:DatedClaimRecords | Where-Object { $_.Verdict -ceq 'ok' })) {
    $age = ($today - [datetime]::ParseExact($r.Date, 'yyyy-MM-dd', [cultureinfo]::InvariantCulture)).Days
    [pscustomobject]@{ Rel = $r.Rel; Line = $r.Line; Date = $r.Date; Age = $age }
  }
  if (-not ($aged | Where-Object { $_.Age -ge $FailAgeDays })) {
    Write-Host "dated claims: every claim is younger than $FailAgeDays days"
    return 0
  }
  Write-Host "Dated capability claims are past the freshness threshold (fail threshold $FailAgeDays days,"
  Write-Host "listing everything at or over $ReportAgeDays days):"
  foreach ($a in ($aged | Where-Object { $_.Age -ge $ReportAgeDays })) {
    Write-Host "  $($a.Rel):$($a.Line) $($a.Date) ($($a.Age) days)"
  }
  return 1
}
```

And short-circuit in the main body, right after the `$NamesTsv` guard near line 570:

```powershell
if (-not (Test-Path -LiteralPath $NamesTsv)) { throw "ERROR: missing $NamesTsv" }

# 2026-09-19/AC19 — stages nothing and writes nothing to dist/, so it returns
# before any of the build machinery below. No managed temp dir is created, so
# there is nothing for Remove-ManagedTempDirs to sweep.
if ($CheckFreshness) {
  exit (Invoke-FreshnessCheck)
}
```

- [ ] **Step 6: Run the PowerShell tests**

Run: `pwsh -File scripts/tests/build_test.ps1`
Expected: `STATUS: PASS`.

- [ ] **Step 7: Confirm the twins agree on the real repo**

```bash
bash scripts/build.sh --check 2>&1 | grep '^dated claims:'
pwsh -File scripts/build.ps1 -Check 2>&1 | grep '^dated claims:'
pwsh -File scripts/build.ps1 -CheckFreshness; echo "exit=$?"
```

Expected: the first two print the identical line, `dated claims: 19 annotations across 6 files, oldest 2026-08-10 (40 days)`. A divergence here means one scanner is missing files — fix before committing. The third prints `dated claims: every claim is younger than 365 days` with `exit=0`.

- [ ] **Step 8: Confirm AC14 holds in the PowerShell script too**

```bash
grep -nE '(^|[^A-Za-z0-9_$])(180|365)([^0-9]|$)' scripts/build.ps1 | grep -vE '\$(ReportAgeDays|FailAgeDays) *='
```

Expected: no output.

- [ ] **Step 9: Run the whole gate and commit**

```bash
bash scripts/build.sh --check && \
bash scripts/tests/shared_test.sh && \
bash scripts/tests/authoring_test.sh && \
bash scripts/tests/build_test.sh && \
pwsh -File scripts/tests/build_test.ps1
git add scripts/build.ps1 scripts/tests/build_test.ps1
git commit -m "feat(build): mirror the dated-claims check in the PowerShell twin"
```

---

## Task 6: The scheduled workflow

Monthly on the first, filing one label-guarded issue. The job exits 0 either way: green means the job ran, and the finding lives in the issue. A workflow that stayed permanently red once it tripped would teach everyone to ignore the Actions tab, which is the same failure this design rejects for pull requests. This is AC28–AC32 and AC30b.

**Files:**
- Create: `.github/workflows/dated-claims.yml`

**Interfaces:**
- Consumes: `bash scripts/build.sh --check-freshness` from Task 4; the `stale-claims` label, already created on the repository.
- Produces: nothing other tasks read.

- [ ] **Step 1: Confirm the label exists**

```bash
gh label list -R Heyian/atelier --search stale-claims
```

Expected: a `stale-claims` row. The spec records it as created on 2026-09-19 with the user's approval. If it is absent, recreate it before going further:

```bash
gh label create stale-claims -R Heyian/atelier --color fbca04 \
  --description "A shipped capability claim's last-verified date is past the freshness threshold"
```

- [ ] **Step 2: Write the workflow**

```bash
cat > .github/workflows/dated-claims.yml <<'EOF'
# 2026-09-19/AC28–AC32 — monthly freshness sweep for dated capability claims.
#
# The job always exits 0. Green means the sweep ran; the finding lives in the
# issue. A workflow that stayed permanently red once it tripped would teach
# everyone to ignore the Actions tab, which is the same failure this design
# rejects for pull requests.
name: dated claims

on:
  # 2026-09-19/AC28 — the first of every month.
  schedule:
    - cron: '0 6 1 * *'
  workflow_dispatch:

permissions:
  contents: read
  issues: write

jobs:
  freshness:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v7

      - name: Check dated-claim freshness
        id: freshness
        run: |
          set +e
          report="$(bash scripts/build.sh --check-freshness 2>&1)"
          rc=$?
          set -e
          echo "$report"
          {
            echo "rc=$rc"
            echo 'report<<DATED_CLAIMS_REPORT_EOF'
            echo "$report"
            echo 'DATED_CLAIMS_REPORT_EOF'
          } >> "$GITHUB_OUTPUT"

      # 2026-09-19/AC29, AC30, AC30b — files at most one issue, and only on a
      # non-zero freshness exit. Matching is on the LABEL, never on issue title
      # text, so a wording change cannot produce a duplicate every month
      # (2026-09-19/AC32).
      - name: File an issue when a claim is stale
        if: steps.freshness.outputs.rc != '0'
        env:
          GH_TOKEN: ${{ github.token }}
          REPORT: ${{ steps.freshness.outputs.report }}
        run: |
          open_count="$(gh issue list --label stale-claims --state open --json number --jq 'length')"
          if [ "$open_count" != "0" ]; then
            echo "An open stale-claims issue already exists; not filing another."
            exit 0
          fi
          {
            printf '%s\n\n' "$REPORT"
            printf 'Re-verify each claim above against its named source, then update the\n'
            printf 'annotation date in the module and the `Claims to re-verify` index in\n'
            printf '`docs/tutorial-corpus.md`.\n'
          } > issue-body.md
          gh issue create \
            --label stale-claims \
            --title 'Dated capability claims are past the freshness threshold' \
            --body-file issue-body.md
EOF
```

- [ ] **Step 3: Verify the YAML parses and the pins are current**

```bash
python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/dated-claims.yml')); print('yaml ok')"
gh api repos/actions/checkout/releases --jq '.[].tag_name' | head -3
```

Expected: `yaml ok`, and `v7` at or near the top of the release list — `ci.yml` and `release-please.yml` already pin `actions/checkout@v7`, and AC28 requires the same. If the current major has moved past v7, read that major's release notes before bumping, and bump all three workflows together rather than leaving this one out of step.

- [ ] **Step 4: Verify the trigger and permissions against AC28**

```bash
python3 - <<'PY'
import yaml
w = yaml.safe_load(open('.github/workflows/dated-claims.yml'))
on = w.get(True, w.get('on'))   # PyYAML reads a bare `on:` key as the boolean True
assert on['schedule'] == [{'cron': '0 6 1 * *'}], on['schedule']
assert 'workflow_dispatch' in on
assert w['permissions'] == {'contents': 'read', 'issues': 'write'}, w['permissions']
print('AC28 ok')
PY
```

Expected: `AC28 ok`. The cron's third field is `1` — the first day of the month, not merely "some monthly schedule".

- [ ] **Step 5: Dry-run the issue-body assembly locally**

The workflow's issue step cannot run outside Actions, so rehearse its body assembly against real freshness output to confirm the pointer lands:

```bash
REPORT="$(bash scripts/build.sh --check-freshness 2>&1)"
{
  printf '%s\n\n' "$REPORT"
  printf 'Re-verify each claim above against its named source, then update the\n'
  printf 'annotation date in the module and the `Claims to re-verify` index in\n'
  printf '`docs/tutorial-corpus.md`.\n'
} | tee /dev/stderr | grep -qF 'Claims to re-verify' && echo "AC29 pointer present"
```

Expected: the rendered body, then `AC29 pointer present`.

- [ ] **Step 6: Verify AC30, AC30b, AC31 and AC32 structurally**

A GitHub Actions job cannot be unit-tested from here, so these four are
asserted against the workflow's own text. Each maps to one line of YAML, and
each would be a silent monthly bug if it drifted.

```bash
python3 - <<'PY'
import re, yaml
src = open('.github/workflows/dated-claims.yml').read()
w = yaml.safe_load(src)
steps = w['jobs']['freshness']['steps']
issue = [s for s in steps if 'gh issue create' in str(s.get('run', ''))]
assert len(issue) == 1, f"expected exactly one issue-creating step, got {len(issue)}"
step = issue[0]

# AC30b — the step is gated on a non-zero freshness exit, so a green sweep
# never files anything.
assert step['if'].strip() == "steps.freshness.outputs.rc != '0'", step['if']

# AC30 — an existing open issue short-circuits before gh issue create.
run = step['run']
assert 'gh issue list --label stale-claims --state open' in run
assert run.index('gh issue list') < run.index('gh issue create')
assert 'exit 0' in run.split('gh issue create')[0]

# AC32 — matching is on the label alone, never on title text.
assert '--search' not in run and 'issue list --search' not in run
lookup = [l for l in run.splitlines() if 'gh issue list' in l][0]
assert '--label stale-claims' in lookup and 'title' not in lookup, lookup

# AC31 — nothing in the job propagates a non-zero status: the freshness step
# swallows rc, and the issue step exits 0 on both branches.
fresh = [s for s in steps if s.get('id') == 'freshness'][0]
assert 'set +e' in fresh['run'] and 'rc=$?' in fresh['run']
assert not any('exit 1' in str(s.get('run', '')) for s in steps)

print('AC30, AC30b, AC31, AC32 ok')
PY
```

Expected: `AC30, AC30b, AC31, AC32 ok`.

- [ ] **Step 7: Commit**

```bash
git add .github/workflows/dated-claims.yml
git commit -m "ci: sweep dated capability claims monthly and file one issue"
```

---

## Task 7: ADR 0015 and the ADR 0011 pointer

The design passes the three-criteria gate on all three counts — hard to reverse (the annotation grammar becomes a contract six shipped files must satisfy), surprising without context (a future reader finds a check that deliberately refuses to fail on the thing it checks for), and a real trade-off (hard-failing in `--check` was a live option). This is AC37 and AC38.

**Files:**
- Create: `docs/adr/0015-staleness-policy-for-dated-claims.md`
- Modify: `docs/adr/0011-dated-capability-claims-in-shipped-references.md`

- [ ] **Step 1: Read the neighbours for the house format**

```bash
sed -n '1,40p' docs/adr/0014-scenario-run-transcripts.md
grep -n "no owner in automation" -B 6 -A 6 docs/adr/0011-dated-capability-claims-in-shipped-references.md
```

Match ADR-0014's heading structure and front-matter exactly — do not invent a new shape. The second command locates the precise line AC38 requires the pointer to sit at.

- [ ] **Step 2: Write ADR-0015**

Follow the structure the previous command printed. The content AC37 requires:

- **Status:** Accepted, dated 2026-09-19.
- **Context:** ADR-0011 lets dated capability claims ship on condition that each carries a last-verified date and a named source, and its own Consequences section records that the re-verification obligation "has no owner in automation yet." Nineteen annotations ship, all dated 2026-08-10, and nothing in the repository knows that.
- **Decision**, in three parts:
  1. **The annotation grammar is the machine-readable contract.** `> **Last verified YYYY-MM-DD** — source: <text>` under `/en/`, `> **Vérifié le YYYY-MM-DD** — source : <text>` under `/fr/`, em dash U+2014, single spaces, French keeping its space before the colon. Detection is looser than validation: any `> **` line carrying either locale's marker is detected and must then satisfy its own locale's pattern, so a typo makes the check fail rather than making the line invisible.
  2. **Two tiers, with named thresholds.** `REPORT_AGE_DAYS=180` prints a note; `FAIL_AGE_DAYS=365` fails `--check-freshness`. The year comes from issue #18's own framing — worth having "before the first claim goes a year unchecked" — with a nudge at the halfway mark. Thirty days, which ADR-0011's "capabilities shift monthly" language would literally imply, would fire permanently and train everyone to ignore it.
  3. **Age never reddens a pull request.** `--check` reports; only the scheduled `--check-freshness` job fails.
- **Alternatives considered**, both named with the reason for rejection:
  - *Hard-failing in `--check` on age*, the `check_whats_new` shape issue #18 names as precedent. Rejected because `check_whats_new` fires on a **change** a contributor made in that pull request, and can be fixed in it. Age fires on the calendar: it would redden a pull request whose author touched nothing related and cannot fix it, which trains reviewers to merge through red.
  - *A separate machine-readable marker* alongside the prose, `<!-- verified: 2026-08-10 -->`. Rejected because it puts the same date in two places that can drift — precisely the failure `check_reference_pointer_drift` exists to catch elsewhere in this repository.
- **Consequences:** the grammar is now load-bearing for six shipped files and every future module; loosening it later is easy, tightening it is not. `skills/dated-claims.tsv` is the mechanically decidable stand-in for ADR-0011's real rule — no script can decide whether a sentence is capability-sensitive, but it can notice that a module known to be full of such claims has ended up with none.

- [ ] **Step 3: Add the pointer to ADR-0011**

At the line Step 1 located — where ADR-0011 states the re-verification obligation has no owner in automation — append a pointer sentence in that file's own voice, the way ADR-0008 was pointed at ADR-0014:

```
This is now owned: see ADR-0015, which makes the annotation grammar a
machine-readable contract, reports the oldest claim's age on every `--check`
run, and fails a monthly job once a claim passes a year.
```

ADR-0011 is **amended, not superseded** — its decision stands unchanged; only this consequence gains a successor. Do not change its Status line.

- [ ] **Step 4: Verify both AC37 and AC38 mechanically**

```bash
test -f docs/adr/0015-staleness-policy-for-dated-claims.md && echo "AC37 file exists"
grep -qF '180' docs/adr/0015-staleness-policy-for-dated-claims.md && \
  grep -qF '365' docs/adr/0015-staleness-policy-for-dated-claims.md && echo "AC37 both thresholds recorded"
grep -qiF 'hard-fail' docs/adr/0015-staleness-policy-for-dated-claims.md && echo "AC37 rejected alternative named"
grep -n 'ADR-0015' docs/adr/0011-dated-capability-claims-in-shipped-references.md
```

Expected: the three `echo`s, and at least one ADR-0015 hit in ADR-0011.

- [ ] **Step 5: Run the gate and commit**

```bash
bash scripts/build.sh --check && \
bash scripts/tests/shared_test.sh && \
bash scripts/tests/authoring_test.sh && \
bash scripts/tests/build_test.sh
git add docs/adr/0015-staleness-policy-for-dated-claims.md \
        docs/adr/0011-dated-capability-claims-in-shipped-references.md
git commit -m "docs(adr): record the staleness policy for dated claims"
```

---

## Task 8: `docs/AUTHORING.md` and its test

Authoring standards are what a skill author reads before writing a claim; the check is only the enforcement. This is AC39 and AC40.

**Files:**
- Modify: `docs/AUTHORING.md`
- Modify: `scripts/tests/authoring_test.sh`

- [ ] **Step 1: Write the failing test first**

Add to `scripts/tests/authoring_test.sh`, after the last `require_heading` line:

```bash
require_heading "## Dated capability claims"
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash scripts/tests/authoring_test.sh`
Expected: `FAIL: AUTHORING.md missing section '## Dated capability claims'` and `STATUS: FAIL (1)`.

- [ ] **Step 3: Add the section**

Append to `docs/AUTHORING.md`, matching the surrounding sections' voice and depth:

```markdown
## Dated capability claims

A claim about what Claude can do today is capability-sensitive: which surfaces
run plugins, which reach local folders, what an interface labels a thing.
Capabilities shift month to month, so a claim that ships without a date reads
as authoritative forever. ADR-0011 lets such a claim ship on one condition —
it carries a last-verified date and a named source in the same file.

Write the annotation as a blockquote directly under the claim. The lead-in is
exact; `bash scripts/build.sh --check` validates it and names the file and line
when it does not match.

English:

    > **Last verified 2026-08-10** — source: Anthropic help center, article
    > 15520349 ("Use Claude Cowork on web, desktop, and mobile").

French:

    > **Vérifié le 2026-08-10** — source : centre d'aide Anthropic, article
    > 15520349 (« Use Claude Cowork on web, desktop, and mobile »).

The dash is an em dash (—, U+2014) with one space either side. French keeps the
space before the colon that its typography requires; English does not. Only the
first line is validated — everything after it is free prose the check never
reads, so put the article title and the "show the executive this date"
instruction there.

A module that carries such claims belongs in `skills/dated-claims.tsv`. Every
file listed there must keep at least one annotation, which is what catches a
translation pass or a bad merge that drops the last one.

Nothing here judges whether the date is *correct* — only that it is present,
well formed, not in the future, and not old. Re-verifying a claim is a human
act; `bash scripts/build.sh --check` reports the oldest claim's age on every
run, and a monthly job files an issue once one passes a year.
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `bash scripts/tests/authoring_test.sh`
Expected: `ok: ## Dated capability claims` and `STATUS: PASS`.

- [ ] **Step 5: Confirm the fenced examples did not break `--check`**

The examples above are indented code blocks, not ``` fences, and `AUTHORING.md` lives under `docs/` which AC12 excludes from the scan. Both facts should hold:

```bash
bash scripts/build.sh --check 2>&1 | grep '^dated claims:'
```

Expected: still `dated claims: 19 annotations across 6 files, oldest 2026-08-10 (40 days)`. A count of 21 would mean the scan reached `docs/`.

- [ ] **Step 6: Run the gate and commit**

```bash
bash scripts/build.sh --check && \
bash scripts/tests/shared_test.sh && \
bash scripts/tests/authoring_test.sh && \
bash scripts/tests/build_test.sh
git add docs/AUTHORING.md scripts/tests/authoring_test.sh
git commit -m "docs(shared): document the dated capability claim annotation"
```

---

## Task 9: `CLAUDE.md`

The agent index is an INDEX, loaded into every conversation, so every line costs tokens forever. Two lines only — the new command, and the citation convention. The design stays in the spec. This is AC41 and AC42.

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Add the command line**

In `CLAUDE.md`, under `## Commands`, directly after the `--check` line:

```markdown
- `bash scripts/build.sh --check-freshness` — validate dated capability claims and fail past the freshness threshold
```

- [ ] **Step 2: Add the citation convention**

Under `## Branches and commits`, as one bullet:

```markdown
- A comment citing an acceptance criterion names its spec: `2026-09-19/AC3`.
  Six specs each number from `AC1` and five define an `AC15`, so a bare `ACn`
  is ambiguous. Existing bare citations stay as they are.
```

- [ ] **Step 3: Verify AC41's line ceiling**

```bash
wc -l < CLAUDE.md
```

Expected: well under 300. It was 53 before this task; four added lines puts it near 57. If it ever approaches 250, move content to the docs dir rather than trimming this entry.

- [ ] **Step 4: Verify AC42 across everything this branch touched**

Every AC citation added by this work must be qualified with the spec date. Bare citations that predate this branch stay.

```bash
git diff dev...HEAD -- scripts/build.sh scripts/build.ps1 \
  | grep '^+' | grep -oE '(^|[^/0-9])AC[0-9]+[a-z]?' \
  | grep -vE '2026-09-19/' || echo "AC42 ok — every new citation is qualified"
```

Expected: `AC42 ok — every new citation is qualified`. Any output means a bare `ACn` slipped into a new comment — qualify it.

- [ ] **Step 5: Run the gate and commit**

```bash
bash scripts/build.sh --check && \
bash scripts/tests/shared_test.sh && \
bash scripts/tests/authoring_test.sh && \
bash scripts/tests/build_test.sh
git add CLAUDE.md
git commit -m "docs: index the freshness command and the AC citation convention"
```

---

## Task 10: Verify the deferred item

The spec's Deferred Items section lists one issue. A deferral is only real if the issue exists and carries all four body sections; a one-liner saying "do this later" is a forgotten item, not a deferral.

- [ ] **Step 1: Read the issue body**

```bash
gh issue view 36 --json title,state,body --jq '.title, .state'
gh issue view 36 --json body --jq -r .body | grep -cE '^#+ *(Context|Required|Integration Points|Priority)'
```

Expected: the title matches "Corpus and module verification dates can drift apart after a re-verification pass", the state is `OPEN`, and the count is `4`.

- [ ] **Step 2: Fix it if short**

If the count is under 4, add the missing sections now — context is freshest while this work is in hand:

```bash
gh issue view 36 --json body --jq -r .body > /tmp/issue36.md
# edit /tmp/issue36.md to add the missing headings and their content
gh issue edit 36 --body-file /tmp/issue36.md
```

If the count is 4, change nothing.

---

## Task 11: Verify every required task actually landed

Read the diff. Do not trust the checkboxes above — a task can be marked done and still have left a file untouched.

- [ ] **Step 1: Confirm every file the spec's impact tables name was touched**

```bash
git diff --stat dev...HEAD
```

Expected, every one of these present:

| File | From |
|---|---|
| `.github/workflows/dated-claims.yml` | Config impact — create |
| `skills/dated-claims.tsv` | Config impact — create |
| `scripts/build.sh` | Config impact — scanner, validator, reporter, `--check-freshness`, thresholds |
| `scripts/build.ps1` | Config impact — the twin |
| `scripts/tests/build_test.sh` | Config impact — AC33–AC35 |
| `scripts/tests/build_test.ps1` | Config impact — AC36 |
| `scripts/tests/authoring_test.sh` | Config impact — the `require_heading` line |
| `CLAUDE.md` | Config impact + docs — two lines |
| `docs/adr/0015-staleness-policy-for-dated-claims.md` | Docs — create |
| `docs/adr/0011-dated-capability-claims-in-shipped-references.md` | Docs — the pointer |
| `docs/AUTHORING.md` | Docs — the new section |

And every one of these **absent**: `version.txt`, any `SKILL.md`, `README.md`, `release-please-config.json`, `.github/workflows/ci.yml`, `docs/tutorial-corpus.md`.

- [ ] **Step 2: Confirm AC43 — no shipped annotation date moved**

```bash
git diff dev...HEAD -- 'skills/atelier-mentor/**' | grep -E '^[+-].*(Last verified|Vérifié le)' \
  || echo "AC43 ok — no shipped annotation line changed"
grep -rhoE '(Last verified|Vérifié le) [0-9]{4}-[0-9]{2}-[0-9]{2}' skills/atelier-mentor \
  | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | sort -u
```

Expected: `AC43 ok — no shipped annotation line changed`, and exactly one date, `2026-08-10`. Test fixtures compute their dates from the run date (AC35) and are not shipped reference files, so they are outside this check.

- [ ] **Step 3: Confirm the criteria with no test of their own**

AC12's exclusion, AC13's once-only scan, and AC26's no-hard-coded-paths are structural — assert them directly:

```bash
# AC12 — docs/ is not scanned
grep -n 'tutorial-corpus' scripts/build.sh | grep -v '^\s*#' \
  || echo "AC12 ok — build.sh references docs/tutorial-corpus.md only in the note text"

# AC13 — check_dated_claims is called exactly once, outside the locale loop
grep -c '^\s*check_dated_claims$' scripts/build.sh

# AC26 — neither script hard-codes an anchor path
grep -nE 'atelier-mentor/(en|fr)/references' scripts/build.sh scripts/build.ps1 \
  || echo "AC26 ok — no anchor path is hard-coded in either script"

# AC18 — the age arithmetic never reaches for `date -d`, which is GNU-only and
# would break for a contributor on macOS
grep -nE "date +-d|date +--date" scripts/build.sh scripts/tests/build_test.sh \
  || echo "AC18 ok — no date -d anywhere in the script or its tests"
```

Expected: the AC12 message (the only `tutorial-corpus` mention is inside the note string), `1` for AC13, and the AC26 and AC18 messages.

- [ ] **Step 4: Fix anything missing, then re-run this task**

Do not proceed to Task 12 with a gap. Each miss belongs to a numbered task above — go back to that task, land it with its own test and commit, then run Task 11 again from Step 1.

---

## Task 12: Final build

Type-checks and tests alone do not catch all build-time failures. This task is non-negotiable.

- [ ] **Step 1: Run the full build**

```bash
bash scripts/build.sh --lang all
```

Expected: one ZIP per skill per locale in `dist/`, no errors. Fix anything that surfaces and re-run until it builds cleanly.

- [ ] **Step 2: Run every check and every test suite once more**

```bash
bash scripts/build.sh --check && \
bash scripts/build.sh --check-freshness && \
bash scripts/tests/shared_test.sh && \
bash scripts/tests/authoring_test.sh && \
bash scripts/tests/build_test.sh && \
pwsh -File scripts/tests/build_test.ps1 && \
pwsh -File scripts/build.ps1 -Check
```

Expected: `STATUS: PASS` from each, and the identical `dated claims: 19 annotations across 6 files, oldest 2026-08-10 (40 days)` line from both `--check` and `-Check`.

- [ ] **Step 3: Confirm `dist/` is not committed**

```bash
git status --porcelain | grep '^?? dist/' && echo "dist/ is untracked, as it should be"
git check-ignore -q dist && echo "dist/ is gitignored"
```

- [ ] **Step 4: Commit anything the build corrected**

If Step 1 required a fix:

```bash
git add -A ':!dist'
git commit -m "fix(build): <what the full build surfaced>"
```

If nothing changed, skip this step.

- [ ] **Step 5: Advisory cross-model review, then finish the branch**

Before wrapping up via `superpowers:finishing-a-development-branch`, run the Codex plugin's adversarial review if it is available, with this focus:

> Judge correctness against the spec's acceptance criteria (AC1–AC43, including AC3b, AC10b, AC15b, AC15c and AC30b) only. Do not flag anything outside the stated criteria — no design alternatives, hardening, or scope the spec did not claim.

This **never gates the merge**. The gate stays `bash scripts/build.sh --check` plus the three test scripts and `bash scripts/build.sh --lang all`; the review only flags what deserves a second look. If no helper is available, finish the branch without it.

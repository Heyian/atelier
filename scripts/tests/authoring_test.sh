#!/usr/bin/env bash
# docs/AUTHORING.md must document every standard the skills are held to.
set -uo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOC="$REPO_ROOT/docs/AUTHORING.md"
FAILURES=0

require_heading() {
  if grep -qF "$1" "$DOC" 2>/dev/null; then
    echo "ok: $1"
  else
    echo "FAIL: AUTHORING.md missing section '$1'"
    FAILURES=$((FAILURES + 1))
  fi
}

require_heading "## Descriptions"
require_heading "## Frontmatter contract"
require_heading "## SKILL.md stays lean"
require_heading "## Match the form to the failure"
require_heading "## Checkable completion criteria"
require_heading "## Role-skill body shape"
require_heading "## The Memory block"
require_heading "## Memory protocol adherence"
require_heading "## Shared glossary"
require_heading "## One excellent example per skill"

echo
if [[ "$FAILURES" -eq 0 ]]; then echo "STATUS: PASS"; exit 0; else echo "STATUS: FAIL ($FAILURES)"; exit 1; fi

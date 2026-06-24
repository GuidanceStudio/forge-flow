#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESIGN="$REPO_ROOT/forge-flow/DESIGN.md"
TDD="$REPO_ROOT/forge-flow/TDD.md"
IDD="$REPO_ROOT/forge-flow/IDD.md"
EXECUTOR_CORE="$REPO_ROOT/forge-flow/EXECUTOR-CORE.md"
SCAFFOLD="$REPO_ROOT/forge-flow/SCAFFOLD.md"
SKILL="$REPO_ROOT/forge-flow/SKILL.md"
ROOT_README="$REPO_ROOT/README.md"
SKILL_README="$REPO_ROOT/forge-flow/README.md"
WORKFLOW="$REPO_ROOT/.github/workflows/tests.yml"

fail() {
    echo "FAIL: $1" >&2
    exit 1
}

contains() {
    local file="$1" text="$2"
    grep -qF "$text" "$file" || fail "$file missing: $text"
}

contains_flat() {
    local file="$1" text="$2"
    tr '\n' ' ' < "$file" | grep -qF "$text" || fail "$file missing: $text"
}

contains "$DESIGN" "#### Essentiality checkpoint"
contains "$DESIGN" "explicit requirement"
contains "$DESIGN" "trust-boundary validation"
contains "$DESIGN" "accessibility"
contains "$DESIGN" "data-loss"
contains "$DESIGN" "project convention"

# Essentiality checkpoint references EXECUTOR-CORE.md
contains "$DESIGN" "Essentiality checkpoint"
contains "$DESIGN" "EXECUTOR-CORE.md"
contains "$DESIGN" "simplification ladder"
contains "$DESIGN" "delete"
contains "$DESIGN" "stdlib"
contains "$DESIGN" "native"
contains "$DESIGN" "existing-dep"
contains "$DESIGN" "smaller-custom"

for readme in "$ROOT_README" "$SKILL_README"; do
    contains "$readme" "DietrichGebert/ponytail"
    contains_flat "$readme" "Conceptual prior art"
    contains_flat "$readme" "Runtime dependency: none"
done

contains "$ROOT_README" "bash tests/test_content.sh"
contains "$WORKFLOW" "bash tests/test_content.sh"

python3 - "$EXECUTOR_CORE" <<'PY'
from pathlib import Path
import sys

steps = (
    "Delete unneeded code",
    "Prefer the standard library",
    "Prefer native platform behavior",
    "Reuse an already-installed dependency",
    "Inline unearned single-use abstractions",
    "Reduce files and branches",
    "Compress or delete comments",
)
boundaries = (
    "all applicable tests",
    "test policy wins",
    "trust-boundary validation",
    "error handling that prevents data loss",
    "security",
    "accessibility",
    "explicit requirements",
    "Done when",
)
text = " ".join(Path(sys.argv[1]).read_text().split())
positions = [text.index(step) for step in steps]
if positions != sorted(positions):
    raise SystemExit(f"FAIL: simplification ladder out of order in {sys.argv[1]}")
lowered = text.lower()
for boundary in boundaries:
    if boundary.lower() not in lowered:
        raise SystemExit(f"FAIL: {sys.argv[1]} missing boundary: {boundary}")
PY

for forbidden in \
    "ONE runnable check" \
    "one small test" \
    "Trivial one-liners need no test" \
    "ACTIVE EVERY RESPONSE"
do
    if grep -qF "$forbidden" "$TDD" "$IDD" "$EXECUTOR_CORE"; then
        fail "executor imported forbidden Ponytail behavior: $forbidden"
    fi
done

# ---- M25: EXECUTOR-CORE.md extraction ----

# File exists
test -f "$EXECUTOR_CORE" || fail "EXECUTOR-CORE.md not found"

# TDD.md and IDD.md both reference it
contains "$TDD" "EXECUTOR-CORE.md"
contains "$IDD" "EXECUTOR-CORE.md"

# Shared sections present in EXECUTOR-CORE.md
contains "$EXECUTOR_CORE" "Operating mode"
contains "$EXECUTOR_CORE" "Preflight"
contains "$EXECUTOR_CORE" "Simplify step"
contains "$EXECUTOR_CORE" "ponytail: comment convention"
contains "$EXECUTOR_CORE" "Register intentional debt"
contains "$EXECUTOR_CORE" "Test policy"
contains "$EXECUTOR_CORE" "Implementation standards"
contains "$EXECUTOR_CORE" "Completion"
contains "$EXECUTOR_CORE" "Common rules"

# Simplification ladder in order in EXECUTOR-CORE.md
python3 - "$EXECUTOR_CORE" <<'PY'
from pathlib import Path
import sys
text = " ".join(Path(sys.argv[1]).read_text().split())
steps = (
    "Delete unneeded code",
    "Prefer the standard library",
    "Prefer native platform behavior",
    "Reuse an already-installed dependency",
    "Inline unearned single-use abstractions",
    "Reduce files and branches",
    "Compress or delete comments",
)
positions = [text.index(step) for step in steps]
if positions != sorted(positions):
    raise SystemExit("FAIL: simplification ladder out of order in EXECUTOR-CORE.md")
PY

# Simplify boundaries in EXECUTOR-CORE.md
python3 - "$EXECUTOR_CORE" <<'PY'
from pathlib import Path
import sys
lowered = " ".join(Path(sys.argv[1]).read_text().split()).lower()
boundaries = (
    "trust-boundary validation",
    "error handling that prevents data loss",
    "security",
    "accessibility",
    "explicit requirements",
    "done when",
)
for boundary in boundaries:
    if boundary.lower() not in lowered:
        raise SystemExit(f"FAIL: EXECUTOR-CORE.md missing boundary: {boundary}")
PY

# Mode-specific timing note in test policy
contains "$EXECUTOR_CORE" "TDD mode, write all applicable test levels BEFORE implementation"
contains "$EXECUTOR_CORE" "IDD mode, write tests AFTER implementation"

# ---- M21-M23: comment essentiality, ponytail: convention, debt tracking ----

# Comment-weight rung present (7th rung of simplify ladder) — canonical in EXECUTOR-CORE.md
contains "$EXECUTOR_CORE" "Compress or delete comments that don't carry their weight"
contains "$EXECUTOR_CORE" "ponytail: comments"

# TDD.md and IDD.md still mention simplify (reference to EXECUTOR-CORE.md)
for playbook in "$TDD" "$IDD"; do
    contains "$playbook" "simplify"
done

# ponytail: comment convention documented — canonical in EXECUTOR-CORE.md
contains "$EXECUTOR_CORE" "ponytail: comment convention"
contains "$EXECUTOR_CORE" "Ceiling:"
contains "$EXECUTOR_CORE" "Upgrade:"
contains "$EXECUTOR_CORE" "measurable threshold"

# Debt registration step present — canonical in EXECUTOR-CORE.md
contains "$EXECUTOR_CORE" "Register intentional debt"
contains "$EXECUTOR_CORE" ".code-audit/debt.tsv"

# Debt count in completion recaps — canonical in EXECUTOR-CORE.md
contains "$EXECUTOR_CORE" "debt registered"

contains_flat "$ROOT_README" "design → implement → simplify"
contains_flat "$SKILL_README" "design → implement → simplify"

# ---- M29: scaffold route ----
test -f "$SCAFFOLD" || fail "SCAFFOLD.md not found"
# Router knows the scaffold route
contains "$SKILL" "scaffold"
contains "$SKILL" "SCAFFOLD.md"
# Generation contract: one-command bring-up + tiered runner
contains "$SCAFFOLD" "one-command bring-up"
contains "$SCAFFOLD" "readiness-poll"
contains "$SCAFFOLD" "run_tests.sh"
contains "$SCAFFOLD" ".env.example"
for tier in unit integration live; do
    contains "$SCAFFOLD" "$tier"
done
contains "$SCAFFOLD" "skip-with-reason"
contains "$SCAFFOLD" "exit code"
# Idempotent generation, never clobber
contains "$SCAFFOLD" "idempotent"
contains "$SCAFFOLD" "never clobber"
# Prod-isolation skeleton
contains "$SCAFFOLD" ".env.test"
# Runnable-app guard
contains "$SCAFFOLD" "runnable"
contains "$SCAFFOLD" "refuse"
# Explicit TODO markers for project-specific bits
contains "$SCAFFOLD" "TODO"
# Documented in both READMEs
contains "$ROOT_README" "scaffold"
contains "$SKILL_README" "scaffold"

# ---- M33: bookkeeping verification gate ----
# Marking a milestone done is a verified, committed gate, not advisory.
contains "$EXECUTOR_CORE" "Verify the bookkeeping landed"
contains "$EXECUTOR_CORE" "no unchecked task may remain for the milestone being closed"
contains "$EXECUTOR_CORE" "Stage the devplan with the milestone"
contains "$EXECUTOR_CORE" "Never commit a milestone whose devplan tasks and heading aren't"
contains "$EXECUTOR_CORE" "Sweep the devplan for unfinished bookkeeping"

echo "content contract passed"

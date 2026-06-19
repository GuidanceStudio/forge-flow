#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESIGN="$REPO_ROOT/devplan/DESIGN.md"
ROOT_README="$REPO_ROOT/README.md"
SKILL_README="$REPO_ROOT/devplan/README.md"
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

python3 - "$DESIGN" <<'PY'
from pathlib import Path
import sys

text = Path(sys.argv[1]).read_text()
steps = (
    "Does the work need to exist",
    "standard library",
    "native platform",
    "already-installed dependency",
    "smaller custom approach",
)
positions = [text.index(step) for step in steps]
if positions != sorted(positions):
    raise SystemExit("FAIL: essentiality checkpoint is not in the required order")
PY

for readme in "$ROOT_README" "$SKILL_README"; do
    contains "$readme" "DietrichGebert/ponytail"
    contains_flat "$readme" "Conceptual prior art"
    contains_flat "$readme" "Runtime dependency: none"
done

contains "$ROOT_README" "bash tests/test_content.sh"
contains "$WORKFLOW" "bash tests/test_content.sh"

echo "content contract passed"

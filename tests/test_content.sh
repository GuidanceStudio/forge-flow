#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESIGN="$REPO_ROOT/forge-flow/DESIGN.md"
TDD="$REPO_ROOT/forge-flow/TDD.md"
IDD="$REPO_ROOT/forge-flow/IDD.md"
EXECUTOR_CORE="$REPO_ROOT/forge-flow/EXECUTOR-CORE.md"
SCAFFOLD="$REPO_ROOT/forge-flow/SCAFFOLD.md"
SKILL="$REPO_ROOT/forge-flow/SKILL.md"
OPENAI_YAML="$REPO_ROOT/forge-flow/agents/openai.yaml"
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

python3 - "$SKILL" <<'PY'
from pathlib import Path
import re
import sys


def fail(message):
    raise SystemExit(f"FAIL: {message}")


path = Path(sys.argv[1])
text = path.read_text()
if not text.startswith("---\n"):
    fail(f"{path} missing opening frontmatter marker")

parts = text.split("---\n", 2)
if len(parts) < 3:
    fail(f"{path} missing closing frontmatter marker")

frontmatter = parts[1]

try:
    import yaml
except ModuleNotFoundError:
    def parse_minimal_frontmatter(block):
        data = {}
        lines = block.splitlines()
        i = 0
        while i < len(lines):
            line = lines[i]
            if not line.strip():
                i += 1
                continue
            if line[:1].isspace():
                fail(f"{path} has unexpected indented frontmatter line: {line!r}")
            if ": " in line:
                key, value = line.split(": ", 1)
            elif line.endswith(":"):
                key, value = line[:-1], ""
            else:
                fail(f"{path} has unparseable frontmatter line: {line!r}")
            if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_-]*", key):
                fail(f"{path} has invalid frontmatter key: {key!r}")
            if value in {">", ">-", "|", "|-"}:
                i += 1
                chunks = []
                while i < len(lines) and (not lines[i].strip() or lines[i].startswith("  ")):
                    chunks.append(lines[i][2:] if lines[i].startswith("  ") else "")
                    i += 1
                if value.startswith(">"):
                    data[key] = " ".join(chunk.strip() for chunk in chunks if chunk.strip())
                else:
                    data[key] = "\n".join(chunks)
                continue
            if value and value[:1] not in {"'", '"'} and ": " in value:
                fail(f"{path} has an unquoted scalar containing ': ': {key}")
            data[key] = value.strip("\"'")
            i += 1
        return data

    meta = parse_minimal_frontmatter(frontmatter)
else:
    meta = yaml.safe_load(frontmatter)

if not isinstance(meta, dict):
    fail(f"{path} frontmatter did not parse to a mapping")
for key in ("name", "description"):
    if key not in meta:
        fail(f"{path} frontmatter missing {key}")
if meta["name"] != "forge-flow":
    fail(f"{path} frontmatter name is not forge-flow")
if not isinstance(meta["description"], str) or "scaffold" not in meta["description"]:
    fail(f"{path} frontmatter description missing scaffold")
PY

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

# ---- M30: DESIGN scaffold pointer ----
contains "$DESIGN" "Reproducibility & test inventory"
contains "$DESIGN" "one-command bring-up"
contains "$DESIGN" "live/e2e tier"
contains "$DESIGN" "Operational spine"
contains "$DESIGN" "default-include proposal"
contains "$DESIGN" "never add a scaffolding milestone"
# M30-unique opt-out clause (M32 says "drops the live task" instead)
contains "$DESIGN" "drops it, recorded under"
contains "$DESIGN" "runnable apps"

# ---- M31: executor reproducibility guardrails ----
# No manual setup — encode in scripts; drive the scaffolded bring-up.
contains "$EXECUTOR_CORE" "No manual setup"
contains "$EXECUTOR_CORE" "never a manual step"
contains "$EXECUTOR_CORE" "Use the scaffolded bring-up"
# First-class live tier with prod isolation.
contains "$EXECUTOR_CORE" "Live tier (first-class, not a fallback)"
contains "$EXECUTOR_CORE" "real, non-prod calls"
contains "$EXECUTOR_CORE" "never run the live tier against prod"
contains "$EXECUTOR_CORE" "skip-with-reason"
contains "$EXECUTOR_CORE" ".env.test"

# ---- M32: DESIGN live test task for external dependencies ----
contains "$DESIGN" "Live test task for external dependencies"
contains "$DESIGN" "real external dependency"
contains "$DESIGN" "Test: live"
contains "$DESIGN" "non-prod credentials"
contains "$DESIGN" "scaffolded live tier"
contains "$DESIGN" "deliberately mocks everything"
# M32-unique opt-out clause (M30 says "drops it, recorded under" instead)
contains "$DESIGN" "drops the live task"

# ---- M36: SCAFFOLD runnable tiers + dispatcher-to-script wiring ----
contains "$SCAFFOLD" "Seed one TODO-marked smoke test per tier"
contains "$SCAFFOLD" "immediately runnable"
contains "$SCAFFOLD" "thin one-line dispatcher"
contains "$SCAFFOLD" "wire the idiom to call it"

# ---- M35: commit-inclusion verification + heading-style done marker ----
contains "$EXECUTOR_CORE" "Verify the devplan shipped in the commit"
contains "$EXECUTOR_CORE" "git show --stat HEAD"
contains "$EXECUTOR_CORE" "## MNN: <title> ✅"

# ---- M37: documentation surfaces aligned to skill name + scaffold route ----
# openai.yaml advertises forge-flow + scaffold, not the pre-rename skill name
contains "$OPENAI_YAML" "forge-flow"
contains "$OPENAI_YAML" "scaffold"
if grep -qF '$devplan' "$OPENAI_YAML"; then fail "openai.yaml still uses old \$devplan invocation"; fi
if grep -qF 'Devplan' "$OPENAI_YAML"; then fail "openai.yaml still uses old Devplan display name"; fi
# SKILL.md frontmatter description advertises the scaffold route
if ! head -6 "$SKILL" | grep -qi 'scaffold'; then fail "SKILL.md frontmatter omits scaffold"; fi
# payload README no longer titled with the pre-rename skill name
if grep -qF '# devplan — skill payload' "$SKILL_README"; then fail "payload README still titled devplan"; fi

# ---- M33: bookkeeping verification gate ----
# Marking a milestone done is a verified, committed gate, not advisory.
contains "$EXECUTOR_CORE" "Verify the bookkeeping landed"
contains "$EXECUTOR_CORE" "no unchecked task may remain for the milestone being closed"
contains "$EXECUTOR_CORE" "Stage the devplan with the milestone"
contains "$EXECUTOR_CORE" "Never commit a milestone whose devplan tasks and heading aren't"
contains "$EXECUTOR_CORE" "Sweep the devplan for unfinished bookkeeping"

# ---- M38: explicit, default-include operational-spine proposal ----
# DESIGN proposes the spine explicitly, default-include, decision recorded in the devplan.
contains "$DESIGN" "propose explicitly"
contains "$DESIGN" "default-include proposal"
contains "$DESIGN" "record the decision in the devplan"
contains "$DESIGN" "no spine"
contains "$DESIGN" "Greenfield"
contains "$DESIGN" "Brownfield"
contains "$DESIGN" "first runnable milestone"
# Executor handles the greenfield day-zero case (no app to wrap yet).
contains "$EXECUTOR_CORE" "first runnable milestone of a greenfield project"

echo "content contract passed"

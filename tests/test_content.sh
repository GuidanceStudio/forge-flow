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

# Whitespace-normalized match: use for phrases that may wrap across lines.
contains_flat() {
    local file="$1" text="$2"
    tr -s '[:space:]' ' ' < "$file" | grep -qF "$text" || fail "$file missing: $text"
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
contains_flat "$DESIGN" "simplify ladder"
contains "$DESIGN" "delete"
contains "$DESIGN" "stdlib"
contains "$DESIGN" "native"
contains "$DESIGN" "existing-dep"

for readme in "$ROOT_README" "$SKILL_README"; do
    contains "$readme" "DietrichGebert/ponytail"
    contains_flat "$readme" "Runtime dependency: none"
done
contains_flat "$ROOT_README" "Conceptual prior art"
# Payload README uses the phrase mid-sentence — lowercase (M44 nit)
contains_flat "$SKILL_README" "is conceptual prior art"

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
contains "$EXECUTOR_CORE" ".tech-audit/debt.tsv"

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

# ---- M40: stuck protocol — root cause before fixes, three-strikes to design review ----
contains "$EXECUTOR_CORE" "## Stuck protocol"
contains "$EXECUTOR_CORE" "root-cause hypothesis grounded in observed evidence"
contains "$EXECUTOR_CORE" "one variable per attempt"
contains "$EXECUTOR_CORE" "re-run the test unchanged once"
contains "$EXECUTOR_CORE" "After three failed attempts on the same failure, stop patching"
contains "$EXECUTOR_CORE" "attempts collectively prove"
contains "$EXECUTOR_CORE" "never a fourth attempt of the same shape"
contains "$EXECUTOR_CORE" "Banned moves"
contains "$EXECUTOR_CORE" "widening an assertion"
contains_flat "$EXECUTOR_CORE" "swallowing the exception"
# Matching ❌ Common rule
contains "$EXECUTOR_CORE" "Never make a fourth same-shape fix attempt"
# Both mode playbooks reference the protocol
contains "$TDD" "Stuck protocol"
contains "$IDD" "Stuck protocol"

# ---- M41: completion gates — evidence before claims, spec fidelity ----
contains "$EXECUTOR_CORE" "Evidence before claims"
contains_flat "$EXECUTOR_CORE" "output and exit code actually read"
contains_flat "$EXECUTOR_CORE" "Cached, remembered, or partial output does not count"
contains_flat "$EXECUTOR_CORE" "not verified — run the command instead"
contains_flat "$EXECUTOR_CORE" "only when it carries the command and its output"
contains "$EXECUTOR_CORE" "Two-verdict self-check"
contains_flat "$EXECUTOR_CORE" "nothing implemented beyond the contract"
contains_flat "$EXECUTOR_CORE" "Never claim completion on stale or unread output"

# ---- M42: DESIGN validation — placeholder scan, coverage, interfaces ----
contains "$DESIGN" "Placeholder scan"
contains_flat "$DESIGN" "defer a decision the plan should make"
contains_flat "$DESIGN" "without naming which errors"
contains "$DESIGN" "Requirement coverage"
contains_flat "$DESIGN" "map each requirement"
contains_flat "$DESIGN" "add a milestone or record it under Out of scope"
contains "$DESIGN" "Interface consistency"
contains_flat "$DESIGN" "the producing milestone's Approach names it"
# Phase 3: staged proposal for large plans
contains_flat "$DESIGN" "present the skeleton first"
contains_flat "$DESIGN" "milestone detail in batches"

# ---- M44: one ladder, one name ----
# DESIGN's checkpoint lists the real 7-rung sequence (no phantom smaller-custom rung)
contains_flat "$DESIGN" "delete → stdlib → native → existing-dep → inline → reduce → compress-comments"
# Canonical name — "simplify ladder" — resolves from every reference
contains_flat "$TDD" "7-rung simplify ladder"
contains_flat "$IDD" "7-rung simplify ladder"
contains_flat "$ROOT_README" "simplify ladder"
contains_flat "$SKILL_README" "simplify ladder"
for stale in "essentiality ladder" "simplification ladder"; do
    if grep -rqF "$stale" "$REPO_ROOT/forge-flow" "$ROOT_README"; then
        fail "stale ladder name still present: $stale"
    fi
done
# README nits: neutral devplan-path example, no payload-dir collision
contains "$ROOT_README" "devplan/v0.3.md"
if grep -qF "forge-flow/v0.3.md" "$ROOT_README"; then
    fail "root README devplan-path example collides with the payload dir"
fi

# ---- M45: in-progress milestone state marker ----
# Three-state marker convention documented in the shared core
contains "$EXECUTOR_CORE" "## Milestone state markers"
contains "$EXECUTOR_CORE" "\`- [~]\`"
contains "$EXECUTOR_CORE" "🔄"
contains_flat "$EXECUTOR_CORE" "working-tree signal, not a separate commit"
# Done-step swaps the in-progress marker for the done marker
contains_flat "$EXECUTOR_CORE" "swap the in-progress \`🔄\` for the done marker"
# Preflight resume-detection keys off the in-progress marker
contains_flat "$EXECUTOR_CORE" "A milestone heading marked \`🔄\`"
# Verify-bookkeeping gate extended to in-progress tasks (M33 phrase preserved)
contains "$EXECUTOR_CORE" "no unchecked task may remain for the milestone being closed"
contains_flat "$EXECUTOR_CORE" "no in-progress \`- [~]\` task either"
# Both mode playbooks mark in-progress at step 1
contains "$TDD" "Mark the milestone in progress in the devplan"
contains "$IDD" "Mark the milestone in progress in the devplan"

# ---- M46: a milestone has a size, and Phase 5 measures it ----
# Written budget in the milestone format
contains "$DESIGN" "#### Milestone budget"
contains_flat "$DESIGN" "A milestone is **≤200 words** when written"
contains_flat "$DESIGN" "Tasks are one line each"
# Anti-restatement: the three pairs that consume the budget first
contains_flat "$DESIGN" "The Why does not repeat the title"
contains_flat "$DESIGN" "the Approach does not repeat the Why"
contains_flat "$DESIGN" "the Done-when does not re-list the tasks"
# Overflow is routed, not compressed
contains_flat "$DESIGN" "What does not fit is not compressed prose"
# Phase 5 measures it
contains "$DESIGN" "**Length check:**"
contains_flat "$DESIGN" "Over budget → split the milestone or route the overflow"

# ---- M47: bounded write-back, and where the rest goes ----
# The write-back is capped and conditional
contains_flat "$EXECUTOR_CORE" "at most 5 lines"
contains_flat "$EXECUTOR_CORE" "only when execution diverged from the plan"
contains_flat "$EXECUTOR_CORE" "the ticks are the record"
# A ticked box is one line — no prose underneath
contains_flat "$EXECUTOR_CORE" "Never write prose under a task box"
contains_flat "$EXECUTOR_CORE" "a new task or a Deviations line"
# Routing table: the four destinations that are not the devplan
contains "$EXECUTOR_CORE" "#### Where the rest goes"
contains_flat "$EXECUTOR_CORE" "Design rationale"
contains_flat "$EXECUTOR_CORE" "the commit body"
contains_flat "$EXECUTOR_CORE" "\`.tech-audit/debt.tsv\`"
# M33's pinned bookkeeping phrase survives the rewrite
contains "$EXECUTOR_CORE" "no unchecked task may remain for the milestone being closed"
# Both mode playbooks point at the bounded block, not an open-ended note
contains_flat "$TDD" "\`**Deviations:**\` block of ≤5 lines"
contains_flat "$IDD" "\`**Deviations:**\` block of ≤5 lines"
for stale in "note deviations and decisions"; do
    if grep -rqF "$stale" "$REPO_ROOT/forge-flow"; then
        fail "open-ended write-back phrasing still present: $stale"
    fi
done

# ---- M48: closed milestones compress on archive ----
contains "$DESIGN" "#### Archive"
contains_flat "$DESIGN" "compresses to one line"
contains_flat "$DESIGN" "MNN | title | date | sha"
contains_flat "$DESIGN" "the sha is the pointer to the detail"
# Archiving is the user's call, like closing a version
contains_flat "$DESIGN" "Never archive on your own initiative"
# The executor never archives
contains_flat "$EXECUTOR_CORE" "Never archive a milestone"

# ---- M49: four gaps the first production application found ----
# A measurement that motivates unstarted work has a destination, and it is here
contains_flat "$DESIGN" "the measurement that justifies work nobody has started"
contains_flat "$EXECUTOR_CORE" "nothing else holds it yet"
# One sha does not address a milestone that closed across several repos
contains_flat "$DESIGN" "In a multi-repo workspace one sha does not resolve"
# The length check measures the milestone as written, not its ticked record
contains_flat "$DESIGN" "ticked task lines are the record of work already done"
# An acceptance gate keeps the evidence under its ticks
contains_flat "$EXECUTOR_CORE" "an **acceptance gate**"

# ---- M50: what a comment carries, in code and in tests ----
contains_flat "$EXECUTOR_CORE" "## Comments A comment carries what the code cannot state itself"
contains_flat "$EXECUTOR_CORE" "the invariant it must hold"
# The three kinds of content git already holds
contains_flat "$EXECUTOR_CORE" "A past date or an incident"
contains_flat "$EXECUTOR_CORE" "A milestone or ticket ID"
contains_flat "$EXECUTOR_CORE" "Markdown or emoji"
# Both carve-outs: a forward deadline stays, rendered doc comments keep markup
contains_flat "$EXECUTOR_CORE" "sunsets 2027-01-01"
contains_flat "$EXECUTOR_CORE" "there the markup is the format"
# The mechanism that grows a comment block once per run
contains_flat "$EXECUTOR_CORE" "Revise the comment, never append to it"
contains_flat "$EXECUTOR_CORE" "65 consecutive comment lines"
# The no-slogans rule reaches code comments
contains_flat "$EXECUTOR_CORE" "No slogans"
# Length routes the overflow, it does not cap the comment
contains_flat "$EXECUTOR_CORE" "Length is a routing signal"
contains_flat "$EXECUTOR_CORE" "It is not a limit"
# Comments in tests: the name carries the why
contains "$EXECUTOR_CORE" "### Comments in tests"
contains_flat "$EXECUTOR_CORE" "A test's **name** carries its why"
contains_flat "$EXECUTOR_CORE" "rename the test and delete the comment"
contains_flat "$EXECUTOR_CORE" "\`# Arrange\` / \`# Act\` / \`# Assert\`"
# Rung 7 defers to the section instead of restating its criteria
contains_flat "$EXECUTOR_CORE" "Apply the rules in \"Comments\""
# Test policy points at the test-specific subsection
contains_flat "$EXECUTOR_CORE" "see \"Comments in tests\""
# The payload README names the new section in EXECUTOR-CORE's contents
contains "$SKILL_README" "comment rules"

echo "content contract passed"

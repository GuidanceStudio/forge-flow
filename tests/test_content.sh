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
contains "$EXECUTOR_CORE" "No manual setup"
contains "$EXECUTOR_CORE" "never a manual step"
contains "$EXECUTOR_CORE" "Use the scaffolded bring-up"
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
# The executor never compresses; relocation is the close-out step (M61)
contains_flat "$EXECUTOR_CORE" "Never compress a closed milestone"

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
contains_flat "$EXECUTOR_CORE" "where the markup is the format"
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

# ---- M51: the carve-outs applying M50 to this repo found ----
contains_flat "$EXECUTOR_CORE" "join key to a document in the same"
contains_flat "$EXECUTOR_CORE" "a **literal being quoted**"
contains_flat "$EXECUTOR_CORE" "verbatim quote of the thing under test"
contains_flat "$EXECUTOR_CORE" "a discriminator explaining why two near-identical anchors both exist"
# The seven restating comments this repo's own pass deleted stay deleted
for restating in \
    "# File exists" \
    "# Documented in both READMEs" \
    "# First-class live tier with prod isolation." \
    "# Three-state marker convention documented in the shared core"
do
    # -x, so the guard's own list of quoted needles is not a match for itself
    if grep -qxF "$restating" "$REPO_ROOT/tests/test_content.sh"; then
        fail "comment restates the assertion below it: $restating"
    fi
done

# ---- M52: a comment check the executor runs, and one scaffold generates ----
contains "$EXECUTOR_CORE" "### Running the check"
contains_flat "$EXECUTOR_CORE" "Every hit is a candidate, not a verdict"
# Scoped to the milestone's files, never the whole repo
contains_flat "$EXECUTOR_CORE" "git diff --name-only --diff-filter=d \"\$BASE\"...HEAD"
contains_flat "$EXECUTOR_CORE" "never the whole repo"
# The emoji branch is a named set, not a non-ASCII test
contains_flat "$EXECUTOR_CORE" "not a general non-ASCII test"
# scaffold generates the CI-side equivalent, diff-scoped with an escape hatch
contains "$SCAFFOLD" "comments\` check in the runner"
contains_flat "$SCAFFOLD" "git merge-base HEAD origin/"
contains_flat "$SCAFFOLD" "The diff scope is what makes it usable"
contains_flat "$SCAFFOLD" "comment-check: ok"
contains_flat "$SCAFFOLD" "the \`comments\` check runs over the merge-base diff"

# ---- M53: explicit paths do not bound a commit — the index does ----
contains_flat "$EXECUTOR_CORE" "A bare \`git commit\` commits the whole index"
contains_flat "$EXECUTOR_CORE" "git commit <paths>"
# The recovery, and the constraint that it only works before a push
contains_flat "$EXECUTOR_CORE" "git reset --soft HEAD~1"
contains_flat "$EXECUTOR_CORE" "restores the index exactly"
# Preflight records what it found, so the close-out has a baseline
contains_flat "$EXECUTOR_CORE" "Record the dirty set"
contains_flat "$EXECUTOR_CORE" "staged/unstaged split"

# ---- M54: three of the four places a comment lives were invisible ----
contains_flat "$EXECUTOR_CORE" "A comment lives in four places"
# The ID branch takes one leading character and needs a second alphabetic run,
# which is what tells a ticket from somebody else's numbering
contains_flat "$EXECUTOR_CORE" "requires two alphabetic segments"
contains_flat "$EXECUTOR_CORE" "somebody else's numbering"
# Doc comments: markup stays, dates and IDs do not
contains_flat "$EXECUTOR_CORE" "keeps its markup"
contains_flat "$EXECUTOR_CORE" "a block opened and closed on one line"
# Python docstrings have no prefix, so the check parses instead of grepping
contains_flat "$EXECUTOR_CORE" "carries no line prefix at all and needs a parser"
contains_flat "$EXECUTOR_CORE" "ast.get_docstring"
# Vendored code is excluded rather than carved out line by line
contains_flat "$EXECUTOR_CORE" "excluded, not carved out"
# scaffold generates all four surfaces, and knows the push-to-default case
contains_flat "$SCAFFOLD" "All four surfaces, not just the inline one"
contains_flat "$SCAFFOLD" "pass the push range explicitly"

# ---- M55: what a test costs is decided when it is written ----
# The Test policy carried coverage and never cost
contains_flat "$EXECUTOR_CORE" "What a test costs"
# a stub cannot satisfy a readiness check, so the waits on that path go too
contains_flat "$EXECUTOR_CORE" "stub never satisfies a readiness check"
contains_flat "$EXECUTOR_CORE" "The wait is not in the test body"
# name resolution is charged before any connect timeout applies
contains_flat "$EXECUTOR_CORE" "Resolve no name and open no socket"
contains_flat "$EXECUTOR_CORE" "A hostname with no dot"
# the fixture is sized to what the assertion reads, and generated
contains_flat "$EXECUTOR_CORE" "Size the fixture to what the assertion reads"
contains_flat "$EXECUTOR_CORE" "generated rather than borrowed"
# the budget is checked in the green step, not beside it
contains_flat "$TDD" "within the per-test budget"
contains_flat "$IDD" "within the per-test budget"

# ---- M56: a tier total cannot show which test is the slow one ----
contains_flat "$SCAFFOLD" "times each test and prints the five slowest"
# printing every run is what catches drift below the ceiling
contains_flat "$SCAFFOLD" "Printing them every run"
# the ceiling is generous, or it reds on work that is legitimately slow
contains_flat "$SCAFFOLD" "generous enough that a legitimately slow test"
# a runner may pick its output format by whether stdout is a terminal
contains_flat "$SCAFFOLD" "whether stdout is a terminal"

# ---- M57: red-before-green is unavailable for a test written after the code ----
contains_flat "$EXECUTOR_CORE" "Prove it can fail"
contains_flat "$EXECUTOR_CORE" "break the code, confirm red, restore"
# most guards and every regression test are written against code that exists
contains_flat "$EXECUTOR_CORE" "written against code that already exists"
# reading does not find a vacuous guard
contains_flat "$EXECUTOR_CORE" "re-reading a guard does not find this"
# both playbooks name it in the step that reaches green
contains_flat "$TDD" "proven able to fail"
contains_flat "$IDD" "proven able to fail"

# ---- M58: an assertion can pin the wrong thing and stay green ----
contains_flat "$EXECUTOR_CORE" "What to assert"
# the value that arrives, not how it got there
contains_flat "$EXECUTOR_CORE" "not the spelling of its passing"
contains_flat "$EXECUTOR_CORE" "green for exactly as long as the code was wrong"
# which failure, not that one happened
contains_flat "$EXECUTOR_CORE" "Assert which failure"
# a count wherever one is knowable
contains_flat "$EXECUTOR_CORE" "survive a swap"

# ---- M60: the devplan is two files, and the executor reads only the active one ----
contains "$DESIGN" "#### Two files: active and completed"
# the completed file's name is derived from the active one
contains_flat "$DESIGN" "DEVPLAN-COMPLETED.md"
contains_flat "$DESIGN" "devplan/v0.3-completed.md"
# the read split: executor on the active file, design on both
contains_flat "$DESIGN" "The executor reads the active file"
contains_flat "$DESIGN" "Design mode reads both"
# a one-file plan is still a valid plan
contains_flat "$DESIGN" "A single-file devplan stays valid"
# numbering comes from the completed file, or a session reuses assigned IDs
contains_flat "$DESIGN" "the last milestone ID lives in the completed file"
contains_flat "$DESIGN" "reuses IDs already assigned"
# closing a version opens a new pair; nothing is moved at version close
contains_flat "$DESIGN" "closing one opens a new pair"
# Archive: relocation is lossless and automatic, compression is the user's call
contains_flat "$DESIGN" "the move and the compression come apart"
contains_flat "$DESIGN" "compressing the completed file"
# the executor reads the active file and zooms only on a named ID
contains_flat "$EXECUTOR_CORE" "Read the active devplan file"
contains_flat "$EXECUTOR_CORE" "names an earlier milestone ID"
# both playbooks say which file step 1 reads
contains_flat "$TDD" "the active file when the project uses the two-file layout"
contains_flat "$IDD" "the active file when the project uses the two-file layout"
# the payload README no longer promises that no format is required
contains_flat "$SKILL_README" "one file or two"

# ---- M61: closing a milestone moves it, and nothing is lost in the move ----
contains_flat "$EXECUTOR_CORE" "Move the closed milestone to the completed file"
# verbatim, never the compressed form whose only pointer is a sha
contains_flat "$EXECUTOR_CORE" "moves verbatim"
contains_flat "$EXECUTOR_CORE" "a force-rewritten history leaves that pointer resolving to nothing"
# append before removing, so a dead run leaves the block in both files
contains_flat "$EXECUTOR_CORE" "Append to the completed file before removing it from the active one"
# the bookkeeping re-read follows the block to where it now lives
contains_flat "$EXECUTOR_CORE" "the re-read follows the block"
# the gate greps the heading; a bare ID appears as a cross-reference
contains_flat "$EXECUTOR_CORE" "resolves in exactly one file"
contains_flat "$EXECUTOR_CORE" "an ID also appears as a cross-reference"
# the commit carries both files
contains_flat "$EXECUTOR_CORE" "stage both"
contains_flat "$EXECUTOR_CORE" "the completed file when the milestone moved"
# preflight recognises a run that died mid-move
contains_flat "$EXECUTOR_CORE" "died during the close-out move"
# the old absolute ban on relocating is gone
if grep -qF "Never archive a milestone or compress closed ones mid-run" "$EXECUTOR_CORE"; then
    fail "EXECUTOR-CORE still bans relocating a closed milestone"
fi

# ---- M62: the split is offered, never performed unasked ----
contains_flat "$DESIGN" "suggest the two-file split"
contains_flat "$DESIGN" "Never split a devplan unasked"
# a section heading follows its milestones once they have all closed
contains_flat "$DESIGN" "moves with them once every milestone under it is closed"
# a version's out-of-scope list is tied to that version
contains_flat "$DESIGN" "Out-of-scope list moves with that version"
# what a planner still needs stays where a planner looks
contains_flat "$DESIGN" "stay in the active file"

# ---- M63: the READMEs carry the two-file model ----
# the layout tree lists the file M62 created
contains_flat "$ROOT_README" "DEVPLAN-COMPLETED.md"
# both READMEs state the model, not just the file names
contains_flat "$ROOT_README" "the active file carries the work queue"
contains_flat "$SKILL_README" "the active file carries the work queue"
# relocation and compression are named apart
contains_flat "$ROOT_README" "compressing it is a separate decision"
contains_flat "$SKILL_README" "compressing it is a separate decision"
# the shared-core entry names the close-out
contains_flat "$SKILL_README" "close-out move"

# ---- M64: the bookkeeping checks follow the milestone to its file ----
# a milestone planned and closed in one run leaves the active file unchanged
contains_flat "$EXECUTOR_CORE" "the milestone's record is in the commit"
contains_flat "$EXECUTOR_CORE" "planned and closed inside one run leaves the active file unchanged"
contains_flat "$EXECUTOR_CORE" "the active file is legitimately absent"
# the completion sweep looks where the milestone now is
contains_flat "$EXECUTOR_CORE" "in whichever file now holds it"
# M33's pinned phrases survive the rewrite
contains "$EXECUTOR_CORE" "Verify the devplan shipped in the commit"
contains "$EXECUTOR_CORE" "Sweep the devplan for unfinished bookkeeping"

# ---- M66: guarantees that assume the agent reading them is the agent acting ----
# the commit is bounded by baselines preflight recorded, so the holder commits
contains_flat "$EXECUTOR_CORE" "The agent that commits is the one holding the baseline"
contains_flat "$EXECUTOR_CORE" "comes back for the orchestrator to review and commit"
# a subagent with its own worktree is not the case being ruled on
contains_flat "$EXECUTOR_CORE" "its own worktree is a different case"
# evidence covers the red-proof, not only completion claims
contains_flat "$EXECUTOR_CORE" "A red-proof is a claim of the same kind"
contains_flat "$EXECUTOR_CORE" "a red-proof is held to the same standard"

# ---- M67: a tier defined by cost, and a fast route that must agree ----
# the fourth tier is split from the others by price, not by how real a test is
contains_flat "$SCAFFOLD" "defined by what it costs rather than by how real it is"
contains_flat "$SCAFFOLD" "runs tests the other tiers already own, over the artifact that is already built"
# a route whose value is its scope refuses to run without one
contains_flat "$SCAFFOLD" "It refuses an unscoped run"
contains_flat "$SCAFFOLD" "run_tests.sh fast --changed"
# two routes to the same tests are one verdict only once that is proven
contains_flat "$SCAFFOLD" "must be proven to return the same verdict as the slow route on the same selection, or refuse to run"
contains_flat "$SCAFFOLD" "270 failed against 3,681 passed"
# and the proof is falsified, or it is proving nothing
contains_flat "$SCAFFOLD" "remove the precondition, and the failures must come back"

# ---- M67: a per-tier budget, and a local gate CI does not already pay for ----
# the second ceiling, and what the first one is blind to
contains_flat "$SCAFFOLD" "per-tier budget beside the per-test ceiling"
contains_flat "$SCAFFOLD" "cannot catch a tier that is expensive because of what surrounds the tests"
# both measurements: cost outside every test, and cost spread thin across many
contains_flat "$SCAFFOLD" "ran in four seconds and the remaining eleven minutes"
contains_flat "$SCAFFOLD" "1,508 cases averaging ~200 ms summed to 5.2 minutes"
# the inner loop does not rebuild what the push rebuilds anyway
contains_flat "$SCAFFOLD" "A local gate only for what CI does not already pay for"
contains_flat "$SCAFFOLD" "buys one answer twice"
contains_flat "$SCAFFOLD" "whether the check needs the artifact rebuilt"
# the generation contract names the tier it now has to produce
contains_flat "$SCAFFOLD" "refuses an unscoped run and its verdict has been proven equal"

# ---- M68: a binding decision has a place to live ----
# the log sits beside the active devplan and is named by derivation from it
contains "$EXECUTOR_CORE" "## Record a binding decision"
contains_flat "$EXECUTOR_CORE" "beside the active devplan"
contains_flat "$EXECUTOR_CORE" "devplan/decisions.md"
# both gate conditions, and the reason the gate is narrow
contains_flat "$EXECUTOR_CORE" "both conditions, or none"
contains_flat "$EXECUTOR_CORE" "A future milestone could plausibly contradict it"
contains_flat "$EXECUTOR_CORE" "not what it rules out, or why"
contains_flat "$EXECUTOR_CORE" "a second devplan is not read"
# a rule about how work is done goes to the instruction file instead
contains_flat "$EXECUTOR_CORE" "belongs in the project's instruction file"
# the entry carries the constraint and what the project now lives with
contains_flat "$EXECUTOR_CORE" "DEC-7: Queue delivery is polled, not pushed"
contains_flat "$EXECUTOR_CORE" "what stops the entry being re-argued"
# supersession replaces editing, which is what leaves two current-tense statements
contains_flat "$EXECUTOR_CORE" "Supersession is the only edit an existing entry may receive"
contains_flat "$EXECUTOR_CORE" "Superseded by DEC-N"
contains_flat "$EXECUTOR_CORE" "both in the present tense, and nothing saying which one is current"
# appending the same decision twice is a no-op
contains_flat "$EXECUTOR_CORE" "is not written twice"

# the routing table gained the row, and gained exactly one
python3 - "$EXECUTOR_CORE" <<'ROUTING'
import re, sys
text = open(sys.argv[1]).read()
start = text.index("#### Where the rest goes")
end = text.index("\n### ", start)
table = [l for l in text[start:end].splitlines() if l.startswith("|")]
rows = [l for l in table if not re.match(r"^\|[\s:-]+\|", l) and "What | Where" not in l]
assert len(rows) == 7, f"routing table has {len(rows)} rows, expected 7"
hits = [r for r in rows if "DECISIONS.md" in r]
assert len(hits) == 1, f"{len(hits)} rows name DECISIONS.md, expected 1"
assert "Record a binding decision" in hits[0], f"row does not point at the section: {hits[0]}"
ROUTING

echo "content contract passed"

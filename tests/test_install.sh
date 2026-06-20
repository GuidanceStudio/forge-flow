#!/usr/bin/env bash
set -euo pipefail

# Test suite for install.sh — multi-assistant model.
# Run: bash tests/test_install.sh

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALL_SH="$REPO_ROOT/install.sh"
PASS=0
FAIL=0

fake_home() { mktemp -d; }
cleanup() { rm -rf "$1"; }

create_snapshot_repo() {
    # A throwaway git repo whose root contains the flat forge-flow/ payload,
    # used as a local clone source for remote-mode tests.
    local root repo
    root="$(mktemp -d)"; repo="$root/repo"
    cp -R "$REPO_ROOT" "$repo"
    rm -rf "$repo/.git"
    ( cd "$repo" && git init -q && git config user.name t && git config user.email t@e \
        && git add -A && git commit -qm snapshot )
    echo "$root"
}

assert_dir()  { if [ -d "$1" ]; then echo "  PASS: $2"; PASS=$((PASS+1)); else echo "  FAIL: $2 — missing dir $1"; FAIL=$((FAIL+1)); fi; }
assert_file() { if [ -f "$1" ]; then echo "  PASS: $2"; PASS=$((PASS+1)); else echo "  FAIL: $2 — missing file $1"; FAIL=$((FAIL+1)); fi; }
assert_nofile(){ if [ ! -e "$1" ]; then echo "  PASS: $2"; PASS=$((PASS+1)); else echo "  FAIL: $2 — exists $1"; FAIL=$((FAIL+1)); fi; }

# Run install.sh with expected exit + a needle in output.
assert_run() {  # <expected_exit> <needle> <label> -- <args...>
    local exp="$1" needle="$2" label="$3"; shift 3; [ "$1" = "--" ] && shift
    local out rc=0
    out="$(bash "$INSTALL_SH" "$@" 2>&1)" || rc=$?
    if [ "$rc" -eq "$exp" ] && printf '%s' "$out" | grep -qF "$needle"; then
        echo "  PASS: $label"; PASS=$((PASS+1))
    else
        echo "  FAIL: $label — exit=$rc (want $exp); output:"; printf '%s\n' "$out" | head -4; FAIL=$((FAIL+1))
    fi
}

echo "=== Verbatim targets (claude/codex/opencode) ==="
for t in claude codex opencode; do
    H="$(fake_home)"
    case "$t" in
        claude)   D="$H/.claude/skills/forge-flow" ;;
        codex)    D="$H/.codex/skills/forge-flow" ;;
        opencode) D="$H/.config/opencode/skills/forge-flow" ;;
    esac
    echo "--- $t ---"
    HOME="$H" bash "$INSTALL_SH" --force --target "$t" >/dev/null
    assert_file "$D/SKILL.md" "$t: SKILL.md installed"
    assert_file "$D/agents/openai.yaml" "$t: payload includes agents/openai.yaml"
    HOME="$H" assert_run 0 "OK" "$t: --check clean" -- --check --target "$t"
    echo "edit" >> "$D/SKILL.md"
    HOME="$H" assert_run 1 "DRIFT" "$t: --check detects drift" -- --check --target "$t"
    cleanup "$H"
done

echo "=== Default target (non-interactive → claude) ==="
H="$(fake_home)"
HOME="$H" bash "$INSTALL_SH" --force >/dev/null
assert_dir "$H/.claude/skills/forge-flow" "default installs claude"
cleanup "$H"

echo "=== Back-compat bare target word ==="
H="$(fake_home)"
HOME="$H" bash "$INSTALL_SH" --force claude >/dev/null
assert_dir "$H/.claude/skills/forge-flow" "bare 'claude' word still works"
cleanup "$H"

echo "=== --check on missing install ==="
H="$(fake_home)"
HOME="$H" assert_run 1 "DRIFT" "missing install reported as drift" -- --check --target claude
cleanup "$H"

echo "=== Gemini TOML wrapper ==="
H="$(fake_home)"
HOME="$H" bash "$INSTALL_SH" --force --target gemini >/dev/null
assert_file "$H/.gemini/commands/forge-flow.toml" "gemini: toml written"
assert_file "$H/.config/forge-flow/SKILL.md" "gemini: payload in neutral home"
if grep -q 'prompt' "$H/.gemini/commands/forge-flow.toml" && grep -q 'SKILL.md' "$H/.gemini/commands/forge-flow.toml"; then
    echo "  PASS: gemini: toml references the router"; PASS=$((PASS+1))
else echo "  FAIL: gemini: toml missing prompt/SKILL.md"; FAIL=$((FAIL+1)); fi
HOME="$H" assert_run 0 "OK" "gemini: --check clean" -- --check --target gemini
cleanup "$H"

echo "=== AGENTS.md pointer (idempotent) ==="
H="$(fake_home)"; PROJ="$(mktemp -d)"
HOME="$H" bash "$INSTALL_SH" --force --target agents --agents-dir "$PROJ" >/dev/null
assert_file "$PROJ/AGENTS.md" "agents: AGENTS.md written"
HOME="$H" bash "$INSTALL_SH" --force --target agents --agents-dir "$PROJ" >/dev/null
n="$(grep -cF 'forge-flow:start' "$PROJ/AGENTS.md")"
if [ "$n" -eq 1 ]; then echo "  PASS: agents: pointer not duplicated"; PASS=$((PASS+1));
else echo "  FAIL: agents: pointer duplicated ($n)"; FAIL=$((FAIL+1)); fi
cleanup "$H"; cleanup "$PROJ"

echo "=== Manual (prints path, writes nothing) ==="
H="$(fake_home)"
HOME="$H" assert_run 0 "forge-flow" "manual prints payload path" -- --target manual
assert_nofile "$H/.claude" "manual wrote nothing under HOME"
cleanup "$H"

echo "=== Remote mode (clone from local snapshot) ==="
SNAP="$(create_snapshot_repo)"
H="$(fake_home)"; ISO="$(mktemp -d)"
cp "$INSTALL_SH" "$ISO/install.sh"
HOME="$H" DEVPLAN_REPO_URL="$SNAP/repo" bash "$ISO/install.sh" --force --target claude >/dev/null
assert_file "$H/.claude/skills/forge-flow/SKILL.md" "remote: SKILL.md installed via clone"
cleanup "$H"; cleanup "$ISO"; cleanup "$SNAP"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ]

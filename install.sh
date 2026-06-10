#!/usr/bin/env bash
set -euo pipefail

# devplan skill installer — multi-assistant.
#
# `devplan/` is a flat, assistant-neutral skill payload. This installer
# places it where your coding assistant looks for skills, or wraps it for
# assistants that use a different convention.
#
# Local mode:  ./install.sh [OPTIONS]
# Remote mode: bash <(curl -fsSL https://raw.githubusercontent.com/kiso-run/devplan/main/install.sh) --target claude

REPO_URL="${DEVPLAN_REPO_URL:-https://github.com/kiso-run/devplan.git}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FORCE=false
CHECK=false
TARGET=""           # claude|codex|opencode|gemini|agents|manual|all (empty → menu/default)
AGENTS_DIR="$PWD"   # where the `agents` target writes AGENTS.md
CLEANUP_DIR=""

CLAUDE_DEST="$HOME/.claude/skills/devplan"
CODEX_DEST="$HOME/.codex/skills/devplan"
OPENCODE_DEST="$HOME/.config/opencode/skills/devplan"
NEUTRAL_HOME="$HOME/.config/devplan"
GEMINI_TOML="$HOME/.gemini/commands/devplan.toml"

cleanup_temp() {
    if [ -n "$CLEANUP_DIR" ] && [ -d "$CLEANUP_DIR" ]; then
        rm -rf "$CLEANUP_DIR"
    fi
}
trap cleanup_temp EXIT

usage() {
    cat <<EOF
Install the devplan skill into your coding assistant.

Usage:
    ./install.sh [OPTIONS]

Options:
    --target NAME   One of: claude, codex, opencode, gemini, agents, manual, all.
                    Omitted → interactive menu (or 'claude' when non-interactive).
    --agents-dir D  Directory the 'agents' target writes AGENTS.md into (default: \$PWD).
    --force         Overwrite an existing installation without prompting.
    --check         Compare the installed copy/wrapper against the source (no writes);
                    exits 1 and reports DRIFT on a difference or missing install.
    --help          Show this message.

Targets:
    claude    → ~/.claude/skills/devplan/          (SKILL.md standard, verbatim)
    codex     → ~/.codex/skills/devplan/           (SKILL.md standard, verbatim)
    opencode  → ~/.config/opencode/skills/devplan/  (SKILL.md standard, verbatim)
    gemini    → ~/.gemini/commands/devplan.toml     (TOML wrapper) + payload in ~/.config/devplan
    agents    → AGENTS.md pointer (Cursor/Windsurf/Copilot/Aider/Continue) + payload in ~/.config/devplan
    manual    → print the flat payload path; copy it wherever your tool reads skills

Environment:
    DEVPLAN_REPO_URL   Override the remote-mode clone URL.
EOF
}

while [ $# -gt 0 ]; do
    case "$1" in
        --force) FORCE=true; shift ;;
        --check) CHECK=true; shift ;;
        --target) TARGET="$2"; shift 2 ;;
        --agents-dir) AGENTS_DIR="$2"; shift 2 ;;
        --help|-h) usage; exit 0 ;;
        # Back-compat: bare target words (old `./install.sh claude`)
        claude|codex|opencode|gemini|agents|manual|all) TARGET="$1"; shift ;;
        *) echo "unknown option: $1" >&2; usage >&2; exit 1 ;;
    esac
done

# Resolve the source payload (local checkout or remote clone)
if [ -d "$SCRIPT_DIR/devplan" ]; then
    SRC_ROOT="$SCRIPT_DIR/devplan"
else
    if ! command -v git >/dev/null 2>&1; then
        echo "error: remote install requires 'git' on PATH" >&2
        exit 1
    fi
    CLEANUP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/devplan-install-XXXXXX")"
    echo "Cloning devplan into a temporary directory..."
    git clone --depth 1 --quiet "$REPO_URL" "$CLEANUP_DIR/devplan"
    SRC_ROOT="$CLEANUP_DIR/devplan/devplan"
    if [ ! -d "$SRC_ROOT" ]; then
        echo "error: cloned repo does not contain devplan/" >&2
        exit 1
    fi
fi
SRC_PARENT="$(dirname "$SRC_ROOT")"

# --- helpers ---------------------------------------------------------------

src_sha() {
    git -C "$SRC_PARENT" rev-parse --short HEAD 2>/dev/null || true
}

copy_payload() {  # <dest>
    local dest="$1"
    if [ -d "$dest" ] && [ "$FORCE" != true ]; then
        printf "Target %s already exists. Overwrite? [y/N] " "$dest"
        read -r ans
        case "$ans" in y|Y|yes) ;; *) echo "Skipped $dest."; return 1 ;; esac
    fi
    rm -rf "$dest"
    mkdir -p "$(dirname "$dest")"
    cp -r "$SRC_ROOT" "$dest"
    local sha; sha="$(src_sha)"
    [ -n "$sha" ] && printf '%s\n' "$sha" > "$dest/.installed-from"
    echo "✅ Installed devplan payload → $dest"
}

write_gemini_toml() {
    copy_payload "$NEUTRAL_HOME" || return 0
    mkdir -p "$(dirname "$GEMINI_TOML")"
    cat > "$GEMINI_TOML" <<TOML
description = "devplan — design or execute a Markdown dev plan (design / TDD / IDD)"
prompt = """
You are the devplan skill. Follow the router and playbooks in the skill
payload, reading files on demand as it directs.

Router: @{$NEUTRAL_HOME/SKILL.md}

User request: {{args}}
"""
TOML
    echo "✅ Wrote Gemini command → $GEMINI_TOML (payload in $NEUTRAL_HOME)"
}

AGENTS_MARK_START="<!-- devplan:start -->"
AGENTS_MARK_END="<!-- devplan:end -->"

write_agents_pointer() {  # <agents-dir>
    local dir="$1" file="$1/AGENTS.md"
    copy_payload "$NEUTRAL_HOME" || return 0
    mkdir -p "$dir"
    if [ -f "$file" ] && grep -qF "$AGENTS_MARK_START" "$file"; then
        sed -i "/$AGENTS_MARK_START/,/$AGENTS_MARK_END/d" "$file"
    fi
    cat >> "$file" <<AGENTS
$AGENTS_MARK_START
## devplan skill

When asked to plan work or execute a dev plan milestone by milestone, act
as the devplan skill: read \`$NEUTRAL_HOME/SKILL.md\` and follow its
routing (design / TDD / IDD).
$AGENTS_MARK_END
AGENTS
    echo "✅ Added devplan pointer → $file (payload in $NEUTRAL_HOME)"
}

check_copy() {  # <dest> <label>
    local dest="$1" label="$2"
    if [ ! -d "$dest" ]; then echo "DRIFT: $label not installed at $dest"; return 1; fi
    local out; out="$(diff -r --exclude=.installed-from "$SRC_ROOT" "$dest" 2>&1)" || true
    if [ -n "$out" ]; then echo "DRIFT: $label at $dest differs from source:"; echo "$out" | head -10; return 1; fi
    echo "OK: $label matches the source tree ($dest)"; return 0
}

run_check() {  # <target>
    case "$1" in
        claude)   check_copy "$CLAUDE_DEST" "claude" ;;
        codex)    check_copy "$CODEX_DEST" "codex" ;;
        opencode) check_copy "$OPENCODE_DEST" "opencode" ;;
        gemini)
            [ -f "$GEMINI_TOML" ] || { echo "DRIFT: gemini command not installed at $GEMINI_TOML"; return 1; }
            check_copy "$NEUTRAL_HOME" "gemini payload" ;;
        agents)
            grep -qF "$AGENTS_MARK_START" "$AGENTS_DIR/AGENTS.md" 2>/dev/null \
                || { echo "DRIFT: AGENTS.md pointer missing in $AGENTS_DIR"; return 1; }
            check_copy "$NEUTRAL_HOME" "agents payload" ;;
        all)
            local rc=0
            run_check claude || rc=1; run_check codex || rc=1; run_check opencode || rc=1
            return $rc ;;
        *) echo "error: --check needs a --target (claude|codex|opencode|gemini|agents|all)" >&2; return 2 ;;
    esac
}

run_install() {  # <target>
    case "$1" in
        claude)   copy_payload "$CLAUDE_DEST" || true ;;
        codex)    copy_payload "$CODEX_DEST" || true ;;
        opencode) copy_payload "$OPENCODE_DEST" || true ;;
        gemini)   write_gemini_toml ;;
        agents)   write_agents_pointer "$AGENTS_DIR" ;;
        manual)
            echo "Flat skill payload:"
            echo "    $SRC_ROOT"
            echo "Copy that folder wherever your assistant reads skills." ;;
        all)
            run_install claude; run_install codex; run_install opencode ;;
        *) echo "unknown target: $1" >&2; usage >&2; exit 1 ;;
    esac
}

interactive_menu() {
    cat <<EOF
Where should devplan be installed?
  1) claude     ~/.claude/skills/devplan
  2) codex      ~/.codex/skills/devplan
  3) opencode   ~/.config/opencode/skills/devplan
  4) gemini     ~/.gemini/commands/devplan.toml
  5) agents     AGENTS.md pointer (Cursor/Windsurf/Copilot/Aider/Continue)
  6) all        claude + codex + opencode
  7) manual     just print the folder path to copy yourself
EOF
    printf "Choice [1-7]: "
    read -r choice
    case "$choice" in
        1) echo claude ;; 2) echo codex ;; 3) echo opencode ;;
        4) echo gemini ;; 5) echo agents ;; 6) echo all ;; 7) echo manual ;;
        *) echo "error: invalid choice" >&2; exit 1 ;;
    esac
}

if [ -z "$TARGET" ]; then
    if [ -t 0 ]; then TARGET="$(interactive_menu)"; else TARGET="claude"; fi
fi

if [ "$CHECK" = true ]; then
    run_check "$TARGET"
    exit $?
fi

run_install "$TARGET"

# forge-flow — Dev Plan

Unified skill for both **Claude Code** and **Codex** that handles the full forge-flow lifecycle:
plan creation/maintenance (`design`) and plan execution (`TDD` / `IDD`).

This project replaces the two standalone repos `claude-forge-flow-executor` and
`codex-forge-flow-executor` with a single source of truth that ships both variants
plus a shared installer.

## Milestone format

Each milestone uses 4 required sections — **Why**, **Approach**, **Tasks**,
**Done when** — and an optional **Notes** section when something doesn't fit
elsewhere. Every task is a markdown checkbox.

---

---

## No open milestones

Everything filed is closed and moved to
**[`DEVPLAN-COMPLETED.md`](DEVPLAN-COMPLETED.md)**, verbatim, which is what that
file's header requires: the move is lossless, and compressing it to the one-line
form is a separate call the user makes.

Fifty-four milestones are recorded there. Both suites are green — `tests/test_content.sh`
holds the payload to what it says it does, and `tests/test_install.sh` covers the
installer.

**To add work:** invoke the skill in `design` mode against this file. Milestone
numbering continues from the highest ID in the completed file.

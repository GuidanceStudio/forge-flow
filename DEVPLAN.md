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

## Follow-up — The suggestion that could not fire (2026-08-26)

### M73: Archiving is suggested when the run closes ✅

**Why:** `#### Archive` says to suggest archiving "when a completed section outgrows the
pending work". Measured on a production devplan: 640 archived rows against 11 open
sections — true for months, so it names no moment and the executor never reached it.
Measured 2026-08-26: eight archives taken on the executor's own initiative in one session,
and the rule against it quoted afterwards.

**Approach:** `Never archive on your own initiative` stays; the size condition is replaced
by the run's close-out. `## Completion` gains a step naming how many closed milestones sit
in the completed file and asking whether to compress them. `## Common rules` carries the
carve-out, since the ask follows the run rather than sitting between milestones.

**Tasks:**
- [x] `#### Archive` trigger becomes the close-out, size condition removed
- [x] `## Completion` step asking to compress, naming the count and the file
- [x] Carve-out in `## Common rules` against the between-milestones prompt ban
- [x] Test: content anchors for the trigger, the Completion step and the carve-out
- [x] Falsified — removing each anchor reds `tests/test_content.sh`
- [x] Commit & push

**Done when:** both suites are green, no file under `forge-flow/` states the size
condition, and `./install.sh --force` has deployed it.

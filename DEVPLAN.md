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

Closed milestones live in **[`DEVPLAN-COMPLETED.md`](DEVPLAN-COMPLETED.md)**, verbatim.
Numbering continues from the highest ID there.

---

## v0.6 — Principles, executable specs, review

Source: a talk on keeping AI-built prototypes from degrading, plus a security talk, read
2026-10-23. M76 establishes the principles document used by the later review rules.

Content anchors guard instructions; removing an anchor proves only that textual guard.
The scenario and fixture tasks below supply separate evidence for each Done-when.

### M82: Verify reviews the diff for security and reports what did not run

**Why:** review must expose findings and unavailable checks without presenting either as clean.

**Approach:** verify separates confirmed findings, concerns to verify and hardening. Attacker
control, reachability, damage and feasible exploit steps support confirmed application
vulnerabilities; they never suppress secrets, configuration or test/CI risks by path.
Project-required checks report `passed`, `failed`, `error` or `skipped` with reasons. Critical
findings and non-passing mandatory checks block completion and shipping unless project policy
permits explicit, documented user acceptance.

**Tasks:**
- [ ] `EXECUTOR-CORE.md` defines evidence questions, finding categories and coverage of secrets, configuration, tests and CI
- [ ] Rank auth, crypto, external calls, removed validation and untested changes by risk rather than diff size
- [ ] Read mandatory checks from project policy; report secret-scan and dependency-lock outcomes and reasons
- [ ] Define remediation or policy-permitted risk acceptance before completion and shipping
- [ ] Put always-required invariants in project hooks/CI; offer second-model review for sensitive milestones
- [ ] Test: content anchors and their removal prove instruction guards
- [ ] Test: scenarios retain test-file secrets and uncertain vulnerabilities; distinguish failed, error and skipped checks
- [ ] Test: scenarios block critical findings and mandatory non-passes until remediation or policy-permitted acceptance
- [ ] `./install.sh --force`
- [ ] Commit & push

**Done when:** recorded scenarios demonstrate reporting and completion/shipping gates, including
unavailable mandatory checks.

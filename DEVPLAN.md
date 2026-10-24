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

## Deferred — Existing-project pilot

This is not an executable milestone. It requires explicit authorization, a selected
repository and a desired change. An isolated run would trace selective spec reads,
a green characterization baseline before implementation, the TDD red/green cycle and
stopping on a principle departure without an approved exception. Controlled scenarios
in M85 do not close this real-project validation gap.

## Required conformance and security test flows

### M88: Make security verification an executable test flow

**Why:** threat modeling and security review exist, but their tests and checks have no required executable flow.

**Approach:** add `security` to the native runner and authorized CI, mapping threat IDs to controls and negative tests/checks. Reuse existing review criteria, stack-appropriate tools and policy exceptions. Preserve actual outcomes; missing mandatory evidence blocks completion. Extend M87's flow contract without copying tests between levels.

**Tasks:**
- [ ] Test: executable fixtures — anonymous/cross-owner access, unsafe startup, missing mappings and mandatory check outcomes
- [ ] Add a project-specific security example whose protection removals produce failing tests
- [ ] Extend the documented runner with `security` and mandatory inclusion in full runs
- [ ] Integrate threat mappings, security-flow execution and existing completion gates across playbooks
- [ ] Update documentation, content/installer checks and validation evidence
- [ ] Run content and installer suites; verify optional and mandatory unavailable checks remain distinguishable
- [ ] Install with `./install.sh --target all --force` and verify installed payloads
- [ ] Commit the verified milestone with its devplan record

**Done when:** the runner executes the mapped security tests and checks, propagates failures and blocks missing mandatory verification.

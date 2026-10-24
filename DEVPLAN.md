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

## Follow-up — Source evidence and conditional procedures

### M85: Load optional procedures only when applicable

**Why:** runs without configured reviewers or unspecified existing behaviour still load
roughly 270 words of review procedure and 220 words of characterization details.

**Approach:** move those procedures from `forge-flow/EXECUTOR-CORE.md` to
`forge-flow/REVIEW.md` and `forge-flow/CHARACTERIZATION.md`. CORE retains applicability
conditions, required reference reads and the green baseline before implementation edits. Preserve
existing invariants and security-gate references at Quality, commit, CI and completion;
update mode references, payload documentation and content checks.

**Tasks:**
- [ ] Map existing review and characterization invariants to their canonical destinations
- [ ] Keep absent/empty reviewer handling and conditions requiring procedure reads in CORE
- [ ] Preserve mode-specific timing, the observed/desired distinction and unspecified unrelated behaviour
- [ ] Update `forge-flow/TDD.md`, `forge-flow/IDD.md`, `forge-flow/README.md` and `tests/test_content.sh` references
- [ ] Test: content — preserve existing guarantees and prove new routing guards fail when removed
- [ ] Test: scenarios — trace reference reads before work for absent/present reviewers and specified/unspecified baselines in TDD/IDD
- [ ] Compare loaded bytes/words against `71a6153`, counting required reference files whenever applicable
- [ ] Test: installer — verify both new reference files ship in the payload
- [ ] `./install.sh --target all --force`
- [ ] Commit & push

**Done when:** controlled traces show reduced guidance in non-applicable paths and required
procedure loads before work in applicable paths, with existing invariants and security gates preserved.

## Deferred — Existing-project pilot

This is not an executable milestone. It requires explicit authorization, a selected
repository and a desired change. An isolated run would trace selective spec reads,
a green characterization baseline before implementation, the TDD red/green cycle and
stopping on a principle departure without an approved exception. Controlled scenarios
in M85 do not close this real-project validation gap.

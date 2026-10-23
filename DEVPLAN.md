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

### M79: Review through explicit heuristics the project chooses

**Why:** a named perspective helps only when its criteria produce findings that another reader
can assess against the diff.

**Approach:** `## Reviewers` in `PRINCIPLES.md` or its existing equivalent records explicit
heuristics, published sources and applicable scopes, approved through design. Authors supply
references rather than impersonated verdicts; no finding is required per author. Beside
simplification, the executor requires a diff location, criterion and consequence, deduplicates
findings and resolves conflicts against project principles and the milestone contract before
creating in-scope tasks; other findings go to the report.

**Tasks:**
- [ ] `DESIGN.md` proposes code references: Kent Beck, Martin Fowler, John Ousterhout, Eric Evans
- [ ] `DESIGN.md` proposes UI references: Don Norman, Jakob Nielsen; legacy: Michael Feathers; security: Adam Shostack
- [ ] `DESIGN.md` records user edits and requires published sources, explicit heuristics and scopes
- [ ] `EXECUTOR-CORE.md` reads reviewer configuration and defines evidence, deduplication, conflict resolution and routing
- [ ] Test: content anchors and their removal prove instruction guards
- [ ] Test: recorded scenario — duplicate findings consolidate, unsupported objections drop, and conflicting advice follows project constraints
- [ ] Test: changing a configured heuristic changes the scenario's review criteria
- [ ] `./install.sh --force`
- [ ] Commit & push

**Done when:** recorded review scenarios demonstrate evidence-based findings, consolidation,
constraint-aware routing and configuration-dependent criteria.

### M80: Repeated concepts prompt an abstraction check, and names read like speech

**Why:** duplicated domain rules can drift, while premature extraction couples operations that
need to evolve independently.

**Approach:** ladder step 5 retains single-use inlining. Two occurrences trigger evaluation,
not mandatory extraction: merge only semantically identical concepts sharing a reason to change,
within milestone scope. Search the diff and neighbouring code before commit. Naming pairs
cover function, class, variable and test; names use requirement language, such as
`TaxCalculator` over `Helper`, `orders_awaiting_payment` over `list2`, and
`test_rejects_writes` over `test_case_3`.

**Tasks:**
- [ ] `EXECUTOR-CORE.md` ladder step 5 defines extraction criteria beside the single-use rule
- [ ] `EXECUTOR-CORE.md` bounds the duplication search and extraction to milestone scope
- [ ] `EXECUTOR-CORE.md` adds paired naming examples for function, class, variable and test
- [ ] `TDD.md` and `IDD.md` point test naming at that section
- [ ] Test: content anchors and their removal prove instruction guards
- [ ] Test: recorded examples — shared domain rules qualify; similar code with independent change reasons stays separate
- [ ] Test: examples retain a single-use abstraction inline and defer extraction beyond milestone scope
- [ ] `./install.sh --force`
- [ ] Commit & push

**Done when:** recorded simplification examples distinguish justified extraction from accidental
similarity, and naming examples cover all four kinds.

### M81: Design asks who can abuse a feature and tests prove the rule holds

**Why:** untested access rules can ship with a green suite and surface only after release.

**Approach:** for milestones touching data, access or external services, `DESIGN.md` updates
`THREATS.md` beside the devplan with trust boundaries, assets and STRIDE per component.
Design also lists the assumptions the code relies on and nothing enforces; each becomes a
negative test in TDD or IDD: one user cannot read another's data, a request without credentials is
refused, a missing secret stops the start instead of falling back to a default. After a bug, a
test covers each other place the same cause appears.

**Tasks:**
- [ ] `DESIGN.md` writes `THREATS.md` for milestones touching data, access or external services
- [ ] `DESIGN.md` lists unenforced assumptions and gives each a negative test task
- [ ] `TDD.md` and `IDD.md` name negative-test shapes: ownership, no credentials, missing secret, following each mode's timing
- [ ] `EXECUTOR-CORE.md` adds the same-cause test after a defect fix
- [ ] Test: content anchors and their removal prove instruction guards
- [ ] Test: recorded scenarios map an unenforced ownership assumption and a repeated defect cause to concrete negative-test tasks
- [ ] `./install.sh --force`
- [ ] Commit & push

**Done when:** recorded planning scenarios produce a threat section, negative-test tasks per
unenforced assumption and same-cause regression tasks in both execution modes.

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

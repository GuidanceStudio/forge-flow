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

Closed milestones live in **[`DEVPLAN-COMPLETED.md`](DEVPLAN-COMPLETED.md)** as a compact index (`MNN | title | date | sha`); full details remain in Git history. Newly closed milestones are recorded verbatim at close-out, and compressed only with the user’s explicit approval. Numbering continues from the highest ID there.

---

## ✅ M93: The scaffold's generated runner has an executable shape, like the other generated files

**Why:** the decision log, the threat model, the spec files and the principles
document each ship a worked shape, and three of them ship an example a test suite
extracts and runs. The scaffold route generates a bring-up script and a tiered
`run_tests.sh` from about a hundred lines of requirements and no example: each run
reimplements the fast-tier refusal, skip-with-reason, per-test timing, the
`comments` check and the flow selection from prose, and nothing executes the result.
A generated runner that drops one of those is caught only by a reader.

**Approach:** a `SCAFFOLD-EXAMPLE.md` beside the other examples with the runner in a
block marked `<!-- scaffold-runner-example -->`, read only from the scaffold route.
A `tests/test_scaffold.py` suite copies it into a temporary project the way the flow
runner suite does and drives it: an unscoped `fast` run refuses, exits non-zero and
prints both scoped forms; a tier whose prerequisite is absent skips and prints why;
a failing test makes the exit code non-zero; the five slowest tests print on every
run; `conformance` and `security` are selectable and included in the full run;
the `comments` check reports a planted hit as `file:line` and skips outside a diff.
The workflow and the README gain the suite as a sixth named step.

**Tasks:**
- [x] `forge-flow/SCAFFOLD-EXAMPLE.md`: the runner example, with a bring-up skeleton
- [x] `forge-flow/SCAFFOLD.md`: Phase 2 points at the example; the loading rule follows M85
- [x] `tests/test_scaffold.py`: the behaviours above, each falsified once
- [x] `.github/workflows/tests.yml`, `README.md`, `tests/test_content.sh`: sixth suite named and asserted

**Done when:** the suite passes under `python3 -I`, each listed behaviour has a test
that fails when the example loses it, and the content contract names the suite.

---

## Deferred — Existing-project pilot

This is not an executable milestone. It requires explicit authorization, a selected
repository and a desired change. An isolated run would trace selective spec reads,
a green characterization baseline before implementation, the TDD red/green cycle and
stopping on a principle departure without an approved exception. Controlled scenarios
in M85 do not close this real-project validation gap.

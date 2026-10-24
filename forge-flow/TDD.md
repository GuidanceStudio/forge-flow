# Devplan Executor — TDD (Test Driven Development) Playbook

> **Read `EXECUTOR-CORE.md`** for all shared behavior: operating mode,
> preflight, simplify ladder, ponytail convention, debt registration,
> shared execution-loop steps (documentation, Done-when verification,
> devplan update, commit & push), stuck protocol, test policy,
> implementation standards, completion recap template, and common rules.

---

## Execution loop (repeat for each milestone)

### 1. 📋 Plan & understand the requirement

- Read the current milestone from the devplan — the active file when the project uses the two-file layout (EXECUTOR-CORE.md "Operating mode").
- Validate that it is executable with high confidence. Prefer milestones
  that include `Why`, `Approach`, `Tasks`, and `Done when`. If the plan
  is simpler, infer the missing structure only when the requirement is
  still unambiguous from the heading and tasks.
- **State the business requirement in your own words** (1-2 sentences).
  What user-visible behavior changes? What contract must hold? If you
  cannot articulate this clearly, the milestone is exploratory — fall
  back to IDD for this milestone (read `IDD.md` and follow it for this
  milestone only) and note the fallback in the devplan with reasoning.
- Identify prerequisites from previous milestones and the current code
  state.
- Announce: *"▶ Milestone X: [name] (TDD)"*
- Mark the milestone in progress in the devplan (`🔄` on the heading) per
  EXECUTOR-CORE's state markers — before writing any test or code, so an
  interrupted run is unambiguously resumable.
- For affected existing behaviour without a specified baseline, follow
  EXECUTOR-CORE.md "Joining an existing project", and read the
  `CHARACTERIZATION.md` it names, even if its file already has other rows. The characterization baseline is preliminary and must be green
  before implementation edits; it is exempt from step 3's red requirement.
  Greenfield work skips this baseline.

### 2. 🧪 Write change tests FIRST

Write change tests at all applicable levels (see Test policy in EXECUTOR-CORE.md)
BEFORE any implementation. Tests must encode the BUSINESS REQUIREMENT,
not the implementation details.
Name tests using EXECUTOR-CORE.md "Naming" so they state the requirement's
observable rule and relevant condition.

Read the relevant spec rows from disk using EXECUTOR-CORE.md "Executable
specifications"; derive the failing tests from their `when` and `expect` values.
Add or revise the milestone's rows before the red run, retaining their stable
IDs. Use the project adapter to turn each selected row into inputs, an action
and an assertion; all selected rows must execute and unknown IDs must fail.
Keep the row and index changes in the implementation's commit.

Register the change tests in the required flows (EXECUTOR-CORE.md "Required test
flows"). Preserve TDD timing; full conformance runs again at the completion gate.

Derive negative tests from the approved threat model and milestone contract.
Example shapes: cross-owner reads are refused; protected requests without
credentials are refused; startup without a required secret fails. Apply these
where the policy requires them; public endpoints retain their declared access
policy. These change tests follow TDD timing above, with the preliminary
characterization baseline exception from "Joining an existing project".

### 3. 🔴 Run tests — they MUST fail

Run all runnable change tests you just wrote. They MUST fail (red). The
preliminary characterization baseline has already passed green and is exempt.

If any runnable change test passes before implementation, either:
- the test is wrong (it doesn't actually test the new behavior), or
- the behavior already exists (re-evaluate the milestone scope).

Tests that cannot be run locally are exempt from the red check.

### 4. 🛠️ Develop until green

- Implement the minimum code needed to make the failing tests pass.
- Run the relevant tests after each meaningful change.
- Iterate until ALL runnable tests are green **and each new one runs within
  the per-test budget** (Test policy, "What a test costs"). A test over it is
  fixed here, while you still know what it waits on — not in a later pass,
  where the cause is no longer legible.
- Any test that could not be red before implementation — a guard over existing
  behaviour, a regression test — is **proven able to fail** here instead: break
  the code, confirm red, restore (Test policy, "Prove it can fail").
- If green won't come, follow the Stuck protocol in EXECUTOR-CORE.md.
- Don't over-engineer — simplification comes next.

### 5. ✨ Simplify

Run the simplify step from EXECUTOR-CORE.md: apply the 7-rung simplify ladder
(delete → stdlib → native → existing-dep → inline → reduce →
compress-comments), register ponytail: debt, re-run tests — they must
stay green. Never simplify away trust-boundary validation, error handling
that prevents data loss, security, accessibility, explicit requirements,
or the Done-when contract.

### 6. 📝 Update documentation

Per EXECUTOR-CORE.md: update README, docstrings, and diagrams. Document
any new public API or interface.

### 7. 🎯 Verify "Done when"

Per EXECUTOR-CORE.md: verify the milestone's Done-when condition
explicitly (run the command, hit the endpoint). If not verifiable
locally, record what remains. Run the UI sanity check if the milestone
has a `UX:` field.

### 8. ✅ Update the devplan

Per EXECUTOR-CORE.md: mark the milestone done; add a `**Deviations:**` block of
≤5 lines only if execution diverged from the plan. Keep it accurate for
resumption, not narrated.

### 9. 📦 Commit & push

Per EXECUTOR-CORE.md: stage explicit paths only, commit with the repo's
convention, push under the permission preflight took. Landing on a shared branch
or opening a pull request is an outward act with its own agreement; a force push
and a rewrite of a pushed commit are refused whatever the project's convention.

---

## TDD-specific rules

*(Common rules are in EXECUTOR-CORE.md.)*

- ❌ Never write the implementation before its change tests (this is TDD mode)
- ✅ Runnable change tests must FAIL before implementation begins (classic
  TDD red→green); baseline tests are exempt from the all-new-tests-red rule
  and must instead pass green before implementation edits.

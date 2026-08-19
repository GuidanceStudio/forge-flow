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

### 2. 🧪 Write tests FIRST

Write tests at all applicable levels (see Test policy in EXECUTOR-CORE.md)
BEFORE any implementation. Tests must encode the BUSINESS REQUIREMENT,
not the implementation details.

### 3. 🔴 Run tests — they MUST fail

Run all the runnable tests you just wrote. They MUST fail (red).

If any runnable test passes before implementation, either:
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
convention, push when possible.

---

## TDD-specific rules

*(Common rules are in EXECUTOR-CORE.md.)*

- ❌ Never write the implementation before the tests (this is TDD mode)
- ✅ Runnable tests must FAIL before implementation begins (classic
  TDD red→green)

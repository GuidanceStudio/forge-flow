# Devplan Executor — IDD (Implementation Driven Development) Playbook

> **Read `EXECUTOR-CORE.md`** for all shared behavior: operating mode,
> preflight, simplify ladder, ponytail convention, debt registration,
> shared execution-loop steps (documentation, Done-when verification,
> devplan update, commit & push), stuck protocol, test policy,
> implementation standards, completion recap template, and common rules.

---

## Execution loop (repeat for each milestone)

### 1. 📋 Plan

- Read the current milestone from the devplan.
- Validate that it is executable with high confidence. Prefer milestones
  that include `Why`, `Approach`, `Tasks`, and `Done when`. If the plan
  is simpler, infer the missing structure only when the requirement is
  still unambiguous from the heading and tasks.
- **State the business requirement in your own words** (1-2 sentences).
  What user-visible behavior changes? What contract must hold?
- Identify prerequisites from previous milestones and the current code
  state.
- Announce: *"▶ Milestone X: [name] (IDD)"*
- Mark the milestone in progress in the devplan (`🔄` on the heading) per
  EXECUTOR-CORE's state markers — before writing the code, so an interrupted
  run is unambiguously resumable.

### 2. 🛠️ Develop

- Implement the required code.
- Keep it functional but not over-engineered — simplification comes
  later.

### 3. 🧪 Tests — written AFTER, must pass

Write tests at all applicable levels (see Test policy in EXECUTOR-CORE.md)
covering the finished code. Tests are written AFTER the implementation
and must PASS immediately. Unit tests must be green before proceeding.
If the implementation from step 2 or its tests won't go green, follow
the Stuck protocol in EXECUTOR-CORE.md.

### 4. ✨ Simplify

Run the simplify step from EXECUTOR-CORE.md: apply the 7-rung simplify ladder
(delete → stdlib → native → existing-dep → inline → reduce →
compress-comments), register ponytail: debt, re-run tests — they must
stay green. Never simplify away trust-boundary validation, error handling
that prevents data loss, security, accessibility, explicit requirements,
or the Done-when contract.

### 5. 📝 Update documentation

Per EXECUTOR-CORE.md: update README, docstrings, and diagrams. Document
any new public API or interface.

### 6. 🎯 Verify "Done when"

Per EXECUTOR-CORE.md: verify the milestone's Done-when condition
explicitly (run the command, hit the endpoint). If not verifiable
locally, record what remains. Run the UI sanity check if the milestone
has a `UX:` field.

### 7. ✅ Update the devplan

Per EXECUTOR-CORE.md: mark the milestone done; add a `**Deviations:**` block of
≤5 lines only if execution diverged from the plan. Keep it accurate for
resumption, not narrated.

### 8. 📦 Commit & push

Per EXECUTOR-CORE.md: stage explicit paths only, commit with the repo's
convention, push when possible.

---

## IDD-specific rules

*(Common rules are in EXECUTOR-CORE.md.)*

- ❌ Do not use IDD as an excuse for vague scope; the milestone still
  needs a concrete objective and observable completion state
- ✅ Tests are written AFTER the code, must PASS immediately

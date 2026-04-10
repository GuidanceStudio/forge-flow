# Dev Plan Executor — TDD (Test Driven Development) Playbook

## General Behavior

- **Everything is pre-approved.** Never ask for confirmation between milestones.
- **Run fully autonomously** from start to finish without interruptions.
- If a milestone is too large → break it down internally and handle it yourself.
- If something is ambiguous → pick the most reasonable interpretation and proceed.
- Stop and ask the user **only** for unresolvable blocking errors.

---

## Execution Order (repeat for each milestone)

### 1. 📋 Plan & understand the requirement

- Read the current milestone from the devplan.
- **State the business requirement in your own words** (1-2 sentences).
  What user-visible behavior changes? What contract must hold? If you
  cannot articulate this clearly, the milestone is exploratory — fall
  back to IDD for this milestone (read `IDD.md` and follow it for this
  milestone only) and note the fallback in the devplan with reasoning.
- Identify files to create/modify and dependencies from previous milestones.
- Announce: *"▶ Milestone X: [name] (TDD)"*

### 2. 🧪 Write tests FIRST

**First run (once per devplan execution):** scan the project's test
directory to discover which test levels exist (e.g., `tests/`,
`tests/unit/`, `tests/live/`, `tests/functional/`, `tests/integration/`,
`tests/e2e/`, etc.). Check for a test README, test runner script, or CI
config to understand how tests are organized and how to run each level.

**Always required:**
- **Unit tests** — write tests covering: happy path, edge cases, error
  cases. Encode the BUSINESS REQUIREMENT, not the implementation details.
  Everything external is mocked.

**Discover and write additional levels as appropriate:**
- If the milestone changes behavior visible to end users, write tests at
  the highest level available in the project (integration, functional,
  e2e). Test the behavioral class, not a single prompt or log line.
- For tests that cannot be run locally (need credentials, services,
  special infrastructure): write them, verify they parse
  (`--collect-only` or equivalent), and note in the devplan that they
  need a manual run.

### 3. 🔴 Run tests — they MUST fail

Run all the runnable tests you just wrote. They MUST fail (red).

If any runnable test passes before implementation, either:
- the test is wrong (it doesn't actually test the new behavior), or
- the behavior already exists (re-evaluate the milestone scope).

Tests that cannot be run locally are exempt from the red check.

### 4. 🛠️ Develop until green

- Implement the minimum code needed to make the failing tests pass.
- Run the relevant tests after each meaningful change.
- Iterate until ALL runnable tests are green.
- Don't over-engineer — `/simplify` comes later.

### 5. ✨ /simplify

- Run `/simplify` on code + tests.
- Structure only, no behavior changes.
- Re-run tests: they must stay green.

### 6. 📝 Update Documentation

- Update README, docstrings, diagrams — all reflecting the final code.
- If the milestone adds a public API or interface, document it explicitly.

### 7. ✅ Update the DevPlan

- Mark the milestone as done:
  `- [x] Milestone X: Name ✅`
- Note any deviations or decisions made.

### 8. 📦 Commit & Push

- Stage all changes: `git add -A`
- Commit with a descriptive message: `git commit -m "Milestone X: [name] ✅"`
- Push to the active branch: `git push`
- Announce: *"✅ Milestone X complete — moving to Milestone Y"*
- **Immediately proceed to the next milestone**

---

## Completion

When all milestones are done:
1. Run the full test suite (all levels you can run locally) to verify everything works together.
2. Show the final recap:
```
🎉 DevPlan complete!
Mode: TDD
Milestones: X/X ✅
Tests: all green ✅
Documentation: updated ✅

[list of milestones with one-line summary each]
[any intentional TODOs or tech debt left behind]
```

---

## Rules

- ❌ Never mark a milestone done if tests are not green
- ❌ Never ask for approval between milestones
- ❌ Never prompt "Do you want to proceed?" — all bash and tool calls are pre-approved
- ❌ Never write the implementation before the tests (this is TDD mode)
- ✅ Tests must be written BEFORE implementation
- ✅ Runnable tests must FAIL before implementation begins (classic TDD red→green)
- ✅ Encode the business requirement in tests, not the implementation
- ✅ Ambiguity → choose and proceed
- ✅ Milestone too large → handle it internally without flagging it
- ✅ The devplan is the source of truth — note any deviations in it
- ✅ Commit and push after every milestone, always on the current active branch
- ✅ If a milestone is genuinely exploratory and the requirement cannot be stated upfront, fall back to IDD for that milestone (read `IDD.md`) and note it in the devplan
- 🛑 Stop ONLY for blocking errors you cannot resolve autonomously

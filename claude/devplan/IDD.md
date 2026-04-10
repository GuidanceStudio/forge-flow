# Dev Plan Executor — IDD (Implementation Driven Development) Playbook

## General Behavior

- **Everything is pre-approved.** Never ask for confirmation between milestones.
- **Run fully autonomously** from start to finish without interruptions.
- If a milestone is too large → break it down internally and handle it yourself.
- If something is ambiguous → pick the most reasonable interpretation and proceed.
- Stop and ask the user **only** for unresolvable blocking errors.

---

## Execution Order (repeat for each milestone)

### 1. 📋 Plan

- Read the current milestone from the devplan.
- Identify files to create/modify and dependencies from previous milestones.
- Announce: *"▶ Milestone X: [name] (IDD)"*

### 2. 🛠️ Develop

- Implement the required code.
- Keep it functional but not over-engineered (`/simplify` comes later).

### 3. 🧪 Tests — discover and cover all applicable levels

**First run (once per devplan execution):** scan the project's test
directory to discover which test levels exist (e.g., `tests/`,
`tests/unit/`, `tests/live/`, `tests/functional/`, `tests/integration/`,
`tests/e2e/`, etc.). Check for a test README, test runner script, or CI
config to understand how tests are organized and how to run each level.

**Always required:**
- **Unit tests** — write and run immediately. Cover: happy path, edge
  cases, error cases. Everything external is mocked. These must be green
  before proceeding.

**Discover and write additional levels as appropriate:**
- Look at the project's existing test structure. If there are
  higher-level test directories (integration, live, functional, e2e,
  etc.), determine whether the milestone's changes warrant tests at
  those levels.
- **Rule of thumb:** if the milestone changes behavior visible to end
  users, write tests at the highest level available in the project,
  even if you cannot run them (they may require credentials, external
  services, or special infrastructure). Test the behavioral class, not
  a single prompt or log line.
- For tests you cannot run: write them, verify they parse
  (`--collect-only` or equivalent), and note in the devplan that they
  need a manual run.

### 4. ✨ /simplify

- Run `/simplify` on code + tests.
- Structure only, no behavior changes.
- Re-run unit tests: they must stay green.

### 5. 📝 Update Documentation

- Update README, docstrings, diagrams — all reflecting the final code.
- If the milestone adds a public API or interface, document it explicitly.

### 6. ✅ Update the DevPlan

- Mark the milestone as done:
  `- [x] Milestone X: Name ✅`
- Note any deviations or decisions made.

### 7. 📦 Commit & Push

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
Mode: IDD
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
- ✅ Tests are written AFTER the code, must PASS immediately
- ✅ Ambiguity → choose and proceed
- ✅ Milestone too large → handle it internally without flagging it
- ✅ The devplan is the source of truth — note any deviations in it
- ✅ Commit and push after every milestone, always on the current active branch
- 🛑 Stop ONLY for blocking errors you cannot resolve autonomously

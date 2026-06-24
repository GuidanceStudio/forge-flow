# Devplan Executor — Shared Core Behavior

Loaded by both TDD and IDD execution modes. Contains all shared
sections: operating mode, preflight, simplify ladder, ponytail
convention, debt registration, shared execution-loop steps, test
policy, implementation standards, completion recap, and common rules.

---

## Operating mode

- **Everything is pre-approved.** Never ask for confirmation between
  milestones; run fully autonomously from start to finish.
- Treat the devplan as the source of truth for scope and ordering.
- Work milestone by milestone; do not batch unrelated milestones together.
- Before editing, check the project's instruction files (`CLAUDE.md` —
  root and global — for Claude Code; `AGENTS.md` / `.codex/instructions.md`
  for Codex) plus `README.md` and contributor docs.
- If a milestone is too large → decompose it internally into safe
  substeps and complete them without asking the user to do project
  management.
- If something is ambiguous → pick the most reasonable interpretation
  and proceed.
- Stop and ask the user **only** for real blockers:
  - missing or contradictory devplan requirements
  - changes that would conflict with unknown user work
  - required escalation the environment cannot perform automatically

---

## Preflight (once, before the first milestone)

- **Clean-worktree check.** Run `git status`. If the worktree contains
  uncommitted changes unrelated to this devplan's work, STOP and ask
  the user how to proceed (stash, commit, or include) — this falls
  under the "conflict with unknown user work" blocker. Unrelated work
  must never end up inside a milestone commit.
- **Resume detection.** If a pending milestone already has `[x]` tasks,
  or leftover changes match its scope, a previous run stopped midway.
  Reconcile against the actual code state (verify which tasks are
  truly done), note the resume in the devplan, and continue from the
  real state instead of redoing or skipping work.
- **Commit convention.** Read the repo's commit-message convention from
  recent history (`git log --oneline -20`): milestone-ID prefix style
  (e.g. `M12: title`, `D5-4: title`) and any trailers used
  consistently. Use it for every milestone commit; default to
  `MNN: <title>` if the repo has no clear convention.

---

## Simplify step

Run `/simplify` if the environment provides it; otherwise do an
explicit simplification pass on code + tests by hand.

Apply this ladder in order:

1. **Delete unneeded code** that is outside the milestone contract.
2. **Prefer the standard library** over custom helpers or a new
   dependency.
3. **Prefer native platform behavior** from the browser, runtime,
   framework, database, or operating system.
4. **Reuse an already-installed dependency** before adding another
   package or parallel implementation.
5. **Inline unearned single-use abstractions** until a second real
   implementation or caller exists.
6. **Reduce files and branches** when the same behavior remains clear.
7. **Compress or delete comments that don't carry their weight.**
   Delete comments that restate the code (the code is the "what").
   Compress verbose docstrings that paraphrase the function
   signature. Keep only: why (intent, trade-off, context the code
   can't express), gotchas (non-obvious behavior), and public-API
   contracts. Never remove ponytail: comments — those are
   intentional debt, not dead weight.

Structure only; no behavior changes. Devplan's existing test policy
wins: keep all applicable tests and established test levels rather
than replacing them with demos or a smaller test count.

Never simplify away trust-boundary validation, error handling that
prevents data loss, security controls, accessibility, explicit
requirements, project conventions, or the milestone's **Done when**
contract.

Re-run all applicable tests: they must stay green.

---

## ponytail: comment convention

When a simplification leaves a known ceiling — an O(n) scan fine at
current scale, a global lock fine at current concurrency, a regex fine
for the current input format — leave a structured comment above the
simplified code:

```
# ponytail: <what was simplified and why>.
# Ceiling: <measurable threshold>. Upgrade: <what to do when exceeded>.
```

The ceiling must be measurable (record count, request rate, input
complexity) so an automated audit can compare against current state.
Never use ponytail: to excuse bugs or missing validation — it marks
intentional trade-offs only.

---

## Register intentional debt

When the simplify pass produced a ponytail: comment, append a row to
`.code-audit/debt.tsv` in the project root. Schema:
`dim⇥location⇥title⇥ceiling⇥revisit_by`.

- `dim`: D01 (essentiality), D10 (performance), or D14 (correctness).
- `location`: `file:line`.
- `title`: one-line summary of the simplification.
- `ceiling`: the measurable threshold from the ponytail: comment.
- `revisit_by`: optional ISO date; omit for permanent shortcuts.

If the file doesn't exist, create it with the header row. Skip if the
same location+title pair already exists (idempotent).

---

## Shared execution-loop steps

### Update documentation

- Update README, docstrings, diagrams — all reflecting the final code.
- If the milestone adds a public API or interface, document it explicitly.

### Verify "Done when"

- Verify the milestone's **Done when** condition explicitly — run the
  command, hit the endpoint, observe the behavior it describes. Green
  tests alone do not count unless the condition says exactly that.
- **Use the scaffolded bring-up** when the milestone needs the app
  running: start the stack with the one-command bring-up, never a manual
  sequence, and verify behavior against the running service. If no
  bring-up exists, run `forge-flow scaffold` to create it (or extend it)
  rather than starting things by hand.
- If the condition cannot be verified locally (needs credentials,
  external services), record precisely what remains to be verified
  manually.
- **UI sanity check:** if the milestone has a `UX:` field, render the
  affected page(s) and verify: titles/labels/buttons are in the
  expected language, no class-name or internal-ID leaks in visible text,
  error/empty states use actionable copy. This catches the most common
  UX regressions without a full audit.

### Update the devplan

- Mark the milestone as done — tick every task and append the done
  marker to the milestone heading, matching the heading level the devplan
  uses: `## MNN: <title> ✅`.
- **Verify the bookkeeping landed.** Re-read the milestone block and
  confirm every task is checked (`- [x]`) and the heading carries its
  done marker. The rule:
  no unchecked task may remain for the milestone being closed.
  If a box is still unchecked, fix it now — the plan must report what is
  actually done. This is a gate, not advice: a green milestone with
  `- [ ]` tasks is an incomplete milestone.
- Note important deviations, decisions made, and how "Done when" was
  verified.
- Keep the devplan accurate enough that another agent could resume
  from it.
- If you discover the milestone is incomplete or the proposed fix is
  insufficient, update the devplan with the missing work instead of
  silently drifting. Never rewrite completed (`- [x]`) milestones —
  plan corrections land in the pending ones or in a note.

### Commit & push

- Stage ONLY the files touched by this milestone (explicit paths —
  never `git add -A` / `git add .`).
- **Stage the devplan with the milestone.** The checkbox and heading
  updates from the previous step are part of this milestone's changes —
  include the devplan file in the same commit, never as a later catch-up
  commit. The work and the record that it is done ship together.
- Commit following the repo's convention detected in preflight
  (default `MNN: <title>`).
- **Verify the devplan shipped in the commit.** After committing, run
  `git show --stat HEAD` and confirm the active devplan file is listed.
  If it is missing, `git commit --amend` to add it before pushing — the
  bookkeeping must travel in the milestone commit, never in a later
  catch-up. (Staging is asserted above; this is the check that proves it.)
- Push to the active branch when network/auth/repo policy allows it.
- If push or commit requires escalation, authentication, or network
  access not currently available, record the exact blocker in the
  devplan and surface it clearly — then continue with the next
  milestone only if that is safe.
- If the push succeeds but CI reports a failure later, add a note to
  the devplan with the failing job link and continue; CI failures
  after a pushed milestone are a separate follow-up, not a reason to
  block the current run.
- Never rewrite or discard unrelated user changes.
- Announce: *"✅ Milestone X complete — moving to Milestone Y"* and
  **immediately proceed to the next milestone**.

---

## Test policy

**First run (once per devplan execution):** discover the project's real
test structure. Check:

- `tests/` layout (e.g. `tests/unit/`, `tests/integration/`,
  `tests/live/`, `tests/functional/`, `tests/e2e/`)
- test README or contributor docs
- project scripts (`Makefile`, `package.json`, `justfile`, CI config,
  custom runners) to learn how each level is organized and run

Then apply this rule:

- **Always add unit coverage** for new logic. Cover: happy path, edge
  cases, error cases. Everything external is mocked.
- Add higher-level tests when the milestone changes user-visible
  behavior, cross-module integration, workflows, or recovery paths.
  Prefer the highest already-established level in the repo
  (integration, live, functional, e2e).
- **Live tier (first-class, not a fallback).** When a milestone touches a
  real external dependency, add a live test that makes
  real, non-prod calls verifying the true use case end-to-end.
  Isolate from production: use test/sandbox credentials, separate keys
  or a dedicated `.env.test`, and dedicated test resources —
  never run the live tier against prod. When the credentials or service
  are absent or still placeholders, skip-with-reason rather than fail.
  Unit coverage stays mandatory; the live tier is additive.
- For tests that cannot be run locally (credentials, external services,
  special infrastructure): write them when justified, verify they parse
  (`--collect-only` or equivalent), and note in the devplan that they
  need a manual run.

Avoid overfitting tests to a single prompt or log line. Test the
behavioral class instead.

**Mode-specific timing:** In TDD mode, write all applicable test levels BEFORE implementation (red first). In IDD mode, write tests AFTER implementation (green immediately).

---

## Implementation standards

- Prefer general runtime fixes over prompt-only tweaks when the failure
  is structurally detectable.
- Avoid special cases that exist only to satisfy one test.
- Keep changes narrow, composable, and reversible.
- **No manual setup — always replicable.** Never bring the stack up by
  hand or apply ad-hoc, one-off setup. Drive the scaffolded bring-up to
  start the app, and encode any setup or environment change in the
  bring-up or test script (or run `forge-flow scaffold` to extend it),
  never a manual step — so the next run reproduces the state. If a needed
  script is absent, create or extend it (or record a ponytail/debt note
  when that is genuinely out of the milestone's scope).
- Preserve existing user-facing behavior unless the milestone
  explicitly changes it.
- **Microcopy rule:** when writing user-facing strings (labels, error
  messages, button text, empty states, placeholders), follow the
  project's language conventions (detect from existing UI or
  CLAUDE.md/AGENTS.md). Use the project's language consistently; never
  leak class names, file paths, ticket codes, or internal IDs into
  visible text. Error messages say what happened and what to do.
  Empty states guide the next action.

---

## Completion

When all milestones are done:

1. Run the broadest local test set that is practical (all levels you
   can run locally) to verify everything works together.
2. **Sweep the devplan for unfinished bookkeeping:** every milestone
   closed during this run must show `- [x]` for all its tasks and a done
   marker on its heading. Fix any milestone still showing an unchecked
   task before the recap — the run is not complete while the plan still
   misreports its own state.
3. Show the final recap:

```
🎉 DevPlan complete!
Mode: {TDD|IDD}
Milestones: X/X ✅
Tests: all green ✅
Documentation: updated ✅

[list of milestones with one-line summary each]
[tests written but not run locally, and why]
[any intentional TODOs, tech debt, or residual risks left behind]
[debt registered: N items → .code-audit/debt.tsv]
[follow-up work already added back into the devplan]
```

4. Ensure the final completed state has already been committed and
   pushed (or the exact blocker recorded in the devplan).

---

## Common rules

- ❌ Never mark a milestone done if its relevant tests are not green
- ❌ Never ask for approval between milestones
- ❌ Never prompt "Do you want to proceed?" — everything is pre-approved
- ❌ Do not turn execution into a long planning exercise
- ❌ Never mark a milestone done without verifying its **Done when**
  condition
- ❌ Never stage with `git add -A` / `git add .` — explicit paths only
- ❌ Never commit a milestone whose devplan tasks and heading aren't
  marked done — the bookkeeping ships in the milestone commit
- ✅ Encode the business requirement in tests, not the implementation
- ✅ Ambiguity → choose and proceed
- ✅ Milestone too large → decompose internally without flagging it
- ✅ The devplan is the source of truth — note any deviations in it
- ✅ Match the repo's commit-message convention (detected in preflight)
- ✅ Commit and push after every milestone, always on the current
  active branch
- 🛑 Stop ONLY for blocking errors you cannot resolve autonomously

> **Mode-specific rules** live in TDD.md and IDD.md respectively.

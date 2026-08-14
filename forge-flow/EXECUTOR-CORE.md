# Devplan Executor — Shared Core Behavior

Loaded by both TDD and IDD execution modes. Contains all shared
sections: operating mode, preflight, simplify ladder, comment rules,
ponytail convention, debt registration, shared execution-loop steps,
stuck protocol, test policy, implementation standards, completion
recap, and common rules.

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

## Milestone state markers

A milestone (and its tasks) moves through three states in the devplan — the
marker IS the record of where the work stands:

- **Not started:** heading `## MNN: <title>` (bare), tasks `- [ ]`.
- **In progress:** heading `## MNN: <title> 🔄`, and the task under active
  work `- [~]`. Flip to this the moment you begin the milestone (at the
  step-1 announce), BEFORE writing tests or code.
- **Done:** heading `## MNN: <title> ✅`, every task `- [x]`.

The in-progress `🔄` is a **working-tree signal, not a separate commit**: it
lives only between start and the done step, where it becomes `✅` and ships
inside the milestone commit. Its whole job is resumability — a run that dies
mid-milestone leaves an uncommitted `🔄` (or a `- [~]` task) that
unambiguously marks where to pick up. A `🔄` still showing when no work is
active is a dangling marker: either resume it or close it — never leave it.

---

## Preflight (once, before the first milestone)

- **Clean-worktree check.** Run `git status`. If the worktree contains
  uncommitted changes unrelated to this devplan's work, STOP and ask
  the user how to proceed (stash, commit, or include) — this falls
  under the "conflict with unknown user work" blocker. Unrelated work
  must never end up inside a milestone commit.
- **Resume detection.** A milestone heading marked `🔄` — or any `- [~]`
  or `[x]` task under a pending milestone, or leftover changes matching its
  scope — means a previous run stopped midway. The `🔄`/`- [~]` markers are
  the unambiguous signal; the rest are inferred. Reconcile against the actual
  code state (verify which tasks are truly done), note the resume in the
  devplan, and continue from the real state instead of redoing or skipping
  work.
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
   Apply the rules in "Comments" below: delete what restates the code
   (the code is the "what"), compress a docstring that paraphrases the
   signature, route out what git already holds, and keep the invariant.
   Never remove ponytail: comments — those are intentional debt, not
   dead weight.

Structure only; no behavior changes. Devplan's existing test policy
wins: keep all applicable tests and established test levels rather
than replacing them with demos or a smaller test count.

Never simplify away trust-boundary validation, error handling that
prevents data loss, security controls, accessibility, explicit
requirements, project conventions, or the milestone's **Done when**
contract.

Re-run all applicable tests: they must stay green.

---

## Comments

A comment carries what the code cannot state itself: the invariant it must
hold, the constraint that forced this shape, the reason the obvious
alternative is wrong. Write it in the present tense, about the code as it
is now.

**Three kinds of content belong in git, not in the comment.** Each is
greppable, so a project can enforce them:

- **A past date or an incident** — `Measured 2026-08-14`, `Found on the
  first run after the credentials were restored` — goes in the commit
  body. `git blame` answers "when did this line appear, and why" without
  a second copy that rots when the code moves. A *forward* deadline is
  different and stays: `the v1 API sunsets 2027-01-01` is a fact about
  the future the reader has to act on.
- **A milestone or ticket ID** — `M-OPS-CI-RED-1`, `PROJ-412` — goes in
  the commit body. The ID names a unit of work; the reader of this line
  needs the rule that work produced, and has no way to resolve the ID.
  The exception is an ID that is a **join key to a document in the same
  repo**: when a test block pins the wording a specific milestone
  introduced and that plan sits beside it, deleting the ID costs the
  maintainer the one handle that says which entry to open.
- **Markdown or emoji in an inline comment** — `**bold**`, `⚠️`, a
  headline above the text — gets deleted. An inline comment is read as
  plain text in an editor, so the markup is noise. Two exceptions: doc
  comments that a generator renders (docstrings, JSDoc, `///`), where the
  markup is the format; and a **literal being quoted**, where the marker
  is the value under test and not decoration.

**Revise the comment, never append to it.** A milestone that changes
commented code rewrites that comment to state the current invariant; it
does not add its own episode below the previous one. Appending is how a
comment block grows once per run until it is a changelog the repository
already keeps — measured at 65 consecutive comment lines above a single
line of code, written by four milestones in sequence.

**No slogans**, the same rule the project's other prose follows. A comment
that opens on a headline — `The HOST decides, not the port` — asserts a
contrast where it owes the reader a rule.

**Length is a routing signal.** A comment block longer than the code it
introduces usually means most of it belongs elsewhere; send the overflow
through "Where the rest goes". It is not a limit: a genuinely subtle
three-line algorithm can earn six lines of why.

A worked example, from a shell tool that opens an SSH tunnel to reach
remote state:

```bash
# BEFORE — 12 lines, one of them about the code
# ⚠️ **The HOST decides, not the port.** A tunnel forwards LOOPBACK, so it
# can only serve a connection aimed at loopback — the assumption the block
# above states outright and this function never checked. Deciding on the
# port alone meant a connection string naming any other host still opened
# an SSH session to the plane: useless for that connection, and a run
# reaching production without being asked to.
#
# Measured 2026-08-14, `M-OPS-CI-RED-1`: four tests supply a deliberately
# fake `state.example:5432`, 5432 is not open on a CI runner, and the
# suite died trying to SSH to the production host. On a developer machine
# the same path succeeds silently, which is worse than the red.

# AFTER — the invariant, minus everything git already holds
# A tunnel forwards loopback only, so route on the target host and not the
# port: a connection naming any other host would otherwise open an SSH
# session to the plane that it can never use.
```

### Comments in tests

A test's **name** carries its why. When a comment explains what the test
verifies, that sentence is the name in the wrong place — rename the test
and delete the comment. `no tunnel opened when the state host is not
loopback` needs nothing above it.

Comment only what a name cannot hold:

- why a fixture value is what it is — `state.example` is unresolvable on
  purpose, `0.1` is below the configured threshold
- why a test is skipped, xfail, or order-dependent
- what an opaque constant, magic byte, or captured payload means

Never in a test: `# Arrange` / `# Act` / `# Assert` labels, a restatement
of the assertion on the next line, or the story of the bug that motivated
the test. The test is that record — it fails if the bug comes back.

One shape of restatement is worth naming because it reads as useful:
**when the assertion's argument is a verbatim quote of the thing under
test** — a documentation anchor, a golden-file line, an expected error
string — a comment paraphrasing that quote adds nothing by construction.
What earns its place beside such an assertion is the rule the quote must
satisfy, a group label over several of them, or a discriminator
explaining why two near-identical anchors both exist.

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
`.tech-audit/debt.tsv` in the project root. Schema:
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
- **Evidence before claims.** A completion claim (tests green, Done-when
  met) requires a command run in this session with its output and exit
  code actually read. Cached, remembered, or partial output does not
  count. Hedged phrasing in a would-be claim ("should", "probably",
  "seems to") means it is not verified — run the command instead. A
  subagent's success report counts only when it carries the command and
  its output.
- **Use the scaffolded bring-up** when the milestone needs the app
  running: start the stack with the one-command bring-up, never a manual
  sequence, and verify behavior against the running service. If no
  bring-up exists, run `forge-flow scaffold` to create it (or extend it)
  rather than starting things by hand. **Exception — greenfield day zero:**
  on the first runnable milestone of a greenfield project the app does not
  exist yet, so mount the spine **as part of that milestone** (per the spine
  decision recorded in DESIGN); scaffold has nothing to wrap before the app
  exists.
- If the condition cannot be verified locally (needs credentials,
  external services), record precisely what remains to be verified
  manually.
- **UI sanity check:** if the milestone has a `UX:` field, render the
  affected page(s) and verify: titles/labels/buttons are in the
  expected language, no class-name or internal-ID leaks in visible text,
  error/empty states use actionable copy. This catches the most common
  UX regressions without a full audit.

### Update the devplan

- **Two-verdict self-check** before marking done:
  - **Spec:** re-read the milestone's Tasks and Done-when — everything
    implemented, and nothing implemented beyond the contract.
    Unrequested extras: delete them via ladder rung 1, or record them
    in the devplan when genuinely needed.
  - **Quality:** the simplify pass ran; all applicable tests are green.
- Mark the milestone as done — tick every task (`- [~]` → `- [x]`) and
  swap the in-progress `🔄` for the done marker on the milestone heading,
  matching the heading level the devplan uses: `## MNN: <title> ✅`.
- **Verify the bookkeeping landed.** Re-read the milestone block and
  confirm every task is checked (`- [x]`) and the heading carries its
  ✅ done marker — no `- [~]` task and no `🔄` heading left behind. The rule:
  no unchecked task may remain for the milestone being closed, and no
  in-progress `- [~]` task either.
  If a box is still `- [ ]` or `- [~]`, fix it now — the plan must report what
  is actually done. This is a gate, not advice: a green milestone with
  `- [ ]` or `- [~]` tasks is an incomplete milestone.
- **The write-back is bounded.** Append a `**Deviations:**` block of **at most
  5 lines**, and write it **only when execution diverged from the plan** — after
  a run that followed the plan, the ticks are the record and no prose is owed.
  It carries: a decision taken differently, a constraint discovered, work found
  to be missing. It does not carry a retelling of what was built, nor how
  "Done when" was verified when it was verified as written.
- **Never write prose under a task box.** A `- [x]` is one line. A fact
  discovered while executing becomes a new task or a Deviations line, never a
  paragraph beneath a tick — measured at 35% of the words in one production
  devplan, and unreadable to anyone scanning the plan for state.
  One thing this does not reach, because it is not a milestone's task list: an
  **acceptance gate**, where each box is a check somebody ran and the prose under
  it is the evidence that it passed — a received header, an alert that fired, a
  DNS query answered. Keep that. It is the same case as an archived milestone
  with no commit: nothing else records it.
- Keep the devplan accurate enough that another agent could resume from it.
  That is a test of **state** — which milestone, which task, what is left — not
  of narrative completeness.
- If you discover the milestone is incomplete or the proposed fix is
  insufficient, update the devplan with the missing work instead of
  silently drifting. Never rewrite completed (`- [x]`) milestones —
  plan corrections land in the pending ones or in a Deviations line.

#### Where the rest goes

Execution produces more knowledge than the plan should carry. Route it:

| What | Where |
|---|---|
| Design rationale, trade-off, gotcha about the code | a comment where that code lives |
| What happened, in what order, and why | the commit body |
| A contract readers outside the plan need | `docs/` |
| Residual or newly discovered work | a new milestone, never inside a closed one |
| A measured ceiling accepted on purpose | `ponytail:` + `.tech-audit/debt.tsv` |
| A measurement motivating work not yet started | the milestone's own Why/Approach — **nothing else holds it yet** |

The commit body says what this change did; the devplan says what is done and
what is left. Writing the account in both places doubles the words and leaves
two versions to keep true.

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

## Stuck protocol

When green won't come, find the cause — don't patch the symptom.

- **From the second fix attempt on the same failure:** state a one-line
  root-cause hypothesis grounded in observed evidence (error text, stack
  trace, diff) BEFORE touching code. Change one variable per attempt —
  no shotgun fixes.
- **Suspected flake:** re-run the test unchanged once to confirm the
  failure is deterministic before it counts as an attempt.
- **After three failed attempts on the same failure, stop patching.**
  The problem is architectural, not tactical. Write down what the
  attempts collectively prove, re-read the milestone's Approach and the
  assumptions behind it, then either take a structurally different
  approach or update the devplan (revise the milestone, add the missing
  work) — never a fourth attempt of the same shape.
- **Banned moves:** widening an assertion, adding a sleep, swallowing
  the exception, skipping the test. Each is legal only with an explicit
  justification recorded in the devplan notes.

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

A test's name is where its intent belongs; comment only what the name
cannot hold (see "Comments in tests").

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
[debt registered: N items → .tech-audit/debt.tsv]
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
- ❌ Never archive a milestone or compress closed ones mid-run —
  archiving is the user's call in design mode (DESIGN.md "Archive")
- ❌ Never make a fourth same-shape fix attempt — after three failures
  on the same failure, revisit the design (see Stuck protocol)
- ❌ Never claim completion on stale or unread output — evidence is a
  command run in this session whose output you actually read
- ✅ Encode the business requirement in tests, not the implementation
- ✅ Ambiguity → choose and proceed
- ✅ Milestone too large → decompose internally without flagging it
- ✅ The devplan is the source of truth — note any deviations in it
- ✅ Match the repo's commit-message convention (detected in preflight)
- ✅ Commit and push after every milestone, always on the current
  active branch
- 🛑 Stop ONLY for blocking errors you cannot resolve autonomously

> **Mode-specific rules** live in TDD.md and IDD.md respectively.

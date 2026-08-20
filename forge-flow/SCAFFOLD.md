# Forge-flow — Scaffold

Mount the **operational spine** every runnable project needs: one command
that brings the whole stack up, one command that runs tiered tests, live
tests that exercise real use cases with real-but-non-prod credentials, and
setup that is never manual — it is codified in scripts so the next run
reproduces the state.

This is a **generation playbook**, not a template library. It detects the
stack and the project's existing idiom, then generates the spine
**idempotently** (extend what exists, **never clobber** the project's own
files). Project-specific bits are left as explicit `TODO` markers rather
than guessed.

`scaffold` runs **outside** the milestone loop: it is infrastructure, not a
feature, so it never becomes a devplan milestone. Run it before executing a
plan, not as part of one.

## Runnable-app guard (first, before anything)

Scaffold targets **runnable apps and services** — something a user starts and
talks to (web app, API, worker, CLI daemon, anything with a process to bring
up and integration/live behavior to test).

If the project is a **pure library, a skill/prompt package, or a static
site** with no process to run and nothing live to test, **refuse** with a
clear one-line message and stop — do not generate a fake spine. Example:
*"forge-flow scaffold targets runnable apps/services; this looks like a
library (no entrypoint/process to bring up). Nothing to scaffold."*

## Phase 1 — Detect stack and idiom

Read, in parallel, what reveals how the project is built and run:

- **Stack:** manifest files (`package.json`, `pyproject.toml`/`requirements.txt`,
  `composer.json`, `go.mod`, `Cargo.toml`, `Gemfile`), Dockerfiles,
  `docker-compose*.yml`, framework markers.
- **Existing idiom — reuse it, never fight it.** Detect how the project
  already exposes commands and pick the same channel:
  - a `Makefile` with targets → add targets,
  - a `dev.sh` / `scripts/` directory → add scripts,
  - `package.json` scripts → add scripts,
  - `docker-compose.yml` → drive it from the bring-up.
  When the idiom is a thin one-line dispatcher (an npm script, a Make
  target) but the bring-up needs non-trivial logic (readiness-poll,
  `--fresh`/`--down`, env parsing), put that logic in a script
  (e.g. `dev.sh`) and wire the idiom to call it (`"dev": "./dev.sh"`).
  The dispatcher stays the entry point; the script holds the behavior.
- **External services:** databases, queues, caches, third-party APIs — these
  decide whether a prod-isolation skeleton is needed.
- **Existing tests:** current `tests/` layout, runner, and any CI config, so
  the generated runner matches established levels instead of inventing new ones.

State a 3-5 line **Scaffold Brief** in chat: detected stack, chosen idiom,
external services found, and what the spine will add vs. what already exists.

## Phase 2 — Generate the spine (idempotent, extend-never-clobber)

Generate only what is missing; extend what exists; **never overwrite** a file
the project already owns without merging. Re-running scaffold on an already-
scaffolded project must be a no-op (or a clean extension), never a clobber.

Standard scope:

1. **One-command bring-up** (the project's idiom: `make up` / `./dev.sh` /
   `npm run dev` / compose). It must:
   - bootstrap `.env` from `.env.example` if absent,
   - load `.env` by **parsing `KEY=VALUE` lines**, never by `source`-ing the
     file: placeholder values like `<REPLACE_WITH_…>` contain shell
     metacharacters that break sourcing,
   - start every dependency the app needs,
   - **readiness-poll** each service until it actually answers (never a blind
     `sleep`), failing with a clear message on timeout,
   - support `--fresh` (rebuild from clean state) and `--down` (tear down).

2. **A tiered test runner `run_tests.sh`** with:
   - tiers `unit`, `integration`, and `live` (run all, or one tier by name),
   - **a fourth tier, `fast`, defined by what it costs rather than by how real
     it is.** The three above split on how much of the system a test touches.
     This one runs tests the other tiers already own, over the artifact that is
     already built — the working tree mounted or copied into the service that is
     already up, no image rebuild and no stack restart — and it is measured in
     seconds, so it is the loop somebody runs while typing. It owns no test
     directory: it is a route over the existing ones.
     **It refuses an unscoped run**, or narrows itself to the files changed
     against the merge-base and says which of the two it did. A tier whose value
     comes from being scoped, and which runs everything when given no argument,
     spends minutes on the first invocation anybody tries and is not tried a
     second time — measured on a route added outside a spine like this one: with
     no argument it ran for six and a half minutes, under the name fast. The
     refusal prints the scoped forms, `./run_tests.sh fast <path>` and
     `./run_tests.sh fast --changed`, and exits non-zero.
   - **a faster route over the same tests must be proven to return the same
     verdict as the slow route on the same selection, or refuse to run.** Until
     that is proven its result is a second opinion, not the tier's. The failure
     it guards against is specific: the fast route's environment is missing a
     precondition the slow route's setup writes — a migration, a seeded fixture,
     a variable the build step exports — so it reports failures that exist only
     in it. Measured on one such route: 270 failed against 3,681 passed, where
     the full tier over the same tests reported 4,018 passed and none failed,
     all 270 of them from a single precondition the fast route's container never
     received. Once a route has reported failures that were not real, its next
     report is not read either.
     Prove it before offering the route, and falsify the proof: run both over
     the same selection, require identical pass and fail sets, then **remove the
     precondition, and the failures must come back**. A comparison that stays
     green with the precondition gone is comparing nothing.
   - **skip-with-reason** gating: when a tier's prerequisites are absent
     (no credentials, service down), skip it and print *why* — never fail
     silently and never pretend it ran,
   - scriptable **exit code**s (non-zero on any real failure) so CI and other
     scripts can gate on it,
   - a final pass/fail/skip recap,
   - **per-test timing**: the runner times each test and prints the five slowest
     on every run, and fails on one over a ceiling. A tier total cannot show
     which test is the slow one, so a single test holding half a tier reads as
     a tier that is evenly slow. **Printing them every run** matters as much as
     the ceiling: drift underneath it is how the next slow test arrives, and a
     reporter that speaks only when the ceiling breaks says nothing until it
     already has. Set the ceiling **generous enough that a legitimately slow
     test** — one doing real crypto or archiving — does not red; it is there to
     catch a test that waits, which is an order of magnitude away, not a test
     that works.

     ⚠️ Prove the reporter against the output the runner really emits. Many
     test runners carry two formats and choose by **whether stdout is a
     terminal**, so a parser written against the documented one can report
     nothing at all on every real run — a guard against slow tests that cannot
     see a slow test.

   - **a per-tier budget beside the per-test ceiling**: each tier declares the
     wall-clock time it is allowed, the runner prints the tier total against it,
     and a tier over its budget reds. The two ceilings answer different
     questions and neither covers the other. A per-test ceiling catches a test
     that waits; it cannot catch a tier that is expensive because of what
     surrounds the tests. Measured on one project: its test framework ran in
     four seconds and the remaining eleven minutes of that tier was rebuilding
     the artifact under test. Measured separately: 1,508 cases averaging ~200 ms
     summed to 5.2 minutes, none of them within an order of magnitude of a
     per-case ceiling. In both the cost sat outside any one test, so the
     per-test rule reported every test healthy. When a tier goes over budget,
     read the total before the slowest five — what a budget usually names is a
     build, a fixture rebuilt per test, or a container started per file, and
     none of those is a test to fix.

3. **`.env.example`** listing every variable the app and the live tier need,
   with **test-credential placeholders** (`<REPLACE_WITH_…>`), never real
   secrets.

4. **`tests/` tier directories** (`tests/unit/`, `tests/integration/`,
   `tests/live/`) matching the runner, created only if missing.
   **Seed one TODO-marked smoke test per tier** (a health-endpoint check
   for integration, a real-call check for live) so every tier is
   immediately runnable — an empty tier dir can only ever skip, never
   demonstrate a pass. Mark each seed with a `TODO:` so it reads as a
   starting point to flesh out, not finished coverage.

5. **Prod-isolation skeleton** — when the stack has external services, generate
   a `.env.test` (or `docker-compose.test.yml`) so the live tier runs against
   dedicated **non-prod** resources: separate keys, sandbox endpoints, a
   throwaway test database. The live tier must never touch prod.

6. **A `comments` check in the runner**, running the patterns from
   `EXECUTOR-CORE.md`'s "Comments" section over the merge-base diff:
   `git diff --name-only "$(git merge-base HEAD origin/<default-branch>)"...HEAD`,
   filtered to source extensions and with vendored trees excluded. **The diff
   scope is what makes it usable** — a repo-wide version reds on every legacy
   file the day it lands and is disabled within the week. Skip-with-reason
   outside a git repo, with no merge-base, or when no source file changed.
   Print each hit as `file:line`, in line order, and exit non-zero.
   **All four surfaces, not just the inline one**: a line comment takes every
   ban, a doc comment and a Python docstring take the date and ID bans but keep
   their markup. Three of the four were missed by the first version of this
   check, and a project that only greps line comments will report clean while
   most of its ticket IDs sit in doc blocks.
   Where the project pushes to its default branch rather than opening pull
   requests, the merge-base with that branch is `HEAD` and the diff is empty:
   pass the push range explicitly instead, or the check skips on every run that
   counts and reports success for having read nothing.
   Because two of the section's carve-outs are not expressible as a pattern
   (a forward deadline, a quoted marker), the check honours a per-line
   escape: a comment carrying `comment-check: ok` is excluded. That is the
   difference between this and the executor's own run of the same pattern —
   CI needs a deterministic verdict, so it gets an explicit way to record a
   cleared hit; the executor reads the hits and judges them directly.

7. **A local gate only for what CI does not already pay for.** When CI builds
   the artifact and runs the full tier on every push, a pre-commit or pre-push
   hook doing the same buys one answer twice: the developer waits for the build,
   then the remote builds it again, and the remote's run is the verdict that
   counts. Decide each check by whether the check needs the artifact rebuilt —
   if it does, it runs on the push. What stays local is fast and specific: the
   `fast` tier over the changed files, a lint, a formatter, the `comments` check
   over the diff.

Leave project-specific decisions the playbook cannot safely infer as explicit
`TODO:` markers in the generated files (e.g. `# TODO: add the readiness check
for <service>`), so a human or a later run completes them deliberately.

## Phase 3 — Verify by running

Reuse `EXECUTOR-CORE.md` verify/commit discipline:

- Run the generated `run_tests.sh` — it must execute and report a clean
  pass/skip recap (no tier failing for a setup reason).
- Where possible, run the bring-up and confirm services reach ready.
- **Re-run scaffold generation** and confirm it does **not clobber**: the
  second pass produces no destructive diff.
- Commit the generated spine with the repo's convention; never stage unrelated
  files.

## Done when

The project has a one-command bring-up and a tiered `run_tests.sh` that runs
green (or skips with reason), `.env.example` documents the test credentials,
a prod-isolation skeleton exists when external services are present, the
`comments` check runs over the merge-base diff (or skips with reason), the
`fast` tier refuses an unscoped run and its verdict has been proven equal to the
full tier's on the same selection, each tier carries a budget the runner checks,
re-running scaffold does not clobber, and a non-runnable project is refused
with a clear message.

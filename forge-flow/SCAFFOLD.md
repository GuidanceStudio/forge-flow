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
   - **skip-with-reason** gating: when a tier's prerequisites are absent
     (no credentials, service down), skip it and print *why* — never fail
     silently and never pretend it ran,
   - scriptable **exit code**s (non-zero on any real failure) so CI and other
     scripts can gate on it,
   - a final pass/fail/skip recap.

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
a prod-isolation skeleton exists when external services are present, re-running
scaffold does not clobber, and a non-runnable project is refused with a clear
message.

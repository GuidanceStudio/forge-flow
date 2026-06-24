# forge-flow — skill payload

An assistant-neutral skill that handles the full forge-flow lifecycle:
planning (`design`) and execution (`TDD` / `IDD`). One flat folder,
installable into any coding assistant that reads skills.

> This is the skill payload. See the [project README](../README.md) for
> install + the multi-assistant installer.

## What it does

Three modes plus a `scaffold` route (see `SKILL.md` for full details):
- **`design`** — structured discovery → proposal → approval → write → validate.
  Passes milestones through an essentiality checkpoint.
- **`TDD` (DEFAULT)** — test-first per milestone: requirement → red tests →
  green implementation → simplify → commit & push.
- **`IDD`** — implement-first: code → tests → simplify → commit. For
  exploratory milestones.
- **`scaffold`** — mount the operational spine (one-command bring-up + tiered
  `run_tests.sh` with unit/integration/live tiers) outside the milestone loop.
  Generates idempotently, never clobbers, and refuses non-runnable projects.

Execution modes run autonomously milestone by milestone, committing and
pushing after each, stopping only on real blockers.

Across modes: **design → implement → simplify** — design removes
speculative work; execution applies the essentiality ladder and re-runs
all applicable tests.

## Requirements

A coding assistant that loads skills; a project with a Markdown devplan
file; Git with a remote for push.

## Skill files

- `SKILL.md` — entry point and router (design / TDD / IDD / scaffold)
- `DESIGN.md` — planning playbook (discovery, proposal, writing, validation)
- `TDD.md` — Test Driven Development execution playbook (default)
- `IDD.md` — Implementation Driven Development execution playbook
- `SCAFFOLD.md` — operational-spine generation playbook (bring-up + tiered runner)
- `EXECUTOR-CORE.md` — shared behavior for execution modes (operating mode,
  preflight, simplify ladder, ponytail, debt registration, test policy, etc.)
- `agents/openai.yaml` — optional Codex interface metadata (ignored by
  other assistants)

`SKILL.md` loads only the playbook for the chosen mode, so the agent
follows a single self-contained set of instructions per run.

## Ponytail integration

[`DietrichGebert/ponytail`](https://github.com/DietrichGebert/ponytail) is
Conceptual prior art for the essentiality ladder (MIT). Runtime dependency:
none. forge-flow imports concepts, not code; its scope, safety, test, and
completion rules remain authoritative.

## Usage

Invoke however your assistant invokes skills, then pick a mode:

```
/forge-flow design                  # create or update a dev plan
/forge-flow TDD                     # execute TDD (recommended default)
/forge-flow IDD                     # execute IDD (exploratory)
/forge-flow TDD devplan/v0.9.md     # TDD on a specific devplan file
/forge-flow devplan/v0.9.md         # path alone defaults to TDD
/forge-flow scaffold                # mount the operational spine (runnable apps)
```

- **TDD** for clear, testable requirements (bug fixes, features, refactors).
- **IDD** for exploratory work (spikes, prototypes). The skill can fall back
  to IDD per-milestone automatically when TDD can't articulate the requirement.

### Tips

- Milestones need clear, actionable checkboxes (`- [ ]` pending, `- [x]` done)
- The skill respects your project's existing test structure
- Interrupt your assistant to pause mid-run

## Devplan format

The skill works with any Markdown file that has milestone headings and checkbox task lists. A minimal example:

```markdown
# My Project Dev Plan

## M1: Add user authentication
- [ ] Implement login endpoint
- [ ] Add JWT token generation
- [ ] Write unit tests

## M2: Add password reset flow
- [ ] Send reset email
- [ ] Implement token validation
```

No specific format is required beyond readable headings and checkboxes.

## License

MIT

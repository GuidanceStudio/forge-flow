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
speculative work; execution applies the simplify ladder and re-runs
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
  preflight, simplify ladder, comment rules, ponytail, debt registration,
  test policy, the close-out move to the completed file, etc.)
- `SPECS-ADAPTER.md` — worked example of an executable spec adapter, opened
  only when a project's first adapter is written
- `agents/openai.yaml` — optional Codex interface metadata (ignored by
  other assistants)

`SKILL.md` loads only the playbook for the chosen mode, so the agent
follows a single self-contained set of instructions per run.

## Ponytail integration

[`DietrichGebert/ponytail`](https://github.com/DietrichGebert/ponytail) is
conceptual prior art for the simplify ladder (MIT). Runtime dependency:
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
- Repeated concepts prompt a semantic and scope check before extraction;
  [names use requirement language](EXECUTOR-CORE.md#naming) for code and tests
- Interrupt your assistant to pause mid-run

## Decision log

A choice that constrains work beyond the milestone that took it goes in
`DECISIONS.md` beside the active devplan, not in a milestone that will be
archived. Both modes use it: design reads it before proposing and writes what
the clarification settled, execution reads it in preflight and appends in the
milestone's own commit. Format and the gate on what earns an entry live in
`EXECUTOR-CORE.md`, "Record a binding decision".

## Project principles

Design proposes numbered trade-offs in root `PRINCIPLES.md`, preserving an
existing equivalent, and writes them on the plan's approval. Linked instruction
snippets are provided for the user to insert. Execution reads saved principles
before work and on resume; projects without them remain executable.

Decisions may cite a `Principle:` and record an approved departure with a reasoned
`Exception:`. Existing decision entries remain valid. A reason alone does not
authorize an exception.

Projects can approve a `## Reviewers` section there: published references,
explicit heuristics and applicable scopes. Design proposes the relevant defaults
and records user edits. [Configured review](EXECUTOR-CORE.md#configured-review)
applies that saved configuration beside simplification, requires evidence,
deduplicates findings and routes confirmed work by milestone scope.

For data, access and external-service changes, design proposes scoped threats
and negative-test tasks, then persists the approved `THREATS.md` section with
the plan. Execution checks policy violations at the selected mode's timing and
looks for other occurrences of a fixed defect's cause within the approved scope.

[Security verification](EXECUTOR-CORE.md#security-verification) separates findings,
uncertainties and hardening, and records actual check outcomes, including checks
that could not run. Critical findings and mandatory non-passes block completion
and shipping unless project policy allows explicit, documented risk acceptance.

## Executable specifications

Behaviour rows live in `specs/<area>.tsv`; `specs/INDEX.tsv` maps affected files
to the relevant areas, including shared scopes and splits above 40 rows. Tests
read those rows from disk using the project's adapter. See
[Executable specifications](EXECUTOR-CORE.md#executable-specifications) for the
layout, scope rules and an executable example that rejects uncovered rows.
Existing projects characterize unspecified behaviour only where the milestone
changes it, with a green baseline before edits in either mode. File scopes and
row counts establish only partial behavioural coverage; unrelated gaps stay
unspecified. Observing a bug does not make it the desired requirement.

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

A plan lives in one file or two. In the two-file layout the active file carries
the work queue and a companion `*-COMPLETED.md` carries the closed milestones,
which keeps a session's context proportional to the work left rather than to the
project's age. A closed milestone moves verbatim at close-out; compressing it is
a separate decision the user makes in `design` mode. Single-file plans stay
valid, and the split is suggested, never applied unasked.

## License

MIT

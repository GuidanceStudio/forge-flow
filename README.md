# forge-flow

Unified skill for coding agents that handles the full forge-flow
lifecycle: planning (`design`) and execution (`TDD` / `IDD`).

One skill, three modes plus a `scaffold` route (see `forge-flow/SKILL.md` for full details):
- **`design`** — plan milestones; **`TDD`** (default) — test-first; **`IDD`** — implement-first for exploration.
- **`scaffold`** — mount the operational spine (one-command bring-up + tiered `run_tests.sh` with a live tier) outside the milestone loop. Runnable apps only.

Across modes: **design → implement → simplify** — design removes
speculative work before it becomes a milestone; execution applies the
simplify ladder after behavior is working, then re-runs every test.

A required `conformance` flow verifies all declared specification rows against
actual behaviour through the project's native runner and authorized CI. Focused
runs remain partial; unspecified legacy behaviour remains visible. See
[`TEST-FLOWS.md`](forge-flow/TEST-FLOWS.md) for the contract and executable examples.
A required `security` flow runs threat-mapped negative tests and applicable
policy checks, preserving missing/failed verification under the security gate.

## Install

`forge-flow/` is the whole skill: one flat folder that follows the common `SKILL.md`
layout. Put a copy where your assistant reads skills.

```bash
git clone https://github.com/GuidanceStudio/forge-flow.git
cp -r forge-flow/forge-flow ~/.claude/skills/forge-flow            # Claude Code
cp -r forge-flow/forge-flow ~/.config/opencode/skills/forge-flow   # opencode
```

For Codex, its skill installer takes the GitHub path directly; pin a tag or a commit
instead of `main`, because a moving branch changes the instructions the assistant follows:

```
$skill-installer install GuidanceStudio/forge-flow/tree/<tag-or-commit>/forge-flow
```

A manual Codex copy goes in `~/.agents/skills/forge-flow`. Keep one active copy per
assistant.

**Update.** Save any local edits, then replace the whole installed folder with the new
one. `diff -r forge-flow/forge-flow <installed folder>` shows whether a copy has drifted
from the source.

**Not provided.** There is no installer script, no remote one-liner and no Gemini or
`AGENTS.md` wrapper; earlier versions had them.

## Usage

Invoke however your assistant invokes skills, then pick a mode:

| Assistant | Invocation |
|---|---|
| Claude Code / Codex / opencode | `/forge-flow design`, `/forge-flow TDD`, `/forge-flow IDD`, `/forge-flow scaffold`, or `/forge-flow` |
| Other assistants | point the assistant's instruction file (for example `AGENTS.md`) at the copied folder's `SKILL.md`, then ask |

`design` creates/updates the plan; `TDD` (recommended) and `IDD`
execute it. You can pass a forge-flow file path directly:

```
/forge-flow TDD devplan/v0.3.md     # TDD on a specific file
/forge-flow devplan/v0.3.md         # path alone defaults to TDD
```

## Provenance

[`docs/SOURCE-PROVENANCE.md`](docs/SOURCE-PROVENANCE.md) records the sources the security
rules were compared against and what each kind of test evidence covers.

## Devplan format

The executor works best with the structured milestone format produced by
`design` mode:

```markdown
## M12: Add retry handling to webhook delivery

**Why:** Failed deliveries currently require manual recovery. The system should
retry transient failures automatically.

**Approach:** Extend the delivery worker to classify retryable failures, persist
attempt state, and expose retry outcomes in the admin view.

**Tasks:**
- [ ] Persist delivery attempt metadata
- [ ] Retry transient failures with bounded backoff
- [ ] Test: integration — delivery succeeds after a transient failure
- [ ] Update docs/webhooks.md if operator behavior changes
- [ ] Commit & push

**Done when:** A transient network failure is retried automatically and the
relevant tests are green.
```

Simpler Markdown plans can still be executed when milestone intent is
unambiguous, but they are not the preferred format for reliable TDD/IDD runs.

A plan lives in one file or two. In the two-file layout the active file carries
the work queue — pending and in-progress milestones — and a companion
`*-COMPLETED.md` carries the closed ones, so a session loads what is left to do
instead of the project's whole history. This plan's own active file went from
131,996 bytes to 5,905 when it split.

Closing a milestone relocates its block verbatim: nothing is dropped, and
compressing it is a separate decision the user makes later (`DESIGN.md`
"Archive"). The layout is optional: a single-file devplan stays valid, and `design` mode
proposes the split once closed milestones outweigh pending ones, never applying
it unasked.

## Inspiration

### Core methodology

- **[Kent Beck](https://en.wikipedia.org/wiki/Kent_Beck)** — TDD (red-green-refactor
  cycle, tests first, business requirement articulation), YAGNI principle.
- **[DietrichGebert/ponytail](https://github.com/DietrichGebert/ponytail)**
  (MIT) — Conceptual prior art for the simplify ladder (`delete:` /
  `stdlib:` / `native:` / `yagni:` / `shrink:`), `ponytail:` structured
  comments for intentional shortcuts, debt register, simplification step
  order, comment-weight scan.
- **[Michael Nygard — Architecture Decision Records](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)** —
  the decision log: a record per choice, and supersede rather than edit, so two
  entries never both read as current.
- **[Jez Humble & Dave Farley — Continuous Delivery](https://continuousdelivery.com/)** —
  shippable milestones, commit-and-push per increment, never-break-main discipline.

### Severity & triage

- **[mastepanoski/nielsen-heuristics-audit](https://github.com/mastepanoski/claude-skills)** —
  0–4 severity rubric and finding triage discipline applied to milestone
  validation.

### Agent-skill patterns

- **[agentskills.io](https://agentskills.io)** / **[Anthropic engineering skills](https://github.com/anthropics/knowledge-work-plugins)** —
  `SKILL.md` standard, cross-assistant portability, progressive disclosure
  (router + playbooks), discovery-before-proposal, never-write-without-approval.

### Project conventions

- **[Conventional Commits](https://www.conventionalcommits.org/)** — commit-message
  convention detection, `MNN: title` prefix pattern.
- **Agile / Scrum** — definition-of-done (Done-when verification), iterative
  delivery, no-preparation-milestones rule.

Runtime dependency: none. forge-flow imports the concepts, not the code.

## Project layout

```
forge-flow/
├── README.md          ← you are here
├── CLAUDE.md          ← contributor rules for this public repo
├── DEVPLAN.md         ← this project's own dev plan (pending work)
├── DEVPLAN-COMPLETED.md ← its closed milestones, moved at close-out
├── DECISIONS.md       ← choices that bind future work, superseded not edited
├── PRINCIPLES.md      ← the trade-offs this repo's plans are checked against
├── THREATS.md         ← the repo's threat model, each threat mapped to a test
├── docs/              ← SOURCE-PROVENANCE.md: the sources the security rules were compared against
├── specs/             ← behaviour rows for the executable examples, with INDEX.tsv
├── tests/             ← run_tests.py and its seven suites: content contract, spec adapter, flow runner, security flow, scaffold, repository security, payload
└── forge-flow/           ← the flat, assistant-neutral skill payload
    ├── SKILL.md       ← router (design / TDD / IDD / scaffold)
    ├── DESIGN.md      ← planning playbook
    ├── TDD.md         ← test-first execution playbook
    ├── IDD.md         ← implementation-first execution playbook
    ├── EXECUTOR-CORE.md ← shared execution behavior (TDD/IDD)
    ├── SCAFFOLD.md    ← operational-spine generation playbook
    ├── README.md      ← skill payload docs, with the full file list
    └── agents/openai.yaml  ← optional Codex metadata
```

`forge-flow/` is the whole skill — copy it anywhere your assistant reads
skills.

## Skill docs

- [Skill payload README](forge-flow/README.md)

## Tests

```bash
python3 -I tests/run_tests.py                # every suite once, then both required flows
python3 -I tests/run_tests.py conformance    # the test mapped to each row in specs/
python3 -I tests/run_tests.py security       # the test mapped to each threat in THREATS.md
```

Each suite also runs alone, for example `python3 -I tests/test_scaffold.py` or
`bash tests/test_content.sh`. The runner reports each flow with its scope and the
requirements that did not pass, and exits non-zero for any non-pass. CI runs
`tests/run_tests.py` on every push and pull request.

## License

MIT

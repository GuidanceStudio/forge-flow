# forge-flow

Unified skill for coding agents that handles the full forge-flow
lifecycle: planning (`design`) and execution (`TDD` / `IDD`).

One skill, three modes plus a `scaffold` route (see `forge-flow/SKILL.md` for full details):
- **`design`** — plan milestones; **`TDD`** (default) — test-first; **`IDD`** — implement-first for exploration.
- **`scaffold`** — mount the operational spine (one-command bring-up + tiered `run_tests.sh` with a live tier) outside the milestone loop. Runnable apps only.

Across modes: **design → implement → simplify** — design removes
speculative work before it becomes a milestone; execution applies the
simplify ladder after behavior is working, then re-runs every test.

## Install

The installer is multi-assistant. Run it with no target for an
interactive menu, or pass `--target`:

```bash
git clone https://github.com/GuidanceStudio/forge-flow.git && cd forge-flow
./install.sh                      # interactive menu
./install.sh --target claude      # ~/.claude/skills/forge-flow/
./install.sh --target opencode    # ~/.config/opencode/skills/forge-flow/
./install.sh --target all         # claude + codex + opencode
```

Remote one-liner:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/GuidanceStudio/forge-flow/main/install.sh) --target claude
```

`claude`, `codex`, and `opencode` get the `forge-flow/` folder copied
verbatim — one payload serves all three. Installing one target leaves the
others on the payload they already had, so the installer names any it finds
holding a different one. Flags: `--force` (overwrite),
`--check` (report `OK`/`DRIFT` vs source). Or skip the installer —
`forge-flow/` is self-contained, copy it anywhere your tool reads skills.

## Usage

Invoke however your assistant invokes skills, then pick a mode:

| Assistant | Invocation |
|---|---|
| Claude Code / Codex / opencode | `/forge-flow design`, `/forge-flow TDD`, `/forge-flow IDD`, `/forge-flow scaffold`, or `/forge-flow` |
| Gemini CLI | `/forge-flow` (installed as a TOML command) |
| Cursor / Windsurf / Copilot / Aider | reference forge-flow from `AGENTS.md`, then ask |

`design` creates/updates the plan; `TDD` (recommended) and `IDD`
execute it. You can pass a forge-flow file path directly:

```
/forge-flow TDD devplan/v0.3.md     # TDD on a specific file
/forge-flow devplan/v0.3.md         # path alone defaults to TDD
```

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

Runtime dependency: none. Forge-flow imports the concepts, not the code.

MIT licensed.

## Project layout

```
forge-flow/
├── README.md          ← you are here
├── install.sh         ← multi-assistant installer
├── CLAUDE.md          ← contributor rules for this public repo
├── DEVPLAN.md         ← this project's own dev plan (pending work)
├── DEVPLAN-COMPLETED.md ← its closed milestones, moved at close-out
├── DECISIONS.md       ← choices that bind future work, superseded not edited
├── tests/             ← test suites (test_install.sh + test_content.sh)
└── forge-flow/           ← the flat, assistant-neutral skill payload
    ├── SKILL.md       ← router (design / TDD / IDD / scaffold)
    ├── DESIGN.md      ← planning playbook
    ├── TDD.md         ← test-first execution playbook
    ├── IDD.md         ← implementation-first execution playbook
    ├── EXECUTOR-CORE.md ← shared execution behavior (TDD/IDD)
    ├── SCAFFOLD.md    ← operational-spine generation playbook
    ├── README.md      ← skill payload docs
    └── agents/openai.yaml  ← optional Codex metadata
```

`forge-flow/` is the whole skill — copy it anywhere your assistant reads
skills, or use `install.sh`.

## Skill docs

- [Skill payload README](forge-flow/README.md)

## Tests

```bash
bash tests/test_install.sh
bash tests/test_content.sh
```

CI (GitHub Actions) runs both suites on every push and PR.

## License

MIT

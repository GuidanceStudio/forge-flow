# devplan

Unified skill for **Claude Code** and **Codex** that handles the full devplan
lifecycle: planning (`design`) and execution (`TDD` / `IDD`).

One skill, three modes:

- **`design`** — create, extend, or refactor a dev plan. Investigates the
  codebase, proposes milestones in chat, writes to file only after approval.
- **`TDD`** (recommended default) — test-first execution. For each milestone:
  state the requirement, write tests, run them red, implement until green,
  simplify, docs, devplan, commit & push.
- **`IDD`** — implementation-first execution. For each milestone: implement,
  write tests covering the finished code, simplify, docs, devplan, commit &
  push. Use for exploratory work.

## Install

One-liner (no clone required):

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kiso-run/devplan/main/install.sh)
```

Requires `git` and `curl`. To install only one variant, append the target:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/kiso-run/devplan/main/install.sh) claude
bash <(curl -fsSL https://raw.githubusercontent.com/kiso-run/devplan/main/install.sh) codex
```

From a local clone:

```bash
./install.sh            # install both variants (default)
./install.sh claude     # Claude Code only
./install.sh codex      # Codex only
./install.sh --force    # overwrite existing install without prompting
```

The installer copies the skill files into the target tool's skill directory:
- Claude Code: `~/.claude/skills/devplan/`
- Codex: `~/.codex/skills/devplan/`

## Usage

| Tool | Command | What it does |
|---|---|---|
| Claude Code | `/devplan design` | Create or update the dev plan |
| Claude Code | `/devplan TDD` | Execute milestones (test-first) |
| Claude Code | `/devplan IDD` | Execute milestones (implementation-first) |
| Claude Code | `/devplan` | Ask which mode to use |
| Codex | `$devplan design` | Create or update the dev plan |
| Codex | `$devplan TDD` | Execute milestones (test-first) |
| Codex | `$devplan IDD` | Execute milestones (implementation-first) |
| Codex | `$devplan` | Ask which mode to use |

You can also pass a devplan file path directly:

```
/devplan TDD devplan/v0.3.md     # TDD on a specific file
/devplan devplan/v0.3.md         # path alone defaults to TDD
```

## Project layout

```
devplan/
├── README.md          ← you are here
├── install.sh         ← installer script
├── DEVPLAN.md         ← this project's own dev plan
├── claude/
│   └── devplan/       ← Claude Code variant (→ ~/.claude/skills/devplan/)
│       ├── SKILL.md   ← router (design / TDD / IDD)
│       ├── DESIGN.md  ← planning playbook
│       ├── TDD.md     ← test-first execution playbook
│       ├── IDD.md     ← implementation-first execution playbook
│       └── README.md  ← variant-specific docs
└── codex/
    └── devplan/       ← Codex variant (→ ~/.codex/skills/devplan/)
        ├── SKILL.md
        ├── DESIGN.md
        ├── TDD.md
        ├── IDD.md
        ├── README.md
        └── agents/
            └── openai.yaml
```

## Per-variant docs

- [Claude Code variant](claude/devplan/README.md)
- [Codex variant](codex/devplan/README.md)

## License

MIT

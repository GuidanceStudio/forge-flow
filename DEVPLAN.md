# devplan — Dev Plan

Unified skill for both **Claude Code** and **Codex** that handles the full devplan lifecycle:
plan creation/maintenance (`design`) and plan execution (`TDD` / `IDD`).

This project replaces the two standalone repos `claude-devplan-executor` and
`codex-devplan-executor` with a single source of truth that ships both variants
plus a shared installer.

## Milestone format

Each milestone uses 4 required sections — **Why**, **Approach**, **Tasks**,
**Done when** — and an optional **Notes** section when something doesn't fit
elsewhere. Every task is a markdown checkbox.

---

## v0.1 — First release

### Phase A — Scaffolding

#### M1: Project skeleton, git init, top-level files ✅

**Why:** A new repo needs a clean foundation before any content lands. Doing the
git init and .gitignore upfront avoids committing junk later and gives every
following milestone a stable place to land.

**Approach:** Create the target-shaped directory tree (`claude/devplan/`,
`codex/devplan/`, `codex/devplan/agents/`). Initialize git. Add a `.gitignore`
that excludes the usual suspects (`.DS_Store`, editor swap files). Add a
placeholder top-level `README.md` (full content lands in M8). No content for
the variants yet — just empty directories ready to receive files.

**Tasks:**
- [x] Create directory tree: `claude/devplan/`, `codex/devplan/`, `codex/devplan/agents/`
- [x] `git init` in `software/skills/devplan/`
- [x] Write `.gitignore` (`.DS_Store`, `*.swp`, `*.swo`, `.idea/`, `.vscode/`)
- [x] Write placeholder `README.md` with title + 1-line description
- [x] Commit (push skipped — no remote, see Notes)

**Done when:** `software/skills/devplan/` exists, is a git repo with one
initial commit, and contains the empty directory tree ready for content.

**Notes:** Executed in IDD mode (TDD fallback) — pure scaffolding has no testable
business contract. `git push` skipped throughout this devplan: the repo is
local-only per the v0.1 out-of-scope (no remote configured).

---

### Phase B — Migrate existing executor into the new structure

#### M2: Migrate Claude variant (TDD.md, IDD.md, README.md)

**Why:** The current Claude executor (`~/.claude/skills/devplan-executor/`) is
already battle-tested. We bring its source files into the new repo unchanged
in behavior, just relocated and renamed for the new package layout. SKILL.md is
intentionally NOT migrated here — it gets rewritten as the new router in M6.

**Approach:** Copy `TDD.md`, `IDD.md`, and `README.md` (source files only, no
`.git`) from `~/.claude/skills/devplan-executor/` into
`claude/devplan/`. Update internal references inside `TDD.md`/`IDD.md` if any
mention the old `devplan-executor` skill name — they should now refer to
`devplan` (with the TDD/IDD mode being one of three router targets). Update
the variant-level `README.md` to reflect the new skill name and the fact that
this is now a sub-document of a unified skill (not a standalone install).

**Tasks:**
- [ ] Copy `TDD.md` → `claude/devplan/TDD.md`
- [ ] Copy `IDD.md` → `claude/devplan/IDD.md`
- [ ] Copy `README.md` → `claude/devplan/README.md`
- [ ] Grep both playbooks for `devplan-executor` references and update to `devplan`
- [ ] Update `claude/devplan/README.md`: skill name, install path, link back to project root
- [ ] Verify no broken internal links remain
- [ ] Commit & push

**Done when:** `claude/devplan/` contains TDD.md, IDD.md, README.md with all
references updated to the new skill name.

---

#### M3: Migrate Codex variant (TDD.md, IDD.md, README.md, agents/openai.yaml)

**Why:** Same rationale as M2 but for the Codex variant, which has the
additional `agents/openai.yaml` file. Keeping the two variants in lockstep is
the whole point of this repo — anything we do to Claude we mirror in Codex.

**Approach:** Mirror M2 for the Codex source. Copy the markdown playbooks plus
the `agents/openai.yaml`. Adapt internal references the same way. The
README for the Codex variant keeps Codex-specific terminology
(`$devplan` invocation, `~/.codex/skills/` path).

**Tasks:**
- [ ] Copy `TDD.md` → `codex/devplan/TDD.md`
- [ ] Copy `IDD.md` → `codex/devplan/IDD.md`
- [ ] Copy `README.md` → `codex/devplan/README.md`
- [ ] Copy `agents/openai.yaml` → `codex/devplan/agents/openai.yaml`
- [ ] Grep both playbooks for `devplan-executor` references and update to `devplan`
- [ ] Update `codex/devplan/README.md`: skill name, install path, link back to project root
- [ ] Verify the openai.yaml `name`/`description` fields match the new skill name
- [ ] Commit & push

**Done when:** `codex/devplan/` contains all 5 files (TDD/IDD/README + agents/openai.yaml)
with all references updated.

---

### Phase C — Build the design playbook

#### M4: Write `DESIGN.md` for the Claude variant

**Why:** The design playbook is the new value this repo brings. It codifies
the user's existing planning workflow (discovery → propose → iterate → write
→ validate) so any session that invokes `/devplan design` follows the same
top-PM approach without needing to be re-explained. Without DESIGN.md the
router has nothing to route to.

**Approach:** Write a single self-contained playbook for Claude Code. Structure
follows the 5 phases agreed in chat:

1. **Discovery** — read CLAUDE.md (root + global), README, docs/, find existing
   devplan files, run `git log -20`, detect stack, identify likely-touched
   files via Grep/Glob. Output a 10-15 line Discovery Brief in chat.
2. **Clarification** — only if real ambiguities exist, ask a max-5 numbered
   list with concrete A/B/C options and a recommended pick. Skip entirely if
   request is clear.
3. **Plan proposal in chat** — emit Obiettivo / Approccio / Rischi / Fasi
   (with milestones grouped) / Out of scope. Wait for explicit approval words
   ("ok", "vai", "scrivi", "procedi"). Never write to file in this phase.
4. **Write to file** — append to current devplan version file (never close or
   create versions without explicit ask). Use the milestone format: **Why /
   Approach / Tasks / Done when** (required) + optional **Notes**. Continue
   numbering from last existing `MNN`. No preparation milestones, no time
   estimates, no code in tasks. Each milestone shippable on its own.
5. **Validation** — re-read the file and self-check: every milestone has the
   4 required sections, every task is actionable, dependencies are ordered,
   numbering is continuous, the plan covers the original request. Auto-correct
   on failure, no confirmation needed.

Plus three implicit modes (`new` / `extend` (default) / `refactor`) detected
from context, and a hard guardrail block (don't touch code, don't modify
`- [x]` milestones, don't estimate time, don't invent requirements, don't
create new versions without ask, but **at ~50 milestones suggest in chat**
that the user may want to close the version — final decision is theirs).

**Tasks:**
- [ ] Write `claude/devplan/DESIGN.md` with frontmatter (`name`, `description`)
- [ ] Section: Discovery (with explicit list of artifacts to read in parallel)
- [ ] Section: Clarification (with the "max 5, concrete options, recommend pick" rules)
- [ ] Section: Plan proposal (with the exact chat template: Obiettivo/Approccio/Rischi/Fasi/Out of scope)
- [ ] Section: Write rules (numbering continuity, append-only on version files, milestone format, no prep milestones)
- [ ] Section: Validation (the self-check list)
- [ ] Section: Modes (new / extend / refactor)
- [ ] Section: Guardrails (the "never" list + the 50-milestone soft suggestion)
- [ ] Section: Sinergia with TDD/IDD (shared milestone format = no translation needed)
- [ ] Commit & push

**Done when:** `claude/devplan/DESIGN.md` is a complete, self-contained
playbook that a fresh Claude session could follow end-to-end without any
additional context, and any milestone it produces is directly executable by
`claude/devplan/TDD.md` or `IDD.md` without translation.

---

#### M5: Write `DESIGN.md` for the Codex variant

**Why:** Mirror M4 for Codex so both tools have feature parity. Codex users
deserve the same planning quality as Claude users.

**Approach:** Port `claude/devplan/DESIGN.md` to `codex/devplan/DESIGN.md`,
adapting only Codex-specific details: invocation syntax (`$devplan design`
instead of `/devplan design`), tool names (Codex's file/search tools instead
of Claude's Read/Grep/Glob), any frontmatter keys that differ between the two
skill systems. Content and structure stay identical. Update
`agents/openai.yaml` if it needs to register the new playbook entry.

**Tasks:**
- [ ] Copy `claude/devplan/DESIGN.md` → `codex/devplan/DESIGN.md` as starting point
- [ ] Replace Claude-specific invocation syntax with Codex equivalents
- [ ] Replace Claude tool names with Codex tool equivalents
- [ ] Update Codex-specific frontmatter if applicable
- [ ] Update `codex/devplan/agents/openai.yaml` if it needs a DESIGN entry
- [ ] Diff the two DESIGN.md files and confirm only intentional differences exist
- [ ] Commit & push

**Done when:** `codex/devplan/DESIGN.md` exists with structural and behavioral
parity with the Claude version, only differing where Codex-specific syntax
requires it.

---

### Phase D — Wire the router

#### M6: Rewrite `SKILL.md` as the design/TDD/IDD router (both variants)

**Why:** This is the single entry point users invoke. Until M6 the new
playbooks exist but nothing routes to them. After M6 the skill is functionally
complete: `/devplan` works.

**Approach:** Write a short (~30-40 line) router for each variant. The router
parses the first argument:

- no arg → ask in chat: *"Vuoi `design` (creare/aggiornare il piano) o
  eseguire (`TDD` raccomandato, o `IDD` per esplorativo)?"*. Recommend TDD as
  default execution mode.
- `design` → load DESIGN.md, forward remaining args
- `TDD` → load TDD.md, forward remaining args
- `IDD` → load IDD.md, forward remaining args
- first arg looks like a path (contains `.md` or `/`) → load TDD.md (default)
  pointing at that file
- unknown arg → ask for clarification, do not assume

The router itself never executes work; it just selects and hands off. Each
playbook stays self-contained.

**Tasks:**
- [ ] Write `claude/devplan/SKILL.md` router with frontmatter and the 5-branch logic
- [ ] Write `codex/devplan/SKILL.md` router (same logic, Codex syntax)
- [ ] Verify both routers explicitly recommend TDD as default execution mode
- [ ] Verify both routers load only one playbook per invocation (no eager loading)
- [ ] Update `codex/devplan/agents/openai.yaml` to point to the new SKILL.md if needed
- [ ] Manual smoke test: invoke each branch mentally against the router text
- [ ] Commit & push

**Done when:** Both `SKILL.md` files dispatch correctly to design/TDD/IDD,
recommend TDD by default, and load only the playbook needed for the chosen
branch.

---

### Phase E — Distribution

#### M7: Write `install.sh`

**Why:** Without an installer the only way to use the skill is manual copy.
The installer is the user-facing distribution surface and must work for
both variants from a single command.

**Approach:** A POSIX `bash` script at the repo root. Flags:

- `./install.sh claude` → copy `claude/devplan/` → `~/.claude/skills/devplan/`
- `./install.sh codex` → copy `codex/devplan/` → `~/.codex/skills/devplan/`
- `./install.sh all` (default if no arg) → install both
- `--force` → overwrite existing target without prompting
- without `--force`, if target exists, prompt y/N before overwriting

Copy is `cp -r` from local files only, never `git clone`. Script must:
verify source dirs exist before copying, create parent dirs as needed,
print a clear success message with the install path, exit non-zero on any
failure.

**Tasks:**
- [ ] Write `install.sh` with the 3 flag modes + `--force`
- [ ] Add `set -euo pipefail` and proper error handling
- [ ] Add prompt-before-overwrite logic
- [ ] Add success/failure messages with absolute paths
- [ ] `chmod +x install.sh`
- [ ] Manual dry-run test (run with a fake `HOME` to verify it copies into the right place)
- [ ] Commit & push

**Done when:** Running `./install.sh all` from a clean checkout installs both
variants into `~/.claude/skills/devplan/` and `~/.codex/skills/devplan/` with
correct files and a clear success message.

---

#### M8: Write project-level `README.md`

**Why:** The placeholder from M1 is not enough. The repo needs a real README
that explains what `devplan` is, the three modes, how to install, and links
to the per-variant docs. This is the first thing anyone (including future-you)
sees when they land on the repo.

**Approach:** A single markdown file at repo root. Sections:

- **What is devplan** — 3-4 lines, agnostic of Claude vs Codex
- **Three modes** — `design` / `TDD` / `IDD` with one-line each
- **Install** — `./install.sh all` (and the flag variants)
- **Usage** — `/devplan design`, `/devplan TDD`, `/devplan IDD`, with the
  default-when-no-arg behavior
- **Project layout** — short tree showing `claude/devplan/`, `codex/devplan/`
- **Per-variant docs** — links to `claude/devplan/README.md` and
  `codex/devplan/README.md`
- **License** — MIT (matching the existing executors)

No emoji. No marketing fluff.

**Tasks:**
- [ ] Write `README.md` replacing the M1 placeholder
- [ ] Include all sections listed above
- [ ] Verify all internal links resolve to real files in the repo
- [ ] Commit & push

**Done when:** Repo root `README.md` is the canonical entry point and
correctly describes the project, modes, install, usage, and layout.

---

#### M9: Smoke test & v0.1 tag

**Why:** Before declaring v0.1 done, verify the whole thing actually installs
and routes correctly end-to-end. Tagging v0.1 marks a stable reference point
to install from.

**Approach:** Run `install.sh` against a temp `HOME` (or accept overwriting
the existing `~/.claude/skills/devplan/` after backing it up), then mentally
walk through `/devplan`, `/devplan design`, `/devplan TDD`, `/devplan IDD`
to confirm each branch loads the right file. Fix anything broken. Tag the
final commit as `v0.1`.

**Tasks:**
- [ ] Backup existing `~/.claude/skills/devplan-executor/` and `~/.codex/skills/devplan-executor/` if present
- [ ] Run `./install.sh all` from the new repo
- [ ] Verify all files landed in the right paths with correct contents
- [ ] Mentally smoke-test each router branch
- [ ] Fix any issue found (each fix gets its own micro-commit)
- [ ] Tag `v0.1`
- [ ] Commit & push (with tag)

**Done when:** A fresh install from this repo produces a working `/devplan`
skill in both Claude Code and Codex, all router branches dispatch correctly,
and the repo has a `v0.1` tag.

---

## Out of scope for v0.1

- Publishing to a public GitHub repo (local-only for now)
- CI / automated tests for the installer
- A `devplan uninstall` command
- Support for skill systems other than Claude Code and Codex
- Auto-update mechanism
- Telemetry of any kind

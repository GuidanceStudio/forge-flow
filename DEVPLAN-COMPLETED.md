# forge-flow — Completed Milestones

Closed milestones, moved verbatim from `DEVPLAN.md` at close-out
(`DESIGN.md` "Two files: active and completed"). Nothing here is compressed.

---

## v0.1 — First release

### Phase A — Scaffolding

#### M1: Project skeleton, git init, top-level files ✅

**Why:** A new repo needs a clean foundation before any content lands. Doing the
git init and .gitignore upfront avoids committing junk later and gives every
following milestone a stable place to land.

**Approach:** Create the target-shaped directory tree (`claude/forge-flow/`,
`codex/forge-flow/`, `codex/forge-flow/agents/`). Initialize git. Add a `.gitignore`
that excludes the usual suspects (`.DS_Store`, editor swap files). Add a
placeholder top-level `README.md` (full content lands in M8). No content for
the variants yet — just empty directories ready to receive files.

**Tasks:**
- [x] Create directory tree: `claude/forge-flow/`, `codex/forge-flow/`, `codex/forge-flow/agents/`
- [x] `git init` in `software/skills/forge-flow/`
- [x] Write `.gitignore` (`.DS_Store`, `*.swp`, `*.swo`, `.idea/`, `.vscode/`)
- [x] Write placeholder `README.md` with title + 1-line description
- [x] Commit (push skipped — no remote, see Notes)

**Done when:** `software/skills/forge-flow/` exists, is a git repo with one
initial commit, and contains the empty directory tree ready for content.

**Notes:** Executed in IDD mode (TDD fallback) — pure scaffolding has no testable
business contract. `git push` skipped throughout this forge-flow: the repo is
local-only per the v0.1 out-of-scope (no remote configured).

---

### Phase B — Migrate existing executor into the new structure

#### M2: Migrate Claude variant (TDD.md, IDD.md, README.md) ✅

**Why:** The current Claude executor (`~/.claude/skills/forge-flow-executor/`) is
already battle-tested. We bring its source files into the new repo unchanged
in behavior, just relocated and renamed for the new package layout. SKILL.md is
intentionally NOT migrated here — it gets rewritten as the new router in M6.

**Approach:** Copy `TDD.md`, `IDD.md`, and `README.md` (source files only, no
`.git`) from `~/.claude/skills/forge-flow-executor/` into
`claude/forge-flow/`. Update internal references inside `TDD.md`/`IDD.md` if any
mention the old `forge-flow-executor` skill name — they should now refer to
`forge-flow` (with the TDD/IDD mode being one of three router targets). Update
the variant-level `README.md` to reflect the new skill name and the fact that
this is now a sub-document of a unified skill (not a standalone install).

**Tasks:**
- [x] Copy `TDD.md` → `claude/forge-flow/TDD.md`
- [x] Copy `IDD.md` → `claude/forge-flow/IDD.md`
- [x] Copy `README.md` → `claude/forge-flow/README.md`
- [x] Grep both playbooks for `forge-flow-executor` references and update to `forge-flow` (none found — clean)
- [x] Update `claude/forge-flow/README.md`: skill name, install path, link back to project root
- [x] Verify no broken internal links remain
- [x] Commit (push skipped — no remote)

**Done when:** `claude/forge-flow/` contains TDD.md, IDD.md, README.md with all
references updated to the new skill name.

**Notes:** Executed in IDD mode (TDD fallback). TDD.md and IDD.md had zero
references to `forge-flow-executor` — they were already self-contained. README.md
was fully rewritten to reflect the new 3-mode routing and unified install.

---

#### M3: Migrate Codex variant (TDD.md, IDD.md, README.md, agents/openai.yaml) ✅

**Why:** Same rationale as M2 but for the Codex variant, which has the
additional `agents/openai.yaml` file. Keeping the two variants in lockstep is
the whole point of this repo — anything we do to Claude we mirror in Codex.

**Approach:** Mirror M2 for the Codex source. Copy the markdown playbooks plus
the `agents/openai.yaml`. Adapt internal references the same way. The
README for the Codex variant keeps Codex-specific terminology
(`$forge-flow` invocation, `~/.codex/skills/` path).

**Tasks:**
- [x] Copy `TDD.md` → `codex/forge-flow/TDD.md`
- [x] Copy `IDD.md` → `codex/forge-flow/IDD.md`
- [x] Copy `README.md` → `codex/forge-flow/README.md`
- [x] Copy `agents/openai.yaml` → `codex/forge-flow/agents/openai.yaml`
- [x] Grep both playbooks for `forge-flow-executor` references and update to `forge-flow` (none found — clean)
- [x] Update `codex/forge-flow/README.md`: skill name, install path, link back to project root
- [x] Verify the openai.yaml `name`/`description` fields match the new skill name
- [x] Commit (push skipped — no remote)

**Done when:** `codex/forge-flow/` contains all 5 files (TDD/IDD/README + agents/openai.yaml)
with all references updated.

**Notes:** Executed in IDD mode (TDD fallback). Same as M2: playbooks had zero
old-name references. Updated `openai.yaml` display_name to "Devplan" and
description/prompt to reflect the 3-mode routing.

---

### Phase C — Build the design playbook

#### M4: Write `DESIGN.md` for the Claude variant ✅

**Why:** The design playbook is the new value this repo brings. It codifies
the user's existing planning workflow (discovery → propose → iterate → write
→ validate) so any session that invokes `/forge-flow design` follows the same
top-PM approach without needing to be re-explained. Without DESIGN.md the
router has nothing to route to.

**Approach:** Write a single self-contained playbook for Claude Code. Structure
follows the 5 phases agreed in chat:

1. **Discovery** — read CLAUDE.md (root + global), README, docs/, find existing
   forge-flow files, run `git log -20`, detect stack, identify likely-touched
   files via Grep/Glob. Output a 10-15 line Discovery Brief in chat.
2. **Clarification** — only if real ambiguities exist, ask a max-5 numbered
   list with concrete A/B/C options and a recommended pick. Skip entirely if
   request is clear.
3. **Plan proposal in chat** — emit Obiettivo / Approccio / Rischi / Fasi
   (with milestones grouped) / Out of scope. Wait for explicit approval words
   ("ok", "vai", "scrivi", "procedi"). Never write to file in this phase.
4. **Write to file** — append to current forge-flow version file (never close or
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
- [x] Write `claude/forge-flow/DESIGN.md` with frontmatter (`name`, `description`)
- [x] Section: Discovery (with explicit list of artifacts to read in parallel)
- [x] Section: Clarification (with the "max 5, concrete options, recommend pick" rules)
- [x] Section: Plan proposal (with the exact chat template: Obiettivo/Approccio/Rischi/Fasi/Out of scope)
- [x] Section: Write rules (numbering continuity, append-only on version files, milestone format, no prep milestones)
- [x] Section: Validation (the self-check list)
- [x] Section: Modes (new / extend / refactor)
- [x] Section: Guardrails (the "never" list + the 50-milestone soft suggestion)
- [x] Section: Sinergia with TDD/IDD (shared milestone format = no translation needed)
- [x] Commit (push skipped — no remote)

**Done when:** `claude/forge-flow/DESIGN.md` is a complete, self-contained
playbook that a fresh Claude session could follow end-to-end without any
additional context, and any milestone it produces is directly executable by
`claude/forge-flow/TDD.md` or `IDD.md` without translation.

**Notes:** Executed in IDD mode (TDD fallback) — content authoring, no testable
code. The playbook is ~200 lines, fully self-contained. Dropped frontmatter
(`name`/`description`) as the Claude skill system uses `SKILL.md` for metadata,
not per-file frontmatter — SKILL.md router handles identification.

---

#### M5: Write `DESIGN.md` for the Codex variant ✅

**Why:** Mirror M4 for Codex so both tools have feature parity. Codex users
deserve the same planning quality as Claude users.

**Approach:** Port `claude/forge-flow/DESIGN.md` to `codex/forge-flow/DESIGN.md`,
adapting only Codex-specific details: invocation syntax (`$forge-flow design`
instead of `/forge-flow design`), tool names (Codex's file/search tools instead
of Claude's Read/Grep/Glob), any frontmatter keys that differ between the two
skill systems. Content and structure stay identical. Update
`agents/openai.yaml` if it needs to register the new playbook entry.

**Tasks:**
- [x] Copy `claude/forge-flow/DESIGN.md` → `codex/forge-flow/DESIGN.md` as starting point
- [x] Replace Claude-specific invocation syntax with Codex equivalents
- [x] Replace Claude tool names with Codex tool equivalents
- [x] Update Codex-specific frontmatter if applicable (N/A — no frontmatter used)
- [x] Update `codex/forge-flow/agents/openai.yaml` if it needs a DESIGN entry (already updated in M3)
- [x] Diff the two DESIGN.md files and confirm only intentional differences exist
- [x] Commit (push skipped — no remote)

**Done when:** `codex/forge-flow/DESIGN.md` exists with structural and behavioral
parity with the Claude version, only differing where Codex-specific syntax
requires it.

**Notes:** Executed in IDD mode (TDD fallback). Diff shows 7 change blocks, all
intentional: heading style, section naming to match Codex TDD.md conventions,
project docs discovery adapted for Codex instructions format, tool-agnostic
wording for file search, guardrail formatting.

---

### Phase D — Wire the router

#### M6: Rewrite `SKILL.md` as the design/TDD/IDD router (both variants) ✅

**Why:** This is the single entry point users invoke. Until M6 the new
playbooks exist but nothing routes to them. After M6 the skill is functionally
complete: `/forge-flow` works.

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
- [x] Write `claude/forge-flow/SKILL.md` router with frontmatter and the 5-branch logic
- [x] Write `codex/forge-flow/SKILL.md` router (same logic, Codex syntax)
- [x] Verify both routers explicitly recommend TDD as default execution mode
- [x] Verify both routers load only one playbook per invocation (no eager loading)
- [x] Update `codex/forge-flow/agents/openai.yaml` to point to the new SKILL.md if needed (already done in M3)
- [x] Manual smoke test: invoke each branch mentally against the router text
- [x] Commit (push skipped — no remote)

**Done when:** Both `SKILL.md` files dispatch correctly to design/TDD/IDD,
recommend TDD by default, and load only the playbook needed for the chosen
branch.

---

### Phase E — Distribution

#### M7: Write `install.sh` ✅

**Why:** Without an installer the only way to use the skill is manual copy.
The installer is the user-facing distribution surface and must work for
both variants from a single command.

**Approach:** A POSIX `bash` script at the repo root. Flags:

- `./install.sh claude` → copy `claude/forge-flow/` → `~/.claude/skills/forge-flow/`
- `./install.sh codex` → copy `codex/forge-flow/` → `~/.codex/skills/forge-flow/`
- `./install.sh all` (default if no arg) → install both
- `--force` → overwrite existing target without prompting
- without `--force`, if target exists, prompt y/N before overwriting

Copy is `cp -r` from local files only, never `git clone`. Script must:
verify source dirs exist before copying, create parent dirs as needed,
print a clear success message with the install path, exit non-zero on any
failure.

**Tasks:**
- [x] Write `install.sh` with the 3 flag modes + `--force`
- [x] Add `set -euo pipefail` and proper error handling
- [x] Add prompt-before-overwrite logic
- [x] Add success/failure messages with absolute paths
- [x] `chmod +x install.sh`
- [x] Manual dry-run test (run with a fake `HOME` to verify it copies into the right place)
- [x] Commit (push skipped — no remote)

**Done when:** Running `./install.sh all` from a clean checkout installs both
variants into `~/.claude/skills/forge-flow/` and `~/.codex/skills/forge-flow/` with
correct files and a clear success message.

---

#### M8: Write project-level `README.md` ✅

**Why:** The placeholder from M1 is not enough. The repo needs a real README
that explains what `forge-flow` is, the three modes, how to install, and links
to the per-variant docs. This is the first thing anyone (including future-you)
sees when they land on the repo.

**Approach:** A single markdown file at repo root. Sections:

- **What is forge-flow** — 3-4 lines, agnostic of Claude vs Codex
- **Three modes** — `design` / `TDD` / `IDD` with one-line each
- **Install** — `./install.sh all` (and the flag variants)
- **Usage** — `/forge-flow design`, `/forge-flow TDD`, `/forge-flow IDD`, with the
  default-when-no-arg behavior
- **Project layout** — short tree showing `claude/forge-flow/`, `codex/forge-flow/`
- **Per-variant docs** — links to `claude/forge-flow/README.md` and
  `codex/forge-flow/README.md`
- **License** — MIT (matching the existing executors)

No emoji. No marketing fluff.

**Tasks:**
- [x] Write `README.md` replacing the M1 placeholder
- [x] Include all sections listed above
- [x] Verify all internal links resolve to real files in the repo (13/13 OK)
- [x] Commit (push skipped — no remote)

**Done when:** Repo root `README.md` is the canonical entry point and
correctly describes the project, modes, install, usage, and layout.

---

#### M9: Smoke test & v0.1 tag ✅

**Why:** Before declaring v0.1 done, verify the whole thing actually installs
and routes correctly end-to-end. Tagging v0.1 marks a stable reference point
to install from.

**Approach:** Run `install.sh` against a temp `HOME` (or accept overwriting
the existing `~/.claude/skills/forge-flow/` after backing it up), then mentally
walk through `/forge-flow`, `/forge-flow design`, `/forge-flow TDD`, `/forge-flow IDD`
to confirm each branch loads the right file. Fix anything broken. Tag the
final commit as `v0.1`.

**Tasks:**
- [x] Backup existing `~/.claude/skills/forge-flow-executor/` and `~/.codex/skills/forge-flow-executor/` if present (skipped — install goes to new `forge-flow/` path, old `forge-flow-executor/` is untouched)
- [x] Run `./install.sh all` from the new repo (dry-run with fake HOME)
- [x] Verify all files landed in the right paths with correct contents (Claude: 5 files, Codex: 5 + agents/openai.yaml)
- [x] Mentally smoke-test each router branch (7/7 branches verified)
- [x] Fix any issue found (none found)
- [x] Tag `v0.1`
- [x] Commit (push skipped — no remote)

**Done when:** A fresh install from this repo produces a working `/forge-flow`
skill in both Claude Code and Codex, all router branches dispatch correctly,
and the repo has a `v0.1` tag.

---

### Phase F — Refinement

#### M10: Refine DESIGN.md — adaptive discovery, scalable proposal, pending check, precise clarification, codebase-aware validation ✅

**Why:** The v0.1 DESIGN.md works but has 5 weaknesses identified during
review: discovery runs 6 mandatory steps regardless of request size, the
proposal template is heavy for small tasks, extend mode silently ignores
pending milestones, clarification triggers are vague, and validation only
checks form (not substance). Fixing these makes the playbook proportional
to the work and catches real planning errors.

**Approach:** Edit both `claude/forge-flow/DESIGN.md` and `codex/forge-flow/DESIGN.md`
in-place. All 5 fixes modify existing sections — no new sections added, the
playbook stays at 5 phases. Changes:

1. **Phase 1 (Discovery):** Add a scale assessment step at the top (small /
   medium / large based on expected milestone count). The 6 discovery sources
   become a catalog — the skill picks only those relevant to the scale. The
   Discovery Brief shrinks proportionally (3-4 lines for small, 10-15 for
   large).

2. **Phase 2 (Clarification):** Replace "real ambiguities" with a concrete
   criterion: ask only when the answer changes the **structure** of the plan
   (number of milestones, modules involved, architectural approach). If it
   only changes an implementation detail, don't ask — the executor decides.

3. **Phase 3 (Proposal):** Add a lightweight template for 1-2 milestone plans
   (just `MNN: title — rationale`, no Obiettivo/Approccio/Rischi/Out of scope
   wrapper). Keep the full template for 3+ milestones.

4. **Phase 4 (Write):** In extend mode, before proposing, count pending
   `- [ ]` milestones. If any exist, report them in chat and ask whether the
   new milestones depend on the pending ones or are independent. Don't block —
   inform and let the user decide.

5. **Phase 5 (Validation):** Add 3 substance checks after the existing form
   checks: (a) files cited in Approach/Tasks exist in the repo or are created
   by a prior milestone, (b) milestones touching the same module are ordered
   sensibly, (c) plan respects project conventions from CLAUDE.md / project
   instructions. If a check fails: auto-correct if possible, otherwise add a
   Notes warning to the milestone.

**Tasks:**
- [x] Update Phase 1 in `claude/forge-flow/DESIGN.md`: add scale assessment, make sources a catalog not a checklist, scale the Discovery Brief
- [x] Update Phase 2 in `claude/forge-flow/DESIGN.md`: replace "real ambiguities" with the structural-impact criterion
- [x] Update Phase 3 in `claude/forge-flow/DESIGN.md`: add lightweight template for 1-2 milestone plans
- [x] Update Phase 4 in `claude/forge-flow/DESIGN.md`: add pending milestone check in extend mode
- [x] Update Phase 5 in `claude/forge-flow/DESIGN.md`: add 3 codebase-coherence checks
- [x] Port all 5 changes to `codex/forge-flow/DESIGN.md`
- [x] Diff both DESIGN.md files and confirm only intentional differences exist (same 7 blocks as before, all intentional)
- [x] Commit (push skipped — no remote)

**Done when:** Both DESIGN.md playbooks scale discovery and proposal to the
request size, warn about pending milestones before extending, ask clarification
only for structure-changing ambiguities, and validate plan coherence against
the actual codebase — not just format.

---

#### M11: Remote install — one-liner `bash <(curl ...)` without cloning ✅

**Why:** The current `install.sh` only works from a local clone. Users
discovering the skill on GitHub should be able to install with a single
command — `bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/forge-flow/main/install.sh)` —
without cloning the repo first. This is the standard distribution pattern
for CLI tools and skills.

**Approach:** Rewrite `install.sh` to auto-detect its execution context:

1. **Local mode** (current behavior) — if the script detects that the
   source directories (`claude/forge-flow/`, `codex/forge-flow/`) exist relative
   to `SCRIPT_DIR`, it uses them directly via `cp -r`. Nothing changes for
   users who already clone.

2. **Remote mode** (new) — if the source directories are not found (i.e.
   the script was piped from curl or run from a temp location), the script:
   - creates a temp dir (`mktemp -d`)
   - `git clone --depth 1` the repo into it (requires git)
   - runs the install logic using the cloned files as source
   - cleans up the temp dir on exit (trap)

Detection: check `[ -d "$SCRIPT_DIR/claude/forge-flow" ]`. If yes → local
mode. If no → remote mode.

The repo URL should be a variable at the top of the script (`REPO_URL`)
so it's easy to change. Default: `https://github.com/OWNER/forge-flow.git`
(placeholder until the repo is published).

All existing flags (`claude`, `codex`, `all`, `--force`, `--help`) work
identically in both modes. The user-facing one-liner to document in the
README:

```
bash <(curl -fsSL https://raw.githubusercontent.com/OWNER/forge-flow/main/install.sh)
```

**Tasks:**
- [x] Refactor `install.sh`: extract source-detection logic at the top
- [x] Add remote mode: temp dir, `git clone --depth 1`, trap cleanup
- [x] Keep local mode unchanged (backwards compatible)
- [x] Test local mode still works (run from repo root)
- [x] Test remote mode (copy `install.sh` to `/tmp`, run from there)
- [x] Update `README.md`: add one-liner install section before the local install section
- [x] Update `README.md`: note that remote install requires `git` and `curl`
- [x] Commit

**Done when:** `bash <(curl -fsSL .../install.sh)` from a machine with
`git` and `curl` installs the skill without a prior clone, and
`./install.sh` from within the repo still works as before.

**Notes:** Executed in TDD mode. `DEVPLAN_REPO_URL` env var added for
testability — tests point it at the local repo to avoid network dependency.
`DEVPLAN_REPO_URL` defaults to this repo's own GitHub home — update if it moves.
Test suite: 21 tests (14 local, 7 remote), all green.

---

## Out of scope for v0.1

- Publishing to a public GitHub repo (local-only for now)
- CI / automated tests for the installer
- A `forge-flow uninstall` command
- Support for skill systems other than Claude Code and Codex
- Auto-update mechanism
- Telemetry of any kind

---

## v0.2 — Variant convergence + executor hardening

**Obiettivo:** the 2026-06-10 self-audit found the repo's core promise
(claude/codex lockstep) already broken — the Codex playbooks were
improved (executability validation, implementation standards, git
behavior with completion criteria, better path routing) without
backporting to Claude — plus real defects in the executors (`git add
-A` swallows unrelated work, the "Done when" contract is declared in
DESIGN.md but never verified, commit convention hardcoded, no resume
protocol) and Italian hardcoded in a published skill.

**Approccio:** instead of templating/build machinery, make the four
behavior files (`SKILL.md`, `DESIGN.md`, `TDD.md`, `IDD.md`)
**variant-neutral and byte-identical** across `claude/` and `codex/`
(variant differences are small enough to phrase inline: "CLAUDE.md for
Claude Code, AGENTS.md for Codex"), then enforce identity with a test.
This kills the drift bug class with zero build complexity. READMEs and
`agents/openai.yaml` stay per-variant. Content fixes land on the
unified files once.

**Rischi:** merging the two playbook generations could lose a nuance
one variant had — mitigated by diffing both sources section by section
during the merge. Inline dual-variant phrasing adds a few lines per
file — accepted, it's cheaper than a build step.

### Phase G — Convergence

#### M12: Reconcile variant drift — variant-neutral canonical playbooks ✅

**Why:** The Codex variant evolved past the Claude one (the one
actually used daily); the improvements are objectively better and the
split is the defect. One canonical text per playbook restores parity
and becomes the base every later fix lands on once.

**Approach:** For each of SKILL.md, DESIGN.md, TDD.md, IDD.md: take
the richer variant as base, merge what the other had that it lacks,
neutralize variant-specific wording inline (instruction-file names,
`/simplify` if available, tool-agnostic search wording). Codex's
superior content adopted: path-token detection + ambiguity rule and
fallback clause (SKILL), milestone executability validation with
structure inference for simple plans, implementation standards, git
behavior incl. push-blocker recording and "never discard unrelated
user changes" (replaces `git add -A`), resumable-forge-flow standard,
completion report with tests-not-run + residual risks (TDD/IDD).
Claude's kept: pre-approved autonomy block, red-check exemption,
`/simplify` step, recap template, IDD-fallback detail. Write once into
`claude/forge-flow/`, copy to `codex/forge-flow/`.

**Tasks:**
- [x] Merge + neutralize `SKILL.md` (claude base + codex routing improvements)
- [x] Merge + neutralize `TDD.md` (codex structure + claude specifics)
- [x] Merge + neutralize `IDD.md` (same approach)
- [x] Neutralize `DESIGN.md` (claude base is canonical post-M10; inline both instruction-file conventions, tool-agnostic wording)
- [x] Copy the four files to `codex/forge-flow/`, verify byte-identical
- [x] Check both variant READMEs + root README for statements the merge contradicts; fix (claude README `/simplify` line made conditional; codex README + root README already neutral)
- [x] Commit & push

**Notes:** Executed in IDD mode (content authoring — the testable
contract lands in M13's lockstep test). Merged TDD/IDD keep the
numbered-step structure with shared `Test policy` / `Implementation
standards` sections from the Codex lineage; `git add -A` replaced by
"stage the milestone's changes" + "never rewrite or discard unrelated
user changes" (M14 adds the preflight).

**Done when:** `diff claude/forge-flow/{SKILL,DESIGN,TDD,IDD}.md codex/forge-flow/` is empty and each merged file contains the named improvements from both lineages.

#### M13: Lockstep guard — identity test + install drift check ✅

**Why:** M12 restores parity; without a mechanical guard it re-breaks
on the next edit, exactly like it did in v0.1.

**Approach:** Extend the existing bash test suite with a lockstep
check (the four behavior files byte-identical across variants) wired
into `tests/test_install.sh` style. Add `install.sh --check`: compare
the installed copies under `~/.claude/skills/forge-flow/` and
`~/.codex/skills/forge-flow/` against the source tree and report drift
without modifying anything; cover it with tests (fresh install →
clean; hand-edited installed file → drift reported, non-zero exit).

**Tasks:**
- [x] Test: lockstep identity of the four behavior files (`tests/test_lockstep.sh`)
- [x] Implement `install.sh --check` (no-write, reports per-variant drift, exit 1 on drift)
- [x] Tests: `--check` clean after install; `--check` detects a modified installed file; `--check` on missing install (T9-T11)
- [x] Document `--check` + tests/ dir in root README
- [x] Commit & push

**Notes:** Executed in TDD mode — T9-T11 written first and confirmed
red ("Unknown argument: --check"), then `--check` implemented to green
(24/24 + lockstep 4/4). Lockstep red-path verified manually by editing
one variant file and watching the test fail.

**Done when:** test suite green including the new cases; editing one variant file by hand makes the lockstep test fail; `install.sh --check` distinguishes clean from drifted installs.

### Phase H — Hardening

#### M14: Executor hardening — preflight, selective staging, Done-when, conventions, resume ✅

**Why:** The executors run fully autonomous with commit+push authority;
today they can swallow unrelated user work (`git add -A` legacy —
removed in M12 but with no preflight replacing the safety), close
milestones without checking the declared exit condition, and produce
commits that ignore the repo's conventions. Autonomy needs guardrails
proportional to its blast radius.

**Approach:** Edit the unified TDD.md/IDD.md (and DESIGN.md where
noted), then sync to codex/. Five behaviors: (1) preflight at
execution start — if the worktree has uncommitted changes unrelated to
the forge-flow, stop and ask once before touching anything; (2) stage
only files touched by the milestone, never blanket-add; (3) before
marking a milestone done, verify its **Done when** condition
explicitly and record the verification in the forge-flow note; (4) read
the repo's commit-message convention from `git log` and match it
(default `MNN: title` when none), including trailers the repo uses;
(5) resume protocol — on start, if a milestone is half-executed
(mid-milestone `[x]` tasks or leftover changes), reconcile state
before continuing; plus the plan-drift rule (a false assumption
discovered mid-run updates the pending plan with a note, never
silently drifts). In DESIGN.md: numbering follows the file's existing
ID scheme (`MNN` is the default for new files, not a mandate over
existing conventions like `D5-4`).

**Tasks:**
- [x] TDD.md + IDD.md: preflight worktree check + resume protocol section
- [x] TDD.md + IDD.md: selective staging rule
- [x] TDD.md + IDD.md: Done-when verification step before marking done (new dedicated loop step + Rules entries)
- [x] TDD.md + IDD.md: commit-convention detection rule (in preflight + commit step)
- [x] TDD.md + IDD.md: plan-drift rule — kept as bullet inside "Update the forge-flow" (a dedicated numbered step added no value), strengthened with "never rewrite completed milestones"
- [x] DESIGN.md: ID-scheme flexibility in the numbering rules
- [x] Sync to codex/, lockstep test green
- [x] Commit & push

**Notes:** Executed in IDD mode (playbook content; the sync contract is
covered by M13's lockstep test, green: 4/4 + 24/24). "Done when"
verified by re-reading both executors: all five behaviors documented,
DESIGN accepts non-MNN schemes.

**Done when:** both executors document all five behaviors, DESIGN.md
accepts non-MNN schemes, lockstep test green.

#### M15: Router/design polish — adaptive language, workspace awareness, handoff ✅

**Why:** Italian is hardcoded in a published skill (router question,
approval words, proposal template) while the milestone format is
English; discovery assumes a single repo; design mode ends without
telling the user how to execute.

**Approach:** Language rule stated once in SKILL.md (chat interactions
in the user's language; forge-flow file content in English unless the
project's existing forge-flow uses another language) — Italian strings
become examples, not prescriptions. DESIGN.md discovery: when the
target directory contains multiple git checkouts (sibling-repo
workspace), enumerate them, confirm scope, locate the forge-flow home.
DESIGN.md phase 5: after validation passes, suggest the execution
handoff (`/forge-flow TDD <path>`). Sync to codex/.

**Tasks:**
- [x] SKILL.md: language-adaptive rule (new `## Language` section); router question + approval words language-neutral with examples
- [x] DESIGN.md: proposal templates, pending-milestone question, version suggestion, Discovery Brief example in English; "present in the user's language" note added
- [x] DESIGN.md: multi-repo workspace bullet in discovery sources (source 7)
- [x] DESIGN.md: execution-handoff suggestion at the end of validation
- [x] Sync to codex/, lockstep test green
- [x] Commit & push

**Notes:** Executed in IDD mode. "Done when" verified: no prescriptive
Italian remains in behavior files (Italian survives only as examples of
approval words), suite green (4 lockstep + 24 install).

**Done when:** no prescriptive Italian remains in behavior files,
discovery handles a multi-repo workspace, design mode ends with the
handoff suggestion, all tests green.

## Out of scope for v0.2

- Templating/build machinery for variants (inline neutral phrasing instead)
- CI on GitHub Actions (tests run locally; revisit if the repo gains contributors)
- `uninstall` command, auto-update, telemetry (unchanged from v0.1)

---

## v0.3 — Flatten to one generic payload + multi-assistant installer

**Obiettivo:** mirror the code-audit v0.3 packaging treatment. v0.2 made
the four behavior files byte-identical across the `claude/` and `codex/`
variants; research since confirmed `SKILL.md` is a cross-assistant
standard (agentskills.io — Claude Code, Codex, opencode read the same
folder verbatim). So the two-variant tree is now redundant: collapse it
to ONE flat generic `forge-flow/` payload, and replace the claude/codex-only
installer with a broad multi-assistant one.

**Approccio:** the behavior files (`SKILL.md`, `DESIGN.md`, `TDD.md`,
`IDD.md`) are already variant-neutral and identical — take them once
into a top-level `forge-flow/`. Merge the two variant READMEs into one
neutral doc. Keep `agents/openai.yaml` in the payload as optional Codex
metadata (harmless to other assistants). The lockstep test becomes moot
(no variants to keep in step) — retire it. Installer mirrors code-audit:
claude/codex/opencode verbatim, gemini TOML, agents AGENTS.md, manual,
with `--check` per target and the `.installed-from` SHA stamp.

**Rischi:** the flatten deletes the variant dirs — anyone who installed
the old `./install.sh claude|codex` flags needs the new `--target`
flags; document in README. Mitigated: no external users beyond this
workspace.

### Phase G — Flatten

#### M16: Collapse the two variants into one flat `forge-flow/` payload ✅

**Why:** The claude/codex split exists only for historical reasons; the
files are identical and the standard is shared. One payload is simpler,
truly de-Claudized, and copyable anywhere.

**Approach:** `git mv claude/forge-flow` → top-level `forge-flow/`; bring
`agents/openai.yaml` across (optional Codex metadata); merge the two
variant READMEs into one neutral `forge-flow/README.md` (drop "Claude
variant"/"Codex variant" framing, keep the per-assistant invocation
notes); remove the now-empty `claude/` and `codex/` trees. Update root
`install.sh` source path, root `README.md` layout, and retire
`tests/test_lockstep.sh` (no variants to lockstep). Behavior files are
unchanged content.

**Tasks:**
- [x] `git mv claude/forge-flow forge-flow`; move `agents/openai.yaml` into it
- [x] Merge variant READMEs → one neutral `forge-flow/README.md`
- [x] Remove empty `claude/` and `codex/` dirs
- [x] Retire `tests/test_lockstep.sh`; update root `README.md` layout tree
- [x] Point `install.sh` source detection at the flat `forge-flow/`
- [x] `bash tests/test_install.sh` still green (or updated in M17)

**Done when:** the skill is one top-level `forge-flow/` folder, the
variant dirs are gone, and `cp -r forge-flow ~/somewhere` is a complete
skill.

### Phase H — Multi-assistant installer

#### M17: Broad multi-assistant installer + per-target tests ✅

**Why:** Match code-audit: one installer that places the payload for
whichever assistant the user runs, plus manual-copy.

**Approach:** Rewrite root `install.sh` mirroring code-audit's:
`--target claude|codex|opencode|gemini|agents|manual|all` (interactive
menu when no target on a TTY; default claude otherwise). claude →
`~/.claude/skills/forge-flow/`, codex → `~/.codex/skills/forge-flow/`,
opencode → `~/.config/opencode/skills/forge-flow/` (verbatim); gemini →
`~/.gemini/commands/forge-flow.toml` + payload in `~/.config/forge-flow`;
agents → AGENTS.md pointer + payload in `~/.config/forge-flow`; manual →
print the flat path. Keep remote-clone mode, `--force`, `--check` per
target, `.installed-from` SHA stamp. Rewrite `tests/test_install.sh`
for the multi-target model (verbatim targets, gemini toml, agents
pointer, manual no-write, --check drift).

**Tasks:**
- [x] Rewrite `install.sh` with the multi-target dispatch + menu
- [x] Gemini TOML emitter + AGENTS.md pointer (idempotent) + manual print
- [x] `--check` per target; `.installed-from` stamp retained
- [x] Rewrite `tests/test_install.sh` for the new model (per-target + drift)
- [x] Root `README.md` install section rewritten for `--target` flow
- [x] Full test suite green

**Done when:** `install.sh --target <x>` installs correctly for
claude/codex/opencode/gemini/agents/manual, `--check` detects drift per
target, and the test suite is green.

#### M18: CI — run the test suite on push ✅

**Why:** code-audit and deck got GitHub Actions in this session; forge-flow's
suite only runs locally. forge-flow is pure Markdown + a bash installer with
no external dependencies, so CI is a clean `bash tests/test_install.sh`
on every push — no best-effort dep installs needed.

**Approach:** `.github/workflows/tests.yml` on push-to-main + PR,
ubuntu-latest, `actions/checkout@v5`, run `bash tests/test_install.sh`.
README gains a one-line CI note.

**Tasks:**
- [x] `.github/workflows/tests.yml` — checkout@v5 + run tests/test_install.sh
- [x] README: note CI runs the installer suite on push
- [x] Local suite still green; workflow YAML valid

**Done when:** the workflow runs `tests/test_install.sh` on push and is
green; a hand-broken installer would red the build.

## Out of scope for v0.3

- Per-assistant behavior divergence (the whole point is one payload).
- Native non-SKILL.md integrations beyond Gemini TOML + AGENTS.md.
- uninstall / auto-update / telemetry (unchanged from v0.1/v0.2).

---

# Follow-up — Ponytail essentiality integration

Adopt the decision model from
[`DietrichGebert/ponytail`](https://github.com/DietrichGebert/ponytail)
as native forge-flow behavior rather than installing its plugin. Devplan
remains authoritative for scope, test policy, execution order, and
completion gates. Ponytail is conceptual prior art under the MIT
license; its lifecycle hooks, persistent modes, duplicate review
skills, and "one small test" policy are not imported.

Recommended order: M19 → M20. The milestones are independent of the
completed v0.3 distribution work.

## M19: Filter proposed milestones through an essentiality ladder ✅

**Why:** DESIGN validates structure and codebase coherence, but it can
still produce a well-formed plan for work that should be deleted,
handled by the standard library, or solved by a native platform
feature. Preventing speculative work at design time is cheaper than
finding it in review after implementation.

**Approach:** Add an essentiality checkpoint to
`forge-flow/DESIGN.md` after discovery and before the final proposal. For
each proposed milestone, test the options in order: does the work need
to exist; does the standard library solve it; does the platform provide
it natively; does an already-installed dependency cover it; can the
custom approach be materially smaller. Delete or merge speculative
milestones and record the selected lower-complexity strategy in the
proposal's Approach/rationale. The checkpoint advises and simplifies;
it never silently removes an explicit requirement, security control,
trust-boundary validation, accessibility behavior, data-loss
protection, or a project convention confirmed during discovery.
Document the conceptual Ponytail source in both READMEs without making
it an installation dependency.

**Tasks:**
- [x] Add the ordered essentiality checkpoint to the proposal flow in `forge-flow/DESIGN.md`
- [x] Extend design validation to reject speculative preparation, avoidable dependencies, and single-use abstractions unless the plan records a verified reason
- [x] State the non-negotiable explicit-requirement, correctness, security, accessibility, and project-convention boundaries
- [x] Add Ponytail attribution and the no-runtime-dependency boundary to `README.md` and `forge-flow/README.md`
- [x] Add `tests/test_content.sh` covering the DESIGN checkpoint, guardrails, and attribution
- [x] Update CI and README test instructions so the installer and content-contract suites both run
- [x] Test: run all shell test suites
- [x] Commit & push

**Done when:** a design-mode proposal must consider deletion, stdlib,
native platform features, installed dependencies, and a smaller custom
approach before adding milestones, while explicit requirements and
existing safety/convention checks remain authoritative and CI enforces
the contract.

**Notes:** Executed in TDD mode. The new content-contract suite failed
on the missing DESIGN checkpoint before implementation, then passed
after the playbook, documentation, and CI updates. Done-when was
verified with `tests/test_content.sh`; the existing installer suite
also remains green (24 checks).

## M20: Make TDD and IDD simplification Ponytail-aware ✅

**Why:** Both executors already contain a generic Simplify step, but
they do not define what simplification means. A shared ordered pass
makes implementation behavior predictable while preserving forge-flow's
stronger test discipline.

**Approach:** Expand the Simplify step in `forge-flow/TDD.md` and
`forge-flow/IDD.md` with the same ladder used by DESIGN: delete only
unneeded code, prefer stdlib and native platform behavior, reuse an
installed dependency before adding one, inline unearned single-use
abstractions, and reduce files/branches only when behavior stays
unchanged. The executor must re-run every applicable test after the
pass. Devplan's existing test policy wins over Ponytail's minimal-test
guidance: do not cap coverage at one check, delete required test levels,
or replace established project tests with demos. The same precedence
applies to validation, error handling that prevents data loss,
security, accessibility, explicit requirements, and the milestone's
Done-when contract. No automatic `ponytail:` comments or persistent
mode state are added.

**Tasks:**
- [x] Expand the Simplify step in `forge-flow/TDD.md` with the ordered essentiality ladder and post-pass test requirement
- [x] Apply the same simplification contract to `forge-flow/IDD.md`
- [x] State explicit precedence for the existing test policy, safety controls, accessibility, requirements, and Done-when verification
- [x] Extend `tests/test_content.sh` to assert TDD/IDD parity and guard against importing one-test limits, persistent modes, or automatic Ponytail comments
- [x] Update `README.md` and `forge-flow/README.md` with the design → implement → simplify behavior
- [x] Test: run all shell test suites
- [x] Commit & push

**Done when:** TDD and IDD apply the same deterministic simplification
pass, all applicable tests are still required and re-run afterward,
and CI fails if either executor weakens the established quality or
completion gates.

**Notes:** Executed in TDD mode. The expanded content suite failed
before TDD/IDD defined the ladder, then passed after both playbooks
received the same ordered contract. Verification covers ladder order,
quality boundaries, forbidden one-test/persistent-mode/comment
behavior, both READMEs, and the unchanged installer suite (24 checks).

---

## Follow-up — Comment essentiality, ponytail: convention, debt tracking

Complete the Ponytail integration with the three remaining concepts
identified in the 2026-06-20 gap analysis: comments that carry their
weight, the `ponytail:` structured-comment convention for intentional
simplifications, and a debt-tracking file that bridges design-time
decisions with audit-time verification.

Recommended order: M21 → M22 → M23.

### M21: Comment essentiality — add a comment-weight step to the simplify ladder ✅

**Why:** The simplify ladder (TDD step 5, IDD step 4) covers code,
dependencies, files, and abstractions, but not comments. A comment that
restates the code line-by-line is technical debt just like a single-use
abstraction: it occupies cognitive space, must be maintained, and lies
when the code changes and the comment doesn't. The right comment says
**why**, not **what**. The ladder must recognize and reduce dead-weight
comments during simplification.

**Approach:** Add a seventh rung to the simplify ladder in both
`forge-flow/TDD.md` and `forge-flow/IDD.md`:

```
7. **Compress or delete comments that don't carry their weight.**
   - Delete comments that restate the code (the code is the "what").
   - Compress verbose docstrings that paraphrase the function signature.
   - Keep only: why (intent, trade-off, context the code can't express),
     gotchas (non-obvious behavior), and public-API contracts.
```

This is the last rung — it runs only when there is material to clean.
It never removes ponytail: comments (those are intentional debt, not
dead weight) or public API documentation.

**Tasks:**
- [x] Add the seventh rung to the simplify ladder in `forge-flow/TDD.md`
- [x] Add the same rung to `forge-flow/IDD.md`
- [x] Extend `tests/test_content.sh` to assert the comment-weight rung exists in both playbooks
- [x] Verify lockstep: TDD.md and IDD.md simplify sections match
- [x] Commit & push

**Done when:** both TDD.md and IDD.md instruct the simplify pass to
compress or delete comments that restate the code, and CI verifies the
rung is present.

**Notes:** Marked done retroactively (2026-06-24 bookkeeping). The 7th
rung shipped in the shared `EXECUTOR-CORE.md` (simplify ladder, rung 7)
during the M25 extraction rather than as a standalone TDD/IDD edit; both
playbooks inherit it. Enforced by `tests/test_content.sh`.

### M22: `ponytail:` comment convention — document intentional simplifications in code ✅

**Why:** Today when TDD/IDD makes a simplification with a known ceiling
(e.g. O(n) scan instead of hash map because today there are 50 elements),
the reasoning lives only in the session transcript. Six months later
nobody knows that the O(n) is intentional, what the ceiling is, or when
to upgrade. A structured `ponytail:` comment — documented as an explicit
instruction in the playbooks — turns a silent trade-off into a machine-
readable breadcrumb that both humans and D01 audits can act on.

**Approach:** Add a paragraph after the simplify ladder in both
`forge-flow/TDD.md` and `forge-flow/IDD.md`:

```
**ponytail: comment convention.** When a simplification leaves a known
ceiling — an O(n) scan fine at current scale, a global lock fine at
current concurrency, a regex fine for the current input format — leave
a structured comment above the simplified code:

  # ponytail: <what was simplified and why>.
  # Ceiling: <measurable threshold>. Upgrade: <what to do when exceeded>.

The ceiling must be measurable (record count, request rate, input
complexity) so an automated audit can compare against current state.
Never use ponytail: to excuse bugs or missing validation — it marks
intentional trade-offs only.
```

**Tasks:**
- [x] Add the ponytail: convention paragraph to `forge-flow/TDD.md` after the simplify ladder
- [x] Add the same paragraph to `forge-flow/IDD.md`
- [x] Extend `tests/test_content.sh` to assert the convention is documented in both playbooks
- [x] Verify lockstep: both playbooks describe the same convention
- [x] Commit & push

**Done when:** both TDD.md and IDD.md document the `ponytail:` comment
structure with measurable ceiling + upgrade path, and CI verifies it.

**Notes:** Marked done retroactively (2026-06-24 bookkeeping). The
`ponytail:` convention lives in the shared `EXECUTOR-CORE.md`; TDD.md and
IDD.md inherit it. Enforced by `tests/test_content.sh`.

### M23: Debt tracking — `.code-audit/debt.tsv` populated during simplification ✅

**Why:** The `ponytail:` comments document individual simplifications,
but they provide no aggregate visibility. A debt-tracking file populated
during development gives a flat, filterable list with revisit dates that
the audit can cross-reference automatically. Without this file, debt is
visible only by grepping the codebase — no dashboard, no trend, no
automated expiry.

**Approach:**

1. Add a step after simplify in `forge-flow/TDD.md` and `forge-flow/IDD.md`:

```
**Register intentional debt.** When the simplify pass produced a
ponytail: comment, append a row to `.code-audit/debt.tsv` in the
project root. Schema: `dim⇥location⇥title⇥ceiling⇥revisit_by`.
- dim: D01 (essentiality), D10 (performance), or D14 (correctness).
- location: file:line.
- title: one-line summary of the simplification.
- ceiling: the measurable threshold from the ponytail: comment.
- revisit_by: optional ISO date. Omit for permanent shortcuts.
If the file doesn't exist, create it with the header row. Skip if the
same location+title pair already exists (idempotent).
```

2. Add to the completion recap in both playbooks:

```
Debt registered: N items (see .code-audit/debt.tsv)
```

**Tasks:**
- [x] Add the debt-registration step to `forge-flow/TDD.md` (after simplify, before docs)
- [x] Add the same step to `forge-flow/IDD.md`
- [x] Add the debt-count line to both completion recaps
- [x] Extend `tests/test_content.sh` to assert the registration step and recap line exist
- [x] Verify lockstep: both playbooks match
- [x] Commit & push

**Done when:** TDD and IDD both register intentional debt to
`.code-audit/debt.tsv`, the completion recap includes the debt count,
and CI verifies the contract.

**Notes:** Marked done retroactively (2026-06-24 bookkeeping). The
debt-registration step and the `[debt registered: N items …]` recap line
live in the shared `EXECUTOR-CORE.md`; both modes inherit them. Enforced
by `tests/test_content.sh`.

---

## Follow-up — Cross-skill coherence fixes (2026-06-20)

Issues found during coherence audit across forge-flow, uxui-audit, and
tech-audit. Fixes belong here.

### M24: Fix debt.tsv column order mismatch between TDD.md and IDD.md ✅

**Why:** The two playbooks write to the same `.code-audit/debt.tsv` file
but use different column orders — TDD.md:135 has `dim⇥location⇥title`,
while IDD.md:119 has `dim⇥title⇥location`. Rows produced by the two modes
would have misaligned columns, making the file unreadable.

**Approach:** Standardize on TDD.md's order (`dim⇥location⇥title` —
location before title), which matches the M23 spec. Fix IDD.md and add a
lockstep assertion to `tests/test_content.sh` so the mismatch can't
recur.

**Tasks:**
- [x] Fix column order in `forge-flow/IDD.md` debt-registration step to match `dim⇥location⇥title⇥ceiling⇥revisit_by`
- [x] Add lockstep assertion to `tests/test_content.sh`: both playbooks specify the same TSV column order
- [x] Commit & push

**Done when:** Both TDD.md and IDD.md specify `dim⇥location⇥title⇥ceiling⇥revisit_by` and tests verify it.

**Notes:** Marked done retroactively (2026-06-24 bookkeeping). The
mismatch became moot once M25 unified the debt schema into a single
canonical `EXECUTOR-CORE.md` source (`dim⇥location⇥title⇥ceiling⇥revisit_by`),
so the two modes can no longer diverge. Enforced by `tests/test_content.sh`.

---

## v0.4 — Token essentiality pass

Cross-skill audit found ~30% of the skill payload is wasted on duplication
and verbose prose. All three skills (forge-flow, uxui-audit, tech-audit) are
one family — this pass applies D01-style essentiality to the skill instructions
themselves. Same concepts, same behavior, fewer tokens.

Recommended order: M25 → M26 → M27 → M28.

### M25: Extract EXECUTOR-CORE.md — deduplicate TDD.md + IDD.md ✅

**Why:** TDD.md and IDD.md are ~70% identical (~200 shared lines). Preflight,
simplify ladder, ponytail, debt registration, test policy, implementation
standards, completion recap, and rules are copy-pasted. Only the execution
loop (test-before vs test-after, 4 numbered steps) is genuinely different.
Every edit to a shared section must be done twice.

**Approach:** Create `forge-flow/EXECUTOR-CORE.md` containing: operating mode,
preflight, simplify ladder, ponytail convention, debt registration, test policy,
implementation standards (incl. microcopy rule), completion recap template, rules.
TDD.md and IDD.md keep only their execution loop + a "Read EXECUTOR-CORE.md"
directive at the top. README updated to document the new file.

**Tasks:**
- [x] Create `forge-flow/EXECUTOR-CORE.md` with all shared sections
- [x] Strip shared content from `forge-flow/TDD.md`, add load directive
- [x] Strip shared content from `forge-flow/IDD.md`, add load directive
- [x] Update `tests/test_content.sh` lockstep checks to verify new structure
- [x] Update `forge-flow/README.md`
- [x] Commit & push

**Done when:** TDD.md and IDD.md are ~90 lines each; EXECUTOR-CORE.md contains
all shared behavior once; both playbooks produce identical results.

### M26: Unify simplify/essentiality ladder across DESIGN.md, TDD.md, IDD.md ✅

**Why:** The same "delete → stdlib → native → existing dep → custom" logic
appears in DESIGN.md (essentiality checkpoint, lines 149-172), TDD.md (simplify
step, lines 90-110), and IDD.md (simplify step, lines 75-99). After M25, the
executor version lives in EXECUTOR-CORE.md. DESIGN.md's version differs slightly
— it's a checkpoint during planning, not a post-implementation pass.

**Approach:** Make EXECUTOR-CORE.md the canonical ladder source. DESIGN.md
references it: "Run the simplification ladder from EXECUTOR-CORE.md against
each candidate milestone." Keep DESIGN.md's non-negotiable boundary list
(explicit requirements, security, a11y) since that's design-mode-specific.

**Tasks:**
- [x] In DESIGN.md, replace the essentiality checkpoint prose with a reference to EXECUTOR-CORE.md
- [x] Preserve DESIGN.md's boundary list (explicit-requirements, security, a11y, data-loss)
- [x] Verify `tests/test_content.sh` still passes
- [x] Commit & push

**Done when:** One canonical ladder, cited from all three playbooks.

### M27: Compress DESIGN.md + SKILL.md prose ✅

**Why:** DESIGN.md has verbose sections: "Synergy with TDD/IDD" (13 lines, self-
evident), Validation section (43 lines, many checks implicit in executor),
discovery brief example (9 lines → 4). SKILL.md mode descriptions restate what
the playbooks already say. Scope section duplicates base CLAUDE.md rule.

**Approach:**
- Delete DESIGN.md "Synergy with TDD/IDD" section (lines 387-399)
- Compress Validation section to ~15 lines (most impactful checks only)
- Compress discovery brief example from 9 lines to 4
- SKILL.md: mode descriptions from 7 lines to 3; scope from 5 lines to 1
- Compress SKILL.md devplan path detection from 8 lines to 3
- Trim SKILL.md frontmatter description

**Tasks:**
- [x] Delete DESIGN.md § Synergy with TDD/IDD
- [x] Compress DESIGN.md § Validation
- [x] Compress discovery brief example
- [x] Compress SKILL.md mode descriptions + scope + path detection
- [x] Update `tests/test_content.sh` to match compressed form
- [x] Commit & push

**Done when:** DESIGN.md is ~330 lines (from ~400), SKILL.md is ~55 lines (from ~67).

### M28: Trim READMEs ✅

**Why:** Top-level README and variant README contain redundant install
instructions and duplicated mode descriptions.

**Approach:** Top-level README: compress install section, merge duplicate
descriptions. Variant README: remove content that duplicates agentskills.io
standard info. Target ~20% reduction.

**Tasks:**
- [x] Compress top-level `README.md`
- [x] Compress `forge-flow/README.md`
- [x] Verify all links resolve
- [x] Commit & push

**Done when:** READMEs convey same information with fewer words.

## v0.5 — Reproducibility doctrine

Sibling repos in the same workspace converge on the same
operational spine: one command brings the whole stack up (`dev.sh`), one command
runs tiered tests (`run_tests.sh`), live/e2e tests exercise real use cases with
real but non-prod credentials, and setup is never manual — it's codified in the
scripts. forge-flow plans and executes work but never steers toward this spine,
and folding scaffolding into the plan would breach its own "no preparation
milestones" rule. This version adds a dedicated **`scaffold`** route that mounts
the spine outside the milestone loop; DESIGN merely points to it (opt-out,
scale-gated, runnable apps only); the executor enforces scripted, non-manual
setup and a first-class live tier.

Recommended order: M29 → M30 → M31 → M32.

### M29: Add the `scaffold` route — mount the operational spine ✅

**Why:** Every project needs the same spine (one-command bring-up, tiered test
runner, live tests with non-prod creds), but forge-flow can't mount it — the user
hand-writes it each time, or it leaks into the devplan as prep milestones the
skill forbids. A dedicated route centralizes the convention knowledge distilled
from the sibling repos and keeps the spine out of the feature plan.

**Approach:** SKILL.md router learns a fourth token `scaffold` → new
`forge-flow/SCAFFOLD.md` playbook. SCAFFOLD.md is a generation *playbook* (like
DESIGN.md), not a template library: it detects the stack and the project's
existing idiom (Makefile targets vs `dev.sh` vs `package.json` scripts vs
docker-compose) and generates, idempotently (extend, never clobber) — standard
scope: a one-command bring-up (readiness-poll, `.env` bootstrap from
`.env.example`, `--fresh`/`--down`), a tiered `run_tests.sh` (unit/integration/
live, skip-with-reason gating, scriptable exit codes, pass/fail/skip recap),
`.env.example` with test-credential placeholders, `tests/` tier dirs, and a
prod-isolation skeleton (`.env.test` or `docker-compose.test.yml`) when the stack
has external services. Project-specific bits are left as explicit TODO markers
rather than guessed. Verifies by running the generated test-runner (and bring-up
where possible); reuses EXECUTOR-CORE.md verify/commit discipline. Scoped to
runnable apps/services — refuses on a pure library/skill/static project with a
clear message.

**Tasks:**
- [x] Add `scaffold` token dispatch to SKILL.md router
- [x] Write `forge-flow/SCAFFOLD.md`: stack + idiom detection, idempotent generation, standard scope, explicit TODO markers, runnable-app guard
- [x] Encode the sibling-repo conventions (readiness-poll, skip-with-reason, exit codes, prod isolation) as the generation contract
- [x] Test: content — `tests/test_content.sh` asserts the route in SKILL.md + SCAFFOLD.md contract terms
- [x] Test: live — run `scaffold` on a throwaway sample project and assert the generated runner executes green and re-running doesn't clobber
- [x] Update `forge-flow/README.md` + top-level README to document the route
- [x] Commit & push

**Done when:** `forge-flow scaffold` on a runnable project with no spine produces a
working, idempotent bring-up + tiered test-runner (verified by running them);
re-running it does not clobber; a non-runnable project is refused with a clear
message; `tests/test_content.sh` passes.

**Notes:** Executed in TDD mode. Content contract written red-first (5+ new
assertions: SCAFFOLD.md presence, router token, bring-up/runner/tier/skip-with-
reason/exit-code/idempotent/prod-isolation/runnable-guard/TODO terms), then
SKILL.md + SCAFFOLD.md + both READMEs made them green. **Live test performed**
(not CI-automated — the playbook is agent-driven): scaffolded a throwaway Python
service in the scratchpad following SCAFFOLD.md, then ran the generated spine —
`run_tests.sh all` → unit PASS, integration/live SKIP-with-reason, exit 0;
`dev.sh` → readiness-poll reached ready, integration PASS against the live
service, `--down` tore it down; re-running generation was idempotent (identical
checksums, "exists, skipping"). The live run caught a real defect — `source`-ing
a `.env` whose placeholders contain `<…>` shell metacharacters fails — so the
bring-up contract in SCAFFOLD.md now mandates parsing `KEY=VALUE` instead of
sourcing. Done-when verified end-to-end; full suite green (content + 24/24
install).

### M30: DESIGN suggests `scaffold` when the spine is missing (opt-out) ✅

**Why:** DESIGN should steer toward the spine during from-scratch or foundational
setup — but as a pointer to the route, not by injecting scaffolding into the plan
(that would be a prep milestone and would derail small requests).

**Approach:** Broaden DESIGN.md Discovery source #6 to "Reproducibility & test
inventory": detect one-command bring-up, replicable runner, and live/e2e tier
presence. In Phase 3, for runnable apps at **Medium+ scale or when the plan
establishes/extends foundations**, if the spine is missing, emit a one-line
pointer: *"no one-command bring-up / replicable runner detected → consider
`forge-flow scaffold` before executing."* Opt-out: a single explicit "no" drops
it, recorded under Out of scope. Never auto-runs scaffold; never adds a
scaffolding milestone; small tweaks and non-runnable projects stay silent.

**Tasks:**
- [x] Broaden DESIGN.md Discovery source #6 to detect bring-up + runner + live tier
- [x] Add the one-line `scaffold` pointer to Phase 3, scale-gated (Medium+/foundational) and runnable-apps-only
- [x] Specify opt-out + record-as-out-of-scope; never auto-run, never a scaffolding milestone
- [x] Test: content — assert the detection terms + the gated scaffold pointer exist in DESIGN.md
- [x] Update docs if needed (none — pointer lives in DESIGN.md; READMEs already cover the route via M29)
- [x] Commit & push

**Done when:** a Medium+ plan for a runnable project with no spine shows the
one-line scaffold pointer; a small tweak and a non-runnable project do not; an
explicit "no" is honored and noted out-of-scope.

**Notes:** Executed in TDD mode. Eight content assertions written red-first
(failed on "Reproducibility spine pointer"), then DESIGN.md source 6 broadened to
"Reproducibility & test inventory" (bring-up + runner + live/e2e detection) and a
"Reproducibility spine pointer" subsection added to Phase 3 — scale-gated
(Medium+/foundational), runnable-apps-only, opt-out → Out of scope, never
auto-run, never a scaffolding milestone. Done-when verified against the playbook
text; suite green (content + 24/24 install).

### M31: EXECUTOR reproducibility guardrails — no manual steps + first-class live tier ✅

**Why:** The executor must not bring the stack up by hand or apply ad-hoc setup;
it should drive and extend the scaffolded scripts so the next run reproduces the
state (global "no manual, always replicable" rule). And live tests must be a
first-class tier with prod isolation, not a "note for manual run" fallback.

**Approach:** Two edits to EXECUTOR-CORE.md. (1) Implementation standards + Verify
"Done when": prefer the scaffolded bring-up to start the stack; encode any
setup/env change idempotently in the bring-up or test script (or run
`forge-flow scaffold` to extend it), never a manual step; if a needed script is
absent, create/extend it (or register a ponytail/debt). (2) Test policy: rewrite
the live paragraph — live tier = real, non-prod calls verifying true use cases
end-to-end, with the isolation conventions distilled from the repos (test
creds/sandbox, separate keys / `.env.test` / dedicated test resources,
skip-with-reason when absent or placeholder, never prod). Unit-always stays; live
is additive.

**Tasks:**
- [x] Add no-manual / encode-in-scripts rule to EXECUTOR-CORE.md implementation standards
- [x] Tie Verify "Done when" to the scripted bring-up when the app must run
- [x] Rewrite the live-test paragraph in Test policy: first-class live tier + prod-isolation conventions
- [x] Test: content — assert both the no-manual rule and the live-tier/isolation language exist
- [x] Update docs if needed (none — executor-internal behavior; READMEs already note the live tier via M29)
- [x] Commit & push

**Done when:** a milestone needing the app running uses the scaffolded bring-up;
any environment change lands in a script, not a manual step; Test policy documents
the live tier and its prod-isolation rules; `tests/test_content.sh` passes.

**Notes:** Executed in TDD mode. Eight content assertions written red-first
(failed on "No manual setup"), then three EXECUTOR-CORE.md edits made them green:
(1) Implementation standards gained a "No manual setup — always replicable" rule
(drive the scaffolded bring-up; encode env/setup in scripts; never a manual
step), (2) Verify "Done when" now says to use the scaffolded bring-up when the
app must run, (3) Test policy gained a first-class "Live tier" paragraph (real
non-prod calls end-to-end, `.env.test`/sandbox isolation, skip-with-reason, never
against prod; unit stays mandatory). Suite green (content + 24/24 install).

### M32: DESIGN adds a live/e2e test task for real external dependencies ✅

**Why:** A plan that only ever asks for unit tests cannot prove the feature works
against the real world. When a milestone integrates a real external dependency,
the plan should require a live test on the real use case — with non-prod
credentials — using the scaffolded live tier.

**Approach:** In DESIGN.md milestone test-task guidance, add: when a milestone
touches a real external dependency (third-party API, DB, queue, external service),
emit a `Test: live — <real use case, non-prod credentials>` task alongside unit
coverage, using the scaffolded live tier. Defer to project convention — if the
repo deliberately mocks everything and has no live tier, do not force one (point
to `scaffold` instead). Gated (pure-logic milestones stay unit-only); opt-out.

**Tasks:**
- [x] Add the external-dependency → live-test rule to DESIGN.md, using the scaffolded live tier
- [x] State the gate + defer-to-convention (no forcing on deliberate mock-only repos) + opt-out
- [x] Test: content — assert the live-test rule exists in DESIGN.md
- [x] Update docs if needed (none — guidance lives in DESIGN.md; live tier already in READMEs via M29/M31)
- [x] Commit & push

**Done when:** a milestone integrating an external API gets both a unit task and a
`Test: live — …` task referencing non-prod credentials; a deliberate mock-only
repo is not forced; pure-logic milestones stay unit-only.

**Notes:** Executed in TDD mode. Seven content assertions written red-first
(failed on "Live test task for external dependencies"), then a "Live test task for
external dependencies" subsection added to DESIGN.md's Milestone format: real
external dependency → a `Test: live — <real use case, non-prod credentials>` task
alongside unit, on the scaffolded live tier. Gated (pure-logic stays unit-only),
defers to convention (mock-only repos not forced → point to scaffold), opt-out
(recorded under Notes). Suite green (content + 24/24 install).

---

## Follow-up — Executor bookkeeping discipline (2026-06-24)

The 2026-06-24 review found M21–M28 were implemented and committed but their
devplan task checkboxes and milestone headings were never marked done — the plan
misrepresented its own state. EXECUTOR-CORE.md already *instructs* "Update the
devplan", but nothing *verifies* the bookkeeping landed before the commit, so a
batch run skipped it silently. The skill that exists to track work failed to
track its own. This milestone turns marking-done into a verified completion gate.

Execution order: **M33 first** (so the hardened discipline is in place), then the
v0.5 milestones M29 → M30 → M31 → M32.

### M33: Make "mark the milestone done" a verified, committed gate ✅

**Why:** The executor's "Update the devplan" step is advisory — it tells the run
to tick the boxes but never checks that it happened, and the devplan file isn't
guaranteed to be in the milestone commit. Result: work ships green while the plan
still shows `- [ ]`, so the plan can no longer be trusted to report what's done —
exactly the drift seen in M21–M28. Bookkeeping that depends on memory gets skipped
under batch execution; it must be enforced like the test and Done-when gates.

**Approach:** Edit `forge-flow/EXECUTOR-CORE.md` (TDD/IDD inherit it). (1) In
"Update the devplan", make the marking verifiable: after editing, re-read the
milestone block and confirm every task is `[x]` and the heading carries the done
marker — no `[ ]` may remain for the milestone being closed. (2) In "Commit &
push", require the devplan file itself among the staged paths for the milestone
commit (the checkbox update ships with the work, never in a later catch-up
commit). (3) Add a Common-rules ❌: never commit a milestone whose devplan tasks
and heading aren't marked done. (4) In "Completion", add a final sweep: scan the
devplan for any milestone closed during this run still showing `[ ]` or an
unmarked heading, and fix before the recap. Add a `tests/test_content.sh`
assertion that EXECUTOR-CORE.md carries the verify-bookkeeping-before-commit
contract so it can't silently regress.

**Tasks:**
- [x] EXECUTOR-CORE.md "Update the devplan": add the re-read / verify-no-`[ ]` step
- [x] EXECUTOR-CORE.md "Commit & push": require the devplan among staged paths
- [x] EXECUTOR-CORE.md Common rules: add the ❌ never-commit-unmarked rule
- [x] EXECUTOR-CORE.md Completion: add the end-of-run unmarked-milestone sweep
- [x] Extend `tests/test_content.sh` to assert the bookkeeping-gate contract
- [x] Run all shell test suites
- [x] Commit & push

**Done when:** EXECUTOR-CORE.md makes marking a milestone done a verified step
whose result must be in the milestone commit, the completion recap sweeps for any
milestone left with `[ ]`, and `tests/test_content.sh` asserts the contract.

**Notes:** Executed in TDD mode — the five `test_content.sh` assertions were
written first and confirmed red ("missing: Verify the bookkeeping landed"), then
the four EXECUTOR-CORE.md edits made them green. Done-when verified by re-reading
EXECUTOR-CORE.md (verify-step in "Update the devplan", devplan-in-commit rule in
"Commit & push", ❌ in Common rules, sweep in Completion) and the green suite
(content + 24/24 install). This commit is itself the first to ship under the new
gate — the devplan bookkeeping is staged with the milestone.

---

## Follow-up — Test specificity (2026-06-24)

### M34: Anchor content assertions to milestone-unique phrases ✅

**Why:** Some content-contract assertions check a generic token that now appears
in more than one milestone — e.g. `"opt-out"` occurs twice in DESIGN.md (M30 and
M32). A regression in one milestone's clause is masked by the other milestone's
identical token, so the guard stays green while the behavior is gone. Found in the
2026-06-24 self-review: a weak guard is worse than none because it reads as
coverage. `tests/test_content.sh` should fail when *that* milestone's content is
removed, not merely when the word disappears everywhere.

**Approach:** For each milestone whose key assertion is a shared/generic token,
add a milestone-unique anchor — a distinctive sentence fragment only that
milestone contains — to `tests/test_content.sh`. Keep the existing broad checks
(they still guard against total deletion); the anchors are additive. Spot-check
the red path: removing the milestone's clause must make its anchor fail.

**Tasks:**
- [x] Add an M30-unique anchor (scaffold-pointer opt-out clause "drops it, recorded under") to `tests/test_content.sh`
- [x] Add an M32-unique anchor (live-test-task opt-out clause "drops the live task") to `tests/test_content.sh`
- [x] Red-path spot check: deleting each clause makes only its own anchor fail
- [x] Run all shell test suites
- [x] Commit & push

**Done when:** M30 and M32 each have a content assertion no other milestone's text
can satisfy, the red path is spot-checked, and the suite is green.

**Notes:** Executed in TDD-ish mode (the change *is* test code). Replaced the two
generic `"opt-out"` checks — which the other milestone's identical token could
satisfy — with milestone-unique opt-out clauses: M30 → "drops it, recorded under",
M32 → "drops the live task". Red path verified: deleting M30's clause fails only
the M30 anchor, deleting M32's fails only the M32 anchor (DESIGN.md restored from
git after each). Suite green (content + 24/24 install).

---

## Follow-up — Behavioral smoke findings (2026-06-24)

Found by the `/tmp` behavioral smoke test (a subagent generated a Node spine by
following SCAFFOLD.md, then executed a 2-milestone devplan to exercise the M33
gate). Both phases passed; these close the residual seams it surfaced.
Recommended order: M35 → M36.

### M35: Close the M33 commit-inclusion seam + align the done-marker example ✅

**Why:** The smoke test confirmed M33's gate holds when followed, but exposed one
game-able seam: the "DEVPLAN.md ships in the milestone commit" requirement is
*asserted*, never *verified*. The checkbox/heading bookkeeping is re-read and
double-checked, but nothing inspects the commit afterward — so an executor that
omits the devplan from its explicit staged paths recreates exactly the forbidden
catch-up commit, and the only net (the Completion sweep) runs once, at the very
end. Separately, the done-marker example `- [x] Milestone X: Name ✅` shows a
checkbox-list item while real milestones are `## MNN: title` headings — misleading.

**Approach:** In EXECUTOR-CORE.md "Commit & push", add a post-commit verification
rung mirroring "verify the bookkeeping landed": after committing, run
`git show --stat HEAD` and confirm the active devplan file is listed; if absent,
`git commit --amend` to include it before moving on. Fix the done-marker example
to `## MNN: <title> ✅`. Add a `tests/test_content.sh` assertion for the new rung.

**Tasks:**
- [x] Add the post-commit `git show --stat HEAD` devplan-inclusion check (amend if absent) to EXECUTOR-CORE.md "Commit & push"
- [x] Align the done-marker example to the heading format `## MNN: <title> ✅`
- [x] Extend `tests/test_content.sh` to assert the post-commit verification rung
- [x] Run all shell test suites
- [x] Commit & push

**Done when:** EXECUTOR-CORE.md tells the executor to verify, after committing,
that the devplan is in the commit and amend if not; the done-marker example uses
heading format; `tests/test_content.sh` asserts the rung; suite green.

**Notes:** Executed in TDD mode (three content assertions red-first, then two
EXECUTOR-CORE.md edits to green). Dogfooded the new rung: after committing this
milestone I ran `git show --stat HEAD` and confirmed `DEVPLAN.md` is listed.
Done-when verified; suite green (content + 24/24 install).

### M36: SCAFFOLD.md — runnable tiers + dispatcher-to-script wiring ✅

**Why:** The smoke test found two spots where a literal follower of SCAFFOLD.md
must improvise: (a) Phase 2.4 creates empty `tests/integration|live/` dirs, so
those tiers can only ever skip, never demonstrate a PASS, until the agent invents
a test; (b) Phase 2.1 says reuse the command idiom (npm script / Make target) but
a one-line dispatcher cannot hold readiness-poll / `--fresh` / `--down` / env-parse
logic, and the playbook never says to put that logic in a script the idiom calls.

**Approach:** (a) Phase 2.4 — instruct scaffold to seed one TODO-marked smoke test
per tier (a health/smoke check) so every tier is immediately runnable. (b) Phase
2.1 — add: when the idiom is a thin one-line dispatcher but the bring-up needs
non-trivial logic, put the logic in a script (e.g. `dev.sh`) and wire the idiom to
call it. Add `tests/test_content.sh` assertions for both.

**Tasks:**
- [x] Phase 2.4: seed one TODO-marked smoke test per tier so tiers are runnable
- [x] Phase 2.1: add the dispatcher-to-script wiring rule
- [x] Extend `tests/test_content.sh` to assert both additions
- [x] Run all shell test suites
- [x] Commit & push

**Done when:** SCAFFOLD.md seeds a runnable smoke test per tier and tells the
follower to wire a thin idiom to a logic script; `tests/test_content.sh` asserts
both; suite green.

**Notes:** Executed in TDD mode (four content assertions red-first, then two
SCAFFOLD.md edits to green). Phase 2.4 now seeds a TODO-marked smoke test per tier
so tiers are immediately runnable; Phase 2.1 adds the thin-dispatcher → logic-
script wiring rule (the exact two improvisations the smoke test had to make).
Suite green (content + 24/24 install).

---

## Follow-up — Documentation alignment (2026-06-24)

### M37: Align documentation surfaces to the real skill (name + scaffold route) ✅

**Why:** A doc-correctness check found the "machine" surfaces lag the prose
READMEs. `agents/openai.yaml` still advertises the pre-rename skill
(`display_name: "Devplan"`, invocation `$devplan`) and omits the `scaffold`
route — it points at a command that no longer exists. `SKILL.md`'s frontmatter
`description` (the string that drives skill discovery/invocation) still says
"Three modes" and never mentions `scaffold`, so the v0.5 route is invisible where
it matters most. `forge-flow/README.md` carries the old skill name in its title
and two references, inconsistent with the root README. A minor: the root layout
tree comment names only the installer suite though `tests/` now also holds the
content-contract suite. (Uses of "devplan" meaning the *plan file* are correct and
stay.)

**Approach:** Update the four surfaces and guard them. `agents/openai.yaml`:
`Devplan`→`forge-flow`, `$devplan`→`$forge-flow`, add `scaffold` to the
short_description/prompt. `SKILL.md` frontmatter `description`: add the `scaffold`
route concisely (it was trimmed for tokens in M27 — keep it tight).
`forge-flow/README.md`: rename the three skill-name `devplan` references to
`forge-flow`. Root `README.md`: broaden the `tests/` tree comment to both suites.
Add `tests/test_content.sh` guards: openai.yaml uses `forge-flow` (not `$devplan`/
`Devplan`) and mentions `scaffold`; the SKILL frontmatter mentions `scaffold`; the
payload README is no longer titled `devplan`.

**Tasks:**
- [x] `agents/openai.yaml`: rename to forge-flow + add the scaffold route
- [x] `SKILL.md` frontmatter `description`: add the scaffold route, concisely
- [x] `forge-flow/README.md`: skill-name `devplan` → `forge-flow` (3 spots; leave plan-file senses)
- [x] Root `README.md`: `tests/` tree comment names both suites
- [x] `tests/test_content.sh`: guards for openai.yaml naming + scaffold, SKILL frontmatter scaffold, payload README title
- [x] Run all shell test suites
- [x] Commit & push

**Done when:** openai.yaml and the SKILL frontmatter name the skill `forge-flow`
and advertise the `scaffold` route, the payload README no longer uses the old
skill name, the layout comment reflects both suites, and `tests/test_content.sh`
guards all of it; suite green.

**Notes:** Executed in TDD mode (guards red-first — "openai.yaml missing: forge-flow"
— then the four surface edits to green). `grep` confirms no residual `$devplan` /
`Devplan` / old payload-README title remain. Plan-file senses of "devplan" left
intact. Suite green (content + 24/24 install); re-installed to ~/.claude with no
drift.

## Follow-up — Greenfield spine proposal (2026-06-27)

### M38: DESIGN proposes the operational spine explicitly (default-include, greenfield-aware) ✅

**Why:** The v0.5 spine pointer (M30) is a passive one-liner, easy to miss — and it
was missed on a real greenfield run, leaving a runnable app with no tiered test
runner or e2e tier. Make the spine an **explicit, default-include proposal** the
user must accept or actively opt out of, recorded in the devplan, and fix the
greenfield day-zero ordering.

**Approach:** In `DESIGN.md`, replace the "Reproducibility spine pointer" subsection
with "Operational spine — propose explicitly": default-include, explicit opt-out
("no spine"), decision recorded in the devplan; branch **greenfield** (scaffold
cannot precede the app → attach the spine to the first runnable milestone, never a
prep milestone) vs **brownfield** (app exists → scaffold before executing). In
`EXECUTOR-CORE.md`, add the greenfield day-zero exception to "Use the scaffolded
bring-up". Update the M30 content anchors and add M38 guards in
`tests/test_content.sh`.

**Tasks:**
- [x] DESIGN.md: replace spine pointer with the explicit default-include "Operational spine" proposal (greenfield/brownfield branches, decision recorded in the devplan)
- [x] EXECUTOR-CORE.md: greenfield day-zero exception in "Verify Done when"
- [x] tests/test_content.sh: update M30 anchors; add M38 guards (red → green)
- [x] Run test_content.sh + test_install.sh (green)
- [x] Commit & push
- [x] Deploy: `./install.sh --target claude --force`

**Done when:** DESIGN proposes the spine explicitly (default-include, opt-out "no
spine", decision recorded in the devplan) with greenfield/brownfield branches;
EXECUTOR-CORE has the greenfield first-milestone exception; `test_content.sh` and
`test_install.sh` green; deployed to `~/.claude`.

**Notes:** Content-contract TDD — added M38 guards (red), then edited DESIGN/EXECUTOR
to green; updated the M30 anchors (heading renamed to "Operational spine — propose
explicitly", "consider scaffold" line replaced with "default-include proposal").
Suites green (content + 24/24 install). Supersedes the M30 passive pointer; triggered
by a real greenfield run (football-reborn editor) where the spine was skipped.

## Follow-up — YAML-safe skill metadata (2026-06-29)

### M39: Make SKILL frontmatter YAML-safe ✅

**Why:** Codex skipped `forge-flow` because `SKILL.md` frontmatter has an
unquoted `description` containing `Closed loop:`, which is invalid YAML. The
installed copy must load cleanly so the skill is discoverable again.

**Approach:** Change `forge-flow/SKILL.md` frontmatter `description` to a
YAML-safe folded scalar while preserving the same discovery text. Add a
content-contract test that parses the `SKILL.md` frontmatter as YAML so future
descriptions with `: ` fail in CI before install. Run the content and installer
suites, then deploy through the installer to the Codex skill directory.

**Tasks:**
- [x] Make `forge-flow/SKILL.md` frontmatter parse as YAML
- [x] Add a `tests/test_content.sh` guard for valid `SKILL.md` frontmatter YAML
- [x] Run `bash tests/test_content.sh`
- [x] Run `bash tests/test_install.sh`
- [x] Deploy with `./install.sh --target codex --force`
- [x] Verify the installed Codex `SKILL.md` parses as YAML
- [x] Commit & push

**Done when:** Source and installed Codex `forge-flow/SKILL.md` both parse as
YAML, both shell suites pass, and Codex no longer skips the skill for invalid
metadata.

**Notes:** TDD content-contract fix. Added a `tests/test_content.sh` guard that
parses `SKILL.md` frontmatter with PyYAML when available and a conservative
stdlib fallback otherwise; it failed red on the existing `Closed loop:` scalar.
Changed the source `description` to a folded scalar, then `test_content.sh` and
`test_install.sh` passed. Deployed to `~/.codex/skills/forge-flow`; source and
installed Codex `SKILL.md` both parse as YAML, and `install.sh --target codex
--check` reports no drift.

## Follow-up — Superpowers-derived hardening (2026-07-03)

Mechanisms distilled from the `obra/superpowers` plugin (systematic-debugging,
verification-before-completion, writing-plans, subagent-driven development)
and adapted to this skill's lean-autonomy philosophy: self-checks and gates,
not mandatory reviewer subagents.

### M40: Stuck protocol — root cause before fixes, three-strikes to design review ✅

**Why:** The develop-until-green loop has no rule for when green won't come:
the executor can burn attempt after attempt symptom-patching (sleeps, widened
assertions, swallowed exceptions) and still land a fragile green. Superpowers'
systematic-debugging encodes the two missing rules: no fix without a root-cause
hypothesis, and after three failed attempts the problem is architectural, not
tactical.

**Approach:** Add a "Stuck protocol" section to `EXECUTOR-CORE.md` (between
the shared execution-loop steps and Test policy): (1) from the second fix
attempt on the same failure, state a one-line root-cause hypothesis grounded
in observed evidence (error text, trace, diff) before touching code — one
variable per attempt, no shotgun fixes; a test suspected flaky is re-run
unchanged once to confirm determinism before it counts as an attempt;
(2) after three failed attempts on the same failure, stop patching: write down
what the attempts collectively prove, re-read the milestone's Approach and its
assumptions, then either take a structurally different approach or update the
devplan (revise the milestone, add the missing work) — never a fourth attempt
of the same shape; (3) name the banned moves — widening an assertion, adding a
sleep, swallowing the exception, skipping the test — each legal only with an
explicit justification in the devplan notes. Reference the protocol from
`TDD.md` §4 (Develop until green) and `IDD.md` §2–3. Content anchors in
`tests/test_content.sh` (red → green).

**Tasks:**
- [x] EXECUTOR-CORE.md: add "Stuck protocol" section (root-cause hypothesis from attempt 2, one variable per attempt, flake re-run rule, three-strikes stop, banned moves)
- [x] EXECUTOR-CORE.md: add matching ❌ Common rule (no fourth same-shape attempt without revisiting the design)
- [x] TDD.md §4 + IDD.md §2–3: one-line reference to the Stuck protocol
- [x] tests/test_content.sh: M40 anchors (red → green)
- [x] Test: behavioral — fresh-context pressure run: a scenario with three failed fix attempts must stop and reassess the design, not patch a fourth time; record the outcome in Notes
- [x] Run test_content.sh + test_install.sh (green)
- [x] Commit & push
- [x] Deploy: `./install.sh --target all --force`

**Done when:** EXECUTOR-CORE carries the Stuck protocol and the ❌ rule, both
mode files reference it, both suites green, deployed; the pressure run shows
stop-and-reassess instead of a fourth patch.

**Notes:** Content-contract TDD — 13 anchors red-first ("missing: ## Stuck
protocol"), then EXECUTOR-CORE (new §Stuck protocol between the shared loop
steps and Test policy + the ❌ rule) and one-line refs in TDD §4 / IDD §3 to
green. Pressure run (simulated, fresh read of the protocol with 3 failed
attempts on one failure): the tempting fourth moves — sleep, widened
assertion, skipped test — are named banned moves needing devplan
justification, so the protocol forces writing what the attempts collectively
prove (the Approach's in-process-worker assumption is false), re-reading the
Approach, and revising the approach/devplan — stop-and-reassess, not a fourth
patch. The protocol also fired for real mid-milestone: three same-class anchor
failures (phrases wrapping across lines vs line-based `grep -qF`) → named the
class and fixed `contains_flat` to whitespace-squeezing instead of a third
spot-patch. Suites green (content + 24/24 install); deployed to all three
targets, `--check` OK.

### M41: Completion gates — evidence before claims, spec fidelity before commit ✅

**Why:** "Verify Done when" says *what* to verify but not what counts as
verification: a stale test run, a subagent's bare "done", or "should work now"
can close a milestone today. And no step checks that the implementation didn't
drift beyond the milestone contract — unrequested extras ship silently.
Superpowers' verification-before-completion ("evidence before claims") and the
spec-compliance verdict of its subagent-driven development close both holes.

**Approach:** In `EXECUTOR-CORE.md`: (1) extend "Verify Done when" with
evidence rules — a completion claim (tests green, Done-when met) requires a
command run in this session with its output and exit code actually read;
cached, remembered, or partial output doesn't count; hedged phrasing
("should", "probably", "seems to") in a would-be claim means it is not
verified — run the command instead; a subagent's success report counts only
when it carries the command and output. (2) Extend "Update the devplan"
(before the bookkeeping gate) with a two-verdict self-check: **spec** —
re-read the milestone's Tasks and Done-when: everything implemented, nothing
implemented beyond the contract (extras: delete via ladder rung 1, or record
in the devplan when genuinely needed); **quality** — simplify pass ran, all
applicable tests green. (3) One ❌ Common rule against unverified claims.
Content anchors in `tests/test_content.sh`.

**Tasks:**
- [x] EXECUTOR-CORE.md: evidence rules in "Verify Done when" (fresh command, output read, hedge-wording = not verified, subagent reports need command+output)
- [x] EXECUTOR-CORE.md: two-verdict self-check (spec fidelity + quality) in "Update the devplan"
- [x] EXECUTOR-CORE.md: ❌ Common rule (never claim completion on stale or unread output)
- [x] tests/test_content.sh: M41 anchors (red → green)
- [x] Run test_content.sh + test_install.sh (green)
- [x] Commit & push
- [x] Deploy: `./install.sh --target all --force`

**Done when:** Both sections carry the new gates and the ❌ rule exists; both
suites green; deployed.

**Notes:** Content-contract TDD — 8 anchors red-first ("missing: Evidence
before claims"), then three EXECUTOR-CORE edits to green: "Evidence before
claims" bullet in Verify "Done when", "Two-verdict self-check" (spec +
quality) opening "Update the devplan" ahead of the bookkeeping gate, and the
❌ stale/unread-output rule in Common rules. Done-when verified by grep (all
three land in the intended sections) + green suites (content + 24/24 install);
deployed to all three targets, `--check` OK.

### M42: DESIGN validation — placeholder scan, requirement coverage, interface consistency ✅

**Why:** Phase 5 checks form and coherence but misses planning's classic
failure modes: vague tasks ("handle errors") that defer decisions to
execution, requirements silently covered by no milestone, and later milestones
consuming interfaces no earlier milestone produces. Large-plan proposals also
land as one monolithic blob that is hard to review. Superpowers' writing-plans
self-review (spec coverage, placeholder scan, signature consistency) and its
chunked design presentation fill these gaps.

**Approach:** In `DESIGN.md` Phase 5 add three validation checks:
**placeholder scan** — no task may defer a decision the plan should make
("handle errors" without which errors, "improve X" without the observable
outcome); **requirement coverage** — map each requirement from the request and
Objective to the milestone implementing it; uncovered → add a milestone or
record under Out of scope; **interface consistency** — when a later milestone
consumes something an earlier one produces (module, endpoint, schema, CLI),
the producing milestone's Approach names it, and names/contracts match across
milestones. In Phase 3, for large plans (6+ milestones): present the skeleton
first (Objective, Approach, Risks, phase list), get a nod, then milestone
detail in batches. Content anchors in `tests/test_content.sh`.

**Tasks:**
- [x] DESIGN.md Phase 5: placeholder scan, requirement-coverage map, interface-consistency check
- [x] DESIGN.md Phase 3: staged proposal for 6+ milestone plans
- [x] tests/test_content.sh: M42 anchors (red → green)
- [x] Test: behavioral — validating a sample plan seeded with a "handle errors" task flags it
- [x] Run test_content.sh + test_install.sh (green)
- [x] Commit & push
- [x] Deploy: `./install.sh --target all --force`

**Done when:** Phase 5 lists the three checks, Phase 3 carries the staged
proposal rule, the seeded placeholder is flagged, both suites green, deployed.

**Notes:** Content-contract TDD — 10 anchors red-first ("missing: Placeholder
scan"), then two DESIGN.md edits to green: Phase 5 gained the three named
checks (between Structure-and-coherence and State coverage), Phase 3 the
skeleton-first / batched-detail rule for 6+ milestone plans. Behavioral test
run against a scratch 2-milestone sample plan (scratchpad, not committed)
seeded with a bare "Handle errors" task: the Placeholder scan flagged it
(defers which-errors + observable outcome; rewrite prescribed), Requirement
coverage showed the Objective's "validated" requirement mapped only to that
vague task, and Interface consistency caught M2 consuming unnamed "parser
output" where M1 produces `ContactRow`. Suites green (content + 24/24
install); deployed to all three targets, `--check` OK.

## Follow-up — Review findings (2026-07-03)

Defects found by the cross-skill review of 2026-07-03 (forge-flow,
tech-audit, uxui-audit). M12–M15 heading markers were reconciled the same
day (work verifiably shipped in `0975c5f`, `4bf6cb1`, `4f9d33d`, `875f26b`).

### M43: Align debt registry to `.tech-audit/` — restore the ponytail→audit bridge ✅

**Why:** tech-audit renamed its per-project dir to `.tech-audit/`
(commit `3563276` in its repo): its D01 now reads `.tech-audit/debt.tsv`
and its pytest pins that path. This skill still writes
`.code-audit/debt.tsv`, so debt registered by the simplify pass is
invisible to the audit's D01 suppression — the cross-skill bridge is
silently dead. Closes the seam tracked as tech-audit M21.

**Approach:** Rename the two payload sites — EXECUTOR-CORE.md "Register
intentional debt" and the completion-recap debt line — from
`.code-audit/debt.tsv` to `.tech-audit/debt.tsv`; update the pinned anchor
in `tests/test_content.sh` (red → green). DEVPLAN history mentioning
`.code-audit` stays untouched (it is history).

**Tasks:**
- [x] EXECUTOR-CORE.md: `.code-audit/debt.tsv` → `.tech-audit/debt.tsv` (debt-registration section + completion recap)
- [x] tests/test_content.sh: update the `.code-audit` anchor (red → green)
- [x] Run test_content.sh + test_install.sh (green)
- [x] Commit & push
- [x] Deploy: `./install.sh --target all --force`

**Done when:** `grep -r ".code-audit" forge-flow/ tests/` returns nothing;
both suites green; deployed; tech-audit M21 can close by verifying D01
reads what this skill writes.

**Notes:** Content-contract TDD — flipped the pinned anchor to
`.tech-audit/debt.tsv` first (red), then renamed the two payload sites
(debt-registration section + completion-recap line) to green. No negative
guard for the old literal: the Done-when grep must return nothing across
`tests/` too, so the test itself cannot carry the string. Done-when verified:
`grep -r ".code-audit" forge-flow/ tests/` exits 1 (no matches); suites green
(content + 24/24 install); deployed to all three targets, `--check` OK.
DEVPLAN history mentions of `.code-audit` left untouched (history).

### M44: One ladder, one name — fix DESIGN's stale rung list and unify naming ✅

**Why:** DESIGN.md's essentiality checkpoint lists five rungs ending in
"smaller-custom" — a rung that doesn't exist in the canonical 7-rung ladder
in EXECUTOR-CORE.md — and `tests/test_content.sh:46` pins the stale
wording, so the contradiction is test-protected. The ladder also goes by
four names across the payload ("Simplify step", "simplification ladder",
"essentiality ladder", "7-rung ladder"): resolvable today (only one ladder
exists) but fragile. Two README nits from the same review ride along.

**Approach:** In DESIGN.md Phase 3, replace the parenthetical with the real
sequence (delete → stdlib → native → existing-dep → inline → reduce →
compress-comments). Canonical name: **simplify ladder** (of the
EXECUTOR-CORE "Simplify step" section); align DESIGN.md Phase 5 and both
READMEs' "essentiality ladder" wording to cite it so every reference
resolves verbatim. Root README: neutral devplan-path example
(`devplan/v0.3.md`, not `forge-flow/v0.3.md` which collides with the
payload dir). Payload README: fix the mid-sentence "Conceptual prior art"
capitalization. Update the pinned test anchors in the same pass
(red → green).

**Tasks:**
- [x] DESIGN.md: essentiality-checkpoint parenthetical → the real 7-rung simplify ladder
- [x] Unify ladder naming across DESIGN.md, TDD.md, IDD.md, READMEs ("simplify ladder" / "Simplify step")
- [x] Root README: `devplan/v0.3.md` example; payload README: fix "Conceptual prior art" capitalization
- [x] tests/test_content.sh: update pinned anchors — `smaller-custom`, prior-art phrase (red → green)
- [x] Run test_content.sh + test_install.sh (green)
- [x] Commit & push
- [x] Deploy: `./install.sh --target all --force`

**Done when:** DESIGN's rung list matches EXECUTOR-CORE's ladder 1:1; one
canonical ladder name resolves from every reference; both README nits
fixed; both suites green; deployed.

**Notes:** Content-contract TDD — pinned anchors updated first (red on
"DESIGN.md missing: simplify ladder"): dropped `smaller-custom`, replaced with
the full 7-rung sequence anchor, split the prior-art loop (root keeps
"Conceptual" as an em-dash fragment; payload's mid-sentence use is now
lowercase, the flagged nit), added a stale-name negative guard ("essentiality
ladder" / "simplification ladder" banned from payload + root README) and a
`forge-flow/v0.3.md` collision guard. Then nine edits to green: DESIGN Phase 3
parenthetical → delete → stdlib → native → existing-dep → inline → reduce →
compress-comments, DESIGN Phase 5 + both READMEs cite "simplify ladder",
TDD/IDD say "7-rung simplify ladder", root README path example →
`devplan/v0.3.md`. Done-when verified by grep (stale-name grep exits 1; rung
shorthand identical to TDD/IDD's citation of the EXECUTOR-CORE ladder); suites
green (content + 24/24 install); deployed to all three targets, `--check` OK.

---

## Follow-up — Lifecycle state marker (2026-07-15)

### M45: In-progress milestone marker — a third devplan state ✅

**Why:** The executor blinds the *done* side (M33/M35: verified, committed
gate) but nothing marks the *start*. A finished task with an unticked box is
invisible — it looks identical to a not-yet-started one — so a missed
close-out drifts silently, and resume detection has to *infer* mid-flight
state from partial `[x]` boxes and stray diffs. A third state fixes both: it
moves the mandatory devplan touch to the highest-adherence moment (the step-1
announce, when the agent is already reading the plan), turns "done" into a
cheap `🔄`→`✅` flip, and — crucially — converts silent drift into a *visible*
one, since a dangling `🔄` next to finished code is an anomaly any later
glance catches.

**Approach:** Add a `## Milestone state markers` section to the shared
`EXECUTOR-CORE.md` defining three states — not-started (`- [ ]`), in-progress
(`🔄` heading / `- [~]` task), done (`✅` / `- [x]`) — and stating that `🔄`
is a working-tree signal that becomes `✅` inside the milestone commit (not a
separate commit), so an interrupted run is unambiguously resumable. Wire it
into the two touchpoints already in the loop: Preflight resume-detection keys
off `🔄`/`- [~]` as the unambiguous signal; the "Update the devplan" done-step
flips `🔄`→`✅` and `- [~]`→`- [x]` and forbids either surviving on a closed
milestone; the verify-bookkeeping gate extends to in-progress tasks without
disturbing M33's pinned phrase. Add a one-line "mark in-progress" bullet to
`TDD.md` and `IDD.md` step 1 (shared behavior, referenced from the mode
files). Content-contract anchors in `tests/test_content.sh`; deploy to all
targets. TDD: anchors red first, then content green.

**Tasks:**
- [x] `tests/test_content.sh`: add M45 anchors (section, `🔄`/`- [~]`, resume signal, done-flip, both mode step-1) — red first
- [x] `EXECUTOR-CORE.md`: new `## Milestone state markers` section (three states + working-tree/resume note)
- [x] `EXECUTOR-CORE.md`: Preflight resume-detection keys off `🔄`/`- [~]`
- [x] `EXECUTOR-CORE.md`: done-step flips `🔄`→`✅` / `- [~]`→`- [x]`; verify-bookkeeping extended (M33 phrase preserved)
- [x] `TDD.md` + `IDD.md` step 1: "mark the milestone in progress" bullet
- [x] Run `tests/test_content.sh` + `tests/test_install.sh` — green
- [x] Deploy `./install.sh --target all --force`; `--check` clean
- [x] Global `~/.claude/CLAUDE.md`: symmetric lifecycle gate (out-of-repo, tracked here for the record)

**Done when:** EXECUTOR-CORE documents the three-state marker with `🔄`/`- [~]`,
the done-step swaps `🔄`→`✅`, preflight resumes off `🔄`, both mode step-1s
mark in-progress, both suites green, deployed; and the global CLAUDE.md carries
the symmetric gate.

**Notes:** Executed TDD by hand this session (not via the executor). Content
anchors added to `tests/test_content.sh` and confirmed red ("EXECUTOR-CORE.md
missing: ## Milestone state markers") before the content landed; one anchor
started with `-` and tripped grep's option parser — fixed by wrapping it in
backticks (`` `- [~]` ``), matching how the marker appears in prose. M33's
pinned phrase ("no unchecked task may remain for the milestone being closed")
kept verbatim as a contiguous substring so its test still passes. Done-when
verified: `tests/test_content.sh` green ("content contract passed") and
`tests/test_install.sh` green (24/24). This milestone dogfooded the new marker —
it carried `🔄` while in flight. The global `~/.claude/CLAUDE.md` gate is
out-of-repo (not in this commit); tracked here for the record.

---

## Follow-up — Devplan essentiality (2026-08-13)

Measured across four production devplans in one workspace: they average 382,
567, 506 and 470 words per milestone. Closed milestones weigh 2.4–4.3× their
still-pending neighbours (932 vs 386 in one plan, 650 vs 152 in another), and
35% of the largest plan's words sit inside already-ticked task boxes. That
write-back duplicates the commit it shipped beside — one repo's last 40 commit
bodies average ~275 words telling the same story.
Three causes, one milestone each: no measured budget at design time (M46), an
unbounded write-back at execution time (M47), closed history kept at full weight
forever (M48).

### M46: A milestone has a size, and Phase 5 measures it ✅

**Why:** `DESIGN.md` already says "Why: 1-2 sentences" and "Approach: 2-4
sentences", but Phase 5 validates form, coherence, placeholders and coverage —
never length. A rule no step measures does not hold, and the plans show it.

**Approach:** Add a written budget to the milestone format (≤200 words total,
one-line tasks of ≤20 words with no sub-paragraphs, one-sentence Done-when) plus
an anti-restatement rule: Why ≠ title, Approach ≠ Why, Done-when ≠ task list.
Add a **Length check** to Phase 5 that splits or cuts an over-budget milestone,
and name where the overflow goes — a second milestone, or the code. Anchors in
`tests/test_content.sh`, red first.

**Tasks:**
- [x] `tests/test_content.sh`: M46 anchors — red first
- [x] `DESIGN.md`: budget + anti-restatement rules in the milestone format
- [x] `DESIGN.md`: Phase 5 length check with the overflow routing
- [x] Run both suites; deploy `./install.sh --target all --force`

**Done when:** `DESIGN.md` states a per-milestone word budget, Phase 5 checks it,
both suites green, deployed.

**Deviations:** budget stated as "≤200 words **when written**", so the executor's
Deviations block (M47) sits on top rather than inside it.

### M47: Bound what execution writes back, and name where the rest goes ✅

**Why:** `EXECUTOR-CORE.md`'s update step asks for deviations, decisions and
verification notes with no limit and no destination, so the executor retells the
milestone inside the plan — 35% of one production devplan — while the commit body
beside it already carries the same account.

**Approach:** Replace the open-ended note with a bounded `**Deviations:**` block:
≤5 lines, written only when execution diverged from the plan, since a run that
followed it has the ticks as its record. Forbid prose under a ticked task — a box
is one line, and a discovered fact becomes a new task or a Deviations line. Add a
routing table: design rationale → code comment or docs, what-happened → commit
body, residual work → new milestone, measured ceiling → `ponytail:` +
`.tech-audit/debt.tsv`. M33's pinned bookkeeping phrases stay verbatim.

**Tasks:**
- [x] `tests/test_content.sh`: M47 anchors — red first
- [x] `EXECUTOR-CORE.md`: bounded Deviations block replaces the open-ended note
- [x] `EXECUTOR-CORE.md`: one-line task rule + routing table
- [x] Run both suites; deploy

**Done when:** the update-devplan step caps the write-back at a 5-line Deviations
block, forbids prose in ticked boxes, routes the rest, and both suites are green.

**Deviations:** `TDD.md`/`IDD.md` step-8 carried the same open-ended phrasing
("note deviations and decisions") and were aligned too; a stale-phrase guard
pins it.

### M48: Closed milestones compress on archive ✅

**Why:** completed milestones are immutable and stay at full weight forever;
one archived devplan reached 1.3 MB across 15,710 lines that nothing
reads, duplicating the commits that already carry it.

**Approach:** Add an **Archive** rule to `DESIGN.md`'s version management — when
milestones move to a completed file, each compresses to one line
(`MNN | title | date | sha`), the sha being the pointer to the detail git already
holds. Archiving stays the user's explicit decision, matching the existing rule
on closing versions, and the executor never archives mid-run.

**Tasks:**
- [x] `tests/test_content.sh`: M48 anchors — red first
- [x] `DESIGN.md`: archive-compression rule under Version management
- [x] `EXECUTOR-CORE.md`: the executor never archives (one line)
- [x] Run both suites; deploy

**Done when:** `DESIGN.md` documents one-line archive compression with the sha as
the pointer to detail, the executor is barred from archiving, both suites green,
deployed.

**Deviations:** a milestone with no commit keeps its Done-when line too —
otherwise nothing records what it delivered.

---

## Follow-up — First application to a production plan (2026-08-13)

### M49: Four gaps the first real application of M45-M48 found ✅

**Why:** M45-M48 were applied to two open production devplans — 44,715 words
to 28,100, 62 ticked boxes collapsed, and 22 milestones no guard could see
promoted out of `###`. Four rules did not survive contact: a measurement
motivating unstarted work has no destination in either routing list; one `sha`
cannot address a milestone that closed across three repos; Phase 5's length check
drops the "when written" qualification M46 states, so it reds on a milestone that
is legitimately mostly shipped; and "never prose under a task box" reads as
covering an acceptance gate, where the prose under a tick is the evidence the
check passed and half of them have no commit.

**Approach:** Each lands as a paragraph where the rule already lives — the routing
list in DESIGN's budget, the Archive format, the Phase 5 length check, and
EXECUTOR-CORE's write-back bullet plus one routing-table row. No new sections: a
fifth place to look is what M44 was about.

**Tasks:**
- [x] `tests/test_content.sh`: M49 anchors — red first
- [x] `DESIGN.md`: the pre-work measurement's destination, in the budget's routing list
- [x] `DESIGN.md`: one sha per repo in Archive, and "as written" on the Phase 5 length check
- [x] `EXECUTOR-CORE.md`: the acceptance-gate exception and the routing-table row
- [x] Run both suites; deploy with `./install.sh --force`

**Done when:** all four are pinned by content anchors, both suites green, deployed.

**Deviations:** a fifth change was proposed and rejected on inspection — an
exemption from the budget for a milestone whose product IS a decision. The
existing routing already covers it (`docs/`), so the budget paragraph gained a
warning against the exemption instead of the exemption.

---

### M50: What a comment carries, in code and in tests ✅

**Why:** Rung 7 filters comments by "keeps the why", and the narrative of an
incident passes that filter — it is literally a why. Measured on a production
ops repo: one 3048-line shell tool is 40% comment lines (1233 of them), with a
block of 65 consecutive comment lines above a single line of code, written by
four milestones each appending its own episode below the last. Across that
workspace, 41 comments carry a past date or milestone ID that `git blame`
already answers, and 659 carry markdown or emoji. The skill also says nothing
about comments in tests, where the rule differs: the test name carries the why,
so a comment restating it is the name in the wrong place.

**Approach:** one `## Comments` section in `EXECUTOR-CORE.md`, placed between
the simplify ladder and the `ponytail:` convention that is its carve-out — both
execution modes inherit it from the shared core. Rung 7 points at it instead of
restating its criteria, and Test policy cross-references the test subsection. No
new file: a seventh place to look is what M44 was about.

**Tasks:**
- [x] `tests/test_content.sh`: M50 anchors — red first
- [x] `EXECUTOR-CORE.md`: `## Comments` — what a comment states; the three kinds
      of content that belong in git (past date/incident, milestone or ticket ID,
      markdown or emoji in an inline comment) with the two carve-outs (a forward
      deadline stays, rendered doc comments keep their markup); revise-never-append;
      no slogans; length as a routing signal; the 12-line → 3-line worked example
- [x] `EXECUTOR-CORE.md`: `### Comments in tests` — the name carries the why;
      the three things a name cannot hold; the never-list (AAA labels, restated
      assertion, the story of the bug)
- [x] `EXECUTOR-CORE.md`: rung 7 points at the section; Test policy cross-references
      it; the file-header section list names it
- [x] `forge-flow/README.md`: the `EXECUTOR-CORE.md` contents line names comment rules
- [x] Run both suites; deploy with `./install.sh --force`
- [x] Commit & push

**Done when:** `bash tests/test_content.sh` and `bash tests/test_install.sh` are
green with the M50 anchors, and applying the section's own rules by hand to the
measured 12-line block yields the 3-line form the section shows.

---

### M51: forge-flow's own comments under M50, and the carve-outs the pass found ✅

**Why:** M50 was written from a measurement of someone else's code. Applied to
this repo it hits three cases it does not cover: a milestone ID that is a join
key to `DEVPLAN.md` in the same repo (the `# ---- MNN: subject ----` blocks in
`tests/test_content.sh`), an emoji that is the literal value under test
(`# Matching ❌ Common rule`), and — the finding worth the pass — a comment
paraphrasing an assertion whose argument is already a verbatim quote of the
document under test, which restates by construction. Seven such comments are in
`test_content.sh` today.

**Approach:** delete the seven, then add the two carve-outs and the doc-anchor
rule to `## Comments` so the next pass does not re-flag what this one kept.

**Tasks:**
- [x] `tests/test_content.sh`: delete the seven comments that restate the
      assertion below them; keep the group labels, the parity notes, and the
      two discriminators that distinguish near-identical anchors
- [x] `EXECUTOR-CORE.md` `## Comments`: two carve-outs — an ID that is a join
      key to a document in the same repo, and a literal being quoted — plus the
      doc-anchor rule that a comment paraphrasing a quoted assertion is a
      restatement
- [x] `tests/test_content.sh`: M51 anchors
- [x] Run both suites; deploy with `./install.sh --force`; commit & push

**Done when:** both suites green, no comment in this repo's shell code restates
the line below it, and the section names the three cases the pass found.

---

### M52: A comment check the executor runs, and one scaffold generates ✅

**Why:** M50's three bans are greppable, which is the only reason they are
enforceable — but nothing runs the grep. Left to reading, the rule holds until
the first long session. A repo-wide check is unusable (it reds on every legacy
file the day it lands), so both checks scope to what changed.

**Approach:** the executor's simplify step gains the grep over the files the
milestone touched, with the carve-outs stated as judgement not exceptions to
automate. `scaffold` generates the CI-side equivalent scoped to the merge-base
diff, in the tier idiom the runner already uses (skip-with-reason, exit code).

**Tasks:**
- [x] `EXECUTOR-CORE.md` rung 7: the grep over the milestone's touched files,
      and the rule that hits are candidates a human judgement clears
- [x] `SCAFFOLD.md` Phase 2: a `comments` check in the generated runner, scoped
      to the merge-base diff, skipping with reason outside a git repo or with no
      changed files
- [x] `SCAFFOLD.md` Done when: the check is part of the generated spine
- [x] `tests/test_content.sh`: M52 anchors
- [x] Run both suites; deploy with `./install.sh --force`; commit & push

**Done when:** both suites green, the grep is runnable as written, and scaffold's
contract names the diff-scoped check.

**Deviations:** the grep lives in a `### Running the check` subsection of
`## Comments` rather than inside ladder rung 7, which already points at that
section — a code block does not fit a one-line rung. Run verbatim against this
milestone's own files it returned one hit, the quoted-literal carve-out, which
is the evidence for "candidate, not verdict".

---

### M53: Explicit paths do not bound a commit — the index does ✅

**Why:** "Stage ONLY the files touched by this milestone (explicit paths — never
`git add -A`)" is necessary and not sufficient: a bare `git commit -m` after an
explicit `git add` commits the whole INDEX, so anything the user had staged
before the run ships too. Measured 2026-08-14 across a 33-repo compliance pass —
an executing agent followed the staging rule exactly, and its first commit
carried a file rename the user had staged and not finished.

**Approach:** two additions where the rules already live. `Commit & push` gains
the pathspec-scoped commit form and the recovery when the check catches a
foreign file. Preflight gains one line: record the dirty set, so the close-out
has something to compare against.

**Tasks:**
- [x] `tests/test_content.sh`: M53 anchors — red first
- [x] `EXECUTOR-CORE.md` `### Commit & push`: `git commit <paths>` bounds the
      commit where `git add` does not; the existing `git show --stat HEAD` check
      is what catches a foreign file; `git reset --soft HEAD~1` restores the
      index intact when it does and nothing is pushed yet
- [x] `EXECUTOR-CORE.md` Preflight: record the dirty set including the
      staged/unstaged split, and verify it unchanged before reporting done
- [x] Run both suites; deploy with `./install.sh --force`; commit & push

**Done when:** both suites green, and the commit section states the pathspec form
as the rule rather than the `git add` form alone.

---

### M54: three of the four places a comment lives were invisible to the check ✅

**Why:** M52's pattern reaches inline comments only, and its ID branch requires
two characters before the first hyphen. Measured 2026-08-14 across a seven-repo
workspace applying M50 for the first time: **1,389 of 2,387 hits sat where it
could not look** — doc-comment bodies, whose continuation line starts with an
asterisk; Python docstrings, which carry no line prefix at all; and framework
banner blocks drawn with pipes. Separately about 100 distinct IDs of the shape
`M-PERF-1` never matched, and that was the workspace's commonest milestone
shape. Three of the four gaps were reported independently by different agents
running the documented pattern against real code, which is the evidence that
reading for them does not work.

**Approach:** the convention already says a doc comment keeps its markup. It
never said the date and ID bans stop there, and they must not: a reader of a
doc block can resolve a ticket ID no better than anyone else. One pattern per
surface, with markup banned on the inline surface alone. The ID branch widens
to one character and instead requires a **second alphabetic segment**, which
drops external identifiers — a standard number, a CVE — in the same change.
Vendored trees are excluded outright: an upstream licence banner is not a
comment this project can revise, and the next build overwrites the edit.

**Tasks:**
- [x] `tests/test_content.sh`: M54 anchors — red first, proven against the previous revision
- [x] ID branch: one leading character, a second alphabetic segment required
- [x] Doc-comment surface — continuation lines, one-line blocks, pipe banners; date and ID only
- [x] Python docstring surface, read with `ast` because no prefix marks one
- [x] Vendored and generated trees excluded from both the executor's run and the generated check
- [x] `SCAFFOLD.md` Phase 2 generates the same four surfaces, and names the push-to-default case where a merge-base diff is empty by construction
- [x] Run both suites; deploy with `./install.sh --force`; commit & push

**Done when:** both suites green, and the documented block finds a ticket ID
inside a doc comment and a Python docstring while leaving an accessibility
standard alone.

---

### M55: what a test costs is decided when it is written, and nothing said so ✅

**Why:** Measured 2026-08-15 while shortening an established suite: **180s of a
415s tier was one test**, which stubbed its container runtime but not the 120s
readiness poll on the same path — a stub never satisfies one. Two more resolved
a bare hostname at five seconds each; one parsed 550KB of PDF to assert a list
emptied.

**Approach:** The Test policy has only ever carried coverage, never cost. It
gains one rule per cause above, and the green step checks the budget in the same
pass rather than beside it.

**Tasks:**
- [x] `tests/test_content.sh`: M55 anchors, red first
- [x] `EXECUTOR-CORE.md` Test policy: one write-time cost rule per cause, each with its measurement
- [x] `TDD.md` + `IDD.md`: the green step includes the per-test budget
- [x] Both suites; `./install.sh --force`; commit & push

**Done when:** each measured cause has a rule in the payload, and a test over
budget is fixed before the commit that adds it.

---

### M56: a runner that reports tier totals cannot show which test is the slow one ✅

**Why:** The generated runner reports a tier total and nothing per test, so one
test holding 43% of a tier looks exactly like a tier that is evenly slow.
Measured 2026-08-15: that state held until the files were timed by hand, one
process at a time.

**Approach:** The runner times each test and prints the five slowest on every
run, red over a generous ceiling. Printing unconditionally is what catches drift
below the ceiling — a reporter that speaks only when the ceiling breaks says
nothing until it already has.

**Tasks:**
- [x] `tests/test_content.sh`: M56 anchors, red first
- [x] `SCAFFOLD.md`: runner times each test, prints five slowest, reds over a ceiling
- [x] Ceiling generous enough that a legitimately slow test does not red
- [x] Reporter proven against the format the runner emits, not its documented one
- [x] Both suites; `./install.sh --force`; commit & push

**Done when:** a generated runner names its five slowest tests and fails on one
over the ceiling.

---

### M57: five guards written in one session could not fail, and reading caught none ✅

**Why:** Measured 2026-08-15: a slow-test reporter parsed the wrong one of its
runner's two output formats and so reported nothing; a guard counted a token
that also appears elsewhere in its own file and passed with half the code
deleted; a test asserted the wrong consequence of a regex and stayed green
against both spellings. Each was found by breaking the code, none by re-reading.

**Approach:** Red-before-green is unavailable for a test written against code
that already exists — most guards, and every regression test. The green step
therefore requires each new test to have been proven able to fail: break the
code, confirm red, restore.

**Tasks:**
- [x] `tests/test_content.sh`: M57 anchors, red first
- [x] `EXECUTOR-CORE.md` Test policy: the red-proof, and when red-before-green cannot apply
- [x] `TDD.md` + `IDD.md`: the green step names the red-proof
- [x] Both suites; `./install.sh --force`; commit & push

**Done when:** the payload requires a red-proof for every test written after the
code it guards.

---

### M58: an assertion can pin the wrong thing and stay green while the code is wrong ✅

**Why:** Measured 2026-08-15: six tests went red on correct code because each
pinned the spelling of a value being passed rather than the value arriving, and
one stayed green for exactly as long as the code was wrong, because it matched a
phrase the code never emits. Four more promised a usage hint nothing checked,
and an any-request assertion passed with the defect inside it.

**Approach:** Three rules, one per cause, in the Test policy beside the
red-proof. They are judgement rather than mechanism, so they are written as what
to assert and not as a step the executor performs.

**Tasks:**
- [x] `tests/test_content.sh`: M58 anchors, red first
- [x] `EXECUTOR-CORE.md`: assert the value that arrives, not the spelling of its passing
- [x] `EXECUTOR-CORE.md`: assert which failure, not that one happened
- [x] `EXECUTOR-CORE.md`: a count wherever one is knowable — "any match" and `>=` survive a swap
- [x] Both suites; `./install.sh --force`; commit & push

**Done when:** each of the three rules carries the measurement that produced it.

---

## Follow-up — Closed milestones leave the active devplan (2026-08-19)

Measured here: `DEVPLAN.md` is 126,701 bytes and every milestone in it is closed,
yet it is read in full each session to act on one pending milestone. The weight
tracks the project's age rather than its remaining work, and the production plan
M48 measured reached 1.3 MB. Three milestones: the layout and who reads what
(M60), the close-out that maintains it (M61), the migration offered and then run
on this repo (M62). Residual risk, accepted: an executor that no longer reads the
whole plan can miss a convention an earlier milestone established without naming
it — preflight's commit-convention read and the project's instruction files are
what remain.

### M60: The devplan is two files, and the executor reads only the active one ✅

**Why:** the active plan is read whole every session to act on one pending
milestone, and on this repo every milestone in it is closed.

**Approach:** an optional two-file layout in `DESIGN.md` — the active file holds
pending and in-progress milestones, a completed file holds closed ones, named by
derivation (`DEVPLAN.md` → `DEVPLAN-COMPLETED.md`). The executor reads the active
file and opens the completed one only when an Approach names an earlier milestone
ID; DESIGN reads both. Single-file projects stay valid.

**Tasks:**
- [x] `tests/test_content.sh`: M60 anchors — red first
- [x] `DESIGN.md`: two-file layout and name derivation under File location
- [x] `DESIGN.md`: discovery takes the last milestone ID from the completed file
- [x] `DESIGN.md`: version close opens a new pair, the old active file being empty
- [x] `EXECUTOR-CORE.md`, `TDD.md`, `IDD.md`: executor reads the active file, zooms on named IDs
- [x] `DESIGN.md`: Archive separates lossless relocation from user-decided compression
- [x] `forge-flow/README.md`: narrow the "no specific format is required" promise
- [x] Run both suites; `./install.sh --force`; commit & push

**Done when:** the layout, the numbering source and the executor's read scope are
pinned by anchors, both suites green, deployed.

**Deviations:** `DESIGN.md`'s Archive rule already sent closed milestones to a
completed file in compressed form, so the same file had two formats; a task was
added to split lossless relocation from user-decided compression. The root README
documents the devplan format too and gained the layout in the same pass.

### M61: Closing a milestone moves it, and nothing is lost in the move ✅

**Why:** with two files, closing a milestone stops being a tick and becomes a
delete plus an append. Today the worst bookkeeping failure is an unchecked box; a
botched move leaves a milestone in both files or in neither.

**Approach:** the update step moves the block verbatim after the ticks, never in
the compressed archive form, whose only pointer is a `sha` — seven histories in
this workspace were force-rewritten on 2026-08-14. The gates below follow the
block to where it now lives and check the **heading**, since a bare ID also
appears as a cross-reference.

**Tasks:**
- [x] `tests/test_content.sh`: M61 anchors — red first
- [x] `EXECUTOR-CORE.md`: the move step, and the bookkeeping re-read follows the block
- [x] `EXECUTOR-CORE.md`: heading-resolves-in-exactly-one-file gate
- [x] `EXECUTOR-CORE.md`: commit stages and verifies both files
- [x] `EXECUTOR-CORE.md`: Common rule bans compression mid-run, not relocation
- [x] `EXECUTOR-CORE.md`: preflight detects a milestone left in both files or neither
- [x] Run both suites; `./install.sh --force`; commit & push

**Done when:** a closed milestone's heading resolves in exactly one file, both
files ship in the milestone commit, and the ban is worded against loss rather than
against moving.

**Deviations:** the move now has a written order — append to the completed file,
then remove from the active one — so a run that dies mid-move leaves a recoverable
duplicate instead of nothing. Both gates were exercised on a scratch copy: the
heading gate resolved 1/0, and the bare-ID variant it rejects matched a live
cross-reference in this plan.

### M62: Offer the split, then run it on this repo's own plan ✅

**Why:** forge-flow installs onto other people's plans, and splitting one rewrites
it. Closing a version and archiving are both suggestions the user accepts.

**Approach:** the suggestion joins `DESIGN.md` version management beside Archive,
raised when closed milestones outweigh pending ones and never acted on unasked.
Only milestone blocks move, which keeps the migration mechanical. Then run it
here, where 58 closed milestones and none pending make the first real case, as M49
applied M45-M48 to production plans.

**Tasks:**
- [x] `tests/test_content.sh`: M62 anchors — red first
- [x] `DESIGN.md`: migration suggested under Version management, never performed unasked
- [x] `DESIGN.md`: only milestone blocks move; other sections stay
- [x] Split `DEVPLAN.md` → `DEVPLAN-COMPLETED.md`, milestone blocks verbatim
- [x] Verify every closed heading resolves in exactly one file
- [x] Run both suites; `./install.sh --force`; commit & push

**Done when:** `DESIGN.md` suggests the split without performing it, and this
repo's active devplan holds no closed milestone while every heading still
resolves.

**Deviations:** the split rule as planned moved milestone blocks alone, which
left version and phase headings behind as empty scaffolding and stranded each
version's Out-of-scope list; both now follow their milestones. Measured on this
plan: 131,996 bytes to 7,823 in the active file, 61 headings resolving in exactly
one file, no source line lost.

---

## Follow-up — The READMEs carry the two-file model (2026-08-19)

### M63: Both READMEs explain the two-file plan, and the layout tree matches the repo ✅

**Why:** the root README's layout tree does not contain `DEVPLAN-COMPLETED.md`, so
it describes a structure that no longer exists. Neither README says why a plan is
in two files, what moves at close, or that compression stays separate from
relocation.

**Approach:** correct the tree, then extend `## Devplan format` in both READMEs
with the model a reader needs to adopt the layout: the active file carries the
work queue, the completed file the history, a closed milestone moves verbatim, and
compressing that file is a separate decision the user makes. The `EXECUTOR-CORE.md`
entry under `## Skill files` names the close-out. `DESIGN.md` stays the normative
text.

**Tasks:**
- [x] `tests/test_content.sh`: M63 anchors — red first
- [x] `README.md`: layout tree lists `DEVPLAN-COMPLETED.md`
- [x] `README.md`: Devplan format states the two-file model
- [x] `forge-flow/README.md`: the same model, sized for the payload doc
- [x] `forge-flow/README.md`: Skill files entry names the close-out move
- [x] Run both suites; `./install.sh --force`; commit & push

**Done when:** the layout tree matches the repo root, both READMEs state the
two-file model with relocation and compression named apart, both suites green.

**Deviations:** verifying the tree against `ls` found a second omission — the
repo's `CLAUDE.md` was never listed either — so the tree gained both files rather
than only the one M62 created.

## Follow-up — Bookkeeping checks follow the milestone (2026-08-19)

### M64: Two bookkeeping checks look for a milestone that has moved ✅

**Why:** measured on M63, planned and closed inside one run: the active file ends
byte-identical, so `git show --stat` omits it correctly, while the commit check
calls that a failure and prescribes amending a file with no changes. The
completion sweep looks for closed milestones in the file they have just left.

**Approach:** the commit check verifies the milestone's record is in the commit —
the active file, the completed file, or both — and names the same-run case as
legitimate. The sweep follows the milestone to whichever file now holds it. M33's
pinned phrases stay verbatim, as M47 established.

**Tasks:**
- [x] `tests/test_content.sh`: M64 anchors — red first
- [x] `EXECUTOR-CORE.md`: the commit check accepts an unchanged active file
- [x] `EXECUTOR-CORE.md`: the completion sweep follows the milestone to its file
- [x] Run both suites; `./install.sh --force`; commit & push

**Done when:** the commit check passes on a milestone planned and closed in one
run, the sweep names both files, and M33's phrases are unchanged.

**Deviations:** rewriting the commit check invalidated an M61 anchor pinning the
old wording; realigned in the same pass, red to green. Verified on this milestone
itself, which is the same-run case: `DEVPLAN.md` ends unchanged and the record
ships in the completed file alone.

## Follow-up — The installer reports what it left behind (2026-08-19)

### M65: install.sh names the targets it left behind ✅

**Why:** measured on this machine — `./install.sh --force` wrote the `claude`
target while `codex` and `opencode` kept an older payload, and nothing said so.
The non-interactive default is `claude`, so a scripted or agent-run deploy
updates one of three installations in silence.

**Approach:** after installing, compare every known target directory that exists
against the source, reusing `check_copy`'s `diff -r --exclude=.installed-from`,
and name the ones that differ alongside `--target all --force`. A warning rather
than a failure, since scripted installs must keep working, and `--target all`
leaves nothing differing so it stays silent on its own. Behavioural tests in
`tests/test_install.sh`, which already builds throwaway HOMEs.

**Tasks:**
- [x] `tests/test_install.sh`: a stale sibling target is named — red first
- [x] `tests/test_install.sh`: silence with no sibling, and with `--target all`
- [x] `install.sh`: warn after installing about targets that differ from the source
- [x] Run both suites; `./install.sh --target all --force`; commit & push

**Done when:** installing one target while another holds a different payload names
that target and the all-targets command, and an install with no stale sibling
prints no warning.

**Deviations:** `assert_run` passed its needle to `grep` without `--`, so any
needle starting with a dash was read as an option; fixed, since this milestone's
needle is `--target all --force`. The two silence guards could not be red before
the code existed and were proven able to fail instead. The message says "a
different payload" rather than "older", which is what the comparison actually
shows.

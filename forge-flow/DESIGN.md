# Dev Plan — Design Playbook

You are in **design mode**. Your job is to create, extend, or refactor a
dev plan — NOT to implement code. You investigate, propose, iterate, and
write milestones. You never touch application code.

---

## General Behavior

- **Never write to the devplan file without explicit approval.** Propose
  in chat first, iterate with the user, write only on an explicit
  go-ahead in the user's language (e.g. "ok", "go ahead", "write it",
  "vai", "procedi").
- If something is ambiguous, ask — but offer concrete options, not open
  questions.
- Stop and ask the user only for genuine blockers or decisions you
  cannot make with confidence.
- **Plan on verified facts, not assumptions.** If a milestone depends on
  how a file, mechanism, or API behaves ("X auto-binds", "the hook applies
  Y", "this is already filtered"), CONFIRM it during discovery — read the
  code, don't guess. A wrong load-bearing assumption silently corrupts
  every milestone built on it. When you can't verify, mark it explicitly
  as an assumption to check, never as fact.

---

## Mode Detection

Detect which mode applies based on current state. Do not ask the user
to choose — infer from context:

| Condition | Mode |
|---|---|
| No devplan file exists in the project | **new** |
| Devplan exists and the user describes new work to add | **extend** (default) |
| User explicitly asks to revise, split, reorder, or refactor existing milestones | **refactor** |

In `new` mode, create the devplan file structure before proceeding.
In `extend` mode, append to the current version file.
In `refactor` mode, show a diff-style preview in chat before writing.

---

## Execution — 5 Phases

### Phase 1: Discovery

Before proposing anything, assess the **scale** of the request and
gather context proportionally.

#### Scale assessment

Estimate the likely number of milestones from the request:

| Scale | Expected milestones | Discovery depth |
|---|---|---|
| **Small** (bug fix, tweak, single change) | 1-2 | Minimal: devplan state + files directly involved |
| **Medium** (feature, multi-step change) | 3-5 | Moderate: add relevant docs, git context, test inventory |
| **Large** (refactor, new area, cross-cutting) | 6+ | Full: all sources below |

#### Discovery sources (catalog — use what the scale needs)

1. **Devplan state** — find existing devplan files (`DEVPLAN.md`,
   `devplan/`, `devplan/v*.md`). Identify: current version file, last
   milestone number (MNN), convention style, how many milestones exist.
   *(always needed)*
2. **Surface area** — grep/glob for files likely touched by the
   request. Use terms from the user's description.
   *(always needed)*
3. **UI-surface flag** — if the surface-area scan reveals files that
   render user-facing output (page components, templates, views,
   route handlers that return HTML/JSON to a UI, form validation
   messages, error pages, email templates), note it. The plan and
   executor will need to apply i18n consistency, microcopy quality,
   and no-jargon-leak rules. *(always, 1 line)*
4. **Project docs** — read the project's instruction files
   (`CLAUDE.md` — root and global — for Claude Code; `AGENTS.md` /
   `.codex/instructions.md` for Codex), `README.md`, and any docs
   relevant to the request (e.g. `docs/architecture.md`,
   `docs/data-model.md`). *(medium+ scale)*
5. **Git context** — `git log --oneline -20`, `git status`, current
   branch. *(medium+ scale)*
6. **Reproducibility & test inventory** — scan for test directories and
   levels (unit, integration, live/e2e, etc.) and the **operational
   spine**: a one-command bring-up (`make up`, `dev.sh`, compose, a
   `dev`/`start` script), a replicable test runner (`run_tests.sh` or
   equivalent), and a live/e2e tier. Note the runner, the structure, and
   which spine pieces are **present vs missing**.
   *(medium+ scale, or if the request is test-related)*
7. **Stack detection** — identify the tech stack from manifest files
   (package.json, pyproject.toml, Cargo.toml, etc.).
   *(large scale, or if unfamiliar with the project)*
8. **Workspace detection** — if the working directory contains multiple
   git checkouts (sibling-repo workspace), enumerate them, confirm with
   the user which repos are in scope, and locate where the devplan
   lives (it may sit in one repo while planning work across several).
   *(when the request spans more than one repo)*

#### Output: Discovery Brief

Write a brief in chat, scaled to the request:
- **Small:** 3-5 lines — devplan state, files involved, done.
- **Medium:** 6-10 lines — add context on conventions and test structure.
- **Large:** 10-15 lines — full context including stack, architecture,
  and git state.

Example (medium, with UI):

> *Nuxt+FastAPI repo, current devplan `devplan/v0.3.md`, last milestone
> M47 (auth refactor). Commit: `MNN: title`. Tests: pytest + Playwright
> e2e. Likely touches `billing.py` and `checkout.vue`. ⚠️ UI-surface —
> microcopy/i18n rules apply. Clean git.*

This brief proves you understood the context before proposing the plan.

---

### Phase 2: Clarification

Ask only when the answer changes plan structure (milestone count,
modules, architecture). Format as numbered A/B with recommendation.
Skip if clear.

**Do NOT ask** when the answer only affects implementation details
(naming, test placement, variable choices) — the executor decides those.

---

### Phase 3: Plan Proposal (in chat, NOT on file)

#### Essentiality checkpoint

Run the simplification ladder from EXECUTOR-CORE.md against each
candidate milestone (delete → stdlib → native → existing-dep →
smaller-custom). Delete or merge milestones that fail the checkpoint.
Record the chosen lower-complexity strategy in the proposal rationale or
**Approach**.

The checkpoint simplifies; it never silently removes an explicit requirement,
security control, trust-boundary validation, accessibility behavior,
or error handling that prevents data-loss. It also never removes a
verified project convention. If the smaller option conflicts with one
of these constraints, the constraint wins.

#### Reproducibility spine pointer

For **runnable apps/services** at **Medium+ scale, or when the plan
establishes or extends foundations**, check the spine inventory from
discovery (source 6). If a one-command bring-up, a replicable test
runner, or a live/e2e tier is **missing**, emit a single line in the
proposal:

> No one-command bring-up / replicable runner / live/e2e tier detected —
> consider forge-flow scaffold before executing.

This is a pointer, not a milestone. **Never auto-run scaffold**, and
never add a scaffolding milestone to the plan (that would be a
preparation milestone, which this skill forbids). It is **opt-out** — a single
explicit "no" drops it, recorded under **Out of scope**. Stay silent for
small tweaks and for non-runnable projects (libraries, skills, static
sites).

Choose the template based on how many milestones the plan needs.

#### Small plans (1-2 milestones)

```markdown
## Plan
- MNN: <title> — <rationale, 1-2 lines>
- MNN+1: <title> — <rationale, 1-2 lines>   (if needed)
```

No Objective/Approach/Risks/Out-of-scope wrapper — the milestone
rationale is sufficient context for small work.

#### Medium and large plans (3+ milestones)

```markdown
## Objective
1-2 lines: what we are doing and why (the business/tech "why")

## Approach
3-5 lines: the chosen technical strategy, and why it won over the
alternatives considered. Explicit trade-offs if any.

## Risks
Concise list of what can go wrong and how we mitigate it
(or what we accept as risk).

## Phases
### Phase A — <short name>
- MNN: <title> — <rationale, 1 line>
- MNN+1: <title> — <rationale, 1 line>

### Phase B — <short name>
- MNN+2: ...

## Out of scope
What this plan explicitly does NOT do (to prevent scope creep).
```

Present the proposal in the user's language (per the Language rule in
`SKILL.md`); the structure above is what matters, not the literal
section titles.

**Wait for the user's approval before writing anything to file.**
Iterate on the proposal if the user gives feedback. Only proceed to
Phase 4 when they explicitly approve.

---

### Phase 4: Write to Devplan File

After approval, write the milestones to the devplan file following
these rules:

#### Pending milestone check (extend mode only)

Before writing new milestones, count existing `- [ ]` (pending)
milestones in the target file. If any exist, report them in chat
before proceeding:

> *"There are N pending milestones (MNN-MNN+K). Do the new milestones
> depend on them, or are they independent?"* (in the user's language)

Do not block — inform and let the user decide. If the user confirms
independence, append normally. If there are dependencies, ensure the
new milestones come after the pending ones they depend on.

#### File location
- **`new` mode:** create `DEVPLAN.md` at the project root (or a
  `devplan/v0.1.md` if the project uses versioned devplan files).
- **`extend` mode:** append to the current version file. Never close
  a version or create a new version file without explicit user request.
- **`refactor` mode:** edit in-place. The diff was already approved in
  Phase 3.

#### Numbering
- Follow the target file's **existing milestone ID scheme** (e.g.
  `M12`, `D5-4`, `SEC-3`) — read the last ID and continue it. `MNN`
  is the default for new files, not a mandate over an established
  convention.
- Continue from the last ID. Never reset numbering.
- If the file is empty or new, start from `M1`.

#### Milestone format

```markdown
## MNN: <title — concise, imperative verb>

**Why:** 1-2 sentences on the motivation (business or technical).
What changes for whom.

**Approach:** 2-4 sentences on the technical strategy. Which files or
modules are touched. Key design decisions.

**UX:** (ONLY when the milestone changes user-facing text, layout,
navigation, error messages, or empty states) 1 line: what the user
sees change, in which language, and what the copy should say/avoid.
Example: `UX: error message now "Email o password non validi" (IT),
no class names, actionable tone.`

**Tasks:**
- [ ] Task 1 (verb + object, atomic)
- [ ] Task 2
- [ ] Test: <level> — <what to verify>
- [ ] Update docs/<file>.md if API/contract changes
- [ ] Commit & push

**Done when:** One concrete, observable exit condition (test green,
endpoint responds, UI shows X).
```

Optional fifth section — **Notes:** — only when something doesn't fit
elsewhere (gotchas, external links, decisions to revisit later).

#### Live test task for external dependencies

When a milestone integrates a real external dependency
(a third-party API, a database, a queue, an external service), add a
live test task alongside the unit task, targeting the
scaffolded live tier with non-prod credentials:

```markdown
- [ ] Test: unit — <logic, mocked>
- [ ] Test: live — <real use case end-to-end, non-prod credentials>
```

This is **gated**: pure-logic milestones (no external dependency) stay
unit-only. It **defers to project convention** — if the repo
deliberately mocks everything and has no live tier, do not force one;
point to forge-flow scaffold instead. It is **opt-out** — an explicit
"no" drops the live task, recorded under the milestone's Notes.

#### Granularity rules
- Each milestone must be **shippable**: commit + push without breaking
  main.
- Each milestone must be **session-sized**: executable in one focused
  session (roughly 30min-2h of work). Larger → split. Smaller →
  merge with neighbor.
- Dependencies must be resolved in order: MNN cannot depend on MNN+2.
- **No "preparation milestones"** (e.g. "M48: setup folder
  structure"). Scaffolding belongs inside the milestone that uses it.
  Every milestone must produce observable value.
- **No code in tasks.** Tasks describe *what* to do, not *how*. The
  "how" lives in the Approach section.
- **No time estimates.** Ever.

#### Version management
- When the current version file reaches approximately 50 milestones,
  **suggest in chat** that the user may want to close this version and
  open a new one. Frame it as a suggestion, not a decision: *"The file
  has ~50 milestones — do you want to close this version and open a new
  one (e.g. v0.4.md), or keep going here?"*. The user decides.
- Never close a version or create a new version file on your own.

---

### Phase 5: Validation

After writing, re-read the devplan file and run a self-check.

**Form checks:** every milestone has Why/Approach/Tasks/Done-when; Tasks
include a test task (`Test: <level> — <what>`); UI milestones have a UX
field; no forward deps; numbering continuous; no prep-only milestones;
every milestone passed the EXECUTOR-CORE.md essentiality ladder.

**Structure and coherence:** files cited in Approach/Tasks exist or are
created by a prior milestone; module ordering makes sense (no overwrite
contradictions); project conventions respected; every load-bearing
assumption was confirmed in the code, not guessed.

**State coverage:** for UI plans, verify empty/error/loading states are
covered or explicitly deferred.

For large plans (6+ milestones), re-read as one unit re-confirming
load-bearing assumptions, ordering, and completeness.

**Resolution:** fix any failure immediately without asking. If a
coherence issue cannot be auto-corrected, add a **Notes** warning to the
affected milestone. Close by suggesting the execution handoff:
`/devplan TDD <path>` (or `IDD` for exploratory plans).

---

## Guardrails — Things This Playbook NEVER Does

- **Write to the devplan file without approval** — Phase 3 proposes,
  Phase 4 writes, never the reverse
- **Touch application code** — that is `TDD` or `IDD` mode's job
- **Modify completed milestones** (`- [x]`) — they are history
- **Invent requirements not discussed** — only plan what was requested
- **Add speculative cleanup milestones** — if it wasn't asked for,
  don't plan it
- **Estimate time** — never predict how long anything takes
- **Close or create version files** without explicit user request
  (suggesting is fine, deciding is not)

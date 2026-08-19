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

Run the simplify ladder (EXECUTOR-CORE.md "Simplify step") against each
candidate milestone (delete → stdlib → native → existing-dep → inline →
reduce → compress-comments). Delete or merge milestones that fail the
checkpoint.
Record the chosen lower-complexity strategy in the proposal rationale or
**Approach**.

The checkpoint simplifies; it never silently removes an explicit requirement,
security control, trust-boundary validation, accessibility behavior,
or error handling that prevents data-loss. It also never removes a
verified project convention. If the smaller option conflicts with one
of these constraints, the constraint wins.

#### Operational spine — propose explicitly

For **runnable apps/services** at **Medium+ scale, or when the plan
establishes or extends foundations**, check the spine inventory from
discovery (source 6): a one-command bring-up, a replicable test runner, a
live/e2e tier. When any piece is **missing**, do not bury it in a passive
line — make an **explicit, default-include proposal** the user must accept
or actively opt out of, and **record the decision in the devplan** (a
prerequisite line in the plan header when included, **Out of scope** when
declined). Default is **include**; only an explicit "no"
drops it, recorded under **Out of scope**.

Branch on project state:

- **Greenfield** (building the app from scratch): scaffold cannot run before
  the app exists, so attach the spine to the **first runnable milestone** —
  folded into it, or a `forge-flow scaffold` pass right after. Propose: *"This
  plan stands up a runnable app from scratch; I'll mount the operational spine
  (one-command bring-up + tiered test runner + e2e smoke) on the first runnable
  milestone. Reply 'no spine' to opt out."*
- **Brownfield** (app already runs, spine missing): the app exists, so propose
  running `forge-flow scaffold` **before executing** — *"No one-command bring-up
  / replicable runner / live/e2e tier detected; I'll run forge-flow scaffold
  first. Reply 'no spine' to opt out."*

**Never auto-run scaffold**, and never add a scaffolding milestone to the plan
(a preparation milestone this skill forbids) — the spine rides inside the first
runnable milestone or a scaffold pass, never its own `MNN`. Stay silent for
small tweaks and for non-runnable projects (libraries, skills, static sites).

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

For large plans (6+ milestones), don't land one monolithic blob:
present the skeleton first (Objective, Approach, Risks, phase list with
milestone titles), get a nod, then the milestone detail in batches
(one phase at a time).

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

#### Two files: active and completed

A devplan is one file or two. In the **two-file layout** the active file holds
pending and in-progress milestones only, and a completed file beside it holds the
closed ones, named by derivation from the active file: `DEVPLAN.md` →
`DEVPLAN-COMPLETED.md`, `devplan/v0.3.md` → `devplan/v0.3-completed.md`.

The executor reads the active file, and opens the completed one only when the milestone it is executing names an
earlier milestone ID. Design mode reads both, because discovery needs the last
milestone ID, the milestone count and the convention in use, and all three sit in
the completed file once the active one carries pending work alone.

Measured on one plan: 126,701 bytes of closed milestones, read in full to act on a
milestone whose own text is 200 words.

A single-file devplan stays valid, and every rule in this playbook applies to it
with the active file being the only file.

Adopting the layout is a suggestion, never an act. When a single-file devplan's
closed milestones outweigh its pending ones, suggest the two-file split and wait.
Never split a devplan unasked — it rewrites a file the user owns, and the rule
matches the ones on closing a version and archiving.

The split moves milestone blocks, and a version, phase or follow-up heading moves
with them once every milestone under it is closed, so the completed file keeps the
structure that made the closed work readable. A version's Out-of-scope list moves
with that version. The plan header, the milestone-format section and any
pending-discussion proposals stay in the active file.

#### Numbering
- Follow the target file's **existing milestone ID scheme** (e.g.
  `M12`, `D5-4`, `SEC-3`) — read the last ID and continue it. `MNN`
  is the default for new files, not a mandate over an established
  convention.
- Continue from the last ID. Never reset numbering.
- If the file is empty or new, start from `M1`.
- In a two-file devplan the last milestone ID lives in the completed file — read
  it there, or a design session reuses IDs already assigned.

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

#### Milestone budget

A milestone is **≤200 words** when written. Within it:

- **Why** 1-2 sentences · **Approach** 2-4 sentences · **Done when** one
  sentence.
- **Tasks are one line each**, ≤20 words, with no sub-paragraph underneath. A
  task needing a paragraph to be understood is under-specified (name the
  concrete thing) or is two tasks.
- **Never restate.** The Why does not repeat the title, the Approach does not
  repeat the Why, the Done-when does not re-list the tasks. Restatement is
  where the budget goes first, and it adds no information.

What does not fit is not compressed prose — it is content in the wrong place.
Route it: a **second milestone** (the plan was carrying two), the **code or its
comments** (design rationale belongs next to what it explains), or **`docs/`**
(a contract readers outside this plan need). A devplan carries what the
executor needs to do the work and what a later planner needs to keep planning;
the executor adds at most a bounded Deviations block on top (EXECUTOR-CORE.md
"Update the devplan").

One thing has no destination in that list and needs naming, because it is most
of what a defect milestone is made of: **the measurement that justifies work
nobody has started.** There is no code yet to carry a comment, it is not a
contract for `docs/`, and it is not a Deviation because nothing has executed —
so it stays in the plan. The number goes in the **Why** or the **Approach**, and
only what the executor cannot act without goes in **`Notes:`**. *"27 call sites,
2 of them guarded"* is the Approach; how they were counted is not.

⚠️ **This is not a licence for a milestone whose product IS a decision** — a
policy, a chosen provider, a table of verdicts. That is *"a contract readers
outside this plan need"*, and it goes to `docs/` with the plan carrying the
pointer. The test: once the work is done, will anything outside this file hold
the decision? If the answer is no, the routing was skipped, not exhausted.

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
- In a two-file devplan the active file is already empty when a version closes, so
  closing one opens a new pair rather than moving anything.

#### Archive

Completed milestones are immutable, so a devplan only grows: a production file
measured 1.3 MB across 15,710 lines of closed work that nothing reads. When the
user moves closed milestones to a completed file, **each compresses to one line**:

```
MNN | title | date | sha
```

Everything else — Why, Approach, ticked tasks, Deviations — is dropped, because
the sha is the pointer to the detail and git already stores it in full. A
milestone with no commit keeps its Done-when line as well, since nothing else
records what it delivered.

**In a multi-repo workspace one sha does not resolve**: name one per repo
(`core a1b2c3d · ops 4e5f6a7 · dash 89bcdef`). A milestone routinely closes
across several — measured on one that landed in three — and a bare sha sends the
reader to a history that does not contain it.

With the two-file layout the move and the compression come apart: relocating a
closed milestone to the completed file is lossless, while compressing the
completed file to the one-line form above drops Why, Approach and the ticked
tasks.

Never archive on your own initiative. Like closing a version, it is the user's
decision; suggest it when a completed section outgrows the pending work, and
wait.

---

### Phase 5: Validation

After writing, re-read the devplan file and run a self-check.

**Form checks:** every milestone has Why/Approach/Tasks/Done-when; Tasks
include a test task (`Test: <level> — <what>`); UI milestones have a UX
field; no forward deps; numbering continuous; no prep-only milestones;
every milestone passed the EXECUTOR-CORE.md simplify ladder.

**Structure and coherence:** files cited in Approach/Tasks exist or are
created by a prior milestone; module ordering makes sense (no overwrite
contradictions); project conventions respected; every load-bearing
assumption was confirmed in the code, not guessed.

**Length check:** every milestone is within its 200-word budget, tasks are one
line each, and no section restates another. Over budget → split the milestone or
route the overflow to code, comments, or `docs/`; never ship it as denser prose.
Measure it **as written**: its **ticked task lines are the record of work already
done** and do not count against the budget, so a milestone that is mostly shipped
legitimately runs long while a mostly-pending one does not.

**Placeholder scan:** no task may defer a decision the plan should make
— "handle errors" without naming which errors, "improve X" without the
observable outcome. Rewrite the task with the concrete decision (or
take the open question back to Clarification).

**Requirement coverage:** map each requirement from the request and the
Objective to the milestone implementing it. Uncovered → add a milestone
or record it under Out of scope.

**Interface consistency:** when a later milestone consumes something an
earlier one produces (module, endpoint, schema, CLI), the producing
milestone's Approach names it, and names/contracts match across
milestones.

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

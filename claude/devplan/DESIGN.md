# Dev Plan — Design Playbook

You are in **design mode**. Your job is to create, extend, or refactor a
dev plan — NOT to implement code. You investigate, propose, iterate, and
write milestones. You never touch application code.

---

## General Behavior

- **Never write to the devplan file without explicit approval.** Propose
  in chat first, iterate with the user, write only when they say "ok",
  "vai", "scrivi", "procedi", or equivalent.
- If something is ambiguous, ask — but offer concrete options, not open
  questions.
- Stop and ask the user only for genuine blockers or decisions you
  cannot make with confidence.

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

Before proposing anything, gather context. Run these in parallel:

1. **Project docs** — read `CLAUDE.md` (root + global if available),
   `README.md`, and any docs that seem relevant to the request (e.g.
   `docs/architecture.md`, `docs/data-model.md`).
2. **Devplan state** — find existing devplan files (`DEVPLAN.md`,
   `devplan/`, `devplan/v*.md`). Identify: current version file, last
   milestone number (MNN), convention style, how many milestones exist.
3. **Git context** — `git log --oneline -20`, `git status`, current
   branch.
4. **Test inventory** — scan for test directories and levels (unit,
   integration, e2e, etc.). Note the runner and structure.
5. **Stack detection** — identify the tech stack from manifest files
   (package.json, pyproject.toml, Cargo.toml, etc.).
6. **Surface area** — grep/glob for files likely touched by the
   request. Use terms from the user's description.

**Output:** Write a **Discovery Brief** in chat (10-15 lines). Example:

> *Repo Nuxt+FastAPI, devplan corrente `devplan/v0.3.md`, ultimo
> milestone M47 (auth refactor, completato). Convenzione commit:
> `MNN: titolo`. Test: pytest unit/integration + Playwright e2e. La
> richiesta tocca probabilmente `backend/app/api/billing.py` e
> `frontend/pages/checkout.vue`. Nessun lavoro in corso su quei file
> (git status pulito).*

This brief proves you understood the context before proposing the plan.

---

### Phase 2: Clarification

After discovery, identify **real ambiguities** — not courtesy questions.

If ambiguities exist (max 3-5), present each as:

```
1. <question>
   (A) <option> — <1-line reason>
   (B) <option> — <1-line reason>
   → recommend <letter>: <why>
```

**If the request is already clear, skip this phase entirely.** Do not
ask questions for the sake of asking.

---

### Phase 3: Plan Proposal (in chat, NOT on file)

Present the plan in conversation using this structure:

```markdown
## Obiettivo
1-2 righe: cosa stiamo facendo e perché (il "why" del business/tech)

## Approccio
3-5 righe: la strategia tecnica scelta, e perché tra le alternative
considerate. Eventuali trade-off espliciti.

## Rischi
Lista concisa di cosa può andare storto e come la mitighiamo
(o cosa accettiamo come rischio).

## Fasi
### Fase A — <nome breve>
- MNN: <titolo> — <razionale 1 riga>
- MNN+1: <titolo> — <razionale 1 riga>

### Fase B — <nome breve>
- MNN+2: ...

## Out of scope
Cosa esplicitamente NON facciamo in questo piano (per evitare scope creep).
```

**Wait for the user's approval before writing anything to file.**
Iterate on the proposal if the user gives feedback. Only proceed to
Phase 4 when they explicitly approve.

---

### Phase 4: Write to Devplan File

After approval, write the milestones to the devplan file following
these rules:

#### File location
- **`new` mode:** create `DEVPLAN.md` at the project root (or a
  `devplan/v0.1.md` if the project uses versioned devplan files).
- **`extend` mode:** append to the current version file. Never close
  a version or create a new version file without explicit user request.
- **`refactor` mode:** edit in-place. The diff was already approved in
  Phase 3.

#### Numbering
- Read the last `MNN` in the target file.
- Continue from `MNN+1`. Never reset numbering.
- If the file is empty or new, start from `M1`.

#### Milestone format

```markdown
## MNN: <title — concise, imperative verb>

**Why:** 1-2 sentences on the motivation (business or technical).
What changes for whom.

**Approach:** 2-4 sentences on the technical strategy. Which files or
modules are touched. Key design decisions.

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
  open a new one. Frame it as a suggestion, not a decision: *"Il file
  ha ~50 milestone — vuoi chiudere questa versione e aprire una nuova
  (es. v0.4.md), o preferisci continuare qui?"*. The user decides.
- Never close a version or create a new version file on your own.

---

### Phase 5: Validation

After writing, re-read the devplan file and run a self-check. Report
results in chat:

- Every milestone has **Why**, **Approach**, **Tasks**, **Done when**
- Every task is actionable (not vague like "improve X" or "handle Y")
- Dependencies are resolved in order (no forward references)
- Numbering is continuous from the last existing MNN
- The plan covers all requirements from the original request
- No preparation-only milestones exist

If anything fails, **fix it immediately** without asking — then re-run
the check. Only report the final passing results to the user.

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

---

## Synergy with TDD / IDD

The milestone format produced by this playbook is designed to be
directly executable by the `TDD` and `IDD` playbooks:

- **Why** → TDD reads this to articulate the business requirement and
  decide whether tests can be written upfront (TDD) or the milestone
  is exploratory (IDD fallback)
- **Approach** → both playbooks use this to orient implementation
- **Tasks** → checkboxes that get marked `[x]` during execution
- **Done when** → the exit condition that TDD checks after tests are
  green

No translation or reformatting is needed between design and execution.

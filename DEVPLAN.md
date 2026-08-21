# forge-flow — Dev Plan

Unified skill for both **Claude Code** and **Codex** that handles the full forge-flow lifecycle:
plan creation/maintenance (`design`) and plan execution (`TDD` / `IDD`).

This project replaces the two standalone repos `claude-forge-flow-executor` and
`codex-forge-flow-executor` with a single source of truth that ships both variants
plus a shared installer.

## Milestone format

Each milestone uses 4 required sections — **Why**, **Approach**, **Tasks**,
**Done when** — and an optional **Notes** section when something doesn't fit
elsewhere. Every task is a markdown checkbox.

---

## Follow-up — A binding decision outlives the milestone that took it (2026-08-21)

### M69: The executor reads the log before it acts, and writes it in the same commit

**Why:** A log nobody reads at the start of a run changes no behaviour, and one written in
a later pass comes apart from the work — the failure already measured on the devplan
tick.

**Approach:** Two steps in `EXECUTOR-CORE.md`. Preflight reads the log once before the
first milestone, where an `Active` entry binds the run and a milestone needing to
contradict one writes the superseding entry instead of diverging silently. `Update the
devplan` appends a qualifying decision in the milestone's own commit, under the landing
check the tick already carries.

**Tasks:**
- [ ] Add the decision-log read to Preflight, with the contradiction rule
- [ ] Add the write step to `Update the devplan`, bound to the milestone's commit
- [ ] Add the landing check — the entry is present and the file is in the commit
- [ ] Test: content — anchors for the preflight read, write step, landing check
- [ ] Commit & push

**Done when:** `bash tests/test_content.sh` is green and both steps name `DECISIONS.md`
and point at M68's section for the schema.

### M70: Design mode reads the log, and writes what the clarification settled

**Why:** The answers a user gives in Phase 2 are a project's standing choices; today they
reach a milestone's `**Why:**` and go when it is archived, leaving a planner to propose
work that contradicts them.

**Approach:** `DESIGN.md` gains a ninth discovery source — read the log when present,
where `Active` entries bound what may be proposed — and a Phase 4 rule turning qualifying
Phase 2 answers into entries, written with the milestones on the same approval. The budget
warning that routes a decision-shaped milestone to `docs/` gains the split: a contract
outside readers need stays there, a binding choice goes to the log.

**Tasks:**
- [ ] Add discovery source 9 to `DESIGN.md`, with the constraint on proposals
- [ ] Add the Phase 4 write rule, gated on the same approval as the milestones
- [ ] Split the milestone-budget warning between `docs/` and the decision log
- [ ] Test: content — anchors for source 9, the Phase 4 rule, the split warning
- [ ] Commit & push

**Done when:** `bash tests/test_content.sh` is green and `DESIGN.md` references the schema
rather than restating it.

### M71: forge-flow keeps its own decision log, and the READMEs point to it

**Why:** Two closed proposals sit in `DEVPLAN.md` kept explicitly so they are "not
re-derived" — decisions parked in a section meant for open discussion. And someone
installing the skill has no way to learn the file exists.

**Approach:** Open `DECISIONS.md` at the repo root and move both closed proposals into it
as `DEC-` entries, leaving the proposals section holding only what is still open. Both
READMEs gain the file in the layout tree and one line on what it holds; `Core methodology`
credits Nygard's ADR, whose supersede-never-edit rule this borrows.

**Tasks:**
- [ ] Create `DECISIONS.md` with the two decisions moved out of `DEVPLAN.md`
- [ ] Remove the two closed proposals from `DEVPLAN.md`
- [ ] Add the file to the layout tree and docs list in both READMEs
- [ ] Credit ADR under `Core methodology` in `README.md`
- [ ] Test: content — anchors for the layout tree entry and the ADR credit
- [ ] Commit & push

**Done when:** `DECISIONS.md` holds both decisions, neither appears in `DEVPLAN.md`, and
`bash tests/test_content.sh` is green.

---

## Proposed — pending discussion (2026-07-04)

Items below are **not milestones**: no M-number, no Tasks to execute, not
approved. They exist to capture a real trigger and the open questions it
raises, so a future design pass can turn them into a real milestone (or
reject them) with the context intact. **Do not execute these via forge-flow
TDD/IDD** — "Everything is pre-approved" (Operating mode) applies to approved
milestones only.

### Proposal: automate the ban on foreign names — REJECTED (2026-08-15)

**Status:** ❌ rejected, with the measurement. Kept so it is not re-derived.

**Trigger:** one foreign project name was found in `DEVPLAN.md`, in a proposal
dated 2026-07-04. It was genericised in M55.

**Why not a check.** The name predates the rule, which was written 2026-08-14,
so nothing shows the rule failing since it exists — the sweep that day was
incomplete, once. And the check is not writable. Measured on this tree: a
pattern broad enough to catch a foreign project name flags this repo's own
GitHub URL, the install one-liner, a cited standard and a credited third-party
repo. A guard that reds on legitimate content is switched off, and takes the
rule with it. The narrow version — developer-machine paths — has exactly one
hit, the line in `CLAUDE.md` documenting the check itself: a mention, not a use.

**What that leaves.** A rule whose violations cannot be recognised mechanically
stays a rule for the reader. `CLAUDE.md` is the right home and already holds it.
Revisit only if a name reaches the remote *after* 2026-08-14, which would be
evidence the rule itself is not enough.

---

### Proposal: Sub-agent delegation — RESOLVED (2026-08-19)

**Status:** ✅ split. The git-boundary half became M66; scope-recency is out of
scope, kept here so neither half is re-derived.

**Resolution.** Question 3 — whether this is forge-flow's concern — was answered
by the text rather than by discussion: `EXECUTOR-CORE.md` already regulated
delegation for evidence, so the silence elsewhere was an inconsistency. An audit
of all seven payload files found exactly three actor-bound rules, and the first
two are one rule, which M66 carries. Question 2 dissolved with them, since each
sentence landed where its guarantee already lives. Question 1 changed shape: "a
subagent never runs git" bans a mechanism and would be wrong for a subagent in
its own worktree, so the rule states the invariant instead.

**Out of scope — the scope-recency half:** a user's most recent instruction
winning over a standing goal is session behaviour, not devplan execution, and in
`Operating mode` it would collide with "never ask for confirmation between
milestones". It belongs in the global instruction file if anywhere.

**Observed trigger:** Executing a project's scaffold milestone S3 via forge-flow
TDD, the executing agent delegated S3's implementation to a sub-agent.
Its first prompt bundled "implement + commit + push"; the user rejected the
tool call before it ran. The corrected instruction was "chiudi solo s3. poi
fermati. commit e push" — the user wanted the commit/push step under the
orchestrating agent's own direct control (after reviewing the diff), not
delegated sight-unseen to a sub-agent, and wanted the run to stop at the one
named milestone even though a broader standing `/goal` had asked for S3+S4+S5
in one pass.

**Why this might belong in forge-flow at all:** EXECUTOR-CORE's "Operating
mode" governs autonomy/scope for the *executing* agent, but says nothing
about what happens when that agent fans work out to sub-agents — a pattern
the global CLAUDE.md already encourages ("Use sub-agents to keep the main
context lean... orchestrate from the main thread"). If forge-flow stays
silent, every executing agent reinvents this boundary from scratch and can
reinvent it wrong, as happened here.

**Open questions / implications to resolve before drafting a real milestone:**
1. **Scope of the rule** — is "sub-agent never runs git" a good universal
   default, or should it depend on risk (fine for a throwaway IDD spike, not
   fine for a shared published package)? A blanket rule may be too rigid.
2. **Where it lives** — EXECUTOR-CORE's existing "Commit & push" section
   (shared execution-loop steps) already covers committing; does a new rule
   belong there instead of a new top-level section, so readers don't need a
   fourth place to check?
3. **Is this forge-flow's concern at all?** forge-flow's playbooks assume
   ONE agent runs the whole loop; they have no concept of "this milestone
   was fanned out to a sub-agent." The delegation decision happened one
   layer above forge-flow (the Claude Code session chose to spawn an Agent;
   forge-flow itself didn't). This guidance may belong in the user's global
   CLAUDE.md (where the sub-agent instruction already lives), not in this
   skill — adding it here could duplicate or contradict that source.
4. **Overlap with existing autonomy rules** — "Operating mode" already says
   "never ask for confirmation between milestones... run autonomously." A
   new "most recent instruction wins over a standing goal" rule needs
   careful wording so it doesn't create ambiguity about when forge-flow
   should defer to the user vs. proceed on its own.
5. **Testability** — every milestone here lands as pinned content anchors in
   `tests/test_content.sh`. Is this rule documentation-only (a content
   anchor, like M40/M41) or does it need a behavioral test? Worth confirming
   it wouldn't just be a rule nobody reads.

**If accepted, a possible shape (not a commitment):** new
`## Sub-agent delegation` section in `EXECUTOR-CORE.md` after
`## Operating mode`, with two rules — (a) a sub-agent implements + tests +
docs + ticks the devplan but never runs git, the orchestrator reviews and
commits/pushes itself; (b) the user's most recent scoping message wins over
a wider standing goal. Anchors in `test_content.sh`; `TDD.md`/`IDD.md`
unchanged (shared-core section, inherited automatically).

**Next step:** resolve questions 1–4 with the user (especially #3 — whether
this belongs in forge-flow or in the global CLAUDE.md instead); only then
draft it as a numbered milestone with committed Tasks.

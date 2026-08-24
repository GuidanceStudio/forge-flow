# forge-flow — Decisions

Choices that constrain future work, kept out of the devplan because a closed
milestone compresses to one line and takes its `**Why:**` with it. Format and
gate: `forge-flow/EXECUTOR-CORE.md`, "Record a binding decision".

## DEC-1: The ban on foreign names is a rule for readers, not a check
**Status:** Active
**Context:** a pattern wide enough to catch a foreign project name also flags
this repo's own URL, the install one-liner and a credited third-party repo
**Decision:** no automated guard; `CLAUDE.md` carries the rule and the
staged-diff grep stays a manual step before committing
**Consequence:** a violation is caught by a reader or not at all, so revisit
this if a foreign name reaches the remote after 2026-08-14

## DEC-2: Delegation rules name the guarantee, never the mechanism
**Status:** Active
**Context:** "a subagent never runs git" bans a mechanism and is wrong for a
subagent in its own worktree, which carries the baseline that bounds a commit
**Decision:** rules about delegation state the invariant that must hold; which
instruction wins when a newer one narrows a standing goal stays out of forge-flow
**Consequence:** a subagent may commit when it holds the baseline, and session
scoping lives in the user's own instruction file

## DEC-3: The milestone budget stays at 200 and identifiers stop counting
**Status:** Active
**Context:** eleven unresolvable references in a 16-milestone plan, nine of them in
milestones with words to spare or already over the limit, so 250 would have fixed two
**Decision:** the number stays; backticked symbols, `file:line` and measured numbers
become a register like ticked lines, and a naming rule joins `Never restate`
**Consequence:** a milestone dense with paths runs long legitimately and a prose one does
not, so the pressure that routes a trap into `docs/` is kept rather than relieved

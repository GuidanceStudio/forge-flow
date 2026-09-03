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

## Follow-up — The suggestion that could not fire (2026-08-26)

### M73: Archiving is suggested when the run closes ✅

**Why:** `#### Archive` says to suggest archiving "when a completed section outgrows the
pending work". Measured on a production devplan: 640 archived rows against 11 open
sections — true for months, so it names no moment and the executor never reached it.
Measured 2026-08-26: eight archives taken on the executor's own initiative in one session,
and the rule against it quoted afterwards.

**Approach:** `Never archive on your own initiative` stays; the size condition is replaced
by the run's close-out. `## Completion` gains a step naming how many closed milestones sit
in the completed file and asking whether to compress them. `## Common rules` carries the
carve-out, since the ask follows the run rather than sitting between milestones.

**Tasks:**
- [x] `#### Archive` trigger becomes the close-out, size condition removed
- [x] `## Completion` step asking to compress, naming the count and the file
- [x] Carve-out in `## Common rules` against the between-milestones prompt ban
- [x] Test: content anchors for the trigger, the Completion step and the carve-out
- [x] Falsified — removing each anchor reds `tests/test_content.sh`
- [x] Commit & push

**Done when:** both suites are green, no file under `forge-flow/` states the size
condition, and `./install.sh --force` has deployed it.

---

## Follow-up — Git is one line of the executor and a whole workflow in practice (2026-09-03)

### M74: The shipping route is the project's, read before it is guessed ✅

**Why:** the executor says *"Commit and push after every milestone, always on the current
active branch"* and *"Push to the active branch when network/auth/repo policy allows it"*.
That is the whole of it: nothing about which branch to be on, nothing about consent, nothing
about a remote that has moved, nothing about pull requests.

⚠️ **It contradicts the host's own default, out loud.** Claude Code's system prompt says to
commit or push only when the user asks, and to branch first when on the default branch. An
agent running this skill holds two documents telling it opposite things, and which one wins
is decided by whichever it read last.

⚠️ **"When repo policy allows it" is about capability, not consent.** It answers whether the
push can happen, never whether it should — so a protected default branch is discovered by
being rejected, and an unprotected one is pushed to without anybody agreeing.

⚠️ **A rejected push has no rule at all.** The two safe answers differ: rebasing is right for
commits this run has not pushed and wrong the moment one has, because it rewrites what
somebody else may hold. Without the rule, the reachable move is a force push.

⚠️ **And the skill must decide none of it.** Branch names, branch granularity, whether a pull
request is opened at all, who reviews it, how it merges — every team has its own and they are
not the skill's to set. A skill that writes one in is a skill that fights its own installer on
the first milestone. What it may decide is the short list that is not a convention: do not
destroy work that is not yours, and say where the work went.

**Approach:** a precedence order, stated in `## Preflight`, so the question is answered by the
project before it is answered by inference and by inference before it is answered by a guess.

1. **What the project WRITES.** `CONTRIBUTING.md`, the agent instruction files the host already
   loads, a devplan preamble. Teams write their branch and review rules down, and where they
   have, those are followed as written and nothing is asked.
2. **What the repository DOES.** Read the same way the commit convention already is: whether
   recent history lands on the default branch directly or arrives through merges, whether a
   pull-request template or CODEOWNERS is present, whether the default branch is protected,
   and — for a name — the shape of the branches the repository already carries. State the
   reading back in one sentence and take the permission with it, once for the run.
3. **Ask.** When neither answers, the agent asks rather than inventing a scheme. A branch name
   it made up is a branch name somebody has to rename.

⚠️ **Consent is graded by the act, not by the run.** A local commit needs none. A push onto a
branch that belongs to this run is covered by the permission taken in preflight. Landing on a
shared or default branch, and opening or merging a pull request, are outward-facing and get
their own agreement — which is also what keeps this from being a prompt between milestones,
the thing `## Common rules` bans.

⚠️ **A declined run still runs.** It executes and commits; it stops before the outward act and
says where the work is, which is the same shape as the existing blocker rule.

The rules that hold whatever the project's convention is, because they are not conventions:
never force-push, never rewrite a commit already pushed, fetch before deciding a rejected push
is a conflict, and integrate the way the repository's own history integrates rather than
picking. `## Completion` reports the sha, the branch, and where the default branch stands
relative to it — a colleague installs from the default branch, and work that is only on a
feature branch does not exist for them.

**Tasks:**
- [x] `## Preflight` carries the precedence order, with what is read at each level
- [x] `## Preflight` states the reading and takes the run's push permission, once
- [x] `## Preflight` asks for a branch name rather than inventing one, when nothing supplies it
- [x] `### Commit & push` grades consent by the act: local, own branch, shared or request
- [x] `### Commit & push` carries fetch-before-conflict, no rewrite of a pushed commit, no force
- [x] `## Completion` names sha, branch, and where the default branch stands
- [x] `## Common rules` carve-out: the preflight ask is not a between-milestones prompt
- [x] No file under `forge-flow/` names a branch-naming scheme, a review policy or a merge
      strategy of its own
- [x] Test: content anchors for the precedence order, the single ask, the graded consent, the
      rebase and force rules, and the completion report
- [x] Test: a scan asserting the skill states no branch-name pattern of its own
- [x] Falsified — removing each anchor reds `tests/test_content.sh`
- [x] `./install.sh --force`
- [x] Commit & push

**Done when:** on a repository it has never seen, the executor follows what that project wrote,
falls back to what it demonstrably does, asks when neither answers, and cannot reach a force
push or an unagreed landing on a shared branch by following the document.

### M75: Archiving is also suggested when nothing open reads what is closed 📋

**Why:** M73 gave the suggestion one moment — a run's close-out — and that is the only one it
has. A plan reaches the state the archive exists for without a run closing: milestones close
across many runs and sessions, and the open ones stop referring to them. Measured on a
production devplan 2026-09-03: 35 milestones, 32 of them closed, and not one of the 3 open
ones read any of the 32. The file was 1,333 lines of which 1,272 described finished work, so
the first task of whoever opened it was finding the three. No run was closing, so nothing
asked.

⚠️ **The trigger has to be mechanical or it repeats M73's failure.** A size comparison was
true for months and therefore named no moment. Relevance is not a judgement here: an open
milestone READS a closed one when it names its ID, or when its Approach or Tasks cite a file,
a decision or an artifact the closed one produced. A devplan has no forward dependencies, so
what an open milestone needs is stated in it.

⚠️ **Compressing alone leaves a remainder that may not stand up.** The same measurement: the
three that survived were each a box and a Done-when, with the context that made them workable
sitting in the 32 being archived. An archive that leaves the file unreadable has moved the
problem.

**Approach:** the same shape M74 gives the push permission — read the state, say what it is,
ask once, and let the answer settle it. `#### Archive` gains the second trigger beside the
close-out, with the reading test spelled out; the ask is made once per state and a decline
holds until a new milestone reads a closed one or the archive is taken. `## Completion`'s
step 5 names the second trigger alongside the close-out. Design mode gains the remainder read,
because that is where the file is rewritten: each surviving milestone carries what somebody
opening it cold needs — what to decide when it is not ours, what it costs, what proves it
done. `sha` in the compressed form is named as the commit that MARKED the milestone done,
which is the commit carrying the work, since the bookkeeping ships with it.

**Tasks:**
- [ ] `#### Archive` carries the second trigger, the reading test and the once-per-state rule
- [ ] `#### Archive` says which sha the compressed row takes
- [ ] `## Completion` step 5 names the second trigger alongside the close-out
- [ ] Design mode reads the remainder when an archive is taken
- [ ] Test: content anchors for the trigger, the reading test, the once-per-state rule, the
      sha and the remainder read
- [ ] Falsified — removing each anchor reds `tests/test_content.sh`
- [ ] `./install.sh --force`
- [ ] Commit & push

**Done when:** an executor opening a plan whose open milestones read none of its closed ones
offers the archive without being asked, offers it once, and leaves a file whose remaining
milestones can be worked from cold.

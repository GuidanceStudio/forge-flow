# forge-flow — Completed Milestones

Compact index of closed milestones. Each SHA points to the commit that marked the milestone done; full details remain available in Git history. Newly closed milestones are recorded verbatim at close-out and compressed only with the user's explicit approval.

Milestone | Title | Date | SHA
--- | --- | --- | ---
M1 | Project skeleton, git init, top-level files | 2026-04-10 | 62463d6d944c
M2 | Migrate Claude variant (TDD.md, IDD.md, README.md) | 2026-04-10 | 1e55b3e85f77
M3 | Migrate Codex variant (TDD.md, IDD.md, README.md, agents/openai.yaml) | 2026-04-10 | 0d6a52aedb18
M4 | Write `DESIGN.md` for the Claude variant | 2026-04-10 | 2e981d0c4549
M5 | Write `DESIGN.md` for the Codex variant | 2026-04-10 | a2a348b5de26
M6 | Rewrite `SKILL.md` as the design/TDD/IDD router (both variants) | 2026-04-10 | 392de367aea6
M7 | Write `install.sh` | 2026-04-10 | aea13e4da0b9
M8 | Write project-level `README.md` | 2026-04-10 | 4efa13f91445
M9 | Smoke test & v0.1 tag | 2026-04-10 | 2293a3c4fc1f
M10 | Refine DESIGN.md — adaptive discovery, scalable proposal, pending check, precise clarification, codebase-aware validation | 2026-04-10 | a99a47442970
M11 | Remote install — one-liner `bash <(curl ...)` without cloning | 2026-04-10 | 1fb065aa9041
M12 | Reconcile variant drift — variant-neutral canonical playbooks | 2026-06-10 | 3860cbfe6700
M13 | Lockstep guard — identity test + install drift check | 2026-06-10 | b7dc74f81022
M14 | Executor hardening — preflight, selective staging, Done-when, conventions, resume | 2026-06-10 | fbffddfdc658
M15 | Router/design polish — adaptive language, workspace awareness, handoff | 2026-06-10 | 2b54f7aa00f3
M16 | Collapse the two variants into one flat `forge-flow/` payload | 2026-06-10 | fe69eeb2899c
M17 | Broad multi-assistant installer + per-target tests | 2026-06-10 | 3cbab0623d73
M18 | CI — run the test suite on push | 2026-06-10 | 9f5e162387a3
M19 | Filter proposed milestones through an essentiality ladder | 2026-06-19 | a52ce2408123
M20 | Make TDD and IDD simplification Ponytail-aware | 2026-06-19 | 5d8a8346db2f
M21 | Comment essentiality — add a comment-weight step to the simplify ladder | 2026-06-24 | 47b86890259a
M22 | `ponytail:` comment convention — document intentional simplifications in code | 2026-06-24 | 47b86890259a
M23 | Debt tracking — `.code-audit/debt.tsv` populated during simplification | 2026-06-24 | 47b86890259a
M24 | Fix debt.tsv column order mismatch between TDD.md and IDD.md | 2026-06-24 | 47b86890259a
M25 | Extract EXECUTOR-CORE.md — deduplicate TDD.md + IDD.md | 2026-06-24 | 47b86890259a
M26 | Unify simplify/essentiality ladder across DESIGN.md, TDD.md, IDD.md | 2026-06-24 | 47b86890259a
M27 | Compress DESIGN.md + SKILL.md prose | 2026-06-24 | 47b86890259a
M28 | Trim READMEs | 2026-06-24 | 47b86890259a
M29 | Add the `scaffold` route — mount the operational spine | 2026-06-24 | b719cdb967be
M30 | DESIGN suggests `scaffold` when the spine is missing (opt-out) | 2026-06-24 | 975ebb6eee1c
M31 | EXECUTOR reproducibility guardrails — no manual steps + first-class live tier | 2026-06-24 | c0f6bdeb02ef
M32 | DESIGN adds a live/e2e test task for real external dependencies | 2026-06-24 | 9938f3c537af
M33 | Make "mark the milestone done" a verified, committed gate | 2026-06-24 | 6ee4c7a18fcd
M34 | Anchor content assertions to milestone-unique phrases | 2026-06-24 | 78c86159dca7
M35 | Close the M33 commit-inclusion seam + align the done-marker example | 2026-06-24 | 8972241feea2
M36 | SCAFFOLD.md — runnable tiers + dispatcher-to-script wiring | 2026-06-24 | 1b610d3dd825
M37 | Align documentation surfaces to the real skill (name + scaffold route) | 2026-06-24 | 5d58ecc7f99a
M38 | DESIGN proposes the operational spine explicitly (default-include, greenfield-aware) | 2026-06-27 | d41799180087
M39 | Make SKILL frontmatter YAML-safe | 2026-06-29 | 37bfc6866bca
M40 | Stuck protocol — root cause before fixes, three-strikes to design review | 2026-07-03 | 90a16b8dc06d
M41 | Completion gates — evidence before claims, spec fidelity before commit | 2026-07-03 | 2d1c5b63ba67
M42 | DESIGN validation — placeholder scan, requirement coverage, interface consistency | 2026-07-03 | 0b8d2df98a92
M43 | Align debt registry to `.tech-audit/` — restore the ponytail→audit bridge | 2026-07-03 | b240d3ff4186
M44 | One ladder, one name — fix DESIGN's stale rung list and unify naming | 2026-07-03 | d5210b513bcb
M45 | In-progress milestone marker — a third devplan state | 2026-07-15 | 381fbbb4d70c
M46 | A milestone has a size, and Phase 5 measures it | 2026-08-13 | 93a40f860f2b
M47 | Bound what execution writes back, and name where the rest goes | 2026-08-13 | 0df84bf6c320
M48 | Closed milestones compress on archive | 2026-08-13 | 780ac4bf1404
M49 | Four gaps the first real application of M45-M48 found | 2026-08-14 | ab31034411da
M50 | What a comment carries, in code and in tests | 2026-08-14 | ae97e72caab0
M51 | forge-flow's own comments under M50, and the carve-outs the pass found | 2026-08-14 | fbb4a071d3dc
M52 | A comment check the executor runs, and one scaffold generates | 2026-08-14 | 6701a9337442
M53 | Explicit paths do not bound a commit — the index does | 2026-08-14 | 24f58e17f78a
M54 | three of the four places a comment lives were invisible to the check | 2026-08-14 | 9da5a669059c
M55 | what a test costs is decided when it is written, and nothing said so | 2026-08-15 | f8b59774f84c
M56 | a runner that reports tier totals cannot show which test is the slow one | 2026-08-15 | bab6664ad976
M57 | five guards written in one session could not fail, and reading caught none | 2026-08-15 | 041c396e93ea
M58 | an assertion can pin the wrong thing and stay green while the code is wrong | 2026-08-15 | 1f066afd1413
M60 | The devplan is two files, and the executor reads only the active one | 2026-08-19 | eb5b8b3fab4f
M61 | Closing a milestone moves it, and nothing is lost in the move | 2026-08-19 | 71f2adcdf934
M62 | Offer the split, then run it on this repo's own plan | 2026-08-19 | f17822474286
M63 | Both READMEs explain the two-file plan, and the layout tree matches the repo | 2026-08-19 | 3c5704836df0
M64 | Two bookkeeping checks look for a milestone that has moved | 2026-08-19 | 8d1557ba817d
M65 | install.sh names the targets it left behind | 2026-08-19 | 7dde1a5adcd4
M66 | Name who holds the baseline, and widen evidence to the red-proof | 2026-08-19 | 7f82656fc732
M67 | The spine has no inner loop | 2026-08-20 | 0a830ca05826
M68 | A binding decision has a place to live | 2026-08-21 | 7229a2d3c672
M69 | The executor reads the log before it acts, and writes it in the same commit | 2026-08-21 | e628f2064d3b
M70 | Design mode reads the log, and writes what the clarification settled | 2026-08-21 | b15024a34ce7
M71 | forge-flow keeps its own decision log, and the READMEs point to it | 2026-08-21 | 42b50101a018
M72 | A milestone names what it refers to | 2026-08-24 | 952ffdb0752c
M73 | Archiving is suggested when the run closes | 2026-08-26 | 81ba0ac52561
M74 | The shipping route is the project's, read before it is guessed | 2026-09-03 | 6157c17eb258
M75 | Archiving is also suggested when nothing open reads what is closed | 2026-09-03 | 19cdf87bebfe
M76 | Design settles the project's principles and decisions cite them | 2026-10-23 | bcea4060061d
M77 | Specs live in small TSV files the tests read | 2026-10-23 | 6f325f5b9434
M78 | A project the skill joins late grows its specs where work happens | 2026-10-23 | c205469e008c
M79 | Review through explicit heuristics the project chooses | 2026-10-23 | f237071fd4d2
M80 | Repeated concepts prompt an abstraction check, and names read like speech | 2026-10-23 | aef7dc23f97b
M81 | Design asks who can abuse a feature and tests prove the rule holds | 2026-10-23 | 8724f9440631
M82 | Verify reviews the diff for security and reports what did not run | 2026-10-24 | fe5de79a1bb6
M83 | The spec adapter example moves out of the file read on every run | 2026-10-24 | 71a61534f6d2
M84 | Record source provenance and validation limits | 2026-10-24 | acf4e359db00
M85 | Load optional procedures only when applicable | 2026-10-24 | 82bb292011bc
M86 | The absence of configured reviewers is reported in chat, once per run | 2026-10-24 | b58812465080
M87 | Make specification conformance an executable test flow | 2026-10-24 | 3987c096ccc4
M88 | Make security verification an executable test flow | 2026-10-24 | edb90ecb76bc

## Closed verbatim

Milestones closed after the index above was compressed. Each moves here as written and is compressed into the index only with the user's approval.

## ✅ M89: Every test suite is named where a reader looks for it

**Why:** the repo ships five test suites, but the CI workflow lists two steps and
the root README names two files and two commands. The three Python suites run only
as calls nested inside the content contract, so a failure there appears as one
contract failure with no suite name in the CI log, and a contributor following the
README runs 43 installer cases and the contract without knowing three more suites
exist. One of the suites also imports a sibling by bare name, which works only
when the interpreter puts the script directory on the path: under `python3 -I`
all nine of its tests error before running.

**Approach:** one CI step per suite, in the order a failure is cheapest to read
(installer, content contract, adapter, runner, security). The root README layout
tree and "Running the tests" list all five. The provenance table's automated-tests
row names the two suites it omits. The runner suite puts its own directory on the
path before importing the security suite's helper.

**Tasks:**
- [x] `.github/workflows/tests.yml`: five named steps, Python suites run with `python3 -I`
- [x] `README.md`: layout tree and test commands name all five suites
- [x] `docs/SOURCE-PROVENANCE.md`: automated-tests row names all five suites
- [x] `tests/test_test_flows.py`: sibling import independent of invocation mode
- [x] `tests/test_content.sh`: the contract asserts the workflow names each suite

**Done when:** all five suites pass locally under the exact commands the workflow
runs, `python3 -I tests/test_test_flows.py` reports 9 tests OK, and the content
contract fails if a suite's step is removed from the workflow.


**Closed:** 2026-10-24. Verified: five suites green under the workflow's exact commands; removing the security step from the workflow fails the content contract.

## ✅ M90: The principles document has one shape, and carries only what constrains a plan

**Why:** design prescribes what a principle says (a conflict, the side that wins,
a non-goal) and that a `## Reviewers` table follows, but not what the persisted
file looks like. The decision log, the threat model and the spec files each ship
a worked shape; `PRINCIPLES.md` ships none, so every run invents a layout, the
executor's "verify IDs and text match" has no anchor, and a reader who opens the
file is not told who reads it or what a departure costs. Nothing says what stays
out either, so a run can pad the file with the README's stack list or a process
rule that belongs in the instruction file.

**Approach:** one fenced example of the whole document in the design playbook's
"Project principles" section: a two-line purpose header, `## P<N>: <sentence>`
headings with the conflict, the winner and a `Non-goal:` line, then the
`## Reviewers` table. A short exclusion list beside it. The persist step in
Phase 4 checks each principle for its three parts and refuses to write an
incomplete one. The content contract parses the example and asserts the parts.

**Tasks:**
- [x] `forge-flow/DESIGN.md`: canonical shape and exclusion list under "Project principles"
- [x] `forge-flow/DESIGN.md`: Phase 4 persist step verifies the three parts and the header
- [x] `tests/test_content.sh`: parse the example; every principle has the three parts, the reviewers section follows

**Done when:** the content contract passes, and fails when the example loses a
`Non-goal:` line or its `## Reviewers` heading.


**Closed:** 2026-10-24. Verified: the content contract passes, and fails with `P1: no non-goal` when the example loses its Non-goal line and with `reviewers section does not follow the principles` when the heading is removed.

## ✅ M91: Every threat entry carries the parts design prescribes

**Why:** design asks the threat model for protected assets, trust boundaries and a
STRIDE category per threat, with a concrete failure, a control and a named
verification. The executable example that runs model the executor copies from
carries the failure, the control and the verification, and names the boundaries
once in its header; no entry names its asset or its STRIDE category. A run that
copies the shape writes a model the Phase 4 check cannot verify for assets, and the
category that tells a reader which failure class a threat belongs to is absent.

**Approach:** one line per threat in the example (`Asset:` and `STRIDE:`), which
the example's parser ignores because it reads headings only. The Phase 4 persist
step names the five parts of an entry and reports an incomplete one instead of
writing it. The content contract parses the example block and asserts the parts and
a valid STRIDE category on each threat.

**Tasks:**
- [x] `forge-flow/SECURITY-EXAMPLE.md`: asset and STRIDE category on each threat entry
- [x] `forge-flow/DESIGN.md`: Phase 4 names the five parts; an incomplete entry is reported, not written
- [x] `tests/test_content.sh`: parse the block; every threat has the five parts and a STRIDE category

**Done when:** the security suite and the contract pass, and the contract fails
when a threat in the example loses its `STRIDE:` line.


**Closed:** 2026-10-24. Verified: security suite 14 OK, runner suite 9 OK, contract passes; the contract fails with `THREAT-IDENTITY: no STRIDE category` when that line is removed from the example.

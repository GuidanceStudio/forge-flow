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

Closed milestones live in **[`DEVPLAN-COMPLETED.md`](DEVPLAN-COMPLETED.md)** as a compact index (`MNN | title | date | sha`); full details remain in Git history. Newly closed milestones are recorded verbatim at close-out, and compressed only with the user’s explicit approval. Numbering continues from the highest ID there.

---

## ✅ M94: The READMEs state the suite count and read as three documents

**Why:** M93 added a sixth suite, but the root README still says "five suites" in its layout block and in the Tests section, while listing six commands. The layout block omits `docs/`. "MIT licensed." appears twice. The payload README sets the principles, review and executable-specification rules as dense paragraphs, so a reader cannot find the rule they came for.

**Approach:** Correct the count and the layout in the root README; drop the duplicated licence line. In the payload README, split the two dense sections into short bullet lists, one rule per bullet, with the normative wording unchanged. Phrases pinned by `tests/test_content.sh` stay verbatim.

**Tasks:**
- [x] `README.md`: "six suites" in layout and Tests; add `docs/` to the layout; remove the duplicate licence line; lower-case "forge-flow"
- [x] `forge-flow/README.md`: "Project principles" and "Executable specifications" as bullet lists
- [x] Run the six suites; all green
- [x] Commit with the ticks, push

**Done when:** no README says "five suites", the six suites pass, and both sections read as one rule per bullet.

---

## M95: The repo carries its own principles

**Why:** `DESIGN.md` and `EXECUTOR-CORE.md` make root `PRINCIPLES.md` the document design and execution read first, yet this repo has none. Its trade-offs sit in `CLAUDE.md` (no foreign names in a public payload) and `DECISIONS.md` (DEC-1 to DEC-3), where design cannot find them under the name it looks for.

**Approach:** Draft 3-5 numbered principles from `CLAUDE.md` and `DECISIONS.md` in the shape of the `principles-shape-example` block in `DESIGN.md`, show the draft in chat and write the file only after the user approves its wording. Add a `## Reviewers` section with the defaults design proposes for a skill package. Do not alter DEC entries; cite them as `Principle:` where they apply.

**Tasks:**
- [ ] Draft the principles and the `## Reviewers` section; present them in chat for approval
- [ ] Write root `PRINCIPLES.md` after approval
- [ ] Add `tests/test_content.sh` coverage: the file exists and follows the shape the example in `DESIGN.md` prescribes
- [ ] Run the six suites; all green
- [ ] Commit with the ticks, push

**Done when:** root `PRINCIPLES.md` exists with user-approved wording, a content test pins its shape, and the six suites pass.

---

## M96: The repo carries its threat model

**Why:** README "Threats" requires `THREATS.md` with negative tests for changes touching data, access or external services. `install.sh` writes under the user's home for six targets, accepts `--force`, and in remote mode clones a repository and runs from it. The public repo also has one standing leak risk (DEC-1). None of these has a threat entry or a negative test.

**Approach:** Write `THREATS.md` in the shape `SECURITY-EXAMPLE.md` shows, scoped to `install.sh` and the public-repo naming rule. Each threat names its control and the negative test or check that proves it. Add the negative tests to the existing installer suite. Task wording of each threat is settled with the user before the file is written.

**Tasks:**
- [ ] Propose the threat list (destination overwrite without `--force`, path escape through `--target` or `FORGE_FLOW_REPO_URL`, temp-dir cleanup, foreign name reaching the remote) in chat for approval
- [ ] Write `THREATS.md` after approval
- [ ] Add a negative test per approved threat to `tests/test_install.sh`
- [ ] Run the six suites; all green
- [ ] Commit with the ticks, push

**Done when:** every approved threat has a control and a passing negative test, and `THREATS.md` follows the `SECURITY-EXAMPLE.md` shape.

---

## M97: The repo exposes its own conformance and security flows

**Why:** `TEST-FLOWS.md` applies to every project, skill packages included: dedicated `conformance` and `security` selections in the native runner and in CI, and behaviour rows under `specs/`. The repo has `tests/` for its examples but no `specs/` for `install.sh` and no named flows, so a full run cannot show that every declared contract executed.

**Approach:** Declare `install.sh` behaviours and the payload's pinned contracts as rows in `specs/<area>.tsv` with `specs/INDEX.tsv`, reusing the adapter pattern from `SPECS-ADAPTER.md`. Add `conformance` and `security` as selections of the existing test commands, mapped to M96's threats, and wire both into `.github/workflows/tests.yml`. Reuse existing tests; copy none.

**Tasks:**
- [ ] Write `specs/INDEX.tsv` and the area files for `install.sh` and the payload contracts
- [ ] Add the `conformance` selection; it fails when a row has no executing test
- [ ] Add the `security` selection mapped to the `THREATS.md` entries from M96
- [ ] Wire both selections into `.github/workflows/tests.yml`
- [ ] Run the full set; record flow, scope, IDs and outcomes as `TEST-FLOWS.md` requires
- [ ] Commit with the ticks, push

**Done when:** both flows run through the repo's native commands and CI, every row has an executing test, and a row without one fails the run.

---

## Deferred — Existing-project pilot

This is not an executable milestone. It requires explicit authorization, a selected
repository and a desired change. An isolated run would trace selective spec reads,
a green characterization baseline before implementation, the TDD red/green cycle and
stopping on a principle departure without an approved exception. Controlled scenarios
in M85 do not close this real-project validation gap.

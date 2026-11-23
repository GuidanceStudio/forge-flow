# forge-flow — Dev Plan

Unified skill for both **Claude Code** and **Codex** that handles the full forge-flow lifecycle:
plan creation/maintenance (`design`) and plan execution (`TDD` / `IDD`).

This project replaces the two standalone repos `claude-forge-flow-executor` and
`codex-forge-flow-executor` with a single source of truth that ships both variants
plus a plain-folder distribution.

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

## ✅ M95: The repo carries its own principles

**Why:** `DESIGN.md` and `EXECUTOR-CORE.md` make root `PRINCIPLES.md` the document design and execution read first, yet this repo has none. Its trade-offs sit in `CLAUDE.md` (no foreign names in a public payload) and `DECISIONS.md` (DEC-1 to DEC-3), where design cannot find them under the name it looks for.

**Approach:** Draft 3-5 numbered principles from `CLAUDE.md` and `DECISIONS.md` in the shape of the `principles-shape-example` block in `DESIGN.md`, show the draft in chat and write the file only after the user approves its wording. Add a `## Reviewers` section with the defaults design proposes for a skill package. Do not alter DEC entries; cite them as `Principle:` where they apply.

**Tasks:**
- [x] Draft the principles and the `## Reviewers` section; present them in chat for approval
- [x] Write root `PRINCIPLES.md` after approval
- [x] Add `tests/test_content.sh` coverage: the file exists and follows the shape the example in `DESIGN.md` prescribes
- [x] Run the suites; all green
- [x] Commit with the ticks, push

**Done when:** root `PRINCIPLES.md` exists with user-approved wording, a content test pins its shape, and the suites pass.

---

## ✅ M96: The repo distributes the payload as a plain folder

**Why:** `forge-flow/` is already the complete, assistant-neutral payload, and the README says copying it is enough. `install.sh` (245 lines, 151 of tests) adds a clone-and-run remote mode, six targets and an `rm -rf` on the destination. It encodes one user's multi-location setup in a public repo, and that setup belongs on that user's machine. Standard distribution is a folder a person copies to wherever their assistant reads skills.

**Approach:** Remove `install.sh` and `tests/test_install.sh`, drop the installer suite from CI, and rewrite the README Install section to the standard path: clone or download, copy `forge-flow/` into the assistant's skills directory, or use the assistant's own skill installer from the GitHub path. No plugin manifest and no assistant-specific packaging. The `agents/openai.yaml` metadata file stays. The user's personal deployment moves to a separate local script, tracked in its own devplan outside this repo.

**Tasks:**
- [x] Remove `install.sh`, `tests/test_install.sh` and the installer step in `.github/workflows/tests.yml`
- [x] Rewrite the README Install section and layout block: the copy route, the Codex skill-installer route pinned to a tag, an update procedure (save local edits, replace the whole folder), and a note that the Gemini and AGENTS.md wrappers and the remote one-liner are gone; "six suites" becomes five everywhere it is stated
- [x] Adjust `tests/test_content.sh` where it pins installer wording, and `forge-flow/README.md` where it mentions the installer
- [x] Add `.claude/` to `.gitignore`
- [x] Run the remaining suites; all green
- [x] Commit with the ticks, push

**Done when:** no file references `install.sh`, the README gives the copy and skill-installer routes with the update procedure and the removed-features note, and the five remaining suites pass.

---

## ✅ M97: The repo carries its threat model

**Why:** README "Threats" requires `THREATS.md` for changes touching data, access or external services. With the installer gone, the public repo's standing exposure is a foreign project name or host reaching the remote inside an installable payload (DEC-1), and the CI workflow that runs on every push. Neither has a threat entry or a negative test.

**Approach:** Write `THREATS.md` in the shape `SECURITY-EXAMPLE.md` shows, scoped to those two surfaces. Each threat names its control and the check that proves it; the threat list is settled with the user before the file is written. Controls stay manual where DEC-1 says so, and a negative test only where a check can run without a name pattern wide enough to flag this repo's own URL.

**Tasks:**
- [x] Propose the threat list in chat for approval; it includes altered instructions delivered through a mutable reference such as `main`, with a tag as the control
- [x] Write `THREATS.md` after approval
- [x] Add a negative test or check per approved threat that can be automated; list the rest as manual controls
- [x] Declare read-only contents permission in `.github/workflows/tests.yml` and run the new suite in CI
- [x] Run the suites; all green
- [x] Commit with the ticks, push

**Done when:** every approved threat has a control and either a passing negative test or an explicit manual-control entry, and `THREATS.md` follows the `SECURITY-EXAMPLE.md` shape.

---

## M98: The repo exposes its own conformance and security flows

**Why:** `TEST-FLOWS.md` applies to every project, skill packages included: dedicated `conformance` and `security` selections in the native runner and in CI, and behaviour rows under `specs/`. The repo has `tests/` for its examples but no `specs/` and no named flows, so a full run cannot show that every declared contract executed.

**Approach:** Declare the payload's pinned contracts and the README's distribution claims as rows in `specs/<area>.tsv` with `specs/INDEX.tsv`, reusing the adapter pattern from `SPECS-ADAPTER.md`. Add `conformance` and `security` as selections of the existing test commands, the latter mapped to M97's threats, and wire both into `.github/workflows/tests.yml`. Reuse existing tests; copy none.

**Tasks:**
- [ ] Write `specs/INDEX.tsv` and the area files, including a row that the payload folder alone contains every file its entry points reference
- [ ] Add the `conformance` selection; it fails when a row has no executing test
- [ ] Add the `security` selection mapped to the `THREATS.md` entries from M97
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

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

## Deferred — Existing-project pilot

This is not an executable milestone. It requires explicit authorization, a selected
repository and a desired change. An isolated run would trace selective spec reads,
a green characterization baseline before implementation, the TDD red/green cycle and
stopping on a principle departure without an approved exception. Controlled scenarios
in M85 do not close this real-project validation gap.

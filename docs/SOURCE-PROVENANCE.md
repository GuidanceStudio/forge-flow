# Source provenance and validation limits

What the security rules added in M81 and M82 were compared against, what was
checked, and what is not known. Nothing here asserts that any text was derived
from a source or that a source's license is compatible with this repository's.

## Comparison references

| Source | License (as reported) | Revision | Status |
|---|---|---|---|
| `trailofbits/skills` | CC-BY-SA-4.0 | `196a9073ab10d35bacf111f945e02c00b2c6883a` (2026-10-23) | pinned, compared |
| `anthropics/claude-code-security-review` | MIT | not pinned | read, not compared |
| Microsoft, *Uncover Security Design Flaws Using the STRIDE Approach* (MSDN Magazine, 2006) | not checked | n/a | cited in the payload for the STRIDE definition |

Other public security-review skill sets and agent scanners were read while the
rules were designed. They are not pinned, and no comparison was run against them.

## What was compared in `trailofbits/skills`

Seven `SKILL.md` files at the pinned revision, and two files of the
`insecure-defaults` plugin: `audit-context-building`, `differential-review`,
`fp-check`, `sharp-edges`, `variant-analysis`, the `semgrep` skill of
`static-analysis`, `supply-chain-risk-auditor`, and `insecure-defaults`
(`README.md`, `commands/audit.md`).

**Method:** every run of five consecutive words in the text M81 and M82 added to
`forge-flow/` (1,505 words) was looked up in those files, lower-cased, ignoring
punctuation. **Result:** no run of five words is shared with any of them.

**What the result does and does not show.** It shows the added text does not
reuse those files' wording. It does not show the ideas are independent: the
rules cover areas those skills also cover (trust boundaries and assumptions,
negative tests, variant search after a defect, risk by change type, reporting
what did not run), and the original inputs of the design discussion are not
preserved.

**Not read or compared:** the `codeql` and `sarif-parsing` skills, the remaining
plugins, and the agent definitions and reference files under each plugin.

## Classification

- **Verified reference:** the pinned revision above exists, carries the license
  shown, and contains the nine files listed.
- **Confirmed derivation:** none.
- **Unknown original inputs:** the material the design discussion drew on beyond
  the pinned revision.

Because the share-alike license applies to adaptations, a reader who needs a
legal conclusion should obtain one; this repository makes none.

## Validation evidence

| Kind | What it covers | Where |
|---|---|---|
| Automated tests | the instructions' wording is present; the installer places the payload; the documented spec adapter runs against fixture files | `tests/test_content.sh`, `tests/test_install.sh`, `tests/test_specs_adapter.py` |
| Reader walkthroughs | one reader applying a playbook to a temporary project, with the outcome recorded | `tests/scenarios.md` |
| Real-project use | the playbooks applied to an existing project's change | none yet |

A passing automated test shows the text is present, not that a model follows it.
A walkthrough shows one reader's application of one playbook in a temporary project.

## Required-flow extensions

The conformance extension is exercised by `tests/test_specs_adapter.py` and
`tests/test_test_flows.py`. They extract the exact Python examples published in
the payload, execute them against temporary disk fixtures, and alter real
implementations to prove that drift produces failures. Runner selection and
exit-code propagation are executable evidence; content guards establish the
playbook wiring only. This does not establish real-project adoption or execution
of another project's CI.

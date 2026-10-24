# Configured review procedure

Read from EXECUTOR-CORE.md "Configured review" when the approved `## Reviewers`
section lists reviewers, when the simplify pass starts and not earlier. It runs
beside that pass, before the milestone closes.

Apply only configured criteria whose scopes cover the diff. Each needs a
published source supporting its explicit heuristic and scope (DESIGN.md
"Reviewer configuration"); reject unsupported entries and report the reason.
Never impersonate an author or invent their verdict. No finding is required
per author or criterion.

For each proposed finding, require a diff location (`path:line`), configured
criterion and concrete consequence. Cite the implementation, test or interaction
that supports that consequence. A style preference, a name, or a smell without
investigation is insufficient. Drop unsupported objections from the findings.

Deduplicate findings about the same underlying issue, merging their locations,
evidence and applicable criteria into one finding rather than one per reference.
Resolve competing advice against the project principles and approved milestone
contract. Respect explicitly approved, reasoned exceptions within their bounds.
Reject an advisory suggestion that would break a binding constraint; for example,
do not remove an ownership check to simplify a private-record operation.
An unresolved contradiction between binding requirements is a blocker under
"Operating mode"; report it rather than rewriting a principle or requirement.

Only confirmed findings within the milestone scope become tasks under that
milestone. Apply the mode's test timing to each fix and re-run applicable tests
and the simplify pass. Report out-of-scope findings and rejected objections with
their reasons; they do not expand the milestone or create tasks on their own.


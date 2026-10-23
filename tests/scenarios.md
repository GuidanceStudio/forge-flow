# Workflow acceptance scenarios

Content assertions guard the playbooks' instructions. Reader scenarios check
application of those instructions; executable fixtures check their documented
examples. Their observed output is separate evidence, not an automated guarantee
of future model behaviour.

## M76 — Approved principles persist and constrain a resumed run

**Setup:** a temporary project has a README stating that records belong to their
owner, existing instruction files, and no principles document. The user approves
a proposed plan and these three principles:

- `P1`: private records stay within their owner's account. Ownership isolation
  wins over convenient cross-account reporting. Anonymous exports are outside scope.
- `P2`: the established stack decides the integration shape. Existing project
  conventions win over a new preferred runtime. A parallel application stack is
  outside scope.
- `P3`: missing mandatory secrets stop startup. Visible failure wins over a
  default credential that appears to work. Embedded production credentials are
  outside scope.

**Design action:** persist the approved plan and principles, show one linked
instruction snippet per principle, then end the design session. Save a binding
decision citing `P1` only if the approved plan actually settles one.

**Expected:** root `PRINCIPLES.md` contains the approved numbered text; instruction
files are left for the user to update. A new reader loads the saved document
before execution. The decision “export all owners' records without ownership
checks” is blocked when no approved exception is supplied. An `Exception:` reason
alone does not confer approval. With explicit approval, a recorded exception
names `P1`, states its reason, and does not silently rewrite the principle.

**Observed:** an independent reader persisted P1–P3 and the approved plan in a
temporary project, then re-read the principles and decision log from disk. The
no-exception and reason-only candidates left the log unchanged; explicit fixture
approval recorded the exception once with `Principle: P1` and its reason.
Principles and instruction files stayed unchanged. A legacy project without a
principles document continued without creating one. Persistence/integrity checks
exited 0; the semantic verdicts came from the reader applying the playbook.

## M77 — Disk rows select scopes and drive executable assertions

**Setup:** `tests/fixtures/specs_adapter` contains an index, two split basket
TSVs, a shared basket/display TSV and an independent delivery TSV, plus their
small Python implementations. Rows use stable IDs and both mandatory-only and
optional-decision headers.

**Action:** `bash tests/test_content.sh` invokes the stdlib fixture suite. It
extracts the Python code block from EXECUTOR-CORE.md and executes it against
temporary copies of those disk files. Selection cases include a single area,
shared and split scopes, overlapping paths, glob matching, and the entire set.
Unselected TSVs are deleted in two cases to prove that they are not opened.

**Observed:** 15 fixture tests passed. The basket scope selected exactly three
TSVs and executed `SUM-001`, `SUM-002`, `FORMAT-001`; delivery selected one TSV;
basket plus delivery selected all four. Changing the on-disk expectation to 99
failed with `SUM-001: expected '99', got '5'`. Changing the input reached the
action and produced 7. An unknown ID failed by name; skipping the last row
failed with `unexecuted spec rows: ['FORMAT-001']`. Duplicate IDs, an incorrect
index count and 41 rows also failed. No supplied paths, an unmatched path, and
matched plus unmatched paths each failed explicitly instead of passing empty
or partial coverage.

Separately, removing each of the twelve new instruction anchors from an
isolated temporary repository made the content command fail on that missing
anchor. This establishes the textual guards; the adapter cases establish the
example's execution, without claiming a model will apply the playbook correctly.

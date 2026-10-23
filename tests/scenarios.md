# Workflow acceptance scenarios

Content assertions guard the playbooks' instructions. The manual scenarios below
check a reader's application of those instructions; their observed output is
separate evidence, not an automated guarantee of future model behaviour.

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

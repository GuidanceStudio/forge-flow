# Workflow acceptance scenarios

Content assertions guard the playbooks' instructions. Reader scenarios check
application of those instructions; executable fixtures check their documented
examples. Their observed output is separate evidence, not an automated guarantee
of future model behaviour.

## M87 — Full conformance differs from scoped verification

The executable tests extract the published adapter and runner into a temporary
copy of `tests/fixtures/specs_adapter`. `--all` executes four contract rows;
the basket selection executes three and reports partial scope with delivery
remaining. Changing the real delivery implementation to return 99 leaves the
basket selection green but fails full conformance and the default runner.
Empty index/area, duplicate index paths, unknown IDs and unexecuted rows fail.
Optimized Python is rejected before it can remove assertion checks.

These cases are run by `tests/test_specs_adapter.py` and
`tests/test_test_flows.py`. They exercise the shipped examples; no claim is made
that another project has adopted the flows or that remote CI has executed them.

## M88 — Security tests and actual check outcomes reach the full runner

`tests/test_security_flow.py` extracts the published threat model, implementation
and tests from SECURITY-EXAMPLE.md. Each real identity/owner/startup protection
is removed in a temporary project: its mapped test fails, and restoring the
implementation returns the flow to green. Missing mappings/tests, numeric
unknown IDs, empty/duplicate declarations, setup errors, mandatory skips and
optimized Python cannot produce passing evidence.

Stub tool processes exercise optional/mandatory command outcomes and unavailable
tooling; these are outcome-propagation tests, not completed scanner assessments.
Raw scanner output and setup tracebacks are excluded from the public JSON.
The combined runner runs security even after conformance fails, runs conformance
when security is unavailable, and propagates non-passing mandatory outcomes.
The final executable suites contain 23 adapter, 9 runner and 14 security tests;
all passed. Installer checks passed 43 cases. An actual redacted directory scan
with Gitleaks found no leaks; there are no dependency or lockfile changes.
Remote CI and existing-project adoption remain unverified.

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

**Location note (M83):** the Python code block this scenario extracts now lives in
`forge-flow/SPECS-ADAPTER.md`. The observations above were recorded when it sat in
`forge-flow/EXECUTOR-CORE.md`; the fixture cases are unchanged.

## M78 — Local characterization in a partially specified file

**Setup:** two temporary projects start with the same `orders.py`: `subtotal`
has one disk row, `TOTAL-001`; `service_fee` and `receipt_label` have none. The
approved change fixes `service_fee(100)` from its observed, buggy result 20 to
10. Discovery reports coverage per operation as partial, despite an index scope
matching the whole file. `receipt_label` is unrelated to the change.

**Action:** a reader applied CORE's joining-existing-project instructions and
the TDD/IDD loops separately. In each project, the reader added `FEE-001` with
the observed result 20 and a named characterization test reading that row.
`python3 -B -m unittest -v test_orders` ran two tests green before any edit to
`orders.py`; a byte-for-byte comparison verified the implementation was unchanged.
The observation and approved target were recorded separately.

**Observed TDD:** revising the same `FEE-001` expectation to 10 and writing its
change test before implementation produced `AssertionError: 20 != 10 : FEE-001`
(exit 1). Fixing the implementation then produced two passing tests (exit 0).

**Observed IDD:** the characterization run was green before implementation.
The reader fixed the implementation first, then revised `FEE-001` to 10 and
wrote the change test. The first change-test run passed both tests (exit 0).
An isolated mutation restoring the bug made that change test fail with
`20 != 10 : FEE-001`; restoring the fix returned it to green. Isolated mutations
also proved both characterization tests could fail on a changed observed result.

**Final checks:** each project still had only `TOTAL-001` and `FEE-001`, with
`FEE-001` expecting 10. The observed 20 remained evidence, not an active bug
snapshot. `subtotal` and `receipt_label` source stayed unchanged; `receipt_label`
still had no row and remained unspecified. The index retained `path`, `scope`,
`rows`, now counting two specific behaviours, without claiming complete coverage.
Commands and write order were recorded during execution. This is an observed
application of the playbooks, not an automated guarantee of future model choices.

## M79 — Configured review consolidates evidence and respects constraints

**Setup:** a temporary profile-update diff swallows a storage error and returns
success. Two proposed objections describe that same cause. Other objections
request an unsupported function-to-class change, remove an ownership guard, or
flag newly added token logging outside the milestone's scope. Saved principles
require owner isolation and honest persistence results, with no approved exception.
The saved reviewer table supplies published sources, explicit heuristics and scopes.

**Action:** an independent reader applied the configured-review instructions,
inspected the diff and configuration, and ran `python3 probe.py`. It observed
false success after storage failure and rejection of a cross-owner write. A
second runtime probe confirmed the token reached logging and a successful save
still returned success after one write.

**Observed:** the two storage objections consolidated into one finding at
`src/profile.py:6-8`, with `C-SMELL`, reproduction evidence and the consequence
that callers can discard input after false success. Only this confirmed,
in-scope cause produced proposed test/fix/verification tasks. The token issue
at `src/notifications.py:5`, under `C-THREAT`, stayed report-only. The class
preference was rejected without a configured criterion or consequence; ownership
removal was rejected against P1 and the milestone contract. No finding was
required for the interface reference.

With only `C-SMELL` changed to investigating duplicated domain validation, the
same diff no longer qualified for that configured finding; the token finding
remained. The independent completion gate still blocked false success against
P2 and the approved contract. Removing a heuristic therefore did not authorize
shipping the defect. The reader also verified that absent configuration does
not install defaults, and a milestone demanding removal of ownership without
an approved exception creates a binding-requirement blocker. These are observed
reader judgements backed by executed probes, separate from textual guard tests.

## M80 — Extract shared meaning within scope, and keep independent concepts apart

**Action:** a reader applied rung 5 and its bounded-search rule to four temporary
contracts and Python snippets, then recorded an explicit decision for each.
`python3 -B probe.py` ran in each fixture; all four commands exited 0.

**Observed decisions:**

- Invoice and reminder functions expose the same payment due date under one
  45-day settlement policy. Both callers and a shared policy function were in
  scope. Extraction to `payment_due_date` qualified because the concept and its
  reason to change were shared; both sample outputs stayed unchanged.
- Returns and trials used identical 30-day arithmetic, with separate policy
  owners and independent change reasons. The reader kept them separate. A
  trial-offer change in an in-memory copy produced 14 days while returns stayed
  30, illustrating the coupling a shared duration policy would introduce.
- A private label helper had one caller and no required seam or boundary. The
  reader kept formatting inline; populated and empty-code label outputs matched.
- Web and batch refund deadlines shared a seven-day rule, but batch edits and
  a shared dependency were excluded by the display milestone. The reader read
  that relevant neighbour and reported the possible extraction without a task;
  the probe verified both source files stayed byte-for-byte unchanged.

The naming examples were read as action, domain role, state and observable
access rule for function, class, variable and test respectively. These semantic
and scope decisions came from the reader applying the contract; executed probes
checked sample behaviour, and content guards separately protect the instructions.

## M81 — Approved threats produce negative tasks and same-cause variants

**Planning action:** a reader prepared a complete proposal for private record
reads and required startup configuration. It named record contents, trusted
identity and signing configuration as assets, with caller/handler/store and
configuration/startup boundaries and flows. Relevant STRIDE prompts identified
missing identity, cross-owner disclosure and unsafe default startup; unrelated
categories/components were scoped explicitly. Five negative tasks mapped the
unenforced assumptions to list/detail ownership, list/detail without identity,
and startup without the required secret.

The existing `THREATS.md` and devplan stayed unchanged during Phase 3. After an
explicit fixture approval of the complete proposal, Phase 4 persisted the plan
and proposed threat section exactly, preserving the unrelated existing section.
This was an approval fixture for the walkthrough, not inferred user permission.

**Execution action:** separate TDD and IDD projects started with own-record and
public-health coverage, while the affected negative behaviours were unspecified.
`python3 -B -m unittest -v test_records` ran seven characterization tests green
before implementation edits; a source comparison confirmed the baseline order.
Observed disclosure and default startup were recorded separately from the target.

**Observed TDD:** the initial list/auth/startup change tests failed in three
specific cases before their fix, then all seven tests passed. After that fix,
inspection and executed detail probes found the same missing identity and owner
checks: alpha could read beta's record, and anonymous detail returned a record.
The two detail negative variants failed before the second fix, then all seven
tests passed again. Permission/startup tests asserted the intended error types
and messages, while list ownership asserted the exact permitted record set.

**Observed IDD:** the same seven baseline tests passed before edits. Each fix
preceded its change-test write, including the detail variants found after the
list fix; each first change-test run was green. An isolated restoration of the
original omissions failed all five negative cases; restoring the fixes returned
seven tests to green.

Public health retained its declared public policy. A same-cause omission in an
explicitly excluded legacy export was reported with the needed regression case,
without editing it or adding a task. The public operation and excluded export
source stayed unchanged. These recorded reader decisions and command outputs
are separate from the instruction-anchor guards.

## M82 — Actual check outcomes control completion and shipping

**Action:** an independent reader applied Security verification, Quality,
Commit & push, Completion and Common rules to five controlled case files and
their project policy. Scanner, exploit and CI records were supplied inputs;
no actual scan, credential validation, exploit, CI or placeholder command ran.
The observations below are the reader's classifications and gate decisions.

**Observed:** a supplied detector result for credential exposure in a test file
remained a confirmed critical finding without requiring an application exploit
path. Uncertain application reachability stayed a concern to verify; an
unproven quota suggestion stayed optional hardening. Values remained redacted.

Mandatory checks with `failed`, `error` and `skipped` outcomes each blocked
completion and shipping. Optional unavailable or inapplicable checks remained
visible without becoming mandatory. General execution/push permission did not
accept a risk. Remediation cleared the corrected finding; policy-permitted
explicit acceptance applied only to its recorded revision and preview scope,
preserving the actual outcome. Acceptance forbidden by policy stayed blocked.

A mandatory CI failure after an approved validation upload kept the milestone
in progress and blocked completion and remaining shipping. Without an agreed
validation route, the reader reported the blocker instead of landing first or
inventing a branch. The manual-review exception in `DEC-1` remained intact;
unavailable optional second-model review did not imply a second opinion.

The reader found no residual contradiction in these cases. Read-only source
and fixture inspection exited 0; only its temporary report was written. These
judgements are separate from the instruction-anchor and coherence mutations,
which verify textual guards rather than an automated security classifier.

## M85 — Optional procedures load only where they apply

**Setup:** an existing project with `specs/INDEX.tsv` and `PRINCIPLES.md`; the
milestone changes `service_fee` in `src/orders.py`. Four cases: TDD with no
`## Reviewers` section and a specified baseline; TDD with one reviewer and a
specified baseline; TDD with no reviewers and no row for `service_fee`; IDD with
one reviewer and no row for `service_fee`.

**Action:** a reader given only the skill payload reports which files it opens
before the first test or line of code, and when it reads the review procedure.

**Observed:** in the first two cases neither `CHARACTERIZATION.md` nor
`SPECS-ADAPTER.md` was opened. In the last two, `CHARACTERIZATION.md` was read
before editing and the baseline was run green before implementation, exempt from
TDD's red rule and IDD's after-code rule. `REVIEW.md` was never opened with no
reviewers, and was opened at the simplify pass, after the code, when a reviewer
was listed. The reader found one ambiguity: the preflight and "Configured review"
wording allowed reading `REVIEW.md` before coding. The text now says to read it
at the simplify pass, not in preflight.

**Loaded words, `EXECUTOR-CORE.md` and the files it routes to**, against the
revision before this change (9,447 words): no reviewers and a specified baseline
9,117 (-330); reviewers listed 9,373 (-74); no row for the behaviour 9,291 (-156);
both 9,547 (+100, the two pointers and the two file headers).


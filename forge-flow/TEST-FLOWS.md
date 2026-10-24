# Required test flows

Read this procedure before planning test changes or wiring the runner. It applies
to every project, including libraries and skill packages; the runnable-app guard
in SCAFFOLD.md does not exempt other projects from verification.

## Runner and evidence

Expose `conformance` and `security` as named selections in the project's normal test
command. Reuse framework suites, markers or existing commands. A flow groups
tests by the contract they verify; unit, integration and live remain execution
levels. Keep one test implementation when it belongs to several selections, and
deduplicate test identities in a combined run. Do not add a testing framework,
DSL or generic execution engine for these flows.

The default/full run includes every required flow. Wire the same commands into
the project's existing authorized CI gates; the approved plan must name runner
and CI changes. Without authorization, report the missing wiring rather than
changing policy during review. A library or skill uses its native commands
without scaffolding an application stack.

Record the flow, full/partial scope, requirement IDs, test/check identities,
command, checked revision/worktree and actual outcomes. Include counts and IDs
for passed, failed and unverified cases, with reasons. An empty suite or missing
mapping is incomplete, never a pass. Skipped tests and collection/setup errors
are unverified; a zero process exit code alone does not establish conformance.
A partial/fast run cannot substitute for full verification before completion.

## Conformance

Maintain a dedicated `conformance` test module/suite, selectable through the
normal runner. Trace each approved behaviour requirement to its stable spec ID,
the implementation it exercises, and a test assertion. Use the existing
`specs/<area>.tsv` contracts; do not create a competing requirements inventory.
During design, map every affected requirement to rows and test tasks, including
requirements still missing rows. Add those rows within the approved milestone.

Full conformance executes every row in every area listed in `specs/INDEX.tsv`,
including areas outside the current diff. Read inputs and expectations from disk
and exercise actual implementation behaviour. IDs and test names alone do not
prove that an assertion ran. Fail for behavioural drift, unknown or duplicate
IDs, inconsistent index entries, or declared rows without executed assertions.
An empty index/area or missing adapter is incomplete and returns non-zero.

For focused development, the many-to-many scope rules in EXECUTOR-CORE.md select
the relevant union. Execute every selected row and label the result partial;
report the selected and remaining areas. Keep full execution explicitly
available, for example the adapter's `--all` selection.

Complete execution of declared specs does not establish complete specification
of the codebase. Keep affected gaps and unrelated unspecified legacy operations
visible. Characterize affected existing behaviour before changing it; do not
backfill unrelated operations or bless observed bugs as desired requirements.

Run full conformance before marking a milestone done or claiming completion.
Required rows without passing evidence block the claim, including live rows
whose prerequisites are unavailable. Record what remains unverified and use an
agreed CI validation route when required; never relabel a skip as a pass.

## Security

Maintain a dedicated `security` flow, selectable through the same runner and
included in default/full runs and authorized CI. Reuse negative tests across
the existing unit/integration/live levels; a test can belong to conformance and
security without being copied or run twice in the combined selection.

Preserve the approved threat model and give the affected threats stable IDs.
Trace threat ID → control → negative test or check, including the expected
rejection, error and forbidden side effects. Use the threat model and framework's
existing metadata/fixtures as the mapping; do not add a parallel security DSL.
Each applicable declared threat needs an executed verification, or an explicit
policy-permitted exception. Check unknown IDs, missing/removed tests, collection
errors and skipped mandatory cases; test discovery or a matching test name alone
is not passing evidence. An empty flow cannot establish verification. When no
threat applies, record why and run the applicable project-policy checks.

Run the mapped negative cases against the actual controls, with TDD/IDD timing
and characterization rules unchanged. Assert the forbidden action's outcome and
side effects, not only an HTTP status or a mock call. Prove tests can fail by
removing the relevant protection in an isolated fixture, then restore it and
confirm green. Use test resources; live tests keep the non-production boundary.

Include applicable secret, dependency/lock and static checks from the approved
plan, stack and project policy. Do not impose an unrelated scanner, add a tool
without authorization or replace an approved manual review with automation.
Record applicability, required/optional status, command, revision, actual outcome
and reason using EXECUTOR-CORE.md "Security verification". A scanner result does
not replace the behavioural cases; optional unavailable tools stay visible as
skipped, and no scan is invented when the tool is unavailable.

Every mandatory check must have passing evidence before completion, or the
explicit exception allowed by the existing security gate. A mandatory check's
failure, setup error, missing mapping or unavailable prerequisite returns
non-zero from the raw flow. It blocks readiness/shipping unless the existing
gate permits a documented exception. An accepted exception changes that gate,
not the raw exit code or the underlying failed/error/skipped outcome. Optional
non-passes remain visible without blocking solely because they are non-passing;
critical findings still follow the existing gate regardless of check optionality.
Enforce the same gate in full runs and authorized CI, retaining the existing
critical-finding and validation-checkpoint rules.

## Worked examples

Open [`SPECS-ADAPTER.md`](SPECS-ADAPTER.md) when creating the first spec adapter;
it shows full and focused execution. Open [`FLOW-EXAMPLE.md`](FLOW-EXAMPLE.md)
when wiring the first runner. These are project-specific examples executed by
this repository's fixture tests, not a universal runner to install unchanged.
Open [`SECURITY-EXAMPLE.md`](SECURITY-EXAMPLE.md) when creating the first security
flow; it maps concrete threat IDs to negative tests and check outcomes.

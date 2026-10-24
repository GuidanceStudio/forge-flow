# Required test flows

Read this procedure before planning test changes or wiring the runner. It applies
to every project, including libraries and skill packages; the runnable-app guard
in SCAFFOLD.md does not exempt other projects from verification.

## Runner and evidence

Expose each required flow as a named selection in the project's normal test
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

## Worked examples

Open [`SPECS-ADAPTER.md`](SPECS-ADAPTER.md) when creating the first spec adapter;
it shows full and focused execution. Open [`FLOW-EXAMPLE.md`](FLOW-EXAMPLE.md)
when wiring the first runner. These are project-specific examples executed by
this repository's fixture tests, not a universal runner to install unchanged.

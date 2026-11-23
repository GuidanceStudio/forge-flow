# Principles

Read by design before a plan is proposed and by the executor before every run.
A milestone that departs from one needs an approved exception in `DECISIONS.md`.

## P1: The public payload names nothing outside forge-flow
The privacy of other projects wins over citing where a measurement came from; the number stays and its origin goes.
Non-goal: an automated name-matching guard (DEC-1).

## P2: Delegation rules name the guarantee, never the mechanism
A stated invariant wins over a rule about which tool may run which command.
Non-goal: per-tool command allowlists inside the payload (DEC-2).

## P3: The milestone budget stays bounded
A fixed word budget per milestone wins over the completeness of its prose; detail that does not fit goes to `docs/`.
Non-goal: raising the budget for one milestone (DEC-3).

## P4: One flat payload serves every assistant
Copying `forge-flow/` is a complete install, and assistant-neutral wording wins over a feature that exists for one assistant.
Non-goal: a per-assistant fork of the payload or an installer that wraps it.

## P5: Optional procedures load only when applicable
The context a run spends wins over having every procedure inlined in the entry file.
Non-goal: a single large `SKILL.md` that carries every route.

## Reviewers

| Criterion | Published source | Heuristic | Applicable scope |
|---|---|---|---|
| C-TEST | [Kent Beck, Test Driven Development: By Example](https://www.informit.com/store/test-driven-development-by-example-9780321146533) | Check the failing-test, green and refactor cycle under the selected mode's timing rules. | `tests/**` and the payload rules they pin |
| C-SMELL | [Martin Fowler, Code Smell](https://martinfowler.com/bliki/CodeSmell.html) | Investigate a smell for a concrete problem; the smell alone does not justify a change. | `tests/**`, `.github/**` |
| C-INTERFACE | [John Ousterhout, Code Review](https://web.stanford.edu/~ouster/cs190-winter24/lectures/codeReview2/) | Prefer simple interfaces that hide implementation knowledge; inspect what callers must know. | The payload's route entry points in `forge-flow/SKILL.md` and the README install steps |
| C-THREAT | [Adam Shostack, Threat Modeling](https://shostack.org/resources/threat-modeling) | Ask what is being built, what can go wrong, what mitigates it and how mitigation is verified. | `.github/**` and the distribution instructions in `README.md` |

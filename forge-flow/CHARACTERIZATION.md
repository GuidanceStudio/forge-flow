# Characterization procedure

Read from EXECUTOR-CORE.md "Joining an existing project" when the behaviour a
milestone changes has no specified baseline.

Read the implementation and run it to observe its current result, write a row from
that observation, and add a test reading the row from disk.

Label characterization as observed baseline in the test name and run evidence;
observations do not approve bugs. For a bug fix, preserve the observed result
in the evidence separately from the approved desired result. When writing the
mode's change test, revise the affected row's expectation to that desired result,
keeping its stable ID. The final active row and test assert the corrected
behaviour; do not keep a contradictory snapshot of the bug as a requirement.
An unchanged baseline can remain as regression coverage.

This preliminary baseline is exempt from the modes' change-test timing. TDD's
change tests still start red before implementation; IDD's change tests are
written after implementation. Characterization tests that remain as guards
still follow "Prove it can fail"; green baseline timing does not waive that
policy.

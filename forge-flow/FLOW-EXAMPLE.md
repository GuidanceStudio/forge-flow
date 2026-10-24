# Executable flow runner example

This combines the small projects in SPECS-ADAPTER.md and SECURITY-EXAMPLE.md.
Save the spec adapter as `test_specs.py`, the three security example blocks
under their documented names, and the block below as `run_tests.py`.
`python3 run_tests.py conformance` verifies every declared contract;
`python3 run_tests.py security` runs the mapped security tests and policy checks;
`python3 run_tests.py` or `python3 run_tests.py all` runs every required flow.
The same command can be used by its CI job. Existing projects keep their native
runner and add equivalent selections, together with their established tiers.

This example has disjoint commands. If framework selections overlap, use its
native union/deduplication mechanism so a combined run executes each test once.
The child adapter rejects empty or incomplete verification. The runner preserves
child output, attempts every selected flow, and exits non-zero for any non-pass.
Focused adapter runs remain available directly and constitute partial evidence.
The security child preserves each check's outcome, including optional skips.
For the security child, exit 1 is a non-passing mandatory verification and exit 2
is a setup/execution error. The parent prints each flow's status and returns 1
when any selected flow is non-passing.
An approved policy exception changes the completion gate, not the recorded check
outcome or the raw flow's non-zero exit code. Record it under Security verification;
never hide the failure with an unconditional shell success.

<!-- flow-runner-example -->
```python
from pathlib import Path
import subprocess
import sys


commands = {
    "conformance": [sys.executable, "test_specs.py", ".", "--all"],
    "security": [sys.executable, "test_security.py"],
}
arguments = sys.argv[1:] or ["all"]
if len(arguments) != 1 or arguments[0] not in {"all", *commands}:
    raise SystemExit("usage: run_tests.py [all|conformance|security]")
selected = list(commands) if arguments[0] == "all" else arguments
nonpassing = False
for flow in selected:
    command = commands[flow]
    if not Path(command[1]).is_file():
        status = "error"
    else:
        result = subprocess.run(command, check=False)
        status = {0: "passed", 1: "failed"}.get(result.returncode, "error")
    print(f"{flow}: {status}", flush=True)
    nonpassing |= status != "passed"
raise SystemExit(1 if nonpassing else 0)
```

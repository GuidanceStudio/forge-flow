# Executable flow runner example

This extends the small project in SPECS-ADAPTER.md. Save its adapter as
`test_specs.py` and the block below as `run_tests.py` in that project.
`python3 run_tests.py conformance` verifies every declared contract;
`python3 run_tests.py` or `python3 run_tests.py all` runs every required flow.
The same command can be used by its CI job. Existing projects keep their native
runner and add equivalent selections, together with their established tiers.

This example has disjoint commands. If framework selections overlap, use its
native union/deduplication mechanism so a combined run executes each test once.
The child adapter rejects empty or incomplete verification. The runner preserves
child output, attempts every selected flow, and exits non-zero for any non-pass.
Focused adapter runs remain available directly and constitute partial evidence.

<!-- flow-runner-example -->
```python
from pathlib import Path
import subprocess
import sys


commands = {
    "conformance": [sys.executable, "test_specs.py", ".", "--all"],
}
arguments = sys.argv[1:] or ["all"]
if len(arguments) != 1 or arguments[0] not in {"all", *commands}:
    raise SystemExit("usage: run_tests.py [all|conformance]")
selected = list(commands) if arguments[0] == "all" else arguments
nonpassing = False
for flow in selected:
    command = commands[flow]
    if not Path(command[1]).is_file():
        status = "error"
    else:
        result = subprocess.run(command, check=False)
        status = "passed" if result.returncode == 0 else "failed"
    print(f"{flow}: {status}", flush=True)
    nonpassing |= status != "passed"
raise SystemExit(1 if nonpassing else 0)
```

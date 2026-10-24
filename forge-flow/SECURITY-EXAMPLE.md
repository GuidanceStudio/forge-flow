# Executable security example

This small project protects an owner's record and requires startup configuration.
Save the following blocks as `THREATS.md`, `security_app.py` and `test_security.py`
in the same directory. Run `python3 test_security.py`; the flow runner invokes
that same command. Reuse an existing project threat model and test framework in
real projects rather than installing this example unchanged.

The threat model is the source of declared IDs. Each ID maps to a real unittest
and its exercised control. Unknown threats, missing tests and empty verification
cannot pass. Exit 0 means all mandatory checks passed; exit 1 means failed or
unverified mandatory checks; exit 2 denotes setup/execution errors. JSON preserves
each check's actual `passed`, `failed`, `error` or `skipped` outcome and reason.
Raw scanner output and tracebacks are excluded from shared JSON; inspect and
redact local diagnostics before sharing detailed findings.

The example policy makes the three threat tests mandatory and a Bandit check
optional. An unavailable optional tool stays skipped; it becomes blocking if
the project's approved policy makes that check mandatory. Bandit is a real tool,
not installed by the example, and no scanner is reimplemented here. Tests of
scanner exit codes use stub tools and do not constitute a real security scan.
The configuration value below is test-only data, never a credential.

<!-- security-threats-example -->
```markdown
# Threat model

Caller identity and record ownership cross the caller/record boundary; startup
configuration crosses the configuration/application boundary.

### THREAT-IDENTITY
An anonymous caller reads a protected record. Control: reject absent identity.
Verify `SecurityTests.test_anonymous_access_is_refused` before any record return.

### THREAT-OWNER
A caller reads another owner's record. Control: require matching ownership.
Verify `SecurityTests.test_cross_owner_access_is_refused`, preserving own access.

### THREAT-STARTUP
The process starts without configured protection. Control: require a nonempty,
non-placeholder startup value. Verify `SecurityTests.test_startup_requires_secret`.
```

<!-- security-implementation-example -->
```python
def read_record(identity, owner):
    if not identity:
        raise PermissionError("identity required")
    if identity != owner:
        raise PermissionError("owner required")
    return "protected record"


def start(secret):
    secret = (secret or "").strip()
    if not secret or secret.startswith("<REPLACE_WITH_"):
        raise RuntimeError("startup configuration required")
    return True
```

<!-- security-tests-example -->
```python
import importlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import unittest


BANDIT_REQUIRED = False


class SecurityTests(unittest.TestCase):
    def setUp(self):
        self.app = importlib.import_module("security_app")

    def test_anonymous_access_is_refused(self):
        self.assertEqual(self.app.read_record("alice", "alice"), "protected record")
        with self.assertRaisesRegex(PermissionError, "identity required"):
            self.app.read_record(None, "alice")

    def test_cross_owner_access_is_refused(self):
        self.assertEqual(self.app.read_record("alice", "alice"), "protected record")
        with self.assertRaisesRegex(PermissionError, "owner required"):
            self.app.read_record("alice", "bob")

    def test_startup_requires_secret(self):
        self.assertTrue(self.app.start("test-only-configuration"))
        for missing in (None, "", "   ", "<REPLACE_WITH_SIGNING_SECRET>"):
            with self.subTest(missing=missing):
                with self.assertRaisesRegex(RuntimeError, "startup configuration required"):
                    self.app.start(missing)


def main():
    reports = []
    setup_error = False

    def record(check_id, required, status, reason):
        reports.append(dict(id=check_id, required=required, status=status, reason=reason))

    if not __debug__:
        record("PYTHON-MODE", True, "error", "optimized Python cannot verify this example")
        print(json.dumps(dict(flow="security", scope="full", checks=reports)))
        return 2

    try:
        declared = re.findall(r"^### (THREAT-\S+)[ \t]*$", Path("THREATS.md").read_text(), re.M)
        if not declared or len(declared) != len(set(declared)):
            raise ValueError("empty threat source or duplicate threat IDs")
    except (OSError, ValueError) as error:
        record("THREAT-MAPPING", True, "error", str(error))
        print(json.dumps(dict(flow="security", scope="full", checks=reports)))
        return 2

    checks = {
        "THREAT-IDENTITY": "test_anonymous_access_is_refused",
        "THREAT-OWNER": "test_cross_owner_access_is_refused",
        "THREAT-STARTUP": "test_startup_requires_secret",
    }
    for threat in declared:
        method = checks.get(threat)
        if method is None or not callable(getattr(SecurityTests, method, None)):
            record(threat, True, "error", "missing test or mapping for declared threat")
            continue
        result = unittest.TestResult()
        unittest.TestSuite([SecurityTests(method)]).run(result)
        if result.errors:
            status, reason = "error", "test setup/execution failed; inspect sanitized diagnostics"
            setup_error = True
        elif result.failures or result.unexpectedSuccesses:
            status, reason = "failed", "security assertion failed"
        elif result.skipped or result.expectedFailures:
            status = "skipped"
            reason = result.skipped[0][1] if result.skipped else "expected failure is unverified"
        elif result.testsRun != 1:
            status, reason = "error", "mapped test did not execute"
        else:
            status, reason = "passed", f"SecurityTests.{method} assertions passed"
        record(threat, True, status, reason)
    for stale in sorted(set(checks) - set(declared)):
        record(stale, True, "error", "mapped test has no declared threat")

    tool = shutil.which("bandit")
    if tool is None:
        record("CHECK-BANDIT", BANDIT_REQUIRED, "skipped", "Bandit unavailable on PATH")
    else:
        try:
            result = subprocess.run([tool, "-q", "security_app.py"],
                                    capture_output=True, text=True, check=False)
            status = {0: "passed", 1: "failed"}.get(result.returncode, "error")
            reason = f"Bandit exited {result.returncode}; review sanitized diagnostics separately"
            record("CHECK-BANDIT", BANDIT_REQUIRED, status, reason)
            setup_error |= BANDIT_REQUIRED and status == "error"
        except OSError as error:
            record("CHECK-BANDIT", BANDIT_REQUIRED, "error", str(error))
            setup_error |= BANDIT_REQUIRED

    print(json.dumps(dict(flow="security", scope="full", checks=reports)))
    if setup_error:
        return 2
    return int(any(check["required"] and check["status"] != "passed" for check in reports))


if __name__ == "__main__":
    raise SystemExit(main())
```

The repository's fixture tests extract these exact blocks, execute their tests,
remove each real protection and require its mapped assertion to fail, then
restore the implementation and require passing evidence again. They also check
missing mappings, mandatory skips, setup errors and unavailable optional checks.
An optional scanner result does not replace threat tests or the project's
security review and completion gate.

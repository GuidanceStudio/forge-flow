"""Execute the published security example, including real protection removals."""

import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
DOCUMENT = ROOT / "forge-flow/SECURITY-EXAMPLE.md"


def install_example(project: Path):
    """Write only the three example files into an existing fixture project."""
    text = DOCUMENT.read_text()
    for marker, language, target in (
        ("security-threats-example", "markdown", "THREATS.md"),
        ("security-implementation-example", "python", "security_app.py"),
        ("security-tests-example", "python", "test_security.py"),
    ):
        match = re.search(r"<!-- " + marker + r" -->\n```" + language
                          + r"\n(.*?)\n```", text, re.S)
        if match is None:
            raise AssertionError(f"missing executable example: {marker}")
        (project / target).write_text(match.group(1) + "\n")


class SecurityFlowTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.project = Path(self.directory.name)
        install_example(self.project)

    def run_security(self, *, env=None, flags=()):
        return subprocess.run(
            [sys.executable, *flags, "test_security.py"], cwd=self.project,
            env={**os.environ, "PATH": "", **(env or {})},
            capture_output=True, text=True, timeout=10,
        )

    def report(self, result):
        return {check["id"]: check for check in json.loads(result.stdout)["checks"]}

    def change(self, path, old, new):
        file = self.project / path
        text = file.read_text()
        self.assertEqual(text.count(old), 1, f"ambiguous mutation: {old}")
        file.write_text(text.replace(old, new))

    def test_all_declared_threats_have_passing_tests(self):
        result = self.run_security()
        self.assertEqual(result.returncode, 0, result.stderr)
        checks = self.report(result)
        for threat in ("THREAT-IDENTITY", "THREAT-OWNER", "THREAT-STARTUP"):
            self.assertEqual(checks[threat]["status"], "passed")
            self.assertTrue(checks[threat]["required"])
            self.assertTrue(checks[threat]["reason"])
        self.assertEqual(checks["CHECK-BANDIT"]["status"], "skipped")
        self.assertFalse(checks["CHECK-BANDIT"]["required"])
        self.assertIn("unavailable", checks["CHECK-BANDIT"]["reason"])

    def test_removing_each_real_protection_fails_its_mapped_test_then_restores(self):
        application = self.project / "security_app.py"
        original = application.read_text()
        for condition, threat in (
            ("if not identity:", "THREAT-IDENTITY"),
            ("if identity != owner:", "THREAT-OWNER"),
            ('if not secret or secret.startswith("<REPLACE_WITH_"):', "THREAT-STARTUP"),
        ):
            with self.subTest(threat=threat):
                self.assertEqual(original.count(condition), 1)
                application.write_text(original.replace(condition, "if False:"))
                result = self.run_security()
                self.assertEqual(result.returncode, 1, result.stderr)
                self.assertEqual(self.report(result)[threat]["status"], "failed")
                application.write_text(original)
                restored = self.run_security()
                self.assertEqual(restored.returncode, 0, restored.stderr)

    def test_declared_threat_without_mapping_blocks_the_flow(self):
        source = self.project / "THREATS.md"
        original = source.read_text()
        for heading in ("THREAT-UNMAPPED", "THREAT-NEW-001", "THREAT-004  "):
            with self.subTest(heading=heading):
                threat = heading.rstrip()
                source.write_text(original + f"\n### {heading}\nUnverified protection.\n")
                result = self.run_security()
                self.assertEqual(result.returncode, 1)
                self.assertEqual(self.report(result)[threat]["status"], "error")

    def test_missing_mapped_test_blocks_the_flow(self):
        self.change("test_security.py", "def test_cross_owner_access_is_refused(self):",
                    "def removed_cross_owner_test(self):")
        result = self.run_security()
        self.assertEqual(result.returncode, 1)
        self.assertIn("missing test", self.report(result)["THREAT-OWNER"]["reason"])

    def test_empty_threat_source_and_duplicate_ids_are_setup_errors(self):
        threat_file = self.project / "THREATS.md"
        original = threat_file.read_text()
        for text in ("# Empty threat model\n", original + "\n### THREAT-OWNER\n"):
            with self.subTest(text=text):
                threat_file.write_text(text)
                result = self.run_security()
                self.assertEqual(result.returncode, 2)
                self.assertEqual(self.report(result)["THREAT-MAPPING"]["status"], "error")

    def test_missing_threat_source_and_application_setup_errors_are_not_passes(self):
        for filename in ("THREATS.md", "security_app.py"):
            with self.subTest(filename=filename):
                file = self.project / filename
                original = file.read_text()
                file.unlink()
                result = self.run_security()
                self.assertEqual(result.returncode, 2, result.stderr)
                self.assertIn("error", [item["status"] for item in self.report(result).values()])
                file.write_text(original)

    def test_mandatory_skip_blocks_completion(self):
        self.change("test_security.py", "    def test_anonymous_access_is_refused(self):",
                    '    @unittest.skip("fixture prerequisite unavailable")\n'
                    "    def test_anonymous_access_is_refused(self):")
        result = self.run_security()
        self.assertEqual(result.returncode, 1)
        check = self.report(result)["THREAT-IDENTITY"]
        self.assertEqual(check["status"], "skipped")
        self.assertIn("fixture prerequisite unavailable", check["reason"])

    def test_empty_mapping_cannot_produce_a_passing_empty_suite(self):
        self.change("test_security.py", "    for threat in declared:",
                    "    checks = {}\n    for threat in declared:")
        result = self.run_security()
        self.assertEqual(result.returncode, 1)
        self.assertTrue(all(item["status"] == "error" for key, item in self.report(result).items()
                            if key.startswith("THREAT-")))

    def test_empty_test_suite_does_not_count_as_executed_verification(self):
        self.change("test_security.py", "unittest.TestSuite([SecurityTests(method)]).run(result)",
                    "unittest.TestSuite([]).run(result)")
        result = self.run_security()
        self.assertEqual(result.returncode, 1)
        for threat in ("THREAT-IDENTITY", "THREAT-OWNER", "THREAT-STARTUP"):
            self.assertEqual(self.report(result)[threat]["status"], "error")
            self.assertIn("did not execute", self.report(result)[threat]["reason"])

    def test_optional_command_runs_and_preserves_failed_and_error_outcomes(self):
        for return_code, expected in ((0, "passed"), (1, "failed"), (2, "error")):
            with self.subTest(return_code=return_code):
                tool = self.project / "bandit"
                tool.write_text(f"#!{sys.executable}\nraise SystemExit({return_code})\n")
                tool.chmod(0o700)
                result = self.run_security(env={"PATH": str(self.project)})
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(self.report(result)["CHECK-BANDIT"]["status"], expected)

    def test_unavailable_optional_check_becomes_blocking_when_policy_requires_it(self):
        self.change("test_security.py", "BANDIT_REQUIRED = False", "BANDIT_REQUIRED = True")
        result = self.run_security()
        self.assertEqual(result.returncode, 1)
        check = self.report(result)["CHECK-BANDIT"]
        self.assertTrue(check["required"])
        self.assertEqual(check["status"], "skipped")

    def test_policy_required_command_failures_and_errors_block_the_flow(self):
        self.change("test_security.py", "BANDIT_REQUIRED = False", "BANDIT_REQUIRED = True")
        for tool_exit, flow_exit, status in ((0, 0, "passed"), (1, 1, "failed"), (2, 2, "error")):
            with self.subTest(tool_exit=tool_exit):
                tool = self.project / "bandit"
                tool.write_text(f"#!{sys.executable}\nraise SystemExit({tool_exit})\n")
                tool.chmod(0o700)
                result = self.run_security(env={"PATH": str(self.project)})
                self.assertEqual(result.returncode, flow_exit, result.stderr)
                self.assertEqual(self.report(result)["CHECK-BANDIT"]["status"], status)

    def test_scanner_output_is_not_published_without_redaction(self):
        tool = self.project / "bandit"
        tool.write_text(f"#!{sys.executable}\n"
                        'print("fixture-only-sensitive-output")\nraise SystemExit(1)\n')
        tool.chmod(0o700)
        result = self.run_security(env={"PATH": str(self.project)})
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.report(result)["CHECK-BANDIT"]["status"], "failed")
        self.assertNotIn("fixture-only-sensitive-output", result.stdout + result.stderr)

    def test_optimized_python_refuses_to_claim_verification(self):
        for arguments in ({"env": {"PYTHONOPTIMIZE": "1"}}, {"flags": ("-O",)}):
            with self.subTest(arguments=arguments):
                result = self.run_security(**arguments)
                self.assertEqual(result.returncode, 2)
                self.assertIn("optimized Python", self.report(result)["PYTHON-MODE"]["reason"])


if __name__ == "__main__":
    unittest.main()

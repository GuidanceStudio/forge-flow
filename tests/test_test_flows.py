"""Execute the runner example shipped with the skill, against disk fixtures."""

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest


sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]


def example(path, marker):
    match = re.search(r"<!-- " + marker + r" -->\n```python\n(.*?)\n```",
                      path.read_text(), re.S)
    if match is None:
        raise AssertionError(f"missing executable example: {marker}")
    return match.group(1)


class TestFlowRunnerTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.project = Path(self.directory.name) / "project"
        shutil.copytree(ROOT / "tests/fixtures/specs_adapter", self.project)
        self.runner = example(ROOT / "forge-flow/FLOW-EXAMPLE.md", "flow-runner-example")
        (self.project / "run_tests.py").write_text(self.runner)
        (self.project / "test_specs.py").write_text(
            example(ROOT / "forge-flow/SPECS-ADAPTER.md", "specs-adapter-example"))
        from test_security_flow import install_example
        install_example(self.project)

    def run_flow(self, *args, env=None):
        return subprocess.run([sys.executable, "run_tests.py", *args], cwd=self.project,
                              capture_output=True, text=True, timeout=10, env=env)

    def test_conformance_selects_every_declared_contract(self):
        result = self.run_flow("conformance")
        self.assertEqual(result.returncode, 0, result.stderr)
        report = next(json.loads(line) for line in result.stdout.splitlines()
                      if line.startswith("{"))
        self.assertEqual(report["executed"], ["DELIVERY-001", "FORMAT-001", "SUM-001", "SUM-002"])
        self.assertEqual(report["scope"], "full")
        self.assertEqual(report["remaining"], [])
        self.assertIn("conformance: passed", result.stdout)

    def test_default_and_all_include_conformance(self):
        for args in ((), ("all",)):
            with self.subTest(args=args):
                result = self.run_flow(*args)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn("conformance: passed", result.stdout)
                self.assertIn("security: passed", result.stdout)
                self.assertEqual(result.stdout.count("security: passed"), 1)
                self.assertIn("DELIVERY-001", result.stdout)

    def test_real_implementation_drift_reaches_runner_exit_code(self):
        path = self.project / "src/delivery.py"
        path.write_text("def delivery_fee(amount):\n    return 99\n")
        for flow in ("conformance", "all"):
            with self.subTest(flow=flow):
                result = self.run_flow(flow)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("DELIVERY-001", result.stderr)
                self.assertIn("conformance: failed", result.stdout)
                if flow == "all":
                    self.assertIn("security: passed", result.stdout)

    def test_security_is_independently_selectable(self):
        (self.project / "test_specs.py").unlink()
        result = self.run_flow("security")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("security: passed", result.stdout)
        self.assertNotIn("conformance:", result.stdout)

    def test_removed_security_controls_fail_the_combined_run(self):
        (self.project / "security_app.py").write_text(
            "def read_record(identity, owner):\n    return 'private'\n"
            "def start(secret):\n    return secret\n")
        result = self.run_flow("all")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("conformance: passed", result.stdout)
        self.assertIn("security: failed", result.stdout)
        self.assertIn("THREAT-IDENTITY", result.stdout)

    def test_missing_security_flow_blocks_full_verification(self):
        (self.project / "test_security.py").unlink()
        result = self.run_flow("all")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("security: error", result.stdout)
        self.assertIn("conformance: passed", result.stdout)
        focused = self.run_flow("conformance")
        self.assertEqual(focused.returncode, 0, focused.stderr)

    def test_missing_adapter_is_an_error(self):
        (self.project / "test_specs.py").unlink()
        result = self.run_flow("conformance")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("conformance: error", result.stdout)

    def test_optimized_python_cannot_remove_verification_through_runner(self):
        (self.project / "src/delivery.py").write_text(
            "def delivery_fee(amount):\n    return 99\n")
        result = self.run_flow("conformance", env={**os.environ, "PYTHONOPTIMIZE": "1"})
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("optimized Python", result.stderr)

    def test_unknown_selection_and_extra_arguments_cannot_pass(self):
        for args in (("typo",), ("conformance", "extra")):
            with self.subTest(args=args):
                result = self.run_flow(*args)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn("usage:", result.stderr)


if __name__ == "__main__":
    unittest.main()

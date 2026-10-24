"""Execute the scaffold's runner example shipped with the skill, in a temporary project."""

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
    match = re.search(r"<!-- " + marker + r" -->\n```bash\n(.*?)\n```", path.read_text(), re.S)
    if match is None:
        raise AssertionError(f"missing executable example: {marker}")
    return match.group(1)


class TestScaffoldRunner(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.project = Path(self.directory.name)
        (self.project / "run_tests.sh").write_text(example(ROOT / "forge-flow/SCAFFOLD-EXAMPLE.md", "scaffold-runner-example"))
        for tier in ("unit", "integration", "conformance", "security"):
            (self.project / "tests" / tier).mkdir(parents=True)
            (self.project / "tests" / tier / f"{tier}_ok.sh").write_text("exit 0\n")

    def tearDown(self):
        self.directory.cleanup()

    def run_tests(self, *args, env=None):
        return subprocess.run([shutil.which("bash"), "run_tests.sh", *args], cwd=self.project, capture_output=True, text=True,
                              env={**os.environ, **(env or {})})

    def test_fast_without_scope_refuses_and_prints_both_scoped_forms(self):
        r = self.run_tests("fast")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("./run_tests.sh fast <path>", r.stdout)
        self.assertIn("./run_tests.sh fast --changed", r.stdout)

    def test_a_tier_without_its_prerequisite_skips_and_says_why(self):
        bare = self.project / "bin"; bare.mkdir()
        for tool in ("bash", "date", "sort", "head", "sed", "ls"):
            os.symlink(shutil.which(tool), bare / tool)
        r = self.run_tests("integration", env={"PATH": str(bare)})
        self.assertEqual(r.returncode, 0)
        self.assertIn("SKIP integration: docker not found", r.stdout)

    def test_a_failing_test_makes_the_exit_code_non_zero(self):
        (self.project / "tests/unit/bad.sh").write_text("exit 1\n")
        r = self.run_tests("unit")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("FAIL unit tests/unit/bad.sh", r.stdout)

    def test_the_five_slowest_tests_print_on_every_run(self):
        for i in range(6):
            (self.project / f"tests/unit/t{i}.sh").write_text("exit 0\n")
        r = self.run_tests("unit")
        lines = r.stdout.split("slowest 5:\n")[1].strip().splitlines()
        self.assertEqual(len(lines), 5)

    def test_conformance_and_security_are_selectable_and_in_the_full_run(self):
        self.assertIn("ran conformance", self.run_tests("conformance").stdout)
        self.assertIn("ran security", self.run_tests("security").stdout)
        full = self.run_tests("all").stdout
        self.assertIn("ran conformance", full)
        self.assertIn("ran security", full)

    def test_the_comment_check_reports_a_planted_hit_as_file_line_and_skips_outside_a_diff(self):
        self.assertIn("SKIP comments", self.run_tests("comments").stdout)
        git = lambda *a: subprocess.run(["git", *a], cwd=self.project, capture_output=True, text=True, check=True)
        git("init", "-q"); git("-c", "user.email=t@t", "-c", "user.name=t", "add", "."); git("-c", "user.email=t@t", "-c", "user.name=t", "commit", "-q", "-m", "base")
        (self.project / "tests/unit/new.sh").write_text("echo ok\n# TODO planted\nexit 0\n")
        git("add", "."); 
        r = self.run_tests("comments", "HEAD")
        self.assertNotEqual(r.returncode, 0)
        self.assertIn("tests/unit/new.sh:2", r.stdout)


if __name__ == "__main__":
    unittest.main()

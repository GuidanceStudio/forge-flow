"""Negative tests for the threats declared in THREATS.md.

Each helper is exercised on a violating input as well as on the repository, so a
check that stops detecting its violation fails here.
"""
import re
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MACHINE_PATH = re.compile(r"(?:/home/[a-z][\w.-]*/|/Users/[a-z][\w.-]*/|~/Documents)")
# CLAUDE.md quotes the grep it tells contributors to run, so it names these patterns.
LEAK_EXEMPT = {"CLAUDE.md", "tests/test_repo_security.py", "THREATS.md"}


def machine_paths(text):
    return MACHINE_PATH.findall(text)


def mutable_refs(readme):
    return re.findall(r"(?:tree/main\b|/main/install|--branch main\b)", readme)


def workflow_violations(workflow):
    found = []
    if not re.search(r"(?m)^permissions:\s*\n\s+contents:\s*read\s*$", workflow):
        found.append("no read-only contents permission")
    if re.search(r"(?m)^\s+(?:contents|pull-requests|actions|packages):\s*write", workflow):
        found.append("write permission")
    if "pull_request_target" in workflow:
        found.append("pull_request_target trigger")
    if "secrets." in workflow:
        found.append("secret reference")
    return found


def tracked_files():
    out = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, text=True, check=True)
    return [p for p in out.stdout.splitlines() if p not in LEAK_EXEMPT]


class RepoSecurityTests(unittest.TestCase):
    def test_tracked_files_carry_no_machine_paths(self):
        self.assertEqual(machine_paths("see /home/someone/project and ~/Documents/x"),
                         ["/home/someone/", "~/Documents"])
        hits = {}
        for name in tracked_files():
            try:
                text = (ROOT / name).read_text()
            except (UnicodeDecodeError, OSError):
                continue
            found = machine_paths(text)
            if found:
                hits[name] = found
        self.assertEqual(hits, {})

    def test_readme_install_routes_do_not_track_main(self):
        self.assertTrue(mutable_refs("$skill-installer install Org/repo/tree/main/skill"))
        self.assertTrue(mutable_refs("curl https://x/org/repo/main/install.sh | bash"))
        self.assertEqual(mutable_refs((ROOT / "README.md").read_text()), [])

    def test_workflow_is_read_only_and_secretless(self):
        bad = "on:\n  pull_request_target:\npermissions:\n  contents: write\nenv: ${{ secrets.TOKEN }}\n"
        self.assertEqual(len(workflow_violations(bad)), 4)
        self.assertEqual(workflow_violations("on: push\n"), ["no read-only contents permission"])
        workflow = (ROOT / ".github/workflows/tests.yml").read_text()
        self.assertEqual(workflow_violations(workflow), [])

    def test_every_declared_threat_has_a_test(self):
        text = (ROOT / "THREATS.md").read_text()
        declared = re.findall(r"(?m)^### (THREAT-\S+)\s*$", text)
        mapped = re.findall(r"`RepoSecurityTests\.(test_\w+)`", text)
        self.assertEqual(len(declared), 3)
        self.assertEqual(len(mapped), len(declared))
        for method in mapped:
            self.assertTrue(callable(getattr(RepoSecurityTests, method, None)), method)


if __name__ == "__main__":
    unittest.main()

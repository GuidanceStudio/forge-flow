"""Execute the project-specific example read from the shared playbook."""

import csv
import io
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unittest


REPO_ROOT = Path(__file__).resolve().parents[1]
FIXTURE = REPO_ROOT / "tests/fixtures/specs_adapter"
CORE = REPO_ROOT / "forge-flow/EXECUTOR-CORE.md"


class SpecsAdapterTests(unittest.TestCase):
    def setUp(self):
        match = re.search(
            r"<!-- specs-adapter-example -->\n```python\n(.*?)\n```",
            CORE.read_text(),
            re.S,
        )
        self.assertIsNotNone(match, "EXECUTOR-CORE.md missing executable specs adapter example")
        self.adapter = match.group(1)
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.project = Path(self.directory.name) / "project"
        shutil.copytree(FIXTURE, self.project)

    def run_adapter(self, *paths, adapter=None):
        return subprocess.run(
            [sys.executable, "-c", self.adapter if adapter is None else adapter,
             str(self.project), *paths],
            capture_output=True,
            text=True,
            timeout=5,
        )

    def assert_result(self, result, selected, executed):
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(json.loads(result.stdout), {
            "selected": selected,
            "executed": sorted(executed),
        })

    def assert_failure(self, result, message):
        self.assertNotEqual(result.returncode, 0)
        self.assertIn(message, result.stderr)

    def change_tsv(self, relative, change):
        path = self.project / relative
        with path.open(newline="") as stream:
            reader = csv.DictReader(stream, delimiter="\t")
            fields, rows = reader.fieldnames, list(reader)
        change(rows)
        output = io.StringIO()
        writer = csv.DictWriter(output, fieldnames=fields, delimiter="\t", lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)
        path.write_text(output.getvalue())

    def test_shared_and_split_scopes_select_the_exact_union(self):
        self.assert_result(self.run_adapter("src/basket.py"), [
            "specs/basket-prices.tsv", "specs/basket-empty.tsv", "specs/amounts.tsv",
        ], ["SUM-001", "SUM-002", "FORMAT-001"])

    def test_one_area_does_not_open_other_tsvs(self):
        for path in (self.project / "specs").glob("*.tsv"):
            if path.name not in {"INDEX.tsv", "delivery.tsv"}:
                path.unlink()
        self.assert_result(self.run_adapter("src/delivery.py"),
                           ["specs/delivery.tsv"], ["DELIVERY-001"])

    def test_shared_scope_matches_each_file_and_ignores_unselected_tsvs(self):
        for name in ("basket-prices.tsv", "basket-empty.tsv", "delivery.tsv"):
            (self.project / "specs" / name).unlink()
        self.assert_result(self.run_adapter("src/display.py"),
                           ["specs/amounts.tsv"], ["FORMAT-001"])

    def test_all_tsvs_are_read_when_the_entire_union_is_relevant(self):
        self.assert_result(self.run_adapter("src/basket.py", "src/delivery.py"), [
            "specs/basket-prices.tsv", "specs/basket-empty.tsv",
            "specs/amounts.tsv", "specs/delivery.tsv",
        ], ["SUM-001", "SUM-002", "FORMAT-001", "DELIVERY-001"])

    def test_overlapping_changed_paths_do_not_execute_a_row_twice(self):
        self.assert_result(self.run_adapter("src/basket.py", "src/display.py", "src/basket.py"), [
            "specs/basket-prices.tsv", "specs/basket-empty.tsv", "specs/amounts.tsv",
        ], ["SUM-001", "SUM-002", "FORMAT-001"])

    def test_scope_globs_match_repository_relative_paths(self):
        self.change_tsv("specs/INDEX.tsv", lambda rows: rows[3].update(scope="src/deliv*.py"))
        self.assert_result(self.run_adapter("src/delivery.py"),
                           ["specs/delivery.tsv"], ["DELIVERY-001"])

    def test_no_affected_paths_cannot_pass_with_empty_coverage(self):
        self.assert_failure(self.run_adapter(), "no affected paths: clarify scope before testing")

    def test_unmatched_path_fails_even_beside_a_matching_path(self):
        for paths in (("src/unknown.py",), ("src/basket.py", "src/unknown.py")):
            with self.subTest(paths=paths):
                self.assert_failure(self.run_adapter(*paths),
                                    "unmatched affected paths: ['src/unknown.py']")

    def test_changed_expectation_from_disk_fails_the_assertion(self):
        self.change_tsv("specs/basket-prices.tsv", lambda rows: rows[0].update(expect="99"))
        self.assert_failure(self.run_adapter("src/basket.py"), "SUM-001: expected '99', got '5'")

    def test_changed_input_from_disk_reaches_the_action(self):
        self.change_tsv("specs/basket-prices.tsv", lambda rows: rows[0].update(when="4,3"))
        self.assert_failure(self.run_adapter("src/basket.py"), "SUM-001: expected '5', got '7'")

    def test_unknown_id_is_rejected(self):
        self.change_tsv("specs/delivery.tsv", lambda rows: rows[0].update(id="UNKNOWN-001"))
        self.assert_failure(self.run_adapter("src/delivery.py"), "unknown spec ID: UNKNOWN-001")

    def test_omitted_row_fails_coverage_instead_of_silently_passing(self):
        self.assertEqual(self.adapter.count("for row in rows:"), 1)
        omitted = self.adapter.replace("for row in rows:", "for row in rows[:-1]:")
        self.assert_failure(self.run_adapter("src/basket.py", adapter=omitted),
                            "unexecuted spec rows: ['FORMAT-001']")

    def test_duplicate_ids_fail_before_running_actions(self):
        self.change_tsv("specs/basket-empty.tsv", lambda rows: rows[0].update(id="SUM-001"))
        self.assert_failure(self.run_adapter("src/basket.py"), "duplicate spec IDs")

    def test_index_row_count_must_match_the_file_on_disk(self):
        self.change_tsv("specs/INDEX.tsv", lambda rows: rows[3].update(rows="2"))
        self.assert_failure(self.run_adapter("src/delivery.py"), "specs/delivery.tsv: row count mismatch")

    def test_area_over_40_rows_requires_a_split(self):
        self.change_tsv("specs/delivery.tsv", lambda rows: rows.extend([dict(rows[0])] * 40))
        self.change_tsv("specs/INDEX.tsv", lambda rows: rows[3].update(rows="41"))
        self.assert_failure(self.run_adapter("src/delivery.py"), "specs/delivery.tsv: split beyond 40 rows")


if __name__ == "__main__":
    unittest.main()

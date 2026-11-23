"""The repository's own runner: required flows over the existing test modules.

    python3 -I tests/run_tests.py [all|conformance|security|content]

`conformance` executes the test mapped to every row declared in specs/INDEX.tsv.
`security` executes the test mapped to every threat declared in THREATS.md.
`content` runs the content contract suite. `all` (the default) runs each test of
the five Python modules once, then reads every flow's verdict from those outcomes,
so a test mapped to a flow is never executed a second time.
Exit 0: every selected flow passed. Exit 1: a flow did not pass. Exit 2: setup error.
"""
import csv
import io
import re
import subprocess
import sys
import unittest
from pathlib import Path

sys.dont_write_bytecode = True
ROOT = Path(__file__).resolve().parents[1]
# -I drops the script directory from the path; the test modules are imported by name.
sys.path.insert(0, str(ROOT / "tests"))

MODULES = ["test_specs_adapter", "test_test_flows", "test_security_flow",
           "test_scaffold", "test_repo_security", "test_payload"]

# Spec ID -> the test that exercises the row's behaviour.
CONFORMANCE = {
    "ADAPT-001": "test_specs_adapter.SpecsAdapterTests.test_shared_and_split_scopes_select_the_exact_union",
    "ADAPT-002": "test_specs_adapter.SpecsAdapterTests.test_full_run_executes_every_indexed_area_without_affected_paths",
    "ADAPT-003": "test_specs_adapter.SpecsAdapterTests.test_full_run_detects_implementation_drift_outside_a_scoped_selection",
    "ADAPT-004": "test_specs_adapter.SpecsAdapterTests.test_empty_index_cannot_pass_as_verified_conformance",
    "ADAPT-005": "test_specs_adapter.SpecsAdapterTests.test_empty_indexed_area_cannot_pass_as_verified_conformance",
    "ADAPT-006": "test_specs_adapter.SpecsAdapterTests.test_duplicate_index_paths_fail_instead_of_being_silently_deduplicated",
    "ADAPT-007": "test_specs_adapter.SpecsAdapterTests.test_changed_expectation_from_disk_fails_the_assertion",
    "ADAPT-008": "test_specs_adapter.SpecsAdapterTests.test_unknown_id_is_rejected",
    "ADAPT-009": "test_specs_adapter.SpecsAdapterTests.test_optimized_python_cannot_silently_disable_contract_checks",
    "ADAPT-010": "test_specs_adapter.SpecsAdapterTests.test_area_over_40_rows_requires_a_split",
    "FLOW-001": "test_test_flows.TestFlowRunnerTests.test_conformance_selects_every_declared_contract",
    "FLOW-002": "test_test_flows.TestFlowRunnerTests.test_default_and_all_include_conformance",
    "FLOW-003": "test_test_flows.TestFlowRunnerTests.test_real_implementation_drift_reaches_runner_exit_code",
    "FLOW-004": "test_test_flows.TestFlowRunnerTests.test_security_is_independently_selectable",
    "FLOW-005": "test_test_flows.TestFlowRunnerTests.test_missing_security_flow_blocks_full_verification",
    "FLOW-006": "test_test_flows.TestFlowRunnerTests.test_unknown_selection_and_extra_arguments_cannot_pass",
    "SEC-001": "test_security_flow.SecurityFlowTests.test_all_declared_threats_have_passing_tests",
    "SEC-002": "test_security_flow.SecurityFlowTests.test_removing_each_real_protection_fails_its_mapped_test_then_restores",
    "SEC-003": "test_security_flow.SecurityFlowTests.test_declared_threat_without_mapping_blocks_the_flow",
    "SEC-004": "test_security_flow.SecurityFlowTests.test_empty_threat_source_and_duplicate_ids_are_setup_errors",
    "SEC-005": "test_security_flow.SecurityFlowTests.test_mandatory_skip_blocks_completion",
    "SEC-006": "test_security_flow.SecurityFlowTests.test_empty_mapping_cannot_produce_a_passing_empty_suite",
    "SEC-007": "test_security_flow.SecurityFlowTests.test_unavailable_optional_check_becomes_blocking_when_policy_requires_it",
    "SEC-008": "test_security_flow.SecurityFlowTests.test_scanner_output_is_not_published_without_redaction",
    "PAYLOAD-001": "test_payload.PayloadTests.test_payload_links_resolve_inside_the_folder",
    "SCAF-001": "test_scaffold.TestScaffoldRunner.test_fast_without_scope_refuses_and_prints_both_scoped_forms",
    "SCAF-002": "test_scaffold.TestScaffoldRunner.test_a_tier_without_its_prerequisite_skips_and_says_why",
    "SCAF-003": "test_scaffold.TestScaffoldRunner.test_a_failing_test_makes_the_exit_code_non_zero",
    "SCAF-004": "test_scaffold.TestScaffoldRunner.test_the_five_slowest_tests_print_on_every_run",
    "SCAF-005": "test_scaffold.TestScaffoldRunner.test_conformance_and_security_are_selectable_and_in_the_full_run",
    "SCAF-006": "test_scaffold.TestScaffoldRunner.test_the_comment_check_reports_a_planted_hit_as_file_line_and_skips_outside_a_diff",
}


class SetupError(Exception):
    pass


def read_tsv(path, required, optional=()):
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        fields = set(reader.fieldnames or ())
        if not required <= fields <= required | set(optional):
            raise SetupError(f"{path.relative_to(ROOT)}: invalid columns")
        return list(reader)


def spec_rows():
    """Every declared row, after the index and area files agree with each other."""
    index = read_tsv(ROOT / "specs/INDEX.tsv", {"path", "scope", "rows"})
    if not index:
        raise SetupError("empty spec index")
    paths = [entry["path"] for entry in index]
    if len(paths) != len(set(paths)):
        raise SetupError("duplicate index paths")
    rows = []
    for entry in index:
        area = read_tsv(ROOT / entry["path"], {"id", "when", "expect", "file"}, {"dec"})
        if not area:
            raise SetupError(f"{entry['path']}: empty spec area")
        if len(area) > 40:
            raise SetupError(f"{entry['path']}: split beyond 40 rows")
        if len(area) != int(entry["rows"]):
            raise SetupError(f"{entry['path']}: row count mismatch")
        rows.extend(row["id"] for row in area)
    if len(rows) != len(set(rows)):
        raise SetupError("duplicate spec IDs")
    unmapped = sorted(set(rows) - set(CONFORMANCE))
    stale = sorted(set(CONFORMANCE) - set(rows))
    if unmapped or stale:
        raise SetupError(f"rows without a mapped test: {unmapped}; mappings without a row: {stale}")
    return rows


def threat_tests():
    """Threat ID -> test id, read from THREATS.md."""
    text = (ROOT / "THREATS.md").read_text(encoding="utf-8")
    found = {}
    for block in re.split(r"(?m)^(?=### THREAT-)", text)[1:]:
        threat = re.match(r"### (THREAT-\S+)", block).group(1)
        method = re.search(r"`RepoSecurityTests\.(test_\w+)`", block)
        if method is None:
            raise SetupError(f"{threat}: no mapped test")
        found[threat] = f"test_repo_security.RepoSecurityTests.{method.group(1)}"
    if not found:
        raise SetupError("empty threat source")
    return found


class Outcomes(unittest.TestResult):
    def __init__(self):
        super().__init__()
        self.by_id = {}

    def _set(self, test, status):
        self.by_id.setdefault(test.id(), status)

    def addSuccess(self, test):
        self.by_id.setdefault(test.id(), "passed")

    def addFailure(self, test, err):
        self.by_id[test.id()] = "failed"

    def addError(self, test, err):
        self.by_id[test.id()] = "error"

    def addSkip(self, test, reason):
        self.by_id[test.id()] = "skipped"

    def addExpectedFailure(self, test, err):
        self.by_id[test.id()] = "skipped"

    def addUnexpectedSuccess(self, test):
        self.by_id[test.id()] = "failed"

    def addSubTest(self, test, subtest, err):
        if err is not None:
            self.by_id[test.id()] = "failed"


def run_tests(ids):
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()
    outcomes = Outcomes()
    for test_id in sorted(ids):
        try:
            suite.addTests(loader.loadTestsFromName(test_id))
        except (ImportError, AttributeError):
            outcomes.by_id[test_id] = "error"
    # Test bodies print their own subprocess output; keep the runner's report readable.
    saved, sys.stdout = sys.stdout, io.StringIO()
    try:
        suite.run(outcomes)
    finally:
        sys.stdout = saved
    return outcomes.by_id


def all_test_ids():
    loader = unittest.TestLoader()
    ids = []
    stack = [loader.loadTestsFromNames(MODULES)]
    while stack:
        item = stack.pop()
        if isinstance(item, unittest.TestSuite):
            stack.extend(item)
        else:
            ids.append(item.id())
    return ids


def report(flow, expected, outcomes):
    """Print one flow's verdict; `expected` maps a requirement ID to its test id."""
    counts = {}
    bad = []
    for requirement, test_id in sorted(expected.items()):
        status = outcomes.get(test_id, "unverified")
        counts[status] = counts.get(status, 0) + 1
        if status != "passed":
            bad.append(f"{requirement} {status}")
    summary = ", ".join(f"{n} {s}" for s, n in sorted(counts.items()))
    print(f"{flow}: {'passed' if not bad else 'failed'} (scope=full; {len(expected)} requirements: {summary})", flush=True)
    for line in bad:
        print(f"  {line}")
    return not bad


def run_content():
    result = subprocess.run(["bash", str(ROOT / "tests/test_content.sh")], check=False)
    status = "passed" if result.returncode == 0 else "failed"
    print(f"content: {status}", flush=True)
    return result.returncode == 0


def main(argv):
    flows = {"all", "conformance", "security", "content"}
    if len(argv) > 1 or (argv and argv[0] not in flows):
        raise SystemExit("usage: run_tests.py [all|conformance|security|content]")
    selection = argv[0] if argv else "all"
    try:
        conformance = {row: CONFORMANCE[row] for row in spec_rows()}
        security = threat_tests()
    except (SetupError, OSError) as error:
        print(f"setup error: {error}", file=sys.stderr)
        return 2
    if selection == "content":
        return 0 if run_content() else 1
    if selection == "all":
        ids = set(all_test_ids())
    else:
        ids = set(conformance.values() if selection == "conformance" else security.values())
    outcomes = run_tests(ids)
    passed = True
    if selection in ("all", "conformance"):
        passed &= report("conformance", conformance, outcomes)
    if selection in ("all", "security"):
        passed &= report("security", security, outcomes)
    if selection == "all":
        others = sorted(i for i, s in outcomes.items() if s != "passed")
        unmapped = len(ids - set(conformance.values()) - set(security.values()))
        print(f"tests: {len(ids)} run once, {len(others)} not passing; {unmapped} have no conformance row or threat")
        for test_id in others:
            print(f"  {test_id} {outcomes[test_id]}")
        passed &= not others
        passed &= run_content()
    return 0 if passed else 1


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))

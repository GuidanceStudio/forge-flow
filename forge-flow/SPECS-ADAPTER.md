# Executable adapter example

This example assumes `src/basket.py` exports `basket_total(prices)` (sum),
`src/display.py` exports `display_amount(amount)` (two decimal places), and
`src/delivery.py` exports `delivery_fee(amount)` (2 below 20, otherwise 0).
The two basket TSVs illustrate a split; the shared amount scope is selected by
either basket or display work. `specs/INDEX.tsv` contains:

```tsv
path	scope	rows
specs/basket-prices.tsv	src/basket.py	1
specs/basket-empty.tsv	src/basket.py	1
specs/amounts.tsv	src/basket.py;src/display.py	1
specs/delivery.tsv	src/delivery.py	1
```

The four area files contain these rows respectively (each with the mandatory
header `id<TAB>when<TAB>expect<TAB>file`; `<TAB>` means an actual tab):

```tsv
SUM-001	2,3	5	src/basket.py
SUM-002	empty	0	src/basket.py
FORMAT-001	2	2.00	src/display.py
DELIVERY-001	10	2	src/delivery.py
```

Save the following example as a test script and run
`python3 test_specs.py . src/basket.py` from that example project. It reads
inputs from `when`, calls the named implementation, and asserts `expect`;
unknown IDs and unexecuted rows fail. The branches are deliberately specific
to these four IDs. Extend the project's adapter for new behaviours, using its
ordinary fixtures and assertions; do not build a generic engine, DSL or runtime.
This example also fails when no affected paths are supplied or any path is
unmatched: clarify the scope and its specification rows before testing.
The repository's content suite extracts and executes this exact code block
against disk fixtures, including a changed expectation and a skipped row.

<!-- specs-adapter-example -->
```python
import csv
from fnmatch import fnmatchcase
import json
from pathlib import Path
import runpy
import sys


def read_tsv(path, required, optional=()):
    with path.open(encoding="utf-8", newline="") as stream:
        reader = csv.DictReader(stream, delimiter="\t")
        fields = set(reader.fieldnames or ())
        assert required <= fields <= required | set(optional), f"{path}: invalid columns"
        return list(reader)


root = Path(sys.argv[1])
affected_paths = sys.argv[2:]
assert affected_paths, "no affected paths: clarify scope before testing"
index = read_tsv(root / "specs/INDEX.tsv", {"path", "scope", "rows"})
unmatched = sorted({path for path in affected_paths
                    if not any(fnmatchcase(path, pattern)
                               for entry in index for pattern in entry["scope"].split(";"))})
assert not unmatched, f"unmatched affected paths: {unmatched}"
selected = list(dict.fromkeys(
    entry["path"] for entry in index
    if any(fnmatchcase(path, pattern)
           for path in affected_paths for pattern in entry["scope"].split(";"))
))
rows = []
for path in selected:
    area = read_tsv(root / path, {"id", "when", "expect", "file"}, {"dec"})
    assert len(area) <= 40, f"{path}: split beyond 40 rows"
    entry = next(entry for entry in index if entry["path"] == path)
    assert len(area) == int(entry["rows"]), f"{path}: row count mismatch"
    rows.extend(area)
ids = [row["id"] for row in rows]
assert len(ids) == len(set(ids)), "duplicate spec IDs"
executed = set()
for row in rows:
    spec_id = row["id"]
    if spec_id in {"SUM-001", "SUM-002"}:
        prices = [] if row["when"] == "empty" else [int(n) for n in row["when"].split(",")]
        actual = runpy.run_path(root / row["file"])["basket_total"](prices)
    elif spec_id == "FORMAT-001":
        actual = runpy.run_path(root / row["file"])["display_amount"](int(row["when"]))
    elif spec_id == "DELIVERY-001":
        actual = runpy.run_path(root / row["file"])["delivery_fee"](int(row["when"]))
    else:
        raise AssertionError(f"unknown spec ID: {spec_id}")
    assert str(actual) == row["expect"], (
        f"{spec_id}: expected {row['expect']!r}, got {str(actual)!r}"
    )
    executed.add(spec_id)
missing = sorted(set(ids) - executed)
assert not missing, f"unexecuted spec rows: {missing}"
print(json.dumps({"selected": selected, "executed": sorted(executed)}))
```

"""The payload folder is self-contained: every relative link in it resolves inside it."""
import re
import sys
import unittest
from pathlib import Path

sys.dont_write_bytecode = True
PAYLOAD = Path(__file__).resolve().parents[1] / "forge-flow"
LINK = re.compile(r"\]\((?!https?://|mailto:|#)([^)\s#]+)")
CODE = re.compile(r"```.*?```|`[^`\n]*`", re.S)


def unresolved(root, files):
    bad = []
    for path in files:
        for target in LINK.findall(CODE.sub("", path.read_text(encoding="utf-8"))):
            resolved = (path.parent / target).resolve()
            if root.resolve() not in resolved.parents and resolved != root.resolve():
                bad.append(f"{path.name} -> {target} (outside the folder)")
            elif not resolved.exists():
                bad.append(f"{path.name} -> {target} (missing)")
    return bad


class PayloadTests(unittest.TestCase):
    def test_payload_links_resolve_inside_the_folder(self):
        # the check detects both failure kinds on a throwaway folder
        import tempfile
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp) / "skill"
            root.mkdir()
            (root / "A.md").write_text("[b](B.md) [up](../README.md) [gone](C.md#x) [web](https://x.example)")
            (root / "B.md").write_text("ok")
            (Path(tmp) / "README.md").write_text("outside")
            self.assertEqual(unresolved(root, [root / "A.md"]),
                             ["A.md -> ../README.md (outside the folder)", "A.md -> C.md (missing)"])
        files = sorted(PAYLOAD.rglob("*.md"))
        self.assertTrue(files)
        self.assertEqual(unresolved(PAYLOAD, files), [])


if __name__ == "__main__":
    unittest.main()

# Scaffold example — the generated runner's executable shape

Read only from the scaffold route (Phase 2). `tests/test_scaffold.py` copies the block
below into a temporary project and falsifies each behaviour once; a generated runner
keeps every one of them. Tests are `tests/<tier>/*.sh`, each a script whose exit code
is the verdict; tiers are `unit`, `integration`, `conformance`, `security`, and `fast`
runs one scoped test.

<!-- scaffold-runner-example -->
```bash
#!/usr/bin/env bash
# run_tests.sh <fast <file>|fast -k <name>|unit|integration|conformance|security|all|comments [base]>
set -u
TIER="${1:-}"; shift || true
TIMES=""
note() { printf '%s\n' "$*"; }
run_one() {  # file -> records time, returns the script's exit code
  local f="$1" s e rc; s=$(date +%s%N); bash "$f"; rc=$?; e=$(date +%s%N)
  TIMES+="$(( (e - s) / 1000000 )) $f"$'\n'; return $rc
}
run_tier() {  # tier -> 0 when every test passed
  local t="$1" failed=0 f
  for f in tests/"$t"/*.sh; do [ -e "$f" ] || continue; run_one "$f" || { failed=1; note "FAIL $t $f"; }; done
  note "ran $t"; return $failed
}
slowest() { note "slowest 5:"; printf '%s' "$TIMES" | sort -rn | head -5 | sed 's/^/  /'; }
has_prereq() { case "$1" in integration) command -v docker >/dev/null 2>&1 ;; *) true ;; esac; }
case "$TIER" in
  fast)
    if [ $# -eq 0 ]; then
      note "fast needs a scope:"; note "  ./run_tests.sh fast <path>"; note "  ./run_tests.sh fast --changed"; exit 2
    fi
    if [ "$1" = "--changed" ]; then f=$(git diff --name-only HEAD -- 'tests/*/*.sh' 2>/dev/null | head -1); else f="$1"; fi
    [ -n "${f:-}" ] && [ -e "$f" ] || { note "no test matches"; exit 2; }
    run_one "$f"; rc=$?; slowest; exit $rc ;;
  unit|integration|conformance|security)
    has_prereq "$TIER" || { note "SKIP $TIER: docker not found"; exit 0; }
    run_tier "$TIER"; rc=$?; slowest; exit $rc ;;
  all)
    rc=0
    for t in unit integration conformance security; do
      if has_prereq "$t"; then run_tier "$t" || rc=1; else note "SKIP $t: docker not found"; fi
    done; slowest; exit $rc ;;
  comments)
    base="${1:-}"
    git rev-parse --git-dir >/dev/null 2>&1 && [ -n "$base" ] || { note "SKIP comments: no diff to read"; exit 0; }
    hits=$(git diff -U0 "$base" -- . | awk '/^\+\+\+ b\//{f=substr($0,7)} /^@@/{split($3,a,/[,+]/); n=a[2]} /^\+[^+]/{ if ($0 ~ /#[ ]*(TODO|FIXME|HACK)/) print f":"n; n++ }')
    [ -z "$hits" ] && exit 0; note "$hits"; exit 1 ;;
  *) note "usage: run_tests.sh <fast <scope>|unit|integration|conformance|security|all|comments [base]>"; exit 2 ;;
esac
```

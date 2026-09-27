#!/usr/bin/env python3
"""Portability suite: the path, encoding, line-ending and git-output cases that differ
between the author's macOS setup and everyone else's machine — Windows above all.

Runs every tests/portability/test_*.py with unittest. Windows behaviour is simulated:
tests/portability/_winsim.py loads a REAL module from this repo with `os.path` swapped
for `ntpath` (sep='\\'), so a case that fails here fails the same way on Windows. The
cases that are not Windows-specific (non-ASCII and quoted file names from git, CRLF
checkouts, case-varied paths on a case-insensitive disk, a BOM) run as they are.

Each case is one of three kinds. A PIN fails on the code before its fix (a defect from
issue #171 or #151, or a regression a first-cut fix introduced) and passes after. A
CONTROL is an ordinary command or clean input that passes before and after, so a fix
that refuses everything cannot pass. A HARNESS check tests the suite itself: that the
ntpath simulation is real, that each skip below guards a mechanism that bites where it
runs, and that this runner counts honestly (test_harness.py). The qualification ledger
gives the before/after counts.

A case whose mechanism this host lacks is SKIPPED with its reason, never passed: a pass
there would pin nothing. The strict-encoding cases need Python 3.10 (EncodingWarning),
the patched-locale cases 3.11 (locale.getencoding), the symlink cases a host that lets
os.symlink run (Windows needs Developer Mode or elevation). The verdict line counts the
skips and prints each reason, so a run that could not exercise a case says which.

Exit: 0 all pass (skips named), 1 a case failed, 2 the suite could not run.
"""
import os
import sys
import unittest
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SUITE = os.path.join(ROOT, "tests", "portability")


def main() -> int:
    if not os.path.isdir(SUITE):
        print(f"portability-tests: CANNOT RUN — {SUITE} is missing", file=sys.stderr)
        return 2
    # #171 G1: under .githooks/pre-commit git exports GIT_INDEX_FILE (absolute for
    # `commit -a`, `commit <paths>` and in a linked worktree, with GIT_DIR there too).
    # A case that runs a gate in-process (_winsim.run_main / load) then had its
    # fixture's `git -C tmp ls-files` read the user's index. Only this process drops
    # them: the real gates in backtest.sh must keep judging the index being committed.
    for k in [k for k in os.environ if k.startswith("GIT_") and k != "GIT_EXEC_PATH"]:
        del os.environ[k]
    sys.path.insert(0, SUITE)
    suite = unittest.defaultTestLoader.discover(SUITE, pattern="test_*.py", top_level_dir=SUITE)
    if suite.countTestCases() == 0:
        print("portability-tests: CANNOT RUN — no test cases found", file=sys.stderr)
        return 2
    result = unittest.TextTestRunner(stream=sys.stdout, verbosity=1).run(suite)
    # The total keeps the skipped cases, as hook-battery's does its UNREACHABLE ones;
    # an unexpected success is a declared failure that no longer fails (#171 G6).
    total = result.testsRun
    bad = len(result.failures) + len(result.errors) + len(result.unexpectedSuccesses)
    if bad:
        print(f"portability-tests: {bad} of {total} cases FAILED")
        return 1
    if not result.skipped:
        print(f"portability-tests: ALL PASS ({total} cases)")
        return 0
    print(f"portability-tests: ALL PASS ({total} cases, {len(result.skipped)} skipped)")
    for reason, n in sorted(Counter(reason for _, reason in result.skipped).items()):
        print(f"  skipped {n}: {reason}")
    return 0


if __name__ == "__main__":
    sys.exit(main())

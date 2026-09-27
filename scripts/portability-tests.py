#!/usr/bin/env python3
"""Portability suite: the path, encoding, line-ending and git-output cases that differ
between the author's macOS setup and everyone else's machine — Windows above all.

Runs every tests/portability/test_*.py with unittest. Windows behaviour is simulated:
tests/portability/_winsim.py loads a REAL module from this repo with `os.path` swapped
for `ntpath` (sep='\\'), so a case that fails here fails the same way on Windows. The
cases that are not Windows-specific (non-ASCII and quoted file names from git, CRLF
checkouts, case-varied paths on a case-insensitive disk, a BOM) run as they are.

Every case pins one defect from issue #171 (and #151): it fails on the code before the
fix and passes after, on Linux and macOS CI alike.

Exit: 0 all pass, 1 a case failed, 2 the suite could not run.
"""
import os
import sys
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SUITE = os.path.join(ROOT, "tests", "portability")


def main() -> int:
    if not os.path.isdir(SUITE):
        print(f"portability-tests: CANNOT RUN — {SUITE} is missing", file=sys.stderr)
        return 2
    sys.path.insert(0, SUITE)
    suite = unittest.defaultTestLoader.discover(SUITE, pattern="test_*.py", top_level_dir=SUITE)
    if suite.countTestCases() == 0:
        print("portability-tests: CANNOT RUN — no test cases found", file=sys.stderr)
        return 2
    result = unittest.TextTestRunner(stream=sys.stdout, verbosity=1).run(suite)
    total = result.testsRun
    bad = len(result.failures) + len(result.errors)
    if bad:
        print(f"portability-tests: {bad} of {total} cases FAILED")
        return 1
    print(f"portability-tests: ALL PASS ({total} cases)")
    return 0


if __name__ == "__main__":
    sys.exit(main())

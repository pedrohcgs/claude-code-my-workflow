"""The simulation harness itself: a case that cannot fail proves nothing, so this
checks that a module loaded through _winsim really sees Windows path rules."""
import os
import tempfile
import unittest

import _winsim


class HarnessTest(unittest.TestCase):
    def test_loaded_module_sees_ntpath(self):
        with tempfile.TemporaryDirectory() as d:
            src = os.path.join(d, "probe.py")
            with open(src, "w", encoding="utf-8") as f:
                f.write("import os\nJOINED = os.path.join('a', 'b')\nSEP = os.sep\n")
            mod = _winsim.load(src)
        self.assertEqual(mod.SEP, "\\")
        self.assertEqual(mod.JOINED, "a\\b")

    def test_paths_round_trip(self):
        self.assertEqual(_winsim.to_posix(_winsim.to_win("/tmp/x/y")), "/tmp/x/y")


if __name__ == "__main__":
    unittest.main()

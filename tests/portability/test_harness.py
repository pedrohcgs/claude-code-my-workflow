"""The harness itself: a case that cannot fail proves nothing. So this checks that a
module loaded through _winsim really sees Windows path rules, that the host-capability
skips in _winsim let a case run only where its mechanism can bite, and that the gate
runner, scripts/portability-tests.py, counts honestly and hands its cases a clean
git environment (issue #171)."""
import contextlib
import importlib.util
import io
import os
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

import _winsim

SUITE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(os.path.dirname(SUITE))
GATE = os.path.join(ROOT, "scripts", "portability-tests.py")


def _clean(**extra):
    env = {k: v for k, v in os.environ.items()
           if (not k.startswith("GIT_") or k == "GIT_EXEC_PATH")
           and k not in ("HOOK_DIR", "PYTHONPATH", "PYTHONWARNINGS", "PYTHONUTF8")}
    env.update(extra)
    return env


def _git(cwd, *args):
    subprocess.run(["git", *args], cwd=cwd, check=True, capture_output=True,
                   env=_clean(GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull))


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


class HostMechanisms(unittest.TestCase):
    """Each skip in _winsim guards a mechanism; wherever it lets a case run, the
    mechanism must actually turn the old behaviour into a failure (#171 F3)."""

    @_winsim.needs_encoding_warning
    def test_strict_flags_turn_a_locale_default_read_into_an_error(self):
        r = subprocess.run([sys.executable, "-X", "warn_default_encoding", "-W", "error::EncodingWarning",
                            "-c", "import os\nopen(os.devnull).close()\n"],
                           capture_output=True, env=_clean(), timeout=60)
        self.assertNotEqual(r.returncode, 0, r.stderr)
        self.assertIn(b"EncodingWarning", r.stderr)

    @_winsim.needs_getencoding
    def test_a_patched_getencoding_decides_subprocess_text(self):
        # U+201D as UTF-8 ends in 0x9D, which cp1252 does not define.
        code = ("import locale, subprocess, sys\n"
                "locale.getencoding = lambda: 'cp1252'\n"
                "subprocess.run([sys.executable, '-c', "
                "'import sys; sys.stdout.buffer.write(bytes([0xe2, 0x80, 0x9d]))'],"
                " capture_output=True, text=True)\n")
        r = subprocess.run([sys.executable, "-c", code], capture_output=True,
                           env=_clean(PYTHONUTF8="0"), timeout=60)
        self.assertNotEqual(r.returncode, 0, r.stderr)
        self.assertIn(b"UnicodeDecodeError", r.stderr)

    def test_the_suite_runs_where_os_symlink_is_refused(self):
        # #171 F4: Windows without Developer Mode refuses os.symlink (WinError 1314).
        # test_rot's setUpModule made four links unguarded, so every case in the file
        # errored; notify.sh's fixture linked cat and tr. Here the link cases skip and
        # the rest run.
        refuse = ("import os, sys, unittest\n"
                  "def symlink(*a, **k):\n"
                  "    raise OSError(1314, 'A required privilege is not held by the client')\n"
                  "os.symlink = symlink\n"
                  "unittest.main(module=None, argv=['refused'] + sys.argv[1:], verbosity=2)\n")
        expect = [("test_rot", "NativeTest", "test_link_claude_hooks", "skipped"),
                  ("test_rot", "NativeTest", "test_scope_alias_project_dir", "skipped"),
                  ("test_rot", "NativeTest", "test_exe_ctrl_status", "ok"),
                  ("test_hooks", "NotifyWithoutJqAndOnWindows", "test_no_jq_still_notifies", "ok"),
                  ("test_gitout", "PreCommitQualityGate", "test_dangling_symlink_is_named_as_a_symlink",
                   "skipped")]
        r = subprocess.run([sys.executable, "-c", refuse, *(".".join(e[:3]) for e in expect)],
                           cwd=SUITE, capture_output=True, env=_clean(), timeout=300)
        out = r.stdout.decode("utf-8", "replace") + r.stderr.decode("utf-8", "replace")
        self.assertEqual(r.returncode, 0, out)
        for _, _, name, verdict in expect:
            self.assertRegex(out, rf"(?m)^{name} \(.*\) \.\.\. {verdict}", out)


class GateRunner(unittest.TestCase):
    """scripts/portability-tests.py: its own main(), handed a stand-in suite."""

    def run_gate(self, *cases):
        spec = importlib.util.spec_from_file_location("portability_gate", GATE)
        gate = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(gate)
        suite = unittest.TestSuite(unittest.defaultTestLoader.loadTestsFromTestCase(c) for c in cases)
        out = io.StringIO()
        with mock.patch.object(unittest.defaultTestLoader, "discover", return_value=suite), \
                mock.patch.object(sys, "path", list(sys.path)), \
                contextlib.redirect_stdout(out), contextlib.redirect_stderr(io.StringIO()):
            rc = gate.main()
        return rc, out.getvalue()

    def test_cases_do_not_read_the_callers_index(self):
        # #171 G1: under `git commit -a`, `commit <paths>` or in a linked worktree the
        # pre-commit hook hands the gate an absolute GIT_INDEX_FILE (and GIT_DIR). A
        # script run in-process then had its fixture's `git -C tmp ls-files` list the
        # user's index. GIT_EXEC_PATH only says where git's own programs are: kept.
        with tempfile.TemporaryDirectory() as d:
            d = os.path.realpath(d)
            fixture, other = os.path.join(d, "fixture"), os.path.join(d, "other")
            for repo, name in ((fixture, "a.md"), (other, "b.md")):
                os.makedirs(repo)
                with open(os.path.join(repo, name), "w", encoding="utf-8") as f:
                    f.write("x\n")
                _git(repo, "init", "-q")
                _git(repo, "add", name)
            exec_path = subprocess.run(["git", "--exec-path"], capture_output=True,
                                       env=_clean()).stdout.decode().strip()
            seen = {}

            class Probe(unittest.TestCase):
                def test_ls_files_in_process(self):
                    r = _winsim.fsub.run(["git", "-C", fixture, "ls-files", "-z"], capture_output=True)
                    seen["listed"] = r.stdout.decode("utf-8").split("\0")[:-1]
                    seen["exec_path"] = os.environ.get("GIT_EXEC_PATH")

            hook = {"GIT_DIR": os.path.join(other, ".git"),
                    "GIT_INDEX_FILE": os.path.join(other, ".git", "index"),
                    "GIT_EXEC_PATH": exec_path}
            with mock.patch.dict(os.environ, hook):
                rc, out = self.run_gate(Probe)
        self.assertEqual(rc, 0, out)
        self.assertEqual(seen["listed"], ["a.md"], "the in-process git read the caller's index")
        self.assertEqual(seen["exec_path"], exec_path)

    def test_skipped_cases_are_counted_and_named(self):
        # #171 G6: 'OK (skipped=3)' was reported as 'ALL PASS (216 cases)'.
        class Probe(unittest.TestCase):
            def test_runs(self):
                pass

            @unittest.skip("no such mechanism on this host")
            def test_cannot_run(self):
                pass

        rc, out = self.run_gate(Probe)
        self.assertEqual(rc, 0, out)
        self.assertIn("portability-tests: ALL PASS (2 cases, 1 skipped)", out)
        self.assertRegex(out, r"(?m)^  skipped 1: no such mechanism on this host$")

    def test_an_unexpected_success_fails_the_gate(self):
        # #171 G6: a case declared to fail that passes has lost what it pinned.
        class Probe(unittest.TestCase):
            @unittest.expectedFailure
            def test_declared_to_fail(self):
                pass

        rc, out = self.run_gate(Probe)
        self.assertEqual(rc, 1, out)
        self.assertIn("portability-tests: 1 of 1 cases FAILED", out)

    def test_a_clean_run_reads_as_before(self):
        # Control: with nothing skipped the verdict line is the one it always was.
        class Probe(unittest.TestCase):
            def test_runs(self):
                pass

        rc, out = self.run_gate(Probe)
        self.assertEqual(rc, 0, out)
        self.assertRegex(out, r"(?m)^portability-tests: ALL PASS \(1 cases\)$")


if __name__ == "__main__":
    unittest.main()

"""Git output, line endings and the quality gate (issue #171, group "gitout"; #151 claims 2-3).

The gates read git's file lists, and git hands back something other than the file
name more often than it looks: without -z it C-quotes every non-ASCII, quote or
backslash name; with text=True Python decodes it in the Windows code page; relpath
and os.path.join answer in backslashes on Windows; a rename is status R, not M.
A case below either pins one of those (it fails on 08a7641, or on the first-cut fix
it corrects, and passes after) or is a control that passes before and after.

Fixture repositories are built in temp directories with git's own environment
scrubbed (the suite also runs inside the pre-commit hook, where GIT_INDEX_FILE
names the user's index) and with no global or system config, so core.quotePath
is at git's default.
"""
import contextlib
import importlib.util
import io
import os
import pathlib
import shutil
import subprocess
import sys
import tempfile
import types
import unicodedata
import unittest
from unittest import mock

import _winsim

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HYGIENE = os.path.join(ROOT, "scripts", "check-repo-hygiene.py")
LEDGER = os.path.join(ROOT, "scripts", "check-ledger-coverage.py")
QSCORE = os.path.join(ROOT, "scripts", "quality_score.py")
PRECOMMIT = os.path.join(ROOT, ".githooks", "pre-commit")
BASH = shutil.which("bash")

# Two hard-coded absolute paths: the scorer gives this R script 60/100 (exit 1)
# from its static checks alone, so the cases below need no Rscript.
FAILING_R = 'a <- read.csv("/Users/x/a.csv")\nb <- read.csv("/Users/x/b.csv")\n'
GOOD_R = "x <- 1\ny <- x + 1\n"

# subprocess decodes text=True output through locale.getencoding() only from Python
# 3.11; before that the function does not exist and there is nothing to patch. The
# fix decodes git's bytes as UTF-8 itself on every version: CI (3.12) keeps the pin,
# and macOS's /usr/bin/python3 (3.9) skips these cases instead of erroring the gate.
# One definition for the suite: test_gates skips on the same probe.
needs_getencoding = _winsim.needs_getencoding


def git_env(**extra):
    env = {k: v for k, v in os.environ.items()
           if not k.startswith("GIT_") and k not in ("SKIP_QUALITY_GATE", "BACKTEST_SKIP_HOOK_BATTERY",
                                                      "PYTHONUTF8", "PYTHONIOENCODING")}
    env.update(GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull,
               GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@example.invalid",
               GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@example.invalid")
    env.update(extra)
    return env


class Repo:
    """A throwaway git repository."""

    def __init__(self, case):
        self.dir = tempfile.mkdtemp(prefix="gitout-")
        case.addCleanup(shutil.rmtree, self.dir, True)
        self.git("init", "-q")

    def git(self, *args, **k):
        r = subprocess.run(["git", *args], cwd=self.dir, env=git_env(), capture_output=True, **k)
        if r.returncode != 0:
            raise AssertionError(f"git {' '.join(args)}: {r.stderr.decode('utf-8', 'replace')}")
        return r

    def path(self, rel):
        return os.path.join(self.dir, *rel.split("/"))

    def write(self, rel, text):
        p = self.path(rel)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, "w", encoding="utf-8", newline="\n") as f:
            f.write(text)

    def copy_in(self, src, rel):
        p = self.path(rel)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        shutil.copy2(src, p)

    def add(self, *rels):
        self.git("add", "--", *rels)

    def commit(self, msg="seed"):
        self.git("commit", "-q", "--no-verify", "-m", msg)

    def index_only(self, *rels):
        """Put paths in the index without touching the disk, so a case pair can exist
        even on a case-insensitive filesystem."""
        blob = self.git("hash-object", "-w", "--stdin", input=b"x\n").stdout.decode().strip()
        args = []
        for rel in rels:
            args += ["--add", "--cacheinfo", f"100644,{blob},{rel}"]
        self.git("-c", "core.precomposeunicode=false", "update-index", *args)


def load(path):
    spec = importlib.util.spec_from_file_location("gitout_" + os.path.basename(path).replace("-", "_")[:-3], path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def run_main(fn):
    out = io.StringIO()
    with contextlib.redirect_stdout(out), contextlib.redirect_stderr(io.StringIO()):
        rc = fn()
    return rc, out.getvalue()


# ---- check-repo-hygiene.py --------------------------------------------------

class HygieneGitOutput(unittest.TestCase):
    """hygiene-ls-files-no-z, hygiene-lsfiles-quoted-nonascii (#151 claim 3)."""

    def run_hygiene(self, repo, **env):
        r = subprocess.run([sys.executable, repo.path("scripts/check-repo-hygiene.py")], cwd=repo.dir,
                           env=git_env(**env), capture_output=True)
        return r.returncode, r.stdout.decode("utf-8", "replace"), r.stderr.decode("utf-8", "replace")

    def fixture(self):
        repo = Repo(self)
        repo.copy_in(HYGIENE, "scripts/check-repo-hygiene.py")
        return repo

    def test_accented_names_are_not_phantom_directories(self):
        repo = self.fixture()
        repo.write("scripts/análise.R", GOOD_R)
        repo.write("Slides/Aula_01_Introdução.tex", "x\n")
        repo.add("scripts", "Slides")
        rc, out, err = self.run_hygiene(repo)
        self.assertNotIn('"scripts/', out)
        self.assertNotIn('"Slides/', out)
        self.assertEqual(rc, 0, out + err)

    def test_accented_draft_names_are_reported_by_their_real_names(self):
        # cp1252 stdout, as on a Western Windows pipe: 'ł' is not in cp1252, so the
        # checker must print UTF-8 rather than crash on the name it reports.
        repo = self.fixture()
        repo.write("scripts/análise_old.R", GOOD_R)
        repo.write("scripts/łódź_backup.R", GOOD_R)
        repo.write("quality_reports/relatório_final.md", "x\n")
        repo.add("scripts", "quality_reports")
        rc, out, err = self.run_hygiene(repo, PYTHONIOENCODING="cp1252")
        self.assertEqual(rc, 1, out + err)
        self.assertNotIn("Traceback", err)
        self.assertIn("scripts/análise_old.R: superseded copy", out)
        self.assertIn("scripts/łódź_backup.R: superseded copy", out)
        self.assertIn("quality_reports/relatório_final.md: version-in-filename", out)
        self.assertNotIn('"scripts/', out)


class HygieneLocaleDecode(unittest.TestCase):
    """ls-files-locale-decode: git's UTF-8 bytes decoded in the Windows code page."""

    @needs_getencoding
    def test_tracked_names_survive_a_cp1252_locale(self):
        repo = Repo(self)
        repo.git("config", "core.quotepath", "off")
        name = "templates/Álgebra-notes.md"           # Á is C3 81; 0x81 is undefined in cp1252
        repo.write(name, "x\n")
        repo.add("templates")
        m = load(HYGIENE)
        m.ROOT = repo.dir
        with mock.patch.dict(os.environ, git_env(), clear=True), \
                mock.patch("locale.getencoding", return_value="cp1252"):
            files = m.tracked()
        self.assertEqual(files, [name])


class HygieneWindowsSeparators(unittest.TestCase):
    """hygiene-numbered-duplicate-ospath-join: os.path.join under ntpath."""

    def test_numbered_duplicate_below_the_root_is_caught_on_windows(self):
        m = _winsim.load(HYGIENE)
        m.tracked = lambda: ["README.md", "templates/notes.md", "templates/notes 2.md"]
        m.append_only_violations = lambda: []
        rc, out = run_main(m.main)
        self.assertEqual(rc, 1, out)
        self.assertIn("templates/notes 2.md: numbered duplicate of templates/notes.md", out)


class HygieneCaseCollisions(unittest.TestCase):
    """hygiene-misses-case-colliding-paths."""

    def run_hygiene(self, repo):
        r = subprocess.run([sys.executable, repo.path("scripts/check-repo-hygiene.py")], cwd=repo.dir,
                           env=git_env(), capture_output=True)
        return r.returncode, r.stdout.decode("utf-8", "replace")

    def fixture(self):
        repo = Repo(self)
        repo.copy_in(HYGIENE, "scripts/check-repo-hygiene.py")
        return repo

    def test_file_names_differing_only_by_case_fail(self):
        repo = self.fixture()
        repo.index_only("quality_reports/notes.md", "quality_reports/Notes.md")
        rc, out = self.run_hygiene(repo)
        self.assertEqual(rc, 1, out)
        self.assertIn("only by case", out)
        self.assertIn("quality_reports/notes.md", out)

    def test_a_directory_spelt_two_ways_is_flagged_once(self):
        repo = self.fixture()
        repo.index_only("quality_reports/Plans/a.md", "quality_reports/Plans/b.md",
                        "quality_reports/plans/c.md", "quality_reports/plans/d.md")
        rc, out = self.run_hygiene(repo)
        self.assertEqual(rc, 1, out)
        self.assertEqual(out.count("only by case"), 1, out)

    def test_nfc_and_nfd_spellings_collide(self):
        repo = self.fixture()
        repo.index_only(unicodedata.normalize("NFC", "templates/café.md"),
                        unicodedata.normalize("NFD", "templates/café.md"))
        rc, out = self.run_hygiene(repo)
        self.assertEqual(rc, 1, out)
        self.assertIn("only by case", out)

    def test_control_distinct_names_pass(self):
        repo = self.fixture()
        repo.index_only("quality_reports/notes.md", "quality_reports/notes-2026.md", "templates/Notes.md")
        rc, out = self.run_hygiene(repo)
        self.assertEqual(rc, 0, out)


def case_sensitive_os():
    """os with exists/isfile/isdir answering as a case-sensitive disk (Linux CI) does,
    whatever this machine's filesystem is."""
    import posixpath
    p = types.ModuleType("posixpath")
    p.__dict__.update(posixpath.__dict__)

    def exact(fn):
        def w(path):
            d, b = os.path.split(os.fspath(path))
            try:
                return b in os.listdir(d or ".") and fn(path)
            except OSError:
                return False
        return w
    for n in ("exists", "isfile", "isdir"):
        setattr(p, n, exact(getattr(posixpath, n)))
    fake = types.ModuleType("os")
    fake.__dict__.update(os.__dict__)
    fake.path = p
    return fake


class HygieneArchiveReadme(unittest.TestCase):
    """hygiene-archive-readme-case-divergence: the same tree, the same verdict, on every disk."""

    def verdict(self, names):
        d = tempfile.mkdtemp(prefix="gitout-")
        self.addCleanup(shutil.rmtree, d, True)
        os.makedirs(os.path.join(d, "explorations"))
        for n in names:
            open(os.path.join(d, "explorations", n), "w").close()
        m = load(HYGIENE)
        m.ROOT, m.os = d, case_sensitive_os()
        m.tracked = lambda: ["explorations/" + n for n in names]
        m.append_only_violations = lambda: []
        return run_main(m.main)

    def test_readme_in_another_case_counts_on_a_case_sensitive_disk(self):
        rc, out = self.verdict(["Readme.md", "work.md"])
        self.assertEqual(rc, 0, out)

    def test_control_no_readme_still_fails(self):
        rc, out = self.verdict(["notes.md", "work.md"])
        self.assertEqual(rc, 1, out)
        self.assertIn("explorations/: holds work but has no README", out)


# ---- check-ledger-coverage.py -----------------------------------------------

class LedgerWindowsSeparators(unittest.TestCase):
    """ledger-coverage-relpath-backslash, ledger-coverage-relpath (#151 claim 2)."""

    def test_named_by_matches_a_directory_token_on_windows(self):
        m = _winsim.load(LEDGER)
        m.ROOT = "C:\\repo"
        self.assertTrue(m.named_by("C:\\repo\\scripts\\check-links.py",
                                   {"check-links.py": {"scripts/check-links.py"}}))
        self.assertTrue(m.named_by("C:\\repo\\.claude\\hooks\\notify.sh",
                                   {"notify.sh": {".claude/hooks/notify.sh"}}))

    def test_windows_report_is_the_posix_report(self):
        # The whole gate, on this repository, under ntpath: the same report, line for line.
        posix_rc, posix_out = run_main(load(LEDGER).main)
        win_rc, win_out = run_main(_winsim.load(LEDGER).main)
        self.assertEqual(win_out, posix_out)
        self.assertEqual(win_rc, posix_rc)


class LedgerGitOutput(unittest.TestCase):
    """ledger-coverage-ls-files-no-z, and ls-files-locale-decode for this gate."""

    HOOK = ".claude/hooks/lembrete_sessão.py"

    def fixture(self, quotepath=None):
        repo = Repo(self)
        if quotepath is not None:
            repo.git("config", "core.quotepath", quotepath)
        repo.write(self.HOOK, "pass\n")
        repo.write("scripts/x.sh", "true\n")
        repo.add(".claude", "scripts")
        return repo

    def tracked(self, repo, encoding=None):
        m = load(LEDGER)
        m.ROOT = repo.dir
        with contextlib.ExitStack() as st:
            st.enter_context(mock.patch.dict(os.environ, git_env(), clear=True))
            if encoding:
                st.enter_context(mock.patch("locale.getencoding", return_value=encoding))
            return m.tracked_files()

    def test_a_non_ascii_hook_reads_as_tracked(self):
        self.assertIn(self.HOOK, self.tracked(self.fixture()))

    @needs_getencoding
    def test_a_non_ascii_hook_reads_as_tracked_under_cp1252(self):
        self.assertIn(self.HOOK, self.tracked(self.fixture(quotepath="off"), encoding="cp1252"))


class GateStdoutCodePage(unittest.TestCase):
    """gate-stdout-emdash-codepage: an em dash on a cp932 pipe must not decide the exit code."""

    def test_ledger_coverage_prints_its_report_on_a_cp932_pipe(self):
        env = {k: v for k, v in os.environ.items() if k != "PYTHONUTF8"}
        env["PYTHONIOENCODING"] = "cp932"
        r = subprocess.run([sys.executable, LEDGER], env=env, capture_output=True)
        err = r.stderr.decode("utf-8", "replace")
        self.assertNotIn("UnicodeEncodeError", err)
        self.assertIn("DIRECTION 1 — every registered check", r.stdout.decode("utf-8", "replace"))

    def test_quality_score_without_rscript_on_a_cp932_pipe(self):
        # No Rscript on PATH: the report carries "syntax not verified — Rscript not installed".
        empty = tempfile.mkdtemp(prefix="gitout-")
        self.addCleanup(shutil.rmtree, empty, True)
        src = os.path.join(empty, "ok.R")
        with open(src, "w", encoding="utf-8") as f:
            f.write(GOOD_R)
        env = {k: v for k, v in os.environ.items() if k != "PYTHONUTF8"}
        env.update(PYTHONIOENCODING="cp932", PATH=empty)
        r = subprocess.run([sys.executable, QSCORE, src], env=env, capture_output=True)
        self.assertNotIn("UnicodeEncodeError", r.stderr.decode("utf-8", "replace"))
        self.assertEqual(r.returncode, 0, r.stdout.decode("utf-8", "replace"))


# ---- quality_score.py ---------------------------------------------------------

class QualityScoreSuffix(unittest.TestCase):
    """quality-score-case-sensitive-suffix."""

    def score(self, name, text, *more):
        """Score one file, or several: each extra file is a (name, text) pair."""
        d = tempfile.mkdtemp(prefix="gitout-")
        self.addCleanup(shutil.rmtree, d, True)
        paths = []
        for n, t in ((name, text),) + more:
            paths.append(os.path.join(d, n))
            with open(paths[-1], "w", encoding="utf-8") as f:
                f.write(t)
        r = subprocess.run([sys.executable, QSCORE, "--summary", *paths], capture_output=True)
        return r.returncode, r.stdout.decode("utf-8", "replace")

    def test_lowercase_r_is_scored_as_r(self):
        rc, out = self.score("t.r", FAILING_R)
        self.assertNotIn("Unsupported", out)
        self.assertEqual(rc, 1, out)

    def test_control_uppercase_r_scores_the_same(self):
        rc, out = self.score("t.R", FAILING_R)
        self.assertEqual(rc, 1, out)

    def test_changed_files_without_a_rubric_are_skipped_not_failed(self):
        # The PR checklist's `quality_score.py <changed-files>`: a passing script
        # beside a .md and a .py exits 0, and the unscored types are still named.
        # A regression pin, not an 08a7641 defect: 82a4590 exited 1 here.
        rc, out = self.score("ok.R", GOOD_R, ("notes.md", "# n\n"), ("tool.py", "x = 1\n"))
        self.assertEqual(rc, 0, out)
        self.assertIn("Unsupported file type: .md", out)
        self.assertIn("Unsupported file type: .py", out)


class QualityScoreRscriptPath(unittest.TestCase):
    """quality-score-rscript-backslash-path: the path is R's argument, not R source."""

    def test_windows_path_is_passed_as_an_argument(self):
        m = load(QSCORE)
        seen = []

        def fake_run(cmd, *a, **k):
            seen.append(cmd)
            return subprocess.CompletedProcess(cmd, 0, "", "")
        win = pathlib.PureWindowsPath("scripts/R/01_load.R")
        with mock.patch.object(m.subprocess, "run", fake_run):
            m.IssueDetector.check_r_syntax(win)
        cmd = seen[0]
        self.assertIn(str(win), cmd)                  # handed over verbatim, as its own argument
        self.assertFalse(any(str(win) in c for c in cmd if "parse" in c),
                         f"the path is spliced into R source: {cmd}")

    @unittest.skipUnless(shutil.which("Rscript") and os.name != "nt", "needs Rscript and a POSIX file name")
    def test_rscript_reads_backslash_and_quote_names_as_files(self):
        m = load(QSCORE)
        d = tempfile.mkdtemp(prefix="gitout-")
        self.addCleanup(shutil.rmtree, d, True)

        def make(name, text):
            p = pathlib.Path(d) / name
            p.write_text(text, encoding="utf-8")
            return p
        ok_backslash = make("win\\R\\01_load.R", GOOD_R)     # what a WindowsPath hands to R
        ok_quote = make('a"b.R', GOOD_R)
        broken_injection = make('y", text="1");#.R', "x <- (\n")
        self.assertIs(m.IssueDetector.check_r_syntax(ok_backslash)[0], True)
        self.assertIs(m.IssueDetector.check_r_syntax(ok_quote)[0], True)
        self.assertIs(m.IssueDetector.check_r_syntax(broken_injection)[0], False)


# ---- .githooks/pre-commit -------------------------------------------------------

@unittest.skipUnless(BASH, "needs bash")
class PreCommitQualityGate(unittest.TestCase):
    """precommit-rename-skips-quality-gate, precommit-quoted-names-skip-quality-and-battery,
    precommit-quality-gate-skips-non-ascii-names, precommit-quoted-staged-names."""

    def fixture(self):
        repo = Repo(self)
        repo.copy_in(PRECOMMIT, ".githooks/pre-commit")
        repo.copy_in(QSCORE, "scripts/quality_score.py")
        # The gate suite is not under test here: a stub that records whether the
        # hook asked it to skip the battery.
        repo.write("scripts/backtest.sh",
                   '#!/bin/sh\nprintf "%s" "${BACKTEST_SKIP_HOOK_BATTERY-unset}" > "$GITOUT_FLAG"\nexit 0\n')
        os.chmod(repo.path("scripts/backtest.sh"), 0o755)
        repo.write("scripts/clean.R", "".join(f"v{i} <- {i}\n" for i in range(12)))
        repo.add(".githooks", "scripts")
        repo.commit()
        return repo

    def hook(self, repo):
        flag = repo.path(".git/gitout-flag")
        r = subprocess.run([BASH, repo.path(".githooks/pre-commit")], cwd=repo.dir,
                           env=git_env(GITOUT_FLAG=flag, PYTHONIOENCODING="utf-8"), capture_output=True)
        out = r.stdout.decode("utf-8", "replace") + r.stderr.decode("utf-8", "replace")
        with open(flag) as f:
            self.battery_flag = f.read()
        return r.returncode, out

    def test_accented_name_is_scored(self):
        repo = self.fixture()
        repo.write("scripts/análise.R", FAILING_R)
        repo.add("scripts/análise.R")
        rc, out = self.hook(repo)
        self.assertEqual(rc, 1, out)
        self.assertIn("✗ quality gate: 'scripts/análise.R' failed", out)

    @unittest.skipIf(os.name == "nt", '" is not a legal Windows file-name character')
    def test_quote_and_backslash_names_are_scored(self):
        repo = self.fixture()
        repo.write('scripts/say"hi".R', FAILING_R)
        repo.write("scripts/back\\slash.R", FAILING_R)
        repo.add('scripts/say"hi".R', "scripts/back\\slash.R")
        rc, out = self.hook(repo)
        self.assertEqual(rc, 1, out)
        self.assertIn("on 2 staged file(s)", out)

    def test_renamed_and_edited_file_is_scored(self):
        repo = self.fixture()
        repo.git("mv", "scripts/clean.R", "scripts/clean_data.R")
        with open(repo.path("scripts/clean_data.R"), "a", encoding="utf-8") as f:
            f.write(FAILING_R)
        repo.add("scripts/clean_data.R")
        status = repo.git("diff", "--cached", "--name-status").stdout.decode()
        self.assertTrue(status.startswith("R"), status)
        rc, out = self.hook(repo)
        self.assertEqual(rc, 1, out)
        self.assertIn("'scripts/clean_data.R' failed", out)

    def test_staged_file_missing_from_the_working_tree_fails_loudly(self):
        repo = self.fixture()
        repo.write("scripts/gone.R", FAILING_R)
        repo.add("scripts/gone.R")
        os.remove(repo.path("scripts/gone.R"))
        rc, out = self.hook(repo)
        self.assertEqual(rc, 1, out)
        self.assertIn("scripts/gone.R", out)

    @unittest.skipIf(os.name == "nt", "a symlink needs privileges on Windows")
    @_winsim.needs_symlink
    def test_dangling_symlink_is_named_as_a_symlink(self):
        # The link IS in the working tree: "missing from the working tree" sent the
        # user looking for a deleted file that was never deleted.
        repo = self.fixture()
        os.symlink("../../nowhere/x.R", repo.path("scripts/link.R"))
        repo.add("scripts/link.R")
        rc, out = self.hook(repo)
        self.assertEqual(rc, 1, out)
        self.assertIn("'scripts/link.R' is a symlink whose target is missing", out)
        self.assertNotIn("missing from the working tree", out)

    def test_lowercase_r_is_scored(self):
        repo = self.fixture()
        repo.write("scripts/broken.r", FAILING_R)
        repo.add("scripts/broken.r")
        rc, out = self.hook(repo)
        self.assertEqual(rc, 1, out)
        self.assertIn("'scripts/broken.r' failed", out)

    def test_accented_hook_name_runs_the_battery(self):
        repo = self.fixture()
        repo.write(".claude/hooks/verificação.py", "pass\n")
        repo.add(".claude")
        rc, out = self.hook(repo)
        self.assertEqual(rc, 0, out)
        self.assertEqual(self.battery_flag, "unset", out)

    def test_control_valid_accented_file_passes(self):
        repo = self.fixture()
        repo.write("scripts/ação.R", GOOD_R)
        repo.write("notes.md", "x\n")
        repo.add("scripts/ação.R", "notes.md")
        rc, out = self.hook(repo)
        self.assertEqual(rc, 0, out)
        self.assertIn("on 1 staged file(s)", out)
        self.assertEqual(self.battery_flag, "1", out)


# ---- .gitattributes -------------------------------------------------------------

class LineEndings(unittest.TestCase):
    """no-gitattributes-crlf-shell, crlf-shell-scripts-break-non-msys-bash,
    gitattributes-partial-autocrlf: an autocrlf=true clone must check out LF."""

    FILES = ["scripts/backtest.sh", ".githooks/pre-commit", "guide/workflow-guide.qmd",
             "scripts/check-staleness.py"]

    def test_autocrlf_clone_checks_out_lf(self):
        src = Repo(self)
        rels = list(self.FILES)
        if os.path.exists(os.path.join(ROOT, ".gitattributes")):
            rels.append(".gitattributes")
        for rel in rels:
            src.copy_in(os.path.join(ROOT, *rel.split("/")), rel)
        src.add(*rels)
        src.commit()
        dst = tempfile.mkdtemp(prefix="gitout-")
        self.addCleanup(shutil.rmtree, dst, True)
        clone = os.path.join(dst, "c")
        r = subprocess.run(["git", "clone", "-q", "-c", "core.autocrlf=true", src.dir, clone],
                           env=git_env(), capture_output=True)
        self.assertEqual(r.returncode, 0, r.stderr)
        crlf = [rel for rel in self.FILES
                if b"\r\n" in pathlib.Path(clone, *rel.split("/")).read_bytes()]
        self.assertEqual(crlf, [], "checked out with CRLF under core.autocrlf=true")


if __name__ == "__main__":
    unittest.main()

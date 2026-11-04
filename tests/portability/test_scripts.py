"""The gates, the pre-commit hook and validate-setup outside the author's setup
(issue #171, group "scripts"): each case fails on 6cbebe1 and passes after the fix.

A clone's own path is spliced into every glob pattern, so a folder named
"Paper [2026]" read as a character class. A tree whose tracked paths differ only
by case or Unicode form is dirty for good on a macOS or Windows disk, and the
hook's stash could never pop; so is a CRLF blob under a later `eol=lf` rule, on
every disk. A stash push that made no stash had the hook pop the user's own.
validate-setup asked the shell's repository for the git identity, not its own.

Every git run gets the caller's environment WITHOUT its GIT_* variables (this suite
runs inside .githooks/pre-commit, which exports GIT_DIR and GIT_INDEX_FILE at the
user's repository) and with no global or system config, so a user's own
core.hooksPath or identity cannot reach a fixture.
"""
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unicodedata
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BASH = shutil.which("bash")
HOOK = os.path.join(ROOT, ".githooks", "pre-commit")
_DROP = ("PYTHONIOENCODING", "PYTHONUTF8", "PYTHONWARNDEFAULTENCODING", "PYTHONWARNINGS",
         "CLAUDE_PROJECT_DIR", "BACKTEST_SKIP_HOOK_BATTERY", "SKIP_QUALITY_GATE", "HOOK_DIR")


def _env(**extra):
    env = {k: v for k, v in os.environ.items()
           if not (k.startswith("GIT_") and k != "GIT_EXEC_PATH") and k not in _DROP}
    env.update(GIT_CONFIG_NOSYSTEM="1", GIT_CONFIG_GLOBAL=os.devnull,
               GIT_AUTHOR_NAME="t", GIT_AUTHOR_EMAIL="t@example.invalid",
               GIT_COMMITTER_NAME="t", GIT_COMMITTER_EMAIL="t@example.invalid")
    env.update(extra)
    return env


def _run(cmd, cwd=None, input=None, timeout=300, **extra):
    """(exit code, stdout+stderr as UTF-8 text)."""
    r = subprocess.run(cmd, cwd=cwd, env=_env(**extra), input=input, stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, timeout=timeout)
    return r.returncode, r.stdout.decode("utf-8", "replace")


def _git(base, *args, input=None):
    r = subprocess.run(["git", "-C", base, *args], env=_env(), input=input, capture_output=True)
    if r.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)}: {r.stderr.decode('utf-8', 'replace')}")
    return r.stdout


def _write(base, rel, content, mode=None):
    p = os.path.join(base, *rel.split("/"))
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "wb") as f:
        f.write(content if isinstance(content, bytes) else content.encode("utf-8"))
    if mode is not None:
        os.chmod(p, mode)
    return p


# ── the gates at a clone path with brackets ───────────────────────────────────

class BracketedClonePath(unittest.TestCase):
    """gates-glob-unescaped-root (G3): check-links and check-staleness matched nothing
    and passed on 0 files, check-spec-conformance found "no skills", and
    check-derived-counts counted 0 of everything."""

    # Each gate, and the count its pass line must show above zero (None: rc says it).
    GATES = (("check-links.py", r"\((\d+) files scanned\)"),
             ("check-staleness.py", r"(\d+) surfaces scanned"),
             ("check-spec-conformance.py", None),
             ("check-derived-counts.py", None))

    @classmethod
    def setUpClass(cls):
        # A clone of the WORKING TREE, not `git clone` of HEAD: under the pre-commit
        # hook HEAD still holds the gates being replaced, and the case would measure them.
        cls._td = tempfile.TemporaryDirectory()
        cls.repo = os.path.join(os.path.realpath(cls._td.name), "Paper [2026]", "repo")
        names = [n for n in _git(ROOT, "ls-files", "-z").decode("utf-8", "surrogateescape").split("\0") if n]
        kept = []
        for rel in names:
            src = os.path.join(ROOT, *rel.split("/"))
            if not os.path.isfile(src):          # deleted in the working tree
                continue
            dst = os.path.join(cls.repo, *rel.split("/"))
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            shutil.copy2(src, dst)
            kept.append(rel)
        _git(cls.repo, "init", "-q")
        # update-index, not add: a force-added file the .gitignore names is tracked all the same.
        _git(cls.repo, "update-index", "--add", "-z", "--stdin",
             input="\0".join(kept).encode("utf-8", "surrogateescape") + b"\0")

    @classmethod
    def tearDownClass(cls):
        cls._td.cleanup()

    def gate(self, name):
        return _run([sys.executable, os.path.join(self.repo, "scripts", name)], cwd=self.repo)

    def test_the_gates_scan_files_and_pass(self):
        for name, count in self.GATES:
            with self.subTest(gate=name):
                rc, out = self.gate(name)
                self.assertEqual(rc, 0, out)
                if count:
                    m = re.search(count, out)
                    self.assertTrue(m and int(m.group(1)) > 0, out)

    def test_a_broken_link_is_still_found(self):
        # The false pass itself: the broken link read as "all ... resolve (0 files scanned)".
        readme = os.path.join(self.repo, "README.md")
        with open(readme, "rb") as f:
            kept = f.read()
        self.addCleanup(_write, self.repo, "README.md", kept)
        with open(readme, "ab") as f:
            f.write(b"\n[broken](does-not-exist-xyz.md)\n")
        rc, out = self.gate("check-links.py")
        self.assertEqual(rc, 1, out)
        self.assertIn("does-not-exist-xyz.md   [missing file]", out)


class EmptyScan(unittest.TestCase):
    """A scan that finds nothing is a broken gate (exit 2), not a clean tree (exit 0):
    whatever next hides the files from the glob cannot pass in silence again."""

    def test_nothing_to_scan_is_an_error(self):
        with tempfile.TemporaryDirectory() as td:
            base = os.path.realpath(td)
            for name in ("check-links.py", "check-staleness.py"):
                dst = os.path.join(base, "scripts", name)
                os.makedirs(os.path.dirname(dst), exist_ok=True)
                shutil.copy2(os.path.join(ROOT, "scripts", name), dst)
            _git(base, "init", "-q")
            for name in ("check-links.py", "check-staleness.py"):
                with self.subTest(gate=name):
                    rc, out = _run([sys.executable, os.path.join(base, "scripts", name)], cwd=base)
                    self.assertEqual(rc, 2, out)
                    self.assertIn("nothing was checked", out)


# ── .githooks/pre-commit on a tree whose paths collide ────────────────────────

@unittest.skipUnless(BASH, "needs bash")
class PreCommitCollidingPaths(unittest.TestCase):
    """precommit-stash-leak-on-colliding-paths (G5): on a macOS or Windows disk the pair
    is one file, the tree is dirty for good, the EXIT-trap pop failed, and every commit
    left a "pre-commit-gate" stash holding the user's unstaged work. On a Linux disk
    the pair is two files and the round trip succeeded: the warning is the pin there."""

    PAIRS = (("templates/session-log.md", "templates/Session-Log.md"),
             ("notes/" + unicodedata.normalize("NFC", "seção.md"),
              "notes/" + unicodedata.normalize("NFD", "seção.md")))

    def commit_with_hook(self, pair):
        tmp = os.path.realpath(tempfile.mkdtemp(prefix="precommit-"))
        self.addCleanup(shutil.rmtree, tmp, True)
        src, clone, hooks = (os.path.join(tmp, d) for d in ("src", "clone", "hooks"))
        os.makedirs(src)
        _write(src, "README.md", "# Seed\n")
        # The gate suite is not under test: a stand-in that passes.
        _write(src, "scripts/backtest.sh", "#!/bin/sh\nexit 0\n", mode=0o755)
        _git(src, "init", "-q")
        _git(src, "add", "--", "README.md", "scripts/backtest.sh")
        args = []
        for i, rel in enumerate(pair):
            blob = _git(src, "hash-object", "-w", "--stdin", input=f"copy {i}\n".encode()).decode().strip()
            args += ["--add", "--cacheinfo", f"100644,{blob},{rel}"]
        # precomposeunicode off, or macOS git turns the NFD argument into the NFC one.
        _git(src, "-c", "core.precomposeunicode=false", "update-index", *args)
        _git(src, "commit", "-q", "--no-verify", "-m", "seed")
        rc, out = _run(["git", "clone", "-q", src, clone])   # "paths have collided" on APFS / NTFS
        self.assertEqual(rc, 0, out)
        os.makedirs(hooks)
        shutil.copy2(HOOK, os.path.join(hooks, "pre-commit"))
        os.chmod(os.path.join(hooks, "pre-commit"), 0o755)
        # The user's work: an unstaged edit, and a staged new file.
        _write(clone, "README.md", "# Seed\n\nUnstaged work in progress.\n")
        _write(clone, "notes.md", "x\n")
        _git(clone, "add", "--", "notes.md")
        rc, out = _run(["git", "-c", f"core.hooksPath={hooks}", "commit", "-m", "x"], cwd=clone)
        stashes = _git(clone, "stash", "list").decode("utf-8", "replace")
        with open(os.path.join(clone, "README.md"), encoding="utf-8") as f:
            readme = f.read()
        return rc, out, stashes, readme

    def test_no_stash_is_left_behind(self):
        for pair in self.PAIRS:
            with self.subTest(pair=pair[1]):
                rc, out, stashes, readme = self.commit_with_hook(pair)
                self.assertEqual(stashes, "", out)
                self.assertIn("Unstaged work in progress.", readme, out)
                self.assertNotIn("could not auto-restore", out)
                self.assertIn("differ only by case or Unicode form", out)
                self.assertEqual(rc, 0, out)


def _hook_dir(tmp):
    hooks = os.path.join(tmp, "hooks")
    os.makedirs(hooks)
    shutil.copy2(HOOK, os.path.join(hooks, "pre-commit"))
    os.chmod(os.path.join(hooks, "pre-commit"), 0o755)
    return hooks


def _seed(repo):
    _write(repo, "README.md", "# Seed\n")
    # The gate suite is not under test: a stand-in that passes.
    _write(repo, "scripts/backtest.sh", "#!/bin/sh\nexit 0\n", mode=0o755)


@unittest.skipUnless(BASH, "needs bash")
class PreCommitDirtyForGood(unittest.TestCase):
    """precommit-stash-leak-on-dirty-tree (G5, the cause the collision pre-check does not
    cover): run.sh committed with CRLF before `*.sh text eol=lf` (the template's own rule)
    stays modified after `stash push --keep-index`, on every OS. The EXIT-trap pop failed,
    the commit went through, and each one moved the user's unstaged work into another
    "pre-commit-gate" stash. Restoring only the paths the stash had cleaned would still
    lose an edit to run.sh itself: the edited case pins that."""

    def commit_with_hook(self, edit_the_dirty_path):
        tmp = os.path.realpath(tempfile.mkdtemp(prefix="precommit-"))
        self.addCleanup(shutil.rmtree, tmp, True)
        repo = os.path.join(tmp, "repo")
        _seed(repo)
        run = _write(repo, "run.sh", b"echo one\r\necho two\r\n")
        _write(repo, "old.txt", "kept\n")
        _git(repo, "init", "-q")
        _git(repo, "add", "--", "README.md", "scripts/backtest.sh", "run.sh", "old.txt")
        _git(repo, "commit", "-q", "--no-verify", "-m", "seed")
        _write(repo, ".gitattributes", "*.sh text eol=lf\n")
        _git(repo, "add", "--", ".gitattributes")
        _git(repo, "commit", "-q", "--no-verify", "-m", "attrs")
        # A changed mtime: while the stat cache vouches for run.sh, git never rehashes it.
        st = os.stat(run)
        os.utime(run, (st.st_atime, st.st_mtime - 100))
        self.assertIn(b"run.sh", _git(repo, "diff", "--name-only"))   # dirty before any edit
        hooks = _hook_dir(tmp)
        # The user's work: unstaged edits (and a deletion), and a staged new file.
        _write(repo, "README.md", "# Seed\n\nUnstaged work in progress.\n")
        if edit_the_dirty_path:
            _write(repo, "run.sh", b"echo one\r\necho two\r\necho three\r\n")
            os.remove(os.path.join(repo, "old.txt"))
        _write(repo, "notes.md", "x\n")
        _git(repo, "add", "--", "notes.md")
        rc, out = _run(["git", "-c", f"core.hooksPath={hooks}", "commit", "-m", "x"], cwd=repo)
        stashes = _git(repo, "stash", "list").decode("utf-8", "replace")
        return repo, rc, out, stashes

    def test_the_unstaged_work_stays_in_the_tree(self):
        for edited in (False, True):
            with self.subTest(edit_the_dirty_path=edited):
                repo, rc, out, stashes = self.commit_with_hook(edited)
                self.assertEqual(stashes, "", out)
                with open(os.path.join(repo, "README.md"), encoding="utf-8") as f:
                    self.assertIn("Unstaged work in progress.", f.read(), out)
                if edited:
                    with open(os.path.join(repo, "run.sh"), "rb") as f:
                        self.assertIn(b"echo three", f.read(), out)
                    self.assertFalse(os.path.exists(os.path.join(repo, "old.txt")), out)
                self.assertNotIn("could not auto-restore", out)
                self.assertIn("stays modified after stashing", out)
                self.assertEqual(rc, 0, out)
                # Restored to the working tree only: the commit carries the staged file alone.
                self.assertEqual(_git(repo, "show", "--format=", "--name-only", "HEAD"), b"notes.md\n")
                self.assertEqual(_git(repo, "diff", "--cached", "--name-only"), b"")


@unittest.skipUnless(BASH, "needs bash")
class PreCommitMadeNoStash(unittest.TestCase):
    """precommit-pops-a-stash-it-did-not-make: with nothing staged (`commit --amend`) and a
    submodule's own dirty content as the only unstaged change, `stash push` exits 0 having
    made no stash, and the EXIT trap popped the user's own newest stash into the tree."""

    def test_the_users_stash_is_left_alone(self):
        tmp = os.path.realpath(tempfile.mkdtemp(prefix="precommit-"))
        self.addCleanup(shutil.rmtree, tmp, True)
        sub_src, repo = os.path.join(tmp, "subsrc"), os.path.join(tmp, "repo")
        _write(sub_src, "s.txt", "s\n")
        _git(sub_src, "init", "-q")
        _git(sub_src, "add", "--", "s.txt")
        _git(sub_src, "commit", "-q", "-m", "s")
        _seed(repo)
        _git(repo, "init", "-q")
        _git(repo, "add", "--", "README.md", "scripts/backtest.sh")
        _git(repo, "commit", "-q", "--no-verify", "-m", "seed")
        _git(repo, "-c", "protocol.file.allow=always", "submodule", "add", "-q", sub_src, "sub")
        _git(repo, "commit", "-q", "--no-verify", "-m", "sub")
        # The user's own stash, made long before this commit.
        _write(repo, "README.md", "# Seed\n\nOlder work, stashed.\n")
        _git(repo, "stash", "push", "-q", "-m", "users-own-stash")
        _write(repo, "sub/s.txt", "s\ndirty\n")
        self.assertEqual(_git(repo, "diff", "--name-only"), b"sub\n")
        hooks = _hook_dir(tmp)
        rc, out = _run(["git", "-c", f"core.hooksPath={hooks}", "commit", "--amend", "-m", "reworded"],
                       cwd=repo)
        stashes = _git(repo, "stash", "list").decode("utf-8", "replace")
        self.assertIn("users-own-stash", stashes, out)
        with open(os.path.join(repo, "README.md"), encoding="utf-8") as f:
            self.assertEqual(f.read(), "# Seed\n", out)
        self.assertEqual(rc, 0, out)


# ── validate-setup.sh ─────────────────────────────────────────────────────────

@unittest.skipUnless(BASH, "needs bash")
class ValidateSetupIdentity(unittest.TestCase):
    """validate-setup-identity-reads-cwd-repo (G8): run from outside its clone, a
    repo-local identity read as "not set", or another repository's was reported."""

    STUB = "#!/bin/sh\necho stub 1.0\n"

    def setUp(self):
        self._td = tempfile.TemporaryDirectory()
        self.addCleanup(self._td.cleanup)
        self.tmp = os.path.realpath(self._td.name)
        self.repo = os.path.join(self.tmp, "template")
        dst = os.path.join(self.repo, "scripts", "validate-setup.sh")
        os.makedirs(os.path.dirname(dst))
        shutil.copy2(os.path.join(ROOT, "scripts", "validate-setup.sh"), dst)
        _git(self.repo, "init", "-q")
        _git(self.repo, "config", "user.name", "tester")
        _git(self.repo, "config", "user.email", "t@example.invalid")
        stubs = os.path.join(self.tmp, "bin")
        for name in ("claude", "xelatex", "quarto", "R", "gh"):
            _write(stubs, name, self.STUB, mode=0o755)
        self.home = os.path.join(self.tmp, "home")        # no ~/.gitconfig
        os.makedirs(self.home)
        self.path = stubs + os.pathsep + os.environ.get("PATH", "")

    def setup_out(self, cwd, **extra):
        rc, out = _run([BASH, os.path.join(self.repo, "scripts", "validate-setup.sh")], cwd=cwd,
                       PATH=self.path, SLIDE_QA_PYTHON="true", HOME=self.home,
                       XDG_CONFIG_HOME=os.path.join(self.home, ".config"), **extra)
        return out

    def test_reads_its_own_identity_from_outside_it(self):
        elsewhere = os.path.join(self.tmp, "elsewhere")
        os.makedirs(elsewhere)
        out = self.setup_out(elsewhere)
        self.assertIn("git user: tester <t@example.invalid>", out)
        self.assertNotIn("user.email not set", out)

    def test_another_repositorys_identity_is_not_its_own(self):
        other = os.path.join(self.tmp, "other")
        os.makedirs(other)
        _git(other, "init", "-q")
        _git(other, "config", "user.name", "otheruser")
        _git(other, "config", "user.email", "o@example.invalid")
        out = self.setup_out(other)
        self.assertIn("git user: tester <t@example.invalid>", out)
        self.assertNotIn("otheruser", out)

    def test_control_an_exported_copy_falls_back_to_the_global_identity(self):
        shutil.rmtree(os.path.join(self.repo, ".git"))
        glob_cfg = _write(self.tmp, "global.gitconfig", "[user]\n\tname = global\n\temail = g@example.invalid\n")
        out = self.setup_out(self.tmp, GIT_CONFIG_GLOBAL=glob_cfg)
        self.assertIn("git user: global <g@example.invalid>", out)


if __name__ == "__main__":
    unittest.main()

"""Hooks and the status line on machines that are not the author's Mac (issue #171).

Each class pins one finding from the 2026-09-27 stress test (its id is in the class
docstring; FindingIds, last, checks that) and fails on the hooks as they stood at
08a7641. Three ways in:

  * the REAL hook as a subprocess, fed a JSON event on stdin, exactly as Claude Code
    and scripts/hook-battery.sh run it;
  * the same, with the stdio code page a Windows machine uses for a pipe —
    PYTHONIOENCODING=<cp>:surrogateescape, since on Windows CPython always pairs the
    ANSI code page with surrogateescape — or with default-encoding I/O turned into an
    error (-X warn_default_encoding -W error::EncodingWarning);
  * the real module loaded through _winsim, where os.path is ntpath and pathlib is a
    WindowsPath, for the separator cases that only exist on Windows.
"""
import ast
import hashlib
import io
import json
import os
import re
import shlex
import shutil
import stat
import subprocess
import sys
import tempfile
import time
import unittest

import _winsim

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HOOKS = os.path.join(ROOT, ".claude", "hooks")
STATUSLINE = os.path.join(ROOT, ".claude", "scripts", "statusline.sh")
SETTINGS = os.path.join(ROOT, ".claude", "settings.json")
BASH = shutil.which("bash") or "/bin/bash"

# Everything a developer's own shell could set that would decide a case for it.
_SCRUB = ("ALLOW_ROOT_OF_TRUST_WRITE", "ALLOW_DIRTY_MERGE", "CLAUDE_STRICT_PATHS",
          "CLAUDE_PROJECT_DIR", "CLAUDE_HANDOFF", "CLAUDE_HANDOFF_MAX_AGE_DAYS",
          "CLAUDE_CODE_ENTRYPOINT", "CLAUDE_ISSUES_AT_START", "CLAUDE_COMPILE_GATE",
          "CLAUDE_PRECOMPACT_BLOCK_ON_DRAFT", "CLAUDE_CONTEXT_WINDOW_TOKENS",
          "CLAUDE_CONTEXT_MAX_TOOL_CALLS", "PYTHONIOENCODING", "PYTHONUTF8",
          "PYTHONWARNINGS", "PYTHONWARNDEFAULTENCODING", "PYTHONPATH")


def clean_env(home, **extra):
    env = {k: v for k, v in os.environ.items()
           if k not in _SCRUB and (not k.startswith("GIT_") or k == "GIT_EXEC_PATH")}
    env["HOME"] = home
    env.update(extra)
    return env


def git(cwd, *args, env=None):
    # Never the inherited GIT_*: under the pre-commit hook GIT_DIR / GIT_INDEX_FILE
    # name the real repository, and a fixture `git init` would act on it.
    if env is None:
        env = {k: v for k, v in os.environ.items()
               if not k.startswith("GIT_") or k == "GIT_EXEC_PATH"}
    subprocess.run(["git", "-c", "user.name=t", "-c", "user.email=t@example.com",
                    "-c", "commit.gpgsign=false", *args],
                   cwd=cwd, env=env, check=True, capture_output=True)


def fire(hook, event, env, pyflags=(), cwd=None):
    """Run a real hook as Claude Code does; returns (stdout, stderr) as text."""
    data = json.dumps(event, ensure_ascii=False).encode("utf-8")
    r = subprocess.run([sys.executable, *pyflags, os.path.join(HOOKS, hook)],
                       input=data, env=env, cwd=cwd, capture_output=True, timeout=60)
    return r.stdout.decode("utf-8", "replace"), r.stderr.decode("utf-8", "replace")


def decision(out):
    try:
        return json.loads(out)["hookSpecificOutput"]["permissionDecision"]
    except (ValueError, KeyError, TypeError):
        return "silent" if not out.strip() else "unparseable"


def sim_fire(hook, event, env, codepage="utf-8"):
    """Run a real hook as __main__ under the Windows simulation (os.path=ntpath,
    pathlib=WindowsPath). stdin is a text pipe in `codepage`, as Windows gives it."""
    data = json.dumps(event, ensure_ascii=False).encode("utf-8")
    stdin = io.TextIOWrapper(io.BytesIO(data), encoding=codepage, errors="surrogateescape")
    out, err = io.StringIO(), io.StringIO()
    saved = sys.stdin, sys.stdout, sys.stderr
    old = {k: os.environ.get(k) for k in env}
    os.environ.update(env)
    sys.stdin, sys.stdout, sys.stderr = stdin, out, err
    try:
        try:
            _winsim.load(os.path.join(HOOKS, hook), as_main=True)
        except SystemExit:
            pass
    finally:
        sys.stdin, sys.stdout, sys.stderr = saved
        for k, v in old.items():
            if v is None:
                os.environ.pop(k, None)
            else:
                os.environ[k] = v
    return out.getvalue()


class _Tmp(unittest.TestCase):
    def setUp(self):
        # realpath: on macOS the temp root is a symlink (/var -> /private/var)
        self.tmp = os.path.realpath(tempfile.mkdtemp(prefix="port-hooks-"))
        self.addCleanup(shutil.rmtree, self.tmp, True)
        self.home = os.path.join(self.tmp, "home")
        os.makedirs(self.home)

    def path(self, *parts):
        return os.path.join(self.tmp, *parts)

    def write(self, rel, text):
        p = self.path(rel)
        os.makedirs(os.path.dirname(p), exist_ok=True)
        with open(p, "w", encoding="utf-8") as f:
            f.write(text)
        return p


# ── git-guardrails / issue-guard: the program word ─────────────────────────
class ExeProgramNames(_Tmp):
    """guards-miss-dot-exe-program-names: `git.exe`, a quoted `C:\\...\\git.exe` and
    `gh.exe` run the same programs in Git Bash, and passed both guards."""

    def gg(self, command):
        ev = {"tool_name": "Bash", "tool_input": {"command": command}, "cwd": self.tmp}
        return decision(fire("git-guardrails.py", ev, clean_env(self.home))[0])

    def ig(self, command):
        ev = {"tool_name": "Bash", "tool_input": {"command": command}, "cwd": self.tmp}
        return decision(fire("issue-guard.py", ev, clean_env(self.home))[0])

    def test_git_exe_spellings_are_denied(self):
        for cmd in ("git.exe reset --hard",
                    "GIT.EXE push --force origin main",
                    "'C:\\Program Files\\Git\\cmd\\git.exe' clean -fdx",
                    '"/c/Program Files/Git/cmd/git.exe" reset --hard'):
            with self.subTest(cmd=cmd):
                self.assertEqual(self.gg(cmd), "deny")

    def test_git_exe_harmless_command_is_silent(self):
        self.assertEqual(self.gg("git.exe status"), "silent")

    # Piped straight to the hook, so these check its reading of the program word.
    # As deployed only `gh.exe` gets that far: the `if` filters never spawn the hook
    # for the other two, so their deny holds only where the filter is ignored
    # (Claude Code < 2.1.85). test_filter_misses_are_disclosed pins that.
    GH_SPELLINGS = ("gh.exe issue create -t x -b y", "GH.EXE issue create -t x -b y",
                    "'C:\\Program Files\\GitHub CLI\\gh.exe' issue create -t x -b y")

    def test_gh_exe_issue_create_is_denied(self):
        for cmd in self.GH_SPELLINGS:
            with self.subTest(cmd=cmd):
                self.assertEqual(self.ig(cmd), "deny")

    def test_filter_misses_are_disclosed(self):
        """A spelling the hook denies but no `if` filter spawns it for is a residual,
        and the docstring has to say so rather than let the test above overstate the
        cover. The filter is emulated as Claude Code 2.1.283 runs it
        (preparePermissionMatcher): the argv joined by spaces, matched against the
        rule as a CASE-SENSITIVE glob in which one trailing ` *` also admits the bare
        word, so `gh *` is /^gh( .*)?$/s. `GH` runs gh on a case-insensitive disk."""
        with open(SETTINGS, encoding="utf-8") as f:
            cfg = json.load(f)
        rules = [h["if"][len("Bash("):-1] for group in cfg["hooks"]["PreToolUse"]
                 for h in group.get("hooks") or []
                 if "issue-guard.py" in h.get("command", "") and h.get("if")]
        self.assertTrue(rules and all(r.endswith(" *") and r.count("*") == 1 for r in rules),
                        rules)

        def reached(cmd):
            argv = " ".join(shlex.split(cmd))
            return any(re.fullmatch(re.escape(r[:-2]) + "( .*)?", s, re.S)
                       for r in rules for s in (argv, "xargs " + argv))

        with open(os.path.join(HOOKS, "issue-guard.py"), encoding="utf-8") as f:
            doc = ast.get_docstring(ast.parse(f.read()))
        residuals = doc[doc.index("What this is not"):].split("\n\n")[0]
        self.assertTrue(reached("gh issue create -t x -b y"))
        self.assertTrue(reached("gh.exe issue create -t x -b y"))
        for cmd, named in ((self.GH_SPELLINGS[1], "`GH.EXE`"),
                           ("GH issue create -t x -b y", "`GH`"),
                           (self.GH_SPELLINGS[2], "'C:\\Program Files\\GitHub CLI\\gh.exe'"),
                           ("/opt/homebrew/bin/gh issue create -t x -b y", "`/path/to/gh`")):
            with self.subTest(cmd=cmd):
                self.assertEqual(self.ig(cmd), "deny")
                if not reached(cmd):
                    self.assertIn(named, residuals)

    def test_gh_exe_issue_list_is_silent(self):
        self.assertEqual(self.ig("gh.exe issue list"), "silent")

    def test_issue_guard_is_registered_for_gh_exe_too(self):
        with open(SETTINGS, encoding="utf-8") as f:
            cfg = json.load(f)
        found = {}
        for group in cfg["hooks"]["PreToolUse"]:
            for h in group.get("hooks") or []:
                if "issue-guard.py" in h.get("command", ""):
                    found[h.get("if")] = (group.get("matcher"), h["command"], h.get("timeout"))
        self.assertIn("Bash(gh *)", found, "the gh filter was dropped")
        self.assertIn("Bash(gh.exe *)", found, "no registration fires the guard for gh.exe")
        self.assertEqual(found["Bash(gh *)"], found["Bash(gh.exe *)"],
                         "the two registrations differ in more than the filter")


class CarriageReturnInsideWords(_Tmp):
    """carriage-return-in-word-bypasses-guards (the git-guardrails and issue-guard
    halves; root-of-trust-guard's is the rot group's): Git Bash drops every CR before
    it splits words, so `git re<CR>set --hard` runs `git reset --hard`; the guards
    read two words."""

    def test_git_guardrails_joins_the_word(self):
        for cmd in ("git re\rset --hard", "gi\rt clean -fdx", "git reset \\\r\n--hard"):
            with self.subTest(cmd=repr(cmd)):
                ev = {"tool_name": "Bash", "tool_input": {"command": cmd}, "cwd": self.tmp}
                self.assertEqual(decision(fire("git-guardrails.py", ev, clean_env(self.home))[0]),
                                 "deny")

    def test_issue_guard_joins_the_word(self):
        ev = {"tool_name": "Bash", "tool_input": {"command": "gh issue cr\reate -t x -b y"}}
        self.assertEqual(decision(fire("issue-guard.py", ev, clean_env(self.home))[0]), "deny")

    def test_crlf_line_ending_still_separates_commands(self):
        ev = {"tool_name": "Bash", "tool_input": {"command": "git status\r\ngit log -1\r\n"},
              "cwd": self.tmp}
        self.assertEqual(decision(fire("git-guardrails.py", ev, clean_env(self.home))[0]),
                         "silent")


# ── the event itself: stdin decoded with the Windows code page ─────────────
class GuardStdinCodePage(_Tmp):
    """guard-stdin-codepage-fail-open, guard-stdin-mojibake-scope-bypass and
    hook-stdin-ansi-codepage-fail-open (the git-guardrails and issue-guard halves;
    root-of-trust-guard's are the rot group's): the event was decoded with the ANSI
    code page. Western: an accented path became mojibake. CJK: a multibyte character
    swallowed the backslash of `\\"` and the JSON did not parse, so the guard exited
    silent."""

    def test_accented_dirty_repo_merge_is_denied_on_cp1252(self):
        repo = self.path("Pé proj")
        os.makedirs(repo)
        git(repo, "init", "-q")
        self.write("Pé proj/untracked.txt", "x\n")
        ev = {"tool_name": "Bash", "tool_input": {"command": "git merge feature"}, "cwd": repo}
        env = clean_env(self.home, PYTHONUTF8="0", PYTHONIOENCODING="cp1252:surrogateescape")
        self.assertEqual(decision(fire("git-guardrails.py", ev, env)[0]), "deny")

    @_winsim.needs_encoding_warning
    def test_status_read_is_not_locale_decoded(self):
        """`git status` output decoded with the locale: on Windows with quotePath off,
        a name the code page cannot decode raised, and the guard read that as an
        unanswered question. A clean tree prints nothing, so it was never refused;
        the reachable effects are a dirty tree denied for the wrong reason and a
        `--autostash` merge over tracked-only dirt denied although it is allowed
        (test_autostash_over_tracked_dirt_is_allowed reproduces that one). Here
        default-encoding decoding is made an error, which trips the call itself
        whatever git prints, on any OS."""
        repo = self.path("clean")
        os.makedirs(repo)
        git(repo, "init", "-q")
        ev = {"tool_name": "Bash", "tool_input": {"command": "git merge feature"}, "cwd": repo}
        out = fire("git-guardrails.py", ev, clean_env(self.home),
                   ("-X", "warn_default_encoding", "-W", "error::EncodingWarning"))[0]
        self.assertEqual(decision(out), "silent", out)

    def test_autostash_over_tracked_dirt_is_allowed(self):
        """The Windows effect itself, with an ASCII locale standing in for a code page
        that cannot decode the name: quotePath off, only a tracked `Á.txt` modified.
        Rule 2b allows `--autostash` here; the undecodable status denied it."""
        repo = self.path("tracked")
        os.makedirs(repo)
        git(repo, "init", "-q")
        git(repo, "config", "core.quotePath", "off")
        self.write("tracked/Á.txt", "a\n")
        git(repo, "add", "-A")
        git(repo, "commit", "-qm", "c")
        self.write("tracked/Á.txt", "b\n")
        env = clean_env(self.home, LC_ALL="C", PYTHONUTF8="0")
        ev = {"tool_name": "Bash", "tool_input": {"command": "git merge --autostash feature"},
              "cwd": repo}
        out = fire("git-guardrails.py", ev, env)[0]
        self.assertEqual(decision(out), "silent", out)
        ev["tool_input"]["command"] = "git merge feature"
        self.assertIn("must start from a clean tree", fire("git-guardrails.py", ev, env)[0])

    def test_cjk_command_still_parses_for_both_guards(self):
        env = clean_env(self.home, PYTHONUTF8="0", PYTHONIOENCODING="cp936:surrogateescape")
        ev = {"tool_name": "Bash", "tool_input": {"command": 'echo "王" && git reset --hard'},
              "cwd": self.tmp}
        self.assertEqual(decision(fire("git-guardrails.py", ev, env)[0]), "deny")
        ev = {"tool_name": "Bash", "tool_input": {"command": 'gh issue create -t "王" -b x'}}
        self.assertEqual(decision(fire("issue-guard.py", ev, env)[0]), "deny")


# ── git-guardrails: -C in Git Bash spelling ─────────────────────────────────
class MsysDashC(_Tmp):
    """git-guardrails-msys-dash-c-false-deny: `-C /c/Users/me/proj` is what Git Bash
    turns into `C:/Users/me/proj` for git.exe; Windows Python read it as C:\\c\\..."""

    def test_resolve_maps_the_drive(self):
        m = _winsim.load(os.path.join(HOOKS, "git-guardrails.py"))
        self.assertEqual(m._resolve_dash_c(["/c/work/repo"], "C:\\proj").lower(), "c:\\work\\repo")

    def test_posix_keeps_c_as_a_directory(self):
        import importlib.util
        spec = importlib.util.spec_from_file_location("gg_posix",
                                                      os.path.join(HOOKS, "git-guardrails.py"))
        m = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(m)
        self.assertEqual(m._resolve_dash_c(["/c/work/repo"], "/proj"),
                         os.path.realpath("/c/work/repo"))

    def test_clean_repo_merge_via_msys_path_is_allowed(self):
        repo = self.path("clean")
        os.makedirs(repo)
        git(repo, "init", "-q")
        ev = {"tool_name": "Bash", "tool_input": {"command": f"git -C /c{repo} merge feature"},
              "cwd": _winsim.to_win(self.tmp)}
        out = sim_fire("git-guardrails.py", ev, {"HOME": self.home})
        self.assertEqual(decision(out), "silent", out)
        self.write("clean/dirt.txt", "x\n")
        out = sim_fire("git-guardrails.py", ev, {"HOME": self.home})
        self.assertIn("must start from a clean tree", out)


# ── git-guardrails: hardcoded machine paths ─────────────────────────────────
class HardcodedPaths(_Tmp):
    """hardcoded-path-misses-single-backslash, hardcoded-path-check-misses-windows-and-case:
    Stata's `cd "C:\\Users\\me"`, a raw string, `c:/users/`, and `.rmd` / `MASTER.DO`
    passed CLAUDE_STRICT_PATHS=1; a global (?i) would falsely flag a GitHub API URL."""

    def strict(self, name, content):
        ev = {"tool_name": "Write",
              "tool_input": {"file_path": self.path("scripts", name), "content": content}}
        return decision(fire("git-guardrails.py", ev,
                             clean_env(self.home, CLAUDE_STRICT_PATHS="1"))[0])

    def test_windows_user_paths_are_denied(self):
        for name, content in (("master.do", 'cd "C:\\Users\\me\\proj"\n'),
                              ("a.do", 'use "C:\\Users\\pedro\\Dropbox\\data.dta", clear\n'),
                              ("a.py", 'pd.read_csv(r"C:\\Users\\pedro\\proj\\data.csv")\n'),
                              ("a.R", 'read.csv("c:/users/pedro/x.csv")\n'),
                              ("a.R", 'read.csv("C:\\\\Users\\\\pedro\\\\x.csv")\n'),
                              ("a.py", 'open(r"\\\\?\\C:\\Users\\pedro\\x.csv")\n')):
            with self.subTest(name=name, content=content):
                self.assertEqual(self.strict(name, content), "deny")

    def test_extension_case_does_not_skip_the_check(self):
        for name in ("a.rmd", "MASTER.DO", "a.PY", "a.QMD"):
            with self.subTest(name=name):
                self.assertEqual(self.strict(name, 'x <- "/Users/me/x"\n'), "deny")

    def test_controls_stay_allowed(self):
        for name, content in (("a.py", 'requests.get("https://api.github.com/users/octocat/repos")\n'),
                              ("a.py", 'url = "gs://users/x.csv"\n'),
                              ("a.py", 'url = "https://users/x"\n'),
                              ("a.py", 'x = {"key:/users/me": 1}\n'),
                              ("a.R", 'read.csv(here::here("data", "x.csv"))\n'),
                              ("notes.md", 'cd "C:\\Users\\me\\proj"\n')):
            with self.subTest(name=name, content=content):
                self.assertEqual(self.strict(name, content), "silent")

    def test_default_mode_warns(self):
        ev = {"tool_name": "Write", "tool_input": {"file_path": self.path("scripts", "master.do"),
                                                   "content": 'cd "C:\\Users\\me\\proj"\n'}}
        out, err = fire("git-guardrails.py", ev, clean_env(self.home))
        self.assertEqual(out.strip(), "")
        self.assertIn("Hardcoded machine path", err)


# ── claim-reconcile ────────────────────────────────────────────────────────
PASSPORT = """claims:
  - id: C1
    description: headline estimate
    source_file: scripts/analysis.R
    location: paper.tex
    appears_in:
      - path: paper.tex
      - path: slides.qmd
  - id: C2
    description: saved model object
    output_file: output/main.rds
  - id: C3
    description: a number shown in the paper and the deck
    location: paper/main.tex
    appears_in:
      - path: paper/main.tex
      - path: Slides/Lecture1.tex
"""


class _Proj(_Tmp):
    PROJ = "proj"

    def setUp(self):
        super().setUp()
        self.proj = self.path(self.PROJ)
        self.write(f"{self.PROJ}/quality_reports/passports/demo.yaml", PASSPORT)
        for rel in ("scripts/analysis.R", "output/main.rds", "paper.tex", "slides.qmd",
                    "paper/main.tex", "Slides/Lecture1.tex", "notes.md"):
            self.write(f"{self.PROJ}/{rel}", "")


class ClaimReconcileWindowsPaths(_Proj):
    """claim-reconcile-watch-regex-slash-only, claim-reconcile-watch-backslash (both
    reports), claim-reconcile-relpath-backslash: a backslash file_path never passed
    the `/`-only WATCH filter, and a forward-slash one produced `scripts\\analysis.R`,
    which never matched the passport's `scripts/analysis.R`."""

    def edit(self, file_path):
        ev = {"tool_name": "Edit", "tool_input": {"file_path": file_path}}
        return sim_fire("claim-reconcile.py", ev,
                        {"HOME": self.home, "CLAUDE_PROJECT_DIR": _winsim.to_win(self.proj)})

    def test_backslash_script_and_output_are_stale(self):
        for rel in ("scripts/analysis.R", "output/main.rds"):
            with self.subTest(rel=rel):
                out = self.edit(_winsim.to_win(os.path.join(self.proj, rel)))
                self.assertIn(f"{rel} changed", out)
                self.assertIn("STALE", out)

    def test_forward_slash_drive_path_is_stale(self):
        p = "C:" + os.path.join(self.proj, "scripts", "analysis.R")
        out = self.edit(p)
        self.assertIn("scripts/analysis.R changed", out)
        self.assertIn("STALE", out)

    def test_backslash_display_and_control(self):
        out = self.edit(_winsim.to_win(os.path.join(self.proj, "paper", "main.tex")))
        self.assertIn("disagree", out)
        self.assertEqual(self.edit(_winsim.to_win(os.path.join(self.proj, "notes.md"))), "")
        self.assertEqual(self.edit(_winsim.to_win(os.path.join(self.proj, "myscripts", "x.R"))), "")


class ClaimReconcileCaseVariants(_Proj):
    """claim-reconcile-case-variant-paths: on macOS and Windows `slides/` is `Slides/`,
    but the relative path, the provenance test and the display test were exact."""

    def edit(self, file_path):
        ev = {"tool_name": "Edit", "tool_input": {"file_path": file_path}}
        return fire("claim-reconcile.py", ev,
                    clean_env(self.home, CLAUDE_PROJECT_DIR=self.proj))[0]

    def test_case_varied_display_nudges(self):
        for rel in ("slides/Lecture1.tex", "Slides/lecture1.tex", "Paper.tex"):
            with self.subTest(rel=rel):
                shutil.rmtree(os.path.join(self.home, ".claude"), ignore_errors=True)
                self.assertIn("disagree", self.edit(os.path.join(self.proj, rel)))

    def test_case_varied_producer_is_stale(self):
        for rel in ("scripts/Analysis.R", "Scripts/analysis.R", "Output/main.rds"):
            with self.subTest(rel=rel):
                shutil.rmtree(os.path.join(self.home, ".claude"), ignore_errors=True)
                self.assertIn("STALE", self.edit(os.path.join(self.proj, rel)))

    def test_case_varied_project_prefix(self):
        up = os.path.join(os.path.dirname(self.proj), self.PROJ.upper(), "paper", "main.tex")
        self.assertIn("paper/main.tex changed", self.edit(up))

    def test_case_variants_share_one_throttle_and_control_is_silent(self):
        self.assertIn("disagree", self.edit(os.path.join(self.proj, "paper.tex")))
        self.assertEqual(self.edit(os.path.join(self.proj, "PAPER.tex")), "")
        self.assertEqual(self.edit(os.path.join(self.proj, "notes.md")), "")


class ClaimReconcileStdin(_Proj):
    """nonguard-hooks-stdin-silent (claim-reconcile): an accented project path came
    through a cp1252 stdin as mojibake, relative_to failed, and the display check
    compared the bare basename."""
    PROJ = "Pé proj"

    def test_accented_project_display_edit_nudges(self):
        ev = {"tool_name": "Edit",
              "tool_input": {"file_path": os.path.join(self.proj, "paper", "main.tex")}}
        env = clean_env(self.home, CLAUDE_PROJECT_DIR=self.proj,
                        PYTHONUTF8="0", PYTHONIOENCODING="cp1252:surrogateescape")
        out = fire("claim-reconcile.py", ev, env)[0]
        self.assertIn("paper/main.tex changed", out)


# ── compaction: plan and session log read with the locale ──────────────────
class CompactionUtf8(_Tmp):
    """compaction-plan-read-locale (and the pre-compact/post-compact half of
    nonguard-hooks-stdin-silent): with no encoding, Windows read the plan in its code
    page — a curly quote raised and nothing was saved or restored. Pinned with
    default-encoding I/O made an error, which trips on every such call on any OS."""
    STRICT = ("-X", "warn_default_encoding", "-W", "error::EncodingWarning")

    @_winsim.needs_encoding_warning
    def test_state_survives_compaction(self):
        proj = self.path("proj")
        self.write("proj/quality_reports/plans/2026-09-27_x.md",
                   "# Plan\n**Status:** APPROVED\n\nThe referee said the “main” spec is fragile.\n"
                   "- [x] done\n- [ ] Re-run stage 2 → 3 with clustered SEs\n")
        self.write("proj/quality_reports/session_logs/2026-09-27_log.md",
                   "# Log\n→ Chose the clustered errors for table 3 ═ final\n")
        env = clean_env(self.home, CLAUDE_PROJECT_DIR=proj)
        fire("pre-compact.py", {"trigger": "manual", "custom_instructions": "keep “this”"},
             env, self.STRICT)
        h = hashlib.md5(proj.encode()).hexdigest()[:8]
        state = os.path.join(self.home, ".claude", "sessions", h, "pre-compact-state.json")
        self.assertTrue(os.path.exists(state), "pre-compact saved no state")
        with open(state, encoding="utf-8") as f:
            saved = json.load(f)
        self.assertIn("Re-run stage 2 → 3", saved["current_task"])
        self.assertTrue(any("Chose the clustered errors" in d for d in saved["decisions"]))
        out = fire("post-compact-restore.py", {"source": "compact"}, env, self.STRICT)[0]
        ctx = json.loads(out)["hookSpecificOutput"]["additionalContext"]
        self.assertIn("Re-run stage 2 → 3", ctx)
        self.assertIn("Chose the clustered errors", ctx)

    def test_restore_reads_a_cjk_profile_event(self):
        """The SessionStart event carries transcript_path; under C:\\Users\\王\\ on a
        CJK code page it did not parse, `source` read as empty, nothing was restored."""
        proj = self.path("proj")
        self.write("proj/quality_reports/plans/2026-09-27_x.md",
                   "# Plan\n**Status:** APPROVED\n- [ ] Re-run table 3\n")
        env = clean_env(self.home, CLAUDE_PROJECT_DIR=proj, PYTHONUTF8="0",
                        PYTHONIOENCODING="cp936:surrogateescape")
        out = fire("post-compact-restore.py",
                   {"source": "compact", "transcript_path": "C:\\Users\\王\\.claude\\t.jsonl"}, env)[0]
        self.assertIn("Re-run table 3", out)


# ── other session hooks ─────────────────────────────────────────────────────
class ContextMonitorStdin(_Tmp):
    """nonguard-hooks-stdin-silent (context-monitor): a transcript under an accented
    directory came through a cp1252 stdin as mojibake, getsize failed, and the
    estimate fell back to the tool-call counter. Its cache was also written in the
    locale encoding."""

    def test_accented_transcript_is_measured(self):
        tr = self.write("José/t.jsonl", "x" * 1000)
        env = clean_env(self.home, CLAUDE_PROJECT_DIR=self.tmp, CLAUDE_CONTEXT_WINDOW_TOKENS="250",
                        PYTHONUTF8="0", PYTHONIOENCODING="cp1252:surrogateescape")
        out = fire("context-monitor.py", {"transcript_path": tr}, env)[0]
        h = hashlib.md5(self.tmp.encode()).hexdigest()[:8]
        with open(os.path.join(self.home, ".claude", "sessions", h, "context-pct.txt"),
                  encoding="utf-8") as f:
            self.assertEqual(f.read(), "100")
        self.assertIn("Context ~100%", out)

    @_winsim.needs_encoding_warning
    def test_cache_io_is_utf8(self):
        tr = self.write("t.jsonl", "x" * 1000)
        env = clean_env(self.home, CLAUDE_PROJECT_DIR=self.tmp, CLAUDE_CONTEXT_WINDOW_TOKENS="250")
        out = fire("context-monitor.py", {"transcript_path": tr}, env,
                   ("-X", "warn_default_encoding", "-W", "error::EncodingWarning"))[0]
        self.assertIn("Context ~100%", out)


class SessionHandoffStdin(_Tmp):
    """nonguard-hooks-stdin-silent (session-handoff): on a CJK code page the prompt did
    not parse, the handoff was never marked delivered, and the next startup got it again.
    Its state file was also written in the locale encoding."""

    def checkpoint(self):
        proj = self.path("hp")
        ck = self.write("hp/quality_reports/checkpoints/2026-01-01_demo.md",
                        "# Checkpoint\nNEXT: finish table 3\n")
        t = time.time() - 3600
        os.utime(ck, (t, t))
        return proj

    @_winsim.needs_encoding_warning
    def test_state_io_is_utf8(self):
        env = clean_env(self.home, CLAUDE_PROJECT_DIR=self.checkpoint())
        start = {"hook_event_name": "SessionStart", "source": "startup", "session_id": "s1"}
        out = fire("session-handoff.py", start, env,
                   ("-X", "warn_default_encoding", "-W", "error::EncodingWarning"))[0]
        self.assertIn("finish table 3", out)

    def test_cjk_prompt_marks_delivered(self):
        proj = self.checkpoint()
        env = clean_env(self.home, CLAUDE_PROJECT_DIR=proj,
                        PYTHONUTF8="0", PYTHONIOENCODING="cp936:surrogateescape")
        start = {"hook_event_name": "SessionStart", "source": "startup", "session_id": "s1"}
        self.assertIn("finish table 3", fire("session-handoff.py", start, env)[0])
        fire("session-handoff.py", {"hook_event_name": "UserPromptSubmit",
                                    "prompt": '改 王"表3"', "session_id": "s1"}, env)
        start["session_id"] = "s2"
        self.assertEqual(fire("session-handoff.py", start, env)[0], "")


class OpenIssuesGhOutput(_Tmp):
    """nonguard-hooks-stdin-silent (open-issues): `gh api` output was decoded with the
    locale code page; one title holding ” made the whole list disappear on Windows."""

    def fake_gh(self, title):
        fake = self.path("bin")
        os.makedirs(fake, exist_ok=True)
        issues = [{"number": 7, "title": title, "labels": [], "author_association": "OWNER",
                   "repository_url": "https://api.github.com/repos/o/r"}]
        gh = self.write("bin/gh", "#!/bin/sh\ncat <<'EOF'\n" + json.dumps(issues, ensure_ascii=False)
                        + "\nEOF\n")
        os.chmod(gh, os.stat(gh).st_mode | stat.S_IXUSR)
        return fake

    @_winsim.needs_encoding_warning
    def test_curly_quote_title_is_listed(self):
        fake = self.fake_gh("Table 3 “SEs” disagree")
        env = clean_env(self.home, CLAUDE_ISSUES_AT_START="1",
                        PATH=fake + os.pathsep + os.environ.get("PATH", ""))
        out = fire("open-issues.py", {"source": "startup"}, env,
                   ("-X", "warn_default_encoding", "-W", "error::EncodingWarning"), cwd=self.tmp)[0]
        self.assertIn("#7 Table 3 “SEs” disagree", json.loads(out)["hookSpecificOutput"]["additionalContext"])

    def test_cjk_profile_event_still_lists(self):
        fake = self.fake_gh("Table 3 disagrees")
        env = clean_env(self.home, CLAUDE_ISSUES_AT_START="1", PYTHONUTF8="0",
                        PYTHONIOENCODING="cp936:surrogateescape",
                        PATH=fake + os.pathsep + os.environ.get("PATH", ""))
        out = fire("open-issues.py", {"source": "startup",
                                      "transcript_path": "C:\\Users\\王\\.claude\\t.jsonl"},
                   env, cwd=self.tmp)[0]
        self.assertIn("#7 Table 3 disagrees", out)


class LogReminderNames(_Tmp):
    """log-reminder-quoted-and-cp1252: porcelain C-quoted non-ASCII and spaced names
    (`"scripts/an\\303\\241lise.R"`), and with quotePath off Windows' code-page decode
    raised, `_git` returned "", and no log was written."""

    def setUp(self):
        super().setUp()
        self.repo = self.path("repo")
        os.makedirs(self.repo)
        env = clean_env(self.home)
        git(self.repo, "init", "-q", env=env)
        self.write("repo/README.md", "x\n")
        git(self.repo, "add", "README.md", env=env)
        git(self.repo, "commit", "-q", "-m", "seed", env=env)
        git(self.repo, "mv", "README.md", "LÉAME.md", env=env)
        self.write("repo/scripts/análise.R", "x\n")
        git(self.repo, "add", "scripts/análise.R", env=env)
        self.write("repo/notes with space.md", "x\n")

    def run_hook(self, pyflags=(), event=None, **extra):
        env = clean_env(self.home, CLAUDE_PROJECT_DIR=self.repo, **extra)
        fire("log-reminder.py", event or {}, env, pyflags)
        logs = os.path.join(self.repo, "quality_reports", "session_logs")
        files = [f for f in os.listdir(logs) if f.endswith("_auto.md")] if os.path.isdir(logs) else []
        if not files:
            return None
        with open(os.path.join(logs, files[0]), encoding="utf-8") as f:
            return f.read()

    def test_names_are_logged_readably(self):
        log = self.run_hook()
        self.assertIsNotNone(log, "no session log written")
        self.assertIn("scripts/análise.R", log)
        self.assertIn("notes with space.md", log)
        self.assertIn("LÉAME.md <- README.md", log)
        self.assertNotIn("\\303", log)
        self.assertNotIn("- `README.md`", log)

    @_winsim.needs_encoding_warning
    def test_git_output_is_not_decoded_with_the_locale(self):
        log = self.run_hook(("-X", "warn_default_encoding", "-W", "error::EncodingWarning"))
        self.assertIsNotNone(log, "no session log written")
        self.assertIn("scripts/análise.R", log)

    def test_stop_hook_active_is_read_on_a_cjk_profile(self):
        """nonguard-hooks-stdin-silent (log-reminder): the loop guard. On a CJK code page
        the event did not parse, `stop_hook_active` read as absent, and the hook ran."""
        log = self.run_hook(event={"stop_hook_active": True,
                                   "transcript_path": "C:\\Users\\王\\.claude\\t.jsonl"},
                            PYTHONUTF8="0", PYTHONIOENCODING="cp936:surrogateescape")
        self.assertIsNone(log, "the Stop hook ran although stop_hook_active was set")


# ── notify.sh ──────────────────────────────────────────────────────────────
class NotifyWithoutJqAndOnWindows(_Tmp):
    """notify-sh-no-notification-on-windows: Git Bash (`uname` MINGW64_NT-…) fell to
    a stderr echo nobody sees, and a missing jq exited before any notification."""

    def tools(self, uname, with_jq=False):
        d = self.path("tools-" + uname.split("_")[0])
        os.makedirs(d, exist_ok=True)
        self.log = self.path("notifier.log")
        # The real tools go in as shims, not symlinks: Windows refuses os.symlink without
        # Developer Mode (#171 F4), and a copied MSYS cat.exe will not start without its
        # msys-2.0.dll beside it.
        real = [(t, f"exec {shlex.quote(shutil.which(t))} \"$@\"")
                for t in ("cat", "tr") + (("jq",) if with_jq else ())]
        for name, body in real + [("uname", f"echo {uname}"),
                                  ("notify-send", f'printf "%s|" "$@" >> "{self.log}"'),
                                  ("osascript", f'printf "%s|" "$@" >> "{self.log}"')]:
            p = os.path.join(d, name)
            with open(p, "w", encoding="utf-8") as f:
                f.write("#!/bin/sh\n" + body + "\n")
            os.chmod(p, 0o755)
        return d

    def notify(self, tools, payload):
        r = subprocess.run([BASH, os.path.join(HOOKS, "notify.sh")], input=payload.encode("utf-8"),
                           env={"PATH": tools, "HOME": self.home}, capture_output=True, timeout=30)
        return r.stdout.decode("utf-8", "replace")

    def logged(self):
        if not os.path.exists(self.log):
            return ""
        with open(self.log, encoding="utf-8") as f:
            return f.read()

    def test_git_bash_emits_an_osc9_sequence(self):
        out = self.notify(self.tools("MINGW64_NT-10.0-22631"),
                          '{"message":"Claude needs your permission to use Bash"}')
        seq = json.loads(out)["terminalSequence"]
        self.assertTrue(seq.startswith("\x1b]9;"), seq)
        self.assertTrue(seq.endswith("\x07"), seq)
        self.assertIn("Claude needs attention", seq)       # no jq: the default message

    @unittest.skipUnless(shutil.which("jq"), "jq not installed")
    def test_git_bash_escapes_the_message(self):
        out = self.notify(self.tools("MINGW64_NT-10.0-22631", with_jq=True),
                          json.dumps({"message": 'say "hi" \\ 100%\tnow\x1b'}))
        seq = json.loads(out)["terminalSequence"]
        self.assertIn('say "hi" \\ 100%now', seq)
        self.assertEqual(seq.count("\x1b"), 1)

    def test_no_jq_still_notifies(self):
        for uname in ("Linux", "Darwin"):
            with self.subTest(uname=uname):
                if os.path.exists(self.path("notifier.log")):
                    os.remove(self.path("notifier.log"))
                self.notify(self.tools(uname), '{"message":"x"}')
                self.assertIn("Claude needs attention", self.logged())


# ── statusline.sh ───────────────────────────────────────────────────────────
class StatusLine(_Tmp):
    """statusline-stdin-locale, statusline-ctx-hash-mismatch-cp1252,
    statusline-plan-badge-from-subdir."""

    def repo(self, name):
        r = self.path(name)
        os.makedirs(r)
        git(r, "init", "-q")
        git(r, "symbolic-ref", "HEAD", "refs/heads/main")
        return r

    def run_sl(self, payload, **env):
        r = subprocess.run([BASH, STATUSLINE], input=json.dumps(payload, ensure_ascii=False).encode(),
                           env=clean_env(self.home, **env), capture_output=True, timeout=30)
        return r.stdout.decode("utf-8", "replace")

    def test_cjk_code_page_keeps_badge_model_ctx_and_branch(self):
        r = self.repo("José-proj")
        out = self.run_sl({"permission_mode": "bypassPermissions", "model": {"display_name": "Opus"},
                           "workspace": {"current_dir": r}, "transcript_path": "C:\\Users\\王\\x.jsonl",
                           "context_window": {"used_percentage": 42}},
                          PYTHONUTF8="0", PYTHONIOENCODING="cp936:surrogateescape")
        for part in ("[BYPASS]", "Opus", "@ main", "ctx 42%"):
            self.assertIn(part, out)

    def test_ctx_fallback_found_for_non_ascii_project_dir(self):
        pd = "/x/Đorđe ção/repo"
        d = os.path.join(self.home, ".claude", "sessions", hashlib.md5(pd.encode()).hexdigest()[:8])
        os.makedirs(d)
        with open(os.path.join(d, "context-pct.txt"), "w", encoding="utf-8") as f:
            f.write("42")
        out = self.run_sl({"model": {"display_name": "Opus"}, "workspace": {"current_dir": self.tmp}},
                          CLAUDE_PROJECT_DIR=pd, PYTHONUTF8="0",
                          PYTHONIOENCODING="cp1252:surrogateescape")
        self.assertIn("ctx ~42%", out)

    def test_plan_badge_from_a_subdirectory(self):
        r = self.repo("repo")
        self.write("repo/quality_reports/plans/2026-09-27_x.md", "# P\n**Status:** APPROVED\n")
        os.makedirs(os.path.join(r, "Slides"))
        for cwd in (r, os.path.join(r, "Slides")):
            with self.subTest(cwd=cwd):
                out = self.run_sl({"model": {"display_name": "M"}, "workspace": {"current_dir": cwd}})
                self.assertIn("plan:approved", out)


class FindingIds(unittest.TestCase):
    """The module docstring's promise: every class above names the finding it pins by
    its id, which the issue and the other groups can search for, not by a gitignored
    plan's item number. A hook's own kebab-case name does not count as one."""

    def test_every_class_cites_a_finding_id(self):
        fid = re.compile(r"\b[a-z0-9]+(?:-[a-z0-9]+){2,}\b")
        hooks = {os.path.splitext(f)[0] for f in os.listdir(HOOKS)}
        for name, cls in sorted(globals().items()):
            if (isinstance(cls, type) and issubclass(cls, unittest.TestCase)
                    and cls is not FindingIds and any(k.startswith("test_") for k in vars(cls))):
                with self.subTest(cls=name):
                    ids = [t for t in fid.findall(cls.__doc__ or "") if t not in hooks]
                    self.assertTrue(ids, f"{name} cites no finding id")


if __name__ == "__main__":
    unittest.main()

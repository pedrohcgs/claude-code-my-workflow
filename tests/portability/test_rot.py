"""root-of-trust-guard.py: the spellings of a gate-defining path that the guard
used to allow while its literal twin denied (issue #171, and #151 claim 1).

Two kinds of case:

  * NATIVE — the real hook run as a subprocess with a PreToolUse event on stdin
    and CLAUDE_PROJECT_DIR set, exactly as scripts/hook-battery.sh fires it. The
    backslash fold, the CR strip, the `.exe`/case fold on program names, the
    Unicode casefold, the stdin decoding and the scope half are all
    unconditional, so they are pinned here on Linux and macOS alike.
  * WINDOWS — the real hook loaded through _winsim (os.path = ntpath) and its
    real main() driven with a Bash event. The project is a real fixture
    directory reached through its Windows spelling (C:\\...), so the scope half
    resolves on disk. MSYS drive paths (`/c/...`) and the `-C` composition only
    exist on Windows, so they are pinned here.

HOOK_DIR (the same variable hook-battery.sh reads) points the suite at another
copy of the hooks — that is how the pre-fix code is shown to fail these cases.

Every case is safe to run: the hook only DECIDES; nothing is ever executed.
"""
import io
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unicodedata
import unittest

import _winsim

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
HOOK_DIR = os.environ.get("HOOK_DIR") or os.path.join(ROOT, ".claude", "hooks")
GUARD = os.path.join(HOOK_DIR, "root-of-trust-guard.py")
DENY = '"permissionDecision": "deny"'

_T = ""          # fixture base (realpath'd), built once in setUpModule
FX = {}          # fixture name -> absolute path


def _mkproj(path):
    os.makedirs(os.path.join(path, ".claude", "hooks"), exist_ok=True)
    os.makedirs(os.path.join(path, ".claude", "rules"), exist_ok=True)
    os.makedirs(os.path.join(path, ".githooks"), exist_ok=True)
    os.makedirs(os.path.join(path, "docs"), exist_ok=True)
    for rel, body in ((".claude/hooks/git-guardrails.py", "# stub\n"),
                      (".claude/settings.json", "{}\n"),
                      (".githooks/pre-commit", "#!/bin/sh\n")):
        with open(os.path.join(path, rel), "w", encoding="utf-8") as f:
            f.write(body)
    return path


def setUpModule():
    global _T
    _T = os.path.realpath(tempfile.mkdtemp(prefix="rot-port-"))
    FX["proj"] = _mkproj(os.path.join(_T, "Proj"))            # mixed case on purpose
    FX["projx"] = _mkproj(os.path.join(_T, "Projx"))          # sibling-prefix control
    FX["other"] = _mkproj(os.path.join(_T, "other"))
    FX["accent"] = _mkproj(os.path.join(_T, "proj-\u00e9"))   # NFC é
    FX["nfd"] = _mkproj(os.path.join(_T, unicodedata.normalize("NFD", "\u00e9t\u00e9")))
    # a project whose `.claude` is a link to a shared config dir outside it
    shared = _mkproj(os.path.join(_T, "shared"))
    FX["shared"] = shared
    FX["symproj"] = os.path.join(_T, "symproj")
    os.makedirs(FX["symproj"])
    os.symlink(os.path.join(shared, ".claude"), os.path.join(FX["symproj"], ".claude"))
    # ... whose `.claude/hooks` alone is linked out
    FX["symhooks"] = os.path.join(_T, "symhooks")
    os.makedirs(os.path.join(FX["symhooks"], ".claude"))
    os.symlink(os.path.join(shared, ".claude", "hooks"),
               os.path.join(FX["symhooks"], ".claude", "hooks"))
    # ... whose `.githooks` is linked out
    FX["symgit"] = os.path.join(_T, "symgit")
    os.makedirs(FX["symgit"])
    os.symlink(os.path.join(shared, ".githooks"), os.path.join(FX["symgit"], ".githooks"))
    # an ALIAS spelling of the symlinked project (CLAUDE_PROJECT_DIR through a link)
    FX["alias"] = os.path.join(_T, "alias")
    os.symlink(FX["symproj"], FX["alias"])
    # the Windows-simulated project and a second tree beside it
    FX["win"] = _mkproj(os.path.join(_T, "win", "proj"))
    FX["winother"] = _mkproj(os.path.join(_T, "win", "other"))


def tearDownModule():
    if _T:
        shutil.rmtree(_T, ignore_errors=True)


# ---- native: the hook as a subprocess ----------------------------------------
def _clean_env(extra):
    env = {k: v for k, v in os.environ.items()
           if not k.startswith("GIT_")
           and k not in ("ALLOW_ROOT_OF_TRUST_WRITE", "CLAUDE_PROJECT_DIR",
                         "PYTHONIOENCODING", "PYTHONUTF8")}
    env.update(extra)
    return env


def fire(command, cwd, project, env=None, event_extra=None):
    """Run the guard on one Bash event; return its stdout (empty = allowed)."""
    ev = {"tool_name": "Bash", "tool_input": {"command": command}, "cwd": cwd}
    ev.update(event_extra or {})
    raw = json.dumps(ev, ensure_ascii=False).encode("utf-8")   # what Node sends
    r = subprocess.run([sys.executable, GUARD], input=raw, capture_output=True,
                       cwd=cwd, timeout=60,
                       env=_clean_env(dict(env or {}, CLAUDE_PROJECT_DIR=project)))
    if r.returncode != 0:
        raise AssertionError(f"hook exited {r.returncode}: {r.stderr.decode(errors='replace')}")
    return r.stdout.decode("utf-8", "replace")


# (id, fixture, command, expect_deny, env) — command may hold {P} {T} for paths;
# cwd and CLAUDE_PROJECT_DIR are the fixture.
NATIVE = [
    # -- backslash separators (rot-backslash-separators, rotg-backslash-token-bypass,
    #    rot-windows-backslash-and-msys-paths, msys-path-spellings-bypass-root-of-trust)
    ("bs_quoted_dir",       "proj", r"rm -rf '.claude\hooks'", True, None),
    ("bs_quoted_redirect",  "proj", r"echo x > '.claude\settings.json'", True, None),
    ("bs_mixed",            "proj", r"rm -rf '.claude/hooks\git-guardrails.py'", True, None),
    ("bs_githooks",         "proj", r"mv '.githooks\pre-commit' /tmp/x", True, None),
    ("bs_git_dash_c",       "proj", r"git -C '.claude\hooks' rm -f git-guardrails.py", True, None),
    ("bs_ctrl_unquoted",    "proj", r"echo x > .claude\settings.json", False, None),
    ("bs_ctrl_read",        "proj", r"cat '.claude\hooks\git-guardrails.py'", False, None),
    ("bs_ctrl_rules",       "proj", r"rm -rf '.claude\rules'", False, None),
    # -- a CR inside a word (carriage-return-in-word-bypasses-guards)
    ("cr_rm",               "proj", "rm -rf .clau\rde/hooks", True, None),
    ("cr_redirect",         "proj", "echo CLOBBERED > .claude/settings.js\ron", True, None),
    ("cr_wrapped_git",      "proj", "bash -c 'git reset --ha\rrd'", True, None),
    ("cr_ctrl_read",        "proj", "ls .clau\rde/hooks", False, None),
    # -- `.exe` and case-varied program names (exe-suffix-bypasses-guards)
    ("exe_rm",              "proj", "rm.exe -rf .claude/hooks", True, None),
    ("exe_rm_upper",        "proj", "RM.EXE -rf .claude/hooks", True, None),
    ("exe_rm_path",         "proj", "/usr/bin/rm.exe -rf .claude/hooks", True, None),
    ("exe_cp",              "proj", "cp.exe /dev/null .claude/settings.json", True, None),
    ("exe_git",             "proj", "git.exe rm -r .claude/hooks", True, None),
    ("exe_bash_payload",    "proj", "bash.exe -c 'rm -rf .claude/hooks'", True, None),
    ("exe_bash_git",        "proj", "bash.exe -c 'git reset --hard'", True, None),
    ("exe_sed",             "proj", "sed.exe -i s/a/b/ .claude/settings.json", True, None),
    ("exe_env",             "proj", "env.exe rm -rf .claude/hooks", True, None),
    ("exe_find_exec",       "proj", "find .claude/hooks -exec rm.exe {} +", True, None),
    ("case_wrapper_nice",   "proj", "NICE rm -f .claude/hooks/git-guardrails.py", True, None),
    ("case_wrapper_bash",   "proj", "BASH -c 'rm -f .claude/hooks/git-guardrails.py'", True, None),
    ("exe_ctrl_status",     "proj", "git.exe status", False, None),
    ("exe_ctrl_cat",        "proj", "cat.exe .claude/settings.json", False, None),
    ("exe_ctrl_bash_ls",    "proj", "bash.exe -c 'ls .claude/hooks'", False, None),
    ("exe_ctrl_rm_other",   "proj", "rm.exe -f docs/tmp.txt", False, None),
    # -- Unicode casefold: APFS folds U+017F to `s` (rot-unicode-casefold)
    ("fold_hooks",          "proj", "rm -rf .claude/hook\u017f", True, None),
    ("fold_settings",       "proj", "printf x > .claude/setting\u017f.json", True, None),
    ("fold_githooks",       "proj", "rm -rf .githook\u017f", True, None),
    ("fold_writer_sed",     "proj", "\u017fed -i s/a/b/ .claude/settings.json", True, None),
    ("fold_writer_install", "proj", "in\u017ftall /dev/null .claude/hooks/git-guardrails.py", True, None),
    ("fold_ctrl_read",      "proj", "cat .claude/setting\u017f.json", False, None),
    # -- stdin decoded as UTF-8, not the ANSI code page (guard-stdin-codepage-fail-open,
    #    guard-stdin-mojibake-scope-bypass, hook-stdin-ansi-codepage-fail-open)
    ("enc_cjk_pipe",        "proj", "echo \u4e2d|rm -rf .claude/hooks", True,
     {"PYTHONIOENCODING": "cp936:surrogateescape"}),
    ("enc_curly_quote",     "proj", "rm -rf .claude/hooks  # \u201d", True,
     {"PYTHONIOENCODING": "cp1252"}),
    ("enc_mojibake_scope",  "accent", "rm -rf {P}/.claude/hooks", True,
     {"PYTHONIOENCODING": "cp1252:surrogateescape"}),
    ("enc_mojibake_redirect", "accent", "echo x > {P}/.claude/settings.json", True,
     {"PYTHONIOENCODING": "cp1252:surrogateescape"}),
    # -- scope: case- and normalisation-varied spellings (rot-scope-string-compare,
    #    rotg-scope-case-sensitive-apfs)
    ("scope_case_prefix",   "proj", "rm -rf {T}/PROJ/.claude/hooks", True, None),
    ("scope_case_redirect", "proj", "echo X > {T}/PROJ/.claude/settings.json", True, None),
    ("scope_case_githooks", "proj", "rm -f {T}/PROJ/.githooks/pre-commit", True, None),
    ("scope_nfc_token",     "nfd",  "rm -rf {T}/\u00e9t\u00e9/.claude/hooks", True, None),
    ("scope_ctrl_other",    "proj", "rm -rf {T}/other/.claude/hooks", False, None),
    ("scope_ctrl_sibling",  "proj", "rm -rf {T}/Projx/.claude/hooks", False, None),
    # -- scope: a link that carries the protected NAME (rot-symlinked-claude-dir)
    ("link_claude_hooks",   "symproj", "rm -rf .claude/hooks", True, None),
    ("link_claude_settings", "symproj", "echo X > .claude/settings.json", True, None),
    ("link_claude_dir",     "symproj", "rm -rf .claude", True, None),
    ("link_hooks_file",     "symhooks", "rm -f .claude/hooks/git-guardrails.py", True, None),
    ("link_githooks",       "symgit", "rm -f .githooks/pre-commit", True, None),
    ("link_ctrl_shared",    "symproj", "rm -rf {T}/shared/.claude/hooks", False, None),
]


def _native_case(fx, command, expect_deny, env):
    def test(self):
        cwd = FX[fx]
        cmd = command.replace("{P}", cwd).replace("{T}", _T)
        out = fire(cmd, cwd, cwd, env)
        if expect_deny:
            self.assertIn(DENY, out, f"not denied: {cmd!r}")
        else:
            self.assertEqual(out, "", f"not silent: {cmd!r}")
    return test


class NativeTest(unittest.TestCase):
    """The real hook as a subprocess, on this machine's own path rules."""

    def test_enc_cp1252_profile_name(self):
        # guard-stdin-codepage-fail-open: an `Á` in transcript_path (every event
        # carries it) holds a byte cp1252 cannot decode; under a strict decoder
        # the guard failed open. (Windows' own pipe default is surrogateescape,
        # which garbles instead — enc_cjk_pipe and enc_mojibake_* pin that.)
        out = fire("rm -rf .claude/hooks", FX["proj"], FX["proj"],
                   {"PYTHONIOENCODING": "cp1252"},
                   {"transcript_path": "C:\\Users\\\u00c1lvaro\\.claude\\t.jsonl"})
        self.assertIn(DENY, out)

    def test_scope_alias_project_dir(self):
        # rot-symlinked-claude-dir, the verifier's gap: CLAUDE_PROJECT_DIR spelled
        # through an alias AND `.claude` linked out of the tree.
        a = FX["alias"]
        self.assertIn(DENY, fire(f"rm -rf {a}/.claude/hooks", a, a))

    def test_scope_case_varied_cwd(self):
        # rotg-scope-case-sensitive-apfs, second vector: the EVENT cwd arrives
        # case-varied (bash keeps a `cd` as typed), so a relative write resolved
        # outside the project. Where the volume is case-sensitive the spelled cwd
        # does not exist and the guard falls back to its own cwd, which is right.
        cwd = os.path.join(_T, "PROJ")
        ev = {"tool_name": "Bash", "tool_input": {"command": "rm -rf .claude/hooks"},
              "cwd": cwd}
        r = subprocess.run([sys.executable, GUARD], cwd=FX["proj"], capture_output=True,
                           input=json.dumps(ev).encode(), timeout=60,
                           env=_clean_env({"CLAUDE_PROJECT_DIR": FX["proj"]}))
        self.assertIn(DENY, r.stdout.decode())

    def test_scope_project_at_filesystem_root(self):
        # rot-project-at-filesystem-root: `_PROJECT + os.sep` was `//`.
        self.assertIn(DENY, fire("echo X > /.claude/settings.json", "/", "/"))
        self.assertIn(DENY, fire("rm -rf .claude/hooks", "/", "/"))

    @unittest.skipUnless(sys.platform == "darwin", "macOS firmlinks")
    def test_scope_firmlink(self):
        # rot-scope-string-compare: /System/Volumes/Data/<p> IS <p> on macOS, and
        # realpath does not say so.
        fl = "/System/Volumes/Data" + FX["proj"]
        if not (os.path.exists(fl) and os.path.samefile(fl, FX["proj"])):
            self.skipTest("no Data-volume firmlink for the fixture")
        self.assertIn(DENY, fire(f"rm -rf {fl}/.claude/hooks", FX["proj"], FX["proj"]))


for _id, _fx, _cmd, _deny, _env in NATIVE:
    setattr(NativeTest, f"test_{_id}", _native_case(_fx, _cmd, _deny, _env))


# ---- Windows: the real main() under ntpath -----------------------------------
def win_fire(command, cwd=None, project=None):
    """Drive the real main() under _winsim; return stdout (empty = allowed)."""
    cwd = cwd or FX["win"]
    project = project or FX["win"]
    mod = _winsim.load(GUARD)
    ev = {"tool_name": "Bash", "tool_input": {"command": command},
          "cwd": _winsim.to_win(cwd)}
    raw = json.dumps(ev, ensure_ascii=False).encode("utf-8")
    saved = sys.stdin, sys.stdout, {k: os.environ.get(k) for k in
                                    ("CLAUDE_PROJECT_DIR", "ALLOW_ROOT_OF_TRUST_WRITE")}
    sys.stdin = io.TextIOWrapper(io.BytesIO(raw), encoding="utf-8")
    sys.stdout = io.StringIO()
    os.environ.pop("ALLOW_ROOT_OF_TRUST_WRITE", None)
    os.environ["CLAUDE_PROJECT_DIR"] = _winsim.to_win(project)
    try:
        try:
            mod.main()
        except Exception:
            pass                     # the hook fails open: nothing on stdout
        return sys.stdout.getvalue()
    finally:
        sys.stdin, sys.stdout = saved[0], saved[1]
        for k, v in saved[2].items():
            if v is None:
                os.environ.pop(k, None)
            else:
                os.environ[k] = v


# (id, command, expect_deny) — {W} is the project's Windows spelling (C:\...),
# {M} its Git Bash spelling without the drive (/c{M} is the MSYS path), {O}/{OM}
# the same for a tree beside it.
WINDOWS = [
    ("win_bs_rel",          r"rm -rf '.claude\hooks'", True),
    ("win_bs_abs",          r"rm -rf '{W}\.claude\hooks'", True),
    ("win_bs_redirect",     r"echo x > '.claude\settings.json'", True),
    ("win_bs_githooks",     r"rm -f '.githooks\pre-commit'", True),
    ("win_bs_envvar",       r'rm -rf "$CLAUDE_PROJECT_DIR\.claude\hooks"', True),
    ("win_msys",            "rm -rf /c{M}/.claude/hooks", True),
    ("win_msys_redirect",   "echo x > /c{M}/.claude/settings.json", True),
    ("win_msys_upper",      "rm -rf /C{M}/.claude/hooks", True),
    ("win_cygdrive",        "rm -rf /cygdrive/c{M}/.claude/hooks", True),
    ("win_msys_git_dash_c", "git -C /c{M}/.claude/hooks rm -f git-guardrails.py", True),
    ("win_dash_c_compose",  "git -C .claude -C hooks rm -f git-guardrails.py", True),
    ("win_dash_c_msys",     "git -C C:/x -C /c{M}/.claude rm -rf hooks", True),
    ("win_exe_full_path",   r"'C:\Program Files\Git\usr\bin\rm.exe' -rf .claude/hooks", True),
    ("win_ctrl_other_msys", "rm -rf /c{OM}/.claude/hooks", False),
    ("win_ctrl_other_bs",   r"rm -rf '{O}\.claude\hooks'", False),
    ("win_ctrl_read",       r"cat '.claude\hooks\git-guardrails.py'", False),
    ("win_ctrl_build",      r"rm -rf 'build\out'", False),
    ("win_ctrl_dash_c_out", "git -C .claude -C ../docs rm -rf .", False),
]


def _win_case(command, expect_deny):
    def test(self):
        cmd = (command.replace("{W}", _winsim.to_win(FX["win"]))
                      .replace("{OM}", FX["winother"])
                      .replace("{O}", _winsim.to_win(FX["winother"]))
                      .replace("{M}", FX["win"]))
        out = win_fire(cmd)
        if expect_deny:
            self.assertIn(DENY, out, f"not denied under ntpath: {cmd!r}")
        else:
            self.assertEqual(out, "", f"not silent under ntpath: {cmd!r}")
    return test


class WindowsTest(unittest.TestCase):
    """The real hook under ntpath, against a real fixture reached as C:\\..."""

    def test_win_compose_joins_with_forward_slash(self):
        # #151 claim 1 / rot-dash-c-ospath-join / rotg-a54-compose-dash-C: git
        # composes -C values with `/`; os.path.join gave `.claude\hooks`.
        m = _winsim.load(GUARD)
        self.assertEqual(m._compose_dash_c([".claude", "hooks"]), ".claude/hooks")
        self.assertTrue(m.matches_root_of_trust(m._compose_dash_c([".claude", "hooks"])))

    def test_win_project_at_drive_root(self):
        # rot-project-at-filesystem-root, Windows spelling: a project at `C:\`.
        m = _winsim.load(GUARD)
        m._PROJECT = m._CWD = "C:\\"
        self.assertTrue(m.in_project("C:/.claude/settings.json"))
        self.assertTrue(m.in_project(".claude\\hooks"))


for _id, _cmd, _deny in WINDOWS:
    setattr(WindowsTest, f"test_{_id}", _win_case(_cmd, _deny))


# ---- scope, with no disk to lean on -------------------------------------------
def _load_native():
    import importlib.util
    spec = importlib.util.spec_from_file_location("rot_native", GUARD)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


class ScopeWithoutDiskTest(unittest.TestCase):
    """The scope half on paths that do not exist, as a case-sensitive volume
    (Linux CI) sees a case-varied spelling. On macOS the fixture cases above
    can also be rescued by the file-identity fallback; these cannot, so each
    string repair is pinned on its own."""

    ROOT_ = "/nonexistent-rot-scope"

    def test_case_folded(self):
        m = _load_native()
        m._PROJECT = m._CWD = self.ROOT_ + "/Proj"
        self.assertTrue(m.is_protected(self.ROOT_ + "/PROJ/.claude/hooks"))
        self.assertFalse(m.is_protected(self.ROOT_ + "/Projx/.claude/hooks"))

    def test_unicode_form_folded(self):
        m = _load_native()
        m._PROJECT = m._CWD = self.ROOT_ + "/" + unicodedata.normalize("NFD", "\u00e9t\u00e9")
        self.assertTrue(m.is_protected(self.ROOT_ + "/\u00e9t\u00e9/.claude/hooks"))   # NFC

    def test_path_as_named_counts(self):
        # `.claude` resolves elsewhere (a link), but is named inside the project.
        m = _load_native()
        m._PROJECT = m._CWD = self.ROOT_ + "/proj"
        m._real = lambda p: p.replace("/proj/.claude", "/shared/.claude")
        self.assertTrue(m.is_protected(".claude/hooks"))
        self.assertFalse(m.is_protected(self.ROOT_ + "/shared/.claude/hooks"))

    def test_share_root_is_its_own_prefix(self):
        # rot-project-at-filesystem-root: a project at a UNC share root keeps
        # its trailing separator, so `root + os.sep` doubled it.
        m = _winsim.load(GUARD)
        m._PROJECT = m._CWD = "\\\\server\\share\\"
        self.assertTrue(m.in_project("\\\\server\\share\\.claude\\settings.json"))


if __name__ == "__main__":
    unittest.main()

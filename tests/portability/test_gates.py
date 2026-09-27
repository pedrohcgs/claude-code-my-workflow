"""The gates and the scripts around them (issue #171): each case fails on the code
before the fix and passes after it, on Linux and macOS alike.

Windows is reached three ways. _winsim loads a real module with ntpath swapped in
(path separators). A subprocess is handed what Windows hands it: a pipe in a
code page (PYTHONIOENCODING=cp1252 / cp932), a locale that decodes with cp1252
(locale.getencoding patched before the script runs), or every locale-default
text read and write made an error (-X warn_default_encoding with EncodingWarning
raised). Line endings, BOMs, spaces, case and the index are not Windows-specific
and are exercised as they are.

Every subprocess gets the caller's environment WITHOUT its GIT_* variables: this
suite runs inside .githooks/pre-commit, which exports GIT_DIR and GIT_INDEX_FILE
at the user's repository, and a fixture's `git add` would otherwise land there.
"""
import hashlib
import importlib.util
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import unittest

import _winsim

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SCRIPTS = os.path.join(ROOT, "scripts")
# A few fixtures are POSIX constructs: a stand-in `gh` with no .exe, a mode bit, a
# battery run with Git Bash's ln and uname faked. On a Windows host they would
# measure the fixture, and the real gates run there natively anyway.
POSIX_HOST = unittest.skipIf(os.name == "nt", "simulates Windows on a POSIX host; Windows runs the real thing")
_DROP = ("PYTHONIOENCODING", "PYTHONUTF8", "PYTHONWARNDEFAULTENCODING", "PYTHONWARNINGS",
         "CLAUDE_PROJECT_DIR", "BACKTEST_SKIP_HOOK_BATTERY", "HOOK_DIR", "FILE_ISSUE")


def _env(**extra):
    env = {k: v for k, v in os.environ.items()
           if not (k.startswith("GIT_") and k != "GIT_EXEC_PATH") and k not in _DROP}
    env.update(extra)
    return env


def _run(cmd, cwd=None, timeout=300, **extra):
    """(exit code, stdout+stderr as UTF-8 text)."""
    r = subprocess.run(cmd, cwd=cwd, env=_env(**extra), stdout=subprocess.PIPE,
                       stderr=subprocess.STDOUT, timeout=timeout)
    return r.returncode, r.stdout.decode("utf-8", "replace")


def _write(base, rel, content, mode=None):
    p = os.path.join(base, *rel.split("/"))
    os.makedirs(os.path.dirname(p), exist_ok=True)
    with open(p, "wb") as f:
        f.write(content if isinstance(content, bytes) else content.encode("utf-8"))
    if mode is not None:
        os.chmod(p, mode)
    return p


def _copy_script(base, name):
    dst = os.path.join(base, "scripts", name)
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(os.path.join(SCRIPTS, name), dst)
    return dst


def _git(base, *args):
    r = subprocess.run(["git", "-C", base, *args], env=_env(), capture_output=True)
    if r.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)}: {r.stderr.decode('utf-8', 'replace')}")
    return r.stdout.decode("utf-8", "replace")


def _load(name):
    """Import a script from scripts/ as a plain module (no simulation)."""
    path = os.path.join(SCRIPTS, name)
    spec = importlib.util.spec_from_file_location("gates_" + re.sub(r"\W", "_", name), path)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def _bin(base, **scripts):
    """A directory of executable stand-ins, for the front of PATH."""
    d = os.path.join(base, "bin")
    os.makedirs(d, exist_ok=True)
    for name, body in scripts.items():
        _write(d, name, body, mode=0o755)
    return d


class Tmp(unittest.TestCase):
    def setUp(self):
        self._td = tempfile.TemporaryDirectory()
        self.tmp = os.path.realpath(self._td.name)

    def tearDown(self):
        self._td.cleanup()


# ── check-staleness.py / stamp-render.sh ──────────────────────────────────────

class StalenessSkipList(unittest.TestCase):
    def test_anti_pattern_catalogue_is_skipped_on_windows(self):
        # staleness-skip-regex-slash-only, -vs-relpath, -backslash: SKIP is written with
        # '/', relpath gives '\' on Windows, so defect-library.md was scanned and failed.
        mod = _winsim.load(os.path.join(SCRIPTS, "check-staleness.py"))
        names = [s.replace("\\", "/") for s in mod.surfaces()]
        self.assertTrue(any(n.endswith("/README.md") for n in names), "the scan found nothing at all")
        self.assertEqual([n for n in names if n.endswith("defect-library.md")], [])


@unittest.skipUnless(shutil.which("shasum") and shutil.which("perl"), "stamp-render.sh needs shasum and perl")
class RenderStampLineEndings(Tmp):
    FILES = ("guide/workflow-guide.qmd", "guide/workflow-guide.html", "docs/workflow-guide.html")

    def setUp(self):
        super().setUp()
        _copy_script(self.tmp, "check-staleness.py")
        _copy_script(self.tmp, "stamp-render.sh")
        _write(self.tmp, "guide/workflow-guide.qmd", "---\ntitle: Guide\n---\n\nOne line.\nAnother.\n")
        for p in self.FILES[1:]:
            _write(self.tmp, p, "<html>\n<p>One line.</p>\n</html>\n")

    def stamp(self):
        rc, out = _run(["bash", os.path.join(self.tmp, "scripts", "stamp-render.sh")])
        self.assertEqual(rc, 0, out)
        with open(os.path.join(self.tmp, ".render-stamp"), "rb") as f:
            return f.read()

    def staleness(self):
        return _run([sys.executable, os.path.join(self.tmp, "scripts", "check-staleness.py")])

    def to_crlf(self):
        for p in self.FILES:
            fp = os.path.join(self.tmp, *p.split("/"))
            with open(fp, "rb") as f:
                b = f.read()
            with open(fp, "wb") as f:
                f.write(b.replace(b"\n", b"\r\n"))

    def test_crlf_checkout_is_not_a_stale_render(self):
        # staleness-crlf-hash, staleness-false-fail-on-autocrlf: an autocrlf clone of
        # an up-to-date tree read as STALE-RENDER.
        self.stamp()
        self.to_crlf()
        rc, out = self.staleness()
        self.assertNotIn("STALE-RENDER", out)
        self.assertEqual(rc, 0, out)

    def test_stamp_made_on_crlf_matches_the_lf_stamp(self):
        # The other direction: a stamp written in a CRLF checkout turned LF CI red.
        lf = self.stamp()
        self.to_crlf()
        self.assertEqual(self.stamp(), lf)

    def test_control_a_real_edit_is_still_stale(self):
        self.stamp()
        with open(os.path.join(self.tmp, "guide", "workflow-guide.qmd"), "ab") as f:
            f.write(b"A new paragraph.\n")
        rc, out = self.staleness()
        self.assertIn("STALE-RENDER", out)
        self.assertEqual(rc, 1)

    def test_a_finding_survives_a_cp932_pipe(self):
        # gate-stdout-emdash-codepage: the finding's em dash turned it into "internal error".
        self.stamp()
        with open(os.path.join(self.tmp, "guide", "workflow-guide.qmd"), "ab") as f:
            f.write(b"A new paragraph.\n")
        rc, out = _run([sys.executable, os.path.join(self.tmp, "scripts", "check-staleness.py")],
                       PYTHONIOENCODING="cp932")
        self.assertIn("STALE-RENDER", out)
        self.assertEqual(rc, 1, out)


# ── check-links.py / check-skill-integrity.py ─────────────────────────────────

class LinkResolution(Tmp):
    def repo(self, tracked, untracked=None):
        _copy_script(self.tmp, "check-links.py")
        _copy_script(self.tmp, "check-skill-integrity.py")
        for rel, text in tracked.items():
            _write(self.tmp, rel, text)
        _git(self.tmp, "init", "-q")
        _git(self.tmp, "add", "--", *tracked)
        for rel, text in (untracked or {}).items():
            _write(self.tmp, rel, text)

    def links(self):
        return _run([sys.executable, os.path.join(self.tmp, "scripts", "check-links.py")])

    def integrity(self):
        return _run([sys.executable, os.path.join(self.tmp, "scripts", "check-skill-integrity.py")])

    def test_encoded_and_angle_bracket_targets(self):
        # links-percent-encoding-and-angle-brackets: %20 and <a b.md> are the two ways
        # CommonMark puts a space in a link; the first failed, the second was skipped.
        self.repo({
            "templates/A b.md": "# A\n\n## Seção\n",
            "templates/links.md": ("[x](A%20b.md#se%C3%A7%C3%A3o)\n\n[y](<A b.md#seção>)\n\n"
                                   "[z](A%20b.md#seção \"t\")\n\n[v](<A b.md>)\n\n[w](<Missing file.md>)\n"),
        })
        rc, out = self.links()
        self.assertEqual(rc, 1, out)
        broken = [ln for ln in out.splitlines() if "->" in ln]
        self.assertEqual(len(broken), 1, out)
        self.assertIn("Missing file.md", broken[0])
        rc, out = self.integrity()
        self.assertNotIn("does not exist", out)
        self.assertNotIn("not found in", out)
        self.assertEqual(rc, 0, out)

    def test_untracked_target_is_missing(self):
        # gates-read-disk-not-index: green locally, red in a fresh clone.
        self.repo({"README.md": "[the note](templates/nota.md)\n"},
                  untracked={"templates/nota.md": "# Nota\n"})
        rc, out = self.links()
        self.assertEqual(rc, 1, out)
        self.assertIn("templates/nota.md", out)
        self.assertIn("missing file", out)

    def test_wrong_case_target_is_missing(self):
        # links-gate-case-insensitive-exists: README.MD for README.md resolves on
        # APFS and NTFS, 404s on GitHub. (On a case-sensitive disk it failed anyway.)
        self.repo({"README.md": "# Read me\n", "guide.md": "[r](README.MD)\n\n[s](Templates/)\n",
                   "templates/t.md": "# T\n"})
        rc, out = self.links()
        self.assertEqual(rc, 1, out)
        self.assertIn("README.MD", out)
        self.assertIn("Templates/", out)

    def test_untracked_markdown_is_not_scanned(self):
        # An untracked copy (a worktree under .claude/) is not the repository's to judge.
        self.repo({"README.md": "# Fine\n"},
                  untracked={".claude/worktrees/w/notes.md": "[gone](nowhere.md)\n"})
        rc, out = self.links()
        self.assertEqual(rc, 0, out)

    def test_directory_link_to_tracked_content_resolves(self):
        self.repo({"README.md": "[t](templates/) and [s](templates/sub/)\n",
                   "templates/sub/t.md": "# T\n"})
        rc, out = self.links()
        self.assertEqual(rc, 0, out)

    def test_same_verdicts_under_windows_paths(self):
        # Judging against the index compares '/' paths: without the os.sep swap every
        # file on Windows would read as untracked, scanned or linked.
        self.repo({"README.md": "[t](templates/)\n",
                   "templates/A b.md": "## Seção\n",
                   "templates/links.md": "[x](A%20b.md#seção)\n\n[c](a%20B.md#seção)\n\n[w](<Missing file.md>)\n"})
        code, out, err = _winsim.run_main(os.path.join(self.tmp, "scripts", "check-links.py"))
        self.assertEqual(code, 1, out + err)
        broken = sorted(ln.split("->")[1].split("[")[0].strip() for ln in out.splitlines() if "->" in ln)
        self.assertEqual(broken, ["Missing file.md", "a%20B.md#seção"], out)
        code, out, err = _winsim.run_main(os.path.join(self.tmp, "scripts", "check-skill-integrity.py"))
        self.assertEqual(code, 1, out + err)
        self.assertIn("'a B.md' does not exist", out)
        self.assertNotIn("'A b.md'", out)

    def test_report_naming_an_accented_file_survives_a_cp932_pipe(self):
        self.repo({"README.md": "[n](<Falta seção.md>)\n"})
        rc, out = _run([sys.executable, os.path.join(self.tmp, "scripts", "check-links.py")],
                       PYTHONIOENCODING="cp932")
        self.assertEqual(rc, 1, out)
        self.assertIn("Falta se", out)
        self.assertIn("missing file", out)
        self.assertNotIn("Traceback", out)

    def test_skill_integrity_advisory_survives_a_cp932_pipe(self):
        # A P2 is advice, exit 0 — its em dash crashed the print, exit 1.
        self.repo({".claude/skills/demo/SKILL.md":
                   '---\nname: demo\nargument-hint: "[--frobnicate]"\nallowed-tools: ["Bash"]\n---\n\nDoes a thing.\n'})
        rc, out = _run([sys.executable, os.path.join(self.tmp, "scripts", "check-skill-integrity.py")],
                       PYTHONIOENCODING="cp932")
        self.assertIn("P2", out)
        self.assertIn("--frobnicate", out)
        self.assertEqual(rc, 0, out)

    def test_skill_integrity_judges_anchor_targets_against_the_index(self):
        self.repo({"templates/A b.md": "## Seção\n",
                   "templates/links.md": "[a](A%20B.md#seção)\n\n[b](nota.md#top)\n"},
                  untracked={"templates/nota.md": "# top\n"})
        rc, out = self.integrity()
        self.assertEqual(rc, 1, out)
        self.assertIn("'A B.md' does not exist", out)
        self.assertIn("'nota.md' does not exist", out)


# ── BOM before frontmatter ────────────────────────────────────────────────────

SKILL = ('---\nname: demo\ndescription: "A demo skill that does one thing."\n'
         'argument-hint: "[x]"\nallowed-tools: ["Bash", "Agent"]\n---\n\nUse the Agent tool.\n')


class FrontmatterBom(Tmp):
    def test_skill_integrity_reads_frontmatter_behind_a_bom(self):
        # bom-frontmatter-misreport: a false P0, and a rule passing check 5 by omission.
        fm, body = _load("check-skill-integrity.py").parse_frontmatter("\ufeff" + SKILL)
        self.assertEqual(fm.get("allowed-tools"), ["Bash", "Agent"])
        self.assertEqual(fm.get("name"), "demo")

    def test_spec_conformance_reads_frontmatter_behind_a_bom(self):
        _copy_script(self.tmp, "check-spec-conformance.py")
        _write(self.tmp, ".claude/skills/demo/SKILL.md", b"\xef\xbb\xbf" + SKILL.encode())
        rc, out = _run([sys.executable, os.path.join(self.tmp, "scripts", "check-spec-conformance.py")])
        self.assertNotIn("no YAML frontmatter", out)
        self.assertEqual(rc, 0, out)

    def test_spec_conformance_survives_a_cp932_pipe(self):
        # gate-stdout-emdash-codepage: the advisory header's em dash is not in cp932.
        _copy_script(self.tmp, "check-spec-conformance.py")
        _write(self.tmp, ".claude/skills/demo/SKILL.md", SKILL)
        rc, out = _run([sys.executable, os.path.join(self.tmp, "scripts", "check-spec-conformance.py")],
                       PYTHONIOENCODING="cp932")
        self.assertIn("portability advisory", out)
        self.assertEqual(rc, 0, out)


# ── validate-findings.py ──────────────────────────────────────────────────────

_WARN = ["-X", "warn_default_encoding", "-W", "error::EncodingWarning"]
FINDING = {"file": "paper.md", "line": 1, "locus": "Results \u00b61", "lens": "results",
           "severity": "minor", "rule": "r", "claim": "c",
           "evidence": "The text reads \"effect is large \u2014 roughly 12 percent\" there.",
           "failing_case": "f", "suggested_fix": "s", "mechanical": False, "confidence": "high"}


class FindingIds(Tmp):
    def test_path_spelling_does_not_split_an_id(self):
        # finding-id-separator-sensitive
        fid = _load("validate-findings.py").finding_id
        want = fid("Slides/deck.tex", 12, "frame-3")
        self.assertEqual(want, "cd7e3f99d57dd867376fdffa97d2199a4d6ac496")   # canonical ids unchanged
        self.assertEqual(fid("Slides\\deck.tex", 12, "frame-3"), want)
        self.assertEqual(fid("./Slides/deck.tex", 12, "frame-3"), want)

    def test_mixed_spelling_pair_is_a_duplicate(self):
        a = dict(FINDING, file="Slides/deck.tex", lens="visual")
        b = dict(FINDING, file="Slides\\deck.tex", lens="pedagogy")
        p = _write(self.tmp, "f.json", json.dumps([a, b]))
        rc, out = _run([sys.executable, os.path.join(SCRIPTS, "validate-findings.py"), "--fill-ids", p])
        self.assertEqual(rc, 1, out)
        self.assertIn("duplicate of findings[0]", out)


class FindingsEncoding(Tmp):
    def test_fill_then_check_quotes_on_a_windows_code_page(self):
        # validate-findings-locale-read: the report and stdin were read, and the filled
        # report written, in the locale; a true quote read as invented, a '¶' locus
        # broke its own id.
        _write(self.tmp, "paper.md", "The estimated effect is large \u2014 roughly 12 percent "
                                     "of the baseline for S\u00e3o Paulo firms.\n")
        block = _write(self.tmp, "block.json", json.dumps([FINDING], ensure_ascii=False))
        vf = os.path.join(SCRIPTS, "validate-findings.py")
        r = subprocess.run([sys.executable, *_WARN, vf, "--fill-ids", block], capture_output=True,
                           env=_env(PYTHONIOENCODING="cp1252", PYTHONUTF8="0"), timeout=120)
        self.assertEqual(r.returncode, 0, r.stderr.decode("utf-8", "replace"))
        filled = _write(self.tmp, "r.json", r.stdout)
        with open(filled, encoding="utf-8") as f:
            got = json.load(f)[0]["id"]
        self.assertEqual(got, hashlib.sha1("paper.md:1:Results \u00b61".encode()).hexdigest())
        rc, out = _run([sys.executable, *_WARN, vf, "--check-quotes", filled, "--root", self.tmp],
                       PYTHONIOENCODING="cp1252", PYTHONUTF8="0")
        self.assertEqual(rc, 0, out)
        self.assertIn("quotes OK", out)


# ── file-issue.py ─────────────────────────────────────────────────────────────

FAKE_GH = """#!/usr/bin/env bash
echo "ARGS $*" >> "$FAKE_GH_LOG"
case "$1 ${2:-}" in
  "issue list")   cat "$FAKE_GH_HITS"; exit 0 ;;
  "issue create") echo "https://github.com/o/r/issues/99"; exit 0 ;;
esac
exit 1
"""
# Windows decodes a child's text output with the ANSI code page: patch the locale
# the subprocess module asks, then run the script.
CP1252_LOCALE = ("import locale, runpy, sys\n"
                 "locale.getencoding = lambda: 'cp1252'\n"
                 "locale.getpreferredencoding = lambda do_setlocale=True: 'cp1252'\n"
                 "sys.argv = sys.argv[1:]\n"
                 "runpy.run_path(sys.argv[0], run_name='__main__')\n")


@POSIX_HOST
class FileIssueEncoding(Tmp):
    TITLE = "Standard errors in Table 3 disagree with the log"

    def gh(self, title):
        fake = _bin(self.tmp, gh=FAKE_GH)
        hits = _write(self.tmp, "hits.json",
                      json.dumps([{"number": 31, "title": title, "state": "CLOSED", "url": "u31"}],
                                 ensure_ascii=False))            # gh prints raw UTF-8
        body = _write(self.tmp, "body.md", "Standard errors in Table 3 do not match the log.\n")
        log = os.path.join(self.tmp, "gh.log")
        env = dict(PATH=fake + os.pathsep + os.environ.get("PATH", ""), FAKE_GH_HITS=hits,
                   FAKE_GH_LOG=log, PYTHONUTF8="0")
        return body, log, env

    def created(self, log):
        with open(log, encoding="utf-8", errors="replace") as f:
            return sum(1 for ln in f if ln.startswith("ARGS issue create"))

    def test_look_alike_with_curly_quotes_is_listed_not_lost(self):
        # file-issue-gh-decode: the ” in a candidate's title is not cp1252; the decode
        # failed, and on Windows the check read it as "no candidates" and filed.
        body, log, env = self.gh("Table 3 \u201cSEs\u201d disagree")
        fi = os.path.join(SCRIPTS, "file-issue.py")
        rc, out = _run([sys.executable, "-c", CP1252_LOCALE, fi, "--title", self.TITLE, "--body-file", body], **env)
        self.assertEqual(rc, 3, out)
        self.assertIn("#31 [closed] Table 3 \u201cSEs\u201d disagree", out)
        self.assertEqual(self.created(log), 0)

    def test_listing_survives_a_cp932_pipe(self):
        # The 'Possible duplicates —' line: no em dash in cp932, so any candidate crashed it.
        body, log, env = self.gh("Table 3 SEs disagree")
        fi = os.path.join(SCRIPTS, "file-issue.py")
        rc, out = _run([sys.executable, fi, "--title", self.TITLE, "--body-file", body],
                       PYTHONIOENCODING="cp932", **env)
        self.assertEqual(rc, 3, out)
        self.assertIn("#31 [closed] Table 3 SEs disagree", out)
        self.assertEqual(self.created(log), 0)


# ── slide-qa.py ───────────────────────────────────────────────────────────────

SLIDE_QA_RUNNER = r'''
import importlib.util, sys, types
script, deck, out, title, verdict = sys.argv[1:6]
sys.modules["playwright"] = types.ModuleType("playwright")      # measured below instead
spec = importlib.util.spec_from_file_location("slide_qa", script)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
def measure_deck(html, out_dir, tol, screenshots):
    bad = verdict != "ok"
    return ([{"n": 1, "h": 0, "v": 0, "title": title, "verdict": verdict,
              "overflow_px": {"bottom": 5 if bad else 0, "right": 0, "top": 0, "left": 0},
              "offenders": [{"element": "p", "by_px": 5, "text": title}] if bad else [],
              "clipped": [], "images_not_loaded": [], "broken_images": [], "broken_assets": [],
              "screenshot": None, "defects": ["overflow"] if bad else []}],
            "stub", "none", (1050, 700), {"missing": [], "wrong_case": []})
m.measure_deck = measure_deck
sys.argv = [script, deck, "--out", out, "--no-screenshots"]
sys.exit(m.main())
'''


class SlideQaEncoding(Tmp):
    def run_qa(self, title, verdict):
        runner = _write(self.tmp, "runner.py", SLIDE_QA_RUNNER)
        deck = _write(self.tmp, "deck.html", "<html></html>\n")
        out = os.path.join(self.tmp, "out")
        rc, text = _run([sys.executable, *_WARN, runner, os.path.join(SCRIPTS, "slide-qa.py"), deck, out,
                         title, verdict], PYTHONIOENCODING="cp1252", PYTHONUTF8="0")
        return rc, text, os.path.join(out, "report.md")

    def test_clean_deck_exits_0_on_a_cp1252_pipe(self):
        # slide-qa-arrow-print: '→' is in no Windows ANSI code page; a clean deck exited 1.
        rc, out, md = self.run_qa("Intro", "ok")
        self.assertEqual(rc, 0, out)
        with open(md, "rb") as f:
            self.assertIn("1050\u00d7700", f.read().decode("utf-8"))

    def test_report_is_utf8_whatever_the_locale(self):
        # report.md was written in the locale: cp1252 bytes, or empty on a β title.
        rc, out, md = self.run_qa("\u03b2 \u2192 estimates", "overflow")
        self.assertEqual(rc, 1, out)
        self.assertTrue(os.path.exists(md), out)
        with open(md, "rb") as f:
            self.assertIn("\u03b2 \u2192 estimates", f.read().decode("utf-8"))


# ── validate-setup.sh ─────────────────────────────────────────────────────────

class ValidateSetup(Tmp):
    # Stand-ins, so the tool checks answer at once instead of starting the real ones.
    STUB = "#!/bin/sh\necho stub 1.0\n"

    def setUp(self):
        super().setUp()
        self.repo = os.path.join(self.tmp, "template")
        _copy_script(self.repo, "validate-setup.sh")
        _write(self.repo, ".githooks/pre-commit", "#!/usr/bin/env bash\nexit 0\n", mode=0o755)
        _write(self.repo, ".claude/hooks/guard.py", "print()\n", mode=0o644)     # run as `python3 <file>`
        _write(self.repo, ".claude/hooks/notify.sh", "#!/usr/bin/env bash\n", mode=0o755)
        _git(self.repo, "init", "-q")
        stubs = _bin(self.tmp, claude=self.STUB, xelatex=self.STUB, quarto=self.STUB, R=self.STUB, gh=self.STUB)
        self.path = stubs + os.pathsep + os.environ.get("PATH", "")

    def setup_out(self, cwd):
        rc, out = _run([shutil.which("bash"), os.path.join(self.repo, "scripts", "validate-setup.sh")],
                       cwd=cwd, PATH=self.path, SLIDE_QA_PYTHON="true")
        return out

    def test_equivalent_hookspath_spelling_is_active(self):
        # validate-setup-hookspath-string-equality
        for hp in ("./.githooks", ".githooks/", os.path.join(self.repo, ".githooks")):
            _git(self.repo, "config", "core.hooksPath", hp)
            out = self.setup_out(self.repo)
            self.assertIn("gate active", out, hp)
            self.assertNotIn("not activated", out, hp)

    def test_reads_its_own_repository_from_outside_it(self):
        # validate-setup-reads-cwd-repo, direction 1: run from a directory that is no repo.
        _git(self.repo, "config", "core.hooksPath", ".githooks")
        elsewhere = os.path.join(self.tmp, "elsewhere")
        os.makedirs(elsewhere)
        self.assertIn("gate active", self.setup_out(elsewhere))

    def test_another_repositorys_setting_is_not_its_own(self):
        # validate-setup-reads-cwd-repo, direction 2: the shell's repo has the gate on.
        other = os.path.join(self.tmp, "other")
        os.makedirs(os.path.join(other, ".githooks"))
        _git(other, "init", "-q")
        _git(other, "config", "core.hooksPath", ".githooks")
        out = self.setup_out(other)
        self.assertIn("not activated", out)
        self.assertNotIn("gate active", out)

    @POSIX_HOST
    def test_exec_bit_is_checked_only_where_it_matters(self):
        # validate-setup-false-exec-bit-warning: a 0644 .py hook run by python3 is fine.
        out = self.setup_out(self.repo)
        self.assertNotIn("hook script(s) not executable", out)
        self.assertIn("All hook scripts are executable", out)
        os.chmod(os.path.join(self.repo, ".claude", "hooks", "notify.sh"), 0o644)
        self.assertIn("1 hook script(s) not executable", self.setup_out(self.repo))


# ── sync_to_docs.sh ───────────────────────────────────────────────────────────

class SyncToDocs(Tmp):
    def deploy(self, name, *decks):
        _copy_script(self.tmp, "sync_to_docs.sh")
        for d in decks:
            _write(self.tmp, "Quarto/" + d, "---\ntitle: x\n---\n")
        os.makedirs(os.path.join(self.tmp, "Figures"))
        os.makedirs(os.path.join(self.tmp, "docs"))
        log = os.path.join(self.tmp, "quarto.log")
        stub = _bin(self.tmp, quarto='#!/bin/sh\nprintf \'%s|\' "$@" >> "$QLOG"\n')
        rc, out = _run([shutil.which("bash"), os.path.join(self.tmp, "scripts", "sync_to_docs.sh"), name],
                       PATH=stub + os.pathsep + os.environ.get("PATH", ""), QLOG=log)
        rendered = ""
        if os.path.exists(log):
            with open(log, encoding="utf-8") as f:
                rendered = f.read()
        return rc, out, rendered

    def test_lecture_name_with_a_space(self):
        # sync-to-docs-unquoted-arg: 'Aula 1' split in two; with a stray 1.qmd it
        # rendered THAT deck.
        rc, out, rendered = self.deploy("Aula 1", "Aula 1.qmd", "1.qmd")
        self.assertEqual(rc, 0, out)
        self.assertEqual(rendered, "render|Aula 1.qmd|")

    def test_control_exact_name_still_wins_over_a_suffixed_one(self):
        rc, out, rendered = self.deploy("Lecture2", "Lecture2.qmd", "Lecture2_Intro.qmd")
        self.assertEqual(rc, 0, out)
        self.assertEqual(rendered, "render|Lecture2.qmd|")


# ── hook-battery.sh ───────────────────────────────────────────────────────────

BATTERY = os.path.join(SCRIPTS, "hook-battery.sh")
SYM_CASES = ("c57", "c58", "c59", "c60", "c61", "c62", "c63", "c64")


def _battery_cases():
    # The count check-derived-counts.py takes: expect_ call sites.
    with open(BATTERY, encoding="utf-8") as f:
        return len(re.findall(r'^[ \t]*expect_(?:deny|silent|contains)[ \t]', f.read(), re.M))


class BatteryEventRewrite(Tmp):
    """_ev (PR #152) rewrites an event's POSIX paths to the native spelling under Git
    Bash. The paths must go in literally: '&' in a replacement and '[ ]' or a trailing
    '$' in a pattern are sed syntax (battery-ev-sed-metachar)."""
    FAKE_CYGPATH = ('#!/bin/sh\n[ "$1" = "-m" ] && shift\n'
                    'case "$1" in /c/*) printf \'C:/%s\\n\' "${1#/c/}" ;;'
                    ' /*) printf \'C:/msys64%s\\n\' "$1" ;; *) printf \'%s\\n\' "$1" ;; esac\n')
    DRIVER = 'TMP="$1"; ROOT="$2"; . "$3"; cat "$(_ev "$4")"\n'

    def test_paths_are_rewritten_literally(self):
        with open(BATTERY, encoding="utf-8") as f:
            m = re.search(r"^if command -v cygpath >/dev/null 2>&1; then\n.*?^fi$", f.read(), re.S | re.M)
        self.assertIsNotNone(m, "hook-battery.sh has no cygpath event-rewrite block")
        block = _write(self.tmp, "block.sh", m.group(0) + "\n")
        driver = _write(self.tmp, "driver.sh", self.DRIVER)
        fake = _bin(self.tmp, cygpath=self.FAKE_CYGPATH)
        for tmp, root in (("/tmp/T&mp/hb.1", "/c/Users/R&D/proj"),
                          ("/tmp/hb.2", "/c/Users/dev/proj[1]"),
                          ("/tmp/hb.3", "/c/Users/dev/proj$"),
                          ("/tmp/a.b*c", "/c/Users/x^y/proj (1) {2} +3.v")):
            ev = _write(self.tmp, "ev.json", '{"cwd":"%s","f":"%s/repo","r":"%s/.claude"}' % (root, tmp, root))
            rc, out = _run([shutil.which("bash"), driver, tmp, root, block, ev],
                           PATH=fake + os.pathsep + os.environ.get("PATH", ""))
            want = '{"cwd":"C:/%s","f":"C:/msys64%s/repo","r":"C:/%s/.claude"}' % (root[3:], tmp, root[3:])
            self.assertEqual((rc, out), (0, want), (tmp, root))


@POSIX_HOST
@unittest.skipIf(os.environ.get("BACKTEST_SKIP_HOOK_BATTERY") == "1",
                 "pre-commit: no hook, hook setting or battery change is staged; CI runs these")
class BatteryPortability(unittest.TestCase):
    """Two full battery runs, side by side (each takes about half a minute)."""
    LN_COPIES = ('#!/usr/bin/env bash\n# MSYS2 / Git Bash default: ln -s makes a deep COPY.\n'
                 'if [ "${1:-}" = "-s" ]; then shift; exec cp -RL "$1" "$2"; fi\nexec /bin/ln "$@"\n')
    # Windows only to the battery itself: git's own shell helpers ask uname too, and
    # a MINGW answer swaps in their Windows code paths (c46's `submodule add` broke).
    UNAME_MINGW = ('#!/bin/sh\ncase "$(ps -o args= -p "$PPID" 2>/dev/null)" in\n'
                   '  *hook-battery.sh*) echo MINGW64_NT-10.0-19045 ;;\n  *) exec "%s" "$@" ;;\nesac\n')

    @classmethod
    def setUpClass(cls):
        cls._td = tempfile.TemporaryDirectory()
        tmp = os.path.realpath(cls._td.name)
        outside = os.path.join(tmp, "outside")
        foreign = os.path.join(tmp, "foreign-project")
        os.makedirs(outside)
        os.makedirs(foreign)
        shims = _bin(tmp, ln=cls.LN_COPIES, uname=cls.UNAME_MINGW % shutil.which("uname"))
        bash = shutil.which("bash")
        runs = {
            # battery-depends-on-invoker-cwd: by absolute path from outside the repo,
            # with a session's CLAUDE_PROJECT_DIR naming some other directory.
            "elsewhere": subprocess.Popen([bash, BATTERY], cwd=outside, env=_env(CLAUDE_PROJECT_DIR=foreign),
                                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT),
            # battery-symlink-cases-unreachable-on-windows: Git Bash's ln and uname.
            "windows": subprocess.Popen([bash, BATTERY], cwd=ROOT,
                                        env=_env(PATH=shims + os.pathsep + os.environ.get("PATH", "")),
                                        stdout=subprocess.PIPE, stderr=subprocess.STDOUT),
        }
        cls.res = {}
        for k, p in runs.items():
            out, _ = p.communicate(timeout=900)
            cls.res[k] = (p.returncode, out.decode("utf-8", "replace"))
        cls.cases = _battery_cases()

    @classmethod
    def tearDownClass(cls):
        cls._td.cleanup()

    def tail(self, k):
        return "\n".join(self.res[k][1].splitlines()[-25:])

    def test_runs_from_outside_the_repo_with_a_foreign_project_dir(self):
        rc, out = self.res["elsewhere"]
        self.assertEqual(rc, 0, self.tail("elsewhere"))
        self.assertIn(f"hook-battery: ALL PASS ({self.cases} cases)", out)

    def test_symlink_cases_still_run_on_posix(self):
        # The same run: no shim, so c57-c64 are measured, not marked.
        rc, out = self.res["elsewhere"]
        for c in SYM_CASES:
            self.assertRegex(out, rf"(?m)^  PASS  {c} ", c)
        self.assertNotIn("UNREACHABLE", out)

    def test_symlink_cases_are_unreachable_not_failed_on_windows(self):
        rc, out = self.res["windows"]
        self.assertEqual(rc, 0, self.tail("windows"))
        for c in SYM_CASES:
            self.assertRegex(out, rf"(?m)^  UNREACHABLE  {c} ", c)
        self.assertNotRegex(out, r"(?m)^  FAIL  ")
        self.assertIn(f"ALL PASS ({self.cases} cases; 8 UNREACHABLE on this platform", out)


if __name__ == "__main__":
    unittest.main()

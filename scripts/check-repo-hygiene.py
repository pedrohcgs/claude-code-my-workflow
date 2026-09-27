#!/usr/bin/env python3
"""Keep the repo structurally clean. Agents generate scratch; scratch must not become main.

Catches the drift that accumulates when Claude or Codex tries five approaches and four of
them get left behind: draft-named files, numbered duplicates, root clutter, stale artifacts
that were never archived, and archives with no explanation of why they exist. Also paths
that differ only by case, which Linux keeps apart and a Mac or Windows checkout cannot.

Exit: 0 clean, 1 hygiene violations, 2 internal error.
"""
import os, posixpath, re, sys, subprocess, unicodedata

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Files permitted at the repository root. Anything else is clutter until allowlisted.
ROOT_ALLOW = {
    "README.md", "CLAUDE.md", "MEMORY.md", "CHANGELOG.md", "TROUBLESHOOTING.md",
    "LICENSE", "CITATION.cff", ".gitignore", ".gitattributes",
    "Bibliography_base.bib", ".DS_Store",
    # Records which source produced the current rendered artifacts. Must live at
    # the root because it is repo-wide and read by check-staleness.py; git does not
    # preserve mtimes, so content fingerprints are the only portable answer.
    ".render-stamp",
    # Written by /voice-profile at the root (the skill documents this location);
    # an author's voice profile is a legitimate committed artifact.
    "voice-profile.md",
    # R package and environment files that /r-package-check and /capture-environment
    # work with at the root (DESCRIPTION, renv.lock, requirements.txt, a Dockerfile, ...).
    "DESCRIPTION", "NAMESPACE", ".Rbuildignore", "renv.lock", ".Rprofile",
    "requirements.txt", "environment.yml", "uv.lock", "pyproject.toml", "Dockerfile",
}
ROOT_ALLOW_DIRS = {
    ".claude", ".git", ".github", ".githooks", ".vscode", "Figures", "Preambles",
    "Quarto", "Slides", "docs", "explorations", "guide", "master_supporting_docs",
    "quality_reports", "scripts", "templates",
    # The project layout in .claude/rules/repo-hygiene.md ("Where each kind of file
    # goes"): generated results in output/, raw inputs in data/raw/, package-style
    # functions and tests in R/ and tests/. A fork that follows it must not fail here.
    "output", "data", "R", "tests",
    # ...and the rest of an R package (r-package-conventions.md) and a renv library.
    "man", "vignettes", "inst", "renv",
    # The deposit /replication-package assembles for a journal's data editor.
    "replication_package",
}

# Names that mean "I was experimenting". These must not live in tracked source.
DRAFT_PATTERNS = [
    (r'(?i)^(untitled|tmp|temp|scratch|foo|bar|baz|asdf|test123)(?![a-z0-9])', "placeholder name"),
    (r'(?i)[-_ ](old|bak|backup|copy|orig|original|prev|deprecated)\.[a-z0-9]+$', "superseded copy — archive it or delete it"),
    (r'(?i)[-_ ](v\d+|final|new|latest|fixed|updated|real|actual)\.[a-z0-9]+$', "version-in-filename — that is what git is for"),
    # 'name 2.md' is flagged ONLY when the base 'name.md' also exists — the true
    # accidental-copy signature. Bare 'Lecture 2.tex' style names are ordinary
    # academic filenames (v2.5 audit false-positive).
    (None, None),
    (r'^.+\(\d+\)\.[a-z0-9]+$', "parenthesised duplicate — an accidental copy"),
    (r'(?i)^(copy of |untitled )', "unrenamed copy"),
]

# Directories that hold superseded work must explain themselves.
ARCHIVE_DIRS = ["explorations", "master_supporting_docs"]

# Append-only records: an entry, once committed, is never edited or removed — a
# correction is a new entry. Every committed line must still be present, in order, in
# the staged and the working-tree text; new lines may be added anywhere (a merge can
# interleave two co-authors' entries). Line endings are compared as LF, so a CRLF
# checkout does not read as an edit. ALLOW_LOG_REWRITE=1 downgrades a rewrite to a
# warning, for the one case that needs it: a disclosure redaction, explained in the
# commit. Locally the reference is HEAD, which the pre-commit hook checks before each
# commit; CI sets APPEND_ONLY_BASE to the branch the work merges into, so a rewrite
# committed without the hook is caught there.
APPEND_ONLY = ["quality_reports/replication-log.md", "quality_reports/spec-ledger.md"]

def git_blob(spec):
    """Bytes of `git show <spec>` (e.g. HEAD:path, :path), or None if there is none."""
    r = subprocess.run(["git", "-C", ROOT, "show", spec], capture_output=True)
    return r.stdout if r.returncode == 0 else None

def _lines(b):
    return b.replace(b"\r\n", b"\n").decode("utf-8", "replace").split("\n")

def _kept(old, new):
    """(True, None) if every line of `old` appears in `new` in order; else (False, first lost line no.)."""
    it = iter(enumerate(new))
    for n, line in enumerate(old, 1):
        for _, cand in it:
            if cand == line:
                break
        else:
            return False, n
    return True, None

def append_only_violations():
    """One message per append-only record whose committed lines were edited or removed."""
    out, base = [], os.environ.get("APPEND_ONLY_BASE", "").strip()
    for rel in APPEND_ONLY:
        refs = [("HEAD", git_blob(f"HEAD:{rel}"))]
        if base:
            refs.append((base, git_blob(f"{base}:{rel}")))
        refs = [(name, blob) for name, blob in refs if blob is not None]
        if not refs:                           # never committed: nothing to protect yet
            continue
        versions = []
        stages = subprocess.run(["git", "-C", ROOT, "ls-files", "-s", "--", rel], capture_output=True,
                                encoding="utf-8", errors="surrogateescape").stdout.split("\n")
        stages = [ln.split()[2] for ln in stages if ln.strip()]
        if not stages:
            versions.append(("staged (removed from the index)", b""))
        elif stages == ["0"]:                  # a conflicted merge has stages 1-3: nothing staged yet
            versions.append(("staged", git_blob(f":{rel}") or b""))
        wt_path = os.path.join(ROOT, rel)
        versions.append(("working tree", open(wt_path, "rb").read() if os.path.isfile(wt_path) else b""))
        for ref, old in refs:
            hit = next(((where, n) for where, text in versions
                        for ok, n in [_kept(_lines(old), _lines(text))] if not ok), None)
            if hit:
                where, n = hit
                out.append(f"{rel}: committed line {n} (as of {ref}) was edited or removed in the {where} "
                           f"— this record is append-only, so add a new entry instead. For a disclosure "
                           f"redaction, commit with ALLOW_LOG_REWRITE=1 and give the reason in the commit message.")
                break
    return out

def tracked():
    # -z: without it git C-quotes any path holding a non-ASCII byte, a quote or a tab
    # ("scripts/an\303\241lise.R"), so one accented file name read as a phantom
    # top-level directory `"scripts/` and failed every commit, while the closing quote
    # hid `análise_old.R` from the `$`-anchored draft patterns. Decoded as UTF-8 (git's
    # path encoding), not the locale: on Windows text=True means cp1252, where an Á
    # (byte 0x81) crashed the gate and an é came back as mojibake.
    r = subprocess.run(["git", "-C", ROOT, "ls-files", "-z"], capture_output=True)
    return [f for f in r.stdout.decode("utf-8", "surrogateescape").split("\0") if f]

def main():
    # Violations print real file names now, and a cp1252 or cp932 pipe (Git Bash,
    # a captured hook) cannot encode every one: print UTF-8, whatever the console.
    for s in (sys.stdout, sys.stderr):
        try:
            s.reconfigure(encoding="utf-8", errors="backslashreplace")
        except (AttributeError, ValueError):
            pass
    files = tracked()
    if not files:
        print("check-repo-hygiene: no tracked files (not a git repo?)", file=sys.stderr); return 2
    errs, warns = [], []

    # 1. root clutter — files AND top-level directories (ROOT_ALLOW_DIRS was
    #    previously dead code; the audit caught that no directory check ran)
    top_dirs = {f.split("/",1)[0] for f in files if "/" in f}
    for d in sorted(top_dirs - ROOT_ALLOW_DIRS):
        errs.append(f"{d}/: unexpected top-level directory — add to ROOT_ALLOW_DIRS with a reason, or relocate")
    for f in files:
        if "/" in f: continue
        if f not in ROOT_ALLOW:
            errs.append(f"{f}: unexpected file at repo root — move it into a directory, "
                        f"or add it to ROOT_ALLOW in this script with a reason")

    # 2. draft / scratch / duplicate naming anywhere
    NUMBERED_STAGE = re.compile(r'^\d+[-_]')   # 01_explore.R, 02_clean.R — pipeline stages, not drafts
    tracked_set = set(files)
    for f in files:
        base = posixpath.basename(f)             # git paths are '/'-separated on every OS
        if NUMBERED_STAGE.match(base):
            continue
        # explorations/ is the sandbox BY DESIGN — its own protocol permits
        # versioned and dated filenames there (exploration-folder-protocol.md).
        if f.startswith("explorations/"):
            continue
        # sibling-required numbered-duplicate check
        m2 = re.match(r'^(.*) \d+(\.[a-z0-9]+)$', base, re.I)
        if m2:
            # posixpath, not os.path: on Windows os.path.join built 'templates\notes.md',
            # which is never among git's '/' paths, so no duplicate below the root was caught.
            sib = posixpath.join(posixpath.dirname(f), m2.group(1) + m2.group(2))
            if sib in tracked_set:
                errs.append(f"{f}: numbered duplicate of {sib} — an accidental copy")
                continue
        for pat, why in DRAFT_PATTERNS:
            if pat is None: continue
            if re.search(pat, base):
                errs.append(f"{f}: {why}")
                break

    # 2b. paths that differ only by case (or Unicode normalisation) are two files to
    #     Linux CI and one to a macOS or Windows disk: git reports "paths have collided",
    #     one copy wins, the tree stays dirty for good (a stash just moves the change to
    #     the other name), and git-guardrails then denies every pull and merge there.
    #     A directory spelt two ways is flagged once, not once per file under it.
    seen, reported = {}, set()
    for f in files:
        parts = f.split("/")
        for i in range(1, len(parts) + 1):
            p = "/".join(parts[:i])
            first = seen.setdefault(unicodedata.normalize("NFC", p).casefold(), p)
            if first != p and (first, p) not in reported:
                reported.add((first, p))
                errs.append(f"{p}: differs from {first} only by case (or Unicode normalisation) — "
                            f"the two collide on a macOS or Windows checkout; rename one")

    # 3. archive directories must carry a README explaining what is in them and why
    for d in ARCHIVE_DIRS:
        full = os.path.join(ROOT, d)
        if not os.path.isdir(full): continue
        entries = os.listdir(full)
        has_content = any(x for x in entries if not x.startswith("."))
        # Compared case-blind, by name: os.path.exists('README.md') found a Readme.md on
        # a case-insensitive Mac or Windows disk and not on Linux CI, so one tree passed
        # the local hook and failed CI.
        has_readme = any(x.casefold() in ("readme.md", "readme.txt")
                         and os.path.isfile(os.path.join(full, x)) for x in entries)
        if has_content and not has_readme:
            errs.append(f"{d}/: holds work but has no README — an archive nobody can interpret "
                        f"is indistinguishable from abandoned clutter")

    # 4. stray build artifacts that should be gitignored
    ART = re.compile(r'\.(aux|log|out|synctex\.gz|fls|fdb_latexmk|toc|nav|snm|vrb|bbl|blg|pyc|Rcheck)$')
    for f in files:
        if ART.search(f) and not f.startswith("master_supporting_docs/"):
            errs.append(f"{f}: build artifact is tracked — add it to .gitignore")

    # 5. append-only records keep every committed entry
    rewrite_ok = os.environ.get("ALLOW_LOG_REWRITE") == "1"
    for msg in append_only_violations():
        (warns if rewrite_ok else errs).append(msg + (" [ALLOW_LOG_REWRITE=1: allowed]" if rewrite_ok else ""))

    # 6. advisory: very large tracked files
    for f in files:
        p = os.path.join(ROOT, f)
        try: sz = os.path.getsize(p)
        except OSError: continue
        if sz > 5_000_000 and not f.endswith(".html"):
            warns.append(f"{f}: {sz//1_000_000} MB tracked — consider Git LFS or a data mirror")

    print(f"check-repo-hygiene: {len(files)} tracked files")
    if errs:
        print(f"\n{len(errs)} HYGIENE VIOLATION(S):")
        for e in errs: print(f"  {e}")
    if warns:
        print(f"\n{len(warns)} advisory:")
        for w in warns: print(f"  {w}")
    if not errs:
        print("\nStructure is clean: no root clutter, no draft-named files, no case-colliding paths, no stray artifacts, archives documented.")
    return 1 if errs else 0

if __name__ == "__main__":
    sys.exit(main())

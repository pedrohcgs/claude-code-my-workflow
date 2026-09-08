#!/usr/bin/env python3
"""Keep the repo structurally clean. Agents generate scratch; scratch must not become main.

Catches the drift that accumulates when Claude or Codex tries five approaches and four of
them get left behind: draft-named files, numbered duplicates, root clutter, stale artifacts
that were never archived, and archives with no explanation of why they exist.

Exit: 0 clean, 1 hygiene violations, 2 internal error.
"""
import os, re, sys, subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# Files permitted at the repository root. Anything else is clutter until allowlisted.
ROOT_ALLOW = {
    "README.md", "CLAUDE.md", "AGENTS.md", "MEMORY.md", "CHANGELOG.md", "TROUBLESHOOTING.md",
    "LICENSE", "CITATION.cff", ".gitignore", ".gitattributes",
    "Bibliography_base.bib", ".DS_Store",
    # Records which source produced the current rendered artifacts. Must live at
    # the root because it is repo-wide and read by check-staleness.py; git does not
    # preserve mtimes, so content fingerprints are the only portable answer.
    ".render-stamp",
    # Written by /voice-profile at the root (the skill documents this location);
    # an author's voice profile is a legitimate committed artifact.
    "voice-profile.md",
}
ROOT_ALLOW_DIRS = {
    ".agents", ".claude", ".codex", ".git", ".github", ".githooks", ".vscode", "Figures", "Preambles",
    "Quarto", "Slides", "docs", "explorations", "guide", "master_supporting_docs",
    "quality_reports", "scripts", "templates",
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

def tracked():
    r = subprocess.run(["git", "-C", ROOT, "ls-files"], capture_output=True, text=True)
    return [f for f in r.stdout.split("\n") if f]

def main():
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
        base = os.path.basename(f)
        if NUMBERED_STAGE.match(base):
            continue
        # explorations/ is the sandbox BY DESIGN — its own protocol permits
        # versioned and dated filenames there (exploration-folder-protocol.md).
        if f.startswith("explorations/"):
            continue
        # sibling-required numbered-duplicate check
        m2 = re.match(r'^(.*) \d+(\.[a-z0-9]+)$', base, re.I)
        if m2:
            sib = os.path.join(os.path.dirname(f), m2.group(1) + m2.group(2))
            if sib in tracked_set:
                errs.append(f"{f}: numbered duplicate of {sib} — an accidental copy")
                continue
        for pat, why in DRAFT_PATTERNS:
            if pat is None: continue
            if re.search(pat, base):
                errs.append(f"{f}: {why}")
                break

    # 3. archive directories must carry a README explaining what is in them and why
    for d in ARCHIVE_DIRS:
        full = os.path.join(ROOT, d)
        if not os.path.isdir(full): continue
        has_content = any(x for x in os.listdir(full) if not x.startswith("."))
        has_readme = any(os.path.exists(os.path.join(full, n))
                         for n in ("README.md", "readme.md", "README.txt"))
        if has_content and not has_readme:
            errs.append(f"{d}/: holds work but has no README — an archive nobody can interpret "
                        f"is indistinguishable from abandoned clutter")

    # 4. stray build artifacts that should be gitignored
    ART = re.compile(r'\.(aux|log|out|synctex\.gz|fls|fdb_latexmk|toc|nav|snm|vrb|bbl|blg|pyc|Rcheck)$')
    for f in files:
        if ART.search(f) and not f.startswith("master_supporting_docs/"):
            errs.append(f"{f}: build artifact is tracked — add it to .gitignore")

    # 5. advisory: very large tracked files
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
        print("\nStructure is clean: no root clutter, no draft-named files, no stray artifacts, archives documented.")
    return 1 if errs else 0

if __name__ == "__main__":
    sys.exit(main())

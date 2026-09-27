#!/usr/bin/env python3
"""Verify every relative markdown link and anchor in the repo resolves.

Catches: links to files that don't exist, anchors that don't match a heading,
and references to skills/agents/rules that were renamed or removed.
Code spans and fenced blocks are stripped first (docs show example syntax).

A target resolves when git TRACKS it, spelled in exact case — not when the disk
has it. The disk said yes to a link to an untracked file, and on macOS and
Windows (case-insensitive) to README.MD for README.md: green here, then a 404 on
GitHub and a red CI (#171). Only tracked files are scanned, for the same reason.
Outside a git checkout the disk is all there is, and it is used.
"""
import re, os, sys, glob, subprocess, unicodedata
from urllib.parse import unquote

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
NFC = lambda s: unicodedata.normalize("NFC", s)   # macOS stores names NFD, git and links NFC
# A reported link can name what a Windows pipe's code page lacks (cp932 has no
# 'ç'); replace it rather than lose the report to a traceback (#171).
try:
    sys.stdout.reconfigure(errors="replace")
except (AttributeError, ValueError):
    pass

def tracked():
    """Every path in git's index, '/'-separated and NFC; None when git cannot say.
    -z, because without it git quotes a non-ASCII name ("an\\303\\241lise.md")."""
    try:
        r = subprocess.run(["git", "-C", ROOT, "ls-files", "-z"], capture_output=True, timeout=60)
    except (OSError, subprocess.TimeoutExpired):
        return None
    if r.returncode != 0:
        return None
    return {NFC(f) for f in r.stdout.decode("utf-8", "surrogateescape").split("\0") if f} or None

TRACKED = tracked()
TRACKED_DIRS = {"."}
for t in TRACKED or ():
    parts = t.split("/")
    TRACKED_DIRS.update("/".join(parts[:i]) for i in range(1, len(parts)))

def relp(p):
    return os.path.relpath(p, ROOT).replace(os.sep, "/")

def resolves(full):
    if TRACKED is None:
        return os.path.exists(full)
    try:
        r = NFC(relp(full))
    except ValueError:              # Windows: another drive, so never in the repository
        return False
    return r in TRACKED or r in TRACKED_DIRS

SCAN = []
for pat in ["*.md", ".claude/**/*.md", "templates/**/*.md", ".github/**/*.md", "guide/*.qmd"]:
    SCAN += glob.glob(os.path.join(ROOT, pat), recursive=True)
SCAN = sorted(f for f in set(SCAN) if TRACKED is None or NFC(relp(f)) in TRACKED)

def strip_code(t):
    t = re.sub(r'```.*?```', lambda m: "\n"*m.group(0).count("\n"), t, flags=re.S)
    # Fenced blocks first (may span lines), then INLINE spans constrained to a
    # single line: with re.S a lone unpaired backtick paired with a distant one
    # and swallowed every link in between (v2.5 audit).
    t = re.sub(r'```.*?```', lambda m: '\n' * m.group(0).count('\n'), t, flags=re.S)
    t = re.sub(r'(`{1,2})([^`\n]+?)\1', lambda m: ' ' * len(m.group(0)), t)
    return t

def slug(h):
    """GitHub's heading-anchor algorithm.

    Critically, GitHub does NOT collapse runs of whitespace: it strips
    punctuation in place and converts EACH remaining space to a hyphen. So
    "Community & Extensions" -> "community--extensions" (double hyphen), because
    removing "&" leaves two adjacent spaces.

    Collapsing whitespace here produced a false positive on a correct README
    link. Caught while fixing a different finding; the check was wrong, not the
    link. (PR #140.)
    """
    s = h.strip().lower()
    # GitHub KEEPS underscores in anchors (heading "check_links" -> #check_links),
    # so `_` must not be in the strip class. (v2.5 audit: stripping it produced
    # false positives on correct links and false negatives on broken ones.)
    s = re.sub(r'[`*\[\]()]', '', s)
    s = re.sub(r'[^\w\s-]', '', s)      # strip punctuation IN PLACE (\w keeps _)
    return s.replace(' ', '-').strip('-')  # each space -> one hyphen, no collapsing

anchors = {}
def anchors_for(path):
    if path in anchors: return anchors[path]
    a = set()
    try: t = open(path, encoding="utf-8", errors="ignore").read()
    except Exception: anchors[path] = a; return a
    for m in re.finditer(r'^#{1,6}\s+(.*?)\s*$', t, re.M):
        head = m.group(1)
        explicit = re.search(r'\{#([\w:-]+)\}', head)
        if explicit: a.add(explicit.group(1))
        a.add(slug(re.sub(r'\{#[\w:-]+\}', '', head)))
    anchors[path] = a
    return a

# The destination is either <anything but angle brackets> — CommonMark's only way
# to put a space in it, which the old [^)\s]+ never matched, so a broken
# [x](<Aula 2.md>) passed unchecked — or a run with no space, then an optional
# "title" or 'title'.
LINK = re.compile(r'\[[^\]]*\]\((?:<([^<>\n]*)>|([^)\s<][^)\s]*))(?:\s+(?:"[^"]*"|\'[^\']*\'))?\s*\)')
bad = []
for f in SCAN:
    text = strip_code(open(f, encoding="utf-8", errors="ignore").read())
    base = os.path.dirname(f)
    for i, line in enumerate(text.split("\n"), 1):
        for m in LINK.finditer(line):
            target = m.group(1) if m.group(1) is not None else m.group(2)
            if target.startswith(("http://", "https://", "mailto:")):
                continue
            path, _, anc = target.partition("#")
            # A link names a file URL-encoded (Aula%201.md, se%C3%A7%C3%A3o) — the
            # spelling GitHub and editors write for spaces and accents.
            path, anc = unquote(path), unquote(anc)
            if not path:
                # Same-document anchor: [text](#section). Previously skipped
                # entirely, so a broken local anchor passed. (Codex review, PR #140.)
                if anc and f.endswith((".md", ".qmd")) and anc not in anchors_for(f):
                    bad.append((f, i, target, "same-document anchor not found"))
                continue
            full = os.path.normpath(os.path.join(base, path))
            if not resolves(full):
                bad.append((f, i, target, "missing file"))
            elif anc and full.endswith((".md", ".qmd")):
                if anc not in anchors_for(full):
                    bad.append((f, i, target, "anchor not found"))

if bad:
    print(f"check-links: {len(bad)} broken reference(s)\n")
    for f, i, t, why in bad:
        print(f"  {relp(f)}:{i}  ->  {t}   [{why}]")
    sys.exit(1)
print(f"check-links: all relative links and anchors resolve ({len(SCAN)} files scanned)")
sys.exit(0)

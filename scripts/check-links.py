#!/usr/bin/env python3
"""Verify every relative markdown link and anchor in the repo resolves.

Catches: links to files that don't exist, anchors that don't match a heading,
and references to skills/agents/rules that were renamed or removed.
Code spans and fenced blocks are stripped first (docs show example syntax).
"""
import re, os, sys, glob

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCAN = []
for pat in [
    "*.md", ".claude/**/*.md", ".agents/**/*.md", ".codex/**/*.md",
    "templates/**/*.md", ".github/**/*.md", "guide/*.qmd",
]:
    SCAN += glob.glob(os.path.join(ROOT, pat), recursive=True)
SCAN = sorted(set(SCAN))

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

LINK = re.compile(r'\[[^\]]*\]\(([^)\s]+)(?:\s+"[^"]*")?\)')
bad = []
for f in SCAN:
    text = strip_code(open(f, encoding="utf-8", errors="ignore").read())
    base = os.path.dirname(f)
    for i, line in enumerate(text.split("\n"), 1):
        for target in LINK.findall(line):
            if target.startswith(("http://", "https://", "mailto:")):
                continue
            path, _, anc = target.partition("#")
            if not path:
                # Same-document anchor: [text](#section). Previously skipped
                # entirely, so a broken local anchor passed. (Codex review, PR #140.)
                if anc and f.endswith((".md", ".qmd")) and anc not in anchors_for(f):
                    bad.append((f, i, target, "same-document anchor not found"))
                continue
            full = os.path.normpath(os.path.join(base, path))
            if not os.path.exists(full):
                bad.append((f, i, target, "missing file"))
            elif anc and full.endswith((".md", ".qmd")):
                if anc not in anchors_for(full):
                    bad.append((f, i, target, "anchor not found"))

rel = lambda p: os.path.relpath(p, ROOT)
if bad:
    print(f"check-links: {len(bad)} broken reference(s)\n")
    for f, i, t, why in bad:
        print(f"  {rel(f)}:{i}  ->  {t}   [{why}]")
    sys.exit(1)
print(f"check-links: all relative links and anchors resolve ({len(SCAN)} files scanned)")
sys.exit(0)

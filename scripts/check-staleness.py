#!/usr/bin/env python3
"""Scan for stale recommendations and drift the other gates cannot see.

The other gates check that surfaces agree WITH EACH OTHER. This one checks for
claims that were true once and are not any more, plus source/render divergence.

Exit: 0 clean, 1 stale content found, 2 internal error.
"""
import re, os, sys, glob, subprocess

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
# defect-library.md is a CATALOGUE of anti-patterns to seed — it contains them by design.
SKIP = re.compile(r'(^|/)(CHANGELOG\.md|defect-library\.md|\.git/|node_modules/|quality_reports/)')

def surfaces():
    out = []
    for pat in ["*.md", ".claude/**/*.md", "templates/**/*.md", "guide/*.qmd", "docs/*.html", ".github/**/*.md"]:
        out += glob.glob(os.path.join(ROOT, pat), recursive=True)
    # SKIP is written with '/', so match it against a '/' path: on Windows relpath
    # gives backslashes, the anchors never matched, and the anti-pattern catalogue
    # was scanned and failed this gate on every clone (#171).
    return [p for p in sorted(set(out)) if not SKIP.search(os.path.relpath(p, ROOT).replace(os.sep, "/"))]

# (id, description, regex, allow-marker regex or None)
CHECKS = [
 ("STALE-TOOL", "names `Task` as the subagent tool (it is `Agent`)",
  r'via\s+`?Task`?\b|`Task`\s+subagent|spawn\w*\s+[^.\n]{0,30}\bvia\s+Task\b', r'legacy|prior|historical|alias|renamed|model-allow'),
 ("STALE-AUTOMODE", "describes auto mode as plan-gated (it is the Pro/Max/Team default since 2026-08-14)",
  r'auto mode\s+(requires|needs)\s+(Team|Enterprise)|rolling out to Max', r'UPDATED|no longer|was\b'),
 ("STALE-SUPERLATIVE", "unfalsifiable product claim",
  r'\bthe only (public )?(workflow|template|repo)\b|\bnobody else (has|can)\b|\bbest-in-class\b|\bthe first (public )?workflow\b', r'Banned|never claim|Seed|seed|anti-pattern|example of'),
 ("STALE-BLOCKER", "cites a closed issue as an open blocker",
  r'blocked (on|by) .{0,40}#11278|#11278.{0,40}(blocker|quirk)', r'UNBLOCKED|closed'),
]

def main():
    files = surfaces()
    hits = []
    for f in files:
        rel = os.path.relpath(f, ROOT).replace(os.sep, "/")
        try: text = open(f, encoding="utf-8", errors="ignore").read()
        except Exception: continue
        for cid, desc, pat, allow in CHECKS:
            for i, line in enumerate(text.split("\n"), 1):
                if re.search(pat, line, re.I):
                    if allow and re.search(allow, line, re.I): continue
                    hits.append((cid, rel, i, desc, line.strip()[:90]))

    # source vs rendered divergence.
    #
    # NOT by mtime: git does not preserve timestamps, so on a fresh clone or a
    # detached worktree the checkout order decides which file looks newer. That
    # made this gate fail spuriously for every first-time forker and in CI.
    # (Codex review, PR #140 — confirmed by reproducing it in a fresh worktree.)
    #
    # Instead: compare a fingerprint of the SOURCE against the fingerprint the
    # last render recorded. Content, not clock.
    render = []
    import hashlib
    stamp_path = os.path.join(ROOT, ".render-stamp")
    recorded = {}
    if os.path.exists(stamp_path):
        for line in open(stamp_path):
            parts = line.strip().split(":")
            if len(parts) == 3:
                recorded[parts[0]] = (parts[1], parts[2])   # (source_hash, output_hash)
    for src, out in [("guide/workflow-guide.qmd", "guide/workflow-guide.html"),
                     ("guide/workflow-guide.qmd", "docs/workflow-guide.html")]:
        s_path, o_path = os.path.join(ROOT, src), os.path.join(ROOT, out)
        if not (os.path.exists(s_path) and os.path.exists(o_path)):
            continue
        # Line endings are not content. An autocrlf checkout (the Git for Windows
        # default) holds CRLF where the stamp hashed LF, and read as a stale render
        # on a pristine clone (#171). CRLF -> LF only, exactly as
        # scripts/stamp-render.sh does: the two must agree byte for byte, or every
        # stamp goes stale.
        src_hash = hashlib.sha256(open(s_path, "rb").read().replace(b"\r\n", b"\n")).hexdigest()[:16]
        out_hash = hashlib.sha256(open(o_path, "rb").read().replace(b"\r\n", b"\n")).hexdigest()[:16]
        rec = recorded.get(out)
        if rec is None:
            render.append(f"{out}: no render stamp — run scripts/stamp-render.sh after rendering")
        elif rec[0] != src_hash:
            render.append(f"{out}: stamped for a DIFFERENT source ({rec[0]} vs {src_hash}) — "
                          f"re-render: cd guide && quarto render workflow-guide.qmd, sync docs, "
                          f"then ./scripts/stamp-render.sh")
        elif rec[1] != out_hash:
            render.append(f"{out}: output modified since it was stamped ({rec[1]} vs {out_hash}) — "
                          f"either an unsynced copy or a hand-edit; re-render and re-stamp")

    # currency expiry — a verified_on date that has aged out
    expired = []
    mv = os.path.join(ROOT, ".claude/references/model-versions.md")
    if os.path.exists(mv):
        t = open(mv, encoding='utf-8', errors='ignore').read()
        m = re.search(r'\*\*Expires:\*\*\s*(\d{4}-\d{2}-\d{2})', t)
        if m:
            today = subprocess.run(["date","+%Y-%m-%d"],capture_output=True,text=True).stdout.strip()
            if today > m.group(1):
                expired.append(f"model-versions.md expired {m.group(1)} (today {today}) — re-verify against the docs")

    # guide version <-> CHANGELOG parity (Oracle review, 2026-08-22: the source
    # shipped with no version and a stale date; this pins it to the release).
    meta = []
    gq = os.path.join(ROOT, "guide/workflow-guide.qmd")
    cl = os.path.join(ROOT, "CHANGELOG.md")
    if os.path.exists(gq) and os.path.exists(cl):
        gt = open(gq, encoding='utf-8', errors='ignore').read(2000)
        ct = open(cl, encoding='utf-8', errors='ignore').read(4000)
        gv = re.search(r'^version:\s*"?v?(\d+\.\d+\.\d+)"?', gt, re.M)
        cv = re.search(r'^## v(\d+\.\d+\.\d+)', ct, re.M)
        if not gv:
            meta.append("guide frontmatter has no version: field — add one matching the CHANGELOG release")
        elif cv and gv.group(1) != cv.group(1):
            meta.append(f"guide version {gv.group(1)} != CHANGELOG latest v{cv.group(1)} — update the frontmatter")

    # reversed dynamic-injection syntax: `!cmd` (backtick-first) is inert; the
    # real grammar is !`cmd` (Oracle review, 2026-08-22 — the guide shipped the
    # reversed form and readers copy examples verbatim).
    inject = []
    scan = []
    for base in ("guide/workflow-guide.qmd", "templates/skill-template.md"):
        p = os.path.join(ROOT, base)
        if os.path.exists(p): scan.append(p)
    skdir = os.path.join(ROOT, ".claude/skills")
    if os.path.isdir(skdir):
        for d in sorted(os.listdir(skdir)):
            p = os.path.join(skdir, d, "SKILL.md")
            if os.path.exists(p): scan.append(p)
    inj_pat = re.compile(r"`![a-z][a-z0-9._-]*(?:\s+[^`\n]*)?`")
    for p in scan:
        rel = os.path.relpath(p, ROOT).replace(os.sep, "/")
        for i, line in enumerate(open(p, encoding='utf-8', errors='ignore'), 1):
            for m in inj_pat.finditer(line):
                frag = m.group(0)
                # R-code negations like `!anyNA(w)` and shell paths like
                # `!/shell/erase` are not injection attempts.
                if "(" in frag or frag.startswith("`!/"): continue
                inject.append(f"{rel}:{i}: {frag} — reversed injection syntax; write !`cmd`, not `!cmd`")

    print(f"check-staleness: {len(files)} surfaces scanned")
    bad = hits or render or expired or meta or inject
    for cid, rel, i, desc, line in hits: print(f"  [{cid}] {rel}:{i}  {desc}\n      {line}")
    for r in render:  print(f"  [STALE-RENDER] {r}")
    for e in expired: print(f"  [STALE-EXPIRY] {e}")
    for x in meta:    print(f"  [STALE-VERSION] {x}")
    for x in inject:  print(f"  [BAD-INJECT-SYNTAX] {x}")
    if not bad: print("No stale recommendations, no source/render divergence, no expired currency claims.")
    return 1 if bad else 0

if __name__ == "__main__":
    # Every finding line carries an em dash, which a cp932/cp949 pipe (Japanese,
    # Korean Windows) cannot encode: a real finding became "internal error" (#171).
    try:
        sys.stdout.reconfigure(errors="replace")
    except (AttributeError, ValueError):
        pass
    try:
        sys.exit(main())
    except Exception as e:                      # promised exit 2 now exists
        print(f"check-staleness: internal error: {e}", file=sys.stderr)
        sys.exit(2)

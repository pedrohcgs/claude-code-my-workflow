#!/usr/bin/env python3
"""Create a GitHub issue only after checking for duplicates — the one sanctioned route.

A tracker is only a memory if each problem lives in one place. Before anything is
created, this runs several searches over OPEN and CLOSED issues (one strict query on
the title's four most distinctive words, the top three of them alone in titles, every
--search term you pass, and up to three file paths the title or body names; at most
eight searches, and any dropped are reported) and lists what it finds. The issue body
records how many searches of each kind ran and the verdict — not the search text, which
may hold terms the author did not mean to publish. The issue is created only when every candidate has been reviewed and
judged distinct, which you record with --checked. The check and its verdict are
appended to the issue body, so the record shows the search was done.

The issue-guard hook blocks a raw `gh issue create` from Claude and points here.

Usage:
  python3 scripts/file-issue.py --title "..." --body-file body.md \
      [--label bug] [--search "extra terms"] [--checked 12,15] [--repo owner/name] [--dry-run]

Exit: 0 created (or, with --dry-run, ready to create); 3 candidates still to review
(listed on stdout, nothing created); 2 could not run — no gh, a search failed, or no
search could be built (nothing created: the check fails closed); 1 gh refused the
create.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import re
import shlex
import shutil
import subprocess
import sys
import tempfile

MAX_QUERIES = 8
SHOW = 10
STOP = set("""
a an and are as at be been but by can cannot could did do does doesn for from had has have how
if in into is it its it's may might must no not of on once only or our out over should so than
that the their them then there these this those to too under up use used uses using was we were
what when where which while who why will with without would yet you your
add adds added bug bugs error errors fail fails failed failing fix fixes fixed issue issues make
makes new now problem problems still wrong
""".split())
WORD = re.compile(r"[A-Za-z0-9_][A-Za-z0-9_.\-/]*[A-Za-z0-9_]|[A-Za-z0-9_]")
PATH = re.compile(r"(?<![\w/.-])(?:[\w.-]+/)*[\w.-]+\.(?:R|r|py|sh|tex|qmd|md|Rmd|do|ado|ipynb|"
                  r"json|ya?ml|csv|bib|html|js|css|scss|toml|txt)\b")


def keywords(title: str) -> list[str]:
    seen, out = set(), []
    for w in WORD.findall(title):
        k = w.lower().strip(".-/")
        if len(k) >= 3 and k not in STOP and k not in seen:
            seen.add(k)
            out.append(k)
    return sorted(out, key=len, reverse=True)       # longest first: usually the most specific


def build_queries(title: str, body: str, extra: list[str]) -> list[tuple[str, str]]:
    """(kind, query) pairs, deduplicated by query. The kind — not the query — is what
    the issue body records, so a --search term or a path never reaches a public issue
    unless the author wrote it there."""
    kw = keywords(title)
    qs: list[tuple[str, str]] = []
    if kw:
        qs.append(("the title's words", " ".join(kw[:4]) + " in:title,body"))
        qs += [("the title's words", f"{k} in:title") for k in kw[:3]]
    qs += [("--search terms", s) for s in extra if s.strip()]
    for p in list(dict.fromkeys(PATH.findall(title + "\n" + body)))[:3]:
        qs.append(("file paths", f'"{p}"'))
    seen: set[str] = set()
    return [(k, q) for k, q in qs if not (q in seen or seen.add(q))]


def search(query: str, repo: str | None) -> list[dict]:
    cmd = ["gh", "issue", "list", "--state", "all", "--search", query, "--limit", "20",
           "--json", "number,title,state,url"]
    if repo:
        cmd += ["--repo", repo]
    # Bytes, decoded here. gh writes UTF-8; text=True decoded it with the Windows
    # code page, and on Windows that decode runs in subprocess's reader thread,
    # where a title holding ” or ρ killed the thread and left stdout None — read
    # as "no candidates", so the check passed and the issue was filed (#171). A
    # bad decode now raises here, and main() fails closed.
    r = subprocess.run(cmd, capture_output=True, timeout=60)
    if r.returncode != 0:
        raise RuntimeError(f"`{' '.join(cmd[:4])} ... {query!r}` failed: "
                           f"{(r.stderr or r.stdout).decode('utf-8', 'replace').strip()[:300]}")
    return json.loads(r.stdout.decode("utf-8") or "[]")


def parse_checked(values: list[str]) -> set[int]:
    return {int(n) for v in values for n in re.findall(r"\d+", v)}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    ap.add_argument("--title", required=True)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--body-file")
    g.add_argument("--body")
    ap.add_argument("--label", action="append", default=[])
    ap.add_argument("--search", action="append", default=[],
                    help="extra search terms (a section name, a function, a table label)")
    ap.add_argument("--checked", action="append", default=[],
                    help="issue numbers you reviewed and judged distinct, e.g. 12,15")
    ap.add_argument("--repo", help="owner/name (default: the repository gh infers)")
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()
    # A title the pipe's code page cannot show (ρ or → on cp1252; the em dash below
    # on cp932 or cp949) crashed the duplicate listing. UTF-8 is what Claude Code
    # and mintty read.
    for s in (sys.stdout, sys.stderr):
        try:
            s.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, ValueError):
            pass

    if not shutil.which("gh"):
        print("file-issue: CANNOT RUN — the GitHub CLI (gh) is not on PATH. Install it "
              "(brew install gh / apt install gh) and run `gh auth login`. Nothing was created.",
              file=sys.stderr)
        return 2
    try:
        body = open(a.body_file, encoding="utf-8").read() if a.body_file else a.body
    except OSError as e:
        print(f"file-issue: cannot read --body-file: {e}", file=sys.stderr)
        return 2

    queries = build_queries(a.title, body, a.search)
    if not queries:
        print("file-issue: CANNOT RUN — the title has no searchable words; pass --search "
              "with the terms a duplicate would contain. Nothing was created.", file=sys.stderr)
        return 2
    if len(queries) > MAX_QUERIES:
        print(f"file-issue: running the first {MAX_QUERIES} of {len(queries)} searches "
              f"(dropped: {[q for _, q in queries[MAX_QUERIES:]]})", file=sys.stderr)
        queries = queries[:MAX_QUERIES]

    found: dict[int, dict] = {}
    try:
        for _, q in queries:
            for it in search(q, a.repo):
                row = found.setdefault(it["number"], {**it, "hits": 0})
                row["hits"] += 1
    except (RuntimeError, subprocess.TimeoutExpired, ValueError, KeyError) as e:
        # ValueError covers a JSONDecodeError and a UnicodeDecodeError alike.
        print(f"file-issue: CANNOT RUN — the duplicate search did not complete ({e}). "
              "Nothing was created: an unchecked issue is what this script exists to prevent.",
              file=sys.stderr)
        return 2

    checked = parse_checked(a.checked)
    ranked = sorted(found.values(), key=lambda r: (-r["hits"], -r["number"]))
    pending = [r for r in ranked if r["number"] not in checked]

    if pending:
        print(f"Possible duplicates — {len(pending)} not yet reviewed "
              f"({len(queries)} searches over open and closed issues):")
        for r in pending[:SHOW]:
            print(f"  #{r['number']} [{r['state'].lower()}] {r['title']}  "
                  f"(matched {r['hits']} of {len(queries)} searches)")
        if len(pending) > SHOW:
            print(f"  ... and {len(pending) - SHOW} more with fewer matches")
        print("\nRead each one (gh issue view N). If one is the same problem, add to it instead:")
        print("  gh issue comment N --body-file <file>    (and gh issue reopen N if it is back)")
        shown = ",".join(str(r["number"]) for r in pending[:SHOW])
        print(f"If the new issue is distinct from all of them, re-run with --checked {shown}")
        print("Nothing was created.")
        return 3

    today = _dt.date.today().isoformat()
    kinds: dict[str, int] = {}
    for k, _ in queries:
        kinds[k] = kinds.get(k, 0) + 1
    qsummary = ", ".join(f"{n} on {k}" for k, n in kinds.items())
    verdict = (f"reviewed and judged distinct: {', '.join(f'#{n}' for n in sorted(r['number'] for r in ranked))}"
               if ranked else "no candidates found")
    record = (f"\n\n---\nDuplicate check ({today}, scripts/file-issue.py): {len(queries)} searches "
              f"of open and closed issues ({qsummary}); {verdict}.")
    full = body.rstrip("\n") + record + "\n"

    cmd = ["gh", "issue", "create", "--title", a.title]
    for lab in a.label:
        cmd += ["--label", lab]
    if a.repo:
        cmd += ["--repo", a.repo]

    if a.dry_run:
        print("Dry run — nothing created.")
        print(f"Title: {a.title}")
        print(f"Labels: {', '.join(a.label) or '(none)'}")
        print("Body:\n" + full)
        print("Searches run (listed here only; the issue records their kinds, not their text):")
        for _, q in queries:
            print(f"  {q}")
        print("Would run: " + shlex.join(cmd + ["--body-file", "<body>"]))
        return 0

    # The body can hold unpublished findings, so its temp file is removed once gh has
    # it; only a refused create keeps it, named, so the author can fix and retry.
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as f:
        f.write(full)
        path = f.name
    keep = False
    try:
        # Decoded explicitly: a failed locale decode here left stdout None, and the
        # write below raised AFTER the issue had been created.
        r = subprocess.run(cmd + ["--body-file", path], capture_output=True,
                           encoding="utf-8", errors="replace")
        sys.stdout.write(r.stdout)
        if r.returncode != 0:
            keep = True
            sys.stderr.write(r.stderr)
            print(f"file-issue: gh refused the create (exit {r.returncode}); the body is kept "
                  f"at {path} for a retry — delete it when done", file=sys.stderr)
            return 1
        return 0
    finally:
        if not keep:
            try:
                os.unlink(path)
            except OSError:
                pass


if __name__ == "__main__":
    sys.exit(main())

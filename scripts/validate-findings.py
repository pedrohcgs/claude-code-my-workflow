#!/usr/bin/env python3
r"""Validate a review-findings array against .claude/references/finding-schema.json.

Turns the FINDING contract from prose into a gate with an exit code.

    echo '[]' | python3 scripts/validate-findings.py            # smoke test
    python3 scripts/validate-findings.py report.json
    python3 scripts/validate-findings.py --id FILE LINE LOCUS        # compute a finding id
    python3 scripts/validate-findings.py --fill-ids in.json > out.json  # add ids, then validate
    python3 scripts/validate-findings.py --check-quotes report.json [--root DIR]  # quotes vs source

--fill-ids exists because reviewer agents are read-only: they return their findings array
WITHOUT ids (they cannot run this script), and the dispatching skill fills every id from
the finding's own coordinates. Any id already present is overwritten — ids are computed,
never supplied. The filled array is printed to stdout only if it then validates (exit 0);
otherwise the errors go to stderr and nothing is printed (exit 1).

--check-quotes catches the most damaging reviewer error: an invented quotation. Every
double-quoted span of 12+ characters in a finding's `evidence` ("…" or “…”, read left to
right) must occur in the finding's `file` — or in another file the evidence names by path,
as a parity finding quoting the Beamer source does. Comparison is after normalisation:
Unicode NFKC, curly quotes and dashes unified, whitespace collapsed, case folded, line-end
hyphenation joined; for a quote with no backslash also LaTeX markup, `` '' quotes, \% and
-- stripped, so "significant effect" matches \emph{significant} effect. A quote containing a
backslash was copied from source and must match it as written. An elision (..., …, […])
splits a quote into fragments that must occur in order, close together. Backticked code
outside a quotation is not checked. A PDF is read through pdftotext; a file that cannot be
read as text leaves its quotes unchecked (reported, not failed). Each miss is printed with
the closest line of the file. Paths resolve against --root (default: the current directory).

Exit: 0 valid, 1 invalid, 2 internal error.
"""
import json, sys, os, hashlib, re, subprocess, unicodedata, difflib, posixpath

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCHEMA = os.path.join(ROOT, ".claude", "references", "finding-schema.json")

def finding_id(file, line, locus, lens=None):
    # lens is deliberately NOT in the identity: the same defect found by two
    # lenses must dedup to one finding. (Codex review, PR #140.)
    # Nor is the spelling of the path: a reviewer on Windows writes Slides\deck.tex,
    # another ./Slides/deck.tex, and one defect got two ids and listed twice (#171).
    # A canonical Slides/deck.tex keeps the id it always had.
    file = str(file)
    if file:
        file = posixpath.normpath(file.replace("\\", "/"))
    return hashlib.sha1(f"{file}:{line}:{locus}".encode()).hexdigest()

def _utf8_stdio():
    # Windows hands a pipe the ANSI code page (cp1252, cp932). The filled report
    # is read back as UTF-8, and a '¶' in a locus or a quoted '—' was written in
    # the code page, mangled, or crashed the print (#171).
    for s in (sys.stdout, sys.stderr):
        try:
            s.reconfigure(encoding="utf-8", errors="replace")
        except (AttributeError, ValueError):
            pass

def _read_json_text(path):
    # UTF-8 whatever the locale; -sig also takes a BOM, which json.loads rejects.
    if path:
        return open(path, encoding="utf-8-sig").read()
    return sys.stdin.buffer.read().decode("utf-8-sig")

def validate(data, schema):
    errs = []
    if not isinstance(data, list):
        return ["top level must be an ARRAY of findings, not an object "
                "(reports are arrays, not {\"findings\": [...]} wrappers)"]
    req = schema["required"]; props = schema["properties"]; seen = {}
    for i, f in enumerate(data):
        w = f"findings[{i}]"
        if not isinstance(f, dict):
            errs.append(f"{w}: not an object"); continue
        for k in req:
            if k not in f: errs.append(f"{w}: missing required field '{k}'")
        for k in f:
            if k not in props: errs.append(f"{w}: unknown field '{k}' (additionalProperties: false)")
        for k, v in f.items():
            spec = props.get(k)
            if not spec: continue
            if "enum" in spec and v not in spec["enum"]:
                errs.append(f"{w}.{k}: {v!r} not in {spec['enum']}")
            t = spec.get("type")
            # NB: isinstance(True, int) is True in Python; JSON Schema treats
            # boolean and integer as distinct types. (Codex, PR #140 round 2.)
            if t == "integer" and (isinstance(v, bool) or not isinstance(v, int)): errs.append(f"{w}.{k}: must be integer (boolean is not)")
            if t == "string" and not isinstance(v, str): errs.append(f"{w}.{k}: must be string")
            if t == "boolean" and not isinstance(v, bool): errs.append(f"{w}.{k}: must be boolean")
            if "pattern" in spec and isinstance(v, str) and not re.fullmatch(spec["pattern"], v):
                errs.append(f"{w}.{k}: {v!r} does not match {spec['pattern']}")
            if "minimum" in spec and isinstance(v, int) and not isinstance(v, bool) and v < spec["minimum"]:
                errs.append(f"{w}.{k}: below minimum {spec['minimum']}")
        # id must be reproducible from its own coordinates. Guard on type:
        # a non-string id already failed the type check above, and slicing or
        # hashing it here would crash the validator instead of reporting
        # (Codex, PR #140 round 3).
        if isinstance(f.get("id"), str):
            if all(k in f for k in ("file", "line", "locus")):
                want = finding_id(f["file"], f["line"], f["locus"])
                if f["id"] != want:
                    errs.append(f"{w}.id: {f['id'][:12]}… != sha1(file:line:locus) {want[:12]}…")
            if f["id"] in seen: errs.append(f"{w}.id: duplicate of findings[{seen[f['id']]}]")
            seen[f["id"]] = i
    return errs

QUOTE_MIN = 12                # shorter quoted spans are terms ("ATT", "treat"), not quotations
ELISION = re.compile(r'\s*(?:\[(?:\.\.\.|\u2026)\]|\.\.\.|\u2026)\s*')
ELISION_WINDOW = 1500         # characters allowed between two fragments of one elided quotation
PATHLIKE = re.compile(r'(?<![\w/.-])((?:[\w.-]+/)*[\w.-]+\.(?:tex|qmd|md|rmd|R|r|py|do|jl|bib|txt|csv|html|yml|yaml|json|pdf))(?::\d+)?')
_UNIFY = str.maketrans({"\u201c": '"', "\u201d": '"', "\u2018": "'", "\u2019": "'", "\u2013": "-",
                        "\u2014": "-", "\u2212": "-", "\u00a0": " "})

def extract_quotes(evidence):
    """Double-quoted spans of QUOTE_MIN+ characters, read left to right.

    Every pair of straight quotes is consumed whatever its length, so a short quoted
    term cannot shift the pairing onto the prose between two quotations. Code in
    backticks outside a quotation is skipped; backticks inside one belong to it.
    """
    out, i, n = [], 0, len(evidence)
    while i < n:
        c = evidence[i]
        if c == "`":
            tick = re.match(r"`+", evidence[i:]).group(0)
            end = evidence.find(tick, i + len(tick))
            i = n if end < 0 else end + len(tick)
        elif c in '"\u201c':
            end = evidence.find('"' if c == '"' else "\u201d", i + 1)
            if end < 0:
                break
            if end - i - 1 >= QUOTE_MIN:
                out.append(evidence[i + 1:end])
            i = end + 1
        else:
            i += 1
    return out

def _norm(text, latex, dehyphen, quote=False):
    """dehyphen: 0 leave line-end hyphens, 1 join keeping the hyphen (well-known),
    2 join dropping it (a word broken by hyphenation: statis-tics)."""
    t = unicodedata.normalize("NFKC", text).translate(_UNIFY)
    if dehyphen:
        t = re.sub(r"(\w)-[ \t]*\n\s*(\w)", r"\1-\2" if dehyphen == 1 else r"\1\2", t)
    if latex:
        if not quote:
            t = re.sub(r"(?<!\\)%.*", "", t)                     # comments: the file's, never the quote's
        t = t.replace("\\%", "%").replace("``", '"').replace("''", '"')
        t = re.sub(r"\\\\|\\ ", " ", t)                          # forced line break, control space
        t = re.sub(r"-{2,3}", "-", t)                            # -- and --- are dashes
        t = re.sub(r"\\[a-zA-Z]+\*?(\[[^\]]*\])?", " ", t)      # command names; arguments stay
        t = re.sub(r"[{}$~]", " ", t)
    return re.sub(r"\s+", " ", t).strip().casefold()

def _in_order(frags, hay):
    """Every fragment occurs in order, each within ELISION_WINDOW of the one before."""
    start = hay.find(frags[0])
    while start >= 0:
        pos, ok = start + len(frags[0]), True
        for f in frags[1:]:
            nxt = hay.find(f, pos)
            if nxt < 0 or nxt - pos > ELISION_WINDOW:
                ok = False
                break
            pos = nxt + len(f)
        if ok:
            return True
        start = hay.find(frags[0], start + 1)
    return False

def _found(quote, views):
    r"""True if the quotation occurs in one normalised view of the text.

    A quote containing a backslash was copied from source, so it must match the source
    as written: stripping LaTeX commands would let \hat\alpha stand in for \hat\beta.
    """
    for latex in ((False,) if "\\" in quote else (False, True)):
        frags = [_norm(f, latex, 0, quote=True) for f in ELISION.split(quote) if f.strip()]
        if frags and any(_in_order(frags, views[(latex, d)]) for d in (0, 1, 2)):
            return True
    return False

def load_text(path):
    """(text, None), or (None, why) when the file cannot be read as text."""
    if path.lower().endswith(".pdf"):
        try:
            # -enc: xpdf's pdftotext (common on Windows) writes Latin-1 by default.
            r = subprocess.run(["pdftotext", "-q", "-enc", "UTF-8", path, "-"], capture_output=True,
                               encoding="utf-8", errors="replace", timeout=60)
        except (OSError, subprocess.TimeoutExpired):
            return None, "a PDF, and pdftotext (poppler) is not available to read it"
        return (r.stdout, None) if r.returncode == 0 else (None, "a PDF that pdftotext could not read")
    try:
        raw = open(path, "rb").read()
    except OSError:
        return None, "missing"
    if b"\x00" in raw[:8192]:
        return None, "a binary file"
    return raw.decode("utf-8", "replace"), None

def check_quotes(args):
    root = os.getcwd()
    if "--root" in args:
        i = args.index("--root")
        if i + 1 >= len(args):
            print("usage: --check-quotes REPORT.json [--root DIR]", file=sys.stderr); return 2
        root = args[i + 1]; args = args[:i] + args[i + 2:]
    try:
        data = json.loads(_read_json_text(args[0] if args else None))
    except Exception as e:
        print(f"validate-findings: cannot read findings: {e}", file=sys.stderr); return 2
    if not isinstance(data, list):
        print("validate-findings: findings must be a JSON array", file=sys.stderr); return 2
    cache = {}
    def text_of(rel):
        path = os.path.join(root, rel)
        if path not in cache:
            txt, why = load_text(path)
            cache[path] = (txt, why, None if txt is None else
                           {(l, d): _norm(txt, l, d) for l in (False, True) for d in (0, 1, 2)})
        return cache[path]
    misses, unchecked, checked = [], [], 0
    for i, f in enumerate(data):
        if not isinstance(f, dict) or not isinstance(f.get("evidence"), str):
            continue
        quotes = extract_quotes(f["evidence"])
        if not quotes:
            continue
        where = f"findings[{i}] ({f.get('file')}:{f.get('line')}, {f.get('locus', '')})"
        own = str(f.get("file", ""))
        txt, why, _ = text_of(own)
        if why == "missing":
            misses.append(f"{where}: cannot check {len(quotes)} quote(s) — file not found: {own}")
            continue
        # The finding's file, plus any other file the evidence names by path (a parity
        # finding quotes the Beamer source while citing the Quarto file).
        others = [m.group(1) for m in PATHLIKE.finditer(f["evidence"]) if m.group(1) != own]
        sources = [own] + [o for o in dict.fromkeys(others) if os.path.isfile(os.path.join(root, o))]
        readable = [text_of(src) for src in sources if text_of(src)[0] is not None]
        if not readable:
            unchecked.append(f"{where}: {len(quotes)} quote(s) left unchecked — {own} is {why}")
            continue
        for q in quotes:
            checked += 1
            if any(_found(q, views) for _, _, views in readable):
                continue
            lines = [ln.strip() for ln in (txt or readable[0][0]).splitlines() if ln.strip()]
            near = difflib.get_close_matches(q, lines, n=1, cutoff=0.0)
            misses.append(f'{where}: quote not in {" or ".join(sources)}: "{q}"'
                          + (f'\n      closest line: "{near[0][:160]}"' if near else ""))
    for u in unchecked:
        print(f"  unchecked: {u}")
    if misses:
        print(f"validate-findings: {len(misses)} quotation problem(s) — a quote must be the file's own text")
        for m in misses:
            print(f"  {m}")
        return 1
    print(f"validate-findings: quotes OK ({checked} quote(s) checked"
          + (f"; {len(unchecked)} finding(s) with quotes left unchecked" if unchecked else "") + ")")
    return 0

def main():
    _utf8_stdio()
    a = sys.argv[1:]
    if a and a[0] == "--check-quotes":
        return check_quotes(a[1:])
    if a and a[0] == "--id":
        if len(a) not in (4, 5):
            print("usage: --id FILE LINE LOCUS", file=sys.stderr); return 2
        print(finding_id(a[1], a[2], a[3])); return 0
    fill = bool(a) and a[0] == "--fill-ids"
    if fill:
        a = a[1:]
    try:
        schema = json.load(open(SCHEMA, encoding="utf-8"))
    except Exception as e:
        print(f"validate-findings: cannot read schema: {e}", file=sys.stderr); return 2
    try:
        raw = _read_json_text(a[0] if a else None)
        data = json.loads(raw)
    except json.JSONDecodeError as e:
        print(f"validate-findings: invalid JSON: {e}", file=sys.stderr); return 1
    except Exception as e:
        print(f"validate-findings: cannot read input: {e}", file=sys.stderr); return 2
    if fill and isinstance(data, list):
        for f in data:
            if isinstance(f, dict) and all(k in f for k in ("file", "line", "locus")):
                f["id"] = finding_id(f["file"], f["line"], f["locus"])
    errs = validate(data, schema)
    out = sys.stderr if fill else sys.stdout
    if errs:
        print(f"validate-findings: {len(errs)} error(s)", file=out)
        for e in errs: print(f"  {e}", file=out)
        return 1
    if fill:
        print(json.dumps(data, indent=2, ensure_ascii=False))
        print(f"validate-findings: OK ({len(data)} finding(s), ids filled)", file=sys.stderr)
        return 0
    print(f"validate-findings: OK ({len(data)} finding(s))")
    return 0

if __name__ == "__main__":
    sys.exit(main())

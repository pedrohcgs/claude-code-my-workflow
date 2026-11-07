#!/usr/bin/env python3
"""List data files for a replication manifest without reading out a single value.

For each file under the given paths (default `data/raw`): its path, size, SHA-256, format,
and, for tables, the row count, the column names, and the columns whose *names* suggest
personal data (name, email, address, birth date, ...). Values are never printed, written or
returned, so the output can go into a replication README or to an assistant even when the
data cannot. The idea follows the World Bank's reproducibility skill
(worldbank/wb-reproducible-research-repository, which carries no licence; this is an
independent implementation).

Who runs it: on restricted data, the author, on the machine the data-use agreement allows.
The output still contains column names, and some agreements treat those as confidential:
check yours before you share it (.claude/rules/confidential-data.md).

Readers:
  CSV / TSV   standard library. The header row gives the names; if the first row looks like
              data (a cell that parses as a number), the names are withheld, because that
              row would be a record.
  .dta .sav .sas7bdat .xpt   pyreadstat, metadata only, if installed.
  .parquet    pyarrow, schema and row count from the footer, if installed.
  anything else   size and hash only.

Usage:
  python3 scripts/data-inventory.py [PATH ...] [--format csv|md] [--out FILE]

Exit: 0 listed; 2 a path does not exist, or --out cannot be written.
"""
from __future__ import annotations

import argparse
import csv
import hashlib
import io
import os
import re
import sys

CHUNK = 1 << 20
TABULAR_TEXT = {".csv": ",", ".tsv": "\t"}
READSTAT = {".dta": "read_dta", ".sav": "read_sav", ".zsav": "read_sav", ".sas7bdat": "read_sas7bdat",
            ".xpt": "read_xport"}
# Name tokens that suggest a direct or quasi-identifier. A flag is a prompt to look,
# never a verdict: the data-use agreement and the disclosure review decide.
PII_TOKENS = {
    "name", "firstname", "lastname", "surname", "fullname", "address", "street", "email", "mail",
    "phone", "mobile", "telephone", "ssn", "sin", "nino", "passport", "dob", "birth", "birthdate",
    "birthday", "zip", "zipcode", "postcode", "postal", "ip", "ipaddress", "latitude", "longitude",
    "lat", "lon", "lng", "geo", "gps", "iban", "account", "license", "licence", "plate", "mrn",
    "patient", "medicaid", "medicare", "taxid", "tin", "nationalid",
}
FIELDS = ["path", "bytes", "sha256", "format", "rows", "n_columns", "columns", "name_flags", "note"]


def sha256(path: str) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for block in iter(lambda: f.read(CHUNK), b""):
            h.update(block)
    return h.hexdigest()


def name_flags(names: list[str]) -> list[str]:
    out = []
    for n in names:
        parts = re.sub(r"([a-z])([A-Z])", r"\1 \2", n).lower()
        toks = set(re.split(r"[^a-z0-9]+", parts)) - {""}
        joined = re.sub(r"[^a-z0-9]", "", parts)
        if toks & PII_TOKENS or joined in PII_TOKENS:
            out.append(n)
    return out


def looks_like_data(cells: list[str]) -> bool:
    for c in cells:
        try:
            float(c.strip().replace(",", ""))
            return True
        except ValueError:
            continue
    return False


def read_text_table(path: str, delim: str) -> dict:
    with open(path, encoding="utf-8-sig", errors="replace", newline="") as f:
        reader = csv.reader(f, delimiter=delim)
        header = next(reader, None)
        rows = sum(1 for _ in reader)
    if header is None:
        return {"rows": 0, "n_columns": 0, "columns": [], "note": "empty file"}
    if looks_like_data(header):
        return {"rows": rows + 1, "n_columns": len(header), "columns": [],
                "note": "first row looks like data, not a header: column names withheld"}
    return {"rows": rows, "n_columns": len(header), "columns": [h.strip() for h in header], "note": ""}


def read_readstat(path: str, func: str) -> dict:
    try:
        import pyreadstat  # type: ignore
    except ImportError:
        return {"note": "columns not read: install pyreadstat to list them"}
    _, meta = getattr(pyreadstat, func)(path, metadataonly=True)
    return {"rows": meta.number_rows, "n_columns": len(meta.column_names),
            "columns": list(meta.column_names), "note": ""}


def read_parquet(path: str) -> dict:
    try:
        import pyarrow.parquet as pq  # type: ignore
    except ImportError:
        return {"note": "columns not read: install pyarrow to list them"}
    pf = pq.ParquetFile(path)
    names = list(pf.schema_arrow.names)
    return {"rows": pf.metadata.num_rows, "n_columns": len(names), "columns": names, "note": ""}


def describe(path: str, base: str) -> dict:
    ext = os.path.splitext(path)[1].lower()
    row = {"path": os.path.relpath(path, base).replace(os.sep, "/"), "bytes": os.path.getsize(path),
           "sha256": sha256(path), "format": ext.lstrip(".") or "(none)",
           "rows": "", "n_columns": "", "columns": [], "note": ""}
    try:
        if ext in TABULAR_TEXT:
            row.update(read_text_table(path, TABULAR_TEXT[ext]))
        elif ext in READSTAT:
            row.update(read_readstat(path, READSTAT[ext]))
        elif ext == ".parquet":
            row.update(read_parquet(path))
    except Exception as e:  # a reader failure is reported, never a crash and never a value
        row["note"] = f"columns not read: {type(e).__name__}"
    row["name_flags"] = name_flags(row["columns"])
    return row


def walk(paths: list[str]) -> list[tuple[str, str]]:
    """(file, base): paths are shown relative to the working directory when the input is
    inside it, and otherwise relative to the folder that contains the input."""
    cwd = os.getcwd()
    files = []
    for p in paths:
        inside = os.path.commonpath([cwd, p]) == cwd
        base = cwd if inside else os.path.dirname(p.rstrip(os.sep)) or p
        if os.path.isfile(p):
            files.append((p, base))
            continue
        for d, dirs, names in os.walk(p):
            dirs[:] = sorted(x for x in dirs if not x.startswith("."))
            files += [(os.path.join(d, n), base) for n in sorted(names) if not n.startswith(".")]
    return files


def render(rows: list[dict], fmt: str) -> str:
    def cell(r, k):
        v = r.get(k, "")
        return "; ".join(v) if isinstance(v, list) else str(v)
    if fmt == "md":
        out = ["| " + " | ".join(FIELDS) + " |", "|" + "---|" * len(FIELDS)]
        for r in rows:
            out.append("| " + " | ".join(cell(r, k).replace("|", "\\|") for k in FIELDS) + " |")
        return "\n".join(out) + "\n"
    buf = io.StringIO()
    w = csv.writer(buf, lineterminator="\n")
    w.writerow(FIELDS)
    for r in rows:
        w.writerow([cell(r, k) for k in FIELDS])
    return buf.getvalue()


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    ap.add_argument("paths", nargs="*", default=["data/raw"])
    ap.add_argument("--format", choices=["csv", "md"], default="csv")
    ap.add_argument("--out", help="write here instead of stdout")
    a = ap.parse_args()
    paths = [os.path.abspath(p) for p in a.paths]
    missing = [p for p in a.paths if not os.path.exists(p)]
    if missing:
        print(f"data-inventory: no such path: {', '.join(missing)}", file=sys.stderr)
        return 2
    text = render([describe(f, b) for f, b in walk(paths)], a.format)
    if a.out:
        try:
            with open(a.out, "w", encoding="utf-8", newline="") as f:
                f.write(text)
        except OSError as e:
            print(f"data-inventory: cannot write {a.out}: {e.strerror or e}", file=sys.stderr)
            return 2
    else:
        sys.stdout.buffer.write(text.encode("utf-8"))
    return 0


if __name__ == "__main__":
    sys.exit(main())

#!/usr/bin/env python3
"""
Generate a self-contained HTML project dashboard for a clo-author research project.

Scans the project structure — paper sections, data, scripts, quality reports,
bibliography, plans — and produces a single interactive HTML file.

Usage:
    python3 scripts/generate_dashboard.py [--project-root .] [--output project_dashboard.html]
"""

import argparse
import json
import os
import re
import subprocess
import sys
from datetime import datetime
from html import escape
from pathlib import Path


def find_project_root(start=None):
    p = Path(start or os.getcwd()).resolve()
    while p != p.parent:
        if (p / "CLAUDE.md").exists():
            return p
        p = p.parent
    return Path(start or os.getcwd()).resolve()


# ---------- Scanners ----------

def scan_metadata(root):
    """Extract project metadata from CLAUDE.md."""
    meta = {"title": "", "institution": "", "field": "", "status": {}}
    claude_md = root / "CLAUDE.md"
    if not claude_md.exists():
        return meta
    text = claude_md.read_text(errors="replace")

    m = re.search(r"\*\*Project:\*\*\s*(.+)", text)
    if m:
        meta["title"] = m.group(1).strip().strip("[]")
    m = re.search(r"\*\*Institution:\*\*\s*(.+)", text)
    if m:
        meta["institution"] = m.group(1).strip().strip("[]")
    m = re.search(r"\*\*Field:\*\*\s*(.+)", text)
    if m:
        meta["field"] = m.group(1).strip().strip("[]")

    table_match = re.search(
        r"\|\s*Component\s*\|\s*File\s*\|\s*Status\s*\|\s*Description\s*\|.*?\n((?:\|.+\n)+)",
        text,
    )
    if table_match:
        for row in table_match.group(1).strip().split("\n"):
            cols = [c.strip() for c in row.split("|") if c.strip()]
            if len(cols) >= 4 and not cols[0].startswith("-"):
                meta["status"][cols[0]] = {
                    "file": cols[1],
                    "status": cols[2].strip("[]"),
                    "description": cols[3].strip("[]"),
                }
    return meta


def scan_sections(root):
    """Find paper sections from main.tex \\input{} and paper/sections/."""
    sections = []
    main_tex = root / "paper" / "main.tex"

    if main_tex.exists():
        text = main_tex.read_text(errors="replace")
        for m in re.finditer(r"\\input\{([^}]+)\}", text):
            path_str = m.group(1)
            if not path_str.endswith(".tex"):
                path_str += ".tex"
            sec_path = root / "paper" / path_str
            if sec_path.exists():
                wc = len(re.findall(r"\b\w+\b", sec_path.read_text(errors="replace")))
                mtime = datetime.fromtimestamp(sec_path.stat().st_mtime).strftime("%Y-%m-%d")
                sections.append({"name": sec_path.stem.replace("_", " ").title(), "file": path_str, "words": wc, "modified": mtime})

    sec_dir = root / "paper" / "sections"
    if sec_dir.is_dir():
        seen = {s["file"] for s in sections}
        for f in sorted(sec_dir.glob("*.tex")):
            rel = f"sections/{f.name}"
            if rel not in seen:
                wc = len(re.findall(r"\b\w+\b", f.read_text(errors="replace")))
                mtime = datetime.fromtimestamp(f.stat().st_mtime).strftime("%Y-%m-%d")
                sections.append({"name": f.stem.replace("_", " ").title(), "file": rel, "words": wc, "modified": mtime})

    return sections


def scan_data(root):
    """Scan data/ for raw and cleaned datasets."""
    inventory = {"raw": [], "cleaned": []}
    for sub in ["raw", "cleaned"]:
        d = root / "data" / sub
        if d.is_dir():
            for f in sorted(d.rglob("*")):
                if f.is_file() and f.name != ".gitkeep":
                    size_kb = f.stat().st_size / 1024
                    inventory[sub].append({
                        "name": f.name,
                        "size": f"{size_kb:.0f} KB" if size_kb < 1024 else f"{size_kb/1024:.1f} MB",
                        "modified": datetime.fromtimestamp(f.stat().st_mtime).strftime("%Y-%m-%d"),
                    })
    return inventory


def scan_scripts(root):
    """Find analysis scripts in scripts/. Excludes dashboard/report generators."""
    scripts = []
    script_dir = root / "scripts"
    if not script_dir.is_dir():
        return scripts
    exts = {".R": "R", ".r": "R", ".py": "Python", ".jl": "Julia"}
    skip_names = {"generate_dashboard.py", "generate_html_report.py"}
    for f in sorted(script_dir.rglob("*")):
        if f.is_file() and f.suffix in exts and f.name not in skip_names:
            lang = exts[f.suffix]
            rel = str(f.relative_to(root))
            lines = f.read_text(errors="replace").split("\n")
            purpose = ""
            for line in lines[:15]:
                stripped = line.strip()
                if stripped.startswith('"""') or stripped.startswith("'''"):
                    continue
                cleaned = stripped.lstrip("#").lstrip("//").lstrip("'").lstrip('"').strip()
                if cleaned and not cleaned.startswith("!") and not cleaned.startswith("library") \
                   and not cleaned.startswith("import") and not cleaned.startswith("env ") \
                   and not cleaned.startswith("usr/") and len(cleaned) > 5:
                    purpose = cleaned[:80]
                    break
            scripts.append({"name": f.name, "path": rel, "lang": lang, "purpose": purpose})
    return scripts


def scan_figures_tables(root):
    """Count figures and tables."""
    figs = list((root / "paper" / "figures").glob("*")) if (root / "paper" / "figures").is_dir() else []
    figs = [f for f in figs if f.is_file() and f.name != ".gitkeep"]
    tabs = list((root / "paper" / "tables").glob("*.tex")) if (root / "paper" / "tables").is_dir() else []
    tabs = [t for t in tabs if t.name != ".gitkeep"]
    return len(figs), len(tabs)


def scan_bibliography(root):
    """Count bibliography entries."""
    bib = root / "Bibliography_base.bib"
    if not bib.exists():
        return 0
    return len(re.findall(r"@\w+\{", bib.read_text(errors="replace")))


def scan_quality_reports(root):
    """Find quality gate summaries, reviews, and extract scores."""
    reports = []
    qr = root / "quality_reports"
    if not qr.is_dir():
        return reports, None

    latest_gate = None
    for f in sorted(qr.rglob("*.md"), key=lambda x: x.stat().st_mtime, reverse=True):
        if f.name == ".gitkeep":
            continue
        rel = str(f.relative_to(root))
        mtime = datetime.fromtimestamp(f.stat().st_mtime).strftime("%Y-%m-%d")
        text = f.read_text(errors="replace")

        report_type = "report"
        score = None
        verdict = ""

        if "quality_gate" in f.name.lower() or "Quality Gate" in text[:100]:
            report_type = "quality-gate"
            m = re.search(r"Weighted Aggregate:\s*([\d.]+)", text)
            if m:
                score = float(m.group(1))
            m = re.search(r"Gate Result:\s*(\w+)", text)
            if m:
                verdict = m.group(1)
            if latest_gate is None:
                latest_gate = parse_quality_gate(text, score)
        elif "referee" in f.name.lower() or "Referee Report" in text[:100]:
            report_type = "peer-review"
            m = re.search(r"\*\*Overall Score:\*\*\s*(\d+)", text)
            if m:
                score = int(m.group(1))
            m = re.search(r"\*\*Recommendation:\*\*\s*(.+)", text)
            if m:
                verdict = m.group(1).strip()
        elif "editorial" in f.name.lower() or "Editorial Decision" in text[:100]:
            report_type = "editorial"
            m = re.search(r"\*\*Decision:\*\*\s*(.+)", text)
            if m:
                verdict = m.group(1).strip()
        elif "code_audit" in f.name.lower() or "code_review" in f.name.lower() or "Code Audit" in text[:100]:
            report_type = "code-audit"
            m = re.search(r"\*\*Score:\*\*\s*(\d+)", text)
            if m:
                score = int(m.group(1))
        elif "strategy_review" in f.name.lower() or "Strategy Review" in text[:200]:
            report_type = "strategy-review"
        elif "session" in f.name.lower() or f.parent.name == "session_logs":
            report_type = "session"
        elif f.parent.name == "plans":
            report_type = "plan"
            m = re.search(r"\*\*Status:\*\*\s*(\w+)", text)
            if m:
                verdict = m.group(1)

        reports.append({
            "file": rel,
            "name": f.stem.replace("_", " ").replace("-", " ").title(),
            "type": report_type,
            "date": mtime,
            "score": score,
            "verdict": verdict,
        })

    return reports, latest_gate


def parse_quality_gate(text, overall_score):
    """Parse component scores from a quality gate summary."""
    gate = {"overall": overall_score, "components": [], "result": "", "blocking": []}
    m = re.search(r"Gate Result:\s*(\w+)", text)
    if m:
        gate["result"] = m.group(1)

    for row in re.finditer(
        r"\|\s*([^|]+?)\s*\|\s*(\d+)%\s*\|\s*([^|]+?)\s*\|\s*(\d+)/100\s*\|\s*(\w+)\s*\|", text
    ):
        gate["components"].append({
            "name": row.group(1).strip(),
            "weight": int(row.group(2)),
            "agent": row.group(3).strip(),
            "score": int(row.group(4)),
            "status": row.group(5).strip(),
        })

    for m in re.finditer(r"###\s*Blocking.*?\n([\s\S]*?)(?=\n###|\n---|\Z)", text):
        for line in m.group(1).strip().split("\n"):
            line = line.strip().lstrip("-").lstrip("*").strip()
            if line:
                gate["blocking"].append(line)

    return gate


def scan_literature(root):
    """Find annotated bibliography and count papers."""
    lit_dir = root / "quality_reports" / "literature"
    if not lit_dir.is_dir():
        return None
    for project_dir in sorted(lit_dir.iterdir()):
        bib = project_dir / "annotated_bibliography.md"
        if bib.exists():
            text = bib.read_text(errors="replace")
            papers = []
            current = {}
            for line in text.split("\n"):
                if line.startswith("### ") or line.startswith("## "):
                    if current.get("title"):
                        papers.append(current)
                    current = {"title": line.lstrip("#").strip(), "category": "", "proximity": 0}
                pm = re.search(r"Proximity.*?(\d)", line)
                if pm:
                    current["proximity"] = int(pm.group(1))
            if current.get("title"):
                papers.append(current)
            return {"dir": str(project_dir.relative_to(root)), "count": len(papers), "papers": papers[:10]}
    return None


def scan_pipelines(root):
    """Find pipeline manifests in data/cleaned/."""
    pipelines = []
    cleaned = root / "data" / "cleaned"
    if not cleaned.is_dir():
        return pipelines
    for f in sorted(cleaned.glob("*_manifest.json")):
        try:
            manifest = json.loads(f.read_text(errors="replace"))
            pipelines.append(manifest)
        except (json.JSONDecodeError, KeyError):
            continue
    return pipelines


def scan_plans(root):
    """Find active plans."""
    plans = []
    plan_dir = root / "quality_reports" / "plans"
    if not plan_dir.is_dir():
        return plans
    for f in sorted(plan_dir.glob("*.md"), reverse=True):
        text = f.read_text(errors="replace")
        status = "DRAFT"
        m = re.search(r"\*\*Status:\*\*\s*(\w+)", text)
        if m:
            status = m.group(1)
        if status.upper() != "COMPLETED":
            plans.append({
                "name": f.stem.replace("_", " ").replace("-", " ").title(),
                "file": str(f.relative_to(root)),
                "status": status,
                "date": datetime.fromtimestamp(f.stat().st_mtime).strftime("%Y-%m-%d"),
            })
    return plans[:5]


def get_git_activity(root):
    """Get recent git log."""
    try:
        result = subprocess.run(
            ["git", "log", "--oneline", "-15", "--format=%h|%ai|%s"],
            capture_output=True, text=True, cwd=root, timeout=5,
        )
        commits = []
        for line in result.stdout.strip().split("\n"):
            if "|" in line:
                parts = line.split("|", 2)
                if len(parts) == 3:
                    commits.append({"hash": parts[0], "date": parts[1][:10], "message": parts[2]})
        return commits
    except Exception:
        return []


# ---------- HTML Builder ----------

def is_placeholder(text):
    return not text or text.startswith("[") or text.startswith("YOUR") or "--" in text


def score_color(score):
    if score is None:
        return "var(--g500)"
    if score >= 90:
        return "var(--accept)"
    if score >= 80:
        return "var(--minor-rev)"
    if score >= 65:
        return "var(--major-rev)"
    return "var(--reject)"


def score_pill_class(score):
    if score is None:
        return "pill-neutral"
    if score >= 90:
        return "pill-accept"
    if score >= 80:
        return "pill-minor"
    if score >= 65:
        return "pill-major"
    return "pill-reject"


def status_pill_class(status):
    s = (status or "").upper()
    if s in ("PASS", "ACCEPT", "ACCEPTED", "COMPLETED"):
        return "pill-pass"
    if s in ("WARN", "MINOR", "MINOR REVISIONS", "IN PROGRESS", "DRAFT"):
        return "pill-warn"
    if s in ("FAIL", "REJECT", "REJECTED", "BLOCKED", "MAJOR", "MAJOR REVISIONS"):
        return "pill-fail"
    return "pill-neutral"


def type_pill_class(report_type):
    return {
        "peer-review": "pill-accent",
        "editorial": "pill-accent",
        "code-audit": "pill-r",
        "strategy-review": "pill-warn",
        "quality-gate": "pill-neutral",
        "session": "pill-neutral",
        "plan": "pill-neutral",
    }.get(report_type, "pill-neutral")


def lang_pill_class(lang):
    return {"R": "pill-r", "Python": "pill-python", "Julia": "pill-julia"}.get(lang, "pill-neutral")


def build_header(meta, stats):
    raw_title = meta["title"]
    title = escape(raw_title) if not is_placeholder(raw_title) else "Research Project"
    inst = escape(meta["institution"]) if not is_placeholder(meta["institution"]) else ""
    field = escape(meta["field"]) if not is_placeholder(meta["field"]) else ""

    status_pills = ""
    for comp, info in meta.get("status", {}).items():
        st = info.get("status", "")
        if st and not is_placeholder(st):
            cls = status_pill_class(st)
            status_pills += f'<span class="pill {cls}">{escape(comp)}: {escape(st)}</span> '

    stats_html = ""
    for label, val in stats:
        stats_html += f"""
      <div class="stat-card">
        <div class="stat-number">{val}</div>
        <div class="stat-label">{escape(label)}</div>
      </div>"""

    subtitle_parts = [x for x in [inst, field] if x]
    subtitle = " &middot; ".join(subtitle_parts) if subtitle_parts else ""

    return f"""
    <header style="padding-bottom:24px;border-bottom:1.5px solid var(--g300);margin-bottom:8px">
      <div class="eyebrow">Project Dashboard</div>
      <div class="flex-between" style="align-items:flex-start">
        <div>
          <h1>{title}</h1>
          {"<p style='color:var(--g500);font-size:14px;margin-top:4px'>" + subtitle + "</p>" if subtitle else ""}
        </div>
        <div class="toolbar">
          <button class="toolbar-btn" id="dark-toggle">Dark</button>
          <button class="toolbar-btn" id="print-btn">Print</button>
        </div>
      </div>
      {('<div style="margin-top:12px">' + status_pills + '</div>') if status_pills else ''}
      <div class="stats-row">{stats_html}</div>
    </header>"""


def build_nav():
    links = [
        ("sections", "Sections"), ("data", "Data"), ("code", "Code"),
        ("literature", "Literature"), ("quality", "Quality"),
        ("history", "History"), ("plans", "Plans"),
    ]
    items = "".join(f'<a class="nav-link" href="#{k}">{v}</a>' for k, v in links)
    return f'<nav class="nav-bar">{items}</nav>'


def build_sections_panel(sections):
    if not sections:
        return """
    <section id="sections">
      <h2>Paper Sections</h2>
      <div class="empty-state">
        No sections found yet.<br>
        Create <code>.tex</code> files in <code>paper/sections/</code> or add <code>\\input{}</code> to <code>main.tex</code>.
      </div>
    </section>"""

    total_words = sum(s["words"] for s in sections)
    rows = ""
    for s in sections:
        rows += f"""
        <tr>
          <td style="font-family:var(--serif);font-weight:500;color:var(--slate)">{escape(s['name'])}</td>
          <td><span class="mono" style="font-size:11px;color:var(--g500)">{escape(s['file'])}</span></td>
          <td class="text-right"><span class="mono">{s['words']:,}</span></td>
          <td class="text-right" style="color:var(--g500);font-size:12px">{s['modified']}</td>
        </tr>"""

    return f"""
    <section id="sections">
      <h2>Manuscript &nbsp;<span style="font-family:var(--mono);font-size:13px;color:var(--g500);font-weight:400">{len(sections)} sections &middot; {total_words:,} words</span></h2>
      <table class="report-table">
        <thead><tr><th>Section</th><th>File</th><th class="text-right">Words</th><th class="text-right">Modified</th></tr></thead>
        <tbody>{rows}</tbody>
      </table>
    </section>"""


def build_data_panel(data, pipelines=None):
    has_raw = len(data["raw"]) > 0
    has_cleaned = len(data["cleaned"]) > 0
    if not has_raw and not has_cleaned and not pipelines:
        return """
    <section id="data">
      <h2>Data</h2>
      <div class="empty-state">
        No data files found yet.<br>
        Add datasets to <code>data/raw/</code> or <code>data/cleaned/</code>.
      </div>
    </section>"""

    if has_cleaned:
        stage_cls, stage_label = "pill-pass", "Analysis-Ready"
    elif has_raw:
        stage_cls, stage_label = "pill-warn", "Raw Only"
    else:
        stage_cls, stage_label = "pill-neutral", "Empty"

    # --- Pipeline subsection (rendered first, above file listing) ---
    pipeline_html = ""
    if pipelines:
        for p in pipelines:
            name = escape(p.get("name", "Untitled"))
            desc = escape(p.get("description", ""))
            created = p.get("created", "")[:10]
            script = escape(p.get("script", ""))
            output = p.get("output", {})
            sources = p.get("sources", [])
            diag = p.get("diagnostics", {})
            flags = diag.get("flags", [])

            out_rows = f"{output.get('rows', '?'):,}" if isinstance(output.get('rows'), int) else str(output.get('rows', '?'))
            out_counties = f"{output.get('counties', '?'):,}" if isinstance(output.get('counties'), int) else str(output.get('counties', '?'))
            out_years = output.get("years", [])
            years_str = ", ".join(str(y) for y in out_years) if out_years else "?"

            source_cards = ""
            for s in sources:
                s_name = escape(s.get("name", ""))
                s_key = escape(s.get("merge_key", ""))
                s_cov = escape(s.get("coverage", ""))
                s_vars = s.get("variables_contributed", [])
                vars_html = ", ".join(f"<code>{escape(v)}</code>" for v in s_vars[:6])
                if len(s_vars) > 6:
                    vars_html += f" +{len(s_vars) - 6} more"
                source_cards += f"""
              <div class="pipeline-source">
                <div style="font-weight:500;color:var(--slate);font-size:13px;margin-bottom:4px">{s_name}</div>
                <div style="font-size:12px;color:var(--g600);margin-bottom:2px"><strong>Key:</strong> {s_key}</div>
                <div style="font-size:12px;color:var(--g600);margin-bottom:2px"><strong>Coverage:</strong> {s_cov}</div>
                <div style="font-size:11px;color:var(--g500)">{vars_html}</div>
              </div>"""

            flags_html = ""
            for fl in flags:
                sev = fl.get("severity", "info")
                msg = escape(fl.get("message", ""))
                cls = "alert-danger" if sev == "error" else "alert-warning" if sev == "warning" else "alert-info"
                icon = "&#9888;" if sev in ("error", "warning") else "&#8505;"
                flags_html += f'<div class="alert {cls}" style="font-size:12px;margin-top:8px">{icon} {msg}</div>'

            cov_by_year = diag.get("coverage_by_year", [])
            cov_rows = ""
            for c in cov_by_year:
                yr = c.get("year", "")
                n = c.get("n_counties", 0)
                e = c.get("has_erosion", 0)
                ch = c.get("has_church", 0)
                v = c.get("has_voting", 0)
                gop = c.get("mean_gop")
                gop_str = f"{gop:.1%}" if gop is not None else "&mdash;"
                evan = c.get("mean_evan_rate")
                evan_str = f"{evan:.0f}" if evan is not None else "&mdash;"
                cov_rows += f"""
                <tr>
                  <td class="mono">{yr}</td>
                  <td class="text-right">{n:,}</td>
                  <td class="text-right">{e:,}</td>
                  <td class="text-right">{ch:,}</td>
                  <td class="text-right">{v:,}</td>
                  <td class="text-right mono" style="font-size:12px">{gop_str}</td>
                  <td class="text-right mono" style="font-size:12px">{evan_str}</td>
                </tr>"""

            cov_table = ""
            if cov_rows:
                cov_table = f"""
            <h3 style="margin-top:20px">Coverage by Year</h3>
            <table class="report-table" style="font-size:13px">
              <thead><tr>
                <th>Year</th><th class="text-right">Counties</th>
                <th class="text-right">Erosion</th><th class="text-right">Church</th>
                <th class="text-right">Voting</th><th class="text-right">Mean GOP</th>
                <th class="text-right">Evan/1k</th>
              </tr></thead>
              <tbody>{cov_rows}</tbody>
            </table>"""

            db = diag.get("dust_bowl", {})
            db_html = ""
            if db:
                ed = db.get("erosion_distribution", {})
                db_html = f"""
            <h3 style="margin-top:20px">Dust Bowl Region</h3>
            <div class="grid-3" style="gap:12px;margin-bottom:12px">
              <div class="card" style="text-align:center;margin-bottom:0;padding:12px">
                <div style="font-size:22px;font-family:var(--mono);font-weight:600;color:var(--slate)">{db.get('counties', 0):,}</div>
                <div style="font-size:11px;color:var(--g500)">DB counties</div>
              </div>
              <div class="card" style="text-align:center;margin-bottom:0;padding:12px">
                <div style="font-size:22px;font-family:var(--mono);font-weight:600;color:var(--slate)">{db.get('with_church', 0):,}</div>
                <div style="font-size:11px;color:var(--g500)">with church data</div>
              </div>
              <div class="card" style="text-align:center;margin-bottom:0;padding:12px">
                <div style="font-size:22px;font-family:var(--mono);font-weight:600;color:var(--slate)">{db.get('with_voting', 0):,}</div>
                <div style="font-size:11px;color:var(--g500)">with voting data</div>
              </div>
            </div>
            <div style="display:flex;gap:16px;justify-content:center;font-size:13px">
              <span><span class="pill pill-reject" style="font-size:10px">High</span> {ed.get('high', 0)} counties</span>
              <span><span class="pill pill-warn" style="font-size:10px">Medium</span> {ed.get('medium', 0)} counties</span>
              <span><span class="pill pill-pass" style="font-size:10px">Low</span> {ed.get('low', 0)} counties</span>
            </div>"""

            pipeline_html += f"""
      <div class="card" style="margin-bottom:20px">
        <div class="flex-between" style="margin-bottom:12px">
          <div>
            <span style="font-family:var(--serif);font-weight:600;font-size:16px;color:var(--slate)">{name}</span>
            <span class="mono" style="font-size:11px;color:var(--g500);margin-left:8px">{created}</span>
          </div>
          <span class="pill pill-pass">Active</span>
        </div>
        <p style="color:var(--g700);font-size:13px;margin-bottom:12px">{desc}</p>

        <div class="grid-3" style="gap:12px;margin-bottom:16px">
          <div class="card" style="text-align:center;margin-bottom:0;padding:12px;background:var(--g100)">
            <div style="font-size:22px;font-family:var(--mono);font-weight:600;color:var(--slate)">{out_rows}</div>
            <div style="font-size:11px;color:var(--g500)">county-years</div>
          </div>
          <div class="card" style="text-align:center;margin-bottom:0;padding:12px;background:var(--g100)">
            <div style="font-size:22px;font-family:var(--mono);font-weight:600;color:var(--slate)">{out_counties}</div>
            <div style="font-size:11px;color:var(--g500)">counties</div>
          </div>
          <div class="card" style="text-align:center;margin-bottom:0;padding:12px;background:var(--g100)">
            <div style="font-size:22px;font-family:var(--mono);font-weight:600;color:var(--slate)">{len(out_years)}</div>
            <div style="font-size:11px;color:var(--g500)">years</div>
          </div>
        </div>

        <h3>Sources &rarr; Merge</h3>
        <div class="pipeline-flow">{source_cards}
          <div class="pipeline-arrow">&rarr;</div>
          <div class="pipeline-output">
            <div style="font-weight:500;color:var(--slate);font-size:13px;margin-bottom:4px">Output</div>
            <div style="font-size:12px;color:var(--g600)"><code>{escape(', '.join(output.get('files', [])))}</code></div>
            <div style="font-size:11px;color:var(--g500);margin-top:4px">Key: <code>{escape(', '.join(output.get('key', [])))}</code></div>
          </div>
        </div>
        <div style="font-size:11px;color:var(--g500);margin-top:8px">Script: <code>{script}</code> &middot; Years: {years_str}</div>

        {flags_html}
        {cov_table}
        {db_html}
      </div>"""

    # --- File listing ---
    rows = ""
    for sub, files in [("raw", data["raw"]), ("cleaned", data["cleaned"])]:
        for f in files:
            rows += f"""
        <tr>
          <td><span class="pill pill-neutral" style="font-size:9px">{sub}</span> &nbsp;{escape(f['name'])}</td>
          <td class="text-right"><span class="mono" style="font-size:12px">{f['size']}</span></td>
          <td class="text-right" style="color:var(--g500);font-size:12px">{f['modified']}</td>
        </tr>"""

    total = len(data["raw"]) + len(data["cleaned"])
    return f"""
    <section id="data">
      <h2>Data &nbsp;<span class="pill {stage_cls}">{stage_label}</span></h2>
      {pipeline_html}
      <h3 style="margin-top:24px">Files</h3>
      <p style="color:var(--g500);font-size:13px">{len(data['raw'])} raw, {len(data['cleaned'])} cleaned &mdash; {total} total files</p>
      <table class="report-table">
        <thead><tr><th>File</th><th class="text-right">Size</th><th class="text-right">Modified</th></tr></thead>
        <tbody>{rows}</tbody>
      </table>
    </section>"""


def build_code_panel(scripts_list):
    if not scripts_list:
        return """
    <section id="code">
      <h2>Analysis Code</h2>
      <div class="empty-state">
        No analysis scripts found yet.<br>
        Add <code>.R</code>, <code>.py</code>, or <code>.jl</code> files to <code>scripts/</code>.
      </div>
    </section>"""

    rows = ""
    for s in scripts_list:
        lcls = lang_pill_class(s["lang"])
        purpose = escape(s["purpose"]) if s["purpose"] and '"""' not in s["purpose"] else ""
        rows += f"""
        <tr>
          <td style="font-weight:500;color:var(--slate)">{escape(s['name'])}</td>
          <td><span class="pill {lcls}">{s['lang']}</span></td>
          <td style="color:var(--g700);font-size:13px">{purpose}</td>
        </tr>"""

    langs = set(s["lang"] for s in scripts_list)
    lang_str = ", ".join(sorted(langs))
    return f"""
    <section id="code">
      <h2>Analysis Code &nbsp;<span style="font-family:var(--mono);font-size:13px;color:var(--g500);font-weight:400">{len(scripts_list)} scripts &middot; {lang_str}</span></h2>
      <table class="report-table">
        <thead><tr><th>Script</th><th>Lang</th><th>Purpose</th></tr></thead>
        <tbody>{rows}</tbody>
      </table>
    </section>"""


def build_literature_panel(lit):
    if not lit:
        return """
    <section id="literature">
      <h2>Literature</h2>
      <div class="empty-state">
        No literature review found yet.<br>
        Run <code>/discover lit [topic]</code> to search the literature.
      </div>
    </section>"""

    return f"""
    <section id="literature">
      <h2>Literature &nbsp;<span style="font-family:var(--mono);font-size:13px;color:var(--g500);font-weight:400">{lit['count']} papers</span></h2>
      <p style="color:var(--g500);font-size:13px">Source: <span class="mono">{escape(lit['dir'])}</span></p>
      <div class="card" style="text-align:center;color:var(--g700)">
        <p style="font-size:26px;font-family:var(--mono);font-weight:600;color:var(--slate);margin-bottom:4px">{lit['count']}</p>
        <p style="font-size:13px;color:var(--g500);margin-bottom:12px">papers catalogued</p>
        <p style="font-size:13px">Run <code>python3 scripts/generate_html_report.py literature</code> for the full interactive bibliography.</p>
      </div>
    </section>"""


def build_quality_panel(gate):
    if not gate:
        return """
    <section id="quality">
      <h2>Quality Scorecard</h2>
      <div class="empty-state">
        No quality gate summary found yet.<br>
        Run <code>/review --all</code> to generate component scores.
      </div>
    </section>"""

    overall = gate.get("overall")
    result = gate.get("result", "")
    result_cls = status_pill_class(result)
    gauge_color = score_color(overall)

    gauge_html = f"""
    <div class="score-gauge">
      <div class="score-gauge-number" style="color:{gauge_color}">{overall:.1f}</div>
      <div class="score-gauge-label">weighted aggregate</div>
    </div>"""

    gates_html = '<div style="max-width:600px;margin:0 auto 24px">'
    for label, threshold in [("Commit", 80), ("PR", 90), ("Submission", 95)]:
        pct = min((overall or 0) / threshold * 100, 100)
        color = "var(--accept)" if (overall or 0) >= threshold else "var(--reject)"
        passed = "PASS" if (overall or 0) >= threshold else "FAIL"
        pcls = "pill-pass" if passed == "PASS" else "pill-fail"
        gates_html += f"""
      <div class="gate-row">
        <span class="gate-label">{label} &ge;{threshold}</span>
        <div class="gate-track">
          <div class="gate-fill" style="width:{pct:.0f}%;background:{color}"></div>
        </div>
        <span class="gate-value">{overall:.1f}</span>
        <span class="pill {pcls}">{passed}</span>
      </div>"""
    gates_html += "</div>"

    blocking_html = ""
    if gate.get("blocking"):
        items = "".join(f"<li style='margin-bottom:4px'>{escape(b)}</li>" for b in gate["blocking"])
        blocking_html = f'<div class="alert alert-danger" style="margin-bottom:20px"><strong>Blocking issues:</strong><ul style="margin:8px 0 0 20px;padding:0">{items}</ul></div>'

    report_link_map = {
        "literature coverage": "quality_reports/reviews/{date}_lit_review.html",
        "data quality": "quality_reports/reviews/{date}_data_assessment.html",
        "identification validity": "quality_reports/reviews/{date}_strategy_review.html",
        "code quality": "quality_reports/reviews/{date}_code_audit.html",
        "paper quality": "quality_reports/reviews/{date}_peer_review.html",
        "manuscript polish": "quality_reports/reviews/{date}_proofread.html",
        "replication readiness": "quality_reports/reviews/{date}_replication.html",
    }

    comp_html = '<div class="grid-2">'
    for c in gate.get("components", []):
        color = score_color(c["score"])
        scls = score_pill_class(c["score"])
        pct = c["score"]

        link_key = c["name"].lower()
        link_href = report_link_map.get(link_key, "")

        card_inner = f"""
        <div class="card" style="margin-bottom:0">
          <div class="flex-between" style="margin-bottom:8px">
            <div>
              <span style="font-family:var(--serif);font-weight:500;color:var(--slate);font-size:14px">{escape(c['name'])}</span>
              <span style="font-family:var(--mono);font-size:11px;color:var(--g500)">{c['weight']}%</span>
            </div>
            <span class="pill {scls}">{c['score']}</span>
          </div>
          <div class="score-bar-track">
            <div class="score-bar-fill" style="width:{pct}%;background:{color}"></div>
          </div>
          <div style="font-family:var(--mono);font-size:11px;color:var(--g500);margin-top:6px">{escape(c['agent'])}</div>
        </div>"""

        if link_href:
            comp_html += f'<a class="card-link" href="{link_href}" title="View {escape(c["name"])} report">{card_inner}</a>'
        else:
            comp_html += card_inner
    comp_html += "</div>"

    return f"""
    <section id="quality">
      <h2>Quality Scorecard &nbsp;<span class="pill {result_cls}">{escape(result)}</span></h2>
      {gauge_html}
      {gates_html}
      {blocking_html}
      <h3>Components</h3>
      {comp_html}
    </section>"""


def build_history_panel(reports):
    reviews = [r for r in reports if r["type"] not in ("plan",)]
    if not reviews:
        return """
    <section id="history">
      <h2>Review History</h2>
      <div class="empty-state">No reviews or sessions logged yet.</div>
    </section>"""

    items = ""
    for r in reviews[:15]:
        tcls = type_pill_class(r["type"])
        score_str = ""
        if r["score"] is not None:
            scls = score_pill_class(r["score"])
            score_str = f' <span class="pill {scls}">{r["score"]}</span>'
        verdict_str = ""
        if r["verdict"]:
            verdict_str = f' <span style="color:var(--g500);font-size:12px">&mdash; {escape(r["verdict"])}</span>'

        type_label = r["type"].replace("-", " ").title()
        file_link = r.get("file", "")
        title_html = f'<a href="{escape(file_link)}" style="color:var(--slate);text-decoration:none">{escape(r["name"])}</a>' if file_link else escape(r["name"])
        items += f"""
      <div class="timeline-item">
        <div class="timeline-date">{r['date']}</div>
        <div class="timeline-title">{title_html}</div>
        <div>
          <span class="pill {tcls}">{escape(type_label)}</span>{score_str}{verdict_str}
        </div>
      </div>"""

    return f"""
    <section id="history">
      <h2>History &nbsp;<span style="font-family:var(--mono);font-size:13px;color:var(--g500);font-weight:400">{len(reviews)} entries</span></h2>
      <div class="timeline">{items}</div>
    </section>"""


def build_plans_panel(plans):
    if not plans:
        return """
    <section id="plans">
      <h2>Active Plans</h2>
      <div class="empty-state">
        No active plans.<br>
        Run <code>/strategize</code> or enter plan mode to create one.
      </div>
    </section>"""

    cards = ""
    for p in plans:
        scls = status_pill_class(p["status"])
        cards += f"""
      <div class="card">
        <div class="flex-between" style="margin-bottom:4px">
          <span style="font-family:var(--serif);font-weight:500;color:var(--slate);font-size:15px">{escape(p['name'])}</span>
          <span class="pill {scls}">{escape(p['status'])}</span>
        </div>
        <div style="font-family:var(--mono);font-size:11px;color:var(--g500)">{p['date']} &middot; {escape(p['file'])}</div>
      </div>"""

    return f"""
    <section id="plans">
      <h2>Active Plans &nbsp;<span style="font-family:var(--mono);font-size:13px;color:var(--g500);font-weight:400">{len(plans)}</span></h2>
      {cards}
    </section>"""


def build_dashboard(root):
    """Assemble the full dashboard HTML."""
    meta = scan_metadata(root)
    sections = scan_sections(root)
    data = scan_data(root)
    scripts_list = scan_scripts(root)
    pipelines = scan_pipelines(root)
    n_figs, n_tabs = scan_figures_tables(root)
    n_bib = scan_bibliography(root)
    reports, gate = scan_quality_reports(root)
    lit = scan_literature(root)
    plans = scan_plans(root)

    stats = [
        ("sections", str(len(sections))),
        ("scripts", str(len(scripts_list))),
        ("references", str(n_bib)),
        ("figures", str(n_figs)),
        ("tables", str(n_tabs)),
    ]

    # Load base CSS and JS
    base_dir = Path(__file__).resolve().parent.parent / "templates" / "html" / "base"
    css = ""
    js = ""
    if (base_dir / "styles.css").exists():
        css = (base_dir / "styles.css").read_text()
    if (base_dir / "components.js").exists():
        js = (base_dir / "components.js").read_text()

    # Build JSON data block
    dashboard_data = {
        "type": "dashboard",
        "generated": datetime.now().isoformat()[:19],
        "project": meta["title"],
        "sections": len(sections),
        "scripts": len(scripts_list),
        "references": n_bib,
        "figures": n_figs,
        "tables": n_tabs,
        "overall_score": gate["overall"] if gate else None,
        "gate_result": gate["result"] if gate else None,
    }

    panels = [
        build_header(meta, stats),
        build_nav(),
        build_sections_panel(sections),
        build_data_panel(data, pipelines),
        build_code_panel(scripts_list),
        build_literature_panel(lit),
        build_quality_panel(gate),
        build_history_panel(reports),
        build_plans_panel(plans),
    ]

    generated = datetime.now().strftime("%Y-%m-%d %H:%M")
    body = "\n".join(panels)

    return f"""<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>{escape(meta['title'] or 'Project Dashboard')} — Dashboard</title>
  <style>{css}</style>
</head>
<body>
  <script type="application/json" id="report-data">{json.dumps(dashboard_data, indent=None)}</script>
  <div class="page">
    {body}
    <footer class="generated-footer">
      Generated {generated} by clo-author &middot; <a href="https://github.com/hugosantanna/clo-author">github.com/hugosantanna/clo-author</a>
    </footer>
  </div>
  <script>{js}</script>
</body>
</html>"""


def main():
    parser = argparse.ArgumentParser(description="Generate clo-author project dashboard")
    parser.add_argument("--project-root", default=".", help="Project root directory")
    parser.add_argument("--output", default=None, help="Output HTML file path")
    args = parser.parse_args()

    root = find_project_root(args.project_root)
    output = Path(args.output) if args.output else root / "project_dashboard.html"

    html = build_dashboard(root)
    output.write_text(html)
    print(f"Dashboard generated: {output}")


if __name__ == "__main__":
    main()

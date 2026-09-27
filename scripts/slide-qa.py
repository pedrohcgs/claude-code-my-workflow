#!/usr/bin/env python3
"""Measure a rendered Quarto (Reveal.js) deck in a real browser.

Reading a .qmd can only guess at overflow. This loads the rendered HTML in
headless Chrome, visits every slide (uncounted ones too), and measures what a
reader sees — text lines, formulas, images, widgets, chunk output, and boxes
that paint a background or border — against the slide box, in every fragment
state and every tab of a panel-tabset. It reports what spills past an edge and
what is cut off inside a scrolling element (a code block that scrolls sideways,
a scrollable slide), and saves one screenshot per slide for a reviewer to read.

Usage (the skills call it through SLIDE_QA_PYTHON, see below):
    ${SLIDE_QA_PYTHON:-python3} scripts/slide-qa.py Quarto/Lecture1.html
    ${SLIDE_QA_PYTHON:-python3} scripts/slide-qa.py Quarto/Lecture1.qmd   # uses the sibling .html
    ${SLIDE_QA_PYTHON:-python3} scripts/slide-qa.py deck.html --out DIR --tolerance 2 --no-screenshots

Needs Python Playwright. A Homebrew or system Python refuses a plain
`pip install`, so use a virtual environment and point SLIDE_QA_PYTHON at it:
    python3 -m venv ~/.venvs/slide-qa && ~/.venvs/slide-qa/bin/pip install playwright
    export SLIDE_QA_PYTHON=~/.venvs/slide-qa/bin/python
It drives your installed Google Chrome, so no browser download is needed;
without Chrome, run `$SLIDE_QA_PYTHON -m playwright install chromium`.

Writes report.json, report.md and slide-NN.png to
quality_reports/audits/slide-qa/<deck>/ (gitignored) unless --out is given. The
previous run's files are removed first, so a report on disk is always this
run's.

It also reports broken images, local files the deck asks for that are missing, and local
files found only because the filesystem ignores letter case (they break on GitHub Pages).

Exit: 0 clean, 1 overflow, clipped content, a broken image or a missing/wrong-case file, 2 could not run.
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import unicodedata
from urllib.parse import urlparse
from urllib.request import url2pathname
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent   # resolved before anything else runs

# Runs in the page for the current slide. Distances are in slide pixels (the
# deck's configured width/height), so the numbers mean the same thing at any
# window size. Returns every offender; the caller merges states and keeps three.
MEASURE_JS = r"""
(tol) => {
  const slidesEl = document.querySelector('.reveal .slides');
  const cfg = Reveal.getConfig();
  const box = slidesEl.getBoundingClientRect();
  const scale = (typeof cfg.width === 'number' && cfg.width > 0) ? box.width / cfg.width : 1;
  const cur = Reveal.getCurrentSlide();
  const clean = s => (s || '').replace(/\s+/g, ' ').trim().slice(0, 60);
  const label = el => {
    const cls = (typeof el.className === 'string' && el.className.trim())
      ? '.' + el.className.trim().split(/\s+/).slice(0, 2).join('.') : '';
    return el.tagName.toLowerCase() + cls;
  };
  // Measure what a reader SEES, not layout boxes: a block's box is often wider
  // than its text (a centred title), and math engines lay formulas out with
  // internal boxes that are not the rendered formula. So: text is measured by
  // its line boxes; a formula, image, SVG or widget is measured as one box and
  // never entered; an element that clips or scrolls is measured by its own box
  // (that box is exactly what shows); anything else counts only if it paints.
  // Formula boxes: MathJax 2 HTML-CSS draws into the inline-block `.math` inside
  // `.MathJax > nobr` (the `.MathJax` span itself is inline, one line tall);
  // MathJax 3 into `mjx-math` or an svg; KaTeX into `.katex-html`, measured by
  // its scroll extent (see inkRect).
  const ATOMIC = '.MathJax > nobr > .math, .MathJax_SVG, .MathJax_CHTML, mjx-math, mjx-container > svg, '
               + '.katex-html, svg, img, canvas, video, iframe, object, embed, .html-widget, .js-plotly-plot';
  const SKIP_TAGS = new Set(['script', 'style', 'noscript', 'template']);
  const CLIPS = v => v === 'auto' || v === 'scroll' || v === 'hidden' || v === 'clip';
  const clipsOf = cs => CLIPS(cs.overflowX) || CLIPS(cs.overflowY);
  const hiddenBy = cs => (cs.clip && cs.clip !== 'auto') || (cs.clipPath && cs.clipPath !== 'none');
  const shown = cs => cs.display !== 'none' && cs.visibility !== 'hidden' && parseFloat(cs.opacity) !== 0;
  const alpha = c => { const m = /rgba?\(([^)]*)\)/.exec(c || ''); if (!m) return c && c !== 'transparent' ? 1 : 0;
                       const p = m[1].split(/[\s,\/]+/).filter(Boolean); return p.length > 3 ? parseFloat(p[3]) : 1; };
  const paints = cs => alpha(cs.backgroundColor) > 0 || (cs.backgroundImage && cs.backgroundImage !== 'none')
    || ['Top', 'Right', 'Bottom', 'Left'].some(s => parseFloat(cs['border' + s + 'Width']) > 0
                                                 && cs['border' + s + 'Style'] !== 'none');
  const inkRect = el => {
    const r = el.getBoundingClientRect();
    if (!el.matches('.katex-html')) return r;
    // A KaTeX block is as wide as its container; a formula wider than that
    // spills out of it, and only the scroll extent records how far.
    const w = Math.max(r.width, el.scrollWidth * scale), h = Math.max(r.height, el.scrollHeight * scale);
    return {left: r.left, top: r.top, right: r.left + w, bottom: r.top + h, width: w, height: h};
  };
  const curCS = getComputedStyle(cur);
  const curClips = clipsOf(curCS);            // a .scrollable slide scrolls its own content
  // Coverage of a node from the elements between it and the slide:
  // bit 1 = an ancestor (or the slide itself) clips or scrolls: the clipping
  //         element's box is measured for edges, and content hidden inside it is
  //         reported on the element that scrolls;
  // bit 2 = inside something measured whole or never shown (formula, image,
  //         visually-hidden helper, script) — not measured at all.
  const cache = new Map();
  const covered = node => {
    const p = node.parentElement;
    if (!p || p === cur) return curClips ? 1 : 0;
    if (cache.has(p)) return cache.get(p);
    const ps = getComputedStyle(p);
    let v = covered(p);
    if (clipsOf(ps)) v |= 1;
    if (hiddenBy(ps) || p.matches(ATOMIC) || p.matches('aside.notes') || SKIP_TAGS.has(p.tagName.toLowerCase())) v |= 2;
    cache.set(p, v);
    return v;
  };
  const edges = {bottom: 0, right: 0, top: 0, left: 0};
  const over = [], clipped = [];
  const measure = (r, what, text) => {
    if (r.width <= 1 && r.height <= 1) return;
    const d = {bottom: (r.bottom - box.bottom) / scale, right: (r.right - box.right) / scale,
               top: (box.top - r.top) / scale, left: (box.left - r.left) / scale};
    let worst = 0;
    for (const k in d) { if (d[k] > edges[k]) edges[k] = d[k]; if (d[k] > worst) worst = d[k]; }
    if (worst > tol) over.push({element: what, text, by_px: Math.round(worst * 10) / 10});
  };
  const hiddenInside = (el, cs) => {
    const dx = el.scrollWidth - el.clientWidth, dy = el.scrollHeight - el.clientHeight;
    if (dx > tol + 1 || dy > tol + 1) {
      clipped.push({element: label(el), text: clean(el.innerText), hidden_x: dx, hidden_y: dy});
    }
  };
  if (curClips) hiddenInside(cur, curCS);
  for (const el of cur.querySelectorAll('*')) {
    const cov = covered(el);
    if (cov & 2) continue;
    const tag = el.tagName.toLowerCase();
    if (SKIP_TAGS.has(tag) || el.matches('aside.notes')) continue;
    const cs = getComputedStyle(el);
    if (!shown(cs) || hiddenBy(cs)) continue;             // visually hidden (e.g. a formula's a11y copy)
    const atomic = el.matches(ATOMIC), clips = !atomic && clipsOf(cs);
    if (!(cov & 1) && (atomic || clips || paints(cs))) {
      measure(inkRect(el), label(el), clean(el.innerText || el.getAttribute('alt') || ''));
    }
    if (clips) hiddenInside(el, cs);
  }
  const walker = document.createTreeWalker(cur, NodeFilter.SHOW_TEXT);
  const range = document.createRange();
  for (let t = walker.nextNode(); t; t = walker.nextNode()) {
    if (!/\S/.test(t.nodeValue) || covered(t)) continue;   // inside a clipper: reported as clipped instead
    const p = t.parentElement;
    const ps = getComputedStyle(p);
    if (!shown(ps)) continue;
    range.selectNodeContents(t);
    const r = range.getBoundingClientRect(), lines = range.getClientRects();
    // A text rect is the font's content area, which overhangs a tight line box
    // (a heading at line-height 1 reads a few px past the top with no ink
    // there). Trim it to the line box the layout reserves.
    const lh = parseFloat(ps.lineHeight) * scale;
    const inset = (lines.length && lh > 0) ? Math.max(0, (lines[0].height - lh) / 2) : 0;
    measure({left: r.left, right: r.right, top: r.top + inset, bottom: r.bottom - inset,
             width: r.width, height: Math.max(0, r.height - 2 * inset)}, label(p), clean(t.nodeValue));
  }
  over.sort((a, b) => b.by_px - a.by_px);
  const title = (cur.querySelector('h1, h2, h3') || {}).innerText || '';
  for (const k in edges) edges[k] = Math.round(edges[k] * 10) / 10;
  return {title: title.replace(/\s+/g, ' ').trim().slice(0, 70), overflow: edges, offenders: over, clipped};
}
"""

# Readiness: math engines typeset after load (MathJax 2, Quarto's default, only
# once its async script arrives), so wait for the engine that is actually used,
# then fonts and eagerly loaded images. Every wait is bounded. Returns which
# math engine rendered, or "not-typeset" when a deck has math nothing rendered.
READY_JS = r"""
async () => {
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  const bounded = (p, ms) => Promise.race([Promise.resolve(p).catch(() => {}), sleep(ms)]);
  const hasMath = !!document.querySelector('.math, script[type^="math/tex"], mjx-container, .katex');
  const engine = () => window.MathJax && MathJax.Hub ? 'mathjax2'
                     : window.MathJax && MathJax.startup ? 'mathjax3'
                     : (window.katex || document.querySelector('.katex')) ? 'katex' : null;
  if (hasMath) { for (let i = 0; i < 100 && !engine(); i++) await sleep(100); }
  if (window.MathJax && MathJax.startup && MathJax.startup.promise) await bounded(MathJax.startup.promise, 20000);
  if (window.MathJax && MathJax.Hub && MathJax.Hub.Queue) {
    for (let k = 0; k < 2; k++) {                 // after any Typeset the page queued
      await bounded(new Promise(r => MathJax.Hub.Queue(r)), 20000);
      await sleep(100);
    }
  }
  if (document.fonts && document.fonts.ready) await bounded(document.fonts.ready, 10000);
  await bounded(Promise.all([...document.images].filter(i => i.getAttribute('src') && !i.complete)
    .map(i => new Promise(res => { i.onload = i.onerror = res; }))), 15000);
  Reveal.layout();
  return hasMath ? (engine() || 'not-typeset') : 'none';
}
"""

# Freeze the deck in one state: no slide or background transitions (a deck
# default or a per-slide data-transition would otherwise be measured
# mid-animation), no auto-animate, every fragment applied, no chrome.
SETUP_JS = r"""
() => {
  document.querySelectorAll('.reveal .slides section').forEach(s => {
    s.setAttribute('data-transition', 'none');
    s.removeAttribute('data-transition-speed');
    s.setAttribute('data-background-transition', 'none');
  });
  // Fragments animate their own opacity (0.2s): without this, forcing them
  // visible — or restoring them for the screenshot — is read mid-animation.
  document.querySelectorAll('.reveal .slides section .fragment')
    .forEach(f => f.style.setProperty('transition', 'none', 'important'));
  Reveal.configure({transition: 'none', backgroundTransition: 'none', autoAnimate: false,
                    fragments: false, controls: false, progress: false});
  Reveal.layout();
}
"""

# Every leaf slide, counted or not: Reveal.getSlides() drops slides marked
# visibility="uncounted", which is exactly where appendix material hides.
GOTO_JS = r"""
async (i) => {
  const s = document.querySelectorAll('.reveal .slides section:not(.stack)')[i];
  const x = Reveal.getIndices(s);
  Reveal.slide(x.h, x.v);
  // Lazily loaded media (data-src) must be loaded before it can be measured.
  const imgs = [...s.querySelectorAll('img')];
  for (const img of imgs) if (!img.getAttribute('src') && img.dataset && img.dataset.src) img.src = img.dataset.src;
  const sleep = ms => new Promise(r => setTimeout(r, ms));
  await Promise.race([Promise.all(imgs.filter(img => !img.complete).map(img => new Promise(r => {
    img.addEventListener('load', r, {once: true}); img.addEventListener('error', r, {once: true}); }))), sleep(8000)]);
  await new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)));
  return {h: x.h, v: x.v || 0, unloaded: imgs.filter(img => !img.complete).length,
          broken: imgs.filter(img => img.getAttribute('src') && img.complete && img.naturalWidth === 0)
                      .map(img => img.getAttribute('src')),
          urls: (() => {
            const out = new Set();
            const add = v => { if (!v || v.startsWith('data:')) return;
                               try { out.add(new URL(v, document.baseURI).href); } catch (e) {} };
            s.querySelectorAll('img').forEach(i => add(i.currentSrc || i.getAttribute('src')));
            s.querySelectorAll('video, audio, source, iframe, embed').forEach(e => add(e.getAttribute('src')));
            s.querySelectorAll('object').forEach(e => add(e.getAttribute('data')));
            s.querySelectorAll('image').forEach(e => add(e.getAttribute('href') || e.getAttribute('xlink:href')));
            ['data-background-image', 'data-background-video', 'data-background-iframe']
              .forEach(a => (s.getAttribute(a) || '').split(',').forEach(v => add(v.trim())));
            [s, ...s.querySelectorAll('*')].forEach(e => {
              for (const m of getComputedStyle(e).backgroundImage.matchAll(/url\(["']?([^"')]+)["']?\)/g)) add(m[1]);
            });
            return [...out];
          })()};
}
"""
# Force every fragment visible in place — the union of all fragment states, so a
# .fade-out or .current-visible block is measured too. Inline !important, because
# Reveal's own fragment rules outrank any stylesheet we could add; the previous
# inline style is restored afterwards so the screenshot shows the final state.
ALL_FRAGMENTS_JS = r"""
(on) => {
  for (const f of document.querySelectorAll('.reveal .slides section .fragment')) {
    if (on) {
      f.dataset.slideqaStyle = f.getAttribute('style') || '';
      f.style.setProperty('opacity', '1', 'important');
      f.style.setProperty('visibility', 'inherit', 'important');
      f.style.setProperty('transform', 'none', 'important');
    } else if ('slideqaStyle' in f.dataset) {
      if (f.dataset.slideqaStyle) f.setAttribute('style', f.dataset.slideqaStyle); else f.removeAttribute('style');
      delete f.dataset.slideqaStyle;
    }
  }
}
"""
TABS_JS = "() => [...Reveal.getCurrentSlide().querySelectorAll('.panel-tabset')].map(t => t.querySelectorAll('[role=tab]').length)"
CLICK_TAB_JS = r"""
async ([t, j]) => {
  Reveal.getCurrentSlide().querySelectorAll('.panel-tabset')[t].querySelectorAll('[role=tab]')[j].click();
  await new Promise(r => requestAnimationFrame(() => requestAnimationFrame(r)));
}
"""

MIN_TOLERANCE = 0.5   # below this, sub-pixel font metrics flag clean headings


def case_mismatch(path: Path, cache: dict) -> Path | None:
    """The on-disk spelling of `path` if any component differs only in letter case.

    macOS and Windows open a wrong-case path without complaint; Linux and GitHub
    Pages do not, so an image that shows locally is missing once deployed.
    """
    nfc = lambda n: unicodedata.normalize("NFC", n)
    parts, cur, fixed, differs = path.parts, Path(path.anchor), Path(path.anchor), False
    for name in parts[1:]:
        if cur not in cache:
            try:
                cache[cur] = os.listdir(cur)
            except OSError:
                return None
        # macOS may store a name decomposed (NFD) while a URL spells it composed
        # (NFC): the same name, not a case error, so compare normalised.
        real = next((n for n in cache[cur] if nfc(n) == nfc(name)), None)
        if real is None:
            real = next((n for n in cache[cur] if nfc(n).casefold() == nfc(name).casefold()), None)
            if real is None:
                return None
            differs = True
        cur, fixed = cur / real, fixed / real
    return fixed if differs else None


def fail(msg: str) -> int:
    print(f"slide-qa: {msg}", file=sys.stderr)
    return 2


def resolve_html(arg: str) -> tuple[Path | None, str | None]:
    p = Path(arg).resolve()
    suffix = p.suffix.lower()
    if suffix == ".qmd":
        html = p.with_suffix(".html")
        if not html.exists():
            return None, f"no rendered HTML beside {arg} — run `quarto render {arg}` first"
        src = p
    elif suffix in (".html", ".htm"):
        html, src = p, p.with_suffix(".qmd")
    else:
        return None, f"expected a .html or .qmd deck, got {arg}"
    if not html.exists():
        return None, f"file not found: {html}"
    if src.exists() and src.stat().st_mtime > html.stat().st_mtime:
        return None, (f"{html.name} is older than {src.name} — re-render first "
                      f"(`quarto render {src}`), or the measurements describe an old deck")
    return html, None


def merge(into: dict, m: dict) -> None:
    """Fold one measured state of a slide into the running result for that slide."""
    for k, v in m["overflow"].items():
        into["overflow"][k] = max(into["overflow"][k], v)
    into["title"] = into["title"] or m["title"]
    into["offenders"] += m["offenders"]
    into["clipped"] += m["clipped"]


def top3(items: list, key) -> list:
    seen, out = set(), []
    for it in sorted(items, key=key, reverse=True):
        k = (it["element"], it["text"])
        if k not in seen:
            seen.add(k)
            out.append(it)
        if len(out) == 3:
            break
    return out


def measure_deck(html: Path, out: Path, tol: float, screenshots: bool):
    from playwright.sync_api import sync_playwright, Error as PWError
    with sync_playwright() as pw:
        browser, engine = None, None
        for kw, name in (({"channel": "chrome"}, "Google Chrome"), ({}, "Playwright Chromium")):
            try:
                browser, engine = pw.chromium.launch(**kw), name
                break
            except PWError:
                continue
        if browser is None:
            raise RuntimeError("no browser found — install Google Chrome, or run "
                               "`python3 -m playwright install chromium` with the same Python")
        try:
            page = browser.new_page(viewport={"width": 1050, "height": 700})
            requested, failed, http_bad = set(), {}, set()
            page.on("request", lambda r: requested.add(r.url) if r.url.startswith("file:") else None)
            page.on("requestfailed", lambda r: failed.__setitem__(r.url, r.failure or ""))
            page.on("response", lambda r: http_bad.add(r.url) if r.url.startswith("http") and r.status >= 400 else None)
            page.goto(html.as_uri(), wait_until="load", timeout=60_000)
            if not page.evaluate("() => !!window.Reveal"):
                raise RuntimeError(f"{html.name} is not a Reveal.js deck (no Reveal on the page)")
            try:
                page.wait_for_function("() => Reveal.isReady && Reveal.isReady()", timeout=30_000)
            except PWError:
                raise RuntimeError(f"{html.name}: Reveal.js never became ready")
            cfg = page.evaluate("() => { const c = Reveal.getConfig(); return {w: c.width, h: c.height}; }")
            w = cfg["w"] if isinstance(cfg["w"], (int, float)) else 1050
            h = cfg["h"] if isinstance(cfg["h"], (int, float)) else 700
            page.set_viewport_size({"width": int(w), "height": int(h)})
            page.evaluate(SETUP_JS)
            math = page.evaluate(READY_JS)
            page.wait_for_timeout(300)            # widgets that draw after load

            n = page.evaluate("() => document.querySelectorAll('.reveal .slides section:not(.stack)').length")
            slides = []
            for i in range(n):
                pos = page.evaluate(GOTO_JS, i)
                res = {"title": "", "overflow": {"bottom": 0, "right": 0, "top": 0, "left": 0},
                       "offenders": [], "clipped": []}
                page.evaluate(ALL_FRAGMENTS_JS, True)
                merge(res, page.evaluate(MEASURE_JS, tol))
                for t, k in enumerate(page.evaluate(TABS_JS)):       # every tab of every tabset
                    for j in range(1, k):
                        page.evaluate(CLICK_TAB_JS, [t, j])
                        merge(res, page.evaluate(MEASURE_JS, tol))
                    if k > 1:
                        page.evaluate(CLICK_TAB_JS, [t, 0])
                page.evaluate(ALL_FRAGMENTS_JS, False)
                spill = any(v > tol for v in res["overflow"].values())
                verdict = ("overflow" if spill else "clipped" if res["clipped"]
                           else "broken-asset" if pos["broken"] else "ok")
                shot = None
                if screenshots:
                    shot = out / f"slide-{i + 1:02d}.png"
                    page.screenshot(path=str(shot))
                slides.append({"n": i + 1, "h": pos["h"], "v": pos["v"], "title": res["title"],
                               "verdict": verdict, "overflow_px": res["overflow"],
                               "offenders": top3(res["offenders"], key=lambda o: o["by_px"]),
                               "clipped": top3(res["clipped"], key=lambda c: max(c["hidden_x"], c["hidden_y"])),
                               "images_not_loaded": pos["unloaded"], "broken_images": pos["broken"],
                               "_urls": pos["urls"], "_spill": spill,
                               "screenshot": str(shot) if shot else None})
        finally:
            browser.close()
    # Local files the deck asked for that are not on disk, and ones found only because
    # the filesystem ignores letter case. "Missing" is decided on disk, not from a failed
    # request: media the browser aborts, or a module file:// blocks, is still there.
    to_path = lambda u: Path(url2pathname(urlparse(u).path))
    real_fail = {u for u, why in failed.items() if "ERR_ABORTED" not in why}
    cache, wrong_case = {}, []
    missing = sorted({str(to_path(u)) for u in real_fail if u.startswith("file:") and not to_path(u).exists()})
    for u in sorted(requested):
        if to_path(u).exists():
            fixed = case_mismatch(to_path(u), cache)
            if fixed:
                wrong_case.append({"requested": str(to_path(u)), "on_disk": str(fixed)})
    bad_local = set(missing) | {c["requested"] for c in wrong_case}
    bad_remote = http_bad | {u for u in real_fail if u.startswith("http")}
    for sl in slides:                        # pin every broken asset to the slide that uses it
        urls = sl.pop("_urls")
        sl["broken_assets"] = sorted({str(to_path(u)) for u in urls if u.startswith("file:") and str(to_path(u)) in bad_local}
                                     | {u for u in urls if u in bad_remote})
        # Each defect is tracked on its own: a slide that overflows AND hides content
        # in a scrolling element must show both, or the second is found a run later.
        sl["defects"] = ([d for d, on in (("overflow", sl.pop("_spill")), ("clipped", bool(sl["clipped"])),
                                          ("broken-asset", bool(sl["broken_assets"] or sl["broken_images"]))) if on])
        sl["verdict"] = sl["defects"][0] if sl["defects"] else "ok"
    return slides, engine, math, (w, h), {"missing": missing, "wrong_case": wrong_case}


def main() -> int:
    ap = argparse.ArgumentParser(description="Measure overflow in a rendered Reveal.js deck.")
    ap.add_argument("deck", help="rendered .html, or a .qmd whose .html sits beside it")
    ap.add_argument("--out", help="output directory (default quality_reports/audits/slide-qa/<deck>/)")
    ap.add_argument("--tolerance", type=float, default=1.0,
                    help=f"pixels of overflow to ignore (default 1; minimum {MIN_TOLERANCE})")
    ap.add_argument("--no-screenshots", action="store_true", help="measure only")
    args = ap.parse_args()
    # A deck or --out path outside the pipe's code page must not crash the summary.
    try:
        sys.stdout.reconfigure(errors="backslashreplace")
    except (AttributeError, ValueError):
        pass
    tol = args.tolerance
    if tol < MIN_TOLERANCE:
        print(f"slide-qa: tolerance raised to {MIN_TOLERANCE}px — below that, sub-pixel font metrics "
              f"flag clean headings", file=sys.stderr)
        tol = MIN_TOLERANCE

    html, err = resolve_html(args.deck)
    if err:
        return fail(err)
    html = case_mismatch(html, {}) or html   # a wrong-case deck path would make every asset look wrong-case
    out = Path(args.out).resolve() if args.out else ROOT / "quality_reports" / "audits" / "slide-qa" / html.stem
    out.mkdir(parents=True, exist_ok=True)
    # Clear the previous run first: a crash must not leave an old report that a
    # skill could mistake for this run's result.
    for old in [*out.glob("slide-*.png"), out / "report.json", out / "report.md"]:
        old.unlink(missing_ok=True)

    try:
        import playwright  # noqa: F401
    except ImportError:
        return fail("needs Python Playwright in the interpreter that runs this script. "
                    "Install it in a virtual environment (a Homebrew or system Python refuses a plain pip install): "
                    "`python3 -m venv ~/.venvs/slide-qa && ~/.venvs/slide-qa/bin/pip install playwright`, "
                    "then `export SLIDE_QA_PYTHON=~/.venvs/slide-qa/bin/python` — the skills run "
                    "`${SLIDE_QA_PYTHON:-python3} scripts/slide-qa.py`. It drives your installed Chrome; "
                    "no browser download is needed.")

    try:
        slides, engine, math, (w, h), assets = measure_deck(html, out, tol, not args.no_screenshots)
    except Exception as e:                  # anything that stops the run is "could not run", never "overflow"
        return fail(f"could not measure {html.name}: {e}")
    if math == "not-typeset":               # measurements would describe raw TeX, not the deck
        return fail(f"{html.name} has math that never rendered (MathJax/KaTeX did not load — offline, or "
                    "blocked?), so every formula would be measured as raw TeX. Connect to the network, or render "
                    "with `embed-resources: true`, and re-run.")

    bad = [s for s in slides if s["verdict"] != "ok"]
    asset_problems = bool(assets["missing"] or assets["wrong_case"])
    report = {
        "deck": str(html), "generated": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "browser": engine, "math": math, "slide_size": [w, h], "tolerance_px": tol,
        "summary": {"slides": len(slides), "overflow": sum("overflow" in s["defects"] for s in slides),
                    "clipped": sum("clipped" in s["defects"] for s in slides),
                    "broken_asset": sum(bool(s["broken_images"] or s["broken_assets"]) for s in slides),
                    "missing_files": len(assets["missing"]), "wrong_case_files": len(assets["wrong_case"])},
        "assets": assets,
        "slides": slides,
    }
    rel = lambda p: str(Path(p).relative_to(ROOT)) if p and Path(p).is_relative_to(ROOT) else p
    md = [f"# Slide QA: {html.name}", "",
          f"Measured in {engine} at {w}×{h} with every fragment state, every tab and every slide "
          f"(uncounted ones included), tolerance {tol}px, {report['generated']}.", "",
          f"**{len(slides)} slides: {report['summary']['overflow']} overflow, "
          f"{report['summary']['clipped']} with clipped content, "
          f"{report['summary']['broken_asset']} with a broken asset; "
          f"{len(assets['missing'])} missing and {len(assets['wrong_case'])} wrong-case local files.**", ""]
    missing = [s["n"] for s in slides if s["images_not_loaded"]]
    if missing:
        md += [f"> Images still loading after 8s on slide(s) {', '.join(map(str, missing))} — "
               "their size may be understated.", ""]
    if bad:
        md += ["| # | Title | Verdict | Past edge (px: bottom / right / top / left) | Where | Screenshot |",
               "|---|---|---|---|---|---|"]
        for s in bad:
            o = s["overflow_px"]
            where = "; ".join(f"`{x['element']}` +{x['by_px']}px “{x['text']}”" for x in s["offenders"])
            hidden = "; ".join(f"`{c['element']}` hides {c['hidden_x']}×{c['hidden_y']}px “{c['text']}”"
                               for c in s["clipped"])
            where = "; ".join(filter(None, [where, hidden]))
            broken = ([f"image did not load: `{b}`" for b in s["broken_images"]]
                      + [f"broken asset: `{rel(b)}`" for b in s["broken_assets"]])
            where = "; ".join(filter(None, [where] + broken))    # listed whatever the verdict
            md.append(f"| {s['n']} | {s['title'] or '—'} | {' + '.join(s['defects'])} | "
                      f"{o['bottom']} / {o['right']} / {o['top']} / {o['left']} | {where} | "
                      f"{rel(s['screenshot']) or '—'} |")
    else:
        md.append("No slide spills past its edges, hides content inside a scrolling element, or uses a broken asset.")
    if asset_problems:
        md += ["", "## Local files", ""]
        md += [f"- **Missing:** `{rel(m)}`" for m in assets["missing"]]
        md += [f"- **Wrong letter case:** requested `{rel(c['requested'])}`, on disk `{rel(c['on_disk'])}` — "
               "loads on macOS and Windows, fails on Linux and GitHub Pages" for c in assets["wrong_case"]]
    # UTF-8, not the locale: on Windows report.md came out in cp1252, which every
    # reader of it decodes as UTF-8, and a β in a slide title crashed the write and
    # left the Overflow evidence empty (#171).
    (out / "report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
    (out / "report.md").write_text("\n".join(md) + "\n", encoding="utf-8")

    # ASCII '->': the '→' this line ended with is in no Windows ANSI code page, so a
    # CLEAN deck died here with exit 1 — which the contract reads as overflow.
    print(f"slide-qa: {len(slides)} slides, {report['summary']['overflow']} overflow, "
          f"{report['summary']['clipped']} clipped, {report['summary']['broken_asset']} with a broken asset; "
          f"{len(assets['missing'])} missing / {len(assets['wrong_case'])} wrong-case files "
          f"-> {rel(str(out / 'report.md'))}")
    return 1 if (bad or asset_problems) else 0


if __name__ == "__main__":
    sys.exit(main())

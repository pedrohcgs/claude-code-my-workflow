# Demo Walkthrough — ~2½ minutes

**Link:** <https://geoai-analytics.shinyapps.io/decline-explorer/>
Open it ~1 minute before you present (free tier sleeps after ~15 min idle; first
load then takes ~20–30 s).

---

## The talk track

**0:00 — Frame it (15 s)**
> "This is a working prototype of our production-forecasting tool, running on real
> North Sea field data — Equinor's Volve field, six wells, 2008 to 2016, publicly
> released. Nothing here is mocked up."

**0:15 — One well (30 s)**
It opens on well **15/9-F-12**.
> "The grey dots are monthly oil rate. The tool fits a decline curve — the blue
> line — picks the best of three standard models automatically, and projects
> forward in red to an economic cut-off. Top right: estimated ultimate recovery,
> **29 million barrels**. This well actually produced 28.8 — so the model is
> within a percent."

Drag the **Economic oil rate** slider up and down.
> "Change the economic assumption and the forecast and EUR re-price instantly."

Toggle **Rate axis → Linear**, then back to Log.
> "Same fit, two views — engineers read decline on a log axis."

**0:40 — Uncertainty (15 s)**
Point at the shaded band on the chart and the "P90 … P10" under the EUR.
> "It's not a single line — that shaded range is P90 to P10, the conservative-to-
> upside band, carried through to the EUR."

**0:55 — Screening the field (25 s)**
Click the **Well screening** tab.
> "This ranks every well by a transparent attention score — underperformance
> versus its own decline, remaining oil, water cut and how fast water is rising.
> No black box: the four weights are on the About tab. It's the seed of the
> workover-prioritisation product, built honestly without pretending to have ML yet."

**1:20 — The whole asset (20 s)**
Click the **Field portfolio** tab.
> "Roll it up: **field EUR 63.9 million barrels**. Volve's actual lifetime recovery
> was 63.1 — within about one percent, no manual tuning. Every weak fit is flagged,
> not hidden."

**1:40 — Your own data + the deliverable (20 s)**
Sidebar → **Upload production data** (optional, if you have a file handy), then
**Well report (HTML)**.
> "Drop in your own field's production export and everything re-runs on it. And one
> click produces a branded client report — chart, parameters, forecast, methodology,
> attribution. Open it, print to PDF, send it."

**2:00 — What funding builds (25 s)**
Open the **About & method** tab, "What it does not do (yet)".
> "This is the spine. What the raise builds on top: machine-learning and
> physics-based production prediction, full probabilistic reserves, and the
> localisation layer — KazSRE state-reserve reporting and a Russian/Kazakh
> interface. That last piece is the moat: no Western tool does it, and every
> operator in Kazakhstan needs it."

---

## If asked

- **"Is the data real?"** — Yes. Equinor Volve open dataset, ~15,600 daily
  production records. Link on the About tab.
- **"How accurate is it?"** — On Volve, field EUR within ~1% of actual lifetime
  recovery; the two best-fit wells within <1%. Weak fits are flagged, not sold.
- **"Could it run on our field?"** — Yes — it takes the same
  production-history format any operator exports. Swapping in a Kazakhstan field
  is a data-load, not a rebuild.
- **"Who built it?"** — Founder-directed, built fast to prove the concept before
  hiring. The engineering team is what the raise funds.

## Don't

- Don't promise ML accuracy numbers — that model isn't built yet.
- Don't call the EUR "reserves" — say "estimated ultimate recovery, illustrative".
- Don't demo on a flaky network without loading the page first.

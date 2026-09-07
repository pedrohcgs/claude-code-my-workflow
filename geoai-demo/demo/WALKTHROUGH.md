# Demo Walkthrough — ~4 minutes

**Link:** <https://geoai-analytics.shinyapps.io/decline-explorer/>
Open it ~1 minute before you present (free tier sleeps after ~15 min idle; first
load then takes ~20–30 s). Keep the short version for a cold room; add the
starred (★) beats for a technical audience.

---

## The talk track

**0:00 — Frame it (15 s)**
> "A working prototype of our production-forecasting and reserves tool, running on
> real North Sea field data — Equinor's Volve field, six wells, 2008 to 2016,
> publicly released. Nothing here is mocked up."

**0:15 — One well (30 s)**
It opens on well **15/9-F-12**.
> "Grey dots are monthly oil rate. The tool fits a decline curve — blue line —
> picks the best of three standard models automatically, projects forward in red
> to an economic cut-off. Top right: estimated ultimate recovery, **29 million
> barrels**. This well actually produced 28.8 — the model is within a percent.
> The shaded band is the P90-to-P10 range, carried through to the EUR."

Drag the **Economic oil rate** slider; toggle **Rate axis → Linear** and back.
> "Change the economic assumption and everything re-prices instantly."

**0:45 — Screen the field (30 s)**
Click **Well screening**.
> "A transparent attention score per well — underperformance vs its own decline,
> remaining oil, water cut, how fast water is rising. Four weights, all on the
> About tab. No black box."

★ Click **ML attention**, press **Train**.
> "And here's the machine-learning version — gradient-boosted, trained on this
> field, with SHAP showing what drives each well's score. The accuracy figure is
> deliberately labelled illustrative: six wells is a demo, not a training set.
> This is the honest seed of the workover-prioritisation product."

**1:15 — The asset (25 s)**
Click **Field KPIs**, then **Field portfolio**.
> "Per-well operating snapshot, and a blind back-test — we re-fit each decline on
> all but the last six months and score it against what actually happened. Roll
> it up: **field EUR 63.9 million barrels**. Volve's actual lifetime recovery was
> 63.1 — within one percent, no manual tuning."

**1:40 — New wells & analogs (20 s)** ★
Click **Analog & new well**.
> "For a proposed well it finds the closest analogs in the field and estimates its
> qi, decline and EUR from them — the basis of new-well and infill planning."

**2:00 — Logs & your own data (20 s)** ★
Click **Well logs**, mention the LAS upload; then the sidebar **Upload production
data**.
> "Upload a well-log file and it plots the tracks with a QC pass. Upload your own
> field's production export and the whole tool re-runs on it — swapping in a
> Kazakhstan field is a data load, not a rebuild."

**2:20 — The deliverables (25 s)**
Sidebar → **Well report (HTML)** and **KAZ-RC report (HTML)**.
> "One click gives a branded client report. And a second one gives a
> reserves report in the KAZ-RC / CRIRSCO public-reporting shape — Competent
> Person, assessment checklist, a 1P / 2P / 3P table from the P90 / P50 / P10.
> It flags itself as a template: the filed version needs the State classification
> and a licensed Competent Person — which is exactly the compliance work the raise
> funds."

**2:45 — Localisation (15 s)**
Flip the sidebar toggle **EN → RU**.
> "The whole interface switches to Russian. That's the moat: no Western tool does
> Russian / Kazakh and the KazSRE reporting format, and every operator in the
> region needs both."

**3:00 — What funding builds (30 s)**
Open **About & method**, "What it does not do (yet)".
> "This is the spine — deployed, running on real data, honest about its limits.
> The raise builds: the full localisation layer (KazSRE format + Russian/Kazakh),
> physics-based reservoir and EOR modelling, deeper ML on real Kazakhstan wells,
> and the production platform — accounts, data pipelines, cloud. Two engineers,
> twenty-four weeks to a paid pilot."

---

## If asked

- **"Is the data real?"** — Yes. Equinor Volve open dataset, ~15,600 daily
  production records. Link on the About tab.
- **"How accurate is it?"** — On Volve, field EUR within ~1% of actual lifetime
  recovery; the two best-fit wells within <1%. Weak fits are flagged, not sold.
  The **ML model's AUC (~0.62) is illustrative** — six wells — not a production
  number; the app says so.
- **"Could it run on our field?"** — Yes — same production-history format any
  operator exports. A Kazakhstan field is a data load.
- **"Is that a real KazSRE report?"** — No — it's the public-reporting *structure*
  (KAZ-RC / CRIRSCO). A filed report needs the State (ГКЗ) classification and a
  licensed Competent Person. Building that pipeline is in the raise.
- **"Who built it?"** — Founder-directed, built fast to prove the concept before
  hiring. The engineering team is what the raise funds.

## Don't

- Don't quote the ML AUC as an accuracy claim — call it "illustrative of the method".
- Don't call the EUR "reserves" — say "estimated ultimate recovery, illustrative".
- Don't call the KAZ-RC output a filed report — it's a template.
- Don't demo on a flaky network without loading the page first.

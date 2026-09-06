# GeoAI Demo

A two-week prototype: turn well production history into decline-curve forecasts
and a client-ready PDF report, delivered as a web app.

**Live:** <https://geoai-analytics.shinyapps.io/decline-explorer/>

Full plan: [`PLAN_two-week-demo.md`](PLAN_two-week-demo.md)

---

## Status

| Day | Deliverable | State |
|---|---|---|
| 1 | Load + clean Volve data, EDA | **done — runs on real Volve data (6 producers, 63.1 MMbbl)** |
| 2 | Arps decline-curve engine | **done — validated on synthetic + real data** |
| 3 | Shiny app (local) | **done — `source("run_app.R")`** |
| 4 | App polish + fix what real data breaks | **done — field EUR 63.9 MMbbl vs 63.1 produced (~1%)** |
| 5 | Week 1 checkpoint | — |
| 6 | Client-ready report | **done — `source("run_reports.R")`; download buttons in the app** |
| 7 | Multi-well / portfolio report | **done — folded into Day 6** |
| 8 | Deploy to shinyapps.io | **done — [live](https://geoai-analytics.shinyapps.io/decline-explorer/)** |
| 9–10 | Demo polish + dry run | **done — About tab, F-12 default, branding, [`demo/`](demo/) walkthrough + one-pager** |

**The two-week build is complete.** Next steps are in `demo/ONE_PAGER.md` ("what the
raise unlocks") — hire the engineer, build the localisation layer, add a Kazakhstan field.

**Post-build additions (`geoai-demo/` sub-project):**
- **Upload your own data** — `fileInput` in the sidebar; `R/ingest.R` parses a
  CSV/Excel of production (tolerant of column names; oil as volume Sm³/bbl or as a
  rate; daily or monthly). "↺ back to Volve sample" resets.
- **P90 / P50 / P10 ranges** — parameter-covariance sampling of each fit
  (`.decline_bands` in `R/03_decline_curve.R`): a shaded range on the chart, P90–P10
  on every EUR figure, P90/P10 columns in the forecast table.
- **Well screening tab** — `R/06_screening.R`: a transparent rule-based
  attention score (0–100) + plain-language signal per well. Not ML.
- **Field KPIs tab** — `R/07_analytics.R` `field_kpis()`: per-well operating
  snapshot; a **forecast-vs-actual backtest** (`backtest_field()`, 6-month hold-out,
  MAPE + bias).
- **ML attention tab** — `R/08_ml.R`: an XGBoost classifier (target = "will the
  well fall >15% below its own decline over the next 6 months"), **well-grouped**
  cross-validation, SHAP contributions per well. On a 6-well field the AUC is
  illustrative of the method. Behind a "Train" button (re-fits every well-month).
- **Analog & new-well tab** — `R/07_analytics.R`: k-NN analog matching on a
  standardised well-shape vector; a new-well estimate = analog-weighted average of
  the neighbours' fitted parameters and EUR.
- **Well logs tab** — `R/09_las.R`: a base-R LAS 2.0 reader + depth-track plot
  (GR / resistivity / density / neutron / sonic / caliper) + a basic curve-QC
  table (null %, range, spikes, monotonic depth).
- **KAZ-RC report** — `R/05_report.R` `build_kazrc_html()`: a public-report
  template in the KAZ-RC / CRIRSCO shape (Competent Person, the three principles,
  an assessment checklist) with a PRMS **1P / 2P / 3P** table mapped from the
  P90 / P50 / P10 EUR. Flagged in-report as illustrative — KAZ-RC and Order MID RK
  No.374 are the *solid-minerals* codes; petroleum reserves go through the State
  (ГКЗ) classification. Sidebar download button.
- **RU / EN toggle** — a lightweight client-side localisation (`GEOAI_I18N`
  dictionary + a small script in `app.R`): switches tab names, sidebar labels,
  buttons, value-box titles and section headers. A demonstration of the
  localisation layer; full i18next comes with the build.

Deliberately **not** built into the demo (need the engineering hire / infra):
auth + multi-tenant, a database, cloud infra, subscription billing/monitoring,
LSTM production forecasting, physics-based reservoir/EOR modelling.

**Day 4 changes:** qi is now anchored to the fit-window start (fixed F-11's
back-extrapolation blow-up); forecast horizon auto-caps at 10 yr for weak / short /
boundary fits (fixed F-15 D's 30-yr tail); `b_max` slider + `auto` fit-window;
fit-quality badge; **Field portfolio** tab (per-well + field-total EUR bar & table).

**Day 6 report:** `R/05_report.R` builds a branded, self-contained HTML report
(no Quarto / Pandoc / LaTeX needed — the machine has none). One report per well
plus a field-portfolio report: header, stat cards, decline chart, parameter and
forecast tables, methodology, Equinor attribution. Open it and Ctrl/Cmd-P →
Save as PDF, or `run_reports.R` also writes real PDFs via headless Edge/Chrome.
Branding is `default_brand()` in `R/05_report.R` (drop a `report/logo.png` to
add a logo).

---

## Quick start (Day 1)

1. **Get the data.** Follow [`data/README.md`](data/README.md) — download
   `Volve production data.xlsx` from Equinor and put it in `data/`.
2. **Open the project.** Double-click `geoai-demo.Rproj` (RStudio), or in an R
   console run `setwd("C:/Users/zh.kakishev/my-project2/geoai-demo")`.
3. **Run it.**
   ```r
   source("run_day1.R")
   ```
4. **Review.** Open [`outputs/eda/EDA_SUMMARY.md`](outputs/eda/) — field totals,
   per-well table, and four diagnostic figures.

## Day 2 — decline-curve fits

After Day 1 has produced `data/processed/volve_monthly.rds`:

```r
source("setup.R")            # one-time: installs minpack.lm etc.
source("R/04_fit_report.R")  # fits every well, forecasts, writes outputs/decline/
```

Review [`outputs/decline/DECLINE_SUMMARY.md`](outputs/decline/) — fitted Arps
parameters (model, qi, Di, b), R², EUR per well and field total, plus a
history-vs-forecast chart. Edit `Q_ECON` / `WINDOW` at the top of
`R/04_fit_report.R` to change the economic-rate cutoff or the fit window
(`post_peak` / `last_stable` / `all`).

The engine itself is `R/03_decline_curve.R` (`fit_decline()` for one well).

## Day 3 — the app

```r
source("setup.R")     # one-time: installs shiny, bslib, DT
source("run_app.R")   # opens the decline-curve explorer in your browser
```

Controls: well, economic-rate slider, fit window (`auto` / post-peak / last-stable /
all), max-b slider, log/linear axis, forecast-horizon slider. Value boxes show the
fitted Arps parameters + a fit-quality badge; the amber banner lists any warnings.
Tabs: forecast table · fit details · monthly production · **field portfolio**
(per-well and field-total EUR). "Download forecast (CSV)" exports the selected well.

`app.R` sources `R/05_report.R` (which pulls in `R/03_decline_curve.R`). The `R/`
batch scripts are **not** run when the app launches (`R/_disable_autoload.R`).

## Day 6 — client-ready report

```r
source("run_reports.R")   # -> outputs/reports/*.html  (+ *.pdf if Edge/Chrome is present)
```

One branded, self-contained HTML report per well plus a field-portfolio report:
header, stat cards, decline chart, fitted-parameter and annual-forecast tables,
methodology, and Equinor attribution. No Quarto / Pandoc / LaTeX required.

- **To a PDF:** open the `.html` and press Ctrl/Cmd-P → Save as PDF, or let
  `run_reports.R` render PDFs directly through headless Edge/Chrome.
- **In the app:** the sidebar has *Well report (HTML)*, *Field report (HTML)*,
  *Forecast (CSV)* download buttons that use the current settings.
- **Branding:** edit `default_brand()` in `R/05_report.R`; drop a
  `report/logo.png` to add a logo.

## Day 8 — deploy

```r
source("deploy.R")   # pushes to shinyapps.io as geoai-analytics/decline-explorer
```

One-time per machine: configure credentials with the token block from
shinyapps.io → Account → Tokens → Show:
`rsconnect::setAccountInfo(name=…, token=…, secret=…)`. The deploy bundle is
minimal (`deploy.R` lists it): `app.R`, four `R/` files, and
`data/processed/volve_monthly.rds`. First deploy builds ~65 R deps server-side
(~5 min); redeploys are ~1 min.

Free tier: the app sleeps after ~15 min idle (first load then ~20–30 s), 25
active-hours/month — fine for demos. Load the page a minute before presenting.

## Presenting it

- [`demo/WALKTHROUGH.md`](demo/WALKTHROUGH.md) — a 2-minute talk track.
- [`demo/ONE_PAGER.md`](demo/ONE_PAGER.md) — investor leave-behind (fill in the
  `[funding amount]` / `[email]` placeholders).

### Test it before the real data arrives

```r
source("tests/make_synthetic_sample.R")   # writes a fake Volve-shaped CSV
source("run_day1.R")                       # Day 1 pipeline on it
source("R/04_fit_report.R")                # Day 2 fits on it
```
Delete `data/SYNTHETIC_sample_delete_me.csv`, `data/processed/`, and
`outputs/` once the real file is in place.

---

## Layout

```
geoai-demo/
  PLAN_two-week-demo.md   the plan
  run_day1.R              one-shot Day 1 pipeline
  setup.R                 installs Day 2+ packages
  R/
    utils.R               shared helpers
    01_load_data.R        read + clean -> data/processed/
    02_eda.R              EDA + data-quality -> outputs/eda/
  tests/
    make_synthetic_sample.R   fake data to test the pipeline
  data/                   (you add the Volve file here)
  outputs/                generated figures + summaries
```

## Requirements

- **R 4.5.x** (installed: `C:\Users\zh.kakishev\AppData\Local\Programs\R\R-4.5.3`).
- Day 1 uses only packages already present (tidyverse, ggplot2, readxl, scales).
- Day 2+ packages: run `source("setup.R")`.
- Quarto (for the Day 6 report) — not yet installed; we'll handle that on Day 6.

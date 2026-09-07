# GeoAI Analytics — Working Demo

**Production-forecasting and reserves analytics for Central Asian oil & gas.**

Live demo: **https://geoai-analytics.shinyapps.io/decline-explorer/**
(no login; runs in any browser)

---

## What the demo does

Loads a field's monthly production history — or your own uploaded file — and:

- fits an **Arps decline curve** per well (auto-selects exponential / hyperbolic /
  harmonic), forecasts to an economic cut-off, computes **EUR** with a
  **P90 / P50 / P10 range**;
- rolls the wells into an **asset portfolio** and a **field KPI grid**, with a
  blind **forecast-vs-actual back-test**;
- **screens** every well for intervention candidates — a transparent rule-based
  score *and* a **gradient-boosted (XGBoost) model** with SHAP explanations;
- matches **analog wells** and estimates a **new well** from them;
- reads a **LAS well-log** file — depth tracks + a basic curve-QC pass;
- exports a **branded client report** and a **KAZ-RC-style reserves report**
  (1P / 2P / 3P) in one click each;
- switches the whole interface **English ⇄ Russian**;
- **flags** every weak or short-history fit instead of hiding it.

## It runs on real data — and it's accurate

Loaded with **Equinor's Volve field** (North Sea, 6 wells, 2008–2016, ~15,600 daily
records, publicly released under the Equinor Open Data Licence).

| | Model estimate | Actual (Volve lifetime) | Error |
|---|---:|---:|---:|
| **Field EUR** | 63.9 MMbbl | 63.1 MMbbl | **~1%** |
| Well 15/9-F-12 | 29.0 MMbbl | 28.8 MMbbl | <1% |
| Well 15/9-F-14 | 25.0 MMbbl | 24.8 MMbbl | <1% |

No manual tuning — straight out of the automated fit.

## Why this matters for Central Asia

- **Aging Soviet-era well stock** across Kazakhstan, Uzbekistan, Turkmenistan —
  thousands of wells that need decline analysis and workover prioritisation now.
- **Regulatory gap:** no US-centric tool produces the Kazakhstan State
  reserve-reporting format.
- **Language gap:** no serious Russian / Kazakh-language subsurface analytics product.

The demo *shows* the localisation layer — a working RU/EN toggle and a KAZ-RC-shaped
report. Productionising it — the filed State (ГКЗ) format, full-app Russian/Kazakh —
is the moat, and it is what the raise builds.

## What this demo is — and is not

**Is:** a deployed, working product spine, founder-directed, on real field data.
Decline analysis, probabilistic ranges, ML screening, analog/new-well estimation,
log QC, client + reserves reports, bilingual UI.

**Is not (yet):**

- physics-based reservoir / EOR modelling (waterflood optimisation) or LSTM
  production forecasting — deeper models on real Kazakhstan wells;
- a **filed** KazSRE / ГКЗ reserves report — the demo produces the public-reporting
  *structure*, not a document with State classification and a licensed Competent
  Person;
- seismic / subsurface interpretation;
- the production platform — user accounts, multi-tenant isolation, a database,
  cloud infrastructure, billing.

The ML model's accuracy figure (AUC ~0.62 on six wells) is illustrative of the
method, not a production benchmark. EUR figures are illustrative, not SPE-PRMS or
State-certified reserves.

## What the raise unlocks

| Priority | Build |
|---|---|
| 1 | Full-stack engineer — own the codebase; accounts, data pipelines, cloud |
| 2 | Localisation to production — filed KazSRE / ГКЗ format + full Russian/Kazakh UI |
| 3 | First Kazakhstan field as a second dataset (KMG / Uzbekneftegas public data) |
| 4 | Petroleum data scientist — ML + physics-based forecasting on real KZ wells |

**The ask:** [funding amount] to reach a paid pilot with one operator in [N] months.

---

*Data: Equinor Volve open dataset. GeoAI Analytics demo — not investment or reserves advice.
KAZ-RC and Order MID RK No.374 are the solid-minerals codes; petroleum reserves are
reported through the State (ГКЗ) classification. Contact: [email] · [phone].*

# GeoAI Analytics — Working Demo

**Production-forecasting and reserves analytics for Central Asian oil & gas.**

Live demo: **https://geoai-analytics.shinyapps.io/decline-explorer/**

---

## What the demo does

Loads a field's monthly production history and, per well:

- fits an **Arps decline curve** (auto-selects exponential / hyperbolic / harmonic),
- forecasts to an economic cut-off and computes **estimated ultimate recovery (EUR)**,
- rolls the wells up into an **asset-level portfolio** view,
- exports a **branded client report** (chart, parameters, forecast, methodology) in one click,
- **flags** every weak or short-history fit instead of hiding it.

Runs in a browser. No install for the viewer.

## It runs on real data — and it's accurate

Loaded with **Equinor's Volve field** (North Sea, 6 wells, 2008–2016, ~15,600 daily
records, publicly released under the Equinor Open Data Licence).

| | Model estimate | Actual (Volve lifetime) | Error |
|---|---:|---:|---:|
| **Field EUR** | 63.9 MMbbl | 63.1 MMbbl | **~1%** |
| Well 15/9-F-12 | 29.0 MMbbl | 28.8 MMbbl | <1% |
| Well 15/9-F-14 | 25.0 MMbbl | 24.8 MMbbl | <1% |

No manual tuning — these come straight out of the automated fit.

## Why this matters for Central Asia

- **Aging Soviet-era well stock** across Kazakhstan, Uzbekistan, Turkmenistan —
  thousands of wells that need decline analysis and workover prioritisation now.
- **Regulatory gap:** KazSRE / state-reserve reporting formats are not supported
  by any US-centric tool.
- **Language gap:** no serious Russian / Kazakh-language subsurface analytics product.

The localisation layer — regulatory output + Russian/Kazakh UI — is the moat.
It is deliberately **not** in this demo; it is what the raise builds.

## What this demo is — and is not

**Is:** a working, deployed product spine, built founder-directed to prove the
concept before hiring. Turns raw production data into a defensible forecast and a
client-ready document.

**Is not (yet):** machine-learning production prediction, probabilistic (P10/P50/P90)
reserves, seismic/subsurface, KazSRE output, or the Russian/Kazakh interface.
EUR figures are illustrative, not SPE-PRMS reserves.

## What the raise unlocks

| Priority | Build |
|---|---|
| 1 | One full-stack engineer — own the codebase before any client data touches it |
| 2 | Localisation layer — KazSRE report templates + Russian/Kazakh UI |
| 3 | First Kazakhstan field as a second dataset (KMG / Uzbekneftegas public data) |
| 4 | Petroleum data scientist — ML production forecast, probabilistic reserves |

**The ask:** [funding amount] to reach a paid pilot with one operator in [N] months.

---

*Data: Equinor Volve open dataset. GeoAI Analytics demo — not investment or reserves advice.
Contact: [email] · [phone].*

# GeoAI Demo — Two-Week Build Plan

**Status:** DRAFT (awaiting your go-ahead)
**Date:** 2026-09-06
**Builders:** You (direction, testing, feedback) + Claude Code (all code)
**Working folder:** `C:\Users\zh.kakishev\my-project2\geoai-demo\`
*(You may want this as its own git repo later — it is self-contained, nothing here depends on the academic project.)*

---

## 1. Goal

A **live web app** (URL you can send to an investor or a KazMunayGas contact) that:

1. Loads real well production history (Equinor Volve field, public).
2. Fits **Arps decline curves** (exponential / hyperbolic / harmonic, best-fit auto-selected).
3. Forecasts future production to an economic limit and reports **EUR** (estimated ultimate recovery).
4. Exports a **branded PDF report** — per well and a portfolio summary.

## 2. Non-goals (deliberately deferred)

| Deferred | Why | When |
|---|---|---|
| Machine-learning production forecast | High risk of eating the whole two weeks | After funding / after the data-scientist hire |
| Seismic / subsurface / well logs | 40 GB of data, months of work | Post-MVP |
| Russian / Kazakh UI toggle | Polish, competes for time | Sprint after this one (small job) |
| KazSRE report formatting | Needs the real regulatory templates | Pilot phase |
| Multi-user accounts, real client data | Needs an engineer who owns the code | Before first paying pilot |

## 3. Stack (decided)

- **R + Shiny** — one language, matches your existing R setup, no Python/Node toolchain to maintain.
- **Nonlinear fitting:** `minpack.lm` (robust Arps fits).
- **Report:** Quarto parameterised report → PDF (fallback: HTML "print to PDF" if the free host can't run LaTeX — decided on Day 6).
- **Hosting:** shinyapps.io free tier (a public URL; sleeps after idle, ~30 s cold start — fine for demos).
- **Cost: $0.** All free tiers.

---

## 4. What you need to do (mostly upfront)

| # | Task | Time | When |
|---|---|---|---|
| 1 | Create a free **Equinor Data Sharing** account and download **"Volve production data"** (the production-history spreadsheet, a few MB — *not* the 40 GB bundle). Put the file in `geoai-demo\data\`. | 20 min | Before Day 1 |
| 2 | Create a free **shinyapps.io** account (Posit). Send me the account name + token when prompted (Day 8). | 10 min | Before Day 8 |
| 3 | Give me a **company name, one brand colour, and a logo** (PNG) for the report header — or say "use a placeholder". | 5 min | Before Day 6 |
| 4 | **Click through the app and give feedback**, ~30 min/day. | ~5 hrs total | Daily |
| 5 | Confirm R and Quarto run (they do, per your project setup — I'll verify Day 1). | — | Day 1 |

I cannot create accounts or download files for you — those three signups are yours to do. Everything else is on me.

---

## 5. Day-by-day

### Week 1 — Analytics engine + working local app

| Day | Claude Code does | You do | Visible at end of day |
|---|---|---|---|
| **1** | Set up R project (`renv` lockfile, folder structure). Load & clean Volve production data. EDA: well count, date ranges, oil/gas/water rates, data-quality flags (gaps, workovers). | Download Volve file (task 1). Look at the EDA summary. | A table + plots of every Volve well's production history. |
| **2** | Build the Arps engine: fit exp / hyperbolic / harmonic, auto-pick best by AIC + R², compute EUR and forecast to economic limit. Handle messy wells (fit from last stable segment). | Sanity-check 2–3 wells against your own intuition. | Script: give it a well → fitted parameters (qi, Di, b), R², EUR, forecast. |
| **3** | Minimal Shiny app: well dropdown, decline plot (history + fit + forecast), parameter readout. Runs on your laptop. | Click through all the wells. Note anything confusing. | You browsing wells in a real app on your machine. |
| **4** | Polish: log/Cartesian toggle, economic-limit slider, b-factor controls, fit-quality badge, data table, download-data button. | Change assumptions, watch the forecast move. List what feels wrong. | An app where you can drive the analysis, not just view it. |
| **5 (Fri)** | Fix everything from your Day 3–4 notes. Stabilise. | Walk through it with me start to finish. | **Week 1 checkpoint:** stable local app, decline analysis trustworthy. |

### Week 2 — Report, deployment, demo polish

| Day | Claude Code does | You do | Visible at end of day |
|---|---|---|---|
| **6** | Quarto report template: branded cover, one page per well (plot, parameters, EUR, forecast table, methodology note, disclaimer). Decide PDF path (LaTeX vs HTML-print). | Send branding (task 3). Review the first PDF. | "Generate report" button → a clean PDF for the selected well. |
| **7** | Multi-well report + **portfolio summary**: total EUR, aggregate forecast curve, ranked well table. | Review the portfolio PDF — is this what you'd hand a client? | One-click portfolio PDF. |
| **8** | Deploy to shinyapps.io. Fix the usual host snags (fonts, PDF rendering server-side). Test from a phone on mobile data. | Create shinyapps.io account (task 2), send token. | **A live URL** that works from any device. |
| **9** | Demo polish: branding in the app, short "Methodology / About" tab, a good default well loaded on open, a 2-minute walkthrough script. | Read the walkthrough script, tell me where it drags. | URL + a written demo script. |
| **10 (Fri)** | Buffer + last fixes. | Present it back to me (or a colleague) as if I'm an investor. | **Investor-ready demo link + a one-pager** (what it shows, what's next, what funding unlocks). |

---

## 6. Risks & mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Free host (shinyapps.io) can't run LaTeX for PDF | Medium | Day 6 fallback: HTML report + "print to PDF", or `pagedown` via headless Chrome. Report still looks professional. |
| Volve wells with workovers/gaps break naive Arps fits | High | Day 2 builds a "fit from last stable segment" option; flag low-quality fits rather than hide them. |
| Cold-start delay on free tier during a live demo | Certain | Open the link 1 minute before any demo; note it in the script. Paid tier ($9/mo) removes this later. |
| Scope creep (ML, Russian UI, real data "while we're here") | High | This plan is the contract. New ideas go on a "Sprint 2" list, not into these two weeks. |
| Your feedback time slips | Medium | Daily 30-min slot. If a day is missed, the Friday checkpoint absorbs it; the buffer is Day 10. |

---

## 7. What the demo proves — and what it doesn't

**Proves:**
- You can take raw well production data and produce a **defensible forecast + a client-ready report** in a **web tool that could be localised**. That is the spine of the product.
- You (non-technical) can direct a build and ship something real.
- There is a working artifact to raise money against and to hire against.

**Does not prove (and that's fine):**
- ML accuracy, subsurface/seismic capability, KazSRE compliance output, multi-tenant SaaS, or anything on real Kazakhstan data. Those need funding and the engineering hire — which is exactly the ask this demo supports.

---

## 8. After the two weeks

1. **Sprint 2 candidates:** Russian-language toggle, one real Kazakhstan public well as a second dataset, a rough KazSRE-style report layout.
2. **Hire the full-stack engineer** before any live client data touches the system.
3. Use the demo URL + one-pager in investor conversations and university-partnership outreach.

# Consistency Review: Paper Draft vs. Presentation
**Date:** 2026-04-25  
**Paper:** `Paper/main.tex`  
**Reference:** `master_supporting_docs/supporting_slides/CET_presentation.pdf` (June 11, 2024)  
**Reviewer:** Claude Code (automated)

---

## Summary

| Severity | Count | Status |
|---|---|---|
| CRITICAL | 3 | Author decision required |
| MAJOR | 4 | 2 fixed automatically; 2 require author decision |
| MINOR | 3 | Flagged for awareness |

**Mechanical fixes applied in this session** (no author input needed):
- `### Step 3:` → `\subsection{Step 3:...}` (`main.tex` line ~441)
- `\section{Apendix}` → `\section{Appendix}` (`main.tex`)
- `\multicolumn{6}` → `\multicolumn{4}` in `Main_Tab.tex` and `Main_Tab_V2.tex`
- `\multicolumn{6}` → `\multicolumn{5}` in `ManyIVTab.tex` and `ManyIVTab_V2.tex` (done earlier)

---

## CRITICAL Discrepancies

### C1 — Abstract CET does not match any current table

The abstract cites a CET estimate that is close to but not identical to the nearest matching table entry. This is a stale value.

| Source | CET (DOP) | CI lower | CI upper | % GDP |
|---|---|---|---|---|
| **Abstract** (`main.tex` line 138) | **85,928** | 40,720 | 131,140 | 26% |
| `ManyIVTab.tex` col 1 (AVAD, contiguous) | 86,498 | 40,832 | 132,165 | 26% |
| `Main_Tab.tex` col 3 (AVAD, contiguous, Muni×Yr FE) | 86,498 | 40,832 | 132,165 | 26% |
| `Oracle.tex` col 1 (AVAD, combined IV) | 94,615 | 52,640 | 136,589 | 29% |

**Gap:** 85,928 vs. 86,498 — difference of 570 DOP (~0.7%). Abstract CI also differs by ~100–1,000 DOP from tables.

**Action required:** Author must determine which estimate the abstract should cite (individual IV spec or combined IV), then update the abstract to match the exact numbers from the corresponding table.

---

### C2 — Headline measure: AVAD (paper) vs. AVAC (presentation)

The presentation (June 2024) presents **AVAC-based** results as the headline, while the paper abstract implies **AVAD-based** results. These are different health burden measures.

| Document | Preferred measure | CET | Elasticity | CI |
|---|---|---|---|---|
| **Paper abstract** | AVAD (implied) | 85,928 DOP | not stated | [40,720; 131,140] |
| **Presentation slide** | AVAC | 108,349 DOP | −0.313 (SE 0.111) | [45,458; 171,239] |

- AVAD = AVAC + YLD (disability burden) — broader measure
- AVAC = quality-adjusted life years lost from premature death only — narrower measure

Both are tabulated in the paper (`ManyIVTab.tex` = AVAD; `ManyIVTab_V2.tex` = AVAC). The paper currently does not declare which is "preferred."

**Action required:** Authors must decide which measure is the headline result and which is the robustness check. The introduction/methodology and abstract must be updated to explain this choice explicitly. The conclusion section should state the preferred estimate unambiguously.

---

### C3 — Elasticity not stated in abstract; must match preferred spec once C2 resolved

The abstract does not cite the elasticity estimate. Once C2 is resolved, the key elasticities are:

| Measure | Spec | β̂ | SE | Elasticity | SE |
|---|---|---|---|---|---|
| AVAD | Contiguous (preferred IV) | −0.351 | (0.113) | −0.356 | (0.114) |
| AVAC | Contiguous (preferred IV) | −0.313 | (0.111) | −0.318 | (0.112) |

The presentation cites −0.313 for its preferred spec. If the paper adopts AVAC as preferred, it must cite −0.313; if AVAD, it must cite −0.351.

**Action required:** Once C2 is decided, verify all elasticity references in the body text match the chosen spec and add an elasticity statement to the abstract if appropriate.

---

## MAJOR Discrepancies

### M1 — Per-capita GDP 2016 cited inconsistently (author decision)

Two different values appear in the manuscript:

| Location | Value |
|---|---|
| Abstract (`main.tex` line 138) | **331,253 DOP** |
| Results section (`main.tex` line 457) | **330,949 DOP** |

Difference: 304 DOP. Both affect the GDP % calculations. The correct value should be verified against the ONE (Oficina Nacional de Estadística) official figure for 2016 per-capita GDP.

**Action required:** Check the official source, pick the correct value, and update both occurrences consistently. Also update all downstream `%GDP` percentages (26%, 12.3%, 39.6% in abstract; corresponding values in results section).

---

### M2 — `Main_Tab.tex` / `Main_Tab_V2.tex` multicolumn mismatch (FIXED)

Both files declared `{l c c c}` (4-column tabular) but used `\multicolumn{6}{l}` for panel headers. **Fixed** in this session: changed to `\multicolumn{4}{l}`.

---

### M3 — `### Step 3:` Markdown heading (FIXED)

Line 441 used Markdown `### Step 3:` instead of `\subsection{}`. **Fixed** in this session.

---

### M4 — `\section{Apendix}` misspelling (FIXED)

**Fixed** in this session: `\section{Apendix}` → `\section{Appendix}`.

---

## MINOR Issues

### m1 — Sample size differs across table families

| Table | N |
|---|---|
| `Main_Tab.tex` cols 1–2 | 10,630 |
| `Main_Tab.tex` col 3 | 10,626 |
| `ManyIVTab.tex` all cols | 10,626 |
| `ManyIVTab_V2.tex` all cols | 10,626 |

The four-observation difference (10,630 vs. 10,626) between fixed-effects specifications is not discussed in the paper. This likely reflects a collinearity drop when adding Muni×Year FE. Worth a footnote.

---

### m2 — Oracle (combined IV) CI vs. abstract CI

The Oracle combined-IV CI for AVAD is [52,640; 136,589], which is narrower and shifted right compared to the abstract's [40,720; 131,140] (which is from a single-IV spec). The paper should clarify which CI type appears in the abstract and why.

---

### m3 — Title mismatch (expected, not an error)

| Document | Title |
|---|---|
| Paper | "Estimation of the Marginal Cost of Health Produced by the Dominican Republic Healthcare System" |
| Presentation | "Metodología para la estimación del umbral de costo-efectividad: el caso de República Dominicana" |

Different venues, different languages — expected. No action needed unless a single canonical title is desired.

---

## Full Number Comparison Table

### Abstract claims vs. tables

| Claim | Abstract value | Best-matching table | Table value | Match? |
|---|---|---|---|---|
| CET point estimate | 85,928 DOP | ManyIVTab col 1 | 86,498 DOP | ❌ Stale (~0.7% off) |
| CI lower | 40,720 DOP | ManyIVTab col 1 | 40,832 DOP | ❌ Stale |
| CI upper | 131,140 DOP | ManyIVTab col 1 | 132,165 DOP | ❌ Stale |
| % of per-capita GDP | 26% | 85,928/331,253 | 25.94% | ✅ Consistent (rounds to 26%) |
| CI lower % GDP | 12.3% | 40,720/331,253 | 12.29% | ✅ |
| CI upper % GDP | 39.6% | 131,140/331,253 | 39.59% | ✅ |
| Per-capita GDP 2016 | 331,253 DOP | Results text (line 457) | 330,949 DOP | ❌ Internal inconsistency |

### Presentation preferred spec vs. paper tables

| Claim | Presentation | Paper (ManyIVTab_V2 col 1) | Match? |
|---|---|---|---|
| CET | 108,349 DOP | 108,349 DOP | ✅ |
| CI lower | 45,458 DOP | 45,458 DOP | ✅ |
| CI upper | 171,239 DOP | 171,239 DOP | ✅ |
| Elasticity | −0.313 (SE 0.111) | −0.313 (SE 0.111) | ✅ |
| F-statistic | 155.95 | 155.95 | ✅ |
| N | 10,626 | 10,626 | ✅ |
| Fixed effects | Disease + Muni×Year | Disease + Muni×Year | ✅ |

The presentation's preferred spec matches `ManyIVTab_V2.tex` col 1 (AVAC, contiguous) exactly — all numbers align perfectly.

### Paper AVAD spec vs. presentation AVAD spec

| Claim | Paper (ManyIVTab col 1) | Presentation OLS/IV slide | Match? |
|---|---|---|---|
| IV elasticity | −0.351 (SE 0.113) | −0.351 (SE 0.113) | ✅ |
| OLS elasticity | −0.003 (SE 0.010) | −0.003 (SE 0.010) | ✅ |
| F-statistic | 155.95 | 155.95 | ✅ |

---

## Recommended Author Action List

Priority order:

1. **[C2] Decide: AVAD or AVAC as the preferred measure?**  
   This is the core framing decision. Everything else follows from it.

2. **[C1 + C3] Update the abstract** to cite exact numbers from the chosen table (not stale values). Include the elasticity estimate.

3. **[M1] Verify per-capita GDP 2016** against the official ONE source. Fix both occurrences (`main.tex` lines 138 and 457) to the same value.

4. **[m1] Add a footnote** explaining the 4-observation difference between `Main_Tab` specs 1–2 (N=10,630) and spec 3/ManyIVTab (N=10,626).

5. **[m2] Clarify in the paper** whether the CI in the abstract comes from a single-IV spec or the combined-IV (Oracle) estimator.

---

## What Was Fixed (No Author Decision Needed)

| Issue | Fix applied |
|---|---|
| `### Step 3:` Markdown heading | → `\subsection{Step 3:...}` |
| `\section{Apendix}` misspelling | → `\section{Appendix}` |
| `Main_Tab.tex` `\multicolumn{6}` on 4-col table | → `\multicolumn{4}` |
| `Main_Tab_V2.tex` same | → `\multicolumn{4}` |
| `ManyIVTab.tex` `\multicolumn{6}` on 5-col table | → `\multicolumn{5}` (prior session) |
| `ManyIVTab_V2.tex` same | → `\multicolumn{5}` (prior session) |
| 2 unclosed `\begin{itemize}` | → `\end{itemize}` added |
| 19 backtick-delimited math expressions | → `$...$` or `\[...\]` |

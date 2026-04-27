# Manuscript Review: Estimation of the Marginal Cost of Health Produced by the Dominican Republic Healthcare System

**Date:** 2026-04-27  
**Reviewer:** review-paper skill (adversarial mode, Round 1)  
**File:** `Paper/main.tex`  
**Mode:** `--adversarial`

---

## Summary Assessment

**Overall recommendation: Revise & Resubmit**

This paper makes a genuine and timely contribution: it is, to the authors' knowledge, the first within-country supply-side CET estimate for the Caribbean region. The econometric framework is well-motivated and closely follows the English NHS literature (Claxton 2015; Martin 2021), the four-instrument IV strategy with overidentification testing is sound, and the Lavancier (2016) combined estimator adds a non-trivial methodological contribution. The literature review section is comprehensive and positions the paper correctly within the international HTA evidence base.

However, the paper has three blocking structural problems that must be resolved before submission. First, there is no conclusion section: the paper ends mid-robustness-exercise. Second, the keywords field reads "TBD," which must be filled in. Third, the exclusion restriction for the geographic IV is not adequately defended against disease spillovers across municipal borders. Several major concerns about identification, the combined estimator's weighting logic, quality-weight sensitivity, and the OLS/IV comparison structure are also flagged below.

---

## Strengths

1. **Genuine first-mover contribution.** First within-country supply-side CET for the Caribbean region and for any upper-middle-income country with a mandatory-benefits-plan system analogous to the DR's Plan Básico de Salud.
2. **Four-instrument robustness discipline.** Using contiguous municipalities, 5-NN, 10-NN, and inverse-distance weighting, with overlapping CIs across all four, directly addresses the sensitivity concern raised by Edney (2022).
3. **Overidentification test.** C-statistic of 3.72 (p = 0.44) using the three most distant municipalities as auxiliary instrument provides formal evidence against instrument invalidity.
4. **Lavancier combined estimator.** Combining the four IV estimates to improve precision is a methodological contribution beyond any single country application of the Claxton approach.
5. **Well-positioned literature review.** The section is comprehensive, connects each predecessor study to the present design choice, and is honest about what each paper's identification strategy can and cannot deliver.
6. **Numerically consistent and clean.** Paper compiles without errors; all numerical claims in the text match the source tables (verified independently).

---

## Major Concerns

### MC1 — No conclusion section
- **Dimension:** Argument Structure
- **Issue:** The paper ends at the robustness discussion (C-statistic paragraph). There is no conclusion section summarizing the main finding, stating the policy implication (how should the DR's health authorities interpret 26% of per capita GDP relative to current practice?), or acknowledging limitations. Every journal submission requires a conclusion.
- **Suggestion:** Add a 4–6 paragraph conclusion covering: (1) headline CET estimate and what it implies for the Plan Básico de Salud's current coverage decisions; (2) how the estimate compares to the WHO heuristic and to Colombia's first estimate; (3) key identification assumptions and their limitations; (4) what institutional steps would be required for this estimate to enter formal HTA practice (citing Espinosa 2024); (5) avenues for future work (longer panel, administrative drug-price instruments as in Espinosa 2021).
- **Location:** After the robustness paragraph on the C-statistic (before `\printbibliography`).

### MC2 — Keywords field is "TBD"
- **Dimension:** Presentation
- **Issue:** The abstract ends with `\noindent\textbf{Keywords:} TBD`. This will appear verbatim in the PDF.
- **Suggestion:** Fill in 5–6 keywords, e.g., "cost-effectiveness threshold; supply-side estimation; instrumental variables; Dominican Republic; health technology assessment; marginal cost of health."
- **Location:** Line 131.

### MC3 — Exclusion restriction inadequately defended against disease spillovers
- **Dimension:** Identification
- **Issue:** The geographic exclusion restriction requires that neighboring municipalities' disease-specific spending does not directly affect a focal municipality's health outcomes through any channel other than the focal municipality's own spending. This assumption is violated if communicable diseases cross municipal borders: higher spending on influenza or tuberculosis in municipality A may mechanically reduce transmission to municipality B, improving B's outcomes without any change in B's spending. The paper identifies intermunicipal migration flows as the "primary threat to identification" (C-statistic section) but does not address disease spillovers, which are a distinct and potentially more severe threat.
- **Suggestion:** (1) Run the primary specification excluding ICD categories I (Infectious and parasitic diseases) and X (Respiratory diseases), which have the highest inter-municipal transmission potential. Report whether the elasticity estimate is stable or changes materially. (2) If results are stable, this is reassuring and should be reported as a robustness check. If not, the exclusion restriction needs a more careful defense or a restricted estimating sample. A single paragraph suffices if the check comes back clean.
- **Location:** Section 3.2, exogeneity paragraph; and robustness section.

### MC4 — Lavancier weights are counterintuitive and unexplained
- **Dimension:** Econometrics
- **Issue:** The Oracle table shows that the MSE-minimizing weights assign 12% to the contiguous instrument (which has the highest first-stage F = 155.95 and narrowest CI) and 76% to the 5-NN instrument (second-strongest). This seems counterintuitive: the instrument with the smallest variance should receive the most weight in an MSE-minimizing combination. No explanation for this weighting pattern is given, and a referee will view it as a red flag.
- **Suggestion:** Add a brief explanation in the text (one paragraph or a footnote) deriving why the Lavancier procedure assigned high weight to the 5-NN specification. If the bootstrap covariance matrix reveals that the contiguous and 5-NN estimators are highly correlated, the MSE-minimizing combination can rationally down-weight the contiguous IV even if it has the lowest individual variance — because its covariance with 5-NN reduces the diversification benefit. Show the bootstrap variance-covariance matrix $\hat{\Sigma}$ (perhaps in the appendix) and explain the weight logic.
- **Location:** Results section, paragraph on the Oracle table; and Appendix S: Comb.

### MC5 — Sensitivity of CET to quality-of-life weights not explored
- **Dimension:** Econometrics / Robustness
- **Issue:** The quality-of-life scores used to compute AVAC are adapted from Claxton (2015), adjusted to reflect Caribbean averages from Bailey (2022). The paper acknowledges that these weights are imprecise and that EQ-5D scores may not transfer well to the Dominican Republic's population. However, no sensitivity analysis is conducted on the quality weights. A ±10% uniform shift in quality weights would mechanically change AVAC estimates and therefore the AVAC-based CET (Table 2 and Oracle column 2). This is the kind of sensitivity exercise Edney (2022) explicitly recommends.
- **Suggestion:** Report the AVAC-based CET under three sets of quality weights: (1) Bailey (2022) Caribbean averages as currently used; (2) Claxton (2015) UK weights unadjusted; (3) quality weight = 1 for all ages (equivalent to the YLL approach). If the three CET estimates are within 10% of each other, the quality-weight choice is not a material driver of results.
- **Location:** Results section (brief mention) or Appendix.

### MC6 — OLS vs. IV comparison is relegated to appendix without adequate discussion
- **Dimension:** Argument Structure / Econometrics
- **Issue:** The OLS comparison table (Tab: TabOLS) is in the appendix. The main text mentions that "OLS tends to underestimate the expenditure elasticity" and that "this discrepancy justifies the use of instrumental variables." However, the direction of OLS bias needs more careful reasoning: if sicker municipalities receive more spending AND the IV is valid, IV should produce a more negative elasticity than OLS (because IV removes the attenuation from omitted health-demand confounders). Stating OLS "underestimates" (makes the elasticity less negative) needs to be connected explicitly to the estimated sign. Is the OLS elasticity positive or merely less negative?
- **Suggestion:** Move the OLS comparison table to the main body (or at least cite column numbers from the appendix table clearly in the text). Add one sentence stating the OLS elasticity value and confirming the expected bias direction: "OLS yields an elasticity of [X], substantially closer to zero than the IV estimate of −0.356, consistent with upward attenuation bias driven by demand-side confounders."
- **Location:** Results section, robustness paragraph; and Appendix.

### MC7 — "Table A.6" cross-reference is inconsistent
- **Dimension:** Presentation
- **Issue:** The main text at line 528 refers to "column 5 of Table A.6 in the appendix." The overidentification table is labeled `\label{Tab: Sargan}` and captured as Table A.5 or A.6 depending on how the appendix counter sequences. This numeric cross-reference can easily be wrong and will be flagged by any referee who checks.
- **Suggestion:** Replace the hard-coded "Table A.6" with a LaTeX reference: `Table~\ref{Tab: Sargan}`. Check that all appendix table references use `\ref{}` rather than hard-coded numbers.
- **Location:** Line 528.

---

## Minor Concerns

### mc1 — "Table A.6" is the only hard-coded cross-reference; check all others
- Replace any remaining `Table A.X` or `Figure A.X` hard references with `\ref{}` macros.

### mc2 — "arcsinh" vs. "hyperbolic arcsine" terminology inconsistent
- The text alternates between "arcsinh" (technical shorthand) and "hyperbolic arcsine" (spelled out). Pick one form for the running text and use the shorthand only in equations.

### mc3 — Dataset observation counts inconsistency flagged but not fully resolved
- Abstract says 18,605,361 medical attention registries (2016-2019); mortality data is 340,198 deaths, but study period is limited to 2016-2019. The footnote about N = 10,626 vs. 10,630 (singletons) is correct and should be retained. Consider adding a one-sentence bridge between the raw data counts (340k deaths, 18.6M attention records) and the analytic sample (10,626 disease-municipality-year cells) so the reader understands the aggregation logic without having to reconstruct it.

### mc4 — Plan Básico de Salud described but current CET practice not stated
- The Introduction motivates a CET for coverage decisions but never states what reference threshold (if any) the Dominican health system currently applies for technology adoption decisions. Even a sentence ("the Ministry of Health currently applies no formal economic evaluation threshold") would sharpen the policy motivation.

### mc5 — USD conversion not provided for international comparison
- The CET is reported in DOP throughout. For international comparison (Colombia's $4,487.5 per YLL, UK's £12,936, Australia's AUD 28,033), one sentence with the approximate USD equivalent of 86,498 DOP at 2016 exchange rates would help readers unfamiliar with DOP calibrate the result.

### mc6 — Footnote 1 acronyms defined but not used
- Footnote 1 defines "YLL — Years of life lost, DALYs — disability-adjusted life year, SEYLL — Standard expected years of life lost" but the paper uses "AVAD" for disability-adjusted life years throughout (not "DALYs"). Either AVAD should be defined in this footnote or the footnote should define AVAD instead of DALYs.

### mc7 — "between 86,498 and 107,824" should use comma notation consistently
- The preferred specification (column 1) yields 86,498 DOP and column 4 yields 107,824 DOP. These are the endpoints of the "range" but they are not confidence interval endpoints — they are point estimates from different IV strategies. The sentence "the cost-effectiveness threshold lies between 86,498 and 107,824 Dominican pesos" could mislead a reader into thinking this is a CI. Clarify with "point estimates across the four IV strategies range from 86,498 to 107,824 DOP."

---

## Referee Objections

### RO1 — Disease spillovers invalidate the exclusion restriction for communicable categories
**Why it matters:** If higher neighbor spending on disease j reduces disease j transmission into the focal municipality, then $Z_{m,j,t}$ affects $\text{TAVPE}_{j,m,t}$ directly — the exclusion restriction fails. This is not the same as migration (which affects the demand for services) but a direct epidemiological pathway. The C-statistic test cannot detect this because the auxiliary instrument (3 most distant) also uses geographic neighbors and is subject to the same critique at a longer range.
**How to address it:** Exclude communicable disease categories (ICD-I, ICD-X, ICD-II) from the main specification and verify that the elasticity estimate is stable. Alternatively, argue explicitly that the disease-municipality-year fixed effects structure absorbs common regional disease shocks, and that the residual cross-disease, within-municipality-year variation in instrument spending is not driven by transmission channels.

### RO2 — The paper lacks a conclusion section
**Why it matters:** No journal in the health economics or public economics space will desk-accept a paper without a conclusion. The paper's policy relevance is its strongest selling point, but that relevance is never stated explicitly: what does a CET of 86,498 DOP imply for a specific current coverage decision in the DR? What is the next step for the Ministry of Health?
**How to address it:** Write a 4–6 paragraph conclusion section (see MC1 above).

### RO3 — Why does the MSE-minimizing combination heavily weight the 5-NN instrument over the contiguous instrument?
**Why it matters:** The contiguous instrument has F = 155.95 (the highest among the four) and a narrower individual CI. Under standard minimum-variance combination logic, it should receive the most weight. Assigning 76% to 5-NN and only 12% to contiguous municipalities looks like a numerical artifact of the bootstrap estimation of $\hat{\Sigma}$. A referee will suspect that the bootstrap VCV is poorly conditioned and that the combined weights are unstable.
**How to address it:** Report $\hat{\Sigma}$ and the individual bootstrap standard errors for each IV estimator. Show that the high cross-estimator correlations (not just individual variances) drive the weight pattern. If possible, report bootstrap confidence intervals for the weights themselves.

### RO4 — How sensitive is the AVAC-based CET to the choice of quality-of-life adjustment?
**Why it matters:** The Bailey (2022) Caribbean adjustment is the authors' own contribution but relies on a very thin empirical base (5 countries, none of which is the Dominican Republic). A referee will ask whether the AVAC result is driven by the quality-weight choice. If the answer is "not very sensitive," this is a reassuring robustness check that should be shown; if the answer is "yes, sensitive," this is a material limitation.
**How to address it:** Three-point sensitivity exercise (see MC5 above).

### RO5 — What is the current HTA threshold in the Dominican Republic, and what does this estimate change?
**Why it matters:** The policy value of the paper depends entirely on whether 86,498 DOP is above or below whatever threshold is currently in use (explicitly or implicitly). If the DR has no formal threshold, the paper should say so and explain what adoption would require institutionally. If there is an informal threshold (e.g., 1× GDP per capita), the paper should compare directly.
**How to address it:** One paragraph in the Introduction or Conclusion stating the current DR practice and benchmarking the estimate against it.

---

## Specific Comments

- **Line 178 — "The next section describes the data, followed by the three-step estimation procedure"**: The literature review section (Section 2) ends here, but the next section is Methodology (Section 3), which starts with Data as the first subsection. The sentence refers to a "data section" that does not exist as a separate section. Either promote Data to its own `\section{}` or remove the sentence.

- **Line 288 — "In cases where there are multiple causes of death, we take the one with the highest mortality in the Dominican Republic according to … WHO (2022)"**: This decision rule (taking highest-mortality disease as the primary cause) is a non-trivial methodological choice that could affect the burden attribution and therefore the elasticity estimates across disease categories. A brief justification would help (e.g., why not primary-listed cause of death?).

- **Line 451 — "A brief explanation of the method is included in Appendix \ref{S: Comb}"**: The appendix section currently provides the mathematical derivation but not the intuition. Adding one sentence of economic intuition ("the weights are chosen so that the combined estimator has lower expected squared error than any single-IV estimator, exploiting the correlation structure across IV strategies") would serve the reader who skips the math.

- **Line 457 — CET formula**: The formula is presented correctly, but the derivation linking it back to the arcsinh elasticity adjustment (in Appendix A.2) is not cross-referenced here. Add `(see Appendix~\ref{S: Cálculo})` directly after the formula.

- **Line 463 footnote — singletons**: "The four missing observations relative to specifications with separate municipality and year fixed effects ($N = 10{,}630$) correspond to municipality-year cells with a single observation (singletons)." This is a standard issue with two-way FE but worth clarifying: are there 4 singleton municipality-years or 4 singleton disease-municipality-years? The latter is more plausible given the panel structure.

---

## Summary Statistics

| Dimension | Rating (1–5) |
|---|---|
| Argument Structure | 3 — solid reasoning, but missing conclusion and policy benchmark |
| Identification | 3 — four-instrument IV is commendable; disease-spillover gap is material |
| Econometrics | 4 — specification is appropriate; combined estimator adds value; weight transparency needed |
| Literature | 5 — comprehensive and accurate positioning |
| Writing | 4 — professional and precise; minor inconsistencies remain |
| Presentation | 3 — numerically clean; missing conclusion, TBD keywords, one hard-coded cross-reference |
| **Overall** | **3.7** |

---

## Round 1 Verdict

**NOT APPROVED.** Three blocking issues (MC1: no conclusion, MC2: TBD keywords, MC7: hard-coded cross-reference) must be fixed before re-audit. Three major concerns (MC3: disease spillovers, MC4: Lavancier weight explanation, MC5: quality-weight sensitivity) require either new analysis or explicit defensive argument. Two other major concerns (MC6: OLS discussion, mc4: current DR practice) require prose additions only.

**Estimated effort:** Low-to-medium. The blocking fixes are mechanical. The disease-spillover robustness check (MC3) requires re-running the main regression excluding ICD-I/X/II — if results are stable this adds one column and one sentence; if not, it opens a larger identification discussion. The Lavancier weight explanation (MC4) requires reporting $\hat{\Sigma}$ from existing bootstrap runs. The quality-weight sensitivity (MC5) requires re-running the AVAC estimation under two alternative weight assumptions.

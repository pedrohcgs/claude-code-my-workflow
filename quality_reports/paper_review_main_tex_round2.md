# Manuscript Review: Estimation of the Marginal Cost of Health Produced by the Dominican Republic Healthcare System

**Date:** 2026-04-27
**Reviewer:** review-paper skill (adversarial mode, Round 2)
**File:** Paper/main.tex

---

## Round 1 Fix Verification

| Round 1 Issue | Status |
|---|---|
| MC1 — No conclusion section | RESOLVED — full 4-paragraph conclusion added (Section 5, lines 530–541) |
| MC2 — Keywords field "TBD" | RESOLVED — six keywords filled in (line 131) |
| MC3 — Exclusion restriction: disease spillovers not defended | PARTIAL — conclusion acknowledges the concern for infectious/respiratory diseases (line 536) but no robustness check excluding ICD-I/X/II was run |
| MC4 — Lavancier weights counterintuitive and unexplained | PARTIAL — qualitative explanation added in Results (line 503) citing the contiguous/5-NN overlap logic; bootstrap VCV matrix $\hat{\Sigma}$ not reported numerically |
| MC5 — Quality-weight sensitivity not explored | NOT ADDRESSED — no three-point sensitivity exercise; conclusion only notes the weights are an uncertainty source |
| MC6 — OLS vs IV comparison inadequately discussed | RESOLVED — OLS elasticity value stated explicitly (−0.003, SE 0.010) with bias direction explained |
| MC7 — "Table A.6" hard-coded cross-reference | RESOLVED — replaced with `\ref{Tab: Sargan}` (line 528) |
| mc4 — Current DR HTA practice not stated | RESOLVED — Introduction now explicitly states DR lacks a formal CET (line 152) |
| mc5 — USD conversion not provided | RESOLVED — footnote provides USD~1,860 equivalent at 2016 exchange rates (line 466) |
| mc6 — Footnote 1 defines DALYs but paper uses AVAD | NOT ADDRESSED — footnote 1 still defines "DALYs — disability-adjusted life year" while the paper uses AVAD throughout without defining it in the footnote or cross-referencing the later definition |

---

## Summary Assessment

**Overall recommendation: Revise & Resubmit**

The paper has made substantial progress since Round 1. The three blocking structural problems—missing conclusion, TBD keywords, and hard-coded cross-reference—have all been corrected. The conclusion section is genuinely good: it summarizes the headline estimate clearly, benchmarks against the WHO heuristic and Colombia, acknowledges key identification assumptions including the disease-spillover concern, and situates the paper within the HTA adoption literature. The OLS discussion has been sharpened and the current DR HTA practice is now explicitly stated. These were the most urgent fixes and they have been executed competently.

However, three substantive problems remain unresolved and will generate referee objections at any health economics or public economics journal. First, the quality-weight sensitivity analysis (MC5 / RO4) was never run: the paper still reports only Bailey-adjusted Caribbean weights with no comparison to UK weights or quality-weight-free YLL. Second, the bootstrap variance-covariance matrix driving the Lavancier weights is still not reported (MC4 / RO3), leaving the weight-concentration result (76% to 5-NN) empirically unsubstantiated. Third, a previously undetected problem is now visible in the appendix: columns 3 and 4 of Table Sargan (the validity table) show Kleibergen-Paap F-statistics of 9.80 and 13.79, both below the 16.38 threshold the paper uses as its relevance benchmark. The text never acknowledges this weakness, instead claiming instrument sufficiency "across all specifications."

Beyond these carry-forward concerns, this read reveals four new issues. The most serious is a notational inconsistency at the core of the measurement framework: the symbol QAYLL is introduced in equation (3.1) (line 332) to denote quality-adjusted YLL, but it is never referenced again—the paper subsequently uses AVAC to fill the same role without ever equating the two. A reader who parses the methodology carefully cannot tell whether QAYLL = AVAC or whether they are distinct quantities. There is also a pervasive language-mixing problem: the main text and table captions are in English, but all interior table rows, column headers, and panel labels in the generated .tex table files are in Spanish (e.g., "Umbral [Miles DOP]", "Pesos otorgados", "Municipios contiguos", "Tipo de enfermedad"). While the paper's bilingual character is intentional, the mixing is asymmetric in a way that will appear unpolished to English-language journal referees.

---

## Major Concerns

### MC1 — Quality-weight sensitivity analysis absent (carry-forward from R1 MC5)
- **Dimension:** Econometrics / Robustness
- **Issue:** The AVAC-based CET (Table TabIV_V2, Oracle column 2) uses quality weights adapted from Bailey (2022) Caribbean averages applied to Claxton (2015) UK scores. The paper acknowledges in the conclusion (line 536) that this "introducing uncertainty into the AVAC-based results," but presents no evidence on the magnitude of that uncertainty. As RO4 asks: is the AVAC-based result driven by the Caribbean adjustment, or would UK weights or quality-weight-free YLL produce a similar CET? Without this three-point check, the AVAC-based columns in Tables TabIV_V2 and Oracle column 2 are uninterpretable as robustness checks—they are just alternative results with unknown sensitivity to an acknowledged parameter choice.
- **Required fix:** Run the AVAC-based CET under (1) Bailey-adjusted Caribbean weights as currently used, (2) Claxton 2015 UK weights unadjusted, (3) quality weight = 1 for all ages. Report as a footnote or short appendix table. If the three estimates are within 10%, the quality weight choice is not a material driver.
- **Location:** Results section; Appendix.

### MC2 — Instrument weakness in validity table never acknowledged (new)
- **Dimension:** Econometrics / Robustness
- **Issue:** The text at line 464 states that "the instrument is sufficiently relevant across all specifications, as the Kleibergen-Paap F-statistic exceeds the threshold of 16.38 recommended by StockYogo2005." This is true for Table TabIV (the main table, columns 1–4: F = 155.95, 54.67, 18.73, 26.98). However, in Table Sargan (the instrument validity / C-statistic table, Appendix), columns 3 and 4 show F = 9.80 and F = 13.79, both below 16.38. These are the specifications that combine the ten-nearest-neighbor instrument or the inverse-distance instrument with the auxiliary "three most distant" instrument. The paper text (line 526) acknowledges the auxiliary is "considerably weaker" but never acknowledges that two combined specifications fall below the relevance threshold. A referee who reads the appendix table will flag this immediately.
- **Required fix:** Add a sentence in the robustness paragraph acknowledging that columns 3 and 4 of Table Sargan show below-threshold F-statistics due to the weaker auxiliary instrument, and explain why this does not undermine the validity test (the C-statistic itself is computed from column 5, which has F = 71.03). Alternatively, note that the primary identification claims rest on columns 1 and 2 of the validity table (F = 119.90 and 35.65) and column 5.
- **Location:** Results section, robustness paragraph (around line 528); Table Sargan note.

### MC3 — Lavancier bootstrap VCV matrix not reported (carry-forward from R1 MC4/RO3)
- **Dimension:** Econometrics
- **Issue:** The qualitative explanation of the 5-NN weighting (line 503) has been added and improves the paper. However, the claim that the contiguous and 5-NN instruments "share a large fraction of their identifying variation" is asserted without evidence. The bootstrap VCV matrix $\hat{\Sigma}$ that drives the optimal weights is still not reported anywhere. A referee will ask to see $\hat{\Sigma}$ (or at least the pairwise correlations between the four IV estimators from the bootstrap) to verify that the 76%/12% weight distribution is numerically rational rather than an artifact of a poorly conditioned matrix. The appendix (S: Comb) gives the formula for $\lambda^*$ but reports no empirical values.
- **Required fix:** Report $\hat{\Sigma}$ (or at minimum the bootstrap correlation matrix of the four IV estimators) in Appendix S: Comb. This can be a 4×4 table with bootstrap standard errors on the diagonal and correlations off-diagonal. If the contiguous–5NN correlation is close to 1, the weight pattern is fully explained.
- **Location:** Appendix S: Comb (after line 631); and referenced from the qualitative explanation at line 503.

### MC4 — QAYLL notation introduced and immediately abandoned (new)
- **Dimension:** Writing Quality / Notation Consistency
- **Issue:** At line 330–332, the paper introduces the notation QAYLL to represent quality-adjusted years of life lost. This symbol appears exactly once, in equation (3.1). Thereafter the paper uses AVAC to refer to quality-adjusted mortality burden (see line 357: $\text{AVAD}_i = \text{AVAC}_i + \text{YLD}_{i,E_i}$) and the later tables (TabIV_V2, Oracle) also use AVAC as an alternative health measure. The paper never states that QAYLL = AVAC or provides any transition between the two notations. This is a substantive notation error that will confuse any careful reader of the methodology section. The equation at line 332 is also technically ambiguous: it sums from age $M_i$ (the observed age of death) to $L_i$ (life expectancy), but this is the quality-weighted version of YLL—calling it QAYLL is reasonable, but then the paper must trace how this becomes AVAC in subsequent steps.
- **Required fix:** Either (a) rename QAYLL to AVAC throughout and add a definitional sentence "We refer to this quantity as AVAC (años de vida ajustados por calidad) in what follows," or (b) retain QAYLL, add a bridge sentence "AVAC denotes QAYLL as computed above," and use QAYLL consistently in the AVAD = AVAC + YLD formula. Either choice must be applied uniformly across all equations, tables, and table notes.
- **Location:** Line 332 (equation), line 357 (AVAD formula), all references to AVAC thereafter.

---

## Minor Concerns

### mc1 — Pervasive language mixing in table internals (new)
- **Dimension:** Presentation
- **Issue:** Main text and table captions are in English, but interior table content (column headers, panel labels, row labels) across at least seven generated .tex files remains in Spanish: Oracle.tex ("Umbral [Miles DOP]", "Pesos otorgados", "AVAD estandarizado"), ManyIVTab.tex ("Municipios contiguos", "Parámetro modelo", "Tipo de enfermedad"), InstrumentValidityIVTab.tex, First_Stage.tex, QALY.tex, BurdenDisease.tex, and table_A1.tex. While the paper is intentionally bilingual, this creates an asymmetry where the English prose consistently references Spanish table elements. Specifically, the table note for Oracle (line 514) refers to "Column (1)" as the AVAD measure, while the actual column header inside the table says "AVAD estandarizado"—this is fine, but "Umbral [Miles DOP]" in the body rows is left untranslated, and the Oracle table note's phrasing "standardized disability-adjusted life years" does not match the Spanish column header. For an English-language submission, table internals should be in English; for a Spanish-language submission, the text should be in Spanish. A mixed submission will receive a desk note from most journals.
- **Suggested fix:** Translate table interiors to English for English-language submission (e.g., "Umbral [Miles DOP]" → "Threshold [Thousands DOP]", "Municipios contiguos" → "Contiguous municipalities", "Tipo de enfermedad" → "Disease type").

### mc2 — Structure description in Introduction not updated to reflect new section (new)
- **Dimension:** Argument Structure / Writing
- **Issue:** Line 154 reads: "The final section presents the results and main conclusions." The paper now has separate Results (Section 4) and Conclusion (Section 5) sections. The sentence should be updated to read: "The following section presents the results, and the final section draws the main conclusions."
- **Location:** Line 154.

### mc3 — Abstract reports elasticity of −0.356 but text comparisons use −0.351 (new)
- **Dimension:** Writing Quality / Internal Consistency
- **Issue:** The abstract states the expenditure elasticity is −0.356 (Panel B of Table TabIV, column 1). The OLS/IV comparison paragraph (line 521) then states "compared to the IV estimate of −0.351 in the preferred specification." The value −0.351 is the Panel A model parameter, not the elasticity. Both quantities are from column 1 of Table TabIV, but they are on different scales. The text should either compare OLS to the Panel B elasticity (−0.356 vs. the OLS elasticity, which is not reported separately for OLS) or clarify that the comparison is at the model-parameter level (Panel A), not the elasticity level (Panel B). The current mixing will confuse readers who notice that −0.356 and −0.351 are presented interchangeably.
- **Location:** Line 521.

### mc4 — Footnote 1 still defines DALYs but paper uses AVAD throughout (carry-forward from R1 mc6)
- **Dimension:** Writing Quality
- **Issue:** Footnote 1 (line 144) defines "DALYs — disability-adjusted life year" but the paper uses the acronym AVAD (likely the Spanish equivalent, Años de Vida Ajustados por Discapacidad) for the same concept. The paper never defines AVAD in the footnote or connects it to DALYs. A reader encountering "AVAD" before Section 3 (which defines it implicitly at line 357) has no definitional anchor.
- **Suggested fix:** Either replace "DALYs" with "AVAD (disability-adjusted life years)" in footnote 1, or add "AVAD — Años de Vida Ajustados por Discapacidad (disability-adjusted life years)" to the existing footnote.
- **Location:** Footnote 1, line 144.

### mc5 — OLS table (Tab: TabOLS) column headers present IV parameter but call it OLS (new)
- **Dimension:** Presentation
- **Issue:** In Table OLS_Tab.tex, Panel A is labeled "Ordinary least squares" and Panel B is labeled "Two-stage least squares." The column headers use English ("Contiguous municipalities", "Five nearest neighbors"...) while the fixed effects rows use Spanish ("Tipo de enfermedad", "Municipio × Año"). Beyond the language mix, this is one of the appendix tables that is referenced in the main text but never properly introduced with the column numbering used elsewhere. The text at line 521 references "Table TabOLS" by label only; the note for Table TabOLS does not cross-reference Table TabIV to allow the reader to verify the TSLS rows match.
- **Suggested fix:** Add "TSLS parameters match Table~\ref{Tab: TabIV} Panel~A" to the table note. Translate the fixed-effects row labels to English.
- **Location:** OLS_Tab.tex; main text reference at line 521.

### mc6 — "hyperbolic arcsine" (spelled out) vs. "arcsinh" (shorthand) terminology still mixed
- **Dimension:** Writing Quality
- **Issue:** Footnote at line 409 uses "hyperbolic arcsine"; Appendix S: Cálculo heading (line 640) uses "arcsinh-arcsinh model." This is the mc2 concern from Round 1. While both forms appear only twice, consistency is expected in a published paper. The shorthand "arcsinh" is preferred in technical writing when the mathematical form $\sinh^{-1}$ is already established.
- **Suggested fix:** Replace "hyperbolic arcsine" in the footnote at line 409 with "arcsinh (inverse hyperbolic sine)."
- **Location:** Line 409 footnote; line 640.

---

## Referee Objections

### RO1 — Disease spillover robustness check still missing (carry-forward from R1 RO1)
**Why it matters:** The conclusion now acknowledges (line 536) that the exclusion restriction "deserves further scrutiny for infectious and respiratory diseases," which is an honest limitation statement. But a referee will note that this acknowledgment was the minimum possible response—it is a limitation statement, not a robustness check. The C-statistic test cannot detect disease-spillover violations because the auxiliary "three most distant municipalities" instrument is also a geographic instrument and subject to the same pathology at longer range. The only credible response is to estimate the main specification on the subsample excluding ICD categories I (infectious), II (neoplasms—some communicable), and X (respiratory), and show that the elasticity estimate is stable. If the result is clean, the acknowledgment in the conclusion stands as a limitation that has been empirically assessed. If the result is not clean, the paper has a material identification problem.

**How to address it:** Run the main IV specification (contiguous municipalities) on the sample excluding ICD-I and ICD-X (and optionally ICD-II). Report the elasticity and implied CET. If within 15% of the full-sample estimate, add a sentence: "Excluding disease categories with high communicable transmission potential (ICD-I: infectious, ICD-X: respiratory) yields an elasticity of [X], implying a CET of [Y], consistent with the full-sample preferred estimate." One column in the appendix suffices.

### RO2 — Quality-weight sensitivity is acknowledged but not quantified (carry-forward from R1 RO4)
**Why it matters:** The Bailey (2022) Caribbean adjustment is the authors' own contribution and rests on a very thin empirical base (five countries, none of which is the Dominican Republic). The conclusion says this "introduces uncertainty" but provides no information on the magnitude of that uncertainty. The AVAC-based columns in Tables TabIV_V2 and Oracle (column 2) are therefore uninterpretable: a referee cannot tell whether the higher AVAC-based CET (108,349–138,180 DOP) reflects the quality weight choice or the health measure choice. Without a three-point weight sensitivity, the AVAC robustness columns add noise rather than signal.

**How to address it:** Run the AVAC exercise under three weight assumptions: Bailey-adjusted Caribbean (current), Claxton 2015 UK, and uniform quality weight = 1. Report in a short appendix table or footnote. If the range is narrow, the Bailey adjustment is vindicated; if wide, this is a material uncertainty that the paper must discuss explicitly.

### RO3 — Kleibergen-Paap F below 16.38 in two validity-table columns not acknowledged
**Why it matters:** The paper's own relevance benchmark is F > 16.38 (StockYogo2005). Columns 3 and 4 of the Sargan validity table (Appendix) show F = 9.80 and F = 13.79. A referee who reads the appendix will immediately flag this as an internal inconsistency: the paper claims the threshold is exceeded "across all specifications" but two appendix specifications are below it. This is not fatal—the C-statistic is correctly computed from column 5 (F = 71.03)—but the inconsistency must be addressed explicitly.

**How to address it:** Add a parenthetical in the robustness discussion: "Note that adding the weaker auxiliary instrument causes the combined relevance F-statistic to fall below 16.38 in columns 3 and 4 of Table~\ref{Tab: Sargan}; the validity inference is drawn from column 5, which retains high relevance (F = 71.03)."

### RO4 — Bootstrap VCV matrix for Lavancier combination not reported
**Why it matters:** The authors claim the high 5-NN weight reflects high correlation between the contiguous and 5-NN IV estimators (line 503). This is a plausible explanation, but it is asserted rather than shown. The bootstrap VCV matrix $\hat{\Sigma}$ is a 4×4 matrix that would confirm or deny this. Without it, the reviewer's concern from Round 1 (RO3 there) stands: the weight pattern looks like a numerical artifact of a poorly conditioned bootstrap estimate.

**How to address it:** Report $\hat{\Sigma}$ in Appendix S: Comb. A 4×4 table with standard errors on the diagonal and off-diagonal elements will resolve this. If the contiguous–5NN off-diagonal element is large, the qualitative explanation is confirmed.

---

## Specific Comments

- **Line 154 — roadmap sentence needs updating.** The sentence "The final section presents the results and main conclusions" refers to a single section that has since been split into Results and Conclusion. Replace with: "The following section presents the results, and the concluding section draws the main conclusions and directions for future research."

- **Line 332 — QAYLL equation.** The notation QAYLL is defined here but abandoned immediately. At minimum, add after the equation: "We refer to this quality-adjusted mortality burden as AVAC in what follows." This single sentence closes the notation gap.

- **Line 357 — AVAD formula.** The formula AVAD = AVAC + YLD is a key claim: AVAD (the full DALY-equivalent) equals AVAC (quality-adjusted mortality burden) plus YLD (morbidity burden). This formula is stated without derivation or citation to where AVAC is formally defined. Given that QAYLL was just defined in equation (3.1) and is now being called AVAC, the reader needs a one-sentence bridge.

- **Line 521 — OLS vs IV comparison parameter levels.** "The OLS parameter estimate is −0.003 (SE = 0.010), statistically indistinguishable from zero, compared to the IV estimate of −0.351 in the preferred specification." The comparison is at the model-parameter level (Panel A), not the elasticity level (Panel B). The abstract uses −0.356 (Panel B elasticity). This inconsistency should be noted: either add "(Panel A model parameter)" after −0.351, or compare at the elasticity level throughout.

- **Oracle table (Tables/Oracle.tex) — Spanish headers.** The Oracle table caption (line 507) is in English ("Cost-effectiveness threshold, combining IV estimators") and the table notes (line 514) are in English, but the column headers inside Oracle.tex ("AVAD estandarizado", "AVAC estandarizado") and the row labels ("Umbral [Miles DOP]", "Pesos otorgados") are in Spanish. This mismatch will be visible in the PDF and is the most prominent of the language-mixing instances because Oracle is the headline table for the Lavancier combination.

---

## Summary Statistics

| Dimension | Rating (1–5) |
|---|---|
| Argument Structure | 4 — conclusion added and well-written; roadmap sentence needs updating |
| Identification | 3 — disease spillover still unaddressed empirically; validity table F weakness unacknowledged |
| Econometrics | 3 — combined estimator well-motivated but VCV unreported; quality-weight sensitivity absent |
| Literature | 5 — no change needed; comprehensive and accurate |
| Writing | 3 — QAYLL/AVAC notation inconsistency is a structural problem; OLS/elasticity level confusion |
| Presentation | 3 — pervasive Spanish/English table mixing; language-consistency gap prominent in Oracle table |
| **Overall** | **3.5** |

---

## Round 2 Verdict

**NOT APPROVED.**

Blocking items:

1. **MC1** (Quality-weight sensitivity absent) — the AVAC robustness columns cannot be interpreted without it.
2. **MC2** (F-statistic weakness in validity table unclaimed) — internal inconsistency with the paper's own relevance benchmark.
3. **MC4** (QAYLL/AVAC notation inconsistency) — a structural notation error in the core measurement section.

Non-blocking but required before submission:
- MC3 (Bootstrap VCV for Lavancier weights not shown) — addressed partially but RO4 will still object.
- mc1 (Language mixing in table internals) — will receive a desk editorial note.
- Disease spillover robustness check (RO1) — still the most likely referee objection at a health economics journal.

**Estimated effort (Round 3):** Low-to-medium. MC4 (notation fix) and MC2 (one sentence acknowledging weak F in columns 3–4) are mechanical. MC1 (quality-weight sensitivity) requires re-running AVAC under two alternative weight assumptions and reporting results. The language-mixing fix (mc1) requires editing seven .tex table files.

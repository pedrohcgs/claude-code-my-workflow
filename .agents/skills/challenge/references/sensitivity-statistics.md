# Named sensitivity statistics — turning "challenge the assumption" into a number

An identifying assumption cannot be tested. It can be **bounded**. Each statistic below answers
a specific question, has a defensible reference implementation, and should be reported with the
benchmark that makes it interpretable — a robustness value with no comparison is decoration.

**Never reimplement these.** Drive the canonical package. A hand-rolled sensitivity statistic
is an unqualified check.

---

## Unobserved confounding

### E-value
**Question:** how strong would an unmeasured confounder's associations with both treatment and
outcome have to be, on the risk-ratio scale, to explain away the estimate?
**Report:** the E-value for the point estimate **and** for the CI limit nearest the null. The
second is the one that matters — an E-value of 2.1 with a CI-limit E-value of 1.02 is fragile.
**Implementation:** closed form; `EValue` (R).
**Watch:** defined on the risk-ratio scale. Converting a linear-model coefficient requires an
approximation — state which one.

### Cinelli–Hazlett robustness value (RV)
**Question:** what share of residual variance in both treatment and outcome would a confounder
need to explain to bring the estimate to zero (or past a threshold)?
**Report:** `RV_{q=1}`, and the **benchmark** — the RV expressed as a multiple of an observed
covariate's strength ("a confounder 3.2× as strong as region fixed effects").
**Implementation:** `sensemakr` (R), closed form from a t-value and residual df.
**Watch:** RV is about *linear* confounding in the estimated model. It says nothing about
functional-form error.

### Oster δ
**Question:** how large must selection on unobservables be, relative to selection on
observables, to drive the coefficient to zero?
**Report:** δ **with the assumed `R²max`** — δ is meaningless without it. State the rule used —
commonly `R²max = min(1.3 × R̃², 1)`, with Oster's cap, since an R²max above 1 is impossible —
and show sensitivity to it.
**Implementation:** `psacalc` (Python), `robomit` (R).
**Watch:** assumes proportional selection. Widely reported, frequently reported without its
`R²max`, which makes it uninterpretable.

---

> **Design-specific sections are deliberately absent** for the causal-identification designs
> (unvetted-methods veto): populate them from your field's canonical sources after vetting.

---

## Reporting contract

For each statistic report: **the value**, **the benchmark that makes it interpretable**,
**the implementation and version**, and whether it was `executable-here` or
`describe-and-cite`.

A sensitivity analysis that reports only favourable statistics is not a sensitivity analysis.
If a bound is uncomfortably tight, that is the finding — the strongest sentence in a robustness
section is usually the one that retires the author's own preferred interpretation.


---
paths:
  - "scripts/**/*.R"
  - "scripts/**/*.do"
  - "scripts/**/*.py"
---

# Inference & Robustness (multiple testing + researcher degrees of freedom)

Advisory standards for the inference choices that decide whether a result survives a sharp referee — consolidated so they don't live only as a one-line objection. Applies to empirical analysis scripts; the manuscript-side check is in [`$review-paper`](../../.agents/skills/review-paper/SKILL.md) (dimension 3) and the design-side commitment in [`$preregister`](../../.agents/skills/preregister/SKILL.md).

## Multiple hypothesis testing

When a paper tests **many hypotheses** (several outcomes, subgroups, treatment arms, or specifications), unadjusted p-values overstate significance. Decide the correction **by what you control and pre-register the family**:

- **Family-wise error rate (FWER)** — control the probability of *any* false rejection. Use when even one false positive is costly (a headline claim).
  - **Romano–Wolf** stepdown (resampling, exploits cross-equation dependence and is less conservative than Bonferroni; R `wildrwolf`) is a strong default for a small family.
  - Holm–Bonferroni as a distribution-free fallback; plain Bonferroni only for a tiny family.
- **False discovery rate (FDR)** — control the *expected share* of false rejections among rejections. Use for **many** hypotheses where some false positives are acceptable (screening, heterogeneity scans).
  - Benjamini–Hochberg; **Anderson (2008) sharpened two-stage q-values** is common in applied micro.
- **Pre-register the family and the correction** (the unit of correction is a researcher degree of freedom). Report both unadjusted and adjusted; never pick the family that makes the result survive.

## Researcher degrees of freedom / specification robustness

A single specification is a point on a garden of forking paths. Make the robustness explicit:

- **Show the specification is not cherry-picked** — a specification/multiverse curve (sweep the defensible covariate sets, sample restrictions, functional forms; report the distribution of estimates, not one).
- **Leave-one-out / influential observations** — confirm the result isn't driven by a few units or one cluster.
- **Inference robustness** — alternative clustering levels, wild-cluster bootstrap with few clusters (`fwildclusterboot`/`boottest`), randomization inference where the design supports it.

## Reporting

- State the **family** and the **correction method** up front; report unadjusted *and* adjusted p-values/q-values.
- A robustness check that only ever confirms the headline is theatre — report the spec where the result *weakens*, and interpret it.

## Cross-references
- [`.agents/skills/review-paper/SKILL.md`](../../.agents/skills/review-paper/SKILL.md) · [`.agents/skills/preregister/SKILL.md`](../../.agents/skills/preregister/SKILL.md) · [`.agents/skills/power-analysis/SKILL.md`](../../.agents/skills/power-analysis/SKILL.md).

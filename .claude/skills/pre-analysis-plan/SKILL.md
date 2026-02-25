---
name: pre-analysis-plan
description: Draft pre-analysis plans for AEA RCT Registry, OSF, or EGAP standards. Specify primary and secondary outcomes, subgroup analyses, multiple testing corrections, power calculations, and data exclusion rules. Use when asked to "write a PAP", "pre-analysis plan", "register the trial", or "OSF pre-registration".
disable-model-invocation: true
argument-hint: "[research-spec file OR topic OR 'interactive' for guided interview]"
allowed-tools: ["Read", "Grep", "Glob", "Write"]
---

# Pre-Analysis Plan

Draft a pre-analysis plan following AEA RCT Registry / OSF / EGAP standards.

**Input:** `$ARGUMENTS` — path to research spec file, a topic, or `interactive` for guided questions.

---

## Step 0: Load Context

- If `$ARGUMENTS` is a file: read it (research spec from `/interview-me`)
- If `$ARGUMENTS` is `interactive`: ask structured questions (see below)
- Otherwise: treat as topic and draft with ASSUMED placeholders marked clearly

### Interactive Questions (if needed)

1. What is the research question? (1 sentence)
2. What is the study design? (RCT / natural experiment / observational / quasi-experimental)
3. What are the primary outcome variables? (name, measurement, timing)
4. What is the identification strategy? (randomization / DiD / IV / RDD / etc.)
5. What subgroup analyses are pre-specified and why?
6. What multiple testing concerns exist? (number of outcomes, number of subgroups)

---

## Step 1: Draft PAP Structure

```markdown
# Pre-Analysis Plan: [Study Title]

**Registration platform:** [AEA RCT Registry / OSF / EGAP]
**Date:** [YYYY-MM-DD]
**Authors:** [Names and affiliations]
**Status:** DRAFT — requires researcher review before registration

---

## 1. Study Overview

### Research Question
[One clear sentence]

### Study Design
- **Type:** [RCT / Natural experiment / Observational]
- **Unit of observation:** [Individual / Household / Firm / Region]
- **Treatment:** [Description of treatment/policy/intervention]
- **Control:** [Description of control condition]
- **Geographic setting:** [Country/region]
- **Study period:** [Start — End dates]

---

## 2. Outcomes

### Primary Outcomes
| Outcome | Variable Name | Measurement | Data Source | Timing |
|---------|--------------|-------------|-------------|--------|
| [Name] | [var_name] | [How measured, units] | [Survey/admin/etc.] | [When] |

### Secondary Outcomes
[Same table format]

### Mechanism / Intermediate Outcomes
[Same table format — explicitly labeled as exploratory]

---

## 3. Estimating Equations

### Primary Specification
$$Y_{it} = \alpha + \tau D_{it} + X_i'\beta + \varepsilon_{it}$$

where:
- $Y_{it}$: [outcome for unit $i$ at time $t$]
- $D_{it}$: [treatment indicator]
- $X_i$: [pre-specified controls: list them]
- Standard errors clustered at [unit level] because [justification]

### Alternative Specifications
[If multiple: list with justification for each]

---

## 4. Subgroup Analyses

Pre-specified subgroups (with justification for each):

| Subgroup | Variable | Hypothesis | Rationale |
|----------|----------|------------|-----------|
| [Name] | [var] | [Expected direction] | [Why pre-specify this] |

**Note:** Subgroup analyses are exploratory unless the study is powered for them.

---

## 5. Multiple Testing

**Number of primary outcomes:** [N]
**Number of pre-specified subgroups:** [M]
**Total family of tests:** [N × (1 + M) or as appropriate]

**Correction method:** [Choose one]
- Bonferroni: $\alpha^* = 0.05 / K$
- Benjamini-Hochberg: control FDR at 0.05
- Romano-Wolf: stepdown procedure (preferred for correlated outcomes)

**R implementation:**
```r
# Bonferroni
p_adjusted <- p.adjust(p_values, method = "bonferroni")

# Benjamini-Hochberg
p_adjusted <- p.adjust(p_values, method = "BH")

# Romano-Wolf (requires wildrwolf package)
# library(wildrwolf)
# rwolf_result <- rwolf(model, param, B = 999)
```

---

## 6. Power Calculations

| Outcome | MDE | Baseline Mean | SD | N per arm | Power | ICC |
|---------|-----|--------------|-----|-----------|-------|-----|
| [Name] | [δ] | [μ₀] | [σ] | [N] | 0.80 | [ρ] |

**Assumptions:**
- Two-sided test at $\alpha = 0.05$
- Power = 80% (standard) or 90% (if specified)
- [Attrition rate assumption: X%]
- [ICC for clustered designs]

**R implementation:**
```r
library(pwr)
# Simple two-arm RCT
pwr.t.test(d = MDE/SD, sig.level = 0.05, power = 0.80, type = "two.sample")

# Clustered design: adjust for design effect
DEFF <- 1 + (cluster_size - 1) * ICC
N_effective <- N / DEFF
```

---

## 7. Sample and Exclusion Rules

### Inclusion Criteria
[Who is in the sample — define precisely]

### Pre-specified Exclusion Rules (decided BEFORE seeing outcomes)
1. [Rule 1] — [justification]
2. [Rule 2] — [justification]

### Attrition Protocol
- If attrition > [X]%: report Lee (2009) bounds
- If differential attrition by treatment: [protocol]

### Outlier Treatment
- [Winsorize at 1%/99%, or trim, or robust regression — pre-specify]

---

## 8. Data and Analysis

### Data Sources
[Where each variable comes from]

### Software
- R version [X.X.X]
- Key packages: [list with versions]

### Randomization
- Method: [stratified block randomization / simple / cluster]
- Seed: [for reproducibility]
- Strata: [if stratified]

---

## 9. Timeline

| Milestone | Date |
|-----------|------|
| PAP registration | [Date] |
| Data collection start | [Date] |
| Data collection end | [Date] |
| Analysis | [Date] |
| Paper draft | [Date] |

---

## 10. Deviations Log

[To be completed at time of paper writing. Document ANY departures from this plan with justification.]

| Deviation | Section | Justification |
|-----------|---------|---------------|
| [Description] | [Which PAP section] | [Why the change was necessary] |
```

---

## Step 2: Platform-Specific Notes

- **AEA RCT Registry:** Most structured. All fields required. Register before intervention begins.
- **OSF:** More flexible. Good for observational studies and natural experiments.
- **EGAP:** Development economics focused. Similar to AEA but with additional governance questions.

For **observational studies** (not RCTs): adapt the template:
- Replace "randomization" with "identification strategy"
- Replace "treatment/control" with "treated/comparison group"
- Add identification assumption discussion
- Power calculations depend on design (DiD: serial correlation matters; RDD: density at cutoff matters)

---

## Output

Save to `quality_reports/pre_analysis_plan_[topic]_[date].md`

**CRITICAL:** Flag every ASSUMED item clearly. The researcher must review and approve before registration. A registered PAP with errors is worse than no PAP.

---

## Principles

- **Pre-specification is the point.** Everything must be decided before seeing outcomes.
- **Be honest about what's exploratory.** Label subgroups and secondary outcomes clearly.
- **Power calculations require assumptions.** State every assumption. If uncertain, show sensitivity.
- **This is a commitment device.** The PAP constrains the researcher. Make sure they understand what they're committing to.

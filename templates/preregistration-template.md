# Preregistration Template

This template is consumed by `.claude/skills/preregister/SKILL.md`. It contains three style sections (OSF, AsPredicted, AEA RCT Registry). The skill picks one based on `--style` or the field default.

**Output convention.** The skill writes the chosen style's filled-in form to `quality_reports/preregistrations/YYYY-MM-DD_<slug>.md` (gitignored). The user uploads it to the registry; this template is *not* a registry submission tool.

**Annotation legend.** Each field is tagged with one of:

- **MUST** — registry-required; the document cannot be submitted without it.
- **SHOULD** — strongly recommended; reviewers expect it.
- **MAY** — optional; include if relevant.

For any **MUST** field that the input description doesn't supply, write `[CLARIFY: <specific question>]`. Do not fabricate.

---

## Style 1 — OSF (Open Science Framework)

The OSF "Preregistration" template. Default for political-science, psychology, and broad social-science studies. Upload at `osf.io/registries`.

```markdown
---
title: <Study title>
authors: <Author1, Author2, ...>
date: YYYY-MM-DD
version: 1
style: osf
source-spec: <path to quality_reports/specs/... if applicable>
---

# Preregistration — <Study title>

## 1. Study Information (MUST)

### 1.1 Title
<Concise title that names the design and outcome>

### 1.2 Authors
<List with affiliations>

### 1.3 Description
<2–4 sentence study summary: what, why, who, when>

### 1.4 Hypotheses (MUST — directional)
**H1.** <Directional claim, e.g., "Treatment T increases outcome Y compared to control C">.
**H2.** <…>

## 2. Design (MUST)
- **Type:** experimental / quasi-experimental / observational
- **Manipulation (if any):** <description>
- **Randomisation unit:** individual / group / cluster / time
- **Blinding:** <single / double / open>

## 3. Sampling Plan (MUST)
- **Population:** <who>
- **Recruitment / data source:** <where from>
- **Target N:** <number, with justification>
- **Stopping rule:** <e.g., "stop at N=1,200 or 4 weeks, whichever first">
- **Power calculation:** <effect size assumed, alpha, power, resulting N>

## 4. Variables (MUST)
- **Primary outcome (Y):** <name, measurement, units>
- **Treatment (T):** <name, levels, encoding>
- **Pre-registered covariates:** <list>

## 5. Analysis Plan (MUST)
- **Primary estimator:** <e.g., "OLS with treatment dummies and pre-registered covariates, HC2 robust SEs">
- **Inference criterion:** <e.g., "two-sided alpha = 0.05; we will conclude H1 supported if the OLS coefficient on T is positive and statistically significant at this threshold">
- **Pre-registered specifications:** numbered (1, 2, 3) with explicit functional form for each
- **Multiple-testing correction (if H > 1):** <Bonferroni / Benjamini-Hochberg / none + justification>

## 6. Inference Criteria (MUST)
- **Confirmatory test of H1:** <exact decision rule>
- **What would make us reject H1:** <quantitative threshold>
- **Equivalence test (if used):** <bounds>

## 7. Data Exclusions (MUST — ex ante)
- **Outliers:** <e.g., "exclude observations with completion time < 60 seconds">
- **Failed manipulation checks:** <rule>
- **Other:** <rule>

## 8. Missing Data (MUST)
- **Treatment of missingness:** <listwise / multiple imputation / MAR assumption>
- **If MI: imputation model:** <specification>

## 9. Exploratory Analyses (MAY)
> Anything below this point is **exploratory** and not part of the confirmatory test.

- <Optional analyses, clearly labelled>

## 10. Other (MAY)
- **Pilot data already collected?** Yes / No (if yes: were the pilot results used to set H1? Disclose.)
- **Conflicts of interest:** <disclosure>
- **Funding source:** <disclosure>
```

---

## Style 2 — AsPredicted

The 9-question AsPredicted form (aspredicted.org). Designed for lab psych and short experimental studies. Upload at `aspredicted.org/create.php`.

```markdown
---
title: <Study title>
date: YYYY-MM-DD
style: aspredicted
source-spec: <path>
---

# AsPredicted — <Study title>

## 1. Have any data been collected for this study yet? (MUST)
<Yes — describe pilot status / No>

## 2. What's the main question being asked or hypothesis being tested? (MUST — directional)
<H1: directional claim>

## 3. Describe the key dependent variable(s) specifying how they will be measured. (MUST)
<Y, with measurement and units>

## 4. How many and which conditions will participants be assigned to? (MUST)
<List conditions, randomisation procedure, allocation ratio>

## 5. Specify exactly which analyses you will conduct to examine the main question/hypothesis. (MUST)
<Estimator, primary specification, inference rule>

## 6. Describe exactly how outliers will be defined and handled, and your precise rule(s) for excluding observations. (MUST)
<Ex-ante rules>

## 7. How many observations will be collected, or what will determine sample size? (MUST)
<Target N or stopping rule, with power-calc justification>

## 8. Anything else you would like to pre-register? (MAY)
<Robustness specs, secondary outcomes, equivalence tests>

## 9. Name (NOTE: this is for the study, not the paper). (MUST)
<short codename>
```

---

## Style 3 — AEA RCT Registry

The American Economic Association RCT Registry (socialscienceregistry.org). **Required** for AEA-journal submission of any randomised intervention since 2018. Upload at `socialscienceregistry.org/trials/create`.

```markdown
---
title: <Trial title>
investigators: <PI names + affiliations>
date: YYYY-MM-DD
style: aea-rct
source-spec: <path>
---

# AEA RCT Registry — <Trial title>

## Trial Information (MUST)
- **Status:** Not yet on the air / In development / On going / Completed
- **Start date:** YYYY-MM-DD
- **End date (planned):** YYYY-MM-DD
- **Geographic region:** <Country, sub-national region>

## Intervention (MUST)
- **Description:** <what is delivered, by whom, when>
- **Comparison group(s):** <pure control / placebo / active control>
- **Implementation partners:** <NGO, government agency, etc.>

## Primary Outcomes (MUST)
- **Y1 (primary):** <name, measurement, time of measurement>
- **Y2 (secondary, optional):** <…>

## Primary Hypotheses (MUST — directional)
**H1.** <Directional claim about Y1 under T vs C>

## Sample (MUST)
- **Target N:** <number>
- **Eligibility criteria:** <inclusion / exclusion>
- **Randomisation unit:** individual / household / village / school / clinic
- **Randomisation method:** <stratified, paired, blocked, simple>
- **Allocation ratio:** <e.g., 1:1>

## Power Calculation (SHOULD)
- **Assumed effect size:** <SD units>
- **Alpha / power:** <0.05 / 0.80>
- **Resulting N (and ICC if clustered):** <…>

## Pre-Analysis Plan (MAY — attach as PDF)
- **Estimator:** <ANCOVA / DiD / cluster-robust OLS>
- **Specifications:** numbered, with controls listed
- **Multiple testing:** <correction or family-wise rule>
- **Heterogeneity analyses:** <pre-specified subgroups>
- **Sensitivity / robustness:** <bounds analysis, alternative SEs, attrition adjustments>

## IRB / Ethical Approval (MUST for AEA submission)
- **IRB:** <institution>
- **Approval number:** <#>
- **Date of approval:** YYYY-MM-DD

## Data Sharing (SHOULD)
- **Public data plan:** <yes / no / restricted>
- **Replication code:** <will be deposited at JEL data archive — see AEA Data and Code Availability Policy>

## Conflicts of Interest (MUST)
<Disclosure>

## Funding (MUST)
<Source(s)>
```

---

## Style mapping (cross-registry)

For users who need to publish under one registry but report results under another's conventions, the rough mapping is:

| OSF section | AsPredicted question | AEA RCT field |
|---|---|---|
| 1.4 Hypotheses | Q2 | Primary Hypotheses |
| 2 Design | Q4 (conditions) | Intervention |
| 3 Sampling Plan | Q7 | Sample + Power Calc |
| 4 Variables | Q3 (DV) | Primary Outcomes |
| 5 Analysis Plan | Q5 | Pre-Analysis Plan |
| 7 Data Exclusions | Q6 | (in PAP attachment) |
| 6 Inference Criteria | (implicit in Q5) | (in PAP attachment) |

The mapping is approximate — registries differ in granularity. When in doubt, use the registry's native template directly.

---

## Where this template lives

- **File:** `templates/preregistration-template.md`
- **Consumed by:** `.claude/skills/preregister/SKILL.md`
- **Output:** `quality_reports/preregistrations/YYYY-MM-DD_<slug>.md` (gitignored)
- **Registry URLs:** OSF (osf.io/registries), AsPredicted (aspredicted.org), AEA RCT (socialscienceregistry.org)

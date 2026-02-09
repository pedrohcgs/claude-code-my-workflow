---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.R"
---

# Course Knowledge Base: [YOUR COURSE NAME]

<!--
  HOW TO USE THIS TEMPLATE:

  This is the central reference for your course's notation, narrative, applications,
  and design principles. Fill in the tables below with YOUR domain-specific content.

  Claude will read this file before creating or modifying any lecture content, ensuring
  consistency across all materials.

  Tips:
  1. Start small -- add notation as you create each lecture
  2. The "Anti-Pattern" column prevents recurring mistakes
  3. The Applications Database helps Claude thread examples through lectures
  4. The Design Principles section captures YOUR aesthetic preferences

  Delete all HTML comments once you've customized.
-->

**Purpose:** Centralized reference for notation, narrative, applications, and design principles. Read this FIRST before creating or modifying any lecture content.

**Last Updated:** [DATE]

---

## 1. Notation Registry

### Core Conventions

<!-- Define your field's notation rules here. Examples: -->
<!-- | Group in superscript | Treatment value as superscript | $m_t^{d=0}(X)$ | $m_{d=0,t}(X)$ | -->
<!-- | Time in subscript | Time period as subscript | $w_t^{d=1}$ | $w^{d=1,t}$ | -->

| Rule | Convention | Example | Anti-Pattern |
|------|-----------|---------|-------------|
| | | | |

### Symbol Reference

<!-- Organize by category. Add sections as needed: -->

#### Category 1 (e.g., Treatment & Assignment)

| Symbol | Meaning | Introduced |
|--------|---------|------------|
| | | |

#### Category 2 (e.g., Outcomes)

| Symbol | Meaning | Introduced |
|--------|---------|------------|
| | | |

#### Category 3 (e.g., Estimands)

| Symbol | Meaning | Introduced |
|--------|---------|------------|
| | | |

#### Category 4 (e.g., Estimators)

| Symbol | Meaning | Introduced |
|--------|---------|------------|
| | | |

### Key Assumptions (Standard Notation)

<!-- List the core assumptions in your field with standard notation -->
<!-- Example: -->
<!-- - **SUTVA:** No interference + consistency -->
<!-- - **Parallel Trends:** $\mathbb{E}[\Delta Y(\infty) \mid D=1] = \mathbb{E}[\Delta Y(\infty) \mid D=0]$ -->

-
-

---

## 2. Course Narrative Arc

### Lecture Progression

<!-- Map out how lectures build on each other -->

| # | Title | Core Question | Key Notation Introduced | Key Method |
|---|-------|--------------|------------------------|------------|
| 1 | | | | |
| 2 | | | | |
| 3 | | | | |

### Connections Between Lectures

<!-- Document how each lecture leads to the next -->
<!-- Example: L2 -> L3: Potential outcomes framework -> dynamic causal effects -->

- **L1 -> L2:**
- **L2 -> L3:**

---

## 3. Empirical Applications Database

<!-- List the running examples threaded through your course -->

| Application | Paper | Dataset | R Package | Lecture(s) | Purpose |
|------------|-------|---------|-----------|------------|---------|
| | | | | | |

### Replication Data Sources

<!-- Where to find the data for each application -->
-

---

## 4. Validated Design Principles

### What Has Been Approved (Do This)

<!-- As you iterate with Claude, record what works well -->

| Principle | Evidence | Lectures Applied |
|-----------|----------|-----------------|
| | | |

### What Has Been Overridden (Don't Do This)

<!-- Record anti-patterns and mistakes to avoid -->

| Anti-Pattern | What Happened | Correction |
|-------------|---------------|-----------|
| | | |

### R Code Pitfalls

<!-- Domain-specific R code bugs to watch for -->

| Bug | Impact | Fix |
|-----|--------|-----|
| | | |

---

## 5. Research Project Variant

<!--
  For RESEARCH PROJECTS (papers, simulations, empirical analysis) rather than
  courses, use this section instead of (or in addition to) sections 2-3 above.

  Fill in the subsections below with YOUR domain-specific content.
-->

### Estimand Registry

<!-- Define the key estimands in your paper/project -->

| Estimand | Formula | Key Parameters |
|----------|---------|----------------|
| [e.g., ATE] | [e.g., E[Y(1) - Y(0)]] | [e.g., treatment, outcome] |
| | | |

### Mathematical Objects

<!-- Document key mathematical functions, algorithms, and their implementations -->

| Object | Function Name | Location | Notes |
|--------|--------------|----------|-------|
| [e.g., Basis functions] | [e.g., `build_basis()`] | [e.g., `R/utils.R`] | [e.g., Orthogonal on [0,1]] |
| | | | |

### DGP / Simulation Configurations

<!-- If your project includes Monte Carlo simulations, document each DGP -->

| Config | Description | Key Parameters | Expected Behavior |
|--------|------------|----------------|-------------------|
| DGP1 | [e.g., Baseline] | [e.g., n=1000, effect=1] | [e.g., All estimators work well] |
| DGP2 | [e.g., Challenging case] | [e.g., n=500, weak signal] | [e.g., Naive estimator fails] |
| | | | |

### Empirical Applications

<!-- Document each application with its data source and expected outputs -->

| Application | Data Source | Treatment | Outcome | Output Location |
|------------|------------|-----------|---------|-----------------|
| [e.g., App 1] | [e.g., `data/app1.csv`] | [e.g., Policy X] | [e.g., Income Y] | [e.g., `output/applications/app1/`] |
| | | | | |

### Tolerance Thresholds

<!-- For replication/comparison purposes -->

| Quantity | Tolerance | Rationale |
|----------|-----------|-----------|
| Point estimates | [e.g., 1e-6] | [Numerical precision] |
| Standard errors | [e.g., 1e-4] | [MC variability] |
| Coverage rates | [e.g., +/- 0.01] | [MC with B reps] |

### Output Directory Structure

<!-- Document where results go -->

```
output/
├── applications/
│   ├── [App1]/
│   │   ├── results.csv
│   │   └── plots/
│   └── [App2]/
└── simulations/
    ├── results/
    │   └── [config]_[params].csv
    └── plots/
```

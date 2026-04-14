---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "scripts/**/*.do"
  - "scripts/**/*.R"
---

# Project Knowledge Base: Financial Intermediary Shocks and Firm Heterogeneity

## Notation Registry

| Rule | Convention | Example | Anti-Pattern |
|------|-----------|---------|-------------|
| Firm subscript | $i$ for firm, $t$ for time | $Y_{i,t}$ | Using $j$ for firms |
| Bank/lender subscript | $b$ for bank/intermediary | $L_{b,t}$ | Using $i$ for both firm and bank |
| Treatment indicator | $D_{i,t}$ or $\text{Post}_t \times \text{Treated}_i$ | DID specification | Ambiguous treatment timing |
| Standard errors | Cluster at firm level (baseline) | `cluster(firm_id)` | Clustering at industry without justification |
| Log variables | $\log$ prefix or `ln_` in code | $\log(\text{Assets})$, `ln_assets` | Mixing log and level in same table |

## Symbol Reference

| Symbol | Meaning | Context |
|--------|---------|---------|
| $I_{i,t}/K_{i,t-1}$ | Investment-to-capital ratio | Dependent variable |
| $Q_{i,t}$ | Tobin's Q (market-to-book) | Investment demand proxy |
| $CF_{i,t}/K_{i,t-1}$ | Cash flow to capital | Internal funds |
| $\text{Lev}_{i,t}$ | Leverage (debt/assets) | Financial constraint proxy |
| $\Delta \text{CS}_t$ | Credit spread change | Intermediary shock measure |
| $\text{BankCap}_{b,t}$ | Bank capital ratio | Intermediary health |
| $\text{AEM}_t$ | Adrian-Etula-Muir factor | Intermediary asset pricing |
| $\text{HKM}_t$ | He-Kelly-Manela factor | Intermediary capital ratio factor |
| $\text{KZ}_{i,t}$ | Kaplan-Zingales index | Financial constraints |
| $\text{WW}_{i,t}$ | Whited-Wu index | Financial constraints |
| $\text{SA}_{i,t}$ | Size-Age index (Hadlock-Pierce) | Financial constraints |

## Empirical Applications

| Application | Key Paper(s) | Dataset | Purpose |
|------------|-------------|---------|---------|
| Bank lending channel | Kashyap & Stein (2000) | Call reports + Compustat | Credit supply identification |
| Intermediary asset pricing | He, Kelly & Manela (2017) | Broker-dealer data | Shock measurement |
| Investment-Q sensitivity | Fazzari, Hubbard & Petersen (1988) | Compustat | Baseline framework |
| Financial constraints | Kaplan & Zingales (1997), Hadlock & Pierce (2010) | Compustat | Firm heterogeneity |
| Credit supply shocks | Khwaja & Mian (2008) | Loan-level data | Within-firm estimation |
| Firm-bank matching | Chodorow-Reich (2014) | DealScan + Compustat | Relationship lending |

## Estimand Registry

| Estimand | Description | Identification |
|----------|-------------|----------------|
| ATT of credit shock on investment | Effect of intermediary shock on treated firms' I/K | DID with firm + time FE |
| Heterogeneous treatment by constraints | Differential effect by KZ/WW/SA tercile | Triple-difference |
| Bank capital → firm investment | Transmission of bank balance sheet shocks | IV or shift-share |

## Stata Code Pitfalls

| Bug | Impact | Fix |
|-----|--------|-----|
| `winsor` without `by(year)` | Cross-sectional variation distorted | Always winsorize by year |
| `xtset` not set before `xtreg` | Silent wrong estimation | `xtset firm_id year` early |
| Merge without `assert` | Undetected merge failures | `assert _merge == 3` or document |
| `areg` vs `reghdfe` | `areg` slower, fewer FE options | Prefer `reghdfe` for multi-way FE |
| Missing `labmask` for factor vars | Tables show codes not labels | Label variables before estimation |

## Anti-Patterns (Don't Do This)

| Anti-Pattern | What Happened | Correction |
|-------------|---------------|-----------|
| Winsorizing dependent variable | Censors real variation in investment | Winsorize controls only, or use trimming |
| Clustering at industry level for firm panel | Overstates significance | Cluster at firm level (baseline) |
| Dropping financial firms without documenting | Sample selection unclear | Document SIC exclusions explicitly |
| Using book equity < 0 filter without note | Loses distressed firms (selection) | Document or use alternative measure |

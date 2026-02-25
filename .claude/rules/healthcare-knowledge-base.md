---
paths:
  - "Slides/**/*.tex"
  - "Quarto/**/*.qmd"
  - "analysis/**/*"
  - "scripts/**/*"
---

# Domain Knowledge: Capital and Labor Shares in Healthcare

## Core Concepts

### Factor Share Decomposition

- **Capital share (alpha):** Payments to physical capital (equipment, structures, IT) as fraction of total value added
- **Labor share (1 - alpha):** Compensation of employees (wages + benefits + employer contributions) as fraction of total value added
- **Value added = Compensation of employees + Gross operating surplus + Taxes on production less subsidies**
- Healthcare is distinct: high human capital intensity, regulated pricing, third-party payers, large nonprofit sector

---

## Key Data Sources

| Source | Agency | Content | Granularity |
|--------|--------|---------|-------------|
| NIPA / GDP-by-industry | BEA | Value added, compensation, GOS by industry | Annual, national, NAICS |
| Input-Output tables | BEA | Intermediate inputs, make/use | Annual/benchmark |
| Medicare claims | CMS | Service-level spending, provider characteristics | Claim-level |
| QCEW | BLS | Employment, wages by industry-county-quarter | Quarterly, county |
| OES | BLS | Occupation-level wages | Annual, MSA |
| Provider of Services | CMS | Hospital characteristics, ownership, beds | Annual, provider |

---

## Notation Convention

| Symbol | Meaning | Notes |
|--------|---------|-------|
| alpha_j | Capital share in industry j | |
| w_j | Average wage in industry j | |
| L_j | Employment in industry j | |
| VA_j | Value added in industry j | = CE + GOS + Taxes on production |
| GOS_j | Gross operating surplus in industry j | Includes mixed income adjustments |
| CE_j | Compensation of employees in industry j | Wages + supplements |

---

## Known Measurement Issues

1. **Mixed income:** Proprietors' income straddles labor and capital; healthcare has many physician partnerships
2. **Nonprofit sector:** Hospitals often nonprofit -- GOS interpretation differs from for-profit
3. **Government enterprises:** VA hospitals, public health -- factor shares less meaningful
4. **Imputed rent:** Owner-occupied real estate in healthcare facilities
5. **Intellectual property:** R&D capitalization under 2013 NIPA revision affects healthcare capital
6. **NAICS revisions:** Industry boundaries change across revisions; use concordance tables

---

## Anti-Patterns

| Anti-Pattern | Why It's Wrong | Correction |
|-------------|----------------|------------|
| Using revenue as denominator | Revenue includes intermediate inputs | Use value added |
| Ignoring supplements to wages | Understates labor share by ~25% in healthcare | Use total compensation (CE) |
| Treating all GOS as capital income | Includes proprietors' mixed income | Adjust for self-employment |
| Comparing across NAICS revisions | Industry definitions change | Use concordance tables |
| Ignoring nonprofit/for-profit distinction | GOS means different things | Analyze separately or adjust |
| Using current dollars across time | Confounds real changes with price effects | Use chained dollars or deflators |

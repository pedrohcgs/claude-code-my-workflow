# Analysis: Task-Based DAG Structure

Each analysis task lives in its own directory with three subfolders:

```
analysis/
├── task_name/
│   ├── code/          # .do files (main.do is entry point)
│   ├── inputs/        # Symlinks to other tasks' outputs/
│   └── outputs/       # Results: .dta, .csv, .tex, .png
```

## Convention

- **`code/`** contains Stata .do files. `main.do` is always the entry point.
- **`inputs/`** contains ONLY symbolic links to another task's `outputs/` directory.
- **`outputs/`** contains all produced files (data, figures, tables, logs).
- Task names use `snake_case`.
- All paths within .do files are relative to the task root.

## Running a Task

```bash
cd analysis/task_name && stata-mp -b do code/main.do
```

## Running the Full Pipeline

Execute tasks in order (respecting dependencies):

```bash
# Layer 0: Download raw data (can run in parallel)
cd analysis/download_bea_gdp_industry && stata-mp -b do code/main.do
cd analysis/download_bea_nipa_supplements && stata-mp -b do code/main.do
cd analysis/download_bls_qcew && stata-mp -b do code/main.do

# Layer 1: Build clean panels (can run in parallel)
cd analysis/build_nipa_shares && stata-mp -b do code/main.do
cd analysis/build_bls_employment && stata-mp -b do code/main.do

# Layer 2: Analysis (can run in parallel)
cd analysis/compute_factor_shares && stata-mp -b do code/main.do
cd analysis/merge_bea_bls && stata-mp -b do code/main.do

# Layer 3: Output
cd analysis/sensitivity_analysis && stata-mp -b do code/main.do
cd analysis/figures_and_tables && stata-mp -b do code/main.do
```

## Task DAG

```
Layer 0 — Raw Data:
  download_bea_gdp_industry   download_bea_nipa_supplements   download_bls_qcew
         │                            │                            │
Layer 1 — Build/Clean:                │                            │
  build_nipa_shares ──────────────────┘                   build_bls_employment
         │                                                    │    │
Layer 2 — Analysis:                                           │    │
  compute_factor_shares                                  merge_bea_bls
         │         │                                          │
Layer 3 — Output:  │                                          │
  sensitivity_analysis                                        │
         │                                                    │
  figures_and_tables ─────────────────────────────────────────┘
```

## Current Tasks

| Task | Purpose | Upstream Dependencies |
|------|---------|----------------------|
| `download_bea_gdp_industry` | Fetch BEA GDP-by-Industry data via API | -- (BEA API key required) |
| `download_bea_nipa_supplements` | Fetch proprietors' income + CFC tables | -- (BEA API key) |
| `download_bls_qcew` | Fetch BLS QCEW annual averages | -- (direct download) |
| `build_nipa_shares` | Clean BEA data into industry-year VA panel | `download_bea_gdp_industry`, `download_bea_nipa_supplements` |
| `build_bls_employment` | Clean QCEW into employment/wage panel | `download_bls_qcew` |
| `compute_factor_shares` | Compute raw + Gollin-adjusted factor shares | `build_nipa_shares` |
| `merge_bea_bls` | Cross-validate BEA CE vs BLS wages | `build_nipa_shares`, `build_bls_employment` |
| `sensitivity_analysis` | Robustness: mixed income, nonprofits, net vs gross | `compute_factor_shares` |
| `figures_and_tables` | Publication-ready figures and LaTeX tables | `compute_factor_shares`, `sensitivity_analysis`, `merge_bea_bls` |

## Prerequisites

1. **BEA API key**: Sign up at `apps.bea.gov/api/signup/` (free, instant). Save key to `download_bea_gdp_industry/inputs/bea_api_key.txt`.
2. **Python 3**: Required for BEA API helper scripts (stdlib only).
3. **Stata**: stata-mp (or stata-se) on PATH.

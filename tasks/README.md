# Tasks: Task-Based DAG Structure

Following the [Dingel projecttemplate](https://github.com/jdingel/projecttemplate) convention, each analysis task lives in its own directory with three subfolders:

```
tasks/
├── task_name/
│   ├── code/          # Makefile + .do files (main.do is entry point)
│   ├── input/         # Symlinks to other tasks' output/
│   └── output/        # Results: .dta, .csv, .tex, .png
├── generic.make       # Shared build rules
├── shell_functions.sh # Stata/Python/R execution wrappers
└── shell_functions.make
```

## Convention

- **`code/`** contains a Makefile and script files. `main.do` is always the Stata entry point.
- **`input/`** contains ONLY symbolic links to another task's `output/` directory.
- **`output/`** contains all produced files (data, figures, tables, logs).
- Task names use `snake_case`.
- All paths within .do files are relative to the task root.

## Running a Task

```bash
# Via Make (preferred — handles dependencies automatically)
cd tasks/task_name/code && make

# Or directly via Stata
cd tasks/task_name && stata-mp -b do code/main.do
```

## Running the Full Pipeline

Execute tasks in order (respecting dependencies):

```bash
# Layer 0: Download raw data (can run in parallel)
cd tasks/download_bea_gdp_industry/code && make
cd tasks/download_bea_nipa_supplements/code && make
cd tasks/download_bls_qcew/code && make

# Layer 1: Build clean panels (can run in parallel)
cd tasks/build_nipa_shares/code && make
cd tasks/build_bls_employment/code && make

# Layer 2: Analysis (can run in parallel)
cd tasks/compute_factor_shares/code && make
cd tasks/merge_bea_bls/code && make

# Layer 3: Output
cd tasks/sensitivity_analysis/code && make
cd tasks/figures_and_tables/code && make
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

1. **BEA API key**: Sign up at `apps.bea.gov/api/signup/` (free, instant). Save key to `download_bea_gdp_industry/input/bea_api_key.txt`.
2. **Python 3**: Required for BEA API helper scripts (stdlib only).
3. **Stata**: stata-mp (or stata-se) on PATH.
4. **GNU Make**: For automated builds.

---
name: data-deposit
description: Prepare AEA Data Editor compliant replication package. Generate README in required format, establish numbered script order, create master script, document data provenance, produce ICPSR/Zenodo deposit checklist. Use when asked to "prepare data deposit", "create replication package", "AEA data editor", or "openICPSR".
disable-model-invocation: true
argument-hint: "[paper title or package directory (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Deposit Preparation

Prepare an AEA Data Editor compliant replication package for journal submission.

**Input:** `$ARGUMENTS` — paper title or package directory (optional).

---

## Step 1: Inventory

1. Read all R scripts in `scripts/R/` and subdirectories
2. Read all data files referenced in scripts (parse `read.csv`, `readRDS`, `read_dta`, etc.)
3. Read existing README in `Replication/` if any
4. Read paper (`Paper/main.tex`) for table/figure list
5. Read `Tables/` and `Figures/` for output files

---

## Step 2: Determine Script Order

1. Analyze script dependencies:
   - Which scripts create files (`saveRDS`, `write.csv`, `ggsave`) that others load?
   - Which scripts `source()` other scripts?
2. Build dependency graph
3. Propose sequential numbering: `01_clean_data.R`, `02_summary_stats.R`, etc.
4. Identify and flag circular dependencies
5. Present order to user for approval before renaming

---

## Step 3: Draft README (AEA Format)

Generate `Replication/README.md`:

```markdown
# Data and Code Availability Statement

## Overview

| | |
|---|---|
| **Paper** | [Title] |
| **Authors** | [Authors] |
| **Journal** | [Target journal] |

## Data Availability

### [Dataset 1 Name]
| | |
|---|---|
| **Source** | [URL, data provider, or institutional source] |
| **Access** | [Public / Restricted — access instructions] |
| **Files** | [data/filename.csv] |
| **Citation** | [BibTeX key or full citation] |

[Repeat for each dataset]

## Computational Requirements

### Software
- R version [X.X.X] ([date])
- [List key packages with versions from sessionInfo()]

### Hardware
- Estimated runtime: [X minutes] on [machine description]
- Memory requirements: [X GB RAM]
- Storage: [X GB disk space for data + output]

## Description of Programs

| Order | Script | Description | Input | Output |
|-------|--------|-------------|-------|--------|
| 01 | `01_clean_data.R` | [Description] | `data/raw/` | `data/processed/clean.rds` |
| 02 | `02_summary_stats.R` | [Description] | `data/processed/clean.rds` | `Tables/table1.tex` |
| ... | ... | ... | ... | ... |

## Instructions for Replicators

1. Install R [version] and required packages (see `install_packages.R` or run `renv::restore()`)
2. [If restricted data:] Obtain [dataset] from [source] (estimated access time: [X weeks])
3. Place data files in `data/raw/`
4. Set working directory to the package root
5. Run `Rscript master.R`
6. Output will appear in `Tables/` and `Figures/`

## Restricted Data

[If applicable:]
- **Dataset:** [Name]
- **Provider:** [Institution]
- **Access procedure:** [How to apply]
- **Estimated wait time:** [X weeks/months]
- **IRB/ethics approval:** [If human subjects, reference approval number]

## References

[BibTeX entries for all datasets cited]
```

---

## Step 4: Generate Master Script

If no `master.R` exists, create `Replication/master.R`:

```r
# master.R — Reproduces all tables and figures
# Paper: [Title]
# Runtime: approximately X minutes
# Requirements: R X.X.X, see README for package list

# --- Setup ---
if (!dir.exists("Tables")) dir.create("Tables", recursive = TRUE)
if (!dir.exists("Figures")) dir.create("Figures", recursive = TRUE)

# --- Execute scripts in order ---
message("Running 01_clean_data.R...")
source("scripts/R/01_clean_data.R")

message("Running 02_summary_stats.R...")
source("scripts/R/02_summary_stats.R")

# [Continue for all scripts]

message("Replication complete. Check Tables/ and Figures/ for output.")
```

---

## Step 5: Deposit Checklist

Generate `Replication/DEPOSIT_CHECKLIST.md`:

```markdown
# Deposit Checklist

## Before Deposit
- [ ] README.md complete and in package root
- [ ] All scripts numbered and documented
- [ ] Master script runs end-to-end without errors
- [ ] All tables and figures reproduce correctly
- [ ] No hardcoded absolute paths
- [ ] No API keys or credentials in scripts
- [ ] sessionInfo() output saved (or package versions in README)
- [ ] Runtime documented and accurate

## openICPSR Specific
- [ ] Upload all files to openICPSR deposit
- [ ] Set project title matching paper
- [ ] Add all co-authors to deposit
- [ ] Set appropriate access level
- [ ] Record DOI for paper's data availability statement

## Zenodo Specific (if using)
- [ ] Create Zenodo record
- [ ] Upload package as .zip
- [ ] Set license (CC0 or CC BY 4.0 recommended)
- [ ] Link to paper DOI
- [ ] Record Zenodo DOI

## Final Verification
- [ ] Run `/audit-replication` and achieve 6/6 PASS
- [ ] Update paper's Data Availability Statement with deposit DOI
- [ ] Add data citation to Bibliography_base.bib
```

---

## Step 6: Generate Package Installer (Optional)

If `renv` is not used, create `Replication/install_packages.R`:

```r
# install_packages.R — Install all required packages
packages <- c(
  "fixest", "did", "modelsummary", "ggplot2",
  # [list all packages from script inventory]
)
install.packages(setdiff(packages, rownames(installed.packages())))
```

---

## Principles

- **AEA Data Editor standards are the target.** The AEA rejects many packages for exactly these issues — README format, missing versions, undocumented data access.
- **Don't rename scripts without approval.** Present the proposed ordering and get user confirmation.
- **Be thorough on data provenance.** Every dataset must have a documented source, even if it's "generated by script 01."
- **Test the master script yourself** (via `/audit-replication`) before declaring the package ready.

---
name: data-deposit
description: Prepare AEA Data Editor compliant replication package by dispatching the Coder agent for package assembly and Verifier agent for validation. Generates README, master script, numbered script order, and deposit checklist.
disable-model-invocation: true
argument-hint: "[paper title or package directory (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Data Deposit Preparation

Prepare an AEA Data Editor compliant replication package by dispatching the **Coder** (assembly) and **Verifier** (validation).

**Input:** `$ARGUMENTS` — paper title or package directory (optional).

---

## Workflow

### Step 1: Inventory

1. Read all scripts in `scripts/R/` (and `scripts/stata/`, `scripts/python/`, etc.)
2. Parse data file references (`read.csv`, `readRDS`, `read_dta`, etc.)
3. Read existing README in `Replication/` if any
4. Read paper (`Paper/main.tex`) for table/figure list
5. Scan `Tables/` and `Figures/` for output files

### Step 2: Dispatch Coder for Package Assembly

Delegate to the `coder` agent:

```
Prompt: Assemble replication package.
1. Analyze script dependencies (which scripts create files others load?)
2. Propose sequential numbering: 01_clean_data.R, 02_summary_stats.R, etc.
3. Draft README.md in AEA format (data availability, computational requirements,
   program descriptions, replication instructions)
4. Generate master.R (or master.do, master.py) that runs everything in order
5. Generate install_packages.R (if renv not used)
6. Generate DEPOSIT_CHECKLIST.md
Present script order to user for approval before renaming.
Save all to Replication/
```

### Step 3: Validate with Verifier

After package assembly, dispatch the **Verifier** in submission mode:

```
Prompt: Audit the replication package at Replication/.
Mode: Submission (checks 1-10).
This is a fresh package — focus on completeness and executability.
Save report to quality_reports/replication_audit_[date].md
```

This is equivalent to running `/audit-replication Replication/`.

### Step 4: Fix Issues

If Verifier finds failures:
1. Re-dispatch Coder with specific fixes (max 3 rounds)
2. Re-run Verifier to verify

### Step 5: Present Results

1. **Package contents** — all files in `Replication/`
2. **Script order** — numbered sequence with dependency graph
3. **README preview** — key sections
4. **Verification result** — X/10 checks passed
5. **Deposit checklist** — openICPSR / Zenodo steps

---

## Key Outputs

| File | Description |
|------|-------------|
| `Replication/README.md` | AEA-format data and code availability statement |
| `Replication/master.R` | Runs all scripts in order |
| `Replication/install_packages.R` | Package installation (if no renv) |
| `Replication/DEPOSIT_CHECKLIST.md` | Pre-deposit verification checklist |

---

## Principles

- **AEA Data Editor standards are the target.** README format, versions, data access.
- **Don't rename scripts without approval.** Present ordering first.
- **Thorough data provenance.** Every dataset documented with source.
- **Test before declaring ready.** Always run `/audit-replication` after assembly.
- **Worker-critic pairing.** Coder assembles, Verifier validates.

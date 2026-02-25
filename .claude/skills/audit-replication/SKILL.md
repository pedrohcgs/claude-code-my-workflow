---
name: audit-replication
description: Validate replication package end-to-end for AEA Data Editor compliance. Runs master script, cross-references tables and figures against paper, verifies README completeness, flags missing dependencies. Use before data deposit or when asked to "audit the replication package", "check replication", or "prepare for data editor".
disable-model-invocation: true
argument-hint: "[replication package directory OR 'here' for current project]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Task"]
---

# Audit Replication Package

Run end-to-end validation of a replication package against AEA Data Editor standards.

**Input:** `$ARGUMENTS` — directory containing the replication package. Use `here` or no argument for the current project.

---

## Workflow

### Step 1: Locate Package

- If `$ARGUMENTS` is a directory path: use it
- If `$ARGUMENTS` is `here` or empty: use `Replication/` if it exists, otherwise use project root
- Verify the directory exists and contains R scripts

### Step 2: Launch Replication Auditor

Delegate to the `replication-auditor` agent:

```
Prompt: Audit the replication package at [directory].
Paper location: Paper/main.tex (if exists)
Run all 6 checks in the replication audit protocol.
```

### Step 3: Handle Failures

If execution errors are found (Check 4):
1. Display the specific error with file and line number
2. Suggest a concrete fix
3. Ask user if they want to fix and re-audit (max 3 iterations)

### Step 4: Present Results

Show:
1. **Overall PASS/FAIL** with X/6 checks passed
2. **Blocking issues** — must fix before deposit
3. **Priority fix list** — ordered by importance
4. **Positive findings** — what's already good

### Step 5: Save Report

Save to `quality_reports/replication_audit_[date].md`

---

## Principles

- **This skill runs code.** It needs Bash access to execute R scripts for Check 4.
- **Be patient with runtime.** Some replication packages take 30+ minutes. Set appropriate timeouts.
- **Don't modify the package** during the audit. Only read and run.
- **Specific > vague.** "Script 03_robustness.R fails at line 47 with error: object 'treatment_var' not found" beats "execution failed."

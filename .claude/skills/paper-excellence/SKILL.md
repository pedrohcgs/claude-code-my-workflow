---
name: paper-excellence
description: Multi-agent paper review combining proofreading, econometric validity, R code quality, and replication audit. Use for comprehensive quality check before submission or major milestones.
disable-model-invocation: true
argument-hint: "[paper .tex path OR 'all' for full project review]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task", "Bash"]
---

# Paper Excellence Review

Run all review agents in parallel for a comprehensive paper quality assessment.

**Input:** `$ARGUMENTS` — path to paper `.tex` file, or `all` for full project review.

---

## Workflow

### Step 1: Identify Targets

- If `$ARGUMENTS` is a `.tex` file: review that file
- If `$ARGUMENTS` is `all`: review `Paper/main.tex` + all `scripts/R/*.R`
- Also scan for `Talks/*.tex` for auxiliary scoring

### Step 2: Launch Agents in Parallel

Launch up to 4 agents simultaneously via Task tool:

**Agent 1: Proofreader** (existing agent)
```
Review [paper.tex] for grammar, typos, academic writing quality, and consistency.
```

**Agent 2: Econometrician** (new agent)
```
Review [paper.tex] through all 6 lenses of the econometrics review protocol.
Also check any R scripts in scripts/R/ for code-theory alignment.
```

**Agent 3: R-Reviewer** (existing agent, if R scripts exist)
```
Review all R scripts in scripts/R/ for code quality, reproducibility, and domain correctness.
```

**Agent 4: Replication Auditor** (new agent, if Replication/ exists)
```
Audit the replication package at Replication/ (or scripts/R/) for AEA Data Editor compliance.
```

### Step 3: Collect and Score

After all agents return:

1. **Aggregate issues** across all reports by severity:
   - CRITICAL: Any single critical issue → score capped at 60
   - MAJOR: Each major issue → -5 points
   - MINOR: Each minor issue → -1 point

2. **Compute paper score** (starting from 100):
   - Proofreading deductions
   - Econometrics deductions
   - R code deductions (weighted 0.5 — code supports paper, not vice versa)
   - Replication audit PASS/FAIL (FAIL → -15)

3. **Compute talk scores** (if talks exist) — auxiliary, non-blocking:
   - Run proofreader on each talk file
   - Check notation matches paper
   - Report as "Talk (seminar): 85/100" etc.

### Step 4: Present Results

```markdown
# Paper Excellence Report: [Title]
**Date:** [YYYY-MM-DD]
**Paper Score:** [XX/100] — [PASS/FAIL at 80 threshold]

## Score Breakdown
| Component | Score | Issues |
|-----------|-------|--------|
| Proofreading | -X | N issues |
| Econometrics | -X | N issues |
| R Code | -X | N issues |
| Replication | -X | PASS/FAIL |

## Auxiliary: Talk Scores (non-blocking)
| Talk | Score | Issues |
|------|-------|--------|
| Job Market | XX/100 | N |
| Seminar | XX/100 | N |

## Priority Fixes (Top 5)
1. **[CRITICAL]** [Most important — from which agent]
2. **[MAJOR]** [Second priority]
3. ...

## Full Reports
- Proofreading: quality_reports/[file]_proofread.md
- Econometrics: quality_reports/[file]_econometrics_review.md
- R Code: quality_reports/[script]_r_review.md
- Replication: quality_reports/replication_audit_[date].md
```

### Step 5: Gate Enforcement

- **Score >= 90:** "Ready for submission. Minor polish recommended."
- **Score >= 80:** "Commit-ready. Address major issues before submission."
- **Score < 80:** "Blocked. Must fix critical/major issues before proceeding."
  - List specific blocking issues with file locations

---

## Principles

- **Paper score is blocking.** Must pass 80/90/95 quality gates per project rules.
- **Talk scores are advisory.** Reported but do not block commits or submissions.
- **Parallel execution.** All agents run simultaneously for speed.
- **One unified report.** User sees one priority list, not four separate reports.
- **Don't double-count.** If the same issue appears in multiple agents' reports, count it once.

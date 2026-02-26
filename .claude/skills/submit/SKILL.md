---
name: submit
description: Final submission verification gate. Runs Verifier in submission mode (10 checks), confirms aggregate score >= 95 with all components >= 80, and generates submission checklist. Use when ready to submit to a journal.
disable-model-invocation: true
argument-hint: "[journal name (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Bash", "Task"]
---

# Submit

Final submission gate combining full verification, score enforcement, and submission checklist.

**Input:** `$ARGUMENTS` — target journal name (optional, uses domain-profile.md default).

---

## Workflow

### Step 1: Pre-Flight Checks

1. Read `.claude/rules/scoring-protocol.md` for submission requirements
2. Read `.claude/rules/domain-profile.md` for target journal
3. Check for existing quality reports in `quality_reports/`
4. Verify paper exists at `Paper/main.tex`

### Step 2: Run Full Verification

If `/paper-excellence` hasn't been run recently (check report dates):

Dispatch full review pipeline:
```
Run /paper-excellence all
```

This triggers: Econometrician + Debugger + Proofreader + Verifier in parallel.

### Step 3: Run Replication Audit

Dispatch Verifier in submission mode:
```
Run /audit-replication Replication/
```

This runs all 10 checks including end-to-end execution.

### Step 4: Score Gate

Read the most recent aggregate score and check:

| Requirement | Threshold | Status |
|-------------|-----------|--------|
| Aggregate score | >= 95 | PASS/FAIL |
| Identification component | >= 80 | PASS/FAIL |
| Code component | >= 80 | PASS/FAIL |
| Paper component | >= 80 | PASS/FAIL |
| Replication (10/10 checks) | PASS | PASS/FAIL |

**If any requirement FAILS:** List specific blocking issues and stop. Do not generate submission materials.

### Step 5: Generate Submission Package

If all gates pass:

1. **Cover letter draft** (save to `quality_reports/cover_letter_[journal]_[date].tex`)
   - Addressed to current editor
   - 1 paragraph: what the paper does and why it matters
   - 1 paragraph: why this journal
   - 1 paragraph: originality confirmation
   - Suggested referees (3-5, from `/target-journal` if available)

2. **Final checklist** (save to `quality_reports/submission_checklist_[date].md`):
   ```markdown
   # Submission Checklist: [Journal]

   ## Manuscript
   - [ ] Title page with affiliations and contact info
   - [ ] Abstract within word limit
   - [ ] JEL codes (2-3)
   - [ ] Keywords (3-5)
   - [ ] Journal formatting guidelines followed

   ## Data and Code
   - [ ] Replication package audit: PASS (10/10)
   - [ ] Data availability statement in manuscript
   - [ ] Deposit DOI recorded

   ## Quality Gates
   - [ ] Aggregate score: [XX]/100 (>= 95 required)
   - [ ] All components >= 80
   - [ ] No unresolved CRITICAL issues

   ## Submission
   - [ ] Upload manuscript PDF
   - [ ] Upload replication package
   - [ ] Upload cover letter
   - [ ] Submit via [portal]
   ```

### Step 6: Present Results

```markdown
# Submission Report
**Date:** [YYYY-MM-DD]
**Target Journal:** [name]
**Aggregate Score:** [XX/100]

## Gate Status: [PASS / FAIL]

| Component | Score | Threshold | Status |
|-----------|-------|-----------|--------|
| Aggregate | XX | >= 95 | ✓/✗ |
| Identification | XX | >= 80 | ✓/✗ |
| Code | XX | >= 80 | ✓/✗ |
| Paper | XX | >= 80 | ✓/✗ |
| Replication | X/10 | 10/10 | ✓/✗ |

## Generated Materials
- Cover letter: quality_reports/cover_letter_*.tex
- Submission checklist: quality_reports/submission_checklist_*.md

## Remaining Steps (manual)
1. Upload to [submission portal]
2. Enter suggested referees
3. Submit
```

---

## Principles

- **This is the final gate.** Score >= 95 + all components >= 80. No exceptions.
- **Don't skip verification.** Even if reports exist, check they're recent.
- **If it fails, stop.** List blocking issues. Don't generate submission materials for a failing paper.
- **Cover letter is a draft.** The user must review and customize before sending.
- **Manual submission.** This skill prepares materials but does NOT submit to journals.

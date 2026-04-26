---
name: review-stata
description: Read-only Stata code review protocol for `.do` scripts. Checks reproducibility, version pinning, path discipline, logging, estimation hygiene, output structure, and professional standards; produces a report without editing. Use when user says "review this do-file", "check the Stata code", "audit the analysis", "code review on the Stata", or when a `.do` file is touched as part of a paper submission. NOT for running the code — pair with `/audit-reproducibility` for numeric verification.
argument-hint: "[filename or 'all' or '<route-name>']"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# Review Stata Scripts

Run the comprehensive Stata code review protocol.

## Steps

1. **Identify scripts to review:**
   - If `$ARGUMENTS` is a specific `.do` filename: review that file only
   - If `$ARGUMENTS` is a route name (e.g., `parental_awareness`): review all `.do` files under `scripts/stata/depression_internet/<route>/`
   - If `$ARGUMENTS` is `all`: review all `.do` files under `scripts/stata/**` and `Figures/**/*.do`

2. **For each script, launch the `stata-reviewer` agent** with instructions to:
   - Follow the full protocol in the agent instructions
   - Read `.claude/rules/stata-code-conventions.md` for current standards
   - Read `.claude/rules/quality-gates.md` (Stata section) for severity weights
   - Save report to `quality_reports/[script_name]_stata_review.md`

3. **After all reviews complete**, present a summary:
   - Total issues found per script
   - Breakdown by severity (Critical / High / Medium / Low)
   - Top 3 most critical issues
   - Replication readiness verdict per script

4. **IMPORTANT: Do NOT edit any `.do` source files.**
   Only produce reports. Fixes are applied after user review.

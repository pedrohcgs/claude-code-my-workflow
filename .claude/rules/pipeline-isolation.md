# Pipeline Isolation (Enforced by Hook)

**Principle from StatsClaw:** "Critics never create. Creators never self-score."

## What the Hook Enforces

The `enforce-isolation.sh` PreToolUse hook blocks reviewer agents from calling Edit/Write on any file outside `quality_reports/`. This is **100% compliance** -- not a guideline.

### Reviewer Agents (Read-Only)

| Agent | Can Read | Can Write To | Cannot Write To |
|-------|----------|-------------|-----------------|
| proofreader | Everything | `quality_reports/` | Slides, Quarto, R scripts |
| slide-auditor | Everything | `quality_reports/` | Slides, Quarto, R scripts |
| pedagogy-reviewer | Everything | `quality_reports/` | Slides, Quarto, R scripts |
| domain-reviewer | Everything | `quality_reports/` | Slides, Quarto, R scripts |
| tikz-reviewer | Everything | `quality_reports/` | Slides, Quarto, R scripts |
| quarto-critic | Everything | `quality_reports/` | Slides, Quarto, R scripts |
| r-reviewer | Everything | `quality_reports/` | Slides, Quarto, R scripts |

### Fixer Agents (Can Write)

| Agent | Can Write To |
|-------|-------------|
| quarto-fixer | Quarto files, quality_reports/ |
| beamer-translator | Quarto files, quality_reports/ |
| Main session (no agent) | Everything |

## Why This Matters

A reviewer who also fixes has incentive to find only fixable issues. Separation keeps criticism honest. When the hook blocks a write, the reviewer should instead document the issue in their report with:
- Exact file and line number
- Current text
- Proposed fix
- Severity (Critical/Major/Minor)

The orchestrator or fixer then implements the fix.

## False Convergence Detection

After a fixer applies fixes, the reviewer re-reviews. The reviewer MUST:
1. Verify the specific issue was resolved (not just that the file looks OK)
2. Check that the fix matches the reviewer's intent (not a reinterpretation)
3. If the fix addresses a different problem than reported, flag as **FALSE CONVERGENCE**

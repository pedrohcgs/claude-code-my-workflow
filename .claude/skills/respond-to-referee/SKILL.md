---
name: respond-to-referee
description: Structure point-by-point responses to referee reports for academic economics papers. Classifies comments, tracks required analyses, drafts diplomatic language, and maintains a revision tracker. Use when user has received referee reports or asks to "respond to referees", "write response letter", or "draft revision".
disable-model-invocation: true
argument-hint: "[referee-report file path] [paper file path (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Respond to Referee

Structure a point-by-point response to referee reports with classification, tracking, and diplomatic drafting.

**Input:** `$ARGUMENTS` — path to referee report file(s). Optionally followed by paper path.

---

## Step 1: Parse Inputs

1. Read referee report(s) from `$ARGUMENTS`
   - Check `master_supporting_docs/` for reports if path not explicit
   - Support multiple referee reports (Referee 1, Referee 2, Editor)
2. Read the paper (`Paper/main.tex` or specified path) if available
3. Read existing R scripts to know what analyses are already done

---

## Step 2: Classify Every Comment

For each referee point, assign a classification:

| Class | Meaning | Action Required |
|-------|---------|-----------------|
| **NEW ANALYSIS** | Requires running new regressions, collecting data, or substantive new content | HIGH priority — flag for user |
| **CLARIFICATION** | Paper already has the answer; needs better exposition | MEDIUM — draft rewrite |
| **REWRITE** | Structural reorganization or significant text revision | MEDIUM — draft new text |
| **DISAGREE** | Referee may be wrong; requires careful diplomatic pushback | HIGH — flag for user review |
| **MINOR** | Typo fix, small wording change, formatting | LOW — draft fix directly |

---

## Step 3: Build Tracking Document

Save to `quality_reports/referee_response_tracker.md`:

```markdown
# Referee Response Tracker: [Paper Title]
**Date:** [YYYY-MM-DD]
**Journal:** [if known]
**Decision:** [R&R / Major Revision / Minor Revision]

## Summary
- Referee 1: N comments (X new analysis, Y clarification, Z disagree, W minor)
- Referee 2: N comments (...)
- Editor: N comments (...)
- **Total new analyses required:** X

## Action Items (Priority Order)

### HIGH: New Analysis Required
| # | Ref | Point | What's Needed | R Script | Status |
|---|-----|-------|---------------|----------|--------|
| 1 | R1.3 | [Brief] | [Description] | [script if exists] | TODO |

### MEDIUM: Clarification / Rewriting
| # | Ref | Point | Current Location | Change Needed |
|---|-----|-------|-----------------|---------------|
| 1 | R1.1 | [Brief] | Section X, p. Y | [Description] |

### LOW: Minor Edits
- [ ] R1.7: Fix typo on p. 12
- [ ] R2.4: Update Table 3 note
```

---

## Step 4: Draft Response Letter

Structure the response letter:

```latex
\documentclass[12pt]{article}
\usepackage[margin=1in]{geometry}
\usepackage{xcolor}
\definecolor{response}{RGB}{0,0,128}

\begin{document}

\title{Response to Referee Reports}
\author{[Authors]}
\date{\today}
\maketitle

Dear Editor,

We thank the editor and referees for their careful and constructive comments.
We have revised the manuscript to address all points raised. Below we provide
a detailed point-by-point response.

\bigskip

\textbf{Summary of major changes:}
\begin{enumerate}
\item [Major change 1 — addresses R1.3, R2.1]
\item [Major change 2 — addresses R1.5]
\item [Major change 3 — addresses Editor comment]
\end{enumerate}

\newpage

\section*{Response to Referee 1}

\subsection*{Comment 1.1}
\textit{[Exact quote or faithful paraphrase of referee comment]}

\medskip

\textcolor{response}{%
\textbf{Response:} [Draft response]

\textbf{Paper change:} [Specific location — Section X, page Y, paragraph Z]
}

% [Repeat for each comment]

\end{document}
```

---

## Step 5: Diplomatic Disagreement Protocol

When classification is **DISAGREE**:

1. **Open with acknowledgment:**
   "We appreciate Referee [N]'s insightful concern regarding..."

2. **Provide specific evidence** for the disagreement:
   - Cite a theorem, equation number, or published result
   - Reference specific data or estimation output
   - Point to the relevant section of the paper

3. **Offer a partial concession** where possible:
   - "To address this concern, we have added a footnote on p. X discussing..."
   - "We now include an additional robustness check in Appendix Table A.X that..."
   - "We have expanded the discussion in Section Y to clarify..."

4. **Never say:**
   - "The referee is wrong"
   - "The referee misunderstood"
   - "This is incorrect"

5. **Instead say:**
   - "We respectfully note that..."
   - "Upon reflection, we believe the current approach is appropriate because..."
   - "We appreciate this suggestion and have considered it carefully. We maintain... because..."

6. **FLAG to user:** "This is a DISAGREE classification — please review carefully before sending."

---

## Step 6: Save Outputs

1. **Tracking document:** `quality_reports/referee_response_tracker.md`
2. **Response letter draft:** `quality_reports/referee_response_[journal]_[date].tex`
3. **Update paper todo:** If NEW ANALYSIS items exist, list them as concrete tasks

---

## Principles

- **The response letter is the user's voice, not Claude's.** Match their academic tone.
- **Never fabricate empirical results** for NEW ANALYSIS items. Mark them as "TBD: [description of needed analysis]."
- **Flag all DISAGREE items prominently** — these need human judgment.
- **Be concise in responses.** Referees appreciate brevity. Don't over-explain.
- **Track everything.** Every referee comment must appear in both the tracker and the response letter.
- **Acknowledge legitimate criticism graciously.** A revision that takes feedback seriously is more likely to succeed.
- **Prioritize the editor's comments.** The editor's letter often signals which referee concerns are most important.

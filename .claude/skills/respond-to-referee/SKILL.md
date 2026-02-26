---
name: respond-to-referee
description: Structure point-by-point referee responses using the revision-protocol routing. Classifies comments (NEW ANALYSIS / CLARIFICATION / DISAGREE / MINOR), dispatches appropriate agents, and tracks revisions. Use when asked to "respond to referees" or "draft revision".
disable-model-invocation: true
argument-hint: "[referee-report file path] [paper file path (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Respond to Referee

Structure a point-by-point response to referee reports with classification, agent routing per `revision-protocol.md`, and diplomatic drafting.

**Input:** `$ARGUMENTS` — path to referee report file(s). Optionally followed by paper path.

---

## Workflow

### Step 1: Parse Inputs

1. Read referee report(s) from `$ARGUMENTS`
   - Check `master_supporting_docs/` if path not explicit
   - Support multiple reports (Referee 1, Referee 2, Editor)
2. Read the paper (`Paper/main.tex` or specified path)
3. Read `.claude/rules/revision-protocol.md` for routing rules
4. Read existing scripts to know what analyses already exist

### Step 2: Classify Every Comment

Per `revision-protocol.md`, assign each referee point:

| Class | Routing | Action |
|-------|---------|--------|
| **NEW ANALYSIS** | → Coder agent | Flag for user, create analysis task |
| **CLARIFICATION** | → Writer agent | Draft rewritten section |
| **REWRITE** | → Writer agent | Draft structural revision |
| **DISAGREE** | → User (mandatory) | Draft diplomatic pushback, flag for review |
| **MINOR** | → Writer agent | Draft fix directly |

### Step 3: Build Tracking Document

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
| # | Ref | Point | Agent | Status |
|---|-----|-------|-------|--------|
| 1 | R1.3 | [Brief] | Coder | TODO |

### MEDIUM: Clarification / Rewriting
| # | Ref | Point | Agent | Status |
|---|-----|-------|-------|--------|
| 1 | R1.1 | [Brief] | Writer | TODO |

### FLAGGED: Disagreements (require user review)
| # | Ref | Point | Draft Response |
|---|-----|-------|---------------|
| 1 | R2.5 | [Brief] | [Draft] |

### LOW: Minor Edits
- [ ] R1.7: Fix typo on p. 12
```

### Step 4: Dispatch Agents for CLARIFICATION/REWRITE

For comments classified as CLARIFICATION or REWRITE:
- Dispatch Writer agent with specific instructions for each point
- Writer drafts revised text matching the user's voice

For NEW ANALYSIS:
- Do NOT dispatch Coder automatically — flag for user approval first
- Create concrete task descriptions for each required analysis

### Step 5: Draft Response Letter

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
We have revised the manuscript to address all points raised.

\bigskip

\textbf{Summary of major changes:}
\begin{enumerate}
\item [Major change 1 — addresses R1.3, R2.1]
\item [Major change 2 — addresses R1.5]
\end{enumerate}

\newpage
\section*{Response to Referee 1}

\subsection*{Comment 1.1}
\textit{[Exact quote of referee comment]}

\medskip
\textcolor{response}{%
\textbf{Response:} [Draft response]

\textbf{Paper change:} [Section X, page Y]
}

\end{document}
```

### Step 6: Diplomatic Disagreement Protocol

When classification is **DISAGREE**:
1. Open with acknowledgment
2. Provide specific evidence (theorem, data, published result)
3. Offer partial concession where possible
4. **Never say:** "The referee is wrong/misunderstood"
5. **Instead say:** "We respectfully note...", "Upon reflection, we believe..."
6. **FLAG prominently** for user review

### Step 7: Save Outputs

1. **Tracker:** `quality_reports/referee_response_tracker.md`
2. **Response letter:** `quality_reports/referee_response_[journal]_[date].tex`
3. **Revised sections:** `Paper/sections/` (only for CLARIFICATION/REWRITE items)

---

## Principles

- **The response letter is the user's voice.** Match their academic tone.
- **Never fabricate results.** Mark NEW ANALYSIS items as TBD.
- **Flag all DISAGREE items.** These need human judgment.
- **Prioritize editor's comments.** The editor signals which concerns matter most.
- **Track everything.** Every referee comment appears in both tracker and response letter.
- **Route per protocol.** Follow `revision-protocol.md` for agent dispatch.

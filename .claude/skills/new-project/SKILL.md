---
name: new-project
description: Full research pipeline from idea to paper. Orchestrates all phases — interview, literature review, data discovery, identification strategy, analysis, paper drafting, and peer review. Use when starting a new research project from scratch.
disable-model-invocation: true
argument-hint: "[research topic or 'interactive' for guided start]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task", "WebSearch", "WebFetch"]
---

# New Project

Launch a full research pipeline from idea to paper, orchestrated through the dependency graph.

**Input:** `$ARGUMENTS` — a research topic or `interactive` for a guided start via `/interview-me`.

---

## Pipeline Overview

This skill orchestrates the full v3 dependency graph. Each phase activates when its dependencies are met. The orchestrator manages agent dispatch, three-strikes escalation, and quality gates.

```
Phase 1: Discovery
  ├── /interview-me → Research Spec + Domain Profile
  └── /lit-review → Literature Synthesis + BibTeX

Phase 2: Strategy (depends on Phase 1)
  ├── /find-data → Data Assessment
  └── /identify → Strategy Memo + Robustness Plan

Phase 3: Execution (depends on Phase 2)
  ├── /data-analysis → Scripts + Tables + Figures
  └── /draft-paper → Paper Sections

Phase 4: Peer Review (depends on Phase 3)
  ├── /review-paper → Referee Reports + Editorial Decision
  └── /paper-excellence → Aggregate Score

Phase 5: Submission (depends on Phase 4, score >= 95)
  ├── /target-journal → Journal Recommendations
  ├── /data-deposit → Replication Package
  └── /submit → Final Verification
```

---

## Workflow

### Step 1: Discovery Phase

1. **If `interactive` or no research spec exists:**
   Run `/interview-me` to produce:
   - Research specification (`quality_reports/research_spec_*.md`)
   - Domain profile (`.claude/rules/domain-profile.md`) — if still template

2. **Run `/lit-review`** with the research topic:
   - Librarian collects literature
   - Editor critiques coverage
   - Output: literature synthesis + BibTeX entries

**Gate:** Research spec and literature review must exist before proceeding.

### Step 2: Strategy Phase

3. **Run `/find-data`** to identify and assess datasets:
   - Explorer searches for data sources
   - Surveyor critiques data quality

4. **Run `/identify`** to design the empirical strategy:
   - Strategist proposes identification strategy
   - Econometrician critiques the design

**Gate:** Strategy memo must pass Econometrician review (score >= 80).

### Step 3: Execution Phase

5. **Run `/data-analysis`** to implement the strategy:
   - Coder writes scripts
   - Debugger reviews code

6. **Run `/draft-paper`** to write up results:
   - Writer drafts sections
   - Humanizer pass strips AI patterns

**Gate:** Code must pass Debugger review. Paper sections must exist.

### Step 4: Peer Review Phase

7. **Run `/paper-excellence`** for comprehensive review:
   - Econometrician + Debugger + Proofreader + Verifier in parallel
   - Weighted aggregate score computed

8. **Run `/review-paper`** for simulated peer review:
   - 2 blind Referees + Editor

**Gate:** Aggregate score >= 80 (commit-ready). Score >= 90 for submission.

### Step 5: Submission Phase (optional, user-triggered)

9. **Run `/target-journal`** for journal recommendations
10. **Run `/data-deposit`** for replication package
11. **Run `/submit`** for final verification

---

## User Interaction Points

The pipeline pauses for user input at these points:
- After interview (approve research spec)
- After strategy memo (approve identification strategy)
- After data analysis (review results before paper drafting)
- After peer review (review feedback before revision)
- Before submission (approve journal choice)

Between pauses, the orchestrator runs autonomously per `orchestrator-protocol.md`.

---

## Principles

- **This is always orchestrated.** Unlike other skills, `/new-project` always runs through the full pipeline.
- **Dependency-driven.** Phases activate by dependency, not forced sequence.
- **Quality-gated.** Each phase transition requires passing quality checks.
- **User retains control.** Pipeline pauses at key decision points.
- **Resumable.** If interrupted, the pipeline resumes from the last completed phase.

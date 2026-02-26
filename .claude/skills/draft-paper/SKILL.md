---
name: draft-paper
description: Draft academic economics papers by dispatching the Writer agent. Handles section drafting, notation protocol, anti-hedging, and humanizer pass. Use when asked to "draft the paper", "write up the results", or "write the intro".
disable-model-invocation: true
argument-hint: "[section: intro | empirical-strategy | results | conclusion | abstract | full] [paper path (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Draft Paper

Draft an academic economics paper (or specific section) by dispatching the **Writer** agent.

**Input:** `$ARGUMENTS` — section name (`intro`, `empirical-strategy`, `results`, `conclusion`, `abstract`, `full`) optionally followed by a paper path.

---

## Workflow

### Step 1: Context Gathering

Before dispatching the Writer:
1. Read existing paper draft in `Paper/` (if it exists)
2. Read `master_supporting_docs/` for notes, outlines, research specs
3. Read most recent `quality_reports/research_spec_*.md` or `quality_reports/lit_review_*.md`
4. Read `.claude/rules/domain-profile.md` for field conventions
5. Check `Bibliography_base.bib` for available citations
6. Scan `Tables/` and `Figures/` for generated output
7. Read `quality_reports/results_summary.md` if it exists (from Coder)

### Step 2: Section Routing

Based on `$ARGUMENTS`:
- **`full`**: Draft all sections in sequence, pausing between major sections for user feedback
- **`intro`**: Draft introduction (most common request)
- **`empirical-strategy`**: Draft identification and estimation section
- **`results`**: Draft results from available output
- **`conclusion`**: Draft conclusion
- **`abstract`**: Draft abstract (must have other sections first)
- **No argument**: Ask user which section to draft

### Step 3: Launch Writer Agent

Delegate to the `writer` agent via Task tool:

```
Prompt: Draft the [section] section for [paper].
Follow section standards:
  - Introduction: contribution paragraph within first 2 pages, effect sizes stated
  - Empirical strategy: estimating equation displayed and numbered, assumptions explicit
  - Results: every estimate with units, magnitudes not just signs
  - Conclusion: restate with effect size, limitations, implications
Apply notation protocol (Y_it, D_it, gamma_i, delta_t, epsilon_it).
Apply anti-hedging rules (ban "interestingly", "it is worth noting", etc.).
Run humanizer pass before finalizing.
Save to Paper/sections/[section_name].tex
```

The Writer follows these standards:

#### Introduction (~1,000-1,500 words)
- Hook → research question → what we do → what we find → contribution → road map
- Contribution paragraph names specific papers being advanced
- Effect sizes with magnitudes and units

#### Empirical Strategy (~800-1,200 words)
- Identification assumption stated formally
- Estimating equation displayed and numbered
- Threats to identification addressed

#### Results (~800-1,500 words)
- Main specification with interpretation
- Effect sizes in economic terms
- Heterogeneity and robustness

#### Conclusion (~500-700 words)
- Restate with effect size
- Policy implications
- Limitations and future work

### Step 4: Humanizer Pass

The Writer automatically applies the humanizer as a final pass:
- Strips 24 AI writing patterns across 4 categories (structural, lexical, rhetorical, formatting)
- Applies academic adaptation rules (preserve formal structure, keep technical terms)
- This is built into the Writer agent — no separate dispatch needed

### Step 5: Quality Self-Check

Before presenting the draft:
- [ ] Every displayed equation is numbered (`\label{eq:...}`)
- [ ] All `\cite{}` keys exist in `Bibliography_base.bib`
- [ ] Introduction contribution paragraph names specific papers
- [ ] Effect sizes stated with units
- [ ] No banned hedging phrases
- [ ] Notation consistent throughout
- [ ] All tables/figures referenced exist

### Step 6: Present to User

Present each section for feedback. Flag:
- **TBD items:** Where empirical results are needed but not yet available
- **VERIFY items:** Citations that need user confirmation
- **PLACEHOLDER items:** Effect sizes awaiting final estimates

---

## Principles

- **This is the user's paper, not Claude's.** Match their voice and style.
- **Never fabricate results.** Use TBD placeholders.
- **Citations must be verifiable.** Only cite papers you can confirm exist.
- **Humanizer is automatic.** Every draft gets de-AI-ified before presentation.
- **LaTeX best practices.** `\citet` for textual, `\citep` for parenthetical, `booktabs` for tables.

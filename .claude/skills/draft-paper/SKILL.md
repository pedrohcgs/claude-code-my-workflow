---
name: draft-paper
description: Draft academic economics papers with proper structure, introduction with contribution paragraph, empirical strategy section, and results. Handles LaTeX formatting with proper econometrics notation. Use when user says "draft the paper", "write up the results", "help me structure the paper", or "write the intro".
disable-model-invocation: true
argument-hint: "[section to draft: intro | empirical-strategy | results | conclusion | abstract | full] [paper path (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task"]
---

# Draft Paper

Draft an academic economics paper (or specific section) with proper structure and notation.

**Input:** `$ARGUMENTS` — section name (`intro`, `empirical-strategy`, `results`, `conclusion`, `abstract`, `full`) optionally followed by a paper path.

---

## Step 0: Context Gathering

Before drafting anything:
1. Read existing paper draft in `Paper/` (if it exists)
2. Read `master_supporting_docs/` for notes, outlines, research specs
3. Read most recent `quality_reports/research_spec_*.md` or `quality_reports/lit_review_*.md`
4. Check `Bibliography_base.bib` for available citations
5. Scan `scripts/R/` for analysis output (tables, figures) to reference
6. Scan `Tables/` and `Figures/` for generated output

---

## Step 1: Section Routing

Based on `$ARGUMENTS`:
- **`full`**: Draft all sections in sequence, pausing between major sections for user feedback
- **`intro`**: Draft introduction (most common request)
- **`empirical-strategy`**: Draft identification and estimation section
- **`results`**: Draft results from available R output
- **`conclusion`**: Draft conclusion
- **`abstract`**: Draft abstract from completed paper (must have other sections first)
- **No argument**: Ask user which section to draft

---

## Step 2: Economics Paper Structure

Use this structure for `full` or as reference for individual sections:

### 1. Introduction (~1,000-1,500 words)

```latex
% Structure:
% a. Hook — motivating fact, puzzle, or policy question
% b. Research question — one clear sentence
% c. What we do — empirical strategy, 1-2 sentences
% d. What we find — main results with effect sizes
% e. Contribution paragraph — how we advance the literature
% f. Road map — optional, 2-3 sentences
```

**Contribution paragraph rules:**
- Name specific papers being advanced beyond
- State precise novelty claim (new data, new method, new result)
- "We contribute to the growing literature on X" is BANNED — be specific

**Effect sizes rules:**
- State magnitudes: "a 10 percentage point increase in X leads to a Y% decrease in Z"
- Never just signs: "X increases Y" is insufficient without magnitude

### 2. Related Literature (~800-1,200 words, or integrated into intro)

Organize into 2-3 strands:
- Strand 1: Most closely related empirical work — how this paper differs
- Strand 2: Methodological contribution (if any)
- Strand 3: Broader economics literature this connects to

### 3. Background / Institutional Setting (if applicable)

- Institutional details that make the identification strategy credible
- Policy description with key dates and variation sources
- Only include what's necessary for understanding the empirical design

### 4. Data (~500-800 words)

- Data sources with full citations
- Sample construction with explicit inclusion/exclusion criteria
- Variable definitions (especially treatment, outcome, controls)
- Summary statistics table (Table 1)
- Pre-treatment balance table (if applicable)

### 5. Empirical Strategy (~800-1,200 words)

- Identification assumption stated formally
- Estimating equation displayed and numbered:
  ```latex
  \begin{equation}
  Y_{it} = \alpha + \tau D_{it} + X_{it}'\beta + \gamma_i + \delta_t + \varepsilon_{it}
  \label{eq:main}
  \end{equation}
  ```
- Threats to identification and how they're addressed
- Design-specific validation (parallel trends for DiD, McCrary for RDD, first-stage for IV)

### 6. Results (~800-1,500 words)

- Main specification (Table 2) with clear interpretation
- Heterogeneity analysis (if pre-specified)
- Robustness checks (Table 3 or Appendix)
- Mechanism evidence (if applicable)

### 7. Conclusion (~500-700 words)

- Restate question and answer with effect size
- Policy implications (if relevant and supported by results)
- Limitations stated honestly
- Future work directions (brief)

---

## Step 3: Notation Protocol

All math in `equation` or `align` environments, numbered:
- Subscripts: $i$ individual, $t$ time, $g$ group/cohort, $j$ firm/region
- Treatment: $D_{it}$ or $D_i$ depending on timing variation
- Outcome: $Y_{it}$
- ATT: $ATT(g,t)$ for group-time, $\tau_{ATT}$ for aggregate
- Fixed effects: $\gamma_i$ (unit), $\delta_t$ (time)
- Error: $\varepsilon_{it}$

Check `Bibliography_base.bib` for correct citation keys before inserting `\cite{}`.

---

## Step 4: Anti-Hedging Rules

**BANNED phrases** (flag if present in draft):
- "it is worth noting that"
- "interestingly"
- "importantly"
- "it should be noted"
- "needless to say"
- "it goes without saying"
- "we contribute to the growing literature" (without specifics)
- "the results are broadly consistent with"

**PREFERRED alternatives:**
- State the fact directly without preamble
- "We find that X increases Y by Z%" (not "Interestingly, X appears to increase Y")
- "Our estimates imply..." (not "The results are broadly consistent with...")

---

## Step 5: Quality Self-Check

Before presenting the draft:
- [ ] Every displayed equation is numbered (`\label{eq:...}`)
- [ ] All `\cite{}` keys exist in `Bibliography_base.bib` (grep to verify)
- [ ] Introduction contribution paragraph names specific papers
- [ ] Effect sizes are stated with units in introduction
- [ ] No banned hedging phrases
- [ ] Notation is consistent throughout
- [ ] All tables/figures referenced exist in `Tables/` or `Figures/`

---

## Output

Save drafts to `Paper/sections/[section_name].tex` (individual sections) or `Paper/main.tex` (full paper).

Present each section to user for feedback before moving to the next. Flag any places where:
- Empirical results are needed but not yet available ("TBD: insert Table 2 results")
- Citations need verification ("% VERIFY: check Author (Year) citation key")
- Effect sizes are placeholder ("TBD: insert coefficient estimate from main regression")

---

## Principles

- **This is the user's paper, not Claude's.** Match their voice and style from existing drafts.
- **Never fabricate results.** If R output isn't available, write "TBD" placeholders.
- **Citations must be verifiable.** Only cite papers you can confirm exist.
- **Sections can stand alone.** Each section file should compile independently with the shared preamble.
- **LaTeX best practices:** `\citet` for textual citations, `\citep` for parenthetical. Use `booktabs` for tables. Use `\input{}` for table files generated by R.

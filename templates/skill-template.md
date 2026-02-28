# Skill Creation Template

**Use this template to create domain-specific skills for your academic workflow.**

---

## When to Create a Custom Skill

Create a skill when you find yourself:
- Repeatedly explaining the same 3+ step workflow to Claude
- Needing domain-specific quality checks (citation style, notation consistency, lab protocols)
- Enforcing field-specific output formats (thesis structure, journal templates, lab notebooks)
- Coordinating multi-tool workflows (Figma → R → LaTeX, data → analysis → manuscript)

**Don't create a skill for:**
- One-time tasks
- Workflows that change frequently
- Simple 1-2 step operations

---

## Template Structure

Copy the structure below to `.claude/skills/[your-skill-name]/SKILL.md`:

```markdown
---
name: your-skill-name
description: [What it does] + [When to use it] + [Key capabilities]. Use when user asks for "[trigger phrase 1]", "[trigger phrase 2]", or "[context]".
argument-hint: "[brief hint for user]"
allowed-tools: ["Read", "Write", "Edit", "Grep", "Glob", "Bash", "Task"]
---

# [Skill Name]

[One sentence: what this skill accomplishes and why it exists]

## Instructions

Step 1: [First major action with clear explanation]
   - Detail: [Important consideration]
   - Example: [Concrete example]

Step 2: [Second major action]
   - Detail: [Important consideration]

Step 3: [Final action and verification]
   - Verify: [What to check]
   - Output: [What user receives]

## Examples

### Example 1: [Common Scenario Name]
**Context:** [When this occurs]
**User says:** "[Typical user request]"
**Actions:**
1. [What skill does first]
2. [What skill does second]
3. [Final output]
**Result:** [What user receives]

### Example 2: [Another Common Scenario]
**Context:** [Different situation]
**User says:** "[Alternative phrasing]"
**Actions:**
1. [Different path through the skill]
**Result:** [Expected outcome]

## Troubleshooting

**Error:** [Common error message or symptom]
**Cause:** [Why this happens]
**Solution:** [How to fix it]

**Error:** [Another common issue]
**Cause:** [Root cause]
**Solution:** [Fix steps]
```

---

## Writing Effective Descriptions

The `description` field determines when Claude loads your skill. Use this structure:

```
[What it does] + [When to use it] + [Key capabilities]
```

### Good Examples (Field-Specific)

**Citation Style Enforcement (APA Psychology):**
```yaml
description: Enforces APA 7th edition citation format in manuscripts. Use when user asks to "check citations", "fix references", "apply APA style", or when reviewing .tex or .qmd files with bibliography. Checks author-year format, DOI formatting, and reference list completeness.
```

**Lab Notebook Entry Generator (Wet Lab Biology):**
```yaml
description: Generates structured lab notebook entries from experimental notes. Use when user provides "experiment notes", "protocol results", or asks to "format lab entry". Ensures date, hypothesis, materials, procedure, observations, and conclusions are documented.
```

**Thesis Chapter Structure Checker (Graduate Students):**
```yaml
description: Validates thesis chapter structure against institutional requirements. Use when user asks to "check chapter format", "validate thesis structure", or when editing thesis .tex or .docx files. Verifies required sections, heading levels, and citation density.
```

**Econometric Specification Review (Economics):**
```yaml
description: Reviews econometric specifications for common errors. Use when user shares regression code in R or Stata, or asks to "check model spec", "review estimation". Validates: standard error clustering, fixed effects structure, missing covariates, and replication commands.
```

### Bad Examples (Too Generic)

❌ `description: Helps with citations`
→ Too vague, doesn't specify style or when to trigger

❌ `description: Checks lab notebooks`
→ Missing trigger phrases, no format specification

❌ `description: Reviews thesis chapters`
→ Doesn't specify what aspects or when to activate

---

## Academic Domain Examples

### Example 1: Citation Cross-Reference Checker

**File:** `.claude/skills/validate-citations/SKILL.md`

```markdown
---
name: validate-citations
description: Cross-references in-text citations against bibliography entries. Use when user asks to "check citations", "validate references", or when working on .tex, .qmd, or .md files with bibliographies. Identifies missing entries, unused references, and formatting inconsistencies.
argument-hint: "[file or 'all']"
allowed-tools: ["Read", "Grep", "Glob", "Write"]
---

# Validate Citations

Ensures all in-text citations have corresponding bibliography entries and identifies unused references.

## Instructions

Step 1: **Extract in-text citations**
   - Use Grep to find citation commands: `\cite{...}`, `\citep{...}`, `[@...]`
   - Build list of cited keys

Step 2: **Parse bibliography file**
   - Read Bibliography_base.bib (or specified .bib file)
   - Extract all `@article{key,`, `@book{key,` entries

Step 3: **Cross-reference**
   - Missing in bib: citations without entries
   - Unused in bib: entries never cited

Step 4: **Report findings**
   - Save to `quality_reports/citation_validation.md`
   - List missing entries (CRITICAL)
   - List unused entries (for cleanup)
   - Check DOI formatting if present

## Examples

### Example 1: Manuscript with Missing Citation
**User says:** "Check if all my citations are in the bib file"
**Actions:**
1. Grep for `\citep{` in manuscript.tex
2. Extract keys: `Smith2020`, `Jones2019`, `Lee2021`
3. Parse Bibliography_base.bib
4. Find `Lee2021` missing
**Result:** Report: "Missing entry: Lee2021. Add to bibliography before submission."

## Troubleshooting

**Error:** Citation format not recognized
**Cause:** Non-standard citation command
**Solution:** Add pattern to Step 1 grep (e.g., `\citeauthor`, `\citeyear`)
```

---

### Example 2: Regression Output Formatter

**File:** `.claude/skills/format-regression-tables/SKILL.md`

```markdown
---
name: format-regression-tables
description: Converts R regression outputs to publication-ready LaTeX tables. Use when user runs regressions and says "make a table", "format results", or "export to LaTeX". Handles lm, glm, felm, and fixest objects. Applies field-specific conventions (standard errors in parentheses, stars for significance).
argument-hint: "[model object name]"
allowed-tools: ["Read", "Write", "Bash"]
---

# Format Regression Tables

Converts R regression objects into publication-ready LaTeX tables with proper formatting.

## Instructions

Step 1: **Identify model objects**
   - User provides R object names (e.g., `model1`, `model2`)
   - Read corresponding .rds files from output/

Step 2: **Extract coefficients and statistics**
   - Coefficient estimates
   - Standard errors (in parentheses)
   - Significance stars: * p<0.10, ** p<0.05, *** p<0.01
   - R-squared, N observations

Step 3: **Generate LaTeX table**
   - Use booktabs style (no vertical lines)
   - Align on decimal points
   - Add notes for standard errors and significance

Step 4: **Save and verify**
   - Save to `output/tables/regression_results.tex`
   - Verify compiles in standalone .tex document

## Examples

### Example 1: Panel Regression with Fixed Effects
**User says:** "Format my regression results for the paper"
**Context:** User has run `felm(y ~ x | firm + year | 0 | firm, data=df)`
**Actions:**
1. Read saved model object
2. Extract: coefficients, clustered SEs, R², N
3. Generate LaTeX:
   ```latex
   \begin{table}[htbp]
   \caption{Effect of X on Y}
   \begin{tabular}{lc}
   \toprule
   & (1) \\
   \midrule
   X & 0.523*** \\
     & (0.089) \\
   \midrule
   Firm FE & Yes \\
   Year FE & Yes \\
   \midrule
   Observations & 1,234 \\
   R-squared & 0.678 \\
   \bottomrule
   \multicolumn{2}{l}{\footnotesize Clustered SEs in parentheses.} \\
   \multicolumn{2}{l}{\footnotesize * p<0.10, ** p<0.05, *** p<0.01}
   \end{tabular}
   \end{table}
   ```
**Result:** Ready to `\input` in manuscript.tex

## Troubleshooting

**Error:** Model object not found
**Cause:** .rds file not in expected location
**Solution:** Check output/ directory, verify saveRDS() was called

**Error:** Standard errors missing
**Cause:** Model didn't specify clustering/robust SEs
**Solution:** Re-run with vcov specification, document assumption
```

---

### Example 3: Experimental Protocol Validator

**File:** `.claude/skills/validate-protocol/SKILL.md`

```markdown
---
name: validate-protocol
description: Validates experimental protocols against lab safety and reproducibility standards. Use when user provides lab protocol documents, asks to "check protocol", "validate procedure", or when reviewing .md or .docx experimental designs. Ensures required sections, safety notes, and replication details are present.
argument-hint: "[protocol file]"
allowed-tools: ["Read", "Write"]
---

# Validate Experimental Protocol

Checks experimental protocols for completeness, safety documentation, and reproducibility.

## Instructions

Step 1: **Parse protocol document**
   - Extract sections: Objective, Materials, Procedure, Safety, Expected Results
   - Check for required metadata: Date, Version, Author

Step 2: **Validate required elements**
   - Materials list complete (catalog numbers, suppliers)
   - Safety warnings for hazardous materials
   - Quantitative measurements (volumes, temperatures, times)
   - Controls specified

Step 3: **Reproducibility check**
   - Equipment specifications listed
   - Randomization described (if applicable)
   - Sample sizes justified
   - Data recording method specified

Step 4: **Generate report**
   - PASS/FAIL for each section
   - Missing elements highlighted
   - Suggestions for improvement

## Examples

### Example 1: Cell Culture Protocol
**User says:** "Check if my protocol is complete before submitting to IRB"
**Context:** Protocol for isolating primary neurons
**Actions:**
1. Read protocol.md
2. Check Materials: ✓ catalog numbers present
3. Check Safety: ✗ missing biosafety level designation
4. Check Procedure: ✓ quantitative (37°C, 5% CO₂, 10 mL media)
**Result:** Report: "Missing: BSL-2 designation. Add before IRB submission."

## Troubleshooting

**Error:** Cannot parse sections
**Cause:** Non-standard heading format
**Solution:** Add heading patterns to Step 1 (e.g., "### Safety Notes")
```

---

## Testing Your Skill

### Step 1: Manual Test
1. Create skill directory: `mkdir -p .claude/skills/your-skill-name`
2. Copy SKILL.md template and customize
3. Skills hot-reload automatically --- changes are detected without restarting
4. Trigger skill: Use one of your trigger phrases
5. Verify: Skill loads, instructions are clear, output is correct

### Step 2: Iteration
- **If skill doesn't trigger:** Revise description with more specific trigger phrases
- **If instructions unclear:** Add more examples and detail to Steps
- **If output wrong:** Add validation steps, troubleshooting section

### Step 3: Success Criteria
- ✅ Skill triggers on 90%+ of relevant queries
- ✅ Complete workflow in expected number of steps
- ✅ Zero API errors during normal operation
- ✅ Same task yields consistent outputs across sessions

---

## Field-Specific Customization Checklist

When adapting this template to your domain:

- [ ] Replace example trigger phrases with your field's terminology
- [ ] Add domain-specific file types (`.R`, `.py`, `.ipynb`, `.tex`, `.stan`)
- [ ] Include field conventions (notation, formatting, citation styles)
- [ ] Reference standard tools (`ggplot2`, `pandas`, `TikZ`, `Stata`)
- [ ] Add common error messages from your toolchain
- [ ] Include institutional requirements (thesis formats, journal templates)

---

## Allowed Tools Reference

| Tool | Use For |
|------|---------|
| `Read` | Reading file contents (scripts, manuscripts, data) |
| `Write` | Creating new files (reports, tables, outputs) |
| `Edit` | Modifying existing files in place |
| `Grep` | Searching file contents (citations, function names) |
| `Glob` | Finding files by pattern (*.R, *.tex, *.csv) |
| `Bash` | Running commands (R scripts, LaTeX compilation, git) |
| `Task` | Launching subagents (for complex multi-step workflows) |

**Security note:** Only grant `Bash` access if your skill needs to execute code or compile documents. For read-only validation skills, omit it.

---

## Where This Template Lives

- **File:** `templates/skill-template.md`
- **Purpose:** Starter for domain-specific skills
- **Usage:** Copy to `.claude/skills/[name]/SKILL.md`, customize for your field

For existing skills examples, see `.claude/skills/` directory (22 skills for LaTeX, R, Quarto, and research workflows).

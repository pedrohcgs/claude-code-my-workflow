---
name: resume-writer
description: Write, rewrite, translate, polish, or compile professional Chinese/English resumes and CVs. Use this skill whenever the user mentions 简历, resume, CV, curriculum vitae, 求职材料, 实习申请, consulting/finance/tech resume, one-page resume, LaTeX resume, or provides raw experience notes and wants them turned into a polished resume. The skill turns rough materials into high-signal bullet points, chooses the Chinese or English LaTeX template, compiles with xelatex when possible, and verifies one-page quality.
---

# Resume Writer

Create concise, high-signal resumes from messy inputs. Default to a one-page LaTeX resume unless the user explicitly asks for another format.

## Core Rules

- Protect factual integrity. Do not invent schools, employers, titles, awards, dates, GPA, scores, rankings, contact details, publications, or certifications. If a detail is missing, ask for it or use a clearly marked placeholder in the draft.
- Optimize for the role. Lead with the evidence most relevant to the target role, not with chronology or brand names.
- Make every experience bullet scannable. Use a bold label at the start of each work/project bullet, then a compact action-result-insight sentence.
- Preserve user intent and language. If the user asks in Chinese, produce Chinese by default; if they ask in English or provide an English resume, produce English by default.
- Compile and verify when generating `.tex`. Prefer delivering both `.tex` and `.pdf` if the local environment supports `xelatex`.

## Workflow

### 1. Classify The Task

Identify the request type before writing:

| Request type | What to do |
| --- | --- |
| New resume from raw notes | Extract facts, choose structure, draft bullets, fill template, compile |
| Existing resume polish | Preserve truthful content, rewrite bullets, improve ordering, recompile |
| Translation | Translate meaning and role fit, not word-for-word phrasing |
| Role-specific version | Reorder sections and sharpen bullets toward the role |
| Review only | Give prioritized findings with concrete rewrite examples |

When the user asks for "直接帮我做" and enough facts are available, proceed without a long interview. Ask only for blocking details such as target language, target role, or missing identity/contact fields.

### 2. Gather And Normalize Inputs

Collect or infer the working profile:

- Personal info: name, phone, email, LinkedIn/portfolio/GitHub, city if useful.
- Education: school, degree, major, dates, GPA/rank, coursework, scholarships, honors.
- Experience: organization, role, location, dates, project/client context, scope, methods, outputs, measurable results.
- Projects: competition/research/course project name, role, dates, award, methods, data, result.
- Skills: languages, data/AI/tools, certifications, domain knowledge, selective interests.
- Target: role, industry, application language, region, and whether ATS-friendliness matters.

Use `references/intake-checklist.md` when the input is sparse or scattered.

### 3. Choose The Resume Strategy

Pick the organizing principle that best matches the target:

- Consulting / strategy: lead with problem structuring, market sizing, customer research, commercial judgment, slide/report output.
- Finance / investment: lead with investment thesis, modeling, due diligence, valuation, risk judgment, transaction/research output.
- Data / research: lead with data scale, method, validation, robustness, reproducible output, decision implication.
- Product / tech: lead with user problem, system/feature built, stack, adoption, latency/cost/quality impact.
- Early-career generalist: lead with projects, internships, coursework, and proof of execution speed.

Read `references/writing-guidelines.md` before rewriting bullets or when the user asks for a high-end consulting/finance style.

### 4. Draft Bullets

For Chinese resumes:

```latex
\item \textbf{赛道研究：}独立搭建XX分析框架，覆盖XX个样本与XX项指标，识别XX趋势并输出XX页报告。核心判断：XX。
```

For English resumes:

```latex
\item \textbf{Market Analysis:} Built an XX framework across XX samples and XX indicators, identifying XX trend and producing a XX-page report. Core insight: XX.
```

Bullet quality standards:

- Start with a bold label: `\textbf{关键词：}` in Chinese, `\textbf{Short Label:}` in English.
- Prefer strong verbs: built, led, analyzed, quantified, validated, delivered; 中文优先使用“构建、拆解、量化测算、主导、独立完成、验证、交付”。
- Add numbers wherever truthful: sample size, time period, revenue/cost, ranking, users, pages, variables, SKUs, interviews, model metrics.
- End analytical bullets with a conclusion when useful: `核心判断：...` or `Core insight: ...`.
- Keep each bullet to one coherent story. Split unrelated work into separate bullets.

### 5. Fill The Template

Use the bundled template matching the output language:

- Chinese: `assets/template_cn.tex`
- English: `assets/template_en.tex`

Default section order:

1. Header
2. Education
3. Work Experience
4. Projects
5. Skills & Interests

Adjust section order only when it improves role fit, for example placing Projects before Work Experience for a student with stronger project evidence.

### 6. Compile And Verify

Compile with:

```bash
cd <output-dir> && xelatex -interaction=nonstopmode resume.tex
```

If the resume exceeds one page, shrink in this order:

1. Remove weak bullets and repetitive details.
2. Tighten wording and merge low-signal bullets.
3. Reduce section spacing and item spacing slightly.
4. Reduce font size by 0.2pt increments.
5. Reduce margins only as a last resort; avoid going below 1.0cm margins or 7.5pt body text.

Quality gates before final delivery:

- PDF is exactly one page.
- No placeholder remains unless the user explicitly asked for a fill-in draft.
- No factual claim is unsupported by user-provided material.
- Work and project bullets use bold labels consistently.
- Dates, punctuation, and section language are consistent.
- Hyperlinks compile and display cleanly.

Run the skill package validator when editing the skill itself:

```bash
python .agents/skills/resume-writer/scripts/validate_resume_skill.py
```

## Bundled Resources

- `references/writing-guidelines.md`: detailed bullet-writing rules, consulting/finance style, quantification, ordering, and examples.
- `references/intake-checklist.md`: concise fact-gathering checklist for resume projects.
- `assets/template_cn.tex`: Chinese one-page LaTeX template.
- `assets/template_en.tex`: English one-page LaTeX template.
- `evals/evals.json`: smoke-test prompts for future skill evaluation.
- `scripts/validate_resume_skill.py`: static checks for metadata, references, templates, and eval files.

## Final Response Pattern

When you create or edit resume files, summarize:

- Files created or changed.
- Whether compilation succeeded and whether the PDF is one page.
- Any missing facts left as placeholders.
- The strongest improvements made to positioning or bullets.

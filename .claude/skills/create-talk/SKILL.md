---
name: create-talk
description: Generate Beamer presentation slides derived from the paper. Supports four formats — job market (45-60 min), seminar (30-45 min), short (15 min), and lightning (5 min). Use when asked to "create a talk", "make slides", "prepare a presentation", or "job market talk".
disable-model-invocation: true
argument-hint: "[format: job-market | seminar | short | lightning] [paper path (optional)]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Task", "Bash"]
---

# Create Talk

Generate a Beamer presentation derived from the paper, tailored to the specified format.

**Input:** `$ARGUMENTS` — format name, optionally followed by paper path.

---

## Step 0: Parse Arguments

- **Format** (required): `job-market` | `seminar` | `short` | `lightning`
- **Paper path** (optional): defaults to `Paper/main.tex`

If no format specified, ask the user.

### Format Constraints

| Format | Slides | Duration | Content Scope |
|--------|--------|----------|---------------|
| Job market | 40-50 | 45-60 min | Full story, all results, mechanism, robustness |
| Seminar | 25-35 | 30-45 min | Motivation, main result, 2 robustness, conclusion |
| Short | 10-15 | 15 min | Question, method, key result, implication |
| Lightning | 3-5 | 5 min | Hook, one result, so-what |

---

## Step 1: Read the Paper

Extract from `Paper/main.tex` (or specified path):
1. **Research question** — the one-sentence version
2. **Identification strategy** — what design, what variation
3. **Main result** — effect size with confidence interval
4. **Secondary results** — heterogeneity, mechanisms
5. **Robustness checks** — which ones strengthen the case most
6. **Key figures and tables** — which ones tell the story best
7. **Institutional background** — what audience needs to know

---

## Step 2: Select Content by Format

### Job Market Talk (40-50 slides)
```
1. Title slide
2-3. Motivation (fact, puzzle, why it matters)
4. Research question (one slide, one sentence)
5. Preview of results
6-8. Institutional background / context
9-10. Data description + summary stats
11-13. Identification strategy (with equation)
14. Identification validation (parallel trends / first stage / McCrary)
15-20. Main results (Table 2, with interpretation)
21-25. Heterogeneity / mechanisms
26-30. Robustness checks (best 3-4)
31-33. Alternative specifications
34-35. Discussion / policy implications
36-37. Conclusion
38-40. Backup slides (additional robustness, data details, proofs)
```

### Seminar Talk (25-35 slides)
```
1. Title slide
2-3. Motivation
4. Research question
5. Preview of results
6-7. Background (compressed)
8. Data overview
9-10. Identification strategy
11. Validation
12-16. Main results
17-19. Key robustness (best 2)
20-22. One mechanism or heterogeneity
23-24. Conclusion
25+. Backup slides
```

### Short Talk (10-15 slides)
```
1. Title slide
2. Motivation (one compelling fact)
3. Research question + what we do
4. Data (one slide)
5-6. Identification strategy
7-9. Main result (key table or figure)
10. Robustness (one slide summary)
11. Conclusion + so-what
12+. Backup
```

### Lightning Talk (3-5 slides)
```
1. Title + question + one-line answer
2. How we identify the effect (one sentence + key figure)
3. Main result (one number, one figure)
4. So-what (implication, next steps)
5. Thank you + contact info
```

---

## Step 3: Generate Beamer .tex

Use the shared preamble if `Talks/preamble_talk.tex` exists, otherwise create a minimal one.

### Slide Principles

- **One idea per slide.** Never two distinct points on one slide.
- **Figures > tables** when possible. Tables in backup.
- **Equations displayed large.** Font size >= 14pt for projected math.
- **Use `\textbf{}` and color** for key numbers in results.
- **Build tension.** Motivation → question → what we do → what we find → why it matters.
- **Transition slides** between major sections (one word/phrase, centered).

### Table/Figure References

- Reference figures/tables from `Figures/` and `Tables/` directories
- Use `\includegraphics` for figures, `\input` for tables
- Verify referenced files exist before including them
- If a file doesn't exist yet, add a TODO comment: `% TODO: generate Figure X`

---

## Step 4: Compile

Run `/compile-latex` on the generated talk file:
```bash
cd Talks && TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode [talk_file].tex
```

Fix any compilation errors before presenting.

---

## Step 5: Score (Auxiliary)

Run a lightweight quality check (NOT the full `/paper-excellence`):
- [ ] Slide count within format range
- [ ] All results appear in the paper (no talk-only results)
- [ ] Notation matches paper
- [ ] Figures/tables reference existing files
- [ ] No compilation errors

Report score as auxiliary: "Talk (seminar): 85/100 — advisory, non-blocking"

---

## Output

Save to `Talks/[format]_talk.tex` (e.g., `Talks/seminar_talk.tex`).

Present:
1. The generated `.tex` file path
2. Slide count and format compliance
3. Any TODO items (missing figures, tables not yet generated)
4. Auxiliary quality score

---

## Principles

- **Paper is authoritative.** Every claim in the talk must appear in the paper.
- **Less is more.** Especially for short and lightning formats — ruthlessly cut.
- **Audience calibration.** Job market = show breadth and rigor. Seminar = show the interesting result. Lightning = sell the idea.
- **Backup slides matter.** Prepare 5-10 backup slides for job market talks (referees will ask questions).
- **Don't read from slides.** Slides support the speaker, they don't replace them. Minimal text, maximal visual.

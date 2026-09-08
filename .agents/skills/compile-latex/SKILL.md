---
name: compile-latex
description: "Compile a Beamer LaTeX slide deck with XeLaTeX (3 passes, plus BibTeX when citations are present). Use when user says \"compile\", \"build the slides\", \"rebuild the PDF\", \"run latex\", \"render the tex\", or asks why a `.tex` file isn't producing a PDF. Operates on `Slides/*.tex`."
---



# Compile Beamer LaTeX Slides

Compile a Beamer slide deck using XeLaTeX with full citation resolution.

## Steps

1. **Navigate to Slides/ directory** and compile with three XeLaTeX passes.
   Run BibTeX after the first pass only when the generated `.aux` contains a
   `\\citation` command (including one produced by `\\nocite`):

```bash
cd Slides
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode the arguments supplied with the invocation.tex
if grep -q '\\citation' the arguments supplied with the invocation.aux; then
  BIBINPUTS=..:$BIBINPUTS bibtex the arguments supplied with the invocation
fi
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode the arguments supplied with the invocation.tex
TEXINPUTS=../Preambles:$TEXINPUTS xelatex -interaction=nonstopmode the arguments supplied with the invocation.tex
```

**Alternative (latexmk):**
```bash
cd Slides
TEXINPUTS=../Preambles:$TEXINPUTS BIBINPUTS=..:$BIBINPUTS latexmk -xelatex -interaction=nonstopmode the arguments supplied with the invocation.tex
```

2. **Check for warnings:**
   - Grep output for `Overfull \\hbox` warnings
   - Grep for `undefined citations` or `Label(s) may have changed`
   - Report any issues found

3. **Open the PDF** for visual verification:
   ```bash
   open Slides/the arguments supplied with the invocation.pdf          # macOS
   # xdg-open Slides/the arguments supplied with the invocation.pdf    # Linux
   ```

4. **Report results:**
   - Compilation success/failure
   - Number of overfull hbox warnings
   - Any undefined citations
   - PDF page count

## Why 3 passes?
1. First xelatex: Creates `.aux` file with citation keys
2. BibTeX, when citations are present: reads `.aux` and generates `.bbl`
3. Second xelatex: Incorporates bibliography
4. Third xelatex: Resolves all cross-references with final page numbers

## Important
- **Always use XeLaTeX**, never pdflatex
- **TEXINPUTS** is required: your Beamer theme lives in `Preambles/`
- **BIBINPUTS** is required: your `.bib` file lives in the repo root

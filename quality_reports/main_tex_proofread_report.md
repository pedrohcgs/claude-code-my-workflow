# Proofreading Report — `Paper/main.tex`

**Manuscript:** Estimation of the Marginal Cost of Health Produced by the Dominican Republic Healthcare System  
**Date:** 2026-04-27  
**Reviewer:** Claude Code (proofreader agent)  
**Status:** REPORT ONLY — no source files modified

---

## Summary

| Severity | Count |
|---|---|
| Critical | 4 |
| High | 6 |
| Major | 25 |
| Minor | 9 |
| **Total** | **44** |

**Critical issues must be fixed before any further compilation or submission.**

---

## Critical Issues

### C1 — Duplicate `\usepackage{biblatex}` and `\addbibresource`
- **Lines:** 58–67 (first) and 117–126 (second)
- **Fix:** Remove the duplicate block at lines 117–126 entirely.
- **Why critical:** Loading biblatex twice produces a fatal package clash.

### C2 — AI dialogue artifact in body text
- **Line:** ~364 (subsubsection "Disability-Adjusted Life Years")
- **Current:** `I see what you mean. It seems like the formatting got mixed up. Here's the corrected translation with LaTeX code included but not rendered:`
- **Fix:** Delete this sentence entirely.
- **Why critical:** This text will appear verbatim in the PDF.

### C3 — Markdown horizontal rule in body text
- **Line:** ~366
- **Current:** `---`
- **Fix:** Delete this line (companion artifact to C2).

### C4 — `\matbb{E}` undefined command
- **Line:** ~633 (Appendix A.1)
- **Current:** `$$\Sigma=\matbb{E}[(T-\theta \mathbbm{1})(T-\theta \mathbbm{1})']$$`
- **Fix:** `$$\Sigma=\mathbb{E}[(T-\theta \mathbbm{1})(T-\theta \mathbbm{1})']$$`
- **Why critical:** `\matbb` is undefined; this line will fail to compile.

---

## High Issues

### H1 — "Palabras claves" — untranslated heading in abstract
- **Line:** ~143
- **Current:** `\noindent\textbf{Palabras claves:} TBD \\`
- **Fix:** `\noindent\textbf{Keywords:} TBD \\`

### H2 — Spanish table note (QALY comparison table)
- **Line:** ~356
- **Current:** `\item \textbf{Nota:} Comparación entre los Años de vida perdidos \textit{vs}. Años de vida perdidos ajustados por calidad de vida para cada categoría CIE-10.`
- **Fix:** `\item \textbf{Note:} Comparison between years of life lost \textit{vs.} years of life lost adjusted for quality of life, by ICD-10 disease category.`

### H3 — Spanish figure caption and note
- **Lines:** ~440, ~444
- **Current caption:** `\caption{\label{fig: DistEMuj} Red de vecinos geográficos }`
- **Current note:** `\item \scriptsize{\textbf{Nota:} Red de municipios que comparten frontera geográfica. }`
- **Fix caption:** `\caption{\label{fig: DistEMuj} Network of geographic neighbors}`
- **Fix note:** `\item \scriptsize{\textbf{Note:} Network of municipalities sharing a geographic border.}`

### H4 — Spanish table caption (burden ratios table)
- **Line:** ~382
- **Current:** `\caption{\label{Tab: Ratios} Ratios de carga por tipo de enfermedad, 2016-2019}`
- **Fix:** `\caption{\label{Tab: Ratios} Disease burden ratios by disease type, 2016--2019}`

### H5 — "proyect" misspelling (acknowledgements footnote)
- **Line:** ~132
- **Current:** `which participated in early stages of this proyect`
- **Fix:** `who participated in early stages of this project`

### H6 — "grateful with … which" (acknowledgements footnote)
- **Line:** ~132
- **Current:** `We are grateful with Douglas Newball and Cristhian Acosta which participated in early stages of this proyect.`
- **Fix:** `We are grateful to Douglas Newball and Cristhian Acosta, who participated in early stages of this project.`

### H7 — `\graphicspath{{FIGURES/}}` wrong case
- **Line:** ~32
- **Current:** `\graphicspath{{FIGURES/}}`
- **Fix:** `\graphicspath{{Figures/}}`
- **Note:** Will fail on Linux/Mac servers (case-sensitive filesystems).

---

## Major Issues

### M1 — `\babel[spanish]` in English-only paper
- **Line:** ~25
- **Current:** `\usepackage[spanish,es-tabla]{babel}`
- **Fix:** `\usepackage[english]{babel}`
- **Note:** Spanish babel sets automatic hyphenation to Spanish and causes "Tabla" labels.

### M2 — `\renewcommand{\tablename}{Tabla}` — Spanish table label
- **Line:** ~30
- **Current:** `\renewcommand{\tablename}{Tabla}`
- **Fix:** Delete this line entirely (English babel restores "Table" automatically).

### M3 — "database … include" (subject-verb agreement)
- **Line:** ~203
- **Current:** `This database contains 340,198 recorded deaths … and include the total number`
- **Fix:** `… and includes the total number`

### M4 — "To being able to categorize" (wrong infinitive)
- **Line:** ~217
- **Current:** `To being able to categorize different diseases systematically, we use The International Classification`
- **Fix:** `To categorize different diseases systematically, we use the International Classification`

### M5 — "esttimation" + "than" (two typos in one sentence)
- **Line:** ~193
- **Current:** `a key determinant of the type of esttimation than can be done.`
- **Fix:** `a key determinant of the type of estimation that can be done.`

### M6 — "this paper to provides" (broken infinitive)
- **Line:** ~193
- **Current:** `the study by \citet{Martin2021} conducts a similar evaluation … compared to the one this paper to provides.`
- **Fix:** `the study by \citet{Martin2021} conducts a similar evaluation … comparable to the one this paper provides.`

### M7 — "To do these" → "To do this"
- **Line:** ~230
- **Current:** `To do these, we will go through four intermediate steps:`
- **Fix:** `To do this, we will go through four intermediate steps:`

### M8 — "were" → "where" (twice in same paragraph)
- **Line:** ~280
- **Current (×2):** `diseases were the correction yields very different results … were the life expectancy is much higher`
- **Fix:** `diseases where the correction yields…` and `where the life expectancy is much higher`

### M9 — "qulity" (misspelling in subsection heading)
- **Line:** ~316
- **Current:** `\subsubsection{Years of life lost adjusted by qulity of life}`
- **Fix:** `\subsubsection{Years of life lost adjusted by quality of life}`

### M10 — "socres" (misspelling in figure note)
- **Line:** ~334
- **Current:** `The right panel shows the adjusted socres so that they reflect`
- **Fix:** `The right panel shows the adjusted scores so that they reflect`

### M11 — Spanish "y" connector + "CIE" → "and" / "ICD"
- **Line:** ~310
- **Current:** `$\text{YLL}$,$\text{YLG}$ y $\text{YLL}_{\text{net}}$ per CIE disease category`
- **Fix:** `$\text{YLL}$, $\text{YLG}$, and $\text{YLL}_{\text{net}}$ per ICD disease category`

### M12 — "YYL" → "YLL" (transposed letters)
- **Line:** ~310
- **Current:** `The table shows average $\text{YYL}$ per death`
- **Fix:** `The table shows average $\text{YLL}$ per death`

### M13 — Markdown `**bold**` syntax (three instances)
- **Lines:** ~368, ~376, ~465
- **Fix:** Replace `**text**` with `\textbf{text}` or `\emph{text}` as appropriate.

### M14 — Markdown `*italic*` syntax
- **Line:** ~414
- **Current:** `is interpreted as *the number of years of perfect health lost…*`
- **Fix:** `is interpreted as \emph{the number of years of perfect health lost…}`

### M15 — Malformed set definition (orphaned `\Big`)
- **Line:** ~620
- **Current:** `$$\Lambda=\Big \{ \lambda :  \Big \in \mathbb{R}^n: \sum \limits_{i=1}^n \lambda_i=1 \Big \}$$`
- **Fix:** `$$\Lambda=\Big\{ \lambda \in \mathbb{R}^n: \sum_{i=1}^n \lambda_i=1 \Big\}$$`

### M16 — "data of" → "data on" + missing Oxford comma
- **Line:** ~157
- **Current:** `which uses data of life expectancy, mortality and morbidity of the Dominican Republic`
- **Fix:** `which uses data on life expectancy, mortality, and morbidity in the Dominican Republic`

### M17 — "Cost-Effectiveness Threshold" capitalisation inconsistent
- **Lines:** 155, 157, 162, 165 and throughout
- **Fix:** Standardise to lower-case "cost-effectiveness threshold" in running text; title case only at first definition with acronym.

### M18 — "healthcare" vs "health care" — inconsistent compound
- **Lines:** 131, 155, 157, 162, 229, 465
- **Fix:** Choose one form throughout. Recommend "health care" (two words) as noun, "healthcare" as attributive adjective.

### M19 — Research question repeated verbatim (structural flaw)
- **Lines:** 157 and 162
- **Fix:** Remove the version at line 157 or fold it into the surrounding text.

### M20 — "condidional" misspelling + "conditional to" → "conditional on"
- **Line:** ~253 (footnote)
- **Current:** `Life Tables condidional to every disease`
- **Fix:** `life tables conditional on every disease`

### M21 — "This is equivalent to … (G) and …" — incoherent sentence
- **Line:** ~475
- **Current:** `This is equivalent to the average health expenditure (G) and the average health proportion that changes with changes in expenditure`
- **Fix:** `This equals the ratio of average health expenditure (G) to the average change in the health burden per unit change in expenditure`

### M22 — "UCE" used without English definition
- **Line:** ~418
- **Current:** `A key step in calculating the UCE is to relate how effective health spending is`
- **Fix:** `A key step in calculating the CET is to relate how effective health spending is`

### M23 — `\citep` → `\parencite` (natbib vs biblatex style)
- **Lines:** ~320, ~426
- **Fix:** Replace `\citep{}` with `\parencite{}` throughout.

---

## Minor Issues

### m1 — "amongst" → "among"
- **Line:** ~203
- **Fix:** Standard academic English prefers "among."

### m2 — Subsection heading "CIE-10" → "ICD-10"
- **Line:** ~216
- **Fix:** The heading uses the Spanish acronym; body uses English "ICD-10."

### m3 — "(2008) \citet{OPS2008}" — year duplicated
- **Line:** ~217
- **Fix:** `\parencite{OPS2008}` — the year is already in the citation.

### m4 — "Economic Evaluation" — unjustified title case
- **Line:** ~155
- **Fix:** `Economic evaluation` (lower case in running text).

### m5 — "passes this information on to" → "submits … to"
- **Line:** ~210
- **Fix:** More formal academic phrasing.

### m6 — "informative of its age" → "informative of their age"
- **Line:** ~280
- **Fix:** "its" refers to a person; use "their."

### m7 — Missing "Table~" before cross-references
- **Line:** ~214
- **Current:** `shown in \ref{Tab: TNV1} and table \ref{Tab: TNV2}`
- **Fix:** `shown in Table~\ref{Tab: TNV1} and Table~\ref{Tab: TNV2}`

### m8 — Missing space before opening quotation marks in table notes
- **Lines:** ~585, ~601
- **Current:** `Column``Expected additional life…`
- **Fix:** `Column ``Expected additional life…`

### m9 — WHO threshold heuristic stated without citation
- **Line:** ~160 (footnote)
- **Fix:** Add `\parencite` to the WHO recommendation statement.

---

## What was NOT flagged
- Technical acronyms: AVAD, AVAC, TAVPE, SISALRIL, ONE, Plan Básico de Salud — intentional
- Spanish proper nouns and institution names — intentional
- LaTeX math expressions — intentional
- Bilingual content in table headers (these are generated by `.tex` table files, not by `main.tex`)

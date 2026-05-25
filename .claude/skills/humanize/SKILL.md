---
name: humanize
description: Read-only audit of `.tex`, `.qmd`, or `.md` text for AI-voice tells — boilerplate transitions ("Moreover", "Furthermore", "It is important to note that"), AI-cliché lexicon ("delve", "navigate the complexities", "tapestry", "robust framework"), em-dash overuse, symmetric paragraph shapes, tricolon abuse, hedging stacking, "not only X but also Y" frames, and formulaic openers. Produces a report; does NOT rewrite. Use when user says "humanize", "does this sound like AI?", "check for AI tells", "de-AI this draft", "remove AI voice", "audit my prose for sycophancy", or before journal submission / posting a working paper.
author: Claude Code Academic Workflow
version: 1.0.0
argument-hint: "[filename or 'all'] [--severity low|med|high]"
disable-model-invocation: true
allowed-tools: ["Read", "Grep", "Glob", "Write", "Task"]
---

# `/humanize` — AI-voice audit (detect-and-flag)

Read the target file (or all paper-like files), audit for the canonical AI-voice tells in academic prose, and write a structured report. **The skill does not rewrite.** The author edits.

## Why this skill exists

Referees and editors increasingly recognise AI-generated prose. The tells are not stylistic preferences — they're statistically conspicuous patterns the LLM training distribution produces at higher rates than human academic writers. Five reasons to audit before submission:

1. **Reviewer suspicion is a tax.** Even good substance pays a credibility tax if the prose reads as AI-drafted.
2. **Journal policy is tightening.** A growing number of venues require disclosure or prohibit AI-drafted text.
3. **AI tells signal weak content.** Boilerplate transitions ("Moreover", "It is important to note") almost always cover up logical gaps the author didn't think through.
4. **You are not the tells.** Even authors who use AI tools heavily can preserve their own voice by stripping the model's lexical fingerprint.
5. **The fix is cheap once you can see it.** The cost is detection, not rewriting — once the report flags the tells, removal is mechanical.

## What this skill is NOT

- **Not a rewriter.** No `--rewrite` mode. Auto-rewriting AI tells degrades prose quality (cross-vendor research finding); the author preserves voice by editing manually.
- **Not a substance reviewer.** Use `/review-paper` for argument structure, identification, citations.
- **Not a grammar checker.** Use `/proofread` for grammar, typos, overflow, citation format.
- **Not a fact-checker.** Use `/verify-claims` for Chain-of-Verification fact-checking of citations and numeric claims.

`/humanize` is the *voice* lens. Run it alongside the others — none of them substitute.

## When to use

- Before journal submission.
- Before posting a working paper / preprint / SSRN draft.
- After any AI-assisted prose generation (R&R response drafts, lit-review synthesis, abstract revisions).
- As a self-discipline pass after long writing sessions — your own writing drifts toward LLM patterns when you stare at LLM output all day.

## When NOT to use

- On `.bib`, `.R`, or other non-prose files — the detectors are tuned for academic prose.
- On code comments — the tells are different.
- On UI/UX copy — voice norms diverge.

## Detection categories

The humanize-auditor agent checks these category groups:

### 1. BOILERPLATE TRANSITIONS

High-confidence AI tells when they appear sentence-initial or mid-paragraph as connective tissue:

- `Moreover,` / `Furthermore,` / `Additionally,` / `In addition,`
- `It is important to note that` / `It is worth noting that` / `Notably,`
- `In conclusion,` / `In summary,` / `To summarise,`
- `On the other hand,` (when not contrasting two named things)
- `Building on this,` / `Building upon this,`
- `As we can see,` / `As is evident,` / `Indeed,` (stacked)

**Severity:** HIGH if more than 1 per 1000 words. MED if 1 per 2000 words. LOW if rare but present.

### 2. AI-CLICHÉ LEXICON

Words and phrases statistically over-represented in LLM output relative to academic prose:

- "navigate the complexities", "navigate the landscape"
- "delve into", "delve deeper into"
- "tapestry of", "rich tapestry"
- "robust framework", "comprehensive framework", "holistic framework"
- "comprehensive approach" / "multifaceted approach" / "nuanced approach" (especially when stacked)
- "leverage" (as a verb in non-finance / non-engineering contexts)
- "in today's [X] landscape" / "in today's rapidly evolving"
- "play a crucial role" / "play a pivotal role" / "play a significant role"
- "shed light on"
- "underscore the importance" / "highlight the importance"
- "It is essential to" / "It is crucial to"

**Severity:** HIGH on a paper's first three pages (abstract, intro). MED elsewhere.

### 3. EM-DASH AND PUNCTUATION OVERUSE

- Em-dash overuse — more than 3 em-dashes per paragraph is a tell.
- Semicolon stacks — three or more semicolons in a single paragraph.
- Triple-Oxford-comma constructions — lists of three with deliberate parallelism repeated paragraph-to-paragraph.

**Severity:** MED. Em-dashes are a legitimate authorial choice; flag overuse, not all use.

### 4. SYMMETRIC PARAGRAPH SHAPES

Paragraphs with the same micro-architecture: topic sentence → three examples → summarising clause. Repeated across consecutive paragraphs is the AI tell — not the shape itself.

**Detection:** flag any three-paragraph window where each paragraph fits the topic→examples→summary cadence.

**Severity:** MED if 3-paragraph window; HIGH if 5+ paragraph stretch.

### 5. TRICOLON ABUSE

"X, Y, and Z" three-element lists are a legitimate rhetorical device. Tells are:

- More than 4 tricolons per page.
- Tricolons used for items that could naturally be 2 or 4.
- Adjective tricolons stacked ("clear, concise, and compelling"; "rigorous, robust, and reliable").

**Severity:** LOW if rare; MED if patterned.

### 6. HEDGING STACKING

Stacked epistemic hedges in single sentences:

- "might potentially be argued"
- "could possibly suggest"
- "may arguably"
- "perhaps potentially"

**Severity:** HIGH — these are almost never authorial choices; they're LLM uncertainty-management.

### 7. "NOT ONLY X, BUT ALSO Y" FRAMES

Used sparingly, this is a legitimate construction. AI tells:

- More than 2 per paper.
- Used when X and Y are not actually parallel.
- Used as paragraph openers.

**Severity:** MED.

### 8. FORMULAIC OPENERS

- Section openers of the form "This [paper / chapter / section / analysis] [does X]."
- Paragraph openers that re-state the section title.
- Abstract opening with "In this paper, we..." (legitimate in some sub-fields; flag for review where it's atypical, e.g., AER abstracts rarely use it).

**Severity:** LOW unless every section starts this way.

### 9. HYPHENATION EXCESS

Long chains of compound modifiers as a paragraph signature:

- "data-driven", "evidence-based", "well-suited", "well-established", "long-standing" — fine individually; flag if three or more appear in a single paragraph.

**Severity:** LOW.

### 10. SYCOPHANCY / SELF-IMPORTANT FRAMING

- "This important contribution"
- "This significant finding"
- "Our novel approach"
- Self-citation as "groundbreaking" / "pioneering"

**Severity:** HIGH — these read as AI-generated promotional copy; referees will react badly.

## Steps

1. **Identify files to audit:**
   - If `$ARGUMENTS` starts with a filename: audit that file only.
   - If `$ARGUMENTS` is `all`: audit all `.qmd`, `.tex`, `.md` files in `Slides/`, `Quarto/`, root, and `master_supporting_docs/`.
   - Skip `.bib`, `.R`, `.py`, code files, and any file under `scripts/`.

2. **Parse `--severity` flag** (default: report all).
   - `--severity low` → report all findings.
   - `--severity med` → suppress LOW findings.
   - `--severity high` → report only HIGH findings.

3. **For each file, launch the `humanize-auditor` agent** with the 10 detection categories.

4. **Receive structured report** from the agent. Format per finding:

   ```
   line N | category | severity | current text | suggested rewrite or "remove"
   ```

5. **Write report** to `quality_reports/humanize_<filename>_report.md`. Include:
   - Per-category counts (HIGH / MED / LOW)
   - Per-finding table
   - Summary recommendation (rough thresholds):
     - **> 8 HIGH findings per 1000 words**: prose reads as AI-drafted. Author should rewrite the affected sections, not patch.
     - **5–8 HIGH per 1000 words**: substantial AI voice. Strip the tells before submission.
     - **< 5 HIGH per 1000 words**: light cleanup; mostly cosmetic.

6. **Present summary** to user:
   - Total findings per category
   - Most concentrated paragraphs (top 3)
   - Action recommendation (rewrite vs. strip vs. cosmetic)

## Pairings

| When you've drafted prose with AI assistance | Run `/humanize` before submission. Pair with `/proofread` (grammar) and `/verify-claims` (citations). |
| When you wrote in your own voice | Run `/humanize` anyway — your own prose drifts toward LLM patterns after long sessions of AI-assisted work. |
| Submission-ready review | `/review-paper --peer [journal] --variance 3` for substance, `/humanize` for voice, `/verify-claims` for facts. |

## Anti-pattern: no `--rewrite` mode

We deliberately do not ship `/humanize --rewrite`. Cross-vendor research (Cursor / Aider community findings; cited in the v1.9.0 plan) finds that auto-rewriting prose to strip AI tells degrades quality more often than it improves it — the rewriter introduces its *own* AI tells. The detect-and-flag pattern preserves authorial voice; the cost is your editing time, which is exactly the cost we want to pay.

If you find yourself reaching for an auto-rewriter, that's the signal to rewrite the paragraph from scratch — not to patch the tells one by one.

## Output

- Report at `quality_reports/humanize_<filename>_report.md` (gitignored).
- Summary to the conversation: counts per category, top concentrated paragraphs, action recommendation.
- **No file edits.** The user reads the report and applies changes manually.

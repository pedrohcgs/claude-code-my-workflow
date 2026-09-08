---
paths:
  - "master_supporting_docs/**"
---

# Robust PDF Processing

**Default: read the PDF directly.** The Read tool reads PDFs natively — pass a `pages` range (e.g. `pages: "1-20"`) for papers longer than ~10 pages, up to 20 pages per request — and a 1M-token context window comfortably holds a full paper. You do **not** need to pre-split a normal paper into chunk files.

## The Workflow

**Step 1: Check size first**
```bash
pdfinfo paper_name.pdf | grep "Pages:"
ls -lh paper_name.pdf
```

**Step 2: Read it directly**
- **Normal papers (up to ~100 pages):** read with the Read tool, using the `pages` parameter to page through (up to 20 pages per request). No pre-splitting needed.
- **Selective deep reading (a cost optimization, not a capacity limit):** for a long paper you may scan section by section and read the load-bearing parts (identification, methods, results) in detail while skimming appendices/references — this saves tokens, not because the model cannot hold the document.

**Step 3 (fallback): split only when a direct read fails.** Reach for Ghostscript page-range splitting ONLY when the PDF is genuinely oversized (a book or high-resolution scan, hundreds of pages), corrupt, or a direct Read errors:
```bash
mkdir -p paper_name/
for i in {0..9}; do
  start=$((i*5 + 1)); end=$(((i+1)*5))
  gs -sDEVICE=pdfwrite -dNOPAUSE -dBATCH -dSAFER \
     -dFirstPage=$start -dLastPage=$end \
     -sOutputFile="paper_name/paper_name_p$(printf '%03d' $start)-$(printf '%03d' $end).pdf" \
     paper_name.pdf 2>/dev/null
done
```
Then read the page-range files one at a time, building understanding progressively.

## Error Handling Protocol

**If a direct read fails** (corrupt or oversized): fall back to Step 3 page-range splitting.

**If a chunk fails to process:**
1. Note the problematic chunk (e.g., "Chunk p021-025 failed")
2. Try splitting into 1-2 page pieces
3. If still failing, skip and document the gap

**If splitting fails:**
1. Check if Ghostscript is installed: `gs --version`
2. Try alternative: `pdftk paper.pdf burst output paper_%03d.pdf`
3. If all else fails, ask the user to upload specific page ranges manually

## Many documents is a different problem from one document

The guidance above is for **one** paper: read it directly, page through it, the context window
holds it comfortably.

**It does not scale by multiplication.** Loading ~10 large PDFs at once has repeatedly produced
`Prompt is too long` and forced a session reset — after partial work was already done and lost.

For any task spanning **more than two or three documents** — style profiling across a corpus,
triaging reviewer findings across a bundle, a literature sweep — use the **one-subagent-per-
document** pattern:

1. Spawn **one subagent per document**, each with `context: fork`.
2. Each agent reads **only its own file** and writes a short structured note to disk
   (`notes/<name>.md`) — 300 words, a fixed schema.
3. Each returns **only the filename**, not the content.
4. The main session then reads **only the notes** and synthesizes.

The main context never holds more than one document's worth of material, and a failure costs
one agent rather than the session.

> **Check the count before starting.** If the task names more documents than you can read in
> two or three requests, the answer is subagents — decided up front, not after the first
> overflow. And confirm the corpus size against disk: a task that says "my papers" and turns
> out to be eleven of them is a different task from four.

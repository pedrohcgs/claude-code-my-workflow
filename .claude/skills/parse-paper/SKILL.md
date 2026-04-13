---
name: parse-paper
description: Extract structured content from academic PDFs using LiteParse. Preprocesses papers for lit-review, review-paper, oracle, or manual reading.
argument-hint: "[path to PDF file or directory]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Glob
---

# Parse Paper -- PDF Preprocessing with LiteParse

Extract text and screenshots from academic PDFs for use as AI context. Local-only processing -- no data leaves your machine.

## Prerequisites

- LiteParse installed: `npm i -g @llamaindex/liteparse` or `brew install llamaindex-liteparse`
- CLI command: `lit`

## Usage

```
/parse-paper path/to/paper.pdf
/parse-paper path/to/papers/          # batch mode
```

## Workflow

### Single Paper

1. **Extract text** (for prose, references, methodology sections):
   ```bash
   lit parse "$ARGUMENTS" -o /tmp/parsed_paper.txt
   ```

2. **Extract specific pages** (for targeted sections):
   ```bash
   lit parse "$ARGUMENTS" --target-pages "1-5,10-15" -o /tmp/parsed_sections.txt
   ```

3. **Generate screenshots** (for tables, figures, equations that text extraction mangles):
   ```bash
   lit screenshot "$ARGUMENTS" --target-pages "1" --dpi 300 -o /tmp/paper_screenshots/
   ```

4. **Report** what was extracted (page count, key sections found, any issues)

### Batch Mode (Directory of Papers)

```bash
lit batch-parse "$ARGUMENTS" /tmp/parsed_papers/ --recursive --extension .pdf
```

### Integration with Other Skills

- **Before `/lit-review`:** Parse papers first, then feed extracted text
- **Before `/oracle`:** Parse papers, then include as `--file` arguments to Oracle
- **Before `/review-paper`:** Parse PDF to text so review-paper can read content directly

## Output

- Text files go to `/tmp/` (exploratory, not committed)
- If the user wants to save parsed content, move to `master_supporting_docs/parsed/`

## What Works Well

- Modern digital PDFs (post-2000): excellent text extraction
- Prose, references, abstracts: clean output
- Page targeting: only parse what you need

## Limitations

- **Equations:** LaTeX math comes out as character sequences, not structured notation. Use screenshots instead.
- **Complex tables:** Multi-column alignment may be lost. Use screenshots for precise table capture.
- **Scanned papers (pre-2000):** Built-in OCR (Tesseract) is adequate but not state-of-the-art. Consider `--ocr easyocr` for better quality.
- **Not Python:** This is a Node.js tool. Requires npm/Node.js.

## Troubleshooting

- **`lit` not found:** Install with `npm i -g @llamaindex/liteparse`
- **Poor OCR quality:** Try `lit parse paper.pdf --ocr easyocr` (requires EasyOCR server)
- **Large PDF timeout:** Use `--target-pages` to parse only needed sections
- **Office docs (.docx, .pptx):** Requires LibreOffice installed for conversion

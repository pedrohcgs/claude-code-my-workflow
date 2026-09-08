---
paths: ["Slides/**/*.tex", "Slides/**/*.qmd", "manuscript*.tex", "**/*.md"]
---
# Proofreading protocol

Review every manuscript and research-presentation change before commit or PR.

1. Run the academic proofreader for language, citation formatting, and notation.
2. For presentations, also run the slide auditor for overflow, density, hierarchy, figures, and readability.
3. Apply fixes through the parent agent, then re-run reviewers on changed regions.
4. Store requested reports in `quality_reports/` with an artifact-based name.

Separate definite errors from optional style and preserve technical meaning and documented voice.

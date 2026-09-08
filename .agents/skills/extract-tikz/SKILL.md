---
name: extract-tikz
description: Extract TikZ pictures from Beamer LaTeX, compile each as a standalone PDF, and optionally convert them to SVG or PNG assets. Use when regenerating diagrams from a research presentation.
---

# Extract TikZ diagrams

Locate `tikzpicture` environments in the selected Beamer source and preserve required libraries, styles, colors, and macros from its preamble. Number extracted diagrams from zero in source order and give each a stable filename.

Create standalone LaTeX wrappers in the project's existing generated-asset location, compile with the repository's LaTeX engine, and inspect the log for errors or overflow. Convert only to formats the user requests, using deterministic command options. Verify that the number and order of outputs match the source environments and visually inspect representative or changed diagrams.

Never edit the source deck merely to make extraction easier. Report source locations, generated paths, tool versions, and any macro that could not be resolved.


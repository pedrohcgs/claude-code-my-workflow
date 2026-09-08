---
paths: ["Slides/**/*.tex", "Slides/**/*.qmd", "Figures/**", "scripts/**", "manuscript*.tex"]
---
# Verification protocol

At the end of a change, run the narrowest real check that proves the output works.

For TeX/Beamer/TikZ: compile with documented engine and paths; check exit status, undefined citations/references, overfull boxes, and output; confirm diagrams are current and paths resolve; visually inspect when layout matters.

For Quarto RevealJS research talks: run `quarto render` from the documented
directory; check exit status, citations, references, and local assets; open the
HTML at 1600x900 and inspect every slide capture for overflow and legibility.
Missing browser capture means visual verification is NOT RUN, not PASS.

For R and other code: run targeted tests or scripts from the documented directory; verify outputs exist, are nonempty, and have expected structure; record seeds, environments, warnings, failures, and commands; reconcile changed outputs with all reported claims.

Report command, exit status, evidence, warnings, and PASS/FAIL per artifact. Missing dependencies mean NOT RUN, never PASS. Verification does not authorize publishing, deployment, commit, or push.

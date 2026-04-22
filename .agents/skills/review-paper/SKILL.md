---
name: review-paper
description: Comprehensive manuscript review with three modes: single-pass (default), `--adversarial` critic-fixer loop, and `--peer <journal>` simulated peer review (editor + 2 calibrated referees + editorial synthesis). Auto-invokes `/review-r`, `/review-python`, `/review-stata`, and `/audit-reproducibility` on referenced scripts unless `--no-cross-artifact`.
argument-hint: "[paper path] [--adversarial | --peer <journal> [--r2 | --r3 | --stress] [--no-novelty-check]] [--no-cross-artifact]"
allowed-tools: ["Read", "Grep", "Glob", "Write", "Edit", "Bash", "Task"]
---

# Manuscript Review

Produce a serious academic manuscript review. Choose the mode based on the
stage of the draft.

## Which mode to use

- `/review-paper` for one comprehensive report
- `/review-paper --adversarial` for an iterative critic-fixer loop
- `/review-paper --peer <journal>` for simulated editor + referee review
- `/seven-pass-review` for a heavier submission-ready pass
- `/respond-to-referees` when you already have referee comments

## Inputs

`$ARGUMENTS` should resolve to a manuscript path (`.tex`, `.qmd`, `.md`, or
`.pdf`) or a file under `master_supporting_docs/`.

Optional flags:

- `--adversarial`
- `--peer <JOURNAL>`
- `--r2` / `--r3`
- `--stress`
- `--no-novelty-check`
- `--no-cross-artifact`

## Core review dimensions

Always review:

1. Argument structure
2. Identification strategy
3. Econometric or methodological specification
4. Literature positioning
5. Writing quality
6. Presentation quality

## Default mode

1. Resolve and read the manuscript in full.
2. If the paper references analysis scripts and `--no-cross-artifact` is not set:
   - run `/review-r` on referenced `.R` scripts
   - run `/review-python` on referenced `.py` scripts
   - run `/review-stata` on referenced `.do` scripts
   - run `/audit-reproducibility` on the manuscript and the relevant outputs directory
3. Merge critical cross-artifact findings into the top of the paper review.
4. Produce a structured review with:
   - summary assessment
   - strengths
   - major concerns
   - minor concerns
   - referee objections
   - dimension ratings
5. Save to `quality_reports/paper_review_[sanitized_name]_round1.md`.

Cross-artifact protocol reference: `.claude/rules/cross-artifact-review.md`.

## Adversarial mode

Use a critic-fixer loop with a hard cap of 5 rounds.

1. Run the default review and save the round report.
2. If there are no major concerns and no fatal referee objections, stop with `APPROVED`.
3. Otherwise, propose concrete fixes grouped by severity.
4. Apply approved fixes.
5. Re-run a fresh-context subagent review on the revised manuscript.
6. Loop until approved, the user stops, or the round cap is reached.

For compile-target manuscripts, re-run the appropriate build after fixes.

## Peer-review mode

1. Pre-flight:
   - resolve manuscript path
   - resolve journal short name from `.claude/references/journal-profiles.md`
   - run `/audit-reproducibility` first unless `--no-cross-artifact`
2. Editor desk review:
   - spawn the `editor` subagent
   - calibrate to the target journal
   - decide desk reject versus send out
3. Referee stage:
   - spawn `domain-referee`
   - spawn `methods-referee`
4. Editorial synthesis:
   - read both referee reports
   - classify concerns
   - produce the final editorial decision

## Output structure

### Default or adversarial rounds

- summary assessment
- strengths
- major concerns
- minor concerns
- referee objections
- specific comments
- dimension ratings

### Peer mode

- `quality_reports/peer_review_[paper]/desk_review.md`
- `quality_reports/peer_review_[paper]/referee_domain.md`
- `quality_reports/peer_review_[paper]/referee_methods.md`
- `quality_reports/peer_review_[paper]/editorial_decision.md`

Cross-artifact outputs go under `quality_reports/cross_artifact_[paper]/`.

## Principles

- Be constructive and specific.
- Distinguish fatal flaws from smaller issues.
- Reference exact sections, tables, and equations when possible.
- Do not fabricate missing evidence.
- Keep editor and referee roles separate in peer mode.

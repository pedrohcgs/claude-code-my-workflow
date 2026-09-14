# scripts/python/classifier/

The LLM review-text classifier — scores review text (define the construct: e.g. experience valence)
so the *content* of reviews can be compared across solicited vs. organic regimes.

Build + validate:

- **Fixed taxonomy set in advance.** Define the label scheme and coding guidelines *before* looking at
  results; pre-register it (`/preregister`).
- **Labeled hold-out with human ground truth.** Report accuracy / F1 / agreement and the confusion matrix
  **on the hold-out, not the training data**. Report inter-rater agreement on the labels.
- **Version everything.** Model, model version, prompt id, temperature/seed, and elicitation date — logged
  with every run (models drift). Characterize within-model variance across repeated runs.
- **Prompt-sensitivity check.** Confirm outputs are stable across defensible prompt phrasings.
- Numbered scripts (`01_prompts.py`, `02_run.py`, `03_validate.py`, …); `pathlib` paths.

Review path: `/verify-claims` + `/audit-reproducibility` on the output tables (no `.py` scorer exists).

---
name: capture-environment
description: Capture the R and Python computational environment for a reproducible research project, including lockfiles or dependency manifests, session information, seeds, and a paste-ready requirements note.
---

# Capture the computational environment

Detect R and Python from real project files. Do not introduce a language the project does not use.

For R, record the R version, platform, `sessionInfo()`, package sources and versions, `renv.lock` status, and RNG kind/seeds. For Python, record the interpreter, platform, package manager, dependency or lockfile status, and relevant seeds. Prefer existing environment managers such as renv, uv, Poetry, or Conda over inventing a parallel system.

Write captures beside the project's declared reproducibility outputs or under `quality_reports/environment/`. Never overwrite a maintained lockfile without explicit approval. Verify that a clean restore command can be stated and that the recorded files parse. If requested, draft a minimal Dockerfile pinned to the captured versions, clearly separating generated pins from unresolved system dependencies.

Return a concise “Computational requirements” block with software versions, restore command, entry point, expected runtime, memory needs, and any external services or restricted-data requirements.


---
name: replication-package
description: Assemble a submission-ready research replication package for an R or Python project, with a README, data manifest, environment capture, artifact-to-code map, and restricted-data access plan.
---

# Build a replication package

Inventory the manuscript, R/Python analysis entry points, data inputs, generated outputs, licenses, and existing provenance records. Do not copy restricted or personally identifying data.

Create a package with `data/`, `code/`, `output/`, and a README that states:

- exact software and package versions;
- a one-command execution path and expected runtime;
- the order and purpose of scripts;
- every table or figure mapped to its generating file and stable locator;
- each dataset's source, license, access conditions, and inclusion status;
- seeds and stochastic steps;
- known platform or resource requirements.

For unavailable or restricted inputs, include a clear access procedure and, where permitted, synthetic or schema-only test data. Invoke `$capture-environment` for environment evidence and `$audit-reproducibility` before declaring the package ready. Run the package from a clean temporary copy when feasible and record the result. Leave visible `[FILL]` markers for information only the user can supply.


---
name: oracle-review
description: Prepare a self-contained packet for an independent external review and adjudicate the returned findings. Use only when explicitly invoked with $oracle-review and never silently substitute self-review for an unavailable external reviewer.
---

# Independent external review

Verify the artifact first with `$verify-artifact`. Create a review packet containing the exact artifact version, question, scope, acceptance criteria, relevant sources, and a request that the reviewer echo filenames and counts before reviewing.

Use an explicitly configured external reviewer or connector only when it is available and authorized. Do not assume a particular provider, model, CLI, or account. If none is available, stop after writing the packet and tell the user where it is; do not label an internal subagent as external or independent.

Treat every returned finding as a candidate. Apply `$adjudicate-review`: verify it against the actual source, classify it as confirmed, refuted, partial, or unresolved, and inspect any proposed fix for regressions. Preserve the raw review and the adjudication separately.


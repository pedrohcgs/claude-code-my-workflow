# Replication protocol

Reproduce source results before modifying an estimator, sample, figure, or specification. Record source, target statistic, expected value, tolerance, environment, seed, and exact command. Hide the expected value from any independent agent asked to re-derive it.

Use `abs(actual - expected) <= atol + rtol * abs(expected)`; choose tolerances from precision and substantive scale before seeing the result.

Maintain a machine-readable passport mapping each claim to its source/location/transformation, generating code and inputs, output artifact, every display, expected and actual values, tolerance, status, date, environment, access restrictions, and any concrete named `author_alternative`.

Statuses are PASS, FAIL, STALE, CANNOT-VERIFY, and EXPLAINED. EXPLAINED requires a defensible named edition, sample, specification, or rounding convention; it cannot excuse a fabricated source.

Vertical verification follows a claim from source/data through code and output into prose. Horizontal verification compares all displays. A changed source, generator, or output marks downstream claims STALE until both pass.

Save raw results and derived artifacts separately; record seeds, versions, failure counts, and commands; never leave a headline number only in console output; never silently drop missing or nonconverged cases. Restricted data may remain unavailable, but limits must be explicit.

`$audit-reproducibility` owns comparison. `$commit` stops on unresolved FAIL/STALE claims touched by the diff.

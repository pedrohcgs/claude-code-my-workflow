---
paths:
  - "scripts/**"
  - "data/**"
---

# Data Linkage Protocol: Form AP to Revelio

**Core principle:** Maximize match rate while maintaining high confidence in each link.

---

## Phase 1: Data Preparation

Before any matching:

- [ ] Standardize partner names (lowercase, remove suffixes like Jr/Sr/III, handle unicode)
- [ ] Standardize firm names (canonical audit firm names, handle mergers/name changes)
- [ ] Parse and normalize locations (city, state, country)
- [ ] Deduplicate within each source dataset
- [ ] Document variable definitions and any cleaning decisions

## Phase 2: Matching Strategy

### Tier 1: Exact Match
- Match on exact (standardized) name + firm combination
- Highest confidence; apply first

### Tier 2: Fuzzy Match
- Use string similarity (e.g., Jaro-Winkler, Levenshtein) for name matching
- Combine with firm name and/or location for disambiguation
- Set minimum similarity threshold (document and justify)
- Flag matches below high-confidence threshold for manual review

### Tier 3: Supplementary Signals
- Use additional fields (time period, office location, engagement details) to disambiguate
- Consider blocking strategies to reduce comparison space

## Phase 3: Quality Metrics

After each matching round, report:

| Metric | Definition |
|--------|-----------|
| Match rate | % of Form AP partners with a Revelio link |
| Unique match rate | % with exactly one Revelio match |
| Ambiguous match rate | % with multiple candidate matches |
| Unmatched rate | % with no match |
| False positive sample | Manual review of random matched pairs |

## Phase 4: Validation

- [ ] Random sample manual review (target: 100+ pairs per matching tier)
- [ ] Precision estimate from manual review
- [ ] Check for systematic patterns in unmatched records
- [ ] Cross-validate with any available ground truth

## Phase 5: Iteration

If match rate or precision is insufficient:
1. Diagnose: What types of records are failing?
2. Improve: Adjust cleaning, thresholds, or add matching features
3. Re-run and re-validate
4. Document each iteration in session log

---

## Matching Tolerance Thresholds

| Parameter | Default | Notes |
|-----------|---------|-------|
| Exact name+firm match | Confidence: HIGH | No threshold needed |
| Fuzzy name similarity | >= 0.90 (Jaro-Winkler) | Adjust based on validation |
| Fuzzy match + firm match | >= 0.85 | Firm match compensates |
| Manual review zone | 0.80 - 0.90 | Flag for human review |
| Reject threshold | < 0.80 | Do not link |

---

## Non-Negotiables

1. **Never modify raw data** -- all cleaning produces new files in `data/processed/`
2. **Log every merge** -- row counts before, after, and match rates
3. **Document thresholds** -- every cutoff must have a justification
4. **Validate before shipping** -- manual review sample before finalizing
5. **Version outputs** -- date-stamped output files, never overwrite silently

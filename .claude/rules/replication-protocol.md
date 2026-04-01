---
paths:
  - "scripts/**/*.py"
  - "scripts/**/*.do"
  - "data/**"
---

# Data Linkage Verification Protocol

**Core principle:** Verify match quality systematically before declaring linkage complete.

---

## Phase 1: Inventory & Baseline

Before running any matching:

- [ ] Document source datasets (Form AP, Revelio) with variable definitions
- [ ] Record baseline statistics:

| Metric | Form AP | Revelio | Notes |
|--------|---------|---------|-------|
| Total records | | | |
| Unique partners | | | |
| Unique firms | | | |
| Date range | | | |
| Missing name rate | | | |

- [ ] Store baseline in `quality_reports/data_baseline.md`

---

## Phase 2: Match Quality Targets

Define success criteria before matching:

| Metric | Target | Rationale |
|--------|--------|-----------|
| Overall match rate | >= X% | Based on data coverage |
| Precision (manual review) | >= 95% | High-stakes linkage |
| Unique match rate | >= X% | Minimize ambiguity |

---

## Phase 3: Validation

After each matching round:

1. Report match rate breakdown by tier (exact, fuzzy, supplementary)
2. Draw random sample for manual review (min 100 per tier)
3. Calculate precision from manual review
4. Identify patterns in unmatched records (firm size, time period, name complexity)
5. Document findings in session log

### If Quality Below Target

**Do NOT finalize output.** Investigate:
- What record types are failing? (rare names, small firms, old records)
- Is the cleaning step adequate?
- Are thresholds too strict or too lenient?
- Document investigation even if unresolved

---

## Phase 4: Finalize

After validation confirms quality:

- [ ] Produce final matched dataset with confidence scores
- [ ] Generate summary statistics report
- [ ] Archive validation sample and review notes
- [ ] Commit with descriptive message: "Match Form AP to Revelio -- X% match rate, Y% precision"

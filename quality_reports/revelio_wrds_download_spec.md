# Revelio WRDS Download Specification

**Date:** 2026-04-01
**Purpose:** Download Revelio company mapping data from WRDS for firm-level matching (Step 1 of linkage pipeline).

---

## Overview

We need to match 388 unique Form AP audit firms to Revelio company IDs (`rcid`). The proven approach uses a three-pass fuzzy matching strategy, starting with narrow industry filters and broadening as needed.

---

## Download 1: Accounting Firms (NAICS 5412)

**Table:** `revelio_common.company_mapping`
**Expected size:** ~300K+ rows

```sql
SELECT rcid, company_name, naics, hq_country, hq_state, hq_city,
       ultimate_parent_rcid
FROM revelio_common.company_mapping
WHERE naics LIKE '5412%'
```

**Save as:** `data/raw/revelio_accounting_firms.csv`

**Notes:**
- NAICS 5412 = Accounting, Tax Preparation, Bookkeeping, and Payroll Services
- This covers most audit firms directly
- Previous project: 338,008 rows, 82,420 unique US firms

---

## Download 2: Broader Professional Services (NAICS 541%, excluding 5412)

**Table:** `revelio_common.company_mapping`
**Expected size:** ~5M+ rows (large download)

```sql
SELECT rcid, company_name, naics, hq_country, hq_state, hq_city,
       ultimate_parent_rcid
FROM revelio_common.company_mapping
WHERE naics LIKE '541%'
  AND naics NOT LIKE '5412%'
```

**Save as:** `data/raw/revelio_professional_firms.csv`

**Notes:**
- Catches firms classified under broader professional services
- Only needed for firms that don't match in Pass 1
- Previous project: 5,450,732 rows

---

## How to Run on WRDS

### Option A: WRDS Web Query
1. Go to https://wrds-www.wharton.upenn.edu/
2. Navigate to Revelio Labs > Common > Company Mapping
3. Apply the SQL filters above
4. Download as CSV

### Option B: Python via WRDS Library
```python
import wrds

db = wrds.Connection(wrds_username="YOUR_USERNAME")

# Pass 1
query1 = """
    SELECT rcid, company_name, naics, hq_country, hq_state, hq_city,
           ultimate_parent_rcid
    FROM revelio_common.company_mapping
    WHERE naics LIKE '5412%%'
"""
df1 = db.raw_sql(query1)
df1.to_csv("data/raw/revelio_accounting_firms.csv", index=False)

# Pass 2
query2 = """
    SELECT rcid, company_name, naics, hq_country, hq_state, hq_city,
           ultimate_parent_rcid
    FROM revelio_common.company_mapping
    WHERE naics LIKE '541%%'
      AND naics NOT LIKE '5412%%'
"""
df2 = db.raw_sql(query2)
df2.to_csv("data/raw/revelio_professional_firms.csv", index=False)

db.close()
```

**Important:** If using SQLAlchemy 2.x, wrap queries with `sqlalchemy.text()`:
```python
from sqlalchemy import text
df1 = db.raw_sql(text(query1))
```

---

## Later Downloads (After Firm Matching)

These will be needed in Step 2 (partner matching) but should NOT be downloaded yet:

### Individual Positions (per-rcid batches)
```sql
SELECT p.user_id, p.rcid, p.startdate, p.enddate, p.seniority,
       u.fullname
FROM revelio_individual.individual_positions p
JOIN revelio_individual.individual_user u ON p.user_id = u.user_id
WHERE p.rcid = {matched_rcid}
  AND u.fullname ILIKE '%{last_name}%'
```
- Query in batches of ~50 last names per rcid
- Previous project: ~350 total queries

### Raw Titles (for deduplication)
```sql
SELECT user_id, position_id, company_raw, title_raw
FROM revelio_individual.individual_positions_raw
WHERE user_id IN ({matched_user_ids})
```

---

## Known Pitfalls (From Previous Project)

| Pitfall | Fix |
|---------|-----|
| SQLAlchemy 2.x `immutabledict` error | Wrap queries with `sqlalchemy.text()` |
| `individual_user` has `fullname` only | No separate first/last — parse locally |
| `individual_positions_raw` has no `rcid`, `startdate`, `enddate` | Only has `user_id`, `position_id`, `company_raw`, `title_raw`, `description` |
| `role_k50_v2` column doesn't exist | Use `seniority` column instead |
| EY employees mapped to UK global parent | Search parent rcids (not just US siblings) |
| Big 4 subsidiaries | Use `ultimate_parent_rcid` to find sibling/parent rcids |

---

## Checklist

- [ ] Download 1 (NAICS 5412) saved to `data/raw/revelio_accounting_firms.csv`
- [ ] Download 2 (NAICS 541%) saved to `data/raw/revelio_professional_firms.csv`
- [ ] Verify both files are non-empty and have expected columns
- [ ] Proceed to Step 1 firm matching script

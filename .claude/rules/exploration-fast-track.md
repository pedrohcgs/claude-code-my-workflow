# Exploration Fast-Track: Lightweight Workflow for Experiments

**Purpose:** Enable fast, lightweight exploration of research ideas
**Complement to:** Plan-First workflow (which applies only to production code)

---

## Core Philosophy

**Production code** → Rigorous, planned, high-quality (80/100)
**Exploratory code** → Fast, lightweight, acceptable-quality (60/100)

Exploratory code is **experimental by design**. If it works and is valuable, graduate it to production (then apply rigor). If it doesn't work, archive it with a brief explanation and move on.

---

## When to Use Fast-Track

Use Fast-Track for work in `explorations/` folder when:

**DO USE Fast-Track:**
- Testing quick ideas (1-2 hours)
- Validating research approaches (2-6 hours)
- Exploring sensitivity analyses
- Prototyping improvements
- Any experimental work that might be deleted

**DON'T USE Fast-Track:**
- Code destined for production (R/, scripts/, tests/)
- Changes to existing production code
- Infrastructure changes
- Anything that will ship to the paper/slides

---

## The Fast-Track Workflow

### Step 1: Research Value Check (2 minutes)

**Before creating any exploratory code, answer:**

1. Does this improve the project (paper/slides/analysis)?
2. Does this help answer the research question?
3. What's the value if it works?

**If answer to #1 or #2 is clearly "NO"** → Don't build it
**If answer is "MAYBE"** → Build it in explorations/ folder (fast-track)
**If answer is "YES"** → Build with full rigor (use Plan-First)

### Step 2: Create Exploration Folder (5 minutes)

```bash
mkdir -p explorations/[project-name]/{R,scripts,output}
```

Create two files:

**`explorations/[project-name]/README.md`** (2 min)
```markdown
# [Project Name]

## Goal
[1-2 sentence description]

## Hypotheses
- If [condition], then [expected outcome]

## Success Criteria
- [Something you can measure]

## Status
[started / in progress / completed / abandoned]
```

**`explorations/[project-name]/SESSION_LOG.md`** (1 min)
```markdown
# Session Log
[Will append 2-3 line notes as you work]
```

**Start coding immediately.** No plan needed.

### Step 3: Code Without Overhead

**Lightweight Quality Standard (60/100):**

**MUST HAVE:**
- Code runs without errors
- Results are correct
- Goal is documented (in README.md)
- Approach is clear

**NOT NEEDED:**
- Roxygen documentation (you might delete this)
- Perfect path management (temporary code)
- Comprehensive error handling (you'll know if it breaks)
- Style compliance (readability sufficient)
- Full test coverage
- All magic numbers eliminated

**Attitude:** "This code might be deleted tomorrow. Focus on answering the research question, not perfecting the code."

### Step 4: Log Progress (2-3 lines per hour)

Append to `SESSION_LOG.md` as you work:

```markdown
## Hour 1
- Loaded data, checked structure
- Fit initial model: results don't match expected
- Investigating data issue

## Hour 2
- Found data issue: missing values not handled
- Fixed in preprocessing
- Results now match theory, moving forward
```

### Step 5: Decision Point (After 1-2 hours)

**OPTION A: KEEP EXPLORING**
- Direction looks promising → continue in `explorations/[project]/`

**OPTION B: GRADUATE TO PRODUCTION**
- Value validated, results correct
- Copy files to `R/`, `scripts/`, `tests/`
- Upgrade to 80/100 quality (docs, tests)
- Apply Plan-First rigor to final changes
- Move exploration to `ARCHIVE/completed_[project]/`

**OPTION C: ARCHIVE & ABANDON**
- Direction didn't work or value is zero
- Move to `explorations/ARCHIVE/abandoned_[project]/`
- Create brief archive README (5 min)
- Move on

---

## Kill Switch Protocol

At ANY point during exploration, you can stop without completing:

**Use the kill switch when:**
- Hit unexpected blocker that makes direction unviable
- Realize research value is zero
- Find simpler solution that makes exploration unnecessary
- Want to pivot to different approach

**How to use kill switch:**
1. Stop coding
2. Archive with brief note: "Attempted X, hit blocker Y, moving on"
3. Commit and move forward

**No guilt.** Exploration is inherently uncertain. The kill switch prevents sunk cost fallacy.

---

## Comparison: Fast-Track vs Plan-First

### Fast-Track (Exploration)
```
Research value check (2 min)
  ↓
Create folder (5 min)
  ↓
Code immediately (no planning)
  ↓
Log progress (2-3 min per hour)
  ↓
Decision (keep/graduate/archive)
  ↓
If abandon: Archive README (5 min)
  ↓
Total overhead: 12-17 min + logging
```

### Plan-First (Production)
```
Enter Plan Mode
  ↓
Draft comprehensive plan (20-30 min)
  ↓
Save to disk
  ↓
Present to user for approval
  ↓
Implement via orchestrator
  ↓
Full session logging
  ↓
Quality review (80/100 minimum)
  ↓
Documentation, comprehensive tests
  ↓
Total overhead: 2+ hours
```

**Fast-Track saves ~2 hours per exploration cycle.**

---

## Common Questions

**Q: What if I realize mid-exploration that something is valuable?**
A: Keep exploring in `explorations/`. When ready, graduate to production (upgrade to 80/100 quality, add tests, apply Plan-First rigor).

**Q: Can I start with Plan-First and switch to Fast-Track?**
A: No. Production code needs Plan-First rigor. If it's production-bound, use Plan-First from the start.

**Q: What if exploration reveals the production code is wrong?**
A: Document the issue, then use Plan-First to fix production code properly.

**Q: How do I know if something is exploratory or production?**
A: **Exploratory:** "I'm testing an idea; might delete it"
   **Production:** "This improves the project; shipping with it"

**Q: Do I need user approval for Fast-Track explorations?**
A: No. The research value check (2 min) replaces formal planning.

---

## Integration

This document is the **workflow** for the exploration folder.
See `exploration-folder-protocol.md` for the **overall system** (folder structure, archiving, integration with quality gates).

---

## Summary

**Fast-Track = Lightweight exploration workflow**

- Research value check (2 min)
- Create folder + README (5 min)
- Code without overhead (60/100 quality)
- Log progress (2-3 min per hour)
- Decision point (1-2 hours or when clarity emerges)
- Archive with brief explanation (5 min if abandoning)

**Total overhead:** ~12-17 min + logging
**Saves vs Plan-First:** ~2 hours per exploration cycle

Use Fast-Track for all experimental work in `explorations/` folder.
Use Plan-First for all production code.

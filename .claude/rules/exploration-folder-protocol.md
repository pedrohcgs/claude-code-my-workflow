# Exploration Folder Protocol

**Status:** MANDATORY — Enforce on all experimental work
**Workflow:** See `exploration-fast-track.md` for the lightweight workflow

---

## Core Principle

**All experimental and exploratory work goes into the `explorations/` folder first.** Only move to production (`R/`, `scripts/`, etc.) when:
1. All tests pass
2. Results replicate (tolerance checks, if applicable)
3. Code is clear and well-documented
4. Purpose is clearly established
5. Research value validated
6. Quality score >= 80/100

---

## Folder Structure

```
explorations/
├── ACTIVE_PROJECTS.md          # What's being worked on NOW
├── README.md                   # Overview of exploration folder
│
├── [project-1]/                # Each exploration gets a folder
│   ├── README.md               # Project goals, status, findings
│   ├── R/
│   │   ├── function_v1.R
│   │   ├── function_v2.R       # Can iterate on versions
│   │   └── NOTES.md            # Design decisions, what failed
│   ├── scripts/
│   │   ├── test_approach_a.R
│   │   ├── test_approach_b.R
│   │   └── COMPARISON.md       # Which approach won, why
│   ├── output/
│   │   └── [test results, CSVs, comparisons]
│   └── SESSION_LOG.md          # Session-by-session notes
│
├── [project-2]/
│   ├── README.md
│   ├── R/
│   ├── scripts/
│   └── output/
│
└── ARCHIVE/                    # Completed/abandoned projects
    ├── completed_[project]/    # Graduated to production
    └── abandoned_[project]/    # Documented why abandoned
```

---

## Workflow: From Exploration to Production

### Phase 1: Create Exploration Folder

```bash
mkdir -p explorations/[project-name]/{R,scripts,output}
```

**Create `explorations/[project-name]/README.md`:**
```markdown
# [Project Name]

## Goal
[1-2 sentence description]

## Status
[IN PROGRESS / COMPLETED / ABANDONED] (started [DATE])

## Hypotheses to Test
1. [Hypothesis 1]
2. [Hypothesis 2]

## Findings
(Updated as work progresses)

## Timeline
- [DATE]: Started exploration
```

### Phase 2: Develop & Test

All work happens in `explorations/[project-name]/`:
- Try different approaches in separate `_v1.R`, `_v2.R` files
- Keep comparison notes
- Document failures and learnings
- Store test outputs in `output/` subfolder

### Phase 3: Evaluate & Decide

**Decision checklist:**
- [ ] **Code quality:** 80+ score on quality gates
- [ ] **Tests pass:** All checks within threshold
- [ ] **Results replicate:** If compared against reference, matches within tolerance
- [ ] **Clarity:** Anyone can understand the code without deep context
- [ ] **Documentation:** Clear README explaining approach, findings, limitations
- [ ] **Purpose established:** Answer to "why is this useful?"

**Three possible outcomes:**

#### Option A: Graduate to Production
```bash
# Only if ALL checks pass
cp explorations/[project]/R/final_version.R R/[function_name].R
cp explorations/[project]/tests/ tests/testthat/test_[function_name].R
mv explorations/[project]/ explorations/ARCHIVE/completed_[project]/
```

#### Option B: Keep Exploring
```bash
# If promising but needs more work — stay in explorations/
# Document next steps in README.md
```

#### Option C: Abandon & Archive
```bash
# If decision made to not pursue
mv explorations/[project]/ explorations/ARCHIVE/abandoned_[project]/
```

**Archive README.md (required):**
```markdown
# Abandoned: [Project Name] ([DATE RANGE])

## Why Abandoned
[1-2 sentence explanation]

## What Was Tried
- [Approach 1]
- [Approach 2]

## Learnings
- [LEARN:category] What you learned for future reference

## Would Revisiting Require
- [What would need to be true to try this again?]
```

---

## Key Benefits

| Aspect | Without Explorations | With Explorations |
|--------|---------------------|-------------------|
| **Scattered files** | Many (across R/, scripts/, root) | 0 (contained in folder) |
| **Cleanup effort** | Identify each file individually | `rm -rf explorations/project/` |
| **Clarity** | "Is this experimental?" | "Yes, it's in explorations/" |
| **Decision tracking** | Notes scattered | One README per project |
| **Code reuse** | Versions mixed up | Clear `_v1`, `_v2` tracking |
| **Production safety** | Risk of committing unfinished work | Must explicitly graduate |
| **Learnings** | Hard to find what failed | ARCHIVE/ preserves rationale |

---

## Rules for Explorations Folder

### DO
- Create subfolders for each distinct exploration
- Use versions (`_v1`, `_v2`) to track iterations
- Document everything: decisions, failures, learnings
- Run tests and comparisons in the exploration folder
- Keep session logs of progress
- Archive completed or abandoned work
- Clean up aggressively

### DON'T
- Leave exploratory code in main folders (R/, scripts/, etc.)
- Create scattered analysis documents outside explorations/
- Skip documentation (archive commit should explain why)
- Forget to move proven work to production
- Mix versions without version numbers
- Commit to git without clear status (active, archived, or abandoned)

---

## Gitignore Configuration

Add to `.gitignore`:
```
# Temporary exploration outputs
explorations/**/output/*.rds      # Large RDS files during testing
explorations/**/temp/             # Temporary scratch files
explorations/**/.Rhistory         # R history files
explorations/**/*.tmp             # Temp files

# BUT DO commit:
# - explorations/**/README.md
# - explorations/**/SESSION_LOG.md
# - explorations/**/DESIGN_NOTES.md
# - explorations/**/*.R (code)
# - explorations/**/output/*.csv (small CSVs for comparison)
```

---

## Integration with Other Workflows

### With Plan-First Workflow
```
1. User requests exploration: "Let's try [idea]"
2. Create plan (in quality_reports/plans/) — or use fast-track
3. Create exploration folder (explorations/[project]/)
4. Work in exploration folder only
5. Document in SESSION_LOG.md
6. Decision point:
   - Graduate to production? → Move to R/, scripts/, tests/
   - Abandon? → Move to explorations/ARCHIVE/
```

### With Quality Gates
```
Exploration code:
- Can be 60/100 quality (it's experimental!)
- No gate to stay in explorations/
- Must be 80+/100 to graduate to production
- All tolerance checks must pass before graduating
```

### With File Organization
```
Exploration folder = special "sandbox" exception
Everything INSIDE exploration stays organized:
- R/, scripts/, tests/, output/ subfolders
- README.md, SESSION_LOG.md, DESIGN_NOTES.md
- Follows all normal organization rules

Outside exploration = STRICT organization
- No scattered files
- No scattered analysis documents
- Everything in designated folders
```

---

## Commit Strategy

### While Exploring
```bash
# Work locally — no need to commit every change
# Keep explorations/ folder clean and organized
```

### When Graduating to Production
```bash
git add R/new_function.R tests/testthat/test_new_function.R
git commit -m "Graduate [project] from exploration to production

Moved from explorations/[project]/R/function_vX.R
Successfully passed all quality checks.
See explorations/ARCHIVE/completed_[project]/README.md"
```

### When Archiving
```bash
git add explorations/ARCHIVE/abandoned_[project]/
git commit -m "Archive abandoned exploration: [project]

Decision: Not pursuing due to [reason].
See explorations/ARCHIVE/abandoned_[project]/README.md"
```

---
name: knowledge-mgmt-updater
description: Update this repo's knowledge-management records and curated deliverables archive whenever the user asks to update knowledge mgmt, 工作沉淀, research_and_deliverables, archive a project, log a completed request, sync deliverables, or record conclusions/sources for recent work. Use this skill for any task that should modify files under `knowledge_mgmt/` or copy final artifacts into `knowledge_mgmt/deliverables/`.
---

# Knowledge Mgmt Updater

Use this skill to maintain the repo's existing knowledge-management system. This is not a generic writing skill. It is specifically for keeping the local `knowledge_mgmt/` structure accurate, current, and easy to hand off.

The default target surfaces are:
- `knowledge_mgmt/工作沉淀总表.md`
- `knowledge_mgmt/research_and_deliverables.md`
- `knowledge_mgmt/deliverables/README.md`
- `knowledge_mgmt/deliverables/<date>_<project-name>/`

Do not invent a new structure if these files already exist. Extend the current system.

## When to use

Use this skill whenever the user asks for any of the following, even if they do not mention "skill" or "knowledge management" explicitly:
- "update my knowledge mgmt"
- "记录一下这个项目"
- "把这次 research 写到 md"
- "sync the deliverables log"
- "archive this project"
- "把交付物归档到 deliverables"
- "update 工作沉淀总表"
- "update research_and_deliverables"
- "make sure the handoff docs reflect this work"

## Core goal

Capture one request as a reusable knowledge artifact with:
- the request
- what was done
- the conclusion
- the final deliverables
- the supporting sources
- the reusable knowledge
- the remaining gaps

The skill should leave the repo in a state where another person can quickly answer:
- what was the task
- what is the conclusion
- where is the final artifact
- what sources support it
- what remains unresolved

## Workflow

### 1. Inspect the current knowledge-management structure

Before editing anything:
- read the current `knowledge_mgmt/工作沉淀总表.md`
- read `knowledge_mgmt/research_and_deliverables.md` if it exists
- read `knowledge_mgmt/deliverables/README.md`
- inspect the relevant project or exploration folder to identify the final artifact

Preserve the existing tone, language split, and section structure.

### 2. Decide what counts as the final deliverable

Prefer curated handoff artifacts over scripts and intermediate files.

Typical pattern:
- final workbook, report, zip, README, or packaged folder -> copy into `knowledge_mgmt/deliverables/`
- scripts, scratch notes, and intermediate work -> leave in place and link as reusable local source when useful

If the final artifact is already present in `knowledge_mgmt/deliverables/`, do not duplicate it.

### 3. Update the curated deliverables archive

If needed:
- create `knowledge_mgmt/deliverables/<date>_<project-name>/`
- copy final handoff files there
- avoid copying large exploratory directories unless they are themselves the deliverable

Update `knowledge_mgmt/deliverables/README.md` so the folder is discoverable.

### 4. Update both logs, not just one

If both files exist, update both:
- `knowledge_mgmt/工作沉淀总表.md`
- `knowledge_mgmt/research_and_deliverables.md`

The Chinese and English logs do not need to be literal translations, but they should represent the same project and same conclusions.

### 5. Preserve the house structure

For `knowledge_mgmt/工作沉淀总表.md`, preserve the existing pattern:
- quick index row
- full project section with:
  - `Request`
  - `What I Did`
  - `Conclusion`
  - `Deliverables`
  - `Sources`
  - `Reusable Knowledge`
  - `Open Gaps / Follow-Up`

For `knowledge_mgmt/research_and_deliverables.md`, preserve the same logical fields in its existing English style.

Do not rename old sections or reformat the whole file just because you would prefer a different style.

### 6. Keep source hygiene tight

Separate sources into:
- direct source used for the answer
- local reusable source such as scripts, workbooks, notes, or prompt files
- unresolved or missing source gaps

If a conclusion is inferred rather than directly stated in a source, label it as a judgment or interpretation in the prose.

### 7. Be explicit about scope boundaries

When the evidence is incomplete, say so in the relevant `Open Gaps / Follow-Up` section.

Common examples:
- only country-level factory geography is confirmed, not city-level base lists
- public sources support funding mode but not full org-level RACI
- deliverable exists, but raw screenshots or original prompts were not archived

### 8. Use stable linking

Inside knowledge-management markdown:
- prefer repo-relative markdown links
- link to curated deliverables when available
- link to the original script or exploration path only when it adds reuse value

This keeps the log readable while still preserving traceability.

## Decision rules

### When to create a new deliverables folder

Create a new folder when:
- the work has a new request date or project identity
- there is a clear final artifact to hand off
- the current final artifact still only lives in an exploration or project scratch directory

### When not to create a new folder

Do not create a new folder when:
- the task is a small metadata correction to an already archived request
- the final artifact is already archived and only the logs need updating

### What to put in the project summary

Make the conclusion useful for future routing. It should answer:
- what this project decided
- why it matters
- when this artifact should be reused again

Avoid turning the summary into a changelog.

## Output expectations

After using this skill, the repo should have:
- updated knowledge-management markdown
- curated deliverables copied if appropriate
- a short, accurate summary of what changed

## Read next when needed

- For repo-specific templates and naming conventions, read [references/templates.md](references/templates.md).

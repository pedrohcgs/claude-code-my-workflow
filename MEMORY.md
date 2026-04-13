# Project Memory

Corrections and learned facts that persist across sessions.
When a mistake is corrected, append a `[LEARN:category]` entry below.

---

<!-- Append new entries below. Most recent at bottom. -->

## Workflow Patterns

[LEARN:workflow] Requirements specification phase catches ambiguity before planning → reduces rework 30-50%. Use spec-then-plan for complex/ambiguous tasks (>1 hour or >3 files).

[LEARN:workflow] Spec-then-plan protocol: AskUserQuestion (3-5 questions) → create `quality_reports/specs/YYYY-MM-DD_description.md` with MUST/SHOULD/MAY requirements → declare clarity status (CLEAR/ASSUMED/BLOCKED) → get approval → then draft plan.

[LEARN:workflow] Context survival before compression: (1) Update MEMORY.md with [LEARN] entries, (2) Ensure session log current (last 10 min), (3) Active plan saved to disk, (4) Open questions documented. The pre-compact hook displays checklist.

[LEARN:workflow] Plans, specs, and session logs must live on disk (not just in conversation) to survive compression and session boundaries. Quality reports only at merge time.

## Documentation Standards

[LEARN:documentation] When adding new features, update BOTH README and guide immediately to prevent documentation drift. Stale docs break user trust.

[LEARN:documentation] Always document new templates in README's "What's Included" section with purpose description. Template inventory must be complete and accurate.

[LEARN:documentation] Guide must be generic (framework-oriented) not prescriptive. Provide templates with examples for multiple workflows (LaTeX, R, Python, Jupyter), let users customize. No "thou shalt" rules.

[LEARN:documentation] Date fields in frontmatter and README must reflect latest significant changes. Users check dates to assess currency.

## Design Philosophy

[LEARN:design] Framework-oriented > Prescriptive rules. Constitutional governance works as a TEMPLATE with examples users customize to their domain. Same for requirements specs.

[LEARN:design] Quality standard for guide additions: useful + pedagogically strong + drives usage + leaves great impression + improves upon starting fresh + no redundancy + not slow. All 7 criteria must hold.

[LEARN:design] Generic means working for any academic workflow: pure LaTeX (no Quarto), pure R (no LaTeX), Python/Jupyter, any domain (not just econometrics). Test recommendations across use cases.

## File Organization

[LEARN:files] Specifications go in `quality_reports/specs/YYYY-MM-DD_description.md`, not scattered in root or other directories. Maintains structure.

[LEARN:files] Templates belong in `templates/` directory with descriptive names. Currently have: session-log.md, quality-report.md, exploration-readme.md, archive-readme.md, requirements-spec.md, constitutional-governance.md, skill-template.md, research-program.md.

## Constitutional Governance

[LEARN:governance] Constitutional articles distinguish immutable principles (non-negotiable for quality/reproducibility) from flexible user preferences. Keep to 3-7 articles max.

[LEARN:governance] Example articles: Primary Artifact (which file is authoritative), Plan-First Threshold (when to plan), Quality Gate (minimum score), Verification Standard (what must pass), File Organization (where files live).

[LEARN:governance] Amendment process: Ask user if deviating from article is "amending Article X (permanent)" or "overriding for this task (one-time exception)". Preserves institutional memory.

## Skill Creation

[LEARN:skills] Effective skill descriptions use trigger phrases users actually say: "check citations", "format results", "validate protocol" → Claude knows when to load skill.

[LEARN:skills] Skills need 3 sections minimum: Instructions (step-by-step), Examples (concrete scenarios), Troubleshooting (common errors) → users can debug independently.

[LEARN:skills] Domain-specific examples beat generic ones: citation checker (psychology), protocol validator (biology), regression formatter (economics) → shows adaptability.

## Memory System

[LEARN:memory] Two-tier memory solves template vs working project tension: MEMORY.md (generic patterns, committed), personal-memory.md (machine-specific, gitignored) → cross-machine sync + local privacy.

[LEARN:memory] Post-merge hooks prompt reflection, don't auto-append → user maintains control while building habit.

## Meta-Governance

[LEARN:meta] Repository dual nature requires explicit governance: what's generic (commit) vs specific (gitignore) → prevents template pollution.

[LEARN:meta] Dogfooding principles must be enforced: plan-first, spec-then-plan, quality gates, session logs → we follow our own guide.

[LEARN:meta] Template development work (building infrastructure, docs) doesn't create session logs in quality_reports/ → those are for user work (slides, analysis), not meta-work. Keeps template clean for users who fork.

## Security Patterns

[LEARN:security] Defense-in-depth: deny list (static, fast) + hook scripts (dynamic, rich patterns) + output scanner (post-hoc detection). Each layer catches what others miss.

[LEARN:security] Safety hooks should fail CLOSED (exit 2 on error) unlike monitoring hooks which fail OPEN (exit 0). A safety check that crashes should block, not allow.

[LEARN:security] Pipeline isolation (critics never create, creators never self-score) prevents false convergence where a reviewer/fixer finds only easily fixable issues.

## Inter-Agent Patterns

[LEARN:agents] Mailbox protocol (append-only JSONL) gives agents structured communication without polluting quality_reports/ with ad-hoc files. Backward-compatible with existing report files.

[LEARN:agents] Background agents cannot prompt for permissions, causing silent failures. Always enforce foreground-only via hook.

## Research Automation

[LEARN:research] Oracle (steipete/oracle) bridges to ChatGPT Pro for second-opinion on hard problems. Best for plan reviews, theorem proving, structural estimation -- not for iterative applied micro work.

[LEARN:research] LiteParse (run-llama/liteparse) preprocesses PDFs locally. Use text extraction for prose, screenshots for tables/equations. Batch-process reading lists before lit reviews.

[LEARN:research] Karpathy autoresearch pattern: single editable file + single scalar metric + fixed time budget + keep/revert with git. Maps to Monte Carlo simulations in economics.

[LEARN:research] Effort regression fix: use `/effort high` or `max` for complex work. Add `showThinkingSummaries: true` to settings.json. When thinking depth drops, model shifts from research-first to edit-first.

## Anthropic Best Practices

[LEARN:anthropic] Keep CLAUDE.md under ~150 lines. Domain knowledge belongs in skills (loaded on-demand) not CLAUDE.md (loaded every session). Boris Cherny tests: "Would removing this line cause mistakes?"

[LEARN:anthropic] Use `context: fork` on investigation skills (lit-review, research-ideation, review-paper) to prevent context pollution. Use `effort: max` on complex analytical skills.

[LEARN:anthropic] Use `/compact Focus on [topic]` for directed compaction. Add compaction directives to CLAUDE.md so key state survives.

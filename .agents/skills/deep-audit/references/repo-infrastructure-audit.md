# Repository Infrastructure Audit

Use this reference only when `$deep-audit` is applied to this repository's workflow infrastructure.

## Independent lenses

Dispatch independent reviewers for:

1. **Executable safety** — inspect `.codex/hooks/`, scripts, and Git hooks for unsafe path handling, destructive commands, weak input validation, silent error swallowing, and event-schema mistakes.
2. **Skill and guidance integrity** — verify each `.agents/skills/*/SKILL.md` has native frontmatter, a matching directory name, valid relative links, no unsupported invocation syntax, and only intentional explicit-only policy.
3. **Configuration wiring** — parse `.codex/config.toml`, agent TOML, hook JSON, and command-policy rules; confirm every referenced file exists and configuration is discoverable.
4. **Validation quality** — inspect test gates for false-green paths, missing negative fixtures, skipped checks, and checks that cannot detect their target defect.

## Evidence requirements

Each finding must cite a file and stable locator, describe the failure mode, show the smallest witness, and propose a bounded verification step. Deduplicate by root cause before adjudication.

Audit the whole relevant surface, not only recently changed files. Include new untracked workflow files and scripts outside the primary configuration directories. Treat agreement between reviewers as triage evidence, not confirmation.

## Completion gate

The infrastructure audit is complete only when confirmed blockers are fixed or explicitly held by the user, all referenced configuration parses, skill validation passes, relative links resolve, and at least one negative fixture demonstrates that each critical gate can fail.


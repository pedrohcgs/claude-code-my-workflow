---
name: permission-check
description: Inspect Codex project configuration, sandbox scope, and command rules to explain what the current session can read, write, execute, or access over the network. Use when the user asks what permissions are active or why an operation is blocked.
---

# Permission check

Report effective capabilities from evidence, without changing configuration.

1. Read repository `.codex/config.toml`, applicable `.codex/rules/*.rules`, and the active environment context when available.
2. Distinguish filesystem sandboxing, network access, approval policy, command execution rules, and external connector permissions.
3. Note project-trust requirements and whether project configuration is actually active.
4. If settings conflict, describe the effective precedence and cite the concrete files or session state.
5. Explain the narrowest configuration change that would enable a blocked operation, but do not make that change unless the user asks.

Return a compact table of capability, effective state, evidence, and consequence. Mark anything not observable as unknown rather than inferring it.


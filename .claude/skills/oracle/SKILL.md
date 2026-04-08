---
name: oracle
description: Cross-validate ideas, proofs, or strategy with ChatGPT Pro via the Oracle CLI. Bundles context files + prompt into a single rich query for a second-opinion review.
argument-hint: "[question or task for second opinion]"
allowed-tools:
  - Bash
  - Read
  - Glob
  - Grep
---

# Oracle -- Second-Opinion via ChatGPT Pro

Use the `@steipete/oracle` CLI to bundle a prompt plus relevant files and get a second-model review. Treat outputs as advisory: verify against the codebase and tests.

## Prerequisites

- Oracle CLI installed: `npm install -g @steipete/oracle` (requires Node 22+)
- ChatGPT Pro subscription (for browser mode) OR `OPENAI_API_KEY` (for API mode)

## When to Use

- Reviewing a plan for a complex empirical project (structural estimation, etc.)
- Proving theorems or extending mathematical models
- Cross-validating an identification argument or proof strategy
- Getting a fresh perspective on a design decision
- Debugging a stubborn issue after 10+ minutes with Claude

**Not recommended for:** Applied work requiring iterative feedback loops (data exploration, specification searches).

## Workflow

### Step 1: Identify Context Files

Pick the **fewest files** that contain the truth. Fewer files + better prompt beats whole-repo dumps.

```bash
# Preview what you're sending (no tokens spent)
npx -y @steipete/oracle --dry-run summary --files-report \
  -p "$ARGUMENTS" \
  --file "relevant/files/**" --file "!**/*.test.*"
```

### Step 2: Craft the Prompt

Oracle starts with **zero** project knowledge. Include:
- Project briefing (stack, tools, constraints)
- "Where things live" (key directories, entrypoints)
- Exact question + what you tried + error text (verbatim)
- Constraints ("don't change X", "must keep public API")
- Desired output ("return patch plan + tests", "list 3 options with tradeoffs")

### Step 3: Run Oracle

**Browser mode (recommended for ChatGPT Pro -- takes 10-60 min):**
```bash
npx -y @steipete/oracle --engine browser --model gpt-5.4-pro \
  -p "$ARGUMENTS" \
  --file "src/**" --file "!**/*.test.*" \
  --slug "descriptive-session-name"
```

**Manual paste fallback (if browser automation breaks):**
```bash
npx -y @steipete/oracle --render --copy \
  -p "$ARGUMENTS" \
  --file "src/**"
```
This assembles the bundle to your clipboard for manual paste into ChatGPT.

**API mode (costs money -- get user consent first):**
```bash
npx -y @steipete/oracle --engine api --model gpt-5.4-pro \
  -p "$ARGUMENTS" \
  --file "src/**"
```

### Step 4: Handle Results

- If the run detaches/timeouts, **reattach** (don't re-run):
  ```bash
  npx -y @steipete/oracle status --hours 72
  npx -y @steipete/oracle session <id> --render
  ```
- Review the response critically -- it's a second opinion, not gospel
- Cross-reference against your codebase and tests before applying suggestions

## Safety

- Never attach secrets (`.env`, API keys, auth tokens, private keys)
- Keep total input under ~196k tokens
- API runs incur real costs -- always get explicit user consent
- Use `--dry-run summary --files-report` before any real run

## Troubleshooting

- **Browser automation fails:** Use `--render --copy` fallback to get clipboard bundle
- **Oracle defaults to API mode:** If `OPENAI_API_KEY` is set in environment, Oracle auto-selects API. Use `--engine browser` explicitly to force browser mode.
- **Session timeout:** Sessions are stored at `~/.oracle/sessions/`. Use `oracle status` to list, `oracle session <id>` to reattach.

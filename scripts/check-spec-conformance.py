#!/usr/bin/env python3
"""Audit Claude and Codex skills/configuration against their native schemas.

Checks: name format + directory match, description length, SKILL.md body size,
fields that no consumer reads, portability of frontmatter, and the native Codex
agent/config/hook wiring.  This remains one backtest gate; adding a runtime must
not silently add an eleventh gate outside the qualification topology.

Exit: 0 clean (advisories allowed), 1 spec violation, 2 internal error.
"""
import glob, json, os, re, shlex, subprocess, sys, tempfile
from pathlib import Path
try:
    import tomllib
except ImportError:  # Python 3.10 and earlier
    tomllib = None

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SPEC_FIELDS = {"name","description","license","compatibility","metadata","allowed-tools"}
# Fields Claude Code documents beyond the portable spec (verified 2026-08-21).
CC_ONLY = {"when_to_use","argument-hint","arguments","disable-model-invocation","user-invocable",
           "disallowed-tools","model","effort","context","agent","background","hooks","paths","shell"}
NAME_RE = re.compile(r'[a-z0-9]+(-[a-z0-9]+)*')
CODEX_MODELS = {
    "gpt-6-astra", "gpt-5.6-sol", "gpt-5.6-terra", "gpt-5.6-luna", "gpt-5.5",
}
CODEX_AGENT_REQUIRED = {"name", "description", "developer_instructions"}

def rel(path):
    return os.path.relpath(path, ROOT)

def parse_toml(path, errs):
    if tomllib is None:
        errs.append(f"{rel(path)}: Python 3.11+ is required to validate TOML")
        return None
    try:
        with open(path, "rb") as fh:
            return tomllib.load(fh)
    except (OSError, tomllib.TOMLDecodeError) as e:
        errs.append(f"{rel(path)}: invalid/unreadable TOML ({e})")
        return None

def hook_commands(node):
    """Yield command values from any nested Codex hooks.json group."""
    if isinstance(node, dict):
        for key, value in node.items():
            if key == "command" and isinstance(value, (str, list)):
                yield value
            else:
                yield from hook_commands(value)
    elif isinstance(node, list):
        for value in node:
            yield from hook_commands(value)

def command_script(command):
    """Return the repo-relative script token in a hook command, if present."""
    raw = " ".join(command) if isinstance(command, list) else command
    dynamic = re.search(r"\.codex/hooks/([\w.-]+\.(?:py|sh))", raw)
    if dynamic:
        return os.path.join(ROOT, ".codex", "hooks", dynamic.group(1))
    tokens = command if isinstance(command, list) else shlex.split(command)
    for token in tokens:
        token = token.replace("$CODEX_PROJECT_DIR", ROOT).replace("${CODEX_PROJECT_DIR}", ROOT)
        token = token.replace("$PWD", ROOT).replace("${PWD}", ROOT)
        if token.endswith((".py", ".sh")):
            return token if os.path.isabs(token) else os.path.join(ROOT, token)
    return None

def check_codex_native(errs, warns):
    """Validate native Codex files once the port is present."""
    marker = os.path.join(ROOT, ".codex", "port-manifest.toml")
    skill_root = os.path.join(ROOT, ".agents", "skills")
    if not (os.path.exists(marker) or os.path.isdir(skill_root)):
        return

    required_paths = [
        marker,
        os.path.join(ROOT, ".codex", "config.toml"),
        os.path.join(ROOT, ".codex", "hooks.json"),
        os.path.join(ROOT, ".codex", "rules", "git.rules"),
        skill_root,
        os.path.join(ROOT, ".codex", "agents"),
    ]
    for path in required_paths:
        if not os.path.exists(path):
            errs.append(f"{rel(path)}: required by the native Codex port but missing")

    rules_path = os.path.join(ROOT, ".codex", "rules", "git.rules")
    if os.path.isfile(rules_path):
        rules_text = open(rules_path, encoding="utf-8", errors="ignore").read()
        forbidden_blocks = re.findall(
            r"prefix_rule\(\s*(.*?decision\s*=\s*\"forbidden\".*?)\n\)",
            rules_text, re.S,
        )
        if not forbidden_blocks:
            errs.append(".codex/rules/git.rules: no forbidden command rules found")
        for index, block in enumerate(forbidden_blocks, 1):
            if "match =" not in block or "not_match =" not in block:
                errs.append(
                    f".codex/rules/git.rules: forbidden rule {index} needs match and not_match fixtures"
                )

    manifest = parse_toml(marker, errs) if os.path.isfile(marker) else None
    config_path = os.path.join(ROOT, ".codex", "config.toml")
    config = parse_toml(config_path, errs) if os.path.isfile(config_path) else None
    if isinstance(config, dict):
        expected_config = {
            "sandbox_mode": "workspace-write",
            "approval_policy": "never",
        }
        for key, expected in expected_config.items():
            if config.get(key) != expected:
                errs.append(f".codex/config.toml: {key} must be {expected!r}")
        if config.get("sandbox_workspace_write", {}).get("network_access") is not False:
            errs.append(".codex/config.toml: sandbox_workspace_write.network_access must be false")
        for feature in ("hooks", "multi_agent"):
            if config.get("features", {}).get(feature) is not True:
                errs.append(f".codex/config.toml: features.{feature} must be true")
        if config.get("agents", {}).get("max_concurrent_threads_per_session") != 6:
            errs.append(".codex/config.toml: agents.max_concurrent_threads_per_session must be 6")

    if isinstance(manifest, dict):
        def targets(section, *, include_added=False):
            values = set(manifest.get(section, {}).get("direct", []))
            for mapping in manifest.get(section, {}).get("renamed", []):
                values.add(mapping.split("=>", 1)[-1].strip())
            if include_added:
                for item in manifest.get(section, {}).get("added", []):
                    values.add(item.split(" ", 1)[0].strip())
            return values

        inventories = {
            "skills": (
                targets("skills", include_added=True),
                {os.path.basename(os.path.dirname(p)) for p in
                 glob.glob(os.path.join(ROOT, ".agents/skills/*/SKILL.md"))},
            ),
            "agents": (
                targets("agents", include_added=True),
                {os.path.splitext(os.path.basename(p))[0] for p in
                 glob.glob(os.path.join(ROOT, ".codex/agents/*.toml"))},
            ),
            "guidance": (
                targets("guidance", include_added=True),
                {os.path.splitext(os.path.basename(p))[0] for p in
                 glob.glob(os.path.join(ROOT, ".codex/guidance/*.md"))},
            ),
        }
        for kind, (declared, actual) in inventories.items():
            if declared != actual:
                errs.append(
                    f".codex/port-manifest.toml: {kind} inventory differs from disk; "
                    f"missing={sorted(actual - declared)}, stale={sorted(declared - actual)}"
                )
        declared_hooks = set(manifest.get("hooks", {}).get("behaviors", []))
        actual_hooks = {
            os.path.splitext(os.path.basename(p))[0] for p in
            glob.glob(os.path.join(ROOT, ".codex/hooks/*"))
            if p.endswith((".py", ".sh"))
        }
        if declared_hooks != actual_hooks:
            errs.append(
                ".codex/port-manifest.toml: hook inventory differs from disk; "
                f"missing={sorted(actual_hooks - declared_hooks)}, "
                f"stale={sorted(declared_hooks - actual_hooks)}"
            )

    agent_files = sorted(glob.glob(os.path.join(ROOT, ".codex/agents/*.toml")))
    if not agent_files:
        errs.append(".codex/agents: no custom agent TOML files found")
    agent_models = {}
    for path in agent_files:
        data = parse_toml(path, errs)
        if not isinstance(data, dict):
            continue
        missing = sorted(k for k in CODEX_AGENT_REQUIRED if not data.get(k))
        if missing:
            errs.append(f"{rel(path)}: missing required field(s) {missing}")
        if data.get("model") and data["model"] not in CODEX_MODELS:
            errs.append(f"{rel(path)}: unsupported model pin {data['model']!r}")
        if data.get("model"):
            agent_models[os.path.splitext(os.path.basename(path))[0]] = data["model"]
        sandbox = data.get("sandbox_mode")
        if sandbox not in (None, "read-only", "workspace-write"):
            errs.append(f"{rel(path)}: unsupported sandbox_mode {sandbox!r}")
        writable_agents = {
            "strategist.toml", "storyteller.toml", "verifier.toml", "writer.toml",
        }
        expected_sandbox = (
            "workspace-write" if os.path.basename(path) in writable_agents else "read-only"
        )
        if sandbox != expected_sandbox:
            errs.append(
                f"{rel(path)}: sandbox_mode must be {expected_sandbox!r} for its role"
            )
        if data.get("model_reasoning_effort") not in {"medium", "high"}:
            errs.append(f"{rel(path)}: model_reasoning_effort must be medium or high")

    if isinstance(manifest, dict):
        declared_models = {}
        for model, names in manifest.get("models", {}).items():
            if model not in CODEX_MODELS:
                errs.append(f".codex/port-manifest.toml: unsupported model key {model!r}")
            for name in names:
                if name in declared_models:
                    errs.append(f".codex/port-manifest.toml: agent {name!r} has multiple model pins")
                declared_models[name] = model
        if declared_models != agent_models:
            differences = sorted(
                name for name in set(declared_models) | set(agent_models)
                if declared_models.get(name) != agent_models.get(name)
            )
            errs.append(
                ".codex/port-manifest.toml: model pins differ from agent TOML for "
                + ", ".join(differences)
            )

    hooks_path = os.path.join(ROOT, ".codex", "hooks.json")
    if os.path.isfile(hooks_path):
        try:
            hooks = json.load(open(hooks_path, encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as e:
            errs.append(f"{rel(hooks_path)}: invalid/unreadable JSON ({e})")
        else:
            if not isinstance(hooks, dict) or not hooks.get("hooks"):
                errs.append(".codex/hooks.json: top-level 'hooks' object is missing or empty")
            hook_groups = hooks.get("hooks", {})
            required_events = {"PreToolUse", "PostToolUse", "Stop", "PreCompact", "SessionStart", "SessionEnd"}
            missing_events = sorted(required_events - set(hook_groups)) if isinstance(hook_groups, dict) else sorted(required_events)
            if missing_events:
                errs.append(f".codex/hooks.json: missing lifecycle event(s) {missing_events}")
            commands = list(hook_commands(hook_groups))
            if not commands:
                errs.append(".codex/hooks.json: no command hooks are registered")
            for command in commands:
                try:
                    script = command_script(command)
                except ValueError as e:
                    errs.append(f".codex/hooks.json: cannot tokenize command {command!r} ({e})")
                    continue
                if not script:
                    continue  # built-in/non-script command; JSON shape is still checked
                if not os.path.isfile(script):
                    errs.append(f".codex/hooks.json: command points to missing {rel(script)}")
                elif not os.access(script, os.X_OK):
                    errs.append(f"{rel(script)}: registered Codex hook is not executable")

    # Qualification fixtures live inside this existing gate so the repository
    # retains its ten-gate topology. They cover Codex event/output contracts,
    # allow controls, state hand-off, recursion protection, and fail-open input.
    guard_dir = os.path.join(ROOT, ".codex", "hooks")

    def fire(filename, event, *, cwd=ROOT, env=None, raw=None):
        path = os.path.join(guard_dir, filename)
        if not os.path.isfile(path):
            return None  # missing path is already reported by hooks.json wiring
        merged_env = os.environ.copy()
        if env:
            merged_env.update(env)
        return subprocess.run(
            [sys.executable, path] if filename.endswith(".py") else [path],
            input=raw if raw is not None else json.dumps(event),
            text=True, capture_output=True, cwd=cwd, env=merged_env, timeout=10,
        )

    def expect(filename, event, label, *, contains=None, silent=False, cwd=ROOT, env=None):
        result = fire(filename, event, cwd=cwd, env=env)
        if result is None:
            return
        wrong = result.returncode != 0
        if contains is not None:
            wrong = wrong or contains not in result.stdout
        if silent:
            wrong = wrong or bool(result.stdout.strip())
        if wrong:
            errs.append(
                f"{rel(os.path.join(guard_dir, filename))}: qualification failed ({label}); "
                f"exit {result.returncode}, stdout={result.stdout.strip()[:160]!r}, "
                f"stderr={result.stderr.strip()[:120]!r}"
            )

    expect(
        "root-of-trust-guard.py",
        {"tool_name": "Bash", "tool_input": {"command": "tee .codex/config.toml"}},
        "protected control write is denied", contains='"permissionDecision": "deny"',
    )
    expect(
        "root-of-trust-guard.py",
        {"tool_name": "Bash", "tool_input": {"command": "git status --short AGENTS.md"}},
        "protected-path reads remain allowed", silent=True,
    )
    expect(
        "git-guardrails.py",
        {"tool_name": "Bash", "tool_input": {"command": "git reset --hard HEAD"}},
        "destructive Git is denied", contains='"permissionDecision": "deny"',
    )
    expect(
        "git-guardrails.py",
        {"tool_name": "Bash", "tool_input": {"command": "git push --force-with-lease"}},
        "lease-protected force push is still denied", contains='"permissionDecision": "deny"',
    )
    expect(
        "git-guardrails.py",
        {"tool_name": "Bash", "tool_input": {"command": "git status --short"}},
        "safe Git reads remain allowed", silent=True,
    )

    with tempfile.TemporaryDirectory(prefix="codex-hook-fixture-") as tmp_name:
        tmp = Path(tmp_name)
        passport_dir = tmp / "quality_reports" / "passports"
        passport_dir.mkdir(parents=True)
        (passport_dir / "fixture.yaml").write_text("source_file: analysis.R\n", encoding="utf-8")
        patch_event = {
            "tool_name": "apply_patch",
            "tool_input": {"command": "*** Update File: analysis.R"},
            "cwd": tmp_name,
        }
        expect(
            "claim-reconcile.py", patch_event,
            "claim edits emit Codex additional context",
            contains='"hookEventName": "PostToolUse"', cwd=tmp_name,
        )
        expect(
            "claim-reconcile.py",
            {"tool_name": "apply_patch", "tool_input": {"command": "*** Update File: notes.txt"},
             "cwd": tmp_name},
            "irrelevant edits remain silent", silent=True, cwd=tmp_name,
        )

        plans = tmp / "quality_reports" / "plans"
        plans.mkdir(parents=True)
        (plans / "fixture.md").write_text("# Fixture\n\n**Status:** DRAFT\n\n- [ ] Continue work\n")
        compact_event = {"trigger": "auto", "cwd": tmp_name}
        expect(
            "pre-compact.py", compact_event,
            "opt-in draft guard blocks compaction once", contains='"continue": false',
            cwd=tmp_name, env={"CODEX_PRECOMPACT_BLOCK_ON_DRAFT": "1"},
        )
        expect(
            "pre-compact.py", compact_event,
            "draft guard does not loop", silent=True,
            cwd=tmp_name, env={"CODEX_PRECOMPACT_BLOCK_ON_DRAFT": "1"},
        )
        expect(
            "restore-context.py", {"source": "compact", "cwd": tmp_name},
            "saved context is restored through additionalContext",
            contains='"hookEventName": "SessionStart"', cwd=tmp_name,
        )
        expect(
            "restore-context.py", {"source": "compact", "cwd": tmp_name},
            "restored state is consumed once", silent=True, cwd=tmp_name,
        )

        subprocess.run(["git", "init", "-q", tmp_name], capture_output=True, timeout=10)
        (tmp / "artifact.txt").write_text("changed\n", encoding="utf-8")
        stop_event = {"cwd": tmp_name, "stop_hook_active": False}
        expect(
            "session-log.py", stop_event, "Stop writes a structured log",
            contains="{}", cwd=tmp_name,
        )
        logs = sorted((tmp / "quality_reports" / "session_logs").glob("*_codex_auto.md"))
        if not logs or "artifact.txt" not in logs[0].read_text(encoding="utf-8"):
            errs.append(".codex/hooks/session-log.py: Stop fixture did not record the changed path")
        before = logs[0].stat().st_size if logs else 0
        expect(
            "session-log.py", {"cwd": tmp_name, "stop_hook_active": True},
            "Stop recursion protection returns neutral JSON", contains="{}", cwd=tmp_name,
        )
        if logs and logs[0].stat().st_size != before:
            errs.append(".codex/hooks/session-log.py: stop_hook_active caused recursive logging")

    # Decision and provenance hooks fail open silently on malformed/missing context.
    for filename in ("root-of-trust-guard.py", "git-guardrails.py", "claim-reconcile.py",
                     "pre-compact.py", "restore-context.py"):
        result = fire(filename, {}, raw="not-json")
        if result is not None and (result.returncode != 0 or result.stdout.strip()):
            errs.append(f"{rel(os.path.join(guard_dir, filename))}: malformed input must fail open silently")
    notify = fire("notify.sh", {})
    if notify is not None and (notify.returncode != 0 or notify.stdout.strip()):
        errs.append(".codex/hooks/notify.sh: notification fixture must exit cleanly without stdout")

def check_native_leakage(errs):
    """Reject runtime-specific Claude syntax and intentionally omitted workflows."""
    roots = [os.path.join(ROOT, ".agents"), os.path.join(ROOT, ".codex")]
    files = []
    for root in roots:
        if os.path.isdir(root):
            files.extend(glob.glob(os.path.join(root, "**", "*.md"), recursive=True))
            files.extend(glob.glob(os.path.join(root, "**", "*.toml"), recursive=True))
            files.extend(glob.glob(os.path.join(root, "**", "*.yaml"), recursive=True))
    # The manifest intentionally records Claude source paths and exclusions.
    files = [p for p in sorted(set(files)) if not p.endswith("port-manifest.toml")]
    native_skill_names = [os.path.basename(os.path.dirname(p)) for p in
                          glob.glob(os.path.join(ROOT, ".agents/skills/*/SKILL.md"))]
    slash_skill = re.compile(r"(?<![A-Za-z0-9_.-])/(?:(?:" + "|".join(map(re.escape, native_skill_names)) + r"))\b") \
        if native_skill_names else None
    banned_ids = re.compile(
        r"\b(?:qa-quarto|translate-to-quarto|stata-replication|create-lecture|"
        r"scaffold-exercises|pedagogy-review|respond-to-eval|syllabus)\b", re.I)
    for path in files:
        text = open(path, encoding="utf-8", errors="ignore").read()
        fm_match = re.match(r"^---\n(.*?)\n---", text, re.S) if path.endswith("SKILL.md") else None
        fm_lines = set((fm_match.group(1).splitlines() if fm_match else []))
        for lineno, line in enumerate(text.splitlines(), 1):
            reason = None
            if ".claude/" in line or "CLAUDE.md" in line:
                reason = "legacy Claude path"
            elif slash_skill and slash_skill.search(line):
                reason = "Claude slash-skill syntax; use $skill in Codex"
            elif line in fm_lines and re.search(
                r"^(?:argument-hint|disable-model-invocation|context|agent|effort):", line
            ):
                reason = "Claude-only skill frontmatter"
            elif banned_ids.search(line):
                reason = "intentionally excluded teaching/Quarto/Stata workflow"
            if reason:
                errs.append(f"{rel(path)}:{lineno}: {reason}: {line.strip()[:90]}")

    # Codex discovery metadata has a separate schema next to SKILL.md. We do
    # not need a YAML dependency for its one critical boolean, but malformed
    # spellings must not silently turn an explicit-only skill implicit.
    for path in glob.glob(os.path.join(ROOT, ".agents/skills/*/agents/openai.yaml")):
        text = open(path, encoding="utf-8", errors="ignore").read()
        for match in re.finditer(r"^\s*allow_implicit_invocation:\s*(\S+)\s*$", text, re.M):
            if match.group(1).lower() not in {"true", "false"}:
                errs.append(
                    f"{rel(path)}: allow_implicit_invocation must be true or false, "
                    f"got {match.group(1)!r}"
                )

    for codex_skill in glob.glob(os.path.join(ROOT, ".agents/skills/*/SKILL.md")):
        name = os.path.basename(os.path.dirname(codex_skill))
        source_name = "teach-from-paper" if name == "present-paper" else name
        source = os.path.join(ROOT, ".claude", "skills", source_name, "SKILL.md")
        if not os.path.isfile(source):
            continue  # added native skill, not a direct port
        source_text = open(source, encoding="utf-8", errors="ignore").read()
        if not re.search(r"^disable-model-invocation:\s*true\s*$", source_text, re.M):
            continue
        metadata = os.path.join(os.path.dirname(codex_skill), "agents", "openai.yaml")
        if not os.path.isfile(metadata):
            errs.append(
                f"{rel(codex_skill)}: Claude source was explicit-only but agents/openai.yaml is missing"
            )
            continue
        metadata_text = open(metadata, encoding="utf-8", errors="ignore").read()
        if not re.search(r"^\s*allow_implicit_invocation:\s*false\s*$", metadata_text, re.M):
            errs.append(
                f"{rel(metadata)}: ported explicit-only skill must set allow_implicit_invocation: false"
            )

def main():
    errs, warns = [], []
    claude_skills = sorted(glob.glob(os.path.join(ROOT, ".claude/skills/*/SKILL.md")))
    codex_skills = sorted(glob.glob(os.path.join(ROOT, ".agents/skills/*/SKILL.md")))
    skills = claude_skills + codex_skills
    if not skills:
        print("check-spec-conformance: no skills found", file=sys.stderr); return 2
    for f in skills:
        d = os.path.basename(os.path.dirname(f))
        rel = os.path.relpath(f, ROOT)
        s = open(f, encoding="utf-8", errors="ignore").read()
        m = re.match(r'^---\n(.*?)\n---\n(.*)$', s, re.S)
        if not m:
            errs.append(f"{rel}: no YAML frontmatter"); continue
        fm, body = m.group(1), m.group(2)
        def field(k):
            # Value = rest of THIS line plus indented continuation lines only.
            # The old \s* skipped a blank value across the newline and returned
            # the NEXT key's line, so an empty description: passed (v2.5 audit).
            mm = re.search(rf'^{re.escape(k)}:[ \t]*(.*(?:\n[ \t]+\S.*)*)', fm, re.M)
            return mm.group(1).strip() if mm else None
        name = (field("name") or "").strip().strip('"\'')
        desc = field("description") or ""
        if not name:                       errs.append(f"{rel}: missing required 'name'")
        elif not NAME_RE.fullmatch(name):  errs.append(f"{rel}: name '{name}' violates spec format")
        elif name != d:                    errs.append(f"{rel}: name '{name}' != directory '{d}'")
        if not desc:                       errs.append(f"{rel}: missing required 'description'")
        elif len(desc) > 1024:             errs.append(f"{rel}: description {len(desc)} chars > 1024 spec max")
        n = body.count("\n")
        if n > 500:                        errs.append(f"{rel}: body {n} lines > 500 (spec guidance: split into references/)")
        keys = set(re.findall(r'^([a-zA-Z_-]+):', fm, re.M))
        unknown = keys - SPEC_FIELDS - CC_ONLY
        if unknown:
            errs.append(f"{rel}: field(s) {sorted(unknown)} read by neither the spec nor Claude Code "
                        f"— move under 'metadata:'")
        nonportable = keys & CC_ONLY
        is_codex = f in codex_skills
        if is_codex and nonportable:
            errs.append(f"{rel}: Codex skill uses Claude-only field(s) {sorted(nonportable)}")
        elif nonportable:
            warns.append(f"{rel}: {sorted(nonportable)} are Claude Code-only "
                         f"(blocks claude.ai upload / Skills API / Cowork / Routines)")
    check_codex_native(errs, warns)
    check_native_leakage(errs)
    print(f"check-spec-conformance: {len(claude_skills)} Claude + {len(codex_skills)} Codex skills audited")
    if errs:
        print(f"\n{len(errs)} SPEC VIOLATION(S):")
        for e in errs: print(f"  {e}")
    if warns:
        print(f"\n{len(warns)} portability advisory(ies) — not failures, a deliberate ceiling:")
        for w in warns[:3]: print(f"  {w}")
        if len(warns) > 3: print(f"  … and {len(warns)-3} more")
    if not errs: print("\nAll skills conform to the Agent Skills spec.")
    return 1 if errs else 0

if __name__ == "__main__":
    sys.exit(main())

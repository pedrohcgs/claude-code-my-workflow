#!/usr/bin/env python3
"""Run trigger evaluation for a skill description in Codex.

Tests whether a skill description causes Codex to trigger a synthetic probe
skill for a set of queries. Outputs results as JSON.
"""

import argparse
import json
import shutil
import subprocess
import sys
import tempfile
import uuid
from concurrent.futures import ProcessPoolExecutor, as_completed
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from scripts.utils import parse_skill_md


def find_project_root() -> Path:
    """Find the git root when available, otherwise fall back to cwd."""
    current = Path.cwd().resolve()
    try:
        result = subprocess.run(
            ["git", "-C", str(current), "rev-parse", "--show-toplevel"],
            capture_output=True,
            text=True,
            check=True,
        )
        root = Path(result.stdout.strip()).resolve()
        if root.exists():
            return root
    except Exception:
        pass

    for parent in [current, *current.parents]:
        if (parent / ".git").exists() or (parent / ".agents").is_dir():
            return parent
    return current


def _write_probe_skill(skill_dir: Path, skill_name: str, description: str, token: str) -> None:
    """Create a temporary probe skill that emits a unique token when triggered."""
    lines = description.splitlines() or [""]
    indented_description = "\n  ".join(lines)
    content = (
        f"---\n"
        f"name: {skill_name}\n"
        f"description: |\n"
        f"  {indented_description}\n"
        f"---\n\n"
        f"# Trigger Probe\n\n"
        f"If this skill is used, reply with exactly `{token}` and nothing else.\n"
    )
    skill_dir.mkdir(parents=True, exist_ok=False)
    (skill_dir / "SKILL.md").write_text(content)


def run_single_query(
    query: str,
    probe_token: str,
    timeout: int,
    project_root: str,
    model: str | None = None,
) -> bool:
    """Run a single query and return whether the probe skill was triggered."""
    with tempfile.TemporaryDirectory(prefix="codex-skill-eval-") as temp_dir:
        output_file = Path(temp_dir) / "last_message.txt"
        cmd = [
            "codex",
            "exec",
            "--skip-git-repo-check",
            "-C",
            project_root,
            "--sandbox",
            "read-only",
            "-o",
            str(output_file),
        ]
        if model:
            cmd.extend(["--model", model])
        cmd.append("-")

        try:
            result = subprocess.run(
                cmd,
                input=query,
                capture_output=True,
                text=True,
                timeout=timeout,
            )
        except subprocess.TimeoutExpired:
            return False

        if result.returncode != 0:
            return False

        final_message = output_file.read_text() if output_file.exists() else result.stdout
        return probe_token in final_message


def run_eval(
    eval_set: list[dict],
    skill_name: str,
    description: str,
    num_workers: int,
    timeout: int,
    project_root: Path,
    runs_per_query: int = 1,
    trigger_threshold: float = 0.5,
    model: str | None = None,
) -> dict:
    """Run the full eval set and return results."""
    results = []
    unique_id = uuid.uuid4().hex[:12]
    probe_skill_name = f"skill-eval-{unique_id}"
    probe_token = f"SKILL_EVAL_TRIGGERED_{unique_id}"
    probe_skill_dir = project_root / ".agents" / "skills" / probe_skill_name

    try:
        _write_probe_skill(probe_skill_dir, probe_skill_name, description, probe_token)

        with ProcessPoolExecutor(max_workers=num_workers) as executor:
            future_to_info = {}
            for item in eval_set:
                for run_idx in range(runs_per_query):
                    future = executor.submit(
                        run_single_query,
                        item["query"],
                        probe_token,
                        timeout,
                        str(project_root),
                        model,
                    )
                    future_to_info[future] = (item, run_idx)

            query_triggers: dict[str, list[bool]] = {}
            query_items: dict[str, dict] = {}
            for future in as_completed(future_to_info):
                item, _ = future_to_info[future]
                query = item["query"]
                query_items[query] = item
                if query not in query_triggers:
                    query_triggers[query] = []
                try:
                    query_triggers[query].append(future.result())
                except Exception as exc:
                    print(f"Warning: query failed: {exc}", file=sys.stderr)
                    query_triggers[query].append(False)
    finally:
        shutil.rmtree(probe_skill_dir, ignore_errors=True)

    for query, triggers in query_triggers.items():
        item = query_items[query]
        trigger_rate = sum(triggers) / len(triggers)
        should_trigger = item["should_trigger"]
        if should_trigger:
            did_pass = trigger_rate >= trigger_threshold
        else:
            did_pass = trigger_rate < trigger_threshold
        results.append(
            {
                "query": query,
                "should_trigger": should_trigger,
                "trigger_rate": trigger_rate,
                "triggers": sum(triggers),
                "runs": len(triggers),
                "pass": did_pass,
            }
        )

    passed = sum(1 for result in results if result["pass"])
    total = len(results)

    return {
        "skill_name": skill_name,
        "description": description,
        "results": results,
        "summary": {
            "total": total,
            "passed": passed,
            "failed": total - passed,
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Run trigger evaluation for a Codex skill description")
    parser.add_argument("--eval-set", required=True, help="Path to eval set JSON file")
    parser.add_argument("--skill-path", required=True, help="Path to skill directory")
    parser.add_argument("--description", default=None, help="Override description to test")
    parser.add_argument("--num-workers", type=int, default=10, help="Number of parallel workers")
    parser.add_argument("--timeout", type=int, default=30, help="Timeout per query in seconds")
    parser.add_argument("--runs-per-query", type=int, default=3, help="Number of runs per query")
    parser.add_argument("--trigger-threshold", type=float, default=0.5, help="Trigger rate threshold")
    parser.add_argument("--model", default=None, help="Model to use for codex exec (default: user's configured model)")
    parser.add_argument("--verbose", action="store_true", help="Print progress to stderr")
    args = parser.parse_args()

    eval_set = json.loads(Path(args.eval_set).read_text())
    skill_path = Path(args.skill_path)

    if not (skill_path / "SKILL.md").exists():
        print(f"Error: No SKILL.md found at {skill_path}", file=sys.stderr)
        sys.exit(1)

    name, original_description, _ = parse_skill_md(skill_path)
    description = args.description or original_description
    project_root = find_project_root()

    if args.verbose:
        print(f"Evaluating: {description}", file=sys.stderr)

    output = run_eval(
        eval_set=eval_set,
        skill_name=name,
        description=description,
        num_workers=args.num_workers,
        timeout=args.timeout,
        project_root=project_root,
        runs_per_query=args.runs_per_query,
        trigger_threshold=args.trigger_threshold,
        model=args.model,
    )

    if args.verbose:
        summary = output["summary"]
        print(f"Results: {summary['passed']}/{summary['total']} passed", file=sys.stderr)
        for result in output["results"]:
            status = "PASS" if result["pass"] else "FAIL"
            rate_str = f"{result['triggers']}/{result['runs']}"
            print(
                f"  [{status}] rate={rate_str} expected={result['should_trigger']}: {result['query'][:70]}",
                file=sys.stderr,
            )

    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()

#!/usr/bin/env python3
"""Improve a skill description based on eval results using Codex."""

import argparse
import json
import re
import subprocess
import sys
import tempfile
from pathlib import Path

if __package__ in (None, ""):
    sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from scripts.run_eval import find_project_root
from scripts.utils import parse_skill_md


def _call_codex(prompt: str, model: str | None, timeout: int = 300) -> str:
    """Run `codex exec` and return the last assistant message."""
    with tempfile.TemporaryDirectory(prefix="codex-skill-improve-") as temp_dir:
        project_root = Path(temp_dir)
        output_file = Path(temp_dir) / "last_message.txt"
        cmd = [
            "codex",
            "exec",
            "--skip-git-repo-check",
            "-C",
            str(project_root),
            "--sandbox",
            "read-only",
            "-o",
            str(output_file),
        ]
        if model:
            cmd.extend(["--model", model])
        cmd.append("-")

        result = subprocess.run(
            cmd,
            input=prompt,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        if result.returncode != 0:
            raise RuntimeError(
                f"codex exec exited {result.returncode}\nstderr: {result.stderr}"
            )
        if output_file.exists():
            return output_file.read_text()
        return result.stdout


def improve_description(
    skill_name: str,
    skill_content: str,
    current_description: str,
    eval_results: dict,
    history: list[dict],
    model: str | None,
    test_results: dict | None = None,
    log_dir: Path | None = None,
    iteration: int | None = None,
) -> str:
    """Call Codex to improve the description based on eval results."""
    failed_triggers = [
        result for result in eval_results["results"] if result["should_trigger"] and not result["pass"]
    ]
    false_triggers = [
        result for result in eval_results["results"] if not result["should_trigger"] and not result["pass"]
    ]

    train_score = f"{eval_results['summary']['passed']}/{eval_results['summary']['total']}"
    if test_results:
        test_score = f"{test_results['summary']['passed']}/{test_results['summary']['total']}"
        scores_summary = f"Train: {train_score}, Test: {test_score}"
    else:
        scores_summary = f"Train: {train_score}"

    prompt = f"""You are optimizing a Codex skill description for a skill called "{skill_name}". A skill packages a short `name` and `description` with a deeper `SKILL.md` workflow and optional scripts. Codex sees the short metadata first and decides whether to read the full skill based on that description.

The description competes with other skills for Codex's attention. Your goal is to write a description that triggers for relevant queries and stays out of the way for irrelevant ones.

Here's the current description:
<current_description>
"{current_description}"
</current_description>

Current scores ({scores_summary}):
<scores_summary>
"""
    if failed_triggers:
        prompt += "FAILED TO TRIGGER (should have triggered but didn't):\n"
        for result in failed_triggers:
            prompt += f'  - "{result["query"]}" (triggered {result["triggers"]}/{result["runs"]} times)\n'
        prompt += "\n"

    if false_triggers:
        prompt += "FALSE TRIGGERS (triggered but shouldn't have):\n"
        for result in false_triggers:
            prompt += f'  - "{result["query"]}" (triggered {result["triggers"]}/{result["runs"]} times)\n'
        prompt += "\n"

    if history:
        prompt += "PREVIOUS ATTEMPTS (do NOT repeat these, try something structurally different):\n\n"
        for attempt in history:
            train_s = f"{attempt.get('train_passed', attempt.get('passed', 0))}/{attempt.get('train_total', attempt.get('total', 0))}"
            test_s = (
                f"{attempt.get('test_passed', '?')}/{attempt.get('test_total', '?')}"
                if attempt.get("test_passed") is not None
                else None
            )
            score_str = f"train={train_s}" + (f", test={test_s}" if test_s else "")
            prompt += f'<attempt {score_str}>\n'
            prompt += f'Description: "{attempt["description"]}"\n'
            if "results" in attempt:
                prompt += "Train results:\n"
                for result in attempt["results"]:
                    status = "PASS" if result["pass"] else "FAIL"
                    prompt += f'  [{status}] "{result["query"][:80]}" (triggered {result["triggers"]}/{result["runs"]})\n'
            if attempt.get("note"):
                prompt += f'Note: {attempt["note"]}\n'
            prompt += "</attempt>\n\n"

    prompt += f"""</scores_summary>

Skill content (for context on what the skill does):
<skill_content>
{skill_content}
</skill_content>

Based on the failures, write a new and improved description that is more likely to trigger correctly. Do not overfit to the literal examples above. Generalize from the failures to broader categories of user intent and situations where this skill would be useful or not useful.

Constraints:
1. Keep it under about 100-200 words.
2. There is a hard limit of 1024 characters, so stay comfortably under it.
3. Phrase it in the imperative, for example "Use this skill when..."
4. Focus on user intent, not internal implementation details.
5. Make it distinctive enough that Codex can tell it apart from nearby skills.

Please respond with only the new description text in <new_description> tags, nothing else."""

    text = _call_codex(prompt, model)

    match = re.search(r"<new_description>(.*?)</new_description>", text, re.DOTALL)
    description = match.group(1).strip().strip('"') if match else text.strip().strip('"')

    transcript: dict = {
        "iteration": iteration,
        "prompt": prompt,
        "response": text,
        "parsed_description": description,
        "char_count": len(description),
        "over_limit": len(description) > 1024,
    }

    if len(description) > 1024:
        shorten_prompt = (
            f"{prompt}\n\n"
            f"---\n\n"
            f"A previous attempt produced this description, which at "
            f"{len(description)} characters is over the 1024-character hard limit:\n\n"
            f'"{description}"\n\n'
            f"Rewrite it to be under 1024 characters while keeping the most "
            f"important trigger words and intent coverage. Respond with only "
            f"the new description in <new_description> tags."
        )
        shorten_text = _call_codex(shorten_prompt, model)
        match = re.search(r"<new_description>(.*?)</new_description>", shorten_text, re.DOTALL)
        shortened = match.group(1).strip().strip('"') if match else shorten_text.strip().strip('"')

        transcript["rewrite_prompt"] = shorten_prompt
        transcript["rewrite_response"] = shorten_text
        transcript["rewrite_description"] = shortened
        transcript["rewrite_char_count"] = len(shortened)
        description = shortened

    transcript["final_description"] = description

    if log_dir:
        log_dir.mkdir(parents=True, exist_ok=True)
        log_file = log_dir / f"improve_iter_{iteration or 'unknown'}.json"
        log_file.write_text(json.dumps(transcript, indent=2))

    return description


def main() -> None:
    parser = argparse.ArgumentParser(description="Improve a Codex skill description based on eval results")
    parser.add_argument("--eval-results", required=True, help="Path to eval results JSON (from run_eval.py)")
    parser.add_argument("--skill-path", required=True, help="Path to skill directory")
    parser.add_argument("--history", default=None, help="Path to history JSON (previous attempts)")
    parser.add_argument("--model", default=None, help="Model for improvement (default: user's configured model)")
    parser.add_argument("--verbose", action="store_true", help="Print progress to stderr")
    args = parser.parse_args()

    skill_path = Path(args.skill_path)
    if not (skill_path / "SKILL.md").exists():
        print(f"Error: No SKILL.md found at {skill_path}", file=sys.stderr)
        sys.exit(1)

    eval_results = json.loads(Path(args.eval_results).read_text())
    history = []
    if args.history:
        history = json.loads(Path(args.history).read_text())

    name, _, content = parse_skill_md(skill_path)
    current_description = eval_results["description"]

    if args.verbose:
        print(f"Current: {current_description}", file=sys.stderr)
        print(f"Score: {eval_results['summary']['passed']}/{eval_results['summary']['total']}", file=sys.stderr)

    new_description = improve_description(
        skill_name=name,
        skill_content=content,
        current_description=current_description,
        eval_results=eval_results,
        history=history,
        model=args.model,
    )

    if args.verbose:
        print(f"Improved: {new_description}", file=sys.stderr)

    output = {
        "description": new_description,
        "history": history
        + [
            {
                "description": current_description,
                "passed": eval_results["summary"]["passed"],
                "failed": eval_results["summary"]["failed"],
                "total": eval_results["summary"]["total"],
                "results": eval_results["results"],
            }
        ],
    }
    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()

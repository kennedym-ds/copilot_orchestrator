"""
Validation MCP Server — Structured tool access to PowerShell validation scripts.

Wraps the repository's PowerShell validation scripts as MCP tools, returning
structured JSON results instead of raw terminal output. Also exposes MCP
resources (instruction files, templates) and MCP prompts for common workflows.

Usage:
    python scripts/mcp/validation_server.py

Requires:
    pip install mcp[cli]
    PowerShell 5.1+ (powershell command available on PATH)

Tools:
    validate_assets  — Run validate-copilot-assets.ps1
    check_metadata   — Run add-prompt-metadata.ps1 -CheckOnly
    run_lint         — Run run-lint.ps1
    run_smoke_tests  — Run run-smoke-tests.ps1
    token_report     — Run token-report.ps1

Resources:
    templates://plan           — Plan template for conductor workflows
    templates://phase-complete — Phase completion template
    templates://plan-complete  — Plan completion template
    instructions://behavior    — Zen of Engineering tenets
    instructions://security    — Security baseline

Prompts:
    validate-and-report  — Full validation workflow
    tdd-cycle            — TDD implementation workflow
    severity-review      — Severity-tagged code review
"""

from mcp.server.fastmcp import FastMCP
import subprocess
import json
import os
from pathlib import Path

mcp = FastMCP("validation-server")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parent.parent.parent


def _run_powershell(script: str, extra_args: list[str] | None = None,
                    timeout: int = 120) -> dict:
    """Run a PowerShell script and return structured results."""
    script_path = REPO_ROOT / "scripts" / script
    if not script_path.exists():
        return {"error": f"Script not found: {script_path}", "exit_code": -1}

    args = ["powershell", "-NoProfile", "-NonInteractive",
            "-File", str(script_path)]
    if extra_args:
        args.extend(extra_args)

    try:
        result = subprocess.run(
            args,
            capture_output=True,
            text=True,
            timeout=timeout,
            cwd=str(REPO_ROOT),
        )
        stdout = result.stdout.strip()
        stderr = result.stderr.strip()

        # Truncate to avoid blowing up context windows
        if len(stdout) > 6000:
            stdout = stdout[:6000] + "\n... (truncated)"
        if len(stderr) > 2000:
            stderr = stderr[:2000] + "\n... (truncated)"

        return {
            "exit_code": result.returncode,
            "success": result.returncode == 0,
            "stdout": stdout or "(no output)",
            "stderr": stderr or "",
        }
    except subprocess.TimeoutExpired:
        return {"error": f"Script timed out after {timeout}s", "exit_code": -1}
    except FileNotFoundError:
        return {"error": "PowerShell is not installed or not on PATH", "exit_code": -1}
    except Exception as e:
        return {"error": str(e), "exit_code": -1}


# ---------------------------------------------------------------------------
# TOOLS — 5 validation tools
# ---------------------------------------------------------------------------

@mcp.tool()
def validate_assets(repository_root: str = ".") -> str:
    """
    Run the copilot asset validation script (validate-copilot-assets.ps1).
    Checks all agent definitions, prompts, and instructions for schema compliance.
    Returns JSON with exit_code, success boolean, and detailed output.

    Args:
        repository_root: Path to the repository root (default: current directory).
    """
    result = _run_powershell(
        "validate-copilot-assets.ps1",
        ["-RepositoryRoot", repository_root],
    )
    return json.dumps(result, indent=2)


@mcp.tool()
def check_metadata(repository_root: str = ".") -> str:
    """
    Check prompt metadata without modifying files (add-prompt-metadata.ps1 -CheckOnly).
    Reports which prompts are missing required frontmatter fields.
    Returns JSON with exit_code, success boolean, and findings.

    Args:
        repository_root: Path to the repository root (default: current directory).
    """
    result = _run_powershell(
        "add-prompt-metadata.ps1",
        ["-RepositoryRoot", repository_root, "-CheckOnly"],
    )
    return json.dumps(result, indent=2)


@mcp.tool()
def run_lint(repository_root: str = ".") -> str:
    """
    Run the repository linting script (run-lint.ps1).
    Checks code style, formatting, and convention compliance.
    Returns JSON with exit_code, success boolean, and lint findings.

    Args:
        repository_root: Path to the repository root (default: current directory).
    """
    result = _run_powershell(
        "run-lint.ps1",
        ["-RepositoryRoot", repository_root],
    )
    return json.dumps(result, indent=2)


@mcp.tool()
def run_smoke_tests(repository_root: str = ".") -> str:
    """
    Run the smoke test suite (run-smoke-tests.ps1).
    Validates that the core orchestrator features are functional.
    Returns JSON with exit_code, success boolean, and test results.

    Args:
        repository_root: Path to the repository root (default: current directory).
    """
    result = _run_powershell(
        "run-smoke-tests.ps1",
        ["-RepositoryRoot", repository_root],
    )
    return json.dumps(result, indent=2)


@mcp.tool()
def token_report(path: str = ".", config_path: str = "token-thresholds.json") -> str:
    """
    Generate a token budget report (token-report.ps1).
    Shows estimated token usage per file and warns about files exceeding thresholds.
    Returns JSON with exit_code, success boolean, and budget summary.

    Args:
        path: Path to scan for token usage (default: current directory).
        config_path: Path to token threshold config file.
    """
    result = _run_powershell(
        "token-report.ps1",
        ["-Path", path, "-ConfigPath", config_path],
    )
    return json.dumps(result, indent=2)


# ---------------------------------------------------------------------------
# RESOURCES — Expose key repo files as queryable context (VS Code 1.109+)
# ---------------------------------------------------------------------------

def _read_resource(relative_path: str) -> str:
    """Read a file relative to the repo root, with error handling."""
    full_path = REPO_ROOT / relative_path
    try:
        return full_path.read_text(encoding="utf-8")
    except FileNotFoundError:
        return f"Resource not found: {relative_path}"
    except Exception as e:
        return f"Error reading {relative_path}: {e}"


@mcp.resource("templates://plan")
def plan_template() -> str:
    """The standard plan template for conductor workflows."""
    return _read_resource("docs/templates/plan.md")


@mcp.resource("templates://phase-complete")
def phase_complete_template() -> str:
    """The phase completion template for recording implementation progress."""
    return _read_resource("docs/templates/phase-complete.md")


@mcp.resource("templates://plan-complete")
def plan_complete_template() -> str:
    """The plan completion template for final reports."""
    return _read_resource("docs/templates/plan-complete.md")


@mcp.resource("instructions://behavior")
def behavior_instructions() -> str:
    """The Zen of Engineering tenets that govern all agent output."""
    return _read_resource("instructions/global/00_behavior.instructions.md")


@mcp.resource("instructions://security")
def security_instructions() -> str:
    """The security baseline for all agent operations."""
    return _read_resource("instructions/global/02_security.instructions.md")


@mcp.resource("instructions://model-selection")
def model_selection_instructions() -> str:
    """Model allocation tiers, fallback chains, and governance rules."""
    return _read_resource("instructions/global/03_model-selection.instructions.md")


# ---------------------------------------------------------------------------
# PROMPTS — Reusable prompt templates invokable via /mcp.validation.* in chat
# ---------------------------------------------------------------------------

@mcp.prompt("validate-and-report")
def validate_and_report_prompt() -> str:
    """
    Full validation workflow: run all validation scripts, collect results,
    and produce a summary report with pass/fail status and recommendations.
    """
    return (
        "Run the following validation checks in sequence and report results:\n\n"
        "1. `validate_assets` — Check all agent definitions, prompts, and instructions\n"
        "2. `run_lint` — Check code style and formatting\n"
        "3. `run_smoke_tests` — Run the smoke test suite\n"
        "4. `check_metadata` — Verify prompt metadata completeness\n"
        "5. `token_report` — Check token budget compliance\n\n"
        "For each check, report: PASS/FAIL, error count, and key findings.\n"
        "Conclude with an overall verdict and recommended fixes for any failures."
    )


@mcp.prompt("tdd-cycle")
def tdd_cycle_prompt(file_path: str, feature: str) -> str:
    """
    Standard TDD workflow: write a failing test first, implement the feature,
    then validate with the repository's validation scripts.
    """
    return (
        f"Implement '{feature}' in {file_path} using strict TDD:\n\n"
        f"1. **Red**: Write a failing test that defines the expected behavior\n"
        f"2. **Green**: Implement the minimum code to make the test pass\n"
        f"3. **Refactor**: Clean up while keeping tests green\n"
        f"4. **Validate**: Run `validate_assets` and `run_lint` to confirm compliance\n\n"
        f"Tag each step clearly and show test output at each stage."
    )


@mcp.prompt("severity-review")
def severity_review_prompt(files: str, criteria: str = "") -> str:
    """
    Severity-tagged code review: examine files and classify findings
    as BLOCKER, MAJOR, MINOR, or NIT.
    """
    base = (
        f"Review the following files and tag each finding by severity:\n\n"
        f"**Files:** {files}\n\n"
        f"**Severity Levels:**\n"
        f"- BLOCKER: Prevents merge. Security, data loss, or correctness issues.\n"
        f"- MAJOR: Must fix before next release. Logic errors, missing tests.\n"
        f"- MINOR: Should fix. Style, naming, minor improvements.\n"
        f"- NIT: Optional. Suggestions, preferences, polish.\n\n"
        f"Run `validate_assets` to check schema compliance.\n"
        f"Conclude with a verdict: APPROVE, REVISE, or REJECT."
    )
    if criteria:
        base += f"\n\n**Additional Criteria:** {criteria}"
    return base


if __name__ == "__main__":
    mcp.run()

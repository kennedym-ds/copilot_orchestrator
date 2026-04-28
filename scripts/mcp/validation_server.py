# MCP Sandbox (VS Code 1.115+, macOS/Linux): this server operates on the repository filesystem only.
# No network except explicitly configured endpoints. Windows has no sandbox yet — review required.
# Closes gap G6 from the SOTA gap analysis.
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
    validate_assets   — Run validate-copilot-assets.ps1
    check_metadata    — Run add-prompt-metadata.ps1 -CheckOnly
    run_lint          — Run run-lint.ps1
    run_smoke_tests   — Run run-smoke-tests.ps1
    token_report      — Run token-report.ps1
    validate_handoff  — Validate agent handoff/return payloads against HS-* schemas
    get_task_status   — Poll background task status (async_mode pattern, G59)

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

from mcp.server.fastmcp import FastMCP, Context
from mcp.types import ToolAnnotations
import subprocess
import json
import os
import threading
import uuid
from pathlib import Path
from typing import Dict, Any

mcp = FastMCP("validation-server")

# ---------------------------------------------------------------------------
# Async task registry (G59 — MCP Task Augmentation pattern)
# ---------------------------------------------------------------------------
# Long-running tools (validate_assets, run_lint, run_smoke_tests) accept
# async_mode=True. When set, the tool starts work in a background thread and
# immediately returns a task handle. Call get_task_status(task_id) to poll.
#
# This implements the intent of the MCP 2025-11-25 tasks/result pattern
# without requiring the pending SDK helper. Update to the native SDK helper
# once mcp>=2.x ships it in stable form (G59 tracking).

_task_registry: Dict[str, Dict[str, Any]] = {}
_registry_lock = threading.Lock()


def _start_task(fn, *args, **kwargs) -> str:
    """Run fn(*args, **kwargs) in a daemon thread. Return task_id immediately."""
    task_id = uuid.uuid4().hex[:12]
    with _registry_lock:
        _task_registry[task_id] = {"status": "running", "result": None, "error": None}

    def _worker():
        try:
            result = fn(*args, **kwargs)
            with _registry_lock:
                _task_registry[task_id]["status"] = "complete"
                _task_registry[task_id]["result"] = result
        except Exception as exc:
            with _registry_lock:
                _task_registry[task_id]["status"] = "error"
                _task_registry[task_id]["error"] = str(exc)

    threading.Thread(target=_worker, daemon=True).start()
    return task_id


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parent.parent.parent


def _validate_repository_root(repository_root: str) -> dict | None:
    """Return an error dict if repository_root resolves outside REPO_ROOT, else None."""
    if repository_root in (".", ""):
        return None
    try:
        resolved = Path(repository_root).resolve()
    except Exception:
        return {"error": f"Invalid repository_root path: {repository_root!r}", "exit_code": -1}
    try:
        resolved.relative_to(REPO_ROOT)
    except ValueError:
        return {
            "error": f"repository_root '{repository_root}' resolves outside the repository boundary.",
            "exit_code": -1,
        }
    return None


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
        stdout = (result.stdout or "").strip()
        stderr = (result.stderr or "").strip()

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

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
async def validate_assets(repository_root: str = ".", ctx: Context = None, async_mode: bool = False) -> str:
    """
    Run the copilot asset validation script (validate-copilot-assets.ps1).
    Checks all agent definitions, prompts, and instructions for schema compliance.
    Returns JSON with exit_code, success boolean, and detailed output.

    Args:
        repository_root: Path to the repository root (default: current directory).
        async_mode: If True, start validation in the background and return a task_id.
                    Poll the result with get_task_status(task_id). [G59]
    """
    guard = _validate_repository_root(repository_root)
    if guard:
        return json.dumps(guard, indent=2)
    if async_mode:
        task_id = _start_task(
            _run_powershell, "validate-copilot-assets.ps1", ["-RepositoryRoot", repository_root]
        )
        return json.dumps({"task_id": task_id, "status": "running", "poll": "get_task_status"})
    if ctx:
        await ctx.report_progress(progress=0, total=1, message="Running asset validation...")
    result = _run_powershell(
        "validate-copilot-assets.ps1",
        ["-RepositoryRoot", repository_root],
    )
    if ctx:
        await ctx.report_progress(progress=1, total=1, message="Validation complete")
    return json.dumps(result, indent=2)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def check_metadata(repository_root: str = ".") -> str:
    """
    Check prompt metadata without modifying files (add-prompt-metadata.ps1 -CheckOnly).
    Reports which prompts are missing required frontmatter fields.
    Returns JSON with exit_code, success boolean, and findings.

    Args:
        repository_root: Path to the repository root (default: current directory).
    """
    guard = _validate_repository_root(repository_root)
    if guard:
        return json.dumps(guard, indent=2)
    result = _run_powershell(
        "add-prompt-metadata.ps1",
        ["-RepositoryRoot", repository_root, "-CheckOnly"],
    )
    return json.dumps(result, indent=2)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
async def run_lint(repository_root: str = ".", ctx: Context = None, async_mode: bool = False) -> str:
    """
    Run the repository linting script (run-lint.ps1).
    Checks code style, formatting, and convention compliance.
    Returns JSON with exit_code, success boolean, and lint findings.

    Args:
        repository_root: Path to the repository root (default: current directory).
        async_mode: If True, start linting in the background and return a task_id.
                    Poll the result with get_task_status(task_id). [G59]
    """
    guard = _validate_repository_root(repository_root)
    if guard:
        return json.dumps(guard, indent=2)
    if async_mode:
        task_id = _start_task(
            _run_powershell, "run-lint.ps1", ["-RepositoryRoot", repository_root]
        )
        return json.dumps({"task_id": task_id, "status": "running", "poll": "get_task_status"})
    if ctx:
        await ctx.report_progress(progress=0, total=1, message="Running lint checks...")
    result = _run_powershell(
        "run-lint.ps1",
        ["-RepositoryRoot", repository_root],
    )
    if ctx:
        await ctx.report_progress(progress=1, total=1, message="Lint complete")
    return json.dumps(result, indent=2)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
async def run_smoke_tests(repository_root: str = ".", ctx: Context = None, async_mode: bool = False) -> str:
    """
    Run the smoke test suite (run-smoke-tests.ps1).
    Validates that the core orchestrator features are functional.
    Returns JSON with exit_code, success boolean, and test results.

    Args:
        repository_root: Path to the repository root (default: current directory).
        async_mode: If True, start tests in the background and return a task_id.
                    Poll the result with get_task_status(task_id). [G59]
    """
    guard = _validate_repository_root(repository_root)
    if guard:
        return json.dumps(guard, indent=2)
    if async_mode:
        task_id = _start_task(
            _run_powershell, "run-smoke-tests.ps1", ["-RepositoryRoot", repository_root]
        )
        return json.dumps({"task_id": task_id, "status": "running", "poll": "get_task_status"})
    if ctx:
        await ctx.report_progress(progress=0, total=1, message="Running smoke tests...")
    result = _run_powershell(
        "run-smoke-tests.ps1",
        ["-RepositoryRoot", repository_root],
    )
    if ctx:
        await ctx.report_progress(progress=1, total=1, message="Smoke tests complete")
    return json.dumps(result, indent=2)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def get_task_status(task_id: str) -> str:
    """
    Poll the status of a background task started with async_mode=True. [G59]
    Returns status ('running', 'complete', or 'error') and the result when done.

    Args:
        task_id: The task ID returned by validate_assets/run_lint/run_smoke_tests with async_mode=True.
    """
    with _registry_lock:
        entry = _task_registry.get(task_id)
    if entry is None:
        return json.dumps({"error": f"Unknown task_id: {task_id}"})
    return json.dumps({"task_id": task_id, **entry}, indent=2)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
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
# Handoff schema definitions — used by validate_handoff tool
# ---------------------------------------------------------------------------

# Required fields shared by all HS-* dispatch schemas
_DISPATCH_REQUIRED_FIELDS: dict[str, list[str]] = {
    "HS-PLAN": ["schema_id", "objective", "inputs", "constraints"],
    "HS-IMPL": ["schema_id", "objective", "inputs", "constraints"],
    "HS-REVIEW": ["schema_id", "objective", "inputs", "constraints"],
    "HS-RESEARCH": ["schema_id", "objective", "inputs", "constraints"],
    "HS-QUALITY": ["schema_id", "objective", "inputs", "constraints"],
    "HS-RETURN": ["schema_id", "action", "summary", "recommended_next"],
}

# Valid return action enums per role
_RETURN_ACTIONS: dict[str, list[str]] = {
    "planner": ["plan-ready", "needs-research", "scope-too-large"],
    "implementer": ["phase-complete", "blocked", "needs-clarification"],
    "reviewer": ["approve", "request-changes", "escalate"],
    "researcher": ["evidence-gathered", "insufficient-sources", "out-of-scope"],
    "security": ["pass", "fail", "conditional-pass"],
    "performance": ["pass", "fail", "conditional-pass"],
    "accessibility": ["pass", "fail", "conditional-pass"],
}

# Actions that require at least one problem-detail entry
_PROBLEM_ACTIONS: dict[str, str] = {
    "needs-research": "open_questions",
    "scope-too-large": "open_questions",
    "blocked": "open_questions",
    "needs-clarification": "open_questions",
    "request-changes": "findings",
    "escalate": "findings",
    "fail": "findings",
    "insufficient-sources": "sources",
    "out-of-scope": "open_questions",
}


def _validate_payload(payload: dict, schema_id: str,
                      sender_role: str | None) -> list[str]:
    """Validate a handoff payload and return a list of error messages."""
    errors: list[str] = []

    if schema_id not in _DISPATCH_REQUIRED_FIELDS:
        errors.append(f"Unknown schema_id: {schema_id}")
        return errors

    # Check required fields
    required = _DISPATCH_REQUIRED_FIELDS[schema_id]
    for field in required:
        if field not in payload or not payload[field]:
            errors.append(f"Missing or empty required field: {field}")

    # For HS-RETURN, validate action enum and problem-detail rules
    if schema_id == "HS-RETURN" and sender_role:
        role = sender_role.lower()
        action = payload.get("action", "")
        valid_actions = _RETURN_ACTIONS.get(role, [])
        if valid_actions and action not in valid_actions:
            errors.append(
                f"Invalid action '{action}' for role '{role}'. "
                f"Valid actions: {valid_actions}"
            )
        # Check problem-detail requirement
        detail_field = _PROBLEM_ACTIONS.get(action)
        if detail_field:
            detail_value = payload.get(detail_field)
            if not detail_value or (isinstance(detail_value, list)
                                    and len(detail_value) == 0):
                errors.append(
                    f"Action '{action}' requires non-empty '{detail_field}'"
                )

    return errors


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def validate_handoff(schema_id: str, payload_json: str,
                     sender_role: str = "") -> str:
    """
    Validate an agent handoff or return payload against HS-* schemas.

    Checks required fields, action enum validity, and problem-detail rules.
    Returns JSON with valid (bool), errors (list), and the parsed payload.

    Use before dispatching a subagent (validate HS-PLAN/IMPL/REVIEW/RESEARCH/QUALITY)
    or when receiving an agent return (validate HS-RETURN with sender_role).

    Args:
        schema_id: The handoff schema ID (e.g. HS-PLAN, HS-RETURN).
        payload_json: JSON string of the handoff payload to validate.
        sender_role: Role of the returning agent (required for HS-RETURN validation).
    """
    try:
        payload = json.loads(payload_json)
    except (json.JSONDecodeError, TypeError) as exc:
        return json.dumps({
            "valid": False,
            "errors": [f"Invalid JSON: {exc}"],
            "payload": None,
        }, indent=2)

    if not isinstance(payload, dict):
        return json.dumps({
            "valid": False,
            "errors": ["Payload must be a JSON object"],
            "payload": None,
        }, indent=2)

    # Inject schema_id into payload if not present (caller may pass it separately)
    payload.setdefault("schema_id", schema_id)

    errors = _validate_payload(payload, schema_id, sender_role or None)

    return json.dumps({
        "valid": len(errors) == 0,
        "errors": errors,
        "schema_id": schema_id,
        "sender_role": sender_role or None,
        "payload": payload,
    }, indent=2)


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

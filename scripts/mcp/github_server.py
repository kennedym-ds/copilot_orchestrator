"""
GitHub Operations MCP Server

Provides GitHub issue, PR, workflow, and repository management tools
for use by the github-ops agent via the Model Context Protocol.

Prerequisites:
  - GitHub CLI (`gh`) installed and authenticated
  - Python package: mcp[cli] (pip install "mcp[cli]")

Usage:
  python scripts/mcp/github_server.py
"""

from mcp.server.fastmcp import FastMCP, Context
from mcp.types import ToolAnnotations
from pydantic import BaseModel, Field
import subprocess
import json

mcp = FastMCP("github-ops-server")


class MergeConfirmation(BaseModel):
    """Schema for merge PR confirmation elicitation."""
    confirm: bool = Field(description="Confirm merge (true/false)")


def _run_gh(args: list[str], max_output: int = 8000) -> str:
    """Run a gh CLI command and return stdout or error message."""
    try:
        result = subprocess.run(
            ["gh"] + args,
            capture_output=True,
            text=True,
            timeout=30,
        )
        output = result.stdout.strip() if result.returncode == 0 else result.stderr.strip()
        if len(output) > max_output:
            output = output[:max_output] + "\n... (truncated)"
        return output or "(no output)"
    except FileNotFoundError:
        return "Error: GitHub CLI (gh) is not installed or not on PATH."
    except subprocess.TimeoutExpired:
        return "Error: Command timed out after 30 seconds."
    except Exception as e:
        return f"Error: {e}"


# ── Issue Tools ──────────────────────────────────────────────

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def list_issues(state: str = "open", labels: str = "", limit: int = 20) -> str:
    """
    List repository issues filtered by state and labels.

    Args:
        state: Issue state filter — 'open', 'closed', or 'all'.
        labels: Comma-separated label filter (e.g. 'bug,priority:high').
        limit: Maximum number of issues to return (default 20, max 100).
    """
    args = ["issue", "list", "--state", state, "--limit", str(min(limit, 100)),
            "--json", "number,title,state,labels,assignees,createdAt,url"]
    if labels:
        args += ["--label", labels]
    return _run_gh(args)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def view_issue(number: int) -> str:
    """
    Get full details of a specific issue including body and comments.

    Args:
        number: The issue number.
    """
    return _run_gh([
        "issue", "view", str(number),
        "--json", "number,title,state,body,labels,assignees,comments,createdAt,url"
    ])


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=False,
        destructiveHint=False,
        idempotentHint=False,
        openWorldHint=True,
    ),
)
def create_issue(title: str, body: str, labels: str = "", assignees: str = "") -> str:
    """
    Create a new issue in the repository.

    Args:
        title: Issue title.
        body: Issue body (Markdown).
        labels: Comma-separated labels to apply.
        assignees: Comma-separated GitHub usernames to assign.
    """
    args = ["issue", "create", "--title", title, "--body", body]
    if labels:
        args += ["--label", labels]
    if assignees:
        args += ["--assignee", assignees]
    return _run_gh(args)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=False,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def close_issue(number: int, reason: str = "completed") -> str:
    """
    Close an issue with a reason.

    Args:
        number: The issue number.
        reason: Reason for closing — 'completed' or 'not_planned'.
    """
    return _run_gh(["issue", "close", str(number), "--reason", reason])


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=False,
        destructiveHint=False,
        idempotentHint=False,
        openWorldHint=True,
    ),
)
def comment_issue(number: int, body: str) -> str:
    """
    Add a comment to an issue.

    Args:
        number: The issue number.
        body: Comment body (Markdown).
    """
    return _run_gh(["issue", "comment", str(number), "--body", body])


# ── Pull Request Tools ───────────────────────────────────────

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def list_prs(state: str = "open", limit: int = 20) -> str:
    """
    List pull requests filtered by state.

    Args:
        state: PR state filter — 'open', 'closed', 'merged', or 'all'.
        limit: Maximum number of PRs to return (default 20, max 100).
    """
    return _run_gh([
        "pr", "list", "--state", state, "--limit", str(min(limit, 100)),
        "--json", "number,title,state,headRefName,author,createdAt,url,reviewDecision,statusCheckRollup"
    ])


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def view_pr(number: int) -> str:
    """
    Get full details of a specific pull request.

    Args:
        number: The PR number.
    """
    return _run_gh([
        "pr", "view", str(number),
        "--json", "number,title,state,body,headRefName,baseRefName,author,files,reviews,comments,statusCheckRollup,mergeable,url"
    ])


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def pr_checks(number: int) -> str:
    """
    View CI check status for a pull request.

    Args:
        number: The PR number.
    """
    return _run_gh(["pr", "checks", str(number)])


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=False,
        destructiveHint=True,
        idempotentHint=False,
        openWorldHint=True,
    ),
)
async def merge_pr(number: int, method: str = "squash", delete_branch: bool = False, ctx: Context = None) -> str:
    """
    Merge a pull request after confirming all checks pass.
    Prompts the user for confirmation before executing the merge.

    Args:
        number: The PR number.
        method: Merge method — 'squash', 'merge', or 'rebase'.
        delete_branch: Whether to delete the branch after merge (default: False).
    """
    valid_methods = {'squash', 'merge', 'rebase'}
    if method not in valid_methods:
        return f"Error: invalid merge method '{method}'. Must be one of: {', '.join(sorted(valid_methods))}"

    # Elicit user confirmation before irreversible merge
    if ctx:
        result = await ctx.elicit(
            message=f"Confirm merge of PR #{number} using '{method}' method"
                    + (" (branch will be deleted)" if delete_branch else "") + "?",
            schema=MergeConfirmation,
        )
        if result.action != "accept" or not result.data.confirm:
            return json.dumps({"status": "cancelled", "message": "Merge cancelled by user"})

    args = ["pr", "merge", str(number), f"--{method}"]
    if delete_branch:
        args.append("--delete-branch")
    return _run_gh(args)


# ── Workflow Tools ────────────────────────────────────────────

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def list_runs(workflow: str = "", status: str = "", limit: int = 10) -> str:
    """
    List recent GitHub Actions workflow runs.

    Args:
        workflow: Filter by workflow name (e.g. 'validate.yml'). Empty for all.
        status: Filter by status — 'success', 'failure', 'in_progress', etc.
        limit: Maximum number of runs to return.
    """
    args = ["run", "list", "--limit", str(min(limit, 50)),
            "--json", "databaseId,name,status,conclusion,headBranch,createdAt,url"]
    if workflow:
        args += ["--workflow", workflow]
    if status:
        args += ["--status", status]
    return _run_gh(args)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def view_run(run_id: int) -> str:
    """
    Get details and job output for a specific workflow run.

    Args:
        run_id: The workflow run ID.
    """
    return _run_gh([
        "run", "view", str(run_id),
        "--json", "databaseId,name,status,conclusion,jobs,url"
    ])


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def run_failed_logs(run_id: int) -> str:
    """
    Get the failure logs for a workflow run. Only returns logs from failed jobs.

    Args:
        run_id: The workflow run ID.
    """
    return _run_gh(["run", "view", str(run_id), "--log-failed"])


# ── Repository Tools ─────────────────────────────────────────

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=True,
    ),
)
def list_releases(limit: int = 5) -> str:
    """
    List recent releases with tag names and publish dates.

    Args:
        limit: Maximum number of releases to return.
    """
    return _run_gh([
        "release", "list", "--limit", str(min(limit, 20))
    ])


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=False,
        destructiveHint=False,
        idempotentHint=False,
        openWorldHint=True,
    ),
)
def create_release(tag: str, title: str, notes: str, draft: bool = False) -> str:
    """
    Create a new GitHub release.

    Args:
        tag: Git tag for the release (e.g. 'v1.2.0').
        title: Release title.
        notes: Release notes (Markdown).
        draft: Whether to create as a draft release.
    """
    args = ["release", "create", tag, "--title", title, "--notes", notes]
    if draft:
        args.append("--draft")
    return _run_gh(args)


if __name__ == "__main__":
    mcp.run()

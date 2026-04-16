"""
Session Analytics MCP Server — Structured access to artifacts and workflow metrics.

Provides tools for querying session data, artifact listings, and workflow metrics.
Also exposes MCP resources for the delegation routing table and agent roster,
and MCP prompts for common analytics workflows.

Usage:
    python scripts/mcp/analytics_server.py

Requires:
    pip install mcp[cli]

Tools:
    list_sessions   — List sessions from artifacts/sessions/
    get_session     — Read a specific session JSON file
    get_metrics     — Parse artifacts/token-report.json
    list_artifacts  — Browse artifacts/ folder contents
    search_artifacts — Search artifact files by content

Resources:
    routing://delegation-table — Agent delegation routing table
    roster://agents            — Full agent roster from AGENTS.md
    config://token-thresholds  — Token budget thresholds

Prompts:
    workflow-analysis   — Analyze session patterns and metrics
    cost-optimization   — Evaluate token usage and model costs
"""

from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations
import json
import os
from pathlib import Path
from datetime import datetime

mcp = FastMCP("analytics-server")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

REPO_ROOT = Path(__file__).resolve().parent.parent.parent
ARTIFACTS_DIR = REPO_ROOT / "artifacts"


def _safe_read(path: Path, max_size: int = 8000) -> str:
    """Read a file with size limits and error handling."""
    try:
        if not path.exists():
            return json.dumps({"error": f"File not found: {path.name}"})
        content = path.read_text(encoding="utf-8")
        if len(content) > max_size:
            content = content[:max_size] + "\n... (truncated)"
        return content
    except Exception as e:
        return json.dumps({"error": str(e)})


# ---------------------------------------------------------------------------
# TOOLS — 5 analytics tools
# ---------------------------------------------------------------------------

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def list_sessions(state: str = "all") -> str:
    """
    List session files from artifacts/sessions/.
    Returns JSON array of session file names with metadata.

    Args:
        state: Filter by state — 'all', 'active', 'completed', or 'archived'.
    """
    sessions_dir = ARTIFACTS_DIR / "sessions"
    if not sessions_dir.exists():
        return json.dumps({"sessions": [], "count": 0, "note": "No sessions directory found"})

    sessions = []
    for f in sorted(sessions_dir.glob("*.json"), key=lambda p: p.stat().st_mtime, reverse=True):
        try:
            data = json.loads(f.read_text(encoding="utf-8"))
            entry = {
                "file": f.name,
                "modified": datetime.fromtimestamp(f.stat().st_mtime).isoformat(),
                "size_bytes": f.stat().st_size,
            }
            # Extract common session fields if present
            for key in ("phase", "status", "agent", "objective"):
                if key in data:
                    entry[key] = data[key]
            sessions.append(entry)
        except (json.JSONDecodeError, Exception):
            sessions.append({"file": f.name, "error": "Invalid JSON"})

    if state != "all":
        sessions = [s for s in sessions if s.get("status", "") == state]

    return json.dumps({"sessions": sessions, "count": len(sessions)}, indent=2)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def get_session(session_id: str) -> str:
    """
    Read a specific session JSON file from artifacts/sessions/.
    Returns the full session data.

    Args:
        session_id: The session filename (with or without .json extension).
    """
    if not session_id.endswith(".json"):
        session_id += ".json"

    session_path = ARTIFACTS_DIR / "sessions" / session_id
    return _safe_read(session_path, max_size=12000)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def get_metrics() -> str:
    """
    Parse the token report from artifacts/token-report.json.
    Returns token usage metrics, threshold violations, and budget summary.
    """
    report_path = ARTIFACTS_DIR / "token-report.json"

    return _safe_read(report_path)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def list_artifacts(folder: str = "") -> str:
    """
    Browse artifacts/ folder contents. Lists files with sizes and modification dates.
    Use subfolders like 'plans', 'reviews', 'research' to narrow scope.

    Args:
        folder: Subfolder within artifacts/ to list (default: top-level).
    """
    target = ARTIFACTS_DIR / folder if folder else ARTIFACTS_DIR
    if not target.exists():
        return json.dumps({"error": f"Folder not found: artifacts/{folder}"})

    entries = []
    for item in sorted(target.iterdir()):
        entry = {
            "name": item.name + ("/" if item.is_dir() else ""),
            "type": "directory" if item.is_dir() else "file",
        }
        if item.is_file():
            entry["size_bytes"] = item.stat().st_size
            entry["modified"] = datetime.fromtimestamp(item.stat().st_mtime).isoformat()
        elif item.is_dir():
            entry["item_count"] = len(list(item.iterdir()))
        entries.append(entry)

    return json.dumps({
        "path": f"artifacts/{folder}" if folder else "artifacts/",
        "entries": entries,
        "count": len(entries),
    }, indent=2)


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=True,
        openWorldHint=False,
    ),
)
def search_artifacts(query: str, folder: str = "", file_pattern: str = "*.md") -> str:
    """
    Search artifact files by content. Returns matching files with line excerpts.

    Args:
        query: Text to search for (case-insensitive).
        folder: Subfolder within artifacts/ to search (default: all).
        file_pattern: Glob pattern for files to search (default: *.md).
    """
    target = ARTIFACTS_DIR / folder if folder else ARTIFACTS_DIR
    if not target.exists():
        return json.dumps({"error": f"Folder not found: artifacts/{folder}"})

    matches = []
    query_lower = query.lower()

    for f in target.rglob(file_pattern):
        try:
            content = f.read_text(encoding="utf-8")
            if query_lower in content.lower():
                # Find matching lines
                lines = content.splitlines()
                matching_lines = [
                    {"line": i + 1, "text": line.strip()[:120]}
                    for i, line in enumerate(lines)
                    if query_lower in line.lower()
                ][:5]  # Max 5 matches per file

                matches.append({
                    "file": str(f.relative_to(ARTIFACTS_DIR)),
                    "matches": matching_lines,
                })
        except Exception:
            continue

    return json.dumps({
        "query": query,
        "results": matches[:20],  # Max 20 files
        "total_files": len(matches),
    }, indent=2)


# ---------------------------------------------------------------------------
# RESOURCES — Expose key repo knowledge as queryable context (VS Code 1.109+)
# ---------------------------------------------------------------------------

@mcp.resource("routing://delegation-table")
def delegation_table() -> str:
    """The full agent delegation routing table with keyword triggers and model preferences."""
    skill_path = REPO_ROOT / ".github" / "skills" / "delegation-routing" / "SKILL.md"
    return _safe_read(skill_path, max_size=15000)


@mcp.resource("roster://agents")
def agent_roster() -> str:
    """The complete agent roster, lifecycle, and model allocation from AGENTS.md."""
    agents_path = REPO_ROOT / "AGENTS.md"
    return _safe_read(agents_path, max_size=15000)


@mcp.resource("config://token-thresholds")
def token_thresholds() -> str:
    """Token budget thresholds configuration."""
    config_path = REPO_ROOT / "token-thresholds.json"
    return _safe_read(config_path)


@mcp.resource("config://operations")
def operations_doc() -> str:
    """Operations playbook — backlog, incidents, and monitoring."""
    ops_path = REPO_ROOT / "docs" / "operations.md"
    return _safe_read(ops_path, max_size=10000)


# ---------------------------------------------------------------------------
# PROMPTS — Reusable prompt templates invokable via /mcp.analytics.* in chat
# ---------------------------------------------------------------------------

@mcp.prompt("workflow-analysis")
def workflow_analysis_prompt() -> str:
    """
    Analyze session patterns and workflow metrics across the orchestrator.
    Reviews delegation patterns, phase durations, and escalation frequency.
    """
    return (
        "Analyze the workflow patterns in this orchestrator:\n\n"
        "1. Use `list_sessions` to get all session data\n"
        "2. Use `list_artifacts` on each subfolder to see output distribution\n"
        "3. Use `get_metrics` to review token usage\n\n"
        "Report on:\n"
        "- Total sessions by status (active, completed, archived)\n"
        "- Most-used artifact folders (plans, reviews, research)\n"
        "- Token budget compliance\n"
        "- Recommended process improvements"
    )


@mcp.prompt("cost-optimization")
def cost_optimization_prompt() -> str:
    """
    Evaluate token usage and model costs across the orchestrator.
    Compares actual usage against budget thresholds.
    """
    return (
        "Perform a cost optimization analysis:\n\n"
        "1. Run `token_report` via the validation server to get current token usage\n"
        "2. Use `get_metrics` to see historical token data\n"
        "3. Review `config://token-thresholds` resource for budget limits\n"
        "4. Check `roster://agents` resource for model allocation\n\n"
        "Report:\n"
        "- Files exceeding token thresholds (name, current, limit)\n"
        "- Estimated cost by model tier (Premium, Execution, Routine)\n"
        "- Optimization opportunities (file splitting, instruction compression)\n"
        "- Recommendations for model tier adjustments"
    )


if __name__ == "__main__":
    mcp.run()

# MCP Sandbox (VS Code 1.115+, macOS/Linux): this server operates on the repository filesystem only.
# No network except explicitly configured endpoints. Windows has no sandbox yet — review required.
# Closes gap G6 from the SOTA gap analysis.
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


def _validate_artifacts_path(subpath: str) -> str | None:
    """Ensure *subpath* resolves inside ARTIFACTS_DIR. Returns error JSON or None."""
    try:
        resolved = (ARTIFACTS_DIR / subpath).resolve()
        if not resolved.is_relative_to(ARTIFACTS_DIR.resolve()):
            return json.dumps({"error": f"Path '{subpath}' resolves outside artifacts/"})
    except (ValueError, OSError) as e:
        return json.dumps({"error": f"Invalid path: {e}"})
    return None


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
        except Exception:
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

    path_error = _validate_artifacts_path(f"sessions/{session_id}")
    if path_error:
        return path_error
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
def loop_metrics() -> str:
    """
    Agentic-loop observability (G64). Aggregates hook JSONL streams to produce:
      - iteration_count: total subagent-start events
      - repetition_rate: fraction of (parent,child) edges that repeat
      - depth_max: deepest observed nesting
      - tool_failures: count from post-tool-failure.jsonl
      - compactions: count of pre-compact events
      - effort_distribution: placeholder — populated once thinkingEffort is logged per call

    Returns JSON. Safe for budget dashboards and session post-mortems.
    """
    hooks_dir = ARTIFACTS_DIR / "sessions" / "hooks"
    metrics = {
        "iteration_count": 0,
        "repetition_rate": 0.0,
        "depth_max": 0,
        "tool_failures": 0,
        "compactions": 0,
        "effort_distribution": {"low": 0, "medium": 0, "high": 0},
    }
    if not hooks_dir.exists():
        return json.dumps(metrics)

    edges = []
    for line in (hooks_dir / "subagent-start.jsonl").read_text(encoding="utf-8").splitlines() if (hooks_dir / "subagent-start.jsonl").exists() else []:
        try:
            ev = json.loads(line)
            edges.append((ev.get("parent"), ev.get("child")))
            depth = int(ev.get("depth") or 0)
            if depth > metrics["depth_max"]:
                metrics["depth_max"] = depth
        except Exception:
            continue
    metrics["iteration_count"] = len(edges)
    if edges:
        unique = len(set(edges))
        metrics["repetition_rate"] = round(1 - unique / len(edges), 4)

    ftf = hooks_dir / "post-tool-failure.jsonl"
    if ftf.exists():
        metrics["tool_failures"] = sum(1 for _ in ftf.read_text(encoding="utf-8").splitlines() if _.strip())
    pcf = hooks_dir / "pre-compact.jsonl"
    if pcf.exists():
        metrics["compactions"] = sum(1 for _ in pcf.read_text(encoding="utf-8").splitlines() if _.strip())

    return json.dumps(metrics, indent=2)


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
    if folder:
        path_error = _validate_artifacts_path(folder)
        if path_error:
            return path_error
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
    if folder:
        path_error = _validate_artifacts_path(folder)
        if path_error:
            return path_error
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


# ---------------------------------------------------------------------------
# MCP APPS UI ENDPOINTS (VS Code 1.113+) — Phase 4.2 graduate
# Thin UI layer: structured JSON envelopes consumed by VS Code's MCP Apps
# renderer. Business logic stays in the @mcp.tool functions above.
# See artifacts/decisions/ADR-mcp-apps-analytics-spike.md
# ---------------------------------------------------------------------------

# Severity thresholds for the budget card. Kept in sync with token-thresholds.json.
_BUDGET_SEVERITY_CAUTION = 0.75
_BUDGET_SEVERITY_WARNING = 0.90


def _delegation_row(session: dict) -> dict:
    """Project a session entry onto the UI table schema."""
    return {
        "agent": session.get("agent", "—"),
        "phase": session.get("phase", "—"),
        "status": session.get("status", "unknown"),
        "objective": (session.get("objective") or "")[:80],
        "modified": session.get("modified", ""),
        "size_bytes": session.get("size_bytes", 0),
    }


@mcp.resource("ui://delegations-table")
def ui_delegations_table() -> str:
    """
    MCP Apps UI envelope: recent delegations as a sortable table.

    Reuses list_sessions() for data. VS Code's MCP Apps renderer consumes the
    returned JSON and renders a table view in the chat panel.
    """
    try:
        payload = json.loads(list_sessions("all"))
    except (ValueError, TypeError) as e:
        return json.dumps({"error": f"Failed to load sessions: {e}"})

    rows = [_delegation_row(s) for s in payload.get("sessions", [])[:50]]
    return json.dumps({
        "ui": "table",
        "version": 1,
        "title": "Recent Delegations",
        "columns": [
            {"key": "agent",      "label": "Agent"},
            {"key": "phase",      "label": "Phase"},
            {"key": "status",     "label": "Status"},
            {"key": "objective",  "label": "Objective"},
            {"key": "modified",   "label": "Modified"},
            {"key": "size_bytes", "label": "Size", "align": "right"},
        ],
        "rows": rows,
        "empty_message": "No sessions recorded yet — run a delegation first.",
    }, indent=2)


@mcp.resource("ui://budget-card")
def ui_budget_card() -> str:
    """
    MCP Apps UI envelope: current token budget as a card.

    Reads artifacts/token-report.json and token-thresholds.json. Returns a
    card envelope with used/limit/percent plus a severity hint the UI maps
    to colour (ok / caution / warning / exceeded).
    """
    report_path = ARTIFACTS_DIR / "token-report.json"
    thresholds_path = REPO_ROOT / "token-thresholds.json"

    used = 0
    limit = 0
    files_over = 0
    try:
        if report_path.exists():
            report = json.loads(report_path.read_text(encoding="utf-8"))
            # token-report.json schema: {"totals": {...}, "files": [...]}
            totals = report.get("totals") or {}
            used = totals.get("tokens", 0) or sum(
                f.get("tokens", 0) for f in report.get("files", [])
            )
            files_over = sum(
                1 for f in report.get("files", []) if f.get("over_threshold")
            )
    except (ValueError, OSError):
        pass

    try:
        if thresholds_path.exists():
            thresholds = json.loads(thresholds_path.read_text(encoding="utf-8"))
            limit = thresholds.get("workspace_limit") or thresholds.get("total", 0)
    except (ValueError, OSError):
        pass

    percent = (used / limit) if limit > 0 else 0.0
    if percent >= 1.0:
        severity = "exceeded"
    elif percent >= _BUDGET_SEVERITY_WARNING:
        severity = "warning"
    elif percent >= _BUDGET_SEVERITY_CAUTION:
        severity = "caution"
    else:
        severity = "ok"

    return json.dumps({
        "ui": "card",
        "version": 1,
        "title": "Token Budget",
        "severity": severity,
        "metrics": [
            {"label": "Used",         "value": used,                  "format": "number"},
            {"label": "Limit",        "value": limit,                 "format": "number"},
            {"label": "Utilization",  "value": round(percent * 100, 1), "format": "percent"},
            {"label": "Files over",   "value": files_over,            "format": "number"},
        ],
        "source": "artifacts/token-report.json",
    }, indent=2)

if __name__ == "__main__":
    mcp.run()

"""
Research MCP Server — Web search via DuckDuckGo for agent research workflows.

Provides a single tool that wraps the DuckDuckGo search API and returns
structured JSON results for use by the researcher agent.

Usage:
    python scripts/mcp/research_server.py

Requires:
    pip install mcp ddgs
"""

from mcp.server.fastmcp import FastMCP
from mcp.types import ToolAnnotations
from ddgs import DDGS
import json

mcp = FastMCP("research-server")

_MAX_RESULTS_LIMIT = 10
_MAX_OUTPUT_CHARS = 8000


@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,
        destructiveHint=False,
        idempotentHint=False,
        openWorldHint=True,
    ),
)
def web_search(query: str, max_results: int = 5) -> str:
    """
    Search the web for a given query using DuckDuckGo.
    Returns a JSON string of results containing title, href, and body.

    Args:
        query: The search query string.
        max_results: Maximum number of results to return (default 5, max 10).
    """
    try:
        results = DDGS().text(query, max_results=min(max_results, _MAX_RESULTS_LIMIT))
        output = json.dumps(results, indent=2)
        if len(output) > _MAX_OUTPUT_CHARS:
            output = output[:_MAX_OUTPUT_CHARS] + "\n... (truncated)"
        return output
    except Exception as e:
        return json.dumps({"error": str(e)})

if __name__ == "__main__":
    mcp.run()

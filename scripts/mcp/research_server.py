from mcp.server.fastmcp import FastMCP
from duckduckgo_search import DDGS
import json

mcp = FastMCP("research-server")

@mcp.tool()
def web_search(query: str, max_results: int = 5) -> str:
    """
    Search the web for a given query using DuckDuckGo.
    Returns a JSON string of results containing title, href, and body.
    """
    try:
        results = DDGS().text(query, max_results=max_results)
        return json.dumps(results, indent=2)
    except Exception as e:
        return json.dumps({"error": str(e)})

if __name__ == "__main__":
    mcp.run()

# MCP Servers — scripts/mcp/

Five Python MCP servers that expose tool capabilities to agents via the Model Context Protocol. All servers use [FastMCP](https://github.com/jlowin/fastmcp) and are configured in `.vscode/mcp.json`.

## Servers

| Server | File | Tools exposed | Used by agents |
|--------|------|---------------|----------------|
| `validation` | `validation_server.py` | Run PS validation scripts, lint checks | `implementer`, `test` |
| `research` | `research_server.py` | Web search via DuckDuckGo (ddgs) | `researcher` |
| `analytics` | `analytics_server.py` | Session metrics, token usage | `conductor`, `ops` |
| `translation` | `translation_server.py` | Code translation validation, confidence scoring | `translator`, `translation-conductor`, `translation-analyzer`, `translation-validator`, `translation-styler` |
| `design` | `design_server.py` | Diagram helpers, design artifact generation | `ux` |

The `context7` server (live library docs) is hosted externally at `https://mcp.context7.com/mcp` and requires no local file.

The `github` server (GitHub API) is hosted at `https://api.githubcopilot.com/mcp/` (OAuth) and requires no local file.

## VS Code Configuration

All servers are declared in `.vscode/mcp.json`. Agents reference which servers they can use via the `mcp-servers:` frontmatter key in their `.agent.md` file:

```yaml
mcp-servers: [validation, context7]
```

VS Code automatically starts declared servers as stdio processes when an agent session begins.

## Running a Server Manually

```bash
# Activate the virtual environment first
.venv\Scripts\Activate.ps1   # Windows
source .venv/bin/activate      # macOS/Linux

# Run a server directly (for debugging)
python scripts/mcp/validation_server.py
```

## Adding a New Server

1. Create `scripts/mcp/<name>_server.py` following the FastMCP pattern in existing files.
2. Add the server entry to `.vscode/mcp.json` under `"servers"`.
3. Add `mcp-servers: [<name>]` to any agent frontmatter that should access it.
4. Test with `python scripts/mcp/<name>_server.py` and verify tools appear in VS Code MCP panel.

## Dependencies

All servers require Python 3.11+ and the packages in `requirements.txt` (or `pyproject.toml`). Install via:

```bash
pip install -e .
```

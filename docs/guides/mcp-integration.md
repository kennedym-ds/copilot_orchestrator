# MCP Server Integration Guide

Status: Active | Last Updated: 2026-02-09

## Overview

The copilot orchestrator uses the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) to connect specialized agents to external tools and services. MCP servers run as stdio subprocesses spawned by VS Code when an agent with `mcp-servers` frontmatter is activated.

## Active MCP Servers

| Server | File | Agent(s) | Tools | Purpose |
|--------|------|----------|-------|---------|
| github | `scripts/mcp/github_server.py` | github-ops | 14 tools | Issue, PR, workflow, release management |
| research | `scripts/mcp/research_server.py` | researcher, data-analytics | `web-search` | DuckDuckGo web search |
| design | `scripts/mcp/design_server.py` | design | `get_brand_palette`, `search_components`, `check_contrast` | Design system queries |

## Prerequisites

All MCP servers require:
- Python 3.10+ with `mcp[cli]` package installed
- Listed in the agent's `mcp-servers:` frontmatter block

The GitHub server additionally requires:
- [GitHub CLI (`gh`)](https://cli.github.com/) installed and authenticated (`gh auth login`)

Install dependencies:
```bash
pip install -r requirements.txt
```

## Architecture

```
VS Code Agent Session
  └── Agent activated (e.g., github-ops)
       └── VS Code reads mcp-servers frontmatter
            └── Spawns: python scripts/mcp/github_server.py
                 └── MCP stdio server running with 14 tools
                      └── Agent can call: list_issues, view_pr, merge_pr, etc.
```

### Communication Protocol

1. VS Code spawns the MCP server subprocess using the `command` and `args` from frontmatter
2. Server communicates over stdin/stdout using JSON-RPC 2.0 (MCP wire protocol)
3. Tools declared in the `tools:` allowlist are exposed to the agent
4. Agent invokes tools as function calls during conversation
5. Server executes the operation and returns structured results

## Agent Frontmatter Pattern

```yaml
mcp-servers:
  server-name:
    type: stdio
    command: python
    args: ["scripts/mcp/server_file.py"]
    tools: ["tool_a", "tool_b"]  # Allowlist — only these tools are exposed
```

**Key rules:**
- Use **object format** (not array). The validation script will error on array format.
- Include `type: stdio` for local servers.
- Scope `tools:` to only the operations the agent needs (principle of least privilege).

## GitHub MCP Server Tools

The `github_server.py` provides 14 tools organized by domain:

### Issues
| Tool | Description |
|------|-------------|
| `list_issues` | List issues by state and labels |
| `view_issue` | Get full issue details with comments |
| `create_issue` | Create a new issue |
| `close_issue` | Close an issue with reason |
| `comment_issue` | Add a comment to an issue |

### Pull Requests
| Tool | Description |
|------|-------------|
| `list_prs` | List PRs by state |
| `view_pr` | Get full PR details with files and reviews |
| `pr_checks` | View CI check status |
| `merge_pr` | Merge a PR (squash/merge/rebase) |

### Workflows
| Tool | Description |
|------|-------------|
| `list_runs` | List recent workflow runs |
| `view_run` | Get run details and job output |
| `run_failed_logs` | Get failure logs from failed jobs |

### Releases
| Tool | Description |
|------|-------------|
| `list_releases` | List recent releases |
| `create_release` | Create a new release with notes |

## Adding a New MCP Server

1. Create `scripts/mcp/your_server.py` using the FastMCP pattern:
   ```python
   from mcp.server.fastmcp import FastMCP

   mcp = FastMCP("your-server-name")

   @mcp.tool()
   def your_tool(param: str) -> str:
       """Tool description for the AI agent."""
       return "result"

   if __name__ == "__main__":
       mcp.run()
   ```

2. Add `mcp-servers:` block to the agent's frontmatter (object format, stdio type)

3. Run validation:
   ```powershell
   powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
   ```

4. Test the server standalone:
   ```bash
   python scripts/mcp/your_server.py
   # Then send MCP initialize message on stdin
   ```

## Testing

Run the MCP handshake test:
```bash
python scripts/test_mcp_handshake.py
```

This verifies all MCP servers can start and respond to the `initialize` handshake.

## Security Considerations

- MCP servers run with the same permissions as the VS Code process
- The `tools:` allowlist limits which tools an agent can invoke
- Agents with `user-invokable: false` (security, performance, observability, red-team) are only reachable via `#runSubagent`, reducing attack surface
- Never store secrets in MCP server code — use environment variables
- The GitHub server delegates to `gh` CLI which handles authentication separately

## Future Candidates

| Server | Agent | Tools | Status |
|--------|-------|-------|--------|
| terraform | terraform | `plan`, `validate`, `state-list` | Planned |
| bicep | bicep | `build`, `lint`, `what-if` | Planned |
| observability | observability | `query-metrics`, `list-alerts` | Backlog |

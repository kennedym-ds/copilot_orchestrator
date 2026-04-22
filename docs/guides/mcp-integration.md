# MCP Server Integration Guide

Status: Active | Last Updated: 2026-02-17

## Overview

The copilot orchestrator uses the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) to connect specialized agents to external tools and services. MCP servers are configured at two levels:

1. **Workspace-level** (`.vscode/mcp.json`) — shared across all agents, auto-discovered by VS Code
2. **Agent-level** (`mcp-servers:` frontmatter) — scoped tool allowlists per agent (principle of least privilege)

Servers run as either:
- **stdio subprocesses** — local Python servers spawned by VS Code
- **HTTP remote servers** — hosted endpoints authenticated via OAuth (e.g., GitHub's remote MCP)

## Active MCP Servers

| Server | File / URL | Type | Agent(s) | Tools | Purpose |
|--------|-----------|------|----------|-------|---------|
| github | `https://api.githubcopilot.com/mcp/` | HTTP | github-ops, maintainer, security, deployment | ~40+ (GitHub-managed) | Issue, PR, workflow, release, code security |
| research | `scripts/mcp/research_server.py` | stdio | researcher | 1 (`web_search`) | DuckDuckGo web search |
| design | `scripts/mcp/design_server.py` | stdio | design | 3 | Design system queries |
| translation | `scripts/mcp/translation_server.py` | stdio | translation-conductor | 9 | Code translation workflow |
| validation | `scripts/mcp/validation_server.py` | stdio | conductor, implementer, reviewer, test, lint, observability | 5 tools + 6 resources + 3 prompts | PowerShell validation wrappers |
| analytics | `scripts/mcp/analytics_server.py` | stdio | conductor, observability | 5 tools + 4 resources + 2 prompts | Session and artifact analytics |

**Coverage:** 14 of 29 agents have MCP capability.

## Workspace Configuration (`.vscode/mcp.json`)

The workspace-level configuration file registers all MCP servers in one place. VS Code auto-discovers these servers and makes their tools available in the tool picker.

```json
{
  "servers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    },
    "research": {
      "type": "stdio",
      "command": "python",
      "args": ["${workspaceFolder}/scripts/mcp/research_server.py"]
    }
  }
}
```

**Key rules:**
- Use `${workspaceFolder}` for portable paths — commit to source control
- Use camelCase for server names (VS Code convention)
- Use `"type": "http"` for remote servers, `"type": "stdio"` for local
- Add `"dev": {"watch": "scripts/mcp/server.py"}` for auto-restart during development

### Remote vs Local GitHub MCP

The **remote** GitHub MCP server (`https://api.githubcopilot.com/mcp/`) is the primary integration:
- OAuth authentication — no PAT management
- Automatic updates — new tools added by GitHub are instantly available
- Additional toolsets: repos, issues, pull_requests, code_security, actions, experiments
- Read-only mode: add `"headers": {"X-MCP-Readonly": "true"}`
- Selective toolsets: add `"headers": {"X-GitHub-Toolsets": "issues,pull_requests"}`

Install the remote server: Open Command Palette → `GitHub MCP: Install Remote Server`

## Prerequisites

All local MCP servers require:
- Python 3.10+ with `mcp[cli]` package installed
- Listed in `.vscode/mcp.json` or the agent's `mcp-servers:` frontmatter block

Install dependencies:
```bash
pip install -r requirements.txt
```

The remote GitHub MCP server requires:
- GitHub Copilot subscription (Copilot Pro+ or Enterprise)
- Network access to `https://api.githubcopilot.com`

## Architecture

```
VS Code Agent Session
  ├── Workspace MCP (.vscode/mcp.json)
  │    ├── github (HTTP) → api.githubcopilot.com/mcp/
  │    ├── research (stdio) → research_server.py
  │    ├── design (stdio) → design_server.py
  │    ├── translation (stdio) → translation_server.py
  │    ├── validation (stdio) → validation_server.py
  │    └── analytics (stdio) → analytics_server.py
  │
  └── Agent activated (e.g., implementer)
       └── VS Code reads mcp-servers: frontmatter
            └── Exposes only allowlisted tools:
                 validation: [validate_assets, run_lint, run_smoke_tests]
```

### Communication Protocol

1. VS Code reads `.vscode/mcp.json` and agent `mcp-servers:` frontmatter
2. For stdio servers: spawns subprocess, communicates via stdin/stdout JSON-RPC 2.0
3. For HTTP servers: connects to URL, authenticates via OAuth
4. Tools declared in the `tools:` allowlist are exposed to the agent
5. Agent invokes tools as function calls during conversation
6. Server executes the operation and returns structured results

### Tool Layering

```
Layer 1: VS Code Built-in Tools (readFile, edit, search, runCommands)
    → Available to ALL agents via tools: frontmatter

Layer 2: Workspace MCP Servers (.vscode/mcp.json)
    → Shared across all agents, browsable in tool picker

Layer 3: Agent-Scoped MCP (mcp-servers: frontmatter)
    → Per-agent tool allowlists, principle of least privilege

Layer 4: Remote MCP Servers (type: http)
    → Zero local infrastructure, OAuth authentication
```

## Agent Frontmatter Pattern

### Local (stdio) Server
```yaml
mcp-servers:
  validation:
    type: stdio
    command: python
    args: ["scripts/mcp/validation_server.py"]
    tools: ["validate_assets", "run_lint"]  # Allowlist
```

### Remote (HTTP) Server
```yaml
mcp-servers:
  github:
    type: http
    url: "https://api.githubcopilot.com/mcp/"
```

**Key rules:**
- Use **object format** (not array). The validation script will error on array format.
- Include `type: stdio` or `type: http`.
- Scope `tools:` to only the operations the agent needs (principle of least privilege).
- Remote HTTP servers auto-manage their tool catalog — no allowlist needed.

## Validation MCP Server Tools

The `validation_server.py` wraps PowerShell validation scripts as structured MCP tools:

| Tool | Wraps | Description |
|------|-------|-------------|
| `validate_assets` | `validate-copilot-assets.ps1` | Check all agents, prompts, instructions for schema compliance |
| `check_metadata` | `add-prompt-metadata.ps1 -CheckOnly` | Verify prompt frontmatter completeness |
| `run_lint` | `run-lint.ps1` | Check code style and formatting |
| `run_smoke_tests` | `run-smoke-tests.ps1` | Run the smoke test suite |
| `token_report` | `token-report.ps1` | Generate token budget report |

### MCP Resources (VS Code 1.109+)

Resources expose repository knowledge as queryable context — agents can pull these without reading files:

| URI | Content |
|-----|---------|
| `templates://plan` | Standard plan template |
| `templates://phase-complete` | Phase completion template |
| `templates://plan-complete` | Plan completion template |
| `instructions://behavior` | Zen of Engineering tenets |
| `instructions://security` | Security baseline |
| `instructions://model-selection` | Model allocation tiers |

### MCP Prompts (VS Code 1.109+)

Reusable prompt templates invokable via `/mcp.validation.*` in chat:

| Prompt | Purpose |
|--------|---------|
| `validate-and-report` | Full validation workflow with summary |
| `tdd-cycle` | TDD implementation workflow |
| `severity-review` | Severity-tagged code review |

## Analytics MCP Server Tools

The `analytics_server.py` provides structured access to session data and workflow metrics:

| Tool | Description |
|------|-------------|
| `list_sessions` | List session files from artifacts/sessions/ |
| `get_session` | Read a specific session JSON |
| `get_metrics` | Parse token report data |
| `list_artifacts` | Browse artifacts/ folder contents |
| `search_artifacts` | Search artifact files by content |

### Resources
| URI | Content |
|-----|---------|
| `routing://delegation-table` | Agent delegation routing table |
| `roster://agents` | Full agent roster from AGENTS.md |
| `config://token-thresholds` | Token budget thresholds |
| `config://operations` | Operations playbook |

### Prompts
| Prompt | Purpose |
|--------|---------|
| `workflow-analysis` | Analyze session patterns and metrics |
| `cost-optimization` | Evaluate token usage and model costs |

### MCP Apps UI Endpoints (VS Code 1.113+)

Two resource URIs return structured JSON envelopes that VS Code's MCP Apps renderer displays as cards or tables in the chat panel. See [ADR-mcp-apps-analytics-spike](../../artifacts/decisions/ADR-mcp-apps-analytics-spike.md).

| URI | Kind | Purpose |
|-----|------|---------|
| `ui://delegations-table` | table | Sortable list of recent delegations (agent, phase, status, objective) |
| `ui://budget-card` | card | Token budget summary with severity hint (ok / caution / warning / exceeded) |

Envelopes follow a stable shape:

```json
{"ui": "table" | "card", "version": 1, "title": "...", "...": "..."}
```

Business logic stays in the `@mcp.tool` functions — the UI resources are thin projections and degrade gracefully when token data is absent.

## Adding a New MCP Server

1. Create `scripts/mcp/your_server.py` using the FastMCP pattern:
   ```python
   from mcp.server.fastmcp import FastMCP

   mcp = FastMCP("your-server-name")

   @mcp.tool()
   def your_tool(param: str) -> str:
       """Tool description for the AI agent."""
       return "result"

   # Optional: MCP Resources (VS Code 1.109+)
   @mcp.resource("your://resource-name")
   def your_resource() -> str:
       """Expose data as queryable context."""
       return "resource content"

   # Optional: MCP Prompts (VS Code 1.109+)
   @mcp.prompt("your-prompt")
   def your_prompt() -> str:
       """Reusable prompt template invokable via /mcp.server.prompt."""
       return "prompt instructions"

   if __name__ == "__main__":
       mcp.run()
   ```

2. Register in `.vscode/mcp.json`:
   ```json
   {
     "servers": {
       "yourServer": {
         "type": "stdio",
         "command": "python",
         "args": ["${workspaceFolder}/scripts/mcp/your_server.py"],
         "dev": {"watch": "scripts/mcp/your_server.py"}
       }
     }
   }
   ```

3. Add `mcp-servers:` block to the agent's frontmatter with tool allowlist

4. Run validation:
   ```powershell
   powershell -File scripts/validate-copilot-assets.ps1 -RepositoryRoot .
   ```

5. Test the server standalone:
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

Run unit tests:
```bash
python -m pytest tests/mcp/ -v
```

## Security Considerations

- MCP servers run with the same permissions as the VS Code process
- The `tools:` allowlist limits which tools an agent can invoke
- Remote HTTP servers use OAuth — no PATs or tokens stored locally
- Agents with `user-invokable: false` (security, performance, observability, red-team) are only reachable via `#runSubagent`, reducing attack surface
- Never store secrets in MCP server code — use `${input:variable}` in `.vscode/mcp.json` or environment variables
- Follow the `COPILOT_MCP_` naming convention for MCP-related secrets
- The 128-tool limit per chat request is enforced by VS Code — use frontmatter allowlists to stay well under

## MCP Development Mode

Enable auto-restart and debugging for MCP servers during development:

```json
{
  "servers": {
    "myServer": {
      "type": "stdio",
      "command": "python",
      "args": ["scripts/mcp/server.py"],
      "dev": {
        "watch": "scripts/mcp/**/*.py",
        "debug": true
      }
    }
  }
}
```

Debug Python servers: VS Code auto-attaches the debugger when `"debug": true` is set.

## Future Candidates

| Server | Agent | Tools | Status |
|--------|-------|-------|--------|
| terraform | terraform | `plan`, `validate`, `state-list` | Planned |
| bicep | bicep | `build`, `lint`, `what-if` | Planned |

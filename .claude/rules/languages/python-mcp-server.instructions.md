---
paths:
  - "**/*.py"
---

---
description: "Python MCP (Model Context Protocol) server implementation patterns using FastMCP."
applyTo: "**/mcp/**/*.py,**/*mcp*.py"
---

## Overview

Guardrails for implementing MCP servers in Python using the FastMCP high-level
API. MCP servers expose tools, resources, and prompts to AI assistants through
a standardized protocol (JSON-RPC 2.0 over stdio or HTTP).

All servers in this repository use `mcp.server.fastmcp.FastMCP`. Do not use
the low-level `mcp.server.Server` class unless you need custom protocol
handling.

## Guiding Principles

- One tool, one job. Each tool performs a single operation.
- Explicit inputs and outputs. Use type annotations and docstrings.
- Graceful errors. Return informative messages the AI can act on.
- Minimal state. Prefer stateless operations.

## Server Setup

```python
from mcp.server.fastmcp import FastMCP

mcp = FastMCP("my-server-name")

# Register tools, resources, and prompts via decorators (see below)

if __name__ == "__main__":
    mcp.run()
```

Register in `.vscode/mcp.json`:
```json
{
  "servers": {
    "myServer": {
      "type": "stdio",
      "command": "${workspaceFolder}/.venv/Scripts/python.exe",
      "args": ["${workspaceFolder}/scripts/mcp/my_server.py"]
    }
  }
}
```

## Tool Implementation

Use the `@mcp.tool()` decorator. FastMCP derives the JSON schema from
type annotations and the docstring.

```python
import json

@mcp.tool()
def search_codebase(query: str, file_type: str = "") -> str:
    """Search for patterns in the codebase.

    Args:
        query: Search pattern (regex supported).
        file_type: File extension filter (e.g., ".py").
    """
    results = perform_search(query, file_type)
    return json.dumps({"matches": results, "count": len(results)})
```

### Tool Annotations (MCP 2025-11-25)

Annotations tell VS Code about a tool's behavior for auto-approval and
risk display:

```python
from mcp.types import ToolAnnotations

@mcp.tool(
    annotations=ToolAnnotations(
        readOnlyHint=True,       # No side effects — auto-approve eligible
        destructiveHint=False,   # Does not delete or overwrite data
        idempotentHint=True,     # Same input → same output
        openWorldHint=False,     # No network or external access
    ),
)
def list_agents() -> str:
    """List all agent files."""
    ...
```

### Async Tools with Context

Use `Context` for progress reporting, logging, and elicitation:

```python
from mcp.server.fastmcp import Context

@mcp.tool()
async def scan_files(folder: str, ctx: Context) -> str:
    """Scan files with progress reporting."""
    files = list(Path(folder).rglob("*.md"))
    for i, f in enumerate(files):
        await ctx.report_progress(progress=i, total=len(files), message=f.name)
        # process file...
    await ctx.log("info", f"Scanned {len(files)} files")
    return json.dumps({"scanned": len(files)})
```

### Structured Output

Return a Pydantic model instead of a string when the AI needs typed data:

```python
from pydantic import BaseModel

class ScanResult(BaseModel):
    files_scanned: int
    total_lines: int

@mcp.tool(structured_output=True)
def scan_structured() -> ScanResult:
    """Returns typed data instead of a string."""
    return ScanResult(files_scanned=42, total_lines=1500)
```

## Resource Implementation

Resources expose data the AI can query without reading files.

```python
@mcp.resource("config://settings")
def get_settings() -> str:
    """Current configuration values."""
    return json.dumps(get_current_settings())
```

### Resource Annotations

Control visibility with audience and priority:

```python
from mcp.types import Annotations

@mcp.resource(
    "docs://architecture",
    annotations=Annotations(
        audience=["user"],       # Show in UI, not just fed to model
        priority=1.0,            # High priority (0.0–1.0)
    ),
)
def get_architecture() -> str:
    """Architecture overview diagram."""
    return "..."
```

## Prompt Templates

Prompts appear in VS Code's prompt picker (`/mcp.server-name.prompt-name`):

```python
@mcp.prompt("analyze-code")
def analyze_code_prompt(file_path: str) -> str:
    """Analyze code for quality and security issues."""
    return f"Review {file_path} for correctness, security, and style issues."
```

## Elicitation

Servers can ask the user questions mid-execution:

```python
from pydantic import BaseModel, Field

class Confirmation(BaseModel):
    environment: str = Field(json_schema_extra={"enum": ["staging", "production"]})
    reason: str = ""

@mcp.tool()
async def deploy(service: str, ctx: Context) -> str:
    """Deploy with user confirmation."""
    result = await ctx.elicit(
        message=f"Confirm deployment for {service}:",
        schema=Confirmation,
    )
    if result.action == "cancel":
        return json.dumps({"status": "cancelled"})
    return json.dumps({"deployed": service, "env": result.data.environment})
```

## Error Handling

Return structured errors the AI can interpret. Never expose secrets.

```python
import logging

logger = logging.getLogger(__name__)

@mcp.tool()
def risky_operation(path: str) -> str:
    """Operation that might fail."""
    try:
        result = do_work(path)
        return json.dumps({"success": True, "result": result})
    except FileNotFoundError:
        return json.dumps({"success": False, "error": f"File not found: {path}"})
    except Exception as e:
        logger.error(f"risky_operation failed: {e}", exc_info=True)
        return json.dumps({"success": False, "error": str(e)})
```

## Testing

Mock FastMCP so tests run without `mcp[cli]` installed:

```python
import unittest
from unittest.mock import MagicMock

# Mock before import
mock_fastmcp = MagicMock()
sys.modules["mcp"] = MagicMock()
sys.modules["mcp.server"] = MagicMock()
sys.modules["mcp.server.fastmcp"] = mock_fastmcp

def passthrough(*args, **kwargs):
    def decorator(func): return func
    return decorator

mock_instance = MagicMock()
mock_instance.tool.side_effect = passthrough
mock_instance.resource.side_effect = passthrough
mock_instance.prompt.side_effect = passthrough
mock_fastmcp.FastMCP.return_value = mock_instance

import scripts.mcp.my_server as server

class TestMyServer(unittest.TestCase):
    def test_my_tool(self):
        result = json.loads(server.my_tool("input"))
        self.assertTrue(result["success"])
```

## Security Considerations

- Validate all input parameters before processing.
- Sanitize file paths to prevent directory traversal.
- Limit resource access to intended directories.
- Never execute arbitrary code from tool inputs.
- Use `${workspaceFolder}/.venv/Scripts/python.exe` in `.vscode/mcp.json`
  to ensure the correct environment.
- Use `tools:` allowlists in agent frontmatter to scope access.

## Performance Guidance

- Use async I/O for file and network operations.
- Set timeouts for subprocess calls (`subprocess.run(timeout=120)`).
- Truncate large outputs to avoid blowing up context windows.
- Servers idle at ~0% CPU when waiting for input — no polling overhead.

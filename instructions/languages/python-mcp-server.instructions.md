---
description: "Python MCP (Model Context Protocol) server implementation patterns."
applyTo: "**/mcp/**/*.py,**/*mcp*.py"
---

## Overview

This instruction file provides guardrails for implementing MCP (Model Context
Protocol) servers in Python. MCP servers expose tools, resources, and prompts
to AI assistants through a standardized protocol.

## Guiding Principles

- Design tools with clear, focused responsibilities. Each tool should perform
  one well-defined operation.
- Make tool inputs and outputs explicit. Use structured schemas for parameters
  and return values.
- Handle errors gracefully. Return informative error messages that help the
  AI assistant understand what went wrong.
- Keep server state minimal. Prefer stateless operations when possible.

## Server Setup

```python
from mcp.server import Server
from mcp.server.stdio import stdio_server
import asyncio

# Create server instance with descriptive name
server = Server("my-mcp-server")

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream)

if __name__ == "__main__":
    asyncio.run(main())
```

## Tool Implementation

- Use the `@server.tool()` decorator to register tools.
- Provide clear descriptions for tools and their parameters.
- Use Pydantic models or dataclasses for structured input validation.
- Return structured responses with consistent formatting.

```python
from mcp.types import Tool, TextContent

@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="search_codebase",
            description="Search for patterns in the codebase",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "Search pattern"},
                    "file_type": {"type": "string", "description": "File extension filter"}
                },
                "required": ["query"]
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    if name == "search_codebase":
        results = await perform_search(arguments["query"], arguments.get("file_type"))
        return [TextContent(type="text", text=format_results(results))]
    raise ValueError(f"Unknown tool: {name}")
```

## Resource Implementation

- Expose resources for data that the AI assistant may need to read.
- Use URI schemes that clearly identify resource types.
- Implement proper pagination for large datasets.

```python
from mcp.types import Resource

@server.list_resources()
async def list_resources() -> list[Resource]:
    return [
        Resource(
            uri="config://settings",
            name="Application Settings",
            description="Current configuration values",
            mimeType="application/json"
        )
    ]

@server.read_resource()
async def read_resource(uri: str) -> str:
    if uri == "config://settings":
        return json.dumps(get_current_settings())
    raise ValueError(f"Unknown resource: {uri}")
```

## Prompt Templates

- Define prompt templates for common operations.
- Include clear instructions and context in prompt descriptions.
- Use parameter placeholders for dynamic content.

```python
from mcp.types import Prompt, PromptMessage

@server.list_prompts()
async def list_prompts() -> list[Prompt]:
    return [
        Prompt(
            name="analyze_code",
            description="Analyze code for quality and security issues",
            arguments=[
                {"name": "file_path", "description": "Path to analyze", "required": True}
            ]
        )
    ]

@server.get_prompt()
async def get_prompt(name: str, arguments: dict) -> list[PromptMessage]:
    if name == "analyze_code":
        code = read_file(arguments["file_path"])
        return [
            PromptMessage(role="user", content=f"Analyze this code:\n\n{code}")
        ]
    raise ValueError(f"Unknown prompt: {name}")
```

## Error Handling

- Return structured error responses that the AI assistant can interpret.
- Log errors with sufficient context for debugging.
- Never expose sensitive information in error messages.

```python
import logging

logger = logging.getLogger(__name__)

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    try:
        # Tool implementation
        pass
    except ValidationError as e:
        logger.warning(f"Validation error in {name}: {e}")
        return [TextContent(type="text", text=f"Invalid input: {e.message}")]
    except Exception as e:
        logger.error(f"Error in {name}: {e}", exc_info=True)
        return [TextContent(type="text", text=f"Operation failed: {type(e).__name__}")]
```

## Testing

- Write unit tests for each tool, resource, and prompt handler.
- Test error handling paths explicitly.
- Use async test fixtures for testing async handlers.

```python
import pytest

@pytest.mark.asyncio
async def test_search_tool():
    result = await call_tool("search_codebase", {"query": "def main"})
    assert len(result) == 1
    assert "main" in result[0].text
```

## Security Considerations

- Validate all input parameters before processing.
- Sanitize file paths to prevent directory traversal attacks.
- Limit resource access to intended directories.
- Never execute arbitrary code from tool inputs.
- Log tool invocations for audit purposes.

## Performance Guidance

- Use async I/O for file and network operations.
- Implement timeouts for long-running operations.
- Cache expensive computations when appropriate.
- Stream large responses instead of loading entirely into memory.

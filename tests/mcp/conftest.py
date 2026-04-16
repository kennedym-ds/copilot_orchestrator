"""Shared MCP mock setup for all MCP server tests.

Installs sys.modules mocks once before any test module imports the MCP library.
All test files can then import their target server module and get passthrough
decorators for @mcp.tool(), @mcp.resource(), and @mcp.prompt().
"""
import sys
import os
from unittest.mock import MagicMock


def _passthrough_decorator_factory(*args, **kwargs):
    """Return a decorator that passes through the original function unchanged."""
    def decorator(func):
        return func
    return decorator


# Install mocks into sys.modules ONCE at conftest import time.
# This happens before any test file's module-level code runs.
_mock_fastmcp_module = MagicMock()
_mock_mcp_instance = MagicMock()
_mock_mcp_instance.tool.side_effect = _passthrough_decorator_factory
_mock_mcp_instance.resource.side_effect = _passthrough_decorator_factory
_mock_mcp_instance.prompt.side_effect = _passthrough_decorator_factory
_mock_fastmcp_module.FastMCP.return_value = _mock_mcp_instance

sys.modules["mcp"] = MagicMock()
sys.modules["mcp.server"] = MagicMock()
sys.modules["mcp.server.fastmcp"] = _mock_fastmcp_module
sys.modules["mcp.types"] = MagicMock()
sys.modules["duckduckgo_search"] = MagicMock()

# Ensure repo root is on sys.path for `import scripts.mcp.*`
_repo_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "../../"))
if _repo_root not in sys.path:
    sys.path.insert(0, _repo_root)

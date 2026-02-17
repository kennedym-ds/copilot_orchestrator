import unittest
import sys
import os
import json
from unittest.mock import MagicMock

# Mock the mcp library since it might not be installed in the CI/Test env yet
# Configure mock so that @mcp.tool(), @mcp.resource(), @mcp.prompt() act as passthrough decorators

mock_fastmcp_module = MagicMock()
sys.modules["mcp"] = MagicMock()
sys.modules["mcp.server"] = MagicMock()
sys.modules["mcp.server.fastmcp"] = mock_fastmcp_module


def passthrough_decorator_factory(*args, **kwargs):
    def decorator(func):
        return func
    return decorator


mock_mcp_instance = MagicMock()
mock_mcp_instance.tool.side_effect = passthrough_decorator_factory
mock_mcp_instance.resource.side_effect = passthrough_decorator_factory
mock_mcp_instance.prompt.side_effect = passthrough_decorator_factory
mock_fastmcp_module.FastMCP.return_value = mock_mcp_instance

# Add the repository root to sys.path
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), "../../")))


class TestAnalyticsServer(unittest.TestCase):
    def setUp(self):
        if "scripts.mcp.analytics_server" in sys.modules:
            del sys.modules["scripts.mcp.analytics_server"]
        try:
            import scripts.mcp.analytics_server as ans
            self.ans = ans
        except ImportError:
            self.ans = None

    def test_module_exists(self):
        """Verify the analytics_server module exists."""
        if self.ans is None:
            self.fail("scripts.mcp.analytics_server module not found.")

    def test_repo_root_resolved(self):
        """Verify REPO_ROOT points to a directory containing artifacts/."""
        if self.ans is None:
            self.skipTest("Module missing")
        self.assertTrue(self.ans.REPO_ROOT.exists(), "REPO_ROOT should exist")
        self.assertTrue(
            (self.ans.REPO_ROOT / "artifacts").exists(),
            "REPO_ROOT should contain an artifacts/ folder",
        )

    def test_list_sessions_empty(self):
        """Verify list_sessions returns valid JSON when no sessions exist."""
        if self.ans is None:
            self.skipTest("Module missing")
        result = json.loads(self.ans.list_sessions("all"))
        self.assertIn("sessions", result)
        self.assertIn("count", result)
        self.assertIsInstance(result["sessions"], list)

    def test_get_session_missing_file(self):
        """Verify get_session handles non-existent session gracefully."""
        if self.ans is None:
            self.skipTest("Module missing")
        result = json.loads(self.ans.get_session("nonexistent-session"))
        self.assertIn("error", result)

    def test_get_metrics_returns_string(self):
        """Verify get_metrics returns a non-empty string."""
        if self.ans is None:
            self.skipTest("Module missing")
        result = self.ans.get_metrics()
        self.assertIsInstance(result, str)
        self.assertGreater(len(result), 0)

    def test_list_artifacts_returns_json(self):
        """Verify list_artifacts returns valid JSON with entries."""
        if self.ans is None:
            self.skipTest("Module missing")
        result = json.loads(self.ans.list_artifacts())
        self.assertIn("entries", result)
        self.assertIsInstance(result["entries"], list)

    def test_search_artifacts_empty_query(self):
        """Verify search_artifacts handles empty query gracefully."""
        if self.ans is None:
            self.skipTest("Module missing")
        result = json.loads(self.ans.search_artifacts("nonexistent_xyzzy_string"))
        self.assertIn("results", result)
        self.assertEqual(result["total_files"], 0)

    def test_safe_read_missing_file(self):
        """Verify _safe_read handles a missing file."""
        if self.ans is None:
            self.skipTest("Module missing")
        from pathlib import Path
        result = self.ans._safe_read(Path("/nonexistent/path/file.txt"))
        parsed = json.loads(result)
        self.assertIn("error", parsed)

    def test_resource_functions_return_strings(self):
        """Verify resource functions return non-empty strings."""
        if self.ans is None:
            self.skipTest("Module missing")
        for func_name in [
            "get_delegation_table",
            "get_agent_roster",
            "get_token_thresholds",
            "get_operations_config",
        ]:
            func = getattr(self.ans, func_name, None)
            if func is not None:
                result = func()
                self.assertIsInstance(result, str)
                self.assertGreater(len(result), 0, f"{func_name} should return content")

    def test_prompt_functions_return_strings(self):
        """Verify prompt functions return non-empty strings."""
        if self.ans is None:
            self.skipTest("Module missing")
        for func_name in [
            "workflow_analysis_prompt",
            "cost_optimization_prompt",
        ]:
            func = getattr(self.ans, func_name, None)
            if func is not None:
                result = func()
                self.assertIsInstance(result, str)
                self.assertGreater(len(result), 0, f"{func_name} should return content")


if __name__ == "__main__":
    unittest.main()

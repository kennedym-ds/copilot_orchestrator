import unittest
import sys
import os
import json

# MCP mocks are installed by conftest.py — no module-level mock setup needed here.


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
            "delegation_table",
            "agent_roster",
            "token_thresholds",
            "operations_doc",
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


    def test_ui_delegations_table_envelope(self):
        """Verify ui://delegations-table returns a well-formed table envelope."""
        if self.ans is None:
            self.skipTest("Module missing")
        payload = json.loads(self.ans.ui_delegations_table())
        self.assertEqual(payload.get("ui"), "table")
        self.assertEqual(payload.get("version"), 1)
        self.assertIn("columns", payload)
        self.assertIn("rows", payload)
        self.assertIsInstance(payload["columns"], list)
        self.assertIsInstance(payload["rows"], list)
        column_keys = {c["key"] for c in payload["columns"]}
        self.assertIn("agent", column_keys)
        self.assertIn("status", column_keys)

    def test_ui_budget_card_envelope(self):
        """Verify ui://budget-card returns a well-formed card envelope with a severity hint."""
        if self.ans is None:
            self.skipTest("Module missing")
        payload = json.loads(self.ans.ui_budget_card())
        self.assertEqual(payload.get("ui"), "card")
        self.assertEqual(payload.get("version"), 1)
        self.assertIn(payload.get("severity"), {"ok", "caution", "warning", "exceeded"})
        metric_labels = {m["label"] for m in payload.get("metrics", [])}
        self.assertIn("Used", metric_labels)
        self.assertIn("Limit", metric_labels)
        self.assertIn("Utilization", metric_labels)

if __name__ == "__main__":
    unittest.main()

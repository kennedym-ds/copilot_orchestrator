import unittest
import sys
import os
import json
from unittest.mock import MagicMock, patch

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


class TestValidationServer(unittest.TestCase):
    def setUp(self):
        if "scripts.mcp.validation_server" in sys.modules:
            del sys.modules["scripts.mcp.validation_server"]
        try:
            import scripts.mcp.validation_server as vs
            self.vs = vs
        except ImportError:
            self.vs = None

    def test_module_exists(self):
        """Verify the validation_server module exists."""
        if self.vs is None:
            self.fail("scripts.mcp.validation_server module not found.")

    def test_repo_root_resolved(self):
        """Verify REPO_ROOT points to a directory containing scripts/."""
        if self.vs is None:
            self.skipTest("Module missing")
        self.assertTrue(self.vs.REPO_ROOT.exists(), "REPO_ROOT should exist")
        self.assertTrue(
            (self.vs.REPO_ROOT / "scripts").exists(),
            "REPO_ROOT should contain a scripts/ folder",
        )

    @patch("scripts.mcp.validation_server.subprocess.run")
    def test_validate_assets_success(self, mock_run):
        """Verify validate_assets returns structured JSON on success."""
        if self.vs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(
            returncode=0,
            stdout="All assets valid\n",
            stderr="",
        )
        result = json.loads(self.vs.validate_assets("."))
        self.assertTrue(result["success"])
        self.assertEqual(result["exit_code"], 0)
        self.assertIn("valid", result["stdout"].lower())

    @patch("scripts.mcp.validation_server.subprocess.run")
    def test_validate_assets_failure(self, mock_run):
        """Verify validate_assets captures failures."""
        if self.vs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(
            returncode=1,
            stdout="2 errors found\n",
            stderr="ERROR: missing field",
        )
        result = json.loads(self.vs.validate_assets("."))
        self.assertFalse(result["success"])
        self.assertEqual(result["exit_code"], 1)

    @patch("scripts.mcp.validation_server.subprocess.run")
    def test_run_lint_returns_json(self, mock_run):
        """Verify run_lint returns structured JSON."""
        if self.vs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(
            returncode=0, stdout="Linting passed", stderr=""
        )
        result = json.loads(self.vs.run_lint("."))
        self.assertTrue(result["success"])

    @patch("scripts.mcp.validation_server.subprocess.run")
    def test_token_report_returns_json(self, mock_run):
        """Verify token_report returns structured JSON."""
        if self.vs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(
            returncode=0, stdout="Token report: budget OK", stderr=""
        )
        result = json.loads(self.vs.token_report("."))
        self.assertTrue(result["success"])

    def test_run_powershell_missing_script(self):
        """Verify _run_powershell handles missing script files gracefully."""
        if self.vs is None:
            self.skipTest("Module missing")
        result = self.vs._run_powershell("nonexistent-script.ps1")
        self.assertIn("error", result)
        self.assertEqual(result["exit_code"], -1)

    @patch("scripts.mcp.validation_server.subprocess.run")
    def test_run_powershell_timeout(self, mock_run):
        """Verify _run_powershell handles subprocess timeout."""
        if self.vs is None:
            self.skipTest("Module missing")
        import subprocess
        mock_run.side_effect = subprocess.TimeoutExpired(cmd="test", timeout=120)
        result = self.vs._run_powershell("validate-copilot-assets.ps1", timeout=120)
        self.assertIn("error", result)
        self.assertIn("timed out", result["error"])

    def test_resource_functions_return_strings(self):
        """Verify resource functions return non-empty strings."""
        if self.vs is None:
            self.skipTest("Module missing")
        # Resources should read files and return content
        for func_name in [
            "get_behavior_instructions",
            "get_security_instructions",
            "get_model_selection_instructions",
        ]:
            func = getattr(self.vs, func_name, None)
            if func is not None:
                result = func()
                self.assertIsInstance(result, str)
                self.assertGreater(len(result), 0, f"{func_name} should return content")

    def test_prompt_functions_return_strings(self):
        """Verify prompt functions return non-empty strings."""
        if self.vs is None:
            self.skipTest("Module missing")
        # validate_and_report has no required args
        func = getattr(self.vs, "validate_and_report_prompt", None)
        if func is not None:
            result = func()
            self.assertIsInstance(result, str)
            self.assertGreater(len(result), 0)
        # tdd_cycle_prompt requires file_path and feature
        func = getattr(self.vs, "tdd_cycle_prompt", None)
        if func is not None:
            result = func(file_path="src/example.py", feature="login")
            self.assertIsInstance(result, str)
            self.assertGreater(len(result), 0)
        # severity_review_prompt requires scope
        func = getattr(self.vs, "severity_review_prompt", None)
        if func is not None:
            import inspect
            sig = inspect.signature(func)
            kwargs = {}
            for p in sig.parameters:
                if p != "self":
                    kwargs[p] = "test_value"
            result = func(**kwargs)
            self.assertIsInstance(result, str)
            self.assertGreater(len(result), 0)


if __name__ == "__main__":
    unittest.main()

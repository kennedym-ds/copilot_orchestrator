import json
import subprocess
import sys
import unittest
from unittest.mock import MagicMock, patch

# MCP mocks are installed by conftest.py — no module-level mock setup needed here.


class TestGithubServer(unittest.TestCase):
    def setUp(self):
        if "scripts.mcp.github_server" in sys.modules:
            del sys.modules["scripts.mcp.github_server"]
        try:
            import scripts.mcp.github_server as gs
            self.gs = gs
        except ImportError:
            self.gs = None

    # ── Module smoke ─────────────────────────────────────────────────────────

    def test_module_exists(self):
        """Verify the github_server module can be imported."""
        if self.gs is None:
            self.fail("scripts.mcp.github_server module not found.")

    # ── _run_gh helper ────────────────────────────────────────────────────────

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_run_gh_success(self, mock_run):
        """_run_gh returns stdout on exit code 0."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="output\n", stderr="")
        result = self.gs._run_gh(["issue", "list"])
        self.assertEqual(result, "output")

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_run_gh_failure_returns_stderr(self, mock_run):
        """_run_gh returns stderr when exit code is non-zero."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=1, stdout="", stderr="not authenticated")
        result = self.gs._run_gh(["issue", "list"])
        self.assertIn("not authenticated", result)

    def test_run_gh_no_cli(self):
        """_run_gh returns an error string when gh is not on PATH."""
        if self.gs is None:
            self.skipTest("Module missing")
        with patch("scripts.mcp.github_server.subprocess.run",
                   side_effect=FileNotFoundError):
            result = self.gs._run_gh(["issue", "list"])
        self.assertIn("not installed", result)

    def test_run_gh_timeout(self):
        """_run_gh returns an error string on subprocess timeout."""
        if self.gs is None:
            self.skipTest("Module missing")
        with patch("scripts.mcp.github_server.subprocess.run",
                   side_effect=subprocess.TimeoutExpired(cmd="gh", timeout=30)):
            result = self.gs._run_gh(["issue", "list"])
        self.assertIn("timed out", result)

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_run_gh_truncates_large_output(self, mock_run):
        """_run_gh truncates output that exceeds max_output."""
        if self.gs is None:
            self.skipTest("Module missing")
        large_output = "x" * 10000
        mock_run.return_value = MagicMock(returncode=0, stdout=large_output, stderr="")
        result = self.gs._run_gh(["issue", "list"], max_output=100)
        self.assertLessEqual(len(result), 120)  # 100 chars + truncation marker
        self.assertIn("truncated", result)

    # ── Issue tools ───────────────────────────────────────────────────────────

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_list_issues_passes_state_and_limit(self, mock_run):
        """list_issues passes --state and --limit to gh CLI."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="[]", stderr="")
        self.gs.list_issues(state="closed", limit=5)
        call_args = mock_run.call_args[0][0]
        self.assertIn("--state", call_args)
        self.assertIn("closed", call_args)
        self.assertIn("--limit", call_args)
        self.assertIn("5", call_args)

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_list_issues_clamps_limit(self, mock_run):
        """list_issues clamps limit to 100."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="[]", stderr="")
        self.gs.list_issues(limit=999)
        call_args = mock_run.call_args[0][0]
        limit_idx = call_args.index("--limit")
        self.assertEqual(call_args[limit_idx + 1], "100")

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_list_issues_adds_label_filter(self, mock_run):
        """list_issues appends --label when labels are provided."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="[]", stderr="")
        self.gs.list_issues(labels="bug,priority:high")
        call_args = mock_run.call_args[0][0]
        self.assertIn("--label", call_args)
        self.assertIn("bug,priority:high", call_args)

    # ── PR tools ──────────────────────────────────────────────────────────────

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_list_prs_clamps_limit(self, mock_run):
        """list_prs clamps limit to 100."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="[]", stderr="")
        self.gs.list_prs(limit=500)
        call_args = mock_run.call_args[0][0]
        limit_idx = call_args.index("--limit")
        self.assertEqual(call_args[limit_idx + 1], "100")

    def test_merge_pr_rejects_invalid_method(self):
        """merge_pr returns an error string for unknown merge methods."""
        if self.gs is None:
            self.skipTest("Module missing")
        import asyncio
        result = asyncio.run(self.gs.merge_pr(number=1, method="fast-forward", ctx=None))
        self.assertIn("invalid merge method", result)
        self.assertIn("fast-forward", result)

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_merge_pr_no_ctx_calls_gh(self, mock_run):
        """merge_pr without ctx skips elicitation and calls gh directly."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="PR merged", stderr="")
        import asyncio
        result = asyncio.run(self.gs.merge_pr(number=42, method="squash", ctx=None))
        self.assertEqual(result, "PR merged")
        call_args = mock_run.call_args[0][0]
        self.assertIn("--squash", call_args)
        self.assertIn("42", call_args)

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_merge_pr_delete_branch_flag(self, mock_run):
        """merge_pr appends --delete-branch when requested."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="merged", stderr="")
        import asyncio
        asyncio.run(self.gs.merge_pr(number=1, method="merge", delete_branch=True, ctx=None))
        call_args = mock_run.call_args[0][0]
        self.assertIn("--delete-branch", call_args)

    # ── Workflow / release tools ───────────────────────────────────────────────

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_list_runs_clamps_limit(self, mock_run):
        """list_runs clamps limit to 50."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="[]", stderr="")
        self.gs.list_runs(limit=200)
        call_args = mock_run.call_args[0][0]
        limit_idx = call_args.index("--limit")
        self.assertEqual(call_args[limit_idx + 1], "50")

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_create_release_draft_flag(self, mock_run):
        """create_release includes --draft when draft=True."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="release created", stderr="")
        self.gs.create_release(tag="v1.0.0", title="Release", notes="notes", draft=True)
        call_args = mock_run.call_args[0][0]
        self.assertIn("--draft", call_args)

    @patch("scripts.mcp.github_server.subprocess.run")
    def test_create_release_no_draft_flag(self, mock_run):
        """create_release omits --draft when draft=False."""
        if self.gs is None:
            self.skipTest("Module missing")
        mock_run.return_value = MagicMock(returncode=0, stdout="release created", stderr="")
        self.gs.create_release(tag="v1.0.0", title="Release", notes="notes", draft=False)
        call_args = mock_run.call_args[0][0]
        self.assertNotIn("--draft", call_args)


if __name__ == "__main__":
    unittest.main()

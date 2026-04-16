import copy
import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

# MCP mocks are installed by conftest.py — no module-level mock setup needed here.


class TestTranslationServer(unittest.TestCase):
    def setUp(self):
        if "scripts.mcp.translation_server" in sys.modules:
            del sys.modules["scripts.mcp.translation_server"]
        try:
            import scripts.mcp.translation_server as ts
            self.ts = ts
        except ImportError:
            self.ts = None

    # ── Module smoke ─────────────────────────────────────────────────────────

    def test_module_exists(self):
        """Verify the translation_server module can be imported."""
        if self.ts is None:
            self.fail("scripts.mcp.translation_server module not found.")

    def test_repo_root_resolved(self):
        """Verify REPO_ROOT points to the repo directory."""
        if self.ts is None:
            self.skipTest("Module missing")
        self.assertTrue(self.ts.REPO_ROOT.exists())
        self.assertTrue((self.ts.REPO_ROOT / "AGENTS.md").exists())

    # ── _validate_path ────────────────────────────────────────────────────────

    def test_validate_path_accepts_repo_file(self):
        """_validate_path returns None for a path inside REPO_ROOT."""
        if self.ts is None:
            self.skipTest("Module missing")
        inside = str(self.ts.REPO_ROOT / "scripts" / "mcp" / "translation_server.py")
        self.assertIsNone(self.ts._validate_path(inside))

    def test_validate_path_rejects_outside_repo(self):
        """_validate_path returns error JSON for paths outside REPO_ROOT."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = self.ts._validate_path("/etc/passwd")
        parsed = json.loads(result)
        self.assertIn("error", parsed)
        self.assertIn("outside", parsed["error"])

    # ── State persistence ─────────────────────────────────────────────────────

    def test_load_state_returns_default_when_no_file(self):
        """_load_state returns a copy of _DEFAULT_STATE when no state file exists."""
        if self.ts is None:
            self.skipTest("Module missing")
        original = self.ts._STATE_FILE
        self.ts._STATE_FILE = Path("/nonexistent/path/state.json")
        try:
            state = self.ts._load_state()
            self.assertEqual(state["phase"], "idle")
            self.assertIsInstance(state["modules"], list)
        finally:
            self.ts._STATE_FILE = original

    def test_save_and_load_state_round_trip(self):
        """_save_state persists state; _load_state reads it back correctly."""
        if self.ts is None:
            self.skipTest("Module missing")
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp_file = Path(tmpdir) / "state.json"
            original_file = self.ts._STATE_FILE
            original_dir = self.ts._STATE_DIR
            try:
                self.ts._STATE_FILE = tmp_file
                self.ts._STATE_DIR = Path(tmpdir)
                # Write a modified state
                self.ts.translation_state["phase"] = "discovery"
                self.ts._save_state()
                # Load it back
                loaded = self.ts._load_state()
                self.assertEqual(loaded["phase"], "discovery")
            finally:
                self.ts._STATE_FILE = original_file
                self.ts._STATE_DIR = original_dir
                self.ts.translation_state["phase"] = "idle"

    def test_load_state_falls_back_on_corrupt_json(self):
        """_load_state returns defaults when the state file contains invalid JSON."""
        if self.ts is None:
            self.skipTest("Module missing")
        with tempfile.NamedTemporaryFile(mode="w", suffix=".json", delete=False) as f:
            f.write("{ not valid json")
            tmp_path = Path(f.name)
        try:
            original = self.ts._STATE_FILE
            self.ts._STATE_FILE = tmp_path
            state = self.ts._load_state()
            self.assertEqual(state["phase"], "idle")
        finally:
            self.ts._STATE_FILE = original
            tmp_path.unlink(missing_ok=True)

    # ── calculate_confidence ──────────────────────────────────────────────────

    def test_calculate_confidence_perfect_scores(self):
        """All 1.0 scores produce overall_score=1.0 and band='High'."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.calculate_confidence(
            syntax_score=1.0, type_score=1.0, lint_score=1.0,
            unit_test_score=1.0, integration_score=1.0, equivalence_score=1.0,
        ))
        self.assertEqual(result["overall_score"], 1.0)
        self.assertEqual(result["band"], "High")

    def test_calculate_confidence_zero_scores(self):
        """All 0.0 scores produce overall_score=0.0 and band='Critical'."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.calculate_confidence())
        self.assertEqual(result["overall_score"], 0.0)
        self.assertEqual(result["band"], "Critical")

    def test_calculate_confidence_clamps_out_of_range(self):
        """Scores outside [0, 1] are clamped before calculation."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.calculate_confidence(
            syntax_score=2.5, type_score=-1.0,
        ))
        # syntax clamped to 1.0, type clamped to 0.0 — should not raise
        self.assertIn("overall_score", result)
        self.assertGreaterEqual(result["overall_score"], 0.0)
        self.assertLessEqual(result["overall_score"], 1.0)

    def test_calculate_confidence_weights_sum_to_one(self):
        """Breakdown weights sum to 1.0."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.calculate_confidence())
        total_weight = sum(v["weight"] for v in result["breakdown"].values())
        self.assertAlmostEqual(total_weight, 1.0, places=5)

    def test_calculate_confidence_medium_band(self):
        """Score in [0.7, 0.9) maps to 'Medium' band."""
        if self.ts is None:
            self.skipTest("Module missing")
        # weighted score ≈ 0.8: all scores = 0.8
        result = json.loads(self.ts.calculate_confidence(
            syntax_score=0.8, type_score=0.8, lint_score=0.8,
            unit_test_score=0.8, integration_score=0.8, equivalence_score=0.8,
        ))
        self.assertEqual(result["band"], "Medium")

    # ── calculate_repo_confidence ─────────────────────────────────────────────

    def test_calculate_repo_confidence_empty_list(self):
        """Empty input returns repo_score=0.0."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.calculate_repo_confidence("[]"))
        self.assertEqual(result["repo_score"], 0.0)
        self.assertEqual(result["total_files"], 0)

    def test_calculate_repo_confidence_weighted_average(self):
        """LOC-weighted average is calculated correctly."""
        if self.ts is None:
            self.skipTest("Module missing")
        # file A: 100 LOC, score 1.0 → contributes 100
        # file B: 100 LOC, score 0.0 → contributes 0
        # expected repo score: 100/200 = 0.5
        files = [
            {"file": "a.py", "loc": 100, "score": 1.0},
            {"file": "b.py", "loc": 100, "score": 0.0},
        ]
        result = json.loads(self.ts.calculate_repo_confidence(json.dumps(files)))
        self.assertAlmostEqual(result["repo_score"], 0.5, places=4)
        self.assertEqual(result["total_loc"], 200)

    def test_calculate_repo_confidence_band_distribution(self):
        """Files are bucketed into the correct confidence bands."""
        if self.ts is None:
            self.skipTest("Module missing")
        files = [
            {"file": "a.py", "loc": 10, "score": 0.95},  # High
            {"file": "b.py", "loc": 10, "score": 0.75},  # Medium
            {"file": "c.py", "loc": 10, "score": 0.55},  # Low
            {"file": "d.py", "loc": 10, "score": 0.30},  # Critical
        ]
        result = json.loads(self.ts.calculate_repo_confidence(json.dumps(files)))
        self.assertEqual(result["distribution"]["High"]["file_count"], 1)
        self.assertEqual(result["distribution"]["Medium"]["file_count"], 1)
        self.assertEqual(result["distribution"]["Low"]["file_count"], 1)
        self.assertEqual(result["distribution"]["Critical"]["file_count"], 1)

    def test_calculate_repo_confidence_invalid_json(self):
        """Invalid JSON input returns an error."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.calculate_repo_confidence("not json"))
        self.assertIn("error", result)

    # ── get_translation_status ────────────────────────────────────────────────

    def test_get_translation_status_returns_valid_json(self):
        """get_translation_status returns parseable JSON with required keys."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.get_translation_status())
        self.assertIn("phase", result)
        self.assertIn("modules", result)
        self.assertIn("progress", result)

    # ── update_module_status ──────────────────────────────────────────────────

    def test_update_module_status_invalid_status(self):
        """update_module_status rejects unknown status values."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.update_module_status("mod-1", "done"))
        self.assertIn("error", result)
        self.assertIn("Invalid status", result["error"])

    def test_update_module_status_module_not_found(self):
        """update_module_status returns error when module_id is not in manifest."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.update_module_status("nonexistent-id", "pending"))
        self.assertIn("error", result)
        self.assertIn("not found", result["error"])

    def test_update_module_status_updates_and_persists(self):
        """update_module_status updates the module and calls _save_state."""
        if self.ts is None:
            self.skipTest("Module missing")
        # Inject a test module into the live state
        test_module = {"id": "test-mod", "status": "pending", "confidence": None}
        original_modules = self.ts.translation_state["modules"]
        self.ts.translation_state["modules"] = [test_module]
        try:
            with patch.object(self.ts, "_save_state") as mock_save:
                result = json.loads(
                    self.ts.update_module_status("test-mod", "translated", confidence=0.85)
                )
            self.assertTrue(result["success"])
            self.assertEqual(result["module"]["status"], "translated")
            self.assertAlmostEqual(result["module"]["confidence"], 0.85)
            mock_save.assert_called_once()
        finally:
            self.ts.translation_state["modules"] = original_modules

    # ── suggest_target_dependencies ───────────────────────────────────────────

    def test_suggest_target_dependencies_known_mapping(self):
        """Known mappings return high-confidence suggestions."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.suggest_target_dependencies(
            source_packages="requests,flask",
            source_language="python",
            target_language="typescript",
        ))
        self.assertEqual(result["mappings"]["requests"]["confidence"], "high")
        self.assertIsNotNone(result["mappings"]["requests"]["target"])
        self.assertEqual(result["mappings"]["flask"]["confidence"], "high")

    def test_suggest_target_dependencies_unknown_mapping(self):
        """Unknown packages return unknown confidence and None target."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.suggest_target_dependencies(
            source_packages="some_obscure_lib",
            source_language="python",
            target_language="typescript",
        ))
        self.assertEqual(result["mappings"]["some_obscure_lib"]["confidence"], "unknown")
        self.assertIsNone(result["mappings"]["some_obscure_lib"]["target"])
        self.assertEqual(result["unmapped_count"], 1)

    def test_suggest_target_dependencies_unsupported_pair(self):
        """Language pairs with no mapping table return unknown confidence for all packages."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.suggest_target_dependencies(
            source_packages="requests",
            source_language="cobol",
            target_language="brainfuck",
        ))
        self.assertEqual(result["mappings"]["requests"]["confidence"], "unknown")

    # ── analyze_imports path guard ────────────────────────────────────────────

    def test_analyze_imports_rejects_outside_repo(self):
        """analyze_imports returns error JSON for paths outside the workspace."""
        if self.ts is None:
            self.skipTest("Module missing")
        result = json.loads(self.ts.analyze_imports("/etc/passwd", "python"))
        self.assertIn("error", result)


if __name__ == "__main__":
    unittest.main()

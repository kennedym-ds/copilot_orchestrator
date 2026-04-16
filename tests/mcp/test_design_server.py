import unittest
import sys
import os

# MCP mocks are installed by conftest.py — no module-level mock setup needed here.

class TestDesignServer(unittest.TestCase):
    def setUp(self):
        # We need to import the module inside the test to ensure mocks are active
        # and to handle the case where the file doesn't exist yet (TDD)
        try:
            # Force reload to ensure mock changes take effect if run multiple times
            if "scripts.mcp.design_server" in sys.modules:
                del sys.modules["scripts.mcp.design_server"]
            import scripts.mcp.design_server as ds
            self.ds = ds
        except ImportError:
            self.ds = None

    def test_module_exists(self):
        """Phase 1: Verify the design_server module exists."""
        if self.ds is None:
            self.fail("scripts.mcp.design_server module not found. Please create it.")

    def test_get_brand_palette(self):
        """Phase 1: Verify get_brand_palette returns the correct structure."""
        if self.ds is None: self.skipTest("Module missing")
        
        palette = self.ds.get_brand_palette()
        self.assertIsInstance(palette, list)
        self.assertGreater(len(palette), 0)
        self.assertIn("hex", palette[0])
        self.assertIn("name", palette[0])

    def test_check_contrast(self):
        """Phase 1: Verify check_contrast logic."""
        if self.ds is None: self.skipTest("Module missing")

        # Test black on white (High contrast)
        result_pass = self.ds.check_contrast("#000000", "#FFFFFF")
        self.assertTrue(result_pass["pass_AA"])
        self.assertGreater(result_pass["ratio"], 4.5)

        # Test white on white (Low contrast)
        result_fail = self.ds.check_contrast("#FFFFFF", "#FFFFFF")
        self.assertFalse(result_fail["pass_AA"])
        self.assertEqual(result_fail["ratio"], 1.0)

    def test_search_components(self):
        """Phase 1: Verify search_components returns results."""
        if self.ds is None: self.skipTest("Module missing")

        results = self.ds.search_components("button")
        self.assertIsInstance(results, list)
        # Assuming mock data has a button
        found = any("button" in c["name"].lower() for c in results)
        self.assertTrue(found, "Should find a button component in mock data")

if __name__ == "__main__":
    unittest.main()

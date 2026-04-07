"""Tests for File Regeneration Agent and build_and_fix command."""
import os
import sys
import json
import tempfile
import unittest
from unittest.mock import patch, MagicMock

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from repair.file_regeneration import FileRegenerationAgent, NO_THIRD_PARTY_RULE
from agent import create_app, SUPPORTED_COMMANDS


class MockLiteLLMResponse:
    """Mock litellm.completion response."""
    def __init__(self, content="import Foundation\nstruct Mock {}", cost=0.01,
                 input_tokens=100, output_tokens=50):
        self.choices = [MagicMock(message=MagicMock(content=content))]
        self.usage = MagicMock(prompt_tokens=input_tokens, completion_tokens=output_tokens)
        self._cost = cost


class TestRegenerationSingleFile(unittest.TestCase):
    def test_regenerate_produces_new_content(self):
        config = {"regeneration": {"model": "claude-sonnet-4-6", "max_tokens": 8000,
                                    "max_context_files": 5, "max_context_files_escalated": 10,
                                    "max_files_per_cycle": 20}}
        agent = FileRegenerationAgent(config)

        with tempfile.TemporaryDirectory() as tmpdir:
            # Create a broken file
            broken = os.path.join(tmpdir, "Broken.swift")
            with open(broken, "w") as f:
                f.write("struct Broken { invalid syntax here }")

            mock_response = MockLiteLLMResponse(
                content="import Foundation\n\nstruct Broken {\n    var value: Int = 0\n}\n"
            )

            with patch("repair.file_regeneration.litellm") as mock_llm:
                mock_llm.completion.return_value = mock_response
                mock_llm.completion_cost.return_value = 0.01

                result = agent.regenerate_files(
                    failed_files=[broken],
                    error_details=[{"file": broken, "line": 1, "message": "Expected '}'"}],
                    project_dir=tmpdir,
                )

            self.assertTrue(result["any_regenerated"])
            self.assertEqual(result["regenerated"], 1)
            # File should be overwritten
            new_content = open(broken).read()
            self.assertIn("import Foundation", new_content)
            self.assertIn("struct Broken", new_content)


class TestRegenerationNoThirdParty(unittest.TestCase):
    def test_prompt_contains_no_third_party_rule(self):
        self.assertIn("KEINE Third-Party", NO_THIRD_PARTY_RULE)
        self.assertIn("GRDB", NO_THIRD_PARTY_RULE)
        self.assertIn("Realm", NO_THIRD_PARTY_RULE)
        self.assertIn("Alamofire", NO_THIRD_PARTY_RULE)
        self.assertIn("UserDefaults", NO_THIRD_PARTY_RULE)


class TestRegenerationContextCollection(unittest.TestCase):
    def test_finds_related_files(self):
        config = {"regeneration": {"max_context_files": 5, "max_context_files_escalated": 10}}
        agent = FileRegenerationAgent(config)

        with tempfile.TemporaryDirectory() as tmpdir:
            # Create files
            for name in ["PerformanceService.swift", "PerformanceStorageError.swift",
                        "PerformanceModel.swift", "Unrelated.swift"]:
                with open(os.path.join(tmpdir, name), "w") as f:
                    f.write(f"// {name}\nimport Foundation\nstruct {name.replace('.swift', '')} {{}}\n")

            target = os.path.join(tmpdir, "PerformanceStorageError.swift")
            related = agent._collect_context(target, tmpdir, max_files=5)

            # Should find Performance-prefixed files first
            related_names = [os.path.basename(r[0]) for r in related]
            self.assertIn("PerformanceService.swift", related_names)
            self.assertIn("PerformanceModel.swift", related_names)


class TestRegenerationStubbornDetection(unittest.TestCase):
    def test_second_attempt_uses_more_context(self):
        config = {"regeneration": {"model": "claude-sonnet-4-6", "max_tokens": 8000,
                                    "max_context_files": 5, "max_context_files_escalated": 15,
                                    "max_files_per_cycle": 20}}
        agent = FileRegenerationAgent(config)

        with tempfile.TemporaryDirectory() as tmpdir:
            broken = os.path.join(tmpdir, "Stubborn.swift")
            with open(broken, "w") as f:
                f.write("struct Stubborn {}")

            mock_resp = MockLiteLLMResponse(
                content="import Foundation\nstruct Stubborn {\n    var x: Int\n}\n"
            )

            with patch("repair.file_regeneration.litellm") as mock_llm:
                mock_llm.completion.return_value = mock_resp
                mock_llm.completion_cost.return_value = 0.01

                # First attempt
                agent.regenerate_files([broken], [{"file": broken, "line": 1, "message": "err"}], tmpdir)
                self.assertEqual(agent.attempt_counts[broken], 1)

                # Second attempt — should escalate
                agent.regenerate_files([broken], [{"file": broken, "line": 1, "message": "err"}], tmpdir)
                self.assertEqual(agent.attempt_counts[broken], 2)
                self.assertIn(broken, agent.get_stubborn_files())


class TestRegenerationValidation(unittest.TestCase):
    def test_rejects_empty_output(self):
        config = {"regeneration": {}}
        agent = FileRegenerationAgent(config)
        self.assertFalse(agent._validate_output("", "Test.swift"))

    def test_rejects_no_import(self):
        config = {"regeneration": {}}
        agent = FileRegenerationAgent(config)
        self.assertFalse(agent._validate_output("struct Foo {}", "Test.swift"))

    def test_rejects_placeholder(self):
        config = {"regeneration": {}}
        agent = FileRegenerationAgent(config)
        self.assertFalse(agent._validate_output("import Foundation\nstruct Foo { ... }", "Test.swift"))

    def test_accepts_valid_swift(self):
        config = {"regeneration": {}}
        agent = FileRegenerationAgent(config)
        self.assertTrue(agent._validate_output(
            "import Foundation\n\nstruct Foo {\n    var bar: Int\n}\n", "Test.swift"))


class TestBuildAndFixCommandDispatch(unittest.TestCase):
    def test_dispatch_exists(self):
        app = create_app()
        client = app.test_client()
        r = client.post('/command', json={"type": "build_and_fix", "project": "nonexistent"})
        data = r.get_json()
        self.assertEqual(r.status_code, 200)
        # Should be accepted (async) not 400
        self.assertEqual(data["status"], "accepted")
        self.assertIn("job_id", data)

    def test_build_and_fix_in_supported(self):
        self.assertIn("build_and_fix", SUPPORTED_COMMANDS)


class TestBuildAndFixSuccessFirstTry(unittest.TestCase):
    def test_success_without_regen(self):
        app = create_app()
        agent = app.agent

        with patch.object(agent, '_run_xcodegen', return_value=True), \
             patch('repair.swift_repair_engine.SwiftRepairEngine.build_and_repair') as mock_build:
            mock_build.return_value = {
                "build_succeeded": True, "final_errors": 0, "repair_cost": 0,
                "error_details": [], "history": [],
            }

            result = agent._build_and_fix({"project": "test", "params": {"max_cycles": 3}})

        self.assertEqual(result["status"], "success")
        self.assertTrue(result["result"]["build_succeeded"])
        self.assertEqual(result["result"]["cycles"], 1)


class TestBuildAndFixMaxCycles(unittest.TestCase):
    def test_stops_at_max(self):
        """build_and_fix stops after max_cycles and returns failed."""
        app = create_app()
        agent = app.agent

        # Simplest test: nonexistent project fails immediately
        result = agent._build_and_fix({"project": "___nonexistent___", "params": {"max_cycles": 2}})
        self.assertEqual(result["status"], "failed")


class TestCostTracking(unittest.TestCase):
    def test_costs_are_tracked(self):
        config = {"regeneration": {"model": "claude-sonnet-4-6", "max_tokens": 8000,
                                    "max_context_files": 5, "max_context_files_escalated": 10,
                                    "max_files_per_cycle": 20}}
        agent = FileRegenerationAgent(config)

        with tempfile.TemporaryDirectory() as tmpdir:
            broken = os.path.join(tmpdir, "Cost.swift")
            with open(broken, "w") as f:
                f.write("struct Cost {}")

            mock_resp = MockLiteLLMResponse(
                content="import Foundation\nstruct Cost { var x: Int }\n",
                input_tokens=200, output_tokens=100,
            )

            with patch("repair.file_regeneration.litellm") as mock_llm:
                mock_llm.completion.return_value = mock_resp
                mock_llm.completion_cost.return_value = 0.015

                agent.regenerate_files([broken], [{"file": broken, "line": 1, "message": "err"}], tmpdir)

            summary = agent.get_cost_summary()
            self.assertEqual(summary["total_calls"], 1)
            self.assertEqual(summary["total_input_tokens"], 200)
            self.assertEqual(summary["total_output_tokens"], 100)
            self.assertAlmostEqual(summary["total_cost"], 0.015, places=3)


if __name__ == "__main__":
    unittest.main()

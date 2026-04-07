"""Tests for Mac Assembly Factory HTTP agent."""
import json
import io
import os
import sys
import tempfile
import unittest
import zipfile
from unittest.mock import patch

sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from agent import create_app, MacAssemblyAgent, SUPPORTED_COMMANDS, SYNC_COMMANDS


class TestBase(unittest.TestCase):
    def setUp(self):
        self.app = create_app()
        self.app.config['TESTING'] = True
        self.client = self.app.test_client()


class TestHealthEndpoint(TestBase):
    def test_health_returns_ok(self):
        r = self.client.get('/health')
        data = r.get_json()
        self.assertEqual(r.status_code, 200)
        self.assertEqual(data["status"], "ok")
        self.assertIn("xcode_version", data)
        self.assertIn("commands", data)
        self.assertEqual(len(data["commands"]), 11)


class TestSyncCommand(TestBase):
    def test_health_check_sync(self):
        r = self.client.post('/command', json={"type": "health_check"})
        data = r.get_json()
        self.assertEqual(r.status_code, 200)
        self.assertEqual(data["status"], "success")
        self.assertIn("xcode", data["result"])

    def test_check_signing_sync(self):
        r = self.client.post('/command', json={"type": "check_signing", "project": "test"})
        data = r.get_json()
        self.assertEqual(r.status_code, 200)
        self.assertEqual(data["status"], "success")
        self.assertIn("has_distribution_cert", data["result"])


class TestAsyncCommand(TestBase):
    def test_build_returns_accepted(self):
        r = self.client.post('/command', json={"type": "build_ios", "project": "nonexistent_test"})
        data = r.get_json()
        self.assertEqual(r.status_code, 200)
        self.assertEqual(data["status"], "accepted")
        self.assertIn("job_id", data)

    def test_status_running_then_completed(self):
        import time
        r = self.client.post('/command', json={"type": "build_ios", "project": "nonexistent_test"})
        job_id = r.get_json()["job_id"]

        # Should be running or already completed (fast failure)
        r2 = self.client.get(f'/status/{job_id}')
        self.assertIn(r2.get_json()["status"], ("running", "completed"))

        # Wait for completion (will fail fast since project doesn't exist)
        time.sleep(2)
        r3 = self.client.get(f'/status/{job_id}')
        data = r3.get_json()
        self.assertEqual(data["status"], "completed")
        self.assertIn("result", data)


class TestStatusNotFound(TestBase):
    def test_invalid_job_id(self):
        r = self.client.get('/status/invalid_job_id_xyz')
        self.assertEqual(r.status_code, 404)
        self.assertEqual(r.get_json()["status"], "not_found")


class TestUploadEndpoint(TestBase):
    def test_upload_zip(self):
        # Create a test ZIP with a Swift file
        buf = io.BytesIO()
        with zipfile.ZipFile(buf, 'w') as z:
            z.writestr("Models/TestModel.swift", "import Foundation\nstruct TestModel {}\n")
            z.writestr("Views/TestView.swift", "import SwiftUI\nstruct TestView: View { var body: some View { Text(\"Hi\") } }\n")
        buf.seek(0)

        r = self.client.post('/upload',
                            data={"project_name": "_test_upload_project",
                                  "project_zip": (buf, "project.zip")},
                            content_type='multipart/form-data')
        data = r.get_json()
        self.assertEqual(r.status_code, 200)
        self.assertEqual(data["status"], "ok")
        self.assertEqual(data["files_received"], 2)

        # Cleanup
        import shutil
        test_dir = os.path.join(self.app.agent.repo_path, "projects", "_test_upload_project")
        if os.path.exists(test_dir):
            shutil.rmtree(test_dir)

    def test_upload_missing_project_name(self):
        r = self.client.post('/upload', data={}, content_type='multipart/form-data')
        self.assertEqual(r.status_code, 400)

    def test_upload_missing_zip(self):
        r = self.client.post('/upload',
                            data={"project_name": "test"},
                            content_type='multipart/form-data')
        self.assertEqual(r.status_code, 400)


class TestJobsList(TestBase):
    def test_jobs_list(self):
        r = self.client.get('/jobs')
        data = r.get_json()
        self.assertEqual(r.status_code, 200)
        self.assertIn("jobs", data)
        self.assertIn("count", data)
        self.assertIn("running", data)


class TestCommandDispatch(TestBase):
    def test_unknown_command(self):
        r = self.client.post('/command', json={"type": "nonexistent_command"})
        self.assertEqual(r.status_code, 400)

    def test_missing_type(self):
        r = self.client.post('/command', json={"project": "test"})
        self.assertEqual(r.status_code, 400)

    def test_all_commands_registered(self):
        for cmd_type in SUPPORTED_COMMANDS:
            agent = self.app.agent
            handler = agent._dispatch({"type": cmd_type, "project": "test"})
            self.assertIn(handler.get("status", ""), ("success", "failed", "error", "config_missing"))


class TestDispatchUnchanged(TestBase):
    def test_dispatch_returns_same_structure(self):
        """Command dispatch produces same result structure as before."""
        agent = self.app.agent
        r = agent._dispatch({"type": "health_check"})
        self.assertEqual(r["status"], "success")
        self.assertIn("agent", r["result"])
        self.assertIn("commands", r["result"])


class TestServerAccessible(TestBase):
    def test_server_responds(self):
        r = self.client.get('/health')
        self.assertEqual(r.status_code, 200)


class TestTestParsing(TestBase):
    def test_parses_xcodebuild_output(self):
        output = """
Test Case '-[MyTests testLogin]' passed (0.123 seconds).
Test Case '-[MyTests testSignup]' passed (0.456 seconds).
Test Case '-[MyTests testLogout]' failed (1.200 seconds).
"""
        result = self.app.agent._parse_test_output(output, 2.0)
        passed = [d for d in result["test_details"] if d["status"] == "passed"]
        failed = [d for d in result["test_details"] if d["status"] == "failed"]
        self.assertEqual(len(passed), 2)
        self.assertEqual(len(failed), 1)


class TestUploadTestflightConfig(TestBase):
    def test_missing_issuer_id(self):
        result = self.app.agent._upload_testflight({"project": "test", "params": {"ipa_path": "/nonexistent.ipa"}})
        self.assertEqual(result["status"], "config_missing")


if __name__ == "__main__":
    unittest.main()

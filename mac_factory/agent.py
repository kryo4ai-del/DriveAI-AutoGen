#!/usr/bin/env python3
"""Mac Assembly Factory — HTTP Server Build + Test + Sign Agent.

Commands via HTTP statt Git Polling.
POST /command → dispatch → Result (sync oder async mit job_id)

Usage:
    python3 agent.py
"""
import os
import sys
import json
import re
import io
import time
import socket
import subprocess
import shutil
import zipfile
import threading
import yaml
from pathlib import Path
from datetime import datetime

from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))

from flask import Flask, request, jsonify

# Safety Guard — budget/timeout/heartbeat enforcement + cost persistence
import sys as _sys
_THIS_DIR = os.path.dirname(os.path.abspath(__file__))
_REPO_ROOT = os.path.dirname(_THIS_DIR)
if _REPO_ROOT not in _sys.path:
    _sys.path.insert(0, _REPO_ROOT)
from mac_factory.supervisor.safety_guard import SafetyGuard

# Global registry of active safety guards (job_id -> SafetyGuard)
active_safety_guards = {}

SUPPORTED_COMMANDS = (
    "health_check", "build_ios", "generate_and_build",
    "run_tests", "run_qa_suite",
    "archive", "export_ipa", "check_signing", "upload_testflight",
    "build_and_fix", "list_schemes",
    "compile_check", "repair_tier1", "repair_tier2",
    "regenerate", "save_checkpoint", "rollback_checkpoint",
    "deep_repair", "supervised_build",
)

SYNC_COMMANDS = ("health_check", "check_signing", "list_schemes",
                 "save_checkpoint", "rollback_checkpoint")


def create_app(config=None):
    """Create Flask app with config. Allows test injection."""
    app = Flask(__name__)

    if config is None:
        config_path = os.path.join(os.path.dirname(__file__), "config.yaml")
        with open(config_path) as f:
            config = yaml.safe_load(f)

    agent = MacAssemblyAgent(config)
    jobs = {}  # job_id → {status, result, started_at, completed_at, cmd_type}

    def _generate_job_id():
        return f"job_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

    # Shared cancel flags: job_id → True if cancelled
    cancel_flags = {}

    def _run_job(job_id, cmd):
        try:
            # Pass cancel flag to agent so long-running loops can check it
            agent._current_cancel_flag = lambda: cancel_flags.get(job_id, False)
            result = agent._dispatch(cmd)
            if cancel_flags.get(job_id):
                jobs[job_id]["status"] = "cancelled"
                jobs[job_id]["result"] = {"status": "cancelled", "result": {"message": "Job cancelled by user"}}
            else:
                jobs[job_id]["status"] = "completed"
                jobs[job_id]["result"] = result
        except Exception as e:
            jobs[job_id]["status"] = "error"
            jobs[job_id]["result"] = {"status": "failed", "result": {"error": str(e)}}
        finally:
            agent._current_cancel_flag = lambda: False
        jobs[job_id]["completed_at"] = datetime.now().isoformat()

    @app.route('/agents', methods=['GET'])
    def list_agents():
        from mac_factory.registration import get_mac_agents
        agents = get_mac_agents()
        return jsonify({"agents": agents, "count": len(agents)})

    @app.route('/health', methods=['GET'])
    def health():
        from mac_factory.registration import get_registered_agents
        agents = get_registered_agents()
        return jsonify({
            "status": "ok",
            "agent": "mac-assembly-factory",
            "xcode_version": agent._get_xcode_version(),
            "commands": list(SUPPORTED_COMMANDS),
            "agents": len(agents),
            "agent_ids": [a["agent_id"] for a in agents],
        })

    @app.route('/command', methods=['POST'])
    def command():
        cmd = request.json
        if not cmd or "type" not in cmd:
            return jsonify({"status": "error", "error": "Missing 'type' in command"}), 400

        cmd_type = cmd["type"]
        if cmd_type not in SUPPORTED_COMMANDS:
            return jsonify({"status": "error", "error": f"Unknown command: {cmd_type}"}), 400

        project = cmd.get("project", "")
        print(f"\n[{datetime.now().strftime('%H:%M:%S')}] Command: {cmd_type} — {project} {cmd.get('feature_name', '')}")

        # Sync commands: direct response
        if cmd_type in SYNC_COMMANDS:
            result = agent._dispatch(cmd)
            return jsonify(result)

        # Async commands: background thread
        job_id = _generate_job_id()
        jobs[job_id] = {
            "status": "running",
            "started_at": datetime.now().isoformat(),
            "completed_at": None,
            "cmd_type": cmd_type,
            "project": project,
            "result": None,
        }

        thread = threading.Thread(target=_run_job, args=(job_id, cmd), daemon=True)
        thread.start()

        return jsonify({"status": "accepted", "job_id": job_id})

    @app.route('/status/<job_id>', methods=['GET'])
    def status(job_id):
        job = jobs.get(job_id)
        if not job:
            return jsonify({"status": "not_found"}), 404
        # Heartbeat: tell the safety guard that someone is still polling
        if job_id in active_safety_guards:
            active_safety_guards[job_id].heartbeat()
        return jsonify(job)

    @app.route('/costs', methods=['GET'])
    def get_costs():
        """Returns daily/monthly cost summary + active job status."""
        return jsonify({
            "daily_total": SafetyGuard.get_daily_total(),
            "monthly_total": SafetyGuard.get_monthly_total(),
            "active_jobs": {jid: g.get_status() for jid, g in active_safety_guards.items()}
        })

    @app.route('/cancel/<job_id>', methods=['POST'])
    def cancel(job_id):
        job = jobs.get(job_id)
        if not job:
            return jsonify({"status": "not_found"}), 404
        if job["status"] != "running":
            return jsonify({"status": "already_done", "job_status": job["status"]})

        cancel_flags[job_id] = True

        # Kill any running xcodebuild/xcodegen processes
        subprocess.run(["pkill", "-f", "xcodebuild"], capture_output=True)
        subprocess.run(["pkill", "-f", "xcodegen"], capture_output=True)

        print(f"\n  [Mac Agent] CANCEL requested for {job_id}")
        return jsonify({"status": "cancel_requested", "job_id": job_id})

    @app.route('/jobs', methods=['GET'])
    def list_jobs():
        return jsonify({
            "jobs": {jid: {k: v for k, v in j.items() if k != "result" or j["status"] == "completed"}
                     for jid, j in jobs.items()},
            "count": len(jobs),
            "running": sum(1 for j in jobs.values() if j["status"] == "running"),
        })

    @app.route('/upload', methods=['POST'])
    def upload():
        project_name = request.form.get('project_name')
        if not project_name:
            return jsonify({"status": "error", "error": "Missing project_name"}), 400

        zip_file = request.files.get('project_zip')
        if not zip_file:
            return jsonify({"status": "error", "error": "Missing project_zip file"}), 400

        target_dir = os.path.join(agent.repo_path, "projects", project_name)
        os.makedirs(target_dir, exist_ok=True)

        # Read ZIP into memory and extract
        zip_data = io.BytesIO(zip_file.read())
        try:
            with zipfile.ZipFile(zip_data, 'r') as z:
                z.extractall(target_dir)
        except zipfile.BadZipFile:
            return jsonify({"status": "error", "error": "Invalid ZIP file"}), 400

        # Count Swift files
        swift_count = sum(1 for _ in Path(target_dir).rglob("*.swift"))

        # Commit uploaded files so git checkout/clean won't delete them
        # Timeout 120s for large projects (3000+ files)
        subprocess.run(["git", "add", target_dir], cwd=agent.repo_path,
                       capture_output=True, timeout=120)
        subprocess.run(["git", "commit", "-m", f"Upload: {project_name} ({swift_count} Swift files)"],
                       cwd=agent.repo_path, capture_output=True, timeout=120)

        print(f"  Upload: {project_name} — {swift_count} Swift files received + committed")

        return jsonify({
            "status": "ok",
            "files_received": swift_count,
            "project_dir": target_dir,
            "project_name": project_name,
        })

    # Store references for testing
    app.agent = agent
    app.jobs = jobs

    return app


class MacAssemblyAgent:
    def __init__(self, config):
        self.config = config
        self.repo_path = os.path.expanduser(config["driveai_repo"])
        self._current_cancel_flag = lambda: False

    # ── Dispatch ──────────────────────────────────────────────

    def _dispatch(self, cmd):
        handlers = {
            "health_check": self._health_check,
            "build_ios": self._build_ios,
            "generate_and_build": self._generate_and_build,
            "run_tests": self._run_tests,
            "run_qa_suite": self._run_qa_suite,
            "archive": self._archive,
            "export_ipa": self._export_ipa,
            "check_signing": self._check_signing,
            "upload_testflight": self._upload_testflight,
            "build_and_fix": self._build_and_fix,
            "list_schemes": self._list_schemes,
            "compile_check": self._compile_check,
            "repair_tier1": self._repair_tier1,
            "repair_tier2": self._repair_tier2,
            "regenerate": self._regenerate_cmd,
            "save_checkpoint": self._save_checkpoint,
            "rollback_checkpoint": self._rollback_checkpoint,
            "deep_repair": self._deep_repair,
            "supervised_build": self._supervised_build,
        }
        handler = handlers.get(cmd.get("type", ""))
        if not handler:
            return {"status": "error", "result": {"error": f"Unknown command: {cmd.get('type')}"}}
        try:
            return handler(cmd)
        except Exception as e:
            return {"status": "failed", "result": {"error": str(e)}}

    # ── health_check ──────────────────────────────────────────

    def _health_check(self, cmd):
        return {"status": "success", "result": {
            "agent": "mac-assembly-factory",
            "xcode": self._get_xcode_version(),
            "commands": list(SUPPORTED_COMMANDS),
        }}

    # ── build_ios ─────────────────────────────────────────────

    def _build_ios(self, cmd):
        project = cmd.get("project", "")
        project_dir = os.path.join(self.repo_path, "projects", project)

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project dir not found: {project_dir}"}}

        print(f"  Project: {project_dir}")

        print("  Step 1: Pre-Build Cleanup...")
        PreBuildCleanup(project_dir).run()

        print("  Step 2: xcodegen...")
        if not self._run_xcodegen(project_dir, project):
            return {"status": "failed", "result": {"error": "xcodegen failed"}}

        print("  Step 3: Build + Repair Loop...")
        from repair.swift_repair_engine import SwiftRepairEngine
        scheme = self._find_scheme(project_dir, project)
        engine = SwiftRepairEngine(project_dir=project_dir, scheme=scheme, config=self.config)
        result = engine.build_and_repair()

        if result.get("build_succeeded") and self.config.get("post_build", {}).get("auto_test", False):
            print("  Step 4: Post-Build Tests...")
            test_result = self._execute_tests(project_dir, scheme)
            result["tests_executed"] = True
            result["tests_passed"] = test_result.get("tests_passed", 0)
            result["tests_failed"] = test_result.get("tests_failed", 0)
            result["test_details"] = test_result.get("test_details", [])
            result["test_duration"] = test_result.get("test_duration", 0)
        else:
            result["tests_executed"] = False

        return {"status": "success" if result["build_succeeded"] else "failed", "result": result}

    # ── run_tests ─────────────────────────────────────────────

    def _run_tests(self, cmd):
        project = cmd.get("project", "")
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project)
        scheme = params.get("scheme")
        simulator = params.get("simulator", self.config.get("default_simulator", "iPhone 17 Pro"))

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        if not scheme:
            scheme = self._find_scheme(project_dir, project)

        if not list(Path(project_dir).glob("*.xcodeproj")):
            if not self._run_xcodegen(project_dir, project):
                return {"status": "failed", "result": {"error": "No xcodeproj and xcodegen failed"}}

        print(f"  Running tests: scheme={scheme}, simulator={simulator}")
        result = self._execute_tests(project_dir, scheme, simulator,
                                     timeout=params.get("timeout", self.config.get("test_timeout", 600)))

        return {"status": "success" if result.get("tests_failed", 0) == 0 else "failed", "result": result}

    def _execute_tests(self, project_dir, scheme, simulator=None, timeout=600):
        simulator = simulator or self.config.get("default_simulator", "iPhone 17 Pro")
        xcodeproj = list(Path(project_dir).glob("*.xcodeproj"))
        if not xcodeproj:
            return {"tests_passed": 0, "tests_failed": 0, "test_duration": 0,
                    "test_details": [], "error": "No xcodeproj found"}

        has_tests = False
        for root, dirs, files in os.walk(project_dir):
            if "quarantine" in root:
                continue
            for f in files:
                if f.endswith("Tests.swift") or f.endswith("Test.swift"):
                    has_tests = True
                    break
            if has_tests:
                break

        if not has_tests:
            return {"tests_passed": 0, "tests_failed": 0, "test_duration": 0,
                    "test_details": [], "note": "No test files found"}

        cmd = [
            "xcodebuild", "test",
            "-project", str(xcodeproj[0]),
            "-scheme", scheme,
            "-destination", f"platform=iOS Simulator,name={simulator}",
        ]

        start = time.time()
        try:
            r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout, cwd=project_dir)
            output = r.stdout + "\n" + r.stderr
        except subprocess.TimeoutExpired:
            return {"tests_passed": 0, "tests_failed": 0, "test_duration": timeout,
                    "test_details": [], "error": f"Tests timed out after {timeout}s"}

        return self._parse_test_output(output, round(time.time() - start, 1))

    def _parse_test_output(self, output, duration):
        details = []
        pattern = re.compile(r"Test Case\s+'.*?\s(\w+)\]'\s+(passed|failed)\s+\((\d+\.\d+)\s+seconds\)")
        for m in pattern.finditer(output):
            name, status, dur = m.group(1), m.group(2), float(m.group(3))
            detail = {"name": name, "status": status, "duration": dur}
            if status == "failed":
                fm = re.search(rf"{re.escape(name)}.*?failed.*?-\s*(.+?)$", output, re.MULTILINE)
                if fm:
                    detail["message"] = fm.group(1).strip()
            details.append(detail)

        passed = sum(1 for d in details if d["status"] == "passed")
        failed = sum(1 for d in details if d["status"] == "failed")
        if not details:
            passed = output.count("' passed")
            failed = output.count("' failed")

        return {"tests_passed": passed, "tests_failed": failed,
                "test_duration": duration, "test_details": details[:100]}

    # ── run_qa_suite ──────────────────────────────────────────

    def _run_qa_suite(self, cmd):
        project = cmd.get("project", "")
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project)
        scheme = self._find_scheme(project_dir, project)
        simulator = self.config.get("default_simulator", "iPhone 17 Pro")

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        qa_result = {"project": project}

        if params.get("unit_tests", True):
            print("  QA Step 1: Unit Tests...")
            qa_result["unit_tests"] = self._execute_tests(project_dir, scheme, simulator)

        if params.get("ui_tests", False):
            print("  QA Step 2: UI Tests...")
            qa_result["ui_tests"] = self._execute_tests(project_dir, scheme, simulator)

        screenshot_cfg = params.get("screenshots", {})
        if screenshot_cfg.get("enabled", False):
            print("  QA Step 3: Screenshots...")
            devices = screenshot_cfg.get("devices", self.config.get("screenshot_devices", []))
            qa_result["screenshots"] = self._capture_simulator_screenshots(project_dir, devices, scheme)

        total_failed = (qa_result.get("unit_tests", {}).get("tests_failed", 0) +
                       qa_result.get("ui_tests", {}).get("tests_failed", 0))

        return {"status": "success" if total_failed == 0 else "failed", "result": qa_result}

    # ── Screenshots ───────────────────────────────────────────

    def _capture_simulator_screenshots(self, project_dir, devices, scheme):
        screenshots_dir = os.path.join(project_dir, "qa_screenshots")
        os.makedirs(screenshots_dir, exist_ok=True)

        derived = os.path.expanduser("~/Library/Developer/Xcode/DerivedData")
        app_path = None
        for d in Path(derived).glob(f"{scheme}*/**/Build/Products/Debug-iphonesimulator/{scheme}.app"):
            app_path = str(d)
            break

        if not app_path:
            return {"error": "Built .app not found in DerivedData", "screenshots": []}

        bundle_id = None
        try:
            r = subprocess.run(["plutil", "-extract", "CFBundleIdentifier", "raw",
                               os.path.join(app_path, "Info.plist")],
                              capture_output=True, text=True, timeout=5)
            bundle_id = r.stdout.strip()
        except Exception:
            pass

        if not bundle_id:
            return {"error": "Could not read bundle ID", "screenshots": []}

        results = []
        for device_name in devices:
            device_dir = os.path.join(screenshots_dir, device_name.replace(" ", "_"))
            os.makedirs(device_dir, exist_ok=True)
            udid = self._find_simulator_udid(device_name)
            if not udid:
                results.append({"device": device_name, "status": "skipped", "error": "Simulator not found"})
                continue
            try:
                subprocess.run(["xcrun", "simctl", "boot", udid], capture_output=True, timeout=30)
                time.sleep(2)
                subprocess.run(["xcrun", "simctl", "install", udid, app_path], capture_output=True, timeout=30)
                subprocess.run(["xcrun", "simctl", "launch", udid, bundle_id], capture_output=True, timeout=10)
                time.sleep(4)
                ss_path = os.path.join(device_dir, f"launch_{device_name.replace(' ', '_')}.png")
                subprocess.run(["xcrun", "simctl", "io", udid, "screenshot", ss_path], capture_output=True, timeout=10)
                results.append({"device": device_name, "status": "success" if os.path.exists(ss_path) else "failed",
                               "path": ss_path if os.path.exists(ss_path) else ""})
            except Exception as e:
                results.append({"device": device_name, "status": "failed", "error": str(e)})
            finally:
                subprocess.run(["xcrun", "simctl", "shutdown", udid], capture_output=True, timeout=10)

        return {"screenshots": results, "count": len([r for r in results if r["status"] == "success"])}

    def _find_simulator_udid(self, device_name):
        try:
            r = subprocess.run(["xcrun", "simctl", "list", "devices", "available", "-j"],
                              capture_output=True, text=True, timeout=10)
            data = json.loads(r.stdout)
            for runtime, devices in data.get("devices", {}).items():
                for dev in devices:
                    if dev.get("name") == device_name and dev.get("isAvailable"):
                        return dev["udid"]
        except Exception:
            pass
        return ""

    # ── archive ───────────────────────────────────────────────

    def _archive(self, cmd):
        project = cmd.get("project", "")
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project)
        bundle_id = params.get("bundle_id", "")

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project dir not found: {project_dir}"}}

        # Check if Swift files exist
        swift_count = sum(1 for _ in Path(project_dir).rglob("*.swift"))
        if swift_count == 0:
            return {"status": "failed", "result": {
                "error": f"Project {project} has 0 Swift files — upload project files first",
                "project_dir": project_dir,
            }}

        # Ensure xcodeproj is valid (regenerate if needed)
        xcodeproj = list(Path(project_dir).glob("*.xcodeproj"))
        pbxproj_valid = False
        if xcodeproj:
            pbxproj_valid = os.path.isfile(os.path.join(str(xcodeproj[0]), "project.pbxproj"))

        if not xcodeproj or not pbxproj_valid:
            print(f"  Archive: xcodeproj missing or invalid — running xcodegen...")
            if not self._run_xcodegen(project_dir, project):
                return {"status": "failed", "result": {"error": "xcodegen failed — cannot archive"}}
            xcodeproj = list(Path(project_dir).glob("*.xcodeproj"))
            if not xcodeproj:
                return {"status": "failed", "result": {"error": "No .xcodeproj after xcodegen"}}

        # Auto-detect scheme
        scheme = params.get("scheme")
        if not scheme:
            scheme = self._find_scheme(project_dir, project)

        # Validate scheme exists
        available_schemes = self._list_schemes_for_project(str(xcodeproj[0]))
        if available_schemes and scheme not in available_schemes:
            # Try case-insensitive match
            match = [s for s in available_schemes if s.lower() == scheme.lower()]
            if match:
                scheme = match[0]
            else:
                print(f"  Archive: scheme '{scheme}' not found. Available: {available_schemes}")
                scheme = available_schemes[0] if available_schemes else scheme
                print(f"  Archive: using scheme '{scheme}'")

        archive_path = os.path.join(project_dir, "build", f"{scheme}.xcarchive")
        os.makedirs(os.path.join(project_dir, "build"), exist_ok=True)

        # Remove old archive if exists
        if os.path.exists(archive_path):
            shutil.rmtree(archive_path, ignore_errors=True)

        cmd_args = [
            "xcodebuild", "archive",
            "-project", str(xcodeproj[0]),
            "-scheme", scheme,
            "-configuration", "Release",
            "-archivePath", archive_path,
            "-destination", "generic/platform=iOS",
        ]

        # Add bundle ID override if provided
        if bundle_id:
            cmd_args.append(f"PRODUCT_BUNDLE_IDENTIFIER={bundle_id}")

        # Check if signing is available, if not allow unsigned archive
        signing_result = self._check_signing(cmd)
        has_cert = (signing_result.get("result", {}).get("has_distribution_cert", False) or
                   signing_result.get("result", {}).get("has_development_cert", False))
        if not has_cert:
            cmd_args.extend(["CODE_SIGN_IDENTITY=-", "CODE_SIGNING_ALLOWED=NO"])
            print(f"  Archive: no signing cert — building unsigned archive")

        print(f"  Archiving {scheme} ({swift_count} Swift files)...")
        print(f"  Command: {' '.join(cmd_args[-6:])}")  # Log last part of command
        start = time.time()
        try:
            result = subprocess.run(cmd_args, capture_output=True, text=True,
                                   timeout=self.config.get("archive_timeout", 1800), cwd=project_dir)
            elapsed = round(time.time() - start)
        except subprocess.TimeoutExpired:
            return {"status": "failed", "result": {"error": "Archive timed out", "build_time_seconds": self.config.get("archive_timeout", 1800)}}

        succeeded = result.returncode == 0 and os.path.exists(archive_path)

        if not succeeded:
            # Extract meaningful error from output
            error_lines = [l for l in (result.stdout + result.stderr).split("\n") if "error:" in l.lower()]
            return {"status": "failed", "result": {
                "archive_succeeded": False,
                "archive_path": "",
                "build_time_seconds": elapsed,
                "error": error_lines[-1] if error_lines else "xcodebuild archive failed",
                "error_count": len(error_lines),
                "stderr_tail": result.stderr[-500:] if result.stderr else "",
                "scheme_used": scheme,
                "available_schemes": available_schemes,
            }}

        archive_size = sum(f.stat().st_size for f in Path(archive_path).rglob("*") if f.is_file())
        print(f"  Archive succeeded: {archive_path} ({archive_size} bytes)")

        return {"status": "success", "result": {
            "archive_succeeded": True,
            "archive_path": archive_path,
            "archive_size_bytes": archive_size,
            "build_time_seconds": elapsed,
            "scheme_used": scheme,
            "swift_files": swift_count,
            "signed": has_cert,
        }}

    def _list_schemes(self, cmd):
        """List available Xcode schemes for a project."""
        project = cmd.get("project", "")
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects",
                                    params.get("project_dir", project))

        xcodeproj = list(Path(project_dir).glob("*.xcodeproj"))
        if not xcodeproj:
            # Try xcodegen
            if not self._run_xcodegen(project_dir, project):
                return {"status": "failed", "result": {"error": "No xcodeproj and xcodegen failed"}}
            xcodeproj = list(Path(project_dir).glob("*.xcodeproj"))

        if not xcodeproj:
            return {"status": "failed", "result": {"error": "No .xcodeproj found"}}

        schemes = self._list_schemes_for_project(str(xcodeproj[0]))
        swift_count = sum(1 for _ in Path(project_dir).rglob("*.swift"))

        return {"status": "success", "result": {
            "schemes": schemes,
            "project_path": str(xcodeproj[0]),
            "swift_files": swift_count,
        }}

    def _list_schemes_for_project(self, xcodeproj_path: str) -> list:
        """List available schemes from xcodeproj."""
        try:
            r = subprocess.run(
                ["xcodebuild", "-list", "-project", xcodeproj_path, "-json"],
                capture_output=True, text=True, timeout=15)
            if r.returncode == 0:
                data = json.loads(r.stdout)
                return data.get("project", {}).get("schemes", [])
        except Exception:
            pass
        return []

    # ── export_ipa ────────────────────────────────────────────

    def _export_ipa(self, cmd):
        project = cmd.get("project", "")
        params = cmd.get("params", {})
        archive_path = params.get("archive_path", "")
        export_options_path = params.get("export_options_path",
                                         self.config.get("signing", {}).get("export_options_path", ""))

        if not archive_path or not os.path.isdir(archive_path):
            return {"status": "failed", "result": {"error": f"Archive not found: {archive_path}"}}
        if not export_options_path or not os.path.isfile(export_options_path):
            return {"status": "failed", "result": {"error": f"ExportOptions.plist not found: {export_options_path}"}}

        project_dir = os.path.join(self.repo_path, "projects", project)
        export_dir = os.path.join(project_dir, "build", "export")
        os.makedirs(export_dir, exist_ok=True)

        cmd_args = ["xcodebuild", "-exportArchive", "-archivePath", archive_path,
                    "-exportPath", export_dir, "-exportOptionsPlist", export_options_path]

        print(f"  Exporting IPA...")
        start = time.time()
        try:
            result = subprocess.run(cmd_args, capture_output=True, text=True, timeout=600, cwd=project_dir)
        except subprocess.TimeoutExpired:
            return {"status": "failed", "result": {"error": "Export timed out"}}

        if result.returncode != 0:
            return {"status": "failed", "result": {"error": "Export failed", "stderr": result.stderr[-500:]}}

        ipa_files = list(Path(export_dir).glob("*.ipa"))
        if not ipa_files:
            return {"status": "failed", "result": {"error": "No .ipa found after export"}}

        ipa_path = str(ipa_files[0])
        return {"status": "success", "result": {
            "ipa_path": ipa_path, "export_dir": export_dir,
            "ipa_size_bytes": os.path.getsize(ipa_path),
            "export_time_seconds": round(time.time() - start),
        }}

    # ── check_signing ─────────────────────────────────────────

    def _check_signing(self, cmd):
        has_dist = has_dev = False
        cert_name = ""
        identity_count = 0

        try:
            r = subprocess.run(["security", "find-identity", "-v", "-p", "codesigning"],
                              capture_output=True, text=True, timeout=10)
            for line in r.stdout.split("\n"):
                if "Apple Distribution:" in line or "iPhone Distribution:" in line:
                    has_dist = True
                    m = re.search(r'"(.+?)"', line)
                    if m: cert_name = m.group(1)
                if "Apple Development:" in line:
                    has_dev = True
                    if not cert_name:
                        m = re.search(r'"(.+?)"', line)
                        if m: cert_name = m.group(1)
            m = re.search(r"(\d+) valid identit", r.stdout)
            if m: identity_count = int(m.group(1))
        except Exception:
            pass

        profile_count = 0
        profiles_dir = os.path.expanduser("~/Library/MobileDevice/Provisioning Profiles")
        if os.path.isdir(profiles_dir):
            profile_count = len([f for f in os.listdir(profiles_dir) if f.endswith(".mobileprovision")])

        return {"status": "success", "result": {
            "has_distribution_cert": has_dist, "has_development_cert": has_dev,
            "cert_name": cert_name, "identity_count": identity_count,
            "has_provisioning_profiles": profile_count > 0, "profile_count": profile_count,
            "team_id": self.config.get("signing", {}).get("team_id", ""),
        }}

    # ── upload_testflight ─────────────────────────────────────

    def _upload_testflight(self, cmd):
        params = cmd.get("params", {})
        ipa_path = params.get("ipa_path", "")
        signing = self.config.get("signing", {})

        missing = []
        if not signing.get("api_key_id"): missing.append("signing.api_key_id")
        if not signing.get("api_issuer_id"): missing.append("signing.api_issuer_id")
        if not signing.get("api_key_path") or not os.path.isfile(signing.get("api_key_path", "")): missing.append("signing.api_key_path")
        if not ipa_path or not os.path.isfile(ipa_path): missing.append("params.ipa_path")

        if missing:
            return {"status": "config_missing", "result": {
                "error": f"Missing config: {', '.join(missing)}", "missing_fields": missing,
                "hint": "Set these in ~/mac-assembly-factory/config.yaml under 'signing:'",
            }}

        auth_dir = os.path.expanduser("~/private_keys")
        os.makedirs(auth_dir, exist_ok=True)
        key_dest = os.path.join(auth_dir, f"AuthKey_{signing['api_key_id']}.p8")
        if not os.path.exists(key_dest):
            shutil.copy2(signing["api_key_path"], key_dest)

        cmd_args = ["xcrun", "altool", "--upload-app", "--file", ipa_path,
                    "--apiKey", signing["api_key_id"], "--apiIssuer", signing["api_issuer_id"], "--type", "ios"]

        print(f"  Uploading to TestFlight: {ipa_path}")
        start = time.time()
        try:
            result = subprocess.run(cmd_args, capture_output=True, text=True, timeout=600)
        except subprocess.TimeoutExpired:
            return {"status": "failed", "result": {"error": "Upload timed out"}}

        if result.returncode == 0:
            return {"status": "success", "result": {"upload_success": True, "upload_time_seconds": round(time.time() - start)}}
        return {"status": "failed", "result": {"upload_success": False,
                "error": result.stderr[-500:] if result.stderr else result.stdout[-500:]}}

    # ── generate_and_build ────────────────────────────────────

    def _generate_and_build(self, cmd):
        import litellm

        project = cmd.get("project", "")
        project_dir = os.path.join(self.repo_path, "projects", project)
        feature_name = cmd.get("feature_name", "Unknown")
        feature_spec = cmd.get("feature_spec", "")
        model = cmd.get("model", "claude-sonnet-4-6")
        compile_contract = cmd.get("compile_contract", "")
        target_files = cmd.get("target_files", [])

        os.makedirs(project_dir, exist_ok=True)
        print(f"  Feature: {feature_name}, Model: {model}, Files: {target_files}")

        llm_model = model if "/" in model else f"anthropic/{model}"
        try:
            response = litellm.completion(
                model=llm_model,
                messages=[
                    {"role": "system", "content": f"""You are a senior Swift/SwiftUI developer. Generate production-ready iOS code.
{compile_contract}
RESPONSE FORMAT: For each file, wrap in markers:
// === FILENAME: ExactFileName.swift ===
<code>
// === END: ExactFileName.swift ===
Generate ALL requested files."""},
                    {"role": "user", "content": f"""Generate Swift files for "{feature_name}":
{feature_spec}
Files: {chr(10).join(f'- {f}' for f in target_files)}
Each file must compile with swiftc -parse."""}
                ],
                max_tokens=8000, temperature=0.0,
            )
            generated_code = response.choices[0].message.content
            generation_cost = litellm.completion_cost(response)
            print(f"    LLM done — ${generation_cost:.4f}")
        except Exception as e:
            return {"status": "failed", "result": {"error": f"LLM failed: {e}", "generation_model": model}}

        parsed_files = self._parse_generated_files(generated_code)
        if not parsed_files:
            return {"status": "failed", "result": {"error": "No files parsed", "generation_cost": generation_cost}}

        written_files = []
        for filename, code in parsed_files.items():
            target = self._route_file(project_dir, filename)
            os.makedirs(target, exist_ok=True)
            filepath = os.path.join(target, filename)
            with open(filepath, "w", encoding="utf-8") as f:
                f.write(code)
            written_files.append(os.path.relpath(filepath, project_dir))
            print(f"    Wrote: {written_files[-1]}")

        build_result = self._build_ios({"project": project})
        result_data = build_result.get("result", {}) if isinstance(build_result.get("result"), dict) else {}
        result_data.update({"generated_files": written_files, "generation_cost": generation_cost,
                           "generation_model": model, "feature_name": feature_name,
                           "files_parsed": len(parsed_files), "files_requested": len(target_files)})

        return {"status": build_result.get("status", "failed"), "result": result_data}

    # ── build_and_fix ─────────────────────────────────────────

    def _build_and_fix(self, cmd):
        """Autonomous Build Loop: Build → Repair → Regeneration → Rebuild.
        Runs entirely on Mac — no roundtrip to Windows."""
        from repair.swift_repair_engine import SwiftRepairEngine
        from repair.file_regeneration import FileRegenerationAgent

        project = cmd.get("project", "")
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project)
        max_cycles = params.get("max_cycles", 10)

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        # Safety Guard: budget/timeout/heartbeat enforcement
        job_id = cmd.get("_job_id") or cmd.get("id") or f"build_and_fix_{project}_{int(time.time())}"
        guard = SafetyGuard(
            job_id=job_id,
            budget_limit=params.get("budget_limit", 2.00),
            timeout_minutes=params.get("timeout_minutes", 30),
            heartbeat_timeout_minutes=params.get("heartbeat_timeout_minutes", 5),
        )
        active_safety_guards[job_id] = guard
        cmd["_safety_guard"] = guard

        print(f"  [build_and_fix] Project: {project}, max_cycles: {max_cycles}, budget: ${guard.budget_limit}")

        # Commit all project files before build so git rollback won't delete them
        subprocess.run(["git", "add", project_dir], cwd=self.repo_path,
                       capture_output=True, timeout=120)
        subprocess.run(["git", "commit", "-m", f"Pre-build commit: {project}"],
                       cwd=self.repo_path, capture_output=True, timeout=120)

        regen_agent = FileRegenerationAgent(config=self.config)
        cycle_history = []

        for cycle in range(1, max_cycles + 1):
            # Check cancel flag
            if hasattr(self, '_current_cancel_flag') and self._current_cancel_flag():
                print(f"  [Mac Factory] CANCELLED by user at cycle {cycle}")
                guard.print_summary()
                active_safety_guards.pop(job_id, None)
                return {"status": "cancelled", "result": {
                    "cycles": cycle - 1, "cycle_history": cycle_history,
                    "regeneration_cost": regen_agent.total_cost,
                    "message": "Cancelled by user",
                    "safety": guard.get_status(),
                }}

            # Safety Guard: budget/timeout/heartbeat check before each cycle
            if not guard.check():
                print(f"  [Safety Guard] Stopping build_and_fix at cycle {cycle}: {guard.stop_reason}")
                guard.print_summary()
                active_safety_guards.pop(job_id, None)
                return {"status": "stopped", "result": {
                    "stop_reason": guard.stop_reason,
                    "cycles": cycle - 1,
                    "cycle_history": cycle_history,
                    "regeneration_cost": regen_agent.total_cost,
                    "safety": guard.get_status(),
                }}

            # Sync guard's cost with regen_agent's running total (regen makes LLM calls outside guard)
            new_regen_cost = regen_agent.total_cost - getattr(self, '_last_regen_cost_sync', 0)
            if new_regen_cost > 0:
                guard.total_cost += new_regen_cost
                self._last_regen_cost_sync = regen_agent.total_cost

            print(f"\n  ══ Cycle {cycle}/{max_cycles} ══")

            # Step 1: Pre-Build Cleanup
            PreBuildCleanup(project_dir).run()

            # Step 2: xcodegen
            if not self._run_xcodegen(project_dir, project):
                cycle_history.append({"cycle": cycle, "phase": "xcodegen", "errors": -1})
                guard.print_summary()
                active_safety_guards.pop(job_id, None)
                return {"status": "failed", "result": {
                    "error": "xcodegen failed", "cycles": cycle,
                    "cycle_history": cycle_history,
                    "regeneration_cost": regen_agent.total_cost,
                    "safety": guard.get_status(),
                }}

            # Step 3: Build + Repair (Tier 1-2)
            scheme = self._find_scheme(project_dir, project)
            engine = SwiftRepairEngine(project_dir=project_dir, scheme=scheme, config=self.config)
            build_result = engine.build_and_repair()

            error_count = build_result.get("final_errors", 0)
            cycle_history.append({
                "cycle": cycle,
                "phase": "build+repair",
                "errors_after_repair": error_count,
                "repair_cost": build_result.get("repair_cost", 0),
            })

            print(f"  Cycle {cycle}: {error_count} errors after repair")

            if build_result.get("build_succeeded"):
                # Build OK → run tests if available
                print(f"  BUILD SUCCEEDED in cycle {cycle}!")
                test_result = {}
                if self.config.get("post_build", {}).get("auto_test", False):
                    print(f"  Running post-build tests...")
                    test_result = self._execute_tests(project_dir, scheme)

                guard.print_summary()
                active_safety_guards.pop(job_id, None)
                return {"status": "success", "result": {
                    "build_succeeded": True,
                    "cycles": cycle,
                    "cycle_history": cycle_history,
                    "final_errors": 0,
                    "repair_cost": build_result.get("repair_cost", 0),
                    "regeneration_cost": regen_agent.total_cost,
                    "total_cost": build_result.get("repair_cost", 0) + regen_agent.total_cost,
                    "tests_executed": bool(test_result),
                    "tests_passed": test_result.get("tests_passed", 0),
                    "tests_failed": test_result.get("tests_failed", 0),
                    "cost_summary": regen_agent.get_cost_summary(),
                    "safety": guard.get_status(),
                }}

            # Step 4: Build failed after repair → File Regeneration (Tier 4)
            error_details = build_result.get("error_details", [])
            if not error_details:
                print(f"  No error details available — stopping")
                break

            failed_files = list(set(e["file"] for e in error_details if e.get("file")))
            print(f"  [Regen] {len(failed_files)} files need regeneration")

            regen_result = regen_agent.regenerate_files(
                failed_files=failed_files,
                error_details=error_details,
                project_dir=project_dir,
            )

            cycle_history[-1]["regenerated"] = regen_result.get("regenerated", 0)
            cycle_history[-1]["regen_cost"] = regen_result.get("cost", 0)

            # Commit regenerated files so next cycle's rollback won't lose them
            subprocess.run(["git", "add", project_dir], cwd=self.repo_path,
                           capture_output=True, timeout=30)
            subprocess.run(["git", "commit", "-m", f"Regen cycle {cycle}: {regen_result.get('regenerated', 0)} files"],
                           cwd=self.repo_path, capture_output=True, timeout=30)

            if not regen_result.get("any_regenerated"):
                print(f"  No files could be regenerated — stopping")
                break

            # Next cycle...

        # Max cycles or no progress
        # Final build to get current error count
        self._run_xcodegen(project_dir, project)
        engine = SwiftRepairEngine(project_dir=project_dir,
                                  scheme=self._find_scheme(project_dir, project),
                                  config={**self.config, "max_repair_iterations": 0})
        final = engine.build_and_repair()

        guard.print_summary()
        active_safety_guards.pop(job_id, None)
        return {"status": "failed", "result": {
            "build_succeeded": False,
            "cycles": len(cycle_history),
            "cycle_history": cycle_history,
            "final_errors": final.get("final_errors", 0),
            "error_details": final.get("error_details", []),
            "repair_cost": sum(c.get("repair_cost", 0) for c in cycle_history),
            "regeneration_cost": regen_agent.total_cost,
            "total_cost": sum(c.get("repair_cost", 0) for c in cycle_history) + regen_agent.total_cost,
            "stubborn_files": regen_agent.get_stubborn_files(),
            "cost_summary": regen_agent.get_cost_summary(),
            "safety": guard.get_status(),
        }}

    # ── Granular Commands (for Production Supervisor) ────────

    def _compile_check(self, cmd):
        """Compile-only check. No repairs, no file changes. Read-only."""
        project = cmd.get("project", cmd.get("params", {}).get("project", ""))
        project_dir = os.path.join(self.repo_path, "projects", project)

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        # Ensure xcodeproj exists
        if not list(Path(project_dir).glob("*.xcodeproj")):
            PreBuildCleanup(project_dir).run()
            if not self._run_xcodegen(project_dir, project):
                return {"status": "failed", "result": {"error": "xcodegen failed"}}

        xcodeproj = list(Path(project_dir).glob("*.xcodeproj"))
        scheme = self._find_scheme(project_dir, project)

        cmd_args = [
            "xcodebuild", "-project", str(xcodeproj[0]),
            "-scheme", scheme,
            "-destination", "platform=iOS Simulator,name=iPhone 17 Pro",
            "-configuration", "Debug",
            "CODE_SIGNING_ALLOWED=NO",
            "build",
        ]

        print(f"  [Mac Agent] compile_check: {project} (scheme: {scheme})")
        start = time.time()
        try:
            result = subprocess.run(cmd_args, capture_output=True, text=True,
                                   timeout=300, cwd=project_dir)
            output = result.stdout + "\n" + result.stderr
        except subprocess.TimeoutExpired:
            return {"status": "failed", "result": {"error": "Build timed out (300s)"}}

        elapsed = round(time.time() - start, 1)

        # Parse errors and warnings
        error_pattern = re.compile(r'(.+\.swift):(\d+):(\d+):\s+(error|warning):\s+(.+)')
        errors = []
        warnings = []
        for line in output.split("\n"):
            m = error_pattern.match(line.strip())
            if m:
                entry = {"file": m.group(1), "line": int(m.group(2)),
                         "column": int(m.group(3)), "message": m.group(5)}
                if m.group(4) == "error":
                    errors.append(entry)
                else:
                    warnings.append(entry)

        print(f"  [Mac Agent] compile_check: {len(errors)} errors, {len(warnings)} warnings ({elapsed}s)")

        return {"status": "success", "result": {
            "error_count": len(errors),
            "warning_count": len(warnings),
            "errors": errors[:200],
            "warnings": warnings[:50],
            "build_time_seconds": elapsed,
            "scheme": scheme,
        }}

    def _repair_tier1(self, cmd):
        """Deterministic repair only. No LLM, no cost."""
        project = cmd.get("project", cmd.get("params", {}).get("project", ""))
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project)

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        from repair.deterministic import DeterministicFixer
        from repair.error_parser import XcodeError

        # Convert error dicts to XcodeError objects
        error_dicts = params.get("errors", [])
        xcode_errors = []
        for e in error_dicts:
            xcode_errors.append(XcodeError(
                file=e.get("file", ""), line=e.get("line", 0),
                column=e.get("column", 0), severity="error",
                message=e.get("message", "")))

        print(f"  [Mac Agent] repair_tier1: {len(xcode_errors)} errors to fix")
        start = time.time()
        fixer = DeterministicFixer(project_dir)
        fixes = fixer.fix_all(xcode_errors)
        elapsed = round(time.time() - start, 1)

        # Regenerate xcodeproj if files changed
        if fixes > 0:
            self._run_xcodegen(project_dir, project)

        print(f"  [Mac Agent] repair_tier1: {fixes} fixes applied ({elapsed}s)")

        return {"status": "success", "result": {
            "files_modified": fixes,
            "duration_seconds": elapsed,
        }}

    def _repair_tier2(self, cmd):
        """LLM-based repair. Costs money."""
        project = cmd.get("project", cmd.get("params", {}).get("project", ""))
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project)
        max_files = params.get("max_files", 10)

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        from repair.llm_repair import LLMRepairer
        from repair.error_parser import XcodeError, XcodeErrorParser

        error_dicts = params.get("errors", [])
        xcode_errors = [XcodeError(file=e.get("file", ""), line=e.get("line", 0),
                                    column=e.get("column", 0), severity="error",
                                    message=e.get("message", ""))
                        for e in error_dicts]

        # Group by file
        parser = XcodeErrorParser()
        grouped = parser.group_by_file(xcode_errors)

        repairer = LLMRepairer(self.config)
        files_fixed = 0

        print(f"  [Mac Agent] repair_tier2: {len(grouped)} files, max {max_files}")
        start = time.time()

        for filepath, file_errors in list(grouped.items())[:max_files]:
            if len(file_errors) <= 8:
                if repairer.fix_file(filepath, file_errors, tier=2):
                    files_fixed += 1

        elapsed = round(time.time() - start, 1)

        if files_fixed > 0:
            self._run_xcodegen(project_dir, project)

        print(f"  [Mac Agent] repair_tier2: {files_fixed} files fixed, ${repairer.total_cost:.4f} ({elapsed}s)")

        return {"status": "success", "result": {
            "files_modified": files_fixed,
            "cost": round(repairer.total_cost, 4),
            "model_used": self.config.get("repair_models", {}).get("tier2", "unknown"),
            "duration_seconds": elapsed,
        }}

    def _regenerate_cmd(self, cmd):
        """Regenerate specific files completely via LLM."""
        project = cmd.get("project", cmd.get("params", {}).get("project", ""))
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project)
        max_files = params.get("max_files", 5)

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        from repair.file_regeneration import FileRegenerationAgent

        # File list: explicit or from errors
        files = params.get("files", [])
        if files:
            # Make absolute paths
            files = [os.path.join(project_dir, f) if not os.path.isabs(f) else f for f in files]
        else:
            # Auto-detect from errors
            error_dicts = params.get("errors", [])
            files = list(set(e.get("file", "") for e in error_dicts if e.get("file")))

        files = [f for f in files if os.path.isfile(f)][:max_files]

        if not files:
            return {"status": "success", "result": {"files_regenerated": 0, "cost": 0, "note": "No files to regenerate"}}

        error_dicts = params.get("errors", [])

        print(f"  [Mac Agent] regenerate: {len(files)} files")
        start = time.time()

        regen = FileRegenerationAgent(config=self.config)
        result = regen.regenerate_files(
            failed_files=files, error_details=error_dicts, project_dir=project_dir)

        elapsed = round(time.time() - start, 1)

        if result.get("regenerated", 0) > 0:
            self._run_xcodegen(project_dir, project)

        print(f"  [Mac Agent] regenerate: {result.get('regenerated', 0)} files, ${regen.total_cost:.4f} ({elapsed}s)")

        return {"status": "success", "result": {
            "files_regenerated": result.get("regenerated", 0),
            "cost": round(regen.total_cost, 4),
            "duration_seconds": elapsed,
            "file_results": result.get("file_results", []),
        }}

    def _save_checkpoint(self, cmd):
        """Commit current state as checkpoint."""
        project = cmd.get("project", cmd.get("params", {}).get("project", ""))
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project)
        message = params.get("message", f"Checkpoint: {project}")

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        print(f"  [Mac Agent] save_checkpoint: {project}")

        # git add + commit
        subprocess.run(["git", "add", "-A"], cwd=project_dir,
                       capture_output=True, timeout=120)
        r = subprocess.run(["git", "commit", "-m", f"[Checkpoint] {message}"],
                          cwd=project_dir, capture_output=True, text=True, timeout=120)

        if r.returncode != 0:
            # Nothing to commit
            if "nothing to commit" in r.stdout + r.stderr:
                # Get current hash
                h = subprocess.run(["git", "rev-parse", "--short", "HEAD"],
                                  cwd=project_dir, capture_output=True, text=True, timeout=5)
                return {"status": "success", "result": {
                    "commit_hash": h.stdout.strip(), "files_committed": 0, "message": message}}
            return {"status": "failed", "result": {"error": r.stderr[:200]}}

        # Get commit hash
        h = subprocess.run(["git", "rev-parse", "--short", "HEAD"],
                          cwd=project_dir, capture_output=True, text=True, timeout=5)

        # Count committed files
        d = subprocess.run(["git", "diff", "--name-only", "HEAD~1", "HEAD"],
                          cwd=project_dir, capture_output=True, text=True, timeout=10)
        file_count = len([l for l in d.stdout.strip().split("\n") if l])

        print(f"  [Mac Agent] checkpoint saved: {h.stdout.strip()} ({file_count} files)")

        return {"status": "success", "result": {
            "commit_hash": h.stdout.strip(),
            "files_committed": file_count,
            "message": message,
        }}

    def _rollback_checkpoint(self, cmd):
        """Rollback to a specific checkpoint."""
        project = cmd.get("project", cmd.get("params", {}).get("project", ""))
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project)
        to_commit = params.get("to_commit", "")

        if not os.path.exists(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        target = to_commit if to_commit else "HEAD~1"
        print(f"  [Mac Agent] rollback_checkpoint: {project} → {target}")

        # Restore files from target commit
        r = subprocess.run(["git", "checkout", target, "--", "."],
                          cwd=project_dir, capture_output=True, text=True, timeout=120)

        if r.returncode != 0:
            return {"status": "failed", "result": {"error": f"Rollback failed: {r.stderr[:200]}"}}

        # Clean untracked files
        subprocess.run(["git", "clean", "-fd"], cwd=project_dir,
                       capture_output=True, timeout=30)

        # Regenerate xcodeproj
        self._run_xcodegen(project_dir, project)

        # Count restored files
        d = subprocess.run(["git", "diff", "--name-only"],
                          cwd=project_dir, capture_output=True, text=True, timeout=10)
        restored = len([l for l in d.stdout.strip().split("\n") if l]) if d.stdout.strip() else 0

        print(f"  [Mac Agent] rolled back to {target}")

        return {"status": "success", "result": {
            "rolled_back_to": target,
            "files_restored": restored,
        }}

    # ── deep_repair ────────────────────────────────────────────

    def _deep_repair(self, cmd):
        """Context-aware full file rewrite using Sonnet (follows instructions strictly)."""
        import litellm

        project = cmd.get("project", cmd.get("params", {}).get("project", ""))
        params = cmd.get("params", {})
        file_path = params.get("file_path", "")
        project_dir = os.path.join(self.repo_path, "projects", project)
        max_context = params.get("max_context_files", 10)
        error_dicts = params.get("errors", [])

        if not os.path.isabs(file_path):
            file_path = os.path.join(project_dir, file_path)

        if not os.path.isfile(file_path):
            return {"status": "failed", "result": {"error": f"File not found: {file_path}"}}

        filename = os.path.basename(file_path)
        type_name = os.path.splitext(filename)[0]
        print(f"  [Mac Agent] deep_repair: {filename}")

        broken_content = open(file_path, encoding="utf-8").read()
        errors_before = self._quick_error_count(project_dir, project)
        print(f"  [Mac Agent] Errors before: {errors_before}")

        context_files = self._find_deep_context(project_dir, file_path, max_context)
        print(f"  [Mac Agent] Context files: {len(context_files)}")

        error_text = "\n".join(f"Line {e.get('line', '?')}: {e.get('message', '?')}" for e in error_dicts)
        context_text = ""
        for cp, cc in context_files:
            context_text += f"\n--- {cp} ---\n{cc}\n"

        # Use Sonnet specifically — follows "only code" instructions much better than Opus
        model = "claude-sonnet-4-20250514"
        llm_model = f"anthropic/{model}"

        system_prompt = """You are a Swift code generator. You output ONLY valid, compilable Swift source code.

CRITICAL RULES:
- Your ENTIRE response must be valid Swift code that can be saved directly as a .swift file
- Do NOT include markdown code fences (```)
- Do NOT include any explanations, comments about your thinking, or analysis
- Do NOT start with "Here's", "Looking at", "The error", "I need to", or any English text
- Start your response with 'import' or a Swift declaration (class, struct, enum, protocol)
- If you include comments, they must be valid Swift comments (// or /* */)
- Use ONLY Apple frameworks (Foundation, SwiftUI, Combine, CoreLocation, etc.)
- NO third-party libraries (no GRDB, Realm, Alamofire, Kingfisher)
- Every method must have a real implementation (no TODO, no placeholder, no '...')
- Your response will be written DIRECTLY to a .swift file — if it's not valid Swift, the build breaks

RESPOND WITH ONLY THE SWIFT CODE. NOTHING ELSE."""

        user_prompt = f"""REWRITE this Swift file. Output ONLY the complete Swift source code.

FILE: {filename}

CURRENT CONTENT (broken):
{broken_content[:4000]}

COMPILE ERRORS:
{error_text[:2000]}

CONTEXT — FILES THAT REFERENCE {type_name}:
{context_text[:8000]}

REQUIREMENTS:
- Must define: {type_name}
- Must compile with zero errors
- Must be compatible with the context files above

RESPOND WITH ONLY THE COMPLETE SWIFT CODE FOR {filename}.
START WITH 'import' — NO OTHER TEXT BEFORE IT."""

        total_cost = 0.0
        clean = None

        # Attempt 1
        print(f"  [Mac Agent] Calling LLM ({model})...")
        start = time.time()
        try:
            response = litellm.completion(
                model=llm_model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_prompt},
                ],
                max_tokens=8000, temperature=0.0,
            )
            output = response.choices[0].message.content.strip()
            total_cost += litellm.completion_cost(response)
            clean = self._sanitize_llm_output(output)
        except Exception as e:
            return {"status": "failed", "result": {"error": f"LLM failed: {e}", "file_path": file_path}}

        # Attempt 2 (retry) if sanitization failed
        if not clean:
            print(f"  [Mac Agent] First attempt produced invalid output — retrying with stricter prompt...")
            try:
                retry_response = litellm.completion(
                    model=llm_model,
                    messages=[
                        {"role": "system", "content": "You output ONLY Swift code. No markdown. No explanations. Start with 'import'."},
                        {"role": "user", "content": f"""CRITICAL: Output ONLY Swift code for {filename}.
Start with 'import Foundation' or 'import SwiftUI'.
No English text. No markdown fences. No analysis.

The file must define: {type_name}
Errors to fix: {error_text[:500]}

SWIFT CODE ONLY:"""},
                    ],
                    max_tokens=4000, temperature=0.0,
                )
                output2 = retry_response.choices[0].message.content.strip()
                total_cost += litellm.completion_cost(retry_response)
                clean = self._sanitize_llm_output(output2)
            except Exception:
                pass

        elapsed = round(time.time() - start, 1)

        if not clean:
            print(f"  [Mac Agent] deep_repair FAILED — could not get valid Swift from LLM")
            return {"status": "failed", "result": {
                "error": "LLM output was not valid Swift after 2 attempts",
                "file_path": file_path, "cost": round(total_cost, 4),
            }}

        # Write and validate
        backup = broken_content
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(clean)

        self._run_xcodegen(project_dir, project)
        errors_after = self._quick_error_count(project_dir, project)
        print(f"  [Mac Agent] Errors after: {errors_after} (was {errors_before})")

        if errors_after > errors_before:
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(backup)
            self._run_xcodegen(project_dir, project)
            print(f"  [Mac Agent] ROLLED BACK — rewrite made it worse ({errors_before} → {errors_after})")
            return {"status": "failed", "result": {
                "file_path": file_path, "errors_before": errors_before,
                "errors_after": errors_after, "rolled_back": True,
                "cost": round(total_cost, 4), "duration_seconds": elapsed,
            }}

        print(f"  [Mac Agent] deep_repair SUCCESS: {filename} ({errors_before} → {errors_after})")
        return {"status": "success", "result": {
            "file_path": file_path, "errors_before": errors_before,
            "errors_after": errors_after, "context_files_used": len(context_files),
            "cost": round(total_cost, 4), "duration_seconds": elapsed,
            "rewrite_validated": True, "model": model,
        }}

    def _find_deep_context(self, project_dir, target_file, max_files=10):
        """Find files that reference the target, plus siblings."""
        filename = os.path.basename(target_file)
        type_name = os.path.splitext(filename)[0]
        target_dir = os.path.dirname(target_file)
        seen = {os.path.abspath(target_file)}
        results = []

        # Strategy 1: grep for references to the type name
        try:
            r = subprocess.run(
                ["grep", "-rl", type_name, "--include=*.swift", "."],
                cwd=project_dir, capture_output=True, text=True, timeout=10)
            for line in r.stdout.strip().split("\n"):
                if not line:
                    continue
                fp = os.path.join(project_dir, line.lstrip("./"))
                if os.path.abspath(fp) not in seen and os.path.isfile(fp):
                    content = self._safe_read_truncated(fp, 200)
                    if content:
                        results.append((os.path.relpath(fp, project_dir), content))
                        seen.add(os.path.abspath(fp))
                if len(results) >= max_files:
                    break
        except Exception:
            pass

        # Strategy 2: Siblings in same directory
        if len(results) < max_files and os.path.isdir(target_dir):
            for f in sorted(os.listdir(target_dir)):
                if len(results) >= max_files:
                    break
                if not f.endswith(".swift"):
                    continue
                fp = os.path.join(target_dir, f)
                if os.path.abspath(fp) not in seen:
                    content = self._safe_read_truncated(fp, 150)
                    if content:
                        results.append((os.path.relpath(fp, project_dir), content))
                        seen.add(os.path.abspath(fp))

        # Strategy 3: Protocol files
        if len(results) < max_files:
            proto_name = type_name + "Protocol"
            for root, dirs, files in os.walk(project_dir):
                if "quarantine" in root or "Tests" in root:
                    continue
                for f in files:
                    if proto_name in f and f.endswith(".swift"):
                        fp = os.path.join(root, f)
                        if os.path.abspath(fp) not in seen:
                            content = self._safe_read_truncated(fp, 200)
                            if content:
                                results.append((os.path.relpath(fp, project_dir), content))
                                seen.add(os.path.abspath(fp))

        return results[:max_files]

    def _sanitize_llm_output(self, output):
        """Clean LLM output to extract valid Swift code. Tries 4 strategies."""
        if not output or not output.strip():
            return None

        text = output.strip()
        swift_starters = ('import ', 'class ', 'struct ', 'enum ', 'protocol ', 'func ',
                         'let ', 'var ', '//', '/*', '@', 'public ', 'private ',
                         'internal ', 'open ', 'final ', 'extension ', 'actor ',
                         'typealias ', '#if')

        # Strategy 1: Output starts with Swift keyword — it's clean
        if any(text.startswith(s) for s in swift_starters):
            return self._strip_trailing_explanation(text)

        # Strategy 2: Extract from markdown code fences
        fence_matches = re.findall(r'```(?:swift)?\s*\n(.*?)```', text, re.DOTALL)
        if fence_matches:
            best = max(fence_matches, key=len).strip()
            if len(best) > 50 and any(best.startswith(s) for s in swift_starters):
                return self._strip_trailing_explanation(best)

        # Strategy 3: Find first Swift line and take everything from there
        lines = text.split('\n')
        for i, line in enumerate(lines):
            stripped = line.strip()
            if any(stripped.startswith(s) for s in swift_starters):
                swift_section = '\n'.join(lines[i:])
                swift_section = self._strip_trailing_explanation(swift_section)
                if len(swift_section) > 50:
                    return swift_section

        # Strategy 4: Filter out obvious non-code lines
        code_lines = []
        skip_prefixes = ('```', 'Here', 'This ', 'The ', 'I ', 'Note', 'Looking',
                        'Wait', 'Let me', 'First', 'Now', 'Finally', 'Based on',
                        'Sure', 'Of course', 'Below')
        for line in lines:
            stripped = line.strip()
            if any(stripped.startswith(p) for p in skip_prefixes):
                continue
            if stripped:
                code_lines.append(line)

        if code_lines and len('\n'.join(code_lines)) > 50:
            result = '\n'.join(code_lines)
            if any(result.strip().startswith(s) for s in swift_starters):
                return result

        print(f"  [Mac Agent] Sanitization failed — could not extract Swift from {len(text)} chars")
        return None

    def _strip_trailing_explanation(self, code):
        """Remove trailing explanation text after code ends."""
        lines = code.split('\n')
        last_code = len(lines)
        for i in range(len(lines) - 1, -1, -1):
            stripped = lines[i].strip()
            if stripped and not stripped.startswith(('Note:', 'This ', 'The above',
                                                     'I ', '---', 'Key ', 'Explanation')):
                last_code = i + 1
                break
        return '\n'.join(lines[:last_code]).rstrip()

    def _safe_read_truncated(self, filepath, max_lines=200):
        """Read file, truncated to max_lines."""
        try:
            with open(filepath, encoding="utf-8") as f:
                lines = f.readlines()[:max_lines]
            return "".join(lines)
        except Exception:
            return ""

    def _quick_error_count(self, project_dir, project_name):
        """Quick compile and count errors."""
        xcodeproj = list(Path(project_dir).glob("*.xcodeproj"))
        if not xcodeproj:
            self._run_xcodegen(project_dir, project_name)
            xcodeproj = list(Path(project_dir).glob("*.xcodeproj"))
        if not xcodeproj:
            return 9999

        scheme = self._find_scheme(project_dir, project_name)
        cmd = ["xcodebuild", "-project", str(xcodeproj[0]), "-scheme", scheme,
               "-destination", "platform=iOS Simulator,name=iPhone 17 Pro",
               "-configuration", "Debug", "CODE_SIGNING_ALLOWED=NO", "build"]

        try:
            r = subprocess.run(cmd, capture_output=True, text=True,
                              timeout=300, cwd=project_dir)
            return sum(1 for line in (r.stdout + r.stderr).split("\n") if re.match(r'.+\.swift:\d+:\d+:\s+error:', line))
        except Exception:
            return 9999

    # ── Helpers ───────────────────────────────────────────────

    def _parse_generated_files(self, text):
        files = {}
        for m in re.finditer(r'// === FILENAME: (.+?) ===\n(.*?)// === END: \1 ===', text, re.DOTALL):
            name, code = m.group(1).strip(), m.group(2).strip()
            if code and len(code) > 10:
                files[name] = code
        return files

    def _route_file(self, project_dir, filename):
        n = filename.lower()
        if "viewmodel" in n: return os.path.join(project_dir, "ViewModels")
        if "view" in n: return os.path.join(project_dir, "Views")
        if "service" in n or "protocol" in n: return os.path.join(project_dir, "Services")
        return os.path.join(project_dir, "Models")

    def _supervised_build(self, cmd):
        """Mac Supervisor — autonomous iOS build pipeline."""
        from mac_factory.supervisor.mac_supervisor import MacSupervisor

        project_name = cmd.get("project", "")
        params = cmd.get("params", {})
        project_dir = os.path.join(self.repo_path, "projects", project_name)

        if not os.path.isdir(project_dir):
            return {"status": "failed", "result": {"error": f"Project not found: {project_dir}"}}

        # Create external safety guard so it's accessible for /status heartbeat
        job_id = cmd.get("_job_id") or cmd.get("id") or f"supervised_{project_name}_{int(time.time())}"
        guard = SafetyGuard(
            job_id=job_id,
            budget_limit=params.get("budget_limit", 2.00),
            timeout_minutes=params.get("timeout_minutes", 30),
            heartbeat_timeout_minutes=params.get("heartbeat_timeout_minutes", 5),
        )
        active_safety_guards[job_id] = guard

        try:
            supervisor = MacSupervisor(
                project_dir=project_dir,
                project_name=project_name,
                config=self.config
            )
            roadbook_path = params.get("roadbook_path", "")
            if roadbook_path and not os.path.isabs(roadbook_path):
                roadbook_path = os.path.join(project_dir, roadbook_path)

            result = supervisor.run(
                max_cycles=params.get("max_cycles", 10),
                budget_limit=params.get("budget_limit", 2.00),
                timeout_minutes=params.get("timeout_minutes", 30),
                archive_on_success=params.get("archive_on_success", True),
                job_id=job_id,
                external_guard=guard,
                roadbook_path=roadbook_path,
            )
            status = "success" if result.status == "SUCCESS" else "failed"
            return {"status": status, "result": result.to_dict()}
        finally:
            active_safety_guards.pop(job_id, None)

    def _run_xcodegen(self, project_dir, project_name):
        project_yml = os.path.join(project_dir, "project.yml")
        if not os.path.exists(project_yml):
            self._generate_project_yml(project_dir, project_name)

        for item in os.listdir(project_dir):
            if item.endswith(".xcodeproj"):
                shutil.rmtree(os.path.join(project_dir, item), ignore_errors=True)

        try:
            result = subprocess.run(["xcodegen", "generate"], cwd=project_dir,
                                   capture_output=True, text=True,
                                   timeout=self.config.get("xcodegen_timeout", 45))
            if result.returncode == 0:
                print(f"    xcodegen: OK")
                return True
            print(f"    xcodegen FAILED: {result.stderr[:200]}")
            return False
        except subprocess.TimeoutExpired:
            subprocess.run(["pkill", "-f", "xcodegen"], capture_output=True)
            return False
        except FileNotFoundError:
            print("    xcodegen not installed")
            return False

    def _generate_project_yml(self, project_dir, name):
        source_dirs = set()
        for item in os.listdir(project_dir):
            p = os.path.join(project_dir, item)
            if os.path.isdir(p) and item not in ("quarantine", "Tests", "UITests", "build",
                                                   ".build", "DerivedData", "specs",
                                                   "store_submission", "qa_screenshots"):
                if any(f.endswith(".swift") for f in os.listdir(p)):
                    source_dirs.add(item)
        if not source_dirs:
            source_dirs = {"."}

        scheme_name = name.replace("-", "").replace("_", "")
        yml = f"name: {scheme_name}\noptions:\n  bundleIdPrefix: com.driveai\n  deploymentTarget:\n    iOS: \"17.0\"\n\ntargets:\n  {scheme_name}:\n    type: application\n    platform: iOS\n    sources:\n"
        for d in sorted(source_dirs):
            yml += f"      - path: {d}\n"
        yml += "    settings:\n      base:\n        SWIFT_VERSION: \"5.9\"\n        GENERATE_INFOPLIST_FILE: true\n        TARGETED_DEVICE_FAMILY: \"1,2\"\n        INFOPLIST_KEY_UIApplicationSceneManifest_Generation: true\n        INFOPLIST_KEY_UILaunchScreen_Generation: true\n        INFOPLIST_KEY_UISupportedInterfaceOrientations_iPhone: \"UIInterfaceOrientationPortrait\"\n"
        with open(os.path.join(project_dir, "project.yml"), "w") as f:
            f.write(yml)
        print(f"    Generated project.yml (sources: {sorted(source_dirs)})")

    def _find_scheme(self, project_dir, project_name):
        yml_path = os.path.join(project_dir, "project.yml")
        if os.path.exists(yml_path):
            try:
                with open(yml_path) as f:
                    data = yaml.safe_load(f)
                if data and "name" in data:
                    return data["name"]
            except Exception:
                pass
        return project_name.replace("-", "").replace("_", "")

    def _get_xcode_version(self):
        try:
            r = subprocess.run(["xcodebuild", "-version"], capture_output=True, text=True, timeout=10)
            return r.stdout.strip().split("\n")[0]
        except Exception:
            return "unknown"


class PreBuildCleanup:
    def __init__(self, project_dir):
        self.project_dir = project_dir

    def run(self):
        self._quarantine_junk()
        self._move_tests()
        self._remove_framework_stubs()
        self._ensure_main_entry()

    def _quarantine_junk(self):
        quarantine = os.path.join(self.project_dir, "quarantine")
        for root, dirs, files in os.walk(self.project_dir):
            if "quarantine" in root: continue
            for f in files:
                if os.path.splitext(f)[0] in ("GeneratedHelpers", "GeneratedCode") and f.endswith(".swift"):
                    os.makedirs(quarantine, exist_ok=True)
                    src, dst = os.path.join(root, f), os.path.join(quarantine, f)
                    if os.path.exists(dst): os.remove(src)
                    else: shutil.move(src, dst)
                    print(f"    Quarantined: {f}")

    def _move_tests(self):
        tests_dir = os.path.join(self.project_dir, "Tests")
        for root, dirs, files in os.walk(self.project_dir):
            if "Tests" in root or "UITests" in root or "quarantine" in root: continue
            for f in files:
                if f.endswith("Tests.swift") or f.endswith("Test.swift"):
                    os.makedirs(tests_dir, exist_ok=True)
                    src, dst = os.path.join(root, f), os.path.join(tests_dir, f)
                    if os.path.exists(dst): os.remove(src)
                    else: shutil.move(src, dst)
                    print(f"    Moved to Tests/: {f}")

    def _remove_framework_stubs(self):
        quarantine = os.path.join(self.project_dir, "quarantine")
        stubs = {"Hashable","Task","Color","String","Array","Dictionary","Calendar","Timer",
                 "UserDefaults","Foundation","SwiftUI","Codable","Identifiable","Equatable",
                 "Comparable","View","Text","Button","Image","NavigationView","MainActor",
                 "HStack","VStack","ZStack","Preview","TimeInterval","LocalizedError",
                 "NSPersistentContainer","XCTest","XCTestCase","DriveAI","DriveAIDomain","Sendable"}
        for root, dirs, files in os.walk(self.project_dir):
            if "quarantine" in root or "Tests" in root: continue
            for f in files:
                if os.path.splitext(f)[0] in stubs and f.endswith(".swift"):
                    fp = os.path.join(root, f)
                    try:
                        lines = [l for l in open(fp, encoding="utf-8").read().strip().split("\n")
                                if l.strip() and not l.strip().startswith("//")]
                        if len(lines) <= 20:
                            os.makedirs(quarantine, exist_ok=True)
                            dst = os.path.join(quarantine, f)
                            if os.path.exists(dst): os.remove(fp)
                            else: shutil.move(fp, dst)
                            print(f"    Stub quarantined: {f}")
                    except Exception: pass

    def _ensure_main_entry(self):
        has_main = False
        for root, _, files in os.walk(self.project_dir):
            if "quarantine" in root or "Tests" in root: continue
            for f in files:
                if f.endswith(".swift"):
                    try:
                        if "@main" in open(os.path.join(root, f), encoding="utf-8").read():
                            has_main = True; break
                    except Exception: pass
            if has_main: break

        if not has_main:
            app_name = os.path.basename(self.project_dir).replace("-", "").replace("_", "")
            app_name = app_name[0].upper() + app_name[1:] if app_name else "App"
            td = os.path.join(self.project_dir, "Views") if os.path.isdir(os.path.join(self.project_dir, "Views")) else self.project_dir
            af = os.path.join(td, f"{app_name}App.swift")
            if not os.path.exists(af):
                with open(af, "w") as f:
                    f.write(f"import SwiftUI\n\n@main\nstruct {app_name}App: App {{\n    var body: some Scene {{\n        WindowGroup {{\n            ContentView()\n        }}\n    }}\n}}\n")
                print(f"    Generated: {app_name}App.swift")
            has_cv = any("ContentView.swift" in fs for _, _, fs in os.walk(self.project_dir) if "quarantine" not in _)
            if not has_cv:
                with open(os.path.join(td, "ContentView.swift"), "w") as f:
                    f.write("import SwiftUI\n\nstruct ContentView: View {\n    var body: some View {\n        NavigationStack { Text(\"Welcome\").font(.title) }\n    }\n}\n")
                print(f"    Generated: ContentView.swift")


if __name__ == "__main__":
    try:
        import litellm
    except ImportError:
        print("Missing litellm. Run: pip3 install -r requirements.txt")
        sys.exit(1)

    if not os.environ.get("ANTHROPIC_API_KEY"):
        env_path = os.path.join(os.path.dirname(__file__), ".env")
        if os.path.exists(env_path): load_dotenv(env_path)
        if not os.environ.get("ANTHROPIC_API_KEY"):
            print("WARNING: No ANTHROPIC_API_KEY — LLM Repair won't work")

    try:
        subprocess.run(["xcodebuild", "-version"], capture_output=True, timeout=10)
    except Exception:
        print("ERROR: Xcode not found"); sys.exit(1)

    config_path = os.path.join(os.path.dirname(__file__), "config.yaml")
    with open(config_path) as f:
        config = yaml.safe_load(f)

    server_cfg = config.get("server", {})
    host = server_cfg.get("host", "0.0.0.0")
    port = server_cfg.get("port", 8420)

    # Get local IP for display
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
    except Exception:
        local_ip = "unknown"

    print("=" * 60)
    print("  Mac Assembly Factory — HTTP Server")
    print(f"  Repo: {os.path.expanduser(config['driveai_repo'])}")
    print(f"  Server: http://{host}:{port}")
    print(f"  Local IP: http://{local_ip}:{port}")
    print(f"  Repair: Tier 2 = {config['repair_models']['tier2']}")
    print(f"  Commands: {', '.join(SUPPORTED_COMMANDS)}")
    print("=" * 60)

    app = create_app(config)

    # Register Mac agents with central registry
    from mac_factory.registration import register_with_central, print_agents
    register_with_central(server_port=port, windows_url=config.get("thebrain_url", ""))
    print_agents()

    app.run(host=host, port=port, debug=False)

"""Mac Build Agent — watches for factory commands, executes, reports back."""
import json
import os
import subprocess
import time
from datetime import datetime
from pathlib import Path
import sys

REPO_PATH = Path(__file__).resolve().parent.parent
COMMANDS_DIR = REPO_PATH / "_commands"
PENDING = COMMANDS_DIR / "pending"
COMPLETED = COMMANDS_DIR / "completed"
POLL_INTERVAL = 30  # seconds


def git_pull():
    subprocess.run(["git", "pull", "--rebase"], cwd=str(REPO_PATH),
                   capture_output=True, timeout=30)


def git_push(message: str = "Mac agent result"):
    subprocess.run(["git", "add", "-A"], cwd=str(REPO_PATH), capture_output=True)
    subprocess.run(["git", "commit", "-m", message], cwd=str(REPO_PATH), capture_output=True)
    subprocess.run(["git", "push"], cwd=str(REPO_PATH), capture_output=True, timeout=30)


def get_pending() -> list[Path]:
    PENDING.mkdir(parents=True, exist_ok=True)
    return sorted(PENDING.glob("*.json"))


def execute_command(cmd: dict) -> dict:
    cmd_type = cmd.get("type", "")
    project = cmd.get("project", "")
    params = cmd.get("params", {})

    if cmd_type == "health_check":
        return {"status": "success", "result": {"xcode": _check_xcode(), "agent": "running"}}

    elif cmd_type == "build_ios":
        return _build_ios(project, params)

    elif cmd_type == "run_tests":
        return _run_tests(project, params)

    elif cmd_type == "screenshots":
        return _run_screenshots(project, params)

    elif cmd_type == "archive":
        return _archive(project, params)

    elif cmd_type == "check_signing":
        return _check_signing(project, params)

    elif cmd_type == "export_ipa":
        return _export_ipa(project, params)

    else:
        return {"status": "error", "result": {"error": f"Unknown command type: {cmd_type}"}}


def _check_xcode() -> str:
    try:
        r = subprocess.run(["xcodebuild", "-version"], capture_output=True, text=True, timeout=10)
        return r.stdout.strip().split("\n")[0]
    except Exception:
        return "not found"


def _xcodegen(project_dir: Path, timeout: int = 45) -> bool:
    """Regenerate xcodeproj from project.yml. Returns True on success."""
    yml = project_dir / "project.yml"
    if not yml.exists():
        return False
    # Remove old xcodeproj to force clean generation
    for old in project_dir.glob("*.xcodeproj"):
        import shutil
        shutil.rmtree(str(old), ignore_errors=True)
    try:
        r = subprocess.run(
            ["xcodegen", "generate", "--spec", str(yml)],
            cwd=str(project_dir), capture_output=True, text=True, timeout=timeout
        )
        if r.returncode == 0:
            print(f"  xcodegen: OK")
            return True
        print(f"  xcodegen: FAILED — {r.stderr[:200]}")
        return False
    except subprocess.TimeoutExpired:
        print(f"  xcodegen: TIMEOUT ({timeout}s) — likely stub files causing hang")
        # Kill any lingering xcodegen processes
        subprocess.run(["pkill", "-f", "xcodegen"], capture_output=True)
        return False


def _pre_build_cleanup(project_dir: Path):
    """Move test files out of app target and remove known junk before xcodegen."""
    import shutil
    models_dir = project_dir / "Models"
    tests_dir = project_dir / "Tests"

    if not models_dir.exists():
        return

    # Move *Tests.swift out of Models/ into Tests/
    test_files = list(models_dir.glob("*Tests.swift"))
    if test_files:
        tests_dir.mkdir(exist_ok=True)
        for tf in test_files:
            dest = tests_dir / tf.name
            if not dest.exists():
                shutil.move(str(tf), str(dest))
                print(f"  pre-clean: moved {tf.name} -> Tests/")

    # Remove known junk files
    junk_names = {"GeneratedHelpers.swift", "GeneratedCode.swift", "Helpers.swift"}
    for jf in junk_names:
        junk = models_dir / jf
        if junk.exists():
            qdir = project_dir / "quarantine"
            qdir.mkdir(exist_ok=True)
            dest = qdir / jf
            if not dest.exists():
                shutil.move(str(junk), str(dest))
            else:
                junk.unlink()
            print(f"  pre-clean: quarantined {jf}")

    # Remove framework-type stub files (Hashable.swift, Task.swift, etc.)
    FRAMEWORK_STUBS = {
        "Hashable", "Equatable", "Codable", "Identifiable", "Comparable", "Sendable",
        "Task", "MainActor", "HStack", "VStack", "ZStack", "Color", "Preview",
        "TimeInterval", "LocalizedError", "NSPersistentContainer", "XCTest",
        "XCTestCase", "DriveAI", "DriveAIDomain",
    }
    for stub_name in FRAMEWORK_STUBS:
        stub = models_dir / f"{stub_name}.swift"
        if stub.exists():
            qdir = project_dir / "quarantine"
            qdir.mkdir(exist_ok=True)
            dest = qdir / stub.name
            if not dest.exists():
                shutil.move(str(stub), str(dest))
            else:
                stub.unlink()
            print(f"  pre-clean: quarantined stub {stub.name}")


def _build_ios(project: str, params: dict) -> dict:
    project_dir = REPO_PATH / "projects" / project
    scheme = params.get("scheme", project.capitalize() if project else "App")
    config = params.get("configuration", "Debug")
    simulator = params.get("simulator", "iPhone 17 Pro")

    if not project_dir.exists():
        return {"status": "error", "result": {"error": f"Project dir not found: {project}"}}

    # Step 1: Pre-build cleanup (test files, stubs, junk)
    _pre_build_cleanup(project_dir)

    # Step 2: Regenerate xcodeproj
    if not _xcodegen(project_dir):
        # Try again after cleanup might have removed problematic stubs
        if not _xcodegen(project_dir, timeout=90):
            return {"status": "error", "result": {"error": "xcodegen failed or timed out"}}

    xcodeproj = list(project_dir.glob("*.xcodeproj"))
    if not xcodeproj:
        return {"status": "error", "result": {"error": "No .xcodeproj found after xcodegen"}}

    # Step 3: Initial build
    cmd = [
        "xcodebuild",
        "-project", str(xcodeproj[0]),
        "-scheme", scheme,
        "-configuration", config,
        "-destination", f"platform=iOS Simulator,name={simulator}",
        "build",
    ]

    start = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=300,
                            cwd=str(project_dir))
    elapsed = time.time() - start

    errors = [l for l in result.stdout.split("\n") if ": error:" in l]
    warnings = [l for l in result.stdout.split("\n") if ": warning:" in l]

    if result.returncode == 0:
        return {
            "status": "success",
            "result": {
                "build_succeeded": True,
                "errors": 0,
                "warnings": len(warnings),
                "build_time_seconds": round(elapsed),
                "repair_iterations": 0,
            }
        }

    # Step 4: Build failed — RepairEngine loop
    print(f"  Build failed with {len(errors)} errors. Starting RepairEngine...")
    try:
        repo_root = str(REPO_PATH)
        if repo_root not in sys.path:
            sys.path.insert(0, repo_root)

        from mac_agent.repair.swift_repair_engine import SwiftRepairEngine
        engine = SwiftRepairEngine(str(project_dir), max_iterations=5)
        repair_result = engine.repair_and_build(scheme, simulator)

        total_elapsed = time.time() - start
        return {
            "status": "success" if repair_result.success else "failed",
            "result": {
                "build_succeeded": repair_result.success,
                "errors": repair_result.final_errors,
                "initial_errors": repair_result.initial_errors,
                "repair_iterations": repair_result.iterations,
                "repair_cost": repair_result.cost,
                "warnings": len(warnings),
                "build_time_seconds": round(total_elapsed),
                "repair_history": repair_result.history,
                "error_details": errors[:20] if not repair_result.success else [],
            }
        }
    except Exception as e:
        print(f"  RepairEngine error: {e}")
        return {
            "status": "failed",
            "result": {
                "build_succeeded": False,
                "errors": len(errors),
                "warnings": len(warnings),
                "error_details": errors[:20],
                "build_time_seconds": round(time.time() - start),
                "repair_error": str(e),
            }
        }


def _run_tests(project: str, params: dict) -> dict:
    project_dir = REPO_PATH / "projects" / project
    suite = params.get("suite", "golden_gates")
    scheme = params.get("scheme", "AskFinPremium")
    simulator = params.get("simulator", "iPhone 17 Pro")

    xcodeproj = list(project_dir.glob("*.xcodeproj"))
    if not xcodeproj:
        return {"status": "error", "result": {"error": "No .xcodeproj found"}}

    cmd = [
        "xcodebuild", "test",
        "-project", str(xcodeproj[0]),
        "-scheme", scheme,
        "-destination", f"platform=iOS Simulator,name={simulator}",
    ]

    start = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=600,
                            cwd=str(project_dir))
    elapsed = time.time() - start

    passed = result.stdout.count("Test Case") - result.stdout.count("failed")
    failed = result.stdout.count("failed")

    return {
        "status": "success" if result.returncode == 0 else "failed",
        "result": {
            "tests_passed": passed,
            "tests_failed": failed,
            "test_time_seconds": round(elapsed),
            "suite": suite,
        }
    }


def _run_screenshots(project: str, params: dict) -> dict:
    # Similar to run_tests but captures screenshots
    return _run_tests(project, {**params, "suite": "screenshots"})


def _archive(project: str, params: dict) -> dict:
    project_dir = REPO_PATH / "projects" / project
    scheme = params.get("scheme", "AskFinPremium")

    xcodeproj = list(project_dir.glob("*.xcodeproj"))
    if not xcodeproj:
        return {"status": "error", "result": {"error": "No .xcodeproj found"}}

    archive_path = project_dir / "build" / f"{scheme}.xcarchive"
    cmd = [
        "xcodebuild",
        "-project", str(xcodeproj[0]),
        "-scheme", scheme,
        "-configuration", "Release",
        "-archivePath", str(archive_path),
        "archive",
    ]

    start = time.time()
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=600,
                            cwd=str(project_dir))
    elapsed = time.time() - start

    return {
        "status": "success" if result.returncode == 0 else "failed",
        "result": {
            "archive_succeeded": result.returncode == 0,
            "archive_path": str(archive_path) if result.returncode == 0 else "",
            "build_time_seconds": round(elapsed),
        }
    }


def _check_signing(project: str, params: dict) -> dict:
    """Check if code signing credentials are available on this Mac."""
    import re as _re

    has_distribution_cert = False
    has_development_cert = False
    cert_name = ""
    identity_count = 0

    # 1. Check code signing identities
    try:
        r = subprocess.run(
            ["security", "find-identity", "-v", "-p", "codesigning"],
            capture_output=True, text=True, timeout=10
        )
        output = r.stdout
        for line in output.split("\n"):
            if "Apple Distribution:" in line or "iPhone Distribution:" in line:
                has_distribution_cert = True
                m = _re.search(r'"(.+?)"', line)
                if m:
                    cert_name = m.group(1)
            if "Apple Development:" in line:
                has_development_cert = True
                if not cert_name:
                    m = _re.search(r'"(.+?)"', line)
                    if m:
                        cert_name = m.group(1)
        # Count valid identities
        m = _re.search(r"(\d+) valid identit", output)
        if m:
            identity_count = int(m.group(1))
    except Exception as e:
        print(f"[Mac Agent] Error checking identities: {e}")

    # 2. Check provisioning profiles
    profile_count = 0
    has_provisioning_profiles = False
    profiles_dir = Path.home() / "Library" / "MobileDevice" / "Provisioning Profiles"
    if profiles_dir.exists():
        profiles = list(profiles_dir.glob("*.mobileprovision"))
        profile_count = len(profiles)
        has_provisioning_profiles = profile_count > 0

    # 3. Try to extract Team ID from first profile
    team_id = ""
    if has_provisioning_profiles:
        try:
            first_profile = list(profiles_dir.glob("*.mobileprovision"))[0]
            r = subprocess.run(
                ["security", "cms", "-D", "-i", str(first_profile)],
                capture_output=True, text=True, timeout=10
            )
            # Parse TeamIdentifier from plist XML
            m = _re.search(r"<key>TeamIdentifier</key>\s*<array>\s*<string>(.+?)</string>", r.stdout)
            if m:
                team_id = m.group(1)
        except Exception as e:
            print(f"[Mac Agent] Error reading profile: {e}")

    # Build summary
    parts = []
    if has_distribution_cert:
        parts.append(f"Distribution cert: {cert_name}")
    elif has_development_cert:
        parts.append(f"Development cert: {cert_name}")
    else:
        parts.append("No signing certificates found")
    parts.append(f"{profile_count} provisioning profile(s)")
    if team_id:
        parts.append(f"Team ID: {team_id}")
    summary = " | ".join(parts)

    print(f"[Mac Agent] Signing check: {summary}")

    return {
        "status": "success",
        "result": {
            "has_distribution_cert": has_distribution_cert,
            "has_development_cert": has_development_cert,
            "cert_name": cert_name,
            "identity_count": identity_count,
            "has_provisioning_profiles": has_provisioning_profiles,
            "profile_count": profile_count,
            "team_id": team_id,
            "summary": summary,
        }
    }


def _export_ipa(project: str, params: dict) -> dict:
    """Export an .xcarchive to an .ipa file."""
    archive_path = params.get("archive_path", "")
    export_options_path = params.get("export_options_path", "")

    # Verify archive exists
    if not archive_path or not os.path.isdir(archive_path):
        return {"status": "failed", "result": {"error": f"Archive not found: {archive_path}"}}

    # Verify export options exist
    if not export_options_path or not os.path.isfile(export_options_path):
        return {"status": "failed", "result": {"error": f"ExportOptions.plist not found: {export_options_path}"}}

    # Create export directory
    project_dir = REPO_PATH / "projects" / project
    export_dir = project_dir / "build" / "export"
    export_dir.mkdir(parents=True, exist_ok=True)

    cmd = [
        "xcodebuild", "-exportArchive",
        "-archivePath", archive_path,
        "-exportPath", str(export_dir),
        "-exportOptionsPlist", export_options_path,
    ]

    print(f"[Mac Agent] Exporting IPA from {archive_path}...")
    start = time.time()
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=600,
                                cwd=str(project_dir))
        elapsed = time.time() - start
    except subprocess.TimeoutExpired:
        return {"status": "failed", "result": {"error": "Export timed out after 600s"}}
    except Exception as e:
        return {"status": "failed", "result": {"error": str(e)}}

    if result.returncode != 0:
        return {
            "status": "failed",
            "result": {
                "error": "xcodebuild -exportArchive failed",
                "stdout": result.stdout[-500:] if result.stdout else "",
                "stderr": result.stderr[-500:] if result.stderr else "",
            }
        }

    # Find .ipa in export directory
    ipa_files = list(export_dir.glob("*.ipa"))
    if not ipa_files:
        return {
            "status": "failed",
            "result": {
                "error": "Export succeeded but no .ipa found in output",
                "export_dir": str(export_dir),
            }
        }

    ipa_path = str(ipa_files[0])
    ipa_size = os.path.getsize(ipa_path)
    print(f"[Mac Agent] Export successful: {ipa_path} ({ipa_size} bytes)")

    return {
        "status": "success",
        "result": {
            "ipa_path": ipa_path,
            "export_dir": str(export_dir),
            "ipa_size_bytes": ipa_size,
            "export_time_seconds": round(elapsed),
        }
    }


def main():
    print("=" * 60)
    print("  Mac Build Agent")
    print("=" * 60)
    print(f"  Repo: {REPO_PATH}")
    print(f"  Xcode: {_check_xcode()}")
    print(f"  Poll interval: {POLL_INTERVAL}s")
    print(f"  Commands dir: {COMMANDS_DIR}")
    print("=" * 60)
    print()

    while True:
        try:
            git_pull()
            pending = get_pending()

            for cmd_file in pending:
                try:
                    cmd = json.loads(cmd_file.read_text(encoding="utf-8"))
                    print(f"[{datetime.now().strftime('%H:%M:%S')}] Processing: {cmd.get('type')} for {cmd.get('project')}")

                    result = execute_command(cmd)
                    result["id"] = cmd.get("id", cmd_file.stem)
                    result["type"] = cmd.get("type")
                    result["completed_at"] = datetime.now().isoformat()

                    # Write result
                    COMPLETED.mkdir(parents=True, exist_ok=True)
                    result_path = COMPLETED / cmd_file.name
                    result_path.write_text(json.dumps(result, indent=2), encoding="utf-8")

                    # Remove from pending
                    cmd_file.unlink()

                    print(f"  -> {result.get('status', 'unknown')}")

                except Exception as e:
                    print(f"  -> ERROR: {e}")

            if pending:
                git_push(f"Mac agent: {len(pending)} command(s) processed")

        except KeyboardInterrupt:
            print("\nShutting down.")
            break
        except Exception as e:
            print(f"Loop error: {e}")

        time.sleep(POLL_INTERVAL)


if __name__ == "__main__":
    main()

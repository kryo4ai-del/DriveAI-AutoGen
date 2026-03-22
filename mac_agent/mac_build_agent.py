"""Mac Build Agent — watches for factory commands, executes, reports back."""
import json
import os
import subprocess
import time
from datetime import datetime
from pathlib import Path

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

    else:
        return {"status": "error", "result": {"error": f"Unknown command type: {cmd_type}"}}


def _check_xcode() -> str:
    try:
        r = subprocess.run(["xcodebuild", "-version"], capture_output=True, text=True, timeout=10)
        return r.stdout.strip().split("\n")[0]
    except Exception:
        return "not found"


def _build_ios(project: str, params: dict) -> dict:
    project_dir = REPO_PATH / "projects" / project
    scheme = params.get("scheme", "AskFinPremium")
    config = params.get("configuration", "Debug")
    simulator = params.get("simulator", "iPhone 17 Pro")

    # Generate xcodeproj if project.yml exists
    yml = project_dir / "project.yml"
    if yml.exists():
        subprocess.run(["xcodegen", "generate", "--spec", str(yml)],
                       cwd=str(project_dir), capture_output=True, timeout=60)

    xcodeproj = list(project_dir.glob("*.xcodeproj"))
    if not xcodeproj:
        return {"status": "error", "result": {"error": "No .xcodeproj found"}}

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

    return {
        "status": "success" if result.returncode == 0 else "failed",
        "result": {
            "build_succeeded": result.returncode == 0,
            "errors": len(errors),
            "warnings": len(warnings),
            "error_details": errors[:20],
            "build_time_seconds": round(elapsed),
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

"""Factory-side Mac Bridge — sends commands, waits for results."""
import json
import os
import subprocess
import time
from datetime import datetime
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent
COMMANDS_DIR = _ROOT / "_commands"
PENDING = COMMANDS_DIR / "pending"
COMPLETED = COMMANDS_DIR / "completed"


class MacBridge:
    """Send commands to Mac Build Agent via Git, wait for results."""

    def __init__(self):
        self.repo = str(_ROOT)

    def send_command(self, cmd_type: str, project: str, params: dict = None) -> str:
        """Create command file, git push. Returns command ID."""
        cmd_id = f"cmd_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        cmd = {
            "id": cmd_id,
            "type": cmd_type,
            "project": project,
            "params": params or {},
            "requested_by": "factory_windows",
            "timestamp": datetime.now().isoformat(),
        }

        PENDING.mkdir(parents=True, exist_ok=True)
        cmd_path = PENDING / f"{cmd_id}.json"
        cmd_path.write_text(json.dumps(cmd, indent=2), encoding="utf-8")

        # Git push
        subprocess.run(["git", "add", str(cmd_path)], cwd=self.repo, capture_output=True)
        subprocess.run(["git", "commit", "-m", f"Mac command: {cmd_type} for {project}"],
                       cwd=self.repo, capture_output=True)
        subprocess.run(["git", "push"], cwd=self.repo, capture_output=True, timeout=30)

        return cmd_id

    def wait_for_result(self, cmd_id: str, timeout_minutes: int = 15,
                        poll_interval: int = 30) -> dict | None:
        """Poll Git for result."""
        deadline = time.time() + timeout_minutes * 60
        while time.time() < deadline:
            # Git pull
            subprocess.run(["git", "pull", "--rebase"], cwd=self.repo,
                           capture_output=True, timeout=30)

            result_path = COMPLETED / f"{cmd_id}.json"
            if result_path.exists():
                return json.loads(result_path.read_text(encoding="utf-8"))

            remaining = int((deadline - time.time()) / 60)
            print(f"    Waiting for Mac... ({remaining}min remaining)")
            time.sleep(poll_interval)

        return None

    def build_ios(self, project: str, scheme: str = "AskFinPremium") -> dict | None:
        """Send build command and wait."""
        cmd_id = self.send_command("build_ios", project, {"scheme": scheme})
        print(f"  iOS build command sent (ID: {cmd_id})")
        print(f"  Waiting for Mac Build Agent...")
        return self.wait_for_result(cmd_id)

    def run_tests(self, project: str, suite: str = "golden_gates") -> dict | None:
        """Send test command and wait."""
        cmd_id = self.send_command("run_tests", project, {"suite": suite})
        print(f"  Test command sent (ID: {cmd_id})")
        return self.wait_for_result(cmd_id)

    def archive(self, project: str, scheme: str = "AskFinPremium") -> dict | None:
        """Send archive command and wait."""
        cmd_id = self.send_command("archive", project, {"scheme": scheme})
        print(f"  Archive command sent (ID: {cmd_id})")
        return self.wait_for_result(cmd_id, timeout_minutes=30)

    def is_available(self, timeout_minutes: int = 2) -> bool:
        """Check if Mac agent is running."""
        cmd_id = self.send_command("health_check", "")
        result = self.wait_for_result(cmd_id, timeout_minutes=timeout_minutes, poll_interval=15)
        return result is not None and result.get("status") == "success"

"""Send generate_and_build commands to the Mac Assembly Factory.

Commands are written to _commands/pending/ and picked up via git.
"""

import json
import os
import subprocess
import time
from datetime import datetime
from pathlib import Path
from config.model_router import get_fallback_model

_ROOT = Path(__file__).resolve().parent.parent.parent
_PENDING = _ROOT / "_commands" / "pending"
_COMPLETED = _ROOT / "_commands" / "completed"


_FALLBACK_CONTRACT = (
    "Every Swift file MUST start with the correct import "
    "(import SwiftUI for Views, import Foundation for models/services, "
    "import Combine for ObservableObject/Published). "
    "NEVER use ... or placeholder code. Every method body must contain "
    "real compilable Swift. Each type in exactly ONE file. "
    "All files must pass swiftc -parse."
)


def _get_default_compile_contract() -> str:
    """Load compile contract from ios.json platform role."""
    try:
        ios_path = _ROOT / "config" / "platform_roles" / "ios.json"
        with open(ios_path, encoding="utf-8") as f:
            ios_config = json.load(f)
        return ios_config.get("compile_contract", _FALLBACK_CONTRACT)
    except Exception:
        return _FALLBACK_CONTRACT


def send_generate_and_build(
    project: str,
    feature_name: str,
    feature_spec: str,
    target_files: list[str],
    model: str = None,
    compile_contract: str | None = None,
) -> str:
    """Create and send a generate_and_build command to Mac.

    Returns: command_id
    """
    model = model or get_fallback_model()
    if compile_contract is None:
        compile_contract = _get_default_compile_contract()

    cmd_id = f"gen_{datetime.now().strftime('%Y%m%d_%H%M%S')}"

    command = {
        "id": cmd_id,
        "type": "generate_and_build",
        "project": project,
        "feature_name": feature_name,
        "feature_spec": feature_spec,
        "model": model,
        "compile_contract": compile_contract,
        "target_files": target_files,
        "sent_at": datetime.now().isoformat(),
    }

    _PENDING.mkdir(parents=True, exist_ok=True)
    cmd_path = _PENDING / f"{cmd_id}.json"
    cmd_path.write_text(json.dumps(command, indent=2), encoding="utf-8")

    # Git push (with pull-rebase retry on reject)
    repo = str(_ROOT)
    subprocess.run(["git", "add", str(cmd_path)], cwd=repo, capture_output=True)
    subprocess.run(
        ["git", "commit", "-m", f"[Factory] Mac command: {feature_name}"],
        cwd=repo, capture_output=True,
    )
    for _attempt in range(3):
        push = subprocess.run(["git", "push"], cwd=repo, capture_output=True, timeout=30)
        if push.returncode == 0:
            break
        # Pull-rebase and retry
        subprocess.run(["git", "pull", "--rebase"], cwd=repo, capture_output=True, timeout=30)
    else:
        print(f"[MacBridge] WARNING: git push failed after 3 attempts")

    print(f"[MacBridge] Command sent: {cmd_id} — {feature_name} ({len(target_files)} files)")
    return cmd_id


def check_result(cmd_id: str) -> dict | None:
    """Check if Mac has completed the command."""
    repo = str(_ROOT)
    subprocess.run(["git", "pull", "--rebase"], cwd=repo, capture_output=True, timeout=30)

    result_path = _COMPLETED / f"{cmd_id}.json"
    if result_path.exists():
        return json.loads(result_path.read_text(encoding="utf-8"))
    return None


def wait_for_result(
    cmd_id: str,
    timeout_seconds: int = 300,
    poll_interval: int = 15,
) -> dict:
    """Poll for Mac result with timeout."""
    elapsed = 0
    while elapsed < timeout_seconds:
        result = check_result(cmd_id)
        if result:
            status = result.get("status", "unknown")
            print(f"[MacBridge] Result received: {status}")
            return result
        remaining = timeout_seconds - elapsed
        print(f"[MacBridge] Waiting for Mac... ({remaining}s remaining)")
        time.sleep(poll_interval)
        elapsed += poll_interval

    print(f"[MacBridge] Timeout after {timeout_seconds}s — no result from Mac.")
    return {"status": "timeout", "cmd_id": cmd_id, "waited": timeout_seconds}

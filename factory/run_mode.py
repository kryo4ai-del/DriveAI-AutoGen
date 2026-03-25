"""Shared run mode utilities for all pipeline phases.

Reads/writes the 'mode' field (vision|factory) from/to run_config.json.
"""

import json
from pathlib import Path


def read_mode(run_dir: str | Path) -> str:
    """Read mode from a run directory's run_config.json. Returns 'vision' if not found."""
    config_path = Path(run_dir) / "run_config.json"
    if config_path.exists():
        try:
            data = json.loads(config_path.read_text(encoding="utf-8"))
            return data.get("mode", "vision")
        except Exception:
            pass
    return "vision"


def write_mode(output_dir: str | Path, mode: str, **extra_fields) -> None:
    """Write mode (and optional extra fields) to run_config.json in output_dir."""
    config_path = Path(output_dir) / "run_config.json"
    data = {"mode": mode}
    # Preserve existing fields if file already exists
    if config_path.exists():
        try:
            data = json.loads(config_path.read_text(encoding="utf-8"))
            data["mode"] = mode
        except Exception:
            pass
    data.update(extra_fields)
    config_path.write_text(json.dumps(data, indent=2), encoding="utf-8")

"""Integration tests for Name Gate CLI (subprocess calls)."""

import json
import shutil
import subprocess
import sys
import pytest
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parents[3]  # DriveAI-AutoGen/
_TEST_PREFIX = "ng_integ_"


def _run_cli(*args: str, timeout: int = 30, stubs: bool = True) -> subprocess.CompletedProcess:
    """Run Name Gate CLI via subprocess."""
    cmd = [sys.executable, "-m", "factory.name_gate"]
    if stubs:
        cmd.append("--stubs")
    cmd.extend(args)
    return subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        timeout=timeout,
        cwd=str(_PROJECT_ROOT),
    )


def _parse_last_json(stdout: str):
    """Parse JSON from stdout (skip log prefix lines, handle multi-line JSON)."""
    lines = stdout.strip().splitlines()
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("{") or stripped.startswith("["):
            json_str = "\n".join(lines[i:])
            return json.loads(json_str)
    raise ValueError(f"No JSON in output: {stdout[:200]}")


def _test_name(suffix: str) -> str:
    return f"{_TEST_PREFIX}{suffix}"


@pytest.fixture(autouse=True)
def cleanup():
    yield
    # Clean project dirs
    projects_dir = _PROJECT_ROOT / "projects"
    if projects_dir.exists():
        for d in projects_dir.iterdir():
            if d.name.startswith(_TEST_PREFIX):
                shutil.rmtree(d, ignore_errors=True)
    # Clean data files
    data_dir = _PROJECT_ROOT / "factory" / "name_gate" / "data"
    if data_dir.exists():
        for f in data_dir.glob(f"{_TEST_PREFIX}*"):
            f.unlink(missing_ok=True)


class TestCLIValidate:
    def test_exits_zero(self):
        result = _run_cli("validate", "--name", _test_name("cli1"), "--idea", "A test app")
        assert result.returncode == 0, f"stderr: {result.stderr}"

    def test_outputs_valid_json(self):
        result = _run_cli("validate", "--name", _test_name("cli2"), "--idea", "A test app")
        data = _parse_last_json(result.stdout)
        assert "report_id" in data
        assert "ampel" in data
        assert data["ampel"] in ("GRUEN", "GELB", "ROT")
        assert 0 <= data["total_score"] <= 100


class TestCLIStatus:
    def test_unlocked_name(self):
        result = _run_cli("status", "--name", _test_name("nonexist"))
        assert result.returncode == 0
        data = _parse_last_json(result.stdout)
        assert data["locked"] is False


class TestCLIFullFlow:
    def test_validate_lock_status(self):
        name = _test_name("flow1")

        # 1. Validate
        r1 = _run_cli("validate", "--name", name, "--idea", "Full flow test app")
        assert r1.returncode == 0
        report = _parse_last_json(r1.stdout)
        assert report["name"] == name

        # 2. Lock
        r2 = _run_cli("lock", "--name", name)
        assert r2.returncode == 0
        lock_data = _parse_last_json(r2.stdout)
        assert lock_data["locked"] is True

        # 3. Status → locked
        r3 = _run_cli("status", "--name", name)
        assert r3.returncode == 0
        status = _parse_last_json(r3.stdout)
        assert status["locked"] is True
        assert status["name"] == name

    def test_lock_without_validate_fails(self):
        """Lock should fail if no report exists for the name."""
        name = _test_name("novalidate")
        result = _run_cli("lock", "--name", name)
        assert result.returncode == 0  # CLI doesn't exit with error, returns JSON error
        data = _parse_last_json(result.stdout)
        assert "error" in data or data.get("locked") is False


class TestCLIAlternatives:
    def test_generates_alternatives(self):
        result = _run_cli("alternatives", "--idea", "social matching app")
        assert result.returncode == 0
        data = _parse_last_json(result.stdout)
        assert isinstance(data, list)
        assert len(data) > 0
        assert "name" in data[0]
        assert "ampel" in data[0]

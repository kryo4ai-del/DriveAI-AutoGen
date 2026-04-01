"""Tests for Name Gate Orchestrator (use_stubs=True — no network calls)."""

import json
import shutil
import pytest
from pathlib import Path

from factory.name_gate.orchestrator import NameGateOrchestrator, _PROJECT_ROOT
from factory.name_gate.models import NameGateReport


# Temp project names for isolation
_TEST_PREFIX = "ng_test_"


def _test_name(suffix: str) -> str:
    return f"{_TEST_PREFIX}{suffix}"


@pytest.fixture(autouse=True)
def cleanup_test_projects():
    """Remove test project dirs and data files after each test."""
    yield
    # Clean up projects
    projects_dir = _PROJECT_ROOT / "projects"
    if projects_dir.exists():
        for d in projects_dir.iterdir():
            if d.name.startswith(_TEST_PREFIX):
                shutil.rmtree(d, ignore_errors=True)
    # Clean up data files
    data_dir = _PROJECT_ROOT / "factory" / "name_gate" / "data"
    if data_dir.exists():
        for f in data_dir.glob(f"{_TEST_PREFIX}*"):
            f.unlink(missing_ok=True)


class TestValidateName:
    def test_returns_report(self):
        orch = NameGateOrchestrator(use_stubs=True)
        report = orch.validate_name(_test_name("alpha"), "A social app")
        assert isinstance(report, NameGateReport)

    def test_report_has_required_fields(self):
        orch = NameGateOrchestrator(use_stubs=True)
        report = orch.validate_name(_test_name("beta"), "A fitness app")
        assert report.report_id.startswith("NGR-")
        assert report.name == _test_name("beta")
        assert 0 <= report.total_score <= 100
        assert report.ampel in ("GRUEN", "GELB", "ROT")
        assert report.timestamp
        assert report.checks is not None

    def test_checks_all_populated(self):
        orch = NameGateOrchestrator(use_stubs=True)
        report = orch.validate_name(_test_name("gamma"), "A game idea")
        c = report.checks
        assert c.domain.score >= 0
        assert c.store.score >= 0
        assert c.social_media.score >= 0
        assert c.trademark.score >= 0
        assert c.brand_fit.score >= 0
        assert c.aso.score >= 0

    def test_report_serializable(self):
        orch = NameGateOrchestrator(use_stubs=True)
        report = orch.validate_name(_test_name("delta"), "An AI tool")
        d = report.to_dict()
        # Must be JSON-serializable
        json_str = json.dumps(d, ensure_ascii=False)
        assert len(json_str) > 50

    def test_deterministic_with_stubs(self):
        """Same name + stubs → same score."""
        name = _test_name("echo")
        orch1 = NameGateOrchestrator(use_stubs=True)
        orch2 = NameGateOrchestrator(use_stubs=True)
        r1 = orch1.validate_name(name, "idea A")
        r2 = orch2.validate_name(name, "idea B")
        # Stub scores depend on name hash, not idea
        assert r1.total_score == r2.total_score

    def test_saves_report_to_data_dir(self):
        name = _test_name("foxtrot")
        orch = NameGateOrchestrator(use_stubs=True)
        orch.validate_name(name, "test")
        slug = name.lower().replace(" ", "_")
        report_path = orch.data_dir / f"{slug}_report.json"
        assert report_path.exists()


class TestLockName:
    def test_lock_creates_project_dir(self):
        name = _test_name("golf")
        orch = NameGateOrchestrator(use_stubs=True)
        report = orch.validate_name(name, "test")
        result = orch.lock_name(name, report)

        assert result["locked"] is True
        assert result["status"] == "name_locked"

        lock_path = _PROJECT_ROOT / "projects" / name / "name_gate_report.json"
        assert lock_path.exists()

    def test_get_status_after_lock(self):
        name = _test_name("hotel")
        orch = NameGateOrchestrator(use_stubs=True)
        report = orch.validate_name(name, "test")
        orch.lock_name(name, report)

        status = orch.get_status(name)
        assert status is not None
        assert status["locked"] is True
        assert status["name"] == name


class TestGetStatus:
    def test_unlocked_name(self):
        orch = NameGateOrchestrator(use_stubs=True)
        status = orch.get_status(_test_name("nonexistent_xyz"))
        assert status is None


class TestRequestAlternatives:
    def test_returns_list_of_reports(self):
        orch = NameGateOrchestrator(use_stubs=True)
        alts = orch.request_alternatives("social matching app")
        assert isinstance(alts, list)
        assert len(alts) > 0
        assert all(isinstance(r, NameGateReport) for r in alts)

    def test_alternatives_sorted_by_score(self):
        orch = NameGateOrchestrator(use_stubs=True)
        alts = orch.request_alternatives("game puzzle")
        scores = [r.total_score for r in alts]
        assert scores == sorted(scores, reverse=True)


class TestUseStubsFlag:
    def test_stubs_used_when_flag_true(self):
        orch = NameGateOrchestrator(use_stubs=True)
        result = orch._call_mkt04_validate_domain(_test_name("india"))
        assert result.details.get("source") == "STUB"

    def test_stubs_flag_default_false(self):
        orch = NameGateOrchestrator()
        assert orch.use_stubs is False

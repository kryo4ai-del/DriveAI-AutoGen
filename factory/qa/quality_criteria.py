"""DriveAI Factory — QA Quality Criteria

Derives minimum quality requirements from project configuration and structure.
Required checks must pass for QA to succeed. Recommended checks generate warnings only.
"""

from dataclasses import dataclass, field
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

_PLATFORM_EXTENSIONS = {
    "ios": {".swift"},
    "android": {".kt", ".java"},
    "web": {".ts", ".tsx", ".js", ".jsx"},
    "unity": {".cs"},
}

_PLATFORM_MAX_FAILURE_RATE = {
    "ios": 0.10,
    "android": 0.20,
    "web": 0.15,
    "unity": 0.25,
}


@dataclass
class Check:
    """A single QA check result."""
    name: str
    passed: bool
    required: bool
    detail: str = ""


@dataclass
class QualityGateResult:
    """Aggregated result of all quality checks."""
    passed: bool
    checks: list = field(default_factory=list)  # list[Check]
    summary: str = ""


class QualityCriteria:
    """Dynamic QA criteria derived from project config and structure."""

    def __init__(self, min_tests: int = 5, max_failure_rate: float = 0.2) -> None:
        self.min_tests = min_tests
        self.max_failure_rate = max_failure_rate

    @staticmethod
    def from_project(project_name: str, platform: str) -> "QualityCriteria":
        """Analyze project.yaml and file structure to determine criteria."""
        max_rate = _PLATFORM_MAX_FAILURE_RATE.get(platform, 0.2)
        min_tests = 5  # default

        project_dir = _PROJECT_ROOT / "projects" / project_name

        # Try to load project.yaml for feature count
        feature_count = 0
        yaml_path = project_dir / "project.yaml"
        if yaml_path.is_file():
            try:
                import yaml
                with open(yaml_path, encoding="utf-8") as f:
                    data = yaml.safe_load(f) or {}
                features = data.get("features", [])
                if isinstance(features, list):
                    feature_count = len(features)
            except Exception:
                pass

        # Count source files for platform
        extensions = _PLATFORM_EXTENSIONS.get(platform, set())
        source_count = 0
        if project_dir.is_dir():
            for ext in extensions:
                source_count += len(list(project_dir.rglob(f"*{ext}")))

        # Derive min_tests from features
        if feature_count > 0:
            multiplier = 3 if source_count > 100 else 2
            min_tests = feature_count * multiplier
        elif source_count > 100:
            min_tests = 10
        else:
            min_tests = 5

        print(f"[QA Criteria] {project_name}/{platform}: "
              f"{feature_count} features, {source_count} source files, "
              f"min_tests={min_tests}, max_failure_rate={max_rate:.0%}")

        return QualityCriteria(min_tests=min_tests, max_failure_rate=max_rate)

    def evaluate(self, build_result, ops_result: dict, test_result) -> QualityGateResult:
        """Evaluate all quality checks against phase results."""
        checks: list[Check] = []

        # 1. Build success (REQUIRED)
        build_ok = getattr(build_result, "success", False)
        checks.append(Check(
            name="build_success",
            passed=build_ok,
            required=True,
            detail="" if build_ok else f"Build status: {getattr(build_result, 'status', 'UNKNOWN')}",
        ))

        # 2. Zero blocking issues (REQUIRED)
        blocking = ops_result.get("blocking_count", 0) if isinstance(ops_result, dict) else 0
        checks.append(Check(
            name="zero_blocking",
            passed=blocking == 0,
            required=True,
            detail="" if blocking == 0 else f"Blocking issues: {blocking}",
        ))

        # 3. No crashes (REQUIRED)
        has_crashes = getattr(test_result, "has_crashes", False)
        checks.append(Check(
            name="no_crashes",
            passed=not has_crashes,
            required=True,
            detail="" if not has_crashes else "Test crashes detected",
        ))

        # 4. Test pass rate (RECOMMENDED)
        rate = getattr(test_result, "failure_rate", 0.0)
        rate_ok = rate <= self.max_failure_rate
        checks.append(Check(
            name="test_pass_rate",
            passed=rate_ok,
            required=False,
            detail=f"Failure rate: {rate:.1%} (max: {self.max_failure_rate:.1%})",
        ))

        # 5. Minimum test coverage (RECOMMENDED)
        total = getattr(test_result, "tests_total", 0)
        coverage_ok = total >= self.min_tests
        checks.append(Check(
            name="min_test_coverage",
            passed=coverage_ok,
            required=False,
            detail=f"Tests: {total} (min: {self.min_tests})",
        ))

        # Aggregate: passed = all REQUIRED checks pass
        all_required_pass = all(c.passed for c in checks if c.required)
        failed_names = [c.name for c in checks if not c.passed]
        summary = ", ".join(failed_names) if failed_names else "All checks passed"

        return QualityGateResult(
            passed=all_required_pass,
            checks=checks,
            summary=summary,
        )

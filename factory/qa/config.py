"""QA Department configuration.

Central configuration dataclass for all QA modules.
No external dependencies — only stdlib.
"""

from dataclasses import dataclass


@dataclass
class QAConfig:
    """Configuration for the QA Department."""

    # Bounce Limits
    max_bounces: int = 3

    # Build Verification
    build_timeout_seconds: int = 300
    build_retry_count: int = 2

    # Operations Layer
    max_auto_fixes_per_run: int = 10

    # Test Runner
    test_timeout_seconds: int = 300

    # Quality Criteria Defaults (Fallback when project.yaml is missing)
    default_min_tests: int = 5
    default_max_failure_rate: float = 0.2  # 20%

    # Timeouts
    total_qa_timeout_seconds: int = 900  # 15 minutes

    # Report Storage
    report_dir: str = "factory/qa/reports"

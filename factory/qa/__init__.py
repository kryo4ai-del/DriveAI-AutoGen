"""DriveAI Factory — QA Department

Modules:
  config.py           — QAConfig dataclass
  bounce_tracker.py   — Bounce count persistence per project+platform
  qa_report.py        — Structured JSON reports
  test_runner.py      — BuildVerifier + TestRunner (platform-specific)
  quality_criteria.py — QualityCriteria + QualityGateResult
  qa_coordinator.py   — Main orchestrator (4-phase pipeline)
"""

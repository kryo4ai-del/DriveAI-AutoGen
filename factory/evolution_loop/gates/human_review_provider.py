"""Human Review Provider -- File-based CEO Review.

CEO writes feedback into a JSON file.  The provider reads and validates it.
"""

from __future__ import annotations

import json
from pathlib import Path

from factory.evolution_loop.gates.review_provider import ReviewProvider, ReviewResult
from factory.evolution_loop.ldo.schema import CEOIssue, LoopDataObject

_PREFIX = "[EVO-CEO]"

_VALID_STATUSES = {"go", "no_go"}
_VALID_CATEGORIES = {"bug", "ux", "performance", "content", "feel"}
_VALID_SEVERITIES = {"blocker", "major", "minor"}

_QUALITY_TARGETS = {
    "Bug Score": ("bug_score", 90),
    "Roadbook Match": ("roadbook_match_score", 95),
    "Structural Health": ("structural_health_score", 85),
    "Performance": ("performance_score", 70),
    "UX": ("ux_score", 70),
}


class HumanReviewProvider(ReviewProvider):
    """File-based CEO Review.  CEO writes feedback into ceo_feedback.json."""

    def __init__(self, data_dir: str | None = None) -> None:
        self._data_dir = Path(data_dir) if data_dir else None

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def review(self, ldo: LoopDataObject) -> ReviewResult:
        """Execute the human review flow.

        1. Generate and save the review brief
        2. Check for ceo_feedback.json
        3. Parse + validate if it exists, else return pending
        """
        project_dir = self._get_project_dir(ldo)
        project_dir.mkdir(parents=True, exist_ok=True)

        # Write review brief
        brief = self.generate_review_brief(ldo)
        brief_path = project_dir / "ceo_review_brief.md"
        brief_path.write_text(brief, encoding="utf-8")

        # Check for feedback file
        feedback_path = project_dir / "ceo_feedback.json"
        if not feedback_path.exists():
            print(f"{_PREFIX} Waiting for CEO feedback at: {feedback_path}")
            return ReviewResult(status="pending")

        # Parse and validate
        return self._parse_feedback(feedback_path)

    def generate_review_brief(self, ldo: LoopDataObject) -> str:
        """Generate a Markdown review brief for the CEO."""
        project_dir = self._get_project_dir(ldo)
        feedback_path = project_dir / "ceo_feedback.json"

        lines: list[str] = []
        _a = lines.append

        _a(f"# CEO Review Brief -- {ldo.meta.project_id}")
        _a("")
        _a("## Projekt")
        _a(f"- Type: {ldo.meta.project_type}")
        _a(f"- Platform: {ldo.meta.production_line}")
        _a(f"- Iteration: {ldo.meta.iteration}")
        _a(f"- Loop Mode: {ldo.meta.loop_mode}")
        _a("")

        # Quality Scores table
        _a("## Quality Scores")
        _a("| Score | Wert | Confidence | Target | Status |")
        _a("|-------|------|------------|--------|--------|")

        for label, (attr, target) in _QUALITY_TARGETS.items():
            se = getattr(ldo.scores, attr, None)
            if se is None:
                continue
            val = se.value
            conf = se.confidence
            status = "pass" if val >= target else "FAIL"
            _a(f"| {label} | {val:.0f} | {conf:.0f}% | >={target} | {status} |")

        agg = ldo.scores.quality_score_aggregate
        agg_status = "pass" if agg >= 85 else "FAIL"
        _a(f"| **Aggregate** | **{agg:.1f}** | | >=85 | {agg_status} |")
        _a("")

        # Open gaps
        gaps = ldo.gaps or []
        if gaps:
            _a("## Offene Gaps")
            for g in gaps:
                sev = g.severity or "?"
                _a(f"- [{sev}] {g.description} ({g.category}, {g.affected_component})")
            _a("")

        # Iteration history (from regression_data)
        rd = ldo.regression_data
        if rd.trend:
            _a("## Iterations-Verlauf")
            _a(f"- Trend: {rd.trend}")
            if rd.iterations_without_improvement > 0:
                _a(f"- Iterationen ohne Verbesserung: {rd.iterations_without_improvement}")
            _a("")

        # Cost
        _a("## Kosten")
        _a(f"- Akkumuliert: ${ldo.meta.accumulated_cost:.4f}")
        _a("")

        # Feedback instructions
        _a("## Feedback")
        _a("Bitte Feedback in folgende Datei schreiben:")
        _a(f"`{feedback_path}`")
        _a("")
        _a("Format:")
        _a("```json")
        _a("{")
        _a('    "status": "go oder no_go",')
        _a('    "issues": [')
        _a("        {")
        _a('            "category": "bug|ux|performance|content|feel",')
        _a('            "severity": "blocker|major|minor",')
        _a('            "description": "Beschreibung"')
        _a("        }")
        _a("    ]")
        _a("}")
        _a("```")

        return "\n".join(lines)

    # ------------------------------------------------------------------
    # Internal
    # ------------------------------------------------------------------

    def _get_project_dir(self, ldo: LoopDataObject) -> Path:
        if self._data_dir:
            return self._data_dir
        return Path("factory/evolution_loop/data") / ldo.meta.project_id

    def _parse_feedback(self, path: Path) -> ReviewResult:
        """Parse and validate ceo_feedback.json."""
        try:
            raw = json.loads(path.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            print(f"{_PREFIX} ERROR: Invalid JSON in {path}: {e}")
            return ReviewResult(status="pending")

        # Validate status
        status = raw.get("status", "")
        if status not in _VALID_STATUSES:
            print(f"{_PREFIX} ERROR: Invalid status '{status}'. Must be one of: {_VALID_STATUSES}")
            return ReviewResult(status="pending")

        # Parse issues
        issues: list[CEOIssue] = []
        for i, iss_raw in enumerate(raw.get("issues", []), start=1):
            cat = iss_raw.get("category", "")
            sev = iss_raw.get("severity", "")
            desc = iss_raw.get("description", "")

            if cat not in _VALID_CATEGORIES:
                print(f"{_PREFIX} WARNING: Issue #{i} has invalid category '{cat}', using 'bug'")
                cat = "bug"
            if sev not in _VALID_SEVERITIES:
                print(f"{_PREFIX} WARNING: Issue #{i} has invalid severity '{sev}', using 'minor'")
                sev = "minor"
            if not desc:
                print(f"{_PREFIX} WARNING: Issue #{i} has empty description, skipping")
                continue

            issues.append(CEOIssue(
                category=cat,
                severity=sev,
                description=desc,
            ))

        print(f"{_PREFIX} CEO feedback: status={status}, issues={len(issues)}")
        return ReviewResult(status=status, issues=issues)

"""LDO Schema — Loop Data Object Dataclasses.

The LDO is the sole communication medium between all Evolution Loop agents.
No agent talks to another — they only read from and write to the LDO.
"""

from __future__ import annotations

from dataclasses import dataclass, field, asdict, fields
from datetime import datetime, timezone


# ---------------------------------------------------------------------------
# Helper: nested dataclass reconstruction
# ---------------------------------------------------------------------------

def _reconstruct(cls, data):
    """Recursively reconstruct a dataclass from a dict."""
    if data is None:
        return cls()
    if not isinstance(data, dict):
        return data

    field_types = {f.name: f.type for f in fields(cls)}
    kwargs = {}
    for f in fields(cls):
        val = data.get(f.name, None)
        if val is None:
            continue

        # Resolve the type (handle string annotations from __future__)
        ftype = field_types[f.name]
        if isinstance(ftype, str):
            ftype = globals().get(ftype, None)

        if isinstance(ftype, type) and hasattr(ftype, "__dataclass_fields__"):
            kwargs[f.name] = _reconstruct(ftype, val)
        elif isinstance(val, list) and f.name in _LIST_ITEM_TYPES:
            item_cls = _LIST_ITEM_TYPES[f.name]
            kwargs[f.name] = [
                _reconstruct(item_cls, item) if isinstance(item, dict) else item
                for item in val
            ]
        elif isinstance(val, dict) and f.name in _DICT_VALUE_TYPES:
            value_cls = _DICT_VALUE_TYPES[f.name]
            kwargs[f.name] = {
                k: _reconstruct(value_cls, v) if isinstance(v, dict) else v
                for k, v in val.items()
            }
        else:
            kwargs[f.name] = val

    return cls(**kwargs)


# ---------------------------------------------------------------------------
# Dataclasses
# ---------------------------------------------------------------------------

@dataclass
class ScoreEntry:
    value: float = 0.0
    confidence: float = 0.0


@dataclass
class LDOMeta:
    project_id: str = ""
    project_type: str = ""
    production_line: str = ""
    iteration: int = 0
    loop_mode: str = "sprint"
    timestamp: str = ""
    accumulated_cost: float = 0.0
    git_tag: str = ""


@dataclass
class RoadbookTargets:
    features: list = field(default_factory=list)
    screens: list = field(default_factory=list)
    user_flows: list = field(default_factory=list)
    quality_thresholds: dict = field(default_factory=dict)
    score_weights: dict = field(default_factory=dict)


@dataclass
class BuildArtifacts:
    paths: list = field(default_factory=list)
    compile_status: str = "not_built"
    platform_details: dict = field(default_factory=dict)


@dataclass
class QAResults:
    tests_passed: int = 0
    tests_failed: int = 0
    test_details: list = field(default_factory=list)
    compile_errors: list = field(default_factory=list)
    warnings: list = field(default_factory=list)


@dataclass
class SimulationResults:
    static_analysis: dict = field(default_factory=dict)
    roadbook_coverage: dict = field(default_factory=dict)
    synthetic_flows: list = field(default_factory=list)
    plugin_results: dict = field(default_factory=dict)


@dataclass
class Scores:
    bug_score: ScoreEntry = field(default_factory=ScoreEntry)
    roadbook_match_score: ScoreEntry = field(default_factory=ScoreEntry)
    structural_health_score: ScoreEntry = field(default_factory=ScoreEntry)
    performance_score: ScoreEntry = field(default_factory=ScoreEntry)
    ux_score: ScoreEntry = field(default_factory=ScoreEntry)
    plugin_scores: dict = field(default_factory=dict)
    quality_score_aggregate: float = 0.0


@dataclass
class Gap:
    id: str = ""
    category: str = ""
    severity: str = ""
    description: str = ""
    affected_component: str = ""
    is_regression: bool = False
    first_seen_iteration: int = 0


@dataclass
class RegressionData:
    trend: str = "improving"
    iterations_without_improvement: int = 0
    regressions_detected: list = field(default_factory=list)
    recommendation: str = "continue"
    comparison_to_previous: dict = field(default_factory=dict)


@dataclass
class Task:
    id: str = ""
    type: str = ""
    description: str = ""
    target_component: str = ""
    originated_from: str = ""
    priority: str = ""


@dataclass
class CEOIssue:
    category: str = ""
    severity: str = ""
    description: str = ""
    resolved: bool = False


@dataclass
class CEOFeedback:
    status: str = "pending"
    issues: list = field(default_factory=list)


# ---------------------------------------------------------------------------
# Lookup tables for nested list/dict reconstruction
# ---------------------------------------------------------------------------

_LIST_ITEM_TYPES = {
    "gaps": Gap,
    "tasks": Task,
    "issues": CEOIssue,
    "regressions_detected": str,
}

_DICT_VALUE_TYPES = {
    "plugin_scores": ScoreEntry,
}


# ---------------------------------------------------------------------------
# Main LDO
# ---------------------------------------------------------------------------

@dataclass
class LoopDataObject:
    meta: LDOMeta = field(default_factory=LDOMeta)
    roadbook_targets: RoadbookTargets = field(default_factory=RoadbookTargets)
    build_artifacts: BuildArtifacts = field(default_factory=BuildArtifacts)
    qa_results: QAResults = field(default_factory=QAResults)
    simulation_results: SimulationResults = field(default_factory=SimulationResults)
    scores: Scores = field(default_factory=Scores)
    gaps: list = field(default_factory=list)
    regression_data: RegressionData = field(default_factory=RegressionData)
    tasks: list = field(default_factory=list)
    ceo_feedback: CEOFeedback = field(default_factory=CEOFeedback)

    def to_dict(self) -> dict:
        """Serialize the LDO to a JSON-compatible dict."""
        return asdict(self)

    @classmethod
    def from_dict(cls, data: dict) -> LoopDataObject:
        """Deserialize a dict back to a LoopDataObject with correct nested types."""
        return _reconstruct(cls, data)

    @classmethod
    def create_initial(
        cls,
        project_id: str,
        project_type: str,
        production_line: str,
    ) -> LoopDataObject:
        """Factory method: create an empty LDO with meta populated."""
        return cls(
            meta=LDOMeta(
                project_id=project_id,
                project_type=project_type,
                production_line=production_line,
                iteration=0,
                loop_mode="sprint",
                timestamp=datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
                accumulated_cost=0.0,
                git_tag=f"evolution/{project_id}/iteration-0",
            ),
        )

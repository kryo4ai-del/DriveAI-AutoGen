# factory/project_config.py
# Per-project configuration system. Loads from projects/<name>/project.yaml.

import os
from dataclasses import dataclass, field

try:
    import yaml
    _HAS_YAML = True
except ImportError:
    yaml = None
    _HAS_YAML = False

import json


@dataclass
class LineConfig:
    """Configuration for a single platform production line."""
    status: str = "disabled"        # active | planned | disabled
    language: str = ""
    framework: str = ""
    architecture: str = ""
    build_tool: str = ""
    min_target: str = ""
    quality_priority: dict = field(default_factory=dict)

    def get_quality_score(self) -> float:
        """Compute 0.0-1.0 quality priority score from attributes.
        high=3, medium=2, low=1. runtime_tolerance is inverted (low=3).
        Returns average normalized to 0.0-1.0 range."""
        if not self.quality_priority:
            return 0.5  # neutral default — no bias
        value_map = {'high': 3, 'medium': 2, 'low': 1}
        invert = {'runtime_tolerance'}  # low tolerance = HIGH priority
        scores = []
        for key, val in self.quality_priority.items():
            numeric = value_map.get(val, 2)
            if key in invert:
                numeric = 4 - numeric  # low(1) becomes 3, high(3) becomes 1
            scores.append(numeric)
        if not scores:
            return 0.5
        return round((sum(scores) / len(scores) - 1) / 2, 2)  # normalize 1-3 to 0.0-1.0


@dataclass
class PipelineConfig:
    """Pipeline behavior flags for this project."""
    code_extraction: str = "swift"
    templates: list[str] = field(default_factory=lambda: ["feature", "screen", "viewmodel", "service"])
    operations_layer: bool = True
    cd_gate: bool = True


@dataclass
class ProjectMetadata:
    """Project metadata."""
    created: str = ""
    last_run: str = ""
    total_runs: int = 0
    status: str = "development"


@dataclass
class ProjectConfig:
    """Full project configuration loaded from project.yaml."""
    name: str = "Unknown"
    slug: str = ""
    description: str = ""
    version: str = "0.0.0"
    lines: dict[str, LineConfig] = field(default_factory=dict)
    pipeline: PipelineConfig = field(default_factory=PipelineConfig)
    metadata: ProjectMetadata = field(default_factory=ProjectMetadata)

    def get_active_lines(self) -> list[str]:
        """Return list of active line names."""
        return [name for name, line in self.lines.items() if line.status == "active"]

    def get_extraction_language(self) -> str:
        """Return the configured extraction language."""
        return self.pipeline.code_extraction


def _parse_line(data: dict) -> LineConfig:
    """Parse a single line config dict into a LineConfig."""
    return LineConfig(
        status=data.get("status", "disabled"),
        language=data.get("language", ""),
        framework=data.get("framework", ""),
        architecture=data.get("architecture", ""),
        build_tool=data.get("build_tool", ""),
        min_target=data.get("min_target", ""),
        quality_priority=data.get("quality_priority", {}),
    )


def _parse_config(raw: dict) -> ProjectConfig:
    """Parse a raw dict (from YAML or JSON) into a ProjectConfig."""
    project = raw.get("project", {})
    lines_raw = raw.get("lines", {})
    pipeline_raw = raw.get("pipeline", {})
    metadata_raw = raw.get("metadata", {})

    lines = {name: _parse_line(line_data) for name, line_data in lines_raw.items()}

    pipeline = PipelineConfig(
        code_extraction=pipeline_raw.get("code_extraction", "swift"),
        templates=pipeline_raw.get("templates", ["feature", "screen", "viewmodel", "service"]),
        operations_layer=pipeline_raw.get("operations_layer", True),
        cd_gate=pipeline_raw.get("cd_gate", True),
    )

    metadata = ProjectMetadata(
        created=metadata_raw.get("created", ""),
        last_run=metadata_raw.get("last_run", ""),
        total_runs=metadata_raw.get("total_runs", 0),
        status=metadata_raw.get("status", "development"),
    )

    return ProjectConfig(
        name=project.get("name", "Unknown"),
        slug=project.get("slug", ""),
        description=project.get("description", ""),
        version=project.get("version", "0.0.0"),
        lines=lines,
        pipeline=pipeline,
        metadata=metadata,
    )


def _default_ios_config(project_name: str) -> ProjectConfig:
    """Return default iOS/Swift config for backward compatibility."""
    return ProjectConfig(
        name=project_name,
        slug=project_name,
        description="",
        version="0.0.0",
        lines={
            "ios": LineConfig(
                status="active",
                language="swift",
                framework="swiftui",
                architecture="mvvm",
                build_tool="xcodegen",
            ),
        },
        pipeline=PipelineConfig(),
        metadata=ProjectMetadata(),
    )


def load_project_config(project_name: str) -> ProjectConfig:
    """Load project config from projects/<name>/project.yaml (or .json fallback).

    If no config file exists, returns a default iOS/Swift config for
    backward compatibility with existing projects.
    """
    base_dir = os.path.join(os.path.dirname(os.path.dirname(__file__)), "projects", project_name)

    # Try YAML first
    yaml_path = os.path.join(base_dir, "project.yaml")
    if os.path.isfile(yaml_path):
        if _HAS_YAML:
            with open(yaml_path, encoding="utf-8") as f:
                raw = yaml.safe_load(f) or {}
            return _parse_config(raw)
        else:
            # YAML file exists but no PyYAML — try JSON fallback
            pass

    # Try JSON fallback
    json_path = os.path.join(base_dir, "project.json")
    if os.path.isfile(json_path):
        with open(json_path, encoding="utf-8") as f:
            raw = json.load(f)
        return _parse_config(raw)

    # No config file — return defaults for backward compatibility
    return _default_ios_config(project_name)

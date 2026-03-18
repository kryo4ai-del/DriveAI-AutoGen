# factory/orchestrator/spec_parser.py
# Parse build specs (YAML/JSON) into BuildPlans.

import os
from datetime import datetime

try:
    import yaml
    _HAS_YAML = True
except ImportError:
    yaml = None
    _HAS_YAML = False

import json

from factory.orchestrator.build_plan import BuildPlan, BuildStep

# Language mapping per line
_LINE_LANGUAGE = {
    "ios": "swift",
    "android": "kotlin",
    "web": "typescript",
    "backend": "python",
}


def _load_spec(spec_path: str) -> dict:
    """Load a spec file (YAML or JSON)."""
    if spec_path.endswith((".yaml", ".yml")) and _HAS_YAML:
        with open(spec_path, encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    elif spec_path.endswith(".json"):
        with open(spec_path, encoding="utf-8") as f:
            return json.load(f)
    elif _HAS_YAML:
        # Try YAML first
        with open(spec_path, encoding="utf-8") as f:
            return yaml.safe_load(f) or {}
    else:
        with open(spec_path, encoding="utf-8") as f:
            return json.load(f)


def find_spec_file(project_name: str) -> str | None:
    """Find the build spec file for a project. Returns path or None."""
    base = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))),
                        "projects", project_name, "specs")
    for filename in ("build_spec.yaml", "build_spec.yml", "build_spec.json",
                     "features.yaml", "features.yml", "features.json"):
        path = os.path.join(base, filename)
        if os.path.isfile(path):
            return path
    return None


def parse_spec(spec_data: dict, project_name: str) -> BuildPlan:
    """Parse a spec dict into a BuildPlan.

    Each feature × each target_line = one BuildStep,
    unless the feature has a `lines` override.
    """
    target_lines = spec_data.get("target_lines", ["ios"])
    features = spec_data.get("features", [])

    steps: list[BuildStep] = []
    step_counter = 0

    # Build a map of feature_name -> step IDs per line for dependency resolution
    # Key: (feature_name, line) -> step_id
    feature_step_ids: dict[tuple[str, str], str] = {}

    # First pass: assign IDs
    for feature in features:
        fname = feature["name"]
        ftype = feature.get("type", "feature")
        feature_lines = feature.get("lines", target_lines)

        for line in feature_lines:
            if line not in target_lines and line not in feature.get("lines", []):
                continue
            step_counter += 1
            step_id = f"step_{step_counter:03d}"
            feature_step_ids[(fname, line)] = step_id

    # Second pass: create steps with resolved dependencies
    step_counter = 0
    for feature in sorted(features, key=lambda f: f.get("priority", 0)):
        fname = feature["name"]
        ftype = feature.get("type", "feature")
        priority = feature.get("priority", 0)
        description = feature.get("description", "")
        depends_on_features = feature.get("depends_on", [])
        feature_lines = feature.get("lines", target_lines)

        for line in feature_lines:
            if line not in target_lines and line not in feature.get("lines", []):
                continue

            step_counter += 1
            step_id = f"step_{step_counter:03d}"
            language = _LINE_LANGUAGE.get(line, "swift")

            # Resolve dependencies: find step IDs for the same line
            dep_ids = []
            for dep_name in depends_on_features:
                dep_key = (dep_name, line)
                if dep_key in feature_step_ids:
                    dep_ids.append(feature_step_ids[dep_key])

            # Map feature type to template
            template = ftype if ftype in ("feature", "screen", "service", "viewmodel") else "feature"

            steps.append(BuildStep(
                id=step_id,
                name=fname,
                step_type=ftype,
                template=template,
                template_name=fname,
                line=line,
                language=language,
                depends_on=dep_ids,
                priority=priority,
                description=description,
            ))

    return BuildPlan(
        project_name=project_name,
        steps=steps,
        created=datetime.now().isoformat(),
        status="draft",
    )


def parse_spec_file(project_name: str) -> BuildPlan:
    """Find and parse the build spec for a project. Returns empty plan if no spec."""
    spec_path = find_spec_file(project_name)
    if not spec_path:
        return BuildPlan(
            project_name=project_name,
            created=datetime.now().isoformat(),
            status="draft",
        )

    spec_data = _load_spec(spec_path)
    return parse_spec(spec_data, project_name)

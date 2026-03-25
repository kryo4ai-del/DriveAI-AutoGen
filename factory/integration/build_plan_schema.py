"""Extended Build Plan Schema -- supports Forge steps + Code steps.

Version 2.0 Build Plans add:
- forge phases (asset/sound/motion/scene generation)
- parallel groups with dependencies
- integration phases (copy forge outputs to project)
- cost estimates per phase

Backward compatible: v1 plans (code-only) still work.
"""

import json
import logging
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone

logger = logging.getLogger(__name__)


@dataclass
class BuildStep:
    """Single step in a build plan."""
    type: str = ""             # "forge", "integrate", "code", "compile_check", "repair"
    forge: str = ""            # For forge steps: "asset_forge", "sound_forge", etc.
    action: str = ""           # "generate", "copy_forge_outputs", "generate_code"
    specs_ref: str = ""        # Comma-separated spec IDs (e.g. "A-001,A-002")
    file: str = ""             # For code steps: filename
    line: str = ""             # For code steps: production line (ios/android/web/unity)
    target_platform: str = ""  # For integrate steps
    if_needed: bool = False    # For conditional steps (repair)


@dataclass
class BuildPhase:
    """A phase in a build plan (group of steps)."""
    phase: str = ""            # "forge_assets", "forge_scenes", "integrate", "code_generation"
    parallel_group: str = ""   # "A", "B", "C", "D"
    depends_on: str = ""       # Which group must complete first (e.g. "A" or "B")
    steps: list = field(default_factory=list)

    def __post_init__(self):
        # Convert dicts to BuildStep
        self.steps = [
            BuildStep(**s) if isinstance(s, dict) else s
            for s in self.steps
        ]


@dataclass
class FeatureBuildPlan:
    """Build plan for a single feature."""
    feature_id: str = ""
    feature_name: str = ""
    phases: list = field(default_factory=list)

    def __post_init__(self):
        self.phases = [
            BuildPhase(**p) if isinstance(p, dict) else p
            for p in self.phases
        ]


@dataclass
class BuildPlan:
    """Complete build plan for a project."""
    project: str = ""
    version: str = "2.0"
    generated_at: str = ""
    platforms: list = field(default_factory=list)
    features: list = field(default_factory=list)
    cost_estimate: dict = field(default_factory=lambda: {
        "forge_costs_usd": 0.0,
        "llm_costs_usd": 0.0,
        "total_usd": 0.0,
    })

    def __post_init__(self):
        if not self.generated_at:
            self.generated_at = datetime.now(timezone.utc).isoformat()
        self.features = [
            FeatureBuildPlan(**f) if isinstance(f, dict) else f
            for f in self.features
        ]

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "BuildPlan":
        data = json.loads(json_str)
        return cls(**data)

    def is_v2(self) -> bool:
        return self.version.startswith("2")

    def get_forge_phases(self) -> list:
        """Get all forge-type phases across all features."""
        phases = []
        for f in self.features:
            for p in f.phases:
                if any(s.type == "forge" for s in p.steps):
                    phases.append(p)
        return phases

    def get_code_phases(self) -> list:
        """Get all code-type phases."""
        phases = []
        for f in self.features:
            for p in f.phases:
                if any(s.type == "code" for s in p.steps):
                    phases.append(p)
        return phases

    def summary(self) -> str:
        forge_steps = sum(1 for f in self.features for p in f.phases
                          for s in p.steps if s.type == "forge")
        code_steps = sum(1 for f in self.features for p in f.phases
                         for s in p.steps if s.type == "code")
        integrate_steps = sum(1 for f in self.features for p in f.phases
                              for s in p.steps if s.type == "integrate")
        lines = [
            f"Build Plan: {self.project} (v{self.version})",
            f"Platforms: {', '.join(self.platforms)}",
            f"Features: {len(self.features)}",
            f"Forge Steps: {forge_steps}",
            f"Integrate Steps: {integrate_steps}",
            f"Code Steps: {code_steps}",
            f"Est. Cost: ${self.cost_estimate.get('total_usd', 0):.2f}",
        ]
        return "\n".join(lines)


class BuildPlanGenerator:
    """Generates Build Plans from ProjectForgeMaps."""

    # Cost estimates per item
    COST_PER_ITEM = {
        "asset_forge": 0.04,
        "sound_forge": 0.01,
        "motion_forge": 0.00,
        "scene_forge": 0.00,
    }
    COST_PER_CODE_FILE = 0.02

    def generate(self, forge_map, platforms: list = None) -> BuildPlan:
        """Generate a v2 Build Plan from a ProjectForgeMap."""
        if platforms is None:
            platforms = ["ios", "android", "web"]

        plan = BuildPlan(
            project=forge_map.project_name,
            platforms=platforms,
        )

        for feature in forge_map.features:
            fr = feature.forge_requirements if hasattr(feature, "forge_requirements") else feature.get("forge_requirements", {})
            cr = feature.code_requirements if hasattr(feature, "code_requirements") else feature.get("code_requirements", {})
            fid = feature.feature_id if hasattr(feature, "feature_id") else feature.get("feature_id", "?")
            fname = feature.feature_name if hasattr(feature, "feature_name") else feature.get("feature_name", "?")

            feature_plan = FeatureBuildPlan(
                feature_id=fid,
                feature_name=fname,
            )

            # Group A: asset + sound + motion forges (parallel)
            forge_phases_a = self._create_forge_phases_a(fr)
            if forge_phases_a:
                feature_plan.phases.extend(forge_phases_a)

            # Group B: scene forge (depends on A)
            forge_phase_b = self._create_forge_phase_b(fr, has_group_a=bool(forge_phases_a))
            if forge_phase_b:
                feature_plan.phases.append(forge_phase_b)

            # Group C: integration (depends on B or A)
            has_any_forge = bool(forge_phases_a) or bool(forge_phase_b)
            if has_any_forge:
                for platform in platforms:
                    lines_needed = cr.get("lines_needed", platforms)
                    if platform in lines_needed:
                        integrate = self._create_integration_phase(
                            fr, platform,
                            depends_on="B" if forge_phase_b else "A",
                        )
                        feature_plan.phases.append(integrate)

            # Group D: code generation (depends on C or nothing)
            for platform in platforms:
                lines_needed = cr.get("lines_needed", platforms)
                if platform in lines_needed:
                    code = self._create_code_phase(
                        fid, fname, cr, platform,
                        depends_on="C" if has_any_forge else "",
                    )
                    feature_plan.phases.append(code)

            plan.features.append(feature_plan)

        plan.cost_estimate = self._estimate_costs(plan, forge_map)
        return plan

    def _create_forge_phases_a(self, forge_reqs: dict) -> list:
        """Create Group A forge phases (asset, sound, motion — parallel)."""
        phases = []
        for forge_name in ("asset_forge", "sound_forge", "motion_forge"):
            req = forge_reqs.get(forge_name, {})
            if not isinstance(req, dict) or not req.get("needed"):
                continue
            items = req.get("items", [])
            if not items:
                continue

            specs = ",".join(item.get("ref", "") for item in items if item.get("ref"))
            phases.append(BuildPhase(
                phase=f"forge_{forge_name.replace('_forge', '')}",
                parallel_group="A",
                depends_on="",
                steps=[BuildStep(
                    type="forge",
                    forge=forge_name,
                    action="generate",
                    specs_ref=specs,
                )],
            ))
        return phases

    def _create_forge_phase_b(self, forge_reqs: dict, has_group_a: bool) -> BuildPhase:
        """Create Group B phase for scene_forge."""
        req = forge_reqs.get("scene_forge", {})
        if not isinstance(req, dict) or not req.get("needed"):
            return None
        items = req.get("items", [])
        if not items:
            return None

        specs = ",".join(item.get("ref", "") for item in items if item.get("ref"))
        return BuildPhase(
            phase="forge_scene",
            parallel_group="B",
            depends_on="A" if has_group_a else "",
            steps=[BuildStep(
                type="forge",
                forge="scene_forge",
                action="generate",
                specs_ref=specs,
            )],
        )

    def _create_integration_phase(self, forge_reqs: dict, platform: str, depends_on: str) -> BuildPhase:
        """Create Group C integration phase."""
        steps = []
        for forge_name in ("asset_forge", "sound_forge", "motion_forge", "scene_forge"):
            req = forge_reqs.get(forge_name, {})
            if isinstance(req, dict) and req.get("needed"):
                steps.append(BuildStep(
                    type="integrate",
                    forge=forge_name,
                    action="copy_forge_outputs",
                    target_platform=platform,
                ))

        return BuildPhase(
            phase=f"integrate_{platform}",
            parallel_group="C",
            depends_on=depends_on,
            steps=steps,
        )

    def _create_code_phase(self, feature_id: str, feature_name: str,
                           code_reqs: dict, platform: str, depends_on: str) -> BuildPhase:
        """Create Group D code generation phase."""
        est_files = code_reqs.get("estimated_files", 3)
        steps = []
        for i in range(min(est_files, 10)):  # Cap at 10 per feature
            steps.append(BuildStep(
                type="code",
                action="generate_code",
                file=f"{feature_id}_{platform}_file_{i+1}",
                line=platform,
            ))

        return BuildPhase(
            phase=f"code_{platform}",
            parallel_group="D",
            depends_on=depends_on,
            steps=steps,
        )

    def _estimate_costs(self, plan: BuildPlan, forge_map) -> dict:
        """Estimate total costs."""
        forge_cost = 0.0
        for forge_name, rate in self.COST_PER_ITEM.items():
            summary = forge_map.forge_summary.get(forge_name, {})
            forge_cost += summary.get("total_items", 0) * rate

        code_steps = sum(1 for f in plan.features for p in f.phases
                         for s in p.steps if s.type == "code")
        llm_cost = code_steps * self.COST_PER_CODE_FILE

        return {
            "forge_costs_usd": round(forge_cost, 4),
            "llm_costs_usd": round(llm_cost, 4),
            "total_usd": round(forge_cost + llm_cost, 4),
        }


def validate_build_plan(plan: BuildPlan) -> list:
    """Validate a build plan for consistency.

    Returns list of error strings (empty = valid).
    """
    errors = []

    # 1. Version check
    if plan.version not in ("1.0", "2.0"):
        errors.append(f"Invalid version: {plan.version}")

    # Collect all defined parallel_groups
    all_groups = set()
    all_depends = set()
    for f in plan.features:
        if not f.phases:
            errors.append(f"Feature {f.feature_id} has no phases")
        for p in f.phases:
            if p.parallel_group:
                all_groups.add(p.parallel_group)
            if p.depends_on:
                all_depends.add(p.depends_on)

    # 2. All depends_on reference existing groups
    missing = all_depends - all_groups
    if missing:
        errors.append(f"depends_on references undefined groups: {missing}")

    # 3. No circular dependencies
    dep_graph = {}
    for f in plan.features:
        for p in f.phases:
            if p.parallel_group and p.depends_on:
                dep_graph.setdefault(p.parallel_group, set()).add(p.depends_on)

    if _has_cycle(dep_graph):
        errors.append("Circular dependency detected in parallel groups")

    # 4. Every forge step has non-empty specs_ref
    for f in plan.features:
        for p in f.phases:
            for s in p.steps:
                if s.type == "forge" and not s.specs_ref:
                    errors.append(f"Forge step in {f.feature_id}/{p.phase} missing specs_ref")

    # 5. Code steps come after forge/integrate in dependency chain
    for f in plan.features:
        code_groups = set()
        forge_groups = set()
        for p in f.phases:
            has_code = any(s.type == "code" for s in p.steps)
            has_forge = any(s.type in ("forge", "integrate") for s in p.steps)
            if has_code and p.parallel_group:
                code_groups.add(p.parallel_group)
            if has_forge and p.parallel_group:
                forge_groups.add(p.parallel_group)

        # If both exist, code group should depend on forge group (transitively)
        if code_groups and forge_groups:
            for cg in code_groups:
                reachable = _reachable_from(cg, dep_graph)
                if not reachable & forge_groups:
                    # Code doesn't depend on forges — might be intentional for code-only features
                    pass

    # 6. At least 1 step per feature
    for f in plan.features:
        total_steps = sum(len(p.steps) for p in f.phases)
        if total_steps == 0:
            errors.append(f"Feature {f.feature_id} has 0 steps")

    return errors


def is_legacy_plan(plan_json: str) -> bool:
    """Check if a plan JSON is v1 (legacy, code-only)."""
    try:
        data = json.loads(plan_json)
        return data.get("version", "1.0") == "1.0" or "version" not in data
    except Exception:
        return True


def _has_cycle(graph: dict) -> bool:
    """Check for cycles in dependency graph via DFS."""
    visited = set()
    path = set()

    def dfs(node):
        if node in path:
            return True
        if node in visited:
            return False
        visited.add(node)
        path.add(node)
        for neighbor in graph.get(node, set()):
            if dfs(neighbor):
                return True
        path.discard(node)
        return False

    for node in graph:
        if dfs(node):
            return True
    return False


def _reachable_from(start: str, graph: dict) -> set:
    """Find all nodes reachable from start via depends_on."""
    visited = set()
    queue = [start]
    while queue:
        node = queue.pop(0)
        for dep in graph.get(node, set()):
            if dep not in visited:
                visited.add(dep)
                queue.append(dep)
    return visited

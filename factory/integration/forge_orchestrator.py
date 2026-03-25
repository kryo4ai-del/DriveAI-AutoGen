"""Forge Orchestrator -- coordinates all 4 Forge runs in correct dependency order.

Execution order:
  Group A (sequential for MVP): Asset Forge + Sound Forge + Motion Forge
  Group B (after A): Scene Forge (may need asset references)

Group A Forges are independent and could run in parallel.
Scene Forge depends on Asset Forge outputs for prefab asset references.
"""

import json
import logging
import time
from dataclasses import dataclass, field
from pathlib import Path
from datetime import datetime, timezone

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[2]


@dataclass
class ForgeRunResult:
    """Result of a single Forge run."""
    forge_name: str
    success: bool
    manifest_path: str = ""
    items_generated: int = 0
    items_failed: int = 0
    cost: float = 0.0
    duration_seconds: float = 0.0
    error: str = ""


@dataclass
class ForgeOrchestratorResult:
    """Result of the complete Forge orchestration."""
    project_name: str
    mode: str = "full"
    forge_results: dict = field(default_factory=dict)
    total_cost: float = 0.0
    total_duration: float = 0.0
    all_manifests: dict = field(default_factory=dict)
    errors: list = field(default_factory=list)

    def summary(self) -> str:
        lines = [
            "Forge Orchestrator Results:",
            f"  Project: {self.project_name}",
            f"  Mode: {self.mode}",
            f"  Total Cost: ${self.total_cost:.2f}",
            f"  Duration: {self.total_duration:.1f}s",
            "",
        ]
        for name, result in self.forge_results.items():
            status = "OK" if result.success else "FAIL"
            lines.append(
                f"  [{status}] {name}: {result.items_generated} items, "
                f"${result.cost:.2f}, {result.duration_seconds:.1f}s"
            )
            if result.error:
                lines.append(f"      Error: {result.error}")
        if self.errors:
            lines.append("")
            lines.append("  Errors:")
            for e in self.errors:
                lines.append(f"    - {e}")
        return "\n".join(lines)


class ForgeOrchestrator:
    """Coordinates all 4 Forge runs."""

    FORGE_ORDER_A = ["asset_forge", "sound_forge", "motion_forge"]
    FORGE_ORDER_B = ["scene_forge"]

    def __init__(self, max_cost: float = 5.0):
        self._max_cost = max_cost
        self._cost_so_far = 0.0

    def run(self, roadbook_dir: str, project_name: str,
            build_plan=None, budget: float = None,
            skip_forges: list = None) -> ForgeOrchestratorResult:
        """Execute all Forge runs in dependency order.

        Args:
            roadbook_dir: Path to Roadbook PDFs
            project_name: e.g. "echomatch"
            build_plan: Optional BuildPlan v2 (if None, runs all Forges)
            budget: Max total cost (overrides default)
            skip_forges: List of forge names to skip
        """
        if budget is not None:
            self._max_cost = budget
        self._cost_so_far = 0.0

        skip = set(skip_forges or [])
        result = ForgeOrchestratorResult(project_name=project_name, mode="full")
        start = time.time()

        # Determine which forges to run
        forges_needed = self._get_forges_from_plan(build_plan) if build_plan else None

        # Group A: asset, sound, motion (sequential)
        for forge_name in self.FORGE_ORDER_A:
            if forge_name in skip:
                logger.info("Skipping %s (user request)", forge_name)
                continue
            if forges_needed is not None and forge_name not in forges_needed:
                logger.info("Skipping %s (not in build plan)", forge_name)
                continue

            remaining = self._max_cost - self._cost_so_far
            if remaining <= 0:
                result.errors.append(f"Budget exhausted before {forge_name}")
                break

            fr = self._run_forge(forge_name, roadbook_dir, project_name, remaining)
            result.forge_results[forge_name] = fr
            self._cost_so_far += fr.cost
            if fr.manifest_path:
                result.all_manifests[forge_name] = fr.manifest_path
            if not fr.success and fr.error:
                result.errors.append(f"{forge_name}: {fr.error}")

        # Group B: scene_forge (depends on Group A)
        for forge_name in self.FORGE_ORDER_B:
            if forge_name in skip:
                continue
            if forges_needed is not None and forge_name not in forges_needed:
                continue

            remaining = self._max_cost - self._cost_so_far
            if remaining <= 0:
                result.errors.append(f"Budget exhausted before {forge_name}")
                break

            fr = self._run_forge(forge_name, roadbook_dir, project_name, remaining)
            result.forge_results[forge_name] = fr
            self._cost_so_far += fr.cost
            if fr.manifest_path:
                result.all_manifests[forge_name] = fr.manifest_path
            if not fr.success and fr.error:
                result.errors.append(f"{forge_name}: {fr.error}")

        result.total_cost = self._cost_so_far
        result.total_duration = time.time() - start
        return result

    def dry_run(self, roadbook_dir: str, project_name: str) -> ForgeOrchestratorResult:
        """Dry run all Forges (no generation, only specs + cost estimates)."""
        result = ForgeOrchestratorResult(project_name=project_name, mode="dry_run")
        start = time.time()

        for forge_name in self.FORGE_ORDER_A + self.FORGE_ORDER_B:
            fr = self._dry_run_forge(forge_name, roadbook_dir, project_name)
            result.forge_results[forge_name] = fr
            result.total_cost += fr.cost
            if fr.manifest_path:
                result.all_manifests[forge_name] = fr.manifest_path
            if not fr.success and fr.error:
                result.errors.append(f"{forge_name}: {fr.error}")

        result.total_duration = time.time() - start
        return result

    def _run_forge(self, forge_name: str, roadbook_dir: str,
                   project_name: str, budget: float) -> ForgeRunResult:
        """Dispatch to the correct Forge orchestrator."""
        start = time.time()
        try:
            if forge_name == "asset_forge":
                return self._run_asset_forge(roadbook_dir, project_name, budget)
            elif forge_name == "sound_forge":
                return self._run_sound_forge(roadbook_dir, project_name, budget)
            elif forge_name == "motion_forge":
                return self._run_motion_forge(roadbook_dir, project_name, budget)
            elif forge_name == "scene_forge":
                return self._run_scene_forge(roadbook_dir, project_name, budget)
            else:
                return ForgeRunResult(
                    forge_name=forge_name, success=False,
                    error=f"Unknown forge: {forge_name}",
                    duration_seconds=time.time() - start,
                )
        except Exception as e:
            logger.error("Forge %s crashed: %s", forge_name, e)
            return ForgeRunResult(
                forge_name=forge_name, success=False,
                error=str(e), duration_seconds=time.time() - start,
            )

    def _run_asset_forge(self, roadbook_dir: str, project_name: str,
                         budget: float) -> ForgeRunResult:
        """Import and run AssetForgePipeline."""
        start = time.time()
        try:
            from factory.asset_forge.pipeline import AssetForgePipeline
            pipeline = AssetForgePipeline()
            r = pipeline.run(
                roadbook_dir=roadbook_dir,
                project_name=project_name,
                budget_limit=budget,
            )
            manifest = self._find_manifest("asset_forge", project_name)
            return ForgeRunResult(
                forge_name="asset_forge",
                success=r.succeeded > 0 or r.total_specs == 0,
                manifest_path=manifest,
                items_generated=r.succeeded,
                items_failed=r.failed,
                cost=r.total_cost,
                duration_seconds=time.time() - start,
            )
        except Exception as e:
            return ForgeRunResult(
                forge_name="asset_forge", success=False,
                error=str(e), duration_seconds=time.time() - start,
            )

    def _run_sound_forge(self, roadbook_dir: str, project_name: str,
                         budget: float) -> ForgeRunResult:
        """Import and run SoundForgeOrchestrator."""
        start = time.time()
        try:
            from factory.sound_forge.sound_forge_orchestrator import SoundForgeOrchestrator
            orch = SoundForgeOrchestrator()
            r = orch.run(
                roadbook_dir=roadbook_dir,
                project_name=project_name,
                budget=budget,
            )
            return ForgeRunResult(
                forge_name="sound_forge",
                success=r.total_succeeded > 0 or r.total_specs == 0,
                manifest_path=r.manifest_path,
                items_generated=r.total_succeeded,
                items_failed=r.total_failed,
                cost=r.total_cost,
                duration_seconds=r.duration_seconds,
            )
        except Exception as e:
            return ForgeRunResult(
                forge_name="sound_forge", success=False,
                error=str(e), duration_seconds=time.time() - start,
            )

    def _run_motion_forge(self, roadbook_dir: str, project_name: str,
                          budget: float) -> ForgeRunResult:
        """Import and run MotionForgeOrchestrator."""
        start = time.time()
        try:
            from factory.motion_forge.motion_forge_orchestrator import MotionForgeOrchestrator
            orch = MotionForgeOrchestrator(
                project_name=project_name,
                roadbook_dir=roadbook_dir,
                budget=budget,
            )
            r = orch.run()
            return ForgeRunResult(
                forge_name="motion_forge",
                success=r.total_generated > 0 or r.total_specs == 0,
                manifest_path=r.manifest_path,
                items_generated=r.total_generated,
                items_failed=r.total_failed,
                cost=r.total_cost,
                duration_seconds=r.duration_seconds,
            )
        except Exception as e:
            return ForgeRunResult(
                forge_name="motion_forge", success=False,
                error=str(e), duration_seconds=time.time() - start,
            )

    def _run_scene_forge(self, roadbook_dir: str, project_name: str,
                         budget: float) -> ForgeRunResult:
        """Import and run SceneForgeOrchestrator."""
        start = time.time()
        try:
            from factory.scene_forge.scene_forge_orchestrator import SceneForgeOrchestrator
            orch = SceneForgeOrchestrator(
                project_name=project_name,
                roadbook_dir=roadbook_dir,
                budget=budget,
            )
            r = orch.run()
            total_gen = (r.levels.get("generated", 0) + r.scenes.get("generated", 0)
                         + r.shaders.get("generated", 0) + r.prefabs.get("generated", 0))
            total_fail = (r.levels.get("failed", 0) + r.scenes.get("failed", 0)
                          + r.shaders.get("failed", 0) + r.prefabs.get("failed", 0))
            return ForgeRunResult(
                forge_name="scene_forge",
                success=total_gen > 0 or (r.levels.get("total", 0) == 0
                                          and r.scenes.get("total", 0) == 0),
                manifest_path=r.manifest_path,
                items_generated=total_gen,
                items_failed=total_fail,
                cost=r.total_cost,
                duration_seconds=r.duration_seconds,
            )
        except Exception as e:
            return ForgeRunResult(
                forge_name="scene_forge", success=False,
                error=str(e), duration_seconds=time.time() - start,
            )

    def _dry_run_forge(self, forge_name: str, roadbook_dir: str,
                       project_name: str) -> ForgeRunResult:
        """Dry-run a single Forge."""
        start = time.time()
        try:
            if forge_name == "asset_forge":
                from factory.asset_forge.pipeline import AssetForgePipeline
                pipeline = AssetForgePipeline()
                r = pipeline.dry_run(roadbook_dir=roadbook_dir, project_name=project_name)
                return ForgeRunResult(
                    forge_name=forge_name, success=True,
                    items_generated=r.ai_generatable,
                    cost=r.total_cost,
                    duration_seconds=time.time() - start,
                )
            elif forge_name == "sound_forge":
                from factory.sound_forge.sound_forge_orchestrator import SoundForgeOrchestrator
                orch = SoundForgeOrchestrator()
                r = orch.dry_run(roadbook_dir=roadbook_dir, project_name=project_name)
                return ForgeRunResult(
                    forge_name=forge_name, success=True,
                    items_generated=r.total_specs,
                    cost=r.total_cost,
                    duration_seconds=r.duration_seconds,
                )
            elif forge_name == "motion_forge":
                from factory.motion_forge.motion_forge_orchestrator import MotionForgeOrchestrator
                orch = MotionForgeOrchestrator(
                    project_name=project_name, roadbook_dir=roadbook_dir,
                )
                r = orch.dry_run()
                return ForgeRunResult(
                    forge_name=forge_name, success=True,
                    items_generated=r.total_specs,
                    cost=r.total_cost,
                    duration_seconds=r.duration_seconds,
                )
            elif forge_name == "scene_forge":
                from factory.scene_forge.scene_forge_orchestrator import SceneForgeOrchestrator
                orch = SceneForgeOrchestrator(
                    project_name=project_name, roadbook_dir=roadbook_dir,
                )
                r = orch.run(dry_run=True)
                return ForgeRunResult(
                    forge_name=forge_name, success=True,
                    cost=r.total_cost,
                    duration_seconds=r.duration_seconds,
                )
            else:
                return ForgeRunResult(
                    forge_name=forge_name, success=False,
                    error=f"Unknown forge: {forge_name}",
                )
        except Exception as e:
            return ForgeRunResult(
                forge_name=forge_name, success=False,
                error=str(e), duration_seconds=time.time() - start,
            )

    def _get_forges_from_plan(self, build_plan) -> set:
        """Extract which forges are needed from a BuildPlan."""
        needed = set()
        for feature in build_plan.features:
            for phase in feature.phases:
                for step in phase.steps:
                    if step.type == "forge" and step.forge:
                        needed.add(step.forge)
        return needed

    def _find_manifest(self, forge_name: str, project_name: str) -> str:
        """Find the manifest file for a Forge's output.

        Searches:
        - factory/{forge}/catalog/{project}/*manifest*.json
        - factory/{forge}/output/{project}/*manifest*.json
        """
        # Map forge name to directory
        forge_dir = forge_name  # asset_forge, sound_forge, etc.

        search_dirs = [
            PROJECT_ROOT / "factory" / forge_dir / "catalog" / project_name,
            PROJECT_ROOT / "factory" / forge_dir / "output" / project_name,
        ]

        manifest_patterns = [
            f"*manifest*.json",
            f"{project_name}_manifest.json",
        ]

        for search_dir in search_dirs:
            if not search_dir.exists():
                continue
            for pattern in manifest_patterns:
                matches = list(search_dir.glob(pattern))
                if matches:
                    return str(matches[0])

        return ""

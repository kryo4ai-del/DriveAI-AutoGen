"""Full Pipeline Orchestrator -- from CD Roadbook to complete project.

The complete autonomous workflow:
1. Read CD Roadbook
2. Analyze Forge requirements per feature
3. Generate Build Plan v2
4. Run all Forges (Asset -> Sound -> Motion -> Scene)
5. Integrate Forge outputs into project structure
6. Create Integration Map for code generation
7. (Future: trigger code generation via existing pipeline)
8. Generate summary report

This orchestrator coordinates ALL departments. It is the highest-level
automation in the factory -- one command from CEO, everything runs.
"""

import argparse
import json
import logging
import sys
import time
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[2]
CACHE_MAX_AGE_HOURS = 24


@dataclass
class FullPipelineResult:
    """Result of a complete pipeline run."""
    project_name: str
    platform: str
    mode: str = "full"
    started_at: str = ""
    duration_seconds: float = 0.0

    # Forge analysis
    forge_analysis: dict = field(default_factory=dict)

    # Per-forge results
    asset_forge: dict = field(default_factory=dict)
    sound_forge: dict = field(default_factory=dict)
    motion_forge: dict = field(default_factory=dict)
    scene_forge: dict = field(default_factory=dict)
    forge_total_cost: float = 0.0

    # Integration
    integration: dict = field(default_factory=dict)
    integration_map_path: str = ""

    # Code generation readiness
    code_ready: bool = False

    # Totals
    total_files_generated: int = 0
    total_cost: float = 0.0
    errors: list = field(default_factory=list)
    warnings: list = field(default_factory=list)
    ceo_actions: list = field(default_factory=list)

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2, ensure_ascii=False)

    def summary(self) -> str:
        lines = [
            "=" * 56,
            "  FULL PIPELINE -- RUN COMPLETE",
            "=" * 56,
            f"  Project:          {self.project_name}",
            f"  Platform:         {self.platform}",
            f"  Mode:             {self.mode}",
            f"  Duration:         {self.duration_seconds:.1f}s",
            "",
            "  -- FORGE ANALYSIS -------------------------",
            f"  Features found:   {self.forge_analysis.get('features', 0)}",
            f"  Forge items:      {self.forge_analysis.get('total_items', 0)}",
            "",
            "  -- FORGES ---------------------------------",
        ]
        for forge_name in ["asset_forge", "sound_forge", "motion_forge", "scene_forge"]:
            result = getattr(self, forge_name, {})
            if result and result.get("attempted"):
                status = "OK" if result.get("success") else "FAIL"
                items = result.get("items", 0)
                cost = result.get("cost", 0)
                cached = " (cached)" if result.get("cached") else ""
                lines.append(
                    f"  [{status}] {forge_name:20s} {items:3d} items  "
                    f"${cost:.2f}{cached}"
                )
            elif result and result.get("cached"):
                items = result.get("items", 0)
                lines.append(
                    f"  [OK]  {forge_name:20s} {items:3d} items  "
                    f"$0.00 (cached)"
                )
            else:
                lines.append(f"  [SKIP] {forge_name:20s} skipped")
        lines.append(f"  {'-' * 42}")
        lines.append(f"  Forge Total:       ${self.forge_total_cost:.2f}")

        lines.extend([
            "",
            "  -- INTEGRATION ----------------------------",
            f"  Entries:          {self.integration.get('total', 0)}",
            f"  Integrated:       {self.integration.get('integrated', 0)}",
            f"  Missing:          {self.integration.get('missing', 0)}",
            f"  N/A:              {self.integration.get('not_applicable', 0)}",
            f"  Map:              {self.integration_map_path or 'N/A'}",
            "",
            "  -- TOTALS ---------------------------------",
            f"  Total Files:      {self.total_files_generated}",
            f"  Total Cost:       ${self.total_cost:.2f}",
            f"  Code Ready:       {'Yes' if self.code_ready else 'No'}",
        ])

        if self.ceo_actions:
            lines.extend(["", "  -- CEO ACTIONS NEEDED ---------------------"])
            for i, action in enumerate(self.ceo_actions, 1):
                lines.append(f"  {i}. {action}")

        if self.warnings:
            lines.extend(["", "  -- WARNINGS -------------------------------"])
            for w in self.warnings:
                lines.append(f"  WARN: {w}")

        if self.errors:
            lines.extend(["", "  -- ERRORS ---------------------------------"])
            for e in self.errors:
                lines.append(f"  ERR:  {e}")

        lines.append("=" * 56)
        return "\n".join(lines)


class FullPipelineOrchestrator:
    """Orchestrates the complete production pipeline."""

    def __init__(self, max_budget: float = 5.0):
        self._max_budget = max_budget
        self._cost = 0.0

    def run(self, roadbook_dir: str, project_name: str,
            platform: str = "unity",
            budget: float = None,
            skip_forges: list = None,
            forges_only: bool = False) -> FullPipelineResult:
        """Full pipeline run."""
        if budget is not None:
            self._max_budget = budget
        self._cost = 0.0

        result = FullPipelineResult(
            project_name=project_name,
            platform=platform,
            mode="forges_only" if forges_only else "full",
            started_at=datetime.now(timezone.utc).isoformat(),
        )
        start = time.time()

        # Step 1-2: Analyze roadbook
        logger.info("Step 1: Analyzing CD Roadbook...")
        analysis = self._analyze_roadbook(roadbook_dir, project_name)
        result.forge_analysis = {
            "features": analysis.get("feature_count", 0),
            "total_items": analysis.get("total_items", 0),
        }
        self._cost += analysis.get("cost", 0)

        if analysis.get("error"):
            result.errors.append(f"Analysis: {analysis['error']}")

        # Step 3: Run Forges (or use cached)
        logger.info("Step 2: Running Forges...")
        forge_budget = self._max_budget - self._cost
        forge_results = self._run_forges(
            roadbook_dir, project_name, forge_budget,
            skip=skip_forges,
            build_plan=analysis.get("build_plan"),
        )

        # Map forge results
        for fname in ["asset_forge", "sound_forge", "motion_forge", "scene_forge"]:
            fr = forge_results.get(fname, {})
            setattr(result, fname, fr)

        result.forge_total_cost = forge_results.get("total_cost", 0)
        self._cost += result.forge_total_cost

        total_items = sum(
            getattr(result, f).get("items", 0)
            for f in ["asset_forge", "sound_forge", "motion_forge", "scene_forge"]
        )
        result.total_files_generated = total_items

        if forge_results.get("errors"):
            result.errors.extend(forge_results["errors"])

        # Step 4: Integrate assets
        logger.info("Step 3: Integrating assets for %s...", platform)
        integration = self._integrate_assets(
            project_name, platform,
            manifests=forge_results.get("manifests"),
        )
        result.integration = {
            "total": integration.get("total", 0),
            "integrated": integration.get("integrated", 0),
            "missing": integration.get("missing", 0),
            "not_applicable": integration.get("not_applicable", 0),
        }
        result.integration_map_path = integration.get("map_path", "")

        if integration.get("error"):
            result.errors.append(f"Integration: {integration['error']}")

        # Code readiness
        result.code_ready = (
            result.integration.get("integrated", 0) > 0
            and bool(result.integration_map_path)
        )

        # CEO actions
        result.ceo_actions = self._determine_ceo_actions(result)

        # Totals
        result.total_cost = self._cost
        result.duration_seconds = time.time() - start

        # Save result
        self._save_result(result)

        return result

    def dry_run(self, roadbook_dir: str, project_name: str,
                platform: str = "unity") -> FullPipelineResult:
        """Dry run: analyze + build plan + check cached outputs."""
        result = FullPipelineResult(
            project_name=project_name,
            platform=platform,
            mode="dry_run",
            started_at=datetime.now(timezone.utc).isoformat(),
        )
        start = time.time()

        # Analyze
        analysis = self._analyze_roadbook(roadbook_dir, project_name)
        result.forge_analysis = {
            "features": analysis.get("feature_count", 0),
            "total_items": analysis.get("total_items", 0),
        }
        self._cost += analysis.get("cost", 0)

        if analysis.get("error"):
            result.errors.append(f"Analysis: {analysis['error']}")

        # Check cached forge outputs
        for fname in ["asset_forge", "sound_forge", "motion_forge", "scene_forge"]:
            manifest = self._find_cached_manifest(fname, project_name)
            if manifest:
                items = self._count_manifest_items(manifest, fname)
                setattr(result, fname, {
                    "success": True, "attempted": False, "cached": True,
                    "items": items, "cost": 0.0,
                })
                result.total_files_generated += items
            else:
                setattr(result, fname, {
                    "success": False, "attempted": False, "cached": False,
                    "items": 0, "cost": 0.0,
                })
                result.warnings.append(f"{fname}: no cached output found")

        # Check existing integration map
        map_path = (PROJECT_ROOT / "factory" / "integration" / "maps"
                    / f"{project_name}_{platform}_map.json")
        if map_path.exists():
            result.integration_map_path = str(map_path)
            result.code_ready = True

        # Build plan cost estimate
        build_plan = analysis.get("build_plan")
        if build_plan:
            result.total_cost = build_plan.cost_estimate.get("total_usd", 0)
        else:
            result.total_cost = self._cost

        result.ceo_actions = self._determine_ceo_actions(result)
        result.duration_seconds = time.time() - start

        return result

    def estimate_cost(self, roadbook_dir: str, project_name: str,
                      platform: str = "unity") -> float:
        """Quick cost estimate."""
        analysis = self._analyze_roadbook(roadbook_dir, project_name)
        build_plan = analysis.get("build_plan")
        if build_plan:
            return build_plan.cost_estimate.get("total_usd", 0)
        return 0.0

    # ── Internal steps ──────────────────────────────────────────

    def _analyze_roadbook(self, roadbook_dir: str, project_name: str) -> dict:
        """Step 1-2: CDForgeInterface -> ForgeMap -> BuildPlan."""
        result = {"feature_count": 0, "total_items": 0, "cost": 0, "error": ""}

        # Check for cached forge requirements
        cached = (PROJECT_ROOT / "factory" / "integration" / "build_plans"
                  / f"{project_name}_forge_requirements.json")
        if cached.exists() and self._is_fresh(cached):
            logger.info("Using cached forge requirements: %s", cached)
            try:
                from factory.integration.cd_forge_interface import ProjectForgeMap
                forge_map = ProjectForgeMap.from_json(
                    cached.read_text(encoding="utf-8"))
                result["feature_count"] = forge_map.total_features
                result["total_items"] = sum(
                    v.get("total_items", 0)
                    for v in forge_map.forge_summary.values()
                )
                result["forge_map"] = forge_map
                result["cost"] = 0
            except Exception as e:
                logger.warning("Cache load failed: %s", e)
                # Fall through to LLM analysis
            else:
                # Build plan from cached map
                try:
                    from factory.integration.build_plan_schema import BuildPlanGenerator
                    gen = BuildPlanGenerator()
                    plan = gen.generate(forge_map)
                    result["build_plan"] = plan
                except Exception as e:
                    logger.warning("BuildPlan generation failed: %s", e)
                return result

        # Fresh analysis via LLM
        try:
            from factory.integration.cd_forge_interface import CDForgeInterface
            from factory.integration.build_plan_schema import BuildPlanGenerator

            interface = CDForgeInterface()
            forge_map = interface.analyze(roadbook_dir, project_name)

            result["feature_count"] = forge_map.total_features
            result["total_items"] = sum(
                v.get("total_items", 0)
                for v in forge_map.forge_summary.values()
            )
            result["forge_map"] = forge_map
            result["cost"] = 0.02  # Estimated LLM cost

            gen = BuildPlanGenerator()
            plan = gen.generate(forge_map)
            result["build_plan"] = plan

        except Exception as e:
            result["error"] = str(e)
            logger.error("Roadbook analysis failed: %s", e)

        return result

    def _run_forges(self, roadbook_dir: str, project_name: str,
                    budget: float, skip: list = None,
                    build_plan=None) -> dict:
        """Step 3: ForgeOrchestrator runs all Forges (or uses cached)."""
        results = {
            "asset_forge": {}, "sound_forge": {},
            "motion_forge": {}, "scene_forge": {},
            "total_cost": 0.0, "manifests": {}, "errors": [],
        }

        skip_set = set(skip or [])

        for forge_name in ["asset_forge", "sound_forge", "motion_forge", "scene_forge"]:
            if forge_name in skip_set:
                results[forge_name] = {
                    "success": False, "attempted": False, "cached": False,
                    "items": 0, "cost": 0.0,
                }
                continue

            # Check for cached output first
            manifest_path = self._find_cached_manifest(forge_name, project_name)
            if manifest_path and self._is_fresh(Path(manifest_path)):
                items = self._count_manifest_items(manifest_path, forge_name)
                results[forge_name] = {
                    "success": True, "attempted": False, "cached": True,
                    "items": items, "cost": 0.0,
                }
                results["manifests"][forge_name] = manifest_path
                logger.info("%s: using cached output (%d items)", forge_name, items)
                continue

            # Run the forge
            remaining = budget - results["total_cost"]
            if remaining <= 0:
                results["errors"].append(
                    f"Budget exhausted before {forge_name}")
                break

            try:
                from factory.integration.forge_orchestrator import ForgeOrchestrator
                orch = ForgeOrchestrator(max_cost=remaining)
                fr = orch._run_forge(
                    forge_name, roadbook_dir, project_name, remaining)

                results[forge_name] = {
                    "success": fr.success,
                    "attempted": True,
                    "cached": False,
                    "items": fr.items_generated,
                    "cost": fr.cost,
                }
                results["total_cost"] += fr.cost

                if fr.manifest_path:
                    results["manifests"][forge_name] = fr.manifest_path
                if fr.error:
                    results["errors"].append(f"{forge_name}: {fr.error}")

            except Exception as e:
                results[forge_name] = {
                    "success": False, "attempted": True, "cached": False,
                    "items": 0, "cost": 0.0,
                }
                results["errors"].append(f"{forge_name}: {e}")
                logger.error("%s failed: %s", forge_name, e)

        return results

    def _integrate_assets(self, project_name: str, platform: str,
                          manifests: dict = None) -> dict:
        """Step 4: AssetIntegrator creates IntegrationMap."""
        try:
            from factory.integration.asset_integrator import AssetIntegrator

            integrator = AssetIntegrator()
            imap = integrator.integrate(
                project_name, platform,
                forge_manifests=manifests,
                copy_files=False,  # Don't copy in forges_only mode
            )

            return {
                "total": imap.total_entries,
                "integrated": imap.integrated,
                "missing": imap.missing,
                "not_applicable": imap.not_applicable,
                "map_path": str(
                    PROJECT_ROOT / "factory" / "integration" / "maps"
                    / f"{project_name}_{platform}_map.json"
                ),
            }
        except Exception as e:
            logger.error("Integration failed: %s", e)
            return {"total": 0, "integrated": 0, "missing": 0,
                    "not_applicable": 0, "error": str(e)}

    def _determine_ceo_actions(self, result: FullPipelineResult) -> list:
        """Determine what the CEO needs to do."""
        actions = []

        if result.platform == "unity":
            scenes = result.scene_forge.get("items", 0)
            if scenes > 0:
                actions.append(
                    "Open Unity project and verify Scene/Shader/Prefab loading")

        missing = result.integration.get("missing", 0)
        if missing > 0:
            actions.append(
                f"Review {missing} MISSING items in Integration Map "
                f"(assets not found on disk)")

        na = result.integration.get("not_applicable", 0)
        if na > 0 and result.platform != "unity":
            actions.append(
                f"{na} Unity-only assets skipped for {result.platform} "
                f"(scenes/shaders/prefabs/levels)")

        if result.code_ready:
            actions.append(
                f"Integration Map ready -- code generation can proceed "
                f"for {result.platform}")
        else:
            actions.append(
                "Integration Map not ready -- check errors above")

        if not result.asset_forge.get("items") and not result.asset_forge.get("cached"):
            actions.append(
                "No visual assets generated -- run Asset Forge with "
                "Roadbook PDFs or provide assets manually")

        total_cost = result.total_cost
        if total_cost > 0:
            actions.append(
                f"Pipeline cost: ${total_cost:.2f} "
                f"(budget: ${self._max_budget:.2f})")

        return actions

    # ── Helpers ──────────────────────────────────────────────────

    def _find_cached_manifest(self, forge_name: str, project_name: str) -> str:
        """Find cached manifest for a Forge."""
        search_dirs = [
            PROJECT_ROOT / "factory" / forge_name / "catalog" / project_name,
            PROJECT_ROOT / "factory" / forge_name / "output" / project_name,
        ]
        manifest_names = {
            "asset_forge": ["asset_manifest.json", "manifest.json",
                            f"{project_name}_manifest.json"],
            "sound_forge": ["sound_manifest.json"],
            "motion_forge": ["animation_manifest.json"],
            "scene_forge": ["scene_manifest.json"],
        }

        for search_dir in search_dirs:
            if not search_dir.exists():
                continue
            for mname in manifest_names.get(forge_name, []):
                candidate = search_dir / mname
                if candidate.exists():
                    return str(candidate)

        return ""

    def _count_manifest_items(self, manifest_path: str, forge_name: str) -> int:
        """Count items in a manifest file."""
        try:
            data = json.loads(Path(manifest_path).read_text(encoding="utf-8"))
        except Exception:
            return 0

        if forge_name == "sound_forge":
            return len(data.get("sounds", []))
        elif forge_name == "motion_forge":
            return len(data.get("animations", []))
        elif forge_name == "scene_forge":
            return (len(data.get("levels", {}).get("files", []))
                    + len(data.get("scenes", {}).get("files", []))
                    + len(data.get("shaders", {}).get("files", []))
                    + len(data.get("prefabs", {}).get("files", [])))
        elif forge_name == "asset_forge":
            return len(data.get("specs", []))
        return 0

    def _is_fresh(self, path: Path) -> bool:
        """Check if file is less than CACHE_MAX_AGE_HOURS old."""
        try:
            mtime = path.stat().st_mtime
            age_hours = (time.time() - mtime) / 3600
            return age_hours < CACHE_MAX_AGE_HOURS
        except Exception:
            return False

    def _save_result(self, result: FullPipelineResult):
        """Save result to integration/maps/."""
        out_dir = PROJECT_ROOT / "factory" / "integration" / "maps"
        out_dir.mkdir(parents=True, exist_ok=True)
        path = out_dir / f"{result.project_name}_pipeline_result.json"
        path.write_text(result.to_json(), encoding="utf-8")
        logger.info("Pipeline result saved: %s", path)


def main():
    """CLI entry point."""
    logging.basicConfig(
        level=logging.INFO,
        format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    )

    parser = argparse.ArgumentParser(
        description="Full Pipeline -- CD Roadbook to complete project")
    parser.add_argument("--project", required=True, help="Project name")
    parser.add_argument("--roadbook-dir", required=True,
                        help="Roadbook PDF directory")
    parser.add_argument("--platform", default="unity",
                        help="Target platform (unity,ios,android,web)")
    parser.add_argument("--dry-run", action="store_true",
                        help="No generation, only analysis")
    parser.add_argument("--estimate-cost", action="store_true",
                        help="Cost estimate only")
    parser.add_argument("--forges-only", action="store_true",
                        help="Forges + Integration only")
    parser.add_argument("--skip", help="Comma-separated Forges to skip")
    parser.add_argument("--budget", type=float, default=5.0,
                        help="Max budget in USD")

    args = parser.parse_args()

    skip_forges = args.skip.split(",") if args.skip else None
    orchestrator = FullPipelineOrchestrator(max_budget=args.budget)

    if args.estimate_cost:
        cost = orchestrator.estimate_cost(
            args.roadbook_dir, args.project, args.platform)
        print(f"Estimated total cost: ${cost:.2f}")
        sys.exit(0)

    if args.dry_run:
        result = orchestrator.dry_run(
            args.roadbook_dir, args.project, args.platform)
        print(result.summary())
        sys.exit(0)

    result = orchestrator.run(
        roadbook_dir=args.roadbook_dir,
        project_name=args.project,
        platform=args.platform.split(",")[0],
        budget=args.budget,
        skip_forges=skip_forges,
        forges_only=args.forges_only or True,
    )
    print(result.summary())


if __name__ == "__main__":
    main()

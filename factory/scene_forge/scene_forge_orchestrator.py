"""Scene Forge Orchestrator -- end-to-end pipeline for Unity asset generation.

Pipeline steps:
1. Extract specs from Roadbook PDFs (or load cached)
2. Generate levels (LevelGenerator)
3. Generate scenes (UnitySceneWriter)
4. Generate shaders (ShaderGenerator)
5. Generate prefabs (PrefabGenerator)
6. Validate all generated files
7. Build catalog
"""

import json
import logging
import time
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path

from factory.scene_forge.scene_spec_extractor import SceneSpecExtractor, SceneManifest
from factory.scene_forge.level_generator import LevelGenerator
from factory.scene_forge.unity_scene_writer import UnitySceneWriter
from factory.scene_forge.shader_generator import ShaderGenerator
from factory.scene_forge.prefab_generator import PrefabGenerator
from factory.scene_forge.scene_validator import SceneValidator
from factory.scene_forge.scene_catalog_manager import SceneCatalogManager

logger = logging.getLogger(__name__)

GENERATED_DIR = Path(__file__).parent / "generated"
SPECS_DIR = Path(__file__).parent / "specs"


@dataclass
class OrchestratorResult:
    project_name: str
    mode: str = "full"
    duration_seconds: float = 0.0
    levels: dict = field(default_factory=lambda: {"total": 0, "generated": 0, "failed": 0})
    scenes: dict = field(default_factory=lambda: {"total": 0, "generated": 0, "failed": 0})
    shaders: dict = field(default_factory=lambda: {"total": 0, "generated": 0, "failed": 0, "template_count": 0, "custom_count": 0})
    prefabs: dict = field(default_factory=lambda: {"total": 0, "generated": 0, "failed": 0})
    total_cost: float = 0.0
    validation_summary: dict = field(default_factory=lambda: {"pass": 0, "warn": 0, "fail": 0})
    manifest_path: str = ""
    errors: list = field(default_factory=list)
    warnings: list = field(default_factory=list)

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2, ensure_ascii=False)

    def summary(self) -> str:
        total_files = (self.levels["generated"] + self.scenes["generated"]
                       + self.shaders["generated"] + self.prefabs["generated"])
        lines = [
            "",
            "=" * 50,
            "  SCENE FORGE -- RUN COMPLETE",
            "=" * 50,
            f"  Project:         {self.project_name}",
            f"  Mode:            {self.mode}",
            f"  Duration:        {self.duration_seconds:.1f}s",
            "",
            f"  Levels:          {self.levels['generated']}/{self.levels['total']} generated",
        ]
        if self.levels["generated"] > 0:
            lines.append(f"    (campaign + spec-based)")
        lines.extend([
            f"  Scenes:          {self.scenes['generated']}/{self.scenes['total']} generated",
            f"  Shaders:         {self.shaders['generated']}/{self.shaders['total']} generated "
            f"({self.shaders['template_count']} template, {self.shaders['custom_count']} custom)",
            f"  Prefabs:         {self.prefabs['generated']}/{self.prefabs['total']} generated",
            "",
            f"  Total Files:     {total_files}",
            f"  Total Cost:      ${self.total_cost:.4f}",
            "",
            f"  Validation:",
            f"    Pass: {self.validation_summary['pass']}, "
            f"Warn: {self.validation_summary['warn']}, "
            f"Fail: {self.validation_summary['fail']}",
        ])
        if self.manifest_path:
            lines.append(f"  Manifest: {self.manifest_path}")
        if self.errors:
            lines.append("")
            lines.append(f"  Errors ({len(self.errors)}):")
            for e in self.errors[:5]:
                lines.append(f"    - {e}")
        if self.warnings:
            lines.append(f"  Warnings: {len(self.warnings)}")
        lines.append("=" * 50)
        return "\n".join(lines)


class SceneForgeOrchestrator:
    """End-to-end Scene Forge pipeline."""

    def __init__(self, project_name: str, roadbook_dir: str = None, budget: float = 1.0):
        self.project_name = project_name
        self.roadbook_dir = roadbook_dir
        self.budget = budget
        self.cost = 0.0

    def run(self, dry_run: bool = False, only: str = None) -> OrchestratorResult:
        """Run the full pipeline.

        Args:
            dry_run: Only show what would be done, don't generate
            only: Only run specific step (levels, scenes, shaders, prefabs)
        """
        start = time.time()
        result = OrchestratorResult(project_name=self.project_name)

        if dry_run:
            result.mode = "dry_run"
        elif only:
            result.mode = f"only:{only}"

        # Step 1: Load or extract specs
        manifest = self._load_or_extract_specs(result)
        if manifest is None:
            result.duration_seconds = time.time() - start
            return result

        run_levels = only is None or only == "levels"
        run_scenes = only is None or only == "scenes"
        run_shaders = only is None or only == "shaders"
        run_prefabs = only is None or only == "prefabs"

        if dry_run:
            result.levels["total"] = len(manifest.levels) + 10  # campaign
            result.scenes["total"] = len(manifest.scenes)
            result.shaders["total"] = len(manifest.shaders)
            result.prefabs["total"] = len(manifest.prefabs)
            result.duration_seconds = time.time() - start
            return result

        # Step 2: Generate levels
        if run_levels:
            self._generate_levels(manifest, result)

        # Step 3: Generate scenes
        if run_scenes:
            self._generate_scenes(manifest, result)

        # Step 4: Generate shaders
        if run_shaders:
            self._generate_shaders(manifest, result)

        # Step 5: Generate prefabs
        if run_prefabs:
            self._generate_prefabs(manifest, result)

        # Step 6: Validate
        validator = SceneValidator()
        val_results = validator.validate_all(str(GENERATED_DIR))
        for vr in val_results:
            result.validation_summary[vr.overall_status] = (
                result.validation_summary.get(vr.overall_status, 0) + 1
            )

        # Step 7: Build catalog
        catalog_mgr = SceneCatalogManager()
        catalog = catalog_mgr.build_catalog(
            self.project_name,
            str(GENERATED_DIR),
            validation_results=val_results,
            total_cost=self.cost,
        )
        manifest_path = catalog_mgr.save_catalog(catalog)
        result.manifest_path = manifest_path
        result.total_cost = self.cost
        result.warnings = catalog.warnings

        result.duration_seconds = time.time() - start
        return result

    def _load_or_extract_specs(self, result: OrchestratorResult) -> SceneManifest:
        """Load cached specs or extract from PDFs."""
        extractor = SceneSpecExtractor()
        cached_file = f"{self.project_name.lower()}_scene_specs.json"
        cached_path = SPECS_DIR / cached_file

        if cached_path.exists():
            logger.info("Loading cached specs: %s", cached_path)
            try:
                return extractor.load_manifest(cached_file)
            except Exception as e:
                logger.warning("Failed to load cached specs: %s", e)

        if not self.roadbook_dir:
            result.errors.append("No roadbook_dir and no cached specs found")
            return None

        if self.cost + 0.02 > self.budget:
            result.errors.append(f"Budget exceeded: ${self.cost:.4f} + ~$0.02 > ${self.budget:.2f}")
            return None

        logger.info("Extracting specs from PDFs...")
        manifest = extractor.extract(self.roadbook_dir, self.project_name)
        extractor.save_manifest(manifest, cached_file)
        self.cost += 0.02  # Approximate LLM cost
        return manifest

    def _generate_levels(self, manifest: SceneManifest, result: OrchestratorResult):
        """Generate levels: campaign + spec-based."""
        gen = LevelGenerator(seed=42)

        # Campaign levels
        campaign_count = 10
        total = campaign_count + len(manifest.levels)
        result.levels["total"] = total

        try:
            campaign = gen.generate_campaign(campaign_count)
            result.levels["generated"] += len(campaign)
            logger.info("Campaign: %d levels generated", len(campaign))
        except Exception as e:
            result.errors.append(f"Campaign generation failed: {e}")
            result.levels["failed"] += campaign_count

        # Spec-based levels
        for spec in manifest.levels:
            try:
                gen.generate_from_spec(spec)
                result.levels["generated"] += 1
            except Exception as e:
                result.levels["failed"] += 1
                result.errors.append(f"Level {spec.spec_id} failed: {e}")

    def _generate_scenes(self, manifest: SceneManifest, result: OrchestratorResult):
        """Generate Unity scene files."""
        writer = UnitySceneWriter()
        result.scenes["total"] = len(manifest.scenes)

        for spec in manifest.scenes:
            try:
                r = writer.generate(spec)
                if r.get("success"):
                    result.scenes["generated"] += 1
                else:
                    result.scenes["failed"] += 1
                    result.errors.append(f"Scene {spec.spec_id}: {r.get('error', 'unknown')}")
            except Exception as e:
                result.scenes["failed"] += 1
                result.errors.append(f"Scene {spec.spec_id} failed: {e}")

    def _generate_shaders(self, manifest: SceneManifest, result: OrchestratorResult):
        """Generate shader files."""
        shgen = ShaderGenerator()
        result.shaders["total"] = len(manifest.shaders)

        for spec in manifest.shaders:
            if self.cost > self.budget:
                result.errors.append(f"Budget limit reached at shader {spec.spec_id}")
                result.shaders["failed"] += 1
                continue

            try:
                r = shgen.generate(spec)
                if r.get("success"):
                    result.shaders["generated"] += 1
                    if r.get("mode") == "template":
                        result.shaders["template_count"] += 1
                    else:
                        result.shaders["custom_count"] += 1
                    self.cost += r.get("cost", 0)
                else:
                    result.shaders["failed"] += 1
                    result.errors.append(f"Shader {spec.spec_id}: {r.get('error', 'unknown')}")
            except Exception as e:
                result.shaders["failed"] += 1
                result.errors.append(f"Shader {spec.spec_id} failed: {e}")

    def _generate_prefabs(self, manifest: SceneManifest, result: OrchestratorResult):
        """Generate prefab files."""
        pfgen = PrefabGenerator()
        result.prefabs["total"] = len(manifest.prefabs)

        for spec in manifest.prefabs:
            try:
                r = pfgen.generate(spec)
                if r.get("success"):
                    result.prefabs["generated"] += 1
                else:
                    result.prefabs["failed"] += 1
                    result.errors.append(f"Prefab {spec.spec_id}: {r.get('error', 'unknown')}")
            except Exception as e:
                result.prefabs["failed"] += 1
                result.errors.append(f"Prefab {spec.spec_id} failed: {e}")

    def estimate_cost(self) -> dict:
        """Estimate cost without running."""
        extractor = SceneSpecExtractor()
        cached_file = f"{self.project_name.lower()}_scene_specs.json"
        cached_path = SPECS_DIR / cached_file

        extraction_cost = 0.0
        if not cached_path.exists():
            extraction_cost = 0.02

        return {
            "extraction": extraction_cost,
            "levels": 0.0,
            "scenes": 0.0,
            "shaders_template": 0.0,
            "shaders_custom": 0.0,  # Would be ~0.02 per custom shader
            "prefabs": 0.0,
            "total_estimated": extraction_cost,
            "note": "Levels, scenes, prefabs are code-generated ($0). Only spec extraction and custom shaders cost LLM calls.",
        }


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import argparse
    import sys

    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    parser = argparse.ArgumentParser(description="Scene Forge Orchestrator")
    parser.add_argument("--project", required=True, help="Project name")
    parser.add_argument("--roadbook-dir", help="Path to roadbook PDFs")
    parser.add_argument("--dry-run", action="store_true", help="Show plan without executing")
    parser.add_argument("--estimate-cost", action="store_true", help="Estimate cost only")
    parser.add_argument("--only", choices=["levels", "scenes", "shaders", "prefabs"], help="Run only one step")
    parser.add_argument("--budget", type=float, default=0.50, help="Max budget in USD")
    args = parser.parse_args()

    orch = SceneForgeOrchestrator(
        project_name=args.project,
        roadbook_dir=args.roadbook_dir,
        budget=args.budget,
    )

    if args.estimate_cost:
        est = orch.estimate_cost()
        print("Cost Estimate:")
        for k, v in est.items():
            if k != "note":
                print(f"  {k}: ${v:.4f}" if isinstance(v, float) else f"  {k}: {v}")
            else:
                print(f"  {v}")
        sys.exit(0)

    result = orch.run(dry_run=args.dry_run, only=args.only)
    print(result.summary())

"""Motion Forge Orchestrator - runs the complete animation pipeline end-to-end.

Pipeline:
1. Extract specs (or load cached)
2. Generate Lotties (template/composition/custom LLM)
3. Adapt to platforms (CSS, Unity, Lottie copy)
4. Validate
5. Build catalog
6. Print summary
"""

import json
import logging
import time
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class OrchestratorResult:
    project_name: str = ""
    mode: str = "full"
    total_specs: int = 0
    total_generated: int = 0
    total_failed: int = 0
    generation_methods: dict = field(default_factory=lambda: {
        "template": 0, "composition": 0, "custom_llm": 0, "external": 0,
    })
    total_cost: float = 0.0
    platforms: dict = field(default_factory=dict)
    validation_summary: dict = field(default_factory=lambda: {
        "pass": 0, "warn": 0, "fail": 0,
    })
    css_fallback_count: int = 0
    duration_seconds: float = 0.0
    manifest_path: str = ""
    errors: list = field(default_factory=list)
    warnings: list = field(default_factory=list)


class MotionForgeOrchestrator:
    """Orchestrates the complete Motion Forge pipeline."""

    def __init__(self, project_name: str, roadbook_dir: str = None,
                 output_base: str = None, budget: float = 1.0):
        self.project_name = project_name
        self.roadbook_dir = roadbook_dir
        self.budget = budget

        base = Path(output_base) if output_base else Path(__file__).parent
        self.specs_dir = base / "specs"
        self.generated_dir = base / "generated"
        self.platform_dir = base / "platform_output"
        self.catalog_dir = base / "catalog"

    def run(self, anim_id: str = None, category: str = None,
            priority: str = None, platforms: list = None) -> OrchestratorResult:
        """Full pipeline run."""
        start = time.time()
        result = OrchestratorResult(project_name=self.project_name, mode="full")
        platforms = platforms or ["ios", "android", "web", "unity"]

        print(f"\n{'='*60}")
        print(f"  MOTION FORGE - STARTING PIPELINE")
        print(f"  Project: {self.project_name}")
        print(f"  Budget:  ${self.budget:.2f}")
        print(f"{'='*60}\n")

        # Step 1: Extract/load specs
        print("[1/5] Extracting animation specs...")
        specs = self._extract_specs()
        if not specs:
            result.errors.append("No specs extracted")
            result.duration_seconds = time.time() - start
            return result

        # Filter
        specs = self._filter_specs(specs, anim_id, category, priority)
        result.total_specs = len(specs)
        print(f"  -> {len(specs)} specs to process")

        # Step 2: Generate Lotties
        print("\n[2/5] Generating Lottie animations...")
        gen_results = self._generate_lotties(specs)
        succeeded = [g for g in gen_results if g.success]
        failed = [g for g in gen_results if not g.success]
        result.total_generated = len(succeeded)
        result.total_failed = len(failed)

        for g in gen_results:
            method = g.generation_method or "template"
            result.generation_methods[method] = result.generation_methods.get(method, 0) + 1
            result.total_cost += g.cost

        print(f"  -> Generated: {len(succeeded)}/{len(gen_results)}")
        if failed:
            for f in failed:
                print(f"  -> FAILED: {f.anim_id}: {f.error}")

        # Budget check
        if result.total_cost > self.budget:
            print(f"\n  WARNING: Budget exceeded: ${result.total_cost:.3f} > ${self.budget:.2f}")
            result.warnings.append(f"Budget exceeded: ${result.total_cost:.3f}")

        # Step 3: Platform adaptation
        print("\n[3/5] Adapting to platforms...")
        adapt_results = self._adapt_platforms(succeeded, specs, platforms)
        result.css_fallback_count = adapt_results.css_fallback_count
        result.platforms = adapt_results.by_platform

        for plat, counts in adapt_results.by_platform.items():
            status = "OK" if counts["ok"] == counts["total"] else f"{counts['ok']}/{counts['total']}"
            print(f"  -> {plat}: {status}")

        # Step 4: Validate
        print("\n[4/5] Validating...")
        val_results = self._validate(specs)
        for v in val_results:
            result.validation_summary[v.overall_status] = \
                result.validation_summary.get(v.overall_status, 0) + 1

        print(f"  -> Pass={result.validation_summary['pass']}, "
              f"Warn={result.validation_summary['warn']}, "
              f"Fail={result.validation_summary['fail']}")

        # Step 5: Build catalog
        print("\n[5/5] Building catalog...")
        manifest_path = self._build_catalog(specs, gen_results, val_results)
        result.manifest_path = manifest_path
        print(f"  -> Manifest: {manifest_path}")

        result.duration_seconds = time.time() - start
        self._print_summary(result)
        return result

    def dry_run(self, anim_id: str = None, category: str = None) -> OrchestratorResult:
        """Specs only - no generation."""
        start = time.time()
        result = OrchestratorResult(project_name=self.project_name, mode="dry_run")

        print(f"\n{'='*60}")
        print(f"  MOTION FORGE - DRY RUN")
        print(f"  Project: {self.project_name}")
        print(f"{'='*60}\n")

        specs = self._extract_specs()
        specs = self._filter_specs(specs, anim_id, category, None)
        result.total_specs = len(specs)

        for s in specs:
            method = s.generation_method
            result.generation_methods[method] = result.generation_methods.get(method, 0) + 1
            if method == "custom_llm":
                result.total_cost += 0.01

        print(f"  Specs: {len(specs)}")
        print(f"  Methods: {result.generation_methods}")
        print(f"  Estimated cost: ${result.total_cost:.3f}")

        for s in specs:
            print(f"    {s.anim_id}: {s.name} [{s.category}] -> {s.generation_method}")

        result.duration_seconds = time.time() - start
        return result

    def estimate_cost(self) -> float:
        """Quick cost estimate."""
        specs = self._extract_specs()
        cost = sum(0.01 for s in specs if s.generation_method == "custom_llm")
        print(f"Estimated cost: ${cost:.3f} ({len(specs)} specs, "
              f"{sum(1 for s in specs if s.generation_method == 'custom_llm')} LLM calls)")
        return cost

    # ── Pipeline Steps ──

    def _extract_specs(self) -> list:
        """Extract or load cached specs."""
        from factory.motion_forge.anim_spec_extractor import AnimSpecExtractor, AnimManifest

        # Check cache (24h)
        cache_path = self.specs_dir / f"{self.project_name}_anim_specs.json"
        if cache_path.exists():
            import os
            age_h = (time.time() - os.path.getmtime(cache_path)) / 3600
            if age_h < 24:
                manifest = AnimManifest.from_json(cache_path.read_text(encoding="utf-8"))
                print(f"  -> Loaded cached specs ({manifest.total_animations} anims, {age_h:.1f}h old)")
                return manifest.specs

        if not self.roadbook_dir:
            print("  -> No roadbook dir and no cached specs")
            return []

        extractor = AnimSpecExtractor()
        manifest = extractor.extract(self.roadbook_dir, self.project_name)
        extractor.save_manifest(manifest, str(self.specs_dir))
        return manifest.specs

    def _filter_specs(self, specs: list, anim_id: str = None,
                      category: str = None, priority: str = None) -> list:
        """Filter specs by criteria."""
        filtered = specs
        if anim_id:
            filtered = [s for s in filtered if s.anim_id == anim_id]
        if category:
            filtered = [s for s in filtered if s.category == category]
        if priority:
            filtered = [s for s in filtered if s.priority == priority]
        return filtered

    def _generate_lotties(self, specs: list) -> list:
        """Generate Lottie JSONs for all specs."""
        from factory.motion_forge.lottie_writer import LottieWriter

        writer = LottieWriter(output_dir=str(self.generated_dir))

        results = []
        for i, spec in enumerate(specs):
            # Budget check before LLM calls
            if spec.generation_method == "custom_llm":
                spent = sum(r.cost for r in results)
                if spent + 0.01 > self.budget:
                    from factory.motion_forge.lottie_writer import LottieResult
                    results.append(LottieResult(
                        anim_id=spec.anim_id, success=False,
                        error="Budget limit reached - skipping LLM generation",
                    ))
                    continue

            r = writer.generate(spec)
            results.append(r)
            status = "OK" if r.success else "FAIL"
            cost_str = f" ${r.cost:.3f}" if r.cost > 0 else ""
            print(f"  [{i+1}/{len(specs)}] {status} {r.anim_id}: {r.generation_method}{cost_str}")

        return results

    def _adapt_platforms(self, gen_results: list, specs: list,
                         platforms: list) -> "BatchAdaptResult":
        """Adapt generated Lotties to target platforms."""
        from factory.motion_forge.platform_adapter import PlatformAdapter

        adapter = PlatformAdapter(output_base=str(self.platform_dir))

        specs_map = {s.anim_id: s for s in specs}
        items = []
        for g in gen_results:
            if not g.success or not g.file_path:
                continue
            spec = specs_map.get(g.anim_id)
            items.append({
                "lottie_path": g.file_path,
                "anim_id": g.anim_id,
                "anim_type": getattr(spec, "type", "fade") if spec else "fade",
                "tech_specs": getattr(spec, "technical_specs", {}) if spec else {},
                "visual_specs": getattr(spec, "visual_specs", {}) if spec else {},
                "platform_targets": platforms,
            })

        return adapter.adapt_batch(items, platforms=platforms)

    def _validate(self, specs: list) -> list:
        """Validate all generated animations."""
        from factory.motion_forge.animation_validator import AnimationValidator

        validator = AnimationValidator()
        return validator.validate_batch(
            lottie_dir=str(self.generated_dir),
            specs=specs,
            adapted_dir=str(self.platform_dir),
        )

    def _build_catalog(self, specs: list, gen_results: list,
                       val_results: list) -> str:
        """Build and save the animation catalog."""
        from factory.motion_forge.animation_catalog_manager import AnimationCatalogManager

        manager = AnimationCatalogManager(catalog_base=str(self.catalog_dir))
        catalog = manager.build_catalog(
            project_name=self.project_name,
            generated_dir=str(self.generated_dir),
            adapted_dir=str(self.platform_dir),
            specs=specs,
            generation_results=gen_results,
            validation_results=val_results,
        )
        return manager.save_catalog(catalog)

    # ── Summary ──

    def _print_summary(self, result: OrchestratorResult):
        """Print formatted summary."""
        print(f"\n{'='*50}")
        print(f"  MOTION FORGE - RUN COMPLETE")
        print(f"{'='*50}")
        print(f"  Project:        {result.project_name}")
        print(f"  Total Specs:    {result.total_specs}")
        pct = round(result.total_generated / result.total_specs * 100) if result.total_specs else 0
        print(f"  Generated:      {result.total_generated}/{result.total_specs} ({pct}%)")
        if result.total_failed:
            print(f"  Failed:         {result.total_failed}")
        print()

        print(f"  Generation Methods:")
        method_costs = {"template": 0.0, "composition": 0.0, "custom_llm": 0.01, "external": 0.0}
        for method, count in result.generation_methods.items():
            if count > 0:
                est = count * method_costs.get(method, 0)
                print(f"    {method.capitalize():15s} {count:3d}  (${est:.2f})")
        print(f"    {'-'*30}")
        print(f"    {'TOTAL COST':15s}      ${result.total_cost:.3f}")
        print()

        print(f"  Platforms:")
        plat_labels = {
            "ios": "iOS (Lottie)", "android": "Android (Lottie)",
            "web": "Web (CSS)", "unity": "Unity (C#)",
        }
        for plat, counts in sorted(result.platforms.items()):
            ok = counts.get("ok", 0)
            total = counts.get("total", 0)
            label = plat_labels.get(plat, plat)
            fb = f" ({result.css_fallback_count} lottie-web fallback)" if plat == "web" and result.css_fallback_count else ""
            status = "OK" if ok == total else f"{ok}/{total}"
            print(f"    {label:20s} {ok}/{total} {status}{fb}")
        print()

        print(f"  Validation:")
        print(f"    Pass: {result.validation_summary.get('pass', 0)}, "
              f"Warn: {result.validation_summary.get('warn', 0)}, "
              f"Fail: {result.validation_summary.get('fail', 0)}")
        print()
        print(f"  Manifest: {result.manifest_path}")
        print(f"  Duration: {result.duration_seconds:.1f}s")
        print(f"{'='*50}")


# ── CLI ──

if __name__ == "__main__":
    import argparse

    parser = argparse.ArgumentParser(description="DriveAI Motion Forge - Orchestrator")
    parser.add_argument("--project", required=True, help="Project name")
    parser.add_argument("--roadbook-dir", help="Path to roadbook PDFs")
    parser.add_argument("--output", help="Output base directory")
    parser.add_argument("--dry-run", action="store_true", help="Specs only, no generation")
    parser.add_argument("--estimate-cost", action="store_true", help="Quick cost estimate")
    parser.add_argument("--anim-id", help="Process single animation")
    parser.add_argument("--category", help="Filter by category")
    parser.add_argument("--priority", help="Filter by priority")
    parser.add_argument("--budget", type=float, default=0.50, help="Max budget in USD")
    parser.add_argument("--platforms", nargs="+", default=["ios", "android", "web", "unity"])
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")

    orchestrator = MotionForgeOrchestrator(
        project_name=args.project,
        roadbook_dir=args.roadbook_dir,
        output_base=args.output,
        budget=args.budget,
    )

    if args.estimate_cost:
        orchestrator.estimate_cost()
    elif args.dry_run:
        orchestrator.dry_run(anim_id=args.anim_id, category=args.category)
    else:
        orchestrator.run(
            anim_id=args.anim_id,
            category=args.category,
            priority=args.priority,
            platforms=args.platforms,
        )

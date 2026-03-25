"""Asset Forge Pipeline Runner — orchestrates the full asset generation pipeline.

Roadbook PDFs → Specs → Prompts → Generate → Style Check → Convert → Variants → Catalog.
"""

import asyncio
import logging
import sys
import argparse
from dataclasses import dataclass, field
from pathlib import Path
from datetime import datetime

logger = logging.getLogger(__name__)


@dataclass
class PipelineResult:
    project_name: str
    mode: str = "full"
    total_specs: int = 0
    ai_generatable: int = 0
    attempted: int = 0
    succeeded: int = 0
    failed: int = 0
    style_pass: int = 0
    style_warn: int = 0
    style_fail: int = 0
    retries_used: int = 0
    total_cost: float = 0.0
    total_files_written: int = 0
    errors: list[str] = field(default_factory=list)

    def summary(self) -> str:
        lines = [
            "=" * 60,
            "ASSET FORGE — Pipeline Summary",
            "=" * 60,
            f"Project: {self.project_name}",
            f"Mode: {self.mode}",
            "",
            f"Assets in Manifest: {self.total_specs}",
            f"AI-Generatable: {self.ai_generatable}",
            f"Attempted: {self.attempted}",
            f"Succeeded: {self.succeeded}",
            f"Failed: {self.failed}",
            "",
            f"Style Checks: {self.style_pass} PASS, {self.style_warn} WARN, {self.style_fail} FAIL",
            f"Retries Used: {self.retries_used}",
            "",
            f"Total Cost: ${self.total_cost:.2f}",
            f"Files Written: {self.total_files_written}",
            "=" * 60,
        ]
        if self.errors:
            lines.append("Errors:")
            for e in self.errors[:10]:
                lines.append(f"  - {e}")
            lines.append("=" * 60)
        return "\n".join(lines)


class AssetForgePipeline:

    def __init__(self, config=None):
        from factory.asset_forge.config import AssetForgeConfig
        self._config = config or AssetForgeConfig()
        self._pdf_reader = None
        self._extractor = None
        self._prompt_builder = None
        self._style_checker = None
        self._format_converter = None
        self._variant_generator = None
        self._catalog_manager = None

    def _init_components(self, project_dir: str = None, output_dir: str = None):
        from factory.asset_forge.pdf_reader import PDFReader
        from factory.asset_forge.spec_extractor import AssetSpecExtractor
        from factory.asset_forge.prompt_builder import AssetPromptBuilder
        from factory.asset_forge.style_checker import StyleChecker
        from factory.asset_forge.format_converter import FormatConverter
        from factory.asset_forge.variant_generator import VariantGenerator
        from factory.asset_forge.catalog_manager import CatalogManager

        self._pdf_reader = PDFReader()
        self._extractor = AssetSpecExtractor(self._config)
        self._prompt_builder = AssetPromptBuilder()
        self._style_checker = StyleChecker()
        self._format_converter = FormatConverter()
        self._variant_generator = VariantGenerator(self._format_converter)
        out = output_dir or self._config.output_dir
        self._catalog_manager = CatalogManager(project_dir=project_dir, output_dir=out)

    # ------------------------------------------------------------------
    # Pipeline modes
    # ------------------------------------------------------------------

    def run(self, roadbook_dir: str, project_name: str,
            project_dir: str = None, priority_filter: str = None,
            asset_id_filter: str = None, budget_limit: float = None,
            platforms: list[str] = None) -> PipelineResult:

        out_dir = project_dir or f"{self._config.output_dir}/{project_name}"
        self._init_components(project_dir=project_dir, output_dir=out_dir)
        budget = budget_limit or self._config.max_cost_per_run

        print(f"\n{'='*60}")
        print(f"  ASSET FORGE — {project_name}")
        print(f"{'='*60}")

        # Step 1-2: Manifest
        manifest = self._get_or_create_manifest(roadbook_dir, project_name)
        style_ctx = manifest.style_context

        # Step 3: Filter
        specs = self._filter_specs(manifest, priority_filter, asset_id_filter)
        result = PipelineResult(
            project_name=project_name, mode="full",
            total_specs=manifest.total_assets,
            ai_generatable=len(manifest.get_ai_generatable()),
        )

        print(f"  Specs: {manifest.total_assets} total, {len(specs)} to generate")
        print(f"  Budget: ${budget:.2f}")
        print(f"{'='*60}\n")

        running_cost = 0.0

        for i, spec in enumerate(specs):
            tag = f"[{i+1}/{len(specs)}] {spec.asset_id} {spec.name}"

            # Budget check
            est = self._prompt_builder.build_prompt(spec).estimated_cost
            if running_cost + est > budget:
                print(f"  {tag}: SKIP (budget limit ${budget:.2f} reached)")
                result.errors.append(f"{spec.asset_id}: budget limit reached")
                continue

            result.attempted += 1
            prompt = self._prompt_builder.build_prompt(spec, budget_limit=self._config.max_cost_per_asset)

            # Generate
            gen_result = self._run_async(
                self._generate_with_retry(prompt, style_ctx, self._config.max_retries_on_style_fail)
            )
            image_bytes, service_id, cost, style_res, retries = gen_result

            running_cost += cost
            result.total_cost += cost
            result.retries_used += retries

            if image_bytes is None:
                result.failed += 1
                err = style_res.error if hasattr(style_res, 'error') else "generation failed"
                result.errors.append(f"{spec.asset_id}: {err}")
                print(f"  {tag}: FAILED — {err}")
                continue

            # Style result
            verdict = style_res.overall_verdict if style_res else "SKIPPED"
            if verdict == "PASS":
                result.style_pass += 1
            elif verdict == "WARN":
                result.style_warn += 1
            else:
                result.style_fail += 1

            # Convert + Variants
            vs = self._variant_generator.generate_variants(
                image_bytes, spec, platforms=platforms,
                include_dark_mode=self._config.generate_dark_mode_variants and spec.dark_mode_variant,
            )
            written = self._catalog_manager.write_variant_set(
                vs, spec, generation_service=service_id or "unknown",
                cost=cost, style_check=verdict,
            )
            if self._config.keep_raw_output:
                self._catalog_manager.write_raw_output(spec.asset_id, image_bytes)

            result.succeeded += 1
            result.total_files_written += written
            print(f"  {tag}: OK ({verdict}, ${cost:.3f}, {written} files)")

        # Save catalog
        catalog = self._catalog_manager.build_catalog(project_name)
        self._catalog_manager.save_catalog(catalog)
        self._extractor.save_manifest(manifest, f"{out_dir}/{project_name}_manifest.json")

        return result

    def dry_run(self, roadbook_dir: str, project_name: str,
                priority_filter: str = None) -> PipelineResult:
        self._init_components()
        manifest = self._get_or_create_manifest(roadbook_dir, project_name)
        specs = self._filter_specs(manifest, priority_filter)
        prompts = self._prompt_builder.build_all_prompts(manifest)

        result = PipelineResult(
            project_name=project_name, mode="dry_run",
            total_specs=manifest.total_assets,
            ai_generatable=len(manifest.get_ai_generatable()),
            attempted=0,
            total_cost=sum(p.estimated_cost for p in prompts),
        )

        print(f"\n{'='*60}")
        print(f"  ASSET FORGE — DRY RUN: {project_name}")
        print(f"{'='*60}")
        print(f"  Total Specs: {manifest.total_assets}")
        print(f"  AI-Generatable: {result.ai_generatable}")
        print(f"  Prompts Built: {len(prompts)}")
        print(f"  Estimated Cost: ${result.total_cost:.2f}")
        print(f"{'='*60}")

        for p in prompts[:10]:
            print(f"\n  {p.asset_id} ({p.asset_name}):")
            print(f"    Prompt: {p.prompt_text[:150]}...")
            print(f"    Size: {p.technical_specs.get('width')}x{p.technical_specs.get('height')}")
            print(f"    Est: ${p.estimated_cost:.3f}")

        if len(prompts) > 10:
            print(f"\n  ... and {len(prompts) - 10} more")
        print(f"\n{'='*60}")

        return result

    def estimate_cost(self, roadbook_dir: str, project_name: str) -> float:
        self._init_components()
        manifest = self._get_or_create_manifest(roadbook_dir, project_name)
        return self._prompt_builder.estimate_total_cost(manifest)

    # ------------------------------------------------------------------
    # Generation
    # ------------------------------------------------------------------

    async def _generate_asset(self, prompt, style_context: dict):
        """Generate single asset via TheBrain Router."""
        try:
            from factory.brain.brain import get_service_router
            from factory.brain.service_provider.service_router import ServiceRequest

            router = get_service_router()
            if router is None:
                return None, None, 0.0, None

            sr_dict = prompt.service_request
            request = ServiceRequest(
                category=sr_dict.get("category", "image"),
                required_capabilities=sr_dict.get("required_capabilities", []),
                specs=sr_dict.get("specs", {}),
                budget_limit=sr_dict.get("budget_limit", 0.10),
                preferred_service=sr_dict.get("preferred_service"),
                quality_minimum=sr_dict.get("quality_minimum", 0.0),
            )

            result = await router.route_and_execute(request)
            if not result.success:
                return None, result.service_id, result.cost, None

            # Style check
            w = prompt.technical_specs.get("width")
            h = prompt.technical_specs.get("height")
            needs_t = prompt.technical_specs.get("transparent", False)
            check = self._style_checker.check(
                result.data, None, style_context,
                expected_width=w, expected_height=h,
                needs_transparency=needs_t,
            )
            check.asset_id = prompt.asset_id
            return result.data, result.service_id, result.cost, check

        except Exception as e:
            logger.error("Generation failed for %s: %s", prompt.asset_id, e)
            return None, None, 0.0, None

    async def _generate_with_retry(self, prompt, style_context: dict,
                                    max_retries: int = 2):
        retries = 0
        for attempt in range(1 + max_retries):
            image_bytes, service_id, cost, check = await self._generate_asset(prompt, style_context)

            if image_bytes is None:
                return None, service_id, cost, check, retries

            if check and check.overall_verdict != "FAIL":
                return image_bytes, service_id, cost, check, retries

            if attempt < max_retries:
                retries += 1
                logger.info("Style FAIL for %s, retry %d/%d", prompt.asset_id, retries, max_retries)
                # Could modify prompt here for retry

        return image_bytes, service_id, cost, check, retries

    def _run_async(self, coro):
        try:
            loop = asyncio.get_running_loop()
            import concurrent.futures
            with concurrent.futures.ThreadPoolExecutor() as pool:
                return loop.run_in_executor(pool, asyncio.run, coro)
        except RuntimeError:
            return asyncio.run(coro)

    # ------------------------------------------------------------------
    # Manifest management
    # ------------------------------------------------------------------

    def _get_or_create_manifest(self, roadbook_dir: str, project_name: str):
        out = Path(self._config.output_dir)
        manifest_path = out / f"{project_name}_manifest.json"

        if manifest_path.exists():
            import os, time
            age_h = (time.time() - os.path.getmtime(manifest_path)) / 3600
            if age_h < 24:
                print(f"  Loading cached manifest ({age_h:.1f}h old)")
                return self._extractor.load_manifest(str(manifest_path))

        print(f"  Extracting specs from PDFs in {roadbook_dir}...")
        manifest = self._extractor.extract(roadbook_dir, project_name)
        out.mkdir(parents=True, exist_ok=True)
        self._extractor.save_manifest(manifest, str(manifest_path))
        return manifest

    def _filter_specs(self, manifest, priority: str = None,
                      asset_id: str = None, only_ai: bool = True) -> list:
        specs = manifest.specs

        if only_ai:
            specs = [s for s in specs if s.source_type in ("ai_generated", "ai_plus_custom")]

        if priority:
            specs = [s for s in specs if s.priority == priority]

        if asset_id:
            specs = [s for s in specs if s.asset_id == asset_id]

        order = {"launch_critical": 0, "high": 1, "medium": 2, "low": 3}
        specs.sort(key=lambda s: order.get(s.priority, 9))
        return specs


# ------------------------------------------------------------------
# CLI
# ------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="Asset Forge — Autonomous asset generation")
    parser.add_argument("--project", required=True, help="Project name")
    parser.add_argument("--roadbook-dir", required=True, help="Directory with Roadbook PDFs")
    parser.add_argument("--project-dir", help="Project directory for output")
    parser.add_argument("--output-dir", help="Custom output directory")
    parser.add_argument("--dry-run", action="store_true", help="Show specs/prompts without generating")
    parser.add_argument("--estimate-cost", action="store_true", help="Show estimated costs only")
    parser.add_argument("--asset-id", help="Generate only this asset ID")
    parser.add_argument("--priority", help="Only this priority (launch_critical/high/medium/low)")
    parser.add_argument("--budget", type=float, help="Max total budget USD")
    parser.add_argument("--platforms", help="Comma-separated platforms")
    parser.add_argument("--max-retries", type=int, default=2, help="Max retries on style fail")

    args = parser.parse_args()
    platforms = args.platforms.split(",") if args.platforms else None

    from factory.asset_forge.config import AssetForgeConfig
    config = AssetForgeConfig(
        max_retries_on_style_fail=args.max_retries,
        output_dir=args.output_dir or "factory/asset_forge/output",
    )
    if args.budget:
        config.max_cost_per_run = args.budget

    pipeline = AssetForgePipeline(config)

    if args.estimate_cost:
        cost = pipeline.estimate_cost(args.roadbook_dir, args.project)
        print(f"Estimated total cost: ${cost:.2f}")
        sys.exit(0)

    if args.dry_run:
        result = pipeline.dry_run(args.roadbook_dir, args.project, priority_filter=args.priority)
        print(result.summary())
        sys.exit(0)

    result = pipeline.run(
        roadbook_dir=args.roadbook_dir,
        project_name=args.project,
        project_dir=args.project_dir,
        priority_filter=args.priority,
        asset_id_filter=args.asset_id,
        budget_limit=args.budget,
        platforms=platforms,
    )
    print(result.summary())


if __name__ == "__main__":
    main()

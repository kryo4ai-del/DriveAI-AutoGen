"""Sound Forge Orchestrator — runs the complete sound generation pipeline.

Pipeline: PDF → Specs → Prompts → Generate (SFX + Music) → Convert → Catalog
"""

import argparse
import logging
import sys
import time
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class OrchestratorResult:
    project_name: str
    mode: str
    total_specs: int = 0
    total_attempted: int = 0
    total_succeeded: int = 0
    total_failed: int = 0
    needs_manual: int = 0
    cost_by_category: dict = field(default_factory=dict)
    total_cost: float = 0.0
    total_files: int = 0
    platforms: list = field(default_factory=lambda: ["ios", "android", "web", "unity"])
    duration_seconds: float = 0.0
    errors: list = field(default_factory=list)
    warnings: list = field(default_factory=list)
    manifest_path: str = ""

    def summary(self) -> str:
        pct = f" ({self.total_succeeded/self.total_attempted*100:.0f}%)" if self.total_attempted > 0 else ""
        lines = [
            "=" * 56,
            "  SOUND FORGE — RUN COMPLETE",
            "=" * 56,
            f"  Project:        {self.project_name}",
            f"  Mode:           {self.mode}",
            f"  Duration:       {self.duration_seconds:.1f}s",
            f"  Total Specs:    {self.total_specs}",
            f"  Generated:      {self.total_succeeded}/{self.total_attempted}{pct}",
            f"  Failed:         {self.total_failed}",
            f"  Needs Manual:   {self.needs_manual}",
            "",
            "  Cost Breakdown:",
        ]
        for cat, cost in sorted(self.cost_by_category.items()):
            lines.append(f"    {cat:20s} ${cost:.3f}")
        lines.append(f"    {'─' * 30}")
        lines.append(f"    {'TOTAL':20s} ${self.total_cost:.3f}")
        lines.append("")
        lines.append(f"  Platforms:      {' '.join(p + ' ✅' for p in self.platforms)}")
        lines.append(f"  Total Files:    {self.total_files}")
        if self.manifest_path:
            lines.append(f"  Manifest:       {self.manifest_path}")
        if self.warnings:
            lines.append("")
            for w in self.warnings[:5]:
                lines.append(f"  ⚠️  {w}")
        if self.errors:
            lines.append("")
            for e in self.errors[:5]:
                lines.append(f"  ❌  {e}")
        lines.append("=" * 56)
        return "\n".join(lines)


class SoundForgeOrchestrator:
    """Orchestrates the complete Sound Forge pipeline."""

    def __init__(self, max_cost_per_run: float = 2.0):
        self._max_cost = max_cost_per_run

    def run(self, roadbook_dir: str, project_name: str,
            category_filter: str = None, sound_id_filter: str = None,
            priority_filter: str = None, budget: float = None,
            platforms: list = None) -> OrchestratorResult:
        """Full pipeline run."""
        start = time.time()
        max_budget = budget or self._max_cost
        result = OrchestratorResult(project_name=project_name, mode="full")

        # Step 1: Extract specs
        print(f"\n[1/6] Extracting sound specs from PDFs...")
        try:
            manifest = self._extract_specs(roadbook_dir, project_name)
            result.total_specs = manifest.total_sounds
            print(f"      → {manifest.total_sounds} specs extracted")
        except Exception as e:
            result.errors.append(f"Spec extraction failed: {e}")
            result.duration_seconds = time.time() - start
            return result

        # Step 2: Build prompts
        print(f"\n[2/6] Building prompts...")
        try:
            all_prompts = self._build_prompts(manifest)
            prompts = self._filter_prompts(all_prompts, category_filter, sound_id_filter, priority_filter)
            print(f"      → {len(prompts)} prompts built (filtered from {len(all_prompts)})")
        except Exception as e:
            result.errors.append(f"Prompt building failed: {e}")
            result.duration_seconds = time.time() - start
            return result

        # Step 3: Generate SFX
        cost_remaining = max_budget
        gen_results = []

        print(f"\n[3/6] Generating SFX...")
        try:
            sfx_batch = self._generate_sfx(prompts, cost_remaining)
            if sfx_batch:
                for r in sfx_batch.results:
                    gen_results.append(r)
                    if r.success:
                        result.total_succeeded += 1
                        result.cost_by_category[r.category] = result.cost_by_category.get(r.category, 0) + r.cost
                    else:
                        result.total_failed += 1
                result.total_attempted += sfx_batch.total_attempted
                cost_remaining -= sfx_batch.total_cost
                print(f"      → {sfx_batch.succeeded}/{sfx_batch.total_attempted} SFX, ${sfx_batch.total_cost:.3f}")
            else:
                print(f"      → No SFX prompts")
        except Exception as e:
            result.errors.append(f"SFX generation failed: {e}")
            print(f"      → ERROR: {e}")

        # Step 4: Generate Music/Ambient
        print(f"\n[4/6] Generating Ambient/Music...")
        try:
            music_batch = self._generate_music(prompts, cost_remaining)
            if music_batch:
                for r in music_batch.results:
                    gen_results.append(r)
                    if hasattr(r, 'needs_manual') and r.needs_manual:
                        result.needs_manual += 1
                    elif r.success:
                        result.total_succeeded += 1
                        result.cost_by_category[r.category] = result.cost_by_category.get(r.category, 0) + r.cost
                    else:
                        result.total_failed += 1
                result.total_attempted += music_batch.total_attempted
                cost_remaining -= music_batch.total_cost
                print(f"      → {music_batch.succeeded}/{music_batch.total_attempted} Ambient/Music, ${music_batch.total_cost:.3f}")
            else:
                print(f"      → No ambient/music prompts")
        except Exception as e:
            result.errors.append(f"Music generation failed: {e}")
            print(f"      → ERROR: {e}")

        # Step 5: Convert formats
        print(f"\n[5/6] Converting to platform formats...")
        try:
            conv_result = self._convert_formats(manifest.specs if manifest else None)
            result.total_files = conv_result.total_conversions
            print(f"      → {conv_result.total_conversions} conversions, {conv_result.total_size_bytes/1024:.0f}KB")
        except Exception as e:
            result.errors.append(f"Format conversion failed: {e}")
            print(f"      → ERROR: {e}")

        # Step 6: Build catalog
        print(f"\n[6/6] Building catalog...")
        try:
            catalog = self._build_catalog(project_name, manifest.specs if manifest else None, gen_results)
            result.manifest_path = str(Path("factory/sound_forge/catalog") / project_name / "sound_manifest.json")
            result.total_files = sum(len(s.files) for s in catalog.sounds)
            print(f"      → {catalog.total_sounds} sounds cataloged, manifest saved")
        except Exception as e:
            result.errors.append(f"Catalog build failed: {e}")
            print(f"      → ERROR: {e}")

        result.total_cost = sum(self.cost_by_category.values()) if hasattr(self, 'cost_by_category') else sum(result.cost_by_category.values())
        result.duration_seconds = time.time() - start
        return result

    def dry_run(self, roadbook_dir: str, project_name: str,
                category_filter: str = None) -> OrchestratorResult:
        """Dry run: specs + prompts, no generation."""
        start = time.time()
        result = OrchestratorResult(project_name=project_name, mode="dry_run")

        try:
            manifest = self._extract_specs(roadbook_dir, project_name)
            result.total_specs = manifest.total_sounds
        except Exception as e:
            result.errors.append(f"Spec extraction failed: {e}")
            result.duration_seconds = time.time() - start
            return result

        try:
            from factory.sound_forge.sound_prompt_builder import SoundPromptBuilder
            builder = SoundPromptBuilder()
            prompts = builder.build_all_prompts(manifest)

            if category_filter:
                prompts = [p for p in prompts if p.category == category_filter]

            result.total_attempted = len(prompts)
            result.total_cost = builder.estimate_total_cost(manifest)

            # Count by category
            for p in prompts:
                result.cost_by_category[p.category] = result.cost_by_category.get(p.category, 0) + p.estimated_cost

            print(f"\nDry Run: {len(prompts)} prompts, est. ${result.total_cost:.2f}")
            print(f"\nPrompt previews:")
            for p in prompts[:10]:
                print(f"  {p.sound_id} ({p.category}): {p.prompt_text[:120]}...")
            if len(prompts) > 10:
                print(f"  ... and {len(prompts) - 10} more")

        except Exception as e:
            result.errors.append(f"Prompt build failed: {e}")

        result.duration_seconds = time.time() - start
        return result

    def estimate_cost(self, roadbook_dir: str, project_name: str) -> float:
        """Quick cost estimate."""
        try:
            manifest = self._extract_specs(roadbook_dir, project_name)
            from factory.sound_forge.sound_prompt_builder import SoundPromptBuilder
            return SoundPromptBuilder().estimate_total_cost(manifest)
        except Exception:
            return 0.0

    def _extract_specs(self, roadbook_dir, project_name):
        from factory.sound_forge.sound_spec_extractor import SoundSpecExtractor, SoundManifest
        specs_file = Path("factory/sound_forge/specs") / f"{project_name}_sound_specs.json"
        if specs_file.exists():
            import time as _t
            age_h = (_t.time() - specs_file.stat().st_mtime) / 3600
            if age_h < 24:
                print(f"  Loading cached specs ({age_h:.1f}h old)")
                return SoundManifest.from_json(specs_file.read_text(encoding="utf-8"))
        extractor = SoundSpecExtractor()
        manifest = extractor.extract(roadbook_dir, project_name)
        extractor.save_manifest(manifest)
        return manifest

    def _build_prompts(self, manifest):
        from factory.sound_forge.sound_prompt_builder import SoundPromptBuilder
        return SoundPromptBuilder().build_all_prompts(manifest)

    def _generate_sfx(self, prompts, budget):
        from factory.sound_forge.sfx_generator import SFXGenerator
        sfx = [p for p in prompts if p.category in ("sfx", "ui_sound", "notification")]
        if not sfx:
            return None
        return SFXGenerator(max_cost_per_batch=budget).generate_batch(sfx)

    def _generate_music(self, prompts, budget):
        from factory.sound_forge.music_generator import MusicGenerator
        music = [p for p in prompts if p.category in ("ambient", "music")]
        if not music:
            return None
        return MusicGenerator(max_cost_per_batch=budget).generate_batch(music)

    def _convert_formats(self, specs=None):
        from factory.sound_forge.audio_format_pipeline import AudioFormatPipeline
        return AudioFormatPipeline().process_all(sound_specs=specs)

    def _build_catalog(self, project_name, specs=None, gen_results=None):
        from factory.sound_forge.sound_catalog_manager import SoundCatalogManager
        mgr = SoundCatalogManager()
        return mgr.build_catalog(project_name, sound_specs=specs, generation_results=gen_results)

    def _filter_prompts(self, prompts, category=None, sound_id=None, priority=None):
        filtered = prompts
        if category:
            filtered = [p for p in filtered if p.category == category]
        if sound_id:
            filtered = [p for p in filtered if p.sound_id == sound_id]
        return filtered


def main():
    parser = argparse.ArgumentParser(description="Sound Forge — Autonomous audio generation")
    parser.add_argument("--project", required=True, help="Project name")
    parser.add_argument("--roadbook-dir", required=True, help="Directory with Roadbook PDFs")
    parser.add_argument("--dry-run", action="store_true", help="Specs + prompts only")
    parser.add_argument("--estimate-cost", action="store_true", help="Show cost estimate")
    parser.add_argument("--sound-id", help="Generate one sound (e.g. SFX-001)")
    parser.add_argument("--category", help="Category filter (sfx/ambient/music/ui_sound/notification)")
    parser.add_argument("--priority", help="Priority filter (high/medium/low)")
    parser.add_argument("--budget", type=float, default=2.0, help="Max budget USD")
    parser.add_argument("--platforms", help="Platforms (ios,android,web,unity)")
    args = parser.parse_args()

    platforms = args.platforms.split(",") if args.platforms else None
    orch = SoundForgeOrchestrator(max_cost_per_run=args.budget)

    if args.estimate_cost:
        cost = orch.estimate_cost(args.roadbook_dir, args.project)
        print(f"Estimated cost: ${cost:.2f}")
        sys.exit(0)

    if args.dry_run:
        result = orch.dry_run(args.roadbook_dir, args.project, args.category)
        print(result.summary())
        sys.exit(0)

    result = orch.run(
        roadbook_dir=args.roadbook_dir, project_name=args.project,
        category_filter=args.category, sound_id_filter=args.sound_id,
        priority_filter=args.priority, budget=args.budget, platforms=platforms,
    )
    print(result.summary())


if __name__ == "__main__":
    main()

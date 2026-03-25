"""Animation Catalog Manager — organizes generated animations into a project catalog.

Same pattern as SoundCatalogManager. Copies files, builds manifest, dedup guard.
"""

import hashlib
import json
import logging
import shutil
from dataclasses import dataclass, field, asdict
from datetime import datetime
from pathlib import Path

logger = logging.getLogger(__name__)

CATALOG_BASE = Path(__file__).parent / "catalog"


@dataclass
class AnimationEntry:
    anim_id: str
    name: str = ""
    category: str = ""
    complexity: str = "simple"
    generation_method: str = "template"
    duration_ms: int = 300
    cost_usd: float = 0.0
    validation_status: str = "unknown"  # pass, warn, fail, unknown
    files: dict = field(default_factory=dict)  # {platform: {format: path, size_bytes: N, checksum: str}}
    warnings: list = field(default_factory=list)
    css_fallback: bool = False


@dataclass
class AnimationCatalog:
    project: str
    generated_at: str = ""
    total_animations: int = 0
    total_cost_usd: float = 0.0
    generation_stats: dict = field(default_factory=lambda: {
        "template": 0, "composition": 0, "custom_llm": 0, "external": 0,
    })
    categories: dict = field(default_factory=dict)
    platform_stats: dict = field(default_factory=dict)
    animations: list = field(default_factory=list)
    failed_animations: list = field(default_factory=list)
    css_incompatible: int = 0
    warnings: list = field(default_factory=list)

    def to_json(self) -> str:
        data = asdict(self)
        return json.dumps(data, indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "AnimationCatalog":
        data = json.loads(json_str)
        anims = [AnimationEntry(**a) for a in data.pop("animations", [])]
        return cls(**data, animations=anims)

    def summary(self) -> str:
        lines = [
            f"Animation Catalog: {self.project}",
            f"  Total: {self.total_animations}, Cost: ${self.total_cost_usd:.3f}",
            f"  Generation: {self.generation_stats}",
            f"  Categories: {self.categories}",
            f"  CSS Incompatible: {self.css_incompatible}",
            f"  Failed: {len(self.failed_animations)}",
        ]
        return "\n".join(lines)


class AnimationCatalogManager:
    """Organizes generated and adapted animations into a catalog."""

    def __init__(self, catalog_base: str = None):
        self.catalog_base = Path(catalog_base) if catalog_base else CATALOG_BASE

    def build_catalog(self, project_name: str,
                      generated_dir: str,
                      adapted_dir: str = None,
                      specs: list = None,
                      generation_results: list = None,
                      validation_results: list = None) -> AnimationCatalog:
        """Build the full catalog from generated + adapted files.

        Args:
            project_name: Project identifier
            generated_dir: Dir with Lottie JSONs (from LottieWriter)
            adapted_dir: Dir with platform-adapted files (from PlatformAdapter)
            specs: list of AnimSpec objects
            generation_results: list of LottieResult objects
            validation_results: list of ValidationResult objects
        """
        catalog_dir = self.catalog_base / project_name
        catalog_dir.mkdir(parents=True, exist_ok=True)

        specs_map = {}
        if specs:
            for s in specs:
                specs_map[getattr(s, "anim_id", "")] = s

        gen_map = {}
        if generation_results:
            for g in generation_results:
                aid = g.anim_id if hasattr(g, "anim_id") else g.get("anim_id", "")
                gen_map[aid] = g

        val_map = {}
        if validation_results:
            for v in validation_results:
                val_map[v.anim_id] = v

        # Discover generated Lottie files
        gen_path = Path(generated_dir)
        lottie_files = sorted(gen_path.glob("*.json")) if gen_path.exists() else []

        entries = []
        failed = []
        total_cost = 0.0
        gen_stats = {"template": 0, "composition": 0, "custom_llm": 0, "external": 0}
        categories = {}
        platform_counts = {"ios": 0, "android": 0, "web": 0, "unity": 0}
        css_incompat = 0
        copied_files = set()

        for lottie_file in lottie_files:
            anim_id = lottie_file.stem
            spec = specs_map.get(anim_id)
            gen = gen_map.get(anim_id)
            val = val_map.get(anim_id)

            # Metadata from spec
            name = getattr(spec, "name", anim_id) if spec else anim_id
            category = getattr(spec, "category", "unknown") if spec else "unknown"
            complexity = getattr(spec, "complexity", "simple") if spec else "simple"
            dur = 300
            if spec:
                tech = getattr(spec, "technical_specs", {})
                if isinstance(tech, dict):
                    dur = tech.get("duration_ms", 300)

            # Generation method + cost
            method = "template"
            cost = 0.0
            if gen:
                method = gen.generation_method if hasattr(gen, "generation_method") else gen.get("generation_method", "template")
                cost = gen.cost if hasattr(gen, "cost") else gen.get("cost", 0.0)
                success = gen.success if hasattr(gen, "success") else gen.get("success", True)
                if not success:
                    failed.append(anim_id)
                    continue

            # Validation status
            val_status = "unknown"
            entry_warnings = []
            if val:
                val_status = val.overall_status
                entry_warnings = val.warnings[:]

            # Collect files per platform
            files = {}

            # Lottie (source) → copy to catalog
            lottie_dest = catalog_dir / "lottie" / f"{anim_id}.json"
            self._copy_file(lottie_file, lottie_dest, copied_files)
            files["source"] = {
                "format": "lottie_json",
                "path": str(lottie_dest.relative_to(catalog_dir)),
                "size_bytes": lottie_dest.stat().st_size if lottie_dest.exists() else 0,
                "checksum": self._checksum(lottie_dest),
            }

            # Adapted files
            css_fb = False
            if adapted_dir:
                ad = Path(adapted_dir)
                for plat in ("ios", "android", "web", "unity"):
                    found = self._find_adapted_file(ad, plat, anim_id)
                    if found:
                        ext = found.suffix
                        fmt = "lottie_json" if ext == ".json" else "css" if ext == ".css" else "csharp"

                        dest_subdir = plat
                        if plat == "unity":
                            dest_subdir = "unity"
                        dest = catalog_dir / dest_subdir / found.name
                        self._copy_file(found, dest, copied_files)

                        files[plat] = {
                            "format": fmt,
                            "path": str(dest.relative_to(catalog_dir)),
                            "size_bytes": dest.stat().st_size if dest.exists() else 0,
                            "checksum": self._checksum(dest),
                        }
                        platform_counts[plat] = platform_counts.get(plat, 0) + 1

                        # Check if web uses fallback
                        if plat == "web" and fmt == "lottie_json":
                            css_fb = True

            if css_fb:
                css_incompat += 1

            total_cost += cost
            gen_stats[method] = gen_stats.get(method, 0) + 1
            categories[category] = categories.get(category, 0) + 1

            entries.append(AnimationEntry(
                anim_id=anim_id, name=name, category=category,
                complexity=complexity, generation_method=method,
                duration_ms=dur, cost_usd=cost, validation_status=val_status,
                files=files, warnings=entry_warnings, css_fallback=css_fb,
            ))

        # Generate combined CSS file
        self._build_combined_css(catalog_dir, entries)

        catalog = AnimationCatalog(
            project=project_name,
            generated_at=datetime.now().strftime("%Y-%m-%d %H:%M"),
            total_animations=len(entries),
            total_cost_usd=total_cost,
            generation_stats=gen_stats,
            categories=categories,
            platform_stats=platform_counts,
            animations=entries,
            failed_animations=failed,
            css_incompatible=css_incompat,
        )

        return catalog

    def save_catalog(self, catalog: AnimationCatalog):
        """Save catalog manifest to JSON."""
        cat_dir = self.catalog_base / catalog.project
        cat_dir.mkdir(parents=True, exist_ok=True)
        path = cat_dir / "animation_manifest.json"
        path.write_text(catalog.to_json(), encoding="utf-8")
        logger.info("Saved catalog: %s", path)
        return str(path)

    def load_catalog(self, project_name: str) -> AnimationCatalog:
        """Load existing catalog."""
        path = self.catalog_base / project_name / "animation_manifest.json"
        return AnimationCatalog.from_json(path.read_text(encoding="utf-8"))

    # ── Helpers ──

    def _find_adapted_file(self, adapted_dir: Path, platform: str, anim_id: str) -> Path:
        """Find adapted file for a platform."""
        candidates = [
            adapted_dir / platform / "animations" / f"{anim_id}.json",
            adapted_dir / platform / "animations" / f"{anim_id}.css",
        ]
        # Unity uses PascalCase class names
        if platform == "unity":
            import re
            parts = re.split(r'[-_\s]+', anim_id)
            class_name = "Anim" + "".join(p.capitalize() for p in parts)
            candidates.append(adapted_dir / "unity" / "Scripts" / "Animations" / f"{class_name}.cs")

        for c in candidates:
            if c.exists():
                return c
        return None

    def _copy_file(self, src: Path, dest: Path, copied: set):
        """Copy file with dedup guard."""
        key = str(dest)
        if key in copied:
            return
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(src, dest)
        copied.add(key)

    def _checksum(self, path: Path) -> str:
        if not path.exists():
            return ""
        h = hashlib.md5()
        h.update(path.read_bytes())
        return h.hexdigest()[:12]

    def _build_combined_css(self, catalog_dir: Path, entries: list):
        """Combine all CSS files into one all_animations.css."""
        css_parts = []
        web_dir = catalog_dir / "web"
        if not web_dir.exists():
            return

        for f in sorted(web_dir.glob("*.css")):
            css_parts.append(f.read_text(encoding="utf-8"))

        if css_parts:
            combined = catalog_dir / "web" / "all_animations.css"
            combined.write_text("\n\n".join(css_parts), encoding="utf-8")
            logger.info("Combined CSS: %s (%d animations)", combined, len(css_parts))

"""Scene Catalog Manager -- organizes all generated files into a structured catalog.

Copies validated Scene Forge outputs into catalog/{project}/ with:
- levels/, scenes/, shaders/, prefabs/ subdirectories
- scene_manifest.json with full metadata
- Dedup guard: never overwrite existing files
"""

import json
import logging
import shutil
from dataclasses import dataclass, field, asdict
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class SceneCatalog:
    project: str
    generated_at: str = ""
    total_cost_usd: float = 0.0
    levels: dict = field(default_factory=lambda: {"count": 0, "difficulty_range": "", "files": []})
    scenes: dict = field(default_factory=lambda: {"count": 0, "files": []})
    shaders: dict = field(default_factory=lambda: {"count": 0, "files": []})
    prefabs: dict = field(default_factory=lambda: {"count": 0, "files": []})
    failed: list = field(default_factory=list)
    warnings: list = field(default_factory=list)

    def __post_init__(self):
        if not self.generated_at:
            self.generated_at = datetime.now(timezone.utc).isoformat()

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "SceneCatalog":
        data = json.loads(json_str)
        return cls(**data)

    def summary(self) -> str:
        total = self.levels["count"] + self.scenes["count"] + self.shaders["count"] + self.prefabs["count"]
        lines = [
            f"Scene Catalog: {self.project}",
            f"  Generated: {self.generated_at}",
            f"  Levels:  {self.levels['count']}",
        ]
        if self.levels.get("difficulty_range"):
            lines.append(f"    Difficulty: {self.levels['difficulty_range']}")
        lines.extend([
            f"  Scenes:  {self.scenes['count']}",
            f"  Shaders: {self.shaders['count']}",
            f"  Prefabs: {self.prefabs['count']}",
            f"  Total:   {total} files",
            f"  Cost:    ${self.total_cost_usd:.4f}",
        ])
        if self.failed:
            lines.append(f"  Failed:  {len(self.failed)}")
        if self.warnings:
            lines.append(f"  Warnings: {len(self.warnings)}")
        return "\n".join(lines)


class SceneCatalogManager:
    """Organizes Scene Forge outputs into a structured catalog."""

    CATALOG_DIR = Path(__file__).parent / "catalog"

    def __init__(self, catalog_dir: str = None):
        if catalog_dir:
            self.CATALOG_DIR = Path(catalog_dir)

    def build_catalog(
        self,
        project_name: str,
        generated_dir: str,
        validation_results: list = None,
        total_cost: float = 0.0,
    ) -> SceneCatalog:
        """Build catalog from generated files."""
        gen = Path(generated_dir)
        proj_dir = self.CATALOG_DIR / project_name
        catalog = SceneCatalog(project=project_name, total_cost_usd=total_cost)

        # Create subdirectories
        for subdir in ["levels", "scenes", "shaders", "prefabs"]:
            (proj_dir / subdir).mkdir(parents=True, exist_ok=True)

        # Build fail set from validation
        failed_files = set()
        if validation_results:
            for vr in validation_results:
                if vr.overall_status == "fail":
                    failed_files.add(Path(vr.file_path).name)
                    catalog.failed.append(f"{vr.file_id}: {'; '.join(vr.errors)}")
                elif vr.overall_status == "warn":
                    catalog.warnings.extend(
                        f"{vr.file_id}: {w}" for w in vr.warnings
                    )

        # Copy levels
        levels_dir = gen / "levels"
        if levels_dir.exists():
            diffs = []
            for f in sorted(levels_dir.glob("*.json")):
                if f.name in failed_files:
                    continue
                dest = proj_dir / "levels" / f.name
                if not dest.exists():
                    shutil.copy2(f, dest)
                catalog.levels["files"].append(f.name)
                # Read difficulty
                try:
                    data = json.loads(f.read_text(encoding="utf-8"))
                    diffs.append(data.get("difficulty_score", 0))
                except Exception:
                    pass
            catalog.levels["count"] = len(catalog.levels["files"])
            if diffs:
                catalog.levels["difficulty_range"] = f"{min(diffs):.3f} -> {max(diffs):.3f}"

        # Copy scenes
        scenes_dir = gen / "scenes"
        if scenes_dir.exists():
            for f in sorted(scenes_dir.glob("*.unity")):
                if f.name in failed_files:
                    continue
                dest = proj_dir / "scenes" / f.name
                if not dest.exists():
                    shutil.copy2(f, dest)
                catalog.scenes["files"].append(f.name)
            catalog.scenes["count"] = len(catalog.scenes["files"])

        # Copy shaders
        shaders_dir = gen / "shaders"
        if shaders_dir.exists():
            for f in sorted(shaders_dir.glob("*.shader")):
                if f.name in failed_files:
                    continue
                dest = proj_dir / "shaders" / f.name
                if not dest.exists():
                    shutil.copy2(f, dest)
                catalog.shaders["files"].append(f.name)
            catalog.shaders["count"] = len(catalog.shaders["files"])

        # Copy prefabs + .meta
        prefabs_dir = gen / "prefabs"
        if prefabs_dir.exists():
            for f in sorted(prefabs_dir.glob("*.prefab")):
                if f.name in failed_files:
                    continue
                dest = proj_dir / "prefabs" / f.name
                if not dest.exists():
                    shutil.copy2(f, dest)
                # Copy .meta alongside
                meta = Path(str(f) + ".meta")
                if meta.exists():
                    meta_dest = Path(str(dest) + ".meta")
                    if not meta_dest.exists():
                        shutil.copy2(meta, meta_dest)
                catalog.prefabs["files"].append(f.name)
            catalog.prefabs["count"] = len(catalog.prefabs["files"])

        logger.info("Catalog built: %s", catalog.summary())
        return catalog

    def save_catalog(self, catalog: SceneCatalog, filename: str = "scene_manifest.json") -> str:
        """Save catalog manifest to JSON."""
        proj_dir = self.CATALOG_DIR / catalog.project
        proj_dir.mkdir(parents=True, exist_ok=True)
        path = proj_dir / filename
        path.write_text(catalog.to_json(), encoding="utf-8")
        logger.info("Catalog saved: %s", path)
        return str(path)

    def load_catalog(self, project_name: str, filename: str = "scene_manifest.json") -> SceneCatalog:
        """Load catalog from JSON."""
        path = self.CATALOG_DIR / project_name / filename
        return SceneCatalog.from_json(path.read_text(encoding="utf-8"))

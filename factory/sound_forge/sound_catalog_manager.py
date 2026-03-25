"""Sound Catalog Manager — organizes processed audio into a catalog with manifest.

Creates per-project catalog:
  catalog/{project}/
  ├── sound_manifest.json
  ├── ios/
  ├── android/
  ├── web/
  └── unity/
"""

import json
import logging
import hashlib
import shutil
from dataclasses import dataclass, field, asdict
from pathlib import Path
from datetime import datetime
from typing import Optional

logger = logging.getLogger(__name__)


@dataclass
class SoundCatalogEntry:
    sound_id: str
    name: str
    category: str
    description: str
    files: dict = field(default_factory=dict)
    checksums: dict = field(default_factory=dict)
    duration_ms: int = 0
    file_sizes_kb: dict = field(default_factory=dict)
    generated_by: str = "unknown"
    generation_cost_usd: float = 0.0
    quality_score: float = None
    status: str = "ready"
    loop_seamless: bool = False
    mood: str = ""
    context: str = ""


@dataclass
class SoundCatalog:
    project: str
    generated_at: str
    total_sounds: int
    total_cost_usd: float
    categories: dict = field(default_factory=dict)
    platforms: list = field(default_factory=list)
    sounds: list = field(default_factory=list)
    failed_sounds: list = field(default_factory=list)
    warnings: list = field(default_factory=list)

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "SoundCatalog":
        data = json.loads(json_str)
        sounds = [SoundCatalogEntry(**s) for s in data.pop("sounds", [])]
        return cls(**data, sounds=sounds)

    def summary(self) -> str:
        lines = [
            f"Sound Catalog: {self.project}",
            f"Generated: {self.generated_at}",
            f"Total Sounds: {self.total_sounds}",
            f"Total Cost: ${self.total_cost_usd:.2f}",
            f"Categories: {self.categories}",
            f"Platforms: {', '.join(self.platforms)}",
            f"Failed: {len(self.failed_sounds)}",
            f"Warnings: {len(self.warnings)}",
        ]
        return "\n".join(lines)


class SoundCatalogManager:
    """Organizes processed audio files into a catalog with manifest."""

    PLATFORMS = ["ios", "android", "web", "unity"]

    def __init__(self, catalog_base_dir: str = None):
        if catalog_base_dir is None:
            catalog_base_dir = str(Path(__file__).parent / "catalog")
        self._catalog_base = Path(catalog_base_dir)

    def build_catalog(self, project_name: str,
                       processed_dir: str = None,
                       sound_specs: list = None,
                       generation_results: list = None) -> SoundCatalog:
        """Build a complete catalog from processed files."""
        if processed_dir is None:
            processed_dir = str(Path(__file__).parent / "processed")

        # Create catalog dirs
        cat_dir = self._catalog_base / project_name
        cat_dir.mkdir(parents=True, exist_ok=True)
        for plat in self.PLATFORMS:
            (cat_dir / plat).mkdir(exist_ok=True)

        # Find all processed files
        grouped = self._find_processed_files(processed_dir)
        if not grouped:
            logger.warning("No processed files found in %s", processed_dir)

        # Build entries
        entries = []
        failed = []
        total_cost = 0.0
        categories = {}

        for sound_id, platforms in sorted(grouped.items()):
            meta = self._merge_metadata(sound_id, sound_specs, generation_results)
            cat = meta.get("category", "sfx")
            categories[cat] = categories.get(cat, 0) + 1

            files = {}
            checksums = {}
            sizes = {}

            for plat, info in platforms.items():
                src = info["path"]
                rel = self._copy_to_catalog(src, sound_id, plat, project_name)
                if rel:
                    dest_full = cat_dir / rel
                    files[plat] = rel
                    checksums[plat] = self._calculate_checksum(str(dest_full))
                    sizes[plat] = round(dest_full.stat().st_size / 1024, 1)

            status = self._determine_status(sound_id, len(files))
            cost = meta.get("generation_cost_usd", 0.01)
            total_cost += cost

            if len(files) == 0:
                failed.append({"sound_id": sound_id, "reason": "no processed files"})
                continue

            entry = SoundCatalogEntry(
                sound_id=sound_id,
                name=meta.get("name", sound_id.lower()),
                category=cat,
                description=meta.get("description", ""),
                files=files,
                checksums=checksums,
                duration_ms=meta.get("duration_ms", 0),
                file_sizes_kb=sizes,
                generated_by=meta.get("generated_by", "unknown"),
                generation_cost_usd=cost,
                status=status,
                loop_seamless=meta.get("loop_seamless", False),
                mood=meta.get("mood", ""),
                context=meta.get("context", ""),
            )
            entries.append(entry)

        catalog = SoundCatalog(
            project=project_name,
            generated_at=datetime.now().isoformat(),
            total_sounds=len(entries),
            total_cost_usd=round(total_cost, 3),
            categories=categories,
            platforms=self.PLATFORMS,
            sounds=entries,
            failed_sounds=failed,
        )

        # Save manifest
        self.save_catalog(catalog, project_name)
        return catalog

    def _find_processed_files(self, processed_dir: str) -> dict:
        """Find all processed files grouped by sound_id."""
        pd = Path(processed_dir)
        grouped = {}
        audio_exts = {".m4a", ".ogg", ".mp3", ".wav", ".webm", ".flac"}

        for plat in self.PLATFORMS:
            plat_dir = pd / plat
            if not plat_dir.exists():
                continue
            for f in plat_dir.iterdir():
                if f.suffix.lower() in audio_exts and f.is_file():
                    sound_id = f.stem  # SFX-001
                    if sound_id not in grouped:
                        grouped[sound_id] = {}
                    grouped[sound_id][plat] = {
                        "path": str(f),
                        "format": f.suffix.lstrip("."),
                        "size": f.stat().st_size,
                    }

        return grouped

    def _copy_to_catalog(self, source_path: str, sound_id: str,
                          platform: str, project_name: str) -> str:
        """Copy file to catalog. Returns relative path or None."""
        src = Path(source_path)
        if not src.exists():
            return None

        rel = f"{platform}/{sound_id}{src.suffix}"
        dest = self._catalog_base / project_name / rel

        # Dedup: don't overwrite
        if dest.exists():
            return rel

        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(str(src), str(dest))
        return rel

    def _calculate_checksum(self, file_path: str) -> str:
        md5 = hashlib.md5()
        try:
            with open(file_path, "rb") as f:
                for chunk in iter(lambda: f.read(8192), b""):
                    md5.update(chunk)
            return md5.hexdigest()
        except Exception:
            return ""

    def _merge_metadata(self, sound_id: str, specs: list = None,
                         gen_results: list = None) -> dict:
        """Find matching spec/result for metadata."""
        meta = {
            "name": sound_id.lower().replace("-", "_"),
            "category": self._guess_category(sound_id),
            "description": "",
            "generated_by": "unknown",
            "generation_cost_usd": 0.01,
            "mood": "",
            "context": "",
            "duration_ms": 0,
            "loop_seamless": False,
        }

        if specs:
            for s in specs:
                sid = getattr(s, "sound_id", "") if not isinstance(s, dict) else s.get("sound_id", "")
                if sid == sound_id:
                    meta["name"] = getattr(s, "name", meta["name"]) if not isinstance(s, dict) else s.get("name", meta["name"])
                    meta["category"] = getattr(s, "category", meta["category"]) if not isinstance(s, dict) else s.get("category", meta["category"])
                    meta["description"] = getattr(s, "description", "") if not isinstance(s, dict) else s.get("description", "")
                    meta["mood"] = getattr(s, "mood", "") if not isinstance(s, dict) else s.get("mood", "")
                    meta["context"] = getattr(s, "context", "") if not isinstance(s, dict) else s.get("context", "")
                    tech = getattr(s, "technical_specs", {}) if not isinstance(s, dict) else s.get("technical_specs", {})
                    if isinstance(tech, dict):
                        dur = tech.get("duration_ms")
                        if dur:
                            try:
                                meta["duration_ms"] = int(float(str(dur)))
                            except (ValueError, TypeError):
                                pass
                        meta["loop_seamless"] = bool(tech.get("loop_seamless", False))
                    break

        if gen_results:
            for r in gen_results:
                rid = getattr(r, "sound_id", "") if not isinstance(r, dict) else r.get("sound_id", "")
                if rid == sound_id:
                    meta["generated_by"] = getattr(r, "service_used", "unknown") if not isinstance(r, dict) else r.get("service_used", "unknown")
                    meta["generation_cost_usd"] = getattr(r, "cost", 0.01) if not isinstance(r, dict) else r.get("cost", 0.01)
                    break

        return meta

    def _guess_category(self, sound_id: str) -> str:
        sid = sound_id.upper()
        if sid.startswith("SFX"):
            return "sfx"
        if sid.startswith("AMB"):
            return "ambient"
        if sid.startswith("MUS"):
            return "music"
        if sid.startswith("UI"):
            return "ui_sound"
        if sid.startswith("NOT"):
            return "notification"
        return "sfx"

    def _determine_status(self, sound_id: str, file_count: int,
                           expected_platforms: int = 4) -> str:
        if file_count == 0:
            return "failed"
        if file_count < expected_platforms:
            return "needs_review"
        return "ready"

    def save_catalog(self, catalog: SoundCatalog, project_name: str = None):
        name = project_name or catalog.project
        cat_dir = self._catalog_base / name
        cat_dir.mkdir(parents=True, exist_ok=True)
        manifest_path = cat_dir / "sound_manifest.json"
        manifest_path.write_text(catalog.to_json(), encoding="utf-8")
        print(f"[SoundCatalog] Saved: {manifest_path}")

    def load_catalog(self, project_name: str) -> Optional[SoundCatalog]:
        manifest = self._catalog_base / project_name / "sound_manifest.json"
        if not manifest.exists():
            return None
        return SoundCatalog.from_json(manifest.read_text(encoding="utf-8"))

    def get_sound_path(self, project_name: str, sound_id: str,
                        platform: str) -> Optional[str]:
        catalog = self.load_catalog(project_name)
        if not catalog:
            return None
        for s in catalog.sounds:
            if s.sound_id == sound_id:
                rel = s.files.get(platform)
                if rel:
                    return str(self._catalog_base / project_name / rel)
        return None

    def list_projects(self) -> list:
        if not self._catalog_base.exists():
            return []
        return [d.name for d in self._catalog_base.iterdir()
                if d.is_dir() and (d / "sound_manifest.json").exists()]

"""Asset Catalog Manager — organizes generated assets into project directory structures.

Places assets in platform-correct folders, creates manifest.json.
NEVER overwrites existing files (dedup guard).
"""

import json
import logging
import re
from dataclasses import dataclass, field, asdict
from pathlib import Path
from datetime import datetime

logger = logging.getLogger(__name__)


@dataclass
class CatalogEntry:
    asset_id: str
    asset_name: str
    files: list[dict] = field(default_factory=list)
    generation_service: str = "unknown"
    cost: float = 0.0
    style_check: str = "SKIPPED"
    generated_at: str = ""
    source_type: str = "ai_generated"


@dataclass
class AssetCatalog:
    project_name: str
    created_at: str
    total_assets: int = 0
    total_files: int = 0
    total_cost: float = 0.0
    style_check_summary: dict = field(default_factory=dict)
    entries: list[CatalogEntry] = field(default_factory=list)

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "AssetCatalog":
        data = json.loads(json_str)
        entries = [CatalogEntry(**e) for e in data.pop("entries", [])]
        cat = cls(**data)
        cat.entries = entries
        return cat

    def summary(self) -> str:
        return (
            f"Asset Catalog: {self.project_name}\n"
            f"Created: {self.created_at}\n"
            f"Assets: {self.total_assets}, Files: {self.total_files}\n"
            f"Total Cost: ${self.total_cost:.2f}\n"
            f"Style Checks: {self.style_check_summary}"
        )


PLATFORM_ROOTS = {
    "ios": "Assets.xcassets",
    "android": "app/src/main/res",
    "unity": "Assets",
    "web": "public/images",
}


class CatalogManager:

    def __init__(self, project_dir: str = None, output_dir: str = None):
        self._project_dir = Path(project_dir) if project_dir else None
        self._output_dir = Path(output_dir) if output_dir else Path("factory/asset_forge/output")
        self._catalog_entries: list[CatalogEntry] = []
        self._written_files: list[str] = []
        self._skipped_files: list[str] = []

    # ------------------------------------------------------------------
    # Write
    # ------------------------------------------------------------------

    def write_variant_set(self, variant_set, asset_spec=None,
                          generation_service: str = "unknown",
                          cost: float = 0.0,
                          style_check: str = "SKIPPED") -> int:
        written = 0
        file_records = []

        for vf in variant_set.files:
            target_dir = self._get_target_dir(vf.platform)
            full_path = target_dir / vf.relative_path

            if self._file_exists(full_path):
                self._skipped_files.append(str(full_path))
                continue

            self._ensure_dir(full_path.parent)
            full_path.write_bytes(vf.data)
            self._written_files.append(str(full_path))
            written += 1

            file_records.append({
                "path": str(full_path).replace("\\", "/"),
                "platform": vf.platform,
                "variant_type": vf.variant_type,
                "size_bytes": len(vf.data),
            })

        aid = variant_set.asset_id
        aname = variant_set.asset_name
        src_type = getattr(asset_spec, "source_type", "ai_generated") if asset_spec else "ai_generated"

        self._catalog_entries.append(CatalogEntry(
            asset_id=aid,
            asset_name=aname,
            files=file_records,
            generation_service=generation_service,
            cost=cost,
            style_check=style_check,
            generated_at=datetime.now().isoformat(timespec="seconds"),
            source_type=src_type,
        ))

        return written

    def write_raw_output(self, asset_id: str, image_data: bytes,
                         format: str = "png") -> str:
        raw_dir = self._output_dir / "raw"
        self._ensure_dir(raw_dir)
        fname = f"{self._sanitize_filename(asset_id)}.{format}"
        path = raw_dir / fname
        if not self._file_exists(path):
            path.write_bytes(image_data)
            self._written_files.append(str(path))
        return str(path)

    # ------------------------------------------------------------------
    # Catalog
    # ------------------------------------------------------------------

    def build_catalog(self, project_name: str) -> AssetCatalog:
        total_files = sum(len(e.files) for e in self._catalog_entries)
        total_cost = sum(e.cost for e in self._catalog_entries)
        checks: dict[str, int] = {}
        for e in self._catalog_entries:
            checks[e.style_check] = checks.get(e.style_check, 0) + 1

        return AssetCatalog(
            project_name=project_name,
            created_at=datetime.now().isoformat(timespec="seconds"),
            total_assets=len(self._catalog_entries),
            total_files=total_files,
            total_cost=round(total_cost, 4),
            style_check_summary=checks,
            entries=list(self._catalog_entries),
        )

    def save_catalog(self, catalog: AssetCatalog, path: str = None):
        if path is None:
            base = self._project_dir or self._output_dir
            path = str(base / "asset_manifest.json")
        p = Path(path)
        self._ensure_dir(p.parent)
        p.write_text(catalog.to_json(), encoding="utf-8")
        logger.info("Catalog saved: %s (%d assets, %d files)", path, catalog.total_assets, catalog.total_files)

    def load_catalog(self, path: str) -> AssetCatalog:
        return AssetCatalog.from_json(Path(path).read_text(encoding="utf-8"))

    # ------------------------------------------------------------------
    # Queries
    # ------------------------------------------------------------------

    def get_written_files(self) -> list[str]:
        return list(self._written_files)

    def get_skipped_files(self) -> list[str]:
        return list(self._skipped_files)

    def get_summary(self) -> str:
        platforms: dict[str, int] = {}
        for e in self._catalog_entries:
            for f in e.files:
                p = f.get("platform", "?")
                platforms[p] = platforms.get(p, 0) + 1
        lines = [
            f"Written: {len(self._written_files)} files",
            f"Skipped: {len(self._skipped_files)} files (already existed)",
        ]
        if platforms:
            plat_str = ", ".join(f"{p} ({n})" for p, n in sorted(platforms.items()))
            lines.append(f"Platforms: {plat_str}")
        return "\n".join(lines)

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _get_target_dir(self, platform: str) -> Path:
        base = self._project_dir or self._output_dir
        root = PLATFORM_ROOTS.get(platform, platform)
        return base / root

    def _file_exists(self, path: Path) -> bool:
        if path.exists():
            logger.debug("File exists, skipping: %s", path)
            return True
        return False

    def _ensure_dir(self, path: Path):
        path.mkdir(parents=True, exist_ok=True)

    def _sanitize_filename(self, name: str) -> str:
        s = name.lower()
        s = re.sub(r"[^a-z0-9._]+", "_", s)
        return s.strip("_") or "asset"

"""Asset Integrator -- copies Forge outputs into project directory structure.

Reads all Forge manifests, maps each asset to its platform-specific path,
copies files, and creates an Integration Map that the code generator uses
for asset references.
"""

import json
import shutil
import logging
from dataclasses import dataclass, field, asdict
from pathlib import Path
from datetime import datetime, timezone

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[2]
MAPS_DIR = Path(__file__).parent / "maps"


@dataclass
class IntegrationEntry:
    """Single asset in the integration map."""
    asset_id: str
    asset_type: str
    source: str
    destination: str
    code_reference: str
    status: str = "integrated"  # integrated, missing, not_applicable


@dataclass
class IntegrationMap:
    """Complete mapping of all Forge outputs for a platform."""
    project: str
    platform: str
    generated_at: str = ""
    total_entries: int = 0
    integrated: int = 0
    missing: int = 0
    not_applicable: int = 0
    entries: dict = field(default_factory=dict)

    def __post_init__(self):
        if not self.generated_at:
            self.generated_at = datetime.now(timezone.utc).isoformat()
        # Convert dicts to IntegrationEntry
        converted = {}
        for k, v in self.entries.items():
            if isinstance(v, dict):
                converted[k] = IntegrationEntry(**v)
            else:
                converted[k] = v
        self.entries = converted

    def to_json(self) -> str:
        data = {
            "project": self.project,
            "platform": self.platform,
            "generated_at": self.generated_at,
            "total_entries": self.total_entries,
            "integrated": self.integrated,
            "missing": self.missing,
            "not_applicable": self.not_applicable,
            "entries": {k: asdict(v) for k, v in self.entries.items()},
        }
        return json.dumps(data, indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "IntegrationMap":
        data = json.loads(json_str)
        raw_entries = data.pop("entries", {})
        entries = {}
        for k, v in raw_entries.items():
            entries[k] = IntegrationEntry(**v) if isinstance(v, dict) else v
        return cls(**data, entries=entries)

    def get_code_ref(self, asset_id: str) -> str:
        """Quick lookup: get code reference for an asset ID."""
        entry = self.entries.get(asset_id)
        return entry.code_reference if entry else "MISSING_ASSET_TODO"

    def summary(self) -> str:
        lines = [
            f"Integration Map: {self.project} ({self.platform})",
            f"  Total: {self.total_entries}",
            f"  Integrated: {self.integrated}",
            f"  Missing: {self.missing}",
            f"  N/A: {self.not_applicable}",
        ]
        # Group by type
        type_counts = {}
        for entry in self.entries.values():
            t = entry.asset_type
            type_counts[t] = type_counts.get(t, 0) + 1
        if type_counts:
            lines.append("  By type:")
            for t, c in sorted(type_counts.items()):
                lines.append(f"    {t}: {c}")
        return "\n".join(lines)


class AssetIntegrator:
    """Integrates Forge outputs into project directory structure."""

    MANIFEST_NAMES = {
        "asset_forge": ["asset_manifest.json", "manifest.json"],
        "sound_forge": ["sound_manifest.json"],
        "motion_forge": ["animation_manifest.json"],
        "scene_forge": ["scene_manifest.json"],
    }

    def __init__(self, project_dir: str = None, output_dir: str = None):
        self._project_dir = Path(project_dir) if project_dir else None
        self._output_dir = Path(output_dir) if output_dir else MAPS_DIR
        self._output_dir.mkdir(parents=True, exist_ok=True)

    def integrate(self, project_name: str, platform: str,
                  forge_manifests: dict = None,
                  copy_files: bool = True) -> IntegrationMap:
        """Full integration: read manifests -> map -> copy -> create IntegrationMap.

        Args:
            project_name: e.g. "echomatch"
            platform: Target platform (ios, android, web, unity)
            forge_manifests: Optional {forge_name: manifest_path}
            copy_files: Whether to actually copy files (False for dry-run)
        """
        from factory.integration.platform_asset_mapper import PlatformAssetMapper

        mapper = PlatformAssetMapper(platform)
        manifests = forge_manifests or self._find_manifests(project_name)

        imap = IntegrationMap(project=project_name, platform=platform)
        integrated = 0
        missing = 0
        not_applicable = 0

        # Process each forge manifest
        for forge_name, manifest_path in manifests.items():
            manifest = self._load_manifest(manifest_path)
            if manifest is None:
                logger.warning("Could not load manifest: %s", manifest_path)
                continue

            catalog_dir = Path(manifest_path).parent

            # Extract entries based on forge type
            if forge_name == "asset_forge":
                entries = self._extract_entries_from_asset_manifest(manifest)
            elif forge_name == "sound_forge":
                entries = self._extract_entries_from_sound_manifest(
                    manifest, platform, catalog_dir)
            elif forge_name == "motion_forge":
                entries = self._extract_entries_from_animation_manifest(
                    manifest, platform, catalog_dir)
            elif forge_name == "scene_forge":
                entries = self._extract_entries_from_scene_manifest(
                    manifest, catalog_dir)
            else:
                continue

            # Map each entry
            for entry in entries:
                asset_id = entry.get("id", "")
                asset_type = entry.get("type", "")
                name = entry.get("name", asset_id)
                source = entry.get("source_path", "")
                category = entry.get("category", "")
                class_name = entry.get("class_name", "")

                if not mapper.is_supported(asset_type):
                    imap.entries[asset_id] = IntegrationEntry(
                        asset_id=asset_id,
                        asset_type=asset_type,
                        source=source,
                        destination="",
                        code_reference="MISSING_ASSET_TODO",
                        status="not_applicable",
                    )
                    not_applicable += 1
                    continue

                dest = mapper.get_destination(
                    asset_type, name, asset_id, category, class_name)
                code_ref = mapper.get_code_reference(
                    asset_type, name, asset_id, category, class_name)

                # Check if source file exists
                source_path = Path(source) if source else None
                if source_path and not source_path.is_absolute():
                    source_path = catalog_dir / source_path

                file_exists = source_path and source_path.exists() if source_path else False

                if file_exists and copy_files and self._project_dir:
                    copied = self._copy_file(str(source_path), dest)
                    status = "integrated" if copied else "missing"
                elif file_exists:
                    status = "integrated"
                else:
                    status = "missing"

                imap.entries[asset_id] = IntegrationEntry(
                    asset_id=asset_id,
                    asset_type=asset_type,
                    source=str(source_path) if source_path else source,
                    destination=dest,
                    code_reference=code_ref,
                    status=status,
                )

                if status == "integrated":
                    integrated += 1
                else:
                    missing += 1

        imap.total_entries = integrated + missing + not_applicable
        imap.integrated = integrated
        imap.missing = missing
        imap.not_applicable = not_applicable

        # Auto-save
        self.save_integration_map(imap)

        logger.info(
            "Integration map: %s/%s — %d entries (%d integrated, %d missing, %d n/a)",
            project_name, platform, imap.total_entries,
            integrated, missing, not_applicable,
        )
        return imap

    def _find_manifests(self, project_name: str) -> dict:
        """Auto-discover Forge manifests.

        Returns {forge_name: manifest_path}
        """
        found = {}

        for forge_name, manifest_names in self.MANIFEST_NAMES.items():
            forge_dir = forge_name  # asset_forge, sound_forge, etc.

            search_dirs = [
                PROJECT_ROOT / "factory" / forge_dir / "catalog" / project_name,
                PROJECT_ROOT / "factory" / forge_dir / "output" / project_name,
            ]

            for search_dir in search_dirs:
                if not search_dir.exists():
                    continue
                for mname in manifest_names:
                    candidate = search_dir / mname
                    if candidate.exists():
                        found[forge_name] = str(candidate)
                        break
                # Also try {project}_manifest.json
                if forge_name not in found:
                    candidate = search_dir / f"{project_name}_manifest.json"
                    if candidate.exists():
                        found[forge_name] = str(candidate)
                if forge_name in found:
                    break

        return found

    def _load_manifest(self, path: str) -> dict:
        """Load a JSON manifest file."""
        try:
            return json.loads(Path(path).read_text(encoding="utf-8"))
        except Exception as e:
            logger.error("Failed to load manifest %s: %s", path, e)
            return None

    def _extract_entries_from_asset_manifest(self, manifest: dict) -> list:
        """Extract integrable entries from asset_manifest.json."""
        entries = []
        for spec in manifest.get("specs", []):
            asset_id = spec.get("asset_id", spec.get("id", ""))
            asset_type = spec.get("type", spec.get("asset_type", "sprite"))
            name = spec.get("name", asset_id)
            source = spec.get("output_path", spec.get("path", ""))
            entries.append({
                "id": asset_id,
                "type": asset_type,
                "name": name,
                "source_path": source,
                "category": spec.get("category", ""),
            })
        return entries

    def _extract_entries_from_sound_manifest(self, manifest: dict,
                                             platform: str,
                                             catalog_dir: Path) -> list:
        """Extract from sound_manifest.json.

        Sound manifest has per-platform file paths in sounds[].files.{platform}.
        """
        entries = []
        # Map platform to sound category type
        sound_type_map = {
            "sfx": "sfx",
            "ambient": "ambient",
            "music": "music",
            "ui_sound": "ui_sound",
            "notification": "notification",
        }

        for sound in manifest.get("sounds", []):
            sound_id = sound.get("sound_id", "")
            name = sound.get("name", sound_id)
            category = sound.get("category", "sfx")
            asset_type = sound_type_map.get(category, "sfx")

            # Get platform-specific file path
            files = sound.get("files", {})
            plat_path = files.get(platform, "")

            entries.append({
                "id": sound_id,
                "type": asset_type,
                "name": name,
                "source_path": plat_path,
                "category": category,
            })
        return entries

    def _extract_entries_from_animation_manifest(self, manifest: dict,
                                                 platform: str,
                                                 catalog_dir: Path) -> list:
        """Extract from animation_manifest.json.

        Animation manifest has per-platform file info in animations[].files.{platform}.
        For web: CSS files. For unity: C# files. For ios/android: Lottie JSON.
        """
        entries = []

        for anim in manifest.get("animations", []):
            anim_id = anim.get("anim_id", "")
            name = anim.get("name", anim_id)

            files = anim.get("files", {})
            plat_info = files.get(platform, {})
            if isinstance(plat_info, dict):
                fmt = plat_info.get("format", "")
                plat_path = plat_info.get("path", "")
            else:
                fmt = ""
                plat_path = str(plat_info) if plat_info else ""

            # Determine asset type based on format
            if fmt == "css" or (platform == "web" and plat_path.endswith(".css")):
                asset_type = "animation_css"
            elif fmt == "csharp" or plat_path.endswith(".cs"):
                asset_type = "animation_cs"
                # Derive class name from file
                class_name = Path(plat_path).stem if plat_path else ""
            else:
                asset_type = "animation_lottie"

            entry = {
                "id": anim_id,
                "type": asset_type,
                "name": name,
                "source_path": plat_path,
                "category": anim.get("category", ""),
            }
            if asset_type == "animation_cs":
                entry["class_name"] = Path(plat_path).stem if plat_path else ""

            entries.append(entry)

        return entries

    def _extract_entries_from_scene_manifest(self, manifest: dict,
                                             catalog_dir: Path) -> list:
        """Extract from scene_manifest.json (levels, scenes, shaders, prefabs).

        Only relevant for Unity platform.
        """
        entries = []

        # Levels
        for level_file in manifest.get("levels", {}).get("files", []):
            level_id = Path(level_file).stem  # e.g. "lvl-001"
            entries.append({
                "id": level_id,
                "type": "level",
                "name": level_id,
                "source_path": str(catalog_dir / "levels" / level_file),
            })

        # Scenes
        for scene_file in manifest.get("scenes", {}).get("files", []):
            scene_name = Path(scene_file).stem
            entries.append({
                "id": scene_name,
                "type": "scene",
                "name": scene_name,
                "source_path": str(catalog_dir / "scenes" / scene_file),
            })

        # Shaders
        for shader_file in manifest.get("shaders", {}).get("files", []):
            shader_name = Path(shader_file).stem
            entries.append({
                "id": shader_name,
                "type": "shader",
                "name": shader_name,
                "source_path": str(catalog_dir / "shaders" / shader_file),
            })

        # Prefabs
        for prefab_file in manifest.get("prefabs", {}).get("files", []):
            prefab_name = Path(prefab_file).stem
            entries.append({
                "id": prefab_name,
                "type": "prefab",
                "name": prefab_name,
                "source_path": str(catalog_dir / "prefabs" / prefab_file),
                "category": "general",
            })

        return entries

    def _copy_file(self, source: str, destination: str) -> bool:
        """Copy file to project directory. Create dirs as needed."""
        if not self._project_dir:
            return False

        src = Path(source)
        if not src.exists():
            logger.warning("Source not found: %s", source)
            return False

        dest = self._project_dir / destination
        dest.parent.mkdir(parents=True, exist_ok=True)

        try:
            shutil.copy2(str(src), str(dest))
            return True
        except Exception as e:
            logger.error("Copy failed %s -> %s: %s", source, dest, e)
            return False

    def save_integration_map(self, imap: IntegrationMap):
        """Save to factory/integration/maps/{project}_{platform}_map.json"""
        path = self._output_dir / f"{imap.project}_{imap.platform}_map.json"
        path.write_text(imap.to_json(), encoding="utf-8")
        logger.info("Integration map saved: %s", path)

    def load_integration_map(self, project: str, platform: str):
        """Load existing integration map."""
        path = self._output_dir / f"{project}_{platform}_map.json"
        if not path.exists():
            return None
        return IntegrationMap.from_json(path.read_text(encoding="utf-8"))

"""DriveAI Factory — Artifact Registry.

Central storage for build artifacts (IPA, AAB, Web bundles).
Each artifact is stored with version info and build metadata.

Structure::

    factory/signing/artifacts/
    +-- brainpuzzle/
        +-- ios/
            +-- 1.0.0_build5/
                +-- brainpuzzle.ipa
                +-- build_info.json
                +-- signing_info.json (if signed)

No external dependencies — only stdlib.
"""

import json
import os
import shutil
import subprocess
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


@dataclass
class ArtifactEntry:
    """Metadata for a single stored artifact."""

    project: str = ""
    platform: str = ""
    version: str = ""  # marketing version "1.0.0"
    build_number: int = 0
    build_id: str = ""  # web build_id
    artifact_path: str = ""  # path to artifact in registry
    artifact_type: str = ""  # "ipa", "aab", "web_bundle"
    artifact_size_bytes: int = 0
    timestamp: str = ""
    registry_dir: str = ""  # full path to the version dir

    def to_dict(self) -> dict:
        """Return all fields as a dict."""
        return {
            "project": self.project,
            "platform": self.platform,
            "version": self.version,
            "build_number": self.build_number,
            "build_id": self.build_id,
            "artifact_path": self.artifact_path,
            "artifact_type": self.artifact_type,
            "artifact_size_bytes": self.artifact_size_bytes,
            "timestamp": self.timestamp,
            "registry_dir": self.registry_dir,
        }


class ArtifactRegistry:
    """Central storage for build artifacts with versioning.

    Usage:
        registry = ArtifactRegistry()
        entry = registry.store("brainpuzzle", "android", version_info, "/path/to/app.aab")
        latest = registry.get_latest("brainpuzzle", "android")
        registry.cleanup_old("brainpuzzle", "android", keep=5)
    """

    def __init__(self, config=None) -> None:
        from factory.signing.config import SigningConfig

        self.config = config or SigningConfig()
        self.base_dir = Path(self.config.artifacts_dir)
        if not self.base_dir.is_absolute():
            self.base_dir = _ROOT / self.base_dir

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def store(
        self,
        project: str,
        platform: str,
        version_info,
        artifact_path: str,
        metadata: dict | None = None,
    ) -> ArtifactEntry:
        """Store an artifact in the registry.

        version_info: object with marketing_version, build_number, build_id
        (VersionInfo from version_manager.py or any object with those attrs).
        """
        marketing = getattr(version_info, "marketing_version", "0.0.0")
        build_num = getattr(version_info, "build_number", 0)
        build_id = getattr(version_info, "build_id", "")

        # 1. Create version directory
        if build_id:
            dir_name = f"{marketing}_{build_id}"
        else:
            dir_name = f"{marketing}_build{build_num}"

        version_dir = self.base_dir / project / platform / dir_name
        version_dir.mkdir(parents=True, exist_ok=True)

        # 2. Copy artifact
        src = Path(artifact_path)
        artifact_type = self._detect_artifact_type(src, platform)
        copied_path = ""
        size_bytes = 0

        if src.exists():
            if src.is_file():
                dest = version_dir / src.name
                shutil.copy2(str(src), str(dest))
                copied_path = str(dest)
                size_bytes = dest.stat().st_size
                print(
                    f"[Signing Registry] Stored: {dest.name} "
                    f"({self._format_size(size_bytes)})"
                )
            elif src.is_dir():
                dest = version_dir / src.name
                if dest.exists():
                    shutil.rmtree(str(dest))
                shutil.copytree(str(src), str(dest))
                copied_path = str(dest)
                size_bytes = self._dir_size(dest)
                print(
                    f"[Signing Registry] Stored directory: {dest.name} "
                    f"({self._format_size(size_bytes)})"
                )
                artifact_type = "web_bundle"
        else:
            print(
                f"[Signing Registry] WARNING: Artifact not found: {artifact_path}"
            )

        # 3. Get git commit hash
        commit_hash = self._get_git_hash()

        # 4. Create build_info.json
        timestamp = datetime.now(timezone.utc).isoformat()
        build_info = {
            "project": project,
            "platform": platform,
            "marketing_version": marketing,
            "build_number": build_num,
            "build_id": build_id,
            "full_version": getattr(version_info, "full_version", ""),
            "artifact_type": artifact_type,
            "artifact_filename": Path(copied_path).name if copied_path else "",
            "artifact_size_bytes": size_bytes,
            "timestamp": timestamp,
            "source_commit": commit_hash,
            "metadata": metadata or {},
        }

        info_path = version_dir / "build_info.json"
        info_path.write_text(
            json.dumps(build_info, indent=2, ensure_ascii=False) + "\n",
            encoding="utf-8",
        )

        entry = ArtifactEntry(
            project=project,
            platform=platform,
            version=marketing,
            build_number=build_num,
            build_id=build_id,
            artifact_path=copied_path,
            artifact_type=artifact_type,
            artifact_size_bytes=size_bytes,
            timestamp=timestamp,
            registry_dir=str(version_dir),
        )

        print(
            f"[Signing Registry] {project}/{platform}: "
            f"{marketing} build {build_num or build_id} registered"
        )
        return entry

    def get_latest(self, project: str, platform: str) -> ArtifactEntry | None:
        """Return the most recent artifact for project + platform."""
        entries = self.list_versions(project, platform)
        return entries[0] if entries else None

    def list_versions(self, project: str, platform: str) -> list[ArtifactEntry]:
        """List all stored artifacts for project + platform (newest first)."""
        platform_dir = self.base_dir / project / platform
        if not platform_dir.is_dir():
            return []

        entries = []
        for version_dir in platform_dir.iterdir():
            if not version_dir.is_dir():
                continue
            entry = self._load_entry(version_dir)
            if entry:
                entries.append(entry)

        # Sort by build_number descending (newest first)
        entries.sort(key=lambda e: (e.build_number, e.build_id), reverse=True)
        return entries

    def list_projects(self) -> list[str]:
        """List all projects that have artifacts."""
        if not self.base_dir.is_dir():
            return []
        return sorted(
            d.name
            for d in self.base_dir.iterdir()
            if d.is_dir() and not d.name.startswith(".")
        )

    def get_artifact_path(
        self,
        project: str,
        platform: str,
        version: str | None = None,
        build_number: int | None = None,
    ) -> str | None:
        """Return path to a specific artifact.

        - version + build_number: exact match
        - version only: latest build of that version
        - neither: latest overall
        """
        entries = self.list_versions(project, platform)
        if not entries:
            return None

        if version and build_number:
            for e in entries:
                if e.version == version and e.build_number == build_number:
                    return e.artifact_path or None
        elif version:
            for e in entries:
                if e.version == version:
                    return e.artifact_path or None
        else:
            return entries[0].artifact_path or None

        return None

    def get_total_size(self, project: str | None = None) -> int:
        """Return total size of artifacts in bytes."""
        if not self.base_dir.is_dir():
            return 0

        total = 0
        if project:
            project_dir = self.base_dir / project
            if project_dir.is_dir():
                total = self._dir_size(project_dir)
        else:
            for d in self.base_dir.iterdir():
                if d.is_dir() and not d.name.startswith("."):
                    total += self._dir_size(d)
        return total

    def cleanup_old(
        self, project: str, platform: str, keep: int = 5
    ) -> int:
        """Remove old artifacts, keeping only the N most recent.

        Returns number of removed entries.
        """
        entries = self.list_versions(project, platform)
        if len(entries) <= keep:
            return 0

        to_remove = entries[keep:]
        removed = 0

        for entry in to_remove:
            if entry.registry_dir and Path(entry.registry_dir).is_dir():
                try:
                    shutil.rmtree(entry.registry_dir)
                    removed += 1
                    print(
                        f"[Signing Registry] Cleaned up: "
                        f"{entry.version} build {entry.build_number or entry.build_id}"
                    )
                except OSError as e:
                    print(
                        f"[Signing Registry] WARNING: Failed to remove "
                        f"{entry.registry_dir}: {e}"
                    )

        if removed:
            print(
                f"[Signing Registry] {project}/{platform}: "
                f"removed {removed} old artifact(s), kept {keep}"
            )
        return removed

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    def _load_entry(self, version_dir: Path) -> ArtifactEntry | None:
        """Load an ArtifactEntry from a version directory's build_info.json."""
        info_path = version_dir / "build_info.json"
        if not info_path.is_file():
            return None

        try:
            data = json.loads(info_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return None

        # Resolve artifact path
        artifact_filename = data.get("artifact_filename", "")
        artifact_path = ""
        if artifact_filename:
            candidate = version_dir / artifact_filename
            if candidate.exists():
                artifact_path = str(candidate)

        return ArtifactEntry(
            project=data.get("project", ""),
            platform=data.get("platform", ""),
            version=data.get("marketing_version", ""),
            build_number=data.get("build_number", 0),
            build_id=data.get("build_id", ""),
            artifact_path=artifact_path,
            artifact_type=data.get("artifact_type", ""),
            artifact_size_bytes=data.get("artifact_size_bytes", 0),
            timestamp=data.get("timestamp", ""),
            registry_dir=str(version_dir),
        )

    @staticmethod
    def _detect_artifact_type(path: Path, platform: str) -> str:
        """Detect artifact type from file extension or platform."""
        if path.is_file():
            ext = path.suffix.lower()
            type_map = {
                ".ipa": "ipa",
                ".aab": "aab",
                ".apk": "apk",
                ".zip": "zip",
            }
            return type_map.get(ext, ext.lstrip(".") or "unknown")
        elif path.is_dir():
            return "web_bundle"

        # Fallback by platform
        return {
            "ios": "ipa",
            "android": "aab",
            "web": "web_bundle",
        }.get(platform, "unknown")

    @staticmethod
    def _get_git_hash() -> str:
        """Try to get the current git commit hash."""
        try:
            result = subprocess.run(
                ["git", "rev-parse", "HEAD"],
                capture_output=True,
                text=True,
                timeout=5,
                cwd=str(_ROOT),
            )
            if result.returncode == 0:
                return result.stdout.strip()[:12]
        except (OSError, subprocess.TimeoutExpired):
            pass
        return "unknown"

    @staticmethod
    def _dir_size(path: Path) -> int:
        """Calculate total size of a directory."""
        total = 0
        try:
            for f in path.rglob("*"):
                if f.is_file():
                    total += f.stat().st_size
        except OSError:
            pass
        return total

    @staticmethod
    def _format_size(size_bytes: int) -> str:
        """Format bytes as human-readable string."""
        if size_bytes < 1024:
            return f"{size_bytes} B"
        elif size_bytes < 1024 * 1024:
            return f"{size_bytes / 1024:.1f} KB"
        elif size_bytes < 1024 * 1024 * 1024:
            return f"{size_bytes / (1024 * 1024):.1f} MB"
        return f"{size_bytes / (1024 * 1024 * 1024):.1f} GB"

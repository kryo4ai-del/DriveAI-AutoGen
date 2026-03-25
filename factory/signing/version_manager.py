"""DriveAI Factory — Version Manager.

Manages version numbers per project + platform.
Persists to a central versions.json file.

Supports:
  - iOS: marketing_version + build_number (monotonically increasing)
  - Android: marketing_version + version_code (monotonically increasing)
  - Web: marketing_version + build_id (YYYYMMDD-NNN)

No external dependencies — only stdlib.
"""

import json
import re
import shutil
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent
_DEFAULT_VERSIONS_FILE = _ROOT / "factory" / "signing" / "versions.json"
_MAX_HISTORY = 50


@dataclass
class VersionInfo:
    """Version information for a single project + platform."""

    marketing_version: str = "1.0.0"
    build_number: int = 1
    build_id: str = ""  # Web only: "20260325-001"
    full_version: str = ""  # "1.0.0 (5)" or "1.0.0-20260325-001"
    platform: str = ""

    def __post_init__(self) -> None:
        if not self.full_version:
            if self.build_id:
                self.full_version = f"{self.marketing_version}-{self.build_id}"
            else:
                self.full_version = (
                    f"{self.marketing_version} ({self.build_number})"
                )


class VersionManager:
    """Manages version numbers per project + platform.

    Usage:
        vm = VersionManager("brainpuzzle")
        info = vm.get_current("ios")       # 1.0.0 (1)
        info = vm.bump_build("ios")        # 1.0.0 (2)
        info = vm.bump_version("patch")    # 1.0.1 (2)
        vm.apply_to_project("ios", "projects/brainpuzzle")
    """

    def __init__(self, project_name: str, versions_file: str | None = None) -> None:
        self.project_name = project_name
        self.versions_path = Path(versions_file) if versions_file else _DEFAULT_VERSIONS_FILE

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def get_current(self, platform: str) -> VersionInfo:
        """Return the current version for project + platform.

        Initializes with defaults (1.0.0, build 1) if not yet tracked.
        """
        data = self._load()
        project_data = data.get(self.project_name)

        if not project_data:
            # Initialize project
            project_data = self._init_project()
            data[self.project_name] = project_data
            self._save(data)

        marketing = project_data.get("marketing_version", "1.0.0")
        plat_data = project_data.get(platform, {})

        if not plat_data:
            # Initialize platform
            plat_data = self._init_platform(platform)
            project_data[platform] = plat_data
            data[self.project_name] = project_data
            self._save(data)

        return self._build_version_info(marketing, plat_data, platform)

    def bump_build(self, platform: str) -> VersionInfo:
        """Increment the build number for the given platform.

        - iOS: build_number += 1
        - Android: version_code += 1
        - Web: generate new build_id (YYYYMMDD-NNN)

        Returns the new VersionInfo.
        """
        data = self._load()
        project_data = data.setdefault(self.project_name, self._init_project())
        plat_data = project_data.setdefault(platform, self._init_platform(platform))
        marketing = project_data.get("marketing_version", "1.0.0")

        if platform == "web":
            plat_data["build_id"] = self._next_web_build_id(plat_data.get("build_id", ""))
        elif platform == "android":
            plat_data["version_code"] = plat_data.get("version_code", 0) + 1
        else:
            # iOS and others
            plat_data["build_number"] = plat_data.get("build_number", 0) + 1

        data[self.project_name][platform] = plat_data
        self._save(data)

        info = self._build_version_info(marketing, plat_data, platform)
        self._add_history(data, platform, info, "bump_build")
        self._save(data)

        print(f"[Signing Version] {self.project_name}/{platform}: build bumped to {info.full_version}")
        return info

    def bump_version(self, bump_type: str = "patch") -> VersionInfo:
        """Increment the marketing version.

        bump_type: "patch" (1.0.0 -> 1.0.1), "minor" (1.0.0 -> 1.1.0),
                   "major" (1.0.0 -> 2.0.0)

        Does NOT reset build numbers (Apple requires monotonically increasing).
        Returns a VersionInfo with the new marketing version.
        """
        data = self._load()
        project_data = data.setdefault(self.project_name, self._init_project())
        old_version = project_data.get("marketing_version", "1.0.0")

        parts = old_version.split(".")
        if len(parts) != 3:
            parts = ["1", "0", "0"]

        major, minor, patch = int(parts[0]), int(parts[1]), int(parts[2])

        if bump_type == "major":
            major += 1
            minor = 0
            patch = 0
        elif bump_type == "minor":
            minor += 1
            patch = 0
        else:  # patch
            patch += 1

        new_version = f"{major}.{minor}.{patch}"
        project_data["marketing_version"] = new_version
        data[self.project_name] = project_data
        self._save(data)

        # Log history for all initialized platforms
        for plat_key in ("ios", "android", "web"):
            if plat_key in project_data:
                plat_data = project_data[plat_key]
                info = self._build_version_info(new_version, plat_data, plat_key)
                self._add_history(data, plat_key, info, f"bump_version_{bump_type}")
        self._save(data)

        print(f"[Signing Version] {self.project_name}: version bumped {old_version} -> {new_version}")
        return VersionInfo(
            marketing_version=new_version,
            platform="all",
            full_version=new_version,
        )

    def apply_to_project(self, platform: str, project_dir: str) -> bool:
        """Write current version into the project's build files.

        - iOS: Info.plist (CFBundleShortVersionString + CFBundleVersion)
        - Android: build.gradle.kts or build.gradle (versionCode + versionName)
        - Web: package.json ("version" field)

        Returns True if successfully applied, False if target file not found.
        """
        info = self.get_current(platform)
        proj = Path(project_dir)

        if platform == "ios":
            return self._apply_ios(info, proj)
        elif platform == "android":
            return self._apply_android(info, proj)
        elif platform == "web":
            return self._apply_web(info, proj)
        else:
            print(f"[Signing Version] Unknown platform: {platform}")
            return False

    def get_history(self, platform: str) -> list[dict]:
        """Return version history for project + platform (last 50 entries)."""
        data = self._load()
        project_data = data.get(self.project_name, {})
        history_key = f"{platform}_history"
        return project_data.get(history_key, [])

    # ------------------------------------------------------------------
    # Platform-specific apply methods
    # ------------------------------------------------------------------

    def _apply_ios(self, info: VersionInfo, proj: Path) -> bool:
        """Update Info.plist with version info."""
        import plistlib

        # Find Info.plist (skip build/ and DerivedData/)
        plist_path = None
        for candidate in proj.rglob("Info.plist"):
            rel = str(candidate.relative_to(proj))
            if "build/" in rel or "DerivedData/" in rel or ".xcarchive" in rel:
                continue
            plist_path = candidate
            break

        if not plist_path:
            print(f"[Signing Version] WARNING: Info.plist not found in {proj}")
            return False

        try:
            with open(plist_path, "rb") as f:
                plist = plistlib.load(f)

            plist["CFBundleShortVersionString"] = info.marketing_version
            plist["CFBundleVersion"] = str(info.build_number)

            with open(plist_path, "wb") as f:
                plistlib.dump(plist, f)

            print(
                f"[Signing Version] iOS: Updated {plist_path.name} -> "
                f"{info.marketing_version} ({info.build_number})"
            )
            return True
        except Exception as e:
            print(f"[Signing Version] WARNING: Failed to update Info.plist: {e}")
            return False

    def _apply_android(self, info: VersionInfo, proj: Path) -> bool:
        """Update build.gradle.kts or build.gradle with version info."""
        # Try build.gradle.kts first, then build.gradle
        gradle_path = None
        for name in ("build.gradle.kts", "build.gradle"):
            # Check app/ subdir first (common Android layout)
            candidate = proj / "app" / name
            if candidate.exists():
                gradle_path = candidate
                break
            candidate = proj / name
            if candidate.exists():
                gradle_path = candidate
                break

        if not gradle_path:
            print(f"[Signing Version] WARNING: build.gradle not found in {proj}")
            return False

        try:
            content = gradle_path.read_text(encoding="utf-8")

            # Replace versionCode
            content = re.sub(
                r"versionCode\s*=\s*\d+",
                f"versionCode = {info.build_number}",
                content,
            )

            # Replace versionName (Kotlin DSL: versionName = "x.y.z")
            content = re.sub(
                r'versionName\s*=\s*"[^"]*"',
                f'versionName = "{info.marketing_version}"',
                content,
            )

            # Also handle Groovy syntax (versionName "x.y.z")
            content = re.sub(
                r"versionName\s+\"[^\"]*\"",
                f'versionName "{info.marketing_version}"',
                content,
            )
            content = re.sub(
                r"versionCode\s+\d+",
                f"versionCode {info.build_number}",
                content,
            )

            gradle_path.write_text(content, encoding="utf-8")
            print(
                f"[Signing Version] Android: Updated {gradle_path.name} -> "
                f"{info.marketing_version} (code {info.build_number})"
            )
            return True
        except Exception as e:
            print(f"[Signing Version] WARNING: Failed to update build.gradle: {e}")
            return False

    def _apply_web(self, info: VersionInfo, proj: Path) -> bool:
        """Update package.json with version info."""
        pkg_path = proj / "package.json"
        if not pkg_path.exists():
            print(f"[Signing Version] WARNING: package.json not found in {proj}")
            return False

        try:
            pkg = json.loads(pkg_path.read_text(encoding="utf-8"))
            pkg["version"] = info.marketing_version
            pkg_path.write_text(
                json.dumps(pkg, indent=2, ensure_ascii=False) + "\n",
                encoding="utf-8",
            )
            print(
                f"[Signing Version] Web: Updated package.json -> "
                f"{info.marketing_version}"
            )
            return True
        except Exception as e:
            print(f"[Signing Version] WARNING: Failed to update package.json: {e}")
            return False

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _init_project() -> dict:
        """Return default project entry."""
        return {"marketing_version": "1.0.0"}

    @staticmethod
    def _init_platform(platform: str) -> dict:
        """Return default platform entry."""
        if platform == "web":
            return {"build_id": ""}
        elif platform == "android":
            return {"version_code": 1}
        else:
            return {"build_number": 1}

    @staticmethod
    def _build_version_info(
        marketing: str, plat_data: dict, platform: str
    ) -> VersionInfo:
        """Construct a VersionInfo from stored data."""
        if platform == "web":
            return VersionInfo(
                marketing_version=marketing,
                build_id=plat_data.get("build_id", ""),
                platform=platform,
            )
        elif platform == "android":
            return VersionInfo(
                marketing_version=marketing,
                build_number=plat_data.get("version_code", 1),
                platform=platform,
            )
        else:
            return VersionInfo(
                marketing_version=marketing,
                build_number=plat_data.get("build_number", 1),
                platform=platform,
            )

    @staticmethod
    def _next_web_build_id(current_id: str) -> str:
        """Generate next web build_id in YYYYMMDD-NNN format."""
        today = datetime.now(timezone.utc).strftime("%Y%m%d")

        if current_id and current_id.startswith(today + "-"):
            # Same day — increment sequence
            try:
                seq = int(current_id.split("-")[1])
            except (IndexError, ValueError):
                seq = 0
            return f"{today}-{seq + 1:03d}"

        # New day or first build
        return f"{today}-001"

    def _add_history(
        self, data: dict, platform: str, info: VersionInfo, action: str
    ) -> None:
        """Append a history entry (in-memory, caller must save)."""
        project_data = data.setdefault(self.project_name, {})
        history_key = f"{platform}_history"
        history = project_data.setdefault(history_key, [])

        entry = {
            "version": info.marketing_version,
            "build": info.build_number,
            "build_id": info.build_id,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "action": action,
        }
        history.append(entry)

        # Trim to max entries
        if len(history) > _MAX_HISTORY:
            project_data[history_key] = history[-_MAX_HISTORY:]

    def _load(self) -> dict:
        """Load versions.json. Creates file if missing, handles corruption."""
        if not self.versions_path.exists():
            self.versions_path.parent.mkdir(parents=True, exist_ok=True)
            self.versions_path.write_text("{}", encoding="utf-8")
            return {}

        try:
            raw = self.versions_path.read_text(encoding="utf-8")
            return json.loads(raw)
        except (json.JSONDecodeError, OSError) as e:
            # Backup corrupt file
            backup = self.versions_path.with_suffix(".json.corrupt")
            print(f"[Signing Version] WARNING: Corrupt versions.json, backing up to {backup.name}")
            try:
                shutil.copy2(str(self.versions_path), str(backup))
            except OSError:
                pass
            self.versions_path.write_text("{}", encoding="utf-8")
            return {}

    def _save(self, data: dict) -> None:
        """Save versions.json atomically (write to temp, then rename)."""
        self.versions_path.parent.mkdir(parents=True, exist_ok=True)
        tmp = self.versions_path.with_suffix(".json.tmp")
        try:
            tmp.write_text(
                json.dumps(data, indent=2, ensure_ascii=False) + "\n",
                encoding="utf-8",
            )
            # Atomic replace (works on Windows with same drive)
            if self.versions_path.exists():
                self.versions_path.unlink()
            tmp.rename(self.versions_path)
        except OSError as e:
            print(f"[Signing Version] ERROR: Failed to save versions.json: {e}")
            # Fallback: direct write
            try:
                self.versions_path.write_text(
                    json.dumps(data, indent=2, ensure_ascii=False) + "\n",
                    encoding="utf-8",
                )
            except OSError:
                pass

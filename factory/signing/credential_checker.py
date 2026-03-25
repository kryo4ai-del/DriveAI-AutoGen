"""DriveAI Factory — Signing Credential Checker.

Checks if signing credentials are available BEFORE starting a build.
Prevents wasted builds that would fail at the signing step.

iOS checking is deferred to the Mac session — this module only checks
what's available on Windows (Android + Web).

No external dependencies — only stdlib.
"""

import os
import shutil
from dataclasses import dataclass, field
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


@dataclass
class CredentialStatus:
    """Result of a credential check for a single platform."""

    ready: bool
    platform: str
    missing: list = field(default_factory=list)
    found: list = field(default_factory=list)
    instructions: str = ""

    def summary(self) -> str:
        """One-line summary."""
        icon = "READY" if self.ready else "NOT READY"
        m = f", {len(self.missing)} missing" if self.missing else ""
        return f"{self.platform}: {icon} ({len(self.found)} found{m})"


class CredentialChecker:
    """Checks signing credentials before building.

    Usage:
        checker = CredentialChecker()
        status = checker.check("android", "brainpuzzle")
        if not status.ready:
            print(status.instructions)
    """

    def __init__(self, config=None) -> None:
        from factory.signing.config import SigningConfig

        self.config = config or SigningConfig()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def check(self, platform: str, project_name: str = "") -> CredentialStatus:
        """Check signing credentials for the given platform."""
        if platform == "ios":
            return self._check_ios(project_name)
        elif platform == "android":
            return self._check_android(project_name)
        elif platform == "web":
            return self._check_web()
        elif platform == "unity":
            return CredentialStatus(
                ready=False,
                platform="unity",
                missing=["Unity signing not yet implemented"],
            )
        return CredentialStatus(
            ready=False,
            platform=platform,
            missing=[f"Unknown platform: {platform}"],
        )

    def get_keystore_path(self, project_name: str) -> str | None:
        """Return keystore path if it exists, None otherwise."""
        ks_dir = Path(self.config.keystores_dir)
        if not ks_dir.is_absolute():
            ks_dir = _ROOT / ks_dir

        for ext in (".keystore", ".jks"):
            candidate = ks_dir / f"{project_name}{ext}"
            if candidate.is_file():
                return str(candidate)

        # Environment variable fallback
        env_path = os.environ.get("ANDROID_KEYSTORE_PATH", "")
        if env_path and Path(env_path).is_file():
            return env_path

        return None

    def get_keystore_password(self, project_name: str) -> str | None:
        """Return keystore password from environment, None if not set."""
        project_upper = project_name.upper().replace("-", "_")

        # Project-specific first
        pw = os.environ.get(f"ANDROID_KS_{project_upper}_PASSWORD")
        if pw:
            return pw

        # Generic fallback
        pw = os.environ.get("ANDROID_KEYSTORE_PASSWORD")
        if pw:
            return pw

        return None

    # ------------------------------------------------------------------
    # Platform-specific checks
    # ------------------------------------------------------------------

    def _check_ios(self, project_name: str) -> CredentialStatus:
        """iOS credential check (limited — Windows side only).

        Checks:
        1. ExportOptions.plist template exists
        2. Mac Bridge _commands/ directory exists
        """
        status = CredentialStatus(ready=True, platform="ios")

        # 1. ExportOptions.plist template
        template_path = Path(self.config.export_options_template)
        if not template_path.is_absolute():
            template_path = _ROOT / template_path

        if template_path.is_file():
            status.found.append(f"ExportOptions.plist template: {template_path}")
        else:
            status.missing.append("ExportOptions.plist template")
            status.ready = False

        # 2. Mac Bridge _commands/ directory
        commands_dir = _ROOT / "_commands"
        if commands_dir.is_dir():
            status.found.append("Mac Bridge _commands/ directory available")
        else:
            status.missing.append("Mac Bridge _commands/ directory")
            status.ready = False

        # Always add note about Mac session
        status.found.append(
            "iOS signing requires Mac session for full verification"
        )

        if not status.ready:
            status.instructions = (
                "iOS signing prerequisites missing on Windows side.\n"
                "1. Create ExportOptions.plist in factory/signing/templates/\n"
                "2. Ensure Mac Bridge is running (_commands/ directory)\n"
                "3. Full signing check (certs, profiles) must be done on Mac"
            )

        return status

    def _check_android(self, project_name: str) -> CredentialStatus:
        """Android credential check.

        Checks: keystore, password, keytool, gradle.
        """
        status = CredentialStatus(ready=True, platform="android")

        # 1. Keystore file
        ks_path = self.get_keystore_path(project_name)
        if ks_path:
            status.found.append(f"Keystore: {ks_path}")
        else:
            status.missing.append("Android Keystore")
            status.ready = False

        # 2. Keystore password
        ks_pw = self.get_keystore_password(project_name)
        if ks_pw:
            status.found.append("Keystore password configured")
        else:
            status.missing.append("Keystore password")
            status.ready = False

        # 3. keytool
        keytool = shutil.which("keytool")
        if keytool:
            status.found.append(f"keytool: {keytool}")
        else:
            status.missing.append("keytool (JDK)")
            # keytool not strictly required if keystore already exists
            if not ks_path:
                status.ready = False

        # 4. Gradle
        gradle = (
            shutil.which("gradle")
            or shutil.which("gradle.bat")
            or shutil.which("gradlew")
            or shutil.which("gradlew.bat")
        )
        if gradle:
            status.found.append(f"Gradle: {gradle}")
        else:
            # Check common project locations for gradlew
            for search_dir in (_ROOT / "projects", _ROOT):
                for wrapper in ("gradlew.bat", "gradlew"):
                    candidate = search_dir / wrapper
                    if candidate.is_file():
                        gradle = str(candidate)
                        status.found.append(f"Gradle wrapper: {candidate}")
                        break
                if gradle:
                    break

            if not gradle:
                status.missing.append("Gradle or Gradle wrapper")
                status.ready = False

        # Instructions
        project_upper = project_name.upper().replace("-", "_") if project_name else "PROJECT"
        ks_dir = self.config.keystores_dir

        if not ks_path and keytool:
            status.instructions = (
                f"Keystore can be auto-created during signing, or manually with:\n"
                f"keytool -genkey -v "
                f"-keystore {ks_dir}/{project_name or 'project'}.keystore "
                f"-keyalg {self.config.default_keystore_keyalg} "
                f"-keysize {self.config.default_keystore_keysize} "
                f"-validity {self.config.default_keystore_validity} "
                f"-alias {project_name or 'project'} "
                f'-dname "{self.config.default_dname}"\n\n'
                f"Then set password in .env: "
                f"ANDROID_KS_{project_upper}_PASSWORD=<password>"
            )
        elif not ks_path and not keytool:
            status.instructions = (
                "Install JDK to enable keystore creation.\n"
                "keytool not found — ensure JAVA_HOME/bin is in PATH.\n"
                "Then run signing to auto-create keystore."
            )
        elif ks_path and not ks_pw:
            status.instructions = (
                f"Keystore found but password not configured.\n"
                f"Set in .env: ANDROID_KS_{project_upper}_PASSWORD=<password>\n"
                f"Or generic: ANDROID_KEYSTORE_PASSWORD=<password>"
            )

        return status

    def _check_web(self) -> CredentialStatus:
        """Web credential check — no signing needed, only build tools."""
        status = CredentialStatus(ready=True, platform="web")

        # npm
        npm = shutil.which("npm") or shutil.which("npm.cmd")
        if npm:
            status.found.append(f"npm: {npm}")
        else:
            status.missing.append("npm")
            status.ready = False

        # node
        node = shutil.which("node") or shutil.which("node.cmd")
        if node:
            status.found.append(f"node: {node}")
        else:
            status.missing.append("node")
            # npm implies node, but check anyway
            if not npm:
                status.ready = False

        if not status.ready:
            status.instructions = (
                "Node.js and npm are required for web builds.\n"
                "Install from https://nodejs.org/ (LTS recommended)"
            )

        return status

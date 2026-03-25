"""DriveAI Factory — Android Signer.

Manages Android keystore and produces signed release builds (AAB or APK).

Flow:
  1. Ensure keystore exists (find or auto-create via keytool)
  2. Inject signingConfigs into build.gradle.kts
  3. Run gradle bundleRelease → signed AAB
  4. Fallback: assembleRelease → signed APK

Keystore passwords are read from environment variables, never hardcoded.
No external dependencies — only stdlib.
"""

import json
import os
import re
import secrets
import shutil
import subprocess
import sys
import time
from pathlib import Path

from factory.signing.config import SigningConfig
from factory.signing.signing_result import SigningResult

_ROOT = Path(__file__).resolve().parent.parent.parent


class AndroidSigner:
    """Builds and signs Android projects.

    Usage::

        signer = AndroidSigner("myapp", "/path/to/android-project", version_info)
        result = signer.build_and_sign()
        if result.status == "SUCCESS":
            print(result.artifact_path)  # path to .aab or .apk
    """

    def __init__(
        self,
        project_name: str,
        project_dir: str,
        version_info=None,
        config: SigningConfig | None = None,
    ) -> None:
        self.project_name = project_name
        self.project_dir = project_dir
        self.version_info = version_info
        self.config = config or SigningConfig()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def build_and_sign(self) -> SigningResult:
        """Full Android signing flow.

        Steps:
          1. Ensure keystore exists
          2. Inject signing config into build.gradle.kts
          3. Run gradle bundleRelease
          4. Fallback: assembleRelease (APK)
          5. Locate output artifact
        """
        start = time.time()
        print(f"[Signing Android] Starting Android signing for {self.project_name}")

        # -- Verify project -------------------------------------------------
        if not os.path.isdir(self.project_dir):
            return SigningResult(
                status="FAILED",
                phase="verify",
                artifact_type="aab",
                error=f"Project directory not found: {self.project_dir}",
                duration_seconds=round(time.time() - start, 1),
            )

        # -- Step 1: Keystore -----------------------------------------------
        keystore_path = self._ensure_keystore()
        if not keystore_path:
            return SigningResult(
                status="FAILED",
                phase="keystore",
                artifact_type="aab",
                error="No keystore available and auto-creation failed",
                duration_seconds=round(time.time() - start, 1),
            )
        print(f"[Signing Android] Keystore: {keystore_path}")

        # -- Step 2: Password -----------------------------------------------
        password = self._get_password()
        if not password:
            project_upper = self.project_name.upper().replace("-", "_")
            return SigningResult(
                status="FAILED",
                phase="keystore",
                artifact_type="aab",
                error=(
                    "Keystore password not found in environment. "
                    f"Set ANDROID_KS_{project_upper}_PASSWORD "
                    "or ANDROID_KEYSTORE_PASSWORD in .env"
                ),
                duration_seconds=round(time.time() - start, 1),
            )

        # -- Step 3: Inject signing config into gradle ----------------------
        gradle_updated = self._inject_signing_config(keystore_path, password)
        if not gradle_updated:
            return SigningResult(
                status="FAILED",
                phase="gradle_config",
                artifact_type="aab",
                error="Could not inject signing config into build.gradle.kts",
                duration_seconds=round(time.time() - start, 1),
            )

        # -- Step 4: Gradle bundleRelease -----------------------------------
        bundle_result = self._run_gradle("bundleRelease")
        artifact_path: str | None = None
        artifact_type = "aab"

        if bundle_result["success"]:
            artifact_path = self._find_aab()
        else:
            # Fallback: assembleRelease for APK
            print(
                "[Signing Android] bundleRelease failed, trying assembleRelease..."
            )
            apk_result = self._run_gradle("assembleRelease")
            if not apk_result["success"]:
                return SigningResult(
                    status="FAILED",
                    phase="build",
                    artifact_type="aab",
                    error=(
                        f"bundleRelease failed: {bundle_result['error']}\n"
                        f"assembleRelease also failed: {apk_result['error']}"
                    ),
                    duration_seconds=round(time.time() - start, 1),
                )
            artifact_path = self._find_apk()
            artifact_type = "apk"

        if not artifact_path:
            return SigningResult(
                status="FAILED",
                phase="artifact",
                artifact_type=artifact_type,
                error="Build succeeded but output artifact not found",
                duration_seconds=round(time.time() - start, 1),
            )

        duration = round(time.time() - start, 1)
        version_str = (
            getattr(self.version_info, "full_version", "")
            if self.version_info
            else ""
        )
        print(f"[Signing Android] Build successful: {artifact_path} ({duration}s)")

        return SigningResult(
            status="SUCCESS",
            artifact_path=artifact_path,
            artifact_type=artifact_type,
            version=version_str,
            duration_seconds=duration,
            details={
                "keystore": keystore_path,
                "gradle_command": "bundleRelease"
                if artifact_type == "aab"
                else "assembleRelease",
            },
        )

    # ------------------------------------------------------------------
    # Keystore management
    # ------------------------------------------------------------------

    def _ensure_keystore(self) -> str | None:
        """Find or create a keystore.

        Search order:
          1. factory/signing/keystores/{project}.keystore
          2. factory/signing/keystores/{project}.jks
          3. Environment: ANDROID_KEYSTORE_PATH

        Auto-creates via keytool if not found and keytool is available.
        """
        # Check existing keystores
        ks_dir = Path(self.config.keystores_dir)
        if not ks_dir.is_absolute():
            ks_dir = _ROOT / ks_dir

        for ext in (".keystore", ".jks"):
            candidate = ks_dir / f"{self.project_name}{ext}"
            if candidate.is_file():
                return str(candidate)

        # Environment variable fallback
        env_path = os.environ.get("ANDROID_KEYSTORE_PATH", "")
        if env_path and Path(env_path).is_file():
            return env_path

        # Auto-create if keytool is available
        keytool = shutil.which("keytool")
        if not keytool:
            print(
                "[Signing Android] keytool not found — cannot create keystore. "
                "Ensure JAVA_HOME/bin is in PATH."
            )
            return None

        return self._create_keystore(ks_dir, keytool)

    def _create_keystore(self, ks_dir: Path, keytool: str) -> str | None:
        """Auto-create a new keystore via keytool."""
        ks_dir.mkdir(parents=True, exist_ok=True)
        ks_path = ks_dir / f"{self.project_name}.keystore"
        alias = self.project_name.replace("-", "_")

        # Password: from env or auto-generate
        password = self._get_password()
        auto_generated = False
        if not password:
            password = secrets.token_urlsafe(24)
            auto_generated = True

        cmd = [
            keytool,
            "-genkey",
            "-v",
            "-keystore",
            str(ks_path),
            "-keyalg",
            self.config.default_keystore_keyalg,
            "-keysize",
            str(self.config.default_keystore_keysize),
            "-validity",
            str(self.config.default_keystore_validity),
            "-alias",
            alias,
            "-dname",
            self.config.default_dname,
            "-storepass",
            password,
            "-keypass",
            password,
        ]

        print(f"[Signing Android] Creating keystore: {ks_path}")
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=str(_ROOT),
            )
            if result.returncode != 0:
                print(
                    f"[Signing Android] WARNING: keytool failed: "
                    f"{(result.stderr or result.stdout).strip()}"
                )
                return None
        except (subprocess.TimeoutExpired, FileNotFoundError, OSError) as e:
            print(f"[Signing Android] WARNING: keytool error: {e}")
            return None

        if not ks_path.is_file():
            print("[Signing Android] WARNING: Keystore file was not created")
            return None

        # Print important information
        project_upper = self.project_name.upper().replace("-", "_")
        print(
            f"[Signing Android] ========================================\n"
            f"[Signing Android] KEYSTORE CREATED: {ks_path}\n"
            f"[Signing Android] ALIAS: {alias}\n"
            f"[Signing Android] ========================================"
        )
        if auto_generated:
            print(
                f"[Signing Android] AUTO-GENERATED PASSWORD: {password}\n"
                f"[Signing Android] SAVE THIS PASSWORD! It cannot be recovered.\n"
                f"[Signing Android] Add to .env:\n"
                f"[Signing Android]   ANDROID_KS_{project_upper}_PASSWORD={password}"
            )
        print(
            f"[Signing Android] WARNING: Back up this keystore file!\n"
            f"[Signing Android] If lost, you cannot update your app on Google Play.\n"
            f"[Signing Android] ========================================"
        )

        return str(ks_path)

    def _get_password(self) -> str | None:
        """Get keystore password from environment.

        Checks:
          1. ANDROID_KS_{PROJECT_UPPER}_PASSWORD (project-specific)
          2. ANDROID_KEYSTORE_PASSWORD (generic fallback)
        """
        project_upper = self.project_name.upper().replace("-", "_")

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
    # Gradle signing config injection
    # ------------------------------------------------------------------

    def _inject_signing_config(self, keystore_path: str, password: str) -> bool:
        """Inject or update signingConfigs in build.gradle.kts.

        - Finds build.gradle.kts (app/ first, then project root)
        - Backs up original as .gradle.kts.bak
        - Inserts signingConfigs block if missing
        - Adds signingConfig reference in buildTypes/release if missing
        - Passwords use System.getenv(), never hardcoded
        """
        gradle_path = self._find_gradle_file()
        if not gradle_path:
            print("[Signing Android] build.gradle.kts not found")
            return False

        print(f"[Signing Android] Updating gradle: {gradle_path}")

        try:
            content = Path(gradle_path).read_text(encoding="utf-8")
        except OSError as e:
            print(f"[Signing Android] WARNING: Cannot read gradle file: {e}")
            return False

        # Backup original
        backup_path = gradle_path + ".bak"
        try:
            shutil.copy2(gradle_path, backup_path)
        except OSError:
            pass  # Non-critical

        modified = False
        project_upper = self.project_name.upper().replace("-", "_")
        alias = self.project_name.replace("-", "_")
        # Normalize path separators for Gradle (always forward slashes)
        ks_path_escaped = keystore_path.replace("\\", "/")

        # -- Insert signingConfigs block if missing -------------------------
        if "signingConfigs" not in content:
            signing_block = (
                '\n    signingConfigs {\n'
                '        create("release") {\n'
                f'            storeFile = file("{ks_path_escaped}")\n'
                f'            storePassword = System.getenv("ANDROID_KS_{project_upper}_PASSWORD")'
                f' ?: System.getenv("ANDROID_KEYSTORE_PASSWORD") ?: ""\n'
                f'            keyAlias = "{alias}"\n'
                f'            keyPassword = System.getenv("ANDROID_KS_{project_upper}_PASSWORD")'
                f' ?: System.getenv("ANDROID_KEYSTORE_PASSWORD") ?: ""\n'
                '        }\n'
                '    }\n'
            )

            # Insert after "android {" line
            match = re.search(r"(android\s*\{)", content)
            if match:
                insert_pos = match.end()
                content = content[:insert_pos] + signing_block + content[insert_pos:]
                modified = True
                print("[Signing Android] Inserted signingConfigs block")
            else:
                print(
                    "[Signing Android] WARNING: 'android {' block not found in gradle"
                )
                return False
        else:
            # signingConfigs exists — check if storeFile points to correct keystore
            if ks_path_escaped not in content and keystore_path not in content:
                # Update the storeFile path
                content = re.sub(
                    r'storeFile\s*=\s*file\("[^"]*"\)',
                    f'storeFile = file("{ks_path_escaped}")',
                    content,
                )
                modified = True
                print("[Signing Android] Updated storeFile path in signingConfigs")
            else:
                print("[Signing Android] signingConfigs already configured correctly")

        # -- Add signingConfig in release buildType if missing ---------------
        if 'signingConfig = signingConfigs.getByName("release")' not in content:
            # Find release block inside buildTypes
            # Pattern: release { ... } inside buildTypes { ... }
            release_match = re.search(
                r'(getByName\("release"\)\s*\{|release\s*\{)', content
            )
            if release_match:
                insert_pos = release_match.end()
                indent = "            "
                signing_line = (
                    f'\n{indent}signingConfig = signingConfigs.getByName("release")'
                )
                content = content[:insert_pos] + signing_line + content[insert_pos:]
                modified = True
                print(
                    "[Signing Android] Added signingConfig reference in release buildType"
                )
            else:
                # No release block exists — try to add one inside buildTypes
                bt_match = re.search(r"(buildTypes\s*\{)", content)
                if bt_match:
                    insert_pos = bt_match.end()
                    release_block = (
                        '\n        getByName("release") {\n'
                        '            signingConfig = signingConfigs.getByName("release")\n'
                        "            isMinifyEnabled = false\n"
                        "        }\n"
                    )
                    content = content[:insert_pos] + release_block + content[insert_pos:]
                    modified = True
                    print(
                        "[Signing Android] Added release buildType with signingConfig"
                    )

        if modified:
            try:
                Path(gradle_path).write_text(content, encoding="utf-8")
                print(f"[Signing Android] Gradle file updated (backup: {backup_path})")
            except OSError as e:
                print(f"[Signing Android] WARNING: Cannot write gradle file: {e}")
                return False

        return True

    def _find_gradle_file(self) -> str | None:
        """Find build.gradle.kts or build.gradle in project.

        Search order:
          1. {project_dir}/app/build.gradle.kts
          2. {project_dir}/app/build.gradle
          3. {project_dir}/build.gradle.kts
          4. {project_dir}/build.gradle
        """
        for subdir in ("app", ""):
            for name in ("build.gradle.kts", "build.gradle"):
                if subdir:
                    candidate = os.path.join(self.project_dir, subdir, name)
                else:
                    candidate = os.path.join(self.project_dir, name)
                if os.path.isfile(candidate):
                    return candidate
        return None

    # ------------------------------------------------------------------
    # Gradle build execution
    # ------------------------------------------------------------------

    def _run_gradle(self, task: str) -> dict:
        """Run a gradle task (bundleRelease or assembleRelease).

        Returns ``{"success": bool, "stdout": str, "stderr": str, "error": str}``.
        """
        gradle = self._find_gradle()
        if not gradle:
            return {
                "success": False,
                "stdout": "",
                "stderr": "",
                "error": "Gradle not found. Install Gradle or add gradlew to project.",
            }

        print(f"[Signing Android] Running: {gradle} {task}")
        try:
            result = subprocess.run(
                [gradle, task],
                capture_output=True,
                text=True,
                timeout=self.config.android_build_timeout,
                cwd=self.project_dir,
            )
            if result.returncode != 0:
                err_msg = (result.stderr or result.stdout or "").strip()
                if len(err_msg) > 2000:
                    err_msg = err_msg[:2000] + "... (truncated)"
                return {
                    "success": False,
                    "stdout": result.stdout,
                    "stderr": result.stderr,
                    "error": err_msg
                    or f"Gradle {task} failed with exit code {result.returncode}",
                }
            return {
                "success": True,
                "stdout": result.stdout,
                "stderr": result.stderr,
                "error": "",
            }
        except subprocess.TimeoutExpired:
            return {
                "success": False,
                "stdout": "",
                "stderr": "",
                "error": (
                    f"Gradle {task} timed out after "
                    f"{self.config.android_build_timeout}s"
                ),
            }
        except FileNotFoundError:
            return {
                "success": False,
                "stdout": "",
                "stderr": "",
                "error": f"Gradle executable not found: {gradle}",
            }
        except OSError as e:
            return {
                "success": False,
                "stdout": "",
                "stderr": "",
                "error": f"OS error running gradle: {e}",
            }

    def _find_gradle(self) -> str | None:
        """Find gradle executable.

        Search order:
          1. gradlew.bat / gradlew in project_dir (wrapper preferred)
          2. shutil.which("gradle") / shutil.which("gradle.bat")
        """
        # Project-local wrapper first (preferred)
        if sys.platform == "win32":
            wrapper = os.path.join(self.project_dir, "gradlew.bat")
        else:
            wrapper = os.path.join(self.project_dir, "gradlew")

        if os.path.isfile(wrapper):
            return wrapper

        # Also check the other variant
        alt_wrapper = os.path.join(
            self.project_dir,
            "gradlew" if sys.platform == "win32" else "gradlew.bat",
        )
        if os.path.isfile(alt_wrapper):
            return alt_wrapper

        # System-wide gradle
        for name in ("gradle", "gradle.bat"):
            found = shutil.which(name)
            if found:
                return found

        return None

    # ------------------------------------------------------------------
    # Artifact location
    # ------------------------------------------------------------------

    def _find_aab(self) -> str | None:
        """Find the AAB output file.

        Typical locations:
          - {project_dir}/app/build/outputs/bundle/release/*.aab
          - {project_dir}/build/outputs/bundle/release/*.aab
        """
        for base in ("app", ""):
            if base:
                search_dir = Path(self.project_dir) / base / "build" / "outputs" / "bundle" / "release"
            else:
                search_dir = Path(self.project_dir) / "build" / "outputs" / "bundle" / "release"

            if search_dir.is_dir():
                for f in search_dir.iterdir():
                    if f.suffix == ".aab" and f.is_file():
                        return str(f)
        return None

    def _find_apk(self) -> str | None:
        """Find the APK output file.

        Typical locations:
          - {project_dir}/app/build/outputs/apk/release/*.apk
          - {project_dir}/build/outputs/apk/release/*.apk
        """
        for base in ("app", ""):
            if base:
                search_dir = Path(self.project_dir) / base / "build" / "outputs" / "apk" / "release"
            else:
                search_dir = Path(self.project_dir) / "build" / "outputs" / "apk" / "release"

            if search_dir.is_dir():
                for f in search_dir.iterdir():
                    if f.suffix == ".apk" and f.is_file():
                        return str(f)
        return None

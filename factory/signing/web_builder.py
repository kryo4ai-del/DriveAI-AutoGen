"""DriveAI Factory — Web Production Builder.

Builds a production-ready web bundle using npm.
No signing needed — just npm install + npm run build.

Flow:
  1. Verify project_dir has package.json
  2. npm install (if node_modules missing/empty)
  3. npm run build (configurable command)
  4. Locate output directory (.next, dist, build, out)

No external dependencies — only stdlib.
"""

import os
import subprocess
import sys
import time
from pathlib import Path

from factory.signing.config import SigningConfig
from factory.signing.signing_result import SigningResult


class WebBuilder:
    """Builds web projects for production.

    Usage::

        builder = WebBuilder("myapp", "/path/to/project", version_info)
        result = builder.build()
        if result.status == "SUCCESS":
            print(result.artifact_path)
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

    def build(self) -> SigningResult:
        """Build the web project for production.

        Steps:
          1. Verify project_dir exists and has package.json
          2. npm install (skip if node_modules populated)
          3. npm run build (via config.web_build_command)
          4. Find output directory
          5. Return SigningResult with path to output
        """
        start = time.time()
        print(f"[Signing Web] Starting web build for {self.project_name}")
        print(f"[Signing Web] Project dir: {self.project_dir}")

        # -- Verify project -------------------------------------------------
        if not os.path.isdir(self.project_dir):
            return SigningResult(
                status="FAILED",
                phase="verify",
                artifact_type="web_bundle",
                error=f"Project directory not found: {self.project_dir}",
                duration_seconds=round(time.time() - start, 1),
            )

        pkg_json = os.path.join(self.project_dir, "package.json")
        if not os.path.exists(pkg_json):
            return SigningResult(
                status="FAILED",
                phase="verify",
                artifact_type="web_bundle",
                error="package.json not found in project directory",
                duration_seconds=round(time.time() - start, 1),
            )

        npm = "npm.cmd" if sys.platform == "win32" else "npm"

        # -- Step 1: npm install --------------------------------------------
        node_modules = os.path.join(self.project_dir, "node_modules")
        if not os.path.isdir(node_modules) or not os.listdir(node_modules):
            print("[Signing Web] Running npm install...")
            install_result = self._run_command([npm, "install"], timeout=120)
            if not install_result["success"]:
                return SigningResult(
                    status="FAILED",
                    phase="install",
                    artifact_type="web_bundle",
                    error=install_result["error"],
                    duration_seconds=round(time.time() - start, 1),
                )
            print("[Signing Web] npm install completed")
        else:
            print("[Signing Web] node_modules exists, skipping npm install")

        # -- Step 2: npm run build ------------------------------------------
        build_cmd_parts = self.config.web_build_command.split()
        # Replace "npm" with platform-specific command
        if build_cmd_parts and build_cmd_parts[0] == "npm":
            build_cmd_parts[0] = npm

        print(f"[Signing Web] Running {' '.join(build_cmd_parts)}...")
        build_result = self._run_command(
            build_cmd_parts, timeout=self.config.web_build_timeout
        )
        if not build_result["success"]:
            return SigningResult(
                status="FAILED",
                phase="build",
                artifact_type="web_bundle",
                error=build_result["error"],
                duration_seconds=round(time.time() - start, 1),
            )
        print("[Signing Web] Build completed")

        # -- Step 3: Find output directory ----------------------------------
        output_path = self._find_output_dir()
        if not output_path:
            return SigningResult(
                status="FAILED",
                phase="build",
                artifact_type="web_bundle",
                error=(
                    "Build output not found. "
                    f"Checked: {', '.join(self.config.web_output_dirs)}"
                ),
                duration_seconds=round(time.time() - start, 1),
            )

        duration = round(time.time() - start, 1)
        print(f"[Signing Web] Build successful: {output_path} ({duration}s)")

        version_str = ""
        if self.version_info:
            version_str = getattr(
                self.version_info, "full_version", str(self.version_info)
            )

        return SigningResult(
            status="SUCCESS",
            artifact_path=output_path,
            artifact_type="web_bundle",
            version=version_str,
            duration_seconds=duration,
            details={
                "output_dir": output_path,
                "build_command": self.config.web_build_command,
            },
        )

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    def _run_command(self, cmd: list, timeout: int = 300) -> dict:
        """Run a subprocess command in project_dir.

        Returns ``{"success": bool, "stdout": str, "stderr": str, "error": str}``.
        Handles TimeoutExpired, FileNotFoundError, OSError.
        """
        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout,
                cwd=self.project_dir,
            )
            if result.returncode != 0:
                # Prefer stderr, fall back to stdout for error info
                err_msg = (result.stderr or result.stdout or "").strip()
                # Limit error message length
                if len(err_msg) > 2000:
                    err_msg = err_msg[:2000] + "... (truncated)"
                return {
                    "success": False,
                    "stdout": result.stdout,
                    "stderr": result.stderr,
                    "error": err_msg or f"Command failed with exit code {result.returncode}",
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
                "error": f"Command timed out after {timeout}s: {' '.join(cmd)}",
            }
        except FileNotFoundError:
            return {
                "success": False,
                "stdout": "",
                "stderr": "",
                "error": f"Command not found: {cmd[0]}",
            }
        except OSError as e:
            return {
                "success": False,
                "stdout": "",
                "stderr": "",
                "error": f"OS error running {cmd[0]}: {e}",
            }

    def _find_output_dir(self) -> str | None:
        """Check config.web_output_dirs in order for existence in project_dir.

        Returns the first found directory path, or None.
        """
        for dirname in self.config.web_output_dirs:
            candidate = os.path.join(self.project_dir, dirname)
            if os.path.isdir(candidate):
                return candidate
        return None

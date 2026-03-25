"""DriveAI Factory — Store Prep Screenshot Coordinator.

Orchestrates screenshot capture per platform.

Current state:
  - iOS: Via Mac Bridge (stub — sends command, may or may not produce screenshots)
  - Android: SKIPPED (no emulator automation yet)
  - Web: SKIPPED (no Playwright setup yet)
  - Unity: SKIPPED

This module is designed to be extended later when real screenshot capture
is available. For now it provides the structure and gracefully handles
SKIPPED states.

Mac Bridge interaction is file-based only (no imports from mac_agent):
  _commands/pending/*.json  → Mac polls
  _commands/completed/*.json → results
"""

import json
import time
import uuid
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent

# Mac Bridge queue directories (relative to project root)
_COMMANDS_DIR = _ROOT / "_commands"
_PENDING_DIR = _COMMANDS_DIR / "pending"
_COMPLETED_DIR = _COMMANDS_DIR / "completed"

# Timeouts
_IOS_POLL_INTERVAL = 10  # seconds
_IOS_TIMEOUT = 120  # seconds


@dataclass
class ScreenshotResult:
    """Result of a screenshot capture attempt."""

    status: str = "SKIPPED"  # CAPTURED, SKIPPED, FAILED, PARTIAL
    screenshots: list = field(default_factory=list)
    screenshots_count: int = 0
    reason: str = ""
    duration_seconds: float = 0.0

    def to_dict(self) -> dict:
        return {
            "status": self.status,
            "screenshots": self.screenshots,
            "screenshots_count": self.screenshots_count,
            "reason": self.reason,
            "duration_seconds": self.duration_seconds,
        }


class ScreenshotCoordinator:
    """Orchestrates screenshot capture per platform.

    Usage:
        coord = ScreenshotCoordinator("askfin_v1-1", "ios", project_dir, output_dir)
        result = coord.capture()
        # result.status → "CAPTURED", "SKIPPED", "FAILED", or "PARTIAL"
    """

    def __init__(
        self,
        project_name: str,
        platform: str,
        project_dir: str,
        output_dir: str,
        config=None,
    ) -> None:
        self.project_name = project_name
        self.platform = platform
        self.project_dir = Path(project_dir)
        self.output_dir = Path(output_dir)
        self.config = config

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def capture(self) -> ScreenshotResult:
        """Main entry point. Dispatches to platform-specific capture method."""
        start = time.time()

        if self.platform == "ios":
            result = self._capture_ios()
        elif self.platform == "android":
            result = ScreenshotResult(
                status="SKIPPED",
                reason="Android emulator automation not yet implemented",
            )
        elif self.platform == "web":
            result = ScreenshotResult(
                status="SKIPPED",
                reason="Web screenshot capture (Playwright) not yet implemented",
            )
        elif self.platform == "unity":
            result = ScreenshotResult(
                status="SKIPPED",
                reason="Unity screenshot capture not yet implemented",
            )
        else:
            result = ScreenshotResult(
                status="SKIPPED",
                reason=f"Unknown platform: {self.platform}",
            )

        result.duration_seconds = round(time.time() - start, 1)
        return result

    def check_existing_screenshots(self) -> ScreenshotResult:
        """Check if screenshots already exist in the output directory.

        Scans {output_dir}/screenshots/ for .png and .jpg files.
        Useful when screenshots were manually placed or from a previous run.
        """
        screenshots_dir = self.output_dir / "screenshots"
        if not screenshots_dir.exists():
            return ScreenshotResult(
                status="SKIPPED",
                reason="No screenshots directory found",
            )

        screenshots = []
        for img in sorted(screenshots_dir.glob("*.png")) + sorted(
            screenshots_dir.glob("*.jpg")
        ):
            screenshots.append(
                {
                    "path": str(img),
                    "filename": img.name,
                    "size_bytes": img.stat().st_size,
                }
            )

        if screenshots:
            return ScreenshotResult(
                status="CAPTURED",
                screenshots=screenshots,
                screenshots_count=len(screenshots),
            )
        return ScreenshotResult(
            status="SKIPPED",
            reason="Screenshots directory exists but is empty",
        )

    # ------------------------------------------------------------------
    # iOS — Mac Bridge file-based queue
    # ------------------------------------------------------------------

    def _capture_ios(self) -> ScreenshotResult:
        """Send screenshot command via Mac Bridge and wait for result.

        Since the Mac Bridge screenshot command is currently a stub,
        this will likely timeout or return no actual screenshots. That's
        expected — the coordinator handles this gracefully.
        """
        # 1. Check if Mac Bridge queue exists
        if not _COMMANDS_DIR.is_dir():
            return ScreenshotResult(
                status="SKIPPED",
                reason="Mac Bridge not available (_commands/ directory not found)",
            )

        # 2. Create screenshots output directory
        screenshots_dir = self.output_dir / "screenshots"
        screenshots_dir.mkdir(parents=True, exist_ok=True)

        # 3. Write command JSON
        cmd_id = str(uuid.uuid4())
        command = {
            "command": "screenshots",
            "project": self.project_name,
            "output_dir": str(screenshots_dir),
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "id": cmd_id,
        }

        _PENDING_DIR.mkdir(parents=True, exist_ok=True)
        cmd_path = _PENDING_DIR / f"{cmd_id}.json"
        cmd_path.write_text(
            json.dumps(command, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
        print(f"[Store Prep Screenshots] iOS command sent: {cmd_id}")

        # 4. Poll for result
        result_path = _COMPLETED_DIR / f"{cmd_id}.json"
        elapsed = 0.0

        while elapsed < _IOS_TIMEOUT:
            time.sleep(_IOS_POLL_INTERVAL)
            elapsed += _IOS_POLL_INTERVAL

            if result_path.exists():
                return self._process_ios_result(result_path, screenshots_dir)

        # 5. Timeout
        print(
            f"[Store Prep Screenshots] iOS screenshot timeout after {_IOS_TIMEOUT}s"
        )
        # Clean up pending command
        if cmd_path.exists():
            cmd_path.unlink(missing_ok=True)

        return ScreenshotResult(
            status="SKIPPED",
            reason=(
                "Mac Bridge screenshot timeout "
                "-- stub may not produce actual screenshots"
            ),
        )

    def _process_ios_result(
        self, result_path: Path, screenshots_dir: Path
    ) -> ScreenshotResult:
        """Process the Mac Bridge result JSON and check for actual screenshots."""
        try:
            data = json.loads(result_path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError) as e:
            return ScreenshotResult(
                status="FAILED",
                reason=f"Failed to read Mac Bridge result: {e}",
            )

        status = data.get("status", "")
        if status != "success":
            error = data.get("result", {}).get("error", "Unknown error")
            return ScreenshotResult(
                status="FAILED",
                reason=f"Mac Bridge screenshot failed: {error}",
            )

        # Check for actual screenshot files
        screenshots = []
        for img in sorted(screenshots_dir.glob("*.png")) + sorted(
            screenshots_dir.glob("*.jpg")
        ):
            screenshots.append(
                {
                    "path": str(img),
                    "filename": img.name,
                    "size_bytes": img.stat().st_size,
                }
            )

        if not screenshots:
            return ScreenshotResult(
                status="SKIPPED",
                reason="Mac Bridge returned success but no screenshot files found",
            )

        # Determine expected count from config
        expected = 3  # Default minimum
        if self.config:
            sizes = getattr(self.config, "ios_screenshot_sizes", [])
            required = sum(1 for s in sizes if s.get("required", False))
            if required > 0:
                expected = required

        if len(screenshots) < expected:
            result_status = "PARTIAL"
        else:
            result_status = "CAPTURED"

        print(
            f"[Store Prep Screenshots] iOS: {len(screenshots)} screenshots "
            f"({result_status})"
        )
        return ScreenshotResult(
            status=result_status,
            screenshots=screenshots,
            screenshots_count=len(screenshots),
        )

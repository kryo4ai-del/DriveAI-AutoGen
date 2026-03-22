"""Build packager — creates distributable packages per platform."""
import os
import subprocess
from dataclasses import dataclass, field
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


@dataclass
class PackageResult:
    platform: str
    success: bool = False
    output_path: str = ""
    size_mb: float = 0.0
    skipped: bool = False
    skip_reason: str = ""
    manual_steps: list[str] = field(default_factory=list)


class BuildPackager:
    """Creates platform-specific distributable packages."""

    def __init__(self, project_name: str):
        self.project_name = project_name
        self.project_dir = _ROOT / "projects" / project_name

    def package(self, platform: str) -> PackageResult:
        if platform == "ios":
            return self._package_ios()
        elif platform == "android":
            return self._package_android()
        elif platform == "web":
            return self._package_web()
        return PackageResult(platform=platform, skipped=True, skip_reason=f"Unknown platform: {platform}")

    def _package_ios(self) -> PackageResult:
        result = PackageResult(platform="ios")

        # Try Mac Bridge first
        try:
            from factory.mac_bridge import MacBridge
            bridge = MacBridge()
            print(f"    Checking Mac Build Agent...")
            if bridge.is_available(timeout_minutes=1):
                print(f"    Mac available! Sending archive command...")
                mac_result = bridge.archive(self.project_name)
                if mac_result and mac_result.get("status") == "success":
                    result.success = True
                    result.output_path = mac_result["result"].get("archive_path", "")
                    print(f"    iOS package: SUCCESS via Mac Bridge")
                    return result
                else:
                    err = mac_result.get("result", {}).get("error", "Unknown") if mac_result else "Timeout"
                    result.skip_reason = f"Mac build failed: {err}"
                    print(f"    iOS package: FAILED ({err})")
                    return result
            else:
                print(f"    Mac Build Agent not available")
        except ImportError:
            pass

        # Fallback: manual instructions
        result.skipped = True
        result.skip_reason = "Mac Build Agent not available"
        result.manual_steps = [
            "1. Start Mac Build Agent: python3 mac_agent/mac_build_agent.py",
            "2. Or build manually in Xcode: Product > Archive",
            "3. Distribute App > App Store Connect",
            "4. Upload via Transporter or Xcode",
        ]
        print(f"    iOS package: SKIPPED (no Mac)")
        return result

    def _package_android(self) -> PackageResult:
        result = PackageResult(platform="android")
        gradle_cmd = "gradle" if os.name != "nt" else "gradle.bat"
        try:
            subprocess.run([gradle_cmd, "--version"], capture_output=True, timeout=10)
        except (FileNotFoundError, subprocess.TimeoutExpired):
            result.skipped = True
            result.skip_reason = "Gradle not found"
            result.manual_steps = [
                f"1. cd {self.project_dir}",
                "2. gradle bundleRelease (or ./gradlew bundleRelease)",
                "3. Sign with release keystore",
                "4. Upload .aab to Play Console",
            ]
            print(f"    Android package: SKIPPED (no Gradle)")
            return result
        # Would run gradle bundleRelease here
        return result

    def _package_web(self) -> PackageResult:
        result = PackageResult(platform="web")
        try:
            r = subprocess.run(["npm", "--version"], capture_output=True, text=True, timeout=10, shell=True)
            if r.returncode != 0:
                raise FileNotFoundError
        except (FileNotFoundError, subprocess.TimeoutExpired):
            result.skipped = True
            result.skip_reason = "npm not found"
            result.manual_steps = ["1. npm install", "2. npm run build", "3. Deploy .next/ or out/"]
            print(f"    Web package: SKIPPED (no npm)")
            return result

        # Run build
        try:
            build_result = subprocess.run(
                ["npm", "run", "build"], cwd=str(self.project_dir),
                capture_output=True, text=True, timeout=120, shell=True,
            )
            if build_result.returncode == 0:
                result.success = True
                result.output_path = str(self.project_dir / ".next")
                print(f"    Web package: SUCCESS")
            else:
                result.skip_reason = f"Build failed: {build_result.stderr[:200]}"
                print(f"    Web package: FAILED")
        except subprocess.TimeoutExpired:
            result.skip_reason = "Build timed out"
        return result

"""Factory Capability Registry — scans what the factory can actually do."""
import os
import shutil
from dataclasses import dataclass, field
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent


@dataclass
class Capability:
    name: str
    category: str
    available: bool
    details: str
    limitations: list[str] = field(default_factory=list)


class CapabilityRegistry:
    """Central registry of factory capabilities. Scans actual system state."""

    def __init__(self):
        self.capabilities = self._scan_capabilities()

    def _scan_capabilities(self) -> list[Capability]:
        caps = []

        # Production Lines
        caps.append(self._check_line("ios", "Swift/SwiftUI", "234 files proven (AskFin)",
                                      ["Build requires Mac + Xcode"]))
        caps.append(self._check_line("android", "Kotlin/Compose", "537 files proven (AskFin)",
                                      ["Compile needs Android SDK"]))
        caps.append(self._check_line("web", "TypeScript/React/Next.js", "197 files proven (AskFin)",
                                      [] if shutil.which("npm") else ["npm not installed"]))
        caps.append(self._check_line("unity", "C#/Unity", "Extractor + roles ready",
                                      ["Unity Editor not installed", "Code only, no visual assets"]))

        # Assembly
        caps.append(Capability("gradle_build", "assembly",
                               shutil.which("gradle") is not None or os.path.exists("/tmp/gradle-8.4"),
                               "Gradle for Android builds",
                               [] if shutil.which("gradle") else ["Gradle not in PATH"]))
        caps.append(Capability("npm_build", "assembly",
                               shutil.which("npm") is not None,
                               "npm for Web builds",
                               [] if shutil.which("npm") else ["npm not installed"]))
        caps.append(Capability("mac_bridge", "assembly",
                               os.path.exists(str(_ROOT / "factory" / "mac_bridge" / "mac_bridge.py")),
                               "Git-based Mac build agent for iOS",
                               ["Mac must be running mac_build_agent.py"]))

        # Design
        caps.append(Capability("custom_graphics", "design", False,
                               "No image generation pipeline",
                               ["Use SF Symbols (iOS)", "Material Icons (Android)", "Lucide/Heroicons (Web)"]))
        caps.append(Capability("custom_sound", "design", False,
                               "No audio generation pipeline",
                               ["System sounds only"]))
        caps.append(Capability("custom_animations", "design", False,
                               "No custom animation pipeline — CSS/SwiftUI/Compose built-ins only",
                               ["animateContentSize, AnimatedVisibility, framer-motion, CSS transitions"]))

        # Backend
        caps.append(Capability("backend_api", "backend", False,
                               "No backend deployment pipeline",
                               ["Offline-first", "Local storage only", "No server-side logic"]))
        caps.append(Capability("database_hosting", "backend", False,
                               "No cloud database",
                               ["UserDefaults", "Room", "localStorage", "DataStore"]))

        # Store
        caps.append(Capability("store_pipeline", "store",
                               os.path.exists(str(_ROOT / "factory" / "store" / "store_pipeline.py")),
                               "Metadata, compliance, readiness reports",
                               ["App Icon manual", "Dev accounts manual", "iOS build needs Mac"]))

        # Repair
        caps.append(Capability("auto_repair", "production", True,
                               "3-tier: deterministic (96% web) + LLM Haiku + LLM Sonnet",
                               ["Complex errors need Sonnet ($0.03/batch)"]))

        # Testing
        caps.append(Capability("automated_testing", "testing", True,
                               "Test code generation. iOS Golden Gates proven (15 gates)",
                               ["iOS tests require Mac", "No real device testing"]))

        # TheBrain
        caps.append(Capability("multi_provider", "production", True,
                               "4 providers (Anthropic, OpenAI, Google, Mistral), 9 models",
                               ["Pipeline agents use Anthropic only (AutoGen limitation)"]))
        caps.append(Capability("hybrid_pipeline", "production", True,
                               "SelectorGroupChat + Single-Calls. $0.08/run",
                               []))

        return caps

    def _check_line(self, platform: str, tech: str, proven: str, lims: list) -> Capability:
        _ext_map = {"ios": "swift", "android": "kotlin", "web": "typescript", "unity": "csharp"}
        ext_name = _ext_map.get(platform, platform)
        has_extractor = os.path.exists(str(_ROOT / "code_generation" / "extractors" / f"{ext_name}_extractor.py"))
        has_roles = os.path.exists(str(_ROOT / "config" / "platform_roles" / f"{platform}.json"))
        return Capability(
            f"{platform}_production", "production",
            has_extractor and has_roles,
            f"{tech} code generation. {proven}.",
            lims,
        )

    def can(self, name: str) -> bool:
        return any(c.name == name and c.available for c in self.capabilities)

    def get_limitations(self, name: str) -> list[str]:
        for c in self.capabilities:
            if c.name == name:
                return c.limitations
        return []

    def get_realistic_constraints(self) -> dict:
        return {
            "platforms": {
                "ios": self.can("ios_production"),
                "android": self.can("android_production"),
                "web": self.can("web_production"),
                "unity": self.can("unity_production"),
            },
            "design": {
                "custom_graphics": False,
                "custom_icons": False,
                "custom_animations": False,
                "custom_sound": False,
                "allowed_design": ["system_icons", "sf_symbols", "material_icons",
                                   "tailwind_defaults", "css_animations", "system_fonts"],
            },
            "backend": {
                "server_api": False,
                "database_hosting": False,
                "allowed_storage": ["local_only", "userdefaults", "room_db",
                                    "localstorage", "datastore"],
            },
            "features": {
                "max_recommended": 20,
                "max_screens": 12,
                "complexity": "simple_to_medium",
                "no_features_requiring": [
                    "custom_artwork", "server_backend", "real_time_multiplayer",
                    "video_streaming", "AR_VR", "payment_processing",
                    "push_notifications", "camera_access", "GPS_location",
                ],
            },
            "timeline": {
                "estimated_per_feature": "1-2 hours factory time",
                "estimated_total_simple_app": "2-3 days",
                "estimated_cost_per_run": "$0.08",
            },
            "store": {
                "can_prepare_metadata": True,
                "can_check_compliance": True,
                "can_build_android": self.can("gradle_build"),
                "can_build_ios": self.can("mac_bridge"),
                "can_build_web": self.can("npm_build"),
                "manual_steps_required": ["developer_account", "app_icon", "ios_signing"],
            },
        }

    def summary(self) -> str:
        available = [c for c in self.capabilities if c.available]
        unavailable = [c for c in self.capabilities if not c.available]
        lines = [f"Factory Capabilities: {len(available)}/{len(self.capabilities)} available\n"]
        lines.append("Available:")
        for c in available:
            lines.append(f"  + {c.name}: {c.details[:80]}")
        lines.append("\nNot available:")
        for c in unavailable:
            lim = c.limitations[0] if c.limitations else "Not implemented"
            lines.append(f"  - {c.name}: {lim}")
        return "\n".join(lines)

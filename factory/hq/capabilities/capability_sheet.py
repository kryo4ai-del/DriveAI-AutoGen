"""Dynamic Factory Capability Sheet.

Generates a fresh capability profile on every call by scanning:
- CapabilityRegistry (production lines, assembly tools, design, backend, etc.)
- ServiceRegistry (external image/sound/video/search services)
- Assembly Lines (which platform lines exist on disk)
- Forge modules (asset/motion/sound/scene forges)

No caching -- always reflects current factory state.
Only stdlib + factory imports.
"""

import os
from datetime import datetime
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent.parent


def generate_capability_sheet() -> dict:
    """Generate a complete, current factory capability profile.

    Returns a structured dict describing what the factory can and cannot do.
    """
    sheet = {
        "generated_at": datetime.now().isoformat(),
        "production_lines": _scan_production_lines(),
        "external_services": _scan_external_services(),
        "forge_capabilities": _scan_forges(),
        "factory_systems": _scan_factory_systems(),
        "constraints": _get_constraints(),
        "cannot_do": _get_cannot_do(),
    }
    return sheet


# ------------------------------------------------------------------
# Production Lines
# ------------------------------------------------------------------

_LINE_INFO = {
    "ios": {
        "language": "Swift",
        "framework": "SwiftUI",
        "build_system": "xcodegen + Xcode",
        "proven": True,
        "proof": "AskFin Premium: 234 files, App Store ready, 15 Golden Gates",
    },
    "android": {
        "language": "Kotlin",
        "framework": "Jetpack Compose",
        "build_system": "Gradle",
        "proven": True,
        "proof": "AskFin: 537 files generated, compile tested",
    },
    "web": {
        "language": "TypeScript",
        "framework": "React + Next.js",
        "build_system": "npm",
        "proven": True,
        "proof": "AskFin: 197 files generated, compile tested",
    },
    "unity": {
        "language": "C#",
        "framework": "Unity Engine + URP",
        "build_system": "Unity CLI",
        "proven": False,
        "proof": "Extractor + Assembly ready, no shipped product",
    },
}


def _scan_production_lines() -> dict:
    """Check which production lines are available."""
    from factory.capability_registry import CapabilityRegistry

    registry = CapabilityRegistry()
    lines = {}

    for platform, info in _LINE_INFO.items():
        available = registry.can(f"{platform}_production")
        has_line = (_ROOT / "factory" / "assembly" / "lines" / f"{platform}_line.py").exists()
        limitations = registry.get_limitations(f"{platform}_production")

        if available and has_line:
            status = "active" if info["proven"] else "planned"
        elif has_line:
            status = "planned"
        else:
            status = "unavailable"

        capabilities = _get_line_capabilities(platform)

        lines[platform] = {
            "available": available and has_line,
            "status": status,
            "language": info["language"],
            "framework": info["framework"],
            "build_system": info["build_system"],
            "capabilities": capabilities,
            "limitations": limitations,
            "proven": info["proven"],
            "proof": info["proof"],
        }

    return lines


def _get_line_capabilities(platform: str) -> list[str]:
    """Return known capabilities for a production line."""
    base = ["ui_screens", "navigation", "local_storage"]

    platform_caps = {
        "ios": base + [
            "iap", "admob", "push_notifications", "haptic_feedback",
            "share_sheet", "sf_symbols", "core_data", "swiftui_animations",
        ],
        "android": base + [
            "iap", "admob", "push_notifications", "material_icons",
            "room_db", "compose_animations", "datastore",
        ],
        "web": base + [
            "api_calls", "lucide_icons", "css_animations",
            "responsive_design", "pwa_support",
        ],
        "unity": [
            "game_loop", "2d_rendering", "3d_rendering", "physics",
            "audio_system", "particle_effects", "ui_toolkit",
            "admob_unity", "iap_unity", "touch_input",
        ],
    }
    return platform_caps.get(platform, base)


# ------------------------------------------------------------------
# External Services
# ------------------------------------------------------------------

def _scan_external_services() -> dict:
    """Scan ServiceRegistry for active external services."""
    services_by_category = {}

    try:
        from factory.brain.service_provider.service_registry import ServiceRegistry
        sr = ServiceRegistry()
        all_services = sr.get_all_services()

        for svc in all_services:
            cat = svc.category or "other"
            if cat not in services_by_category:
                services_by_category[cat] = []
            services_by_category[cat].append({
                "id": svc.service_id,
                "name": svc.name,
                "provider": svc.provider,
                "status": svc.status,
                "capabilities": svc.capabilities,
            })
    except (ImportError, Exception):
        # ServiceRegistry not available -- return empty
        pass

    return services_by_category


# ------------------------------------------------------------------
# Forge Capabilities
# ------------------------------------------------------------------

def _scan_forges() -> dict:
    """Check which forge modules exist and their capabilities."""
    forges = {}
    forge_dir = _ROOT / "factory"

    forge_map = {
        "asset_forge": {
            "check": "asset_forge/pipeline.py",
            "capabilities": [
                "app_icons", "ui_assets", "illustrations",
                "sprites", "store_screenshots",
            ],
        },
        "sound_forge": {
            "check": "sound_forge/sound_forge_orchestrator.py",
            "capabilities": [
                "sfx_from_library", "tts_via_elevenlabs",
                "background_music_tagging",
            ],
        },
        "motion_forge": {
            "check": "motion_forge/motion_forge_orchestrator.py",
            "capabilities": [
                "lottie_animations", "css_animations",
                "platform_specific_animations",
            ],
        },
        "scene_forge": {
            "check": "scene_forge/__init__.py",
            "capabilities": [
                "unity_scenes", "ui_layouts",
            ],
        },
    }

    for forge_name, info in forge_map.items():
        exists = (forge_dir / info["check"]).exists()
        forges[forge_name] = {
            "available": exists,
            "capabilities": info["capabilities"] if exists else [],
        }

    return forges


# ------------------------------------------------------------------
# Factory Systems
# ------------------------------------------------------------------

def _scan_factory_systems() -> dict:
    """Check which factory systems are operational."""
    from factory.capability_registry import CapabilityRegistry

    registry = CapabilityRegistry()
    factory_dir = _ROOT / "factory"

    return {
        "auto_repair": registry.can("auto_repair"),
        "mac_bridge": registry.can("mac_bridge"),
        "gradle_build": registry.can("gradle_build"),
        "npm_build": registry.can("npm_build"),
        "store_pipeline": registry.can("store_pipeline"),
        "automated_testing": registry.can("automated_testing"),
        "multi_provider": registry.can("multi_provider"),
        "hybrid_pipeline": registry.can("hybrid_pipeline"),
        "qa_department": (factory_dir / "qa" / "qa_coordinator.py").exists(),
        "signing_pipeline": (factory_dir / "signing" / "signing_coordinator.py").exists(),
        "golden_gates": True,
        "compile_hygiene": True,
    }


# ------------------------------------------------------------------
# Constraints & Cannot-Do
# ------------------------------------------------------------------

def _get_constraints() -> dict:
    """Return realistic constraints from CapabilityRegistry."""
    from factory.capability_registry import CapabilityRegistry

    return CapabilityRegistry().get_realistic_constraints()


def _get_cannot_do() -> list[str]:
    """Return list of things the factory cannot do."""
    return [
        "Custom backend APIs (no Cloud Run, no custom REST servers)",
        "Realtime multiplayer (no WebSocket server infrastructure)",
        "AR/VR features (no ARKit/ARCore agents)",
        "Machine Learning model training or deployment",
        "Video generation or editing",
        "Live audio streaming",
        "Blockchain/Web3 integration",
        "Native hardware beyond standard APIs (Bluetooth LE, NFC, custom camera)",
        "Custom graphics/artwork (use system icons only)",
        "Custom sound design (system sounds + TTS only)",
        "GPS/Location services",
        "Payment processing (beyond platform IAP)",
        "Push notification server infrastructure",
    ]

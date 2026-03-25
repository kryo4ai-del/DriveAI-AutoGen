"""Platform Asset Mapper -- platform-specific path rules and code references.

Defines where Forge outputs go in each platform's project structure
and how generated code should reference those assets.
"""

import re
import logging
from pathlib import Path

logger = logging.getLogger(__name__)


PLATFORM_MAPPINGS = {
    "unity": {
        "sprite": {
            "destination": "Assets/Sprites/{category}/{name}.png",
            "code_ref": "Resources.Load<Sprite>(\"Sprites/{category}/{name}\")",
            "naming": "snake_case",
        },
        "icon": {
            "destination": "Assets/UI/Icons/{name}.png",
            "code_ref": "Resources.Load<Sprite>(\"UI/Icons/{name}\")",
            "naming": "snake_case",
        },
        "background": {
            "destination": "Assets/Textures/Backgrounds/{name}.png",
            "code_ref": "Resources.Load<Texture2D>(\"Textures/Backgrounds/{name}\")",
            "naming": "snake_case",
        },
        "sfx": {
            "destination": "Assets/Audio/SFX/{name}.wav",
            "code_ref": "Resources.Load<AudioClip>(\"Audio/SFX/{name}\")",
            "naming": "snake_case",
        },
        "ambient": {
            "destination": "Assets/Audio/Music/{name}.wav",
            "code_ref": "Resources.Load<AudioClip>(\"Audio/Music/{name}\")",
            "naming": "snake_case",
        },
        "music": {
            "destination": "Assets/Audio/Music/{name}.wav",
            "code_ref": "Resources.Load<AudioClip>(\"Audio/Music/{name}\")",
            "naming": "snake_case",
        },
        "ui_sound": {
            "destination": "Assets/Audio/UI/{name}.wav",
            "code_ref": "Resources.Load<AudioClip>(\"Audio/UI/{name}\")",
            "naming": "snake_case",
        },
        "notification": {
            "destination": "Assets/Audio/SFX/{name}.wav",
            "code_ref": "Resources.Load<AudioClip>(\"Audio/SFX/{name}\")",
            "naming": "snake_case",
        },
        "animation_lottie": {
            "destination": "Assets/Animations/Lottie/{id}.json",
            "code_ref": "Resources.Load<TextAsset>(\"Animations/Lottie/{id}\")",
            "naming": "UPPER_ID",
        },
        "animation_cs": {
            "destination": "Assets/Scripts/Animations/{class_name}.cs",
            "code_ref": "gameObject.AddComponent<{class_name}>()",
            "naming": "PascalCase",
        },
        "scene": {
            "destination": "Assets/Scenes/{name}.unity",
            "code_ref": "SceneManager.LoadScene(\"{name}\")",
            "naming": "PascalCase",
        },
        "shader": {
            "destination": "Assets/Shaders/{name}.shader",
            "code_ref": "Shader.Find(\"DriveAI/Generated/{name}\")",
            "naming": "PascalCase",
        },
        "prefab": {
            "destination": "Assets/Prefabs/{category}/{name}.prefab",
            "code_ref": "Resources.Load<GameObject>(\"Prefabs/{category}/{name}\")",
            "naming": "PascalCase",
        },
        "level": {
            "destination": "Assets/Resources/Levels/{id}.json",
            "code_ref": "Resources.Load<TextAsset>(\"Levels/{id}\")",
            "naming": "UPPER_ID",
        },
    },
    "ios": {
        "sprite": {
            "destination": "Assets.xcassets/{name}.imageset/{name}.png",
            "code_ref": "UIImage(named: \"{name}\")",
            "naming": "snake_case",
        },
        "icon": {
            "destination": "Assets.xcassets/{name}.imageset/{name}.png",
            "code_ref": "Image(\"{name}\")",
            "naming": "snake_case",
        },
        "background": {
            "destination": "Assets.xcassets/{name}.imageset/{name}.png",
            "code_ref": "Image(\"{name}\")",
            "naming": "snake_case",
        },
        "sfx": {
            "destination": "Resources/Sounds/{name}.m4a",
            "code_ref": "SoundManager.play(\"{name}\")",
            "naming": "snake_case",
        },
        "ambient": {
            "destination": "Resources/Sounds/{name}.m4a",
            "code_ref": "SoundManager.play(\"{name}\")",
            "naming": "snake_case",
        },
        "music": {
            "destination": "Resources/Sounds/{name}.m4a",
            "code_ref": "SoundManager.play(\"{name}\")",
            "naming": "snake_case",
        },
        "ui_sound": {
            "destination": "Resources/Sounds/{name}.m4a",
            "code_ref": "SoundManager.play(\"{name}\")",
            "naming": "snake_case",
        },
        "notification": {
            "destination": "Resources/Sounds/{name}.m4a",
            "code_ref": "SoundManager.play(\"{name}\")",
            "naming": "snake_case",
        },
        "animation_lottie": {
            "destination": "Resources/Animations/{id}.json",
            "code_ref": "LottieView(name: \"{id}\")",
            "naming": "UPPER_ID",
        },
    },
    "android": {
        "sprite": {
            "destination": "app/src/main/res/drawable/{name}.png",
            "code_ref": "R.drawable.{name}",
            "naming": "snake_case",
        },
        "icon": {
            "destination": "app/src/main/res/drawable/{name}.png",
            "code_ref": "R.drawable.{name}",
            "naming": "snake_case",
        },
        "background": {
            "destination": "app/src/main/res/drawable/{name}.png",
            "code_ref": "R.drawable.{name}",
            "naming": "snake_case",
        },
        "sfx": {
            "destination": "app/src/main/res/raw/{name}.ogg",
            "code_ref": "R.raw.{name}",
            "naming": "snake_case",
        },
        "ambient": {
            "destination": "app/src/main/res/raw/{name}.ogg",
            "code_ref": "R.raw.{name}",
            "naming": "snake_case",
        },
        "music": {
            "destination": "app/src/main/res/raw/{name}.ogg",
            "code_ref": "R.raw.{name}",
            "naming": "snake_case",
        },
        "ui_sound": {
            "destination": "app/src/main/res/raw/{name}.ogg",
            "code_ref": "R.raw.{name}",
            "naming": "snake_case",
        },
        "notification": {
            "destination": "app/src/main/res/raw/{name}.ogg",
            "code_ref": "R.raw.{name}",
            "naming": "snake_case",
        },
        "animation_lottie": {
            "destination": "app/src/main/assets/animations/{id}.json",
            "code_ref": "LottieCompositionSpec(\"animations/{id}.json\")",
            "naming": "UPPER_ID",
        },
    },
    "web": {
        "sprite": {
            "destination": "public/assets/images/{name}.png",
            "code_ref": "'/assets/images/{name}.png'",
            "naming": "kebab-case",
        },
        "icon": {
            "destination": "public/assets/images/{name}.png",
            "code_ref": "'/assets/images/{name}.png'",
            "naming": "kebab-case",
        },
        "background": {
            "destination": "public/assets/images/{name}.png",
            "code_ref": "'/assets/images/{name}.png'",
            "naming": "kebab-case",
        },
        "sfx": {
            "destination": "public/assets/sounds/{name}.mp3",
            "code_ref": "'/assets/sounds/{name}.mp3'",
            "naming": "kebab-case",
        },
        "ambient": {
            "destination": "public/assets/sounds/{name}.mp3",
            "code_ref": "'/assets/sounds/{name}.mp3'",
            "naming": "kebab-case",
        },
        "music": {
            "destination": "public/assets/sounds/{name}.mp3",
            "code_ref": "'/assets/sounds/{name}.mp3'",
            "naming": "kebab-case",
        },
        "ui_sound": {
            "destination": "public/assets/sounds/{name}.mp3",
            "code_ref": "'/assets/sounds/{name}.mp3'",
            "naming": "kebab-case",
        },
        "notification": {
            "destination": "public/assets/sounds/{name}.mp3",
            "code_ref": "'/assets/sounds/{name}.mp3'",
            "naming": "kebab-case",
        },
        "animation_css": {
            "destination": "src/styles/animations/{id}.css",
            "code_ref": "import '../styles/animations/{id}.css'",
            "naming": "kebab-case",
        },
        "animation_lottie": {
            "destination": "public/assets/animations/{id}.json",
            "code_ref": "'/assets/animations/{id}.json'",
            "naming": "kebab-case",
        },
    },
}


class PlatformAssetMapper:
    """Maps Forge outputs to platform-specific paths and code references."""

    def __init__(self, platform: str):
        self._platform = platform
        self._mappings = PLATFORM_MAPPINGS.get(platform, {})

    def get_destination(self, asset_type: str, name: str,
                        asset_id: str = "", category: str = "",
                        class_name: str = "") -> str:
        """Get the destination path for an asset.

        Applies naming convention and fills template.
        Returns empty string if asset_type not supported on this platform.
        """
        mapping = self._mappings.get(asset_type)
        if not mapping:
            return ""

        convention = mapping.get("naming", "snake_case")
        converted = self.convert_name(name, convention)

        template = mapping["destination"]
        return template.format(
            name=converted,
            id=asset_id or converted,
            category=category or "general",
            class_name=class_name or self.convert_name(name, "PascalCase"),
        )

    def get_code_reference(self, asset_type: str, name: str,
                           asset_id: str = "", category: str = "",
                           class_name: str = "") -> str:
        """Get the code reference string for an asset."""
        mapping = self._mappings.get(asset_type)
        if not mapping:
            return "MISSING_ASSET_TODO"

        convention = mapping.get("naming", "snake_case")
        converted = self.convert_name(name, convention)

        template = mapping["code_ref"]
        return template.format(
            name=converted,
            id=asset_id or converted,
            category=category or "general",
            class_name=class_name or self.convert_name(name, "PascalCase"),
        )

    def map_manifest_entry(self, entry: dict, asset_type: str) -> dict:
        """Map a single manifest entry to platform paths.

        Returns:
        {
            "source": original catalog path,
            "destination": platform-specific path,
            "code_reference": code string,
            "supported": True/False
        }
        """
        name = entry.get("name", "")
        asset_id = entry.get("id", entry.get("anim_id", entry.get("sound_id", "")))
        category = entry.get("category", "")
        class_name = entry.get("class_name", "")

        if not self.is_supported(asset_type):
            return {
                "source": entry.get("source_path", entry.get("path", "")),
                "destination": "",
                "code_reference": "MISSING_ASSET_TODO",
                "supported": False,
            }

        return {
            "source": entry.get("source_path", entry.get("path", "")),
            "destination": self.get_destination(
                asset_type, name, asset_id, category, class_name),
            "code_reference": self.get_code_reference(
                asset_type, name, asset_id, category, class_name),
            "supported": True,
        }

    def is_supported(self, asset_type: str) -> bool:
        """Check if this asset type is supported on this platform."""
        return asset_type in self._mappings

    @staticmethod
    def convert_name(name: str, convention: str) -> str:
        """Convert name to target convention.

        snake_case: stone_red
        PascalCase: StoneRed
        kebab-case: stone-red
        UPPER_ID: MI-001 (unchanged)
        """
        if convention == "UPPER_ID":
            return name

        # Normalize: split into words
        # Handle PascalCase/camelCase
        normalized = re.sub(r"([a-z])([A-Z])", r"\1_\2", name)
        # Handle kebab-case
        normalized = normalized.replace("-", "_")
        # Handle spaces
        normalized = normalized.replace(" ", "_")
        # Remove non-alnum except underscores
        normalized = re.sub(r"[^a-zA-Z0-9_]", "", normalized)
        words = [w for w in normalized.lower().split("_") if w]

        if not words:
            return name

        if convention == "snake_case":
            return "_".join(words)
        elif convention == "PascalCase":
            return "".join(w.capitalize() for w in words)
        elif convention == "kebab-case":
            return "-".join(words)

        return name

    @staticmethod
    def get_supported_platforms() -> list:
        return list(PLATFORM_MAPPINGS.keys())

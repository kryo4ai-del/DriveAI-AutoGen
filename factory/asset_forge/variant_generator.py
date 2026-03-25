"""Variant Generator — creates platform, mode, and state variants of assets.

Types: dark/light mode, iOS Asset Catalog, Android density, Unity paths, Web, state variants.
Simple variants are ALWAYS local (Pillow). No external API calls.
"""

import json
import logging
import re
from dataclasses import dataclass, field
from io import BytesIO

logger = logging.getLogger(__name__)


@dataclass
class VariantFile:
    data: bytes
    filename: str
    relative_path: str
    platform: str
    variant_type: str


@dataclass
class VariantSet:
    asset_id: str
    asset_name: str
    source_format: str
    files: list[VariantFile] = field(default_factory=list)

    def file_count(self) -> int:
        return len(self.files)

    def by_platform(self, platform: str) -> list[VariantFile]:
        return [f for f in self.files if f.platform == platform]

    def summary(self) -> str:
        platforms: dict[str, int] = {}
        for f in self.files:
            platforms[f.platform] = platforms.get(f.platform, 0) + 1
        lines = [f"VariantSet: {self.asset_id} ({self.asset_name}), {len(self.files)} files"]
        for p, count in sorted(platforms.items()):
            lines.append(f"  {p}: {count} files")
        return "\n".join(lines)


UNITY_CATEGORY_MAP = {
    "sprite": "Sprites",
    "icon": "UI/Icons",
    "background": "Textures/Backgrounds",
    "illustration": "Textures/Illustrations",
    "ui_element": "UI/Elements",
    "animation": "Sprites/Animations",
    "store_art": "Marketing",
    "marketing": "Marketing",
}

DEFAULT_SIZES = {
    "icon": 1024, "sprite": 512, "background": 1920,
    "illustration": 1024, "ui_element": 256, "store_art": 1242,
    "animation": 512, "marketing": 1242,
}


class VariantGenerator:

    def __init__(self, format_converter=None):
        if format_converter is None:
            from factory.asset_forge.format_converter import FormatConverter
            format_converter = FormatConverter()
        self._conv = format_converter

    # ------------------------------------------------------------------
    # Main entry
    # ------------------------------------------------------------------

    def generate_variants(self, image_data: bytes, asset_spec,
                          platforms: list[str] = None,
                          include_dark_mode: bool = False,
                          include_states: bool = False) -> VariantSet:
        plats = platforms or getattr(asset_spec, "platform_variants", ["ios", "android"])
        name = self._sanitize_name(getattr(asset_spec, "name", "asset"))
        atype = getattr(asset_spec, "asset_type", "illustration")
        base = self._get_base_size(asset_spec)

        vs = VariantSet(
            asset_id=getattr(asset_spec, "asset_id", "?"),
            asset_name=getattr(asset_spec, "name", "?"),
            source_format="png",
        )

        for plat in plats:
            if plat == "ios":
                vs.files.extend(self._generate_ios_variants(image_data, name, base))
            elif plat == "android":
                vs.files.extend(self._generate_android_variants(image_data, name, base))
            elif plat == "unity":
                vs.files.extend(self._generate_unity_variants(image_data, name, atype))
            elif plat == "web":
                vs.files.extend(self._generate_web_variants(image_data, name))

        if include_dark_mode:
            dark = self.generate_dark_mode_variant(image_data)
            dark_name = f"{name}_dark"
            for plat in plats:
                if plat == "ios":
                    vs.files.extend(self._generate_ios_variants(dark, dark_name, base))
                elif plat == "android":
                    vs.files.extend(self._generate_android_variants(dark, dark_name, base))

        if include_states:
            states = self.generate_state_variants(image_data)
            for state_name, state_data in states.items():
                if state_name == "normal":
                    continue
                sname = f"{name}_{state_name}"
                # Only generate for the primary platform
                if "ios" in plats:
                    vs.files.extend(self._generate_ios_variants(state_data, sname, base))
                elif "android" in plats:
                    vs.files.extend(self._generate_android_variants(state_data, sname, base))

        return vs

    # ------------------------------------------------------------------
    # iOS
    # ------------------------------------------------------------------

    def _generate_ios_variants(self, image_data: bytes, asset_name: str,
                                base_size: int) -> list[VariantFile]:
        files = []
        ios_results = self._conv.generate_ios_variants(image_data, base_size)
        imageset = f"{asset_name}.imageset"
        for label, r in ios_results.items():
            if r.success:
                fname = f"{asset_name}{label}.png"
                files.append(VariantFile(
                    data=r.data, filename=fname,
                    relative_path=f"{imageset}/{fname}",
                    platform="ios", variant_type="scale",
                ))
        cj = self._generate_ios_contents_json(asset_name)
        files.append(VariantFile(
            data=cj, filename="Contents.json",
            relative_path=f"{imageset}/Contents.json",
            platform="ios", variant_type="metadata",
        ))
        return files

    def _generate_ios_contents_json(self, asset_name: str) -> bytes:
        contents = {
            "images": [
                {"idiom": "universal", "scale": "1x", "filename": f"{asset_name}@1x.png"},
                {"idiom": "universal", "scale": "2x", "filename": f"{asset_name}@2x.png"},
                {"idiom": "universal", "scale": "3x", "filename": f"{asset_name}@3x.png"},
            ],
            "info": {"version": 1, "author": "DriveAI Asset Forge"},
        }
        return json.dumps(contents, indent=2).encode("utf-8")

    # ------------------------------------------------------------------
    # Android
    # ------------------------------------------------------------------

    def _generate_android_variants(self, image_data: bytes, asset_name: str,
                                    mdpi_size: int) -> list[VariantFile]:
        files = []
        andr = self._conv.generate_android_variants(image_data, mdpi_size)
        for density, r in andr.items():
            if r.success:
                fname_png = f"{asset_name}.png"
                files.append(VariantFile(
                    data=r.data, filename=fname_png,
                    relative_path=f"drawable-{density}/{fname_png}",
                    platform="android", variant_type="density",
                ))
                webp = self._conv.png_to_webp(r.data, quality=85)
                if webp.success:
                    fname_webp = f"{asset_name}.webp"
                    files.append(VariantFile(
                        data=webp.data, filename=fname_webp,
                        relative_path=f"drawable-{density}/{fname_webp}",
                        platform="android", variant_type="density",
                    ))
        return files

    # ------------------------------------------------------------------
    # Unity
    # ------------------------------------------------------------------

    def _generate_unity_variants(self, image_data: bytes, asset_name: str,
                                  asset_type: str) -> list[VariantFile]:
        category = UNITY_CATEGORY_MAP.get(asset_type, "Textures")
        fname = f"{asset_name}.png"
        return [VariantFile(
            data=image_data, filename=fname,
            relative_path=f"{category}/{fname}",
            platform="unity", variant_type="source",
        )]

    # ------------------------------------------------------------------
    # Web
    # ------------------------------------------------------------------

    def _generate_web_variants(self, image_data: bytes, asset_name: str) -> list[VariantFile]:
        files = [VariantFile(
            data=image_data, filename=f"{asset_name}.png",
            relative_path=f"images/{asset_name}.png",
            platform="web", variant_type="source",
        )]
        webp = self._conv.png_to_webp(image_data, quality=85)
        if webp.success:
            files.append(VariantFile(
                data=webp.data, filename=f"{asset_name}.webp",
                relative_path=f"images/{asset_name}.webp",
                platform="web", variant_type="optimized",
            ))
        return files

    # ------------------------------------------------------------------
    # Dark / Light mode
    # ------------------------------------------------------------------

    def generate_dark_mode_variant(self, image_data: bytes) -> bytes:
        return self._adjust_brightness(image_data, 0.8)

    def generate_light_mode_variant(self, image_data: bytes) -> bytes:
        bright = self._adjust_brightness(image_data, 1.3)
        return self._adjust_saturation(bright, 0.85)

    # ------------------------------------------------------------------
    # State variants
    # ------------------------------------------------------------------

    def generate_state_variants(self, image_data: bytes,
                                 states: list[str] = None) -> dict[str, bytes]:
        if states is None:
            states = ["normal", "pressed", "disabled", "hover"]
        result = {}
        for state in states:
            if state == "normal":
                result["normal"] = image_data
            elif state == "pressed":
                result["pressed"] = self._adjust_brightness(image_data, 0.85)
            elif state == "disabled":
                desat = self._adjust_saturation(image_data, 0.4)
                result["disabled"] = self._apply_opacity(desat, 0.5)
            elif state == "hover":
                result["hover"] = self._adjust_brightness(image_data, 1.1)
        return result

    # ------------------------------------------------------------------
    # Image adjustments
    # ------------------------------------------------------------------

    def _adjust_brightness(self, image_data: bytes, factor: float) -> bytes:
        try:
            from PIL import Image, ImageEnhance
            img = Image.open(BytesIO(image_data)).convert("RGBA")
            enhancer = ImageEnhance.Brightness(img)
            adjusted = enhancer.enhance(factor)
            buf = BytesIO()
            adjusted.save(buf, format="PNG")
            return buf.getvalue()
        except Exception:
            return image_data

    def _adjust_saturation(self, image_data: bytes, factor: float) -> bytes:
        try:
            from PIL import Image, ImageEnhance
            img = Image.open(BytesIO(image_data)).convert("RGBA")
            enhancer = ImageEnhance.Color(img)
            adjusted = enhancer.enhance(factor)
            buf = BytesIO()
            adjusted.save(buf, format="PNG")
            return buf.getvalue()
        except Exception:
            return image_data

    def _apply_opacity(self, image_data: bytes, opacity: float) -> bytes:
        try:
            from PIL import Image
            img = Image.open(BytesIO(image_data)).convert("RGBA")
            r, g, b, a = img.split()
            a = a.point(lambda x: int(x * opacity))
            img.putalpha(a)
            buf = BytesIO()
            img.save(buf, format="PNG")
            return buf.getvalue()
        except Exception:
            return image_data

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _sanitize_name(self, name: str) -> str:
        s = name.lower()
        s = re.sub(r"[äöüß]", lambda m: {"ä": "ae", "ö": "oe", "ü": "ue", "ß": "ss"}[m.group()], s)
        s = re.sub(r"[^a-z0-9]+", "_", s)
        s = s.strip("_")
        return s or "asset"

    def _get_base_size(self, asset_spec) -> int:
        sizes = getattr(asset_spec, "sizes", [])
        if sizes and isinstance(sizes, list) and sizes[0]:
            w = sizes[0].get("width") or 0
            try:
                w = int(w)
                if w > 0:
                    return max(1, w // 3)  # Source is ~@3x, base = /3
            except (TypeError, ValueError):
                pass
        atype = getattr(asset_spec, "asset_type", "illustration")
        full = DEFAULT_SIZES.get(atype, 1024)
        return max(1, full // 3)

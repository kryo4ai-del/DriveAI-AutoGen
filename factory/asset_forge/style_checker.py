"""Style Consistency Checker — validates generated assets against the project style guide.

Uses Pillow for deterministic image analysis:
- Color palette check (dominant colors vs style guide)
- Brightness check (dark/light theme compliance)
- Size check (correct dimensions)
- Transparency check (alpha channel present when needed)
"""

import logging
import math
from dataclasses import dataclass, field
from io import BytesIO
from typing import Optional

logger = logging.getLogger(__name__)

DARK_THEME_MAX_BRIGHTNESS = 80
LIGHT_THEME_MIN_BRIGHTNESS = 160

BRIGHTNESS_THRESHOLDS_DARK = {
    "sprite": 80,
    "icon": 80,
    "background": 120,
    "illustration": 100,
    "ui_element": 80,
    "store_art": 140,
    "animation": 80,
}
COLOR_MATCH_THRESHOLD = 100
COLOR_WARN_THRESHOLD = 150
SIZE_TOLERANCE = 0.10  # 10%


@dataclass
class StyleCheckResult:
    asset_id: str
    overall_verdict: str
    color_check: str = "PASS"
    brightness_check: str = "PASS"
    size_check: str = "PASS"
    transparency_check: str = "PASS"
    details: list[str] = field(default_factory=list)
    recommendation: str = ""
    dominant_colors: list[str] = field(default_factory=list)
    avg_brightness: float = 0.0

    def summary(self) -> str:
        icon = {"PASS": "+", "WARN": "!", "FAIL": "X"}.get(self.overall_verdict, "?")
        lines = [f"[{icon}] {self.asset_id}: {self.overall_verdict}"]
        for name in ["color_check", "brightness_check", "size_check", "transparency_check"]:
            val = getattr(self, name)
            if not val.startswith("PASS"):
                lines.append(f"  {name}: {val}")
        if self.recommendation:
            lines.append(f"  Recommendation: {self.recommendation}")
        return "\n".join(lines)


class StyleChecker:

    def check(self, image_data: bytes, asset_spec, style_context: dict,
              expected_width: int = None, expected_height: int = None,
              needs_transparency: bool = False) -> StyleCheckResult:

        aid = getattr(asset_spec, "asset_id", "?") if asset_spec else "?"
        img = self._open_image(image_data)
        if img is None:
            return StyleCheckResult(
                asset_id=aid, overall_verdict="FAIL",
                color_check="FAIL: could not open image",
                brightness_check="FAIL: could not open image",
                size_check="FAIL: could not open image",
                transparency_check="FAIL: could not open image",
                recommendation="regenerate",
            )

        asset_type = getattr(asset_spec, "asset_type", "default") if asset_spec else "default"
        color_result, dom_colors = self._check_colors(img, style_context)
        brightness_result, avg_br = self._check_brightness(img, style_context, needs_transparency, asset_type)
        size_result = self._check_size(img, expected_width, expected_height)
        trans_result = self._check_transparency(img, needs_transparency)

        checks = [color_result, brightness_result, size_result, trans_result]
        if any(c.startswith("FAIL") for c in checks):
            verdict = "FAIL"
            rec = "regenerate"
        elif any(c.startswith("WARN") for c in checks):
            verdict = "WARN"
            rec = "accept"
        else:
            verdict = "PASS"
            rec = "accept"

        return StyleCheckResult(
            asset_id=aid,
            overall_verdict=verdict,
            color_check=color_result,
            brightness_check=brightness_result,
            size_check=size_result,
            transparency_check=trans_result,
            recommendation=rec,
            dominant_colors=[self._rgb_to_hex(*c) for c in dom_colors],
            avg_brightness=avg_br,
        )

    # ------------------------------------------------------------------
    # Image I/O
    # ------------------------------------------------------------------

    def _open_image(self, image_data: bytes):
        try:
            from PIL import Image
            return Image.open(BytesIO(image_data))
        except Exception as e:
            logger.warning("Failed to open image: %s", e)
            return None

    # ------------------------------------------------------------------
    # Color check
    # ------------------------------------------------------------------

    def _check_colors(self, image, style_context: dict) -> tuple[str, list[tuple]]:
        dom = self._get_dominant_colors(image, 5)
        if not dom:
            return ("WARN: could not extract dominant colors", [])

        palette_hexes = []
        for entry in style_context.get("color_palette", []):
            if isinstance(entry, dict) and "hex" in entry:
                palette_hexes.append(entry["hex"])
        for h in style_context.get("background_colors", []):
            if isinstance(h, str):
                palette_hexes.append(h)
        for h in style_context.get("accent_colors", []):
            if isinstance(h, str):
                palette_hexes.append(h)

        if not palette_hexes:
            return ("PASS", dom)

        palette_rgb = []
        for h in palette_hexes:
            try:
                palette_rgb.append(self._hex_to_rgb(h))
            except (ValueError, IndexError):
                pass

        if not palette_rgb:
            return ("PASS", dom)

        matches = 0
        for dc in dom:
            best_dist = min(self._color_distance(dc, pc) for pc in palette_rgb)
            if best_dist <= COLOR_MATCH_THRESHOLD:
                matches += 1

        ratio = matches / len(dom)
        if ratio >= 0.5:
            return ("PASS", dom)
        if ratio >= 0.3:
            return (f"WARN: only {matches}/{len(dom)} dominant colors match palette", dom)
        return (f"FAIL: {matches}/{len(dom)} dominant colors match palette", dom)

    # ------------------------------------------------------------------
    # Brightness check
    # ------------------------------------------------------------------

    def _check_brightness(self, image, style_context: dict,
                          check_non_transparent_only: bool = False,
                          asset_type: str = "default") -> tuple[str, float]:
        from PIL import Image as PILImage

        theme = style_context.get("theme", "mixed")
        if theme == "mixed":
            # Compute anyway for reporting
            gray = image.convert("L")
            pixels = list(gray.getdata())
            avg = sum(pixels) / len(pixels) if pixels else 128
            return ("PASS", round(avg, 1))

        if check_non_transparent_only and image.mode in ("RGBA", "LA", "PA"):
            # Only measure non-transparent pixels
            rgba = image.convert("RGBA")
            pixels = list(rgba.getdata())
            opaque = [p for p in pixels if p[3] > 20]
            if not opaque:
                return ("PASS", 0.0)
            gray_vals = [int(0.299 * r + 0.587 * g + 0.114 * b) for r, g, b, a in opaque]
            avg = sum(gray_vals) / len(gray_vals)
        else:
            gray = image.convert("L")
            vals = list(gray.getdata())
            avg = sum(vals) / len(vals) if vals else 128

        avg = round(avg, 1)

        if theme == "dark":
            threshold = BRIGHTNESS_THRESHOLDS_DARK.get(asset_type, DARK_THEME_MAX_BRIGHTNESS)
            if avg <= threshold:
                return ("PASS", avg)
            if avg <= threshold * 1.5:
                return (f"WARN: brightness {avg} > {threshold} (dark theme, {asset_type})", avg)
            return (f"FAIL: brightness {avg} >> {threshold} (dark theme, {asset_type})", avg)

        if theme == "light":
            if avg >= LIGHT_THEME_MIN_BRIGHTNESS:
                return ("PASS", avg)
            if avg >= LIGHT_THEME_MIN_BRIGHTNESS * 0.7:
                return (f"WARN: brightness {avg} < {LIGHT_THEME_MIN_BRIGHTNESS} (light theme)", avg)
            return (f"FAIL: brightness {avg} << {LIGHT_THEME_MIN_BRIGHTNESS} (light theme)", avg)

        return ("PASS", avg)

    # ------------------------------------------------------------------
    # Size check
    # ------------------------------------------------------------------

    def _check_size(self, image, expected_width: int, expected_height: int) -> str:
        if expected_width is None or expected_height is None:
            return "PASS"
        w, h = image.size
        w_ok = abs(w - expected_width) <= expected_width * SIZE_TOLERANCE
        h_ok = abs(h - expected_height) <= expected_height * SIZE_TOLERANCE
        if w_ok and h_ok:
            return "PASS"
        return f"FAIL: expected {expected_width}x{expected_height}, got {w}x{h}"

    # ------------------------------------------------------------------
    # Transparency check
    # ------------------------------------------------------------------

    def _check_transparency(self, image, needs_transparency: bool) -> str:
        if not needs_transparency:
            return "PASS"
        if "A" in image.mode:
            return "PASS"
        return "FAIL: no alpha channel (transparency required)"

    # ------------------------------------------------------------------
    # Color utilities
    # ------------------------------------------------------------------

    def _hex_to_rgb(self, hex_color: str) -> tuple[int, int, int]:
        h = hex_color.lstrip("#")
        return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))

    def _rgb_to_hex(self, r: int, g: int, b: int) -> str:
        return f"#{r:02x}{g:02x}{b:02x}"

    def _color_distance(self, c1: tuple, c2: tuple) -> float:
        return math.sqrt(sum((a - b) ** 2 for a, b in zip(c1[:3], c2[:3])))

    def _get_dominant_colors(self, image, n_colors: int = 5) -> list[tuple[int, int, int]]:
        try:
            from PIL import Image as PILImage
            rgb = image.convert("RGB")
            small = rgb.resize((100, 100), PILImage.Resampling.LANCZOS)
            quantized = small.quantize(colors=n_colors, method=PILImage.Quantize.MEDIANCUT)
            palette = quantized.getpalette()
            if not palette:
                return []
            colors = []
            for i in range(n_colors):
                idx = i * 3
                if idx + 2 < len(palette):
                    colors.append((palette[idx], palette[idx + 1], palette[idx + 2]))
            return colors
        except Exception as e:
            logger.warning("Color extraction failed: %s", e)
            return []

    # ------------------------------------------------------------------
    # Batch
    # ------------------------------------------------------------------

    def check_batch(self, items: list[tuple], style_context: dict) -> list[StyleCheckResult]:
        """Check multiple images. Each item: (image_bytes, asset_spec, kwargs_dict)."""
        results = []
        for image_data, spec, kwargs in items:
            results.append(self.check(image_data, spec, style_context, **kwargs))
        return results

    def summary(self, results: list[StyleCheckResult]) -> str:
        pass_n = sum(1 for r in results if r.overall_verdict == "PASS")
        warn_n = sum(1 for r in results if r.overall_verdict == "WARN")
        fail_n = sum(1 for r in results if r.overall_verdict == "FAIL")

        lines = [
            "Style Check Summary:",
            f"  PASS: {pass_n} assets",
            f"  WARN: {warn_n} assets",
            f"  FAIL: {fail_n} assets",
        ]

        warns = [r for r in results if r.overall_verdict == "WARN"]
        if warns:
            lines.append("\nWarnings:")
            for r in warns:
                for name in ["color_check", "brightness_check", "size_check", "transparency_check"]:
                    val = getattr(r, name)
                    if val.startswith("WARN"):
                        lines.append(f"  {r.asset_id}: {val}")

        fails = [r for r in results if r.overall_verdict == "FAIL"]
        if fails:
            lines.append("\nFailures:")
            for r in fails:
                for name in ["color_check", "brightness_check", "size_check", "transparency_check"]:
                    val = getattr(r, name)
                    if val.startswith("FAIL"):
                        lines.append(f"  {r.asset_id}: {val}")

        return "\n".join(lines)

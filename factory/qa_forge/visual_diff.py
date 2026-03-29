"""Visual Diff -- validates generated image assets against style guide.

Checks: color palette, brightness, resolution, transparency.
Uses Pillow for image analysis.
"""

import json
import logging
import math
from pathlib import Path

from .config import QA_CONFIG

logger = logging.getLogger(__name__)

try:
    from PIL import Image
    _HAS_PILLOW = True
except ImportError:
    _HAS_PILLOW = False


class VisualDiff:
    """Checks images for color palette, brightness, resolution, transparency."""

    def check_asset(self, image_path: str, asset_spec: dict = None,
                    style_context: dict = None) -> dict:
        """Run all visual checks on one image."""
        result = {
            "asset_id": (asset_spec or {}).get("id", Path(image_path).stem),
            "file": str(image_path),
            "checks": {},
            "overall": "pass",
            "warnings": [],
            "errors": [],
        }

        if not _HAS_PILLOW:
            result["overall"] = "warn"
            result["warnings"].append("Pillow not installed -- skipping image checks")
            return result

        path = Path(image_path)
        if not path.exists():
            result["overall"] = "fail"
            result["errors"].append(f"File not found: {image_path}")
            return result

        try:
            image = Image.open(path)
        except Exception as e:
            result["overall"] = "fail"
            result["errors"].append(f"Cannot open image: {e}")
            return result

        spec = asset_spec or {}
        ctx = style_context or {}
        asset_type = spec.get("type", self._guess_type(path.name))
        theme = ctx.get("theme", "dark")
        palette_hex = ctx.get("palette", [])

        # Run checks
        result["checks"]["color_palette"] = self._check_color_palette(
            image, palette_hex, QA_CONFIG["color_tolerance_rgb_distance"])
        result["checks"]["brightness"] = self._check_brightness(
            image, theme, asset_type)
        result["checks"]["resolution"] = self._check_resolution(
            image, asset_type, spec.get("expected_resolution"))
        result["checks"]["transparency"] = self._check_transparency(
            image, asset_type)

        # Aggregate
        for name, check in result["checks"].items():
            if check.get("pass") is False:
                if check.get("severity", "error") == "warning":
                    result["warnings"].append(f"{name}: {check.get('details', '')}")
                else:
                    result["errors"].append(f"{name}: {check.get('details', '')}")
            elif check.get("pass") == "warn":
                result["warnings"].append(f"{name}: {check.get('details', '')}")

        if result["errors"]:
            result["overall"] = "fail"
        elif result["warnings"]:
            result["overall"] = "warn"

        return result

    def _check_color_palette(self, image, palette_hex: list,
                             tolerance: float) -> dict:
        """Extract dominant colors, compare to palette."""
        dominant = self._get_dominant_colors(image, n=5)
        check = {
            "pass": True,
            "dominant_colors": [f"#{r:02x}{g:02x}{b:02x}" for r, g, b in dominant],
            "details": "",
        }

        if not palette_hex:
            check["details"] = "No palette specified -- skipped"
            return check

        palette_rgb = [self._hex_to_rgb(h) for h in palette_hex]
        warn_dist = QA_CONFIG["color_warn_distance"]

        unmatched = []
        for dc in dominant:
            min_dist = min(self._color_distance(dc, pc) for pc in palette_rgb)
            if min_dist > tolerance:
                unmatched.append((dc, min_dist))

        if unmatched:
            worst = max(unmatched, key=lambda x: x[1])
            if worst[1] > warn_dist:
                check["pass"] = False
                check["severity"] = "error"
                check["details"] = (
                    f"{len(unmatched)} dominant colors outside palette "
                    f"(worst distance: {worst[1]:.0f})")
            else:
                check["pass"] = "warn"
                check["details"] = (
                    f"{len(unmatched)} colors near palette boundary "
                    f"(worst: {worst[1]:.0f})")

        return check

    def _check_brightness(self, image, theme: str, asset_type: str) -> dict:
        """Average brightness check. For sprites: only non-transparent pixels."""
        img = image.convert("RGBA")
        pixels = list(img.getdata())

        if asset_type in ("sprite", "icon"):
            # Only count non-transparent pixels
            pixels = [p for p in pixels if p[3] > 10]

        if not pixels:
            return {"pass": True, "average": 0, "threshold": 0,
                    "details": "No visible pixels"}

        avg = sum((0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2])
                  for p in pixels) / len(pixels)

        if theme == "dark":
            threshold = QA_CONFIG["brightness_threshold_dark"]
            passed = avg <= threshold
        else:
            threshold = QA_CONFIG["brightness_threshold_light"]
            passed = avg >= threshold

        return {
            "pass": passed,
            "average": round(avg, 1),
            "threshold": threshold,
            "details": (f"avg={avg:.0f} {'<=' if theme == 'dark' else '>='} "
                        f"{threshold} ({theme} theme)")
                       if passed else
                       (f"avg brightness {avg:.0f} violates {theme} theme "
                        f"threshold {threshold}"),
        }

    def _check_resolution(self, image, asset_type: str,
                          expected: dict = None) -> dict:
        """Check dimensions against minimums per type."""
        w, h = image.size
        if expected:
            min_w = expected.get("width", 0)
            min_h = expected.get("height", 0)
        elif asset_type == "icon":
            min_w = min_h = QA_CONFIG["min_icon_resolution"]
        else:
            min_w = min_h = QA_CONFIG["min_sprite_resolution"]

        passed = w >= min_w and h >= min_h
        return {
            "pass": passed,
            "actual_size": {"width": w, "height": h},
            "expected_min": {"width": min_w, "height": min_h},
            "details": (f"{w}x{h} OK (min {min_w}x{min_h})" if passed else
                        f"{w}x{h} too small (need {min_w}x{min_h})"),
        }

    def _check_transparency(self, image, asset_type: str) -> dict:
        """Sprites/icons need alpha. Backgrounds should not be transparent."""
        has_alpha = image.mode in ("RGBA", "LA", "PA")

        needs_alpha = asset_type in ("sprite", "icon")
        no_alpha = asset_type in ("background",)

        if needs_alpha and not has_alpha:
            return {"pass": False, "has_alpha": False, "expected": True,
                    "details": f"{asset_type} should have alpha channel"}
        if no_alpha and has_alpha:
            # Check if alpha is actually used
            if image.mode == "RGBA":
                alpha_vals = [p[3] for p in image.getdata()]
                fully_opaque = all(a == 255 for a in alpha_vals)
                if not fully_opaque:
                    return {"pass": "warn", "has_alpha": True, "expected": False,
                            "severity": "warning",
                            "details": "Background has transparency (unexpected)"}

        return {"pass": True, "has_alpha": has_alpha,
                "expected": needs_alpha,
                "details": "OK"}

    def check_batch(self, manifest_path: str,
                    style_context: dict = None) -> list:
        """Check all assets in a manifest."""
        manifest = self._load_manifest(manifest_path)
        if not manifest:
            return []

        results = []
        base_dir = Path(manifest_path).parent

        for spec in manifest.get("specs", manifest.get("assets", [])):
            filename = spec.get("filename", spec.get("file", ""))
            if not filename:
                continue
            img_path = base_dir / filename
            results.append(self.check_asset(str(img_path), spec, style_context))

        return results

    def _load_manifest(self, path: str) -> dict:
        """Load asset manifest JSON."""
        try:
            return json.loads(Path(path).read_text(encoding="utf-8"))
        except Exception as e:
            logger.error("Cannot load manifest %s: %s", path, e)
            return {}

    def _get_dominant_colors(self, image, n: int = 5) -> list:
        """Get N dominant colors via Pillow quantize."""
        img = image.convert("RGB")
        # Reduce to small size for speed
        img = img.resize((100, 100), Image.LANCZOS)
        quantized = img.quantize(colors=n, method=Image.Quantize.MEDIANCUT)
        palette = quantized.getpalette()
        if not palette:
            return [(0, 0, 0)]

        colors = []
        for i in range(min(n, len(palette) // 3)):
            r, g, b = palette[i * 3:(i + 1) * 3]
            colors.append((r, g, b))
        return colors or [(0, 0, 0)]

    @staticmethod
    def _color_distance(c1: tuple, c2: tuple) -> float:
        """Euclidean RGB distance."""
        return math.sqrt(sum((a - b) ** 2 for a, b in zip(c1, c2)))

    @staticmethod
    def _hex_to_rgb(hex_color: str) -> tuple:
        """Convert #RRGGBB to (R, G, B)."""
        h = hex_color.lstrip("#")
        return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))

    @staticmethod
    def _guess_type(filename: str) -> str:
        """Guess asset type from filename."""
        name = filename.lower()
        if "icon" in name:
            return "icon"
        if "bg" in name or "background" in name:
            return "background"
        return "sprite"

    def summary(self, results: list) -> str:
        """Pass: N, Warn: N, Fail: N + details."""
        p = sum(1 for r in results if r["overall"] == "pass")
        w = sum(1 for r in results if r["overall"] == "warn")
        f = sum(1 for r in results if r["overall"] == "fail")
        lines = [f"Visual Diff: {len(results)} assets -- Pass: {p}, Warn: {w}, Fail: {f}"]
        for r in results:
            if r["overall"] != "pass":
                lines.append(f"  [{r['overall'].upper()}] {r['asset_id']}: "
                             f"{'; '.join(r['errors'] + r['warnings'])}")
        return "\n".join(lines)

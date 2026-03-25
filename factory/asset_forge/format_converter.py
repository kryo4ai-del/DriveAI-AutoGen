"""Format Converter — transforms raw generation output into platform-correct formats.

Handles: resize, @1x/@2x/@3x variants, sprite sheets, SVG→PNG, PNG→WebP, padding, crop.
All operations use Pillow. cairosvg for SVG→PNG.
"""

import logging
import math
from dataclasses import dataclass
from io import BytesIO
from typing import Optional

logger = logging.getLogger(__name__)


@dataclass
class ConversionResult:
    success: bool
    data: bytes = b""
    format: str = "png"
    width: int = 0
    height: int = 0
    label: str = ""
    error: str = ""


class FormatConverter:

    ANDROID_DENSITIES = {
        "mdpi": 1.0,
        "hdpi": 1.5,
        "xhdpi": 2.0,
        "xxhdpi": 3.0,
        "xxxhdpi": 4.0,
    }

    IOS_SCALES = {"@1x": 1, "@2x": 2, "@3x": 3}

    # ------------------------------------------------------------------
    # Core operations
    # ------------------------------------------------------------------

    def resize(self, image_data: bytes, target_width: int, target_height: int,
               maintain_aspect: bool = True) -> ConversionResult:
        img = self._open_image(image_data)
        if img is None:
            return ConversionResult(False, error="Failed to open image")
        try:
            from PIL import Image
            if maintain_aspect:
                img.thumbnail((target_width, target_height), Image.Resampling.LANCZOS)
                if img.size != (target_width, target_height):
                    canvas = Image.new("RGBA", (target_width, target_height), (0, 0, 0, 0))
                    x = (target_width - img.width) // 2
                    y = (target_height - img.height) // 2
                    canvas.paste(img, (x, y), img if img.mode == "RGBA" else None)
                    img = canvas
            else:
                img = img.resize((target_width, target_height), Image.Resampling.LANCZOS)
            data = self._to_bytes(img)
            return ConversionResult(True, data, "png", img.width, img.height)
        except Exception as e:
            return ConversionResult(False, error=str(e))

    def generate_ios_variants(self, image_data: bytes, base_size: int) -> dict[str, ConversionResult]:
        results = {}
        for label, scale in self.IOS_SCALES.items():
            size = base_size * scale
            results[label] = self.resize(image_data, size, size)
            if results[label].success:
                results[label].label = label
        return results

    def generate_android_variants(self, image_data: bytes, mdpi_size: int) -> dict[str, ConversionResult]:
        results = {}
        for density, mult in self.ANDROID_DENSITIES.items():
            size = round(mdpi_size * mult)
            results[density] = self.resize(image_data, size, size)
            if results[density].success:
                results[density].label = density
        return results

    def create_sprite_sheet(self, sprites: list[bytes], cols: int = 0,
                            rows: int = 0, padding: int = 2) -> ConversionResult:
        from PIL import Image
        images = []
        for s in sprites:
            img = self._open_image(s)
            if img is None:
                return ConversionResult(False, error="Failed to open a sprite")
            images.append(img)
        if not images:
            return ConversionResult(False, error="No sprites provided")

        sw, sh = images[0].size
        n = len(images)

        if cols <= 0 and rows <= 0:
            cols = math.ceil(math.sqrt(n))
            rows = math.ceil(n / cols)
        elif cols <= 0:
            cols = math.ceil(n / rows)
        elif rows <= 0:
            rows = math.ceil(n / cols)

        sheet_w = (sw + padding) * cols
        sheet_h = (sh + padding) * rows
        sheet = Image.new("RGBA", (sheet_w, sheet_h), (0, 0, 0, 0))

        for idx, img in enumerate(images):
            r, c = divmod(idx, cols)
            x = c * (sw + padding)
            y = r * (sh + padding)
            paste_img = img.convert("RGBA")
            sheet.paste(paste_img, (x, y), paste_img)

        if not self._is_power_of_2(sheet_w) or not self._is_power_of_2(sheet_h):
            logger.info("Sprite sheet %dx%d is not power-of-2 (game engines prefer PoT)", sheet_w, sheet_h)

        data = self._to_bytes(sheet)
        return ConversionResult(True, data, "png", sheet_w, sheet_h, "sheet")

    def svg_to_png(self, svg_data: bytes, width: int = 1024, height: int = 1024) -> ConversionResult:
        try:
            import cairosvg
            png_bytes = cairosvg.svg2png(bytestring=svg_data, output_width=width, output_height=height)
            return ConversionResult(True, png_bytes, "png", width, height)
        except ImportError:
            return ConversionResult(False, error="cairosvg not installed")
        except Exception as e:
            return ConversionResult(False, error=f"SVG conversion failed: {e}")

    def png_to_webp(self, png_data: bytes, quality: int = 85) -> ConversionResult:
        img = self._open_image(png_data)
        if img is None:
            return ConversionResult(False, error="Failed to open image")
        try:
            buf = BytesIO()
            img.save(buf, format="WEBP", quality=quality)
            data = buf.getvalue()
            return ConversionResult(True, data, "webp", img.width, img.height)
        except Exception as e:
            return ConversionResult(False, error=str(e))

    def add_padding(self, image_data: bytes, padding: int,
                    bg_color: tuple = (0, 0, 0, 0)) -> ConversionResult:
        img = self._open_image(image_data)
        if img is None:
            return ConversionResult(False, error="Failed to open image")
        try:
            from PIL import Image
            new_w = img.width + 2 * padding
            new_h = img.height + 2 * padding
            mode = "RGBA" if len(bg_color) == 4 else "RGB"
            canvas = Image.new(mode, (new_w, new_h), bg_color)
            paste_img = img.convert(mode)
            if mode == "RGBA":
                canvas.paste(paste_img, (padding, padding), paste_img)
            else:
                canvas.paste(paste_img, (padding, padding))
            data = self._to_bytes(canvas, "PNG")
            return ConversionResult(True, data, "png", new_w, new_h)
        except Exception as e:
            return ConversionResult(False, error=str(e))

    def crop_to_content(self, image_data: bytes, threshold: int = 10) -> ConversionResult:
        img = self._open_image(image_data)
        if img is None:
            return ConversionResult(False, error="Failed to open image")
        try:
            rgba = img.convert("RGBA")
            alpha = rgba.split()[3]
            bbox = alpha.getbbox()
            if bbox is None:
                return ConversionResult(False, error="Image is fully transparent")
            margin = 2
            x1 = max(0, bbox[0] - margin)
            y1 = max(0, bbox[1] - margin)
            x2 = min(rgba.width, bbox[2] + margin)
            y2 = min(rgba.height, bbox[3] + margin)
            cropped = rgba.crop((x1, y1, x2, y2))
            data = self._to_bytes(cropped)
            return ConversionResult(True, data, "png", cropped.width, cropped.height)
        except Exception as e:
            return ConversionResult(False, error=str(e))

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _open_image(self, image_data: bytes):
        try:
            from PIL import Image
            return Image.open(BytesIO(image_data))
        except Exception as e:
            logger.warning("Failed to open image: %s", e)
            return None

    def _to_bytes(self, image, fmt: str = "PNG") -> bytes:
        buf = BytesIO()
        image.save(buf, format=fmt)
        return buf.getvalue()

    def _is_power_of_2(self, n: int) -> bool:
        return n > 0 and (n & (n - 1)) == 0

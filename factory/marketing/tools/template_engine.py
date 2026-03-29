"""Marketing Template Engine — Erzeugt Marketing-Grafiken mit Pillow.

Deterministisches Tool (kein LLM). Erzeugt:
- Social Media Posts (1080x1080, 1080x1920, 1200x628)
- App Store Screenshots (1290x2796 iOS, 1080x1920 Android)
- Banner / Header (1500x500 Twitter, 1584x396 LinkedIn)
- Feature Graphics (1024x500 Google Play)
- Thumbnails (1280x720 YouTube)

Alle Formate als PNG.
"""

import json
import logging
import os
import shutil
from typing import Optional

from PIL import Image, ImageDraw, ImageFont

logger = logging.getLogger("factory.marketing.tools.template_engine")

# --- Format-Definitionen ---

FORMATS = {
    "social_square": {"width": 1080, "height": 1080, "label": "Social Media (Square)"},
    "social_story": {"width": 1080, "height": 1920, "label": "Social Media (Story/Reel)"},
    "social_landscape": {"width": 1200, "height": 628, "label": "Social Media (Landscape)"},
    "ios_screenshot": {"width": 1290, "height": 2796, "label": "iOS App Store Screenshot"},
    "android_screenshot": {"width": 1080, "height": 1920, "label": "Android Play Store Screenshot"},
    "twitter_header": {"width": 1500, "height": 500, "label": "Twitter/X Header"},
    "linkedin_banner": {"width": 1584, "height": 396, "label": "LinkedIn Banner"},
    "feature_graphic": {"width": 1024, "height": 500, "label": "Google Play Feature Graphic"},
    "youtube_thumbnail": {"width": 1280, "height": 720, "label": "YouTube Thumbnail"},
    "og_image": {"width": 1200, "height": 630, "label": "Open Graph Image"},
    "favicon": {"width": 512, "height": 512, "label": "Favicon / App Icon"},
}

# --- Default-Farben (Fallback wenn kein Brand Book vorhanden) ---

_DEFAULT_BRAND_COLORS = {
    "bg_dark": "#1a1a2e",
    "bg_gradient_top": "#0f0c29",
    "bg_gradient_bottom": "#302b63",
    "text_light": "#ffffff",
    "accent": "#00e5a0",
    "social_top": "#667eea",
    "social_bottom": "#764ba2",
}

# --- Font Helper ---

_FONT_CACHE: dict[str, str] = {}

FONT_SEARCH_PATHS = [
    "C:/Windows/Fonts",
    "/usr/share/fonts/truetype",
    "/usr/share/fonts",
    "/System/Library/Fonts",
]

FONT_NAMES = {
    "regular": ["arial.ttf", "Arial.ttf", "DejaVuSans.ttf", "LiberationSans-Regular.ttf"],
    "bold": ["arialbd.ttf", "Arial Bold.ttf", "DejaVuSans-Bold.ttf", "LiberationSans-Bold.ttf"],
}


def _find_font(style: str = "regular") -> str:
    """Findet einen passenden Font auf dem System."""
    if style in _FONT_CACHE:
        return _FONT_CACHE[style]

    candidates = FONT_NAMES.get(style, FONT_NAMES["regular"])
    for search_dir in FONT_SEARCH_PATHS:
        if not os.path.isdir(search_dir):
            continue
        for name in candidates:
            path = os.path.join(search_dir, name)
            if os.path.isfile(path):
                _FONT_CACHE[style] = path
                return path

    # Fallback: Pillow default
    _FONT_CACHE[style] = ""
    return ""


def _get_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont | ImageFont.ImageFont:
    """Laedt einen Font in der gewuenschten Groesse."""
    style = "bold" if bold else "regular"
    path = _find_font(style)
    if path:
        return ImageFont.truetype(path, size)
    return ImageFont.load_default()


# --- Farb-Helfer ---

def _hex_to_rgb(hex_color: str) -> tuple[int, int, int]:
    """Konvertiert #RRGGBB zu (R, G, B) Tuple."""
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i:i+2], 16) for i in (0, 2, 4))


def _create_gradient(width: int, height: int, color_top: str, color_bottom: str) -> Image.Image:
    """Erzeugt einen vertikalen Farbverlauf."""
    top = _hex_to_rgb(color_top)
    bottom = _hex_to_rgb(color_bottom)
    img = Image.new("RGB", (width, height))
    pixels = img.load()
    for y in range(height):
        ratio = y / max(height - 1, 1)
        r = int(top[0] + (bottom[0] - top[0]) * ratio)
        g = int(top[1] + (bottom[1] - top[1]) * ratio)
        b = int(top[2] + (bottom[2] - top[2]) * ratio)
        for x in range(width):
            pixels[x, y] = (r, g, b)
    return img


def _wrap_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.FreeTypeFont | ImageFont.ImageFont,
    max_width: int,
) -> list[str]:
    """Bricht Text an Wortgrenzen um, damit er in max_width passt.

    Returns:
        Liste von Zeilen.
    """
    if not text:
        return [""]

    # Prüfe ob Text überhaupt umgebrochen werden muss
    bbox = draw.textbbox((0, 0), text, font=font)
    if (bbox[2] - bbox[0]) <= max_width:
        return [text]

    words = text.split()
    lines: list[str] = []
    current_line = ""

    for word in words:
        test_line = f"{current_line} {word}".strip() if current_line else word
        bbox = draw.textbbox((0, 0), test_line, font=font)
        if (bbox[2] - bbox[0]) <= max_width:
            current_line = test_line
        else:
            if current_line:
                lines.append(current_line)
            current_line = word

    if current_line:
        lines.append(current_line)

    return lines or [text]


def _draw_wrapped_text(
    draw: ImageDraw.ImageDraw,
    text: str,
    font: ImageFont.FreeTypeFont | ImageFont.ImageFont,
    canvas_width: int,
    canvas_height: int,
    fill: tuple[int, int, int],
    max_width_ratio: float = 0.85,
) -> None:
    """Zeichnet zentrierten, ggf. umgebrochenen Text auf ein Canvas."""
    max_width = int(canvas_width * max_width_ratio)
    lines = _wrap_text(draw, text, font, max_width)

    # Zeilenhöhe berechnen
    line_heights: list[int] = []
    line_widths: list[int] = []
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        line_widths.append(bbox[2] - bbox[0])
        line_heights.append(bbox[3] - bbox[1])

    line_spacing = int(max(line_heights) * 0.3) if line_heights else 0
    total_h = sum(line_heights) + line_spacing * (len(lines) - 1)
    start_y = (canvas_height - total_h) // 2

    y = start_y
    for i, line in enumerate(lines):
        x = (canvas_width - line_widths[i]) // 2
        draw.text((x, y), line, fill=fill, font=font)
        y += line_heights[i] + line_spacing


class MarketingTemplateEngine:
    """Erzeugt Marketing-Grafiken deterministisch mit Pillow."""

    def __init__(self, output_dir: Optional[str] = None) -> None:
        from factory.marketing.config import OUTPUT_PATH

        self.output_dir = output_dir or os.path.join(OUTPUT_PATH, "templates")
        os.makedirs(self.output_dir, exist_ok=True)
        self.brand_colors = self._load_brand_colors()
        logger.info("TemplateEngine initialized, output: %s", self.output_dir)

    def _load_brand_colors(self) -> dict:
        """Laedt Farben aus brand_book.json. Fallback auf Defaults."""
        try:
            from factory.marketing.config import BRAND_PATH
            json_path = os.path.join(BRAND_PATH, "brand_book", "brand_book.json")
            if os.path.exists(json_path):
                with open(json_path, "r", encoding="utf-8") as f:
                    data = json.load(f)
                colors = data.get("colors", {})
                result = {
                    "bg_dark": colors.get("background_dark", _DEFAULT_BRAND_COLORS["bg_dark"]),
                    "bg_gradient_top": colors.get("primary", _DEFAULT_BRAND_COLORS["bg_gradient_top"]),
                    "bg_gradient_bottom": colors.get("secondary", _DEFAULT_BRAND_COLORS["bg_gradient_bottom"]),
                    "text_light": colors.get("text_light", _DEFAULT_BRAND_COLORS["text_light"]),
                    "accent": colors.get("accent", _DEFAULT_BRAND_COLORS["accent"]),
                    "social_top": colors.get("primary_light", _DEFAULT_BRAND_COLORS["social_top"]),
                    "social_bottom": colors.get("accent_alt", _DEFAULT_BRAND_COLORS["social_bottom"]),
                }
                logger.info("Loaded brand colors from brand_book.json")
                return result
        except Exception as e:
            logger.warning("Could not load brand_book.json: %s", e)
        logger.info("Using default brand colors (no brand_book.json found)")
        return dict(_DEFAULT_BRAND_COLORS)

    def get_available_formats(self) -> dict:
        """Gibt alle verfuegbaren Formate zurueck."""
        return dict(FORMATS)

    def text_on_background(
        self,
        text: str,
        format_key: str,
        bg_color: Optional[str] = None,
        text_color: Optional[str] = None,
        filename: Optional[str] = None,
    ) -> str:
        """Text auf einfarbigem Hintergrund.

        Returns:
            Pfad zur erzeugten PNG-Datei.
        """
        bg_color = bg_color or self.brand_colors["bg_dark"]
        text_color = text_color or self.brand_colors["text_light"]
        fmt = FORMATS[format_key]
        w, h = fmt["width"], fmt["height"]

        img = Image.new("RGB", (w, h), _hex_to_rgb(bg_color))
        draw = ImageDraw.Draw(img)

        # Font-Groesse dynamisch: ca. 5% der Breite
        font_size = max(24, w // 20)
        font = _get_font(font_size, bold=True)

        _draw_wrapped_text(draw, text, font, w, h, _hex_to_rgb(text_color))

        fname = filename or f"text_bg_{format_key}.png"
        path = os.path.join(self.output_dir, fname)
        img.save(path, "PNG")
        logger.info("Created text_on_background: %s (%dx%d)", path, w, h)
        return path

    def gradient_text(
        self,
        text: str,
        format_key: str,
        color_top: Optional[str] = None,
        color_bottom: Optional[str] = None,
        text_color: Optional[str] = None,
        filename: Optional[str] = None,
    ) -> str:
        """Text auf Farbverlauf-Hintergrund.

        Returns:
            Pfad zur erzeugten PNG-Datei.
        """
        color_top = color_top or self.brand_colors["bg_gradient_top"]
        color_bottom = color_bottom or self.brand_colors["bg_gradient_bottom"]
        text_color = text_color or self.brand_colors["text_light"]
        fmt = FORMATS[format_key]
        w, h = fmt["width"], fmt["height"]

        img = _create_gradient(w, h, color_top, color_bottom)
        draw = ImageDraw.Draw(img)

        font_size = max(24, w // 20)
        font = _get_font(font_size, bold=True)

        _draw_wrapped_text(draw, text, font, w, h, _hex_to_rgb(text_color))

        fname = filename or f"gradient_{format_key}.png"
        path = os.path.join(self.output_dir, fname)
        img.save(path, "PNG")
        logger.info("Created gradient_text: %s (%dx%d)", path, w, h)
        return path

    def text_on_image(
        self,
        text: str,
        image_path: str,
        format_key: str,
        text_color: Optional[str] = None,
        position: str = "center",
        overlay_opacity: float = 0.5,
        filename: Optional[str] = None,
    ) -> str:
        """Text auf einem Bild mit optionalem Overlay.

        Args:
            position: "center", "top", "bottom"
            overlay_opacity: Abdunkelung 0.0-1.0

        Returns:
            Pfad zur erzeugten PNG-Datei.
        """
        text_color = text_color or self.brand_colors["text_light"]
        fmt = FORMATS[format_key]
        w, h = fmt["width"], fmt["height"]

        bg = Image.open(image_path).convert("RGB").resize((w, h), Image.LANCZOS)

        # Overlay
        if overlay_opacity > 0:
            overlay = Image.new("RGB", (w, h), (0, 0, 0))
            bg = Image.blend(bg, overlay, overlay_opacity)

        draw = ImageDraw.Draw(bg)
        font_size = max(24, w // 20)
        font = _get_font(font_size, bold=True)

        bbox = draw.textbbox((0, 0), text, font=font)
        tw = bbox[2] - bbox[0]
        th = bbox[3] - bbox[1]
        x = (w - tw) // 2

        if position == "top":
            y = h // 10
        elif position == "bottom":
            y = h - th - h // 10
        else:
            y = (h - th) // 2

        draw.text((x, y), text, fill=_hex_to_rgb(text_color), font=font)

        fname = filename or f"img_text_{format_key}.png"
        path = os.path.join(self.output_dir, fname)
        bg.save(path, "PNG")
        logger.info("Created text_on_image: %s (%dx%d)", path, w, h)
        return path

    def device_mockup(
        self,
        screenshot_path: str,
        device: str = "phone",
        bg_color: Optional[str] = None,
        filename: Optional[str] = None,
    ) -> str:
        """Platziert einen Screenshot in einem Device-Rahmen.

        Args:
            device: "phone" (1290x2796 Bereich) oder "tablet"

        Returns:
            Pfad zur erzeugten PNG-Datei.
        """
        bg_color = bg_color or self.brand_colors["bg_dark"]
        if device == "phone":
            canvas_w, canvas_h = 1600, 3200
            screen_x, screen_y = 155, 202
            screen_w, screen_h = 1290, 2796
        else:
            canvas_w, canvas_h = 2800, 2100
            screen_x, screen_y = 200, 150
            screen_w, screen_h = 2400, 1800

        canvas = Image.new("RGB", (canvas_w, canvas_h), _hex_to_rgb(bg_color))
        draw = ImageDraw.Draw(canvas)

        # Device-Rahmen zeichnen (abgerundetes Rechteck simuliert)
        border = 10
        frame_color = (60, 60, 60)
        draw.rectangle(
            [screen_x - border, screen_y - border,
             screen_x + screen_w + border, screen_y + screen_h + border],
            fill=frame_color,
        )

        # Screenshot einsetzen
        screenshot = Image.open(screenshot_path).convert("RGB")
        screenshot = screenshot.resize((screen_w, screen_h), Image.LANCZOS)
        canvas.paste(screenshot, (screen_x, screen_y))

        fname = filename or f"mockup_{device}.png"
        path = os.path.join(self.output_dir, fname)
        canvas.save(path, "PNG")
        logger.info("Created device_mockup: %s (%dx%d)", path, canvas_w, canvas_h)
        return path

    def social_post_template(
        self,
        headline: str,
        subtext: str,
        format_key: str = "social_square",
        color_top: Optional[str] = None,
        color_bottom: Optional[str] = None,
        text_color: Optional[str] = None,
        filename: Optional[str] = None,
    ) -> str:
        """Social Media Post mit Headline + Subtext.

        Returns:
            Pfad zur erzeugten PNG-Datei.
        """
        color_top = color_top or self.brand_colors["social_top"]
        color_bottom = color_bottom or self.brand_colors["social_bottom"]
        text_color = text_color or self.brand_colors["text_light"]
        fmt = FORMATS[format_key]
        w, h = fmt["width"], fmt["height"]

        img = _create_gradient(w, h, color_top, color_bottom)
        draw = ImageDraw.Draw(img)

        # Headline
        headline_size = max(32, w // 14)
        headline_font = _get_font(headline_size, bold=True)
        max_text_w = int(w * 0.85)
        h_lines = _wrap_text(draw, headline, headline_font, max_text_w)

        # Headline Gesamthoehe
        h_line_heights = []
        for line in h_lines:
            bbox = draw.textbbox((0, 0), line, font=headline_font)
            h_line_heights.append(bbox[3] - bbox[1])
        h_spacing = int(max(h_line_heights) * 0.3) if h_line_heights else 0
        h_total = sum(h_line_heights) + h_spacing * (len(h_lines) - 1)

        # Subtext
        sub_size = max(20, w // 28)
        sub_font = _get_font(sub_size, bold=False)
        s_lines = _wrap_text(draw, subtext, sub_font, max_text_w)

        s_line_heights = []
        for line in s_lines:
            bbox = draw.textbbox((0, 0), line, font=sub_font)
            s_line_heights.append(bbox[3] - bbox[1])
        s_spacing = int(max(s_line_heights) * 0.3) if s_line_heights else 0
        s_total = sum(s_line_heights) + s_spacing * (len(s_lines) - 1)

        total_h = h_total + 30 + s_total
        start_y = (h - total_h) // 2

        fill = _hex_to_rgb(text_color)

        # Headline Zeilen zeichnen
        y = start_y
        for i, line in enumerate(h_lines):
            bbox = draw.textbbox((0, 0), line, font=headline_font)
            lw = bbox[2] - bbox[0]
            draw.text(((w - lw) // 2, y), line, fill=fill, font=headline_font)
            y += h_line_heights[i] + h_spacing

        # Subtext Zeilen zeichnen
        y = start_y + h_total + 30
        for i, line in enumerate(s_lines):
            bbox = draw.textbbox((0, 0), line, font=sub_font)
            lw = bbox[2] - bbox[0]
            draw.text(((w - lw) // 2, y), line, fill=fill, font=sub_font)
            y += s_line_heights[i] + s_spacing

        fname = filename or f"social_post_{format_key}.png"
        path = os.path.join(self.output_dir, fname)
        img.save(path, "PNG")
        logger.info("Created social_post_template: %s (%dx%d)", path, w, h)
        return path

    def batch_create(
        self,
        text: str,
        format_keys: list[str],
        style: str = "gradient",
        **kwargs,
    ) -> dict[str, str]:
        """Erzeugt dasselbe Design in mehreren Formaten.

        Args:
            style: "solid", "gradient"

        Returns:
            Dict {format_key: file_path}
        """
        results = {}
        for fk in format_keys:
            if fk not in FORMATS:
                logger.warning("Unknown format: %s, skipping", fk)
                continue
            try:
                if style == "gradient":
                    path = self.gradient_text(text, fk, filename=f"batch_{fk}.png", **kwargs)
                else:
                    path = self.text_on_background(text, fk, filename=f"batch_{fk}.png", **kwargs)
                results[fk] = path
            except Exception as e:
                logger.error("batch_create failed for %s: %s", fk, e)
        logger.info("Batch created %d/%d formats", len(results), len(format_keys))
        return results

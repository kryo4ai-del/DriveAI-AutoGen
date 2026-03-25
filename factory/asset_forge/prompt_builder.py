"""Asset Prompt Builder — transforms AssetSpec into optimal generation prompts.

Takes an AssetSpec (with style_context, ki_warnings, prompt_hints) and produces
a complete prompt string + negative prompt + ServiceRequest ready for TheBrain Router.
No LLM calls — fully deterministic.
"""

import logging
import re
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)

MAX_PROMPT_CHARS = 1000
MAX_NEGATIVE_CHARS = 500


@dataclass
class AssetPrompt:
    """Complete prompt package ready for generation."""
    asset_id: str
    asset_name: str
    prompt_text: str
    negative_prompt: str
    style_reference: str
    technical_specs: dict
    estimated_cost: float
    service_request: dict

    def summary(self) -> str:
        return (
            f"{self.asset_id} ({self.asset_name}): "
            f"{len(self.prompt_text)} chars prompt, "
            f"~${self.estimated_cost:.3f}, "
            f"{self.technical_specs.get('width', '?')}x{self.technical_specs.get('height', '?')}"
        )


class AssetPromptBuilder:

    TEMPLATE_DIR = Path(__file__).parent / "templates"

    TYPE_TO_TEMPLATE = {
        "sprite": "sprite_prompt.txt",
        "icon": "icon_prompt.txt",
        "background": "background_prompt.txt",
        "illustration": "illustration_prompt.txt",
        "store_art": "store_art_prompt.txt",
        "ui_element": "icon_prompt.txt",
        "animation": "sprite_prompt.txt",
        "marketing": "store_art_prompt.txt",
    }

    DEFAULT_NEGATIVES = {
        "sprite": "background, border, frame, text, watermark, signature, blurry, low quality",
        "icon": "complex details, text, photograph, realistic, blurry, multiple objects",
        "background": "text, UI elements, buttons, icons, characters in foreground, watermark",
        "illustration": "text, watermark, border, frame, low quality, blurry",
        "store_art": "low quality, blurry, amateur, text errors, spelling mistakes",
        "ui_element": "background, complex scene, text, watermark, blurry",
        "animation": "background, border, frame, text, watermark, blurry",
        "marketing": "low quality, blurry, amateur, watermark",
    }

    TYPE_CAPABILITIES = {
        "sprite": ["text_to_image", "png_output", "transparent_bg"],
        "icon": ["text_to_image", "png_output", "transparent_bg"],
        "background": ["text_to_image", "png_output"],
        "illustration": ["text_to_image", "png_output"],
        "store_art": ["text_to_image", "png_output"],
        "ui_element": ["text_to_image", "png_output", "transparent_bg"],
        "animation": ["text_to_image", "png_output", "transparent_bg"],
        "marketing": ["text_to_image", "png_output"],
    }

    DEFAULT_SIZES = {
        "icon": (1024, 1024),
        "sprite": (512, 512),
        "background": (1920, 1080),
        "illustration": (1024, 1024),
        "store_art": (1242, 2688),
        "ui_element": (256, 256),
        "animation": (512, 512),
        "marketing": (1242, 2688),
    }

    def __init__(self, templates_dir: str = None):
        if templates_dir:
            self.TEMPLATE_DIR = Path(templates_dir)
        self._templates = self._load_templates()

    def _load_templates(self) -> dict[str, str]:
        templates = {}
        fallback = "{description}. {style_description}. {color_context} {additional_hints} Technical: {width}x{height}px."
        for name, filename in self.TYPE_TO_TEMPLATE.items():
            path = self.TEMPLATE_DIR / filename
            if path.exists():
                templates[name] = path.read_text(encoding="utf-8")
            else:
                logger.warning("Template missing: %s, using fallback", filename)
                templates[name] = fallback
        return templates

    # ------------------------------------------------------------------
    # Single prompt
    # ------------------------------------------------------------------

    def build_prompt(self, spec, budget_limit: float = 0.10) -> AssetPrompt:
        atype = spec.asset_type if spec.asset_type in self._templates else "illustration"
        template = self._templates.get(atype, self._templates.get("illustration", ""))

        style_desc = self._build_style_description(spec.style_context)
        color_ctx = self._build_color_context(spec.style_context)
        hints = " ".join(spec.prompt_hints[:5]) if spec.prompt_hints else ""
        width, height = self._get_size(spec)

        prompt_text = template.format(
            description=spec.description or spec.name,
            style_description=style_desc,
            color_context=color_ctx,
            additional_hints=hints,
            width=width,
            height=height,
        )
        prompt_text = re.sub(r"\n{3,}", "\n\n", prompt_text).strip()
        prompt_text = prompt_text[:MAX_PROMPT_CHARS]

        neg = self._build_negative_prompt(spec, self.DEFAULT_NEGATIVES.get(atype, ""))
        transparent = self._needs_transparency(spec)
        cost = self._estimate_cost(width, height)

        sr = self._build_service_request(prompt_text, neg, spec, width, height, budget_limit)

        return AssetPrompt(
            asset_id=spec.asset_id,
            asset_name=spec.name,
            prompt_text=prompt_text,
            negative_prompt=neg,
            style_reference=style_desc[:100],
            technical_specs={"width": width, "height": height, "format": spec.format or "png", "transparent": transparent},
            estimated_cost=cost,
            service_request=sr,
        )

    # ------------------------------------------------------------------
    # Style helpers
    # ------------------------------------------------------------------

    def _build_style_description(self, ctx: dict) -> str:
        if not ctx:
            return "Clean modern digital art style"
        parts = []
        ill = ctx.get("illustration_style", "")
        if ill:
            parts.append(ill[:80])
        theme = ctx.get("theme", "")
        if theme:
            parts.append(f"{theme} theme")
        return ". ".join(parts)[:150] if parts else "Clean modern digital art style"

    def _build_color_context(self, ctx: dict) -> str:
        if not ctx:
            return ""
        parts = []
        palette = ctx.get("color_palette", [])
        if isinstance(palette, list):
            colors = [f"{c.get('name', '')}: {c.get('hex', '')}" for c in palette[:4] if isinstance(c, dict)]
            if colors:
                parts.append("Colors: " + ", ".join(colors))
        bg = ctx.get("background_colors", [])
        if bg and isinstance(bg, list):
            parts.append(f"Backgrounds: {', '.join(bg[:2])}")
        accent = ctx.get("accent_colors", [])
        if accent and isinstance(accent, list):
            parts.append(f"Accents: {', '.join(accent[:2])}")
        return ". ".join(parts)[:200]

    def _build_negative_prompt(self, spec, default_negatives: str) -> str:
        parts = [default_negatives]

        for w in (spec.ki_warnings or [])[:3]:
            neg = self._convert_warning_to_negative(w)
            if neg:
                parts.append(neg)

        anti = (spec.style_context or {}).get("anti_rules", [])
        if isinstance(anti, list):
            for rule in anti[:3]:
                if isinstance(rule, str) and len(rule) < 80:
                    parts.append(rule)

        combined = ", ".join(p for p in parts if p)
        # Deduplicate tokens
        tokens = []
        seen = set()
        for tok in combined.split(","):
            tok = tok.strip().lower()
            if tok and tok not in seen:
                seen.add(tok)
                tokens.append(tok)
        return ", ".join(tokens)[:MAX_NEGATIVE_CHARS]

    def _convert_warning_to_negative(self, warning_text: str) -> str:
        if not warning_text:
            return ""
        # Extract key failure descriptions
        keywords = []
        patterns = [
            (r"farbige?\s+(?:Rechteck|Rectangle|Shape)", "colored rectangle shapes"),
            (r"Farbverlauf|gradient", "generic gradient"),
            (r"generisch|generic", "generic design"),
            (r"Platzhalter|placeholder", "placeholder"),
            (r"Text\s+statt|text instead", "text instead of image"),
            (r"System-?(?:font|farb)|system (?:font|color)", "system default styling"),
            (r"Candy.?Crush", "candy crush style"),
            (r"Standard|default", "default generic style"),
        ]
        for pat, neg in patterns:
            if re.search(pat, warning_text, re.IGNORECASE):
                keywords.append(neg)
        return ", ".join(keywords) if keywords else ""

    # ------------------------------------------------------------------
    # Technical specs
    # ------------------------------------------------------------------

    def _get_size(self, spec) -> tuple[int, int]:
        if spec.sizes:
            s = spec.sizes[0]
            w = s.get("width") or 0
            h = s.get("height") or 0
            try:
                w, h = int(w), int(h)
                if w > 0 and h > 0:
                    return (w, h)
            except (TypeError, ValueError):
                pass
        return self.DEFAULT_SIZES.get(spec.asset_type, (1024, 1024))

    def _needs_transparency(self, spec) -> bool:
        return spec.asset_type in ("sprite", "icon", "ui_element", "animation")

    def _build_service_request(self, prompt_text, negative_prompt, spec,
                                width, height, budget_limit) -> dict:
        caps = self.TYPE_CAPABILITIES.get(spec.asset_type, ["text_to_image", "png_output"])
        return {
            "category": "image",
            "required_capabilities": caps,
            "specs": {
                "prompt": prompt_text,
                "negative_prompt": negative_prompt,
                "width": width,
                "height": height,
                "size": f"{width}x{height}",
                "format": spec.format or "png",
            },
            "budget_limit": budget_limit,
            "preferred_service": None,
            "quality_minimum": 3.0,
        }

    def _estimate_cost(self, width: int, height: int) -> float:
        pixels = width * height
        if pixels <= 512 * 512:
            return 0.02
        if pixels <= 1024 * 1024:
            return 0.04
        return 0.06

    # ------------------------------------------------------------------
    # Batch
    # ------------------------------------------------------------------

    def build_all_prompts(self, manifest, budget_limit: float = 0.10,
                          only_ai_generatable: bool = True) -> list[AssetPrompt]:
        prompts = []
        for spec in manifest.specs:
            if only_ai_generatable and spec.source_type not in ("ai_generated", "ai_plus_custom"):
                continue
            prompts.append(self.build_prompt(spec, budget_limit))

        priority_order = {"launch_critical": 0, "high": 1, "medium": 2, "low": 3}
        prompts.sort(key=lambda p: priority_order.get(
            next((s.priority for s in manifest.specs if s.asset_id == p.asset_id), "low"), 3
        ))
        return prompts

    def dry_run(self, manifest, budget_limit: float = 0.10) -> str:
        prompts = self.build_all_prompts(manifest, budget_limit)
        lines = [f"Asset Prompt Builder — Dry Run ({len(prompts)} assets)\n"]
        for p in prompts:
            lines.append("-" * 50)
            lines.append(f"{p.asset_id} {p.asset_name} ({p.technical_specs.get('format','png')}, "
                         f"{'transparent' if p.technical_specs.get('transparent') else 'solid'})")
            lines.append(f"  Prompt: {p.prompt_text[:200]}...")
            lines.append(f"  Negative: {p.negative_prompt[:100]}...")
            lines.append(f"  Size: {p.technical_specs['width']}x{p.technical_specs['height']}")
            lines.append(f"  Est. Cost: ${p.estimated_cost:.3f}")
        lines.append("-" * 50)
        total = sum(p.estimated_cost for p in prompts)
        lines.append(f"\nTotal: {len(prompts)} assets, estimated cost: ${total:.2f}")
        return "\n".join(lines)

    def estimate_total_cost(self, manifest) -> float:
        total = 0.0
        for spec in manifest.specs:
            if spec.source_type in ("ai_generated", "ai_plus_custom"):
                w, h = self._get_size(spec)
                total += self._estimate_cost(w, h)
        return total

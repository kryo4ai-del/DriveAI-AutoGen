"""Asset Spec Extractor — LLM-based extraction of structured asset specs from Roadbook sections.

Takes ExtractedSections from pdf_reader.py, runs 2-3 targeted LLM calls,
produces machine-readable AssetSpec objects in an AssetManifest.
"""

import json
import logging
import re
from dataclasses import dataclass, field, asdict
from datetime import date
from pathlib import Path
from typing import Optional

from factory.asset_forge.config import AssetForgeConfig
from config.model_router import get_fallback_model
from factory.asset_forge.pdf_reader import PDFReader, ExtractedSections

logger = logging.getLogger(__name__)

VALID_ASSET_TYPES = {"icon", "sprite", "background", "illustration", "ui_element", "store_art", "animation", "marketing"}
VALID_PRIORITIES = {"launch_critical", "high", "medium", "low"}
VALID_FORMATS = {"png", "svg", "sprite_sheet", "lottie", "mp3", "wav"}
VALID_SOURCES = {"ai_generated", "custom_design", "ai_plus_custom", "free_open_source", "native"}


@dataclass
class AssetSpec:
    asset_id: str
    name: str
    description: str
    screens: list[str] = field(default_factory=list)
    asset_type: str = "illustration"
    format: str = "png"
    sizes: list[dict] = field(default_factory=list)
    platform_variants: list[str] = field(default_factory=lambda: ["ios", "android"])
    dark_mode_variant: bool = False
    priority: str = "medium"
    static_or_dynamic: str = "static"
    source_type: str = "ai_generated"
    style_context: dict = field(default_factory=dict)
    ki_warnings: list[str] = field(default_factory=list)
    prompt_hints: list[str] = field(default_factory=list)


@dataclass
class AssetManifest:
    project_name: str
    extraction_date: str
    total_assets: int = 0
    by_priority: dict = field(default_factory=dict)
    by_type: dict = field(default_factory=dict)
    by_platform: dict = field(default_factory=dict)
    by_source: dict = field(default_factory=dict)
    style_context: dict = field(default_factory=dict)
    specs: list[AssetSpec] = field(default_factory=list)

    def to_json(self) -> str:
        return json.dumps(asdict(self), indent=2, ensure_ascii=False)

    @classmethod
    def from_json(cls, json_str: str) -> "AssetManifest":
        data = json.loads(json_str)
        specs = [AssetSpec(**s) for s in data.pop("specs", [])]
        m = cls(**data)
        m.specs = specs
        return m

    def get_by_priority(self, priority: str) -> list[AssetSpec]:
        return [s for s in self.specs if s.priority == priority]

    def get_by_type(self, asset_type: str) -> list[AssetSpec]:
        return [s for s in self.specs if s.asset_type == asset_type]

    def get_ai_generatable(self) -> list[AssetSpec]:
        return [s for s in self.specs if s.source_type in ("ai_generated", "ai_plus_custom")]

    def summary(self) -> str:
        lines = [
            f"Asset Manifest: {self.project_name}",
            f"Date: {self.extraction_date}",
            f"Total: {self.total_assets} assets",
            f"By priority: {self.by_priority}",
            f"By type: {self.by_type}",
            f"By source: {self.by_source}",
            f"AI-generatable: {len(self.get_ai_generatable())}",
            f"Style: {list(self.style_context.keys()) if self.style_context else 'none'}",
        ]
        return "\n".join(lines)


class AssetSpecExtractor:

    def __init__(self, config: AssetForgeConfig = None):
        self._config = config or AssetForgeConfig()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def extract(self, roadbook_dir: str, project_name: str) -> AssetManifest:
        reader = PDFReader()
        docs = reader.read_roadbook_dir(roadbook_dir)
        sections = reader.extract_sections(docs)
        return self.extract_from_sections(sections, project_name)

    def extract_from_sections(self, sections: ExtractedSections, project_name: str) -> AssetManifest:
        # Call 1: assets from asset_table + screen_architecture (combined for better coverage)
        raw_assets = []
        asset_context = sections.asset_table or ""
        if sections.screen_architecture:
            asset_context += "\n\n--- Additional Asset References from Screen Architecture ---\n"
            asset_context += sections.screen_architecture
        if asset_context.strip():
            raw_assets = self._extract_assets_via_llm(asset_context)
            logger.info("LLM Call 1: %d assets extracted", len(raw_assets))
        else:
            logger.warning("No asset context — skipping LLM Call 1")

        # Call 2: warnings from ki_warnings
        raw_warnings = []
        if sections.ki_warnings:
            raw_warnings = self._extract_warnings_via_llm(sections.ki_warnings)
            logger.info("LLM Call 2: %d warnings extracted", len(raw_warnings))

        # Call 3: style context
        style_text = "\n\n".join(filter(None, [
            sections.style_guide_cd,
            sections.color_palette,
            sections.illustration_style,
            sections.anti_rules,
        ]))
        style = {}
        if style_text.strip():
            style = self._extract_style_via_llm(style_text)
            logger.info("LLM Call 3: style context with %d keys", len(style))

        # Merge
        if raw_warnings:
            raw_assets = self._merge_warnings_to_assets(raw_assets, raw_warnings)
        if style:
            raw_assets = self._apply_style_context(raw_assets, style)

        specs = self._apply_defaults(raw_assets)
        return self._build_manifest(specs, project_name, style)

    # ------------------------------------------------------------------
    # LLM Calls
    # ------------------------------------------------------------------

    def _extract_assets_via_llm(self, asset_context: str) -> list[dict]:
        """Extract assets. Split into chunks if input > 8000 chars."""
        system = (
            "You extract visual asset specifications from CD Roadbook text. "
            "Extract EVERY unique asset mentioned (by ID like A001 or by description). "
            "Return ONLY a JSON array. Each element: "
            '{"asset_id":"A001","name":"...","description":"...","screens":["S001"],'
            '"asset_type":"icon|sprite|background|illustration|ui_element|store_art|animation|marketing",'
            '"format":"png|svg|sprite_sheet","sizes":[{"width":1024,"height":1024,"label":"base"}],'
            '"platform_variants":["ios","android"],"dark_mode_variant":false,'
            '"priority":"launch_critical|high|medium|low","static_or_dynamic":"static|animated",'
            '"source_type":"ai_generated|custom_design|ai_plus_custom|free_open_source",'
            '"prompt_hints":["..."]}. '
            "Extract EVERY asset. Do not skip any."
        )

        if len(asset_context) <= 8000:
            user = f"Extract ALL assets:\n---\n{asset_context}\n---"
            resp = self._call_llm(system, user, max_tokens=8000)
            return self._parse_json_response(resp) if resp else []

        # Split into chunks of ~6000 chars at paragraph boundaries
        chunks = []
        remaining = asset_context
        while remaining:
            if len(remaining) <= 6000:
                chunks.append(remaining)
                break
            split_at = remaining.rfind("\n", 0, 6000)
            if split_at <= 0:
                split_at = 6000
            chunks.append(remaining[:split_at])
            remaining = remaining[split_at:]

        logger.info("Split asset context into %d chunks", len(chunks))
        all_assets = []
        seen_ids = set()
        for i, chunk in enumerate(chunks):
            user = f"Extract ALL assets from chunk {i+1}/{len(chunks)}:\n---\n{chunk}\n---"
            resp = self._call_llm(system, user, max_tokens=8000)
            parsed = self._parse_json_response(resp) if resp else []
            for a in parsed:
                aid = a.get("asset_id", "")
                if aid and aid not in seen_ids:
                    seen_ids.add(aid)
                    all_assets.append(a)
                elif not aid:
                    all_assets.append(a)
            logger.info("  Chunk %d: %d assets (total unique: %d)", i+1, len(parsed), len(all_assets))

        return all_assets

    def _extract_warnings_via_llm(self, ki_warnings_text: str) -> list[dict]:
        """Extract KI warnings. Split into 2 calls if text > 8000 chars."""
        if len(ki_warnings_text) <= 8000:
            return self._extract_warnings_single_call(ki_warnings_text)

        midpoint = len(ki_warnings_text) // 2
        split_pos = midpoint
        for pat in [r'\n\s*\*?\*?W1[4-6]', r'\n\s*\*?\*?W1[0-9]', r'\n\s*\|\s*W?\d+']:
            matches = list(re.finditer(pat, ki_warnings_text))
            if matches:
                split_pos = min(matches, key=lambda m: abs(m.start() - midpoint)).start()
                break

        chunk1 = ki_warnings_text[:split_pos]
        chunk2 = ki_warnings_text[split_pos:]
        logger.info("Split KI-warnings: %d + %d chars", len(chunk1), len(chunk2))

        w1 = self._extract_warnings_single_call(chunk1)
        w2 = self._extract_warnings_single_call(chunk2)

        seen = set()
        unique = []
        for w in w1 + w2:
            wid = w.get("warning_id", "")
            if wid and wid not in seen:
                seen.add(wid)
                unique.append(w)
            elif not wid:
                unique.append(w)
        return unique

    def _extract_warnings_single_call(self, text: str) -> list[dict]:
        system = (
            "You extract KI production warnings from a CD Roadbook. "
            "Return ONLY a JSON array. Each element: "
            '{"warning_id":"W01","screens":["S006"],"asset_ids":["A003"],'
            '"what_goes_wrong":"...","correct_approach":"...","prompt_instruction":"..."}. '
            "Extract ALL warnings from the provided text."
        )
        user = f"Extract ALL warnings:\n---\n{text}\n---"
        resp = self._call_llm(system, user, max_tokens=4096)
        return self._parse_json_response(resp) if resp else []

    def _extract_style_via_llm(self, style_text: str) -> dict:
        system = (
            "You extract design style information from a Design Vision document. "
            "Return ONLY a JSON object: "
            '{"color_palette":[{"name":"...","hex":"#...","usage":"..."}],'
            '"illustration_style":"...","theme":"dark|light|mixed",'
            '"anti_rules":["..."],"background_colors":["#..."],'
            '"accent_colors":["#..."],"typography_style":"..."}.'
        )
        user = f"Extract style info:\n---\n{style_text[:6000]}\n---"
        resp = self._call_llm(system, user, model="haiku", max_tokens=2048)
        result = self._parse_json_response(resp) if resp else {}
        return result if isinstance(result, dict) else {}

    # ------------------------------------------------------------------
    # Merge + Defaults
    # ------------------------------------------------------------------

    def _merge_warnings_to_assets(self, assets: list[dict], warnings: list[dict]) -> list[dict]:
        for asset in assets:
            aid = asset.get("asset_id", "")
            a_screens = set(asset.get("screens", []))
            matched_warnings = []
            matched_hints = []
            for w in warnings:
                w_screens = set(w.get("screens", []))
                w_assets = set(w.get("asset_ids", []))
                if aid in w_assets or a_screens & w_screens:
                    matched_warnings.append(w.get("what_goes_wrong", ""))
                    hint = w.get("prompt_instruction", "")
                    if hint:
                        matched_hints.append(hint)
            asset["ki_warnings"] = matched_warnings
            asset.setdefault("prompt_hints", []).extend(matched_hints)
        return assets

    def _apply_style_context(self, assets: list[dict], style: dict) -> list[dict]:
        for asset in assets:
            asset["style_context"] = style
        return assets

    def _apply_defaults(self, assets: list[dict]) -> list[AssetSpec]:
        specs = []
        for i, a in enumerate(assets):
            aid = a.get("asset_id", f"A{i+1:03d}")
            atype = a.get("asset_type", "illustration")
            if atype not in VALID_ASSET_TYPES:
                atype = "illustration"

            sizes = a.get("sizes", [])
            if not sizes:
                default_size = self._config.default_sizes.get(atype, "1024x1024")
                w, h = default_size.split("x")
                sizes = [{"width": int(w), "height": int(h), "label": "base"}]

            priority = a.get("priority", "medium")
            if priority not in VALID_PRIORITIES:
                priority = "medium"

            fmt = a.get("format", "png")
            if fmt not in VALID_FORMATS:
                fmt = "png"

            source = a.get("source_type", "ai_generated")
            if source not in VALID_SOURCES:
                source = "ai_generated"

            specs.append(AssetSpec(
                asset_id=aid,
                name=a.get("name", f"Asset {aid}"),
                description=a.get("description", ""),
                screens=a.get("screens", []),
                asset_type=atype,
                format=fmt,
                sizes=sizes,
                platform_variants=a.get("platform_variants", ["ios", "android"]),
                dark_mode_variant=a.get("dark_mode_variant", False),
                priority=priority,
                static_or_dynamic=a.get("static_or_dynamic", "static"),
                source_type=source,
                style_context=a.get("style_context", {}),
                ki_warnings=a.get("ki_warnings", []),
                prompt_hints=a.get("prompt_hints", []),
            ))
        return specs

    def _build_manifest(self, specs: list[AssetSpec], project_name: str, style: dict) -> AssetManifest:
        by_priority: dict[str, int] = {}
        by_type: dict[str, int] = {}
        by_platform: dict[str, int] = {}
        by_source: dict[str, int] = {}
        for s in specs:
            by_priority[s.priority] = by_priority.get(s.priority, 0) + 1
            by_type[s.asset_type] = by_type.get(s.asset_type, 0) + 1
            by_source[s.source_type] = by_source.get(s.source_type, 0) + 1
            for p in s.platform_variants:
                by_platform[p] = by_platform.get(p, 0) + 1
        return AssetManifest(
            project_name=project_name,
            extraction_date=date.today().isoformat(),
            total_assets=len(specs),
            by_priority=by_priority,
            by_type=by_type,
            by_platform=by_platform,
            by_source=by_source,
            style_context=style,
            specs=specs,
        )

    # ------------------------------------------------------------------
    # LLM Helper
    # ------------------------------------------------------------------

    def _call_llm(self, system_prompt: str, user_prompt: str,
                  model: str = "sonnet", max_tokens: int = 4096) -> str:
        # Try TheBrain first
        try:
            from factory.brain.model_provider import get_model, get_router
            profile = "dev" if model == "haiku" else "standard"
            selection = get_model(profile=profile, expected_output_tokens=max_tokens)
            router = get_router()
            messages = [
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt},
            ]
            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=messages,
                max_tokens=max_tokens,
            )
            if response.error:
                raise RuntimeError(response.error)
            cost_str = f" (${response.cost_usd:.4f})" if response.cost_usd else ""
            logger.info("[AssetExtractor] %s%s", selection["model"], cost_str)
            return response.content
        except Exception as e:
            logger.warning("TheBrain failed (%s), trying Anthropic fallback", e)

        # Anthropic fallback
        try:
            import anthropic
            client = anthropic.Anthropic()
            model_id = get_fallback_model("dev") if model == "haiku" else get_fallback_model()
            resp = client.messages.create(
                model=model_id,
                max_tokens=max_tokens,
                system=system_prompt,
                messages=[{"role": "user", "content": user_prompt}],
            )
            return resp.content[0].text
        except Exception as e:
            logger.error("Anthropic fallback failed: %s", e)
            return ""

    def _parse_json_response(self, response: str):
        if not response:
            return []
        text = response.strip()

        # Strip ALL markdown fences (even with leading whitespace/newlines)
        text = re.sub(r"```(?:json)?\s*\n", "", text)
        text = re.sub(r"\n\s*```", "", text)
        text = text.strip()

        # Try direct parse
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass

        # Try removing trailing commas
        cleaned = re.sub(r",\s*([}\]])", r"\1", text)
        try:
            return json.loads(cleaned)
        except json.JSONDecodeError:
            pass

        # Find JSON array or object boundaries
        for opener, closer in [("[", "]"), ("{", "}")]:
            start = cleaned.find(opener)
            end = cleaned.rfind(closer)
            if start >= 0 and end > start:
                try:
                    return json.loads(cleaned[start:end + 1])
                except json.JSONDecodeError:
                    # Try with trailing comma fix on the substring too
                    sub = cleaned[start:end + 1]
                    sub = re.sub(r",\s*([}\]])", r"\1", sub)
                    try:
                        return json.loads(sub)
                    except json.JSONDecodeError:
                        pass

        logger.warning("Failed to parse JSON from LLM response (%d chars)", len(text))
        return []

    # ------------------------------------------------------------------
    # Persistence
    # ------------------------------------------------------------------

    def save_manifest(self, manifest: AssetManifest, output_path: str):
        Path(output_path).write_text(manifest.to_json(), encoding="utf-8")
        logger.info("Manifest saved: %s (%d assets)", output_path, manifest.total_assets)

    def load_manifest(self, manifest_path: str) -> AssetManifest:
        text = Path(manifest_path).read_text(encoding="utf-8")
        return AssetManifest.from_json(text)

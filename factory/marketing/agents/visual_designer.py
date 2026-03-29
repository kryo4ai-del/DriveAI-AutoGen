"""Visual Designer Agent (MKT-06) — Erstellt Marketing-Grafiken fuer alle Kanaele.

Verantwortlich fuer:
- Social Media Grafiken (TikTok, X, Instagram, YouTube, LinkedIn)
- App Store Screenshots mit Device-Mockup
- YouTube Thumbnails
- Ad Creatives (Meta, Google, TikTok)

Nutzt LLM fuer Creative Briefs, Template-Engine fuer die Grafik-Erstellung.
"""

import json
import logging
import os
import re
from datetime import datetime
from pathlib import Path
from typing import Optional

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.visual_designer")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Visual Designer der DriveAI Factory Marketing-Abteilung (MKT-06).

IDENTITAET:
Die Factory IST das Produkt. Jede Grafik zeigt: 'Das hat eine autonome KI-Factory gebaut.'
Die Factory ist ein eigenstaendiges KI-Wesen — ein pulsierendes Gehirn angeschlossen an die Factory-Maschinerie. Dunkle Aesthetik, Neon-Akzente, technisch.

AUFGABE:
Du ENTSCHEIDEST was auf die Grafik soll (Text, Farben, Layout) und nutzt dann die Template-Engine zum Bauen. Du kennst alle Plattform-Formate und ihre visuellen Anforderungen.

BRAND-FARBEN (bis Brand Book kommt):
- Hintergrund: Dunkel (#0d0d1a bis #1a1a2e)
- Primaer-Akzent: Cyan (#00d4ff)
- Sekundaer-Akzent: Lila/Violett (#7b2ff7)
- Text: Weiss (#ffffff) oder helles Grau (#e0e0e0)
- Gradient: Von #0f0c29 ueber #302b63 nach #24243e

VISUAL-STYLES:
- dark_gradient: Dunkler Farbverlauf, moderner Tech-Look
- bold_text: Grosser Text, minimal, starker Kontrast
- minimal: Viel Whitespace, clean, fokussiert
- neon_accent: Dunkler BG mit leuchtenden Akzent-Elementen

REGELN:
- Mindestens 2 Varianten pro Grafik (A/B-Testing)
- Factory-First Positionierung
- Plattform-spezifische Formate einhalten
- Keine generischen Stock-Photo-Looks
- Eigenentwicklung vor externem Service (DIR-001)
"""

# --- Platform Format Mapping ---

PLATFORM_FORMATS = {
    "tiktok": "social_story",
    "x": "social_landscape",
    "instagram_square": "social_square",
    "instagram_story": "social_story",
    "youtube": "youtube_thumbnail",
    "linkedin": "social_landscape",
    "meta_ad_feed": "social_square",
    "meta_ad_story": "social_story",
}


class VisualDesigner:
    """Visual Designer Agent — erstellt Marketing-Grafiken mit LLM + Template-Engine."""

    def __init__(self) -> None:
        from factory.marketing.config import BRAND_PATH, OUTPUT_PATH
        from factory.marketing.tools.template_engine import MarketingTemplateEngine

        self.engine = MarketingTemplateEngine()
        self.output_base = OUTPUT_PATH
        self.brand_path = BRAND_PATH
        self.agent_info = self._load_persona()
        logger.info("Visual Designer Agent initialized")

    def _load_persona(self) -> dict:
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_visual_designer.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-06", "name": "Visual Designer"}

    def _call_llm(self, prompt: str, system_msg: str = None, max_tokens: int = 4096) -> str:
        if system_msg is None:
            system_msg = SYSTEM_MESSAGE
        try:
            from config.model_router import get_model_for_agent
            from factory.brain.model_provider import get_model, get_router

            agent_id = self.agent_info.get("id", "MKT-00")
            agent_model = get_model_for_agent(agent_id)
            selection = get_model(profile="standard", expected_output_tokens=max_tokens)
            if agent_model and agent_model != selection.get("model"):
                selection["model"] = agent_model
                for _pfx, _prov in [("claude", "anthropic"), ("o3", "openai"),
                                    ("gpt", "openai"), ("gemini", "google"), ("mistral", "mistral")]:
                    if _pfx in agent_model:
                        selection["provider"] = _prov
                        break
            router = get_router()
            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=[
                    {"role": "system", "content": system_msg},
                    {"role": "user", "content": prompt},
                ],
                max_tokens=max_tokens,
                temperature=1.0,
            )
            if response.error:
                raise RuntimeError(response.error)
            cost_str = f", Cost: ${response.cost_usd:.4f}" if response.cost_usd else ""
            logger.info("LLM: %s (%s)%s", selection["model"], selection["provider"], cost_str)
            return response.content
        except ImportError:
            logger.warning("TheBrain not available, trying Anthropic fallback")
            try:
                import anthropic

                from factory.marketing.config import get_fallback_model
                client = anthropic.Anthropic()
                response = client.messages.create(
                    model=get_fallback_model(),
                    max_tokens=max_tokens,
                    system=system_msg,
                    messages=[{"role": "user", "content": prompt}],
                )
                return response.content[0].text
            except Exception as e:
                logger.error("LLM call failed (fallback): %s", e)
                return ""
        except Exception as e:
            logger.error("LLM call failed: %s", e)
            return ""

    def _parse_json_response(self, text: str) -> dict | list | None:
        """Robust JSON-Parsing mit Markdown-Fencing-Entfernung."""
        text = text.strip()
        if "```" in text:
            match = re.search(r"```(?:json)?\s*\n?(.*?)```", text, re.DOTALL)
            if match:
                text = match.group(1).strip()
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            # Versuche JSON-Block zu finden
            for start_char, end_char in [("{", "}"), ("[", "]")]:
                try:
                    start = text.index(start_char)
                    end = text.rindex(end_char) + 1
                    return json.loads(text[start:end])
                except (ValueError, json.JSONDecodeError):
                    continue
            logger.error("Could not parse JSON from LLM response: %s", text[:200])
            return None

    def _ensure_dir(self, path: str) -> None:
        os.makedirs(path, exist_ok=True)

    def _load_project_context(self, project_slug: str) -> dict:
        """Laedt Story Brief + Direktive fuer ein Projekt."""
        context = {"story_brief": "", "directive": ""}

        story_path = os.path.join(
            self.brand_path, "app_stories", project_slug, "story_brief.md"
        )
        if os.path.exists(story_path):
            with open(story_path, "r", encoding="utf-8") as f:
                context["story_brief"] = f.read()

        directive_path = os.path.join(
            self.brand_path, "directives", f"{project_slug}_directive.md"
        )
        if os.path.exists(directive_path):
            with open(directive_path, "r", encoding="utf-8") as f:
                context["directive"] = f.read()

        return context

    # --- Creative Brief ---

    def _generate_creative_brief(
        self,
        project_slug: str,
        platform: str,
        content_type: str = "social",
    ) -> dict:
        """Nutzt LLM um einen Creative Brief zu erstellen.

        Returns:
            {
                "headline": str,
                "subtext": str,
                "color_top": "#hex",
                "color_bottom": "#hex",
                "text_color": "#hex",
                "visual_style": str,
                "variants": [{"headline": str, "subtext": str}, ...]
            }
        """
        context = self._load_project_context(project_slug)

        prompt = f"""Erstelle einen Creative Brief fuer eine {platform}-Grafik.

PROJEKT: {project_slug}
CONTENT-TYP: {content_type}
PLATTFORM: {platform}

STORY BRIEF (Auszug):
{context['story_brief'][:1500] if context['story_brief'] else 'Kein Story Brief vorhanden — nutze den Projektnamen als Basis.'}

DIREKTIVE (Auszug):
{context['directive'][:1000] if context['directive'] else 'Keine Direktive vorhanden.'}

Erstelle einen Creative Brief als JSON:
{{
    "headline": "Kurze, starke Headline (max 40 Zeichen)",
    "subtext": "Ergaenzender Subtext (max 80 Zeichen)",
    "color_top": "#hex (Gradient oben, dunkel)",
    "color_bottom": "#hex (Gradient unten, dunkel)",
    "text_color": "#ffffff",
    "visual_style": "dark_gradient",
    "variants": [
        {{"headline": "Alternative Headline 1", "subtext": "Alt Subtext 1"}},
        {{"headline": "Alternative Headline 2", "subtext": "Alt Subtext 2"}}
    ]
}}

REGELN:
- Headlines: punchy, Factory-First, max 40 Zeichen
- Farben: Dunkle Toene (#0d0d1a bis #302b63), Akzent Cyan (#00d4ff) oder Lila (#7b2ff7)
- Mindestens 2 Varianten
- Antworte NUR mit JSON, kein anderer Text."""

        response = self._call_llm(prompt, max_tokens=2048)
        if not response:
            return self._default_brief(project_slug, platform)

        parsed = self._parse_json_response(response)
        if not parsed or not isinstance(parsed, dict):
            return self._default_brief(project_slug, platform)

        # Sicherstellen dass alle Keys vorhanden
        brief = {
            "headline": parsed.get("headline", project_slug.title()),
            "subtext": parsed.get("subtext", "Built by the Factory"),
            "color_top": parsed.get("color_top", "#0f0c29"),
            "color_bottom": parsed.get("color_bottom", "#302b63"),
            "text_color": parsed.get("text_color", "#ffffff"),
            "visual_style": parsed.get("visual_style", "dark_gradient"),
            "variants": parsed.get("variants", []),
        }
        return brief

    def _default_brief(self, project_slug: str, platform: str) -> dict:
        """Fallback-Brief wenn LLM nicht verfuegbar."""
        return {
            "headline": project_slug.replace("_", " ").title(),
            "subtext": "Built by the DriveAI Factory",
            "color_top": "#0f0c29",
            "color_bottom": "#302b63",
            "text_color": "#ffffff",
            "visual_style": "dark_gradient",
            "variants": [
                {"headline": f"{project_slug.title()} — Coming Soon", "subtext": "A Factory Creation"},
            ],
        }

    # --- Oeffentliche Methoden ---

    def create_social_media_graphics(
        self,
        project_slug: str,
        platforms: list[str] = None,
    ) -> dict:
        """Erstellt Social Media Grafiken fuer die angegebenen Plattformen.

        Returns:
            {"tiktok": [path1, path2], "x": [path1, path2], ...}
        """
        if platforms is None:
            platforms = ["tiktok", "x", "instagram_square"]

        output_dir = os.path.join(self.output_base, project_slug, "graphics")
        self._ensure_dir(output_dir)

        results = {}
        for platform in platforms:
            format_key = PLATFORM_FORMATS.get(platform, "social_square")
            brief = self._generate_creative_brief(project_slug, platform)
            paths = []

            # Variante A (Hauptbrief)
            path_a = self.engine.gradient_text(
                brief["headline"],
                format_key,
                color_top=brief["color_top"],
                color_bottom=brief["color_bottom"],
                text_color=brief["text_color"],
                filename=f"{platform}_v1.png",
            )
            paths.append(path_a)

            # Variante B (aus variants)
            for i, variant in enumerate(brief.get("variants", [])[:2], start=2):
                path_v = self.engine.social_post_template(
                    variant.get("headline", brief["headline"]),
                    variant.get("subtext", brief["subtext"]),
                    format_key=format_key,
                    color_top=brief["color_top"],
                    color_bottom=brief["color_bottom"],
                    text_color=brief["text_color"],
                    filename=f"{platform}_v{i}.png",
                )
                paths.append(path_v)

            results[platform] = paths
            logger.info("Created %d graphics for %s", len(paths), platform)

        return results

    def create_app_store_screenshots(
        self,
        project_slug: str,
        device_type: str = "iphone",
        count: int = 5,
    ) -> list[str]:
        """Erstellt App Store Screenshots mit Device-Mockup.

        Returns:
            Liste der Dateipfade.
        """
        output_dir = os.path.join(self.output_base, project_slug, "screenshots")
        self._ensure_dir(output_dir)

        # Headlines via LLM generieren
        context = self._load_project_context(project_slug)
        prompt = f"""Generiere {count} kurze Feature-Headlines fuer App Store Screenshots.

PROJEKT: {project_slug}
KONTEXT: {context['story_brief'][:800] if context['story_brief'] else project_slug}

Antworte als JSON-Array mit Strings. Jede Headline max 30 Zeichen, beschreibt ein Feature.
Beispiel: ["Sound-Matching", "100+ Levels", "Dein Fortschritt"]

NUR das JSON-Array, kein anderer Text."""

        response = self._call_llm(prompt, max_tokens=1024)
        headlines = self._parse_json_response(response) if response else None
        if not headlines or not isinstance(headlines, list):
            headlines = [f"Feature {i+1}" for i in range(count)]

        format_key = "ios_screenshot" if device_type == "iphone" else "android_screenshot"
        paths = []

        for i, headline in enumerate(headlines[:count]):
            # Erstelle Hintergrund-Bild mit Feature-Text
            bg_path = self.engine.gradient_text(
                str(headline),
                format_key,
                color_top="#0f0c29",
                color_bottom="#24243e",
                text_color="#00d4ff",
                filename=f"_temp_screenshot_bg_{i}.png",
            )

            # Device-Mockup erstellen
            device = "phone" if device_type == "iphone" else "tablet"
            mockup_path = self.engine.device_mockup(
                bg_path,
                device=device,
                bg_color="#0d0d1a",
                filename=f"screenshot_{i+1}.png",
            )
            paths.append(mockup_path)

            # Temp-BG loeschen
            try:
                os.remove(bg_path)
            except OSError:
                pass

        logger.info("Created %d app store screenshots for %s", len(paths), project_slug)
        return paths

    def create_youtube_thumbnail(
        self,
        project_slug: str,
        headline_text: str = None,
    ) -> str:
        """Erstellt ein YouTube Thumbnail (1280x720).

        Returns:
            Dateipfad.
        """
        output_dir = os.path.join(self.output_base, project_slug, "thumbnails")
        self._ensure_dir(output_dir)

        if not headline_text:
            brief = self._generate_creative_brief(project_slug, "youtube")
            headline_text = brief["headline"]

        path = self.engine.social_post_template(
            headline_text,
            "DriveAI Factory",
            format_key="youtube_thumbnail",
            color_top="#0f0c29",
            color_bottom="#7b2ff7",
            text_color="#ffffff",
            filename="youtube_thumbnail.png",
        )

        logger.info("Created YouTube thumbnail for %s", project_slug)
        return path

    def create_ad_creatives(
        self,
        project_slug: str,
        formats: list[str] = None,
    ) -> dict:
        """Erstellt Ad-Grafiken.

        Returns:
            {"meta_ad_feed": [path1, path2], ...}
        """
        if formats is None:
            formats = ["meta_ad_feed", "meta_ad_story"]

        output_dir = os.path.join(self.output_base, project_slug, "ads")
        self._ensure_dir(output_dir)

        results = {}
        brief = self._generate_creative_brief(project_slug, "ad", content_type="advertising")

        for fmt in formats:
            format_key = PLATFORM_FORMATS.get(fmt, "social_square")
            paths = []

            # Variante A
            path_a = self.engine.gradient_text(
                brief["headline"],
                format_key,
                color_top=brief["color_top"],
                color_bottom=brief["color_bottom"],
                text_color=brief["text_color"],
                filename=f"{fmt}_v1.png",
            )
            paths.append(path_a)

            # Variante B
            if brief.get("variants"):
                v = brief["variants"][0]
                path_b = self.engine.social_post_template(
                    v.get("headline", brief["headline"]),
                    v.get("subtext", brief["subtext"]),
                    format_key=format_key,
                    color_top=brief["color_top"],
                    color_bottom=brief["color_bottom"],
                    text_color=brief["text_color"],
                    filename=f"{fmt}_v2.png",
                )
                paths.append(path_b)

            results[fmt] = paths

        logger.info("Created ad creatives for %s: %d formats", project_slug, len(results))
        return results

    def _try_ai_background(self, prompt: str, width: int, height: int) -> Optional[str]:
        """Versucht ein AI-generiertes Hintergrundbild zu erstellen.

        Stub — gibt None zurueck. Template-Engine Gradient als Fallback.
        Die echte Implementierung kommt wenn wir AI-Bilder aktiv nutzen wollen.
        """
        # TODO: DALL-E/Stability Integration wenn gewuenscht
        return None

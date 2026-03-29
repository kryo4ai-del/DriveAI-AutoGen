"""Video Script Agent (MKT-07) — Schreibt Video-Skripte und erzeugt einfache Clips.

Verantwortlich fuer:
- Video-Skripte fuer TikTok, YouTube Shorts, YouTube Long, Instagram Reels
- Content-Typen: Showcase, Behind the Scenes, Factory Update, Tutorial, Trend Reaction
- Einfache Video-Clips aus Skripten (statische Bild-Slides via Template-Engine + Video-Pipeline)
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

logger = logging.getLogger("factory.marketing.agents.video_script")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Video Script Agent der DriveAI Factory (MKT-07).

IDENTITAET:
Die Factory IST das Produkt. Jedes Video zeigt die Factory als autonomes KI-Wesen, das Apps baut. Das Maskottchen: ein pulsierendes Gehirn angeschlossen an Factory-Maschinerie.

AUFGABE:
Du schreibst Skripte fuer alle Videoformate: YouTube Long, Shorts, TikTok, Reels.
Der Hook in den ersten 2-3 Sekunden entscheidet ALLES.

SZENEN-FORMAT:
Jede Szene hat:
- scene_number: Nummer
- description: Was visuell zu sehen ist
- voiceover: Gesprochener Text
- on_screen_text: Text der eingeblendet wird (kurz, punchy)
- duration: Dauer in Sekunden

CONTENT-TYPEN:
- showcase: App-Vorstellung, Features zeigen, Factory als Erbauer
- behind_the_scenes: Wie die Factory arbeitet, Agent-Orchestrierung
- factory_update: News aus der Factory (neue Features, neue Agents)
- tutorial: How-To fuer Factory-Apps
- trend_reaction: Reaktion auf aktuelle Trends, Factory-Spin

FORMAT-CONSTRAINTS:
- tiktok: max 60s, Hook unter 3s, vertikal 9:16
- youtube_short: max 60s, Hook unter 3s, vertikal 9:16
- youtube_long: 5-15 Min, Kapitelmarken, horizontal 16:9
- instagram_reel: max 90s, Hook unter 3s, vertikal 9:16

REGELN:
- Jedes Skript beginnt mit einem HOOK (On-Screen-Text + Voiceover, max 3s)
- Am Ende immer ein CTA (Call to Action)
- Musik/Sound Empfehlung angeben
- Factory-First Positionierung
- Authentisch und technisch, keine generischen Phrasen
"""

# --- Format Constraints ---

FORMAT_CONSTRAINTS = {
    "tiktok": {"max_duration": 60, "hook_max": 3, "orientation": "vertical"},
    "youtube_short": {"max_duration": 60, "hook_max": 3, "orientation": "vertical"},
    "youtube_long": {"max_duration": 900, "hook_max": 5, "orientation": "horizontal"},
    "instagram_reel": {"max_duration": 90, "hook_max": 3, "orientation": "vertical"},
}

# Video-Format Mapping (fuer Video-Pipeline)
VIDEO_FORMAT_MAP = {
    "tiktok": "tiktok",
    "youtube_short": "tiktok",  # Gleiche 9:16 Dimensionen
    "youtube_long": "youtube",
    "instagram_reel": "story",
}


class VideoScriptAgent:
    """Video Script Agent — schreibt Skripte und erzeugt einfache Video-Clips."""

    def __init__(self) -> None:
        from factory.marketing.config import BRAND_PATH, OUTPUT_PATH
        from factory.marketing.tools.template_engine import MarketingTemplateEngine
        from factory.marketing.tools.video_pipeline import MarketingVideoPipeline

        self.video_pipeline = MarketingVideoPipeline()
        self.template_engine = MarketingTemplateEngine()
        self.output_base = OUTPUT_PATH
        self.brand_path = BRAND_PATH
        self.agent_info = self._load_persona()
        logger.info("Video Script Agent initialized")

    def _load_persona(self) -> dict:
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_video_script.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-07", "name": "Video Script"}

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

    def _ensure_dir(self, path: str) -> None:
        os.makedirs(path, exist_ok=True)

    def _write_output(self, path: str, content: str) -> str:
        self._ensure_dir(os.path.dirname(path))
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        logger.info("Output written: %s", path)
        return path

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

    # --- Oeffentliche Methoden ---

    def create_video_script(
        self,
        project_slug: str,
        format: str = "tiktok",
        content_type: str = "showcase",
    ) -> str:
        """Erstellt ein Video-Skript.

        Returns:
            Pfad zum Skript (.md Datei).
        """
        constraints = FORMAT_CONSTRAINTS.get(format, FORMAT_CONSTRAINTS["tiktok"])
        context = self._load_project_context(project_slug)

        prompt = f"""Schreibe ein Video-Skript im Format {format} ({content_type}).

PROJEKT: {project_slug}

STORY BRIEF (Auszug):
{context['story_brief'][:1500] if context['story_brief'] else f'App namens {project_slug} — ein Factory-Produkt.'}

FORMAT-CONSTRAINTS:
- Max Dauer: {constraints['max_duration']}s
- Hook max: {constraints['hook_max']}s
- Orientierung: {constraints['orientation']}

AUSGABE-FORMAT (Markdown):

# Video-Skript: {project_slug} ({format}, {content_type})

## Metadaten
- Format: {format}
- Gesamtdauer: Xs
- Orientierung: {constraints['orientation']}
- Musik/Sound: [Empfehlung]

## Hook (0-3s)
**On-Screen-Text:** [Kurzer, punchiger Text]
**Voiceover:** [Was gesprochen wird]
**Visuell:** [Was zu sehen ist]

## Szene 1 (Xs)
**On-Screen-Text:** [Text]
**Voiceover:** [Sprechtext]
**Visuell:** [Beschreibung]
**Dauer:** Xs

## Szene 2 (Xs)
...

## CTA
**On-Screen-Text:** [Call to Action]
**Voiceover:** [Abschluss]

Schreibe das Skript jetzt. Halte die Gesamtdauer unter {constraints['max_duration']}s.
Der Hook MUSS in den ersten {constraints['hook_max']}s fesseln."""

        response = self._call_llm(prompt, max_tokens=4096)
        if not response:
            response = self._default_script(project_slug, format, content_type)

        output_dir = os.path.join(self.output_base, project_slug, "scripts")
        file_path = os.path.join(output_dir, f"video_{format}_{content_type}.md")
        return self._write_output(file_path, response)

    def create_daily_factory_content(self, topic: str = None) -> str:
        """Erstellt ein Kurz-Skript fuer taeglichen Factory-Content.

        Returns:
            Pfad zum Skript.
        """
        if not topic:
            topic = "Die DriveAI Factory arbeitet rund um die Uhr an neuen Apps"

        prompt = f"""Schreibe ein 15-30 Sekunden Kurz-Skript fuer taeglichen Factory-Content.

THEMA: {topic}
FORMAT: TikTok/Short (vertikal, max 30s)
ZIEL: Zeige die Factory als lebendiges KI-Wesen

AUSGABE-FORMAT (Markdown):

# Daily Factory Content — {datetime.now().strftime('%Y-%m-%d')}

## Metadaten
- Format: TikTok/Short
- Gesamtdauer: 15-30s
- Musik/Sound: [Empfehlung]

## Hook (0-3s)
**On-Screen-Text:** [Punchig]
**Voiceover:** [Hook-Satz]

## Szene 1 (Xs)
**On-Screen-Text:** [Text]
**Voiceover:** [Sprechtext]
**Dauer:** Xs

## CTA
**On-Screen-Text:** [Follow/Like CTA]

Halte es kurz und punchy. Max 30 Sekunden gesamt."""

        response = self._call_llm(prompt, max_tokens=2048)
        if not response:
            response = f"# Daily Factory Content — {datetime.now().strftime('%Y-%m-%d')}\n\n## Hook\n**On-Screen-Text:** {topic}\n**Dauer:** 3s\n"

        output_dir = os.path.join(self.output_base, "daily")
        date_str = datetime.now().strftime("%Y%m%d")
        file_path = os.path.join(output_dir, f"factory_content_{date_str}.md")
        return self._write_output(file_path, response)

    def create_video_from_script(
        self,
        script_path: str,
        format_name: str = "tiktok",
    ) -> str:
        """Erstellt einen einfachen Video-Clip aus einem Skript.

        BASIC-VERSION: Statische Bild-Slides mit Text auf Gradient-Hintergrund.

        Returns:
            Pfad zur MP4-Datei.
        """
        with open(script_path, "r", encoding="utf-8") as f:
            script_content = f.read()

        scenes = self._parse_script_scenes(script_content)
        if not scenes:
            logger.warning("No scenes found in script, using fallback")
            scenes = [{"scene_number": 1, "on_screen_text": "Video Script", "duration": 5.0}]

        # Video-Format bestimmen
        video_format = VIDEO_FORMAT_MAP.get(format_name, "tiktok")
        # Template-Format: vertikal oder horizontal
        if format_name in ("tiktok", "youtube_short", "instagram_reel"):
            template_format = "social_story"
        else:
            template_format = "youtube_thumbnail"

        # Farben pro Szene abwechseln
        color_schemes = [
            ("#0f0c29", "#302b63"),
            ("#1a1a2e", "#16213e"),
            ("#0d0d1a", "#24243e"),
            ("#1a0533", "#3a0ca3"),
        ]

        # Pro Szene ein Bild erstellen
        image_paths = []
        durations = []
        temp_dir = os.path.join(self.output_base, "_temp_video")
        self._ensure_dir(temp_dir)

        for i, scene in enumerate(scenes):
            text = scene.get("on_screen_text", f"Scene {i+1}")
            duration = scene.get("duration", 4.0)
            colors = color_schemes[i % len(color_schemes)]

            img_path = self.template_engine.gradient_text(
                text,
                template_format,
                color_top=colors[0],
                color_bottom=colors[1],
                text_color="#ffffff",
                filename=f"_scene_{i}.png",
            )
            image_paths.append(img_path)
            durations.append(duration)

        # Video zusammenbauen: ein Clip pro Szene, dann zusammenfuegen
        # Da images_to_video eine einheitliche duration_per_image nutzt,
        # erstellen wir stattdessen einzelne Clips und fuegen sie zusammen
        if len(image_paths) == 1:
            # Einzelnes Bild → einfacher Clip
            result_path = self.video_pipeline.create_simple_clip(
                image_paths[0],
                duration=durations[0],
                format_key=video_format,
                filename=f"video_{format_name}_{datetime.now().strftime('%H%M%S')}.mp4",
            )
        else:
            # Mehrere Szenen → Slideshow
            # Durchschnittliche Dauer verwenden (images_to_video hat uniform duration)
            avg_duration = sum(durations) / len(durations)
            result_path = self.video_pipeline.images_to_video(
                image_paths,
                format_key=video_format,
                duration_per_image=avg_duration,
                filename=f"video_{format_name}_{datetime.now().strftime('%H%M%S')}.mp4",
            )

        # Szenen-Bilder nach Video-Erstellung verschieben (in output statt temp)
        # Projekt-Slug aus Script-Pfad extrahieren
        script_dir = os.path.dirname(script_path)
        project_dir = os.path.dirname(script_dir)
        project_slug = os.path.basename(project_dir) if os.path.basename(script_dir) == "scripts" else "unknown"

        final_dir = os.path.join(self.output_base, project_slug, "videos")
        self._ensure_dir(final_dir)

        # Video verschieben wenn nicht schon im richtigen Ordner
        final_name = f"video_{format_name}_{datetime.now().strftime('%H%M%S')}.mp4"
        final_path = os.path.join(final_dir, final_name)
        if result_path != final_path:
            import shutil
            shutil.copy2(result_path, final_path)

        # Temp-Bilder aufraeumen
        for p in image_paths:
            try:
                os.remove(p)
            except OSError:
                pass

        logger.info("Created video from script: %s (%d scenes)", final_path, len(scenes))
        return final_path

    def _parse_script_scenes(self, script_content: str) -> list[dict]:
        """Parst ein Skript in Szenen.

        Returns:
            [{"scene_number": int, "on_screen_text": str, "duration": float}, ...]
        """
        scenes = []
        # Pattern: "## Hook" oder "## Szene N" oder "## Scene N" oder "## CTA"
        section_pattern = re.compile(
            r"^##\s+(Hook|Szene\s*\d+|Scene\s*\d+|CTA).*$",
            re.MULTILINE | re.IGNORECASE,
        )
        matches = list(section_pattern.finditer(script_content))

        for idx, match in enumerate(matches):
            start = match.end()
            end = matches[idx + 1].start() if idx + 1 < len(matches) else len(script_content)
            section_text = script_content[start:end]

            # On-Screen-Text extrahieren
            on_screen = ""
            on_screen_match = re.search(
                r"\*\*On-Screen(?:-Text)?:?\*\*\s*(.+?)(?:\n|$)",
                section_text,
                re.IGNORECASE,
            )
            if on_screen_match:
                on_screen = on_screen_match.group(1).strip()

            # Dauer extrahieren
            duration = 4.0  # Default
            duration_match = re.search(
                r"(?:\*\*Dauer:?\*\*|Duration:?)\s*(\d+(?:\.\d+)?)\s*s",
                section_text,
                re.IGNORECASE,
            )
            if duration_match:
                duration = float(duration_match.group(1))
            else:
                # Aus Section-Header: "## Hook (0-3s)" oder "## Szene 1 (5s)"
                header_duration = re.search(r"\((\d+(?:\.\d+)?)\s*s\)", match.group(0))
                if header_duration:
                    duration = float(header_duration.group(1))
                # "## Hook (0-3s)" → nimm die zweite Zahl
                range_match = re.search(r"\((\d+)-(\d+)s\)", match.group(0))
                if range_match:
                    duration = float(range_match.group(2))

            if on_screen or match.group(1).lower() in ("hook", "cta"):
                scenes.append({
                    "scene_number": len(scenes) + 1,
                    "on_screen_text": on_screen or match.group(1),
                    "duration": max(duration, 2.0),  # Minimum 2s pro Szene
                })

        if not scenes:
            # Fallback: Teile in gleich lange Abschnitte
            lines = [l.strip() for l in script_content.split("\n") if l.strip() and not l.startswith("#")]
            if lines:
                chunk_size = max(1, len(lines) // 4)
                for i in range(0, min(len(lines), 16), chunk_size):
                    text = lines[i][:60]
                    scenes.append({
                        "scene_number": len(scenes) + 1,
                        "on_screen_text": text,
                        "duration": 4.0,
                    })

        return scenes

    def _default_script(self, project_slug: str, format: str, content_type: str) -> str:
        """Fallback-Skript wenn LLM nicht verfuegbar."""
        return f"""# Video-Skript: {project_slug} ({format}, {content_type})

## Metadaten
- Format: {format}
- Gesamtdauer: 15s
- Orientierung: vertikal
- Musik/Sound: Ambient Tech

## Hook (0-3s)
**On-Screen-Text:** Die Factory baut Apps
**Voiceover:** Was wenn eine KI komplette Apps bauen koennte?
**Dauer:** 3s

## Szene 1 (5s)
**On-Screen-Text:** {project_slug.title()} — Built by AI
**Voiceover:** Das ist {project_slug}, gebaut von der DriveAI Factory.
**Dauer:** 5s

## Szene 2 (4s)
**On-Screen-Text:** 81 Agents. 14 Departments.
**Voiceover:** 81 KI-Agents arbeiten zusammen.
**Dauer:** 4s

## CTA (3s)
**On-Screen-Text:** Follow fuer mehr
**Voiceover:** Folge uns fuer mehr Factory-Content.
**Dauer:** 3s
"""

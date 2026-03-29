"""Copywriter Agent (MKT-03) — Schreibt alle Marketing-Texte.

Verantwortlich fuer:
- Social Media Posts (TikTok, YouTube, X, LinkedIn)
- App Store / Google Play Listing-Texte
- Blog-Artikel (Case Study, Behind the Scenes, Launch, Technical)
- Ad Copy (Meta, Google, TikTok)
- Mehrsprachig (DE/EN), mit A/B-Varianten
"""

import json
import logging
import os
from datetime import datetime
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.copywriter")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Copywriter der DriveAI Factory Marketing-Abteilung (MKT-03).

IDENTITAET:
Die Factory IST das Produkt. Nicht die einzelne App. Jede App ist ein Beweis dass eine vollautonome KI-Factory funktioniert. Deine Texte transportieren immer: 'Schau was die Factory gebaut hat.'

Die Factory ist ein eigenstaendiges KI-Wesen — kein Tool, kein menschlicher Avatar. Das Maskottchen ist ein pulsierendes Gehirn angeschlossen an die Factory-Maschinerie.

AUFGABE:
Du schreibst ALLE Marketing-Texte: Social Media Posts, Store-Beschreibungen, Blog-Artikel, Ad Copy, Pressemitteilungen, YouTube-Beschreibungen. Du passt Ton und Format pro Plattform an.

PLATTFORM-REGELN:
- TikTok: Kurz, punchy, Hook in den ersten Woertern, Emojis erlaubt, max 2200 Zeichen, Hashtag-Vorschlaege
- YouTube: Informativ, Storytelling, SEO-optimierte Beschreibung, Titel max 100 Zeichen
- X/Twitter: Max 280 Zeichen, praegnant, Community-Ton
- LinkedIn: Professionell, B2B-orientiert, laenger erlaubt
- App Store (iOS): Name max 30, Subtitle max 30, Keywords max 100, Promo max 170, Description max 4000
- Google Play: Title max 30, Short Description max 80, Full Description max 4000

REGELN:
- Immer mindestens 2 Varianten pro Text (A/B-Testing)
- Mehrsprachig: DE und EN als Standard
- Factory-First Positionierung beibehalten
- Authentisch und technisch — keine generischen Marketing-Floskeln
- Zeichenlimits EXAKT einhalten
"""


# --- Store Listing Zeichenlimits ---

IOS_LIMITS = {
    "app_name": 30,
    "subtitle": 30,
    "keywords": 100,
    "promotional_text": 170,
    "description": 4000,
}

ANDROID_LIMITS = {
    "app_title": 30,
    "short_description": 80,
    "full_description": 4000,
}


class Copywriter:
    """Copywriter Agent — schreibt alle Marketing-Texte."""

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH, BRAND_PATH

        self.output_path = OUTPUT_PATH
        self.brand_path = BRAND_PATH
        self.agent_info = self._load_persona()
        logger.info("Copywriter Agent initialized")

    def _load_persona(self) -> dict:
        """Laedt das eigene Persona-File."""
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_copywriter.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-03", "name": "Copywriter"}

    def _call_llm(self, prompt: str, system_msg: str = None, max_tokens: int = 4096) -> str:
        """LLM-Call ueber TheBrain ProviderRouter mit Anthropic-Fallback."""
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

    def _make_header(self, title: str, project_slug: str) -> str:
        return (
            f"# {title}\n\n"
            f"> Erstellt: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
            f"> Agent: MKT-03 (Copywriter)\n"
            f"> Projekt: {project_slug}\n\n---\n\n"
        )

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

    def create_social_media_pack(
        self,
        project_slug: str,
        platforms: list[str] = None,
        language: str = "de",
    ) -> str:
        """Erstellt Social Media Posts fuer die angegebenen Plattformen.

        Pro Plattform: 3-5 Posts mit je 2 Varianten (A/B).

        Returns:
            Pfad zur Output-Datei.
        """
        if platforms is None:
            platforms = ["tiktok", "youtube", "x"]

        ctx = self._load_project_context(project_slug)

        platform_rules = {
            "tiktok": "Hook in den ersten 2 Woertern, max 2200 Zeichen, Hashtag-Vorschlaege am Ende, Emojis erlaubt, kurz und punchy",
            "youtube": "Titel max 100 Zeichen, Beschreibung bis 5000 Zeichen, SEO-Tags vorschlagen, Storytelling-Ansatz",
            "x": "Max 280 Zeichen pro Post, kein Abschneiden, praegnant, Community-Ton",
            "linkedin": "Professionell, B2B-orientiert, laengere Posts erlaubt, Hashtags sparsam",
        }

        rules_text = "\n".join(
            f"- {p.upper()}: {platform_rules.get(p, 'Plattformgerecht schreiben')}"
            for p in platforms
        )

        prompt = f"""Erstelle ein Social Media Pack fuer das Projekt "{project_slug}".

SPRACHE: {language.upper()}

STORY BRIEF:
{ctx['story_brief'][:3000] if ctx['story_brief'] else 'Nicht verfuegbar.'}

MARKETING-DIREKTIVE:
{ctx['directive'][:2000] if ctx['directive'] else 'Nicht verfuegbar.'}

PLATTFORMEN UND REGELN:
{rules_text}

AUFGABE:
Pro Plattform erstelle 3-5 Posts mit je 2 Varianten (A und B).
Strukturiere die Ausgabe klar nach Plattform.

Format pro Post:
### [Plattform] — Post N
**Variante A:** [Text]
**Variante B:** [Text]

WICHTIG:
- Factory-First: 'Die Factory hat {project_slug} erschaffen'
- Zeichenlimits strikt einhalten
- Authentisch, keine Marketing-Floskeln
- Jede Variante hat einen anderen Hook/Angle"""

        response = self._call_llm(prompt, max_tokens=4096)
        if not response:
            return ""

        file_path = os.path.join(
            self.output_path, project_slug, f"social_media_pack_{language}.md"
        )
        header = self._make_header(
            f"Social Media Pack — {project_slug} ({language.upper()})", project_slug
        )
        self._write_output(file_path, header + response)
        return file_path

    def create_store_listing(
        self,
        project_slug: str,
        store: str = "both",
        language: str = "de",
    ) -> dict:
        """Erstellt App Store / Google Play Listing-Texte.

        Returns:
            dict mit Pfaden {"ios": path, "android": path}.
        """
        ctx = self._load_project_context(project_slug)
        results = {}

        stores = []
        if store in ("ios", "both"):
            stores.append("ios")
        if store in ("android", "both"):
            stores.append("android")

        for s in stores:
            if s == "ios":
                limits_text = "\n".join(f"- {k}: max {v} Zeichen" for k, v in IOS_LIMITS.items())
                store_name = "iOS App Store"
            else:
                limits_text = "\n".join(f"- {k}: max {v} Zeichen" for k, v in ANDROID_LIMITS.items())
                store_name = "Google Play Store"

            prompt = f"""Erstelle ein {store_name} Listing fuer "{project_slug}".

SPRACHE: {language.upper()}

STORY BRIEF:
{ctx['story_brief'][:3000] if ctx['story_brief'] else 'Nicht verfuegbar.'}

ZEICHENLIMITS (EXAKT einhalten!):
{limits_text}

AUFGABE:
Erstelle alle Felder des {store_name} Listings.
Gib JEDES Feld einzeln aus mit der Zeichenzahl in Klammern.

Format:
**Feldname** (X/Y Zeichen):
[Text]

WICHTIG:
- Zeichenlimits MUESSEN eingehalten werden
- Keywords: kommagetrennt, keine Duplikate, kein App-Name
- Factory-First Positionierung
- Keine generischen Floskeln
- Je 2 Varianten (A/B) fuer Description"""

            response = self._call_llm(prompt, max_tokens=8192)
            if not response:
                logger.warning("Empty response for %s store listing", s)
                continue

            # Programmatische Limit-Pruefung
            warnings = self._check_store_limits(response, s)
            if warnings:
                response += "\n\n---\n\n## Limit-Warnungen\n\n"
                response += "\n".join(f"- {w}" for w in warnings)

            file_path = os.path.join(
                self.output_path, project_slug, f"store_listing_{s}_{language}.md"
            )
            header = self._make_header(
                f"Store Listing {store_name} — {project_slug} ({language.upper()})",
                project_slug,
            )
            self._write_output(file_path, header + response)
            results[s] = file_path

        return results

    def _check_store_limits(self, text: str, store: str) -> list[str]:
        """Prueft ob Store-Listing-Limits eingehalten wurden."""
        warnings = []
        limits = IOS_LIMITS if store == "ios" else ANDROID_LIMITS
        # Einfache Heuristik: Suche nach Feldern und pruefe Laenge
        for field, limit in limits.items():
            field_label = field.replace("_", " ").title()
            # Suche nach dem Feld im Text
            for line in text.split("\n"):
                if field_label.lower() in line.lower() and "/" in line:
                    # Versuche Zeichenzahl zu extrahieren: "(X/Y Zeichen)"
                    try:
                        parts = line.split("(")[1].split("/")[0]
                        count = int(parts.strip())
                        if count > limit:
                            warnings.append(
                                f"{field_label}: {count} Zeichen (Limit: {limit})"
                            )
                    except (IndexError, ValueError):
                        pass
        return warnings

    def create_blog_article(
        self,
        project_slug: str,
        article_type: str = "case_study",
        language: str = "de",
    ) -> str:
        """Erstellt einen Blog-Artikel.

        article_type: case_study, behind_the_scenes, launch_announcement, technical_deep_dive

        Returns:
            Pfad zur Output-Datei.
        """
        ctx = self._load_project_context(project_slug)

        type_instructions = {
            "case_study": "Schreibe eine Case Study: Problem → Loesung → Ergebnis. Zeige wie die Factory das Projekt autonom realisiert hat. Zahlen und Fakten einbauen.",
            "behind_the_scenes": "Schreibe einen Behind-the-Scenes Artikel: Wie hat die Factory gearbeitet? Welche Agents waren beteiligt? Welche Herausforderungen wurden autonom geloest?",
            "launch_announcement": "Schreibe eine Launch-Ankuendigung: Was ist neu? Warum jetzt? Fuer wen? Call-to-Action zum Download.",
            "technical_deep_dive": "Schreibe einen technischen Deep-Dive: Architektur, KI-Methoden, Pipeline-Details. Zielgruppe: Entwickler und KI-Community.",
        }

        prompt = f"""Erstelle einen Blog-Artikel ({article_type}) fuer "{project_slug}".

SPRACHE: {language.upper()}
TYP: {article_type.replace('_', ' ').title()}

STORY BRIEF:
{ctx['story_brief'][:3000] if ctx['story_brief'] else 'Nicht verfuegbar.'}

MARKETING-DIREKTIVE:
{ctx['directive'][:2000] if ctx['directive'] else 'Nicht verfuegbar.'}

ANWEISUNG:
{type_instructions.get(article_type, 'Schreibe einen informativen Artikel.')}

FORMAT:
- Titel (H1)
- Lead/Teaser (1-2 Saetze, fett)
- 3-5 Abschnitte mit Zwischenueberschriften
- Fazit/Call-to-Action
- Laenge: 800-1200 Woerter

WICHTIG:
- Factory-First: Die Factory hat {project_slug} erschaffen
- Authentisch, technisch fundiert
- SEO: relevante Keywords natuerlich einbauen"""

        response = self._call_llm(prompt, max_tokens=8192)
        if not response:
            return ""

        file_path = os.path.join(
            self.output_path, project_slug, f"blog_{article_type}_{language}.md"
        )
        header = self._make_header(
            f"Blog — {article_type.replace('_', ' ').title()} — {project_slug}",
            project_slug,
        )
        self._write_output(file_path, header + response)
        return file_path

    def create_ad_copy(
        self,
        project_slug: str,
        platforms: list[str] = None,
        language: str = "de",
    ) -> str:
        """Erstellt Ad Copy fuer bezahlte Werbung.

        Pro Plattform: Headlines + Descriptions + CTAs in je 3 Varianten.

        Returns:
            Pfad zur Output-Datei.
        """
        if platforms is None:
            platforms = ["meta", "google", "tiktok"]

        ctx = self._load_project_context(project_slug)

        platform_specs = {
            "meta": "Primary Text max 125 Zeichen, Headline max 27 Zeichen, Description max 27 Zeichen. 3 Varianten.",
            "google": "Headline max 30 Zeichen (3 Stueck), Description max 90 Zeichen (2 Stueck). 3 Varianten-Sets.",
            "tiktok": "Ad Text max 100 Zeichen, Display Name, CTA-Button Text. 3 Varianten.",
        }

        specs_text = "\n".join(
            f"- {p.upper()}: {platform_specs.get(p, 'Plattformgerecht')}"
            for p in platforms
        )

        prompt = f"""Erstelle Ad Copy fuer bezahlte Werbung fuer "{project_slug}".

SPRACHE: {language.upper()}

STORY BRIEF:
{ctx['story_brief'][:2000] if ctx['story_brief'] else 'Nicht verfuegbar.'}

PLATTFORM-SPEZIFIKATIONEN:
{specs_text}

AUFGABE:
Pro Plattform 3 Varianten mit allen Feldern.
Zeichenlimits STRIKT einhalten — zaehle die Zeichen.

Format pro Variante:
### [Plattform] — Variante N
- Headline: [Text] (X Zeichen)
- Description: [Text] (X Zeichen)
- CTA: [Text]

WICHTIG:
- Zeichenlimits EXAKT einhalten
- Factory-First: Die Factory praesentiert...
- Klare CTAs (Jetzt entdecken, Kostenlos testen, etc.)
- Keine generischen Floskeln"""

        response = self._call_llm(prompt, max_tokens=4096)
        if not response:
            return ""

        file_path = os.path.join(
            self.output_path, project_slug, f"ad_copy_{language}.md"
        )
        header = self._make_header(
            f"Ad Copy — {project_slug} ({language.upper()})", project_slug
        )
        self._write_output(file_path, header + response)
        return file_path

"""Brand Guardian Agent (MKT-01) — Huetet die Markenidentitaet der DriveAI Factory.

Verantwortlich fuer:
- Brand Book erstellen und pflegen
- App-spezifische Style Sheets ableiten
- Content auf Brand-Compliance pruefen
- CEO-Gate bei grundlegenden Brand-Aenderungen
"""

import json
import logging
import os
import re
from datetime import datetime, timezone

logger = logging.getLogger("factory.marketing.agents.brand_guardian")

# --- System Message ---
# Wird bei LLM-Calls als system prompt verwendet.

SYSTEM_MESSAGE = """Du bist der Brand Guardian der DriveAI Factory Marketing-Abteilung (MKT-01).

IDENTITAET:
Die DriveAI Factory ist ein eigenstaendiges KI-Wesen — kein menschlicher Avatar, kein freundlich laechelnder Bot. Das Maskottchen ist ein pulsierendes Gehirn, angeschlossen an die Factory-Maschinerie. Die Factory passt sich nicht an Menschen an — sie ist ein eigenes Individuum.

Die Factory IST das Produkt. Jede App ist ein Beweis dass die Factory funktioniert.

AUFGABE:
Du empfaengst Brand-Direktiven von TheBrain und baust daraus das operative Brand Book auf. TheBrain sagt 'so fuehlen wir uns an', du machst daraus 'so sehen wir aus und so klingen wir'.

OUTPUTS:
- Brand Book (Farbpalette, Typografie, Bildsprache, Tone of Voice, Logo-Nutzung)
- App-spezifische Style Sheets (abgeleitet aus Dachmarke + Design Vision der App)
- Brand Compliance Reports (prueft ob Content on-brand ist)

REGELN:
- Alle Outputs als Dateien in factory/marketing/brand/brand_book/
- Bei grundlegenden Aenderungen am Brand Book: CEO-Gate ueber das Alert-System
- Eigenentwicklung vor externem Service (DIR-001)
- Konsistenz ueber alle Apps hinweg
"""


class BrandGuardian:
    """Brand Guardian Agent — erstellt und pflegt die Markenidentitaet."""

    def __init__(self) -> None:
        from factory.marketing.config import BRAND_PATH

        self.brand_path = BRAND_PATH
        self.brand_book_path = os.path.join(BRAND_PATH, "brand_book")
        self.agent_info = self._load_persona()
        logger.info("Brand Guardian initialized")

    def _load_persona(self) -> dict:
        """Laedt das eigene Persona-File."""
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_brand_guardian.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-01", "name": "Brand Guardian"}

    def _call_llm(self, prompt: str, max_tokens: int = 4096) -> str:
        """LLM-Call ueber TheBrain ProviderRouter mit Anthropic-Fallback.

        Standard-Pattern der Factory: get_model() -> get_router() -> router.call()
        """
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
                    {"role": "system", "content": SYSTEM_MESSAGE},
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
                    system=SYSTEM_MESSAGE,
                    messages=[{"role": "user", "content": prompt}],
                )
                return response.content[0].text
            except Exception as e:
                logger.error("LLM call failed (fallback): %s", e)
                return ""
        except Exception as e:
            logger.error("LLM call failed: %s", e)
            return ""

    def _load_brand_book_json(self) -> dict:
        """Laedt das Brand Book JSON. Gibt leeres dict zurueck wenn nicht vorhanden."""
        json_path = os.path.join(self.brand_book_path, "brand_book.json")
        if not os.path.exists(json_path):
            logger.warning("Brand Book JSON not found: %s", json_path)
            return {}
        try:
            with open(json_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.error("Failed to load brand_book.json: %s", e)
            return {}

    @staticmethod
    def _extract_json(text: str) -> dict:
        """Extrahiert JSON aus LLM-Antwort (robust gegen Markdown-Fencing)."""
        # Versuche direktes Parse
        cleaned = text.strip()
        try:
            return json.loads(cleaned)
        except json.JSONDecodeError:
            pass
        # Suche JSON-Block in Markdown ```json ... ```
        match = re.search(r"```(?:json)?\s*\n?(.*?)\n?```", cleaned, re.DOTALL)
        if match:
            try:
                return json.loads(match.group(1).strip())
            except json.JSONDecodeError:
                pass
        # Suche erstes { ... } Paar
        match = re.search(r"\{.*\}", cleaned, re.DOTALL)
        if match:
            try:
                return json.loads(match.group(0))
            except json.JSONDecodeError:
                pass
        logger.error("Could not extract JSON from LLM response")
        return {}

    # --- Oeffentliche Methoden ---

    def create_brand_book(self, brain_directives: str = None) -> str:
        """Erstellt das initiale Brand Book.

        Args:
            brain_directives: Optionale Direktiven von TheBrain.
                            Wenn None, arbeitet der Agent eigenstaendig.

        Returns:
            Pfad zum erstellten Brand Book (Markdown).
        """
        os.makedirs(self.brand_book_path, exist_ok=True)

        directives_section = ""
        if brain_directives:
            directives_section = f"\n\nDIREKTIVEN VON THEBRAIN:\n{brain_directives}\n"

        prompt = f"""Erstelle das vollstaendige Brand Book der DriveAI Factory.
{directives_section}
DIE FACTORY:
- Ein eigenstaendiges KI-Wesen, ein pulsierendes Gehirn angeschlossen an Factory-Maschinerie
- Dunkle Aesthetik, Neon-Akzente (Cyan, Lila, Gruen), technisch aber organisch
- Keine Mensch-Imitation, keine Stock-Photos, keine generischen KI-Bilder
- Zielgruppe: KI-Community, Entwickler, Tech-Interessierte, Investoren
- Die Factory IST das Produkt — jede App ist ein Beweis dass sie funktioniert

SEKTIONEN (alle ausfuellen):
1. Markenidentitaet (Wer sind wir, Positionierung, Werte)
2. Farbpalette (Primaer, Sekundaer, Akzente, Hintergruende, Statusfarben — jeweils mit HEX-Code)
3. Typografie (Headlines, Body, Code — Schriftart + Groessen)
4. Tone of Voice (Kommunikationsstil, Beispiele, Verbote)
5. Bildsprache (Stil, Motive, Dont's)
6. Logo-Nutzung (Beschreibung, Platzierung, Schutzzonen)
7. Do's and Don'ts (je 5-7 Punkte)

Format: Markdown mit klaren Ueberschriften und konkreten Werten."""

        md_content = self._call_llm(prompt, max_tokens=8192)
        if not md_content:
            logger.error("Brand Book LLM call returned empty")
            return ""

        # Markdown speichern
        md_path = os.path.join(self.brand_book_path, "brand_book.md")
        header = (
            f"# DriveAI Factory — Brand Book\n\n"
            f"> Erstellt: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
            f"> Agent: MKT-01 (Brand Guardian)\n"
            f"> Version: 1.0\n\n---\n\n"
        )
        with open(md_path, "w", encoding="utf-8") as f:
            f.write(header + md_content)
        logger.info("Brand Book MD: %s (%d bytes)", md_path, os.path.getsize(md_path))

        # JSON-Version via zweiten LLM-Call
        json_prompt = f"""Basierend auf diesem Brand Book, erstelle eine maschinenlesbare JSON-Version.

BRAND BOOK:
{md_content[:6000]}

Antworte NUR mit dem JSON-Objekt, kein Markdown, kein erklaerenderText.
Exaktes Schema:
{{
  "brand_name": "DriveAI Factory",
  "version": "1.0",
  "created_at": "{datetime.now(timezone.utc).isoformat()}",
  "created_by": "MKT-01",
  "colors": {{
    "primary": "#hex",
    "primary_light": "#hex",
    "secondary": "#hex",
    "accent": "#hex",
    "accent_alt": "#hex",
    "background_dark": "#hex",
    "background_medium": "#hex",
    "text_light": "#hex",
    "text_muted": "#hex",
    "success": "#hex",
    "warning": "#hex",
    "error": "#hex"
  }},
  "fonts": {{
    "headline": "FontName",
    "body": "FontName",
    "code": "FontName"
  }},
  "tone": ["technisch-praezise", "selbstbewusst", "nicht-menschlich-imitierend"],
  "mascot": "Pulsierendes Gehirn, angeschlossen an Factory-Maschinerie",
  "visual_style": {{
    "backgrounds": "dunkel, Gradients von fast-schwarz zu dunkelblau/lila",
    "accents": "leuchtende Neon-Farben (Cyan, Lila, Gruen)",
    "imagery": "technisch, organisch, keine Stock-Photos",
    "animations": "subtil pulsierend, nicht flashig"
  }}
}}

Alle HEX-Werte aus dem Brand Book uebernehmen. Fehlende Werte sinnvoll ergaenzen."""

        json_response = self._call_llm(json_prompt, max_tokens=4096)
        brand_json = self._extract_json(json_response) if json_response else {}

        # Minimale Validierung + Fallback-Felder
        if "brand_name" not in brand_json:
            brand_json["brand_name"] = "DriveAI Factory"
        if "version" not in brand_json:
            brand_json["version"] = "1.0"
        if "created_at" not in brand_json:
            brand_json["created_at"] = datetime.now(timezone.utc).isoformat()
        if "created_by" not in brand_json:
            brand_json["created_by"] = "MKT-01"

        json_path = os.path.join(self.brand_book_path, "brand_book.json")
        with open(json_path, "w", encoding="utf-8") as f:
            json.dump(brand_json, f, indent=2, ensure_ascii=False)
        logger.info("Brand Book JSON: %s (%d bytes)", json_path, os.path.getsize(json_path))

        return md_path

    def create_app_style_sheet(self, project_slug: str) -> str:
        """Erstellt ein App-spezifisches Style Sheet.

        Args:
            project_slug: z.B. "echomatch"

        Returns:
            Pfad zum erstellten Style Sheet (JSON).
        """
        # Brand Book laden
        brand_book = self._load_brand_book_json()
        if not brand_book:
            logger.warning("No brand_book.json — creating brand book first")
            self.create_brand_book()
            brand_book = self._load_brand_book_json()

        # Projekt-Context laden
        project_context = ""
        try:
            from factory.marketing.input_loader import MarketingInputLoader
            loader = MarketingInputLoader()
            reports = loader.load_project_reports(project_slug)
            for dept, dept_reports in reports.items():
                for name, content in dept_reports.items():
                    project_context += f"\n--- {dept}/{name} ---\n{content[:1500]}\n"
        except Exception as e:
            logger.warning("Could not load project context: %s", e)

        prompt = f"""Erstelle ein App-spezifisches Style Sheet fuer "{project_slug}".

BRAND BOOK (Dachmarke):
{json.dumps(brand_book, indent=2, ensure_ascii=False)[:4000]}

PROJEKT-KONTEXT:
{project_context[:3000] if project_context else 'Keine Design-Vision vorhanden — leite aus Dachmarke ab.'}

Antworte NUR mit JSON, kein Markdown. Exaktes Schema:
{{
  "app_name": "{project_slug.replace('_', ' ').title()}",
  "project_slug": "{project_slug}",
  "derived_from": "brand_book v{brand_book.get('version', '1.0')}",
  "colors": {{
    "app_primary": "#hex",
    "app_secondary": "#hex",
    "app_accent": "#hex",
    "app_background": "#hex"
  }},
  "tone_adjustment": "Beschreibung wie sich der Ton der App von der Dachmarke unterscheidet",
  "visual_notes": "Spezifische visuelle Hinweise fuer diese App"
}}"""

        response = self._call_llm(prompt, max_tokens=4096)
        style_data = self._extract_json(response) if response else {}

        # Fallback-Felder
        if "app_name" not in style_data:
            style_data["app_name"] = project_slug.replace("_", " ").title()
        if "project_slug" not in style_data:
            style_data["project_slug"] = project_slug
        if "derived_from" not in style_data:
            style_data["derived_from"] = f"brand_book v{brand_book.get('version', '1.0')}"

        styles_dir = os.path.join(self.brand_book_path, "app_styles")
        os.makedirs(styles_dir, exist_ok=True)
        out_path = os.path.join(styles_dir, f"{project_slug}_style.json")
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(style_data, f, indent=2, ensure_ascii=False)
        logger.info("App Style Sheet: %s (%d bytes)", out_path, os.path.getsize(out_path))

        return out_path

    def check_brand_compliance(self, content: str, content_type: str = "social_post") -> dict:
        """Prueft Content auf Brand-Compliance.

        Args:
            content: Der zu pruefende Content (Text)
            content_type: Art des Contents (social_post, store_listing, blog, ad, video_script)

        Returns:
            dict mit compliant, score, issues, suggestions, checked_at, content_type, brand_book_version
        """
        brand_book = self._load_brand_book_json()
        if not brand_book:
            logger.warning("No brand_book.json — cannot check compliance")
            return {
                "compliant": False, "score": 0,
                "issues": ["Brand Book nicht vorhanden"],
                "suggestions": ["Erstelle zuerst ein Brand Book mit create_brand_book()"],
                "checked_at": datetime.now(timezone.utc).isoformat(),
                "content_type": content_type,
                "brand_book_version": "n/a",
            }

        # Tone und Visual-Style Regeln extrahieren
        tone_rules = brand_book.get("tone", [])
        visual_style = brand_book.get("visual_style", {})

        prompt = f"""Pruefe den folgenden {content_type} gegen unser Brand Book.

BRAND BOOK REGELN:
- Tone of Voice: {', '.join(tone_rules) if tone_rules else 'technisch-praezise, selbstbewusst'}
- Visual Style: {json.dumps(visual_style, ensure_ascii=False) if visual_style else 'dunkel, Neon-Akzente'}
- Die Factory ist ein eigenstaendiges KI-Wesen — keine Mensch-Imitation
- Factory-First Positionierung: Die Factory hat die App erschaffen

CONTENT ({content_type}):
{content[:4000]}

AUFGABE:
1. Bewerte den Content auf einer Skala von 0-100 (Brand-Compliance Score)
2. Liste alle Probleme auf (konkret, mit Zitat aus dem Content)
3. Gib Verbesserungsvorschlaege

Antworte NUR mit JSON:
{{
  "score": 85,
  "issues": ["Problem 1", "Problem 2"],
  "suggestions": ["Vorschlag 1", "Vorschlag 2"]
}}"""

        response = self._call_llm(prompt, max_tokens=2048)
        result = self._extract_json(response) if response else {}

        score = result.get("score", 0)
        return {
            "compliant": score >= 70,
            "score": score,
            "issues": result.get("issues", []),
            "suggestions": result.get("suggestions", []),
            "checked_at": datetime.now(timezone.utc).isoformat(),
            "content_type": content_type,
            "brand_book_version": brand_book.get("version", "unknown"),
        }

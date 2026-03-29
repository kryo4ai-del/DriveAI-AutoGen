"""ASO Content Agent (MKT-05) — App Store Optimization Spezialist.

Verantwortlich fuer:
- Keyword-Research (Primary, Secondary, Competitor Cluster)
- Lokalisierte Store-Listings (kulturelle Anpassung, nicht nur Uebersetzung)
- What's New Texte fuer Updates
- Wettbewerber-Keyword-Analyse
"""

import json
import logging
import os
from datetime import datetime
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.aso")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der ASO Content Agent der DriveAI Factory (MKT-05).

IDENTITAET:
Die Factory IST das Produkt. App Store Optimization ist ein Schluessel zur Sichtbarkeit der Factory-Produkte. Du optimierst nicht nur fuer Rankings, sondern positionierst jede App als Factory-Showcase.

EXPERTISE:
Du kennst die Unterschiede zwischen iOS App Store und Google Play:

iOS App Store:
- Keyword-Feld: max 100 Zeichen, kommagetrennt
- Title: max 30 Zeichen
- Subtitle: max 30 Zeichen
- Apple Search Ads Relevanz beeinflusst organisches Ranking
- Keywords im Keyword-Feld werden NICHT in Description wiederholt

Google Play:
- Kein separates Keyword-Feld
- Title: max 30 Zeichen
- Short Description: max 80 Zeichen (stark ranking-relevant)
- Full Description: max 4000 Zeichen (Keywords natuerlich einbauen)
- Google indexiert den gesamten Text

KEYWORD-STRATEGIE:
- Primary Keywords: Haupt-Suchbegriffe mit hohem Volumen
- Secondary Keywords: Long-Tail, spezifischere Begriffe
- Competitor Keywords: Wettbewerber-Namen als Keywords (wo erlaubt)
- Cluster-Denken: Verwandte Keywords gruppieren

LOKALISIERUNG:
Nicht nur uebersetzen — kulturell anpassen:
- DE: Formeller Ton, Datenschutz betonen, Qualitaet hervorheben
- US: Informeller, Feature-fokussiert, Social Proof
- Weitere Maerkte: LLM passt kulturell an

REGELN:
- Zeichenlimits EXAKT einhalten
- Factory-First Positionierung
- Keine Keyword-Stuffing — natuerlicher Lesefluss
- Eigenentwicklung vor externem Service (DIR-001)
"""

# --- Store Limits ---

IOS_LIMITS = {
    "title": 30,
    "subtitle": 30,
    "keywords": 100,
    "promotional_text": 170,
    "description": 4000,
}

ANDROID_LIMITS = {
    "title": 30,
    "short_description": 80,
    "full_description": 4000,
}


class ASOAgent:
    """ASO Content Agent — App Store Optimization."""

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH, BRAND_PATH

        self.output_path = OUTPUT_PATH
        self.brand_path = BRAND_PATH
        self.agent_info = self._load_persona()
        logger.info("ASO Agent initialized")

    def _load_persona(self) -> dict:
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_aso.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-05", "name": "ASO Content"}

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

    def _make_header(self, title: str, project_slug: str) -> str:
        return (
            f"# {title}\n\n"
            f"> Erstellt: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
            f"> Agent: MKT-05 (ASO Content)\n"
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

    def _serpapi_search(self, query: str) -> dict | None:
        """SerpAPI Suche mit Fehlerbehandlung.

        Returns: Suchergebnisse als dict, oder None bei Fehler/kein API Key.
        """
        api_key = os.environ.get("SERPAPI_API_KEY")
        if not api_key:
            logger.info("SerpAPI key not available")
            return None

        try:
            import requests

            params = {
                "q": query,
                "api_key": api_key,
                "num": 10,
            }
            resp = requests.get(
                "https://serpapi.com/search", params=params, timeout=10
            )
            if resp.status_code != 200:
                logger.warning("SerpAPI returned %d", resp.status_code)
                return None
            return resp.json()
        except Exception as e:
            logger.warning("SerpAPI search failed: %s", e)
            return None

    # --- Oeffentliche Methoden ---

    def keyword_research(
        self,
        project_slug: str,
        markets: list[str] = None,
    ) -> dict:
        """Keyword-Research fuer eine App.

        Default markets: ["US", "DE"]

        Returns:
            dict {"US": path, "DE": path, ...}
        """
        if markets is None:
            markets = ["US", "DE"]

        ctx = self._load_project_context(project_slug)
        results = {}

        for market in markets:
            # SerpAPI-Validierung fuer Top-Keywords
            serpapi_context = ""
            serpapi_available = os.environ.get("SERPAPI_API_KEY") is not None

            if serpapi_available:
                # Teste ein paar naheliegende Keywords
                test_queries = [
                    f"{project_slug} app",
                    f"puzzle game {market.lower()}",
                ]
                serpapi_results = []
                for q in test_queries:
                    data = self._serpapi_search(q)
                    if data:
                        organic = data.get("organic_results", [])[:3]
                        for r in organic:
                            serpapi_results.append(
                                f"  - '{q}': {r.get('title', '?')} ({r.get('link', '?')})"
                            )
                if serpapi_results:
                    serpapi_context = (
                        "\n\nSERPAPI ERGEBNISSE (echte Suchdaten):\n"
                        + "\n".join(serpapi_results)
                    )

            prompt = f"""Erstelle eine Keyword-Research fuer die App "{project_slug}" im Markt {market}.

APP-KONZEPT:
{ctx['story_brief'][:3000] if ctx['story_brief'] else 'Nicht verfuegbar.'}
{serpapi_context}

AUFGABE:
Erstelle eine strukturierte Keyword-Liste mit drei Clustern:

1. PRIMARY KEYWORDS (5-8):
   Haupt-Suchbegriffe mit geschaetztem Suchvolumen und Wettbewerb.
   Format: | Keyword | Volumen (geschaetzt) | Wettbewerb | Relevanz |

2. SECONDARY KEYWORDS (10-15):
   Long-Tail Keywords, spezifischere Begriffe.
   Format: | Keyword | Volumen | Wettbewerb | Relevanz |

3. COMPETITOR KEYWORDS (5-8):
   Keywords die Wettbewerber nutzen und die wir auch targeten sollten.
   Format: | Keyword | Hauptkonkurrent | Chance |

4. iOS KEYWORD-FELD VORSCHLAG:
   Exakt max 100 Zeichen, kommagetrennt, optimiert fuer Apple Search.
   Kein App-Name, keine Duplikate.

5. GOOGLE PLAY OPTIMIERUNG:
   Top-10 Keywords die in Title, Short Description und Full Description vorkommen sollen.

MARKT-SPEZIFISCH fuer {market}:
- {'Deutsch, formeller Ton' if market == 'DE' else 'Englisch, informeller Ton'}
- Lokale Suchgewohnheiten beruecksichtigen
{'- SerpAPI-Daten oben als Referenz nutzen' if serpapi_available else '- Keine Live-Daten verfuegbar, nutze dein Wissen'}"""

            response = self._call_llm(prompt, max_tokens=4096)
            if not response:
                continue

            file_path = os.path.join(
                self.output_path, project_slug, f"aso_keywords_{market}.md"
            )
            header = self._make_header(
                f"ASO Keyword Research — {project_slug} ({market})", project_slug
            )
            self._write_output(file_path, header + response)
            results[market] = file_path

        return results

    def create_localized_listing(
        self,
        project_slug: str,
        language: str = "de",
        market: str = "DE",
    ) -> str:
        """Erstellt ein komplett lokalisiertes Store-Listing.

        Returns:
            Pfad zur Output-Datei.
        """
        ctx = self._load_project_context(project_slug)

        # Lade Keywords wenn verfuegbar
        keywords_path = os.path.join(
            self.output_path, project_slug, f"aso_keywords_{market}.md"
        )
        keywords_context = ""
        if os.path.exists(keywords_path):
            with open(keywords_path, "r", encoding="utf-8") as f:
                keywords_context = f"\n\nKEYWORD-RESEARCH:\n{f.read()[:2000]}"

        cultural_hints = {
            "DE": "Formeller Ton, Datenschutz betonen, Qualitaet und Praezision hervorheben, 'Made in Germany' Mentalitaet",
            "US": "Informeller Ton, Feature-fokussiert, Social Proof betonen, Superlative erlaubt",
            "UK": "Britisch-hoeflicher Ton, understatement, Qualitaet subtil betonen",
            "FR": "Eleganter Ton, Lifestyle-Aspekte betonen, kulturelle Referenzen",
            "JP": "Hoeflichkeitsformen, detaillierte Feature-Beschreibungen, Kawaii-Elemente bei Games",
        }

        ios_limits = "\n".join(f"- {k}: max {v} Zeichen" for k, v in IOS_LIMITS.items())
        android_limits = "\n".join(f"- {k}: max {v} Zeichen" for k, v in ANDROID_LIMITS.items())

        prompt = f"""Erstelle ein lokalisiertes Store-Listing fuer "{project_slug}".

SPRACHE: {language.upper()}
MARKT: {market}

APP-KONZEPT:
{ctx['story_brief'][:3000] if ctx['story_brief'] else 'Nicht verfuegbar.'}
{keywords_context}

KULTURELLE ANPASSUNG fuer {market}:
{cultural_hints.get(market, 'Passe den Ton kulturell an den Markt an.')}

AUFGABE:
Erstelle BEIDE Store-Listings (iOS + Android) in einer Datei.

## iOS App Store
{ios_limits}
Gib jedes Feld mit Zeichenzahl an: **Feldname** (X/Y Zeichen)

## Google Play Store
{android_limits}
Gib jedes Feld mit Zeichenzahl an: **Feldname** (X/Y Zeichen)

WICHTIG:
- Dies ist KEINE Uebersetzung — es ist eine kulturelle Anpassung
- Keywords natuerlich einbauen (kein Stuffing)
- Factory-First Positionierung beibehalten
- Zeichenlimits EXAKT einhalten"""

        response = self._call_llm(prompt, max_tokens=8192)
        if not response:
            return ""

        file_path = os.path.join(
            self.output_path, project_slug, f"store_listing_{language}_{market}.md"
        )
        header = self._make_header(
            f"Localized Store Listing — {project_slug} ({language}/{market})",
            project_slug,
        )
        self._write_output(file_path, header + response)
        return file_path

    def create_whats_new(
        self,
        project_slug: str,
        version: str,
        changes_summary: str,
    ) -> str:
        """Schreibt What's New Text fuer ein Update.

        Returns:
            Markdown-String (kein File, direkt verwendbar).
        """
        prompt = f"""Schreibe What's New Texte fuer ein App-Update.

APP: {project_slug}
VERSION: {version}
AENDERUNGEN: {changes_summary}

Erstelle ZWEI Versionen:

1. iOS VERSION (max 4000 Zeichen):
   Ausfuehrlicher, kann Features detailliert beschreiben.

2. GOOGLE PLAY VERSION (max 500 Zeichen empfohlen):
   Kompakt, nur die wichtigsten Punkte.

Format:
## iOS What's New
[Text] (X Zeichen)

## Google Play What's New
[Text] (X Zeichen)

STIL: Enthusiastisch aber authentisch. Factory-Produkt-Updates."""

        response = self._call_llm(prompt, max_tokens=1024)
        return response or ""

    def competitor_keyword_analysis(
        self,
        competitors: list[str],
        market: str = "US",
    ) -> str:
        """Analysiert Wettbewerber-Keywords.

        Returns:
            Pfad zur Output-Datei.
        """
        # SerpAPI-basierte Analyse wenn verfuegbar
        serpapi_data = []
        for comp in competitors:
            data = self._serpapi_search(f"{comp} app")
            if data:
                organic = data.get("organic_results", [])[:5]
                entries = []
                for r in organic:
                    entries.append(f"  - {r.get('title', '?')}: {r.get('snippet', '')[:100]}")
                if entries:
                    serpapi_data.append(f"\n### {comp}\n" + "\n".join(entries))

        serpapi_context = ""
        if serpapi_data:
            serpapi_context = "\n\nSERPAPI ERGEBNISSE:\n" + "\n".join(serpapi_data)
        else:
            serpapi_context = "\n\nKeine SerpAPI-Daten verfuegbar. Nutze dein Wissen ueber diese Apps."

        prompt = f"""Analysiere die Keywords der folgenden Wettbewerber im Markt {market}.

WETTBEWERBER: {', '.join(competitors)}
{serpapi_context}

AUFGABE:
Pro Wettbewerber:
1. Geschaetzte Primary Keywords (5-8)
2. Store-Listing Analyse (welche Keywords nutzen sie in Title/Description)
3. Keyword-Gaps (Keywords die sie NICHT nutzen, die wir nutzen koennten)

ZUSAMMENFASSUNG:
- Top-10 Keyword-Chancen (Keywords mit niedrigem Wettbewerb und hoher Relevanz)
- Keywords die ALLE Wettbewerber nutzen (must-have)
- Keywords die KEIN Wettbewerber nutzt (Opportunity)

Format als Markdown-Tabellen."""

        response = self._call_llm(prompt, max_tokens=4096)
        if not response:
            return ""

        file_path = os.path.join(
            self.output_path, "aso", f"competitor_keywords_{market}.md"
        )
        header = (
            f"# Competitor Keyword Analysis — {market}\n\n"
            f"> Erstellt: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
            f"> Agent: MKT-05 (ASO Content)\n"
            f"> Wettbewerber: {', '.join(competitors)}\n\n---\n\n"
        )
        self._write_output(file_path, header + response)
        return file_path

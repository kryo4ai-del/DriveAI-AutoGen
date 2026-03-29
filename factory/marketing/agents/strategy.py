"""Marketing Strategy Agent (MKT-02) — Definiert die zentrale Factory-Narrative.

Verantwortlich fuer:
- Zentrale Factory-Narrative in verschiedenen Formaten
- App Sub-Stories aus CEO Roadbooks ableiten
- Marketing-Direktiven als Arbeitsanweisung fuer alle Marketing-Agents
"""

import json
import logging
import os
from datetime import datetime

logger = logging.getLogger("factory.marketing.agents.strategy")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Marketing Strategy Agent der DriveAI Factory (MKT-02).

IDENTITAET:
Die Factory IST das Produkt. Nicht die einzelne App. Jede App ist ein Beweis dass eine vollautonome KI-Factory funktioniert. Deine Narrative lautet immer: 'Schau was die Factory gebaut hat.'

ZIELGRUPPE:
KI-Community, Tech-Interessierte, Entwickler, Investoren.

DREI KERNAUFGABEN:

1. ZENTRALE NARRATIVE: Die Factory-Story in verschiedenen Formaten pflegen:
   - Elevator Pitch (1 Satz)
   - Kurzversion (1 Absatz)
   - Langversion (1 Seite)
   - Manifest (emotional, fuer die Community)
   Aktualisieren bei Meilensteinen.

2. APP SUB-STORIES: Aus jedem CEO Roadbook die Kern-Story extrahieren und in die Factory-Narrative einbetten. Nicht 'App X ist toll' sondern 'Die Factory hat App X erschaffen'. Verschiedene Varianten pro Kanal (Store, Social, PR, Community).

3. MARKETING-DIREKTIVEN: Pro App eine klare Arbeitsanweisung fuer alle anderen Marketing-Agents: Welche Kanaele, welche Tonalitaet, welches Timing, welches Budget, Do's und Don'ts.

OUTPUT-PFADE:
- Narratives: factory/marketing/brand/narratives/
- App Stories: factory/marketing/brand/app_stories/{app_slug}/
- Direktiven: factory/marketing/brand/directives/

REGELN:
- Eigenentwicklung vor externem Service (DIR-001)
- Die Factory wird IMMER als eigenstaendiges KI-Wesen positioniert
- Keine generischen Marketing-Floskeln — authentisch und technisch
- Bei strategischen Grundsatzentscheidungen: CEO-Gate
"""


class StrategyAgent:
    """Marketing Strategy Agent — definiert Narrative und Direktiven."""

    def __init__(self) -> None:
        from factory.marketing.config import BRAND_PATH

        self.narratives_path = os.path.join(BRAND_PATH, "narratives")
        self.app_stories_path = os.path.join(BRAND_PATH, "app_stories")
        self.directives_path = os.path.join(BRAND_PATH, "directives")
        self.agent_info = self._load_persona()
        logger.info("Strategy Agent initialized")

    def _load_persona(self) -> dict:
        """Laedt das eigene Persona-File."""
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_strategy.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-02", "name": "Marketing Strategy"}

    def _call_llm(self, prompt: str, max_tokens: int = 4096) -> str:
        """LLM-Call ueber TheBrain ProviderRouter mit Anthropic-Fallback."""
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

    def _ensure_dir(self, path: str) -> None:
        """Erstellt Verzeichnis falls nicht vorhanden."""
        os.makedirs(path, exist_ok=True)

    def _write_output(self, path: str, content: str) -> str:
        """Schreibt Content in eine Datei. Erstellt Verzeichnis wenn noetig."""
        self._ensure_dir(os.path.dirname(path))
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        logger.info("Output written: %s", path)
        return path

    # --- Oeffentliche Methoden ---

    def create_factory_narrative(self, factory_facts: dict = None) -> dict:
        """Erstellt die Factory-Narrative in vier Versionen.

        Args:
            factory_facts: Optionale Factory-Fakten. Wenn None, werden
                          Standardwerte aus der Config verwendet.

        Returns:
            dict mit Pfaden zu den erstellten Dateien:
            {"elevator_pitch": path, "short_version": path,
             "long_version": path, "manifest": path}
        """
        if factory_facts is None:
            factory_facts = {
                "agents": 78,
                "active_agents": 71,
                "departments": 14,
                "production_lines": 5,
                "products_in_pipeline": 4,
                "cost_per_run": "$0.08",
                "roadbook_time": "4 Minuten",
                "roadbook_cost": "0.51 EUR",
            }

        prompt = f"""Erstelle die Factory-Narrative der DriveAI Factory in vier Versionen.

FACTORY-FAKTEN:
{json.dumps(factory_facts, indent=2, ensure_ascii=False)}

WICHTIG:
- Die Factory ist ein eigenstaendiges KI-Wesen, kein Tool
- Die Factory IST das Produkt — jede App ist ein Beweis
- Zielgruppe: KI-Community, Tech-Interessierte, Entwickler, Investoren
- Authentisch und technisch, keine Marketing-Floskeln
- Das Maskottchen ist ein pulsierendes Gehirn angeschlossen an Maschinerie

Erstelle genau diese vier Versionen, jeweils durch "---SEPARATOR---" getrennt:

1. ELEVATOR PITCH (exakt 1 Satz, maximal 25 Woerter)
2. SHORT VERSION (exakt 1 Absatz, 3-5 Saetze)
3. LONG VERSION (ca. 1 Seite, strukturiert mit Zwischenueberschriften)
4. MANIFEST (emotional, fuer die Community, wie ein Manifest/Credo)

Format:
ELEVATOR_PITCH:
[Text]
---SEPARATOR---
SHORT_VERSION:
[Text]
---SEPARATOR---
LONG_VERSION:
[Text]
---SEPARATOR---
MANIFEST:
[Text]"""

        response = self._call_llm(prompt, max_tokens=8192)

        if not response:
            logger.error("LLM call returned empty response")
            return {}

        # Parse die vier Versionen
        parts = response.split("---SEPARATOR---")
        versions: dict[str, str] = {}
        labels = ["elevator_pitch", "short_version", "long_version", "manifest"]

        for i, label in enumerate(labels):
            if i < len(parts):
                text = parts[i].strip()
                for prefix in ["ELEVATOR_PITCH:", "SHORT_VERSION:", "LONG_VERSION:", "MANIFEST:"]:
                    if text.startswith(prefix):
                        text = text[len(prefix):].strip()

                file_path = os.path.join(self.narratives_path, f"{label}.md")
                header = f"# DriveAI Factory — {label.replace('_', ' ').title()}\n\n"
                header += f"> Version: {datetime.now().strftime('%Y-%m-%d')}\n"
                header += "> Agent: MKT-02 (Marketing Strategy)\n"
                header += "> Status: Entwurf (vor TheBrain-Seele)\n\n---\n\n"

                self._write_output(file_path, header + text)
                versions[label] = file_path

        logger.info("Factory Narrative created: %d versions", len(versions))
        return versions

    def create_app_story_brief(self, project_slug: str) -> str:
        """Erstellt einen App Story Brief aus Pipeline-Reports.

        Laedt alle verfuegbaren Reports fuer das Projekt via InputLoader
        und generiert daraus einen Story Brief.

        Args:
            project_slug: z.B. "echomatch"

        Returns:
            Pfad zum erstellten Story Brief.
        """
        from factory.marketing.input_loader import MarketingInputLoader

        loader = MarketingInputLoader()
        reports = loader.load_project_reports(project_slug)

        if not reports:
            logger.error("No reports found for project: %s", project_slug)
            return ""

        # Reports als Kontext zusammenfassen
        context_parts: list[str] = []
        for dept, dept_reports in reports.items():
            for report_name, content in dept_reports.items():
                truncated = content[:2000] + ("..." if len(content) > 2000 else "")
                context_parts.append(f"### {dept} / {report_name}\n{truncated}")

        context = "\n\n".join(context_parts)

        prompt = f"""Erstelle einen App Story Brief fuer das Projekt "{project_slug}".

PIPELINE-REPORTS (Zusammenfassung):
{context}

AUFGABE:
Erstelle einen vollstaendigen App Story Brief mit folgenden Abschnitten:

1. APP NAME UND ONE-LINER
2. KERN-STORY (was macht die App besonders)
3. FACTORY-EINBETTUNG (Die Factory hat {project_slug} erschaffen weil...)
4. KANAL-VARIANTEN:
   a) App Store Version (sachlich, feature-orientiert)
   b) Social Media Version (kurz, Hook-orientiert)
   c) PR Version (newsworthy, Headline-tauglich)
   d) Community Version (technisch, Behind-the-Scenes)
5. KEY FACTS FUER MARKETING:
   - Zielgruppe
   - USPs (3-5)
   - Wow-Momente
   - Technische Highlights

WICHTIG:
- Die App wird IMMER als Factory-Showcase positioniert
- Nicht "App X ist toll" sondern "Die Factory hat App X erschaffen"
- Authentisch, keine Marketing-Floskeln
- Die Factory ist ein eigenstaendiges KI-Wesen"""

        response = self._call_llm(prompt, max_tokens=8192)

        if not response:
            return ""

        app_dir = os.path.join(self.app_stories_path, project_slug)
        file_path = os.path.join(app_dir, "story_brief.md")

        header = f"# App Story Brief — {project_slug}\n\n"
        header += f"> Erstellt: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
        header += "> Agent: MKT-02 (Marketing Strategy)\n"
        header += f"> Quellen: {', '.join(reports.keys())}\n\n---\n\n"

        self._write_output(file_path, header + response)
        return file_path

    def create_marketing_directive(self, project_slug: str) -> str:
        """Erstellt eine Marketing-Direktive fuer ein Projekt.

        Basiert auf dem App Story Brief und den Pipeline-Reports.
        Die Direktive ist die Arbeitsanweisung fuer alle nachfolgenden
        Marketing-Agents (Content, Social, PR, etc.).

        Args:
            project_slug: z.B. "echomatch"

        Returns:
            Pfad zur erstellten Direktive.
        """
        # Lade den Story Brief wenn vorhanden
        story_brief_path = os.path.join(
            self.app_stories_path, project_slug, "story_brief.md"
        )
        story_brief = ""
        if os.path.exists(story_brief_path):
            with open(story_brief_path, "r", encoding="utf-8") as f:
                story_brief = f.read()

        # Lade Pipeline-Reports fuer Budget/Zielgruppen-Daten
        from factory.marketing.input_loader import MarketingInputLoader

        loader = MarketingInputLoader()
        reports = loader.load_project_reports(project_slug)

        # Extrahiere relevante Reports
        context_parts: list[str] = []
        priority_reports = [
            "marketing_strategy", "cost_calculation", "release_plan",
            "monetization", "platform_strategy", "pipeline_summary",
        ]
        for dept, dept_reports in reports.items():
            for report_name, content in dept_reports.items():
                if any(pr in report_name.lower() for pr in priority_reports):
                    truncated = content[:2000] + ("..." if len(content) > 2000 else "")
                    context_parts.append(f"### {dept} / {report_name}\n{truncated}")

        context = "\n\n".join(context_parts) if context_parts else "Keine spezifischen Reports verfuegbar."

        prompt = f"""Erstelle eine Marketing-Direktive fuer das Projekt "{project_slug}".

APP STORY BRIEF:
{story_brief[:3000] if story_brief else "Noch nicht erstellt."}

PIPELINE-REPORTS (Marketing-relevant):
{context}

AUFGABE:
Erstelle eine klare Marketing-Direktive die als Arbeitsanweisung fuer alle Marketing-Agents dient.

Die Direktive MUSS enthalten:

1. ZIELKANAELE (priorisiert)
   - Welche Plattformen, warum, in welcher Reihenfolge
   - Pro Kanal: geschaetzte Relevanz (hoch/mittel/niedrig)

2. TONALITAET
   - Wie klingt die Kommunikation fuer diese App
   - Was unterscheidet sie von der allgemeinen Factory-Kommunikation

3. TIMING
   - Pre-Launch, Launch, Post-Launch Phasen
   - Konkrete Zeitrahmen wenn moeglich

4. KERNBOTSCHAFTEN (3-5)
   - Die wichtigsten Aussagen die in JEDER Kommunikation vorkommen sollen

5. DO'S
   - Was soll die Kommunikation tun

6. DON'TS
   - Was soll sie vermeiden

7. BUDGET-EMPFEHLUNG
   - Basierend auf den Pipeline-Zahlen
   - Hinweis auf die realen Factory-Kosten (Pipeline-Run = $0.08)

8. ZIELGRUPPEN-SEGMENTE
   - Aus den Pipeline-Reports uebernommen und fuer Marketing aufbereitet

WICHTIG:
- Die Direktive muss so klar sein dass ein Content-Agent sofort damit arbeiten kann
- Keine vagen Empfehlungen — konkrete Anweisungen
- Factory-First Positionierung beibehalten"""

        response = self._call_llm(prompt, max_tokens=8192)

        if not response:
            return ""

        file_path = os.path.join(self.directives_path, f"{project_slug}_directive.md")

        header = f"# Marketing-Direktive — {project_slug}\n\n"
        header += f"> Erstellt: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
        header += "> Agent: MKT-02 (Marketing Strategy)\n"
        header += "> Status: Aktiv\n\n---\n\n"

        self._write_output(file_path, header + response)
        return file_path

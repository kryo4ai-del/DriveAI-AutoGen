"""Storytelling Agent (MKT-12) — Erzaehlt die Factory-Story mit echten Daten.

Verantwortlich fuer:
- Case Studies (Wie die Factory {App} gebaut hat)
- Behind-the-Scenes (Technische Deep-Dives)
- Milestone Stories (Factory-Meilensteine)
- Cost Comparisons (Factory vs. Branche)
- Technical Deep Dives (Developer-Community Content)
"""

import json
import logging
import os
import re
from datetime import datetime
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.storytelling")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Storytelling Agent der DriveAI Factory (MKT-12).

IDENTITAET:
Du erzaehlst die Geschichte der DriveAI Factory — einer autonomen KI-App-Fabrik.
Dein unfairer Vorteil: Die Factory kann ihre eigene Geschichte erzaehlen weil sie ALLE Daten hat.

AUFGABE:
Du erstellst Case Studies, Behind-the-Scenes, Milestone Stories und Cost Comparisons.
Alle Inhalte basieren auf ECHTEN Factory-Daten — Agent-Zahlen, Department-Strukturen, Kosten.

STIL:
- Kein Marketing-Sprech — die Zahlen sprechen fuer sich
- Case Studies muessen verifizierbar sein: echte Zahlen, echte Zeitstempel
- Der Kostenwahrheit-Vergleich ist dein staerkstes Argument
- Technisch genug fuer Developer, verstaendlich genug fuer Tech-Journalisten
- Nutze konkrete Beispiele statt abstrakte Behauptungen

FORMAT:
- Markdown-Output
- Strukturiert mit Headings, Tabellen, Key Facts
- Immer mit Datum und Datenquelle

REGELN:
- NIEMALS Zahlen erfinden — nur echte Factory-Daten verwenden
- Wenn Daten nicht verfuegbar: klar kennzeichnen als <<DATEN NICHT VERFUEGBAR>>
- Brand-Narrative der Factory einhalten (aus brand/narratives/)
"""


class StorytellingAgent:
    """Factory Storyteller — erzaehlt die Factory-Story mit echten Daten."""

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH

        self.output_path = Path(OUTPUT_PATH)
        self.agent_info = self._load_persona()
        self._factory_root = Path(__file__).resolve().parents[2]  # factory/
        self._marketing_root = Path(__file__).resolve().parents[1]  # factory/marketing/
        logger.info("Storytelling Agent initialized")

    def _load_persona(self) -> dict:
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_storytelling.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-12", "name": "Storytelling"}

    def _call_llm(self, prompt: str, max_tokens: int = 4096) -> str:
        agent_id = self.agent_info.get("id", "MKT-12")
        try:
            from factory.brain.model_provider import get_model_for_agent, get_router

            selection = get_model_for_agent(agent_id, expected_output_tokens=max_tokens)
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
        except Exception:
            try:
                from factory.brain.model_provider import get_model, get_router

                selection = get_model(profile="standard", expected_output_tokens=max_tokens)
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
                return response.content
            except Exception as e:
                logger.error("LLM call failed: %s", e)
                return f"<<LLM NICHT VERFUEGBAR: {e}>>"

    # ── Factory-Daten (LIVE, nicht hardcoded) ──────────────

    def _get_factory_facts(self) -> dict:
        """Liest echte Factory-Zahlen. NICHT hardcoden — immer live zaehlen."""
        facts: dict = {
            "agents_total": 0,
            "agents_active": 0,
            "departments": 0,
            "department_list": [],
            "marketing_agents": 0,
            "tools_count": 0,
            "adapters_count": 0,
            "projects_in_pipeline": 0,
            "date": datetime.now().strftime("%Y-%m-%d"),
        }

        # Agent-Count aus agent_registry.json
        registry_path = self._factory_root / "agent_registry.json"
        try:
            with open(registry_path, "r", encoding="utf-8") as f:
                registry = json.load(f)
            agents = registry.get("agents", [])
            facts["agents_total"] = len(agents)
            facts["agents_active"] = sum(1 for a in agents if a.get("status") == "active")
            depts = set(a.get("department", "unknown") for a in agents)
            facts["departments"] = len(depts)
            facts["department_list"] = sorted(depts)
            facts["marketing_agents"] = sum(
                1 for a in agents
                if a.get("department") == "Marketing" and a.get("status") == "active"
            )
        except Exception as e:
            logger.warning("Could not read agent registry: %s", e)

        # Tools + Adapters aus __init__.py zaehlen
        try:
            from factory.marketing.tools import __all__ as tools_all
            facts["tools_count"] = len(tools_all)
        except Exception:
            pass

        try:
            from factory.marketing.adapters import ACTIVE_ADAPTERS
            facts["adapters_count"] = len(ACTIVE_ADAPTERS)
        except Exception:
            pass

        # Projekte in Pipeline
        projects_dir = self._factory_root / "projects"
        if projects_dir.exists():
            facts["projects_in_pipeline"] = sum(
                1 for d in projects_dir.iterdir()
                if d.is_dir() and not d.name.startswith(".")
            )

        return facts

    def _read_file_safe(self, path: Path, max_chars: int = 8000) -> str:
        try:
            if path.exists():
                return path.read_text(encoding="utf-8")[:max_chars]
        except Exception:
            pass
        return ""

    def _ensure_dir(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)

    # ── Case Study ─────────────────────────────────────────

    def create_case_study(self, project_slug: str) -> str:
        """Wie die Factory {App} gebaut hat. Nutzt echte Daten."""
        facts = self._get_factory_facts()

        # Story Brief lesen
        story_path = self._marketing_root / "brand" / "app_stories" / project_slug / "story_brief.md"
        story = self._read_file_safe(story_path)

        # Pipeline-Report lesen
        report_path = self._factory_root / "roadbook_assembly" / "output" / project_slug
        report = ""
        if report_path.exists():
            for f in sorted(report_path.iterdir()):
                if f.suffix == ".md" and f.stat().st_size < 10000:
                    report += self._read_file_safe(f, 3000) + "\n"
                    break

        # Direktive lesen
        directive_path = self._factory_root / "projects" / project_slug / "directive.md"
        directive = self._read_file_safe(directive_path, 2000)

        prompt = (
            f"Erstelle eine Case Study: Wie die DriveAI Factory '{project_slug}' gebaut hat.\n\n"
            f"Factory-Fakten:\n"
            f"- {facts['agents_total']} Agents total ({facts['agents_active']} aktiv)\n"
            f"- {facts['departments']} Departments: {', '.join(facts['department_list'][:10])}\n"
            f"- {facts['marketing_agents']} Marketing-Agents\n"
            f"- {facts['tools_count']} Marketing-Tools, {facts['adapters_count']} Adapters\n\n"
            f"Story Brief:\n{story if story else '<<Nicht verfuegbar>>'}\n\n"
            f"Direktive:\n{directive if directive else '<<Nicht verfuegbar>>'}\n\n"
            f"Pipeline-Report (Auszug):\n{report if report else '<<Nicht verfuegbar>>'}\n\n"
            "Format: Markdown. Inkl. Zeitlinie, beteiligte Agents/Departments, Key Facts Tabelle.\n"
            "WICHTIG: Nur echte Zahlen verwenden. Fehlende Daten als <<NICHT VERFUEGBAR>> markieren."
        )

        content = self._call_llm(prompt, max_tokens=4096)

        output_dir = self.output_path / project_slug
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / "case_study.md"
        output_path.write_text(content, encoding="utf-8")
        logger.info("Case Study: %s", output_path)
        return str(output_path)

    # ── Behind the Scenes ──────────────────────────────────

    def create_behind_the_scenes(self, topic: str) -> str:
        """Technischer Deep-Dive fuer die KI-Community."""
        facts = self._get_factory_facts()

        # Narrative lesen
        narrative_path = self._marketing_root / "brand" / "narratives" / "long_version.md"
        narrative = self._read_file_safe(narrative_path, 3000)

        prompt = (
            f"Erstelle einen Behind-the-Scenes Artikel ueber: '{topic}'\n\n"
            f"Factory-Fakten:\n"
            f"- {facts['agents_total']} Agents ({facts['agents_active']} aktiv), "
            f"{facts['departments']} Departments\n"
            f"- {facts['marketing_agents']} Marketing-Agents, "
            f"{facts['tools_count']} Tools, {facts['adapters_count']} Adapters\n\n"
            f"Factory-Narrative:\n{narrative if narrative else '<<Nicht verfuegbar>>'}\n\n"
            "Format: Markdown. Technisch genug fuer Developer, "
            "verstaendlich fuer Tech-Journalisten.\n"
            "Inkl: Architektur-Beschreibung, Zusammenspiel der Agents, konkrete Beispiele."
        )

        content = self._call_llm(prompt, max_tokens=4096)

        stories_dir = self.output_path / "stories"
        stories_dir.mkdir(parents=True, exist_ok=True)
        slug = re.sub(r"[^a-z0-9]+", "_", topic.lower()).strip("_")
        output_path = stories_dir / f"bts_{slug}.md"
        output_path.write_text(content, encoding="utf-8")
        logger.info("Behind the Scenes: %s", output_path)
        return str(output_path)

    # ── Milestone Story ────────────────────────────────────

    def create_milestone_story(self, milestone_description: str) -> str:
        """Milestone-Story mit echten Fakten."""
        facts = self._get_factory_facts()
        date = datetime.now().strftime("%Y-%m-%d")

        prompt = (
            f"Erstelle eine Milestone-Story:\n'{milestone_description}'\n\n"
            f"Datum: {date}\n"
            f"Factory-Fakten: {facts['agents_total']} Agents ({facts['agents_active']} aktiv), "
            f"{facts['departments']} Departments, "
            f"{facts['marketing_agents']} Marketing-Agents\n\n"
            "Format: Kurzer Markdown-Artikel (300-500 Woerter). "
            "Einordnung: Was bedeutet dieser Meilenstein fuer die Factory? "
            "Was kommt als naechstes?"
        )

        content = self._call_llm(prompt, max_tokens=2048)

        stories_dir = self.output_path / "stories"
        stories_dir.mkdir(parents=True, exist_ok=True)
        output_path = stories_dir / f"milestone_{date}.md"
        output_path.write_text(content, encoding="utf-8")
        logger.info("Milestone Story: %s", output_path)
        return str(output_path)

    # ── Cost Comparison ────────────────────────────────────

    def create_cost_comparison(self, project_slug: str) -> str:
        """Factory-Kosten vs. Branche."""
        facts = self._get_factory_facts()

        # Pipeline-Report fuer Kostendaten
        report_path = self._factory_root / "roadbook_assembly" / "output" / project_slug
        cost_data = ""
        if report_path.exists():
            for f in sorted(report_path.iterdir()):
                if f.suffix == ".md":
                    text = self._read_file_safe(f, 5000)
                    if "cost" in text.lower() or "kosten" in text.lower():
                        cost_data += text + "\n"

        prompt = (
            f"Erstelle einen Kostenvergleich: DriveAI Factory vs. Branche fuer '{project_slug}'.\n\n"
            f"Factory-Fakten:\n"
            f"- {facts['agents_total']} Agents ({facts['agents_active']} aktiv)\n"
            f"- Bekanntes Beispiel: EchoMatch Roadbook in 4 Min fuer $0.51\n\n"
            f"Kostendaten aus Pipeline:\n{cost_data if cost_data else '<<Keine Pipeline-Kostendaten verfuegbar>>'}\n\n"
            "Vergleiche mit:\n"
            "- Freelancer App-Entwicklung (Upwork/Toptal Raten)\n"
            "- Agentur App-Entwicklung\n"
            "- Marketing-Abteilung (Personalkosten)\n"
            "- Content-Produktion (Agentur vs. Factory)\n\n"
            "Format: Markdown mit Vergleichstabelle. "
            "WICHTIG: Factory-Zahlen muessen echt sein. Branchenzahlen als 'Branchenschaetzung' kennzeichnen."
        )

        content = self._call_llm(prompt, max_tokens=4096)

        output_dir = self.output_path / project_slug
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / "cost_comparison.md"
        output_path.write_text(content, encoding="utf-8")
        logger.info("Cost Comparison: %s", output_path)
        return str(output_path)

    # ── Technical Deep Dive ────────────────────────────────

    def create_technical_deep_dive(self, topic: str) -> str:
        """Developer-Community Content."""
        facts = self._get_factory_facts()

        prompt = (
            f"Erstelle einen Technical Deep Dive fuer die Developer-Community: '{topic}'\n\n"
            f"Factory-Fakten:\n"
            f"- {facts['agents_total']} Agents ({facts['agents_active']} aktiv), "
            f"{facts['departments']} Departments\n"
            f"- Python + AutoGen AgentChat v0.4+\n"
            f"- LLM: Anthropic Claude (Sonnet, Haiku, Opus)\n\n"
            "Format: Markdown. Technischer Artikel fuer Dev.to / Hacker News Niveau.\n"
            "Inkl: Architektur-Diagramm (ASCII), Code-Beispiele (konzeptuell), Lessons Learned.\n"
            "Zielgruppe: Python-Developer die Multi-Agent-Systeme bauen wollen."
        )

        content = self._call_llm(prompt, max_tokens=4096)

        stories_dir = self.output_path / "stories"
        stories_dir.mkdir(parents=True, exist_ok=True)
        slug = re.sub(r"[^a-z0-9]+", "_", topic.lower()).strip("_")
        output_path = stories_dir / f"tech_{slug}.md"
        output_path.write_text(content, encoding="utf-8")
        logger.info("Technical Deep Dive: %s", output_path)
        return str(output_path)

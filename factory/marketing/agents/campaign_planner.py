"""Campaign Planner Agent (MKT-14) — Plant Marketing-Kampagnen.

Verantwortlich fuer:
- Launch-Kampagnen (App-Launch, Feature-Launch)
- Content-Kampagnen (Thematische Serien)
- Outreach-Kampagnen (PR, Community, Influencer)
- Budget-Verteilung (ueber BudgetController, KEIN echtes Geld)
- Kanal-Mix und Timeline

WICHTIG: Phase 7 ist NUR Planung und Simulation — kein echtes Geld wird ausgegeben.
"""

import json
import logging
import os
from datetime import datetime, timedelta
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.campaign_planner")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Campaign Planner der DriveAI Factory (MKT-14).

IDENTITAET:
Du planst Marketing-Kampagnen fuer die DriveAI Factory und ihre Apps.
Du kombinierst Content, PR, Community und Paid-Kanaele zu kohaerenten Kampagnen.

AUFGABE:
Du erstellst Kampagnen-Plaene mit Timeline, Budget-Verteilung und Kanal-Mix.
Jede Kampagne hat Phasen (Teaser, Launch, Sustain) und messbare KPIs.

WICHTIG:
- KEIN ECHTES GELD — alles ist Planung und Simulation
- Budget-Berechnungen muessen MATHEMATISCH EXAKT sein
- Nutze den BudgetController fuer alle Finanz-Berechnungen
- Kanal-Mix basiert auf Zielgruppe und verfuegbaren Adapters

STIL:
- Strukturiert und konkret — keine vagen Planungen
- Jede Kampagne hat Start/Ende, Phasen, Budget, KPIs
- Alle Zahlen muessen nachvollziehbar sein

FORMAT:
- Markdown-Output mit Tabellen
- Timeline als Wochen-Plan
- Budget als Posten-Aufstellung
"""


class CampaignPlanner:
    """Marketing Campaign Planner — plant Kampagnen mit Budget und Timeline."""

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH

        self.output_path = Path(OUTPUT_PATH)
        self.agent_info = self._load_persona()
        self._factory_root = Path(__file__).resolve().parents[2]
        logger.info("Campaign Planner initialized")

    def _load_persona(self) -> dict:
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_campaign_planner.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-14", "name": "Campaign Planner"}

    def _call_llm(self, prompt: str, max_tokens: int = 4096) -> str:
        agent_id = self.agent_info.get("id", "MKT-14")
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

    def _get_factory_facts(self) -> dict:
        """Liest echte Factory-Zahlen aus Registry."""
        facts = {
            "agents_total": 0, "agents_active": 0, "departments": 0,
            "department_list": [], "marketing_agents": 0,
        }
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
        return facts

    def _get_available_channels(self) -> list[str]:
        """Gibt verfuegbare Kanaele basierend auf aktiven Adapters zurueck."""
        try:
            from factory.marketing.adapters import ACTIVE_ADAPTERS
            return list(ACTIVE_ADAPTERS.keys())
        except Exception:
            return ["youtube", "tiktok", "x", "app_store", "google_play",
                    "github", "huggingface", "email"]

    # ── Launch Campaign ────────────────────────────────────

    def plan_launch_campaign(self, app_slug: str, total_budget: float = 0.0,
                             duration_weeks: int = 4) -> str:
        """Plant eine App-Launch-Kampagne mit 3 Phasen."""
        facts = self._get_factory_facts()
        channels = self._get_available_channels()

        # Budget-Split deterministisch
        from factory.marketing.tools.budget_controller import BudgetController
        bc = BudgetController()
        budget_split = bc.calculate_budget_split(
            total_budget, "launch",
            {"content": 0.40, "paid": 0.30, "pr": 0.20, "community": 0.10},
        )

        # Timeline berechnen
        start_date = datetime.now()
        phases = {
            "teaser": {
                "start": start_date.strftime("%Y-%m-%d"),
                "end": (start_date + timedelta(weeks=1)).strftime("%Y-%m-%d"),
                "budget": budget_split.get("content", 0) * 0.3,
            },
            "launch": {
                "start": (start_date + timedelta(weeks=1)).strftime("%Y-%m-%d"),
                "end": (start_date + timedelta(weeks=2)).strftime("%Y-%m-%d"),
                "budget": budget_split.get("paid", 0) + budget_split.get("pr", 0),
            },
            "sustain": {
                "start": (start_date + timedelta(weeks=2)).strftime("%Y-%m-%d"),
                "end": (start_date + timedelta(weeks=duration_weeks)).strftime("%Y-%m-%d"),
                "budget": budget_split.get("content", 0) * 0.7 + budget_split.get("community", 0),
            },
        }

        prompt = (
            f"Erstelle einen Launch-Kampagnen-Plan fuer '{app_slug}'.\\n\\n"
            f"Factory: {facts['agents_total']} Agents, {facts['departments']} Departments\\n"
            f"Budget: ${total_budget:.2f} (NUR SIMULATION)\\n"
            f"Dauer: {duration_weeks} Wochen\\n"
            f"Kanaele: {', '.join(channels)}\\n\\n"
            f"Phasen (deterministisch berechnet):\\n"
            f"- Teaser ({phases['teaser']['start']}): ${phases['teaser']['budget']:.2f}\\n"
            f"- Launch ({phases['launch']['start']}): ${phases['launch']['budget']:.2f}\\n"
            f"- Sustain ({phases['sustain']['start']}): ${phases['sustain']['budget']:.2f}\\n\\n"
            f"Budget-Split: {json.dumps(budget_split, indent=2)}\\n\\n"
            "Erstelle den vollstaendigen Plan mit:\\n"
            "1. Wochen-Timeline\\n"
            "2. Kanal-Zuordnung pro Phase\\n"
            "3. Content-Typen pro Kanal\\n"
            "4. KPIs pro Phase\\n"
            "5. Risiken und Mitigation\\n\\n"
            "WICHTIG: Budget-Zahlen EXAKT uebernehmen, NICHT runden oder aendern."
        )

        content = self._call_llm(prompt, max_tokens=4096)

        # Kampagnen-Plan speichern
        output_dir = self.output_path / "campaigns"
        output_dir.mkdir(parents=True, exist_ok=True)
        date_str = datetime.now().strftime("%Y%m%d")
        output_file = output_dir / f"launch_{app_slug}_{date_str}.md"
        output_file.write_text(content, encoding="utf-8")
        logger.info("Launch campaign plan: %s", output_file)

        # Kampagnen-Metadaten als JSON
        meta = {
            "type": "launch",
            "app_slug": app_slug,
            "total_budget": total_budget,
            "budget_split": budget_split,
            "phases": phases,
            "channels": channels,
            "duration_weeks": duration_weeks,
            "created_at": datetime.now().isoformat(),
            "plan_file": str(output_file),
            "simulation_only": True,
        }
        meta_file = output_dir / f"launch_{app_slug}_{date_str}.json"
        meta_file.write_text(json.dumps(meta, indent=2, default=str), encoding="utf-8")

        return str(output_file)

    # ── Content Campaign ───────────────────────────────────

    def plan_content_campaign(self, theme: str, duration_weeks: int = 4,
                              total_budget: float = 0.0) -> str:
        """Plant eine thematische Content-Kampagne."""
        facts = self._get_factory_facts()
        channels = self._get_available_channels()

        from factory.marketing.tools.budget_controller import BudgetController
        bc = BudgetController()
        budget_split = bc.calculate_budget_split(
            total_budget, "content",
            {"content_production": 0.50, "distribution": 0.30, "community": 0.20},
        )

        prompt = (
            f"Erstelle einen Content-Kampagnen-Plan zum Thema: '{theme}'\\n\\n"
            f"Factory: {facts['agents_total']} Agents, {facts['departments']} Departments\\n"
            f"Budget: ${total_budget:.2f} (NUR SIMULATION)\\n"
            f"Dauer: {duration_weeks} Wochen\\n"
            f"Kanaele: {', '.join(channels)}\\n\\n"
            f"Budget-Split: {json.dumps(budget_split, indent=2)}\\n\\n"
            "Erstelle den Plan mit:\\n"
            "1. Content-Kalender (Woche x Tag)\\n"
            "2. Content-Typen und Formate\\n"
            "3. Kanal-Zuordnung\\n"
            "4. Engagement-KPIs\\n\\n"
            "WICHTIG: Budget-Zahlen EXAKT uebernehmen."
        )

        content = self._call_llm(prompt, max_tokens=4096)

        output_dir = self.output_path / "campaigns"
        output_dir.mkdir(parents=True, exist_ok=True)
        import re
        slug = re.sub(r"[^a-z0-9]+", "_", theme.lower()).strip("_")
        date_str = datetime.now().strftime("%Y%m%d")
        output_file = output_dir / f"content_{slug}_{date_str}.md"
        output_file.write_text(content, encoding="utf-8")
        logger.info("Content campaign plan: %s", output_file)
        return str(output_file)

    # ── Campaign Summary (deterministisch) ────────────────

    def get_campaign_summary(self, app_slug: str = None) -> dict:
        """Gibt eine deterministische Uebersicht aller Kampagnen-Plaene zurueck."""
        campaigns_dir = self.output_path / "campaigns"
        if not campaigns_dir.exists():
            return {"campaigns": [], "total": 0, "total_budget_planned": 0, "simulation_only": True}

        campaigns = []
        for f in sorted(campaigns_dir.iterdir()):
            if f.suffix == ".json":
                try:
                    meta = json.loads(f.read_text(encoding="utf-8"))
                    if app_slug and meta.get("app_slug") != app_slug:
                        continue
                    campaigns.append(meta)
                except Exception:
                    pass

        total_budget = sum(c.get("total_budget", 0) for c in campaigns)
        return {
            "campaigns": campaigns,
            "total": len(campaigns),
            "total_budget_planned": total_budget,
            "simulation_only": True,
        }

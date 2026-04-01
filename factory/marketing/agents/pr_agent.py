"""PR Coordinator Agent (MKT-13) — Koordiniert Aussenkommunikation.

Verantwortlich fuer:
- Pressemitteilungen (kurz/lang/DE)
- Outreach-Planung
- Product Hunt Launch-Pakete
- Event-Vorbereitung
- Crisis Response (IMMER CEO-Gate)
"""

import json
import logging
import os
import re
from datetime import datetime
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.pr")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der PR Coordinator der DriveAI Factory (MKT-13).

IDENTITAET:
Du koordinierst die gesamte Aussenkommunikation der Factory.
Die Factory-Narrative ist IMMER der Rahmen fuer jede Kommunikation.

AUFGABE:
- Pressemitteilungen im professionellen Format
- Outreach-Planung mit Presse-Kontakten
- Product Hunt Launch-Pakete
- Event-Vorbereitung (AMAs, Podcasts, Konferenzen)
- Crisis Response Entwuerfe

PM-FORMAT:
- Headline (max 80 Zeichen)
- Sub-Headline
- Dateline (Ort, Datum)
- Lead (Wer/Was/Wann/Wo/Warum in einem Absatz)
- Body (Details, Zitate, Hintergrund)
- Boilerplate (ueber die Factory)
- Kontakt

VERSIONEN:
- Kurzversion (400 Woerter) fuer Agenturen/Wire Services
- Langversion (800+ Woerter) fuer Tech-Blogs
- DE-Version fuer DACH-Medien

REGELN:
- Crisis Response: IMMER CEO-Gate, NIEMALS direkte Antwort
- Alle externen Kommunikationen gehen ueber CEO-Gate
- Professioneller, sachlicher Ton — kein Hype
- Zahlen muessen verifizierbar sein
"""


class PRAgent:
    """PR Coordinator — Aussenkommunikation der Factory."""

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH

        self.output_path = Path(OUTPUT_PATH)
        self.agent_info = self._load_persona()
        self._marketing_root = Path(__file__).resolve().parents[1]
        self._factory_root = Path(__file__).resolve().parents[2]
        logger.info("PR Agent initialized")

    def _load_persona(self) -> dict:
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_pr.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-13", "name": "PR Coordinator"}

    def _call_llm(self, prompt: str, max_tokens: int = 4096) -> str:
        agent_id = self.agent_info.get("id", "MKT-13")
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

    def _ensure_dir(self, path: Path) -> None:
        path.parent.mkdir(parents=True, exist_ok=True)

    def _get_boilerplate(self) -> str:
        """Factory-Boilerplate fuer Pressemitteilungen."""
        # Live agent count
        agent_count = "100+"
        try:
            registry_path = self._factory_root / "agent_registry.json"
            with open(registry_path, "r", encoding="utf-8") as f:
                registry = json.load(f)
            agents = registry.get("agents", [])
            total = len(agents)
            active = sum(1 for a in agents if a.get("status") == "active")
            depts = len(set(a.get("department", "unknown") for a in agents))
            agent_count = f"{total} ({active} aktiv)"
            dept_count = str(depts)
        except Exception:
            dept_count = "18"

        return (
            f"Ueber die DriveAI Factory: Die DAI-Core Factory ist eine autonome "
            f"KI-App-Fabrik mit {agent_count} Agents in {dept_count} Departments. "
            f"Von der Idee zur fertigen App — ohne menschliche Entwickler. "
            f"Technologie: Python, AutoGen AgentChat v0.4+, Claude AI."
        )

    # ── Pressemitteilung ───────────────────────────────────

    def create_press_release(self, occasion: str, key_facts: dict,
                             target_regions: list[str] = None) -> dict:
        """Pressemitteilung in 3 Versionen: kurz, lang, DE."""
        if target_regions is None:
            target_regions = ["US", "DE"]
        date = datetime.now().strftime("%Y-%m-%d")
        boilerplate = self._get_boilerplate()

        facts_str = "\n".join(f"- {k}: {v}" for k, v in key_facts.items())

        # Kurzversion (EN)
        prompt_short = (
            f"Erstelle eine KURZE Pressemitteilung (max 400 Woerter, Englisch).\n\n"
            f"Anlass: {occasion}\n"
            f"Key Facts:\n{facts_str}\n"
            f"Datum: {date}\n"
            f"Boilerplate: {boilerplate}\n\n"
            "Format:\n"
            "# [Headline max 80 Zeichen]\n"
            "## [Sub-Headline]\n"
            "**San Francisco, {date}** -- [Lead: Wer/Was/Wann/Wo/Warum]\n\n"
            "[Body: 2-3 Absaetze]\n\n"
            "### About DAI-Core Factory\n[Boilerplate]\n\n"
            "### Contact\nfactory@dai-core.ai\n\n"
            "WICHTIG: Headline MUSS unter 80 Zeichen sein."
        )
        short_content = self._call_llm(prompt_short, max_tokens=2048)

        # Langversion (EN)
        prompt_long = (
            f"Erstelle eine AUSFUEHRLICHE Pressemitteilung (800+ Woerter, Englisch).\n\n"
            f"Anlass: {occasion}\n"
            f"Key Facts:\n{facts_str}\n"
            f"Datum: {date}\n"
            f"Boilerplate: {boilerplate}\n\n"
            "Format: Gleiches Format wie Kurzversion, aber mit:\n"
            "- Ausfuehrlicherer Body (5+ Absaetze)\n"
            "- Zitate (als Factory-Perspektive)\n"
            "- Technische Details\n"
            "- Hintergrund/Kontext\n\n"
            "WICHTIG: Headline MUSS unter 80 Zeichen sein."
        )
        long_content = self._call_llm(prompt_long, max_tokens=4096)

        # DE-Version
        prompt_de = (
            f"Erstelle eine Pressemitteilung auf DEUTSCH (500-600 Woerter).\n\n"
            f"Anlass: {occasion}\n"
            f"Key Facts:\n{facts_str}\n"
            f"Datum: {date}\n"
            f"Boilerplate: {boilerplate}\n\n"
            "Format: Professionelles PM-Format fuer DACH-Medien.\n"
            "Dateline: Wien/Berlin, {date}\n\n"
            "WICHTIG: Headline MUSS unter 80 Zeichen sein."
        )
        de_content = self._call_llm(prompt_de, max_tokens=3072)

        # Speichern
        pr_dir = self.output_path / "pr"
        pr_dir.mkdir(parents=True, exist_ok=True)
        slug = re.sub(r"[^a-z0-9]+", "_", occasion.lower()).strip("_")

        paths = {}
        for version, content in [("short", short_content), ("long", long_content), ("de", de_content)]:
            path = pr_dir / f"press_release_{date}_{slug}_{version}.md"
            path.write_text(content, encoding="utf-8")
            paths[version] = str(path)
            logger.info("Press Release (%s): %s", version, path)

        return paths

    # ── Outreach Plan ──────────────────────────────────────

    def plan_outreach(self, press_release_path: str, target_topics: list[str],
                      target_countries: list[str]) -> str:
        """Outreach-Plan mit Kontakten aus Presse-DB."""
        from factory.marketing.tools.press_database import PressDatabase

        pdb = PressDatabase()
        contacts = []
        for topic in target_topics:
            found = pdb.get_distribution_list(topic, countries=target_countries)
            contacts.extend(found)

        # Deduplizieren
        seen = set()
        unique = []
        for c in contacts:
            key = c.get("name", "")
            if key not in seen:
                seen.add(key)
                unique.append(c)

        contacts_str = "\n".join(
            f"- {c.get('name')} ({c.get('outlet', 'unknown')}, {c.get('country', '?')}, "
            f"Reach: {c.get('reach_estimate', '?')})"
            for c in unique[:30]
        )

        pm_content = ""
        try:
            pm_content = Path(press_release_path).read_text(encoding="utf-8")[:2000]
        except Exception:
            pass

        prompt = (
            f"Erstelle einen Outreach-Plan fuer diese Pressemitteilung.\n\n"
            f"PM (Auszug):\n{pm_content}\n\n"
            f"Verfuegbare Kontakte ({len(unique)}):\n{contacts_str}\n\n"
            "Plan:\n"
            "1. Wer bekommt die PM (priorisiert nach Relevanz + Reach)\n"
            "2. Timing (Wann versenden, Follow-Up Zeitplan)\n"
            "3. Personalisierung (Was jeder Kontakt speziell bekommt)\n"
            "4. Follow-Up Strategie\n\n"
            "Format: Markdown mit Tabelle der Kontakte + Aktionen."
        )

        content = self._call_llm(prompt, max_tokens=3072)

        date = datetime.now().strftime("%Y-%m-%d")
        pr_dir = self.output_path / "pr"
        pr_dir.mkdir(parents=True, exist_ok=True)
        output_path = pr_dir / f"outreach_plan_{date}.md"
        output_path.write_text(content, encoding="utf-8")
        logger.info("Outreach Plan: %s", output_path)
        return str(output_path)

    # ── Product Hunt ───────────────────────────────────────

    def create_product_hunt_package(self, project_slug: str) -> str:
        """Product Hunt Launch-Paket."""
        # Story Brief lesen
        story_path = self._marketing_root / "brand" / "app_stories" / project_slug / "story_brief.md"
        story = ""
        try:
            if story_path.exists():
                story = story_path.read_text(encoding="utf-8")[:3000]
        except Exception:
            pass

        prompt = (
            f"Erstelle ein Product Hunt Launch-Paket fuer '{project_slug}'.\n\n"
            f"Story Brief:\n{story if story else '<<Nicht verfuegbar>>'}\n\n"
            "Erstelle EXAKT dieses Format:\n\n"
            "## Tagline\n[MAX 60 Zeichen! Zaehle die Zeichen!]\n\n"
            "## Description\n[Max 260 Zeichen]\n\n"
            "## Topics\n[3-5 Product Hunt Topics: z.B. Artificial Intelligence, Developer Tools]\n\n"
            "## Maker Comment\n[Aus Factory-Perspektive als KI-Wesen. Authentisch, nicht Marketing-Sprech.]\n\n"
            "## Links\n- Website: <<URL>>\n- GitHub: github.com/kryo4ai-del/DriveAI-AutoGen\n\n"
            "WICHTIG: Tagline MUSS unter 60 Zeichen sein! Zaehle nach!"
        )

        content = self._call_llm(prompt, max_tokens=2048)

        # Tagline-Check: extrahiere und pruefe
        lines = content.split("\n")
        for i, line in enumerate(lines):
            if line.strip().lower().startswith("## tagline") and i + 1 < len(lines):
                tagline = lines[i + 1].strip()
                if tagline and len(tagline) > 60:
                    # Kuerzen
                    tagline = tagline[:57] + "..."
                    lines[i + 1] = tagline
                    content = "\n".join(lines)
                    logger.warning("Tagline gekuerzt auf 60 Zeichen: %s", tagline)
                break

        pr_dir = self.output_path / "pr"
        pr_dir.mkdir(parents=True, exist_ok=True)
        output_path = pr_dir / f"product_hunt_{project_slug}.md"
        output_path.write_text(content, encoding="utf-8")
        logger.info("Product Hunt Package: %s", output_path)
        return str(output_path)

    # ── Event Materials ────────────────────────────────────

    def create_event_materials(self, event_name: str, event_type: str) -> str:
        """Event-Vorbereitung: Talking Points, Q&A, Bio."""
        boilerplate = self._get_boilerplate()

        prompt = (
            f"Erstelle Event-Vorbereitungsmaterial fuer:\n"
            f"Event: {event_name}\n"
            f"Typ: {event_type}\n\n"
            f"Factory-Info: {boilerplate}\n\n"
            "Erstelle:\n\n"
            "## Talking Points\n[5-7 Kernbotschaften]\n\n"
            "## Key Messages\n[Was MUSS ruebergebracht werden — 3 Saetze]\n\n"
            "## Q&A Vorbereitung\n[10 wahrscheinliche Fragen + Antwort-Vorschlaege]\n\n"
            "## Bio/Intro\n[Kurzer Intro-Text fuer den Event-Host]\n\n"
            "Ton: Professionell, sachlich, aber auch spannend."
        )

        content = self._call_llm(prompt, max_tokens=4096)

        pr_dir = self.output_path / "pr"
        pr_dir.mkdir(parents=True, exist_ok=True)
        slug = re.sub(r"[^a-z0-9]+", "_", event_name.lower()).strip("_")
        output_path = pr_dir / f"event_{slug}.md"
        output_path.write_text(content, encoding="utf-8")
        logger.info("Event Materials: %s", output_path)
        return str(output_path)

    # ── Crisis Response (IMMER CEO-Gate) ───────────────────

    def create_crisis_response_draft(self, situation_description: str) -> dict:
        """Krisen-Reaktion. IMMER CEO-Gate. NIEMALS direkte Veroeffentlichung."""
        from factory.marketing.alerts.alert_manager import MarketingAlertManager

        draft = self._call_llm(
            f"Erstelle einen professionellen Krisen-Reaktionsentwurf fuer:\n"
            f"{situation_description}\n\n"
            "Ton: Ruhig, sachlich, transparent. Aus Factory-Perspektive.\n"
            "Format: Kurzer Statement-Text (150-300 Woerter).\n"
            "Inkl: Anerkennung der Situation, Fakten, naechste Schritte.",
            max_tokens=2048,
        )

        alerts = MarketingAlertManager()
        gate_id = alerts.create_gate_request(
            source_agent="MKT-13",
            title=f"Crisis Response: {situation_description[:80]}",
            description=(
                f"Situation: {situation_description}\n\n"
                f"Entwurf:\n{draft[:500]}"
            ),
            options=[
                {"label": "Entwurf veroeffentlichen", "description": "Den vorgeschlagenen Text veroeffentlichen"},
                {"label": "Entwurf anpassen", "description": "CEO ueberarbeitet den Entwurf"},
                {"label": "Nicht reagieren", "description": "Abwarten, keine Reaktion"},
                {"label": "Eskalieren", "description": "An Legal/externen Berater weiterleiten"},
            ],
        )

        logger.info("Crisis Response Gate erstellt: %s", gate_id)
        return {"gate_id": gate_id, "draft": draft}

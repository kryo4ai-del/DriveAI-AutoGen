"""Report Agent (MKT-09) — Erstellt Marketing-Reports aus Analytics-Daten.

Verantwortlich fuer:
- Taegliches Briefing (KPI-Status, Alerts, Top-Content)
- Wochenbericht (Trends, Vergleich Vorwoche)
- Monatsbericht (Gesamt-Performance, Empfehlungen)

Daten kommen deterministisch aus RankingDB, KPI-Tracker, Alert-Manager.
LLM formatiert und interpretiert die Daten.
"""

import json
import logging
import os
from datetime import datetime
from pathlib import Path
from typing import Optional

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.report")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Report Agent der DriveAI Factory Marketing-Abteilung (MKT-09).

IDENTITAET:
Die Factory IST das Produkt. Du berichtest ueber die Marketing-Performance der Factory und ihrer Apps.

AUFGABE:
Du erstellst Marketing-Reports in verschiedenen Formaten: Daily Briefing, Weekly Report, Monthly Report.
Deine Daten kommen aus dem KPI-Tracker, der Ranking-Datenbank und dem Alert-System.
Du INTERPRETIERST die Daten — nicht nur auflisten, sondern Muster erkennen und Handlungsempfehlungen geben.

FORMAT:
- Markdown
- Klare Sektionen mit Ueberschriften
- Emojis fuer Status: ✅ OK, ⚠️ Warning, 🔴 Critical
- Zahlen immer mit Einheit und Trend-Pfeil (↑↓→)
- Empfehlungen am Ende, priorisiert

REGELN:
- Factory-First: Immer die Factory-Perspektive, nicht einzelne Apps
- Ehrlich: Probleme benennen, nicht beschoenigen
- Actionable: Jede Empfehlung muss umsetzbar sein
- Daten-gesteuert: Jede Aussage mit Zahl belegen
"""


class ReportAgent:
    """Erstellt Marketing-Reports aus Analytics-Daten."""

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH, REPORTS_PATH

        self.output_path = OUTPUT_PATH
        self.reports_path = REPORTS_PATH
        os.makedirs(self.reports_path, exist_ok=True)
        self.agent_info = self._load_persona()
        logger.info("ReportAgent initialized")

    def _load_persona(self) -> dict:
        """Laedt das eigene Persona-File."""
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_report.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-09", "name": "Report Agent"}

    def _call_llm(self, prompt: str, system_msg: str = None, max_tokens: int = 4096) -> str:
        """LLM-Call ueber TheBrain ProviderRouter mit Anthropic-Fallback."""
        if system_msg is None:
            system_msg = SYSTEM_MESSAGE
        try:
            from config.model_router import get_model_for_agent
            from factory.brain.model_provider import get_model, get_router

            agent_id = self.agent_info.get("id", "MKT-09")
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
                temperature=0.7,
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

    def _gather_data(self, days: int = 1) -> dict:
        """Sammelt alle Daten fuer den Report (deterministisch)."""
        data = {
            "kpi_check": {},
            "alert_stats": {},
            "social_stats": {},
            "top_content": [],
            "db_export": {},
            "timestamp": datetime.now().isoformat(),
            "period_days": days,
        }

        # KPI-Check
        try:
            from factory.marketing.tools.kpi_tracker import KPITracker
            tracker = KPITracker()
            data["kpi_check"] = tracker.run_daily_check()
        except Exception as e:
            logger.warning("KPI data unavailable: %s", e)

        # Alert-Stats
        try:
            from factory.marketing.alerts.alert_manager import MarketingAlertManager
            am = MarketingAlertManager()
            data["alert_stats"] = am.get_alert_stats()
            data["active_alerts"] = am.get_active_alerts()
            data["pending_gates"] = am.get_pending_gates()
        except Exception as e:
            logger.warning("Alert data unavailable: %s", e)

        # Social Stats
        try:
            from factory.marketing.tools.social_analytics_collector import SocialAnalyticsCollector
            collector = SocialAnalyticsCollector()
            data["social_stats"] = collector.collect_all_platform_stats()
            data["cross_platform"] = collector.get_cross_platform_summary(days=days)
        except Exception as e:
            logger.warning("Social data unavailable: %s", e)

        # Top Content
        try:
            from factory.marketing.tools.social_analytics_collector import SocialAnalyticsCollector
            collector = SocialAnalyticsCollector()
            data["top_content"] = collector.identify_top_content(limit=5, days=days)
        except Exception as e:
            logger.warning("Top content data unavailable: %s", e)

        # DB Export
        try:
            from factory.marketing.tools.ranking_database import RankingDatabase
            db = RankingDatabase()
            data["db_export"] = db.export_for_report("com.driveai.askfin", days)
        except Exception as e:
            logger.warning("DB export unavailable: %s", e)

        return data

    def create_daily_briefing(self) -> dict:
        """Erstellt ein taegliches Marketing-Briefing.

        Returns: {
            "report_path": str,
            "data": dict,
            "summary": str (LLM-formatiert),
            "mock_data": bool
        }
        """
        data = self._gather_data(days=1)

        prompt = f"""Erstelle ein kurzes Daily Marketing Briefing basierend auf diesen Daten:

KPI-CHECK:
{json.dumps(data.get('kpi_check', {}), indent=2, default=str)}

ALERTS:
- Aktive Alerts: {len(data.get('active_alerts', []))}
- Offene Gates: {len(data.get('pending_gates', []))}
- Stats: {json.dumps(data.get('alert_stats', {}), indent=2, default=str)}

SOCIAL MEDIA:
{json.dumps(data.get('social_stats', {}), indent=2, default=str)}

TOP CONTENT:
{json.dumps(data.get('top_content', []), indent=2, default=str)}

Format: Markdown, maximal 500 Woerter. Sektionen: Status-Uebersicht, KPIs, Alerts, Social Media, Top Content, Handlungsempfehlungen.
Nutze Emojis fuer Status (✅⚠️🔴). Datum: {datetime.now().strftime('%d.%m.%Y')}"""

        summary = self._call_llm(prompt, max_tokens=4096)

        # Speichern
        date_str = datetime.now().strftime("%Y-%m-%d")
        report_path = os.path.join(self.reports_path, f"daily_{date_str}.md")
        with open(report_path, "w", encoding="utf-8") as f:
            f.write(summary if summary else "# Daily Briefing\n\nKeine LLM-Antwort verfuegbar.\n")

        return {
            "report_path": report_path,
            "data": data,
            "summary": summary,
            "mock_data": True,  # Dry-Run Daten
        }

    def create_weekly_report(self) -> dict:
        """Erstellt einen Wochenbericht.

        Returns: {
            "report_path": str,
            "data": dict,
            "summary": str (LLM-formatiert),
            "mock_data": bool
        }
        """
        data = self._gather_data(days=7)

        prompt = f"""Erstelle einen ausfuehrlichen Weekly Marketing Report basierend auf diesen Daten:

KPI-CHECK:
{json.dumps(data.get('kpi_check', {}), indent=2, default=str)}

ALERT-STATISTIK:
{json.dumps(data.get('alert_stats', {}), indent=2, default=str)}

SOCIAL MEDIA PERFORMANCE:
{json.dumps(data.get('social_stats', {}), indent=2, default=str)}

CROSS-PLATFORM SUMMARY:
{json.dumps(data.get('cross_platform', {}), indent=2, default=str)}

TOP CONTENT (letzte 7 Tage):
{json.dumps(data.get('top_content', []), indent=2, default=str)}

DB EXPORT:
{json.dumps(data.get('db_export', {}), indent=2, default=str)}

Format: Markdown, ausfuehrlich (1000-1500 Woerter).
Sektionen: Executive Summary, KPI-Dashboard, Social Media Performance, Content Performance, Alert-Uebersicht, Trends & Muster, Empfehlungen fuer naechste Woche.
Nutze Tabellen wo sinnvoll. Vergleiche mit Vorwoche (wenn Daten vorhanden).
Datum: KW {datetime.now().isocalendar()[1]} / {datetime.now().year}"""

        summary = self._call_llm(prompt, max_tokens=8192)

        date_str = datetime.now().strftime("%Y-%m-%d")
        report_path = os.path.join(self.reports_path, f"weekly_{date_str}.md")
        with open(report_path, "w", encoding="utf-8") as f:
            f.write(summary if summary else "# Weekly Report\n\nKeine LLM-Antwort verfuegbar.\n")

        return {
            "report_path": report_path,
            "data": data,
            "summary": summary,
            "mock_data": True,
        }

    def create_monthly_report(self) -> dict:
        """Erstellt einen Monatsbericht.

        Returns: {
            "report_path": str,
            "data": dict,
            "summary": str (LLM-formatiert),
            "mock_data": bool
        }
        """
        data = self._gather_data(days=30)

        prompt = f"""Erstelle einen umfassenden Monthly Marketing Report basierend auf diesen Daten:

KPI-CHECK:
{json.dumps(data.get('kpi_check', {}), indent=2, default=str)}

ALERT-STATISTIK:
{json.dumps(data.get('alert_stats', {}), indent=2, default=str)}

SOCIAL MEDIA PERFORMANCE:
{json.dumps(data.get('social_stats', {}), indent=2, default=str)}

CROSS-PLATFORM SUMMARY:
{json.dumps(data.get('cross_platform', {}), indent=2, default=str)}

TOP CONTENT (letzte 30 Tage):
{json.dumps(data.get('top_content', []), indent=2, default=str)}

DB EXPORT:
{json.dumps(data.get('db_export', {}), indent=2, default=str)}

Format: Markdown, umfassend (2000-3000 Woerter).
Sektionen: Executive Summary, Monats-KPIs mit Zielerreichung, Social Media Deep-Dive (pro Plattform), Content-Analyse (was hat funktioniert, was nicht), Alert-Analyse, Strategische Empfehlungen, Ziele fuer naechsten Monat.
Nutze Tabellen, Listen, Emojis. Sei analytisch und ehrlich.
Monat: {datetime.now().strftime('%B %Y')}"""

        summary = self._call_llm(prompt, max_tokens=8192)

        date_str = datetime.now().strftime("%Y-%m")
        report_path = os.path.join(self.reports_path, f"monthly_{date_str}.md")
        with open(report_path, "w", encoding="utf-8") as f:
            f.write(summary if summary else "# Monthly Report\n\nKeine LLM-Antwort verfuegbar.\n")

        return {
            "report_path": report_path,
            "data": data,
            "summary": summary,
            "mock_data": True,
        }

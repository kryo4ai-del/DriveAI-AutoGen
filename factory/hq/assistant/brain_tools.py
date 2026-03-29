"""TheBrain Tools fuer den HQ Assistant.

Kapselt alle TheBrain-Interaktionen in einfach aufrufbare Funktionen.
Jede Funktion gibt ein fertiges Ergebnis zurueck das der Assistant
direkt an Andreas weitergeben kann.
"""

import json
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

FACTORY_ROOT = Path(__file__).parent.parent.parent.parent


class BrainTools:
    """Schnittstelle zwischen HQ Assistant und TheBrain.

    Jede Methode entspricht einem Befehl den Andreas geben kann.
    Alle Methoden fangen Fehler ab — wenn TheBrain nicht verfuegbar ist,
    kommt eine klare Fehlermeldung statt einem Crash.
    """

    def __init__(self):
        self.available = False
        self._error = None
        try:
            from factory.brain.task_router import TaskRouter
            from factory.brain.state_report import StateReportGenerator
            from factory.brain.problem_detector import ProblemDetector
            from factory.brain.solution_proposer import SolutionProposer
            from factory.brain.gap_analyzer import GapAnalyzer
            from factory.brain.extension_advisor import ExtensionAdvisor

            self._task_router = TaskRouter(str(FACTORY_ROOT))
            self._state_report = StateReportGenerator(str(FACTORY_ROOT))
            self._problem_detector = ProblemDetector(str(FACTORY_ROOT))
            self._solution_proposer = SolutionProposer(str(FACTORY_ROOT))
            self._gap_analyzer = GapAnalyzer(str(FACTORY_ROOT))
            self._extension_advisor = ExtensionAdvisor(str(FACTORY_ROOT))
            self.available = True
        except Exception as e:
            self._error = str(e)
            logger.warning("BrainTools init failed: %s", e)

    def is_available(self) -> bool:
        return self.available

    def _unavailable_msg(self) -> str:
        return json.dumps({
            "error": "TheBrain ist aktuell nicht erreichbar",
            "detail": self._error or "Unknown",
        })

    # ── Befehle ──────────────────────────────────────────

    def factory_briefing(self) -> str:
        """Vollstaendiger Factory-Report (Kompakt-Report von StateReportGenerator)."""
        if not self.available:
            return self._unavailable_msg()
        try:
            report = self._state_report.generate_compact_report()
            return json.dumps({"briefing": report}, ensure_ascii=False)
        except Exception as e:
            return json.dumps({"error": f"TheBrain Briefing fehlgeschlagen: {e}"})

    def factory_diagnose(self) -> str:
        """Probleme erkennen + Loesungsvorschlaege."""
        if not self.available:
            return self._unavailable_msg()
        try:
            result = self._task_router.diagnose_and_propose()
            detection = result.get("detection", {})
            solutions = result.get("solutions", {})

            output = {
                "overall_severity": detection.get("overall_severity", "unknown"),
                "problem_count": detection.get("problem_count", {}),
                "problems": [],
                "solutions": [],
                "execution_plan": solutions.get("execution_plan", {}),
            }

            for p in detection.get("problems", []):
                output["problems"].append({
                    "severity": p.get("severity"),
                    "title": p.get("title"),
                    "detail": p.get("detail", ""),
                })

            for s in solutions.get("solutions", []):
                output["solutions"].append({
                    "title": s.get("title"),
                    "approval_level": s.get("approval_level"),
                    "delegate_to": s.get("delegate_to", "?"),
                })

            return json.dumps(output, indent=2, ensure_ascii=False, default=str)
        except Exception as e:
            return json.dumps({"error": f"Factory Diagnose fehlgeschlagen: {e}"})

    def factory_gaps(self) -> str:
        """Tiefenanalyse aller Capability-Gaps mit Stufen-Empfehlungen."""
        if not self.available:
            return self._unavailable_msg()
        try:
            result = self._gap_analyzer.analyze_all_gaps()

            output = {
                "total_gaps": result.get("total_gaps", 0),
                "summary": result.get("summary", {}),
                "analyses": [],
            }

            for a in result.get("analyses", []):
                rec = a.get("overall_recommendation", {})
                output["analyses"].append({
                    "gap_category": a.get("gap_category"),
                    "gap_severity": a.get("gap_severity"),
                    "best_stufe": rec.get("best_stufe"),
                    "best_option": rec.get("best_option"),
                    "self_solvable": a.get("self_solvable", False),
                })

            return json.dumps(output, indent=2, ensure_ascii=False, default=str)
        except Exception as e:
            return json.dumps({"error": f"Gap-Analyse fehlgeschlagen: {e}"})

    def factory_roadmap(self) -> str:
        """Erweiterungs-Roadmap mit Timeline."""
        if not self.available:
            return self._unavailable_msg()
        try:
            result = self._extension_advisor.create_extension_roadmap()

            output = {
                "total_plans": result.get("total_plans", 0),
                "total_weeks": result.get("resource_summary", {}).get("total_estimated_weeks", 0),
                "roadmap": {},
            }

            for category in ["immediate", "short_term", "mid_term", "long_term"]:
                plans = result.get("roadmap", {}).get(category, [])
                if plans:
                    output["roadmap"][category] = [
                        {
                            "title": p.get("title"),
                            "weeks": p.get("timeline", {}).get("total_weeks"),
                            "stufe": p.get("directive_stufe"),
                        }
                        for p in plans
                    ]

            return json.dumps(output, indent=2, ensure_ascii=False, default=str)
        except Exception as e:
            return json.dumps({"error": f"Roadmap-Erstellung fehlgeschlagen: {e}"})

    def factory_quick_check(self) -> str:
        """Ultraknapper 3-Zeilen-Status."""
        if not self.available:
            return self._unavailable_msg()
        try:
            detection = self._problem_detector.run_detection()
            severity = detection.get("overall_severity", "unknown")
            counts = detection.get("problem_count", {})
            crit = counts.get("critical", 0)
            warn = counts.get("warning", 0)
            healthy = detection.get("healthy_systems", [])

            return json.dumps({
                "health": severity,
                "critical": crit,
                "warnings": warn,
                "healthy_systems": healthy,
            }, ensure_ascii=False, default=str)
        except Exception as e:
            return json.dumps({"error": f"Quick Check fehlgeschlagen: {e}"})

    def brain_evolution(self, force: bool = False, dry_run: bool = False) -> str:
        """Model Evolution Cycle — erkennt und integriert neue Modelle autonom."""
        try:
            from factory.brain.model_provider.model_evolution import ModelEvolution
            evo = ModelEvolution()
            if dry_run:
                return json.dumps(evo.get_status(), indent=2, ensure_ascii=False, default=str)
            report = evo.run_cycle(force=force)
            return json.dumps({
                "status": report.status,
                "models_added": report.models_added,
                "models_deprecated": report.models_deprecated,
                "cost_usd": report.cost_usd,
                "duration_sec": report.duration_sec,
                "actions": [
                    {"action": a.action, "model": f"{a.provider}/{a.model_id}",
                     "tier": a.tier, "reason": a.reason}
                    for a in report.actions
                ],
                "errors": report.errors,
            }, indent=2, ensure_ascii=False, default=str)
        except Exception as e:
            return json.dumps({"error": f"Model Evolution fehlgeschlagen: {e}"})

    def get_available_commands(self) -> str:
        """Liste aller verfuegbaren TheBrain-Befehle."""
        commands = [
            ("Factory Briefing", "Vollstaendiger Tages-Report mit Health, Alerts, Capabilities"),
            ("Factory Diagnose", "Probleme erkennen + Loesungsvorschlaege"),
            ("Gap Analyse", "Tiefenanalyse aller fehlenden Faehigkeiten"),
            ("Roadmap", "Erweiterungs-Roadmap mit Zeitplan"),
            ("Quick Check", "Kurz-Status: Health + Probleme"),
            ("Model Evolution", "Autonome Erkennung + Integration neuer Modelle"),
            ("TheBrain Befehle", "Diese Liste"),
        ]
        return json.dumps({
            "available": self.available,
            "commands": [{"command": c, "description": d} for c, d in commands],
        }, ensure_ascii=False)


# Singleton — wird einmal geladen, dann wiederverwendet
_instance = None


def get_brain_tools() -> BrainTools:
    """Gibt die BrainTools-Singleton-Instanz zurueck."""
    global _instance
    if _instance is None:
        _instance = BrainTools()
    return _instance

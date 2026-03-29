"""Memory Writer — Convenience-Methoden fuer das Factory Memory.

Wird von anderen TheBrain-Modulen genutzt um Events automatisch
zu loggen ohne die volle Memory-API zu kennen.

100% deterministisch, kein LLM.
"""

import logging
from pathlib import Path

logger = logging.getLogger(__name__)

_DEFAULT_ROOT = Path(__file__).resolve().parents[3]


class MemoryWriter:
    """Hilfsklasse fuer haeufige Memory-Operationen."""

    def __init__(self, factory_root: str = None):
        from factory.brain.memory.factory_memory import FactoryMemory
        self._memory = FactoryMemory(factory_root)

    def log_production_start(self, project_name: str, project_type: str,
                              capabilities_needed: list) -> str:
        """Loggt den Start einer App-Produktion. Returns event_id."""
        result = self._memory.record_event({
            "type": "production_start",
            "project": project_name,
            "source": "MemoryWriter",
            "severity": "info",
            "title": f"Produktion gestartet: {project_name}",
            "detail": {
                "project_type": project_type,
                "capabilities_needed": capabilities_needed,
            },
            "tags": ["production", project_type] + capabilities_needed,
        })
        return result["event_id"]

    def log_production_complete(self, project_name: str,
                                 duration_hours: float = None) -> str:
        """Loggt den Abschluss einer Produktion."""
        detail = {}
        if duration_hours is not None:
            detail["duration_hours"] = duration_hours

        result = self._memory.record_event({
            "type": "production_complete",
            "project": project_name,
            "source": "MemoryWriter",
            "severity": "info",
            "title": f"Produktion abgeschlossen: {project_name}",
            "detail": detail,
            "tags": ["production", "complete"],
        })
        return result["event_id"]

    def log_production_error(self, project_name: str, error: str,
                              phase: str, agent: str = None) -> str:
        """Loggt einen Produktionsfehler."""
        detail = {
            "error": error,
            "phase": phase,
        }
        if agent:
            detail["agent"] = agent

        tags = ["error", phase]
        if agent:
            tags.append(agent)

        result = self._memory.record_event({
            "type": "production_error",
            "project": project_name,
            "source": agent or "MemoryWriter",
            "severity": "error",
            "title": f"Fehler in {phase}: {error[:100]}",
            "detail": detail,
            "tags": tags,
        })
        return result["event_id"]

    def log_error_resolved(self, project_name: str, error_event_id: str,
                            resolution: str) -> str:
        """Loggt die Loesung eines Fehlers. Verlinkt auf das Original-Error-Event."""
        result = self._memory.record_event({
            "type": "error_resolved",
            "project": project_name,
            "source": "MemoryWriter",
            "severity": "info",
            "title": f"Fehler geloest: {resolution[:100]}",
            "detail": {
                "original_error_event": error_event_id,
                "resolution": resolution,
            },
            "tags": ["resolved", "fix"],
        })
        return result["event_id"]

    def log_workaround(self, project_name: str, problem: str,
                        workaround: str) -> str:
        """Loggt einen Workaround."""
        result = self._memory.record_event({
            "type": "workaround_found",
            "project": project_name,
            "source": "MemoryWriter",
            "severity": "info",
            "title": f"Workaround: {workaround[:100]}",
            "detail": {
                "problem": problem,
                "workaround": workaround,
            },
            "tags": ["workaround"],
        })
        return result["event_id"]

    def log_capability_change(self, capability: str,
                               change_type: str, detail: str) -> str:
        """Loggt eine Capability-Aenderung (added/removed/upgraded)."""
        event_type = "capability_added" if change_type in ("added", "upgraded") else "capability_removed"
        result = self._memory.record_event({
            "type": event_type,
            "source": "MemoryWriter",
            "severity": "info",
            "title": f"Capability {change_type}: {capability}",
            "detail": {
                "capability": capability,
                "change_type": change_type,
                "description": detail,
            },
            "tags": ["capability", capability, change_type],
        })
        return result["event_id"]

    def log_service_event(self, service: str,
                           event_type: str, detail: str) -> str:
        """Loggt ein Service-Event (outage/restored)."""
        mem_type = "service_outage" if event_type == "outage" else "service_restored"
        severity = "warning" if event_type == "outage" else "info"

        result = self._memory.record_event({
            "type": mem_type,
            "source": "MemoryWriter",
            "severity": severity,
            "title": f"Service {event_type}: {service}",
            "detail": {
                "service": service,
                "event_type": event_type,
                "description": detail,
            },
            "tags": ["service", service, event_type],
        })
        return result["event_id"]

    def log_detection_run(self, problems_found: int,
                           solutions_proposed: int) -> str:
        """Loggt einen Problem-Detection-Run."""
        severity = "info"
        if problems_found > 5:
            severity = "warning"

        result = self._memory.record_event({
            "type": "detection_run",
            "source": "ProblemDetector",
            "severity": severity,
            "title": f"Detection: {problems_found} Probleme, {solutions_proposed} Loesungen",
            "detail": {
                "problems_found": problems_found,
                "solutions_proposed": solutions_proposed,
            },
            "tags": ["detection", "monitoring"],
        })
        return result["event_id"]

    def create_lesson_from_events(self, event_ids: list, title: str,
                                    recommendation: str,
                                    category: str = "best_practice") -> str:
        """Erstellt eine Lesson aus mehreren Events."""
        # Collect tags from source events
        events = self._memory._load_store("events")
        collected_tags = set()
        applies_to = set()
        description_parts = []

        for evt in events:
            if evt.get("event_id") in event_ids:
                collected_tags.update(evt.get("tags", []))
                if evt.get("project"):
                    applies_to.add(evt["project"])
                description_parts.append(
                    f"[{evt.get('type')}] {evt.get('title', '')}"
                )

        result = self._memory.record_lesson({
            "title": title,
            "description": " → ".join(description_parts) if description_parts else title,
            "source_events": event_ids,
            "category": category,
            "applies_to": list(applies_to),
            "recommendation": recommendation,
            "tags": list(collected_tags),
        })
        return result["lesson_id"]

"""TheBrain Response Collector.

Verarbeitet Rohergebnisse von Factory-Subsystemen und liefert
klare, handlungsorientierte Antworten im TheBrain-Stil.

Sitzt zwischen TaskRouter-Output und dem finalen Response an den Aufrufer.

Zwei Modi:
- Deterministisch: Fuer strukturierte Daten (Status, Listen, Zahlen)
- LLM-unterstuetzt: Fuer komplexe Zusammenfassungen oder wenn mehrere
  Quellen zusammengefasst werden muessen

Kommunikation:
- Empfaengt von: TaskRouter.route()
- Liefert an: HQ Assistant, Dashboard, externe Systeme
"""

import logging
import re
from pathlib import Path

logger = logging.getLogger(__name__)

_DEFAULT_ROOT = Path(__file__).resolve().parents[2]

# ── Floskel-Patterns (fuer _format_brain_style) ─────────────────
_FLOSKEL_PATTERNS = [
    (re.compile(r"^(gerne|natuerlich|selbstverstaendlich|klar),?\s*", re.IGNORECASE), ""),
    (re.compile(r"^ich helfe (ihnen|dir) gerne\s*(dabei)?[.,!]?\s*", re.IGNORECASE), ""),
    (re.compile(r"^ich wuerde gerne\s*", re.IGNORECASE), ""),
    (re.compile(r"^(hier ist|hier sind)\s*(die|der|das|ein|eine)?\s*", re.IGNORECASE), ""),
    (re.compile(r"^lassen sie mich\s*", re.IGNORECASE), ""),
    (re.compile(r"^lass mich\s*", re.IGNORECASE), ""),
    (re.compile(r"^I'd be happy to\s*", re.IGNORECASE), ""),
    (re.compile(r"^Let me\s*", re.IGNORECASE), ""),
    (re.compile(r"^Sure,?\s*", re.IGNORECASE), ""),
    (re.compile(r"^Of course,?\s*", re.IGNORECASE), ""),
    (re.compile(r"^Absolutely,?\s*", re.IGNORECASE), ""),
]

# ── Eskalations-Schwellwerte ─────────────────────────────────────
_ESCALATION_THRESHOLDS = {
    "maintenance_backlog": 500,
    "stuck_hours": 72,
    "critical_alerts": 1,
    "red_gaps_blocking": 1,
}


class ResponseCollector:
    """Verarbeitet Rohergebnisse von Factory-Subsystemen im TheBrain-Stil."""

    def __init__(self, factory_root: str = None):
        self.root = Path(factory_root) if factory_root else _DEFAULT_ROOT
        self._model_router = None
        try:
            from config.model_router import ModelRouter
            self._model_router = ModelRouter()
        except Exception:
            pass

    # ------------------------------------------------------------------
    # Main Entry Points
    # ------------------------------------------------------------------
    def process(self, router_result: dict) -> dict:
        """Nimmt ein TaskRouter-Ergebnis und verarbeitet es."""
        category = router_result.get("category", "unknown")
        status = router_result.get("status", "error")

        logger.info("Processing response for category '%s' (status=%s)", category, status)

        # Error passthrough
        if status == "error":
            return self._wrap_error(router_result)

        handler = {
            "factory_status": self._process_factory_status,
            "capabilities": self._process_capabilities,
            "project_status": self._process_project_status,
            "maintenance": self._process_maintenance,
            "health_check": self._process_health_check,
            "repair": self._process_repair,
            "service_status": self._process_service_status,
            "department_task": self._process_department_task,
            "unknown": self._process_unknown,
        }.get(category, self._process_unknown)

        try:
            processed = handler(router_result)
        except Exception as e:
            logger.error("Response processing failed for '%s': %s", category, e)
            processed = {
                "status": "error",
                "category": category,
                "summary": f"Verarbeitung fehlgeschlagen: {e}",
                "detail": router_result.get("result"),
                "alerts": [],
                "next_steps": [],
                "escalate": False,
                "escalation_reason": None,
            }

        # Final escalation check
        escalate, reason = self._determine_escalation(processed)
        if escalate and not processed.get("escalate"):
            processed["escalate"] = True
            processed["escalation_reason"] = reason

        logger.info(
            "Response processed: category=%s, escalate=%s, llm_used=False",
            category, processed.get("escalate", False),
        )
        return processed

    def process_multi(self, router_results: list) -> dict:
        """Verarbeitet mehrere TaskRouter-Ergebnisse zusammen."""
        if not router_results:
            return self._empty_result("multi_source")

        if len(router_results) == 1:
            return self.process(router_results[0])

        # Process each individually
        processed_list = []
        all_alerts = []
        all_next_steps = []
        any_escalation = False
        escalation_reasons = []

        for rr in router_results:
            p = self.process(rr)
            processed_list.append(p)
            all_alerts.extend(p.get("alerts", []))
            all_next_steps.extend(p.get("next_steps", []))
            if p.get("escalate"):
                any_escalation = True
                if p.get("escalation_reason"):
                    escalation_reasons.append(p["escalation_reason"])

        # Deduplicate alerts by message
        seen = set()
        unique_alerts = []
        for a in all_alerts:
            key = a.get("message", "")
            if key not in seen:
                seen.add(key)
                unique_alerts.append(a)

        # Sort alerts: critical > warning > info
        level_order = {"critical": 0, "warning": 1, "info": 2}
        unique_alerts.sort(key=lambda a: level_order.get(a.get("level", "info"), 3))

        # Deduplicate next_steps
        unique_steps = list(dict.fromkeys(all_next_steps))

        # Build combined summary
        summaries = [p.get("summary", "") for p in processed_list if p.get("summary")]
        combined_summary = " | ".join(summaries)

        # Build combined detail
        detail = {}
        for p in processed_list:
            cat = p.get("category", "unknown")
            detail[cat] = p.get("detail")

        # If 3+ sources, try LLM summary
        if len(processed_list) >= 3:
            llm_summary = self._summarize_with_llm(detail, "Fasse den Gesamtzustand zusammen.")
            if llm_summary:
                combined_summary = llm_summary

        return {
            "status": "success",
            "category": "multi_source",
            "summary": self._format_brain_style(combined_summary),
            "detail": detail,
            "alerts": unique_alerts,
            "next_steps": unique_steps[:8],
            "escalate": any_escalation,
            "escalation_reason": " + ".join(escalation_reasons) if escalation_reasons else None,
        }

    # ------------------------------------------------------------------
    # Category Processors (all deterministic except department_task)
    # ------------------------------------------------------------------
    def _process_factory_status(self, rr: dict) -> dict:
        """Verarbeitet Factory-Status-Ergebnisse (StateReportGenerator Output)."""
        result = rr.get("result", "")
        alerts = []
        next_steps = []

        # Parse health from compact report text
        health = "unknown"
        if isinstance(result, str):
            if "GREEN" in result:
                health = "GREEN"
            elif "YELLOW" in result:
                health = "YELLOW"
            elif "RED" in result:
                health = "RED"

            # Count alert lines
            alert_lines = [l.strip() for l in result.split("\n")
                           if l.strip().startswith(("\u274c", "\u26a0", "\u2139"))]
            for line in alert_lines:
                level = "critical" if line.startswith("\u274c") else "warning" if line.startswith("\u26a0") else "info"
                alerts.append({"level": level, "message": line.lstrip("\u274c\u26a0\u2139 ")})

            # Count gap lines
            gap_lines = [l.strip() for l in result.split("\n") if l.strip().startswith("[RED]")]
            if gap_lines:
                next_steps.append("RED Gaps schliessen")

        if health == "YELLOW":
            if alerts:
                next_steps.append("Alerts pruefen und abarbeiten")
        elif health == "RED":
            next_steps.insert(0, "SOFORT: Critical Issues beheben")

        # Build summary
        alert_count = len(alerts)
        critical_count = sum(1 for a in alerts if a.get("level") == "critical")
        summary = f"Factory {health}. {alert_count} Alerts"
        if critical_count:
            summary += f" ({critical_count} critical)"
        summary += "."

        return {
            "status": "success",
            "category": "factory_status",
            "summary": summary,
            "detail": result,
            "alerts": alerts,
            "next_steps": next_steps,
            "escalate": health == "RED" or critical_count > 0,
            "escalation_reason": f"Factory Health {health}, {critical_count} Critical Alerts" if health == "RED" or critical_count > 0 else None,
        }

    def _process_capabilities(self, rr: dict) -> dict:
        """Verarbeitet Capability-Abfragen (CapabilityMap Output)."""
        result = rr.get("result", {})
        routed_to = rr.get("routed_to", "")
        alerts = []
        next_steps = []

        if "get_gaps" in routed_to:
            # Gap query
            gaps = result.get("gaps", [])
            red = [g for g in gaps if g.get("severity") == "red"]
            yellow = [g for g in gaps if g.get("severity") == "yellow"]
            green = [g for g in gaps if g.get("severity") == "green"]

            summary = f"{len(gaps)} Gaps. {len(red)} RED, {len(yellow)} YELLOW, {len(green)} GREEN."

            for g in red:
                alerts.append({"level": "critical", "message": g.get("message", g.get("type", "RED Gap"))})
                # Suggest fix based on gap type
                gap_type = g.get("type", "")
                if "service" in gap_type:
                    detail_str = g.get("detail", "")
                    next_steps.append(f"Service aktivieren: {detail_str}" if detail_str else "Fehlenden Service aktivieren")
                elif "adapter" in gap_type:
                    next_steps.append(f"Draft-Adapter aktivieren: {g.get('detail', '?')}")

            for g in yellow[:3]:
                alerts.append({"level": "warning", "message": g.get("message", g.get("type", "YELLOW Gap"))})

            if red:
                next_steps.insert(0, "RED Gaps priorisieren — koennen Produktion blockieren")

            detail = {
                "red_gaps": [{"type": g.get("type"), "detail": g.get("detail"), "message": g.get("message")} for g in red],
                "yellow_gaps": [{"type": g.get("type"), "message": g.get("message")} for g in yellow],
                "green_gaps": [{"type": g.get("type"), "message": g.get("message")} for g in green],
            }

            escalate = len(red) > 0
            esc_reason = None
            if escalate:
                red_msgs = ", ".join(g.get("message", "?")[:40] for g in red[:3])
                esc_reason = f"RED Capability Gap: {red_msgs}. Kann Produktion blockieren."

            return {
                "status": "success",
                "category": "capabilities",
                "summary": summary,
                "detail": detail,
                "alerts": alerts,
                "next_steps": next_steps,
                "escalate": escalate,
                "escalation_reason": esc_reason,
            }
        else:
            # build_map query
            totals = result.get("totals", {})
            agents = totals.get("agents", 0)
            agents_active = totals.get("agents_active", 0)
            services = len(result.get("services_active", []))
            forges = result.get("forges_operational", 0)
            lines = result.get("production_lines_active", 0)

            summary = (
                f"{agents} Agents ({agents_active} aktiv), "
                f"{services} Services, {forges} Forges, {lines} Lines aktiv."
            )

            return {
                "status": "success",
                "category": "capabilities",
                "summary": summary,
                "detail": result,
                "alerts": [],
                "next_steps": ["Fuer Gap-Analyse: 'Welche Faehigkeiten fehlen?'"],
                "escalate": False,
                "escalation_reason": None,
            }

    def _process_project_status(self, rr: dict) -> dict:
        """Verarbeitet Projekt-Status-Abfragen."""
        result = rr.get("result", {})
        alerts = []
        next_steps = []

        # Single project match
        if "project" in result and "total_projects" not in result:
            project = result["project"]
            name = project.get("name", "?")
            phase = project.get("phase", "?")
            is_stuck = result.get("is_stuck", False)

            summary = f"Projekt {name}: Phase '{phase}'."
            if is_stuck:
                summary += " STUCK."
                alerts.append({"level": "critical", "message": f"{name} steckt fest in Phase '{phase}'"})
                next_steps.append(f"CEO-Review fuer {name}")

            return {
                "status": "success",
                "category": "project_status",
                "summary": summary,
                "detail": result,
                "alerts": alerts,
                "next_steps": next_steps,
                "escalate": is_stuck,
                "escalation_reason": f"Projekt {name} stuck seit >48h" if is_stuck else None,
            }

        # All projects
        total = result.get("total_projects", 0)
        stuck = result.get("stuck_projects", [])
        projects = result.get("projects", [])

        summary = f"{total} Projekte in Pipeline."
        if stuck:
            stuck_names = ", ".join(s.get("name", "?") for s in stuck[:3])
            summary += f" {len(stuck)} stuck ({stuck_names})."
            for s in stuck:
                alerts.append({"level": "critical", "message": f"{s.get('name', '?')} stuck in {s.get('phase', '?')}"})
            next_steps.append("Stuck-Projekte reviewen")

        return {
            "status": "success",
            "category": "project_status",
            "summary": summary,
            "detail": result,
            "alerts": alerts,
            "next_steps": next_steps,
            "escalate": len(stuck) > 0,
            "escalation_reason": f"{len(stuck)} Projekte stuck" if stuck else None,
        }

    def _process_maintenance(self, rr: dict) -> dict:
        """Verarbeitet Maintenance/Janitor-Ergebnisse."""
        result = rr.get("result", {})
        alerts = []
        next_steps = []

        janitor = result.get("janitor", {})
        cmd_queue = result.get("command_queue", {})

        # Janitor summary
        issues = janitor.get("issues_found", janitor.get("total_issues", 0))
        health_score = janitor.get("health_score")
        last_scan = janitor.get("last_scan", "unbekannt")

        # Command queue
        total_cmds = cmd_queue.get("total_commands", cmd_queue.get("pending_commands", 0))
        oldest_age = cmd_queue.get("oldest_age_days", 0)

        parts = []
        if issues:
            parts.append(f"Janitor: {issues} Issues")
            if health_score is not None:
                parts.append(f"Score {health_score}/100")
        if total_cmds:
            parts.append(f"Command Queue: {total_cmds} pending")
            if oldest_age > 7:
                parts.append(f"aelteste {oldest_age} Tage")

        summary = ". ".join(parts) + "." if parts else "Kein Maintenance-Bedarf erkannt."

        if issues > _ESCALATION_THRESHOLDS["maintenance_backlog"]:
            alerts.append({"level": "warning", "message": f"Maintenance-Backlog hoch: {issues} Issues"})
            next_steps.append("Janitor-Deep-Scan beauftragen")
        elif issues > 200:
            alerts.append({"level": "info", "message": f"Janitor: {issues} Issues"})
            next_steps.append("Janitor-Scan pruefen")

        if total_cmds > 100:
            alerts.append({"level": "warning", "message": f"Command Queue Backlog: {total_cmds}"})
            next_steps.append("Command Queue archivieren")
        elif total_cmds > 0 and oldest_age > 14:
            alerts.append({"level": "info", "message": f"Alte Commands: {total_cmds}, aelteste {oldest_age} Tage"})
            next_steps.append("Alte Commands pruefen und archivieren")

        return {
            "status": "success",
            "category": "maintenance",
            "summary": summary,
            "detail": result,
            "alerts": alerts,
            "next_steps": next_steps,
            "escalate": issues > _ESCALATION_THRESHOLDS["maintenance_backlog"],
            "escalation_reason": f"Maintenance-Backlog: {issues} Issues" if issues > _ESCALATION_THRESHOLDS["maintenance_backlog"] else None,
        }

    def _process_health_check(self, rr: dict) -> dict:
        """Verarbeitet Health-Check-Ergebnisse."""
        result = rr.get("result", {})
        alerts = []
        next_steps = []

        overall = result.get("overall", "unknown")
        total_alerts = result.get("total_alerts", 0)
        critical = result.get("critical", 0)
        warnings = result.get("warnings", 0)
        hm_alerts = result.get("alerts", [])

        summary = f"Health: {overall.upper()}. {total_alerts} Alerts ({critical} critical, {warnings} warnings)."

        if critical > 0:
            for a in hm_alerts:
                if a.get("severity") == "critical" or a.get("level") == "critical":
                    alerts.append({"level": "critical", "message": a.get("message", a.get("type", "Critical Alert"))})
            next_steps.insert(0, "Critical Alerts sofort beheben")

        if warnings > 0:
            for a in hm_alerts:
                sev = a.get("severity", a.get("level", ""))
                if sev == "warning":
                    alerts.append({"level": "warning", "message": a.get("message", a.get("type", "Warning"))})
            next_steps.append("Warnungen pruefen")

        # If HM returned raw alerts without severity, treat them as warnings
        if not alerts and hm_alerts:
            for a in hm_alerts[:5]:
                msg = a.get("message", a.get("type", str(a)))
                alerts.append({"level": "warning", "message": msg})

        return {
            "status": rr.get("status", "success"),
            "category": "health_check",
            "summary": summary,
            "detail": result,
            "alerts": alerts,
            "next_steps": next_steps,
            "escalate": critical >= _ESCALATION_THRESHOLDS["critical_alerts"],
            "escalation_reason": f"{critical} Critical Health Alerts" if critical >= _ESCALATION_THRESHOLDS["critical_alerts"] else None,
        }

    def _process_service_status(self, rr: dict) -> dict:
        """Verarbeitet Service-Status-Abfragen."""
        result = rr.get("result", {})
        alerts = []
        next_steps = []

        sp = result.get("service_provider", {})
        mp = result.get("model_provider", {})

        # Services
        services = sp.get("services", [])
        active_services = [s for s in services if s.get("status") == "active"]
        inactive_services = [s for s in services if s.get("status") != "active"]

        # Models
        stats = mp.get("stats", {})
        available_models = stats.get("available_models", 0)
        total_models = stats.get("total_models", 0)
        providers = stats.get("available_providers", [])

        parts = []
        if services:
            parts.append(f"Services: {len(active_services)}/{len(services)} aktiv")
        if total_models:
            parts.append(f"Models: {available_models}/{total_models} ({', '.join(providers)})")

        summary = ". ".join(parts) + "." if parts else "Keine Service-Daten verfuegbar."

        for s in inactive_services:
            name = s.get("name", s.get("id", "?"))
            alerts.append({"level": "warning", "message": f"Service '{name}' ist nicht aktiv"})

        if inactive_services:
            next_steps.append("Inaktive Services pruefen — API Keys gesetzt?")

        if available_models == 0 and total_models > 0:
            alerts.append({"level": "critical", "message": "Kein LLM-Modell verfuegbar"})
            next_steps.insert(0, "SOFORT: API Keys pruefen — kein Modell erreichbar")

        return {
            "status": "success",
            "category": "service_status",
            "summary": summary,
            "detail": result,
            "alerts": alerts,
            "next_steps": next_steps,
            "escalate": available_models == 0 and total_models > 0,
            "escalation_reason": "Kein LLM-Modell verfuegbar — Factory kann nicht arbeiten" if available_models == 0 and total_models > 0 else None,
        }

    def _process_department_task(self, rr: dict) -> dict:
        """Verarbeitet Department-Routing-Empfehlungen."""
        result = rr.get("result", {})
        dept = result.get("recommended_department", "unknown")
        agents = result.get("agents", [])

        if dept == "unknown":
            summary = "Kein passendes Department identifiziert."
            next_steps = ["Anfrage praezisieren oder manuell zuordnen"]
        else:
            agent_str = ", ".join(agents[:3]) if agents else "keine spezifischen Agents"
            summary = f"Empfehlung: {dept}. Agents: {agent_str}."
            next_steps = [f"Department {dept} beauftragen", "Delegation noch nicht automatisiert (Phase 2)"]

        return {
            "status": rr.get("status", "partial"),
            "category": "department_task",
            "summary": summary,
            "detail": result,
            "alerts": [],
            "next_steps": next_steps,
            "escalate": False,
            "escalation_reason": None,
        }

    def _process_repair(self, rr: dict) -> dict:
        """Verarbeitet Repair-Status-Abfragen."""
        result = rr.get("result", {})
        alerts = []
        next_steps = []

        auto_repair = result.get("auto_repair_status", {})
        fixable = result.get("auto_fixable_alerts", 0)
        fixable_details = result.get("fixable_details", [])

        available = auto_repair.get("available", False)
        summary = f"Auto-Repair: {'bereit' if available else 'nicht verfuegbar'}. {fixable} auto-reparierbare Probleme."

        if fixable > 0:
            for d in fixable_details[:3]:
                msg = d.get("message", d.get("type", "Fixable Issue"))
                alerts.append({"level": "info", "message": f"Auto-fixable: {msg}"})
            next_steps.append(f"{fixable} Probleme koennten automatisch repariert werden")
            next_steps.append("Repair braucht CEO-Approval ueber HQ Assistant")

        if not available:
            alerts.append({"level": "warning", "message": "Auto-Repair ist nicht verfuegbar"})
            next_steps.append("Auto-Repair-System pruefen")

        return {
            "status": "success",
            "category": "repair",
            "summary": summary,
            "detail": result,
            "alerts": alerts,
            "next_steps": next_steps,
            "escalate": False,
            "escalation_reason": None,
        }

    def _process_unknown(self, rr: dict) -> dict:
        """Verarbeitet unbekannte Anfragen."""
        follow_up = rr.get("follow_up", "")
        return {
            "status": "error",
            "category": "unknown",
            "summary": "Anfrage nicht zuordbar.",
            "detail": rr.get("result", ""),
            "alerts": [],
            "next_steps": [f"Verfuegbare Routen: {follow_up}"] if follow_up else [],
            "escalate": False,
            "escalation_reason": None,
        }

    # ------------------------------------------------------------------
    # Escalation Logic
    # ------------------------------------------------------------------
    def _determine_escalation(self, processed: dict) -> tuple:
        """Entscheidet ob das Ergebnis an den CEO eskaliert werden muss."""
        if processed.get("escalate"):
            return True, processed.get("escalation_reason")

        alerts = processed.get("alerts", [])
        critical_count = sum(1 for a in alerts if a.get("level") == "critical")
        if critical_count >= _ESCALATION_THRESHOLDS["critical_alerts"]:
            return True, f"{critical_count} Critical Alerts benoetigen CEO-Attention"

        return False, None

    # ------------------------------------------------------------------
    # Brain Style Formatting
    # ------------------------------------------------------------------
    def _format_brain_style(self, text: str) -> str:
        """Entfernt LLM-Floskeln, macht Output direkt und datengetrieben."""
        if not text:
            return text

        result = text.strip()
        for pattern, replacement in _FLOSKEL_PATTERNS:
            result = pattern.sub(replacement, result, count=1)

        # Capitalize first letter after cleanup
        if result and result[0].islower():
            result = result[0].upper() + result[1:]

        return result.strip()

    # ------------------------------------------------------------------
    # LLM Summary (only for multi-source with 3+ sources)
    # ------------------------------------------------------------------
    def _summarize_with_llm(self, data: dict, question: str) -> str:
        """LLM-unterstuetzte Zusammenfassung fuer Multi-Source-Daten."""
        if not self._model_router:
            return ""

        try:
            from factory.brain.persona.brain_system_prompt import get_brain_system_prompt
            from factory.brain.model_provider.provider_router import ProviderRouter

            system_prompt = get_brain_system_prompt(include_state=False)

            # Compact data representation
            compact = {}
            for key, value in data.items():
                if isinstance(value, dict):
                    compact[key] = {k: v for k, v in value.items() if k in ("summary", "status", "total", "count")}
                elif isinstance(value, str):
                    compact[key] = value[:200]

            route_info = self._model_router.route("summarization", tier_lock="premium")
            router = ProviderRouter()
            resp = router.call(
                model_id=route_info["model"],
                provider=route_info["provider"],
                messages=[
                    {"role": "system", "content": system_prompt},
                    {
                        "role": "user",
                        "content": (
                            f"{question}\n\n"
                            f"Daten:\n{compact}\n\n"
                            "Antworte in 2-3 Saetzen. Direkt. Daten-getrieben. Deutsch."
                        ),
                    },
                ],
                max_tokens=150,
                temperature=0.0,
            )

            if resp.error:
                logger.warning("LLM summary failed: %s", resp.error)
                return ""

            return self._format_brain_style(resp.content.strip())
        except Exception as e:
            logger.warning("LLM summary error: %s", e)
            return ""

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    def _wrap_error(self, rr: dict) -> dict:
        """Wraps an error router result into collector format."""
        return {
            "status": "error",
            "category": rr.get("category", "error"),
            "summary": str(rr.get("result", "Unbekannter Fehler")),
            "detail": rr.get("result"),
            "alerts": [],
            "next_steps": [],
            "escalate": False,
            "escalation_reason": None,
        }

    def _empty_result(self, category: str) -> dict:
        """Returns an empty result structure."""
        return {
            "status": "error",
            "category": category,
            "summary": "Keine Daten.",
            "detail": None,
            "alerts": [],
            "next_steps": [],
            "escalate": False,
            "escalation_reason": None,
        }

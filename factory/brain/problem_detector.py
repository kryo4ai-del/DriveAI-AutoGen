"""Factory Problem Detector (BRN-03).

Proaktive Problemerkennung fuer die DriveAI Swarm Factory.
Analysiert FactoryStateCollector-Output und CapabilityMap-Gaps
um Probleme zu erkennen BEVOR sie eskalieren.

100% deterministisch — kein LLM, keine Schreiboperationen.
10 Detection Rules mit konfigurierbaren Thresholds als Class Constants.
"""

import logging
from datetime import datetime, timezone

logger = logging.getLogger(__name__)


class ProblemDetector:
    """Erkennt Probleme in der Factory proaktiv aus State + Capability Daten."""

    # ── Thresholds (Class Constants) ─────────────────────────────────
    CMD_QUEUE_WARN = 100
    CMD_QUEUE_CRIT = 200
    STUCK_HOURS_WARN = 48
    STUCK_HOURS_CRIT = 72
    JANITOR_ISSUES_WARN = 50
    JANITOR_HEALTH_SCORE_MIN = 40
    MIN_AVAILABLE_MODELS = 1
    SUBSYSTEM_MIN_AVAILABLE = 4

    # ── Detection Rules Registry ─────────────────────────────────────
    _RULES = (
        "command_queue_backlog",
        "stuck_projects",
        "service_outages",
        "capability_gaps_blocking",
        "health_monitor_failures",
        "janitor_backlog",
        "auto_repair_anomalies",
        "subsystem_unavailability",
        "model_provider_issues",
        "production_line_limitations",
    )

    def __init__(self, factory_root: str = None):
        self._factory_root = factory_root

    # ── Public API ───────────────────────────────────────────────────

    def run_detection(self, state: dict = None, gaps: list = None) -> dict:
        """Fuehrt alle 10 Detection Rules aus.

        Parameters:
            state: Output von FactoryStateCollector.collect_full_state().
                   Wird lazy geladen wenn None.
            gaps:  Output von CapabilityMap.get_gaps().
                   Wird lazy geladen wenn None.

        Returns:
            {
                "detected_at": ISO timestamp,
                "problems": [...],
                "total_problems": int,
                "critical": int,
                "warnings": int,
                "healthy_systems": [...],
            }
        """
        state = state or self._collect_state()
        gaps = gaps or self._collect_gaps()

        all_problems = []
        healthy = []

        for rule_name in self._RULES:
            method = getattr(self, f"_detect_{rule_name}", None)
            if not method:
                logger.warning("Detection rule method not found: %s", rule_name)
                continue
            try:
                problems = method(state, gaps)
                if problems:
                    all_problems.extend(problems)
                else:
                    healthy.append(rule_name)
            except Exception as e:
                logger.warning("Detection rule '%s' failed: %s", rule_name, e)
                healthy.append(rule_name)  # Don't penalize for rule errors

        critical = sum(1 for p in all_problems if p.get("severity") == "critical")
        warnings = sum(1 for p in all_problems if p.get("severity") == "warning")

        # Optional: Detection-Run ins Memory loggen
        try:
            from factory.brain.memory.memory_writer import MemoryWriter
            writer = MemoryWriter(self._factory_root)
            writer.log_detection_run(
                problems_found=len(all_problems),
                solutions_proposed=0,  # Wird vom SolutionProposer ergaenzt
            )
        except Exception:
            pass  # Memory nicht verfuegbar, kein Problem

        return {
            "detected_at": datetime.now(timezone.utc).isoformat(),
            "problems": all_problems,
            "total_problems": len(all_problems),
            "critical": critical,
            "warnings": warnings,
            "healthy_systems": healthy,
        }

    def run_single_detection(
        self, rule_name: str, state: dict = None, gaps: list = None
    ) -> list:
        """Fuehrt eine einzelne Detection Rule aus.

        Returns:
            Liste von Problem-Dicts (leer wenn healthy).

        Raises:
            ValueError: Wenn rule_name nicht existiert.
        """
        if rule_name not in self._RULES:
            raise ValueError(
                f"Unknown rule '{rule_name}'. Available: {', '.join(self._RULES)}"
            )

        state = state or self._collect_state()
        gaps = gaps or self._collect_gaps()

        method = getattr(self, f"_detect_{rule_name}")
        return method(state, gaps)

    def get_detection_rules(self) -> list[str]:
        """Gibt alle verfuegbaren Detection Rule Namen zurueck."""
        return list(self._RULES)

    # ── Problem Factory ──────────────────────────────────────────────

    @staticmethod
    def _create_problem(
        rule: str,
        severity: str,
        title: str,
        detail: str,
        subsystem: str,
        metric: dict = None,
    ) -> dict:
        """Erzeugt ein standardisiertes Problem-Dict.

        Parameters:
            rule:      Name der Detection Rule.
            severity:  "critical" oder "warning".
            title:     Einzeiler-Zusammenfassung.
            detail:    Ausfuehrliche Beschreibung.
            subsystem: Betroffenes Subsystem (health_monitor, janitor, etc.).
            metric:    Optionale Messwerte {key: value}.
        """
        return {
            "rule": rule,
            "severity": severity,
            "title": title,
            "detail": detail,
            "subsystem": subsystem,
            "metric": metric or {},
        }

    # ── Detection Rules ──────────────────────────────────────────────

    def _detect_command_queue_backlog(self, state: dict, gaps: list) -> list:
        """Rule 1: Command Queue waechst unkontrolliert."""
        problems = []
        cq = state.get("command_queue", {})
        if cq.get("status") == "unavailable":
            return problems

        total = cq.get("total_commands", 0)
        age_days = cq.get("oldest_age_days", 0)

        if total >= self.CMD_QUEUE_CRIT:
            problems.append(self._create_problem(
                rule="command_queue_backlog",
                severity="critical",
                title=f"Command Queue kritisch: {total} Commands",
                detail=f"{total} unverarbeitete Commands (Threshold: {self.CMD_QUEUE_CRIT}). "
                       f"Aeltester Command: {age_days} Tage alt.",
                subsystem="command_queue",
                metric={"total_commands": total, "oldest_age_days": age_days},
            ))
        elif total >= self.CMD_QUEUE_WARN:
            problems.append(self._create_problem(
                rule="command_queue_backlog",
                severity="warning",
                title=f"Command Queue wachsend: {total} Commands",
                detail=f"{total} unverarbeitete Commands (Threshold: {self.CMD_QUEUE_WARN}). "
                       f"Aeltester Command: {age_days} Tage alt.",
                subsystem="command_queue",
                metric={"total_commands": total, "oldest_age_days": age_days},
            ))

        return problems

    def _detect_stuck_projects(self, state: dict, gaps: list) -> list:
        """Rule 2: Projekte stecken in der Pipeline fest."""
        problems = []
        pq = state.get("pipeline_queue", {})
        if pq.get("status") == "unavailable":
            return problems

        stuck = pq.get("stuck_projects", [])
        for project in stuck:
            hours = project.get("stuck_hours", 0)
            name = project.get("name", "unknown")
            phase = project.get("phase", "unknown")

            if hours >= self.STUCK_HOURS_CRIT:
                problems.append(self._create_problem(
                    rule="stuck_projects",
                    severity="critical",
                    title=f"Projekt '{name}' stuck seit {hours}h",
                    detail=f"Projekt '{name}' haengt in Phase '{phase}' seit {hours}h "
                           f"(Threshold: {self.STUCK_HOURS_CRIT}h).",
                    subsystem="pipeline_queue",
                    metric={"stuck_hours": hours, "phase": phase, "project": name},
                ))
            elif hours >= self.STUCK_HOURS_WARN:
                problems.append(self._create_problem(
                    rule="stuck_projects",
                    severity="warning",
                    title=f"Projekt '{name}' verzoegert ({hours}h)",
                    detail=f"Projekt '{name}' in Phase '{phase}' seit {hours}h ohne Update "
                           f"(Threshold: {self.STUCK_HOURS_WARN}h).",
                    subsystem="pipeline_queue",
                    metric={"stuck_hours": hours, "phase": phase, "project": name},
                ))

        return problems

    def _detect_service_outages(self, state: dict, gaps: list) -> list:
        """Rule 3: Services sind registriert aber nicht aktiv."""
        problems = []
        sp = state.get("service_provider", {})
        if sp.get("status") == "unavailable":
            return problems

        inactive = sp.get("inactive_services", [])
        total = sp.get("total_services", 0)
        active_count = len(sp.get("active_services", []))

        if total > 0 and active_count == 0:
            problems.append(self._create_problem(
                rule="service_outages",
                severity="critical",
                title=f"Alle {total} Services inaktiv",
                detail=f"Kein einziger Service ist aktiv. "
                       f"Inaktive Services: {', '.join(inactive[:5])}.",
                subsystem="service_provider",
                metric={"total": total, "active": 0, "inactive": len(inactive)},
            ))
        elif inactive:
            problems.append(self._create_problem(
                rule="service_outages",
                severity="warning",
                title=f"{len(inactive)} von {total} Services inaktiv",
                detail=f"Inaktive Services: {', '.join(inactive[:5])}.",
                subsystem="service_provider",
                metric={"total": total, "active": active_count, "inactive": len(inactive)},
            ))

        return problems

    def _detect_capability_gaps_blocking(self, state: dict, gaps: list) -> list:
        """Rule 4: RED Capability Gaps blockieren die Factory."""
        problems = []

        red_gaps = [g for g in gaps if g.get("severity") == "red"]
        if not red_gaps:
            return problems

        for gap in red_gaps:
            problems.append(self._create_problem(
                rule="capability_gaps_blocking",
                severity="critical",
                title=f"Blocking Gap: {gap.get('type', 'unknown')}",
                detail=gap.get("message", "Keine Details"),
                subsystem=gap.get("area", "unknown"),
                metric={"gap_type": gap.get("type"), "name": gap.get("name")},
            ))

        return problems

    def _detect_health_monitor_failures(self, state: dict, gaps: list) -> list:
        """Rule 5: Health Monitor meldet kritische Alerts."""
        problems = []
        hm = state.get("health_monitor", {})
        if hm.get("status") == "unavailable":
            return problems

        critical = hm.get("critical", 0)
        warnings = hm.get("warnings", 0)
        alerts = hm.get("alerts", [])

        if critical > 0:
            # Group by category for better overview
            categories = {}
            for a in alerts:
                if a.get("severity") == "critical":
                    cat = a.get("category", "unknown")
                    categories.setdefault(cat, []).append(a.get("message", ""))

            for cat, msgs in categories.items():
                problems.append(self._create_problem(
                    rule="health_monitor_failures",
                    severity="critical",
                    title=f"Health Critical: {cat} ({len(msgs)}x)",
                    detail=f"Kritische Alerts in '{cat}': {'; '.join(msgs[:3])}",
                    subsystem="health_monitor",
                    metric={"category": cat, "count": len(msgs), "critical_total": critical},
                ))
        elif warnings > 5:
            problems.append(self._create_problem(
                rule="health_monitor_failures",
                severity="warning",
                title=f"Health Monitor: {warnings} Warnings",
                detail=f"{warnings} Warnings aktiv. Kein Critical, aber Trend beobachten.",
                subsystem="health_monitor",
                metric={"warnings": warnings, "critical": 0},
            ))

        return problems

    def _detect_janitor_backlog(self, state: dict, gaps: list) -> list:
        """Rule 6: Janitor hat zu viele offene Issues."""
        problems = []
        jan = state.get("janitor", {})
        if jan.get("status") == "unavailable":
            return problems

        issues = jan.get("issues_found", 0)
        health_score = jan.get("health_score")
        growth_alerts = jan.get("growth_alerts", 0)

        if health_score is not None and health_score < self.JANITOR_HEALTH_SCORE_MIN:
            problems.append(self._create_problem(
                rule="janitor_backlog",
                severity="critical",
                title=f"Janitor Health Score kritisch: {health_score}",
                detail=f"Health Score {health_score} unter Minimum {self.JANITOR_HEALTH_SCORE_MIN}. "
                       f"{issues} offene Issues, {growth_alerts} Growth Alerts.",
                subsystem="janitor",
                metric={"health_score": health_score, "issues": issues, "growth_alerts": growth_alerts},
            ))
        elif issues >= self.JANITOR_ISSUES_WARN:
            problems.append(self._create_problem(
                rule="janitor_backlog",
                severity="warning",
                title=f"Janitor Backlog: {issues} Issues",
                detail=f"{issues} offene Issues (Threshold: {self.JANITOR_ISSUES_WARN}). "
                       f"Health Score: {health_score or 'N/A'}.",
                subsystem="janitor",
                metric={"issues": issues, "health_score": health_score},
            ))

        return problems

    def _detect_auto_repair_anomalies(self, state: dict, gaps: list) -> list:
        """Rule 7: Auto-Repair Modul nicht verfuegbar oder aktive Repairs."""
        problems = []
        ar = state.get("auto_repair", {})
        if ar.get("status") == "unavailable":
            problems.append(self._create_problem(
                rule="auto_repair_anomalies",
                severity="warning",
                title="Auto-Repair Subsystem nicht erreichbar",
                detail="Das Auto-Repair Modul konnte nicht geladen werden. "
                       "Automatische Reparaturen sind nicht moeglich.",
                subsystem="auto_repair",
            ))
            return problems

        if not ar.get("module_available", False):
            problems.append(self._create_problem(
                rule="auto_repair_anomalies",
                severity="warning",
                title="Auto-Repair Modul nicht installiert",
                detail="auto_repair.py nicht gefunden. Automatische Reparaturen deaktiviert.",
                subsystem="auto_repair",
            ))

        active = ar.get("active_repairs", 0)
        if active > 0:
            problems.append(self._create_problem(
                rule="auto_repair_anomalies",
                severity="warning",
                title=f"Auto-Repair: {active} aktive Reparaturen",
                detail=f"{active} Reparaturen laufen gerade. System instabil.",
                subsystem="auto_repair",
                metric={"active_repairs": active},
            ))

        return problems

    def _detect_subsystem_unavailability(self, state: dict, gaps: list) -> list:
        """Rule 8: Zu viele Subsysteme nicht erreichbar."""
        problems = []
        subsystems = (
            "health_monitor", "janitor", "pipeline_queue", "project_registry",
            "service_provider", "model_provider", "command_queue", "auto_repair",
        )

        unavailable = []
        for name in subsystems:
            sub = state.get(name, {})
            if sub.get("status") == "unavailable":
                unavailable.append(name)

        available = len(subsystems) - len(unavailable)

        if unavailable and available < self.SUBSYSTEM_MIN_AVAILABLE:
            problems.append(self._create_problem(
                rule="subsystem_unavailability",
                severity="critical",
                title=f"Nur {available}/{len(subsystems)} Subsysteme erreichbar",
                detail=f"Nicht erreichbar: {', '.join(unavailable)}. "
                       f"Minimum: {self.SUBSYSTEM_MIN_AVAILABLE}.",
                subsystem="factory",
                metric={"available": available, "unavailable": unavailable},
            ))
        elif unavailable:
            problems.append(self._create_problem(
                rule="subsystem_unavailability",
                severity="warning",
                title=f"{len(unavailable)} Subsystem(e) nicht erreichbar",
                detail=f"Nicht erreichbar: {', '.join(unavailable)}.",
                subsystem="factory",
                metric={"available": available, "unavailable": unavailable},
            ))

        return problems

    def _detect_model_provider_issues(self, state: dict, gaps: list) -> list:
        """Rule 9: Keine LLM-Modelle verfuegbar."""
        problems = []
        mp = state.get("model_provider", {})
        if mp.get("status") == "unavailable":
            problems.append(self._create_problem(
                rule="model_provider_issues",
                severity="critical",
                title="Model Provider nicht erreichbar",
                detail="Das Model Provider Modul ist nicht verfuegbar. "
                       "Kein LLM-Zugriff moeglich.",
                subsystem="model_provider",
            ))
            return problems

        available = mp.get("available_models", 0)
        registered = mp.get("registered_models", 0)
        providers = mp.get("available_providers", [])

        if registered > 0 and available < self.MIN_AVAILABLE_MODELS:
            problems.append(self._create_problem(
                rule="model_provider_issues",
                severity="critical",
                title=f"Keine LLM-Modelle verfuegbar ({available}/{registered})",
                detail=f"{registered} Modelle registriert, aber nur {available} verfuegbar. "
                       f"Fehlende API-Keys? Provider: {', '.join(providers) or 'keine'}.",
                subsystem="model_provider",
                metric={"registered": registered, "available": available, "providers": providers},
            ))
        elif registered > 0 and available < registered // 2:
            problems.append(self._create_problem(
                rule="model_provider_issues",
                severity="warning",
                title=f"Nur {available}/{registered} Modelle verfuegbar",
                detail=f"Weniger als die Haelfte der registrierten Modelle ist verfuegbar. "
                       f"Aktive Provider: {', '.join(providers)}.",
                subsystem="model_provider",
                metric={"registered": registered, "available": available, "providers": providers},
            ))

        # Health report check
        health = mp.get("latest_health_report", {})
        if health and health.get("all_healthy") is False:
            problems.append(self._create_problem(
                rule="model_provider_issues",
                severity="warning",
                title="Model Provider Health Check fehlgeschlagen",
                detail="Mindestens ein Provider meldet Probleme im letzten Health Check.",
                subsystem="model_provider",
                metric={"health_report": health},
            ))

        return problems

    def _detect_production_line_limitations(self, state: dict, gaps: list) -> list:
        """Rule 10: Production Lines nicht operativ."""
        problems = []

        # Use gaps data for line issues
        line_gaps = [g for g in gaps if g.get("area") == "production_lines"]

        no_code = [g for g in line_gaps if g.get("type") == "line_no_code"]
        inactive = [g for g in line_gaps if g.get("type") == "line_inactive"]

        if no_code:
            names = [g.get("name", "?") for g in no_code]
            problems.append(self._create_problem(
                rule="production_line_limitations",
                severity="warning",
                title=f"{len(no_code)} Line(s) ohne Code",
                detail=f"Lines ohne Implementierung: {', '.join(names)}.",
                subsystem="production_lines",
                metric={"lines_no_code": names},
            ))

        if inactive:
            names = [g.get("name", "?") for g in inactive]
            problems.append(self._create_problem(
                rule="production_line_limitations",
                severity="warning",
                title=f"{len(inactive)} Line(s) nicht aktiv",
                detail=f"Lines mit Code aber nicht aktiv: {', '.join(names)}.",
                subsystem="production_lines",
                metric={"lines_inactive": names},
            ))

        return problems

    # ── Lazy Data Loading ────────────────────────────────────────────

    def _collect_state(self) -> dict:
        """Lazy-Load: FactoryStateCollector aufrufen."""
        try:
            from factory.brain.factory_state import FactoryStateCollector
            fsc = FactoryStateCollector(self._factory_root)
            return fsc.collect_full_state()
        except Exception as e:
            logger.error("Failed to collect factory state: %s", e)
            return {}

    def _collect_gaps(self) -> list:
        """Lazy-Load: CapabilityMap.get_gaps() aufrufen."""
        try:
            from factory.brain.capability_map import CapabilityMap
            cm = CapabilityMap(self._factory_root)
            return cm.get_gaps()
        except Exception as e:
            logger.error("Failed to collect capability gaps: %s", e)
            return []

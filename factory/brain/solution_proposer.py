"""Factory Solution Proposer (BRN-04).

Wandelt erkannte Probleme (ProblemDetector) in konkrete, ausfuehrbare
Loesungsvorschlaege um. Priorisiert, gruppiert und kategorisiert nach:
- Dringlichkeit (CRITICAL zuerst)
- Aufwand (Quick Wins vs. groessere Projekte)
- Approval-Level (auto-approvable vs. CEO-required)

100% deterministisch. Kein LLM. Fuehrt KEINE Aktionen aus —
erstellt nur den Loesungsplan.
"""

import json
import logging
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)

_DEFAULT_ROOT = Path(__file__).resolve().parents[2]

# ── Rule → Solution Generator Mapping ────────────────────────────
_RULE_TO_SOLVER = {
    "command_queue_backlog": "_solve_command_queue_backlog",
    "stuck_projects": "_solve_stuck_project",
    "service_outages": "_solve_service_outage",
    "capability_gaps_blocking": "_solve_capability_gap",
    "health_monitor_failures": "_solve_health_monitor_failure",
    "janitor_backlog": "_solve_janitor_backlog",
    "auto_repair_anomalies": "_solve_auto_repair_anomaly",
    "subsystem_unavailability": "_solve_subsystem_unavailability",
    "model_provider_issues": "_solve_model_provider_issue",
    "production_line_limitations": "_solve_production_line_limitation",
}


class SolutionProposer:
    """Wandelt erkannte Probleme in konkrete Loesungsvorschlaege um."""

    def __init__(self, factory_root: str = None):
        self.root = Path(factory_root) if factory_root else _DEFAULT_ROOT
        self._service_registry = None  # lazy loaded

    # ── Public API ───────────────────────────────────────────────────

    def propose_solutions(self, problems: list = None) -> dict:
        """Hauptmethode. Nimmt Probleme vom ProblemDetector und erstellt Loesungsvorschlaege.

        Wenn problems=None, ruft intern ProblemDetector.run_detection() auf.

        Returns:
            {
                "proposed_at": ISO timestamp,
                "problem_count": int,
                "solution_count": int,
                "solutions": [Solution, ...],
                "execution_plan": {
                    "immediate": [...],
                    "needs_approval": [...],
                    "long_term": [...]
                },
                "estimated_impact": str
            }
        """
        if problems is None:
            problems = self._detect_problems()

        solutions = []
        for problem in problems:
            try:
                solution = self.propose_for_single(problem)
                if solution:
                    solutions.append(solution)
                    logger.info(
                        "Solution: %s → %s [%s]",
                        solution.get("for_problem"),
                        solution.get("solution_id"),
                        solution.get("approval_level"),
                    )
            except Exception as e:
                logger.warning("Solution generation failed for '%s': %s", problem.get("rule"), e)
                # Never ignore — create generic escalation
                solutions.append(self._create_generic_escalation(problem))

        solutions = self._prioritize_solutions(solutions)
        plan = self._build_execution_plan(solutions)

        solvable = sum(1 for s in solutions if s.get("approval_level") != "info_only")
        return {
            "proposed_at": datetime.now(timezone.utc).isoformat(),
            "problem_count": len(problems),
            "solution_count": len(solutions),
            "solutions": solutions,
            "execution_plan": plan,
            "estimated_impact": f"Loest {solvable} von {len(problems)} Problemen",
        }

    def propose_for_single(self, problem: dict) -> dict:
        """Erstellt Loesungsvorschlag fuer ein einzelnes Problem."""
        rule = problem.get("rule", "")
        solver_name = _RULE_TO_SOLVER.get(rule)

        if not solver_name:
            logger.warning("No solver for rule '%s', creating generic escalation", rule)
            return self._create_generic_escalation(problem)

        solver = getattr(self, solver_name, None)
        if not solver:
            return self._create_generic_escalation(problem)

        return solver(problem)

    # ── Solution Generators ──────────────────────────────────────────

    def _solve_command_queue_backlog(self, problem: dict) -> dict:
        """Problem: command_queue_backlog → Archivierung via Janitor."""
        metric = problem.get("metric", {})
        total = metric.get("total_commands", 0)
        age = metric.get("oldest_age_days", 0)
        severity = problem.get("severity", "warning")

        if severity == "critical":
            return self._create_solution(
                solution_id="SOL_CMD_ARCHIVE_URGENT",
                for_problem="command_queue_backlog",
                title=f"Command Queue dringend archivieren ({total} Commands)",
                description=f"{total} unverarbeitete Commands, aeltester {age} Tage. "
                            "Sofortige Archivierung erledigter Commands empfohlen.",
                delegate_to="janitor",
                action_type="cleanup",
                approval_level="auto",
                steps=[
                    "Janitor: Scanne _commands/ nach erledigten Commands (status=done/processed)",
                    "Janitor: Verschiebe erledigte Commands aelter als 7 Tage nach _commands/archive/",
                    "Janitor: Pruefe verbleibende Commands auf Duplikate",
                    "Janitor: Melde Ergebnis an TheBrain",
                ],
                estimated_effort="minimal",
                priority=1,
                risk="none",
            )

        return self._create_solution(
            solution_id="SOL_CMD_ARCHIVE",
            for_problem="command_queue_backlog",
            title=f"Command Queue archivieren ({total} Commands)",
            description=f"{total} unverarbeitete Commands, aeltester {age} Tage. "
                        "Erledigte Commands in Archiv-Ordner verschieben.",
            delegate_to="janitor",
            action_type="cleanup",
            approval_level="auto",
            steps=[
                "Janitor: Scanne _commands/ nach erledigten Commands",
                "Janitor: Verschiebe erledigte Commands aelter als 7 Tage nach _commands/archive/",
                "Janitor: Melde Ergebnis an TheBrain",
            ],
            estimated_effort="minimal",
            priority=3,
            risk="none",
        )

    def _solve_stuck_project(self, problem: dict) -> dict:
        """Problem: stuck_projects → Phase-abhaengige Empfehlung."""
        metric = problem.get("metric", {})
        name = metric.get("project", "unknown")
        phase = metric.get("phase", "unknown")
        hours = metric.get("stuck_hours", 0)

        phase_lower = phase.lower()

        # CEO Gate → wartet auf CEO
        if "gate" in phase_lower or "ceo" in phase_lower or "approval" in phase_lower:
            return self._create_solution(
                solution_id="SOL_STUCK_CEO_GATE",
                for_problem="stuck_projects",
                title=f"Projekt '{name}' wartet auf CEO-Approval ({hours}h)",
                description=f"Projekt '{name}' haengt in Phase '{phase}' seit {hours}h. "
                            "Wartet auf CEO-Gate-Entscheidung.",
                delegate_to="ceo",
                action_type="escalate",
                approval_level="ceo_required",
                steps=[
                    f"CEO: Projekt '{name}' im Gate-Dashboard pruefen",
                    "CEO: Gate-Entscheidung treffen (approve/reject/revise)",
                    "TheBrain: Nach Entscheidung Pipeline fortsetzen",
                ],
                estimated_effort="minimal",
                priority=1 if hours >= 72 else 2,
                risk="none",
            )

        # Andere Phasen → Diagnose empfohlen
        return self._create_solution(
            solution_id="SOL_STUCK_DIAGNOSE",
            for_problem="stuck_projects",
            title=f"Projekt '{name}' stuck in '{phase}' ({hours}h) — Diagnose empfohlen",
            description=f"Projekt '{name}' seit {hours}h in Phase '{phase}' ohne Update. "
                        "Manuelle Diagnose empfohlen.",
            delegate_to="ceo",
            action_type="escalate",
            approval_level="ceo_required",
            steps=[
                f"CEO: Projekt '{name}' pruefen — warum steckt Phase '{phase}' fest?",
                "TheBrain: Pipeline-Logs auf Fehler pruefen",
                "CEO: Entscheiden ob Projekt fortsetzen, zuruecksetzen oder archivieren",
            ],
            estimated_effort="moderate",
            priority=1 if hours >= 72 else 2,
            risk="low",
        )

    def _solve_service_outage(self, problem: dict) -> dict:
        """Problem: service_outages → Fallback, Draft-Adapter oder Info."""
        metric = problem.get("metric", {})
        inactive_count = metric.get("inactive", 0)
        active_count = metric.get("active", 0)
        total = metric.get("total", 0)

        # All services down → critical
        if total > 0 and active_count == 0:
            return self._create_solution(
                solution_id="SOL_SERVICE_ALL_DOWN",
                for_problem="service_outages",
                title=f"Alle {total} Services inaktiv — Sofortmassnahme",
                description="Kein einziger externer Service ist aktiv. "
                            "Pruefen ob API-Keys gueltig und Services erreichbar sind.",
                delegate_to="ceo",
                action_type="escalate",
                approval_level="ceo_required",
                steps=[
                    "CEO: API-Keys in .env pruefen (OPENAI_API_KEY, STABILITY_API_KEY, ELEVENLABS_API_KEY)",
                    "TheBrain: Service-Health-Check fuer alle Provider ausfuehren",
                    "CEO: Fehlende API-Keys eintragen oder Budget freigeben",
                ],
                estimated_effort="moderate",
                priority=1,
                risk="medium",
            )

        # Some inactive — check for alternatives
        registry = self._load_service_registry()
        services = registry.get("services", {})
        inactive_names = []
        solutions_detail = []

        for sid, svc in services.items():
            if svc.get("status") != "inactive":
                continue
            name = svc.get("name", sid)
            category = svc.get("category", "unknown")
            inactive_names.append(name)

            # Check for alternatives in same category
            alternatives = self._find_alternative_services(category)
            active_alts = [a for a in alternatives if a.get("status") == "active"]
            draft_alts = [a for a in alternatives if a.get("type") == "draft"]

            if active_alts:
                solutions_detail.append(
                    f"{name} ({category}): Fallback verfuegbar — {active_alts[0]['name']} ist aktiv"
                )
            elif draft_alts:
                draft = draft_alts[0]
                solutions_detail.append(
                    f"{name} ({category}): Draft-Adapter '{draft['name']}' vorhanden — API-Key noetig"
                )
            else:
                solutions_detail.append(
                    f"{name} ({category}): Kein Fallback verfuegbar"
                )

        detail_text = "; ".join(solutions_detail) if solutions_detail else "Keine Details"
        needs_action = any("Draft-Adapter" in s or "Kein Fallback" in s for s in solutions_detail)

        return self._create_solution(
            solution_id="SOL_SERVICE_PARTIAL",
            for_problem="service_outages",
            title=f"{inactive_count} Services inaktiv — Alternativen pruefen",
            description=f"{inactive_count} von {total} Services sind inaktiv. {detail_text}.",
            delegate_to="ceo" if needs_action else "info",
            action_type="activate_service" if needs_action else "monitor",
            approval_level="ceo_required" if needs_action else "info_only",
            steps=self._build_service_activation_steps(services),
            estimated_effort="moderate" if needs_action else "minimal",
            priority=2,
            risk="low",
        )

    def _solve_capability_gap(self, problem: dict) -> dict:
        """Problem: capability_gaps_blocking (RED) → DIR-001 Stufenlogik anwenden."""
        metric = problem.get("metric", {})
        gap_type = metric.get("gap_type", "unknown")
        gap_name = metric.get("name", "unknown")

        # category_no_active_service → DIR-001 Stufenlogik
        if gap_type == "category_no_active_service":
            category = gap_name
            alternatives = self._find_alternative_services(category)
            active_alts = [a for a in alternatives if a.get("status") == "active"]
            inactive_alts = [a for a in alternatives if a.get("status") == "inactive"]
            draft_alts = [a for a in alternatives if a.get("type") == "draft"]

            # ── DIR-001 Stufe 1: Eigene Mittel (bestehende aktive Services)
            if active_alts:
                alt = active_alts[0]
                solution = self._create_solution(
                    solution_id=f"SOL_GAP_INTERNAL_{category.upper()}",
                    for_problem="capability_gaps_blocking",
                    title=f"Kategorie '{category}': Bestehenden Service '{alt['name']}' nutzen (Stufe 1)",
                    description=f"DIR-001 Self-First: Aktiver Service '{alt['name']}' als Loesung fuer '{category}'.",
                    delegate_to="info",
                    action_type="activate_service",
                    approval_level="auto",
                    steps=[
                        f"TheBrain: Service '{alt['name']}' fuer Kategorie '{category}' konfigurieren",
                        "TheBrain: Health-Check nach Konfiguration ausfuehren",
                    ],
                    estimated_effort="minimal",
                    priority=1,
                    risk="none",
                )
                solution["directive_compliance"] = "stufe_1"
                solution["self_host_plan"] = None
                logger.info("DIR-001 applied: %s resolved via Stufe 1 (existing service)", category)
                return solution

            # ── DIR-001 Stufe 2/3: Selbst entwickeln oder Self-Host
            solution = self._create_solution(
                solution_id=f"SOL_GAP_SELFHOST_{category.upper()}",
                for_problem="capability_gaps_blocking",
                title=f"Kategorie '{category}': Self-Build/Self-Host evaluieren (DIR-001 Stufe 2/3)",
                description=f"DIR-001 Self-First: Open-Source-Modell fuer '{category}' auf Proxmox-Server "
                            "deployen oder eigene Capability entwickeln. Keine externe API-Abhaengigkeit.",
                delegate_to="ceo",
                action_type="evaluate",
                approval_level="ceo_required",
                steps=[
                    f"Pruefe Stufe 2: Eigene '{category}'-Capability entwickeln (Agent/Pipeline)",
                    f"Pruefe Stufe 3: Open-Source-Modelle fuer '{category}' evaluieren (Proxmox Self-Host)",
                    "Infrastruktur: Server-Kapazitaet pruefen",
                    "Entwicklung: Docker-Container + Adapter implementieren",
                ],
                estimated_effort="significant",
                priority=2,
                risk="medium",
            )
            solution["directive_compliance"] = "stufe_2_3"
            solution["self_host_plan"] = None

            # Stufe 4 Fallback erwaehnen (aber nicht empfehlen)
            if draft_alts or inactive_alts:
                fallback = draft_alts[0] if draft_alts else inactive_alts[0]
                fallback_name = fallback.get("name", "?")
                solution["steps"].append(
                    f"Stufe 4 Fallback (NUR mit CEO-Approval): '{fallback_name}' temporaer aktivieren, "
                    "Abloese-Plan innerhalb 6 Monaten"
                )
                solution["self_host_plan"] = (
                    f"Temporaer '{fallback_name}' nutzen, parallel Self-Hosting aufbauen. "
                    "Migration innerhalb 6 Monaten."
                )
                logger.info(
                    "DIR-001 applied: %s → Stufe 2/3 empfohlen, Stufe 4 Fallback '%s' erwaehnt",
                    category, fallback_name,
                )
            else:
                logger.info("DIR-001 applied: %s → Stufe 2/3 empfohlen, kein Fallback", category)

            return solution

        # department_no_active — Departments ohne aktive Agents
        if gap_type == "department_no_active":
            return self._create_solution(
                solution_id=f"SOL_GAP_DEPT_{gap_name.upper().replace(' ', '_')}",
                for_problem="capability_gaps_blocking",
                title=f"Department '{gap_name}' hat keine aktiven Agents",
                description=f"Department '{gap_name}' hat Agents registriert aber keinen aktiven. "
                            "Agents aktivieren oder Department-Planung pruefen.",
                delegate_to="ceo",
                action_type="escalate",
                approval_level="ceo_required",
                steps=[
                    f"CEO: Pruefen ob Department '{gap_name}' noch benoetigt wird",
                    "Falls ja: Agents aktivieren oder neue Agents planen",
                    "Falls nein: Department als archiviert markieren",
                ],
                estimated_effort="moderate",
                priority=2,
                risk="low",
            )

        # Forge ohne Orchestrator
        if gap_type == "forge_no_orchestrator":
            return self._create_solution(
                solution_id=f"SOL_GAP_FORGE_{gap_name.upper().replace(' ', '_')}",
                for_problem="capability_gaps_blocking",
                title=f"Forge '{gap_name}' hat keinen Orchestrator",
                description=f"Forge '{gap_name}' existiert aber hat keinen Orchestrator. "
                            "Implementierung noetig fuer volle Funktionalitaet.",
                delegate_to="ceo",
                action_type="evaluate",
                approval_level="ceo_required",
                steps=[
                    f"CEO: Prioritaet fuer Forge '{gap_name}' festlegen",
                    "Entwicklung: Orchestrator-Datei erstellen",
                    "QA: Forge-Integration testen",
                ],
                estimated_effort="significant",
                priority=3,
                risk="low",
            )

        # Generic RED gap
        return self._create_solution(
            solution_id=f"SOL_GAP_GENERIC_{gap_type.upper()}",
            for_problem="capability_gaps_blocking",
            title=f"RED Gap: {gap_type} bei '{gap_name}'",
            description=problem.get("detail", "Blocking Capability Gap erkannt."),
            delegate_to="ceo",
            action_type="escalate",
            approval_level="ceo_required",
            steps=[
                "CEO: Gap-Details pruefen",
                "CEO: Priorisierung und Loesungsweg festlegen",
            ],
            estimated_effort="moderate",
            priority=1,
            risk="medium",
        )

    def _solve_janitor_backlog(self, problem: dict) -> dict:
        """Problem: janitor_backlog → Janitor Scan + Cleanup."""
        metric = problem.get("metric", {})
        issues = metric.get("issues", 0)
        health_score = metric.get("health_score")
        severity = problem.get("severity", "warning")

        if severity == "critical":
            return self._create_solution(
                solution_id="SOL_JANITOR_DEEP_CLEAN",
                for_problem="janitor_backlog",
                title=f"Janitor Deep-Clean (Health Score: {health_score})",
                description=f"Janitor Health Score bei {health_score}, {issues} offene Issues. "
                            "Vollstaendiger Scan mit Auto-Fix empfohlen.",
                delegate_to="janitor",
                action_type="cleanup",
                approval_level="auto",
                steps=[
                    "Janitor: Weekly Scan ausfuehren (python -m factory.hq.janitor weekly)",
                    "Janitor: Auto-fixable Issues automatisch beheben",
                    "Janitor: Yellow-Proposals fuer CEO-Review vorbereiten",
                    "Janitor: Ergebnis-Report an TheBrain melden",
                ],
                estimated_effort="minimal",
                priority=2,
                risk="none",
            )

        return self._create_solution(
            solution_id="SOL_JANITOR_SCAN",
            for_problem="janitor_backlog",
            title=f"Janitor Scan empfohlen ({issues} Issues)",
            description=f"{issues} offene Issues. Regulaerer Scan mit Cleanup empfohlen.",
            delegate_to="janitor",
            action_type="cleanup",
            approval_level="auto",
            steps=[
                "Janitor: Daily Scan ausfuehren (python -m factory.hq.janitor daily)",
                "Janitor: Gefundene Issues nach Schwere sortieren",
                "Janitor: Auto-fixable Issues automatisch beheben",
                "Janitor: Melde Ergebnis an TheBrain",
            ],
            estimated_effort="minimal",
            priority=3,
            risk="none",
        )

    def _solve_health_monitor_failure(self, problem: dict) -> dict:
        """Problem: health_monitor_failures → Auto-Repair oder CEO-Meldung."""
        metric = problem.get("metric", {})
        severity = problem.get("severity", "warning")
        category = metric.get("category", "unknown")
        count = metric.get("count", 0)

        if severity == "critical":
            return self._create_solution(
                solution_id=f"SOL_HEALTH_CRIT_{category.upper()}",
                for_problem="health_monitor_failures",
                title=f"Kritische Health-Alerts: {category} ({count}x)",
                description=f"{count} kritische Alerts in Kategorie '{category}'. "
                            "Auto-Repair pruefen, ggf. CEO-Intervention.",
                delegate_to="auto_repair",
                action_type="repair",
                approval_level="ceo_required",
                steps=[
                    "Auto-Repair: Pruefe ob Alerts auto-fixable sind",
                    "Falls ja: Auto-Repair ausfuehren (mit CEO-Approval)",
                    f"Falls nein: CEO ueber kritische '{category}'-Probleme informieren",
                    "TheBrain: Nach Repair erneuten Health-Check ausfuehren",
                ],
                estimated_effort="moderate",
                priority=1,
                risk="low",
            )

        # Warning level
        return self._create_solution(
            solution_id="SOL_HEALTH_WARN",
            for_problem="health_monitor_failures",
            title=f"Health Warnings beobachten ({metric.get('warnings', 0)}x)",
            description="Mehrere Warnings aktiv. Kein sofortiger Handlungsbedarf, "
                        "aber Trend beobachten.",
            delegate_to="info",
            action_type="monitor",
            approval_level="info_only",
            steps=[
                "TheBrain: Health-Monitor-Trend beobachten",
                "Bei Verschlechterung: Eskalation an CEO",
            ],
            estimated_effort="minimal",
            priority=4,
            risk="none",
        )

    def _solve_auto_repair_anomaly(self, problem: dict) -> dict:
        """Problem: auto_repair_anomalies → System-Check oder CEO-Review."""
        metric = problem.get("metric", {})
        active_repairs = metric.get("active_repairs", 0)
        title = problem.get("title", "")

        if active_repairs > 0:
            return self._create_solution(
                solution_id="SOL_REPAIR_ACTIVE",
                for_problem="auto_repair_anomalies",
                title=f"Auto-Repair: {active_repairs} laufende Reparaturen — CEO-Review",
                description=f"{active_repairs} Reparaturen gleichzeitig aktiv. "
                            "Deutet auf systematisches Problem hin.",
                delegate_to="ceo",
                action_type="escalate",
                approval_level="ceo_required",
                steps=[
                    "CEO: Auto-Repair-Logs pruefen — was wird repariert?",
                    "CEO: Root Cause identifizieren (warum so viele Repairs?)",
                    "CEO: Entscheiden ob Repairs fortsetzen oder stoppen",
                ],
                estimated_effort="moderate",
                priority=2,
                risk="medium",
            )

        # Module unavailable
        return self._create_solution(
            solution_id="SOL_REPAIR_UNAVAIL",
            for_problem="auto_repair_anomalies",
            title="Auto-Repair Modul nicht verfuegbar — System-Check",
            description="Auto-Repair kann nicht geladen werden. "
                        "Automatische Reparaturen sind deaktiviert.",
            delegate_to="ceo",
            action_type="escalate",
            approval_level="ceo_required",
            steps=[
                "CEO: Pruefen ob factory/hq/auto_repair.py existiert und importierbar ist",
                "CEO: Dependencies pruefen (fehlende Module?)",
                "TheBrain: Nach Fix erneuten System-Check ausfuehren",
            ],
            estimated_effort="moderate",
            priority=3,
            risk="low",
        )

    def _solve_subsystem_unavailability(self, problem: dict) -> dict:
        """Problem: subsystem_unavailability → Spezifische Empfehlung pro Subsystem."""
        metric = problem.get("metric", {})
        unavailable = metric.get("unavailable", [])
        available = metric.get("available", 8)
        severity = problem.get("severity", "warning")

        subsystem_hints = {
            "health_monitor": "factory/hq/health_monitor.py importierbar?",
            "janitor": "factory/hq/janitor/ Verzeichnis + Konfiguration vorhanden?",
            "pipeline_queue": "factory/dispatcher/queue_store.json vorhanden?",
            "project_registry": "factory/projects/ Verzeichnis vorhanden?",
            "service_provider": "factory/brain/service_registry.json vorhanden?",
            "model_provider": "factory/brain/model_provider/ Modul importierbar?",
            "command_queue": "_commands/ Verzeichnis vorhanden?",
            "auto_repair": "factory/hq/auto_repair.py importierbar?",
        }

        steps = []
        for sub in unavailable:
            hint = subsystem_hints.get(sub, "Modul pruefen")
            steps.append(f"Pruefen: {sub} — {hint}")
        steps.append("TheBrain: Nach Fixes erneuten State-Check ausfuehren")

        return self._create_solution(
            solution_id="SOL_SUBSYSTEM_CHECK",
            for_problem="subsystem_unavailability",
            title=f"{len(unavailable)} Subsystem(e) nicht erreichbar",
            description=f"Nicht erreichbar: {', '.join(unavailable)}. "
                        f"Nur {available}/8 Subsysteme verfuegbar.",
            delegate_to="ceo",
            action_type="repair",
            approval_level="ceo_required" if severity == "critical" else "info_only",
            steps=steps,
            estimated_effort="moderate",
            priority=1 if severity == "critical" else 3,
            risk="low",
        )

    def _solve_model_provider_issue(self, problem: dict) -> dict:
        """Problem: model_provider_issues → Fallback-Routing oder CEO-Meldung."""
        metric = problem.get("metric", {})
        available = metric.get("available", 0)
        registered = metric.get("registered", 0)
        providers = metric.get("providers", [])
        severity = problem.get("severity", "warning")

        if severity == "critical" and available == 0:
            return self._create_solution(
                solution_id="SOL_MODEL_NONE",
                for_problem="model_provider_issues",
                title="Keine LLM-Modelle verfuegbar — Factory blockiert",
                description=f"{registered} Modelle registriert, 0 verfuegbar. "
                            "Kein LLM-Zugriff moeglich. Factory kann nicht arbeiten.",
                delegate_to="ceo",
                action_type="escalate",
                approval_level="ceo_required",
                steps=[
                    "CEO: ANTHROPIC_API_KEY in .env pruefen",
                    "CEO: API-Guthaben und Rate Limits pruefen",
                    "CEO: Ggf. Fallback-Provider konfigurieren (Google Gemini)",
                    "TheBrain: Nach Fix Model-Provider Health-Check ausfuehren",
                ],
                estimated_effort="moderate",
                priority=1,
                risk="high",
            )

        if "health_report" in metric:
            return self._create_solution(
                solution_id="SOL_MODEL_HEALTH",
                for_problem="model_provider_issues",
                title="Model Provider Health Check fehlgeschlagen",
                description="Mindestens ein Provider meldet Probleme. "
                            f"Aktive Provider: {', '.join(providers) or 'keine'}.",
                delegate_to="info",
                action_type="monitor",
                approval_level="info_only",
                steps=[
                    "TheBrain: Model-Provider Health-Report pruefen",
                    "TheBrain: Routing passt sich automatisch an verfuegbare Provider an",
                    "Bei Verschlechterung: CEO informieren",
                ],
                estimated_effort="minimal",
                priority=4,
                risk="none",
            )

        # Partial availability
        return self._create_solution(
            solution_id="SOL_MODEL_PARTIAL",
            for_problem="model_provider_issues",
            title=f"Nur {available}/{registered} Modelle verfuegbar",
            description=f"Weniger als Haelfte der Modelle verfuegbar. "
                        f"Aktive Provider: {', '.join(providers)}. "
                        "Routing funktioniert mit Einschraenkungen.",
            delegate_to="info",
            action_type="monitor",
            approval_level="info_only",
            steps=[
                "TheBrain: ModelRouter nutzt automatisch verfuegbare Modelle",
                "Fehlende Provider-Keys in .env nachtragen fuer volle Kapazitaet",
            ],
            estimated_effort="minimal",
            priority=3,
            risk="none",
        )

    def _solve_production_line_limitation(self, problem: dict) -> dict:
        """Problem: production_line_limitations → Info, kein Quick Fix."""
        metric = problem.get("metric", {})
        no_code = metric.get("lines_no_code", [])
        inactive = metric.get("lines_inactive", [])

        if no_code:
            names = ", ".join(no_code) if isinstance(no_code, list) else str(no_code)
            return self._create_solution(
                solution_id="SOL_LINE_NO_CODE",
                for_problem="production_line_limitations",
                title=f"Production Lines ohne Code: {names}",
                description=f"Lines {names} haben agent.json aber keine Implementierung. "
                            "Entwicklungsprojekt, kein Quick Fix.",
                delegate_to="ceo",
                action_type="evaluate",
                approval_level="info_only",
                steps=[
                    f"CEO: Prioritaet fuer Lines {names} festlegen",
                    "Entwicklung: Assembly-Line-Code implementieren",
                    "QA: Line-Integration testen",
                ],
                estimated_effort="significant",
                priority=4,
                risk="none",
            )

        if inactive:
            names = ", ".join(inactive) if isinstance(inactive, list) else str(inactive)
            return self._create_solution(
                solution_id="SOL_LINE_INACTIVE",
                for_problem="production_line_limitations",
                title=f"Production Lines nicht aktiv: {names}",
                description=f"Lines {names} haben Code aber Status != active. "
                            "Aktivierung oder Archivierung empfohlen.",
                delegate_to="ceo",
                action_type="evaluate",
                approval_level="info_only",
                steps=[
                    f"CEO: Status der Lines {names} pruefen",
                    "Falls bereit: Status in agent.json auf 'active' setzen",
                    "Falls nicht bereit: Im Backlog fuer spaetere Aktivierung vormerken",
                ],
                estimated_effort="minimal",
                priority=4,
                risk="none",
            )

        # Fallback
        return self._create_solution(
            solution_id="SOL_LINE_GENERIC",
            for_problem="production_line_limitations",
            title="Production Line Einschraenkungen",
            description=problem.get("detail", "Production Lines nicht voll operativ."),
            delegate_to="info",
            action_type="monitor",
            approval_level="info_only",
            steps=["CEO: Line-Status im naechsten Review pruefen"],
            estimated_effort="minimal",
            priority=4,
            risk="none",
        )

    # ── Hilfsmethoden ────────────────────────────────────────────────

    def _find_alternative_services(self, category: str) -> list:
        """Sucht alternative Services fuer eine Kategorie.

        Prueft: aktive Services, inaktive Services, Draft-Adapter.
        Liest echte Daten aus service_registry.json und Draft-Adapter-Verzeichnis.

        Returns: Liste von Alternativen mit Status und Aktivierungsinfos.
        """
        registry = self._load_service_registry()
        services = registry.get("services", {})
        categories = registry.get("categories", {})

        alternatives = []

        # 1. Registrierte Services in dieser Kategorie
        for sid, svc in services.items():
            if svc.get("category") != category:
                continue
            alternatives.append({
                "id": sid,
                "name": svc.get("name", sid),
                "status": svc.get("status", "unknown"),
                "type": "registered",
                "api_key_env": svc.get("api_key_env", ""),
                "cost": svc.get("cost_per_call", {}),
                "capabilities": svc.get("capabilities", []),
            })

        # 2. Draft-Adapter die zu dieser Kategorie passen koennten
        drafts_dir = self.root / "factory" / "brain" / "service_provider" / "adapters" / "drafts"
        if drafts_dir.exists():
            # Map known draft adapters to categories
            draft_category_hints = {
                "black_forest_labs": "image",
                "leonardo": "image",
                "kling": "video",
                "luma": "video",
                "meta_audiocraft": "sound",
                "stability_audio": "sound",
                "rive": "animation",
            }

            for f in sorted(drafts_dir.glob("*_adapter.py")):
                draft_name = f.stem.replace("_adapter", "")
                draft_cat = draft_category_hints.get(draft_name, "unknown")
                if draft_cat != category:
                    continue

                # Check if already registered
                already_registered = any(
                    draft_name.replace("_", "").lower() in sid.replace("_", "").lower()
                    for sid in services
                )

                if not already_registered:
                    # Try to extract API key env from adapter file
                    api_key_env = self._extract_api_key_env(f)
                    alternatives.append({
                        "id": f"draft_{draft_name}",
                        "name": draft_name.replace("_", " ").title(),
                        "status": "draft",
                        "type": "draft",
                        "api_key_env": api_key_env,
                        "file": str(f.relative_to(self.root)),
                        "capabilities": [],
                    })

        # 3. Fallback-Reihenfolge aus Kategorie-Definition
        cat_def = categories.get(category, {})
        fallback_order = cat_def.get("preferred_fallback_order", [])
        if fallback_order:
            # Sort alternatives by fallback order
            order_map = {sid: i for i, sid in enumerate(fallback_order)}
            alternatives.sort(key=lambda a: order_map.get(a["id"], 999))

        return alternatives

    def _build_service_activation_steps(self, services: dict) -> list:
        """Baut konkrete Aktivierungs-Steps fuer inaktive Services."""
        steps = []
        for sid, svc in services.items():
            if svc.get("status") != "inactive":
                continue
            name = svc.get("name", sid)
            api_key = svc.get("api_key_env", "UNKNOWN")
            steps.append(f"CEO: Pruefen ob {api_key} in .env eingetragen ist (fuer {name})")
        if steps:
            steps.append("Service Registry: Status der geprueften Services auf 'active' setzen")
            steps.append("TheBrain: Health-Check nach Aktivierung ausfuehren")
        else:
            steps.append("Keine inaktiven Services zum Aktivieren gefunden")
        return steps

    def _extract_api_key_env(self, adapter_file: Path) -> str:
        """Versucht API-Key-Env-Variable aus Adapter-Datei zu extrahieren."""
        try:
            content = adapter_file.read_text(encoding="utf-8")
            # Look for common patterns
            for line in content.split("\n"):
                if "api_key" in line.lower() and "os.environ" in line:
                    # Extract env var name from os.environ["..."] or os.environ.get("...")
                    import re
                    match = re.search(r'os\.environ(?:\.get)?\(\s*["\']([A-Z_]+)["\']', line)
                    if match:
                        return match.group(1)
                if "API_KEY" in line and "=" in line:
                    import re
                    match = re.search(r'([A-Z_]+API_KEY)', line)
                    if match:
                        return match.group(1)
        except Exception:
            pass

        # Fallback: guess from adapter name
        name = adapter_file.stem.replace("_adapter", "").upper()
        return f"{name}_API_KEY"

    def _prioritize_solutions(self, solutions: list) -> list:
        """Sortiert Loesungen: CRITICAL first, auto before CEO, minimal before significant."""
        effort_order = {"minimal": 0, "moderate": 1, "significant": 2}
        approval_order = {"auto": 0, "info_only": 1, "ceo_required": 2}

        return sorted(solutions, key=lambda s: (
            s.get("priority", 5),
            approval_order.get(s.get("approval_level", "ceo_required"), 3),
            effort_order.get(s.get("estimated_effort", "significant"), 3),
        ))

    def _build_execution_plan(self, solutions: list) -> dict:
        """Gruppiert Loesungen in immediate / needs_approval / long_term."""
        immediate = []
        needs_approval = []
        long_term = []

        for s in solutions:
            approval = s.get("approval_level", "ceo_required")
            effort = s.get("estimated_effort", "moderate")

            if approval == "auto" and effort in ("minimal", "moderate"):
                immediate.append(s)
            elif effort == "significant" or approval == "info_only":
                long_term.append(s)
            else:
                needs_approval.append(s)

        return {
            "immediate": immediate,
            "needs_approval": needs_approval,
            "long_term": long_term,
        }

    def _create_generic_escalation(self, problem: dict) -> dict:
        """Erstellt generische Eskalation fuer unbekannte Probleme."""
        return self._create_solution(
            solution_id=f"SOL_ESCALATE_{problem.get('rule', 'UNKNOWN').upper()}",
            for_problem=problem.get("rule", "unknown"),
            title=f"Unbekanntes Problem: {problem.get('title', 'N/A')}",
            description=f"Kein spezifischer Loesungsweg verfuegbar. {problem.get('detail', '')}",
            delegate_to="ceo",
            action_type="escalate",
            approval_level="ceo_required",
            steps=[
                f"CEO: Problem '{problem.get('title', 'N/A')}' manuell pruefen",
                "CEO: Loesungsweg festlegen",
            ],
            estimated_effort="moderate",
            priority=2,
            risk="medium",
        )

    @staticmethod
    def _create_solution(
        solution_id: str,
        for_problem: str,
        title: str,
        description: str,
        delegate_to: str,
        action_type: str,
        approval_level: str,
        steps: list,
        estimated_effort: str,
        priority: int,
        risk: str,
    ) -> dict:
        """Factory-Methode fuer standardisierte Solution-Dicts."""
        return {
            "solution_id": solution_id,
            "for_problem": for_problem,
            "title": title,
            "description": description,
            "delegate_to": delegate_to,
            "action_type": action_type,
            "approval_level": approval_level,
            "steps": steps,
            "estimated_effort": estimated_effort,
            "priority": priority,
            "risk": risk,
        }

    # ── Lazy Data Loading ────────────────────────────────────────────

    def _load_service_registry(self) -> dict:
        """Lazy-Load der Service Registry."""
        if self._service_registry is not None:
            return self._service_registry

        try:
            # Try both known locations
            registry_file = self.root / "factory" / "brain" / "service_provider" / "service_registry.json"
            if not registry_file.exists():
                registry_file = self.root / "factory" / "brain" / "service_registry.json"
            if not registry_file.exists():
                logger.warning("service_registry.json not found")
                self._service_registry = {}
                return self._service_registry

            self._service_registry = json.loads(registry_file.read_text(encoding="utf-8"))
            return self._service_registry
        except Exception as e:
            logger.warning("Failed to load service registry: %s", e)
            self._service_registry = {}
            return self._service_registry

    def _detect_problems(self) -> list:
        """Lazy-Load: ProblemDetector.run_detection() aufrufen."""
        try:
            from factory.brain.problem_detector import ProblemDetector
            pd = ProblemDetector(str(self.root))
            result = pd.run_detection()
            return result.get("problems", [])
        except Exception as e:
            logger.error("Failed to detect problems: %s", e)
            return []

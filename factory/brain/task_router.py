"""TheBrain Task Router.

Zentraler Eingangstor fuer Factory-Operationen.
Nimmt Anfragen entgegen, klassifiziert sie deterministisch (Keyword-basiert),
und delegiert an das richtige Subsystem.

Kommunikation:
- Empfaengt von: HQ Assistant, interne Systeme
- Delegiert an: Phase-1-Module, Janitor, Health Monitor, Auto-Repair, Dispatcher
- Gibt zurueck: Strukturiertes dict

WICHTIG: Dieser Agent laeuft mit tier_lock=premium.
Deterministische Klassifikation first, LLM-Fallback second.
"""

import logging
import re
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)

_DEFAULT_ROOT = Path(__file__).resolve().parents[2]

# ── Keyword-basierte Klassifikation ─────────────────────────────
# Jede Kategorie hat eine Liste von Keyword-Patterns (case-insensitive).
# Reihenfolge ist wichtig: spezifischere Patterns zuerst.
_CATEGORY_PATTERNS = {
    "repair": [
        r"\brepair\b", r"\breparier", r"\bfix\b", r"\bkaputt\b", r"\bbroken\b",
        r"\bauto.?repair\b", r"\bselbstheilung\b",
    ],
    "maintenance": [
        r"\baufr[aä]um", r"\bcleanup\b", r"\bclean.?up\b", r"\bm[uü]ll\b",
        r"\bjanitor\b", r"\barchiv", r"\bbereinig", r"\bcommand.?queue\b",
        r"\bquarantine\b", r"\bquarant[aä]ne\b",
    ],
    "health_check": [
        r"\bhealth\b", r"\bgesundheit\b", r"\bcheck\b", r"\bpr[uü]f",
        r"\bdiagnos", r"\bmonitor\b", r"\balert", r"\bwarnung",
    ],
    "service_status": [
        r"\bservice\b", r"\bapi\b", r"\bprovider\b", r"\bdown\b",
        r"\berreichbar", r"\bmodel.?provider\b", r"\bexternal\b",
    ],
    "project_status": [
        r"\bprojekt", r"\bproject\b", r"\bfortschritt", r"\bprogress\b",
        r"\bpipeline.?status\b", r"\bstuck\b", r"\bfeststeck", r"\bqueue\b",
        r"\bphase\b",
    ],
    "capabilities": [
        r"\bcapabilit", r"\bf[aä]higkeit", r"\bgap\b", r"\bl[uü]cke\b",
        r"\bkann die factory\b", r"\bwas kann\b", r"\bwhat can\b",
        r"\bforge\b", r"\bproduction.?line\b", r"\badapter\b", r"\bdraft\b",
        r"\bgap.?analy", r"\bwas fehlt\b", r"\bself.?build\b", r"\bstufe\b",
        r"\broadmap\b", r"\berweiterungsplan\b", r"\bextension\b",
        r"\bwas sollen wir.*bauen\b", r"\bn[aä]chstes bauen\b",
    ],
    "factory_status": [
        r"\bfactory.?status\b", r"\bfactory.?report\b", r"\bzustand\b",
        r"\bwie geht.?s?\b", r"\bhow.?is\b", r"\b[uü]berblick\b",
        r"\boverview\b", r"\bstatus\b", r"\breport\b", r"\bbriefing\b",
    ],
    "department_task": [
        r"\bhomepage\b", r"\bmarketing\b", r"\bdesign\b", r"\bentwurf",
        r"\berstell", r"\bcreate\b", r"\bbuild\b", r"\bgenerier",
        r"\bstrategi", r"\banalyse\b", r"\banalysis\b", r"\bresearch\b",
    ],
}

# Compiled patterns (lazy init)
_COMPILED_PATTERNS: dict = {}

# Verfuegbare Kategorien mit Beschreibung
_ROUTE_DESCRIPTIONS = {
    "factory_status": "Gesamtzustand der Factory abfragen",
    "capabilities": "Factory-Faehigkeiten und Gaps pruefen",
    "project_status": "Status eines Projekts in der Pipeline",
    "maintenance": "Janitor-Status, Cleanup-Bedarf",
    "health_check": "Gesundheitscheck, Alerts und Warnungen",
    "repair": "Auto-Repair Status, was reparierbar waere",
    "service_status": "Externe Services und Model Provider",
    "department_task": "Aufgabe an ein Department delegieren",
}


def _compile_patterns():
    """Compile regex patterns once."""
    global _COMPILED_PATTERNS
    if _COMPILED_PATTERNS:
        return
    for cat, patterns in _CATEGORY_PATTERNS.items():
        _COMPILED_PATTERNS[cat] = [re.compile(p, re.IGNORECASE) for p in patterns]


class TaskRouter:
    """Zentraler Eingangstor fuer Factory-Operationen."""

    def __init__(self, factory_root: str = None):
        self.root = Path(factory_root) if factory_root else _DEFAULT_ROOT
        _compile_patterns()

        # Load subsystems — each in own try/except
        self._state_collector = None
        self._capability_map = None
        self._report_generator = None
        self._model_router = None

        try:
            from factory.brain.factory_state import FactoryStateCollector
            self._state_collector = FactoryStateCollector(str(self.root))
        except Exception as e:
            logger.warning("FactoryStateCollector unavailable: %s", e)

        try:
            from factory.brain.capability_map import CapabilityMap
            self._capability_map = CapabilityMap(str(self.root))
        except Exception as e:
            logger.warning("CapabilityMap unavailable: %s", e)

        try:
            from factory.brain.state_report import StateReportGenerator
            self._report_generator = StateReportGenerator(str(self.root))
        except Exception as e:
            logger.warning("StateReportGenerator unavailable: %s", e)

        try:
            from config.model_router import ModelRouter
            self._model_router = ModelRouter()
        except Exception as e:
            logger.warning("ModelRouter unavailable: %s", e)

    # ------------------------------------------------------------------
    # Main Entry Point
    # ------------------------------------------------------------------
    def route(self, request: str, context: dict = None) -> dict:
        """Hauptmethode. Klassifiziert Anfrage und routet an Subsystem."""
        context = context or {}
        category = self._classify_request(request)
        logger.info("Request classified as '%s', routing...", category)

        handler = {
            "factory_status": self._route_factory_status,
            "capabilities": self._route_capabilities,
            "project_status": self._route_project_status,
            "maintenance": self._route_maintenance,
            "health_check": self._route_health_check,
            "repair": self._route_repair,
            "service_status": self._route_service_status,
            "department_task": self._route_department_task,
            "unknown": self._route_unknown,
        }.get(category, self._route_unknown)

        try:
            return handler(request, context)
        except Exception as e:
            logger.error("Routing failed for category '%s': %s", category, e)
            return {
                "status": "error",
                "category": category,
                "routed_to": None,
                "result": f"Fehler beim Routing: {e}",
                "follow_up": None,
            }

    # ------------------------------------------------------------------
    # Classification
    # ------------------------------------------------------------------
    def _classify_request(self, request: str) -> str:
        """Deterministisch: Keyword-basiert. LLM nur als Fallback."""
        # Score each category by number of pattern matches
        scores: dict[str, int] = {}
        for cat, compiled in _COMPILED_PATTERNS.items():
            for pattern in compiled:
                if pattern.search(request):
                    scores[cat] = scores.get(cat, 0) + 1

        if scores:
            best = max(scores, key=scores.get)
            logger.debug("Keyword classification: %s (scores: %s)", best, scores)
            return best

        # LLM Fallback
        llm_result = self._classify_with_llm(request)
        if llm_result and llm_result != "unknown":
            logger.info("LLM fallback classified as '%s'", llm_result)
            return llm_result

        return "unknown"

    def _classify_with_llm(self, request: str) -> str:
        """Fallback: LLM-Klassifikation. Minimal-Cost."""
        if not self._model_router:
            return "unknown"

        try:
            from factory.brain.model_provider.provider_router import ProviderRouter

            # System prompt from persona module (fallback to inline if unavailable)
            categories_list = list(_ROUTE_DESCRIPTIONS.keys())
            try:
                from factory.brain.persona.brain_system_prompt import get_classification_prompt
                system_content = get_classification_prompt(categories_list)
            except ImportError:
                categories = ", ".join(categories_list)
                system_content = (
                    "Du bist ein Request-Klassifikator. "
                    "Antworte NUR mit dem Kategorie-Namen, nichts anderes. "
                    f"Verfuegbare Kategorien: {categories}, unknown"
                )

            route_info = self._model_router.route("classification", tier_lock="premium")
            model_id = route_info["model"]
            provider = route_info["provider"]

            router = ProviderRouter()
            resp = router.call(
                model_id=model_id,
                provider=provider,
                messages=[
                    {"role": "system", "content": system_content},
                    {"role": "user", "content": f"Klassifiziere: {request}"},
                ],
                max_tokens=50,
                temperature=0.0,
            )

            if resp.error:
                logger.warning("LLM classification failed: %s", resp.error)
                return "unknown"

            result = resp.content.strip().lower().replace(" ", "_")
            if result in _ROUTE_DESCRIPTIONS or result == "unknown":
                return result
            return "unknown"
        except Exception as e:
            logger.warning("LLM classification error: %s", e)
            return "unknown"

    # ------------------------------------------------------------------
    # Route Handlers
    # ------------------------------------------------------------------
    def _route_factory_status(self, request: str, context: dict) -> dict:
        """Ruft StateReportGenerator auf."""
        if not self._report_generator:
            return self._unavailable("StateReportGenerator")

        report = self._report_generator.generate_compact_report()
        return {
            "status": "success",
            "category": "factory_status",
            "routed_to": "StateReportGenerator",
            "result": report,
            "follow_up": None,
        }

    def _route_capabilities(self, request: str, context: dict) -> dict:
        """Ruft CapabilityMap auf. Sub-Routing:
        - Roadmap/Extension → ExtensionAdvisor
        - Gap-Analyse/Stufe → GapAnalyzer
        - Allgemein → CapabilityMap
        """
        if not self._capability_map:
            return self._unavailable("CapabilityMap")

        req_lower = request.lower()

        # Sub-Route 1: Extension Roadmap
        is_roadmap_query = any(w in req_lower for w in (
            "roadmap", "erweiterungsplan", "extension",
            "naechstes bauen", "nächstes bauen",
        ))
        if is_roadmap_query:
            try:
                result = self.get_extension_roadmap()
                return {
                    "status": "success",
                    "category": "capabilities",
                    "capability": "get_extension_roadmap",
                    "routed_to": "ExtensionAdvisor.create_extension_roadmap",
                    "result": result,
                    "follow_up": None,
                }
            except Exception as e:
                logger.warning("ExtensionAdvisor failed: %s", e)

        # Sub-Route 2: Deep Gap Analysis (4-Stufe)
        is_deep_gap_query = any(w in req_lower for w in (
            "gap_analy", "gap analy", "stufe", "self_build", "self build",
            "tiefenanalyse", "was fehlt",
        ))
        if is_deep_gap_query:
            try:
                result = self.analyze_gaps()
                return {
                    "status": "success",
                    "category": "capabilities",
                    "capability": "analyze_gaps",
                    "routed_to": "GapAnalyzer.analyze_all_gaps",
                    "result": result,
                    "follow_up": None,
                }
            except Exception as e:
                logger.warning("GapAnalyzer failed: %s", e)

        # Sub-Route 3: Simple Gap List
        is_gap_query = any(w in req_lower for w in ("gap", "lücke", "luecke", "fehlt", "fehlen", "missing", "kann nicht"))
        if is_gap_query:
            gaps = self._capability_map.get_gaps()
            red = [g for g in gaps if g.get("severity") == "red"]
            yellow = [g for g in gaps if g.get("severity") == "yellow"]
            green = [g for g in gaps if g.get("severity") == "green"]
            return {
                "status": "success",
                "category": "capabilities",
                "capability": "get_gaps",
                "routed_to": "CapabilityMap.get_gaps",
                "result": {
                    "gaps": gaps,
                    "summary": f"{len(gaps)} Gaps erkannt. {len(red)} RED, {len(yellow)} YELLOW, {len(green)} GREEN.",
                },
                "follow_up": "Soll ich Details zu den RED Gaps anzeigen?" if red else None,
            }

        # Default: Full Capability Map
        cap_map = self._capability_map.build_map()
        totals = cap_map.get("totals", {})
        return {
            "status": "success",
            "category": "capabilities",
            "capability": "build_map",
            "routed_to": "CapabilityMap.build_map",
            "result": {
                "totals": totals,
                "departments": cap_map.get("agents", {}).get("departments", []),
                "services_active": cap_map.get("services", {}).get("active_services", []),
                "forges_operational": cap_map.get("forges", {}).get("operational", 0),
                "production_lines_active": totals.get("production_lines_active", 0),
            },
            "follow_up": "Soll ich die Capability Gaps anzeigen?",
        }

    def _route_project_status(self, request: str, context: dict) -> dict:
        """Fragt FactoryStateCollector nach Pipeline Queue."""
        if not self._state_collector:
            return self._unavailable("FactoryStateCollector")

        state = self._state_collector.collect_full_state()
        pipeline = state.get("pipeline_queue", {})
        projects = pipeline.get("projects", [])
        stuck = pipeline.get("stuck_projects", [])

        # Try to find a specific project name in the request
        req_lower = request.lower()
        matched = None
        for p in projects:
            name = p.get("name", "").lower()
            if name and name in req_lower:
                matched = p
                break

        if matched:
            return {
                "status": "success",
                "category": "project_status",
                "routed_to": "FactoryStateCollector.pipeline_queue",
                "result": {
                    "project": matched,
                    "is_stuck": any(s.get("name", "").lower() == matched.get("name", "").lower() for s in stuck),
                },
                "follow_up": None,
            }

        return {
            "status": "success",
            "category": "project_status",
            "routed_to": "FactoryStateCollector.pipeline_queue",
            "result": {
                "total_projects": len(projects),
                "projects": projects,
                "stuck_projects": stuck,
            },
            "follow_up": f"{len(stuck)} Projekte feststeckend." if stuck else None,
        }

    def _route_maintenance(self, request: str, context: dict) -> dict:
        """Fragt Janitor-Status ab. Loest KEINE Aktionen aus."""
        if not self._state_collector:
            return self._unavailable("FactoryStateCollector")

        state = self._state_collector.collect_full_state()
        janitor = state.get("janitor", {})
        cmd_queue = state.get("command_queue", {})

        return {
            "status": "success",
            "category": "maintenance",
            "routed_to": "FactoryStateCollector.janitor + command_queue",
            "result": {
                "janitor": janitor,
                "command_queue": cmd_queue,
            },
            "follow_up": "Janitor-Scan oder Cleanup braucht CEO-Approval ueber den HQ Assistant.",
        }

    def _route_health_check(self, request: str, context: dict) -> dict:
        """Ruft Health Monitor ab."""
        try:
            from factory.hq.health_monitor import run_health_check
            result = run_health_check()
            return {
                "status": "success",
                "category": "health_check",
                "routed_to": "HealthMonitor.run_health_check",
                "result": {
                    "overall": result.get("status", "unknown"),
                    "total_alerts": result.get("summary", {}).get("total_alerts", 0),
                    "critical": result.get("summary", {}).get("critical", 0),
                    "warnings": result.get("summary", {}).get("warnings", 0),
                    "alerts": result.get("alerts", [])[:10],
                },
                "follow_up": None,
            }
        except Exception as e:
            logger.warning("Health Monitor call failed: %s", e)
            # Fallback to cached state
            if self._state_collector:
                state = self._state_collector.collect_full_state()
                return {
                    "status": "partial",
                    "category": "health_check",
                    "routed_to": "FactoryStateCollector.health_monitor (cached)",
                    "result": state.get("health_monitor", {}),
                    "follow_up": None,
                }
            return self._unavailable("HealthMonitor")

    def _route_repair(self, request: str, context: dict) -> dict:
        """Fragt Auto-Repair Status. Loest KEINE Repairs aus."""
        if not self._state_collector:
            return self._unavailable("FactoryStateCollector")

        state = self._state_collector.collect_full_state()
        auto_repair = state.get("auto_repair", {})

        # Also check health for auto-fixable alerts
        hm = state.get("health_monitor", {})
        fixable = [a for a in hm.get("alerts", []) if a.get("auto_fixable")]

        return {
            "status": "success",
            "category": "repair",
            "routed_to": "FactoryStateCollector.auto_repair + health_monitor",
            "result": {
                "auto_repair_status": auto_repair,
                "auto_fixable_alerts": len(fixable),
                "fixable_details": fixable[:5],
            },
            "follow_up": f"{len(fixable)} Probleme auto-reparierbar. Repair braucht CEO-Approval." if fixable else None,
        }

    def _route_service_status(self, request: str, context: dict) -> dict:
        """Fragt Service/Model Provider Status."""
        if not self._state_collector:
            return self._unavailable("FactoryStateCollector")

        state = self._state_collector.collect_full_state()
        return {
            "status": "success",
            "category": "service_status",
            "routed_to": "FactoryStateCollector.service_provider + model_provider",
            "result": {
                "service_provider": state.get("service_provider", {}),
                "model_provider": state.get("model_provider", {}),
            },
            "follow_up": None,
        }

    def _route_department_task(self, request: str, context: dict) -> dict:
        """Routing-Empfehlung fuer Department-Tasks (Phase 2 Einschraenkung)."""
        department, agents = self._guess_department(request)

        return {
            "status": "partial",
            "category": "department_task",
            "routed_to": "routing_recommendation",
            "result": {
                "recommended_department": department,
                "agents": agents,
                "note": "Direkte Department-Delegation noch nicht implementiert (Phase 2, Step 2)",
            },
            "follow_up": "Department-Delegation wird in Phase 2, Step 2 aktiviert.",
        }

    def _route_unknown(self, request: str, context: dict) -> dict:
        """Anfrage nicht klassifizierbar."""
        categories = ", ".join(_ROUTE_DESCRIPTIONS.keys())
        return {
            "status": "error",
            "category": "unknown",
            "routed_to": None,
            "result": "Konnte die Anfrage nicht zuordnen.",
            "follow_up": f"Verfuegbare Kategorien: {categories}",
        }

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------
    def _unavailable(self, subsystem: str) -> dict:
        return {
            "status": "error",
            "category": "error",
            "routed_to": None,
            "result": f"Subsystem '{subsystem}' ist nicht verfuegbar.",
            "follow_up": None,
        }

    def _guess_department(self, request: str) -> tuple:
        """Versucht Department und zustaendige Agents zu identifizieren."""
        req_lower = request.lower()

        dept_keywords = {
            "Swarm Factory / Marketing-Strategie": {
                "keywords": ["marketing", "homepage", "strategi", "monetarisierung", "zielgruppe"],
                "agents": ["SWF-08 Plattform-Strategie", "SWF-10 Marketing-Strategie", "SWF-09 Monetarisierungs-Architekt"],
            },
            "Swarm Factory / Design-Vision": {
                "keywords": ["design", "entwurf", "ui", "ux", "screen", "layout", "visual"],
                "agents": ["SWF-15 Screen-Architect", "SWF-16 Design-Trend-Breaker", "SWF-17 UX-Emotion-Architect"],
            },
            "Swarm Factory / Research": {
                "keywords": ["research", "trend", "competitor", "analyse", "analysis", "markt"],
                "agents": ["SWF-01 Trend-Scout", "SWF-02 Competitor-Scan", "SWF-03 Zielgruppen-Analyst"],
            },
            "Code-Pipeline": {
                "keywords": ["code", "swift", "kotlin", "develop", "programmier", "implement", "build", "erstell"],
                "agents": ["CPL-01 DriveAI Lead", "CPL-02 iOS Architect", "CPL-03 Swift Developer"],
            },
            "Asset Forge": {
                "keywords": ["asset", "bild", "image", "icon", "grafik"],
                "agents": ["ASF-01 Asset Forge"],
            },
            "Sound Forge": {
                "keywords": ["sound", "audio", "musik", "music", "sfx"],
                "agents": ["SOF-01 Sound Forge"],
            },
            "Motion Forge": {
                "keywords": ["animation", "motion", "bewegung", "lottie"],
                "agents": ["MOF-01 Motion Forge"],
            },
        }

        best_dept = "unknown"
        best_agents = []
        best_score = 0

        for dept, info in dept_keywords.items():
            score = sum(1 for kw in info["keywords"] if kw in req_lower)
            if score > best_score:
                best_score = score
                best_dept = dept
                best_agents = info["agents"]

        return best_dept, best_agents

    def route_and_collect(self, request: str, context: dict = None) -> dict:
        """Kombiniert route() + ResponseCollector.process().

        Bevorzugte Methode fuer den HQ Assistant.
        route() bleibt fuer direkten Zugriff erhalten (Abwaertskompatibilitaet).
        """
        raw_result = self.route(request, context)
        try:
            from factory.brain.response_collector import ResponseCollector
            collector = ResponseCollector(str(self.root))
            return collector.process(raw_result)
        except Exception as e:
            logger.warning("ResponseCollector unavailable, returning raw result: %s", e)
            return raw_result

    def diagnose_and_propose(self) -> dict:
        """Kombiniert ProblemDetector + SolutionProposer.

        Erkennt alle Probleme und liefert sofort Loesungsvorschlaege.
        Das ist der 'Factory Diagnose' Befehl.
        """
        from factory.brain.problem_detector import ProblemDetector
        from factory.brain.solution_proposer import SolutionProposer

        detector = ProblemDetector(str(self.root))
        proposer = SolutionProposer(str(self.root))

        detection = detector.run_detection()
        solutions = proposer.propose_solutions(detection["problems"])

        return {
            "detection": detection,
            "solutions": solutions,
        }

    def analyze_gaps(self) -> dict:
        """Tiefenanalyse aller Capability-Gaps mit DIR-001 Stufenlogik.

        Nutzt GapAnalyzer (BRN-05) fuer 4-Stufe-Analyse pro Gap.
        Das ist der 'Gap Analyse' Befehl.
        """
        from factory.brain.gap_analyzer import GapAnalyzer

        analyzer = GapAnalyzer(str(self.root))
        return analyzer.analyze_all_gaps()

    def get_extension_roadmap(self) -> dict:
        """Erstellt die vollstaendige Erweiterungs-Roadmap.

        Kombiniert GapAnalyzer + ExtensionAdvisor.
        Das ist der 'Roadmap' / 'Was sollen wir als naechstes bauen' Befehl.
        """
        from factory.brain.extension_advisor import ExtensionAdvisor

        advisor = ExtensionAdvisor(str(self.root))
        return advisor.create_extension_roadmap()

    def get_available_routes(self) -> list:
        """Liste aller verfuegbaren Routen mit Beschreibung."""
        return [
            {"category": cat, "description": desc}
            for cat, desc in _ROUTE_DESCRIPTIONS.items()
        ]

"""Factory Directive Engine.

Laedt und verwaltet CEO-Direktiven fuer TheBrain.
Wird von TheBrain-Modulen genutzt um Entscheidungen gegen
die CEO-Direktiven zu pruefen.

100% deterministisch. Kein LLM. Keine Schreiboperationen.
"""

import json
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

_DIRECTIVES_DIR = Path(__file__).resolve().parent

# ── Solution Types → Stufen Mapping ─────────────────────────────
_STUFE_MAP = {
    "internal": 1,
    "self_built": 2,
    "open_source": 3,
    "external": 4,
}

_STUFE_LABELS = {
    1: "Stufe 1: Eigene Mittel",
    2: "Stufe 2: Selbst entwickeln",
    3: "Stufe 3: Open-Source / Self-Hosting",
    4: "Stufe 4: Externer Dienstleister (Uebergangsloesung)",
}

# ── Compact directive for LLM prompts (max ~100 words) ──────────
_DIR_001_PROMPT = """\
CEO Directive DIR-001 (Self-First): The factory builds everything itself. \
External services are the LAST resort, not the first. Decision order: \
(1) Use existing tools/agents, (2) Build it yourself, (3) Self-host open-source, \
(4) External service ONLY if 1-3 impossible — marked as temporary, with migration plan. \
If an app needs a missing capability: pause production, work on other projects, \
build the capability in parallel. Never compromise autonomy for speed."""


class DirectiveEngine:
    """Laedt und verwaltet Factory-Direktiven."""

    def __init__(self, factory_root: str = None):
        self._directives_dir = _DIRECTIVES_DIR
        self._registry = self._load_registry()

    # ── Public API ───────────────────────────────────────────────────

    def get_all_directives(self) -> list:
        """Gibt alle aktiven Direktiven zurueck."""
        return [
            d for d in self._registry.get("directives", [])
            if d.get("status") == "active"
        ]

    def get_directive(self, directive_id: str) -> dict:
        """Gibt eine spezifische Direktive zurueck."""
        for d in self._registry.get("directives", []):
            if d.get("id") == directive_id:
                return d
        return {}

    def check_capability_decision(self, proposal: dict) -> dict:
        """Prueft einen Capability-Vorschlag gegen Direktive 001.

        Parameters:
            proposal: {
                "capability_needed": str,
                "proposed_solution": str,
                "solution_type": str  # "internal"|"self_built"|"open_source"|"external"
            }

        Returns:
            {
                "approved": bool,
                "directive": "DIR-001",
                "stufe": int,
                "stufe_label": str,
                "reason": str,
                "required_action": str | None,
                "alternative_steps": list
            }
        """
        solution_type = proposal.get("solution_type", "external")
        capability = proposal.get("capability_needed", "unknown")
        solution = proposal.get("proposed_solution", "unknown")
        stufe = _STUFE_MAP.get(solution_type, 4)
        stufe_label = _STUFE_LABELS.get(stufe, "Unbekannt")

        # Stufe 1-3: approved
        if stufe <= 3:
            logger.info(
                "DIR-001 approved: %s via %s (%s)",
                capability, solution, stufe_label,
            )
            return {
                "approved": True,
                "directive": "DIR-001",
                "stufe": stufe,
                "stufe_label": stufe_label,
                "reason": f"Loesung '{solution}' entspricht {stufe_label}.",
                "required_action": None,
                "alternative_steps": [],
            }

        # Stufe 4: external → rejected
        logger.info(
            "DIR-001 rejected: %s via %s — external service requires CEO approval",
            capability, solution,
        )
        return {
            "approved": False,
            "directive": "DIR-001",
            "stufe": 4,
            "stufe_label": stufe_label,
            "reason": f"Direktive 001: Externe Services nur als letzte Option. "
                      f"'{solution}' ist ein externer Dienstleister.",
            "required_action": "ceo_approval_required",
            "alternative_steps": [
                "Pruefe Stufe 1: Kann die Factory das mit bestehenden Tools/Agents loesen?",
                "Pruefe Stufe 2: Koennen wir die Capability selbst entwickeln?",
                "Pruefe Stufe 3: Gibt es ein Open-Source-Modell/Tool zum Self-Hosting?",
                f"Nur wenn 1-3 nicht moeglich: CEO-Approval fuer '{solution}' einholen (temporaer, mit Abloese-Plan)",
            ],
        }

    def get_production_pause_recommendation(
        self, project_name: str, missing_capability: str
    ) -> dict:
        """Empfiehlt Produktions-Pause statt externem Einkauf.

        Returns:
            {
                "recommendation": "pause_production",
                "project": project_name,
                "missing": missing_capability,
                "message": str,
                "directive": "DIR-001"
            }
        """
        return {
            "recommendation": "pause_production",
            "project": project_name,
            "missing": missing_capability,
            "message": (
                f"Produktion von '{project_name}' pausieren. "
                f"Capability '{missing_capability}' wird nach Stufe 2/3 aufgebaut. "
                "Factory arbeitet an anderen Projekten weiter."
            ),
            "directive": "DIR-001",
        }

    def format_directive_for_prompt(self, directive_id: str = "DIR-001") -> str:
        """Gibt die Direktive als kompakten Text fuer LLM System-Prompts zurueck.

        Maximal ~100 Woerter — die Essenz der Direktive.
        """
        if directive_id == "DIR-001":
            return _DIR_001_PROMPT

        # Generic fallback: Load directive and return summary
        directive = self.get_directive(directive_id)
        if directive:
            return f"CEO Directive {directive['id']}: {directive.get('summary', 'No summary.')}"
        return ""

    def classify_solution_stufe(self, solution_type: str) -> tuple[int, str]:
        """Gibt (stufe_nummer, stufe_label) fuer einen solution_type zurueck.

        Hilfsmethode fuer SolutionProposer-Integration.
        """
        stufe = _STUFE_MAP.get(solution_type, 4)
        return stufe, _STUFE_LABELS.get(stufe, "Unbekannt")

    # ── Internal ─────────────────────────────────────────────────────

    def _load_registry(self) -> dict:
        """Laedt directives_registry.json."""
        registry_file = self._directives_dir / "directives_registry.json"
        try:
            if registry_file.exists():
                return json.loads(registry_file.read_text(encoding="utf-8"))
        except Exception as e:
            logger.warning("Failed to load directives registry: %s", e)
        return {"directives": [], "meta": {"total_directives": 0}}

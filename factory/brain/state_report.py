"""Factory State Report Generator.

Erzeugt Factory-Zustandsberichte aus FactoryStateCollector + CapabilityMap.
Zwei Formate:
  - Kompakt-Report (lesbarer Text fuer HQ Assistant / Daily Briefing)
  - Full Report (Dictionary fuer Dashboard / Logging)

Rein deterministisch, kein LLM, einzige Schreiboperation: save_report().
"""

import json
import logging
from datetime import datetime, timezone, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)

try:
    from factory.brain.factory_state import FactoryStateCollector
    from factory.brain.capability_map import CapabilityMap
except ImportError:
    from .factory_state import FactoryStateCollector
    from .capability_map import CapabilityMap

_DEFAULT_ROOT = Path(__file__).resolve().parents[2]


class StateReportGenerator:
    """Erzeugt Factory-Zustandsberichte aus FactoryStateCollector + CapabilityMap."""

    def __init__(self, factory_root: str = None):
        root = factory_root or str(_DEFAULT_ROOT)
        self.root = Path(root)
        self.state_collector = FactoryStateCollector(root)
        self.capability_map = CapabilityMap(root)

    # ------------------------------------------------------------------
    # Kompakt-Report
    # ------------------------------------------------------------------
    def generate_compact_report(self) -> str:
        """Erzeugt einen kompakten, lesbaren Text-Report (max ~40 Zeilen)."""
        state = self.state_collector.collect_full_state()
        cap = self.capability_map.build_map()
        health = self._determine_overall_health(state, cap)
        alerts = self._format_alerts(state, cap)

        now_local = datetime.now()
        ts = now_local.strftime("%d.%m.%Y, %H:%M Uhr")

        health_symbol = {"green": "\u2705 GREEN", "yellow": "\u26a0 YELLOW", "red": "\u274c RED"}
        health_label = health_symbol.get(health, health.upper())

        lines = []
        lines.append("\u2550" * 50)
        lines.append("  DriveAI Swarm Factory \u2014 Status Report")
        lines.append(f"  {ts}")
        lines.append("\u2550" * 50)
        lines.append("")
        lines.append(f"Factory Health: {health_label}")

        # Aktive Projekte
        projects = self._get_active_projects(state)
        if projects:
            lines.append("")
            lines.append("\u2500\u2500 Aktive Projekte " + "\u2500" * 33)
            for p in projects:
                name = p["name"][:18].ljust(18)
                phase = p["phase"][:24].ljust(24)
                pct = p.get("progress", "")
                pct_str = f"{pct}%" if pct != "" else ""
                lines.append(f"  {name}{phase}{pct_str}")

        # Alerts
        if alerts:
            lines.append("")
            lines.append(f"\u2500\u2500 Alerts ({len(alerts)}) " + "\u2500" * (34 - len(str(len(alerts)))))
            for a in alerts:
                icon = {"critical": "\u274c", "warning": "\u26a0", "info": "\u2139"}.get(a["level"], "\u2022")
                lines.append(f"  {icon} {a['message']}")

        # Capabilities
        lines.append("")
        lines.append("\u2500\u2500 Capabilities " + "\u2500" * 36)
        lines.append(self._format_production_lines(cap))
        lines.append(self._format_service_line(cap, "image", "Image"))
        lines.append(self._format_service_line(cap, "sound", "Sound"))
        lines.append(self._format_service_line(cap, "video", "Video"))

        totals = cap.get("totals", {})
        lines.append(f"  Modelle:     {totals.get('models', 0)} Modelle, {len(cap.get('models', {}).get('available_providers', []))} Provider")

        agents_total = totals.get("agents", 0)
        agents_active = totals.get("agents_active", 0)
        agents_disabled = cap.get("agents", {}).get("disabled", 0)
        agents_planned = cap.get("agents", {}).get("planned", 0)
        lines.append(f"  Agents:      {agents_total} gesamt ({agents_active} aktiv, {agents_disabled} disabled, {agents_planned} planned)")

        forges_total = totals.get("forges", 0)
        forges_op = totals.get("forges_operational", 0)
        lines.append(f"  Forges:      {forges_op}/{forges_total} operational")

        # Capability Gaps (nur RED + YELLOW)
        gaps = self.capability_map.get_gaps()
        important_gaps = [g for g in gaps if g.get("severity") in ("red", "yellow")]
        if important_gaps:
            lines.append("")
            lines.append(f"\u2500\u2500 Gaps ({len(important_gaps)}) " + "\u2500" * (35 - len(str(len(important_gaps)))))
            for g in important_gaps[:8]:
                sev = g["severity"].upper()
                lines.append(f"  [{sev}] {g['message']}")
            if len(important_gaps) > 8:
                lines.append(f"  ... und {len(important_gaps) - 8} weitere")

        lines.append("")
        lines.append("\u2550" * 50)

        return "\n".join(lines)

    # ------------------------------------------------------------------
    # Full Report
    # ------------------------------------------------------------------
    def generate_full_report(self) -> dict:
        """Vollstaendiger Report als Dictionary."""
        state = self.state_collector.collect_full_state()
        cap = self.capability_map.build_map()
        health = self._determine_overall_health(state, cap)
        alerts = self._format_alerts(state, cap)

        return {
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "overall_health": health,
            "alert_count": len(alerts),
            "alerts": alerts,
            "factory_state": state,
            "capabilities": cap,
            "gaps": self.capability_map.get_gaps(),
        }

    # ------------------------------------------------------------------
    # Health Determination
    # ------------------------------------------------------------------
    def _determine_overall_health(self, state: dict, capabilities: dict) -> str:
        """Bestimmt den Gesamt-Gesundheitszustand: green | yellow | red."""
        # RED conditions
        hm = state.get("health_monitor", {})
        if hm.get("critical", 0) > 0:
            return "red"

        unavailable = state.get("subsystems_total", 8) - state.get("subsystems_available", 0)
        if unavailable > 3:
            return "red"

        pipeline = state.get("pipeline_queue", {})
        if len(pipeline.get("stuck_projects", [])) > 0:
            return "red"

        # YELLOW conditions
        cmd_queue = state.get("command_queue", {})
        if cmd_queue.get("total_commands", 0) > 100:
            return "yellow"

        janitor = state.get("janitor", {})
        if janitor.get("issues_found", 0) > 200:
            return "yellow"

        if hm.get("warnings", 0) > 0:
            return "yellow"

        gaps = capabilities.get("totals", {})
        red_gaps = [g for g in self.capability_map.get_gaps() if g.get("severity") == "red"]
        if red_gaps:
            return "yellow"

        return "green"

    # ------------------------------------------------------------------
    # Alert Collection
    # ------------------------------------------------------------------
    def _format_alerts(self, state: dict, capabilities: dict) -> list:
        """Sammelt alle Dinge die Aufmerksamkeit brauchen."""
        alerts = []

        # Health Monitor alerts
        hm = state.get("health_monitor", {})
        if hm.get("critical", 0) > 0:
            alerts.append({
                "level": "critical",
                "source": "health_monitor",
                "message": f"Health Monitor: {hm['critical']} kritische Alerts",
            })
        if hm.get("warnings", 0) > 0:
            alerts.append({
                "level": "warning",
                "source": "health_monitor",
                "message": f"Health Monitor: {hm['warnings']} Warnungen",
            })

        # Command Queue
        cmd = state.get("command_queue", {})
        total_cmds = cmd.get("total_commands", 0)
        if total_cmds > 0:
            age = cmd.get("oldest_age_days", 0)
            if total_cmds > 50:
                alerts.append({
                    "level": "warning",
                    "source": "command_queue",
                    "message": f"Command Queue: {total_cmds} Commands, \u00e4lteste {age} Tage",
                })
            elif age > 7:
                alerts.append({
                    "level": "info",
                    "source": "command_queue",
                    "message": f"Command Queue: {total_cmds} Commands, \u00e4lteste {age} Tage",
                })

        # Pipeline stuck
        pipeline = state.get("pipeline_queue", {})
        stuck = pipeline.get("stuck_projects", [])
        if stuck:
            names = ", ".join(s.get("name", "?") for s in stuck[:3])
            alerts.append({
                "level": "critical",
                "source": "pipeline_queue",
                "message": f"Pipeline: {len(stuck)} Projekte feststeckend ({names})",
            })

        # Janitor
        janitor = state.get("janitor", {})
        issues = janitor.get("issues_found", 0)
        if issues > 0:
            health_score = janitor.get("health_score")
            hs_str = f", Health Score {health_score}/100" if health_score is not None else ""
            level = "warning" if issues > 200 else "info"
            alerts.append({
                "level": level,
                "source": "janitor",
                "message": f"Janitor: {issues} Issues beim letzten Scan{hs_str}",
            })

        # Growth alerts from janitor
        growth = janitor.get("growth_alerts", 0)
        if growth > 0:
            alerts.append({
                "level": "warning",
                "source": "janitor",
                "message": f"Janitor: {growth} Growth Alerts",
            })

        # Capability gaps (RED only)
        gaps = self.capability_map.get_gaps()
        red_gaps = [g for g in gaps if g.get("severity") == "red"]
        for g in red_gaps:
            # Make message more user-friendly
            alerts.append({
                "level": "warning",
                "source": "capabilities",
                "message": g["message"],
            })

        # Unavailable subsystems
        unavailable_count = state.get("subsystems_total", 8) - state.get("subsystems_available", 0)
        if unavailable_count > 0:
            alerts.append({
                "level": "warning" if unavailable_count <= 3 else "critical",
                "source": "subsystems",
                "message": f"{unavailable_count} von {state.get('subsystems_total', 8)} Subsystemen nicht erreichbar",
            })

        # Sort: critical > warning > info
        level_order = {"critical": 0, "warning": 1, "info": 2}
        alerts.sort(key=lambda a: level_order.get(a.get("level", "info"), 3))

        return alerts

    # ------------------------------------------------------------------
    # Helper: Active Projects
    # ------------------------------------------------------------------
    def _get_active_projects(self, state: dict) -> list:
        """Extrahiert aktive Projekte aus Pipeline Queue + Project Registry."""
        projects = []

        # From pipeline queue
        pipeline = state.get("pipeline_queue", {})
        for p in pipeline.get("projects", []):
            phase = p.get("phase", "unknown")
            if phase in ("completed", "archived", "failed"):
                continue
            projects.append({
                "name": p.get("name", "?"),
                "phase": self._humanize_phase(phase),
                "progress": self._estimate_progress(phase),
            })

        # If no pipeline projects, try project registry
        if not projects:
            registry = state.get("project_registry", {})
            active = registry.get("active", 0)
            if active > 0:
                projects.append({
                    "name": f"{active} aktive Projekte",
                    "phase": "In Registry",
                    "progress": "",
                })

        return projects

    def _humanize_phase(self, phase: str) -> str:
        """Wandelt interne Phase-Bezeichnungen in lesbare um."""
        mapping = {
            "pre_production": "Pre-Production",
            "pre_production_complete": "Pre-Prod. Complete",
            "market_strategy": "Market Strategy",
            "mvp_scope": "MVP Scope",
            "design_vision": "Design Vision",
            "visual_audit": "Visual Audit",
            "roadbook": "Roadbook",
            "feasibility": "Feasibility Check",
            "production": "In Produktion",
            "assembly": "Assembly",
            "qa": "Quality Assurance",
            "store_prep": "Store Prep",
            "store_submission": "Store Submission",
            "launched": "Launched",
            "in_arbeit": "In Arbeit",
        }
        return mapping.get(phase, phase.replace("_", " ").title())

    def _estimate_progress(self, phase: str) -> str:
        """Schaetzt Fortschritt basierend auf Phase."""
        phase_progress = {
            "pre_production": "15",
            "market_strategy": "30",
            "mvp_scope": "40",
            "design_vision": "50",
            "visual_audit": "55",
            "roadbook": "60",
            "feasibility": "65",
            "production": "70",
            "assembly": "80",
            "qa": "85",
            "store_prep": "90",
            "store_submission": "95",
            "launched": "100",
        }
        return phase_progress.get(phase, "")

    # ------------------------------------------------------------------
    # Helper: Formatting
    # ------------------------------------------------------------------
    def _format_production_lines(self, cap: dict) -> str:
        """Formatiert Production Lines als kompakte Zeile."""
        lines_data = cap.get("production_lines", {}).get("lines", [])
        if not lines_data:
            return "  Production:  Keine Lines konfiguriert"

        parts = []
        for line in lines_data:
            name = line["id"].replace("_", " ").title()
            # Short name
            short = {"ios": "iOS", "android": "Android", "web": "Web", "unity": "Unity"}.get(line["id"], name)
            mark = "\u2713" if line.get("operational") else "\u2717"
            parts.append(f"{short} {mark}")

        return "  Production:  " + " | ".join(parts)

    def _format_service_line(self, cap: dict, category: str, label: str) -> str:
        """Formatiert eine Service-Kategorie als kompakte Zeile."""
        by_cat = cap.get("services", {}).get("by_category", {})
        cat_data = by_cat.get(category, {})
        services = cat_data.get("services", [])
        active = [s for s in services if s.get("status") == "active"]
        inactive = [s for s in services if s.get("status") != "active"]

        label_padded = f"{label}:".ljust(11)

        if not services:
            return f"  {label_padded} Keine Services"

        if active:
            names = ", ".join(s.get("name", s.get("id", "?")) for s in active)
            result = f"  {label_padded} {len(active)} aktiv ({names})"
        else:
            # Check for draft adapters
            drafts = cap.get("services", {}).get("draft_adapters", [])
            draft_names = [d["name"] for d in drafts if self._draft_matches_category(d["name"], category)]
            if draft_names:
                result = f"  {label_padded} 0 aktiv \u2014 \u26a0 Gap (Drafts: {', '.join(draft_names[:3])})"
            else:
                result = f"  {label_padded} 0 aktiv \u2014 \u26a0 Gap"

        return result

    def _draft_matches_category(self, draft_name: str, category: str) -> bool:
        """Prueft ob ein Draft-Adapter zu einer Kategorie passt."""
        video_drafts = {"runway", "kling", "luma", "leonardo"}
        sound_drafts = {"meta_audiocraft", "stability_audio", "rive"}
        image_drafts = {"black_forest_labs"}

        mapping = {
            "video": video_drafts,
            "sound": sound_drafts,
            "image": image_drafts,
        }

        return draft_name.lower() in mapping.get(category, set())

    # ------------------------------------------------------------------
    # Save Report
    # ------------------------------------------------------------------
    def save_report(self, path: str = None) -> str:
        """Speichert den Full Report als JSON. Einzige Schreiboperation in Phase 1."""
        report = self.generate_full_report()

        if path:
            save_path = Path(path)
        else:
            reports_dir = self.root / "factory" / "brain" / "reports"
            reports_dir.mkdir(parents=True, exist_ok=True)
            ts = datetime.now(timezone.utc).strftime("%Y-%m-%d_%H-%M")
            save_path = reports_dir / f"state_report_{ts}.json"

        save_path.parent.mkdir(parents=True, exist_ok=True)
        save_path.write_text(
            json.dumps(report, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
        logger.info("State report saved: %s", save_path)
        return str(save_path)

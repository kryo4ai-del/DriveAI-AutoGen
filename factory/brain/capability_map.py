"""Factory Capability Map.

Aggregiert alle Faehigkeiten der Factory aus drei Quellen:
- Agent Registry (factory/agent_registry.json)
- Service Registry (factory/brain/service_registry.json)
- Model Registry (factory/brain/model_provider/)

Scannt zusaetzlich das Dateisystem fuer:
- Production Lines (factory/lines/)
- Forges (factory/assembly/forges/)
- Adapters (factory/assembly/adapters/)

Rein deterministisch, kein LLM, keine Schreiboperationen.
"""

import json
import logging
from pathlib import Path

logger = logging.getLogger(__name__)

# Factory root: 2 Ebenen hoch von factory/brain/
_DEFAULT_ROOT = Path(__file__).resolve().parents[2]


class CapabilityMap:
    """Aggregiert alle Factory-Capabilities in eine einheitliche Map."""

    def __init__(self, factory_root: str = None):
        self.root = Path(factory_root) if factory_root else _DEFAULT_ROOT

    def build_map(self) -> dict:
        """Hauptmethode. Baut die komplette Capability-Map."""
        cap_map = {
            "production_lines": self._scan_production_lines(),
            "agents": self._scan_agents(),
            "services": self._scan_services(),
            "models": self._scan_models(),
            "forges": self._scan_forges(),
        }

        # Totals
        agents = cap_map["agents"]
        services = cap_map["services"]
        models = cap_map["models"]
        forges = cap_map["forges"]
        lines = cap_map["production_lines"]

        cap_map["totals"] = {
            "agents": agents.get("total", 0),
            "agents_active": agents.get("active", 0),
            "services": services.get("total", 0),
            "services_active": services.get("active_count", 0),
            "models": models.get("total", 0),
            "models_available": models.get("available", 0),
            "forges": forges.get("total", 0),
            "forges_operational": forges.get("operational", 0),
            "production_lines": lines.get("total", 0),
            "production_lines_active": lines.get("active", 0),
        }

        return cap_map

    # ------------------------------------------------------------------
    # Production Lines
    # ------------------------------------------------------------------
    def _scan_production_lines(self) -> dict:
        """Scannt factory/lines/ fuer verfuegbare Production Lines."""
        try:
            lines_dir = self.root / "factory" / "lines"
            if not lines_dir.exists():
                return {"total": 0, "active": 0, "lines": []}

            lines = []
            for line_dir in sorted(lines_dir.iterdir()):
                if not line_dir.is_dir():
                    continue

                agent_file = line_dir / "agent.json"
                if not agent_file.exists():
                    continue

                try:
                    agent = json.loads(agent_file.read_text(encoding="utf-8"))
                except Exception:
                    agent = {}

                name = agent.get("name", line_dir.name)
                status = agent.get("status", "unknown")

                # Check if line has actual code (in assembly/lines/)
                assembly_line = self.root / "factory" / "assembly" / "lines" / f"{line_dir.name}_line.py"
                has_code = assembly_line.exists()

                lines.append({
                    "id": line_dir.name,
                    "name": name,
                    "status": status,
                    "has_code": has_code,
                    "operational": status == "active" and has_code,
                })

            active = sum(1 for l in lines if l["operational"])

            return {
                "total": len(lines),
                "active": active,
                "lines": lines,
            }
        except Exception as e:
            logger.warning("Production Lines scan failed: %s", e)
            return {"total": 0, "active": 0, "lines": [], "error": str(e)}

    # ------------------------------------------------------------------
    # Agents
    # ------------------------------------------------------------------
    def _scan_agents(self) -> dict:
        """Liest die Agent Registry und gruppiert nach Department."""
        try:
            registry_file = self.root / "factory" / "agent_registry.json"
            if not registry_file.exists():
                return {"total": 0, "active": 0, "by_department": {}, "by_status": {}}

            data = json.loads(registry_file.read_text(encoding="utf-8"))
            agents = data.get("agents", [])

            by_department = {}
            by_status = {}
            by_task_type = {}

            for agent in agents:
                dept = agent.get("department", "unknown")
                status = agent.get("status", "unknown")
                task_type = agent.get("task_type", "unknown")

                by_department.setdefault(dept, []).append({
                    "id": agent.get("id", ""),
                    "name": agent.get("name", ""),
                    "status": status,
                    "task_type": task_type,
                    "model_tier": agent.get("model_tier", "unknown"),
                })

                by_status[status] = by_status.get(status, 0) + 1
                by_task_type[task_type] = by_task_type.get(task_type, 0) + 1

            active = by_status.get("active", 0)

            return {
                "total": len(agents),
                "active": active,
                "disabled": by_status.get("disabled", 0),
                "planned": by_status.get("planned", 0),
                "by_department": {
                    dept: {
                        "count": len(members),
                        "active": sum(1 for m in members if m["status"] == "active"),
                        "agents": members,
                    }
                    for dept, members in by_department.items()
                },
                "by_status": by_status,
                "by_task_type": by_task_type,
                "departments": sorted(by_department.keys()),
            }
        except Exception as e:
            logger.warning("Agent Registry scan failed: %s", e)
            return {"total": 0, "active": 0, "by_department": {}, "error": str(e)}

    # ------------------------------------------------------------------
    # Services
    # ------------------------------------------------------------------
    def _scan_services(self) -> dict:
        """Liest die Service Registry und gruppiert nach Category."""
        try:
            # Try both known locations
            registry_file = self.root / "factory" / "brain" / "service_provider" / "service_registry.json"
            if not registry_file.exists():
                registry_file = self.root / "factory" / "brain" / "service_registry.json"
            if not registry_file.exists():
                return {"total": 0, "active_count": 0, "by_category": {}}

            data = json.loads(registry_file.read_text(encoding="utf-8"))
            services = data.get("services", {})
            categories = data.get("categories", {})

            by_category = {}
            active_list = []
            inactive_list = []

            for sid, svc in services.items():
                name = svc.get("name", sid)
                cat = svc.get("category", "unknown")
                status = svc.get("status", "inactive")
                capabilities = svc.get("capabilities", [])
                cost = svc.get("cost_per_call", 0)

                entry = {
                    "id": sid,
                    "name": name,
                    "status": status,
                    "capabilities": capabilities,
                    "cost_per_call": cost,
                    "provider": svc.get("provider", "unknown"),
                }

                by_category.setdefault(cat, []).append(entry)

                if status == "active":
                    active_list.append(name)
                else:
                    inactive_list.append(name)

            # Scan for draft adapters
            drafts = self._scan_draft_adapters()

            return {
                "total": len(services),
                "active_count": len(active_list),
                "inactive_count": len(inactive_list),
                "active_services": active_list,
                "inactive_services": inactive_list,
                "by_category": {
                    cat: {
                        "count": len(members),
                        "active": sum(1 for m in members if m["status"] == "active"),
                        "services": members,
                    }
                    for cat, members in by_category.items()
                },
                "categories": list(categories.keys()) if isinstance(categories, dict) else [],
                "draft_adapters": drafts,
            }
        except Exception as e:
            logger.warning("Service Registry scan failed: %s", e)
            return {"total": 0, "active_count": 0, "by_category": {}, "error": str(e)}

    def _scan_draft_adapters(self) -> list:
        """Scannt adapters/drafts/ fuer Draft-Adapter (vorbereitet aber nicht aktiv)."""
        try:
            drafts_dir = self.root / "factory" / "brain" / "service_provider" / "adapters" / "drafts"
            if not drafts_dir.exists():
                return []

            drafts = []
            for f in sorted(drafts_dir.glob("*_adapter.py")):
                name = f.stem.replace("_adapter", "")
                drafts.append({
                    "name": name,
                    "file": f.relative_to(self.root).as_posix(),
                })
            return drafts
        except Exception:
            return []

    # ------------------------------------------------------------------
    # Models
    # ------------------------------------------------------------------
    def _scan_models(self) -> dict:
        """Liest die Model Registry ueber das model_provider Modul."""
        try:
            from factory.brain.model_provider import get_registry
            registry = get_registry()
            stats = registry.stats

            return {
                "total": stats.get("total_models", 0),
                "available": stats.get("available_models", 0),
                "by_provider": stats.get("by_provider", {}),
                "by_tier": stats.get("by_tier", {}),
                "available_providers": stats.get("available_providers", []),
            }
        except Exception as e:
            logger.warning("Model Registry scan failed: %s", e)
            return {"total": 0, "available": 0, "by_provider": {}, "error": str(e)}

    # ------------------------------------------------------------------
    # Forges
    # ------------------------------------------------------------------
    def _scan_forges(self) -> dict:
        """Scannt factory/*_forge/ fuer verfuegbare Forges."""
        try:
            factory_dir = self.root / "factory"
            if not factory_dir.exists():
                return {"total": 0, "operational": 0, "forges": []}

            forges = []
            for forge_dir in sorted(factory_dir.iterdir()):
                if not forge_dir.is_dir() or not forge_dir.name.endswith("_forge"):
                    continue

                # Check for orchestrator or pipeline file
                py_files = [f for f in forge_dir.glob("*.py") if f.name != "__init__.py"]
                has_orchestrator = any(
                    "orchestrator" in f.name or "pipeline" in f.name
                    for f in py_files
                )

                # Look up status from agent registry
                status = self._get_forge_status_from_registry(forge_dir.name)

                forges.append({
                    "id": forge_dir.name,
                    "name": forge_dir.name.replace("_", " ").title(),
                    "status": status,
                    "has_orchestrator": has_orchestrator,
                    "py_files": len(py_files),
                    "operational": status == "active" and has_orchestrator,
                })

            operational = sum(1 for f in forges if f["operational"])

            return {
                "total": len(forges),
                "operational": operational,
                "forges": forges,
            }
        except Exception as e:
            logger.warning("Forges scan failed: %s", e)
            return {"total": 0, "operational": 0, "forges": [], "error": str(e)}

    def _get_forge_status_from_registry(self, forge_dir_name: str) -> str:
        """Sucht den Status eines Forge in der Agent Registry."""
        try:
            registry_file = self.root / "factory" / "agent_registry.json"
            if not registry_file.exists():
                return "unknown"
            data = json.loads(registry_file.read_text(encoding="utf-8"))
            # Match forge name case-insensitive against department
            forge_label = forge_dir_name.replace("_", " ").lower()
            for agent in data.get("agents", []):
                dept = agent.get("department", "").lower()
                if dept == forge_label:
                    return agent.get("status", "unknown")
            return "unknown"
        except Exception:
            return "unknown"

    # ------------------------------------------------------------------
    # Capability Lookup
    # ------------------------------------------------------------------
    def get_capability(self, category: str) -> dict:
        """Gibt Capabilities fuer eine bestimmte Kategorie zurueck.

        Kategorien: production_lines, agents, services, models, forges
        """
        full_map = self.build_map()
        if category in full_map:
            return full_map[category]
        return {"error": f"Unknown category: {category}"}

    # ------------------------------------------------------------------
    # Gap Analysis
    # ------------------------------------------------------------------
    def get_gaps(self) -> list:
        """Identifiziert Capability-Gaps in der Factory.

        Prueft:
        - Production Lines ohne Code
        - Departments ohne aktive Agents
        - Service-Kategorien ohne aktiven Service
        - Forges ohne Orchestrator
        - Draft-Adapter (vorhanden aber nicht integriert)
        - Geplante aber nicht implementierte Agents

        Wird in Phase 4 (Reasoning Engine) wiederverwendet.
        """
        full_map = self.build_map()
        gaps = []

        # 1. Production Lines ohne Code
        for line in full_map.get("production_lines", {}).get("lines", []):
            if not line.get("has_code"):
                gaps.append({
                    "type": "line_no_code",
                    "severity": "yellow",
                    "area": "production_lines",
                    "name": line["name"],
                    "message": f"Production Line '{line['name']}' hat agent.json aber keinen Code",
                })
            elif line.get("status") != "active":
                gaps.append({
                    "type": "line_inactive",
                    "severity": "yellow",
                    "area": "production_lines",
                    "name": line["name"],
                    "message": f"Production Line '{line['name']}' hat Code aber Status '{line['status']}'",
                })

        # 2. Departments ohne aktive Agents
        agents_data = full_map.get("agents", {})
        for dept, info in agents_data.get("by_department", {}).items():
            if info["active"] == 0:
                gaps.append({
                    "type": "department_no_active",
                    "severity": "red",
                    "area": "agents",
                    "name": dept,
                    "message": f"Department '{dept}' hat {info['count']} Agents aber keinen aktiven",
                })

        # 3. Geplante Agents
        for dept, info in agents_data.get("by_department", {}).items():
            for agent in info.get("agents", []):
                if agent["status"] == "planned":
                    gaps.append({
                        "type": "agent_planned",
                        "severity": "green",
                        "area": "agents",
                        "name": agent["name"],
                        "message": f"Agent '{agent['name']}' ({dept}) ist geplant aber nicht implementiert",
                    })

        # 4. Disabled Agents
        for dept, info in agents_data.get("by_department", {}).items():
            for agent in info.get("agents", []):
                if agent["status"] == "disabled":
                    gaps.append({
                        "type": "agent_disabled",
                        "severity": "yellow",
                        "area": "agents",
                        "name": agent["name"],
                        "message": f"Agent '{agent['name']}' ({dept}) ist deaktiviert",
                    })

        # 5. Service-Kategorien ohne aktiven Service
        services_data = full_map.get("services", {})
        for cat, info in services_data.get("by_category", {}).items():
            if info["active"] == 0:
                gaps.append({
                    "type": "category_no_active_service",
                    "severity": "red",
                    "area": "services",
                    "name": cat,
                    "message": f"Service-Kategorie '{cat}' hat {info['count']} Services aber keinen aktiven",
                })

        # 6. Inactive Services
        for svc in services_data.get("inactive_services", []):
            gaps.append({
                "type": "service_inactive",
                "severity": "yellow",
                "area": "services",
                "name": svc,
                "message": f"Service '{svc}' ist registriert aber inaktiv",
            })

        # 7. Draft-Adapter (vorhanden aber nicht integriert)
        active_service_names = {
            s.lower().replace(" ", "_").replace("-", "_")
            for s in services_data.get("active_services", [])
        }
        for draft in services_data.get("draft_adapters", []):
            draft_name = draft["name"].lower()
            if draft_name not in active_service_names:
                gaps.append({
                    "type": "draft_adapter",
                    "severity": "green",
                    "area": "services",
                    "name": draft["name"],
                    "message": f"Draft-Adapter '{draft['name']}' existiert aber ist nicht als Service registriert",
                    "file": draft.get("file"),
                })

        # 8. Forges ohne Orchestrator
        for forge in full_map.get("forges", {}).get("forges", []):
            if not forge.get("has_orchestrator"):
                gaps.append({
                    "type": "forge_no_orchestrator",
                    "severity": "red",
                    "area": "forges",
                    "name": forge["name"],
                    "message": f"Forge '{forge['name']}' hat keinen Orchestrator",
                })
            elif not forge.get("operational"):
                gaps.append({
                    "type": "forge_not_operational",
                    "severity": "yellow",
                    "area": "forges",
                    "name": forge["name"],
                    "message": f"Forge '{forge['name']}' hat Orchestrator aber Status '{forge['status']}'",
                })

        # 9. Models: Keine verfuegbaren Provider
        models_data = full_map.get("models", {})
        if models_data.get("total", 0) > 0 and models_data.get("available", 0) == 0:
            gaps.append({
                "type": "no_available_models",
                "severity": "red",
                "area": "models",
                "name": "models",
                "message": "Keine Modelle verfuegbar (fehlende API-Keys?)",
            })

        # Sort by severity (red > yellow > green)
        severity_order = {"red": 0, "yellow": 1, "green": 2}
        gaps.sort(key=lambda g: severity_order.get(g.get("severity", "green"), 3))

        return gaps

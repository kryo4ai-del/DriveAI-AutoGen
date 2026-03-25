"""Context builder helpers for the Factory HQ Assistant."""

import json
import os
from datetime import datetime
from pathlib import Path

FACTORY_BASE = Path(__file__).parent.parent.parent.parent
PROJECTS_DIR = FACTORY_BASE / "factory" / "projects"
DOC_SEC_DIR = FACTORY_BASE / "factory" / "document_secretary" / "output"
BRAIN_DIR = FACTORY_BASE / "factory" / "brain"


def read_factory_health() -> str:
    """Read factory infrastructure health."""
    result = {"components": []}

    # TheBrain
    registry_path = BRAIN_DIR / "model_provider" / "models_registry.json"
    brain_ok = registry_path.exists()
    result["components"].append({
        "name": "TheBrain", "status": "ok" if brain_ok else "missing",
        "details": f"Registry: {'found' if brain_ok else 'not found'}",
    })

    # Service Registry
    srv_path = BRAIN_DIR / "service_registry.json"
    if srv_path.exists():
        try:
            srv = json.loads(srv_path.read_text(encoding="utf-8"))
            active = sum(1 for s in srv.get("services", {}).values() if s.get("status") == "active")
            total = len(srv.get("services", {}))
            result["components"].append({
                "name": "Service Registry", "status": "ok",
                "details": f"{active}/{total} services active",
            })
        except Exception:
            result["components"].append({"name": "Service Registry", "status": "error"})

    # API Keys
    from dotenv import load_dotenv
    load_dotenv(FACTORY_BASE / ".env")
    keys = {}
    for k in ["ANTHROPIC_API_KEY", "OPENAI_API_KEY", "GOOGLE_AI_API_KEY", "MISTRAL_API_KEY",
              "SERPAPI_API_KEY", "ELEVENLABS_API_KEY", "STABILITY_API_KEY"]:
        keys[k] = bool(os.environ.get(k))
    active_keys = sum(1 for v in keys.values() if v)
    result["components"].append({
        "name": "API Keys", "status": "ok" if active_keys >= 3 else "warning",
        "details": f"{active_keys}/{len(keys)} keys configured",
        "keys": {k: ("configured" if v else "missing") for k, v in keys.items()},
    })

    # Document Secretary
    pdf_count = 0
    if DOC_SEC_DIR.exists():
        pdf_count = sum(1 for f in DOC_SEC_DIR.iterdir() if f.suffix == ".pdf")
    result["components"].append({
        "name": "Document Secretary", "status": "ok" if pdf_count > 0 else "warning",
        "details": f"{pdf_count} PDFs generated",
    })

    return json.dumps(result, indent=2, default=str)


def build_cost_summary(slug: str = None) -> str:
    """Build cost summary from project.json files."""
    if not PROJECTS_DIR.exists():
        return json.dumps({"error": "No projects directory"})

    if slug:
        pf = PROJECTS_DIR / slug / "project.json"
        if pf.exists():
            p = json.loads(pf.read_text(encoding="utf-8"))
            return json.dumps({
                "project": slug,
                "costs": p.get("costs", {}),
                "chapters": {k: v.get("costs", {}) for k, v in (p.get("chapters") or {}).items() if isinstance(v, dict) and v.get("costs")},
            }, indent=2, default=str)
        return json.dumps({"error": f"Project {slug} not found"})

    # All projects
    total_serpapi = 0
    total_llm = 0.0
    projects = []
    for d in sorted(PROJECTS_DIR.iterdir()):
        pf = d / "project.json"
        if not pf.exists():
            continue
        p = json.loads(pf.read_text(encoding="utf-8"))
        costs = p.get("costs", {})
        serpapi = costs.get("serpapi_credits_total", 0)
        llm = costs.get("llm_cost_usd_total", 0.0)
        total_serpapi += serpapi
        total_llm += llm
        projects.append({"project": d.name, "serpapi": serpapi, "llm_usd": llm})

    return json.dumps({
        "total_serpapi_credits": total_serpapi,
        "total_llm_cost_usd": round(total_llm, 4),
        "projects": projects,
    }, indent=2, default=str)


def build_ceo_briefing() -> str:
    """Build a daily CEO briefing from factory state."""
    from factory.hq.health_monitor import run_health_check

    health = run_health_check()
    briefing = {
        "date": datetime.now().strftime("%Y-%m-%d"),
        "factory_status": health["status"],
        "projects": [],
        "pending_gates": [],
        "recent_completions": [],
        "alerts_summary": health["summary"],
        "top_alerts": health["alerts"][:5],
    }

    if not PROJECTS_DIR.exists():
        return json.dumps(briefing, indent=2, default=str)

    for d in sorted(PROJECTS_DIR.iterdir()):
        pf = d / "project.json"
        if not pf.exists():
            continue
        p = json.loads(pf.read_text(encoding="utf-8"))
        if p.get("archived"):
            continue

        entry = {
            "name": p.get("title", d.name),
            "status": p.get("status"),
            "phase": p.get("current_phase"),
            "mode": p.get("mode", "vision"),
        }
        briefing["projects"].append(entry)

        # Check for pending gates
        gates = p.get("gates", {})
        chapters = p.get("chapters", {})

        for gate_key in ["ceo_gate", "visual_review"]:
            gate = gates.get(gate_key, {})
            ch_gate = chapters.get(gate_key, {})
            if gate.get("status") == "pending" and not (isinstance(ch_gate, dict) and ch_gate.get("decision")):
                prereq = "phase1" if gate_key == "ceo_gate" else "kapitel5"
                prereq_ch = chapters.get(prereq, {})
                if isinstance(prereq_ch, dict) and prereq_ch.get("status") == "complete":
                    briefing["pending_gates"].append({
                        "project": p.get("title", d.name),
                        "gate": gate_key,
                        "since": prereq_ch.get("date", "unbekannt"),
                    })

    return json.dumps(briefing, indent=2, default=str)


def get_time_greeting() -> str:
    """Time-of-day greeting for Andreas."""
    hour = datetime.now().hour
    if 5 <= hour < 12:
        return "Guten Morgen, Andreas."
    elif 12 <= hour < 17:
        return "Hallo Andreas."
    elif 17 <= hour < 22:
        return "Guten Abend, Andreas."
    else:
        return "Hey Andreas, noch aktiv?"


def build_welcome_briefing() -> str:
    """Compact welcome briefing for dashboard login."""
    from factory.hq.health_monitor import run_health_check

    greeting = get_time_greeting()
    health = run_health_check()

    status_word = {"healthy": "sauber", "warnings": "mit Hinweisen", "critical": "mit Problemen"}.get(
        health["status"], health["status"]
    )

    pending_gates = []
    active_projects = []
    if PROJECTS_DIR.exists():
        for d in sorted(PROJECTS_DIR.iterdir()):
            pf = d / "project.json"
            if not pf.exists():
                continue
            try:
                p = json.loads(pf.read_text(encoding="utf-8"))
            except Exception:
                continue
            if p.get("archived"):
                continue
            active_projects.append(p.get("title", d.name))

            gates = p.get("gates", {})
            chapters = p.get("chapters", {})
            for gk in ["ceo_gate", "visual_review"]:
                gate = gates.get(gk, {})
                ch_gate = chapters.get(gk, {})
                if gate.get("status") == "pending" and not (isinstance(ch_gate, dict) and ch_gate.get("decision")):
                    prereq = "phase1" if gk == "ceo_gate" else "kapitel5"
                    if isinstance(chapters.get(prereq, {}), dict) and chapters[prereq].get("status") == "complete":
                        pending_gates.append(p.get("title", d.name))

    lines = [greeting]
    lines.append(f"Factory laeuft {status_word}. {len(active_projects)} aktive Projekte.")

    if pending_gates:
        names = ", ".join(pending_gates[:3])
        lines.append(f"{len(pending_gates)} Gate{'s' if len(pending_gates) > 1 else ''} warten: {names}")

    alerts = health.get("summary", {})
    if alerts.get("critical", 0) > 0:
        lines.append(f"Achtung: {alerts['critical']} kritische Alerts.")
    elif alerts.get("warnings", 0) > 0:
        lines.append(f"{alerts['warnings']} Hinweise vorhanden.")

    if pending_gates:
        lines.append("Empfehlung: Offene Gates pruefen.")
    else:
        lines.append("Alles im Fluss.")

    return json.dumps({"briefing": "\n".join(lines)}, default=str)

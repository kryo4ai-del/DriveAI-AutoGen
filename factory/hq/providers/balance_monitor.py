"""Provider Balance Monitor — checks account balances and generates alerts.

Hybrid: API query where possible, manually maintained balance where not.
"""

import json
import logging
import os
from datetime import datetime, timezone
from pathlib import Path

import requests

logger = logging.getLogger(__name__)

PROVIDERS_DIR = Path(__file__).parent
REGISTRY_FILE = PROVIDERS_DIR / "provider_registry.json"
STATE_FILE = PROVIDERS_DIR / "provider_state.json"


def load_registry() -> dict:
    with open(REGISTRY_FILE, "r", encoding="utf-8") as f:
        return json.load(f)


def _save_registry(data: dict):
    with open(REGISTRY_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


def load_state() -> dict:
    if STATE_FILE.exists():
        try:
            return json.loads(STATE_FILE.read_text(encoding="utf-8"))
        except Exception:
            pass
    return {"providers": {}, "last_check": None}


def save_state(state: dict):
    STATE_FILE.write_text(json.dumps(state, indent=2, default=str), encoding="utf-8")


def check_balance_api(provider: dict) -> dict:
    """Try to query balance via API. Returns {balance, unit} or {error}."""
    from dotenv import load_dotenv
    load_dotenv()

    api = provider.get("api_config", {})
    endpoint = api.get("balance_endpoint")
    env_var = api.get("auth_env_var")

    if not endpoint or not env_var:
        return {"error": "Keine Balance-API konfiguriert"}

    key = os.environ.get(env_var)
    if not key:
        return {"error": f"API-Key nicht gesetzt: {env_var}"}

    header_name = api.get("auth_header", "Authorization")
    prefix = api.get("auth_prefix", "")
    headers = {header_name: f"{prefix}{key}"}

    try:
        resp = requests.get(endpoint, headers=headers, timeout=10)
        resp.raise_for_status()
        data = resp.json()

        bf = api.get("balance_field")
        if bf and " - " in bf:
            parts = [p.strip() for p in bf.split(" - ")]
            balance = data.get(parts[0], 0) - data.get(parts[1], 0)
        elif bf:
            balance = data.get(bf, 0)
        elif "total_available" in data:
            balance = data["total_available"]
        elif "credits" in data:
            balance = data["credits"]
        else:
            balance = data

        return {"balance": balance, "unit": provider.get("currency", "USD"), "raw": data}
    except requests.exceptions.HTTPError as e:
        return {"error": f"HTTP {e.response.status_code}: {e.response.text[:200]}" if e.response else str(e)}
    except Exception as e:
        return {"error": str(e)}


def update_manual_balance(provider_id: str, balance: float) -> dict:
    """CEO manually sets current balance."""
    reg = load_registry()
    for p in reg["providers"]:
        if p["id"] == provider_id:
            p["manual_balance"] = balance
            p["manual_balance_updated_at"] = datetime.now(timezone.utc).isoformat()
            _save_registry(reg)
            return {"success": True, "provider": provider_id, "balance": balance}
    return {"error": f"Provider nicht gefunden: {provider_id}"}


def add_tracked_usage(provider_id: str, amount: float, project: str = None, agent: str = None):
    """Track usage for providers without balance API."""
    state = load_state()
    ps = state.setdefault("providers", {}).setdefault(provider_id, {"tracked_usage": 0, "usage_log": []})
    ps["tracked_usage"] = ps.get("tracked_usage", 0) + amount
    ps["usage_log"].append({"amount": amount, "project": project, "agent": agent,
                             "timestamp": datetime.now(timezone.utc).isoformat()})
    # Keep log manageable
    if len(ps["usage_log"]) > 100:
        ps["usage_log"] = ps["usage_log"][-100:]
    save_state(state)

    # Deduct from manual_balance
    reg = load_registry()
    for p in reg["providers"]:
        if p["id"] == provider_id and p.get("manual_balance") is not None:
            p["manual_balance"] = max(0, p["manual_balance"] - amount)
            _save_registry(reg)


def check_all_providers() -> dict:
    """Check all providers and generate status report."""
    from dotenv import load_dotenv
    load_dotenv()

    reg = load_registry()

    # Agent counts from registry
    try:
        from factory.agent_registry import get_all_agents
        all_agents = get_all_agents()
        provider_agents = {}
        for a in all_agents:
            prov = a.get("provider", "")
            if prov and prov != "none":
                provider_agents[prov] = provider_agents.get(prov, 0) + 1
    except Exception:
        provider_agents = {}

    results = []
    alerts = []

    for prov in reg["providers"]:
        pid = prov["id"]
        r = {
            "id": pid, "name": prov["name"], "type": prov.get("type", "llm"),
            "logo_emoji": prov.get("logo_emoji", ""), "website": prov.get("website", ""),
            "currency": prov.get("currency", "USD"),
            "balance_method": prov["balance_method"],
            "warning_threshold": prov.get("warning_threshold"),
            "critical_threshold": prov.get("critical_threshold"),
            "agent_count": provider_agents.get(pid, 0),
            "models": prov.get("models", []),
            "api_key_set": bool(os.environ.get(prov.get("api_config", {}).get("auth_env_var", ""))),
            "error": None, "balance": None, "balance_fresh": False, "last_check": None, "status": "unknown",
        }

        if prov["balance_method"] == "api":
            api_result = check_balance_api(prov)
            if "error" in api_result:
                r["error"] = api_result["error"]
                # Fallback to manual
                if prov.get("manual_balance") is not None:
                    r["balance"] = prov["manual_balance"]
                    r["balance_fresh"] = False
                    r["last_check"] = prov.get("manual_balance_updated_at")
            else:
                r["balance"] = api_result["balance"]
                r["balance_fresh"] = True
                r["last_check"] = datetime.now(timezone.utc).isoformat()

        elif prov["balance_method"] == "tracked":
            r["balance"] = prov.get("manual_balance")
            r["balance_fresh"] = prov.get("manual_balance_updated_at") is not None
            r["last_check"] = prov.get("manual_balance_updated_at")
            if r["balance"] is None:
                r["error"] = "Kein Guthaben eingetragen"

        # Status
        if r["balance"] is not None:
            crit = prov.get("critical_threshold", 0)
            warn = prov.get("warning_threshold", 0)
            if r["balance"] <= crit:
                r["status"] = "critical"
                alerts.append({"provider": pid, "severity": "critical",
                               "message": f"{prov['name']} KRITISCH: {r['balance']} {r['currency']}"})
            elif r["balance"] <= warn:
                r["status"] = "warning"
                alerts.append({"provider": pid, "severity": "warning",
                               "message": f"{prov['name']} niedrig: {r['balance']} {r['currency']}"})
            else:
                r["status"] = "ok"

        results.append(r)

    return {
        "timestamp": datetime.now(timezone.utc).isoformat(),
        "providers": results, "alerts": alerts,
        "summary": {
            "total": len(results),
            "ok": sum(1 for r in results if r["status"] == "ok"),
            "warning": sum(1 for r in results if r["status"] == "warning"),
            "critical": sum(1 for r in results if r["status"] == "critical"),
            "unknown": sum(1 for r in results if r["status"] == "unknown"),
        },
    }

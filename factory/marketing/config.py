"""Marketing-Abteilung Konfiguration.

Zentrale Konstanten und Pfade fuer alle Marketing-Module.
"""

import os

# --- Pfade ---
MARKETING_ROOT = os.path.dirname(os.path.abspath(__file__))
FACTORY_ROOT = os.path.dirname(MARKETING_ROOT)
PROJECT_ROOT = os.path.dirname(FACTORY_ROOT)

ALERTS_PATH = os.path.join(MARKETING_ROOT, "alerts")
BRAND_PATH = os.path.join(MARKETING_ROOT, "brand")
REPORTS_PATH = os.path.join(MARKETING_ROOT, "reports")
OUTPUT_PATH = os.path.join(MARKETING_ROOT, "output")
AGENTS_PATH = os.path.join(MARKETING_ROOT, "agents")

# --- Department-Info ---
DEPARTMENT_NAME = "Marketing"
DEPARTMENT_ID_PREFIX = "MKT"
VERSION = "0.1.0"

# --- Agent-Definitionen ---
AGENTS = {
    "brand_guardian": {
        "id": "MKT-01",
        "name": "Brand Guardian",
        "status": "active",
        "model_tier": "mid",
    },
    "strategy": {
        "id": "MKT-02",
        "name": "Marketing Strategy",
        "status": "active",
        "model_tier": "mid",
    },
}

# --- Pipeline Input Quellen ---
# Die Marketing-Abteilung liest Outputs aus diesen Factory-Departments
PIPELINE_SOURCES = {
    "pre_production": os.path.join(FACTORY_ROOT, "pre_production", "output"),
    "market_strategy": os.path.join(FACTORY_ROOT, "market_strategy", "output"),
    "mvp_scope": os.path.join(FACTORY_ROOT, "mvp_scope", "output"),
    "roadbook_assembly": os.path.join(FACTORY_ROOT, "roadbook_assembly", "output"),
    "design_vision": os.path.join(FACTORY_ROOT, "design_vision", "output"),
}

# --- Service-Status (wird dynamisch aus service_registry.json gelesen) ---
SERVICE_REGISTRY_PATH = os.path.join(FACTORY_ROOT, "brain", "service_registry.json")

# --- LLM Fallback ---
# Wird von allen Marketing-Agents im Anthropic-Fallback genutzt.
# NICHT hardcoden in Agent-Dateien! Immer ueber get_fallback_model() beziehen.

def get_fallback_model() -> str:
    """Gibt das aktuelle Fallback-Modell zurueck.

    Versucht zuerst das Modell aus der Model Registry (llm_profiles.json) zu lesen.
    Falls nicht verfuegbar, nutzt die .env Variable ANTHROPIC_FALLBACK_MODEL.
    Letzter Fallback: hartcodierter Default (einzige Stelle im gesamten Marketing-Code).
    """
    # 1. Aus TheBrain Model Registry
    try:
        from factory.brain.model_provider import get_model
        selection = get_model(profile="standard")
        if selection and selection.get("model"):
            return selection["model"]
    except Exception:
        pass

    # 2. Aus .env
    env_model = os.environ.get("ANTHROPIC_FALLBACK_MODEL")
    if env_model:
        return env_model

    # 3. Letzter Fallback — EINZIGE hardcodierte Stelle
    return "claude-sonnet-4-6"


# --- Prinzipien ---
BUILD_OVER_BUY = True
DASHBOARD_WRITE = False
CEO_GATE_ON_CRISIS = True

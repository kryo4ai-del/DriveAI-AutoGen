"""UpdatePlanner configuration — version logic, scope rules, priorities."""

# ── Version Bump Rules ─────────────────────────────────────────────
# hotfix  → patch version (1.2.3 → 1.2.4)
# patch   → patch version (1.2.3 → 1.2.4)
# feature_update → minor version (1.2.3 → 1.3.0)
VERSION_BUMP = {
    "hotfix": "patch",
    "patch": "patch",
    "feature_update": "minor",
}

# ── Scope Determination ────────────────────────────────────────────
# hotfix: minimal — only the primary trigger
# patch:  focused — all active triggers
# feature_update: broad — new features + improvements
SCOPE_RULES = {
    "hotfix": {"max_triggers": 1, "label": "minimal", "description": "Nur primaerer Trigger"},
    "patch": {"max_triggers": 99, "label": "focused", "description": "Alle aktiven Trigger"},
    "feature_update": {"max_triggers": 99, "label": "broad", "description": "Neue Features + Verbesserungen"},
}

# ── Priority Mapping ───────────────────────────────────────────────
PRIORITY_MAP = {
    "hotfix": "P0-CRITICAL",
    "patch": "P1-HIGH",
    "feature_update": "P2-MEDIUM",
    "strategic_pivot": "P0-CRITICAL",
}

# ── Briefing Storage ──────────────────────────────────────────────
BRIEFING_DIR_NAME = "briefings"

# ── Factory Instructions per Action Type ──────────────────────────
FACTORY_INSTRUCTIONS = {
    "hotfix": {
        "urgency": "SOFORT — naechster Build-Slot",
        "testing": "Smoke Test + betroffener Bereich",
        "rollback_plan": "Automatisch bei Health-Score-Drop > 10pt",
    },
    "patch": {
        "urgency": "Innerhalb 24h",
        "testing": "Vollstaendiger Regression Test",
        "rollback_plan": "Manuell via Release Manager",
    },
    "feature_update": {
        "urgency": "Naechster Sprint-Zyklus",
        "testing": "Full QA + User Acceptance",
        "rollback_plan": "Feature Flag Deaktivierung",
    },
    "strategic_pivot": {
        "urgency": "CEO-Entscheidung abwarten",
        "testing": "Kompletter Relaunch-Test",
        "rollback_plan": "Kein Rollback — neues Produkt",
    },
}

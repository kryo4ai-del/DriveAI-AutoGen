"""
DAI-Core Brand Context Loader
Zentrale Stelle um Brand-Context fuer Agents zu laden.
Wird von TheBrain und direkt von Agents genutzt.
"""

from pathlib import Path

BRAND_DIR = Path(__file__).parent
ASSETS_DIR = BRAND_DIR / "assets"
CSS_DIR = BRAND_DIR / "css"

# Brand Tier Definitions
TIER_A_FULL = "full"       # Complete Brand Bible
TIER_B_SUMMARY = "summary"  # Compact Brand Summary
TIER_C_NONE = "none"        # No brand injection

# Agent -> Tier Mapping
# Keys: Ordnernamen oder Agent-Prefixes
BRAND_TIERS = {
    # Tier A — Full Brand Bible
    "roadbook_assembly": TIER_A_FULL,
    "marketing": TIER_A_FULL,
    "document_secretary": TIER_A_FULL,
    "store": TIER_A_FULL,
    "store_prep": TIER_A_FULL,

    # Tier B — Brand Summary
    "design_vision": TIER_B_SUMMARY,
    "asset_forge": TIER_B_SUMMARY,
    "sound_forge": TIER_B_SUMMARY,
    "motion_forge": TIER_B_SUMMARY,
    "scene_forge": TIER_B_SUMMARY,
    "visual_audit": TIER_B_SUMMARY,
    "market_strategy": TIER_B_SUMMARY,

    # Tier C — No Injection (not listed = no injection)
}


def get_brand_tier(agent_department: str) -> str:
    """Bestimme den Brand-Tier fuer ein Department/Agent."""
    return BRAND_TIERS.get(agent_department, TIER_C_NONE)


def load_brand_context(tier: str = None, department: str = None) -> str:
    """
    Lade Brand-Context basierend auf Tier oder Department.

    Args:
        tier: Direkt "full" oder "summary" angeben
        department: Department-Name (wird zu Tier aufgeloest)

    Returns:
        Brand-Context als String, oder leerer String wenn Tier C
    """
    if tier is None and department:
        tier = get_brand_tier(department)

    if tier == TIER_A_FULL:
        bible_path = BRAND_DIR / "DAI-CORE_Brand_Bible_v1.0.md"
        if bible_path.exists():
            return (
                "\n<brand_identity>\n"
                + bible_path.read_text(encoding="utf-8")
                + "\n</brand_identity>\n"
            )

    elif tier == TIER_B_SUMMARY:
        summary_path = BRAND_DIR / "brand_summary.md"
        if summary_path.exists():
            return (
                "\n<brand_context>\n"
                + summary_path.read_text(encoding="utf-8")
                + "\n</brand_context>\n"
            )

    return ""


def get_logo_path(variant: str = "full") -> Path:
    """
    Hole den Pfad zu einer Logo-Variante.

    Args:
        variant: "full" (mit Text), "icon" (nur Icon),
                 "favicon" (quadratisch), "original" (mit BG)
    """
    variants = {
        "full": ASSETS_DIR / "DAI-CORE_Logo_Full.png",
        "icon": ASSETS_DIR / "DAI-CORE_Logo_Icon.png",
        "favicon": ASSETS_DIR / "DAI-CORE_Favicon_512.png",
        "original": ASSETS_DIR / "DAI-CORE_Logo_Original.png",
    }
    return variants.get(variant, variants["full"])


def get_css_variables_path() -> Path:
    """Pfad zur CSS Variables Datei."""
    return CSS_DIR / "brand_variables.css"


def get_brand_colors() -> dict:
    """Brand-Farben als Dictionary."""
    return {
        "magenta": "#D660D7",
        "cyan": "#6BD2F2",
        "void": "#1E1D25",
        "magenta_glow": "#F09CF8",
        "purple_deep": "#7A3C9F",
        "cyan_steel": "#4B9BB4",
        "midnight": "#13121A",
        "white": "#FFFFFF",
        "gray_light": "#B0B0C0",
        "gray_mid": "#4A4A5A",
    }


def get_brand_info() -> dict:
    """Kern-Brand-Infos als Dictionary (fuer programmatische Nutzung)."""
    return {
        "name": "DAI-Core",
        "domain": "dai-core.ai",
        "tagline": "One idea in. One extraordinary app out.",
        "agent_count": "100+",
        "department_count": "14+",
        "voice": "we",  # Always "we", never "I"
        "attribution_short": "Built by DAI-Core",
        "attribution_long": (
            "A DAI-Core Production — Crafted by over 100 AI specialists"
        ),
    }

"""Section detection patterns for CD Roadbook and Design Vision PDFs."""

import re

CD_ROADBOOK_SECTIONS = {
    "product_profile": [
        r"1\.\s*Produkt-Kurzprofil",
        r"Produkt-Kurzprofil",
    ],
    "design_vision": [
        r"2\.\s*Design-Vision",
        r"Design-Vision\s*\(VERBINDLICH\)",
    ],
    "style_guide": [
        r"3\.\s*Stil-Guide",
        r"Stil-Guide\s*\(VERBINDLICH\)",
    ],
    "feature_map": [
        r"4\.\s*Feature-Map",
        r"Feature-Map",
    ],
    "screen_architecture": [
        r"5\.\s*Screen-Uebersicht",
        r"6\.\s*Screen-Architektur",
        r"Screen-Architektur\s*\(VERBINDLICH\)",
    ],
    "asset_table": [
        r"7\.\s*Asset-Liste",
        r"Asset-Liste\s*\(VERBINDLICH\)",
        r"Vollst.ndige Asset-Tabelle",
    ],
    "ki_warnings": [
        r"8\.\s*KI-Produktions-Warnungen",
        r"KI-Produktions-Warnungen\s*\(VERBINDLICH",
    ],
}

DESIGN_VISION_SECTIONS = {
    "emotional_guideline": [
        r"1\.1\s*Emotionale Leitlinie",
        r"Emotionale Leitlinie",
    ],
    "color_palette": [
        r"Farbpalette",
        r"Farb-System",
        r"Color Palette",
    ],
    "typography": [
        r"Typografie",
        r"Typography",
        r"Schrift",
    ],
    "illustration_style": [
        r"Illustrations-Stil",
        r"Illustration Style",
        r"Visual Style",
    ],
    "anti_rules": [
        r"Anti-Regeln",
        r"Was.*NICHT",
        r"Verboten",
    ],
}

NUMBERED_SECTION = re.compile(r'\n(\d+)\.\s+([A-ZÄÖÜ][^\n]+)')

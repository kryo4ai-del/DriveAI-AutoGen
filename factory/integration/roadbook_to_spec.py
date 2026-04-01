"""Roadbook-to-Spec Converter — Parses CD Technical Roadbook into project.yaml.

Reads the ~80-page markdown CD Technical Roadbook and extracts structured data
that the Factory Orchestrator (spec_parser.py) can consume for production.

Usage:
    python -m factory.integration.roadbook_to_spec \
        --roadbook path/to/cd_technical_roadbook.md \
        --output projects/growmeldai/project.yaml
"""

import argparse
import json
import logging
import re
import sys
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)

try:
    import yaml
    _HAS_YAML = True
except ImportError:
    yaml = None
    _HAS_YAML = False

FACTORY_BASE = Path(__file__).resolve().parents[2]


class RoadbookConverter:
    """Parses a CD Technical Roadbook (.md) into a structured project spec."""

    # Known section headers in the roadbook
    _SECTIONS = [
        "Produkt-Kurzprofil", "Design-Vision", "Stil-Guide",
        "Feature-Map", "Abhängigkeits-Graph", "Screen-Architektur",
        "Asset-Liste", "KI-Produktions-Warnungen", "Legal-Anforderungen",
    ]

    def __init__(self, roadbook_path: str):
        self.path = Path(roadbook_path)
        if not self.path.is_file():
            raise FileNotFoundError(f"Roadbook not found: {self.path}")
        self.text = self.path.read_text(encoding="utf-8")
        self._validate()
        self._sections: dict[str, str] = {}
        self._split_sections()

    def _validate(self):
        """Check this is actually a CD Technical Roadbook."""
        markers = ["Creative Director Technical Roadbook", "VERBINDLICH"]
        found = sum(1 for m in markers if m in self.text)
        if found == 0:
            raise ValueError("File does not appear to be a CD Technical Roadbook")

    def _split_sections(self):
        """Split roadbook into named sections by ## headers."""
        pattern = re.compile(r"^## \d+\.\s+(.+?)$", re.MULTILINE)
        matches = list(pattern.finditer(self.text))
        for i, m in enumerate(matches):
            name = m.group(1).strip().split("(")[0].strip()
            start = m.end()
            end = matches[i + 1].start() if i + 1 < len(matches) else len(self.text)
            self._sections[name] = self.text[start:end]

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def convert(self) -> dict:
        """Parse the roadbook and return a complete project spec dict."""
        project_info = self._parse_project_info()
        platforms = self._parse_platforms()
        design = self._parse_design_tokens()
        screens = self._parse_screens()
        features = self._parse_features()
        assets = self._parse_assets()
        apis = self._parse_apis()
        legal = self._parse_legal_requirements()

        spec = {
            "project": {
                "name": project_info.get("name", "Unknown"),
                "slug": project_info.get("slug", "unknown"),
                "version": "1.0.0",
                "source": self.path.name,
                "generated_at": datetime.now(timezone.utc).isoformat(),
            },
            "platforms": platforms,
            "design": design,
            "screens": screens,
            "features": features,
            "assets": assets,
            "apis": apis,
            "legal": legal,
            # Orchestrator-compatible format
            "target_lines": [platforms.get("primary", "ios")],
        }

        logger.info(
            "Parsed: %d screens, %d features, %d assets, %d APIs",
            len(screens), len(features), len(assets), len(apis),
        )
        return spec

    def save_yaml(self, spec: dict, output_path: str) -> Path:
        """Save spec as YAML. Falls back to JSON if PyYAML unavailable."""
        out = Path(output_path)
        out.parent.mkdir(parents=True, exist_ok=True)
        if _HAS_YAML:
            with open(out, "w", encoding="utf-8") as f:
                yaml.dump(spec, f, default_flow_style=False,
                          allow_unicode=True, sort_keys=False, width=120)
        else:
            out = out.with_suffix(".json")
            with open(out, "w", encoding="utf-8") as f:
                json.dump(spec, f, ensure_ascii=False, indent=2)
            logger.warning("PyYAML not installed — saved as JSON instead")
        return out

    # ------------------------------------------------------------------
    # Section parsers
    # ------------------------------------------------------------------

    def _parse_project_info(self) -> dict:
        """Extract project name, slug from header / Produkt-Kurzprofil."""
        info = {"name": "Unknown", "slug": "unknown"}
        # Title line: "# Creative Director Technical Roadbook: GrowMeldAI"
        m = re.search(r"^# .*?:\s*(.+)$", self.text, re.MULTILINE)
        if m:
            info["name"] = m.group(1).strip()
            info["slug"] = re.sub(r"[^a-z0-9]+", "", info["name"].lower())
        # Alt: **App Name:** GrowMeldAI
        m = re.search(r"\*\*App Name:\*\*\s*(.+)", self.text)
        if m:
            info["name"] = m.group(1).strip()
            info["slug"] = re.sub(r"[^a-z0-9]+", "", info["name"].lower())
        return info

    def _parse_platforms(self) -> dict:
        """Extract platform info from Produkt-Kurzprofil."""
        result = {"primary": "ios", "secondary": [], "tech_stack": {}}
        sec = self._sections.get("Produkt-Kurzprofil", self.text[:3000])

        if re.search(r"Primär.*?iOS", sec, re.IGNORECASE):
            result["primary"] = "ios"
        elif re.search(r"Primär.*?Android", sec, re.IGNORECASE):
            result["primary"] = "android"

        if re.search(r"Sekundär.*?Android", sec, re.IGNORECASE):
            result["secondary"].append("android")
        if re.search(r"Sekundär.*?iOS", sec, re.IGNORECASE):
            result["secondary"].append("ios")

        # Tech stack
        if "Swift/SwiftUI" in sec or "Swift" in sec:
            result["tech_stack"]["ios"] = "Swift/SwiftUI"
        if "Kotlin" in sec:
            result["tech_stack"]["android"] = "Kotlin/Jetpack Compose"
        if "Flutter" in sec:
            result["tech_stack"]["cross_platform"] = "Flutter"
        if "Firebase" in sec:
            result["tech_stack"]["backend"] = "Firebase"

        return result

    def _parse_design_tokens(self) -> dict:
        """Extract colors, fonts, differentiators from Stil-Guide / Design-Vision."""
        design: dict = {"tokens": {"colors": {}, "fonts": {}}, "differentiators": []}

        # Colors: look for hex codes in tables
        for sec_name in ("Stil-Guide", "Design-Vision"):
            sec = self._sections.get(sec_name, "")
            # Pattern: | Name | `#HEXCODE` | Usage |
            for m in re.finditer(
                r"\|\s*([^|]+?)\s*\|\s*`?(#[0-9A-Fa-f]{6}(?:[0-9A-Fa-f]{2})?)`?\s*\|",
                sec,
            ):
                name = m.group(1).strip()
                hex_val = m.group(2).strip()
                key = re.sub(r"[^a-z0-9]+", "_", name.lower()).strip("_")
                design["tokens"]["colors"][key] = hex_val

        # Fonts from typography table
        sec = self._sections.get("Stil-Guide", "")
        for m in re.finditer(
            r"\|\s*\*\*([^*]+)\*\*\s*\|\s*\*\*VERBINDLICH:\*\*\s*([^|]+)\|",
            sec,
        ):
            font_name = m.group(1).strip()
            usage = m.group(2).strip()
            key = "headline" if "headline" in usage.lower() or "h1" in usage.lower() else "body"
            if "mono" in font_name.lower() or "debug" in usage.lower():
                key = "mono"
            design["tokens"]["fonts"][key] = font_name

        # Differentiators: D01, D02, ...
        sec = self._sections.get("Design-Vision", "")
        design["differentiators"] = sorted(set(re.findall(r"\bD0[1-9]\b", sec)))

        return design

    def _parse_screens(self) -> list[dict]:
        """Extract screen specs from Screen-Architektur section."""
        screens = []
        sec = self._sections.get("Screen-Architektur", "")

        # Table rows: | S001 | Name | Typ | Zweck | Features | States |
        for m in re.finditer(
            r"\|\s*(S\d{3})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|",
            sec,
        ):
            sid = m.group(1).strip()
            name = m.group(2).strip()
            stype = m.group(3).strip()
            purpose = m.group(4).strip()
            features_raw = m.group(5).strip()
            states_raw = m.group(6).strip()

            # Extract feature IDs
            feature_ids = re.findall(r"F\d{3}", features_raw)
            # Extract states
            states = [s.strip() for s in states_raw.split(",") if s.strip()]

            # Determine priority based on type
            priority = "must_have"
            if stype.lower() in ("overlay", "debug"):
                priority = "could_have"
            elif stype.lower() == "modal":
                priority = "should_have"

            # Determine layer
            layer = 3  # UI layer default
            if "splash" in name.lower() or "loading" in name.lower():
                layer = 1
            elif "modal" in stype.lower() or "overlay" in stype.lower():
                layer = 4

            screens.append({
                "id": sid,
                "name": name,
                "type": stype.lower().replace(" ", "_"),
                "description": purpose,
                "features": feature_ids,
                "states": states[:5],  # cap for readability
                "priority": priority,
                "layer": layer,
            })

        # Phase B screens (S023+)
        for m in re.finditer(
            r"\|\s*(S\d{3})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|",
            sec,
        ):
            sid = m.group(1).strip()
            if int(sid[1:]) < 23:
                continue  # already captured above
            if any(s["id"] == sid for s in screens):
                continue
            screens.append({
                "id": sid,
                "name": m.group(2).strip(),
                "type": "subscreen",
                "description": m.group(3).strip(),
                "features": [],
                "states": [],
                "priority": "could_have",
                "layer": 3,
                "phase": "B",
            })

        return screens

    def _parse_features(self) -> list[dict]:
        """Extract features from Feature-Map section."""
        features = []
        sec = self._sections.get("Feature-Map", "")
        current_phase = "A"

        for line in sec.split("\n"):
            # Detect phase headers
            if "Phase B" in line:
                current_phase = "B"
            elif "Backlog" in line:
                current_phase = "backlog"

            # Table rows: | F001 | Name | Description | KPI | Weeks | Dependencies |
            m = re.match(
                r"\|\s*(F\d{3})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|\s*([^|]*?)\s*\|",
                line,
            )
            # Backlog table: | F050 | Name | Version | Impact | Reason | (5 columns)
            m_bl = None
            if not m:
                m_bl = re.match(
                    r"\|\s*(F\d{3})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|",
                    line,
                )
            if not m and not m_bl:
                continue

            if m:
                fid = m.group(1).strip()
                name = m.group(2).strip()
                desc = m.group(3).strip()
                kpi_raw = m.group(4).strip()
                weeks_raw = m.group(5).strip()
                deps_raw = m.group(6).strip()
            else:
                fid = m_bl.group(1).strip()
                name = m_bl.group(2).strip()
                desc = m_bl.group(4).strip()  # "Erwarteter Impact" as description
                kpi_raw = ""
                weeks_raw = ""
                deps_raw = ""

            # Parse weeks
            weeks = 0
            wm = re.search(r"(\d+)", weeks_raw)
            if wm:
                weeks = int(wm.group(1))

            # Parse dependencies
            depends_on = re.findall(r"F\d{3}", deps_raw)

            # Determine priority based on phase
            if current_phase == "A":
                priority = "must_have"
            elif current_phase == "B":
                priority = "should_have"
            else:
                priority = "wont_have"

            # Determine layer
            layer = 2  # core default
            name_lower = name.lower()
            if any(k in name_lower for k in ("firebase", "api", "integration", "auth", "cloud")):
                layer = 1  # foundation
            elif any(k in name_lower for k in ("ui", "onboarding", "screen", "kamera")):
                layer = 3  # UI
            elif any(k in name_lower for k in ("compliance", "dsgvo", "coppa", "legal")):
                layer = 5  # integration/compliance
            elif any(k in name_lower for k in ("aso", "tiktok", "instagram", "seo", "marketing")):
                layer = 6  # polish/marketing

            # Determine complexity
            if weeks >= 6:
                complexity = "high"
            elif weeks >= 3:
                complexity = "medium"
            else:
                complexity = "low"

            features.append({
                "id": fid,
                "name": name,
                "description": desc,
                "priority": priority,
                "phase": current_phase,
                "layer": layer,
                "weeks": weeks,
                "complexity": complexity,
                "depends_on": depends_on,
                "kpi_impact": [k.strip() for k in kpi_raw.split(",") if k.strip()],
            })

        return features

    def _parse_assets(self) -> list[dict]:
        """Extract assets from Asset-Liste section."""
        assets = []
        sec = self._sections.get("Asset-Liste", "")

        # Table: | A001 | Name | Screen(s) | Kategorie | Quelle | Format | Priorität |
        for m in re.finditer(
            r"\|\s*(A\d{3})\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|\s*([^|]+?)\s*\|",
            sec,
        ):
            aid = m.group(1).strip()
            name = m.group(2).strip()
            screen_refs = m.group(3).strip()
            category = m.group(4).strip()
            source = m.group(5).strip()
            fmt = m.group(6).strip()
            priority_raw = m.group(7).strip()

            screens_list = re.findall(r"S\d{3}", screen_refs)
            launch_critical = "launch-kritisch" in priority_raw.lower() or "Launch-kritisch" in priority_raw

            assets.append({
                "id": aid,
                "name": name,
                "screens": screens_list,
                "category": category,
                "source": source,
                "format": fmt,
                "launch_critical": launch_critical,
            })

        return assets

    def _parse_apis(self) -> list[dict]:
        """Extract API integrations from the roadbook."""
        apis = []
        seen = set()
        # Search full text for known API patterns
        api_patterns = [
            (r"Plant\.id\s*API", "plant_id", "external", "Plant identification + disease diagnosis"),
            (r"OpenWeatherMap", "openweathermap", "external", "Weather data for care recommendations"),
            (r"Firebase\s*Auth", "firebase_auth", "backend", "User authentication"),
            (r"Cloud\s*Firestore", "cloud_firestore", "backend", "Database for profiles + care plans"),
            (r"Firebase\s*Cloud\s*Functions", "firebase_functions", "backend", "Serverless backend logic"),
            (r"Firebase\s*Analytics", "firebase_analytics", "analytics", "User behavior tracking"),
            (r"Firebase\s*Crashlytics", "firebase_crashlytics", "monitoring", "Crash reporting"),
            (r"Firebase\s*Cloud\s*Messaging", "firebase_fcm", "backend", "Push notifications"),
        ]
        for pattern, name, api_type, desc in api_patterns:
            if re.search(pattern, self.text, re.IGNORECASE) and name not in seen:
                seen.add(name)
                apis.append({
                    "name": name,
                    "type": api_type,
                    "description": desc,
                })

        return apis

    def _parse_legal_requirements(self) -> dict:
        """Extract legal/compliance requirements."""
        legal: dict = {
            "gdpr_consent_required": False,
            "coppa_required": False,
            "att_required": False,
            "location_mode": "unknown",
            "ml_training_user_data": True,
            "consent_screens": [],
        }
        sec = self._sections.get("Legal-Anforderungen", self.text)

        if re.search(r"DSGVO", sec):
            legal["gdpr_consent_required"] = True
        if re.search(r"COPPA", sec):
            legal["coppa_required"] = True
        if re.search(r"ATT|App Tracking Transparency", sec):
            legal["att_required"] = True

        # Location mode
        if re.search(r"PLZ-Ebene|PLZ-Fallback|KEINE GPS", sec, re.IGNORECASE):
            legal["location_mode"] = "plz"
        elif re.search(r"GPS", sec):
            legal["location_mode"] = "gps"

        # ML training
        if re.search(r"KEINE.*?Nutzer-Uploads.*?ML-Training", sec, re.IGNORECASE):
            legal["ml_training_user_data"] = False

        # Consent screens — only actual consent/permission modals
        consent_keywords = re.findall(
            r"(S\d{3}).*?(?:Consent|Permission|Einwilligung|DSGVO|COPPA|ATT)",
            sec,
        )
        for sid in consent_keywords:
            if sid not in legal["consent_screens"]:
                legal["consent_screens"].append(sid)
        # Fallback: known consent screen IDs from standard roadbook structure
        for sid in ("S003", "S007", "S018", "S022"):
            if sid not in legal["consent_screens"] and re.search(sid, sec):
                legal["consent_screens"].append(sid)

        return legal


def main():
    parser = argparse.ArgumentParser(
        description="Convert CD Technical Roadbook to project.yaml for Factory Orchestrator"
    )
    parser.add_argument("--roadbook", required=True, help="Path to cd_technical_roadbook.md")
    parser.add_argument("--output", default="", help="Output path for project.yaml (default: auto)")
    parser.add_argument("--json", action="store_true", help="Force JSON output instead of YAML")
    parser.add_argument("--stats", action="store_true", help="Print parsing stats to stderr")
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, stream=sys.stderr,
                        format="[RoadbookConverter] %(message)s")

    converter = RoadbookConverter(args.roadbook)
    spec = converter.convert()

    # Determine output path
    if args.output:
        out_path = args.output
    else:
        slug = spec["project"]["slug"]
        out_path = str(FACTORY_BASE / "projects" / slug / "specs" / "build_spec.yaml")

    if args.json:
        out_path = str(Path(out_path).with_suffix(".json"))
        Path(out_path).parent.mkdir(parents=True, exist_ok=True)
        with open(out_path, "w", encoding="utf-8") as f:
            json.dump(spec, f, ensure_ascii=False, indent=2)
        saved = Path(out_path)
    else:
        saved = converter.save_yaml(spec, out_path)

    # Stats
    n_screens = len(spec["screens"])
    n_features = len(spec["features"])
    n_assets = len(spec["assets"])
    n_apis = len(spec["apis"])
    n_colors = len(spec["design"]["tokens"]["colors"])
    n_diffs = len(spec["design"]["differentiators"])
    launch_critical = sum(1 for a in spec["assets"] if a.get("launch_critical"))

    print(f"Saved: {saved}", file=sys.stderr)
    print(f"Screens: {n_screens}", file=sys.stderr)
    print(f"Features: {n_features} (Phase A: {sum(1 for f in spec['features'] if f['phase'] == 'A')}, "
          f"Phase B: {sum(1 for f in spec['features'] if f['phase'] == 'B')}, "
          f"Backlog: {sum(1 for f in spec['features'] if f['phase'] == 'backlog')})", file=sys.stderr)
    print(f"Assets: {n_assets} ({launch_critical} launch-critical)", file=sys.stderr)
    print(f"APIs: {n_apis}", file=sys.stderr)
    print(f"Design Tokens: {n_colors} colors, {len(spec['design']['tokens']['fonts'])} fonts, "
          f"{n_diffs} differentiators", file=sys.stderr)
    print(f"Legal: GDPR={spec['legal']['gdpr_consent_required']}, "
          f"COPPA={spec['legal']['coppa_required']}, "
          f"Location={spec['legal']['location_mode']}, "
          f"ML-Training={spec['legal']['ml_training_user_data']}", file=sys.stderr)


if __name__ == "__main__":
    main()

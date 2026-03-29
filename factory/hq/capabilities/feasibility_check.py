"""Production Feasibility Check.

Reads a CD Technical Roadbook and checks each requirement against
the current Factory Capability Sheet. Deterministic keyword matching
(Stufe 1-2, free). No LLM calls by default.

Usage::

    checker = FeasibilityChecker()
    result = checker.check_project("memerun2026")
    print(result["overall_status"])  # feasible / partially_feasible / not_feasible
"""

import json
import os
import re
from datetime import datetime
from pathlib import Path

from factory.hq.capabilities.capability_sheet import generate_capability_sheet

_ROOT = Path(__file__).resolve().parent.parent.parent.parent
_REPORTS_DIR = _ROOT / "factory" / "hq" / "capabilities" / "reports"


class FeasibilityChecker:
    """Checks a project's CD Roadbook against factory capabilities."""

    def __init__(self):
        self.sheet = generate_capability_sheet()

    def check_project(self, slug: str, roadbook_path: str = None) -> dict:
        """Run feasibility check for a project.

        Returns structured report with overall_status, per-requirement
        analysis, capability gaps, line assignments, and recommendations.
        """
        roadbook = self._load_roadbook(slug, roadbook_path)
        if not roadbook:
            return {
                "project_slug": slug,
                "overall_status": "not_feasible",
                "score": 0.0,
                "summary": f"CD Technical Roadbook nicht gefunden fuer {slug}",
                "requirements": [],
                "capability_gaps": [],
                "line_assignments": {},
                "recommendations": ["Roadbook Assembly (Kapitel 6) zuerst ausfuehren"],
                "check_date": datetime.now().isoformat(),
                "report_path": None,
            }

        requirements = self._extract_requirements(roadbook)
        matched = [self._match_requirement(req) for req in requirements]

        # Calculate scores
        met = [r for r in matched if r["status"] == "met"]
        warnings = [r for r in matched if r["status"] == "warning"]
        not_met = [r for r in matched if r["status"] == "not_met"]

        total = len(matched) if matched else 1
        score = round((len(met) + 0.5 * len(warnings)) / total, 2)

        # Collect capability gaps
        gaps = []
        seen_gaps = set()
        for r in not_met:
            gap_name = r.get("gap", "")
            if gap_name and gap_name not in seen_gaps:
                seen_gaps.add(gap_name)
                gaps.append({
                    "capability": gap_name,
                    "required_by": [r["name"]],
                    "severity": "blocking",
                })
            elif gap_name in seen_gaps:
                for g in gaps:
                    if g["capability"] == gap_name:
                        g["required_by"].append(r["name"])

        for r in warnings:
            gap_name = r.get("gap", "")
            if gap_name and gap_name not in seen_gaps:
                seen_gaps.add(gap_name)
                gaps.append({
                    "capability": gap_name,
                    "required_by": [r["name"]],
                    "severity": "warning",
                })

        # Determine overall status
        blocking_gaps = [g for g in gaps if g["severity"] == "blocking"]
        if not blocking_gaps:
            overall = "feasible"
        elif len(blocking_gaps) <= 2 and score >= 0.6:
            overall = "partially_feasible"
        else:
            overall = "not_feasible"

        # Line assignments
        line_assignments = self._calculate_line_assignments(roadbook)

        # Recommendations
        recommendations = self._generate_recommendations(
            overall, matched, gaps, line_assignments
        )

        # Summary
        summary = (
            f"{len(met)} von {total} Requirements erfuellt. "
            f"{len(warnings)} Warnungen, {len(not_met)} nicht machbar."
        )

        result = {
            "project_slug": slug,
            "overall_status": overall,
            "score": score,
            "summary": summary,
            "requirements": matched,
            "capability_gaps": gaps,
            "line_assignments": line_assignments,
            "recommendations": recommendations,
            "check_date": datetime.now().isoformat(),
            "report_path": None,
        }

        # Save report
        report_path = self._save_report(slug, result)
        result["report_path"] = report_path

        return result

    # ------------------------------------------------------------------
    # Roadbook Loading
    # ------------------------------------------------------------------

    def _load_roadbook(self, slug: str, path: str = None) -> str:
        """Find and read cd_technical_roadbook.md for a project."""
        if path and os.path.isfile(path):
            return Path(path).read_text(encoding="utf-8")

        # Search in roadbook_assembly output
        rb_output = _ROOT / "factory" / "roadbook_assembly" / "output"
        if rb_output.exists():
            # Find latest run for this slug
            candidates = sorted(
                [d for d in rb_output.iterdir() if d.is_dir() and slug in d.name],
                reverse=True,
            )
            for run_dir in candidates:
                rb_file = run_dir / "cd_technical_roadbook.md"
                if rb_file.exists():
                    return rb_file.read_text(encoding="utf-8")

        return ""

    # ------------------------------------------------------------------
    # Requirement Extraction (Keyword-based, Stufe 1-2)
    # ------------------------------------------------------------------

    def _extract_requirements(self, roadbook: str) -> list[dict]:
        """Extract requirements from roadbook via keyword matching."""
        requirements = []
        text_lower = roadbook.lower()

        # Platform requirements
        for platform_keywords, platform_name in _PLATFORM_KEYWORDS:
            for kw in platform_keywords:
                if kw in text_lower:
                    requirements.append({
                        "name": f"Platform: {platform_name}",
                        "category": "platform",
                        "keyword": kw,
                        "platform": platform_name.lower(),
                    })
                    break

        # Backend/Infrastructure requirements
        for keywords, req_name, category in _INFRA_KEYWORDS:
            for kw in keywords:
                if kw in text_lower:
                    requirements.append({
                        "name": req_name,
                        "category": category,
                        "keyword": kw,
                    })
                    break

        # Feature requirements (from feature lists in roadbook)
        features = self._extract_feature_list(roadbook)
        for feat in features:
            requirements.append({
                "name": f"Feature: {feat}",
                "category": "feature",
                "keyword": feat.lower(),
            })

        # Deduplicate by name
        seen = set()
        unique = []
        for r in requirements:
            if r["name"] not in seen:
                seen.add(r["name"])
                unique.append(r)

        return unique

    def _extract_feature_list(self, roadbook: str) -> list[str]:
        """Extract feature names from roadbook markdown."""
        features = []
        in_feature_section = False

        for line in roadbook.split("\n"):
            stripped = line.strip()

            # Detect feature sections
            if re.match(r"^#{1,3}\s.*(feature|funktion|screen|seite)", stripped, re.IGNORECASE):
                in_feature_section = True
                continue

            if in_feature_section and re.match(r"^#{1,3}\s", stripped):
                # New section header -- end feature section
                if not re.match(r"^#{1,3}\s.*(feature|funktion|screen)", stripped, re.IGNORECASE):
                    in_feature_section = False
                    continue

            if in_feature_section:
                # Match list items: "- Feature Name" or "1. Feature Name"
                m = re.match(r"^[-*]\s+(.+)", stripped) or re.match(r"^\d+\.\s+(.+)", stripped)
                if m:
                    feat_text = m.group(1).strip()
                    # Clean up markdown formatting
                    feat_text = re.sub(r"\*\*(.+?)\*\*", r"\1", feat_text)
                    feat_text = re.sub(r"\[(.+?)\]", r"\1", feat_text)
                    if len(feat_text) > 3 and len(feat_text) < 120:
                        features.append(feat_text)

        return features[:30]  # Limit to avoid noise

    # ------------------------------------------------------------------
    # Requirement Matching
    # ------------------------------------------------------------------

    def _match_requirement(self, req: dict) -> dict:
        """Match a single requirement against the capability sheet."""
        category = req.get("category", "")
        result = {
            "name": req["name"],
            "category": category,
            "status": "met",
            "matched_by": "",
            "gap": "",
            "alternatives": [],
        }

        if category == "platform":
            return self._match_platform(req, result)
        elif category == "backend":
            return self._match_cannot_do(req, result, "backend")
        elif category == "design":
            return self._match_cannot_do(req, result, "design")
        elif category == "infrastructure":
            return self._match_cannot_do(req, result, "infrastructure")
        elif category == "feature":
            return self._match_feature(req, result)
        else:
            result["matched_by"] = "No specific check"
            return result

    def _match_platform(self, req: dict, result: dict) -> dict:
        """Check if a platform requirement is met."""
        platform = req.get("platform", "")
        line = self.sheet.get("production_lines", {}).get(platform, {})

        if line.get("available"):
            result["status"] = "met"
            result["matched_by"] = f"{platform} line: {line.get('status', 'unknown')}"
            if not line.get("proven"):
                result["status"] = "warning"
                result["gap"] = f"{platform}_not_proven"
                result["alternatives"] = [
                    f"{platform} Line existiert, aber noch kein shipped Product"
                ]
        else:
            result["status"] = "not_met"
            result["gap"] = f"{platform}_production"
            result["matched_by"] = f"{platform} line not available"
        return result

    def _match_cannot_do(self, req: dict, result: dict, category: str) -> dict:
        """Check against cannot_do list."""
        keyword = req.get("keyword", "").lower()
        cannot_do = [c.lower() for c in self.sheet.get("cannot_do", [])]

        for item in cannot_do:
            if keyword in item or any(kw in item for kw in keyword.split()):
                result["status"] = "not_met"
                result["gap"] = req["name"]
                result["matched_by"] = f"In cannot_do list: {item}"
                result["alternatives"] = _ALTERNATIVES.get(keyword, [
                    "Feature streichen",
                    "Alternative mit verfuegbaren Capabilities suchen",
                ])
                return result

        result["status"] = "met"
        result["matched_by"] = "Not in cannot_do list"
        return result

    def _match_feature(self, req: dict, result: dict) -> dict:
        """Check a feature requirement against capabilities."""
        keyword = req.get("keyword", "").lower()

        # Check against cannot_do keywords
        for blocked_kw, cannot_label in _BLOCKED_FEATURE_KEYWORDS:
            if blocked_kw in keyword:
                result["status"] = "not_met"
                result["gap"] = cannot_label
                result["matched_by"] = f"Feature requires blocked capability: {cannot_label}"
                result["alternatives"] = _ALTERNATIVES.get(blocked_kw, [
                    "Feature streichen oder vereinfachen"
                ])
                return result

        # Check for external service requirements
        for svc_kw, svc_category in _SERVICE_KEYWORDS:
            if svc_kw in keyword:
                services = self.sheet.get("external_services", {}).get(svc_category, [])
                active = [s for s in services if s.get("status") == "active"]
                if active:
                    result["status"] = "met"
                    result["matched_by"] = f"Service available: {active[0].get('name', svc_category)}"
                else:
                    result["status"] = "warning"
                    result["gap"] = f"external_service_{svc_category}"
                    result["matched_by"] = f"Service {svc_category} registered but not active"
                return result

        # Default: assume feasible (standard app feature)
        result["status"] = "met"
        result["matched_by"] = "Standard app feature (no special capabilities required)"
        return result

    # ------------------------------------------------------------------
    # Line Assignments
    # ------------------------------------------------------------------

    def _calculate_line_assignments(self, roadbook: str) -> dict:
        """Determine which platforms are needed based on roadbook content."""
        text_lower = roadbook.lower()
        assignments = {}

        for platform_keywords, platform_name in _PLATFORM_KEYWORDS:
            platform = platform_name.lower()
            line = self.sheet.get("production_lines", {}).get(platform, {})
            for kw in platform_keywords:
                if kw in text_lower:
                    assignments[platform] = {
                        "assigned": True,
                        "line_status": line.get("status", "unavailable"),
                        "available": line.get("available", False),
                    }
                    break

        return assignments

    # ------------------------------------------------------------------
    # Recommendations
    # ------------------------------------------------------------------

    def _generate_recommendations(
        self, overall: str, requirements: list, gaps: list, assignments: dict
    ) -> list[str]:
        """Generate actionable recommendations based on the check results."""
        recs = []

        if overall == "feasible":
            recs.append("Alle Requirements erfuellt -- Produktion kann starten.")
            unproven = [
                p for p, info in assignments.items()
                if info.get("available") and not self.sheet["production_lines"].get(p, {}).get("proven")
            ]
            if unproven:
                recs.append(
                    f"Hinweis: {', '.join(unproven)} Line(s) noch nicht proven -- erhoehtes Risiko."
                )

        elif overall == "partially_feasible":
            blocking = [g for g in gaps if g["severity"] == "blocking"]
            recs.append(
                f"{len(blocking)} blockierende Luecke(n). "
                f"Optionen: Features streichen, Alternative implementieren, oder parken."
            )
            for g in blocking:
                recs.append(f"  Fehlend: {g['capability']} (benoetigt von: {', '.join(g['required_by'])})")

        elif overall == "not_feasible":
            recs.append("Zu viele fehlende Capabilities fuer Produktion.")
            recs.append("Optionen: Projekt parken, Roadbook redesignen, oder killen.")
            for g in gaps:
                if g["severity"] == "blocking":
                    recs.append(f"  Blockiert: {g['capability']}")

        return recs

    # ------------------------------------------------------------------
    # Report Persistence
    # ------------------------------------------------------------------

    def _save_report(self, slug: str, result: dict) -> str:
        """Save feasibility report as JSON."""
        _REPORTS_DIR.mkdir(parents=True, exist_ok=True)
        report_file = _REPORTS_DIR / f"{slug}_feasibility.json"
        report_file.write_text(
            json.dumps(result, indent=2, ensure_ascii=False, default=str),
            encoding="utf-8",
        )
        return str(report_file)


# ------------------------------------------------------------------
# Keyword Tables (deterministic matching)
# ------------------------------------------------------------------

_PLATFORM_KEYWORDS = [
    (["ios", "iphone", "ipad", "swift", "swiftui", "xcode"], "iOS"),
    (["android", "kotlin", "jetpack compose", "google play"], "Android"),
    (["web", "react", "next.js", "typescript", "browser", "pwa"], "Web"),
    (["unity", "c#", "game engine", "urp", "2d/3d"], "Unity"),
]

_INFRA_KEYWORDS = [
    (["backend", "server", "rest api", "cloud run", "cloud function"],
     "Backend/Server API", "backend"),
    (["firebase", "firestore", "realtime database", "cloud database"],
     "Cloud Database (Firebase)", "backend"),
    (["supabase", "postgresql", "mysql", "mongodb"],
     "Custom Database", "backend"),
    (["websocket", "realtime multiplayer", "socket.io", "echtzeit"],
     "Realtime/WebSocket", "backend"),
    (["ar ", "arkit", "arcore", "augmented reality", "vr ", "virtual reality"],
     "AR/VR Features", "infrastructure"),
    (["blockchain", "web3", "nft", "crypto wallet", "smart contract"],
     "Blockchain/Web3", "infrastructure"),
    (["video stream", "live stream", "video generation"],
     "Video Streaming/Generation", "infrastructure"),
    (["bluetooth", "ble ", "nfc", "custom camera pipeline"],
     "Native Hardware (BLE/NFC)", "infrastructure"),
    (["gps", "location service", "geofencing", "maps api"],
     "GPS/Location", "infrastructure"),
    (["payment gateway", "stripe", "paypal"],
     "Payment Processing (non-IAP)", "infrastructure"),
    (["machine learning", "ml model", "tensorflow", "pytorch", "core ml training"],
     "ML Model Training", "infrastructure"),
]

_BLOCKED_FEATURE_KEYWORDS = [
    ("backend", "backend_api"),
    ("server api", "backend_api"),
    ("cloud run", "backend_api"),
    ("websocket", "realtime_multiplayer"),
    ("multiplayer", "realtime_multiplayer"),
    ("arkit", "ar_vr"),
    ("arcore", "ar_vr"),
    ("augmented reality", "ar_vr"),
    ("virtual reality", "ar_vr"),
    ("blockchain", "blockchain_web3"),
    ("nft", "blockchain_web3"),
    ("video generation", "video_generation"),
    ("live stream", "video_generation"),
    ("bluetooth le", "native_hardware"),
    ("gps tracking", "gps_location"),
    ("geofencing", "gps_location"),
]

_SERVICE_KEYWORDS = [
    ("text-to-speech", "sound"),
    ("tts", "sound"),
    ("voice", "sound"),
    ("sound effect", "sound"),
    ("image generat", "image"),
    ("ai image", "image"),
    ("illustration", "image"),
    ("web search", "search"),
    ("research", "search"),
]

_ALTERNATIVES = {
    "backend": [
        "Offline-First mit lokalem Storage (UserDefaults/Room/localStorage)",
        "Firebase als BaaS nutzen (wenn in Capability Sheet)",
        "Feature streichen",
    ],
    "server api": [
        "Offline-First mit lokalem Storage",
        "Feature streichen",
    ],
    "websocket": [
        "Asynchrones Messaging statt Echtzeit",
        "Feature streichen",
    ],
    "multiplayer": [
        "Lokaler Singleplayer-Modus",
        "Turn-based statt Realtime",
        "Feature streichen",
    ],
    "arkit": ["Feature streichen -- keine AR-Capability in der Factory"],
    "arcore": ["Feature streichen -- keine AR-Capability in der Factory"],
    "blockchain": ["Feature streichen -- keine Web3-Capability"],
    "gps tracking": ["Feature streichen oder manuelle Ortseingabe statt GPS"],
    "video generation": ["Statische Bilder statt Video verwenden"],
}

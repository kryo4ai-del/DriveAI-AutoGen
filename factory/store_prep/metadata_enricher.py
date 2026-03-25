"""DriveAI Factory — Metadata Enricher.

Loads Pre-Production, Market Strategy, and Design Vision reports for a project
and extracts structured context for the PlatformMetadataAdapter.

All extraction is deterministic (regex/text parsing, no LLM).
Uses project_registry to find report directories, with glob fallback.
"""

import re
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


def _clean_section(raw: str) -> str:
    """Strip separator lines and whitespace from extracted section text."""
    text = raw.strip()
    # Remove separator lines (──────, ----, ====)
    text = re.sub(r"^[\u2500\-=]{4,}$", "", text, flags=re.MULTILINE)
    return text.strip()


# ---------------------------------------------------------------------------
# Report file names per phase
# ---------------------------------------------------------------------------

_PHASE1_FILES = {
    "concept_brief": "concept_brief.md",
    "audience_profile": "audience_profile.md",
    "competitive_report": "competitive_report.md",
    "risk_assessment": "risk_assessment.md",
}

_PHASE2_FILES = {
    "platform_strategy": "platform_strategy.md",
    "monetization_report": "monetization_report.md",
    "marketing_strategy": "marketing_strategy.md",
}

_PHASE45_FILES = {
    "design_vision": "design_vision_document.md",
    "emotion_report": "emotion_architect_report.md",
    "trend_breaker": "trend_breaker_report.md",
}


class MetadataEnricher:
    """Loads factory reports and extracts enrichment context.

    Usage:
        enricher = MetadataEnricher("echomatch")
        context = enricher.enrich()
        # context = {
        #   "audience": {"raw": "...", "segments": [...]},
        #   "usp": {"raw": "...", "one_liner": "..."},
        #   "competitors": {"raw": "...", "names": [...]},
        #   "positioning": {"raw": "..."},
        #   "monetization": {"raw": "...", "model": "..."},
        #   "marketing_hooks": {"raw": "...", "channels": [...]},
        #   "design_language": {"raw": "...", "emotion": "..."},
        # }
    """

    def __init__(self, project_name: str) -> None:
        self.project_name = project_name
        self._registry_data: dict | None = None

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def enrich(self) -> dict:
        """Extract enrichment context from all available reports.

        Returns a dict with keys: audience, usp, competitors, positioning,
        monetization, marketing_hooks, design_language.
        Each value is a dict with at minimum a "raw" key (str).
        Missing reports produce empty strings — never raises.
        """
        result = {}

        # Phase 1 — Pre-Production
        pp = self._extract_from_pre_production()
        result["audience"] = pp.get("audience", {"raw": ""})
        result["usp"] = pp.get("usp", {"raw": ""})
        result["competitors"] = pp.get("competitors", {"raw": ""})

        # Phase 2 — Market Strategy
        ms = self._extract_from_market_strategy()
        result["positioning"] = ms.get("positioning", {"raw": ""})
        result["monetization"] = ms.get("monetization", {"raw": ""})
        result["marketing_hooks"] = ms.get("marketing_hooks", {"raw": ""})

        # Phase 4.5 — Design Vision
        dv = self._extract_from_design_vision()
        result["design_language"] = dv.get("design_language", {"raw": ""})

        return result

    # ------------------------------------------------------------------
    # Phase 1: Pre-Production
    # ------------------------------------------------------------------

    def _extract_from_pre_production(self) -> dict:
        """Extract audience, USP, competitors from Phase 1 reports."""
        result = {}
        report_dir = self._find_report_dir("phase1")

        # --- Audience (from audience_profile.md) ---
        audience_text = self._safe_read(report_dir, _PHASE1_FILES["audience_profile"])
        audience_raw = self._extract_section(audience_text, "Primäre Zielgruppe")
        segments = self._extract_table_column(audience_text, 0)  # First column of any table
        result["audience"] = {
            "raw": audience_raw,
            "segments": segments,
            "spending": self._extract_section(audience_text, "Ausgabeverhalten"),
            "session": self._extract_section(audience_text, "Session-Verhalten"),
        }

        # --- USP (from concept_brief.md) ---
        concept_text = self._safe_read(report_dir, _PHASE1_FILES["concept_brief"])
        one_liner = self._extract_section(concept_text, "One-Liner")
        core_loop = self._extract_section(concept_text, "Kern-Mechanik & Core Loop")
        result["usp"] = {
            "raw": one_liner or core_loop,
            "one_liner": one_liner,
            "core_loop": core_loop,
        }

        # --- Competitors (from competitive_report.md) ---
        comp_text = self._safe_read(report_dir, _PHASE1_FILES["competitive_report"])
        comp_raw = self._extract_section(comp_text, "Detailanalyse pro Wettbewerber")
        if not comp_raw:
            comp_raw = self._extract_section(comp_text, "Wettbewerber")
        names = self._extract_competitor_names(comp_text)
        result["competitors"] = {
            "raw": comp_raw,
            "names": names,
        }

        return result

    # ------------------------------------------------------------------
    # Phase 2: Market Strategy
    # ------------------------------------------------------------------

    def _extract_from_market_strategy(self) -> dict:
        """Extract positioning, monetization, marketing hooks from Phase 2."""
        result = {}
        report_dir = self._find_report_dir("kapitel3")

        # --- Positioning (from platform_strategy.md) ---
        plat_text = self._safe_read(report_dir, _PHASE2_FILES["platform_strategy"])
        plat_raw = self._extract_section(plat_text, "Plattform-Bewertung")
        if not plat_raw:
            plat_raw = self._extract_section(plat_text, "Zielgruppen-Plattform-Analyse")
        result["positioning"] = {"raw": plat_raw}

        # --- Monetization (from monetization_report.md) ---
        mon_text = self._safe_read(report_dir, _PHASE2_FILES["monetization_report"])
        mon_raw = self._extract_section(mon_text, "Modell-Analyse")
        if not mon_raw:
            mon_raw = self._extract_section(mon_text, "Empfohlenes Modell")
        model = self._detect_recommended_model(mon_text)
        result["monetization"] = {
            "raw": mon_raw,
            "model": model,
        }

        # --- Marketing Hooks (from marketing_strategy.md) ---
        mkt_text = self._safe_read(report_dir, _PHASE2_FILES["marketing_strategy"])
        mkt_raw = self._extract_section(mkt_text, "Marketing-Kanal-Analyse")
        if not mkt_raw:
            mkt_raw = self._extract_section(mkt_text, "Effektivste Kanäle für die Zielgruppe")
        channels = self._extract_marketing_channels(mkt_text)
        result["marketing_hooks"] = {
            "raw": mkt_raw,
            "channels": channels,
        }

        return result

    # ------------------------------------------------------------------
    # Phase 4.5: Design Vision
    # ------------------------------------------------------------------

    def _extract_from_design_vision(self) -> dict:
        """Extract design language from Phase 4.5 reports."""
        result = {}
        report_dir = self._find_report_dir("kapitel45")

        # --- Design Language (from design_vision_document.md) ---
        dv_text = self._safe_read(report_dir, _PHASE45_FILES["design_vision"])
        emotion = self._extract_section(dv_text, "Emotionale Leitlinie")
        if not emotion:
            emotion = self._extract_section(dv_text, "Design-Briefing")
        diff_points = self._extract_section(dv_text, "Differenzierungspunkte")
        result["design_language"] = {
            "raw": emotion,
            "emotion": emotion,
            "differentiation": diff_points,
        }

        return result

    # ------------------------------------------------------------------
    # Report directory resolution
    # ------------------------------------------------------------------

    def _find_report_dir(self, phase: str) -> Path | None:
        """Find the report output directory for a phase.

        Strategy:
          1. project_registry → chapters[phase].output_dir
          2. Glob fallback: factory/{phase_dir}/output/*_{slug}/
        """
        # Try project registry
        reg = self._get_registry()
        if reg:
            output_dir = (
                reg.get("chapters", {}).get(phase, {}).get("output_dir")
            )
            if output_dir:
                p = _ROOT / output_dir if not Path(output_dir).is_absolute() else Path(output_dir)
                if p.is_dir():
                    return p

        # Glob fallback
        phase_dirs = {
            "phase1": "pre_production",
            "kapitel3": "market_strategy",
            "kapitel45": "design_vision",
        }
        factory_subdir = phase_dirs.get(phase)
        if not factory_subdir:
            return None

        search_dir = _ROOT / "factory" / factory_subdir / "output"
        if not search_dir.is_dir():
            return None

        slug = self.project_name.lower().replace("-", "_").replace(" ", "_")
        candidates = sorted(search_dir.glob(f"*_{slug}*"), reverse=True)
        if candidates:
            # Return the latest (highest run number)
            return candidates[0]

        return None

    def _get_registry(self) -> dict | None:
        """Lazy-load project registry data."""
        if self._registry_data is not None:
            return self._registry_data
        try:
            from factory.project_registry import get_project
            self._registry_data = get_project(self.project_name) or {}
        except ImportError:
            self._registry_data = {}
        return self._registry_data

    # ------------------------------------------------------------------
    # Text extraction helpers
    # ------------------------------------------------------------------

    @staticmethod
    def _safe_read(report_dir: Path | None, filename: str) -> str:
        """Read a report file. Returns empty string on any failure."""
        if not report_dir:
            return ""
        path = report_dir / filename
        try:
            return path.read_text(encoding="utf-8")
        except (FileNotFoundError, PermissionError, OSError):
            return ""

    @staticmethod
    def _extract_section(text: str, header: str) -> str:
        """Extract content under a section header.

        Supports multiple header formats found in factory reports:
          - Markdown: ## Header or ### Header
          - Arrow:    ▶ Header
          - Numbered: 2. Header or 2. Header (Tabelle)
          - Box:      ──── \\n Header \\n ────

        Returns text from the header line until the next section of same
        or higher level, or end of file.
        """
        if not text or not header:
            return ""

        escaped = re.escape(header)

        # Try markdown headers first (## or ###)
        md_match = re.search(
            rf"^(#{{2,3}})\s+.*{escaped}.*$",
            text, re.MULTILINE | re.IGNORECASE,
        )
        if md_match:
            level = len(md_match.group(1))
            start = md_match.end()
            next_h = re.search(rf"^#{{{1},{level}}}\s+", text[start:], re.MULTILINE)
            end = start + next_h.start() if next_h else len(text)
            return _clean_section(text[start:end])

        # Try arrow format: ▶ Header
        arrow_match = re.search(
            rf"^[▶►>]\s*{escaped}",
            text, re.MULTILINE | re.IGNORECASE,
        )
        if arrow_match:
            start = arrow_match.end()
            # Next section = next arrow or separator line
            next_s = re.search(r"^(?:[▶►>]\s|\u2500{4,})", text[start:], re.MULTILINE)
            end = start + next_s.start() if next_s else len(text)
            return _clean_section(text[start:end])

        # Try numbered format: N. Header
        num_match = re.search(
            rf"^\d+\.\s+{escaped}",
            text, re.MULTILINE | re.IGNORECASE,
        )
        if num_match:
            start = num_match.end()
            # Next section = next numbered header only (not separators,
            # since separators appear between header and content)
            next_s = re.search(r"^\d+\.\s+\S", text[start:], re.MULTILINE)
            end = start + next_s.start() if next_s else len(text)
            return _clean_section(text[start:end])

        return ""

    @staticmethod
    def _extract_table_column(text: str, col_index: int) -> list[str]:
        """Extract values from a specific column of the first markdown table found."""
        if not text:
            return []

        values = []
        in_table = False
        header_skipped = False

        for line in text.split("\n"):
            stripped = line.strip()
            if stripped.startswith("|") and stripped.endswith("|"):
                if not in_table:
                    in_table = True
                    continue  # Skip header row
                if not header_skipped:
                    # Skip separator row (|---|---|)
                    if re.match(r"^\|[\s\-:|]+\|$", stripped):
                        header_skipped = True
                        continue
                    header_skipped = True

                cells = [c.strip() for c in stripped.split("|")]
                # Remove empty strings from leading/trailing pipes
                cells = [c for c in cells if c]
                if col_index < len(cells):
                    val = cells[col_index].strip()
                    if val and not re.match(r"^-+$", val):
                        values.append(val)
            else:
                if in_table:
                    break  # End of table

        return values

    @staticmethod
    def _extract_competitor_names(text: str) -> list[str]:
        """Extract competitor app/product names from competitive report."""
        if not text:
            return []

        names = []

        # Pattern 1: Table rows with app names (first data column)
        for match in re.finditer(r"^\|\s*(\S[^|]+?)\s*\|", text, re.MULTILINE):
            name = match.group(1).strip().strip("*")
            # Skip header/separator rows
            if name and len(name) < 50 and not re.match(r"^[-:]+$", name) and name.lower() != "app":
                names.append(name)

        # Pattern 2: ### headers with competitor names
        if not names:
            for match in re.finditer(r"^###\s+(?:\d+\.\s+)?(.+?)(?:\s*[-—]|$)", text, re.MULTILINE):
                name = match.group(1).strip().strip("*")
                if name and len(name) < 50:
                    names.append(name)

        # Pattern 3: Letter-prefixed names (A. Name, B. Name)
        if not names:
            for match in re.finditer(r"^[A-Z]\.\s+(.+?)(?:\s{2,}|$)", text, re.MULTILINE):
                name = match.group(1).strip()
                if name and len(name) < 50:
                    names.append(name)

        return names

    @staticmethod
    def _detect_recommended_model(text: str) -> str:
        """Detect which monetization model is recommended."""
        if not text:
            return ""

        # Look for "Empfohlenes Modell" section with model name on next line
        rec_match = re.search(
            r"(?:Empfohlenes Modell|Recommendation)\s*\n+\s*(?:[-•]\s*)?(.+)",
            text, re.IGNORECASE,
        )
        if rec_match:
            return rec_match.group(1).strip().strip("*").strip()

        # Look for explicit recommendation markers
        patterns = [
            (r"(?:empfohl|recommend|favorisiert|bevorzugt).*?(Free-to-Play|Subscription|Abo|Hybrid|Premium|Freemium)", ""),
            (r"Bewertung.*?(\d+)/10", "score"),
        ]

        # Try direct recommendation
        for pattern, mode in patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match and mode == "":
                return match.group(1).strip()

        # Fallback: find the model with highest score
        model_scores = {}
        current_model = ""
        for line in text.split("\n"):
            model_match = re.match(r"^###\s+Modell\s+\d+:\s+(.+)", line)
            if model_match:
                current_model = model_match.group(1).strip()
            score_match = re.search(r"Bewertung.*?(\d+)\s*/\s*10", line, re.IGNORECASE)
            if score_match and current_model:
                model_scores[current_model] = int(score_match.group(1))

        if model_scores:
            return max(model_scores, key=model_scores.get)

        return ""

    @staticmethod
    def _extract_marketing_channels(text: str) -> list[str]:
        """Extract marketing channel names from marketing strategy report."""
        if not text:
            return []

        channels = []
        # Pattern: ### Channel Name or bold channel names
        for match in re.finditer(
            r"(?:^###\s+(.+)|^\*\*(.+?)\*\*\s*[-—:])",
            text,
            re.MULTILINE,
        ):
            name = (match.group(1) or match.group(2) or "").strip()
            # Filter out generic headers
            if name and len(name) < 60 and "analyse" not in name.lower():
                channels.append(name)

        return channels[:10]  # Cap at 10

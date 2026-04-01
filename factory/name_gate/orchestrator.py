"""Name Gate Orchestrator (NGO-01) — Pre-Pipeline Name Validation.

Validates project names for availability across domains, stores,
social media, trademark registries, brand fit, and ASO before
any project folders are created.

Real agent calls: MKT-04 (NamingAgent), MKT-01 (BrandGuardian),
MKT-05 (ASOAgent).  Falls back to deterministic stubs on failure.
"""

from __future__ import annotations

import hashlib
import json
import os
import re
from datetime import datetime, timezone
from pathlib import Path
from typing import List, Optional

from factory.name_gate.config import (
    AGENT_ID,
    AGENT_NAME,
    MAX_ALTERNATIVES,
    MAX_ITERATIONS,
)
from factory.name_gate.models import (
    ASOPreCheckResult,
    BrandFitResult,
    DomainCheckResult,
    NameCheckResult,
    NameGateReport,
    SocialMediaCheckResult,
    StoreCheckResult,
    TrademarkCheckResult,
)
from factory.name_gate.scoring import (
    calculate_total_score,
    detect_hard_blockers,
    detect_soft_blockers,
    determine_ampel,
)

_PREFIX = "[NGO-01]"
_PROJECT_ROOT = Path(__file__).resolve().parents[2]  # DriveAI-AutoGen/


def _log(msg: str) -> None:
    import sys as _sys
    ts = datetime.now(timezone.utc).strftime("%H:%M:%S")
    print(f"{_PREFIX} [{ts}] {msg}", file=_sys.stderr)


def _name_hash(name: str) -> int:
    """Deterministic hash for consistent mock data per name."""
    return int(hashlib.md5(name.lower().encode()).hexdigest(), 16)


class NameGateOrchestrator:
    """Pre-Pipeline Name Validation Gate.

    Checks a project name for availability across 6 dimensions
    and produces a scored NameGateReport with Ampel rating.

    Args:
        profile: LLM profile for agent calls (dev/standard/premium).
        use_stubs: Force stub data (no real agent calls). For testing.
    """

    AGENT_ID = AGENT_ID

    def __init__(self, profile: str = "dev", use_stubs: bool = False) -> None:
        self.profile = profile
        self.use_stubs = use_stubs
        self.data_dir = _PROJECT_ROOT / "factory" / "name_gate" / "data"
        self.data_dir.mkdir(parents=True, exist_ok=True)

        # Lazy agent instances
        self._naming_agent = None
        self._brand_guardian = None
        self._aso_agent = None

        # Cache for MKT-04 validate_name (one call returns domain+store+social)
        self._mkt04_cache: dict = {}

    # ------------------------------------------------------------------
    # Lazy agent accessors
    # ------------------------------------------------------------------

    def _get_naming_agent(self):
        if self._naming_agent is None:
            from factory.marketing.agents.naming_agent import NamingAgent
            self._naming_agent = NamingAgent()
        return self._naming_agent

    def _get_brand_guardian(self):
        if self._brand_guardian is None:
            from factory.marketing.agents.brand_guardian import BrandGuardian
            self._brand_guardian = BrandGuardian()
        return self._brand_guardian

    def _get_aso_agent(self):
        if self._aso_agent is None:
            from factory.marketing.agents.aso_agent import ASOAgent
            self._aso_agent = ASOAgent()
        return self._aso_agent

    def _get_mkt04_validate(self, name: str) -> dict:
        """Call NamingAgent.validate_name() once per name, cache result."""
        if name not in self._mkt04_cache:
            agent = self._get_naming_agent()
            self._mkt04_cache[name] = agent.validate_name(name)
        return self._mkt04_cache[name]

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def validate_name(
        self,
        name: str,
        idea: str,
        template: str = "",
    ) -> NameGateReport:
        """Run full 6-dimension validation for *name*.

        Returns a NameGateReport with score, Ampel, blockers, and
        recommendations.
        """
        _log(f"Validating name: '{name}' (idea: '{idea}')")

        # 1. Run all checks
        checks = NameCheckResult()

        _log("  [1/6] Domain check ...")
        checks.domain = self._call_mkt04_validate_domain(name)

        _log("  [2/6] App Store check ...")
        checks.store = self._call_mkt04_validate_store(name)

        _log("  [3/6] Social Media check ...")
        checks.social_media = self._call_mkt04_validate_social(name)

        _log("  [4/6] Trademark check ...")
        checks.trademark = self._call_mkt04_trademark(name)

        _log("  [5/6] Brand Fit evaluation ...")
        checks.brand_fit = self._call_mkt01_brand_fit(name, idea)

        _log("  [6/6] ASO pre-check ...")
        checks.aso = self._call_mkt05_aso_precheck(name)

        # 2. Score + Ampel
        total = calculate_total_score(checks)
        ampel = determine_ampel(total, checks)
        hard = detect_hard_blockers(checks)
        soft = detect_soft_blockers(checks)

        # 3. Recommendations
        recs = self._generate_recommendations(checks, hard, soft)

        # 4. Build report
        report = NameGateReport(
            report_id=f"NGR-{_name_hash(name) % 100000:05d}",
            name=name,
            total_score=total,
            ampel=ampel,
            checks=checks,
            hard_blockers=hard,
            soft_blockers=soft,
            recommendations=recs,
            alternatives=[],
            iteration=1,
            timestamp=datetime.now(timezone.utc).isoformat(),
        )

        _log(f"  Result: {ampel} ({total}/100) | "
             f"Hard: {len(hard)} | Soft: {len(soft)}")

        # 5. Persist
        self._save_report(name, report)

        return report

    def request_alternatives(
        self,
        idea: str,
        template: str = "",
        rejected: Optional[List[str]] = None,
    ) -> List[NameGateReport]:
        """Generate and validate alternative names.

        Returns up to MAX_ALTERNATIVES validated NameGateReports.
        """
        rejected = rejected or []
        _log(f"Generating alternatives for idea: '{idea}' "
             f"(rejected: {rejected})")

        candidates = self._stub_generate_alternatives(idea, rejected)

        reports: List[NameGateReport] = []
        for alt_name in candidates[:MAX_ALTERNATIVES]:
            report = self.validate_name(alt_name, idea, template)
            reports.append(report)

        # Sort by score descending
        reports.sort(key=lambda r: r.total_score, reverse=True)

        _log(f"  {len(reports)} alternatives validated, "
             f"best: {reports[0].name} ({reports[0].total_score}/100)"
             if reports else "  No alternatives generated")

        return reports

    def lock_name(self, name: str, report: NameGateReport) -> dict:
        """Lock a validated name for project creation.

        Writes the report to projects/{name}/name_gate_report.json
        and registers the name in the project registry.
        """
        _log(f"Locking name: '{name}' (score: {report.total_score})")

        # Create project directory
        project_dir = _PROJECT_ROOT / "projects" / name
        project_dir.mkdir(parents=True, exist_ok=True)

        # Save report
        report_path = project_dir / "name_gate_report.json"
        with open(report_path, "w", encoding="utf-8") as f:
            json.dump(report.to_dict(), f, indent=2, ensure_ascii=False)

        _log(f"  Report saved: {report_path}")

        result = {
            "project_id": name.lower().replace(" ", "_"),
            "status": "name_locked",
            "locked": True,
            "report_path": str(report_path),
            "locked_at": datetime.now(timezone.utc).isoformat(),
        }

        _log(f"  Name locked: {result['project_id']}")
        return result

    def lock_from_saved(self, name: str) -> dict:
        """Lock a name using its previously saved validation report."""
        slug = re.sub(r"[^a-z0-9_]", "", name.lower().replace(" ", "_"))
        report_path = self.data_dir / f"{slug}_report.json"
        if not report_path.exists():
            return {"error": f"No saved report for '{name}'. Run validate first.", "locked": False}

        with open(report_path, "r", encoding="utf-8") as f:
            report_data = json.load(f)

        project_dir = _PROJECT_ROOT / "projects" / name
        project_dir.mkdir(parents=True, exist_ok=True)
        lock_path = project_dir / "name_gate_report.json"
        with open(lock_path, "w", encoding="utf-8") as f:
            json.dump(report_data, f, indent=2, ensure_ascii=False)

        _log(f"Name locked from saved report: '{name}' -> {lock_path}")
        return {
            "project_id": name.lower().replace(" ", "_"),
            "name": name,
            "status": "name_locked",
            "locked": True,
            "total_score": report_data.get("total_score", 0),
            "ampel": report_data.get("ampel", "?"),
            "report_path": str(lock_path),
            "locked_at": datetime.now(timezone.utc).isoformat(),
        }

    def get_status(self, name: str) -> Optional[dict]:
        """Check if a name is already locked."""
        report_path = _PROJECT_ROOT / "projects" / name / "name_gate_report.json"
        if not report_path.exists():
            return None
        with open(report_path, "r", encoding="utf-8") as f:
            data = json.load(f)
        return {
            "name": name,
            "locked": True,
            "total_score": data.get("total_score", 0),
            "ampel": data.get("ampel", "?"),
            "report_path": str(report_path),
        }

    # ------------------------------------------------------------------
    # Generate & Validate (auto-name flow)
    # ------------------------------------------------------------------

    def generate_and_validate(
        self,
        idea: str,
        template: str = "",
        count: int = 3,
    ) -> dict:
        """Generate name suggestions and validate each through the full gate.

        Two-phase approach to minimize LLM calls:
          Phase 1 — Quick-scan all candidates (4 fast checks: domain, store,
                    social, trademark — no LLM calls).
          Phase 2 — Full 6-check validation on the top *count* candidates
                    (adds brand_fit LLM + ASO LLM).

        In stubs mode, all checks are deterministic and both phases run
        identically fast.

        Args:
            idea: App idea description.
            template: Optional project template type.
            count: Number of top suggestions to return (default 3).

        Returns:
            Dict with idea, generated_count, validated_count, suggestions
            list (each with rank + full report), and timestamp.
        """
        generate_count = count * 2  # request extra for buffer
        _log(f"Generating {generate_count} name candidates for: '{idea}'")

        # 1. Generate names via MKT-04 (or stubs)
        if self.use_stubs:
            candidates = self._stub_generate_names(idea, generate_count)
        else:
            try:
                agent = self._get_naming_agent()
                candidates = agent.generate_name_suggestions(idea, generate_count)
                if not candidates:
                    _log("  MKT-04 returned empty — using stub fallback")
                    candidates = self._stub_generate_names(idea, generate_count)
            except Exception as e:
                _log(f"  MKT-04 generation failed ({e}) — using stub fallback")
                candidates = self._stub_generate_names(idea, generate_count)

        _log(f"  Got {len(candidates)} candidates: {candidates}")

        # 2. Phase 1: Quick-scan (4 checks, no LLM)
        _log(f"  Phase 1: Quick-scan {len(candidates)} candidates "
             "(domain + store + social + trademark)...")
        quick_results: list[tuple[str, int, bool]] = []  # (name, score, has_hard_blocker)
        for i, name in enumerate(candidates):
            _log(f"    [{i + 1}/{len(candidates)}] Quick-scan: '{name}'")
            try:
                qs = self._quick_scan(name)
                quick_results.append((name, qs["score"], qs["hard_blocker"]))
                _log(f"      Score: {qs['score']}/85 | Hard: {qs['hard_blocker']}")
            except Exception as e:
                _log(f"      Quick-scan failed for '{name}': {e}")
                quick_results.append((name, 0, True))

        # Sort: no hard blockers first, then by score desc
        quick_results.sort(key=lambda x: (-int(x[2]), -x[1]))
        top_names = [name for name, _, _ in quick_results[:count]]

        _log(f"  Phase 2: Full validation top {count}: {top_names}")

        # 3. Phase 2: Full 6-check validation on top N only
        reports: List[NameGateReport] = []
        for i, name in enumerate(top_names):
            _log(f"    [{i + 1}/{len(top_names)}] Full validate: '{name}'")
            try:
                report = self.validate_name(name, idea, template)
                reports.append(report)
            except Exception as e:
                _log(f"      Validation failed for '{name}': {e}")

        # 4. Sort by score descending
        reports.sort(key=lambda r: r.total_score, reverse=True)

        suggestions = [
            {"rank": i + 1, "report": r.to_dict()}
            for i, r in enumerate(reports)
        ]

        _log(f"  Result: {len(reports)} suggestions — "
             + ", ".join(f"{s['report']['name']}({s['report']['total_score']})"
                         for s in suggestions))

        return {
            "idea": idea,
            "generated_count": len(candidates),
            "validated_count": len(reports),
            "suggestions": suggestions,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    def _quick_scan(self, name: str) -> dict:
        """Run fast checks only (domain, store, social, trademark).

        No LLM calls — only network/cache lookups + stubs.
        Returns partial score (max 85) and hard_blocker flag.
        """
        domain = self._call_mkt04_validate_domain(name)
        store = self._call_mkt04_validate_store(name)
        social = self._call_mkt04_validate_social(name)
        trademark = self._call_mkt04_trademark(name)

        # Partial weighted score (domain=25, store=25, social=10, trademark=25)
        partial = (
            domain.score * 25
            + store.score * 25
            + social.score * 10
            + trademark.score * 25
        )
        score = round(partial / 100)

        hard = trademark.hard_blocker
        if not store.apple and not store.google:
            hard = True
        if not domain.com and not domain.de and not domain.app:
            hard = True

        return {"score": score, "hard_blocker": hard}

    def _stub_generate_names(self, idea: str, count: int) -> List[str]:
        """Deterministic stub name generation for testing."""
        words = [w for w in idea.lower().split() if len(w) > 3]
        base = words[0].capitalize() if words else "App"
        suffixes = ["ly", "ify", "io", "ix", "ai", "go", "iq", "ex"]
        return [f"{base}{s}" for s in suffixes[:count]]

    # ------------------------------------------------------------------
    # Real agent calls (with stub fallback)
    # ------------------------------------------------------------------

    def _call_mkt04_validate_domain(self, name: str) -> DomainCheckResult:
        """Check domain availability via MKT-04 NamingAgent.validate_name().

        Real agent returns score 0-25; normalized to 0-100 for scoring.
        Falls back to stub on failure.
        """
        if self.use_stubs:
            return self._stub_mkt04_validate_domain(name)
        try:
            vr = self._get_mkt04_validate(name)
            d = vr["domain"]
            _log("    Domain: real MKT-04 agent")
            return DomainCheckResult(
                com=bool(d.get("com", False)),
                de=bool(d.get("de", False)),
                app=bool(d.get("app", False)),
                io=bool(d.get("io", False)),
                score=min(100, round(d.get("score", 0) * 100 / 25)),
                details={**d.get("details", {}), "source": "MKT-04"},
            )
        except Exception as e:
            _log(f"    Domain: MKT-04 failed ({e}) - stub fallback")
            return self._stub_mkt04_validate_domain(name)

    def _call_mkt04_validate_store(self, name: str) -> StoreCheckResult:
        """Check App Store availability via MKT-04 NamingAgent.validate_name().

        Real agent returns score 0-25; normalized to 0-100 for scoring.
        """
        if self.use_stubs:
            return self._stub_mkt04_validate_store(name)
        try:
            vr = self._get_mkt04_validate(name)
            s = vr["app_store"]
            _log("    Store: real MKT-04 agent")
            return StoreCheckResult(
                apple=bool(s.get("apple", False)),
                google=bool(s.get("google", False)),
                score=min(100, round(s.get("score", 0) * 100 / 25)),
                details={**s.get("details", {}), "source": "MKT-04"},
            )
        except Exception as e:
            _log(f"    Store: MKT-04 failed ({e}) - stub fallback")
            return self._stub_mkt04_validate_store(name)

    def _call_mkt04_validate_social(self, name: str) -> SocialMediaCheckResult:
        """Check social media handles via MKT-04 NamingAgent.validate_name().

        Real agent returns score 0-10; normalized to 0-100 for scoring.
        """
        if self.use_stubs:
            return self._stub_mkt04_validate_social(name)
        try:
            vr = self._get_mkt04_validate(name)
            sm = vr["social_media"]
            _log("    Social: real MKT-04 agent")
            return SocialMediaCheckResult(
                instagram=bool(sm.get("instagram", False)),
                tiktok=bool(sm.get("tiktok", False)),
                x=bool(sm.get("x", False)),
                youtube=bool(sm.get("youtube", False)),
                linkedin=bool(sm.get("linkedin", False)),
                score=min(100, round(sm.get("score", 0) * 100 / 10)),
                details={**sm.get("details", {}), "source": "MKT-04"},
            )
        except Exception as e:
            _log(f"    Social: MKT-04 failed ({e}) - stub fallback")
            return self._stub_mkt04_validate_social(name)

    def _call_mkt04_trademark(self, name: str) -> TrademarkCheckResult:
        """Check trademark registries via MKT-04 NamingAgent.check_trademark().

        Real agent returns score 0-25; normalized to 0-100 for scoring.
        Note: agent's dpma.found=True means conflict, model's dpma=True means CLEAR.
        """
        if self.use_stubs:
            return self._stub_mkt04_trademark(name)
        try:
            agent = self._get_naming_agent()
            tr = agent.check_trademark(name)
            _log("    Trademark: real MKT-04 agent")

            # Invert: agent found=True → model clear=False
            dpma_info = tr.get("dpma", {})
            euipo_info = tr.get("euipo", {})
            dpma_clear = not dpma_info.get("found", False)
            euipo_clear = not euipo_info.get("found", False)

            return TrademarkCheckResult(
                dpma=dpma_clear,
                euipo=euipo_clear,
                score=min(100, round(tr.get("score", 0) * 100 / 25)),
                hard_blocker=bool(tr.get("hard_blocker", False)),
            )
        except Exception as e:
            _log(f"    Trademark: MKT-04 failed ({e}) - stub fallback")
            return self._stub_mkt04_trademark(name)

    def _call_mkt01_brand_fit(self, name: str, idea: str) -> BrandFitResult:
        """Evaluate brand fit via MKT-01 BrandGuardian.evaluate_name_brand_fit().

        Real agent returns scores 1-10; multiplied by 10 for 0-100 scale.
        """
        if self.use_stubs:
            return self._stub_mkt01_brand_fit(name, idea)
        try:
            agent = self._get_brand_guardian()
            bf = agent.evaluate_name_brand_fit(name, idea)
            _log("    Brand Fit: real MKT-01 agent")
            return BrandFitResult(
                tonality=bf.get("tonality", 5) * 10,
                pronounceability=bf.get("pronounceability", 5) * 10,
                memorability=bf.get("memorability", 5) * 10,
                confusion_risk=bf.get("confusion_risk", 5) * 10,
                international=bf.get("international", 5) * 10,
                score=min(100, bf.get("score", 5) * 10),
                recommendation=str(bf.get("recommendation", "")),
            )
        except Exception as e:
            _log(f"    Brand Fit: MKT-01 failed ({e}) - stub fallback")
            return self._stub_mkt01_brand_fit(name, idea)

    def _call_mkt05_aso_precheck(self, name: str) -> ASOPreCheckResult:
        """ASO keyword pre-check via MKT-05 ASOAgent.pre_check_aso().

        Real agent returns score 0-5; multiplied by 20 for 0-100 scale.
        """
        if self.use_stubs:
            return self._stub_mkt05_aso_precheck(name)
        try:
            agent = self._get_aso_agent()
            aso = agent.pre_check_aso(name)
            _log("    ASO: real MKT-05 agent")
            return ASOPreCheckResult(
                keyword_saturation=str(aso.get("keyword_saturation", "medium")),
                dominant_competitors=list(aso.get("dominant_competitors", [])),
                score=min(100, aso.get("score", 3) * 20),
            )
        except Exception as e:
            _log(f"    ASO: MKT-05 failed ({e}) - stub fallback")
            return self._stub_mkt05_aso_precheck(name)

    # ------------------------------------------------------------------
    # STUB fallbacks (deterministic mock data)
    # ------------------------------------------------------------------

    def _stub_mkt04_validate_domain(self, name: str) -> DomainCheckResult:
        """Deterministic domain check stub."""
        h = _name_hash(name)
        slug = re.sub(r"[^a-z0-9]", "", name.lower())

        com_free = (h % 7) != 0
        de_free = (h % 5) != 0
        app_free = (h % 3) != 0
        io_free = (h % 4) != 0

        available_count = sum([com_free, de_free, app_free, io_free])
        score = round(available_count / 4 * 100)

        return DomainCheckResult(
            com=com_free,
            de=de_free,
            app=app_free,
            io=io_free,
            score=score,
            details={
                "checked": [f"{slug}.com", f"{slug}.de",
                            f"{slug}.app", f"{slug}.io"],
                "source": "STUB",
            },
        )

    def _stub_mkt04_validate_store(self, name: str) -> StoreCheckResult:
        """Deterministic store check stub."""
        h = _name_hash(name)
        apple_free = (h % 6) != 0
        google_free = (h % 8) != 0

        available_count = sum([apple_free, google_free])
        score = round(available_count / 2 * 100)

        return StoreCheckResult(
            apple=apple_free,
            google=google_free,
            score=score,
            details={
                "apple_search": f"'{name}' on App Store",
                "google_search": f"'{name}' on Play Store",
                "source": "STUB",
            },
        )

    def _stub_mkt04_validate_social(self, name: str) -> SocialMediaCheckResult:
        """Deterministic social media check stub."""
        h = _name_hash(name)
        handle = re.sub(r"[^a-z0-9]", "", name.lower())

        ig = (h % 4) != 0
        tt = (h % 3) != 0
        x_ = (h % 5) != 0
        yt = (h % 6) != 0
        li = (h % 7) != 0

        available_count = sum([ig, tt, x_, yt, li])
        score = round(available_count / 5 * 100)

        return SocialMediaCheckResult(
            instagram=ig,
            tiktok=tt,
            x=x_,
            youtube=yt,
            linkedin=li,
            score=score,
            details={
                "handle_checked": f"@{handle}",
                "source": "STUB",
            },
        )

    def _stub_mkt04_trademark(self, name: str) -> TrademarkCheckResult:
        """Deterministic trademark check stub."""
        h = _name_hash(name)
        dpma_clear = (h % 11) != 0
        euipo_clear = (h % 13) != 0
        hard_blocker = not dpma_clear or not euipo_clear

        score = 100 if (dpma_clear and euipo_clear) else (50 if (dpma_clear or euipo_clear) else 0)

        return TrademarkCheckResult(
            dpma=dpma_clear,
            euipo=euipo_clear,
            score=score,
            hard_blocker=hard_blocker,
        )

    def _stub_mkt01_brand_fit(self, name: str, idea: str) -> BrandFitResult:
        """Deterministic brand fit stub."""
        h = _name_hash(name)
        length = len(name)

        tonality = min(100, 60 + (h % 35))
        pronounce = min(100, 90 - length * 3) if length < 20 else 30
        memorability = min(100, 70 + (h % 25))
        confusion = max(0, 100 - (h % 40))
        international = min(100, 65 + (h % 30))

        score = round((tonality + pronounce + memorability + confusion + international) / 5)

        if score >= 80:
            rec = "Strong name. Proceed."
        elif score >= 60:
            rec = "Acceptable. Minor concerns noted."
        else:
            rec = "Weak brand fit. Consider alternatives."

        return BrandFitResult(
            tonality=tonality,
            pronounceability=pronounce,
            memorability=memorability,
            confusion_risk=confusion,
            international=international,
            score=score,
            recommendation=rec,
        )

    def _stub_mkt05_aso_precheck(self, name: str) -> ASOPreCheckResult:
        """Deterministic ASO pre-check stub."""
        h = _name_hash(name)
        saturation_val = h % 3
        saturation = ["low", "medium", "high"][saturation_val]
        score = [90, 60, 30][saturation_val]

        competitors = []
        if saturation in ("medium", "high"):
            bases = ["AppX", "QuickApp", "SmartTool", "ProHelper", "EasyMatch"]
            competitors = [bases[i % len(bases)] for i in range(saturation_val + 1)]

        return ASOPreCheckResult(
            keyword_saturation=saturation,
            dominant_competitors=competitors,
            score=score,
        )

    # ------------------------------------------------------------------
    # Alternative generation (stub — no real agent wired yet)
    # ------------------------------------------------------------------

    def _stub_generate_alternatives(
        self, idea: str, rejected: List[str],
    ) -> List[str]:
        """Generate alternative names (deterministic stub)."""
        words = idea.lower().split()
        base = words[0] if words else "app"
        suffixes = ["ly", "ify", "hub", "io", "go", "now", "ai", "x"]
        prefixes = ["my", "get", "try", "hey", "be"]

        candidates = []
        for s in suffixes:
            candidate = f"{base.capitalize()}{s}"
            if candidate not in rejected:
                candidates.append(candidate)
        for p in prefixes:
            candidate = f"{p.capitalize()}{base.capitalize()}"
            if candidate not in rejected:
                candidates.append(candidate)

        return candidates[:MAX_ALTERNATIVES]

    # ------------------------------------------------------------------
    # Recommendations
    # ------------------------------------------------------------------

    def _generate_recommendations(
        self,
        checks: NameCheckResult,
        hard: List[str],
        soft: List[str],
    ) -> List[str]:
        """Generate actionable recommendations based on check results."""
        recs: List[str] = []

        if hard:
            recs.append("CRITICAL: Hard blockers detected. Name cannot proceed.")

        if not checks.domain.com:
            recs.append("Consider alternative TLDs (.app, .io) or a modified name for .com")

        if not checks.store.apple or not checks.store.google:
            recs.append("Check exact store listing names - slight variations may work")

        if checks.brand_fit.score < 70:
            recs.append("Brand fit is below average - consider a naming workshop")

        if checks.aso.keyword_saturation == "high":
            recs.append("ASO: Highly saturated keyword space - differentiation needed")

        if checks.social_media.score < 60:
            recs.append("Social handles limited - consider adding a prefix (get/my/the)")

        if not recs:
            recs.append("Name looks strong across all dimensions. Proceed with confidence.")

        return recs

    # ------------------------------------------------------------------
    # Persistence
    # ------------------------------------------------------------------

    def _save_report(self, name: str, report: NameGateReport) -> None:
        """Save report to data directory."""
        slug = re.sub(r"[^a-z0-9_]", "", name.lower().replace(" ", "_"))
        path = self.data_dir / f"{slug}_report.json"
        with open(path, "w", encoding="utf-8") as f:
            json.dump(report.to_dict(), f, indent=2, ensure_ascii=False)


# ------------------------------------------------------------------
# Convenience function
# ------------------------------------------------------------------

def run_name_gate(
    name: str,
    idea: str,
    template: str = "",
    profile: str = "dev",
) -> NameGateReport:
    """Run the full Name Gate validation (convenience wrapper)."""
    orch = NameGateOrchestrator(profile=profile)
    return orch.validate_name(name, idea, template)

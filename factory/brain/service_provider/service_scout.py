"""Service Scout — Autonomous market watcher for external AI services.

Searches for new/better services, compares with existing registry entries,
writes skeleton adapters, and generates CEO reports.

Autonomy levels:
  CAN do autonomously: compare services, write adapter skeletons, write reports
  CANNOT do autonomously: set up API keys, activate services, deactivate existing
"""

import json
import logging
import textwrap
from dataclasses import dataclass, field, asdict
from pathlib import Path
from typing import Optional
from datetime import date

logger = logging.getLogger(__name__)


@dataclass
class ScoutFinding:
    """A single service found by the scout."""
    name: str
    provider: str
    category: str
    api_url: str
    api_docs_url: str
    capabilities: list[str] = field(default_factory=list)
    estimated_cost_per_call: float = 0.0
    pros: list[str] = field(default_factory=list)
    cons: list[str] = field(default_factory=list)
    comparison_to_existing: str = "monitor"
    recommended_action: str = "monitor"


@dataclass
class ScoutReport:
    """Complete scout report for CEO review."""
    scan_date: str
    category_scanned: str
    existing_services: list[str] = field(default_factory=list)
    findings: list[ScoutFinding] = field(default_factory=list)
    summary: str = ""
    adapter_files_written: list[str] = field(default_factory=list)


# ======================================================================
# Curated knowledge — the scout's offline database
# ======================================================================

KNOWN_SERVICES = {
    "image": [
        {
            "name": "Flux Pro 1.1",
            "provider": "black_forest_labs",
            "api_url": "https://api.bfl.ml/v1/flux-pro-1.1",
            "api_docs_url": "https://docs.bfl.ml/",
            "capabilities": ["text_to_image", "png_output", "max_2048x2048", "style_control", "fast_generation"],
            "estimated_cost": 0.04,
            "notes": "Fast generation, high quality, good prompt adherence",
        },
        {
            "name": "Ideogram v2",
            "provider": "ideogram",
            "api_url": "https://api.ideogram.ai/generate",
            "api_docs_url": "https://docs.ideogram.ai/",
            "capabilities": ["text_to_image", "png_output", "text_in_image", "max_1024x1024", "style_control"],
            "estimated_cost": 0.03,
            "notes": "Excellent text-in-image rendering, good for UI mockups",
        },
        {
            "name": "Leonardo AI",
            "provider": "leonardo",
            "api_url": "https://cloud.leonardo.ai/api/rest/v1/generations",
            "api_docs_url": "https://docs.leonardo.ai/",
            "capabilities": ["text_to_image", "png_output", "style_control", "max_1024x1024", "game_assets"],
            "estimated_cost": 0.02,
            "notes": "Specialized in game assets, characters, and environments",
        },
    ],
    "sound": [
        {
            "name": "AudioCraft (Meta)",
            "provider": "meta_audiocraft",
            "api_url": "https://huggingface.co/facebook/musicgen-large",
            "api_docs_url": "https://github.com/facebookresearch/audiocraft",
            "capabilities": ["text_to_music", "ambient_generation", "wav_output", "max_30s"],
            "estimated_cost": 0.00,
            "notes": "Open source, self-host, no API cost but needs GPU",
        },
        {
            "name": "Stability Audio",
            "provider": "stability_audio",
            "api_url": "https://api.stability.ai/v2beta/stable-audio/generate",
            "api_docs_url": "https://platform.stability.ai/docs/api-reference#tag/Audio",
            "capabilities": ["text_to_sfx", "text_to_music", "wav_output", "max_47s", "stereo"],
            "estimated_cost": 0.01,
            "notes": "Same provider as Stability SDXL, might bundle API key",
        },
    ],
    "video": [
        {
            "name": "Kling AI",
            "provider": "kling",
            "api_url": "https://api.klingai.com/v1/videos/text2video",
            "api_docs_url": "https://docs.klingai.com/",
            "capabilities": ["text_to_video", "image_to_video", "mp4_output", "max_10s"],
            "estimated_cost": 0.08,
            "notes": "Cheaper than Runway, good quality, Chinese provider",
        },
        {
            "name": "Luma Dream Machine",
            "provider": "luma",
            "api_url": "https://api.lumalabs.ai/dream-machine/v1/generations",
            "api_docs_url": "https://docs.lumalabs.ai/",
            "capabilities": ["text_to_video", "image_to_video", "mp4_output", "max_5s"],
            "estimated_cost": 0.05,
            "notes": "Good quality, fast generation, camera motion control",
        },
    ],
    "animation": [
        {
            "name": "Rive (Runtime)",
            "provider": "rive",
            "api_url": "https://rive.app",
            "api_docs_url": "https://help.rive.app/",
            "capabilities": ["interactive_animation", "vector_animation", "state_machine"],
            "estimated_cost": 0.00,
            "notes": "Design tool, not API-based. Animations created in editor.",
        },
    ],
}


class ServiceScout:
    """Searches for new external AI services and reports to CEO."""

    def __init__(self, registry, router=None, reports_dir: str = None):
        self._registry = registry
        self._router = router
        if reports_dir is None:
            reports_dir = str(Path(__file__).parent / "scout_reports")
        self._reports_dir = Path(reports_dir)
        self._reports_dir.mkdir(parents=True, exist_ok=True)

    # ------------------------------------------------------------------
    # Scanning
    # ------------------------------------------------------------------

    def scan_category(self, category: str) -> ScoutReport:
        existing = self._registry.get_active_services(category)
        all_in_registry = self._registry.get_all_services()
        existing_ids = [s.service_id for s in existing]
        registry_providers = {s.provider for s in all_in_registry}

        known = KNOWN_SERVICES.get(category, [])
        findings = []
        adapters_written = []

        for svc in known:
            if svc["provider"] in registry_providers:
                continue  # Already in registry

            finding = self.compare_with_existing(svc, category)
            findings.append(finding)

            if finding.recommended_action == "add_to_registry":
                try:
                    path = self.write_adapter_skeleton(finding)
                    adapters_written.append(path)
                except Exception as e:
                    logger.warning("Failed to write adapter skeleton for %s: %s", svc["name"], e)

        add_count = sum(1 for f in findings if f.recommended_action == "add_to_registry")
        monitor_count = sum(1 for f in findings if f.recommended_action == "monitor")

        summary = (
            f"{len(findings)} neue Services gefunden fuer '{category}'. "
            f"{add_count} empfohlen zum Hinzufuegen, {monitor_count} zum Beobachten. "
            f"Bestehende Services: {', '.join(existing_ids) or 'keine aktiven'}."
        )

        report = ScoutReport(
            scan_date=date.today().isoformat(),
            category_scanned=category,
            existing_services=existing_ids,
            findings=findings,
            summary=summary,
            adapter_files_written=adapters_written,
        )
        self._save_report(report)
        return report

    def compare_with_existing(self, new_service: dict, category: str) -> ScoutFinding:
        existing = self._registry.get_active_services(category)
        new_cost = new_service.get("estimated_cost", 0.0)
        new_caps = set(new_service.get("capabilities", []))

        # Gather existing data
        existing_costs = []
        existing_caps_union = set()
        for s in existing:
            cost = self._registry.get_cost_estimate(s.service_id, {})
            if cost >= 0:
                existing_costs.append(cost)
            existing_caps_union.update(s.capabilities)

        cheapest_existing = min(existing_costs) if existing_costs else 999
        novel_caps = new_caps - existing_caps_union

        # Determine comparison
        is_cheaper = new_cost < cheapest_existing and existing_costs
        has_new_caps = len(novel_caps) > 0

        if is_cheaper and has_new_caps:
            comparison = "replacement"
            action = "add_to_registry"
        elif is_cheaper:
            comparison = "cheaper"
            action = "add_to_registry"
        elif has_new_caps:
            comparison = "new_capability"
            action = "add_to_registry"
        elif not existing:
            comparison = "new_capability"
            action = "add_to_registry"
        else:
            comparison = "similar"
            action = "monitor"

        # Build pros/cons
        pros = []
        cons = []
        if is_cheaper:
            pros.append(f"Guenstiger: ${new_cost:.2f} vs ${cheapest_existing:.2f}")
        if novel_caps:
            pros.append(f"Neue Capabilities: {', '.join(novel_caps)}")
        notes = new_service.get("notes", "")
        if notes:
            pros.append(notes)
        if new_cost > cheapest_existing and existing_costs:
            cons.append(f"Teurer als guenstigster bestehender (${cheapest_existing:.2f})")
        if new_cost == 0.0 and "self-host" in notes.lower():
            cons.append("Self-Hosting noetig (GPU-Kosten)")

        return ScoutFinding(
            name=new_service["name"],
            provider=new_service["provider"],
            category=category,
            api_url=new_service.get("api_url", ""),
            api_docs_url=new_service.get("api_docs_url", ""),
            capabilities=new_service.get("capabilities", []),
            estimated_cost_per_call=new_cost,
            pros=pros,
            cons=cons,
            comparison_to_existing=comparison,
            recommended_action=action,
        )

    # ------------------------------------------------------------------
    # Adapter skeleton
    # ------------------------------------------------------------------

    def write_adapter_skeleton(self, finding: ScoutFinding) -> str:
        drafts_dir = Path(__file__).parent / "adapters" / "drafts"
        drafts_dir.mkdir(parents=True, exist_ok=True)

        slug = finding.provider.lower().replace(" ", "_").replace("-", "_")
        filename = f"{slug}_adapter.py"
        filepath = drafts_dir / filename

        class_name = "".join(w.capitalize() for w in slug.split("_")) + "Adapter"
        caps_str = ", ".join(f'"{c}"' for c in finding.capabilities)
        service_id = slug

        code = textwrap.dedent(f'''\
            """{{name}} Adapter — DRAFT (generated by Service Scout).

            Provider: {finding.provider}
            API: {finding.api_url}
            Docs: {finding.api_docs_url}
            Estimated cost: ${finding.estimated_cost_per_call:.2f}/call

            STATUS: DRAFT — requires CEO review + API key before activation.
            """

            import logging
            import time

            import httpx

            from factory.brain.service_provider.adapters.base_adapter import BaseServiceAdapter, ServiceResult

            logger = logging.getLogger(__name__)

            API_BASE = "{finding.api_url}"


            class {class_name}(BaseServiceAdapter):

                def __init__(self, api_key: str):
                    super().__init__("{service_id}", api_key)

                def get_capabilities(self) -> list[str]:
                    return [{caps_str}]

                def get_cost_estimate(self, specs: dict) -> float:
                    return {finding.estimated_cost_per_call}

                def health_check(self) -> bool:
                    try:
                        resp = httpx.get(
                            API_BASE,
                            headers={{"Authorization": f"Bearer {{self._api_key}}"}},
                            timeout=10.0,
                        )
                        return True  # Reachable if any HTTP response
                    except Exception:
                        return False

                async def generate(self, prompt: str, specs: dict) -> ServiceResult:
                    t0 = time.time()
                    # TODO: Implement actual API call
                    # See docs: {finding.api_docs_url}
                    duration = int((time.time() - t0) * 1000)
                    return ServiceResult.failure(
                        self._service_id,
                        "Not implemented — draft adapter, needs API integration",
                        duration,
                    )
        ''').replace("{{name}}", finding.name)

        filepath.write_text(code, encoding="utf-8")
        logger.info("Wrote adapter skeleton: %s", filepath)
        return str(filepath)

    # ------------------------------------------------------------------
    # CEO Report
    # ------------------------------------------------------------------

    def generate_ceo_report(self, report: ScoutReport) -> str:
        w = 58
        border = "=" * w

        lines = [
            border,
            f"  SERVICE SCOUT REPORT",
            f"  Category: {report.category_scanned} | Date: {report.scan_date}",
            border,
            "",
            f"  Existing services: {', '.join(report.existing_services) or 'none'}",
            f"  New services found: {len(report.findings)}",
            "",
        ]

        for i, f in enumerate(report.findings, 1):
            lines.append(f"  -- Finding {i}: {f.name} --")
            lines.append(f"  Provider:    {f.provider}")
            lines.append(f"  Category:    {f.category}")
            lines.append(f"  Est. Cost:   ${f.estimated_cost_per_call:.2f}/call")
            lines.append(f"  Capabilities: {', '.join(f.capabilities)}")
            lines.append(f"  vs Current:  {f.comparison_to_existing}")
            lines.append(f"  Pros:        {'; '.join(f.pros) or '-'}")
            lines.append(f"  Cons:        {'; '.join(f.cons) or '-'}")
            lines.append(f"  Recommendation: {f.recommended_action.upper()}")
            lines.append("")

        lines.append(border)
        lines.append("  CEO ACTION REQUIRED:")
        add_findings = [f for f in report.findings if f.recommended_action == "add_to_registry"]
        if add_findings:
            lines.append("  1. Review findings above")
            lines.append("  2. For services to add:")
            for af in add_findings:
                env_key = af.provider.upper().replace(" ", "_") + "_API_KEY"
                lines.append(f"     - {af.name}: Register at {af.api_docs_url}")
                lines.append(f"       Add key to .env as {env_key}")
            lines.append("  3. Give GO for activation")
        else:
            lines.append("  No immediate action needed. Services noted for monitoring.")
        lines.append(border)

        return "\n".join(lines)

    # ------------------------------------------------------------------
    # Persistence
    # ------------------------------------------------------------------

    def _save_report(self, report: ScoutReport):
        filename = f"{report.scan_date}_{report.category_scanned}_scan.json"
        path = self._reports_dir / filename
        try:
            payload = asdict(report)
            path.write_text(json.dumps(payload, indent=2, ensure_ascii=False), encoding="utf-8")
        except OSError as e:
            logger.error("Failed to save scout report: %s", e)

    def get_latest_report(self, category: str) -> Optional[dict]:
        pattern = f"*_{category}_scan.json"
        files = sorted(self._reports_dir.glob(pattern), reverse=True)
        if not files:
            return None
        try:
            return json.loads(files[0].read_text(encoding="utf-8"))
        except (json.JSONDecodeError, OSError):
            return None

    # ------------------------------------------------------------------
    # Convenience
    # ------------------------------------------------------------------

    def scan_all_categories(self) -> list[ScoutReport]:
        reports = []
        for cat in KNOWN_SERVICES:
            reports.append(self.scan_category(cat))
        return reports

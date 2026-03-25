"""DriveAI Factory — Store Prep Coordinator.

Main orchestrator for the Store Preparation pipeline.
Runs 4 phases per platform:
  1. Metadata Generation + Enrichment + Platform Adaptation
  2. Asset Preparation (Icons via AssetForge, Screenshots)
  3. Compliance Check + Privacy Labels
  4. Packaging + Report

Interfaces with existing factory/store/ modules and adds:
- Platform-specific metadata (Apple/Google/Web formats)
- Report-based enrichment for better store texts
- Privacy Nutrition Labels / Data Safety Sections
- CEO Gates for metadata review and asset selection

All external factory imports are lazy and wrapped in try/except.
"""

import os
import shutil
import time
import traceback
import types
from dataclasses import dataclass, field
from pathlib import Path

from factory.store_prep.config import StorePrepConfig
from factory.store_prep.metadata_enricher import MetadataEnricher
from factory.store_prep.platform_metadata import (
    AppleStoreMetadata,
    GooglePlayMetadata,
    PlatformMetadataAdapter,
    WebMetadata,
)
from factory.store_prep.privacy_labels import PrivacyLabelGenerator
from factory.store_prep.screenshot_coordinator import (
    ScreenshotCoordinator,
    ScreenshotResult,
)
from factory.store_prep.store_prep_report import PlatformPrepStatus, StorePrepReport

_ROOT = Path(__file__).resolve().parent.parent.parent


@dataclass
class StorePrepResult:
    """Result of a complete Store Preparation run."""

    status: str = "PENDING"  # READY, INCOMPLETE, BLOCKED
    per_platform: dict = field(default_factory=dict)
    report_path: str = ""
    output_dir: str = ""
    gates_triggered: list = field(default_factory=list)


class StorePrepCoordinator:
    """Orchestrates the complete Store Preparation pipeline.

    Usage:
        coord = StorePrepCoordinator("askfin_v1-1", ["ios", "web"])
        result = coord.run()
        print(result.status)  # READY, INCOMPLETE, or BLOCKED
    """

    def __init__(
        self,
        project_name: str,
        platforms: list[str],
        config: StorePrepConfig | None = None,
    ) -> None:
        self.project_name = project_name
        self.platforms = platforms
        self.config = config or StorePrepConfig()
        self.output_dir = os.path.join(self.config.output_base_dir, project_name)
        self.report = StorePrepReport(project_name)

    # ------------------------------------------------------------------
    # Main entry point
    # ------------------------------------------------------------------

    def run(self, qa_report_path: str | None = None) -> StorePrepResult:
        """Run Store Preparation for all specified platforms."""
        start = time.time()
        print(f"[Store Prep] Starting Store Preparation for {self.project_name}")
        print(f"[Store Prep] Platforms: {', '.join(self.platforms)}")
        print(f"[Store Prep] Output: {self.output_dir}")

        result = StorePrepResult(output_dir=self.output_dir)

        try:
            # Resolve project directory
            project_dir = self._resolve_project_dir()
            if not project_dir:
                print(
                    "[Store Prep] WARNING: Project directory not found, "
                    "some features will be limited"
                )
                project_dir = ""

            # Load enrichment (once for all platforms)
            print("[Store Prep] Loading enrichment data...")
            enricher = MetadataEnricher(self.project_name)
            enrichment = enricher.enrich()
            enrichment_keys = [
                k for k, v in enrichment.items() if v and v.get("raw")
            ]
            print(
                f"[Store Prep] Enrichment loaded: {len(enrichment_keys)} "
                f"data sources ({', '.join(enrichment_keys)})"
            )

            # Process each platform
            for platform in self.platforms:
                print(f"\n[Store Prep] {'=' * 50}")
                print(f"[Store Prep] Processing: {platform}")
                print(f"[Store Prep] {'=' * 50}")

                platform_dir = os.path.join(self.output_dir, platform)
                os.makedirs(platform_dir, exist_ok=True)

                plat_status = self.report.add_platform(platform)

                # Phase 1: Metadata
                self._phase_1_metadata(
                    platform, platform_dir, enrichment, plat_status
                )

                # Phase 2: Assets
                self._phase_2_assets(
                    platform, platform_dir, project_dir, plat_status
                )

                # Phase 3: Compliance + Privacy
                self._phase_3_compliance(
                    platform, platform_dir, project_dir, plat_status
                )

                # Phase 4: Evaluate readiness
                self._phase_4_evaluate(platform, plat_status)

                result.per_platform[platform] = plat_status

            # Overall report
            self.report.evaluate_overall_status()
            report_path = self.report.save(self.output_dir)
            self.report.print_summary()

            result.status = self.report.overall_status
            result.report_path = report_path
            result.gates_triggered = self.report.ceo_gates_triggered

        except Exception as e:
            print(f"[Store Prep] UNEXPECTED ERROR: {e}")
            traceback.print_exc()
            result.status = "BLOCKED"

        duration = round(time.time() - start, 1)
        print(f"\n[Store Prep] Completed in {duration}s -- Status: {result.status}")
        return result

    # ------------------------------------------------------------------
    # Project directory resolution
    # ------------------------------------------------------------------

    def _resolve_project_dir(self) -> str | None:
        """Resolve the project source directory.

        Try order:
          1. Project registry
          2. Convention: projects/{project_name}/
          3. None
        """
        # Try project registry
        try:
            from factory.project_registry import get_project

            proj = get_project(self.project_name)
            if proj:
                # Check for source dir in project data
                proj_dir = _ROOT / "projects" / self.project_name
                if proj_dir.is_dir():
                    return str(proj_dir)
        except ImportError:
            pass

        # Convention fallback
        conv = _ROOT / "projects" / self.project_name
        if conv.is_dir():
            return str(conv)

        return None

    # ------------------------------------------------------------------
    # Phase 1: Metadata Generation + Enrichment + Adaptation
    # ------------------------------------------------------------------

    def _phase_1_metadata(
        self,
        platform: str,
        platform_dir: str,
        enrichment: dict,
        plat_status: PlatformPrepStatus,
    ) -> None:
        """Phase 1: Generate, enrich, and adapt metadata."""
        print(f"[Store Prep] Phase 1: Metadata ({platform})")

        # Step 1: Generate generic metadata
        generic_meta = self._generate_generic_metadata(platform)

        # Step 2: Adapt to platform-specific format
        adapter = PlatformMetadataAdapter(self.config)
        try:
            platform_meta = adapter.adapt(generic_meta, platform, enrichment)
            print(f"[Store Prep]   Adapted to {platform} format")
        except Exception as e:
            print(f"[Store Prep]   Adaptation failed: {e}")
            platform_meta = adapter.adapt(generic_meta, platform)

        # Step 3: Validate
        errors = platform_meta.validate()
        if errors:
            for err in errors:
                print(f"[Store Prep]   Validation: {err}")
                self.report.add_warning(f"{platform}: {err}")

        # Step 4: Save
        meta_path = os.path.join(platform_dir, "metadata.json")
        platform_meta.to_json(meta_path)
        print(f"[Store Prep]   Metadata saved to {meta_path}")

        # Step 5: CEO Gate — Metadata Review
        if self.config.require_metadata_review:
            self._create_metadata_review_gate(platform, platform_meta)

        # Step 6: Update status
        meta_dict = platform_meta.to_dict()
        filled = sum(1 for v in meta_dict.values() if v and v != "N/A")
        empty_required = len(errors)

        plat_status.metadata_status = "READY" if not errors else "INCOMPLETE"
        plat_status.metadata_fields_complete = filled
        plat_status.metadata_fields_missing = empty_required
        plat_status.metadata_validation_errors = errors

        print(
            f"[Store Prep]   Metadata: {plat_status.metadata_status} "
            f"({filled} fields, {len(errors)} errors)"
        )

    def _generate_generic_metadata(self, platform: str):
        """Generate generic StoreMetadata via MetadataGenerator, with fallback."""
        try:
            from factory.store.metadata_generator import MetadataGenerator

            meta = MetadataGenerator(self.project_name).generate(platform)
            print(f"[Store Prep]   MetadataGenerator: OK ({meta.app_name})")
            return meta
        except ImportError:
            print("[Store Prep]   MetadataGenerator: not available, using fallback")
        except Exception as e:
            print(f"[Store Prep]   MetadataGenerator failed: {e}, using fallback")

        # Minimal fallback
        name = self.project_name.replace("_", " ").replace("-", " ").title()
        return types.SimpleNamespace(
            app_name=name,
            subtitle="",
            description_de="",
            description_en="",
            keywords="",
            category_primary="",
            category_secondary="",
            age_rating="4+",
            privacy_url="",
            support_url="",
            whats_new="Initial release",
            privacy_policy="",
            platforms=[],
            version="1.0.0",
        )

    def _create_metadata_review_gate(self, platform: str, meta) -> None:
        """Create a non-blocking CEO gate for metadata review."""
        try:
            from factory.hq.gate_api import create_gate

            meta_dict = meta.to_dict()

            # Build preview for description
            desc_key = {
                "ios": "description",
                "android": "full_description",
                "web": "meta_description",
            }.get(platform, "description")
            desc_preview = str(meta_dict.get(desc_key, ""))[:200]

            subtitle_key = {
                "ios": "subtitle",
                "android": "short_description",
                "web": "title",
            }.get(platform, "subtitle")

            description = (
                f"App: {meta_dict.get('app_name', '')}\n"
                f"Subtitle: {meta_dict.get(subtitle_key, '')}\n"
                f"Description: {desc_preview}..."
            )

            gate_id = create_gate(
                project=self.project_name,
                gate_type="store_metadata_review",
                category="store_prep",
                title=f"Store Metadata Review -- {self.project_name} ({platform})",
                description=description,
                severity="info",
                options=[
                    {"id": "approve", "label": "Freigeben", "color": "green"},
                    {"id": "revise", "label": "Ueberarbeiten", "color": "orange"},
                    {"id": "skip", "label": "Ueberspringen", "color": "gray"},
                ],
                source_department="factory/store_prep",
                source_agent="store_prep_coordinator",
                platform=platform,
                context=meta_dict,
                recommendation={
                    "option_id": "approve",
                    "reasoning": "Auto-generated, enriched with report data",
                },
            )
            self.report.add_ceo_gate(
                "store_metadata_review", "pending", f"gate:{gate_id}"
            )
            print(f"[Store Prep]   CEO Gate created: {gate_id}")
        except ImportError:
            print("[Store Prep]   Gate API not available, skipping metadata review gate")
        except Exception as e:
            print(f"[Store Prep]   Gate creation failed: {e}")

    # ------------------------------------------------------------------
    # Phase 2: Assets (Icons + Screenshots)
    # ------------------------------------------------------------------

    def _phase_2_assets(
        self,
        platform: str,
        platform_dir: str,
        project_dir: str,
        plat_status: PlatformPrepStatus,
    ) -> None:
        """Phase 2: Icon generation + screenshot capture."""
        print(f"[Store Prep] Phase 2: Assets ({platform})")

        # Step A: Icon
        self._prepare_icon(platform, platform_dir, project_dir, plat_status)

        # Step B: Screenshots
        self._prepare_screenshots(platform, platform_dir, project_dir, plat_status)

        # Step C: CEO Gate for assets
        if (
            self.config.require_asset_review
            and plat_status.icon_status == "READY"
        ):
            self._create_asset_review_gate(platform, platform_dir)

    def _prepare_icon(
        self,
        platform: str,
        platform_dir: str,
        project_dir: str,
        plat_status: PlatformPrepStatus,
    ) -> None:
        """Try AssetForge, then check project dir for existing icons."""
        icon_dir = os.path.join(platform_dir, "icon")

        # Try AssetForge
        roadbook_dir = self._find_roadbook_dir()
        if roadbook_dir:
            try:
                from factory.asset_forge.pipeline import AssetForgePipeline

                print("[Store Prep]   AssetForge: generating icons...")
                result = AssetForgePipeline().run(
                    roadbook_dir=roadbook_dir,
                    project_name=self.project_name,
                    priority_filter="icon",
                    platforms=[platform],
                )
                # Check for generated icons
                forge_output = (
                    _ROOT / "factory" / "asset_forge" / "output"
                    / f"{self.project_name}_proof"
                )
                if forge_output.is_dir():
                    count = self._copy_files(str(forge_output), icon_dir, "*.png")
                    if count > 0:
                        plat_status.icon_status = "READY"
                        print(f"[Store Prep]   Icon: {count} files from AssetForge")
                        return
            except ImportError:
                print("[Store Prep]   AssetForge: not available")
            except Exception as e:
                print(f"[Store Prep]   AssetForge failed: {e}")
        else:
            print("[Store Prep]   AssetForge: no roadbook directory found")

        # Check project dir for existing icons
        if project_dir:
            icon_patterns = {
                "ios": ["AppIcon*", "*1024*png", "*.appiconset/*"],
                "android": ["ic_launcher*", "mipmap*/*"],
                "web": ["favicon*", "icon*png"],
            }
            patterns = icon_patterns.get(platform, ["*icon*png"])
            proj_path = Path(project_dir)
            for pattern in patterns:
                found = list(proj_path.rglob(pattern))
                if found:
                    os.makedirs(icon_dir, exist_ok=True)
                    count = 0
                    for f in found[:5]:  # Cap at 5 files
                        if f.is_file() and f.suffix in (".png", ".jpg", ".jpeg"):
                            dest = os.path.join(icon_dir, f.name)
                            if not os.path.exists(dest):
                                shutil.copy2(str(f), dest)
                                count += 1
                    if count > 0:
                        plat_status.icon_status = "READY"
                        print(
                            f"[Store Prep]   Icon: {count} files from project dir"
                        )
                        return

        plat_status.icon_status = "MISSING"
        print("[Store Prep]   Icon: MISSING")

    def _prepare_screenshots(
        self,
        platform: str,
        platform_dir: str,
        project_dir: str,
        plat_status: PlatformPrepStatus,
    ) -> None:
        """Check for existing screenshots, then try capture."""
        coord = ScreenshotCoordinator(
            self.project_name,
            platform,
            project_dir or "",
            platform_dir,
            self.config,
        )

        # Check existing
        existing = coord.check_existing_screenshots()
        if existing.status == "CAPTURED":
            plat_status.screenshots_status = "CAPTURED"
            plat_status.screenshots_count = existing.screenshots_count
            print(
                f"[Store Prep]   Screenshots: {existing.screenshots_count} "
                f"existing found"
            )
            return

        # Try capture
        result = coord.capture()
        plat_status.screenshots_status = result.status
        plat_status.screenshots_count = result.screenshots_count

        if result.status == "CAPTURED":
            print(
                f"[Store Prep]   Screenshots: {result.screenshots_count} captured"
            )
        elif result.status == "PARTIAL":
            print(
                f"[Store Prep]   Screenshots: {result.screenshots_count} "
                f"(partial, expected more)"
            )
        else:
            print(f"[Store Prep]   Screenshots: {result.status} ({result.reason})")

        # Android feature graphic
        if platform == "android":
            fg_path = os.path.join(platform_dir, "feature_graphic.png")
            if os.path.exists(fg_path):
                plat_status.feature_graphic_status = "READY"
            else:
                plat_status.feature_graphic_status = "MISSING"

    def _create_asset_review_gate(self, platform: str, platform_dir: str) -> None:
        """Create a non-blocking CEO gate for asset review."""
        try:
            from factory.hq.gate_api import create_gate

            gate_id = create_gate(
                project=self.project_name,
                gate_type="store_asset_review",
                category="store_prep",
                title=f"Store Asset Review -- {self.project_name} ({platform})",
                description="New store assets generated. Please review icons and screenshots.",
                severity="info",
                options=[
                    {"id": "approve", "label": "Freigeben", "color": "green"},
                    {"id": "revise", "label": "Ueberarbeiten", "color": "orange"},
                    {"id": "skip", "label": "Ueberspringen", "color": "gray"},
                ],
                source_department="factory/store_prep",
                source_agent="store_prep_coordinator",
                platform=platform,
                context={"platform_dir": platform_dir},
            )
            self.report.add_ceo_gate(
                "store_asset_review", "pending", f"gate:{gate_id}"
            )
            print(f"[Store Prep]   Asset review gate created: {gate_id}")
        except ImportError:
            pass
        except Exception as e:
            print(f"[Store Prep]   Asset gate creation failed: {e}")

    # ------------------------------------------------------------------
    # Phase 3: Compliance + Privacy Labels
    # ------------------------------------------------------------------

    def _phase_3_compliance(
        self,
        platform: str,
        platform_dir: str,
        project_dir: str,
        plat_status: PlatformPrepStatus,
    ) -> None:
        """Phase 3: Compliance check + privacy label generation."""
        print(f"[Store Prep] Phase 3: Compliance + Privacy ({platform})")

        # Step A: Compliance
        self._run_compliance(platform, platform_dir, plat_status)

        # Step B: Privacy Labels
        self._generate_privacy_labels(platform, platform_dir, project_dir, plat_status)

    def _run_compliance(
        self, platform: str, platform_dir: str, plat_status: PlatformPrepStatus
    ) -> None:
        """Run compliance checks."""
        try:
            from factory.store.compliance_checker import ComplianceChecker

            report = ComplianceChecker(self.project_name).check(platform)
            passed = sum(
                1 for i in report.issues if i.severity == "info"
            )
            failed = report.blocking_count
            warning = report.warning_count

            plat_status.compliance_status = "READY" if report.ready else "BLOCKED"
            plat_status.compliance_checks_passed = passed
            plat_status.compliance_checks_failed = failed
            plat_status.compliance_checks_warning = warning

            # Save compliance report
            report.save(platform_dir)

            if not report.ready:
                for issue in report.issues:
                    if issue.severity == "blocking":
                        plat_status.missing_items.append(
                            f"Compliance: {issue.description}"
                        )

            print(
                f"[Store Prep]   Compliance: "
                f"{'READY' if report.ready else 'BLOCKED'} "
                f"({failed} blocking, {warning} warnings)"
            )
        except ImportError:
            plat_status.compliance_status = "SKIPPED"
            print("[Store Prep]   Compliance: SKIPPED (module not available)")
        except Exception as e:
            plat_status.compliance_status = "SKIPPED"
            print(f"[Store Prep]   Compliance failed: {e}")

    def _generate_privacy_labels(
        self,
        platform: str,
        platform_dir: str,
        project_dir: str,
        plat_status: PlatformPrepStatus,
    ) -> None:
        """Generate privacy labels for the platform."""
        if not project_dir:
            plat_status.privacy_label_status = "SKIPPED"
            self.report.add_warning(
                f"{platform}: Privacy labels skipped (no project directory)"
            )
            print("[Store Prep]   Privacy labels: SKIPPED (no project dir)")
            return

        try:
            gen = PrivacyLabelGenerator(self.project_name)
            labels = gen.generate()
            gen.save(labels, os.path.join(platform_dir, "privacy"))
            plat_status.privacy_label_status = "GENERATED"

            scan = labels["scan"]
            categories = scan.categories_detected
            print(
                f"[Store Prep]   Privacy labels: GENERATED "
                f"({len(categories)} categories: "
                f"{', '.join(categories) or 'none'})"
            )

            # Check if manual review is warranted (sensitive categories)
            sensitive = {"health", "financial", "biometrics", "contacts", "location"}
            needs_review = any(c in sensitive for c in categories)
            if needs_review:
                plat_status.privacy_label_status = "NEEDS_REVIEW"
                print("[Store Prep]   Privacy labels: flagged for CEO review")
                self._create_privacy_review_gate(platform, categories)

        except Exception as e:
            plat_status.privacy_label_status = "SKIPPED"
            print(f"[Store Prep]   Privacy labels failed: {e}")

    def _create_privacy_review_gate(
        self, platform: str, categories: list[str]
    ) -> None:
        """Create a non-blocking CEO gate for privacy label review."""
        try:
            from factory.hq.gate_api import create_gate

            gate_id = create_gate(
                project=self.project_name,
                gate_type="privacy_label_review",
                category="store_prep",
                title=f"Privacy Label Review -- {self.project_name} ({platform})",
                description=(
                    f"Sensitive data categories detected: {', '.join(categories)}. "
                    f"Please verify privacy labels are accurate."
                ),
                severity="info",
                options=[
                    {"id": "approve", "label": "Bestaetigen", "color": "green"},
                    {"id": "revise", "label": "Anpassen", "color": "orange"},
                ],
                source_department="factory/store_prep",
                source_agent="store_prep_coordinator",
                platform=platform,
                context={"categories": categories},
            )
            self.report.add_ceo_gate(
                "privacy_label_review", "pending", f"gate:{gate_id}"
            )
        except (ImportError, Exception):
            pass

    # ------------------------------------------------------------------
    # Phase 4: Evaluate readiness
    # ------------------------------------------------------------------

    def _phase_4_evaluate(
        self, platform: str, plat_status: PlatformPrepStatus
    ) -> None:
        """Phase 4: Evaluate overall readiness for this platform."""
        print(f"[Store Prep] Phase 4: Evaluate ({platform})")

        # Check for blocking conditions
        blocked = False
        if plat_status.metadata_status == "BLOCKED":
            blocked = True
        if plat_status.compliance_status == "BLOCKED":
            blocked = True

        if blocked:
            plat_status.status = "BLOCKED"
            print(f"[Store Prep]   Status: BLOCKED")
            return

        # Check for missing items
        if plat_status.icon_status != "READY":
            plat_status.missing_items.append(
                "App Icon (required for store submission)"
            )

        if platform == "ios":
            if plat_status.screenshots_status not in ("CAPTURED", "PARTIAL"):
                plat_status.missing_items.append(
                    "Screenshots (min 3 required for App Store)"
                )
        elif platform == "android":
            if plat_status.screenshots_status not in ("CAPTURED", "PARTIAL"):
                plat_status.missing_items.append(
                    "Screenshots (min 2 required for Play Store)"
                )
            if plat_status.feature_graphic_status != "READY":
                plat_status.missing_items.append(
                    "Feature Graphic 1024x500 (required for Play Store)"
                )

        # Check metadata validation errors for required URLs
        for err in plat_status.metadata_validation_errors:
            if "privacy_url" in err or "privacy_policy_url" in err:
                plat_status.missing_items.append("Privacy Policy URL (required)")
            if "support_url" in err and platform == "ios":
                plat_status.missing_items.append(
                    "Support URL (required for App Store)"
                )

        # Determine status
        if plat_status.metadata_status == "READY" and not plat_status.missing_items:
            plat_status.status = "READY"
        elif plat_status.metadata_status in ("READY", "INCOMPLETE"):
            plat_status.status = "INCOMPLETE"
        else:
            plat_status.status = "INCOMPLETE"

        print(
            f"[Store Prep]   Status: {plat_status.status}"
            f"{' (' + str(len(plat_status.missing_items)) + ' missing items)' if plat_status.missing_items else ''}"
        )

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _find_roadbook_dir(self) -> str | None:
        """Find the K6 Roadbook output directory for AssetForge."""
        # Try project registry
        try:
            from factory.project_registry import get_project

            proj = get_project(self.project_name)
            if proj:
                k6_dir = (
                    proj.get("chapters", {})
                    .get("kapitel6", {})
                    .get("output_dir")
                )
                if k6_dir:
                    p = _ROOT / k6_dir if not Path(k6_dir).is_absolute() else Path(k6_dir)
                    if p.is_dir():
                        return str(p)
        except ImportError:
            pass

        # Glob fallback
        search = _ROOT / "factory" / "roadbook_assembly" / "output"
        if search.is_dir():
            slug = self.project_name.lower().replace("-", "_")
            candidates = sorted(search.glob(f"*{slug}*"), reverse=True)
            if candidates:
                return str(candidates[0])

        return None

    @staticmethod
    def _copy_files(source_dir: str, dest_dir: str, pattern: str = "*.png") -> int:
        """Copy files matching pattern from source to dest. Returns count."""
        src = Path(source_dir)
        dst = Path(dest_dir)
        dst.mkdir(parents=True, exist_ok=True)

        count = 0
        for f in src.glob(pattern):
            if f.is_file():
                shutil.copy2(str(f), str(dst / f.name))
                count += 1
        return count

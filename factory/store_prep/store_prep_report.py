"""DriveAI Factory — Store Prep Report Generator.

Generates structured JSON reports for Store Preparation runs.
Reports track per-platform status for metadata, assets, compliance,
and screenshots.

No external dependencies — only stdlib.
"""

import json
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path


@dataclass
class PlatformPrepStatus:
    """Status for a single platform's store preparation."""

    platform: str = ""
    status: str = "PENDING"  # READY, INCOMPLETE, BLOCKED, PENDING

    # Metadata
    metadata_status: str = "PENDING"
    metadata_fields_complete: int = 0
    metadata_fields_missing: int = 0
    metadata_validation_errors: list = field(default_factory=list)

    # Assets
    icon_status: str = "PENDING"  # READY, MISSING, SKIPPED
    screenshots_status: str = "PENDING"  # CAPTURED, MISSING, SKIPPED
    screenshots_count: int = 0
    feature_graphic_status: str = "N/A"  # Only relevant for Android

    # Compliance
    compliance_status: str = "PENDING"
    compliance_checks_passed: int = 0
    compliance_checks_failed: int = 0
    compliance_checks_warning: int = 0
    privacy_label_status: str = "PENDING"  # GENERATED, SKIPPED, NEEDS_REVIEW

    # Missing items
    missing_items: list = field(default_factory=list)

    def to_dict(self) -> dict:
        """Returns all fields as a dict."""
        return {
            "platform": self.platform,
            "status": self.status,
            "metadata": {
                "status": self.metadata_status,
                "fields_complete": self.metadata_fields_complete,
                "fields_missing": self.metadata_fields_missing,
                "validation_errors": self.metadata_validation_errors,
            },
            "assets": {
                "icon_status": self.icon_status,
                "screenshots_status": self.screenshots_status,
                "screenshots_count": self.screenshots_count,
                "feature_graphic_status": self.feature_graphic_status,
            },
            "compliance": {
                "status": self.compliance_status,
                "checks_passed": self.compliance_checks_passed,
                "checks_failed": self.compliance_checks_failed,
                "checks_warning": self.compliance_checks_warning,
                "privacy_label_status": self.privacy_label_status,
            },
            "missing_items": self.missing_items,
        }


class StorePrepReport:
    """Generates and manages Store Preparation reports.

    Usage:
        report = StorePrepReport("brainpuzzle")
        ios = report.add_platform("ios")
        ios.metadata_status = "READY"
        ios.metadata_fields_complete = 12
        ios.status = "READY"
        report.evaluate_overall_status()
        report.save("factory/store_prep/output/brainpuzzle")
        report.print_summary()
    """

    def __init__(self, project_name: str) -> None:
        self.project_name = project_name
        self.timestamp = datetime.now(timezone.utc).isoformat()
        self.platforms: dict[str, PlatformPrepStatus] = {}
        self.ceo_gates_triggered: list = []
        self.warnings: list = []
        self.overall_status: str = "PENDING"
        self._saved_path: str | None = None

    # ------------------------------------------------------------------
    # Platform management
    # ------------------------------------------------------------------

    def add_platform(self, platform: str) -> PlatformPrepStatus:
        """Create and add a PlatformPrepStatus for the given platform."""
        status = PlatformPrepStatus(platform=platform)
        self.platforms[platform] = status
        return status

    def get_platform(self, platform: str) -> PlatformPrepStatus | None:
        """Return PlatformPrepStatus or None."""
        return self.platforms.get(platform)

    # ------------------------------------------------------------------
    # Gates and warnings
    # ------------------------------------------------------------------

    def add_ceo_gate(
        self, gate_type: str, status: str = "pending", decision: str = ""
    ) -> None:
        """Record a CEO gate that was triggered during Store Prep."""
        self.ceo_gates_triggered.append(
            {
                "gate_type": gate_type,
                "status": status,
                "decision": decision,
            }
        )

    def add_warning(self, warning: str) -> None:
        """Add a warning message."""
        self.warnings.append(warning)

    # ------------------------------------------------------------------
    # Evaluation
    # ------------------------------------------------------------------

    def evaluate_overall_status(self) -> str:
        """Evaluate overall status based on all platforms.

        READY:      All platforms are READY
        INCOMPLETE: At least one platform is INCOMPLETE
        BLOCKED:    At least one platform is BLOCKED
        PENDING:    No platforms evaluated yet

        Returns the overall status string.
        """
        if not self.platforms:
            self.overall_status = "PENDING"
            return self.overall_status

        statuses = [p.status for p in self.platforms.values()]

        if all(s == "READY" for s in statuses):
            self.overall_status = "READY"
        elif any(s == "BLOCKED" for s in statuses):
            self.overall_status = "BLOCKED"
        elif any(s == "INCOMPLETE" for s in statuses):
            self.overall_status = "INCOMPLETE"
        else:
            self.overall_status = "PENDING"

        return self.overall_status

    # ------------------------------------------------------------------
    # Serialization
    # ------------------------------------------------------------------

    def to_dict(self) -> dict:
        """Return the full report as a dict."""
        return {
            "project": self.project_name,
            "timestamp": self.timestamp,
            "overall_status": self.overall_status,
            "platforms": {k: v.to_dict() for k, v in self.platforms.items()},
            "ceo_gates_triggered": self.ceo_gates_triggered,
            "warnings": self.warnings,
        }

    def save(self, output_dir: str) -> str:
        """Save report to output_dir as store_prep_report.json.

        Creates output_dir if needed. Returns file path.
        """
        path = Path(output_dir) / "store_prep_report.json"
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(
            json.dumps(self.to_dict(), indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
        self._saved_path = str(path)
        print(f"[Store Prep Report] Saved to {path}")
        return str(path)

    @property
    def path(self) -> str | None:
        """Path to the saved report file, or None if not yet saved."""
        return self._saved_path

    # ------------------------------------------------------------------
    # Human-readable summary
    # ------------------------------------------------------------------

    def print_summary(self) -> None:
        """Print a human-readable summary to console."""
        p = "[Store Prep Report]"
        print(f"{p} Project: {self.project_name}")
        print(f"{p} Overall: {self.overall_status}")

        for name, plat in self.platforms.items():
            print(f"{p} ----- {name} -----")

            # Metadata
            meta_detail = ""
            total = plat.metadata_fields_complete + plat.metadata_fields_missing
            if total > 0:
                meta_detail = f" ({plat.metadata_fields_complete}/{total} fields)"
            print(f"{p}   Metadata: {plat.metadata_status}{meta_detail}")

            # Icon
            print(f"{p}   Icon: {plat.icon_status}")

            # Screenshots
            scr_detail = f" ({plat.screenshots_count} captured)"
            print(f"{p}   Screenshots: {plat.screenshots_status}{scr_detail}")

            # Compliance
            comp_detail = (
                f" ({plat.compliance_checks_passed} passed, "
                f"{plat.compliance_checks_failed} failed, "
                f"{plat.compliance_checks_warning} warning)"
            )
            print(f"{p}   Compliance: {plat.compliance_status}{comp_detail}")

            # Privacy Label
            print(f"{p}   Privacy Label: {plat.privacy_label_status}")

            # Feature Graphic (Android only)
            if name == "android":
                print(
                    f"{p}   Feature Graphic: {plat.feature_graphic_status}"
                )

            # Platform status
            print(f"{p}   Status: {plat.status}")

            # Missing items
            if plat.missing_items:
                for item in plat.missing_items:
                    print(f"{p}   Missing: {item}")

        # Warnings
        if self.warnings:
            print(f"{p} ----- Warnings -----")
            for w in self.warnings:
                print(f"{p}   {w}")

        # CEO Gates
        if self.ceo_gates_triggered:
            print(f"{p} ----- CEO Gates -----")
            for g in self.ceo_gates_triggered:
                print(
                    f"{p}   {g['gate_type']}: {g['status']}"
                    f"{' -> ' + g['decision'] if g['decision'] else ''}"
                )

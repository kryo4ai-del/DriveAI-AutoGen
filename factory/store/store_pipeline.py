"""Store Submission Pipeline — coordinates metadata, compliance, packaging, submission."""
import os
from pathlib import Path
from .metadata_generator import MetadataGenerator
from .compliance_checker import ComplianceChecker
from .build_packager import BuildPackager
from .submission_preparer import SubmissionPreparer
from .readiness_report import ReadinessReport

_ROOT = Path(__file__).resolve().parent.parent.parent


class StorePipeline:
    """Coordinates the full store submission flow."""

    def __init__(self, project_name: str):
        self.project_name = project_name
        self.project_dir = _ROOT / "projects" / project_name

    def run(self, platform: str = "all") -> dict:
        """Run the full store pipeline."""
        platforms = self._resolve_platforms(platform)
        results = {}

        for plat in platforms:
            print(f"\n{'='*60}")
            print(f"  Store Pipeline: {self.project_name} ({plat})")
            print(f"{'='*60}")

            # 1. Metadata
            print("\n  [1/5] Generating metadata...")
            meta_gen = MetadataGenerator(self.project_name)
            metadata = meta_gen.generate(plat)
            results[f"{plat}_metadata"] = metadata is not None

            # 2. Compliance
            print("  [2/5] Checking compliance...")
            checker = ComplianceChecker(self.project_name)
            compliance = checker.check(plat)
            results[f"{plat}_compliance"] = compliance.summary()

            # 3. Package
            print("  [3/5] Building package...")
            packager = BuildPackager(self.project_name)
            package = packager.package(plat)
            results[f"{plat}_package"] = package

            # 4. Prepare submission
            print("  [4/5] Preparing submission folder...")
            preparer = SubmissionPreparer(self.project_name)
            submission = preparer.prepare(plat, metadata, compliance)
            results[f"{plat}_submission"] = submission

            # 5. Readiness report
            print("  [5/5] Generating readiness report...")

        # Overall readiness
        report = ReadinessReport(self.project_name)
        readiness = report.generate(platforms)
        results["readiness_report"] = readiness
        print(readiness)

        return results

    def _resolve_platforms(self, platform: str) -> list[str]:
        """Resolve 'all' to actual active platforms from project config."""
        if platform != "all":
            return [platform]
        try:
            from factory.project_config import load_project_config
            config = load_project_config(self.project_name)
            return config.get_active_lines()
        except Exception:
            return ["ios"]

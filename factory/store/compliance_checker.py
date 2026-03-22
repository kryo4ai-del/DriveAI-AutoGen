"""Store compliance checker — catches rejection reasons before submission."""
import os
import re
from dataclasses import dataclass, field
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


@dataclass
class ComplianceIssue:
    severity: str          # "blocking", "warning", "info"
    guideline: str
    description: str
    fix_suggestion: str
    auto_fixable: bool = False

@dataclass
class ComplianceReport:
    platform: str
    issues: list[ComplianceIssue] = field(default_factory=list)

    @property
    def blocking_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == "blocking")

    @property
    def warning_count(self) -> int:
        return sum(1 for i in self.issues if i.severity == "warning")

    @property
    def ready(self) -> bool:
        return self.blocking_count == 0

    def summary(self) -> str:
        status = "READY" if self.ready else f"NOT READY ({self.blocking_count} blockers)"
        return f"{self.platform}: {status}, {self.warning_count} warnings"

    def save(self, output_dir: str):
        out = Path(output_dir)
        out.mkdir(parents=True, exist_ok=True)
        lines = [f"# Compliance Report: {self.platform}\n"]
        lines.append(f"Status: {'READY' if self.ready else 'NOT READY'}\n")
        lines.append(f"Blocking: {self.blocking_count}, Warnings: {self.warning_count}\n\n")
        for issue in self.issues:
            icon = {"blocking": "BLOCK", "warning": "WARN", "info": "INFO"}[issue.severity]
            lines.append(f"- [{icon}] {issue.guideline}: {issue.description}\n")
            lines.append(f"  Fix: {issue.fix_suggestion}\n\n")
        (out / "compliance_report.md").write_text("".join(lines), encoding="utf-8")
        print(f"    Compliance report saved")


class ComplianceChecker:
    """Deterministic compliance checks — no LLM."""

    def __init__(self, project_name: str):
        self.project_name = project_name
        self.project_dir = _ROOT / "projects" / project_name

    def check(self, platform: str) -> ComplianceReport:
        if platform == "ios":
            return self._check_ios()
        elif platform == "android":
            return self._check_android()
        elif platform == "web":
            return self._check_web()
        return ComplianceReport(platform=platform)

    def _check_ios(self) -> ComplianceReport:
        report = ComplianceReport(platform="ios")
        # Icon
        icon_found = any(self.project_dir.rglob("AppIcon*")) or any(self.project_dir.rglob("*1024*"))
        if not icon_found:
            report.issues.append(ComplianceIssue("blocking", "Apple 2.1", "App Icon (1024x1024) missing",
                                                  "Create 1024x1024 PNG icon", False))
        # Privacy policy
        privacy = list(self.project_dir.rglob("*privacy*")) + list(self.project_dir.rglob("*PRIVACY*"))
        if not privacy:
            report.issues.append(ComplianceIssue("blocking", "Apple 5.1.1",
                                                  "Privacy policy missing", "Generate with --store-prepare", True))
        # Xcode project
        xcodeproj = list(self.project_dir.rglob("*.xcodeproj"))
        if not xcodeproj:
            report.issues.append(ComplianceIssue("blocking", "Build",
                                                  "Xcode project not found", "Run xcodegen or create .xcodeproj", False))
        # Placeholder content check
        self._check_placeholder_content(report, [".swift"])
        # Developer account
        report.issues.append(ComplianceIssue("info", "Apple Dev Account",
                                              "Apple Developer account needed ($99/year)",
                                              "Register at developer.apple.com", False))
        return report

    def _check_android(self) -> ComplianceReport:
        report = ComplianceReport(platform="android")
        # Build files
        gradle = list(self.project_dir.rglob("build.gradle*"))
        if not gradle:
            report.issues.append(ComplianceIssue("blocking", "Build",
                                                  "Gradle build files missing", "Run assembly first", False))
        # Manifest
        manifest = list(self.project_dir.rglob("AndroidManifest.xml"))
        if not manifest:
            report.issues.append(ComplianceIssue("blocking", "Build",
                                                  "AndroidManifest.xml missing", "Run assembly first", False))
        # Icon
        icons = list(self.project_dir.rglob("ic_launcher*"))
        if not icons:
            report.issues.append(ComplianceIssue("warning", "Play Store",
                                                  "App icon not found in res/", "Add launcher icons", False))
        # Privacy
        privacy = list(self.project_dir.rglob("*privacy*")) + list(self.project_dir.rglob("*PRIVACY*"))
        if not privacy:
            report.issues.append(ComplianceIssue("warning", "Play 4.1",
                                                  "Privacy policy recommended", "Generate with --store-prepare", True))
        # Target SDK
        for g in gradle:
            try:
                content = g.read_text(encoding="utf-8")
                m = re.search(r"targetSdk\s*=\s*(\d+)", content)
                if m and int(m.group(1)) < 33:
                    report.issues.append(ComplianceIssue("blocking", "Play Target SDK",
                                                          f"targetSdk {m.group(1)} too low (min 33)",
                                                          "Update targetSdk to 34", True))
            except Exception:
                pass
        return report

    def _check_web(self) -> ComplianceReport:
        report = ComplianceReport(platform="web")
        pkg = self.project_dir / "package.json"
        if not pkg.exists():
            report.issues.append(ComplianceIssue("blocking", "Build", "package.json missing",
                                                  "Run assembly first", False))
        # Meta tags in layout
        layouts = list(self.project_dir.rglob("layout.tsx")) + list(self.project_dir.rglob("layout.jsx"))
        if not layouts:
            report.issues.append(ComplianceIssue("warning", "SEO", "Root layout.tsx not found",
                                                  "Create src/app/layout.tsx with meta tags", False))
        return report

    def _check_placeholder_content(self, report: ComplianceReport, extensions: list[str]):
        """Scan for placeholder text that would trigger rejection."""
        placeholders = ["lorem ipsum", "TODO:", "FIXME:", "placeholder", "sample data"]
        for ext in extensions:
            for f in self.project_dir.rglob(f"*{ext}"):
                if "quarantine" in str(f) or "test" in str(f).lower():
                    continue
                try:
                    content = f.read_text(encoding="utf-8", errors="ignore").lower()
                    for ph in placeholders:
                        if ph.lower() in content:
                            report.issues.append(ComplianceIssue("warning", "Apple 2.1",
                                f"Placeholder '{ph}' found in {f.name}",
                                f"Remove placeholder content from {f.name}", False))
                            break
                except Exception:
                    pass

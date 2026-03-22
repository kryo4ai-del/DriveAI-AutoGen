"""CEO-readable store readiness assessment."""
import os
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


class ReadinessReport:
    """Generates a comprehensive readiness report."""

    def __init__(self, project_name: str):
        self.project_name = project_name
        self.project_dir = _ROOT / "projects" / project_name

    def generate(self, platforms: list[str] | None = None) -> str:
        """Generate full readiness report."""
        if not platforms:
            platforms = ["ios"]

        lines = [
            f"\n{'='*60}",
            f"  Store Readiness Report: {self.project_name}",
            f"{'='*60}\n",
        ]

        total_items = 0
        done_items = 0

        for platform in platforms:
            items = self._check_items(platform)
            p_done = sum(1 for _, status, _ in items if status)
            total_items += len(items)
            done_items += p_done
            pct = int(p_done / len(items) * 100) if items else 0

            lines.append(f"  {platform.upper()}: {pct}% Ready ({p_done}/{len(items)} items)")
            lines.append(f"  {'─'*56}")
            lines.append(f"  {'Item':<30} {'Status':<8} {'Action'}")
            lines.append(f"  {'─'*56}")

            for name, status, action in items:
                icon = "OK" if status else "MISSING"
                lines.append(f"  {name:<30} {icon:<8} {action}")

            lines.append("")

        overall = int(done_items / total_items * 100) if total_items else 0
        lines.insert(3, f"  Overall: {overall}% Ready\n")

        # Manual steps
        lines.append(f"  {'─'*56}")
        lines.append("  Manual Steps Required:")
        manual = self._get_manual_steps(platforms)
        for i, step in enumerate(manual, 1):
            lines.append(f"    {i}. {step}")
        lines.append(f"{'='*60}\n")

        report = "\n".join(lines)

        # Save
        out = self.project_dir / "store_submission"
        out.mkdir(parents=True, exist_ok=True)
        (out / "READINESS_REPORT.md").write_text(report, encoding="utf-8")

        return report

    def _check_items(self, platform: str) -> list[tuple[str, bool, str]]:
        """Check each readiness item. Returns (name, done, action_if_not_done)."""
        items = []
        p = self.project_dir

        # Code compiled
        code_files = list(p.rglob("*.swift")) + list(p.rglob("*.kt")) + list(p.rglob("*.ts"))
        items.append(("Code files", len(code_files) > 10, f"{len(code_files)} files" if code_files else "No code"))

        # App Icon
        icon = any(p.rglob("AppIcon*")) or any(p.rglob("ic_launcher*")) or any(p.rglob("*1024*png"))
        items.append(("App Icon", icon, "—" if icon else "Create icon"))

        # Privacy Policy
        privacy = any(p.rglob("*privacy*")) or any(p.rglob("*PRIVACY*"))
        items.append(("Privacy Policy", privacy, "—" if privacy else "Generate"))

        # Description
        desc = any(p.rglob("*METADATA*")) or any(p.rglob("*description*"))
        items.append(("Store Description", desc, "—" if desc else "Generate"))

        # Screenshots
        screenshots = any(p.rglob("*screenshot*")) or any(p.rglob("*Screenshot*"))
        items.append(("Screenshots", screenshots, "—" if screenshots else "Capture"))

        if platform == "ios":
            xcodeproj = any(p.rglob("*.xcodeproj"))
            items.append(("Xcode Project", xcodeproj, "—" if xcodeproj else "Create"))
            items.append(("Developer Account", False, "Register ($99/year)"))
            items.append(("Code Signing", False, "Configure in Xcode"))

        elif platform == "android":
            gradle = any(p.rglob("build.gradle*"))
            items.append(("Gradle Build", gradle, "—" if gradle else "Run assembly"))
            manifest = any(p.rglob("AndroidManifest.xml"))
            items.append(("AndroidManifest", manifest, "—" if manifest else "Run assembly"))
            items.append(("Play Developer Account", False, "Register ($25)"))
            items.append(("Signing Keystore", False, "Create keystore"))

        elif platform == "web":
            pkg = (p / "package.json").exists()
            items.append(("package.json", pkg, "—" if pkg else "Run assembly"))
            items.append(("Domain/Hosting", False, "Set up Vercel/Netlify"))

        return items

    def _get_manual_steps(self, platforms: list[str]) -> list[str]:
        steps = []
        if "ios" in platforms:
            steps.extend([
                "Register Apple Developer Account ($99/year)",
                "Create App Icon (1024x1024 PNG)",
                "Build on Mac with Xcode",
                "Upload via App Store Connect",
            ])
        if "android" in platforms:
            steps.extend([
                "Register Google Play Developer Account ($25)",
                "Create App Icon (adaptive icon)",
                "Build AAB with Gradle",
                "Upload via Play Console",
            ])
        if "web" in platforms:
            steps.extend([
                "Set up domain and hosting",
                "Deploy with npm run build",
            ])
        return steps

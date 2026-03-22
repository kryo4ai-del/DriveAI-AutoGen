"""Submission preparer — organizes all files for store submission."""
import json
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


class SubmissionPreparer:
    """Prepares submission-ready folder with all required files."""

    def __init__(self, project_name: str):
        self.project_name = project_name
        self.project_dir = _ROOT / "projects" / project_name

    def prepare(self, platform: str, metadata=None, compliance=None) -> dict:
        out_dir = self.project_dir / "store_submission" / platform
        out_dir.mkdir(parents=True, exist_ok=True)

        # Save metadata
        if metadata:
            metadata.save(str(out_dir), platform)

        # Save compliance
        if compliance:
            compliance.save(str(out_dir))

        # Generate checklist
        self._generate_checklist(out_dir, platform, compliance)

        # Screenshots spec
        self._generate_screenshot_spec(out_dir, platform)

        print(f"    Submission folder: {out_dir}")
        return {"output_dir": str(out_dir), "status": "prepared"}

    def _generate_checklist(self, out_dir: Path, platform: str, compliance=None):
        lines = [f"# Submission Checklist: {self.project_name} ({platform})\n\n"]

        if platform == "ios":
            steps = [
                ("Apple Developer Account", "Register at developer.apple.com ($99/year)", compliance and not any(i.guideline == "Apple Dev Account" for i in compliance.issues)),
                ("App Icon 1024x1024", "Create and add to Asset Catalog", False),
                ("Screenshots (6.7, 6.1, 5.5 inch)", "Capture from simulator", False),
                ("App Store Description", "Write in App Store Connect", True),
                ("Keywords", "Add in App Store Connect (max 100 chars)", True),
                ("Privacy Policy URL", "Host privacy policy, add URL", False),
                ("Xcode Archive", "Product > Archive in Xcode", False),
                ("App Store Connect Upload", "Via Xcode or Transporter", False),
                ("TestFlight Beta Test", "At least 1 internal tester", False),
                ("Submit for Review", "Submit in App Store Connect", False),
            ]
        elif platform == "android":
            steps = [
                ("Google Play Developer Account", "Register at play.google.com/console ($25 one-time)", False),
                ("App Icon (512x512)", "Create adaptive icon", False),
                ("Feature Graphic (1024x500)", "Create for Play Store listing", False),
                ("Screenshots (phone + tablet)", "Capture from emulator", False),
                ("Store Listing", "Fill in Play Console", True),
                ("Content Rating", "Complete questionnaire in Play Console", False),
                ("Data Safety", "Fill data safety section", False),
                ("Signing Key", "Create release keystore", False),
                ("App Bundle (AAB)", "Build with gradle bundleRelease", False),
                ("Internal Testing Track", "Upload for testing", False),
                ("Submit for Review", "Promote to production", False),
            ]
        else:
            steps = [
                ("Domain", "Register or use Vercel/Netlify subdomain", False),
                ("Build", "npm run build", False),
                ("Deploy", "Push to hosting platform", False),
                ("SSL/HTTPS", "Ensure HTTPS is active", False),
                ("Meta Tags", "Verify OG tags for social sharing", False),
            ]

        for name, desc, done in steps:
            check = "x" if done else " "
            lines.append(f"- [{check}] **{name}**: {desc}\n")

        (out_dir / "CHECKLIST.md").write_text("".join(lines), encoding="utf-8")

    def _generate_screenshot_spec(self, out_dir: Path, platform: str):
        specs = []
        screens = ["Home", "Training", "Exam Simulation", "Skill Map", "Readiness Score", "Results"]

        if platform == "ios":
            for screen in screens:
                specs.append({"screen": screen, "devices": ["iPhone 15 Pro Max (6.7\")", "iPhone 15 (6.1\")", "iPhone SE (4.7\")"]})
        elif platform == "android":
            for screen in screens:
                specs.append({"screen": screen, "devices": ["Pixel 8 Pro", "Pixel 8", "Tablet"]})
        else:
            for screen in screens:
                specs.append({"screen": screen, "devices": ["Desktop (1280x720)", "Mobile (375x812)"]})

        ss_dir = out_dir / "screenshots"
        ss_dir.mkdir(exist_ok=True)
        (ss_dir / "screenshot_spec.json").write_text(json.dumps(specs, indent=2), encoding="utf-8")

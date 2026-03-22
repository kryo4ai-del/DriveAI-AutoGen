"""Store metadata generator — app name, description, keywords, privacy."""
import json
import os
import re
from dataclasses import dataclass, field
from pathlib import Path

_ROOT = Path(__file__).resolve().parent.parent.parent


@dataclass
class StoreMetadata:
    app_name: str = ""
    subtitle: str = ""
    description_de: str = ""
    description_en: str = ""
    keywords: str = ""
    category_primary: str = ""
    category_secondary: str = ""
    age_rating: str = "4+"
    privacy_url: str = ""
    support_url: str = ""
    whats_new: str = "Initial release"
    privacy_policy: str = ""
    platforms: list[str] = field(default_factory=list)
    version: str = "1.0.0"

    def save(self, output_dir: str, platform: str):
        out = Path(output_dir)
        out.mkdir(parents=True, exist_ok=True)
        # metadata.json
        (out / "metadata.json").write_text(json.dumps({
            "app_name": self.app_name,
            "subtitle": self.subtitle,
            "version": self.version,
            "category": self.category_primary,
            "age_rating": self.age_rating,
            "privacy_url": self.privacy_url,
            "support_url": self.support_url,
        }, indent=2, ensure_ascii=False), encoding="utf-8")
        # Descriptions
        if self.description_de:
            (out / "description_de.txt").write_text(self.description_de, encoding="utf-8")
        if self.description_en:
            (out / "description_en.txt").write_text(self.description_en, encoding="utf-8")
        # Keywords
        if self.keywords:
            (out / "keywords.txt").write_text(self.keywords, encoding="utf-8")
        # Privacy policy
        if self.privacy_policy:
            (out / "privacy_policy.md").write_text(self.privacy_policy, encoding="utf-8")
        print(f"    Metadata saved to {out}")


class MetadataGenerator:
    """Generates store metadata from project config and code analysis."""

    def __init__(self, project_name: str):
        self.project_name = project_name
        self.project_dir = _ROOT / "projects" / project_name

    def generate(self, platform: str) -> StoreMetadata:
        """Generate complete metadata."""
        config = self._load_project_config()
        meta = StoreMetadata(
            app_name=config.get("name", self.project_name),
            subtitle=config.get("description", "")[:30],
            version=config.get("version", "1.0.0"),
            platforms=[platform],
        )

        # Check for existing metadata files
        existing_meta = self.project_dir / "APP_STORE_METADATA.md"
        if existing_meta.exists():
            self._parse_existing_metadata(existing_meta, meta)
            print(f"    Loaded existing metadata from APP_STORE_METADATA.md")

        # Generate privacy policy from code analysis
        meta.privacy_policy = self._generate_privacy_policy()

        # Keywords
        if not meta.keywords:
            meta.keywords = self._generate_keywords(config)

        # Category
        if not meta.category_primary:
            meta.category_primary = self._infer_category(config)

        # Description fallback
        if not meta.description_de and not meta.description_en:
            meta.description_en = f"{meta.app_name} — {config.get('description', 'An app built by DriveAI Factory.')}"
            meta.description_de = meta.description_en

        # Save
        submission_dir = self.project_dir / "store_submission" / platform
        meta.save(str(submission_dir), platform)

        return meta

    def _load_project_config(self) -> dict:
        config_path = self.project_dir / "project.yaml"
        if config_path.exists():
            try:
                import yaml
                with open(config_path, encoding="utf-8") as f:
                    data = yaml.safe_load(f)
                return data.get("project", {})
            except Exception:
                pass
        return {"name": self.project_name}

    def _parse_existing_metadata(self, path: Path, meta: StoreMetadata):
        """Parse APP_STORE_METADATA.md if it exists."""
        content = path.read_text(encoding="utf-8")
        # Extract app name
        m = re.search(r"App[- ]Name[:\s]+(.+)", content, re.IGNORECASE)
        if m:
            meta.app_name = m.group(1).strip().strip('"')
        # Extract subtitle
        m = re.search(r"Subtitle[:\s]+(.+)", content, re.IGNORECASE)
        if m:
            meta.subtitle = m.group(1).strip().strip('"')[:30]
        # Extract keywords
        m = re.search(r"Keywords[:\s]+(.+)", content, re.IGNORECASE)
        if m:
            meta.keywords = m.group(1).strip()[:100]
        # Extract description (multi-line, between markers)
        m = re.search(r"Beschreibung.*?\n([\s\S]*?)(?=\n##|\Z)", content, re.IGNORECASE)
        if m:
            meta.description_de = m.group(1).strip()[:4000]

    def _generate_privacy_policy(self) -> str:
        """Analyze code to generate appropriate privacy policy."""
        has_network = False
        has_analytics = False
        has_local_storage = False

        for ext in ["*.swift", "*.kt", "*.ts", "*.tsx", "*.cs"]:
            for f in self.project_dir.rglob(ext):
                if "quarantine" in str(f) or "node_modules" in str(f) or "test" in str(f).lower():
                    continue
                try:
                    content = f.read_text(encoding="utf-8", errors="ignore")
                    if any(kw in content for kw in ["URLSession", "fetch(", "HttpClient", "retrofit", "axios", "UnityWebRequest"]):
                        has_network = True
                    if any(kw in content for kw in ["Analytics", "Firebase", "Amplitude", "Mixpanel"]):
                        has_analytics = True
                    if any(kw in content for kw in ["UserDefaults", "DataStore", "localStorage", "PlayerPrefs", "Room"]):
                        has_local_storage = True
                except Exception:
                    continue

        if not has_network and not has_analytics:
            return (
                "# Privacy Policy\n\n"
                "This app does not collect, store, or transmit any personal data.\n"
                "All data is stored locally on your device and never leaves it.\n\n"
                "## Data Collection\n- No personal data collected\n- No analytics\n- No tracking\n- No advertisements\n\n"
                "## Local Storage\n"
                + ("This app stores your progress locally on your device using standard system storage. "
                   "This data is not accessible to us or any third party.\n" if has_local_storage else
                   "This app does not store any data.\n")
                + "\n## Contact\nFor questions about this privacy policy, contact: support@driveai.app\n"
            )
        else:
            sections = ["# Privacy Policy\n"]
            if has_network:
                sections.append("## Data Transmission\nThis app may connect to the internet for functionality.\n")
            if has_analytics:
                sections.append("## Analytics\nThis app uses analytics to improve the user experience.\n")
            if has_local_storage:
                sections.append("## Local Storage\nThis app stores data locally on your device.\n")
            sections.append("\n## Contact\nsupport@driveai.app\n")
            return "\n".join(sections)

    def _generate_keywords(self, config: dict) -> str:
        desc = config.get("description", "")
        keywords = []
        keyword_candidates = ["app", "learning", "training", "exam", "quiz", "study",
                              "driver", "license", "driving", "practice", "test",
                              "game", "match", "puzzle", "score", "fitness"]
        for kw in keyword_candidates:
            if kw.lower() in desc.lower():
                keywords.append(kw)
        return ",".join(keywords[:10]) if keywords else "app,mobile"

    def _infer_category(self, config: dict) -> str:
        desc = (config.get("description", "") + " " + config.get("name", "")).lower()
        if any(w in desc for w in ["game", "match", "puzzle", "play"]):
            return "Games"
        if any(w in desc for w in ["learn", "study", "exam", "education", "quiz"]):
            return "Education"
        if any(w in desc for w in ["fitness", "health", "workout"]):
            return "Health & Fitness"
        if any(w in desc for w in ["finance", "trading", "crypto"]):
            return "Finance"
        return "Utilities"

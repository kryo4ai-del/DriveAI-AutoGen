# bootstrap_manager.py
# Creates new project structures from validated ideas.
# Generates folders, PROJECT.md, roadmap.md, spec placeholders, and project metadata.

import json
import os
from datetime import date

_BOOTSTRAP_DIR = os.path.dirname(__file__)
_STORE_PATH = os.path.join(_BOOTSTRAP_DIR, "project_store.json")
_PROJECTS_ROOT = os.path.join(_BOOTSTRAP_DIR, "workspaces")

VALID_CATEGORIES = (
    "ios_app",
    "android_app",
    "web_app",
    "saas",
    "tool",
    "library",
    "content_product",
    "experiment",
)

VALID_PLATFORMS = (
    "ios",
    "ipad",
    "watchos",
    "android",
    "web",
    "cross_platform",
    "backend",
    "cli",
    "multi",
)

VALID_STATUSES = (
    "created",
    "planning",
    "in_development",
    "mvp_complete",
    "released",
    "paused",
    "archived",
)


def _load_json(path: str) -> dict:
    try:
        with open(path, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {}


def _save_json(path: str, data: dict) -> None:
    os.makedirs(os.path.dirname(os.path.abspath(path)), exist_ok=True)
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)


class BootstrapManager:
    """Creates and manages bootstrapped project structures."""

    def __init__(self):
        self.data = _load_json(_STORE_PATH)
        self.data.setdefault("projects", [])

    def save(self) -> None:
        _save_json(_STORE_PATH, self.data)

    @property
    def projects(self) -> list[dict]:
        return self.data["projects"]

    def _next_id(self) -> str:
        max_num = 0
        for proj in self.projects:
            id_str = proj.get("project_id", "")
            if id_str.startswith("PROJ-"):
                try:
                    num = int(id_str.split("-")[1])
                    max_num = max(max_num, num)
                except (IndexError, ValueError):
                    pass
        return f"PROJ-{max_num + 1:03d}"

    def _slugify(self, name: str) -> str:
        """Convert project name to folder-safe slug."""
        return name.lower().replace(" ", "-").replace("_", "-")

    def _validate_platforms(self, platforms: list[str]) -> None:
        for p in platforms:
            if p not in VALID_PLATFORMS:
                raise ValueError(f"Invalid platform: {p}. Valid: {VALID_PLATFORMS}")

    def create_project(
        self,
        name: str,
        description: str = "",
        category: str = "ios_app",
        platform: str = "ios",
        secondary_platforms: list[str] | None = None,
        linked_idea: str = "",
        notes: str = "",
    ) -> dict:
        if category not in VALID_CATEGORIES:
            raise ValueError(f"Invalid category: {category}. Valid: {VALID_CATEGORIES}")
        if platform not in VALID_PLATFORMS:
            raise ValueError(f"Invalid platform: {platform}. Valid: {VALID_PLATFORMS}")
        if secondary_platforms:
            self._validate_platforms(secondary_platforms)

        project = {
            "project_id": self._next_id(),
            "name": name,
            "slug": self._slugify(name),
            "description": description,
            "category": category,
            "platform": platform,
            "secondary_platforms": secondary_platforms or [],
            "status": "created",
            "linked_idea": linked_idea,
            "created_at": date.today().isoformat(),
            "notes": notes,
        }
        self.projects.append(project)
        self.save()
        return project

    def create_from_idea(self, idea: dict, **overrides) -> dict:
        """Create a project directly from an idea record."""
        return self.create_project(
            name=overrides.get("name", idea.get("title", "Untitled")),
            description=overrides.get("description", idea.get("description", "")),
            category=overrides.get("category", "ios_app"),
            platform=overrides.get("platform", "ios"),
            secondary_platforms=overrides.get("secondary_platforms"),
            linked_idea=idea.get("idea_id", ""),
            notes=overrides.get("notes", f"Bootstrapped from {idea.get('idea_id', '?')}"),
        )

    def scaffold_project(self, project_id: str) -> str:
        """Create the folder structure for a project. Returns the project path."""
        proj = self.get_project(project_id)
        if not proj:
            raise ValueError(f"Project not found: {project_id}")

        slug = proj["slug"]
        project_path = os.path.join(_PROJECTS_ROOT, slug)

        # Create folder structure
        folders = [
            project_path,
            os.path.join(project_path, "specs"),
            os.path.join(project_path, "content"),
            os.path.join(project_path, "compliance"),
        ]
        for folder in folders:
            os.makedirs(folder, exist_ok=True)

        # Generate PROJECT.md
        project_md = self._generate_project_md(proj)
        with open(os.path.join(project_path, "PROJECT.md"), "w", encoding="utf-8") as f:
            f.write(project_md)

        # Generate roadmap.md
        roadmap_md = self._generate_roadmap_md(proj)
        with open(os.path.join(project_path, "roadmap.md"), "w", encoding="utf-8") as f:
            f.write(roadmap_md)

        # Update project record with path
        proj["project_path"] = project_path
        proj["status"] = "planning"
        self.save()

        return project_path

    def _generate_project_md(self, proj: dict) -> str:
        lines = [
            f"# {proj['name']}",
            "",
            f"Project ID: {proj['project_id']}",
            f"Category: {proj['category']}",
            f"Platform: {proj['platform']}",
        ]
        if proj.get("secondary_platforms"):
            lines.append(f"Secondary Platforms: {', '.join(proj['secondary_platforms'])}")
        lines.extend([
            f"Created: {proj['created_at']}",
            f"Status: {proj['status']}",
            "",
        ])
        if proj.get("linked_idea"):
            lines.append(f"Linked Idea: {proj['linked_idea']}")
            lines.append("")
        if proj.get("description"):
            lines.append("## Description")
            lines.append("")
            lines.append(proj["description"])
            lines.append("")
        lines.extend([
            "## Architecture",
            "",
            "TBD — to be defined during planning phase.",
            "",
            "## Tech Stack",
            "",
            "TBD — to be defined based on platform and requirements.",
            "",
            "## Notes",
            "",
            proj.get("notes", ""),
            "",
        ])
        return "\n".join(lines)

    def _generate_roadmap_md(self, proj: dict) -> str:
        lines = [
            f"# {proj['name']} — Roadmap",
            "",
            f"Project: {proj['project_id']}",
            f"Created: {proj['created_at']}",
            "",
            "## Phase 1: Planning",
            "",
            "- [ ] Define core features",
            "- [ ] Create implementation specs",
            "- [ ] Legal/compliance review",
            "- [ ] Architecture decision",
            "",
            "## Phase 2: MVP",
            "",
            "- [ ] Core feature implementation",
            "- [ ] Basic UI/UX",
            "- [ ] Initial testing",
            "",
            "## Phase 3: Polish",
            "",
            "- [ ] Accessibility review",
            "- [ ] Performance optimization",
            "- [ ] Content generation",
            "",
            "## Phase 4: Release",
            "",
            "- [ ] Final testing",
            "- [ ] Store listing preparation",
            "- [ ] Release",
            "",
        ]
        return "\n".join(lines)

    def get_project(self, project_id: str) -> dict | None:
        for proj in self.projects:
            if proj.get("project_id") == project_id:
                return proj
        return None

    def get_by_idea(self, idea_id: str) -> dict | None:
        for proj in self.projects:
            if proj.get("linked_idea") == idea_id:
                return proj
        return None

    def update_project(self, project_id: str, **fields) -> dict | None:
        proj = self.get_project(project_id)
        if not proj:
            return None
        for key, value in fields.items():
            if key in proj and key != "project_id":
                proj[key] = value
        self.save()
        return proj

    def transition(self, project_id: str, new_status: str) -> dict | None:
        if new_status not in VALID_STATUSES:
            raise ValueError(f"Invalid status: {new_status}. Valid: {VALID_STATUSES}")
        return self.update_project(project_id, status=new_status)

    def by_status(self, status: str) -> list[dict]:
        return [p for p in self.projects if p.get("status") == status]

    def by_category(self, category: str) -> list[dict]:
        return [p for p in self.projects if p.get("category") == category]

    def by_platform(self, platform: str) -> list[dict]:
        return [p for p in self.projects if p.get("platform") == platform]

    def active(self) -> list[dict]:
        return [p for p in self.projects if p.get("status") not in ("paused", "archived")]

    def get_summary(self) -> str:
        total = len(self.projects)
        if total == 0:
            return "Bootstrap -- total: 0 projects"
        active = self.active()
        by_status = {}
        for proj in active:
            s = proj.get("status", "?")
            by_status[s] = by_status.get(s, 0) + 1
        status_str = ", ".join(f"{k}: {v}" for k, v in sorted(by_status.items()))
        return f"Bootstrap -- total: {total}  active: {len(active)}  ({status_str})"

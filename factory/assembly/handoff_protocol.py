"""Production → Assembly handoff protocol."""

import json
import os
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path

_PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent


@dataclass
class ProductionHandoff:
    """Formal handoff from Production to Assembly."""

    project_name: str
    platform: str = ""
    language: str = ""

    # What was produced
    source_directory: str = ""
    total_files: int = 0
    file_manifest: list[str] = field(default_factory=list)

    # Production quality summary
    features_completed: list[str] = field(default_factory=list)
    layers_completed: int = 0
    blocking_issues: int = 0
    quality_gate_status: str = "UNKNOWN"

    # What Assembly needs to do
    assembly_tasks: list[str] = field(default_factory=list)

    # Metadata
    production_run_id: str = ""
    timestamp: str = ""
    brain_entries_created: list[str] = field(default_factory=list)

    def is_ready_for_assembly(self) -> bool:
        """Check if production output meets assembly requirements."""
        return (
            self.blocking_issues == 0
            and self.quality_gate_status in ("CLEAN", "WARNINGS")
            and self.total_files > 0
        )

    def save(self, path: str) -> None:
        """Save handoff document to JSON."""
        os.makedirs(os.path.dirname(path), exist_ok=True)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(self.to_dict(), f, indent=2, ensure_ascii=False)

    @classmethod
    def load(cls, path: str) -> "ProductionHandoff":
        """Load handoff document."""
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
        return cls(**{k: v for k, v in data.items() if k != "_summary"})

    def to_dict(self) -> dict:
        return {
            "project_name": self.project_name,
            "platform": self.platform,
            "language": self.language,
            "source_directory": self.source_directory,
            "total_files": self.total_files,
            "file_manifest": self.file_manifest,
            "features_completed": self.features_completed,
            "layers_completed": self.layers_completed,
            "blocking_issues": self.blocking_issues,
            "quality_gate_status": self.quality_gate_status,
            "assembly_tasks": self.assembly_tasks,
            "production_run_id": self.production_run_id,
            "timestamp": self.timestamp,
            "brain_entries_created": self.brain_entries_created,
        }

    def summary(self) -> str:
        """Human-readable handoff summary."""
        ready = "READY" if self.is_ready_for_assembly() else "NOT READY"
        lines = [
            "=" * 60,
            "  Production → Assembly Handoff",
            "=" * 60,
            f"  Project    : {self.project_name}",
            f"  Platform   : {self.platform} / {self.language}",
            f"  Files      : {self.total_files}",
            f"  Features   : {', '.join(self.features_completed) or 'none'}",
            f"  Layers     : {self.layers_completed}",
            f"  Blocking   : {self.blocking_issues}",
            f"  Gate Status: {self.quality_gate_status}",
            f"  Assembly   : {ready}",
            "",
            "  Assembly Tasks:",
        ]
        for t in self.assembly_tasks:
            lines.append(f"    - {t}")
        lines.append("=" * 60)
        return "\n".join(lines)


def create_handoff_from_project(project_name: str) -> ProductionHandoff:
    """Scan a project's production output and create a handoff document."""
    project_dir = _PROJECT_ROOT / "projects" / project_name

    # Load project config
    platform = "ios"
    language = "swift"
    try:
        from factory.project_config import load_project_config

        config = load_project_config(project_name)
        active = config.get_active_lines()
        if active:
            platform = active[0]
            line_cfg = config.lines.get(platform)
            language = getattr(line_cfg, "language", "swift") if line_cfg else "swift"
    except Exception:
        pass

    # File extension mapping
    ext_map = {"swift": ".swift", "kotlin": ".kt", "typescript": (".ts", ".tsx"), "python": ".py"}
    extensions = ext_map.get(language, ".swift")
    if isinstance(extensions, str):
        extensions = (extensions,)

    # Scan files
    manifest = []
    if project_dir.is_dir():
        for f in sorted(project_dir.rglob("*")):
            if f.is_file() and any(f.name.endswith(e) for e in extensions):
                # Skip quarantine
                try:
                    f.relative_to(project_dir / "quarantine")
                    continue
                except ValueError:
                    pass
                manifest.append(str(f.relative_to(project_dir)))

    # Load build spec features
    features = []
    spec_path = project_dir / "specs" / "build_spec.yaml"
    if spec_path.is_file():
        try:
            import yaml

            with open(spec_path, encoding="utf-8") as sf:
                spec = yaml.safe_load(sf)
            features = [feat["name"] for feat in spec.get("features", [])]
        except Exception:
            pass

    # Load hygiene status
    hygiene_path = _PROJECT_ROOT / "factory" / "reports" / "hygiene" / f"{project_name}_compile_hygiene.json"
    blocking = 0
    gate_status = "UNKNOWN"
    if hygiene_path.is_file():
        try:
            hdata = json.load(open(hygiene_path, encoding="utf-8"))
            blocking = hdata.get("blocking_count", 0)
            gate_status = "CLEAN" if blocking == 0 else "BLOCKING"
            if hdata.get("warning_count", 0) > 0 and blocking == 0:
                gate_status = "WARNINGS"
        except Exception:
            pass

    # Determine assembly tasks based on platform
    tasks_map = {
        "android": [
            "create_build_system (Gradle + AndroidManifest)",
            "organize_package_structure (com.driveai.askfin.*)",
            "wire_app (Application + MainActivity + NavHost + Hilt)",
            "compile (gradle assembleDebug)",
            "fix_compile_errors (up to 5 cycles)",
            "run_tests (gradle test)",
        ],
        "ios": [
            "create_build_system (xcodegen + project.yml)",
            "wire_app (App entry + NavigationStack)",
            "compile (xcodebuild)",
            "run_tests (xcodebuild test)",
        ],
        "web": [
            "create_build_system (package.json + next.config)",
            "wire_app (app/layout.tsx + routing)",
            "compile (next build)",
            "run_tests (jest)",
        ],
    }

    return ProductionHandoff(
        project_name=project_name,
        platform=platform,
        language=language,
        source_directory=str(project_dir),
        total_files=len(manifest),
        file_manifest=manifest,
        features_completed=features,
        layers_completed=len(features) * 5,
        blocking_issues=blocking,
        quality_gate_status=gate_status,
        assembly_tasks=tasks_map.get(platform, []),
        production_run_id=datetime.now().strftime("%Y%m%d_%H%M%S"),
        timestamp=datetime.now().isoformat(),
    )

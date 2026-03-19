# project_integrator.py
# Copies generated Swift files into the real Xcode project structure.

import os
import shutil
from pathlib import Path

SUBFOLDER_MAP = {
    "ViewModel": "ViewModels",
    "View": "Views",
    "Service": "Services",
    "Model": "Models",
}


def _strip_extension(filename: str) -> str:
    """Strip any known source extension from a filename."""
    for ext in (".swift", ".kt", ".ts", ".tsx", ".py"):
        if filename.endswith(ext):
            return filename[:-len(ext)]
    return filename


def _detect_target_folder(filename: str, file_path: str | None = None) -> str:
    """Detect target subfolder. Uses filename suffix first, then file content for Kotlin/TS."""
    name = _strip_extension(filename)
    for suffix, folder in SUBFOLDER_MAP.items():
        if name.endswith(suffix):
            return folder

    # Content-based routing for Kotlin/TypeScript files
    if file_path and os.path.isfile(file_path):
        ext = os.path.splitext(filename)[1]
        if ext in (".kt", ".ts", ".tsx"):
            try:
                with open(file_path, encoding="utf-8") as f:
                    head = f.read(2000)  # first 2000 chars
                if ext == ".kt":
                    if "@Composable" in head:
                        return "Views"
                    if "@HiltViewModel" in head or ": ViewModel()" in head:
                        return "ViewModels"
                    if "interface" in head and "Service" in head:
                        return "Services"
                elif ext in (".ts", ".tsx"):
                    if "export function use" in head:
                        return "hooks"
                    if "createContext" in head:
                        return "contexts"
                    if "fetch(" in head or "axios" in head:
                        return "services"
                    if ext == ".tsx":
                        return "components"
                    if "export interface" in head or "export type" in head:
                        return "types"
            except Exception:
                pass

    return "Models"


def _file_unchanged(dest: str, src: str) -> bool:
    try:
        with open(dest, encoding="utf-8") as f:
            dest_content = f.read()
        with open(src, encoding="utf-8") as f:
            src_content = f.read()
        return dest_content == src_content
    except FileNotFoundError:
        return False


GENERATED_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "generated_code")


class ProjectIntegrator:
    def __init__(self, xcode_project_path: str, file_extensions: list[str] | None = None):
        # Resolve relative to the project root (same level as main.py)
        project_root = os.path.dirname(os.path.dirname(__file__))
        self.xcode_root = os.path.join(project_root, xcode_project_path)
        self._extensions = file_extensions or [".swift"]

    def _build_project_file_index(self) -> dict[str, str]:
        """Build filename → relative_path index of all source files in the project.

        Excludes generated_code/ to avoid self-referencing.
        """
        index: dict[str, str] = {}
        root = Path(self.xcode_root)
        if not root.is_dir():
            return index
        generated = Path(GENERATED_DIR).resolve()
        for ext in self._extensions:
            for src_file in root.rglob(f"*{ext}"):
                try:
                    src_file.resolve().relative_to(generated)
                    continue
                except ValueError:
                    pass
                rel = str(src_file.relative_to(root))
                index[src_file.name] = rel
        return index

    def integrate_generated_code(self, approval: str = "auto") -> dict:
        """
        approval: "auto" | "ask" | "off"
        Returns {"status": ..., "integrated": n, "unchanged": n, "skipped_existing": n}
        """
        if approval == "off":
            print()
            print("Xcode integration skipped (approval=off)")
            return {"status": "skipped", "integrated": 0, "unchanged": 0, "skipped_existing": 0}

        if approval == "ask":
            answer = input("\nIntegrate generated code into the Xcode project? [y/N] ").strip().lower()
            if answer not in ("y", "yes"):
                print("Xcode integration skipped.")
                return {"status": "skipped", "integrated": 0, "unchanged": 0, "skipped_existing": 0}

        integrated = []
        unchanged = 0
        skipped_existing = []

        if not os.path.isdir(GENERATED_DIR):
            return {"status": "integrated", "integrated": 0, "unchanged": 0, "skipped_existing": 0}

        # Build dynamic project file index — replaces static _PROTECTED_FILES
        project_files = self._build_project_file_index()

        for subfolder in os.listdir(GENERATED_DIR):
            src_dir = os.path.join(GENERATED_DIR, subfolder)
            if not os.path.isdir(src_dir):
                continue

            for filename in os.listdir(src_dir):
                if not any(filename.endswith(ext) for ext in self._extensions):
                    continue

                # --- Guard: Skip if file already exists anywhere in project ---
                if filename in project_files:
                    skipped_existing.append((filename, project_files[filename]))
                    continue

                src_path_for_routing = os.path.join(src_dir, filename)
                target_folder = _detect_target_folder(filename, file_path=src_path_for_routing)
                dest_dir = os.path.join(self.xcode_root, target_folder)
                dest_path = os.path.join(dest_dir, filename)

                src_path = os.path.join(src_dir, filename)
                os.makedirs(dest_dir, exist_ok=True)

                if _file_unchanged(dest_path, src_path):
                    unchanged += 1
                    continue

                shutil.copy2(src_path, dest_path)
                integrated.append(filename)

        print()
        print("Xcode integration completed")
        if integrated:
            print("Files integrated:")
            for name in integrated:
                print(f"  - {name}")
        else:
            print("  (no new or changed files)")

        if skipped_existing:
            print(f"Skipped ({len(skipped_existing)} already in project):")
            for name, existing_path in skipped_existing:
                print(f"  - {name} (exists: {existing_path})")

        return {
            "status": "integrated",
            "integrated": len(integrated),
            "unchanged": unchanged,
            "skipped_existing": len(skipped_existing),
        }

"""One-time migration: Enrich existing project.json files with new fields.

Adds: mode, created_at, updated_at, documents, title (if missing).
Does NOT overwrite existing data.
"""

import json
import os
from datetime import datetime
from pathlib import Path

PROJECTS_DIR = Path(__file__).parent / "projects"
FACTORY_BASE = Path(__file__).parent
DOC_SEC_DIR = FACTORY_BASE / "document_secretary" / "output"


def migrate():
    if not PROJECTS_DIR.exists():
        print("No projects directory found")
        return

    for project_dir in sorted(PROJECTS_DIR.iterdir()):
        pf = project_dir / "project.json"
        if not pf.exists():
            continue

        project = json.loads(pf.read_text(encoding="utf-8"))
        slug = project_dir.name
        changed = False

        # Add mode
        if "mode" not in project:
            project["mode"] = "vision"
            changed = True

        # Add title
        if "title" not in project or not project["title"]:
            project["title"] = slug.replace("_", " ").replace("-", " ").title()
            changed = True

        # Add timestamps
        if "created_at" not in project:
            # Try to get from earliest output dir
            earliest = project.get("updated", project.get("created", datetime.now().strftime("%Y-%m-%d")))
            project["created_at"] = earliest + "T00:00:00" if "T" not in earliest else earliest
            changed = True
        if "updated_at" not in project:
            project["updated_at"] = project.get("updated", datetime.now().strftime("%Y-%m-%dT%H:%M:%S"))
            changed = True

        # Add documents section
        if "documents" not in project:
            docs = {"idea_file": "", "reports": [], "pdfs": [], "roadbooks": []}

            # Find idea file
            idea_in_project = project_dir / "idea.md"
            idea_in_ideas = FACTORY_BASE.parent / "ideas" / f"{slug}.md"
            if idea_in_project.exists():
                docs["idea_file"] = str(idea_in_project)
            elif idea_in_ideas.exists():
                docs["idea_file"] = str(idea_in_ideas)

            # Find PDFs
            if DOC_SEC_DIR.exists():
                for f in DOC_SEC_DIR.iterdir():
                    if f.suffix == ".pdf" and slug in f.name.lower():
                        docs["pdfs"].append(str(f))

            # Find reports from chapter output dirs
            for ch_key, ch_data in project.get("chapters", {}).items():
                out_dir = ch_data.get("output_dir")
                if out_dir and Path(out_dir).exists():
                    for f in Path(out_dir).iterdir():
                        if f.suffix == ".md" and f.name != "pipeline_summary.md":
                            docs["reports"].append(str(f))

            # Find roadbooks
            k6 = project.get("chapters", {}).get("kapitel6", {})
            k6_dir = k6.get("output_dir")
            if k6_dir and Path(k6_dir).exists():
                for f in Path(k6_dir).iterdir():
                    if "roadbook" in f.name.lower():
                        docs["roadbooks"].append(str(f))

            project["documents"] = docs
            changed = True

        # Add project_type and archived if missing
        if "project_type" not in project:
            if "test" in slug:
                project["project_type"] = "test"
            else:
                project["project_type"] = "production"
            changed = True
        if "archived" not in project:
            project["archived"] = False
            changed = True

        # Ensure chapters has gate entries
        chapters = project.setdefault("chapters", {})
        if "ceo_gate" not in chapters:
            gate_data = project.get("gates", {}).get("ceo_gate", {})
            chapters["ceo_gate"] = {
                "status": "complete" if gate_data.get("status") in ("GO", "KILL") else "pending",
                "decision": gate_data.get("status"),
                "date": gate_data.get("date"),
                "notes": gate_data.get("notes", ""),
            }
            changed = True
        if "visual_review" not in chapters:
            vr_data = project.get("gates", {}).get("visual_review", {})
            chapters["visual_review"] = {
                "status": "complete" if vr_data.get("status") in ("GO", "REDO") else "pending",
                "decision": vr_data.get("status"),
                "date": vr_data.get("date"),
                "notes": vr_data.get("notes", ""),
            }
            changed = True

        # Create subdirs
        for sub in ["reports", "pdfs", "roadbooks"]:
            (project_dir / sub).mkdir(exist_ok=True)

        if changed:
            pf.write_text(json.dumps(project, indent=2, ensure_ascii=False), encoding="utf-8")
            print(f"  Migrated: {slug} (mode={project.get('mode')}, docs={len(project.get('documents', {}).get('reports', []))} reports, {len(project.get('documents', {}).get('pdfs', []))} pdfs)")
        else:
            print(f"  Skipped: {slug} (already up to date)")


if __name__ == "__main__":
    print("=== Project Migration ===")
    migrate()
    print("=== Done ===")

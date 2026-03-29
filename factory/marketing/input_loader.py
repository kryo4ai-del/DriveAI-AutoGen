"""Marketing Input Loader — Laedt Pipeline-Outputs fuer beliebige Projekte.

Dynamisch: Nimmt einen Projekt-Slug (z.B. "echomatch") und sammelt alle
verfuegbaren Reports aus allen Pipeline-Departments.
"""

import logging
import os
from typing import Optional

from factory.marketing.config import PIPELINE_SOURCES

logger = logging.getLogger("factory.marketing.input_loader")


class MarketingInputLoader:
    """Laedt und aggregiert Pipeline-Outputs fuer ein Projekt.

    Sucht in allen PIPELINE_SOURCES nach dem Projekt-Slug
    und sammelt die Markdown-Reports ein.
    """

    def __init__(self) -> None:
        """Init mit Pfaden aus config.py."""
        self._sources = PIPELINE_SOURCES

    def find_project_outputs(self, project_slug: str) -> dict[str, Optional[str]]:
        """Sucht alle Output-Verzeichnisse fuer einen Projekt-Slug.

        Der Slug kann Teil des Ordnernamens sein (z.B. "echomatch" findet
        "003_echomatch" in pre_production/output/).

        Returns:
            Dict mit Department-Name -> absoluter Pfad oder None.
        """
        result: dict[str, Optional[str]] = {}

        for dept, output_dir in self._sources.items():
            result[dept] = None
            if not os.path.exists(output_dir):
                continue

            for entry in os.listdir(output_dir):
                entry_path = os.path.join(output_dir, entry)
                if not os.path.isdir(entry_path):
                    continue
                # Slug-Match: "echomatch" findet "003_echomatch"
                if project_slug.lower() in entry.lower():
                    result[dept] = entry_path
                    break

        return result

    def load_project_reports(self, project_slug: str) -> dict[str, dict[str, str]]:
        """Laedt alle Markdown-Reports fuer ein Projekt.

        Returns:
            Dict mit Department -> {report_name: content}.
            Nur Departments/Files die tatsaechlich existieren.
        """
        outputs = self.find_project_outputs(project_slug)
        result: dict[str, dict[str, str]] = {}

        for dept, path in outputs.items():
            if path is None or not os.path.exists(path):
                continue

            reports: dict[str, str] = {}
            for fname in sorted(os.listdir(path)):
                if not fname.endswith(".md"):
                    continue
                fpath = os.path.join(path, fname)
                try:
                    with open(fpath, "r", encoding="utf-8") as f:
                        reports[fname.replace(".md", "")] = f.read()
                except Exception as e:
                    logger.warning("Report lesen fehlgeschlagen: %s — %s", fpath, e)

            if reports:
                result[dept] = reports

        return result

    def get_available_projects(self) -> list[str]:
        """Scannt alle Pipeline-Sources und gibt eine deduplizierte Liste
        aller gefundenen Projekt-Slugs zurueck.
        """
        slugs: set[str] = set()

        for dept, output_dir in self._sources.items():
            if not os.path.exists(output_dir):
                continue
            for entry in os.listdir(output_dir):
                if not os.path.isdir(os.path.join(output_dir, entry)):
                    continue
                if entry.startswith("."):
                    continue
                # Slug extrahieren: "003_echomatch" -> "echomatch"
                parts = entry.split("_", 1)
                if len(parts) == 2 and parts[0].isdigit():
                    slugs.add(parts[1])
                else:
                    slugs.add(entry)

        return sorted(slugs)

    def get_project_summary(self, project_slug: str) -> str:
        """Gibt eine kompakte Zusammenfassung zurueck:
        welche Departments haben Output, wie viele Reports, Gesamtgroesse.
        """
        outputs = self.find_project_outputs(project_slug)
        lines: list[str] = [f"Projekt: {project_slug}"]
        total_files = 0
        total_size = 0

        for dept, path in outputs.items():
            if path is None or not os.path.exists(path):
                lines.append(f"  {dept}: —")
                continue

            md_files = [f for f in os.listdir(path) if f.endswith(".md")]
            dept_size = sum(
                os.path.getsize(os.path.join(path, f))
                for f in md_files
                if os.path.isfile(os.path.join(path, f))
            )
            total_files += len(md_files)
            total_size += dept_size
            lines.append(f"  {dept}: {len(md_files)} Reports ({dept_size / 1024:.1f} KB)")

        lines.append(f"  Gesamt: {total_files} Reports, {total_size / 1024:.1f} KB")
        return "\n".join(lines)

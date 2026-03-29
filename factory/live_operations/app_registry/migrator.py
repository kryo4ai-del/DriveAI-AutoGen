"""Registry Migrator — Importiert Apps aus der Store Pipeline JSON in die SQLite DB."""

import json
import os
import shutil
from typing import Optional

from .database import AppRegistryDB


class RegistryMigrator:
    """Migriert app_registry.json -> SQLite."""

    # Mögliche Pfade für die Store Pipeline JSON
    _JSON_CANDIDATES = [
        "factory/store_pipeline/app_registry.json",
        "factory/store/app_registry.json",
        "factory/store_prep/app_registry.json",
    ]

    def __init__(
        self,
        json_path: Optional[str] = None,
        db: Optional[AppRegistryDB] = None,
    ) -> None:
        self.json_path = json_path or self._find_json()
        self.db = db or AppRegistryDB()

    def _find_json(self) -> Optional[str]:
        """Sucht die app_registry.json an bekannten Stellen."""
        factory_root = os.path.abspath(
            os.path.join(os.path.dirname(__file__), "..", "..")
        )
        for candidate in self._JSON_CANDIDATES:
            path = os.path.join(factory_root, candidate)
            if os.path.isfile(path):
                print(f"[Registry Migrator] JSON gefunden: {path}")
                return path
        return None

    def migrate(self) -> dict:
        """Liest JSON, erstellt Einträge in SQLite, returned Summary."""
        summary = {"imported": 0, "skipped": 0, "errors": [], "source": None}

        if not self.json_path or not os.path.isfile(self.json_path):
            print("[Registry Migrator] Keine app_registry.json gefunden.")
            print("[Registry Migrator] Erwartete Pfade:")
            for c in self._JSON_CANDIDATES:
                print(f"  - {c}")
            print("[Registry Migrator] Migration skipped -- no data to import.")
            return summary

        summary["source"] = self.json_path

        # Backup der DB vor Migration
        if os.path.isfile(self.db.db_path):
            backup_path = self.db.db_path + ".bak"
            shutil.copy2(self.db.db_path, backup_path)
            print(f"[Registry Migrator] DB-Backup erstellt: {backup_path}")

        # JSON laden
        try:
            with open(self.json_path, "r", encoding="utf-8") as f:
                data = json.load(f)
        except (json.JSONDecodeError, OSError) as e:
            print(f"[Registry Migrator] Fehler beim Lesen der JSON: {e}")
            summary["errors"].append(str(e))
            return summary

        # Normalize: Liste oder einzelnes Dict
        entries = data if isinstance(data, list) else [data]

        if not entries:
            print("[Registry Migrator] JSON ist leer — keine Apps zum Importieren.")
            return summary

        existing_apps = self.db.get_all_apps()
        existing_bundles = {a.get("bundle_id") for a in existing_apps if a.get("bundle_id")}
        existing_packages = {a.get("package_name") for a in existing_apps if a.get("package_name")}

        for entry in entries:
            try:
                app_data = self._map_json_to_app(entry)

                # Duplikat-Check
                bid = app_data.get("bundle_id")
                pkg = app_data.get("package_name")
                if (bid and bid in existing_bundles) or (pkg and pkg in existing_packages):
                    name = app_data.get("app_name", "?")
                    print(f"[Registry Migrator] Skipped (already exists): {name}")
                    summary["skipped"] += 1
                    continue

                self.db.add_app(app_data)
                summary["imported"] += 1

                if bid:
                    existing_bundles.add(bid)
                if pkg:
                    existing_packages.add(pkg)

            except Exception as e:
                print(f"[Registry Migrator] Fehler bei Eintrag: {e}")
                summary["errors"].append(str(e))

        print(f"[Registry Migrator] Migration abgeschlossen: "
              f"{summary['imported']} imported, {summary['skipped']} skipped, "
              f"{len(summary['errors'])} Fehler")
        return summary

    def _map_json_to_app(self, json_entry: dict) -> dict:
        """Mapping JSON-Felder auf DB-Felder."""
        return {
            "app_name": json_entry.get("app_name") or json_entry.get("name", "Unknown"),
            "bundle_id": json_entry.get("bundle_id") or json_entry.get("ios_bundle_id"),
            "package_name": json_entry.get("package_name") or json_entry.get("android_package"),
            "apple_app_id": json_entry.get("apple_app_id") or json_entry.get("apple_id"),
            "google_package": json_entry.get("google_package") or json_entry.get("package_name"),
            "current_version": json_entry.get("current_version") or json_entry.get("version"),
            "last_upload_timestamp": json_entry.get("last_upload_timestamp") or json_entry.get("timestamp"),
            "store_status": json_entry.get("store_status", "unknown"),
            "app_profile": json_entry.get("app_profile") or json_entry.get("category", "utility"),
            "monetization_model": json_entry.get("monetization_model") or json_entry.get("monetization", "unknown"),
            "firebase_project_id": json_entry.get("firebase_project_id"),
            "repository_path": json_entry.get("repository_path") or json_entry.get("repo_path"),
        }

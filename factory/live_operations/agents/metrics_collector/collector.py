"""Metrics Collector Agent — sammelt Rohdaten aus allen Quellen und normalisiert sie.

Erster Agent im Live Operations Department.
Rein deterministisch — kein LLM-Call.
"""

import json
import os
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.agents.metrics_collector.store_api import StoreAPIAdapter
from factory.live_operations.agents.metrics_collector.firebase_api import FirebaseAPIAdapter
from factory.live_operations.agents.metrics_collector.config import (
    DATA_OUTPUT_DIR,
    REVIEW_FETCH_LIMIT,
)

_PREFIX = "[Metrics Collector]"


class MetricsCollector:
    """Sammelt und normalisiert Metriken aus Store APIs und Firebase."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self._db = registry_db or AppRegistryDB()
        self._apple_api = StoreAPIAdapter("apple")
        self._google_api = StoreAPIAdapter("google")

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def collect_all(self) -> dict:
        """Sammelt Metriken fuer ALLE registrierten Apps."""
        apps = self._db.get_all_apps()
        if not apps:
            print(f"{_PREFIX} Keine Apps in der Registry. Nichts zu sammeln.")
            return {"collected_at": _now_iso(), "apps": {}, "total": 0}

        print(f"{_PREFIX} Starte Collection fuer {len(apps)} Apps...")
        results = {}
        for app in apps:
            app_id = app["app_id"]
            try:
                results[app_id] = self.collect_for_app(app_id)
            except Exception as e:
                print(f"{_PREFIX} Fehler bei {app_id}: {e}")
                results[app_id] = {
                    "app_id": app_id,
                    "collected_at": _now_iso(),
                    "store_metrics": {},
                    "firebase_metrics": {},
                    "reviews": [],
                    "collection_status": {
                        "store_success": False,
                        "firebase_success": False,
                        "errors": [str(e)],
                    },
                }

        summary = {
            "collected_at": _now_iso(),
            "apps": results,
            "total": len(results),
        }

        # Save to data directory
        self._save_collection(summary)
        print(f"{_PREFIX} Collection abgeschlossen: {len(results)} Apps verarbeitet.")
        return summary

    def collect_for_app(self, app_id: str) -> dict:
        """Sammelt Metriken fuer eine spezifische App."""
        app = self._db.get_app(app_id)
        if not app:
            print(f"{_PREFIX} App {app_id} nicht in Registry gefunden.")
            return {
                "app_id": app_id,
                "collected_at": _now_iso(),
                "store_metrics": {},
                "firebase_metrics": {},
                "reviews": [],
                "collection_status": {
                    "store_success": False,
                    "firebase_success": False,
                    "errors": [f"App {app_id} not found in registry"],
                },
            }

        errors = []
        store_data = {}
        firebase_data = {}
        reviews = []
        store_success = False
        firebase_success = False

        # 1. Store Metrics
        try:
            store_data = self._collect_store_metrics(app)
            store_success = True
        except Exception as e:
            errors.append(f"Store API error: {e}")
            print(f"{_PREFIX} Store API Fehler fuer {app_id}: {e}")

        # 2. Firebase Metrics
        try:
            firebase_data = self._collect_firebase_metrics(app)
            firebase_success = True
        except Exception as e:
            errors.append(f"Firebase API error: {e}")
            print(f"{_PREFIX} Firebase API Fehler fuer {app_id}: {e}")

        # 3. Reviews
        try:
            reviews = self._collect_reviews(app)
        except Exception as e:
            errors.append(f"Review fetch error: {e}")

        # 4. Normalize
        normalized = self._normalize_metrics(store_data, firebase_data)

        result = {
            "app_id": app_id,
            "app_name": app.get("app_name", "Unknown"),
            "collected_at": _now_iso(),
            "store_metrics": normalized.get("store_metrics", {}),
            "firebase_metrics": normalized.get("firebase_metrics", {}),
            "reviews": reviews,
            "collection_status": {
                "store_success": store_success,
                "firebase_success": firebase_success,
                "errors": errors,
            },
        }

        print(f"{_PREFIX} Metriken gesammelt fuer: {app.get('app_name', app_id)}")
        return result

    # ------------------------------------------------------------------
    # Internal — Data Collection
    # ------------------------------------------------------------------

    def _collect_store_metrics(self, app: dict) -> dict:
        """Sammelt Store API Daten (Apple + Google)."""
        data = {}

        # Determine platform and fetch
        if app.get("apple_app_id") or app.get("bundle_id"):
            identifier = app.get("apple_app_id") or app.get("bundle_id", "")
            data["apple"] = self._apple_api.fetch_metrics(identifier)

        if app.get("google_package") or app.get("package_name"):
            identifier = app.get("google_package") or app.get("package_name", "")
            data["google"] = self._google_api.fetch_metrics(identifier)

        # If neither platform identifier exists, try both with app_id
        if not data:
            data["apple"] = self._apple_api.fetch_metrics(app["app_id"])

        return data

    def _collect_firebase_metrics(self, app: dict) -> dict:
        """Sammelt Firebase Analytics Daten."""
        project_id = app.get("firebase_project_id", app["app_id"])
        adapter = FirebaseAPIAdapter(project_id)

        return {
            "analytics": adapter.fetch_analytics(),
            "crashlytics": adapter.fetch_crashlytics(),
        }

    def _collect_reviews(self, app: dict) -> list[dict]:
        """Sammelt Reviews aus den Stores."""
        reviews = []

        if app.get("apple_app_id") or app.get("bundle_id"):
            identifier = app.get("apple_app_id") or app.get("bundle_id", "")
            reviews.extend(self._apple_api.fetch_reviews(identifier, REVIEW_FETCH_LIMIT))

        if app.get("google_package") or app.get("package_name"):
            identifier = app.get("google_package") or app.get("package_name", "")
            reviews.extend(self._google_api.fetch_reviews(identifier, REVIEW_FETCH_LIMIT))

        return reviews

    # ------------------------------------------------------------------
    # Internal — Normalization
    # ------------------------------------------------------------------

    def _normalize_metrics(self, store_data: dict, firebase_data: dict) -> dict:
        """Vereinheitlicht Store + Firebase Daten in ein einheitliches Format."""

        # Merge store metrics (prefer Google for Android-specific, Apple for iOS)
        store_metrics = {}
        for platform_data in store_data.values():
            if isinstance(platform_data, dict):
                for key, value in platform_data.items():
                    if key not in store_metrics or value:
                        store_metrics[key] = value

        # Extract firebase analytics
        analytics = firebase_data.get("analytics", {})
        crashlytics = firebase_data.get("crashlytics", {})

        firebase_metrics = {
            "dau": analytics.get("dau", 0),
            "mau": analytics.get("mau", 0),
            "dau_mau_ratio": analytics.get("dau_mau_ratio", 0.0),
            "session_count_period": analytics.get("session_count_period", 0),
            "avg_session_length_seconds": analytics.get("avg_session_length_seconds", 0.0),
            "retention_day1": analytics.get("retention_day1", 0.0),
            "retention_day7": analytics.get("retention_day7", 0.0),
            "retention_day30": analytics.get("retention_day30", 0.0),
            "feature_usage": analytics.get("feature_usage", {}),
            "funnel_completion": analytics.get("funnel_completion", {}),
            "arpu": analytics.get("arpu", 0.0),
            "conversion_rate": analytics.get("conversion_rate", 0.0),
            "crash_free_sessions_pct": crashlytics.get("crash_free_sessions_pct", 100.0),
            "crash_free_users_pct": crashlytics.get("crash_free_users_pct", 100.0),
        }

        return {
            "store_metrics": store_metrics,
            "firebase_metrics": firebase_metrics,
        }

    # ------------------------------------------------------------------
    # Internal — Persistence
    # ------------------------------------------------------------------

    def _save_collection(self, data: dict) -> None:
        """Speichert Collection-Ergebnis als JSON."""
        output_dir = Path(DATA_OUTPUT_DIR)
        output_dir.mkdir(parents=True, exist_ok=True)

        timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        filename = f"collection_{timestamp}.json"
        filepath = output_dir / filename

        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False, default=str)

        print(f"{_PREFIX} Daten gespeichert: {filepath}")


# ------------------------------------------------------------------
# CLI Entry Point
# ------------------------------------------------------------------

def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


if __name__ == "__main__":
    print(f"{_PREFIX} Starte manuelle Collection...")
    collector = MetricsCollector()
    result = collector.collect_all()
    print(f"{_PREFIX} Fertig. {result['total']} Apps verarbeitet.")

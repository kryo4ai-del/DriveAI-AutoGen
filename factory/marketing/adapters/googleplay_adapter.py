"""Google Play Developer API Adapter.

Dry-Run mit realistischen Mock-Daten wenn keine Credentials.
Deterministisch, kein LLM.
"""

import logging
import os
from typing import Optional

logger = logging.getLogger("factory.marketing.adapters.googleplay")

# --- Realistische Mock-Daten (Android-Markt: hoehere Downloads, niedrigerer ARPU) ---

MOCK_REVIEWS = [
    {"id": "gp-r001", "rating": 5, "title": "", "body": "Super App zum Lernen! Auf meinem Pixel 9 laeuft alles perfekt.", "author": "AndroidFan2026", "date": "2026-03-20", "device": "Google Pixel 9"},
    {"id": "gp-r002", "rating": 4, "title": "", "body": "Gut, aber die Werbung nervt. Premium ist teuer fuer eine Lern-App.", "author": "Sam_DE", "date": "2026-03-21", "device": "Samsung Galaxy S25"},
    {"id": "gp-r003", "rating": 1, "title": "", "body": "Stuetzt immer ab auf meinem alten Handy. Samsung A14, Android 14.", "author": "BudgetUser", "date": "2026-03-22", "device": "Samsung Galaxy A14"},
    {"id": "gp-r004", "rating": 5, "title": "", "body": "Bestanden! Danke fuer diese tolle App. Alles richtig gemacht.", "author": "GluecklicherSchueler", "date": "2026-03-23", "device": "Google Pixel 8a"},
    {"id": "gp-r005", "rating": 3, "title": "", "body": "Fragen sind ok, aber die Erklaerungen koennten besser sein.", "author": "Kritiker99", "date": "2026-03-24", "device": "Xiaomi 14T"},
    {"id": "gp-r006", "rating": 4, "title": "", "body": "Tablet-Modus funktioniert gut. Wuensche mir Dark Mode.", "author": "TabletLerner", "date": "2026-03-25", "device": "Samsung Galaxy Tab S10"},
    {"id": "gp-r007", "rating": 2, "title": "", "body": "Nach Update alle Fortschritte weg! Sehr aergerlich.", "author": "FortschrittVerloren", "date": "2026-03-26", "device": "OnePlus 13"},
]

MOCK_METRICS = {
    "downloads": {"daily_avg": 1200, "total_30d": 36000, "trend": "+18%"},
    "revenue": {"daily_avg": 280.0, "total_30d": 8400.0, "currency": "EUR", "trend": "+6%"},
    "sessions": {"daily_avg": 22000, "avg_session_duration": 3.8, "trend": "+7%"},
    "crashes": {"daily_avg": 25, "crash_rate": 0.11, "trend": "-10%"},
    "active_devices": {"dau": 32000, "mau": 250000, "dau_mau_ratio": 0.128},
    "retention": {"d1": 38, "d7": 19, "d30": 9},
}

MOCK_RATINGS = {
    "average": 4.1,
    "total_ratings": 4120,
    "distribution": {"5": 1850, "4": 1030, "3": 520, "2": 380, "1": 340},
    "trend_30d": "+0.05",
}

MOCK_KEYWORD_RANKINGS = [
    {"keyword": "Fuehrerschein App", "position": 5, "change_7d": -1},
    {"keyword": "Fahrschule lernen", "position": 4, "change_7d": 2},
    {"keyword": "Fuehrerschein Theorie", "position": 8, "change_7d": 0},
    {"keyword": "Driving Test Germany", "position": 15, "change_7d": 5},
    {"keyword": "Verkehrsregeln lernen", "position": 9, "change_7d": -3},
]


class GooglePlayAdapter:
    """Google Play Developer API Adapter."""

    STATUS = "active"
    PLATFORM = "google_play"

    def __init__(self, dry_run: bool = True):
        self.service_account_path = os.getenv("GOOGLE_PLAY_SERVICE_ACCOUNT")
        self._force_dry_run = not self.service_account_path
        self.dry_run = True if self._force_dry_run else dry_run

        if self._force_dry_run:
            logger.info("Google Play Adapter: No service account — DRY RUN enforced")
        elif self.dry_run:
            logger.info("Google Play Adapter: Credentials found, DRY RUN mode")
        else:
            logger.info("Google Play Adapter: LIVE mode")

    def _get_service(self):
        """Erstellt Google Play Developer API Service."""
        try:
            from google.oauth2 import service_account
            from googleapiclient.discovery import build
        except ImportError:
            raise ImportError("google-api-python-client not installed")

        credentials = service_account.Credentials.from_service_account_file(
            self.service_account_path,
            scopes=["https://www.googleapis.com/auth/androidpublisher"],
        )
        return build("androidpublisher", "v3", credentials=credentials)

    def _dry_run_log(self, method: str, **kwargs) -> dict:
        logger.info("[DRY RUN] GooglePlay.%s(%s)", method, ", ".join(f"{k}={v!r}" for k, v in kwargs.items()))
        return {"dry_run": True, "method": method, "params": kwargs}

    def get_reviews(self, app_id: str, limit: int = 50) -> list[dict]:
        """Gibt Google Play Reviews zurueck."""
        if self.dry_run:
            self._dry_run_log("get_reviews", app_id=app_id, limit=limit)
            return MOCK_REVIEWS[:min(limit, len(MOCK_REVIEWS))]

        service = self._get_service()
        result = service.reviews().list(packageName=app_id, maxResults=limit).execute()
        reviews = []
        for item in result.get("reviews", []):
            comment = item.get("comments", [{}])[0].get("userComment", {})
            reviews.append({
                "id": item["reviewId"],
                "rating": comment.get("starRating", 0),
                "title": "",
                "body": comment.get("text", ""),
                "author": item.get("authorName", ""),
                "date": "",
                "device": comment.get("deviceMetadata", {}).get("productName", ""),
            })
        return reviews

    def reply_to_review(self, review_id: str, response_text: str) -> dict:
        """Antwortet auf ein Review."""
        if self.dry_run:
            return self._dry_run_log("reply_to_review", review_id=review_id, response_text=response_text[:50])

        raise NotImplementedError("Live Google Play reply requires package name context")

    def get_app_metrics(self, app_id: str, metric_type: str = "all", days: int = 30) -> dict:
        """Gibt App-Metriken zurueck."""
        if self.dry_run:
            self._dry_run_log("get_app_metrics", app_id=app_id, metric_type=metric_type, days=days)
            if metric_type == "all":
                return dict(MOCK_METRICS)
            return {metric_type: MOCK_METRICS.get(metric_type, {})}

        raise NotImplementedError("Live Google Play metrics require Play Console API")

    def get_ratings_summary(self, app_id: str) -> dict:
        """Gibt Ratings-Zusammenfassung zurueck."""
        if self.dry_run:
            self._dry_run_log("get_ratings_summary", app_id=app_id)
            return dict(MOCK_RATINGS)

        raise NotImplementedError("Live ratings summary not yet implemented")

    def get_keyword_rankings(self, app_id: str, keywords: list[str] = None,
                             country: str = "DE") -> list[dict]:
        """Gibt Keyword-Rankings zurueck."""
        if self.dry_run:
            self._dry_run_log("get_keyword_rankings", app_id=app_id, country=country)
            if keywords:
                return [r for r in MOCK_KEYWORD_RANKINGS if r["keyword"] in keywords]
            return list(MOCK_KEYWORD_RANKINGS)

        raise NotImplementedError("Live keyword rankings require SerpAPI")

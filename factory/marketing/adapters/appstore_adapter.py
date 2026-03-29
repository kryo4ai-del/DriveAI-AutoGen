"""App Store Connect API Adapter.

Dry-Run mit realistischen Mock-Daten wenn keine Credentials.
Deterministisch, kein LLM.
"""

import logging
import os
import time
from typing import Optional

logger = logging.getLogger("factory.marketing.adapters.appstore")

# --- Realistische Mock-Daten (EchoMatch Roadbook) ---

MOCK_REVIEWS = [
    {"id": "r001", "rating": 5, "title": "Beste Lern-App!", "body": "Endlich eine App die wirklich hilft. Hab meine Pruefung beim ersten Versuch bestanden!", "author": "MaxM", "date": "2026-03-20", "territory": "DE"},
    {"id": "r002", "rating": 4, "title": "Gut aber...", "body": "Funktioniert gut, aber mehr Fragen waeren toll. Manche Kategorien haben nur 10 Fragen.", "author": "Lisa_K", "date": "2026-03-21", "territory": "DE"},
    {"id": "r003", "rating": 2, "title": "App stuerzt ab", "body": "Seit dem letzten Update crasht die App beim Start. iPhone 14 Pro, iOS 19.3.", "author": "FrustrierterUser", "date": "2026-03-22", "territory": "DE"},
    {"id": "r004", "rating": 1, "title": "Geld verschwendet", "body": "Premium gekauft und es funktioniert nichts. Keine Antwort vom Support.", "author": "Angry_Customer", "date": "2026-03-23", "territory": "DE"},
    {"id": "r005", "rating": 5, "title": "Hat mir geholfen!", "body": "Pruefung beim ersten Versuch bestanden. Die Erklaerungen sind super verstaendlich.", "author": "Fahrschueler2026", "date": "2026-03-24", "territory": "DE"},
    {"id": "r006", "rating": 3, "title": "Ganz ok", "body": "Nichts besonderes, aber funktioniert. Design koennte moderner sein.", "author": "NeutralUser", "date": "2026-03-25", "territory": "DE"},
    {"id": "r007", "rating": 5, "title": "Toll!", "body": "Einfach super! Perfekt fuer die Vorbereitung.", "author": "HappyUser", "date": "2026-03-26", "territory": "AT"},
]

MOCK_METRICS = {
    "downloads": {"daily_avg": 850, "total_30d": 25500, "trend": "+12%"},
    "revenue": {"daily_avg": 425.0, "total_30d": 12750.0, "currency": "EUR", "trend": "+8%"},
    "sessions": {"daily_avg": 15000, "avg_session_duration": 4.2, "trend": "+5%"},
    "crashes": {"daily_avg": 12, "crash_rate": 0.08, "trend": "-15%"},
    "active_devices": {"dau": 25000, "mau": 180000, "dau_mau_ratio": 0.139},
    "retention": {"d1": 42, "d7": 22, "d30": 11},
}

MOCK_RATINGS = {
    "average": 4.3,
    "total_ratings": 2840,
    "distribution": {"5": 1420, "4": 710, "3": 340, "2": 200, "1": 170},
    "trend_30d": "+0.1",
}

MOCK_KEYWORD_RANKINGS = [
    {"keyword": "Fuehrerschein App", "position": 3, "change_7d": 1},
    {"keyword": "Fahrschule lernen", "position": 7, "change_7d": -2},
    {"keyword": "Fuehrerschein Theorie", "position": 5, "change_7d": 0},
    {"keyword": "Driving Test", "position": 42, "change_7d": 3},
    {"keyword": "Verkehrsregeln lernen", "position": 12, "change_7d": -1},
]


class AppStoreAdapter:
    """App Store Connect API v1 Adapter."""

    STATUS = "active"
    PLATFORM = "app_store"

    def __init__(self, dry_run: bool = True):
        self.key_id = os.getenv("APPSTORE_KEY_ID")
        self.issuer_id = os.getenv("APPSTORE_ISSUER_ID")
        self.key_path = os.getenv("APPSTORE_KEY_PATH")
        self._force_dry_run = not all([self.key_id, self.issuer_id, self.key_path])
        self.dry_run = True if self._force_dry_run else dry_run

        if self._force_dry_run:
            logger.info("App Store Adapter: No credentials — DRY RUN enforced")
        elif self.dry_run:
            logger.info("App Store Adapter: Credentials found, DRY RUN mode")
        else:
            logger.info("App Store Adapter: LIVE mode")

    def _generate_jwt_token(self) -> str:
        """Generiert JWT fuer App Store Connect API."""
        try:
            import jwt
        except ImportError:
            raise ImportError("pyjwt not installed. Run: pip install pyjwt cryptography")

        with open(self.key_path, "r") as f:
            private_key = f.read()

        payload = {
            "iss": self.issuer_id,
            "iat": int(time.time()),
            "exp": int(time.time()) + 1200,
            "aud": "appstoreconnect-v1",
        }
        headers = {
            "alg": "ES256",
            "kid": self.key_id,
            "typ": "JWT",
        }
        return jwt.encode(payload, private_key, algorithm="ES256", headers=headers)

    def _dry_run_log(self, method: str, **kwargs) -> dict:
        """Loggt Dry-Run-Aufruf und gibt Mock-Result zurueck."""
        logger.info("[DRY RUN] AppStore.%s(%s)", method, ", ".join(f"{k}={v!r}" for k, v in kwargs.items()))
        return {"dry_run": True, "method": method, "params": kwargs}

    def get_reviews(self, app_id: str, limit: int = 50) -> list[dict]:
        """Gibt App Store Reviews zurueck."""
        if self.dry_run:
            self._dry_run_log("get_reviews", app_id=app_id, limit=limit)
            return MOCK_REVIEWS[:min(limit, len(MOCK_REVIEWS))]

        # Live: App Store Connect API
        import requests
        token = self._generate_jwt_token()
        headers = {"Authorization": f"Bearer {token}"}
        url = f"https://api.appstoreconnect.apple.com/v1/apps/{app_id}/customerReviews"
        params = {"limit": limit, "sort": "-createdDate"}
        resp = requests.get(url, headers=headers, params=params, timeout=30)
        resp.raise_for_status()
        data = resp.json()

        reviews = []
        for item in data.get("data", []):
            attrs = item.get("attributes", {})
            reviews.append({
                "id": item["id"],
                "rating": attrs.get("rating", 0),
                "title": attrs.get("title", ""),
                "body": attrs.get("body", ""),
                "author": attrs.get("reviewerNickname", ""),
                "date": attrs.get("createdDate", "")[:10],
                "territory": attrs.get("territory", ""),
            })
        return reviews

    def reply_to_review(self, review_id: str, response_text: str) -> dict:
        """Antwortet auf ein Review."""
        if self.dry_run:
            return self._dry_run_log("reply_to_review", review_id=review_id, response_text=response_text[:50])

        import requests
        token = self._generate_jwt_token()
        headers = {
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }
        url = "https://api.appstoreconnect.apple.com/v1/customerReviewResponses"
        payload = {
            "data": {
                "type": "customerReviewResponses",
                "attributes": {"responseBody": response_text},
                "relationships": {
                    "review": {"data": {"type": "customerReviews", "id": review_id}}
                },
            }
        }
        resp = requests.post(url, headers=headers, json=payload, timeout=30)
        resp.raise_for_status()
        return {"status": "replied", "review_id": review_id}

    def get_app_metrics(self, app_id: str, metric_type: str = "all", days: int = 30) -> dict:
        """Gibt App-Metriken zurueck."""
        if self.dry_run:
            self._dry_run_log("get_app_metrics", app_id=app_id, metric_type=metric_type, days=days)
            if metric_type == "all":
                return dict(MOCK_METRICS)
            return {metric_type: MOCK_METRICS.get(metric_type, {})}

        # Live: Analytics Reports API (nicht implementiert — erfordert separate Autorisierung)
        raise NotImplementedError("Live App Store metrics require Analytics Reports API")

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

        raise NotImplementedError("Live keyword rankings require third-party API (SerpAPI)")

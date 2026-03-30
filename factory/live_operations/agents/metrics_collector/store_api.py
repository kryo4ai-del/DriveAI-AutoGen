"""Store API Adapter — abstracts Apple App Store Connect and Google Play Console APIs.

IMPORTANT: All methods are STUB implementations returning realistic mock data.
Replace with real API calls once OAuth/JWT credentials are configured.
"""

import random
from datetime import datetime, timezone


class StoreAPIAdapter:
    """Adapter for App Store Connect and Google Play Console APIs."""

    def __init__(self, platform: str) -> None:
        if platform not in ("apple", "google"):
            raise ValueError(f"[Store API] Unknown platform: {platform}. Use 'apple' or 'google'.")
        self.platform = platform

    def fetch_metrics(self, app_identifier: str) -> dict:
        """Fetch store metrics for an app.

        # TODO: Replace with real API call
        # Apple: https://developer.apple.com/documentation/appstoreconnectapi
        # Google: https://developers.google.com/play/developer/reporting
        """
        print(f"[Store API] STUB: Would call {self._api_name()} for {app_identifier}")

        base_downloads = random.randint(500, 50000)
        rating = round(random.uniform(3.0, 5.0), 1)

        result = {
            "downloads_total": base_downloads * random.randint(10, 100),
            "downloads_period": base_downloads,
            "rating_average": rating,
            "rating_count": random.randint(50, 5000),
            "rating_trend": round(random.uniform(-0.3, 0.3), 2),
            "revenue_period": round(random.uniform(100.0, 25000.0), 2),
            "revenue_trend": round(random.uniform(-0.15, 0.25), 2),
            "crash_rate": round(random.uniform(0.0, 3.0), 2),
        }

        if self.platform == "google":
            result["anr_rate"] = round(random.uniform(0.0, 1.5), 2)
        else:
            result["anr_rate"] = 0.0

        return result

    def fetch_reviews(self, app_identifier: str, limit: int = 20) -> list[dict]:
        """Fetch recent reviews for an app.

        # TODO: Replace with real API call
        # Apple: https://developer.apple.com/documentation/appstoreconnectapi/list_all_customer_reviews
        # Google: https://developers.google.com/play/developer/api/rest/v3/reviews
        """
        print(f"[Store API] STUB: Would fetch reviews from {self._api_name()} for {app_identifier}")

        sentiments = ["positive", "neutral", "negative"]
        sample_texts = [
            "Great app, love the new update!",
            "Works well but could use dark mode.",
            "Crashes on startup after latest update.",
            "Perfect for what I need. Simple and clean.",
            "Too many ads, considering uninstalling.",
            "Best app in this category. Highly recommend!",
            "Slow loading times, needs optimization.",
            "Good concept but buggy execution.",
            "Love the design, hate the subscription model.",
            "Does exactly what it says. No complaints.",
        ]

        reviews = []
        for i in range(min(limit, len(sample_texts))):
            rating = random.randint(1, 5)
            reviews.append({
                "review_id": f"rev_{app_identifier}_{i}",
                "author": f"user_{random.randint(1000, 9999)}",
                "rating": rating,
                "text": sample_texts[i],
                "sentiment": sentiments[0] if rating >= 4 else (sentiments[2] if rating <= 2 else sentiments[1]),
                "date": datetime.now(timezone.utc).isoformat(),
                "version": f"1.{random.randint(0, 9)}.{random.randint(0, 20)}",
            })
        return reviews

    def fetch_crash_reports(self, app_identifier: str) -> dict:
        """Fetch crash report summary for an app.

        # TODO: Replace with real API call
        # Apple: https://developer.apple.com/documentation/appstoreconnectapi/diagnostic_logs
        # Google: https://developers.google.com/play/developer/reporting/crashes
        """
        print(f"[Store API] STUB: Would fetch crash reports from {self._api_name()} for {app_identifier}")

        return {
            "total_crashes_period": random.randint(0, 500),
            "crash_free_users_pct": round(random.uniform(95.0, 99.9), 1),
            "top_crashes": [
                {
                    "crash_id": f"crash_{i}",
                    "title": title,
                    "count": random.randint(1, 100),
                    "affected_users": random.randint(1, 50),
                }
                for i, title in enumerate([
                    "NullPointerException in MainViewModel",
                    "OutOfMemoryError in ImageLoader",
                    "IndexOutOfBoundsException in RecyclerView",
                ])
            ],
        }

    def _api_name(self) -> str:
        return "Apple App Store Connect API" if self.platform == "apple" else "Google Play Console API"

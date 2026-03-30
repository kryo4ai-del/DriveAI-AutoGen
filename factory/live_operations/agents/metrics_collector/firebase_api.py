"""Firebase API Adapter — abstracts Firebase Analytics and Crashlytics APIs.

IMPORTANT: All methods are STUB implementations returning realistic mock data.
Replace with real Firebase Admin SDK calls once credentials are configured.
"""

import random
from datetime import datetime, timezone


class FirebaseAPIAdapter:
    """Adapter for Firebase Analytics, Crashlytics, and Remote Config."""

    def __init__(self, project_id: str) -> None:
        self.project_id = project_id

    def fetch_analytics(self, date_range_days: int = 7) -> dict:
        """Fetch Firebase Analytics data.

        # TODO: Replace with real Firebase Admin SDK call
        # https://firebase.google.com/docs/analytics/get-started
        # https://developers.google.com/analytics/devguides/reporting/data/v1
        """
        print(f"[Firebase API] STUB: Would fetch analytics for project {self.project_id} ({date_range_days}d)")

        dau = random.randint(100, 10000)
        mau = dau * random.randint(5, 20)

        return {
            "dau": dau,
            "mau": mau,
            "dau_mau_ratio": round(dau / max(mau, 1), 3),
            "session_count_period": dau * random.randint(3, 10),
            "avg_session_length_seconds": round(random.uniform(30.0, 600.0), 1),
            "retention_day1": round(random.uniform(20.0, 60.0), 1),
            "retention_day7": round(random.uniform(10.0, 40.0), 1),
            "retention_day30": round(random.uniform(5.0, 25.0), 1),
            "feature_usage": {
                "home_screen": random.randint(500, 5000),
                "settings": random.randint(100, 1000),
                "search": random.randint(200, 3000),
                "profile": random.randint(100, 2000),
                "notifications": random.randint(50, 500),
            },
            "funnel_completion": {
                "onboarding": {
                    "step_1_start": 100.0,
                    "step_2_profile": round(random.uniform(60.0, 90.0), 1),
                    "step_3_preferences": round(random.uniform(40.0, 70.0), 1),
                    "step_4_complete": round(random.uniform(30.0, 60.0), 1),
                },
                "purchase": {
                    "step_1_browse": 100.0,
                    "step_2_add_to_cart": round(random.uniform(20.0, 50.0), 1),
                    "step_3_checkout": round(random.uniform(10.0, 30.0), 1),
                    "step_4_payment": round(random.uniform(5.0, 20.0), 1),
                },
            },
            "arpu": round(random.uniform(0.10, 5.00), 2),
            "conversion_rate": round(random.uniform(1.0, 12.0), 1),
        }

    def fetch_crashlytics(self) -> dict:
        """Fetch Firebase Crashlytics data.

        # TODO: Replace with real Firebase Admin SDK call
        # https://firebase.google.com/docs/crashlytics
        """
        print(f"[Firebase API] STUB: Would fetch crashlytics for project {self.project_id}")

        return {
            "crash_free_sessions_pct": round(random.uniform(96.0, 99.9), 1),
            "crash_free_users_pct": round(random.uniform(97.0, 99.9), 1),
            "total_crashes": random.randint(0, 200),
            "total_non_fatals": random.randint(0, 500),
            "top_issues": [
                {
                    "issue_id": f"issue_{i}",
                    "title": title,
                    "events": random.randint(5, 100),
                    "users_affected": random.randint(1, 50),
                    "first_seen": "2026-03-20T10:00:00Z",
                    "last_seen": datetime.now(timezone.utc).isoformat(),
                }
                for i, title in enumerate([
                    "Fatal: UIApplicationMain crash",
                    "Non-fatal: NetworkError timeout",
                    "Fatal: ArrayIndexOutOfBounds",
                ])
            ],
        }

    def fetch_remote_config(self) -> dict:
        """Fetch current Firebase Remote Config status (for Phase 5).

        # TODO: Replace with real Firebase Admin SDK call
        # https://firebase.google.com/docs/remote-config/get-started
        """
        print(f"[Firebase API] STUB: Would fetch remote config for project {self.project_id}")

        return {
            "last_fetch": datetime.now(timezone.utc).isoformat(),
            "parameters_count": random.randint(5, 30),
            "active_experiments": random.randint(0, 3),
            "status": "active",
        }

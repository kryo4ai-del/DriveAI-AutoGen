"""Ticket Store -- lokaler JSON-basierter Ticket-Speicher fuer die Stub-Phase."""

import json
import os
import random
from datetime import datetime, timezone, timedelta


class TicketStore:
    """JSON-basierter Ticket-Speicher."""

    def __init__(self, data_dir: str = None) -> None:
        self.data_dir = data_dir or os.path.join(
            "factory", "live_operations", "data", "support"
        )

    def add_ticket(self, ticket: dict) -> None:
        """Ticket speichern."""
        os.makedirs(self.data_dir, exist_ok=True)
        app_id = ticket.get("app_id", "unknown")
        path = os.path.join(self.data_dir, f"{app_id}_tickets.json")

        tickets = []
        if os.path.isfile(path):
            with open(path, "r", encoding="utf-8") as f:
                tickets = json.load(f)

        tickets.append(ticket)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(tickets, f, indent=2, default=str)

    def get_tickets(self, app_id: str = None, days: int = 7) -> list[dict]:
        """Tickets laden."""
        if not os.path.isdir(self.data_dir):
            return []

        tickets = []
        for fname in os.listdir(self.data_dir):
            if not fname.endswith("_tickets.json"):
                continue
            if app_id and not fname.startswith(app_id):
                continue
            path = os.path.join(self.data_dir, fname)
            with open(path, "r", encoding="utf-8") as f:
                tickets.extend(json.load(f))

        return tickets

    def generate_mock_tickets(self, app_id: str, count: int = 30,
                              seed: int = 42) -> list[dict]:
        """Generiert realistische Mock-Tickets."""
        rng = random.Random(seed)

        # Templates nach Kategorie
        templates = {
            "crash": [
                ("App crashes on startup", "Every time I open the app it crashes immediately. iPhone 15 Pro."),
                ("Crash when exporting", "App freezes and then crashes when I tap the export button."),
                ("Force close after update", "Since the last update, the app force closes every time I open settings."),
                ("App not responding", "The app is stuck on the loading screen and not responding."),
                ("Crash in dark mode", "When I switch to dark mode, the app crashes immediately."),
            ],
            "bug": [
                ("Wrong calculation", "The total amount shows $0.00 even though I have items in my cart."),
                ("Notifications broken", "I don't receive any notifications even though they are enabled."),
                ("Data not syncing", "My data doesn't sync between my phone and tablet anymore."),
                ("Images not loading", "Profile pictures and thumbnails are showing blank squares."),
            ],
            "feature_request": [
                ("Please add dark mode", "Would love to have a dark mode option for nighttime use."),
                ("Widget support", "It would be great to have a home screen widget showing my stats."),
                ("Export to CSV", "Could you add the ability to export data as CSV files?"),
            ],
            "how_to": [
                ("How to change language?", "I can't find where to change the app language to German."),
                ("How do I delete my account?", "Where is the option to delete my account and all data?"),
                ("Can't find settings", "Where are the notification settings? I've looked everywhere."),
                ("How to use voice input?", "Is there a voice input feature? I heard about it but can't find it."),
            ],
            "account": [
                ("Can't login", "I forgot my password and the reset email never arrives."),
                ("Subscription not working", "I paid for premium but still see ads."),
                ("Double charged", "I was charged twice this month for my subscription."),
            ],
            "performance": [
                ("App is very slow", "The app takes 10+ seconds to load every screen."),
                ("Battery drain", "This app drains my battery extremely fast in the background."),
            ],
        }

        # Gewichtung: 30% crash, 20% bug, 15% feature, 20% how_to, 10% account, 5% perf
        categories = (
            ["crash"] * 30 + ["bug"] * 20 + ["feature_request"] * 15 +
            ["how_to"] * 20 + ["account"] * 10 + ["performance"] * 5
        )

        platforms = ["ios", "android", "web"]
        versions = ["1.0.0", "1.1.0", "1.2.0"]

        tickets = []
        now = datetime.now(timezone.utc)

        for i in range(count):
            category = rng.choice(categories)
            template = rng.choice(templates[category])
            platform = rng.choice(platforms)
            version = rng.choice(versions)

            # Cluster: 50% der Crashes auf iOS 1.2.0
            if category == "crash" and rng.random() < 0.5:
                platform = "ios"
                version = "1.2.0"

            ts = now - timedelta(days=rng.uniform(0, 7), hours=rng.uniform(0, 24))

            tickets.append({
                "ticket_id": f"T-{i + 1:03d}",
                "app_id": app_id,
                "timestamp": ts.isoformat(),
                "source": rng.choice(["email", "in_app", "store_review"]),
                "subject": template[0],
                "body": template[1],
                "user_platform": platform,
                "app_version": version,
            })

        return tickets

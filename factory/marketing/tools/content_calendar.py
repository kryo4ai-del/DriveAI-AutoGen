"""Marketing Content Calendar — Plant und verwaltet den Redaktionskalender.

Deterministisch, kein LLM.
"""

import json
import logging
import os
from datetime import datetime, timedelta

logger = logging.getLogger("factory.marketing.tools.content_calendar")

# Item-Status
STATUS_SCHEDULED = "scheduled"
STATUS_PUBLISHED = "published"
STATUS_FAILED = "failed"
STATUS_CANCELLED = "cancelled"

# Launch-Kampagne Zeitplan: (offset_days, time, content_type, description)
_LAUNCH_TIMELINE = [
    (-14, "10:00", "social_post", "Teaser"),
    (-7, "10:00", "social_post", "Countdown"),
    (-3, "10:00", "video", "Behind-the-Scenes"),
    (-1, "10:00", "social_post", "Morgen-Teaser"),
    (0, "10:00", "social_post", "Launch-Post"),
    (1, "10:00", "social_post", "Danke + erste Zahlen"),
    (3, "10:00", "video", "Wie die Factory es gebaut hat"),
    (7, "10:00", "social_post", "Erste Woche Recap"),
]


class ContentCalendar:
    """Verwaltet den Marketing-Redaktionskalender als JSON-Dateien."""

    def __init__(self, calendar_dir: str = None) -> None:
        if calendar_dir:
            self.calendar_dir = calendar_dir
        else:
            from factory.marketing.config import OUTPUT_PATH
            self.calendar_dir = os.path.join(OUTPUT_PATH, "calendar")
        os.makedirs(self.calendar_dir, exist_ok=True)
        self._counter = 0
        logger.info("ContentCalendar initialized: %s", self.calendar_dir)

    def _next_id(self, publish_time: str) -> str:
        """Generiert eine Item-ID: CAL-{NNN}-{YYYYMMDD}-{HHMMSS}."""
        self._counter += 1
        dt = datetime.fromisoformat(publish_time)
        return f"CAL-{self._counter:03d}-{dt.strftime('%Y%m%d')}-{dt.strftime('%H%M%S')}"

    def _load_calendar(self, calendar_path: str) -> dict:
        """Laedt eine Kalender-Datei."""
        with open(calendar_path, "r", encoding="utf-8") as f:
            return json.load(f)

    def _save_calendar(self, calendar_path: str, data: dict) -> None:
        """Speichert eine Kalender-Datei."""
        with open(calendar_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    def _check_conflicts(self, items: list[dict], new_item: dict) -> list[str]:
        """Prueft auf Konflikte: min. 30 Min Abstand pro Platform."""
        warnings = []
        new_time = datetime.fromisoformat(new_item["publish_time"])
        new_platform = new_item["platform"]

        for item in items:
            if item["platform"] != new_platform:
                continue
            if item.get("status") in (STATUS_CANCELLED, STATUS_FAILED):
                continue
            existing_time = datetime.fromisoformat(item["publish_time"])
            diff = abs((new_time - existing_time).total_seconds())
            if diff < 1800:  # 30 Minuten
                warnings.append(
                    f"Konflikt: {new_item.get('item_id', '?')} und {item['item_id']} "
                    f"auf {new_platform} nur {int(diff // 60)} Min Abstand"
                )
        return warnings

    def create_weekly_calendar(
        self,
        week_start_date: str,
        content_items: list[dict],
    ) -> str:
        """Erstellt einen Wochenplan.

        Args:
            week_start_date: ISO-Datum (z.B. "2026-04-01")
            content_items: Liste von dicts mit content_type, platform,
                          file_paths, publish_time, tags (optional)

        Returns:
            Pfad zur Kalender-Datei.
        """
        items = []
        all_warnings = []

        for ci in content_items:
            item = {
                "item_id": self._next_id(ci["publish_time"]),
                "content_type": ci.get("content_type", "social_post"),
                "platform": ci.get("platform", "x"),
                "file_paths": ci.get("file_paths", {"text": None, "media": None}),
                "publish_time": ci["publish_time"],
                "status": STATUS_SCHEDULED,
                "published_at": None,
                "error": None,
                "metadata": None,
                "tags": ci.get("tags", []),
            }
            warnings = self._check_conflicts(items, item)
            all_warnings.extend(warnings)
            items.append(item)

        # Sortiere chronologisch
        items.sort(key=lambda x: x["publish_time"])

        calendar = {
            "name": f"week_{week_start_date}",
            "created_at": datetime.now().isoformat(),
            "week_start": week_start_date,
            "items": items,
            "warnings": all_warnings,
        }

        path = os.path.join(self.calendar_dir, f"week_{week_start_date}.json")
        self._save_calendar(path, calendar)
        logger.info("Weekly calendar: %s (%d items, %d warnings)",
                     path, len(items), len(all_warnings))
        return path

    def add_item(self, calendar_path: str, content_item: dict) -> str:
        """Fuegt ein Item zum bestehenden Kalender hinzu.

        Returns:
            item_id des neuen Items.
        """
        cal = self._load_calendar(calendar_path)
        item = {
            "item_id": self._next_id(content_item["publish_time"]),
            "content_type": content_item.get("content_type", "social_post"),
            "platform": content_item.get("platform", "x"),
            "file_paths": content_item.get("file_paths", {"text": None, "media": None}),
            "publish_time": content_item["publish_time"],
            "status": STATUS_SCHEDULED,
            "published_at": None,
            "error": None,
            "metadata": None,
            "tags": content_item.get("tags", []),
        }

        warnings = self._check_conflicts(cal["items"], item)
        cal["items"].append(item)
        cal["items"].sort(key=lambda x: x["publish_time"])
        cal.setdefault("warnings", []).extend(warnings)

        self._save_calendar(calendar_path, cal)
        logger.info("Added item %s to %s", item["item_id"], calendar_path)
        return item["item_id"]

    def get_due_items(
        self,
        calendar_path: str,
        as_of: datetime = None,
    ) -> list[dict]:
        """Gibt alle faelligen Items zurueck (publish_time <= as_of, status=scheduled)."""
        cal = self._load_calendar(calendar_path)
        as_of = as_of or datetime.now()

        due = []
        for item in cal["items"]:
            if item["status"] != STATUS_SCHEDULED:
                continue
            pub_time = datetime.fromisoformat(item["publish_time"])
            if pub_time <= as_of:
                due.append(item)

        due.sort(key=lambda x: x["publish_time"])
        return due

    def mark_published(
        self,
        calendar_path: str,
        item_id: str,
        metadata: dict = None,
    ) -> bool:
        """Setzt Status auf 'published' + Zeitstempel."""
        cal = self._load_calendar(calendar_path)
        for item in cal["items"]:
            if item["item_id"] == item_id:
                item["status"] = STATUS_PUBLISHED
                item["published_at"] = datetime.now().isoformat()
                if metadata:
                    item["metadata"] = metadata
                self._save_calendar(calendar_path, cal)
                logger.info("Marked %s as published", item_id)
                return True
        logger.warning("Item %s not found", item_id)
        return False

    def mark_failed(
        self,
        calendar_path: str,
        item_id: str,
        error_message: str,
    ) -> bool:
        """Setzt Status auf 'failed' + Fehlergrund."""
        cal = self._load_calendar(calendar_path)
        for item in cal["items"]:
            if item["item_id"] == item_id:
                item["status"] = STATUS_FAILED
                item["error"] = error_message
                self._save_calendar(calendar_path, cal)
                logger.info("Marked %s as failed: %s", item_id, error_message)
                return True
        logger.warning("Item %s not found", item_id)
        return False

    def get_calendar_stats(self, calendar_path: str) -> dict:
        """Gibt Statistik zurueck."""
        cal = self._load_calendar(calendar_path)
        items = cal["items"]

        stats = {
            "total": len(items),
            "scheduled": 0,
            "published": 0,
            "failed": 0,
            "cancelled": 0,
            "by_platform": {},
            "by_type": {},
        }
        for item in items:
            status = item.get("status", STATUS_SCHEDULED)
            if status in stats:
                stats[status] += 1

            platform = item.get("platform", "unknown")
            stats["by_platform"][platform] = stats["by_platform"].get(platform, 0) + 1

            ctype = item.get("content_type", "unknown")
            stats["by_type"][ctype] = stats["by_type"].get(ctype, 0) + 1

        return stats

    def create_launch_campaign(
        self,
        project_slug: str,
        launch_date: str,
        platforms: list[str] = None,
    ) -> str:
        """Erstellt einen Kampagnen-Kalender fuer einen App-Launch.

        Args:
            project_slug: z.B. "echomatch"
            launch_date: ISO-Datum (z.B. "2026-05-01")
            platforms: Liste der Plattformen (default: youtube, tiktok, x)

        Returns:
            Pfad zur Kalender-Datei.
        """
        platforms = platforms or ["youtube", "tiktok", "x"]
        launch_dt = datetime.fromisoformat(launch_date)
        items = []

        for offset_days, time_str, content_type, description in _LAUNCH_TIMELINE:
            dt = launch_dt + timedelta(days=offset_days)
            hour, minute = map(int, time_str.split(":"))
            dt = dt.replace(hour=hour, minute=minute, second=0)

            # BTS-Videos nur auf YouTube + TikTok
            target_platforms = platforms
            if content_type == "video" and offset_days == -3:
                target_platforms = [p for p in platforms if p in ("youtube", "tiktok")]
            if content_type == "video" and offset_days == 3:
                target_platforms = [p for p in platforms if p == "youtube"]

            for platform in target_platforms:
                item = {
                    "item_id": self._next_id(dt.isoformat()),
                    "content_type": content_type,
                    "platform": platform,
                    "file_paths": {"text": None, "media": None},
                    "publish_time": dt.isoformat(),
                    "status": STATUS_SCHEDULED,
                    "published_at": None,
                    "error": None,
                    "metadata": None,
                    "tags": [project_slug, description.lower().replace(" ", "_")],
                }
                items.append(item)

        items.sort(key=lambda x: x["publish_time"])

        calendar = {
            "name": f"campaign_{project_slug}",
            "created_at": datetime.now().isoformat(),
            "project_slug": project_slug,
            "launch_date": launch_date,
            "platforms": platforms,
            "items": items,
            "warnings": [],
        }

        path = os.path.join(self.calendar_dir, f"campaign_{project_slug}.json")
        self._save_calendar(path, calendar)
        logger.info("Launch campaign: %s (%d items across %s)",
                     path, len(items), ", ".join(platforms))
        return path

    def list_calendars(self) -> list[dict]:
        """Listet alle Kalender-Dateien mit Basic-Stats."""
        result = []
        for fname in sorted(os.listdir(self.calendar_dir)):
            if not fname.endswith(".json"):
                continue
            path = os.path.join(self.calendar_dir, fname)
            try:
                cal = self._load_calendar(path)
                items = cal.get("items", [])
                times = [i["publish_time"] for i in items if i.get("publish_time")]
                date_range = ""
                if times:
                    date_range = f"{min(times)[:10]} — {max(times)[:10]}"
                result.append({
                    "path": path,
                    "name": cal.get("name", fname),
                    "items": len(items),
                    "date_range": date_range,
                })
            except Exception as e:
                logger.warning("Could not read %s: %s", fname, e)
        return result

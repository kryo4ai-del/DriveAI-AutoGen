"""Publishing Orchestrator (MKT-08) — Verteilt Content auf Plattformen.

DETERMINISTISCH — kein LLM. Liest Content-Kalender, ruft Adapter auf,
trackt Ergebnisse ueber Alert-System.

KRITISCH: dry_run=True ist IMMER der Default. Kein realer Post ohne
explizite CEO-Freigabe.
"""

import json
import logging
import os
from datetime import datetime, timedelta

logger = logging.getLogger("factory.marketing.agents.publishing_orchestrator")


class PublishingOrchestrator:
    """Verteilt Content auf Plattformen — deterministisch, kein LLM."""

    def __init__(self, dry_run: bool = True):
        self.dry_run = dry_run
        self.agent_info = self._load_persona()

        from factory.marketing.adapters import ALL_ADAPTERS, get_adapter

        self._get_adapter = get_adapter
        self._available_platforms = list(ALL_ADAPTERS.keys())

        from factory.marketing.tools.content_calendar import ContentCalendar

        self.calendar = ContentCalendar()

        from factory.marketing.alerts.alert_manager import MarketingAlertManager

        self.alerts = MarketingAlertManager()

        if dry_run:
            logger.info("Publishing Orchestrator: DRY RUN mode")
        else:
            logger.warning("Publishing Orchestrator: LIVE MODE!")

    def _load_persona(self) -> dict:
        path = os.path.join(
            os.path.dirname(__file__), "agent_publishing_orchestrator.json"
        )
        try:
            with open(path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception:
            return {"id": "MKT-08", "name": "Publishing Orchestrator"}

    def publish_due_items(self, calendar_path: str = None) -> dict:
        """Verarbeitet alle faelligen Items aus dem Content-Kalender.

        Returns:
            dict mit processed, published, failed, skipped, details
        """
        if calendar_path is None:
            calendars = self.calendar.list_calendars()
            if not calendars:
                logger.info("No calendars found")
                return {
                    "processed": 0,
                    "published": 0,
                    "failed": 0,
                    "skipped": 0,
                    "details": [],
                }
            calendar_path = calendars[-1]["path"]

        due_items = self.calendar.get_due_items(calendar_path)
        results = {
            "processed": 0,
            "published": 0,
            "failed": 0,
            "skipped": 0,
            "details": [],
        }

        for item in due_items:
            results["processed"] += 1
            platform = item.get("platform", "unknown")
            item_id = item.get("item_id", "unknown")

            try:
                adapter = self._get_adapter(platform, dry_run=self.dry_run)
                result = self._publish_item(adapter, item)

                if result.get("error"):
                    results["failed"] += 1
                    self.calendar.mark_failed(
                        calendar_path, item_id, result["error"]
                    )
                    self.alerts.create_alert(
                        type="alert",
                        priority="high",
                        category="system",
                        source_agent="MKT-08",
                        title=f"Publishing fehlgeschlagen: {platform}",
                        description=(
                            f"Item {item_id} konnte nicht auf {platform} "
                            f"veroeffentlicht werden: {result['error']}"
                        ),
                        action_required="Fehler pruefen und ggf. manuell posten",
                    )
                else:
                    results["published"] += 1
                    self.calendar.mark_published(
                        calendar_path, item_id, metadata=result
                    )

                results["details"].append(
                    {
                        "item_id": item_id,
                        "platform": platform,
                        "status": "failed" if result.get("error") else "published",
                        "result": result,
                    }
                )

            except ValueError as e:
                results["skipped"] += 1
                results["details"].append(
                    {
                        "item_id": item_id,
                        "platform": platform,
                        "status": "skipped",
                        "result": {"error": str(e)},
                    }
                )
            except Exception as e:
                results["failed"] += 1
                results["details"].append(
                    {
                        "item_id": item_id,
                        "platform": platform,
                        "status": "error",
                        "result": {"error": str(e)},
                    }
                )

        logger.info(
            f"Publishing run: {results['published']} published, "
            f"{results['failed']} failed, {results['skipped']} skipped"
        )
        return results

    def _publish_item(self, adapter, item: dict) -> dict:
        """Veroeffentlicht ein einzelnes Item ueber den Adapter."""
        content_type = item.get("content_type", "social_post")
        platform = item.get("platform", "unknown")
        file_paths = item.get("file_paths", {})
        text_path = file_paths.get("text") if isinstance(file_paths, dict) else None
        media_path = file_paths.get("media") if isinstance(file_paths, dict) else None

        text = ""
        if text_path and os.path.exists(text_path):
            with open(text_path, "r", encoding="utf-8") as f:
                text = f.read()

        if platform == "youtube":
            if media_path and os.path.exists(media_path):
                return adapter.upload_video(
                    video_path=media_path,
                    title=text[:100] if text else "DriveAI Factory",
                    description=text[:5000] if text else "",
                    tags=item.get("tags", []),
                    privacy="private",
                )
            return {"error": "no_media_for_youtube"}

        elif platform == "tiktok":
            if media_path and os.path.exists(media_path):
                return adapter.upload_video(
                    video_path=media_path,
                    description=text[:2200] if text else "",
                    hashtags=item.get("tags"),
                )
            return {"error": "no_media_for_tiktok"}

        elif platform == "x":
            media_list = (
                [media_path] if media_path and os.path.exists(media_path) else None
            )
            return adapter.post_tweet(
                text=text[:280] if text else "DriveAI Factory Update",
                media_paths=media_list,
            )

        else:
            if hasattr(adapter, "post_update"):
                return adapter.post_update(text=text[:500])
            elif hasattr(adapter, "post_image"):
                return adapter.post_image(image_path=media_path, caption=text[:200])
            return {"stub": True, "platform": platform}

    def publish_single(
        self, platform: str, text: str = None, media_path: str = None,
        dry_run: bool = True,
    ) -> dict:
        """Einzelnen Post veroeffentlichen.

        Beide dry_run-Flags (Orchestrator + Method) muessen False sein fuer Live.
        """
        effective_dry_run = self.dry_run or dry_run
        adapter = self._get_adapter(platform, dry_run=effective_dry_run)

        if platform == "x":
            return adapter.post_tweet(
                text=text or "", media_paths=[media_path] if media_path else None
            )
        elif platform in ("youtube", "tiktok"):
            if not media_path:
                return {"error": f"no_media_for_{platform}"}
            return adapter.upload_video(
                video_path=media_path,
                title=text or "DriveAI Factory",
                description=text or "",
            )
        else:
            return {"stub": True, "platform": platform}

    def cross_post(
        self, text: str, media_path: str = None,
        platforms: list[str] = None, stagger_minutes: int = 60,
        calendar_path: str = None,
    ) -> str:
        """Verteilt Content auf mehrere Plattformen mit zeitlichem Versatz.

        POSTET NICHT DIREKT — erstellt nur den Kalender-Plan.
        """
        if platforms is None:
            platforms = ["youtube", "tiktok", "x"]

        now = datetime.now()
        items = []

        for i, platform in enumerate(platforms):
            publish_time = now + timedelta(minutes=i * stagger_minutes)
            items.append(
                {
                    "content_type": "video"
                    if platform in ("youtube", "tiktok")
                    else "social_post",
                    "platform": platform,
                    "file_paths": {"text": None, "media": media_path},
                    "publish_time": publish_time.isoformat(),
                    "tags": ["cross_post"],
                }
            )

        if calendar_path is None:
            calendar_path = self.calendar.create_weekly_calendar(
                now.strftime("%Y-%m-%d"), items
            )
        else:
            for item in items:
                self.calendar.add_item(calendar_path, item)

        logger.info(
            f"Cross-post plan created: {len(items)} items on {platforms}"
        )
        return calendar_path

    def get_publishing_status(self) -> dict:
        """Uebersicht ueber alle Kalender und deren Status."""
        calendars = self.calendar.list_calendars()
        status = {
            "calendars": len(calendars),
            "total_items": 0,
            "scheduled": 0,
            "published": 0,
            "failed": 0,
            "by_platform": {},
        }

        for cal in calendars:
            try:
                stats = self.calendar.get_calendar_stats(cal["path"])
                status["total_items"] += stats.get("total", 0)
                status["scheduled"] += stats.get("scheduled", 0)
                status["published"] += stats.get("published", 0)
                status["failed"] += stats.get("failed", 0)
                for platform, count in stats.get("by_platform", {}).items():
                    status["by_platform"][platform] = (
                        status["by_platform"].get(platform, 0) + count
                    )
            except Exception:
                pass

        return status

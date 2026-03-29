"""Social Media Analytics Collector — Sammelt Performance-Daten von allen Plattformen.

Deterministisch, kein LLM. Nutzt die bestehenden Adapter.
"""

import logging
from typing import Optional

logger = logging.getLogger("factory.marketing.tools.social_analytics_collector")


class SocialAnalyticsCollector:
    """Sammelt und aggregiert Social Media Analytics."""

    def __init__(self):
        from factory.marketing.adapters import get_adapter, ACTIVE_ADAPTERS
        self.adapters = {}
        for platform in ACTIVE_ADAPTERS:
            try:
                self.adapters[platform] = get_adapter(platform, dry_run=True)
            except Exception as e:
                logger.warning("Could not init %s adapter: %s", platform, e)

        from factory.marketing.tools.ranking_database import RankingDatabase
        self.db = RankingDatabase()

    # Social-Media-Plattformen (keine Store-Adapter)
    SOCIAL_PLATFORMS = {"youtube", "tiktok", "x"}

    # Realistische Mock-Stats pro Plattform (Dry-Run)
    _MOCK_STATS = {
        "youtube": {"subscribers": 12400, "views_30d": 185000, "videos": 47},
        "tiktok": {"followers": 8200, "views_30d": 420000, "likes_30d": 31000},
        "x": {"followers": 5600, "impressions_30d": 95000, "engagements_30d": 4200},
    }

    def _get_platform_stats(self, platform: str, adapter) -> dict:
        """Ruft Account-Stats vom Adapter ab (verschiedene Methoden-Namen)."""
        for method_name in ("get_account_stats", "get_channel_stats"):
            if hasattr(adapter, method_name):
                result = getattr(adapter, method_name)()
                # Dry-Run-Dicts filtern (enthalten "dry_run" key)
                if isinstance(result, dict) and result.get("dry_run"):
                    return dict(self._MOCK_STATS.get(platform, {}))
                return result
        return {}

    def collect_all_platform_stats(self) -> dict:
        """Sammelt Account-Stats von allen aktiven Social-Media-Plattformen.

        Speichert in DB. Fehler bei einem Adapter: loggen, weitermachen.
        Returns: {platform: stats_dict}
        """
        results = {}
        for platform, adapter in self.adapters.items():
            if platform not in self.SOCIAL_PLATFORMS:
                continue
            try:
                stats = self._get_platform_stats(platform, adapter)
                if stats:
                    self.db.store_social_metrics(platform, stats)
                    results[platform] = stats
                    logger.info("Collected stats for %s: %d metrics", platform, len(stats))
                else:
                    logger.info("No stats available for %s", platform)
            except Exception as e:
                logger.warning("Failed to collect stats for %s: %s", platform, e)
                results[platform] = {"error": str(e)}
        return results

    def collect_post_performance(self, platform: str, post_id: str,
                                 content_type: str = "unknown") -> dict:
        """Sammelt Performance eines einzelnen Posts. Speichert in DB."""
        adapter = self.adapters.get(platform)
        if not adapter:
            return {"error": f"No adapter for {platform}"}

        try:
            # Verschiedene Adapter haben verschiedene Analytics-Methoden
            if platform == "youtube":
                perf = adapter.get_video_analytics(post_id) if hasattr(adapter, "get_video_analytics") else {}
            elif platform == "x":
                perf = adapter.get_tweet_analytics(post_id) if hasattr(adapter, "get_tweet_analytics") else {}
            elif platform == "tiktok":
                perf = adapter.get_video_analytics(post_id) if hasattr(adapter, "get_video_analytics") else {}
            else:
                perf = {}

            if perf:
                self.db.store_post_performance(platform, post_id, content_type, perf)
            return perf
        except Exception as e:
            logger.warning("Failed to collect performance for %s/%s: %s", platform, post_id, e)
            return {"error": str(e)}

    def collect_all_recent_performance(self, days: int = 7) -> dict:
        """Sammelt Performance aller kuerzlich geposteten Inhalte.

        Liest aus dem Content-Kalender welche Posts veroeffentlicht wurden.
        """
        results = {"collected": 0, "errors": 0, "by_platform": {}}

        try:
            from factory.marketing.tools.content_calendar import ContentCalendar
            cal = ContentCalendar()
            calendars = cal.list_calendars()

            for cal_info in calendars:
                try:
                    cal_data = cal._load_calendar(cal_info["path"])
                    for item in cal_data.get("items", []):
                        if item.get("status") != "published":
                            continue
                        metadata = item.get("metadata") or {}
                        post_id = metadata.get("post_id") or metadata.get("video_id")
                        if not post_id:
                            continue

                        platform = item.get("platform", "unknown")
                        perf = self.collect_post_performance(
                            platform, post_id, item.get("content_type", "unknown")
                        )
                        if "error" not in perf:
                            results["collected"] += 1
                            results["by_platform"].setdefault(platform, []).append(post_id)
                        else:
                            results["errors"] += 1
                except Exception as e:
                    logger.warning("Error processing calendar %s: %s", cal_info.get("name"), e)
        except Exception as e:
            logger.warning("Could not access content calendar: %s", e)

        return results

    def get_cross_platform_summary(self, days: int = 30) -> dict:
        """Aggregierte Uebersicht ueber alle Plattformen."""
        summary = {
            "total_impressions": 0,
            "total_engagements": 0,
            "engagement_rate": 0.0,
            "by_platform": {},
            "top_platform": "",
            "trend": "stable",
        }

        top_posts = self.db.get_top_posts(limit=100, days=days)

        platform_data = {}
        for post in top_posts:
            p = post.get("platform", "unknown")
            if p not in platform_data:
                platform_data[p] = {"impressions": 0, "engagements": 0, "posts": 0}
            platform_data[p]["impressions"] += post.get("impressions", 0)
            platform_data[p]["engagements"] += post.get("engagements", 0)
            platform_data[p]["posts"] += 1

        for p, data in platform_data.items():
            summary["total_impressions"] += data["impressions"]
            summary["total_engagements"] += data["engagements"]
            data["engagement_rate"] = round(
                data["engagements"] / max(data["impressions"], 1) * 100, 2
            )
            summary["by_platform"][p] = data

        if summary["total_impressions"] > 0:
            summary["engagement_rate"] = round(
                summary["total_engagements"] / summary["total_impressions"] * 100, 2
            )

        if platform_data:
            summary["top_platform"] = max(
                platform_data, key=lambda p: platform_data[p]["engagements"]
            )

        return summary

    def identify_top_content(self, metric: str = "engagements",
                             limit: int = 5, days: int = 30) -> list[dict]:
        """Identifiziert den best-performenden Content. Liest aus DB."""
        return self.db.get_top_posts(metric=metric, limit=limit, days=days)

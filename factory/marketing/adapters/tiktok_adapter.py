"""TikTok Content Posting API Adapter.

Alle Operationen default Dry-Run.
"""

import logging
import os
from datetime import datetime

logger = logging.getLogger("factory.marketing.adapters.tiktok")


class TikTokAdapter:
    """TikTok Content Posting API v2 Adapter.

    Default: Dry-Run-Modus. Kein realer Upload ohne explizites dry_run=False.
    """

    STATUS = "active"
    PLATFORM = "tiktok"

    def __init__(self, dry_run: bool = True):
        self.access_token = os.getenv("TIKTOK_ACCESS_TOKEN")
        self._force_dry_run = self.access_token is None
        self.dry_run = True if self._force_dry_run else dry_run
        self._base_url = "https://open.tiktokapis.com/v2"

        if self._force_dry_run:
            logger.info("TikTok Adapter: No access token — DRY RUN enforced")
        elif self.dry_run:
            logger.info("TikTok Adapter: Token found but DRY RUN active")
        else:
            logger.warning("TikTok Adapter: LIVE MODE — uploads will be real!")

    def _headers(self) -> dict:
        return {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json",
        }

    def _dry_run_log(self, method: str, **kwargs) -> dict:
        logger.info(f"[DRY RUN] TikTok.{method}({kwargs})")
        return {
            "dry_run": True,
            "method": method,
            "params": {k: str(v)[:100] for k, v in kwargs.items()},
            "timestamp": datetime.now().isoformat(),
            "fake_id": f"dry_run_{method}_{datetime.now().strftime('%Y%m%d%H%M%S')}",
        }

    def upload_video(
        self, video_path: str, description: str, hashtags: list[str] = None
    ) -> dict:
        """Laedt ein Video auf TikTok hoch.

        Args:
            video_path: Pfad zur Video-Datei
            description: Beschreibung (max 2200 Zeichen)
            hashtags: Liste von Hashtags (ohne #)
        """
        if not os.path.exists(video_path):
            logger.error(f"Video file not found: {video_path}")
            return {"error": "file_not_found", "path": video_path}

        # Hashtags in Beschreibung einbauen
        full_desc = description[:2200]
        if hashtags:
            tags_str = " ".join(f"#{t.lstrip('#')}" for t in hashtags)
            full_desc = f"{description[:2100]} {tags_str}"[:2200]

        if self.dry_run:
            return self._dry_run_log(
                "upload_video",
                video_path=video_path,
                description=full_desc[:50],
                hashtags=hashtags,
            )

        try:
            import requests

            # Step 1: Init upload
            init_url = f"{self._base_url}/post/publish/video/init/"
            payload = {
                "post_info": {
                    "title": full_desc[:150],
                    "description": full_desc,
                    "privacy_level": "SELF_ONLY",
                    "disable_comment": False,
                    "disable_duet": False,
                    "disable_stitch": False,
                },
                "source_info": {"source": "FILE_UPLOAD"},
            }

            resp = requests.post(
                init_url, json=payload, headers=self._headers(), timeout=30
            )

            if resp.status_code == 429:
                logger.warning("TikTok rate limit hit!")
                return {"error": "rate_limit", "retry_after": resp.headers.get("Retry-After")}

            resp.raise_for_status()
            data = resp.json()

            upload_url = data.get("data", {}).get("upload_url")
            publish_id = data.get("data", {}).get("publish_id")

            if not upload_url:
                return {"error": "no_upload_url", "response": data}

            # Step 2: Upload video file
            with open(video_path, "rb") as f:
                upload_resp = requests.put(
                    upload_url,
                    data=f,
                    headers={
                        "Content-Type": "video/mp4",
                        "Authorization": f"Bearer {self.access_token}",
                    },
                    timeout=300,
                )
                upload_resp.raise_for_status()

            logger.info(f"TikTok upload success: {publish_id}")
            return {"publish_id": publish_id, "dry_run": False}

        except Exception as e:
            logger.error(f"TikTok upload failed: {e}")
            return {"error": str(e)}

    def get_video_analytics(self, video_id: str) -> dict:
        """Views, Likes, Shares, Comments."""
        if self.dry_run:
            return self._dry_run_log("get_video_analytics", video_id=video_id)
        return {"error": "not_implemented_for_live"}

    def get_account_stats(self) -> dict:
        """Follower, Total Likes, Video Count."""
        if self.dry_run:
            return self._dry_run_log("get_account_stats")
        return {"error": "not_implemented_for_live"}

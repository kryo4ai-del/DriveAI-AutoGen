"""Instagram Adapter Stub — nicht implementiert, nur Logging."""

import logging
from datetime import datetime

logger = logging.getLogger("factory.marketing.adapters.instagram")


class InstagramAdapter:
    """Instagram Adapter Stub."""

    STATUS = "stub"
    PLATFORM = "instagram"

    def __init__(self, dry_run: bool = True):
        self.dry_run = True  # IMMER dry_run
        logger.info("Instagram Adapter: STUB — not yet implemented")

    def _stub_log(self, method: str, **kwargs) -> dict:
        logger.info(f"[STUB] Instagram.{method}({kwargs})")
        return {"stub": True, "method": method, "platform": self.PLATFORM,
                "timestamp": datetime.now().isoformat()}

    def post_image(self, image_path: str = None, caption: str = None) -> dict:
        return self._stub_log("post_image", image_path=image_path, caption=caption)

    def post_reel(self, video_path: str = None, caption: str = None) -> dict:
        return self._stub_log("post_reel", video_path=video_path, caption=caption)

    def post_story(self, media_path: str = None, text: str = None) -> dict:
        return self._stub_log("post_story", media_path=media_path, text=text)

    def get_post_analytics(self, post_id: str = None) -> dict:
        return self._stub_log("get_post_analytics", post_id=post_id)

    def get_account_stats(self) -> dict:
        return self._stub_log("get_account_stats")

"""LinkedIn Adapter Stub — nicht implementiert, nur Logging."""

import logging
from datetime import datetime

logger = logging.getLogger("factory.marketing.adapters.linkedin")


class LinkedInAdapter:
    """LinkedIn Adapter Stub."""

    STATUS = "stub"
    PLATFORM = "linkedin"

    def __init__(self, dry_run: bool = True):
        self.dry_run = True
        logger.info("LinkedIn Adapter: STUB — not yet implemented")

    def _stub_log(self, method: str, **kwargs) -> dict:
        logger.info(f"[STUB] LinkedIn.{method}({kwargs})")
        return {"stub": True, "method": method, "platform": self.PLATFORM,
                "timestamp": datetime.now().isoformat()}

    def post_article(self, title: str = None, body: str = None) -> dict:
        return self._stub_log("post_article", title=title)

    def post_update(self, text: str = None, media_path: str = None) -> dict:
        return self._stub_log("post_update", text=text)

    def get_post_analytics(self, post_id: str = None) -> dict:
        return self._stub_log("get_post_analytics", post_id=post_id)

    def get_account_stats(self) -> dict:
        return self._stub_log("get_account_stats")

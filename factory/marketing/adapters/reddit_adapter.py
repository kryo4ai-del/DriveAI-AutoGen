"""Reddit Adapter Stub — nicht implementiert, nur Logging."""

import logging
from datetime import datetime

logger = logging.getLogger("factory.marketing.adapters.reddit")


class RedditAdapter:
    """Reddit Adapter Stub."""

    STATUS = "stub"
    PLATFORM = "reddit"

    def __init__(self, dry_run: bool = True):
        self.dry_run = True
        logger.info("Reddit Adapter: STUB — not yet implemented")

    def _stub_log(self, method: str, **kwargs) -> dict:
        logger.info(f"[STUB] Reddit.{method}({kwargs})")
        return {"stub": True, "method": method, "platform": self.PLATFORM,
                "timestamp": datetime.now().isoformat()}

    def submit_post(self, subreddit: str = None, title: str = None, body: str = None) -> dict:
        return self._stub_log("submit_post", subreddit=subreddit, title=title)

    def submit_link(self, subreddit: str = None, title: str = None, url: str = None) -> dict:
        return self._stub_log("submit_link", subreddit=subreddit, title=title, url=url)

    def get_post_analytics(self, post_id: str = None) -> dict:
        return self._stub_log("get_post_analytics", post_id=post_id)

    def get_subreddit_stats(self, subreddit: str = None) -> dict:
        return self._stub_log("get_subreddit_stats", subreddit=subreddit)

"""Twitch Adapter Stub — nicht implementiert, nur Logging."""

import logging
from datetime import datetime

logger = logging.getLogger("factory.marketing.adapters.twitch")


class TwitchAdapter:
    """Twitch Adapter Stub."""

    STATUS = "stub"
    PLATFORM = "twitch"

    def __init__(self, dry_run: bool = True):
        self.dry_run = True
        logger.info("Twitch Adapter: STUB — not yet implemented")

    def _stub_log(self, method: str, **kwargs) -> dict:
        logger.info(f"[STUB] Twitch.{method}({kwargs})")
        return {"stub": True, "method": method, "platform": self.PLATFORM,
                "timestamp": datetime.now().isoformat()}

    def create_clip(self, broadcaster_id: str = None) -> dict:
        return self._stub_log("create_clip", broadcaster_id=broadcaster_id)

    def update_stream_info(self, title: str = None, game_id: str = None) -> dict:
        return self._stub_log("update_stream_info", title=title, game_id=game_id)

    def get_stream_stats(self, broadcaster_id: str = None) -> dict:
        return self._stub_log("get_stream_stats", broadcaster_id=broadcaster_id)

    def get_channel_stats(self, broadcaster_id: str = None) -> dict:
        return self._stub_log("get_channel_stats", broadcaster_id=broadcaster_id)

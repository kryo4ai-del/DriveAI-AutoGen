"""Marketing Platform Adapters — YouTube, TikTok, X, App Store, Google Play + Stubs."""

from .youtube_adapter import YouTubeAdapter
from .tiktok_adapter import TikTokAdapter
from .x_adapter import XAdapter
from .appstore_adapter import AppStoreAdapter
from .googleplay_adapter import GooglePlayAdapter
from .instagram_adapter import InstagramAdapter
from .linkedin_adapter import LinkedInAdapter
from .reddit_adapter import RedditAdapter
from .twitch_adapter import TwitchAdapter

ACTIVE_ADAPTERS = {
    "youtube": YouTubeAdapter,
    "tiktok": TikTokAdapter,
    "x": XAdapter,
    "app_store": AppStoreAdapter,
    "google_play": GooglePlayAdapter,
}

STUB_ADAPTERS = {
    "instagram": InstagramAdapter,
    "linkedin": LinkedInAdapter,
    "reddit": RedditAdapter,
    "twitch": TwitchAdapter,
}

ALL_ADAPTERS = {**ACTIVE_ADAPTERS, **STUB_ADAPTERS}


def get_adapter(platform: str, dry_run: bool = True):
    """Factory-Methode: gibt den richtigen Adapter fuer eine Plattform zurueck.

    dry_run ist IMMER True als Default.
    """
    adapter_class = ALL_ADAPTERS.get(platform.lower())
    if adapter_class is None:
        raise ValueError(
            f"Unknown platform: {platform}. Available: {list(ALL_ADAPTERS.keys())}"
        )
    return adapter_class(dry_run=dry_run)

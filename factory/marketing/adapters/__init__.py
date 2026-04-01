"""Marketing Platform Adapters — 16 total: 8 active + 4 Publishing-Stubs + 4 Ad-Platform-Stubs."""

from .youtube_adapter import YouTubeAdapter
from .tiktok_adapter import TikTokAdapter
from .x_adapter import XAdapter
from .appstore_adapter import AppStoreAdapter
from .googleplay_adapter import GooglePlayAdapter
from .instagram_adapter import InstagramAdapter
from .linkedin_adapter import LinkedInAdapter
from .reddit_adapter import RedditAdapter
from .twitch_adapter import TwitchAdapter
from .github_adapter import GitHubAdapter
from .huggingface_adapter import HuggingFaceAdapter
from .smtp_adapter import SMTPAdapter
from .meta_ads_adapter import MetaAdsAdapter
from .google_ads_adapter import GoogleAdsAdapter
from .tiktok_ads_adapter import TikTokAdsAdapter
from .apple_search_ads_adapter import AppleSearchAdsAdapter

ACTIVE_ADAPTERS = {
    "youtube": YouTubeAdapter,
    "tiktok": TikTokAdapter,
    "x": XAdapter,
    "app_store": AppStoreAdapter,
    "google_play": GooglePlayAdapter,
    "github": GitHubAdapter,
    "huggingface": HuggingFaceAdapter,
    "email": SMTPAdapter,
}

STUB_ADAPTERS = {
    "instagram": InstagramAdapter,
    "linkedin": LinkedInAdapter,
    "reddit": RedditAdapter,
    "twitch": TwitchAdapter,
}

AD_PLATFORM_STUBS = {
    "meta_ads": MetaAdsAdapter,
    "google_ads": GoogleAdsAdapter,
    "tiktok_ads": TikTokAdsAdapter,
    "apple_search_ads": AppleSearchAdsAdapter,
}

ALL_ADAPTERS = {**ACTIVE_ADAPTERS, **STUB_ADAPTERS, **AD_PLATFORM_STUBS}


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

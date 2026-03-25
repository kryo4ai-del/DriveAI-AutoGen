"""DriveAI Factory — Store Preparation Configuration.

Central configuration for all Store Prep modules.
No external dependencies — only stdlib.
"""

from dataclasses import dataclass, field


@dataclass
class StorePrepConfig:
    """Configuration for the Store Preparation layer."""

    # Output
    output_base_dir: str = "factory/store_prep/output"

    # Metadata
    default_languages: list = field(default_factory=lambda: ["de-DE", "en-US"])
    default_age_rating: str = "4+"
    default_content_rating: str = "Everyone"

    # Apple App Store Limits
    apple_app_name_max: int = 30
    apple_subtitle_max: int = 30
    apple_promo_text_max: int = 170
    apple_description_max: int = 4000
    apple_keywords_max: int = 100
    apple_whats_new_max: int = 4000

    # Google Play Store Limits
    google_app_name_max: int = 30
    google_short_desc_max: int = 80
    google_full_desc_max: int = 4000
    google_whats_new_max: int = 500

    # Web / SEO Limits
    web_meta_desc_max: int = 160
    web_title_max: int = 60

    # LLM for Store Text Generation
    use_llm_for_texts: bool = True
    llm_timeout_seconds: int = 60

    # CEO Gates
    require_metadata_review: bool = True
    require_asset_review: bool = True

    # Timeouts
    total_prep_timeout_seconds: int = 1800  # 30 minutes

    # Asset Forge
    use_asset_forge: bool = True

    # Screenshots
    ios_screenshot_sizes: list = field(default_factory=lambda: [
        {"name": "6.7inch", "width": 1290, "height": 2796, "required": True},
        {"name": "6.1inch", "width": 1179, "height": 2556, "required": False},
        {"name": "ipad_12.9inch", "width": 2048, "height": 2732, "required": False},
    ])
    google_min_screenshots: int = 2
    google_max_screenshots: int = 8
    google_feature_graphic_size: list = field(default_factory=lambda: [1024, 500])

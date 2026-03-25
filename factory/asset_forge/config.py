"""Asset Forge configuration."""

from dataclasses import dataclass, field


@dataclass
class AssetForgeConfig:
    max_cost_per_asset: float = 0.10
    max_cost_per_run: float = 10.0
    max_retries_on_style_fail: int = 2
    style_check_enabled: bool = True
    llm_style_check_enabled: bool = False
    llm_style_check_priority: str = "launch_critical"
    quality_minimum: float = 0.0  # 0 until enough scoring data exists
    output_dir: str = "factory/asset_forge/output"
    keep_raw_output: bool = True
    generate_dark_mode_variants: bool = True
    generate_platform_variants: bool = True
    parallel_generation: bool = False
    default_sizes: dict = field(default_factory=lambda: {
        "icon": "1024x1024",
        "sprite": "512x512",
        "background": "1920x1080",
        "illustration": "1024x1024",
        "ui_element": "256x256",
        "store_art": "1242x2688",
    })

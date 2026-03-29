"""QA Forge configuration -- all thresholds and tolerances."""

QA_CONFIG = {
    # Visual Diff
    "color_tolerance_rgb_distance": 100,
    "color_warn_distance": 150,
    "brightness_threshold_dark": 120,
    "brightness_threshold_light": 170,
    "min_sprite_resolution": 256,
    "min_icon_resolution": 512,

    # Audio Check
    "peak_target_dbfs": -1.0,
    "peak_tolerance_db": 2.0,
    "lufs_target": -16.0,
    "lufs_tolerance": 3.0,
    "duration_tolerance_percent": 30,
    "sfx_duration_range": (100, 3000),
    "ui_sound_duration_range": (50, 500),
    "ambient_duration_range": (5000, 180000),
    "music_duration_range": (10000, 300000),
    "notification_duration_range": (200, 2000),

    # Animation Timing
    "timing_ranges": {
        "micro_interaction": {"min": 100, "max": 900},
        "screen_transition": {"min": 250, "max": 1000},
        "feedback": {"min": 150, "max": 800},
        "loading": {"min": 800, "max": 3000},
        "ambient": {"min": 2000, "max": 10000},
        "branding": {"min": 500, "max": 3000},
    },
    "max_lottie_size_kb": 500,
    "max_css_size_kb": 20,
    "max_unity_cs_size_kb": 50,

    # Scene Integrity
    "min_grid_size": 5,
    "max_grid_size": 15,
    "min_stone_types": 3,
    "max_difficulty_jump": 0.25,

    # Verdict
    "verdict_thresholds": {
        "pass": {"max_errors": 0, "max_warnings": 5, "min_pass_rate": 0.95},
        "conditional_pass": {"max_errors": 3, "max_warnings": 10, "min_pass_rate": 0.85},
    },
}

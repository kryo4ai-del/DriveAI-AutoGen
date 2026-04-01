"""Fleet Generator — Konfiguration.

App-Namen, Profile, Health States, Metrik-Bereiche.
"""

# ---------------------------------------------------------------
# Synthetic App Fleet — 15 realistische Apps
# ---------------------------------------------------------------
APP_FLEET: list[dict] = [
    {"name": "PixelQuest Pro",    "profile": "gaming",       "bundle": "com.driveai.pixelquest"},
    {"name": "DragonRealm",       "profile": "gaming",       "bundle": "com.driveai.dragonrealm"},
    {"name": "MindTrainer",       "profile": "education",    "bundle": "com.driveai.mindtrainer"},
    {"name": "WordMaster",        "profile": "education",    "bundle": "com.driveai.wordmaster"},
    {"name": "QuickCalc",         "profile": "utility",      "bundle": "com.driveai.quickcalc"},
    {"name": "PhotoFix",          "profile": "utility",      "bundle": "com.driveai.photofix"},
    {"name": "TaskPilot",         "profile": "utility",      "bundle": "com.driveai.taskpilot"},
    {"name": "CodeSnippets",      "profile": "utility",      "bundle": "com.driveai.codesnippets"},
    {"name": "StreamVault",       "profile": "content",      "bundle": "com.driveai.streamvault"},
    {"name": "BeatDrop",          "profile": "content",      "bundle": "com.driveai.beatdrop"},
    {"name": "CookBook+",         "profile": "content",      "bundle": "com.driveai.cookbook"},
    {"name": "TuneWave",          "profile": "content",      "bundle": "com.driveai.tunewave"},
    {"name": "FitFlow Premium",   "profile": "subscription", "bundle": "com.driveai.fitflow"},
    {"name": "SleepTracker",      "profile": "subscription", "bundle": "com.driveai.sleeptracker"},
    {"name": "BudgetBoss",        "profile": "subscription", "bundle": "com.driveai.budgetboss"},
]

# ---------------------------------------------------------------
# Health State Ranges — Score + Metrik-Bereiche
# ---------------------------------------------------------------
HEALTH_STATES: dict[str, dict] = {
    "healthy": {
        "score_range": (75.0, 95.0),
        "crash_rate": (0.1, 0.8),
        "rating": (4.0, 4.8),
        "retention_d7": (25.0, 45.0),
        "dau_mau": (0.25, 0.45),
        "arpu": (2.0, 5.0),
        "conversion": (4.0, 9.0),
        "downloads_period": (500, 5000),
        "session_length": (120, 600),
    },
    "warning": {
        "score_range": (45.0, 65.0),
        "crash_rate": (1.5, 3.5),
        "rating": (3.0, 3.8),
        "retention_d7": (12.0, 22.0),
        "dau_mau": (0.12, 0.22),
        "arpu": (0.8, 2.0),
        "conversion": (1.5, 4.0),
        "downloads_period": (100, 800),
        "session_length": (60, 200),
    },
    "critical": {
        "score_range": (10.0, 35.0),
        "crash_rate": (4.0, 8.0),
        "rating": (1.5, 2.8),
        "retention_d7": (3.0, 10.0),
        "dau_mau": (0.03, 0.10),
        "arpu": (0.1, 0.8),
        "conversion": (0.2, 1.5),
        "downloads_period": (10, 100),
        "session_length": (15, 60),
    },
    "new_app": {
        "score_range": (50.0, 70.0),
        "crash_rate": (0.5, 2.0),
        "rating": (3.5, 4.2),
        "retention_d7": (15.0, 30.0),
        "dau_mau": (0.15, 0.30),
        "arpu": (0.5, 1.5),
        "conversion": (1.0, 3.0),
        "downloads_period": (50, 300),
        "session_length": (60, 300),
    },
}

# Verteilung: wie viele Apps pro State (summiert sich auf 15)
FLEET_DISTRIBUTION: dict[str, int] = {
    "healthy": 6,
    "warning": 4,
    "critical": 3,
    "new_app": 2,
}

# ---------------------------------------------------------------
# Metrics History — Tage zurueck
# ---------------------------------------------------------------
HISTORY_DAYS: int = 30
HISTORY_POINTS_PER_DAY: int = 4  # alle 6h wie Decision Cycle

# ---------------------------------------------------------------
# Review Templates
# ---------------------------------------------------------------
POSITIVE_REVIEWS: list[str] = [
    "Great app, works flawlessly!",
    "Love the new update, much smoother now.",
    "Best in its category, highly recommended.",
    "Simple, clean, does what it should.",
    "Finally an app that just works. 5 stars.",
]

NEGATIVE_REVIEWS: list[str] = [
    "Crashes every time I open it.",
    "Used to be good, latest update broke everything.",
    "Way too many bugs, can't recommend.",
    "Deleted after 2 days, waste of storage.",
    "App hangs and drains battery like crazy.",
]

MIXED_REVIEWS: list[str] = [
    "Decent app but needs work on stability.",
    "Good concept, poor execution.",
    "Works most of the time, occasional glitches.",
    "3 stars — nothing special but gets the job done.",
    "OK app, wish it had more features.",
]

# ---------------------------------------------------------------
# Support Ticket Templates
# ---------------------------------------------------------------
SUPPORT_CATEGORIES: list[str] = [
    "crash_report",
    "feature_request",
    "billing_issue",
    "performance_complaint",
    "login_problem",
    "data_loss",
]

# Synthetic data marker — damit wir spaeter aufräumen koennen
SYNTHETIC_MARKER: str = "SYNTHETIC_FLEET"

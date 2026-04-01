"""Escalation Configuration."""

import os

# Escalation Levels
LEVEL_INFO = 1       # Dashboard-Protokoll, kein Alert
LEVEL_WARNING = 2    # Dashboard prominent + Details
LEVEL_CEO = 3        # Dashboard + Telegram

# Level Labels
LEVEL_LABELS = {
    0: "none",
    1: "info",
    2: "warning",
    3: "ceo_escalation",
}

# Telegram Config
TELEGRAM_BOT_TOKEN = os.environ.get("DRIVEAI_TELEGRAM_BOT_TOKEN", "")
TELEGRAM_CHAT_ID = os.environ.get("DRIVEAI_TELEGRAM_CHAT_ID", "")
TELEGRAM_ENABLED = bool(TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID)

# Log
ESCALATION_LOG_FILE = "escalation_log.jsonl"

# Retry
TELEGRAM_TIMEOUT_SECONDS = 10
TELEGRAM_MAX_RETRIES = 2

"""Metrics Collector — Configuration."""

import os
from pathlib import Path

# Collection settings
COLLECTION_INTERVAL_HOURS = 6
REVIEW_FETCH_LIMIT = 20
METRIC_RETENTION_DAYS = 90
DATA_OUTPUT_DIR = Path("factory/live_operations/data")

# API Credentials (from environment variables)
APPLE_KEY_ID = os.environ.get("APPLE_API_KEY_ID", "")
APPLE_ISSUER_ID = os.environ.get("APPLE_API_ISSUER_ID", "")
APPLE_KEY_PATH = os.environ.get("APPLE_API_KEY_PATH", "")
GOOGLE_SERVICE_ACCOUNT = os.environ.get("GOOGLE_PLAY_SERVICE_ACCOUNT", "")
FIREBASE_CREDENTIALS = os.environ.get("FIREBASE_ADMIN_CREDENTIALS", "")

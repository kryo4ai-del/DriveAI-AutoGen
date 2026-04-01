"""Anomaly Detector Configuration."""

SCAN_INTERVAL_MINUTES = 30
CRASH_EXPLOSION_MULTIPLIER = 2.0    # Crash Rate muss sich verdoppeln
REVENUE_COLLAPSE_THRESHOLD = 0.20   # Revenue unter 20% des Baselines
HEALTH_FREEFALL_THRESHOLD = 20      # Score-Drop >20 Punkte
POST_UPDATE_WINDOW_HOURS = 48       # Nur innerhalb von 48h nach Release
BASELINE_CYCLES = 3                 # Durchschnitt ueber letzte 3 Zyklen als Baseline

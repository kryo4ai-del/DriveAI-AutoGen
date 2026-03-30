"""Analytics Configuration."""

import os

TREND_WINDOW_SHORT = 7          # Tage fuer kurzfristigen Trend
TREND_WINDOW_LONG = 30          # Tage fuer langfristigen Trend
ANOMALY_THRESHOLD_SIGMA = 2.0   # Standardabweichungen fuer Anomalie
SEASONAL_PERIOD = 7             # Tage (Wochentags-Saisonalitaet)
MIN_DATA_POINTS = 7             # Minimum Datenpunkte fuer Trendberechnung
INSIGHTS_OUTPUT_DIR = os.path.join("factory", "live_operations", "data", "insights")

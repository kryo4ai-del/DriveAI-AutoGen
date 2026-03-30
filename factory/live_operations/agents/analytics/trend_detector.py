"""Trend Detection -- erkennt Trends, Anomalien und Saisonalitaet in Metriken."""

import math
from typing import Optional

from . import config


class TrendDetector:
    """Analysiert Zeitreihen auf Trends, Anomalien und Saisonalitaet."""

    def __init__(self) -> None:
        pass

    def detect_trends(self, metrics_history: list[dict]) -> dict:
        """Analysiert alle Metriken auf Trends.

        Args:
            metrics_history: Liste von Metrik-Snapshots (chronologisch, aelteste zuerst).
                             Jeder Eintrag hat 'collected_at' + Metriken-Felder.

        Returns:
            Dict mit Trend-Analyse pro Metrik.
        """
        if not metrics_history:
            return {"trends": {}, "summary": "No data"}

        # Metriken extrahieren die wir tracken
        metric_keys = self._discover_metric_keys(metrics_history)
        trends = {}

        for key in metric_keys:
            values = self._extract_values(metrics_history, key)
            if not values:
                continue
            trends[key] = self._analyze_metric(key, values)

        return {
            "trends": trends,
            "data_points": len(metrics_history),
            "metrics_analyzed": len(trends),
        }

    def _discover_metric_keys(self, history: list[dict]) -> list[str]:
        """Findet alle numerischen Metrik-Keys in den Daten."""
        target_keys = [
            "dau", "mau", "dau_mau_ratio",
            "session_count_period", "avg_session_length_seconds",
            "retention_day1", "retention_day7", "retention_day30",
            "crash_rate", "anr_rate",
            "revenue_period", "arpu", "conversion_rate",
            "downloads_period", "downloads_total",
            "rating_average", "rating_count",
        ]
        found = set()
        for entry in history:
            store = entry.get("store_metrics", {})
            firebase = entry.get("firebase_metrics", {})
            flat = {**store, **firebase, **entry}
            for k in target_keys:
                if k in flat and isinstance(flat[k], (int, float)):
                    found.add(k)
        return sorted(found)

    def _extract_values(self, history: list[dict], key: str) -> list[float]:
        """Extrahiert Werte fuer einen bestimmten Key aus der History."""
        values = []
        for entry in history:
            store = entry.get("store_metrics", {})
            firebase = entry.get("firebase_metrics", {})
            flat = {**store, **firebase, **entry}
            val = flat.get(key)
            if val is not None and isinstance(val, (int, float)):
                values.append(float(val))
        return values

    def _analyze_metric(self, name: str, values: list[float]) -> dict:
        """Vollstaendige Analyse einer einzelnen Metrik."""
        n = len(values)
        current = values[-1]
        previous = values[-2] if n >= 2 else current

        result = {
            "metric_name": name,
            "current_value": current,
            "previous_period_value": previous,
            "change_percent": self._pct_change(previous, current),
            "data_points": n,
        }

        if n < 3:
            result["direction"] = "insufficient_data"
            result["strength"] = 0.0
            result["moving_average_7d"] = current
            result["moving_average_30d"] = current
            result["is_seasonal"] = False
            result["anomalies"] = []
            result["rate_of_change"] = 0.0
            return result

        ma_short = self._calculate_moving_average(values, min(config.TREND_WINDOW_SHORT, n))
        ma_long = self._calculate_moving_average(values, min(config.TREND_WINDOW_LONG, n))

        direction = self._calculate_trend_direction(values)
        strength = self._calculate_trend_strength(values)

        result["direction"] = direction
        result["strength"] = round(strength, 3)
        result["moving_average_7d"] = round(ma_short[-1], 2) if ma_short else current
        result["moving_average_30d"] = round(ma_long[-1], 2) if ma_long else current
        result["is_seasonal"] = self._is_seasonal(values, config.SEASONAL_PERIOD) if n >= 14 else False
        result["anomalies"] = self._detect_anomaly_in_trend(values)
        result["rate_of_change"] = round(self._calculate_rate_of_change(values, min(3, n)), 3)

        return result

    # ------------------------------------------------------------------
    # Core Calculations
    # ------------------------------------------------------------------

    def _calculate_moving_average(self, values: list[float], window: int = 7) -> list[float]:
        """Berechnet gleitenden Durchschnitt."""
        if not values or window < 1:
            return []
        result = []
        for i in range(len(values)):
            start = max(0, i - window + 1)
            chunk = values[start:i + 1]
            result.append(sum(chunk) / len(chunk))
        return result

    def _calculate_trend_direction(self, values: list[float]) -> str:
        """Bestimmt Trend-Richtung via lineare Regression.

        Returns: 'rising', 'falling', oder 'stable'
        """
        slope = self._linear_regression_slope(values)
        # Normalisiere Steigung relativ zum Mittelwert
        mean = sum(values) / len(values) if values else 1
        if mean == 0:
            mean = 1
        relative_slope = (slope / abs(mean)) * 100  # % pro Zeiteinheit

        if relative_slope > 0.5:
            return "rising"
        elif relative_slope < -0.5:
            return "falling"
        return "stable"

    def _calculate_trend_strength(self, values: list[float]) -> float:
        """Berechnet Trend-Staerke (0.0 bis 1.0) via R-squared."""
        if len(values) < 3:
            return 0.0

        slope = self._linear_regression_slope(values)
        intercept = self._linear_regression_intercept(values, slope)

        # R-squared
        n = len(values)
        mean_y = sum(values) / n
        ss_tot = sum((y - mean_y) ** 2 for y in values)
        ss_res = sum((values[i] - (intercept + slope * i)) ** 2 for i in range(n))

        if ss_tot == 0:
            return 0.0
        r_squared = max(0.0, 1 - (ss_res / ss_tot))
        return min(r_squared, 1.0)

    def _detect_anomaly_in_trend(self, values: list[float]) -> list[dict]:
        """Erkennt Anomalien (> 2 Sigma vom gleitenden Durchschnitt)."""
        if len(values) < config.MIN_DATA_POINTS:
            return []

        ma = self._calculate_moving_average(values, config.TREND_WINDOW_SHORT)
        anomalies = []

        # Std-Abweichung der Residuen
        residuals = [values[i] - ma[i] for i in range(len(values))]
        if not residuals:
            return []
        mean_r = sum(residuals) / len(residuals)
        var = sum((r - mean_r) ** 2 for r in residuals) / len(residuals)
        std = math.sqrt(var) if var > 0 else 0

        if std == 0:
            return []

        threshold = config.ANOMALY_THRESHOLD_SIGMA * std
        for i, (val, avg) in enumerate(zip(values, ma)):
            deviation = abs(val - avg)
            if deviation > threshold:
                anomalies.append({
                    "index": i,
                    "value": val,
                    "expected": round(avg, 2),
                    "deviation_sigma": round(deviation / std, 2),
                    "type": "spike" if val > avg else "drop",
                })
        return anomalies

    def _is_seasonal(self, values: list[float], period: int = 7) -> bool:
        """Prueft auf Saisonalitaet via Autokorrelation."""
        n = len(values)
        if n < period * 2:
            return False

        mean = sum(values) / n
        variance = sum((v - mean) ** 2 for v in values) / n
        if variance == 0:
            return False

        # Autokorrelation bei lag = period
        autocorr = 0.0
        count = 0
        for i in range(n - period):
            autocorr += (values[i] - mean) * (values[i + period] - mean)
            count += 1

        if count == 0:
            return False
        autocorr = autocorr / (count * variance)
        # Saisonalitaet wenn Autokorrelation > 0.3
        return autocorr > 0.3

    def _calculate_rate_of_change(self, values: list[float], window: int = 3) -> float:
        """Berechnet Aenderungsgeschwindigkeit (% pro Zeiteinheit) ueber die letzten N Werte."""
        if len(values) < 2:
            return 0.0
        recent = values[-window:]
        if len(recent) < 2:
            return 0.0
        first = recent[0] if recent[0] != 0 else 1.0
        return ((recent[-1] - recent[0]) / abs(first)) * 100 / (len(recent) - 1)

    # ------------------------------------------------------------------
    # Linear Regression (least squares)
    # ------------------------------------------------------------------

    def _linear_regression_slope(self, values: list[float]) -> float:
        """Berechnet Steigung via least-squares lineare Regression."""
        n = len(values)
        if n < 2:
            return 0.0
        x_mean = (n - 1) / 2.0
        y_mean = sum(values) / n
        num = sum((i - x_mean) * (values[i] - y_mean) for i in range(n))
        den = sum((i - x_mean) ** 2 for i in range(n))
        return num / den if den != 0 else 0.0

    def _linear_regression_intercept(self, values: list[float], slope: float) -> float:
        """Berechnet Y-Intercept."""
        n = len(values)
        if n == 0:
            return 0.0
        return (sum(values) / n) - slope * ((n - 1) / 2.0)

    @staticmethod
    def _pct_change(old: float, new: float) -> float:
        if old == 0:
            return 0.0 if new == 0 else 100.0
        return round(((new - old) / abs(old)) * 100, 2)

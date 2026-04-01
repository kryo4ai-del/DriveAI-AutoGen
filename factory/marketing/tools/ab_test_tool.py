"""A/B Test Tool — Statistisch korrekte A/B-Test-Auswertung.

Nutzt scipy.stats fuer Z-Test (zwei Proportionen).
Fallback: Manuelle Berechnung mit Abramowitz & Stegun Approximation.

Kein LLM. Reine Statistik.
"""

import json
import logging
import math
import os
from datetime import datetime
from pathlib import Path
from typing import Optional

logger = logging.getLogger("factory.marketing.tools.ab_test_tool")


class ABTestTool:
    """Statistisch korrekte A/B-Test-Auswertung."""

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH
        self.output_path = Path(OUTPUT_PATH)
        self._has_scipy = False
        try:
            import scipy.stats  # noqa: F401
            self._has_scipy = True
        except ImportError:
            logger.warning("scipy not available — using manual Z-test fallback")
        logger.info("ABTestTool initialized (scipy=%s)", self._has_scipy)

    # ── Statistische Kernfunktionen ───────────────────────

    @staticmethod
    def _manual_norm_cdf(z: float) -> float:
        """Abramowitz & Stegun Approximation fuer die Normal-CDF.

        Genauigkeit: max. Fehler < 7.5e-8
        Referenz: Handbook of Mathematical Functions, Formula 26.2.17
        """
        if z < -8.0:
            return 0.0
        if z > 8.0:
            return 1.0

        sign = 1.0 if z >= 0 else -1.0
        z_abs = abs(z)

        # Konstanten (Abramowitz & Stegun 26.2.17)
        p = 0.2316419
        b1 = 0.319381530
        b2 = -0.356563782
        b3 = 1.781477937
        b4 = -1.821255978
        b5 = 1.330274429

        t = 1.0 / (1.0 + p * z_abs)
        t2 = t * t
        t3 = t2 * t
        t4 = t3 * t
        t5 = t4 * t

        pdf = (1.0 / math.sqrt(2.0 * math.pi)) * math.exp(-0.5 * z_abs * z_abs)
        cdf_complement = pdf * (b1 * t + b2 * t2 + b3 * t3 + b4 * t4 + b5 * t5)

        if sign >= 0:
            return 1.0 - cdf_complement
        else:
            return cdf_complement

    def _z_test_two_proportions(self, n_a: int, conv_a: int,
                                 n_b: int, conv_b: int) -> dict:
        """Z-Test fuer zwei Proportionen.

        Args:
            n_a: Sample-Groesse Variante A
            conv_a: Conversions Variante A
            n_b: Sample-Groesse Variante B
            conv_b: Conversions Variante B

        Returns:
            Dict mit p_a, p_b, z_score, p_value, significant, winner.
        """
        if n_a <= 0 or n_b <= 0:
            return {
                "error": "Sample-Groesse muss > 0 sein",
                "valid": False,
            }

        p_a = conv_a / n_a
        p_b = conv_b / n_b

        # Pooled proportion
        p_pool = (conv_a + conv_b) / (n_a + n_b)

        # Standard Error
        se = math.sqrt(p_pool * (1 - p_pool) * (1 / n_a + 1 / n_b)) if p_pool > 0 and p_pool < 1 else 0

        if se == 0:
            return {
                "p_a": p_a,
                "p_b": p_b,
                "z_score": 0.0,
                "p_value": 1.0,
                "significant": False,
                "winner": None,
                "confidence": 0.0,
                "valid": True,
                "note": "Kein Unterschied messbar (SE=0)",
            }

        z_score = (p_a - p_b) / se

        # p-Value berechnen (two-tailed)
        if self._has_scipy:
            from scipy.stats import norm
            p_value = float(2 * (1 - norm.cdf(abs(z_score))))
        else:
            p_value = 2 * (1 - self._manual_norm_cdf(abs(z_score)))

        significant = bool(p_value < 0.05)
        confidence = (1 - p_value) * 100

        winner = None
        if significant:
            winner = "A" if p_a > p_b else "B"

        return {
            "p_a": round(p_a, 6),
            "p_b": round(p_b, 6),
            "diff": round(p_a - p_b, 6),
            "diff_percent": round((p_a - p_b) / max(p_b, 0.0001) * 100, 2),
            "z_score": round(z_score, 4),
            "p_value": round(p_value, 6),
            "significant": significant,
            "confidence": round(confidence, 2),
            "winner": winner,
            "n_a": n_a,
            "n_b": n_b,
            "conv_a": conv_a,
            "conv_b": conv_b,
            "method": "scipy" if self._has_scipy else "manual_abramowitz_stegun",
            "valid": True,
        }

    # ── Oeffentliche API ──────────────────────────────────

    def evaluate_test(self, test_name: str,
                      n_a: int, conv_a: int,
                      n_b: int, conv_b: int,
                      hypothesis: str = None,
                      variant_a_desc: str = None,
                      variant_b_desc: str = None,
                      metric: str = "conversion_rate") -> dict:
        """Wertet einen A/B-Test aus und speichert das Ergebnis.

        Args:
            test_name: Name des Tests
            n_a: Sample A
            conv_a: Conversions A
            n_b: Sample B
            conv_b: Conversions B
            hypothesis: Was wird getestet?
            variant_a_desc: Beschreibung Variante A
            variant_b_desc: Beschreibung Variante B
            metric: Gemessene Metrik

        Returns:
            Dict mit statistischem Ergebnis + Empfehlung.
        """
        result = self._z_test_two_proportions(n_a, conv_a, n_b, conv_b)

        if not result.get("valid"):
            return result

        result["test_name"] = test_name
        result["hypothesis"] = hypothesis
        result["variant_a_desc"] = variant_a_desc or "Variante A"
        result["variant_b_desc"] = variant_b_desc or "Variante B"
        result["metric"] = metric
        result["evaluated_at"] = datetime.now().isoformat()

        # Empfehlung
        if result["significant"]:
            winner_desc = variant_a_desc if result["winner"] == "A" else variant_b_desc
            result["recommendation"] = (
                f"Signifikant: {winner_desc or result['winner']} gewinnt "
                f"mit {result['confidence']:.1f}% Konfidenz "
                f"(p={result['p_value']:.4f}). "
                f"Differenz: {result['diff_percent']:+.2f}%."
            )
        else:
            result["recommendation"] = (
                f"NICHT signifikant (p={result['p_value']:.4f}). "
                f"Mehr Daten sammeln oder Test laenger laufen lassen."
            )

        # In DB speichern
        try:
            from factory.marketing.tools.ranking_database import RankingDatabase
            db = RankingDatabase()
            db.store_ab_test(
                test_name=test_name,
                hypothesis=hypothesis,
                variant_a_desc=variant_a_desc,
                variant_b_desc=variant_b_desc,
                metric=metric,
                winner=result.get("winner"),
                confidence=result.get("confidence"),
                p_value=result.get("p_value"),
                learnings=result.get("recommendation"),
            )
        except Exception as e:
            logger.warning("Could not store A/B test result: %s", e)

        return result

    def calculate_sample_size(self, baseline_rate: float,
                              min_detectable_effect: float,
                              alpha: float = 0.05,
                              power: float = 0.80) -> dict:
        """Berechnet die benoetigte Sample-Groesse pro Variante.

        Args:
            baseline_rate: Aktuelle Conversion Rate (z.B. 0.05 = 5%)
            min_detectable_effect: Minimaler Effekt (relativ, z.B. 0.10 = 10% Verbesserung)
            alpha: Signifikanzniveau (default: 0.05)
            power: Statistische Power (default: 0.80)

        Returns:
            Dict mit sample_size_per_variant, total_sample_size.
        """
        if baseline_rate <= 0 or baseline_rate >= 1:
            return {"error": "baseline_rate muss zwischen 0 und 1 liegen", "valid": False}
        if min_detectable_effect <= 0:
            return {"error": "min_detectable_effect muss > 0 sein", "valid": False}

        p1 = baseline_rate
        p2 = baseline_rate * (1 + min_detectable_effect)
        if p2 >= 1:
            p2 = 0.99

        # Z-Werte
        if self._has_scipy:
            from scipy.stats import norm
            z_alpha = norm.ppf(1 - alpha / 2)
            z_beta = norm.ppf(power)
        else:
            # Approximationen fuer Standard-Werte
            z_lookup = {0.05: 1.96, 0.01: 2.576, 0.10: 1.645}
            power_lookup = {0.80: 0.842, 0.90: 1.282, 0.95: 1.645}
            z_alpha = z_lookup.get(alpha, 1.96)
            z_beta = power_lookup.get(power, 0.842)

        # Sample Size Formel
        p_avg = (p1 + p2) / 2
        numerator = (z_alpha * math.sqrt(2 * p_avg * (1 - p_avg)) +
                     z_beta * math.sqrt(p1 * (1 - p1) + p2 * (1 - p2))) ** 2
        denominator = (p1 - p2) ** 2

        n = math.ceil(numerator / denominator)

        return {
            "sample_size_per_variant": n,
            "total_sample_size": n * 2,
            "baseline_rate": baseline_rate,
            "expected_rate": round(p2, 4),
            "min_detectable_effect": min_detectable_effect,
            "alpha": alpha,
            "power": power,
            "valid": True,
        }

    def get_test_history(self, test_name: str = None) -> list[dict]:
        """Gibt A/B-Test-Historie aus der DB zurueck."""
        try:
            from factory.marketing.tools.ranking_database import RankingDatabase
            db = RankingDatabase()
            return db.get_ab_test_history(test_name=test_name)
        except Exception as e:
            logger.warning("Could not read A/B test history: %s", e)
            return []

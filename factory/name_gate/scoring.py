"""Name Gate Scoring — Weighted score calculation and Ampel logic."""

from __future__ import annotations

from typing import List

from factory.name_gate.config import WEIGHTS, THRESHOLDS
from factory.name_gate.models import NameCheckResult


def calculate_total_score(checks: NameCheckResult) -> int:
    """Weighted sum of all sub-scores.

    Each sub-score is 0-100.  Weights are defined in config.WEIGHTS (sum=100).
    Returns an integer 0-100.
    """
    raw = (
        checks.domain.score * WEIGHTS["domain"]
        + checks.store.score * WEIGHTS["app_store"]
        + checks.trademark.score * WEIGHTS["trademark"]
        + checks.brand_fit.score * WEIGHTS["brand_fit"]
        + checks.social_media.score * WEIGHTS["social_media"]
        + checks.aso.score * WEIGHTS["aso"]
    )
    return round(raw / 100)


def determine_ampel(score: int, checks: NameCheckResult) -> str:
    """Return GRUEN / GELB / ROT.

    Hard blockers always force ROT regardless of score.
    """
    if detect_hard_blockers(checks):
        return "ROT"
    if score >= THRESHOLDS["green"]:
        return "GRUEN"
    if score >= THRESHOLDS["yellow"]:
        return "GELB"
    return "ROT"


def detect_hard_blockers(checks: NameCheckResult) -> List[str]:
    """Check for automatic ROT triggers."""
    blockers: List[str] = []

    # Trademark conflict
    if checks.trademark.hard_blocker:
        blockers.append("trademark_conflict: DPMA or EUIPO match found")

    # Both app stores taken
    if not checks.store.apple and not checks.store.google:
        blockers.append("both_stores_taken: Name taken on Apple AND Google")

    # All major domains taken
    if not checks.domain.com and not checks.domain.de and not checks.domain.app:
        blockers.append("all_major_domains_taken: .com, .de, and .app all taken")

    return blockers


def detect_soft_blockers(checks: NameCheckResult) -> List[str]:
    """Identify partial conflicts (warnings, not hard stops)."""
    blockers: List[str] = []

    # Domain partially taken
    if not checks.domain.com and (checks.domain.de or checks.domain.app):
        blockers.append("domain_partial: .com taken but other TLDs available")

    # One store taken
    if not checks.store.apple and checks.store.google:
        blockers.append("store_partial: Apple App Store name taken")
    elif checks.store.apple and not checks.store.google:
        blockers.append("store_partial: Google Play Store name taken")

    # Social media partially taken
    taken = []
    if not checks.social_media.instagram:
        taken.append("Instagram")
    if not checks.social_media.tiktok:
        taken.append("TikTok")
    if not checks.social_media.x:
        taken.append("X")
    if taken and len(taken) < 5:
        blockers.append(f"social_partial: Handle taken on {', '.join(taken)}")

    # Brand fit below 60
    if checks.brand_fit.score < 60:
        blockers.append(f"brand_fit_low: Score {checks.brand_fit.score}/100")

    # High ASO saturation
    if checks.aso.keyword_saturation == "high":
        blockers.append("aso_saturated: High keyword saturation in stores")

    return blockers

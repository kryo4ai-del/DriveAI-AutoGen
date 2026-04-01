"""Tests for Name Gate scoring logic."""

import pytest

from factory.name_gate.models import (
    ASOPreCheckResult,
    BrandFitResult,
    DomainCheckResult,
    NameCheckResult,
    SocialMediaCheckResult,
    StoreCheckResult,
    TrademarkCheckResult,
)
from factory.name_gate.scoring import (
    calculate_total_score,
    detect_hard_blockers,
    detect_soft_blockers,
    determine_ampel,
)


def _make_checks(**overrides) -> NameCheckResult:
    """Build a NameCheckResult with all-perfect defaults, then apply overrides."""
    checks = NameCheckResult(
        domain=DomainCheckResult(com=True, de=True, app=True, io=True, score=100),
        store=StoreCheckResult(apple=True, google=True, score=100),
        social_media=SocialMediaCheckResult(
            instagram=True, tiktok=True, x=True, youtube=True, linkedin=True, score=100,
        ),
        trademark=TrademarkCheckResult(dpma=True, euipo=True, score=100, hard_blocker=False),
        brand_fit=BrandFitResult(
            tonality=80, pronounceability=80, memorability=80,
            confusion_risk=80, international=80, score=80,
        ),
        aso=ASOPreCheckResult(keyword_saturation="low", score=90),
    )
    for key, val in overrides.items():
        setattr(checks, key, val)
    return checks


class TestCalculateTotalScore:
    def test_perfect_scores(self):
        checks = _make_checks()
        # domain=100*25 + store=100*25 + trademark=100*25 + brand=80*10 + social=100*10 + aso=90*5
        # = 2500 + 2500 + 2500 + 800 + 1000 + 450 = 9750 / 100 = 97.5 → 98
        total = calculate_total_score(checks)
        assert 90 <= total <= 100

    def test_zero_scores(self):
        checks = NameCheckResult()  # all defaults = 0
        total = calculate_total_score(checks)
        assert total == 0

    def test_weighted_correctly(self):
        # Only domain scores, rest zero
        checks = NameCheckResult(
            domain=DomainCheckResult(score=100),
        )
        total = calculate_total_score(checks)
        assert total == 25  # 100 * 25 / 100


class TestDetermineAmpel:
    def test_gruen(self):
        checks = _make_checks()
        total = calculate_total_score(checks)
        assert determine_ampel(total, checks) == "GRUEN"

    def test_gelb(self):
        checks = _make_checks(
            domain=DomainCheckResult(com=True, de=False, app=False, io=False, score=50),
            store=StoreCheckResult(apple=True, google=False, score=50),
        )
        total = calculate_total_score(checks)
        assert 50 <= total < 80
        assert determine_ampel(total, checks) == "GELB"

    def test_rot(self):
        checks = NameCheckResult()  # score 0
        total = calculate_total_score(checks)
        assert determine_ampel(total, checks) == "ROT"

    def test_hard_blocker_overrides_score(self):
        checks = _make_checks(
            trademark=TrademarkCheckResult(dpma=False, euipo=True, score=50, hard_blocker=True),
        )
        total = calculate_total_score(checks)
        assert total > 50  # score is decent
        assert determine_ampel(total, checks) == "ROT"  # but hard blocker forces ROT


class TestDetectHardBlockers:
    def test_no_blockers(self):
        checks = _make_checks()
        assert detect_hard_blockers(checks) == []

    def test_trademark_conflict(self):
        checks = _make_checks(
            trademark=TrademarkCheckResult(dpma=False, euipo=False, score=0, hard_blocker=True),
        )
        blockers = detect_hard_blockers(checks)
        assert len(blockers) == 1
        assert "trademark" in blockers[0].lower()

    def test_both_stores_taken(self):
        checks = _make_checks(
            store=StoreCheckResult(apple=False, google=False, score=0),
        )
        blockers = detect_hard_blockers(checks)
        assert any("stores" in b.lower() or "store" in b.lower() for b in blockers)

    def test_all_major_domains_taken(self):
        checks = _make_checks(
            domain=DomainCheckResult(com=False, de=False, app=False, io=True, score=25),
        )
        blockers = detect_hard_blockers(checks)
        assert any("domain" in b.lower() for b in blockers)


class TestDetectSoftBlockers:
    def test_no_soft_blockers(self):
        checks = _make_checks()
        assert detect_soft_blockers(checks) == []

    def test_one_store_taken(self):
        checks = _make_checks(
            store=StoreCheckResult(apple=False, google=True, score=50),
        )
        soft = detect_soft_blockers(checks)
        assert any("store" in b.lower() for b in soft)

    def test_social_partial(self):
        checks = _make_checks(
            social_media=SocialMediaCheckResult(
                instagram=False, tiktok=True, x=True, youtube=True, linkedin=True, score=80,
            ),
        )
        soft = detect_soft_blockers(checks)
        assert any("social" in b.lower() or "instagram" in b.lower() for b in soft)

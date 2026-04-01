"""Name Gate Data Models — All check results and the final report.

Dataclasses with to_dict() for JSON serialization.
Used by orchestrator, scoring, and CLI.
"""

from __future__ import annotations

from dataclasses import dataclass, field, asdict
from typing import List, Optional


@dataclass
class DomainCheckResult:
    """Availability of key TLDs."""
    com: bool = False
    de: bool = False
    app: bool = False
    io: bool = False
    score: int = 0
    details: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class StoreCheckResult:
    """App Store name availability."""
    apple: bool = False
    google: bool = False
    score: int = 0
    details: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class SocialMediaCheckResult:
    """Handle availability on major platforms."""
    instagram: bool = False
    tiktok: bool = False
    x: bool = False
    youtube: bool = False
    linkedin: bool = False
    score: int = 0
    details: dict = field(default_factory=dict)

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class TrademarkCheckResult:
    """Trademark registry check results."""
    dpma: bool = False
    euipo: bool = False
    score: int = 0
    hard_blocker: bool = False

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class BrandFitResult:
    """Qualitative brand assessment scores (0-100 each)."""
    tonality: int = 0
    pronounceability: int = 0
    memorability: int = 0
    confusion_risk: int = 0
    international: int = 0
    score: int = 0
    recommendation: str = ""

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class ASOPreCheckResult:
    """ASO keyword saturation pre-check."""
    keyword_saturation: str = "medium"  # low / medium / high
    dominant_competitors: List[str] = field(default_factory=list)
    score: int = 0

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class NameCheckResult:
    """Aggregated check results for a single name."""
    domain: DomainCheckResult = field(default_factory=DomainCheckResult)
    store: StoreCheckResult = field(default_factory=StoreCheckResult)
    social_media: SocialMediaCheckResult = field(default_factory=SocialMediaCheckResult)
    trademark: TrademarkCheckResult = field(default_factory=TrademarkCheckResult)
    brand_fit: BrandFitResult = field(default_factory=BrandFitResult)
    aso: ASOPreCheckResult = field(default_factory=ASOPreCheckResult)

    def to_dict(self) -> dict:
        return {
            "domain": self.domain.to_dict(),
            "store": self.store.to_dict(),
            "social_media": self.social_media.to_dict(),
            "trademark": self.trademark.to_dict(),
            "brand_fit": self.brand_fit.to_dict(),
            "aso": self.aso.to_dict(),
        }


@dataclass
class NameGateReport:
    """Final Name Gate validation report."""
    report_id: str = ""
    name: str = ""
    total_score: int = 0
    ampel: str = "ROT"  # GRUEN / GELB / ROT
    checks: NameCheckResult = field(default_factory=NameCheckResult)
    hard_blockers: List[str] = field(default_factory=list)
    soft_blockers: List[str] = field(default_factory=list)
    recommendations: List[str] = field(default_factory=list)
    alternatives: List[str] = field(default_factory=list)
    ceo_decision: Optional[str] = None
    iteration: int = 1
    timestamp: str = ""

    def to_dict(self) -> dict:
        return {
            "report_id": self.report_id,
            "name": self.name,
            "total_score": self.total_score,
            "ampel": self.ampel,
            "checks": self.checks.to_dict(),
            "hard_blockers": self.hard_blockers,
            "soft_blockers": self.soft_blockers,
            "recommendations": self.recommendations,
            "alternatives": self.alternatives,
            "ceo_decision": self.ceo_decision,
            "iteration": self.iteration,
            "timestamp": self.timestamp,
        }

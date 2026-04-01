"""Apple Search Ads Adapter — STUB Phase 1.

NUR Platzhalter fuer die Architektur. Keine echten Kampagnen, keine echten Ausgaben.
Phase 2 (aktiv) kommt wenn echtes Produkt im Store und CEO-Freigabe.
"""

import logging

logger = logging.getLogger("factory.marketing.adapters.apple_search_ads")


class AppleSearchAdsAdapter:
    """STUB — Phase 1 des Performance Marketing Stufenplans."""

    STATUS = "stub_phase1"
    PLATFORM = "apple_search_ads"

    REQUIRED_CREDENTIALS = {
        "APPLE_SEARCH_ADS_ORG_ID": "Apple Search Ads Organization ID",
        "APPLE_SEARCH_ADS_KEY_ID": "Key ID",
        "APPLE_SEARCH_ADS_TEAM_ID": "Team ID",
        "APPLE_SEARCH_ADS_KEY_PATH": "Private Key File Path",
    }

    def __init__(self, dry_run: bool = True):
        self.dry_run = True  # IMMER True, egal was uebergeben wird
        logger.info("%s Adapter: STUB Phase 1 — no real campaigns", self.PLATFORM)

    def create_campaign(self, name, objective, budget, targeting, creatives) -> dict:
        """STUB: Loggt Kampagnen-Setup."""
        logger.info("[STUB] %s.create_campaign(name=%s, budget=%s)", self.PLATFORM, name, budget)
        return {"stub": True, "method": "create_campaign", "platform": self.PLATFORM}

    def set_budget(self, campaign_id, daily_budget) -> dict:
        """STUB: Loggt Budget-Aenderung."""
        return {"stub": True, "method": "set_budget"}

    def set_targeting(self, campaign_id, targeting) -> dict:
        """STUB: Loggt Targeting-Aenderung."""
        return {"stub": True, "method": "set_targeting"}

    def get_performance(self, campaign_id, date_range=None) -> dict:
        """STUB: Gibt Mock-Performance zurueck."""
        return {"stub": True, "method": "get_performance", "impressions": 0, "clicks": 0, "spend": 0}

    def pause_campaign(self, campaign_id) -> dict:
        """STUB: Loggt Kampagnen-Pause."""
        return {"stub": True, "method": "pause_campaign"}

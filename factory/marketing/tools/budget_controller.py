"""Budget Controller — Deterministische Budget-Verwaltung fuer Marketing-Kampagnen.

KEIN LLM. Reine Mathematik.
KEIN ECHTES GELD — nur Planung und Simulation.

Verantwortlich fuer:
- Budget-Splits (Prozentuale Verteilung auf Kanaele)
- ROI-Projektion (Hochrechnung basierend auf Annahmen)
- Budget-Validierung (Summen muessen EXAKT stimmen)
- Kampagnen-Budget-Tracking (Plan vs. Simulation)
"""

import json
import logging
import os
from datetime import datetime
from pathlib import Path
from typing import Optional

logger = logging.getLogger("factory.marketing.tools.budget_controller")


class BudgetController:
    """Deterministischer Budget-Controller. Kein LLM, keine API-Calls."""

    # Branchenstandard CPMs (Cost per Mille) — NUR fuer Simulation
    _DEFAULT_CPMS = {
        "youtube": 15.0,
        "tiktok": 10.0,
        "x": 8.0,
        "instagram": 12.0,
        "linkedin": 25.0,
        "reddit": 6.0,
        "google_ads": 20.0,
        "app_store_ads": 30.0,
    }

    # Branchenstandard Conversion Rates — NUR fuer Simulation
    _DEFAULT_CONVERSION_RATES = {
        "impression_to_click": 0.02,
        "click_to_install": 0.05,
        "install_to_active": 0.30,
    }

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH
        self.output_path = Path(OUTPUT_PATH)
        logger.info("BudgetController initialized (simulation only)")

    def calculate_budget_split(self, total_budget: float,
                               campaign_type: str,
                               custom_weights: dict = None) -> dict:
        """Berechnet Budget-Split. Summe MUSS exakt total_budget ergeben.

        Args:
            total_budget: Gesamt-Budget (Simulation)
            campaign_type: 'launch', 'content', 'outreach', 'custom'
            custom_weights: Dict mit Kanal -> Anteil (0.0-1.0), Summe MUSS 1.0 sein

        Returns:
            Dict mit Kanal -> Betrag. Summe == total_budget (garantiert).
        """
        if total_budget <= 0:
            return {"total": 0.0, "note": "Kein Budget allokiert"}

        # Default-Weights nach Kampagnen-Typ
        default_weights = {
            "launch": {"content": 0.35, "paid": 0.35, "pr": 0.20, "community": 0.10},
            "content": {"content_production": 0.50, "distribution": 0.30, "community": 0.20},
            "outreach": {"pr": 0.40, "influencer": 0.30, "community": 0.20, "events": 0.10},
        }

        weights = custom_weights or default_weights.get(campaign_type, {})
        if not weights:
            return {"total": total_budget, "unallocated": total_budget}

        # Weights normalisieren (Summe auf 1.0 bringen)
        weight_sum = sum(weights.values())
        if weight_sum <= 0:
            return {"total": total_budget, "unallocated": total_budget}

        normalized = {k: v / weight_sum for k, v in weights.items()}

        # Budget verteilen — auf 2 Dezimalstellen runden
        split = {}
        allocated = 0.0
        keys = list(normalized.keys())
        for key in keys[:-1]:
            amount = round(total_budget * normalized[key], 2)
            split[key] = amount
            allocated += amount

        # Letzter Posten bekommt den Rest (verhindert Rundungsfehler)
        split[keys[-1]] = round(total_budget - allocated, 2)

        # Validierung: Summe MUSS exakt stimmen
        check_sum = sum(split.values())
        assert abs(check_sum - total_budget) < 0.01, (
            f"Budget-Summe {check_sum} != {total_budget}"
        )

        split["_total"] = total_budget
        split["_campaign_type"] = campaign_type
        split["_simulation"] = True

        return split

    def project_roi(self, budget: float, channel: str,
                    cpm: float = None,
                    conversion_rates: dict = None) -> dict:
        """Projiziert ROI basierend auf Budget und Kanal.

        Returns:
            Dict mit projected impressions, clicks, installs, active_users, cpi, roas.
        """
        if budget <= 0:
            return {"budget": 0, "channel": channel, "note": "Kein Budget"}

        effective_cpm = cpm or self._DEFAULT_CPMS.get(channel, 15.0)
        rates = conversion_rates or self._DEFAULT_CONVERSION_RATES

        impressions = int((budget / effective_cpm) * 1000)
        clicks = int(impressions * rates.get("impression_to_click", 0.02))
        installs = int(clicks * rates.get("click_to_install", 0.05))
        active_users = int(installs * rates.get("install_to_active", 0.30))

        cpi = round(budget / max(installs, 1), 2)

        return {
            "budget": budget,
            "channel": channel,
            "cpm": effective_cpm,
            "projected_impressions": impressions,
            "projected_clicks": clicks,
            "projected_installs": installs,
            "projected_active_users": active_users,
            "cpi": cpi,
            "conversion_rates": rates,
            "simulation_only": True,
            "note": "Branchenschaetzung — keine echten Daten",
        }

    def validate_budget(self, items: list[dict]) -> dict:
        """Validiert eine Budget-Aufstellung: Summen pruefen, Fehler melden.

        Args:
            items: Liste von {"name": str, "amount": float}

        Returns:
            Dict mit total, items, valid, errors.
        """
        total = 0.0
        errors = []
        validated = []

        for i, item in enumerate(items):
            name = item.get("name", f"Posten_{i}")
            amount = item.get("amount", 0)

            if not isinstance(amount, (int, float)):
                errors.append(f"{name}: Betrag ist keine Zahl ({amount})")
                continue

            if amount < 0:
                errors.append(f"{name}: Negativer Betrag ({amount})")

            total += amount
            validated.append({"name": name, "amount": round(amount, 2)})

        return {
            "total": round(total, 2),
            "items": validated,
            "item_count": len(validated),
            "valid": len(errors) == 0,
            "errors": errors,
            "simulation_only": True,
        }

    def compare_campaigns(self, campaigns: list[dict]) -> dict:
        """Vergleicht Budget-Effizienz mehrerer Kampagnen.

        Args:
            campaigns: Liste von {"name": str, "budget": float, "channel": str}

        Returns:
            Dict mit Vergleichstabelle und Rankings.
        """
        results = []
        for c in campaigns:
            roi = self.project_roi(c.get("budget", 0), c.get("channel", "unknown"))
            results.append({
                "name": c.get("name", "?"),
                "budget": c.get("budget", 0),
                "channel": c.get("channel", "?"),
                "projected_installs": roi["projected_installs"],
                "cpi": roi["cpi"],
            })

        # Ranking nach CPI (niedrigster = bester)
        ranked = sorted(results, key=lambda x: x["cpi"])
        for i, r in enumerate(ranked):
            r["rank"] = i + 1

        total_budget = sum(r["budget"] for r in results)
        total_installs = sum(r["projected_installs"] for r in results)

        return {
            "campaigns": ranked,
            "total_budget": round(total_budget, 2),
            "total_projected_installs": total_installs,
            "avg_cpi": round(total_budget / max(total_installs, 1), 2),
            "best_channel": ranked[0]["channel"] if ranked else None,
            "simulation_only": True,
        }

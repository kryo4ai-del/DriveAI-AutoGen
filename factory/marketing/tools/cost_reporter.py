"""Marketing Cost Reporter — Aggregiert Kosten der Marketing-Abteilung.

LIEST TheBrain-Daten, SCHREIBT NICHT. Deterministisch.
"""

import json
import logging
import os
from datetime import datetime
from pathlib import Path

from factory.marketing.tools.ranking_database import RankingDatabase
from factory.marketing.config import OUTPUT_PATH, REPORTS_PATH

logger = logging.getLogger("factory.marketing.tools.cost_reporter")


class MarketingCostReporter:
    """Aggregiert und vergleicht Marketing-Kosten."""

    # Branchenuebliche Kosten (Benchmark-Daten)
    MARKET_BENCHMARKS = {
        "marketing_team_6months": 120000,     # 3 Personen, 6 Monate
        "content_production_agency": 15000,    # Agentur, 6 Monate
        "market_research": 8000,               # Marktforschung
        "pr_outreach": 12000,                  # PR-Agentur
        "performance_marketing_setup": 5000,   # Kampagnen-Setup
        "analytics_tools": 3000,               # SaaS-Tools (Mixpanel, etc.)
        "total": 163000,
    }

    # Geschaetzte Kosten pro API-Call-Typ
    ESTIMATED_COSTS = {
        "llm_per_call": 0.003,       # Durchschnitt fuer Mid-Tier Modelle
        "serpapi_per_call": 0.01,    # SerpAPI Search
        "image_per_call": 0.04,     # Image Generation (wenn aktiv)
        "video_per_call": 0.0,      # FFmpeg = lokal = $0
        "email_per_call": 0.0,      # SMTP = lokal/Dry-Run = $0
    }

    def __init__(self):
        self.db = RankingDatabase()

    def calculate_marketing_costs(self, project_slug: str = None) -> dict:
        """Berechnet Marketing-Kosten.

        Versucht echte Daten aus TheBrain zu lesen.
        Falls nicht zugreifbar: Schaetzung basierend auf bekannten API-Preisen.

        Returns: {
            "source": "live" | "estimated",
            "project_slug": str | None,
            "llm_costs": float,
            "research_costs": float,
            "image_costs": float,
            "video_costs": float,
            "email_costs": float,
            "total": float,
            "currency": "USD",
        }
        """
        # Versuch 1: Live-Daten aus TheBrain
        live_costs = self._try_live_costs(project_slug)
        if live_costs:
            return live_costs

        # Versuch 2: Schaetzung
        return self._estimate_costs(project_slug)

    def _try_live_costs(self, project_slug: str = None) -> dict | None:
        """Versucht Kosten aus TheBrain ChainTracker/CostTracker zu lesen."""
        try:
            from factory.brain.model_provider.chain_tracker import ChainTracker
            tracker = ChainTracker()
            # Versuche Marketing-Kosten zu extrahieren
            stats = tracker.get_stats() if hasattr(tracker, "get_stats") else None
            if stats and isinstance(stats, dict):
                marketing_costs = stats.get("marketing", stats.get("total", {}))
                if isinstance(marketing_costs, dict) and marketing_costs.get("total_cost", 0) > 0:
                    return {
                        "source": "live",
                        "project_slug": project_slug,
                        "llm_costs": float(marketing_costs.get("llm_cost", 0)),
                        "research_costs": float(marketing_costs.get("research_cost", 0)),
                        "image_costs": float(marketing_costs.get("image_cost", 0)),
                        "video_costs": 0.0,
                        "email_costs": 0.0,
                        "total": float(marketing_costs.get("total_cost", 0)),
                        "currency": "USD",
                    }
        except Exception as e:
            logger.debug("ChainTracker not available: %s", e)

        try:
            from factory.brain.service_provider.cost_tracker import ServiceCostTracker
            tracker = ServiceCostTracker()
            if hasattr(tracker, "get_department_costs"):
                costs = tracker.get_department_costs("marketing")
                if costs and isinstance(costs, dict) and costs.get("total", 0) > 0:
                    return {
                        "source": "live",
                        "project_slug": project_slug,
                        "llm_costs": float(costs.get("llm", 0)),
                        "research_costs": float(costs.get("research", 0)),
                        "image_costs": float(costs.get("image", 0)),
                        "video_costs": 0.0,
                        "email_costs": 0.0,
                        "total": float(costs.get("total", 0)),
                        "currency": "USD",
                    }
        except Exception as e:
            logger.debug("ServiceCostTracker not available: %s", e)

        return None

    def _estimate_costs(self, project_slug: str = None) -> dict:
        """Schaetzung basierend auf bekannten API-Preisen."""
        # 14 Marketing-Agents, ~50 LLM-Calls pro Projekt-Durchlauf
        llm_calls = 50
        research_calls = 10  # SerpAPI fuer ASO + Trends
        image_calls = 5      # Social Graphics + Thumbnails

        llm_costs = llm_calls * self.ESTIMATED_COSTS["llm_per_call"]
        research_costs = research_calls * self.ESTIMATED_COSTS["serpapi_per_call"]
        image_costs = image_calls * self.ESTIMATED_COSTS["image_per_call"]
        video_costs = 0.0   # FFmpeg lokal
        email_costs = 0.0   # SMTP lokal/Dry-Run

        total = llm_costs + research_costs + image_costs + video_costs + email_costs

        return {
            "source": "estimated",
            "project_slug": project_slug,
            "llm_costs": round(llm_costs, 4),
            "research_costs": round(research_costs, 4),
            "image_costs": round(image_costs, 4),
            "video_costs": video_costs,
            "email_costs": email_costs,
            "total": round(total, 4),
            "currency": "USD",
            "assumptions": {
                "llm_calls": llm_calls,
                "research_calls": research_calls,
                "image_calls": image_calls,
                "cost_per_llm_call": self.ESTIMATED_COSTS["llm_per_call"],
            },
        }

    def compare_factory_vs_market(self, project_slug: str = None) -> dict:
        """Factory vs. Branche."""
        factory = self.calculate_marketing_costs(project_slug)
        market = self.MARKET_BENCHMARKS.copy()

        factory_total = factory["total"]
        market_total = market["total"]

        savings_absolute = market_total - factory_total
        savings_percent = (savings_absolute / market_total * 100) if market_total > 0 else 0

        return {
            "factory": {
                "total": factory_total,
                "breakdown": {
                    "llm": factory["llm_costs"],
                    "research": factory["research_costs"],
                    "image": factory["image_costs"],
                    "video": factory["video_costs"],
                    "email": factory["email_costs"],
                },
                "source": factory["source"],
            },
            "market": {
                "total": market_total,
                "breakdown": {k: v for k, v in market.items() if k != "total"},
            },
            "savings_absolute": round(savings_absolute, 2),
            "savings_percent": round(savings_percent, 2),
        }

    def create_cost_export(self) -> str:
        """JSON-Export fuer SWF-12.
        Output: factory/marketing/output/costs/marketing_costs_{date}.json
        """
        now = datetime.now()
        date_str = now.strftime("%Y%m%d")

        costs = self.calculate_marketing_costs()
        comparison = self.compare_factory_vs_market()

        export = {
            "generated_at": now.isoformat(),
            "costs": costs,
            "comparison": comparison,
        }

        out_dir = Path(OUTPUT_PATH) / "costs"
        out_dir.mkdir(parents=True, exist_ok=True)
        out_path = out_dir / f"marketing_costs_{date_str}.json"
        out_path.write_text(json.dumps(export, indent=2, default=str), encoding="utf-8")

        logger.info("Cost export: %s", out_path)
        return str(out_path)

    def get_cost_trend(self, days: int = 30) -> list[dict]:
        """Kosten-Verlauf. Liest aus Export-Dateien wenn vorhanden."""
        cost_dir = Path(OUTPUT_PATH) / "costs"
        if not cost_dir.exists():
            return []

        trend = []
        for f in sorted(cost_dir.glob("marketing_costs_*.json")):
            try:
                data = json.loads(f.read_text(encoding="utf-8"))
                trend.append({
                    "date": data.get("generated_at", f.stem.split("_")[-1]),
                    "total": data.get("costs", {}).get("total", 0),
                    "source": data.get("costs", {}).get("source", "unknown"),
                })
            except Exception:
                continue

        return trend[-days:]  # Letzte N Eintraege

    def create_cost_report(self) -> str:
        """Lesbarer Kosten-Report.
        Output: factory/marketing/reports/costs/cost_report_{date}.md
        """
        now = datetime.now()
        date_str = now.strftime("%Y%m%d")

        costs = self.calculate_marketing_costs()
        comparison = self.compare_factory_vs_market()

        report_dir = Path(REPORTS_PATH) / "costs"
        report_dir.mkdir(parents=True, exist_ok=True)
        report_path = report_dir / f"cost_report_{date_str}.md"

        lines = [
            "# Marketing Cost Report",
            f"\nGeneriert: {now.strftime('%Y-%m-%d %H:%M')}",
            f"\n## Factory-Kosten ({costs['source'].upper()})",
            f"\n| Posten | Kosten |",
            f"|---|---|",
            f"| LLM-Calls | ${costs['llm_costs']:.4f} |",
            f"| Research (SerpAPI) | ${costs['research_costs']:.4f} |",
            f"| Image Generation | ${costs['image_costs']:.4f} |",
            f"| Video (FFmpeg) | ${costs['video_costs']:.4f} |",
            f"| Email (SMTP) | ${costs['email_costs']:.4f} |",
            f"| **Gesamt** | **${costs['total']:.4f}** |",
            f"\n## Factory vs. Markt",
            f"\n| | Factory | Markt |",
            f"|---|---|---|",
            f"| Gesamt | ${comparison['factory']['total']:.2f} | "
            f"${comparison['market']['total']:,.0f} |",
            f"| **Ersparnis** | **${comparison['savings_absolute']:,.2f}** | "
            f"**{comparison['savings_percent']:.1f}%** |",
            f"\n### Markt-Benchmark (6 Monate)",
        ]
        for k, v in comparison["market"]["breakdown"].items():
            lines.append(f"- {k}: ${v:,.0f}")

        content = "\n".join(lines)
        report_path.write_text(content, encoding="utf-8")
        logger.info("Cost report: %s", report_path)
        return str(report_path)

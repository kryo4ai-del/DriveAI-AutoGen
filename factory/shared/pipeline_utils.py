"""Shared utilities for all pipeline runners.
Tracks model selection, costs, and generates enriched pipeline summaries.
"""

from datetime import datetime


class AgentTracker:
    """Tracks model usage and costs per agent across a pipeline run."""

    def __init__(self):
        self.agents = []

    def record(self, agent_name: str, status: str, report_length: int,
               model: str = "unknown", provider: str = "unknown",
               llm_calls: int = 1, cost_usd: float = 0.0,
               serpapi_calls: int = 0):
        """Record one agent's execution result."""
        self.agents.append({
            "name": agent_name,
            "status": status,
            "model": model,
            "provider": provider,
            "report_length": report_length,
            "llm_calls": llm_calls,
            "cost_usd": round(cost_usd, 4),
            "serpapi_calls": serpapi_calls,
        })

    def generate_summary(self, idea_title: str, run_number: int,
                         kapitel: str, status: str = "completed",
                         extra_sections: str = "") -> str:
        """Generate enriched pipeline_summary.md content."""
        agent_rows = []
        for a in self.agents:
            agent_rows.append(
                f"| {a['name']} | {a['status']} | {a['model']} | {a['provider']} "
                f"| {a['report_length']:,} Zeichen | {a['llm_calls']} | ${a['cost_usd']:.4f} |"
            )
        agent_table = "\n".join(agent_rows)

        total_llm = sum(a["cost_usd"] for a in self.agents)
        total_serpapi = sum(a["serpapi_calls"] for a in self.agents)
        total_calls = sum(a["llm_calls"] for a in self.agents)
        serpapi_cost = total_serpapi * 0.01

        summary = f"""# Pipeline-Summary: {idea_title}
**Run:** #{run_number:03d}
**Datum:** {datetime.now().strftime('%Y-%m-%d')}
**Status:** {status}
**Kapitel:** {kapitel}

## Agent-Status
| Agent | Status | Modell | Provider | Report-Laenge | LLM-Calls | Kosten-USD |
|---|---|---|---|---|---|---|
{agent_table}

## SerpAPI-Nutzung
- API-Calls: {total_serpapi}
- Geschaetzte SerpAPI-Kosten: ${serpapi_cost:.2f}

## Kosten-Zusammenfassung
- LLM-Calls gesamt: {total_calls}
- LLM-Kosten gesamt: ${total_llm:.4f}
- SerpAPI-Kosten gesamt: ${serpapi_cost:.2f}
- **Gesamtkosten dieser Pipeline: ${total_llm + serpapi_cost:.4f}**
{extra_sections}"""

        return summary

    def get_totals(self) -> dict:
        """Get aggregated totals for project registry."""
        return {
            "agents_ok": sum(1 for a in self.agents if a["status"] == "OK"),
            "agents_total": len(self.agents),
            "llm_cost_usd": round(sum(a["cost_usd"] for a in self.agents), 4),
            "serpapi_credits": sum(a["serpapi_calls"] for a in self.agents),
            "llm_calls": sum(a["llm_calls"] for a in self.agents),
        }

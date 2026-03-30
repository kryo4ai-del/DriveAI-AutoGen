"""Support Analyzer -- kategorisiert Tickets, erkennt Muster, berechnet Support-Health."""

from collections import Counter
from datetime import datetime, timezone
from typing import Optional

from ...app_registry.database import AppRegistryDB
from . import config


class SupportAnalyzer:
    """Analysiert Support-Tickets fuer Live Operations Insights."""

    def __init__(self, registry_db: Optional[AppRegistryDB] = None) -> None:
        self.db = registry_db or AppRegistryDB()

    def process_tickets(self, app_id: str, tickets: list[dict],
                        dau: int = 0) -> dict:
        """Verarbeitet und analysiert Tickets."""
        if not tickets:
            print(f"[Support Analyzer] No tickets for {app_id}")
            return self._empty_result(app_id)

        print(f"[Support Analyzer] Processing {len(tickets)} tickets for {app_id}")

        categorized = [self._categorize_ticket(t) for t in tickets]
        urgencies = [self._assess_urgency(t) for t in tickets]
        recurring = self._detect_recurring_issues(tickets, categorized)
        health = self._calculate_support_health(tickets, urgencies, dau)
        insights = self._generate_insights(categorized, urgencies, recurring, health)

        cat_counts = Counter(c["category"] for c in categorized)
        urg_counts = Counter(urgencies)

        return {
            "app_id": app_id,
            "analyzed_at": datetime.now(timezone.utc).isoformat(),
            "period_days": config.RECURRING_WINDOW_DAYS,
            "total_tickets": len(tickets),
            "category_breakdown": dict(cat_counts),
            "urgency_breakdown": dict(urg_counts),
            "support_health": health,
            "recurring_issues": recurring,
            "insights": insights,
        }

    def get_support_summary(self, app_id: str) -> dict:
        """Zusammenfassung fuer Dashboard und Decision Engine."""
        return self._empty_result(app_id)

    # ------------------------------------------------------------------
    # Categorization
    # ------------------------------------------------------------------

    def _categorize_ticket(self, ticket: dict) -> dict:
        """Kategorie zuweisen via Keyword-Matching."""
        text = f"{ticket.get('subject', '')} {ticket.get('body', '')}".lower()

        best_cat = "other"
        best_score = 0

        for category, keywords in config.TICKET_CATEGORIES.items():
            score = sum(1 for kw in keywords if kw in text)
            if score > best_score:
                best_score = score
                best_cat = category

        return {
            "ticket_id": ticket.get("ticket_id", ""),
            "category": best_cat,
            "text_snippet": text[:80],
        }

    def _assess_urgency(self, ticket: dict) -> str:
        """Urgency bewerten: low/medium/high/critical."""
        text = f"{ticket.get('subject', '')} {ticket.get('body', '')}".lower()

        is_crash = any(kw in text for kw in config.TICKET_CATEGORIES.get("crash", []))
        is_account = any(kw in text for kw in config.TICKET_CATEGORIES.get("account", []))
        is_persistent = any(kw in text for kw in config.URGENCY_CRITICAL_KEYWORDS)
        is_core = any(kw in text for kw in config.URGENCY_CORE_FEATURES)

        # Critical: crash + persistent keyword + core feature
        if is_crash and (is_persistent or is_core):
            return "critical"
        # High: crash OR (account issue)
        if is_crash or is_account:
            return "high"
        # Medium: bug or performance
        is_bug = any(kw in text for kw in config.TICKET_CATEGORIES.get("bug", []))
        is_perf = any(kw in text for kw in config.TICKET_CATEGORIES.get("performance", []))
        if is_bug or is_perf:
            return "medium"
        # Low: feature request, how_to, other
        return "low"

    # ------------------------------------------------------------------
    # Recurring Issues
    # ------------------------------------------------------------------

    def _detect_recurring_issues(self, tickets: list[dict],
                                 categorized: list[dict]) -> list[dict]:
        """Erkennt wiederkehrende Probleme."""
        # Gruppiere nach Kategorie + Platform + Version
        issue_groups = {}

        for ticket, cat_info in zip(tickets, categorized):
            key = (
                cat_info["category"],
                ticket.get("user_platform", "unknown"),
                ticket.get("app_version", "unknown"),
            )
            if key not in issue_groups:
                issue_groups[key] = []
            issue_groups[key].append(ticket)

        recurring = []
        for (category, platform, version), group_tickets in issue_groups.items():
            if len(group_tickets) < config.RECURRING_MIN_TICKETS:
                continue

            # Severity Score basierend auf Count und Urgency
            urgencies = [self._assess_urgency(t) for t in group_tickets]
            critical_count = urgencies.count("critical")
            high_count = urgencies.count("high")
            severity_score = min(100, len(group_tickets) * 10 + critical_count * 20 + high_count * 10)

            # Issue name generieren
            issue_name = f"{category.replace('_', ' ').title()} on {platform} v{version}"

            recurring.append({
                "issue": issue_name,
                "category": category,
                "ticket_count": len(group_tickets),
                "affected_platform": platform,
                "affected_version": version,
                "severity_score": severity_score,
                "sample_tickets": [t.get("ticket_id", "") for t in group_tickets[:3]],
                "suggested_action": self._suggest_action(category, platform, version),
            })

        recurring.sort(key=lambda r: r["severity_score"], reverse=True)
        return recurring

    def _suggest_action(self, category: str, platform: str, version: str) -> str:
        """Generiert Action-Vorschlag."""
        if category == "crash":
            return f"Hotfix for crash on {platform} {version} -- likely regression"
        if category == "bug":
            return f"Investigate and patch bug on {platform} {version}"
        if category == "performance":
            return f"Performance profiling on {platform}"
        if category == "how_to":
            return "Improve in-app help or add tutorial for this feature"
        if category == "account":
            return "Check auth/payment system for issues"
        return f"Monitor {category} reports on {platform}"

    # ------------------------------------------------------------------
    # Support Health
    # ------------------------------------------------------------------

    def _calculate_support_health(self, tickets: list[dict],
                                  urgencies: list[str], dau: int) -> dict:
        """Support-Metriken berechnen."""
        total = len(tickets)
        critical_count = urgencies.count("critical")
        critical_ratio = critical_count / max(total, 1)
        tickets_per_dau = total / max(dau, 1)

        return {
            "tickets_per_dau": round(tickets_per_dau, 4),
            "trend": "unknown",  # Would need historical data
            "critical_ratio": round(critical_ratio, 3),
            "above_dau_threshold": tickets_per_dau > config.TICKETS_PER_DAU_THRESHOLD,
            "above_critical_threshold": critical_ratio > config.CRITICAL_RATIO_THRESHOLD,
        }

    # ------------------------------------------------------------------
    # Insights
    # ------------------------------------------------------------------

    def _generate_insights(self, categorized: list, urgencies: list,
                           recurring: list, health: dict) -> list[dict]:
        """Generiert Insights fuer Decision Engine."""
        insights = []

        # Recurring Issues
        for issue in recurring:
            if issue["severity_score"] >= 70:
                insights.append({
                    "type": "critical",
                    "message": f"{issue['ticket_count']} tickets for '{issue['issue']}' -- likely regression",
                    "recurring_issue": issue["issue"],
                    "suggested_action": issue["suggested_action"],
                })
            else:
                insights.append({
                    "type": "warning",
                    "message": f"Recurring: '{issue['issue']}' ({issue['ticket_count']} tickets)",
                    "recurring_issue": issue["issue"],
                    "suggested_action": issue["suggested_action"],
                })

        # High critical ratio
        if health.get("above_critical_threshold"):
            insights.append({
                "type": "critical",
                "message": f"Critical ticket ratio {health['critical_ratio']:.0%} exceeds threshold {config.CRITICAL_RATIO_THRESHOLD:.0%}",
                "suggested_action": "Investigate critical issues immediately",
            })

        # High ticket volume
        if health.get("above_dau_threshold"):
            insights.append({
                "type": "warning",
                "message": f"Support volume high: {health['tickets_per_dau']:.2%} of DAU submitting tickets",
                "suggested_action": "Review common issues and improve in-app help",
            })

        # How-to pattern (documentation issue)
        howto_count = sum(1 for c in categorized if c["category"] == "how_to")
        if howto_count >= 5:
            insights.append({
                "type": "info",
                "message": f"{howto_count} how-to tickets -- documentation/UX might be unclear",
                "suggested_action": "Add in-app tutorials or tooltips for confusing features",
            })

        return insights

    def _empty_result(self, app_id: str) -> dict:
        return {
            "app_id": app_id,
            "analyzed_at": datetime.now(timezone.utc).isoformat(),
            "total_tickets": 0,
            "category_breakdown": {},
            "urgency_breakdown": {},
            "support_health": {},
            "recurring_issues": [],
            "insights": [],
        }

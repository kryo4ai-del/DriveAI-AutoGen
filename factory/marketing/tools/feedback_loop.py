"""Marketing Feedback-Loop — Verbindet Analytics mit Content-Agents.

Macht die Abteilung selbstlernend. Analysiert Performance-Daten und routet
Erkenntnisse an die richtigen Agents.
"""

import json
import logging
from datetime import datetime, timedelta

from factory.marketing.tools.ranking_database import RankingDatabase
from factory.marketing.alerts.alert_manager import MarketingAlertManager

logger = logging.getLogger("factory.marketing.tools.feedback_loop")


class MarketingFeedbackLoop:
    """Analysiert Performance-Daten und routet Erkenntnisse an die richtigen Agents."""

    # Mapping: Insight-Typ → Ziel-Agent
    ROUTING = {
        "content_underperform": "MKT-03",     # Copywriter
        "content_outperform": "MKT-03",       # Copywriter
        "hook_performance": "MKT-03",         # Copywriter + Hook-Bibliothek
        "keyword_change": "MKT-05",           # ASO Agent
        "store_conversion_drop": "MKT-06",    # Visual Designer (Screenshots)
        "sentiment_shift": "MKT-02",          # Strategy Agent
        "competitor_move": "MKT-02",          # Strategy Agent
        "format_preference": "MKT-07",        # Video Script Agent
        "audience_insight": "MKT-14",         # Campaign Planner
    }

    def __init__(self):
        self.db = RankingDatabase()
        self.alerts = MarketingAlertManager()

    def analyze_and_route(self, period_days: int = 7) -> dict:
        """Analysiert die letzten X Tage und erstellt Feedback-Tasks.

        Prueft:
        1. Post-Performance: Top/Bottom Posts identifizieren
        2. Hook-Performance: Welche funktionierten
        3. Format-Performance: Video vs Image vs Text
        4. Sentiment: Stimmungsaenderung
        5. Competitor: Aenderungen erkennen

        Returns: {"period_days": int, "insights_found": int,
                  "tasks_created": int, "tasks": [dict]}
        """
        insights = []
        tasks_created = []

        # 1. Post-Performance: Top/Bottom
        insights.extend(self._analyze_post_performance(period_days))

        # 2. Hook-Performance
        insights.extend(self._analyze_hook_performance())

        # 3. Format-Performance
        insights.extend(self._analyze_format_performance(period_days))

        # 4. Sentiment
        insights.extend(self._analyze_sentiment(period_days))

        # 5. Competitor changes
        insights.extend(self._analyze_competitors())

        # Create feedback tasks for each insight
        for insight in insights:
            task_id = self.create_feedback_task(
                insight_type=insight["type"],
                description=insight["description"],
                data=insight.get("data", {}),
                priority=insight.get("priority", "medium"),
            )
            tasks_created.append({
                "task_id": task_id,
                "insight_type": insight["type"],
                "target_agent": self.ROUTING.get(insight["type"], "MKT-02"),
                "description": insight["description"],
            })

        result = {
            "period_days": period_days,
            "insights_found": len(insights),
            "tasks_created": len(tasks_created),
            "tasks": tasks_created,
        }
        logger.info("Feedback analysis: %d insights, %d tasks created",
                     len(insights), len(tasks_created))
        return result

    def _analyze_post_performance(self, days: int) -> list[dict]:
        """Identifiziert Top/Bottom Posts."""
        insights = []
        top_posts = self.db.get_top_posts(limit=5, days=days)
        if not top_posts:
            return insights

        # Berechne Durchschnitt
        all_posts = self.db.get_top_posts(limit=100, days=days)
        if len(all_posts) < 3:
            return insights

        avg_engagement = sum(p.get("engagements", 0) for p in all_posts) / len(all_posts)
        if avg_engagement == 0:
            return insights

        for post in top_posts[:2]:
            eng = post.get("engagements", 0)
            if eng > avg_engagement * 2:
                insights.append({
                    "type": "content_outperform",
                    "description": f"Post {post.get('post_id', '?')} auf {post.get('platform', '?')} "
                                   f"hat {eng} Engagements (Schnitt: {avg_engagement:.0f})",
                    "data": {"post_id": post.get("post_id"), "platform": post.get("platform"),
                             "engagements": eng, "avg": avg_engagement},
                    "priority": "medium",
                })

        # Bottom Posts
        bottom = sorted(all_posts, key=lambda p: p.get("engagements", 0))
        for post in bottom[:2]:
            eng = post.get("engagements", 0)
            if eng < avg_engagement * 0.3 and avg_engagement > 0:
                insights.append({
                    "type": "content_underperform",
                    "description": f"Post {post.get('post_id', '?')} auf {post.get('platform', '?')} "
                                   f"hat nur {eng} Engagements (Schnitt: {avg_engagement:.0f})",
                    "data": {"post_id": post.get("post_id"), "platform": post.get("platform"),
                             "engagements": eng, "avg": avg_engagement},
                    "priority": "medium",
                })

        return insights

    def _analyze_hook_performance(self) -> list[dict]:
        """Analysiert Hook-Erfolgsraten."""
        insights = []
        proven_hooks = self.db.get_hooks(status="proven", limit=5)
        deprecated_hooks = self.db.get_hooks(status="deprecated", limit=5)

        if proven_hooks:
            insights.append({
                "type": "hook_performance",
                "description": f"{len(proven_hooks)} bewiesene Hooks gefunden — "
                               f"Top: '{proven_hooks[0].get('hook_text', '?')[:50]}'",
                "data": {"proven_count": len(proven_hooks),
                         "top_hook": proven_hooks[0].get("hook_text", "")[:100]},
                "priority": "low",
            })

        if deprecated_hooks:
            insights.append({
                "type": "hook_performance",
                "description": f"{len(deprecated_hooks)} gescheiterte Hooks — ueberarbeiten",
                "data": {"deprecated_count": len(deprecated_hooks)},
                "priority": "medium",
            })

        return insights

    def _analyze_format_performance(self, days: int) -> list[dict]:
        """Analysiert Format-Performance (Video vs Image vs Text)."""
        insights = []
        formats = self.db.get_format_performance(days=days)
        if len(formats) < 2:
            return insights

        # Gruppieren nach format_type
        by_format: dict[str, list] = {}
        for f in formats:
            fmt = f.get("format_type", "unknown")
            by_format.setdefault(fmt, []).append(f.get("avg_engagement", 0))

        # Durchschnitt pro Format
        avg_by_format = {}
        for fmt, values in by_format.items():
            avg_by_format[fmt] = sum(values) / len(values) if values else 0

        if len(avg_by_format) >= 2:
            best = max(avg_by_format, key=avg_by_format.get)
            worst = min(avg_by_format, key=avg_by_format.get)
            if avg_by_format[best] > 0 and avg_by_format[worst] < avg_by_format[best] * 0.5:
                insights.append({
                    "type": "format_preference",
                    "description": f"Format '{best}' performt {avg_by_format[best]:.0f} avg engagement "
                                   f"vs '{worst}' mit {avg_by_format[worst]:.0f}",
                    "data": {"best_format": best, "worst_format": worst,
                             "best_avg": avg_by_format[best], "worst_avg": avg_by_format[worst]},
                    "priority": "medium",
                })

        return insights

    def _analyze_sentiment(self, days: int) -> list[dict]:
        """Analysiert Sentiment-Veraenderungen."""
        insights = []
        # Pruefe Sentiment-Daten fuer 'echomatch' oder allgemein
        for topic in ["echomatch", "factory", "driveai"]:
            trend = self.db.get_sentiment_trend(topic, days=days)
            if len(trend) < 2:
                continue
            scores = [t.get("sentiment_score", 0) for t in trend if t.get("sentiment_score") is not None]
            if len(scores) < 2:
                continue
            recent = scores[0]
            older = scores[-1]
            if older != 0 and abs(recent - older) / abs(older) > 0.2:
                direction = "verbessert" if recent > older else "verschlechtert"
                insights.append({
                    "type": "sentiment_shift",
                    "description": f"Sentiment fuer '{topic}' hat sich {direction}: "
                                   f"{older:.2f} → {recent:.2f}",
                    "data": {"topic": topic, "old_score": older, "new_score": recent},
                    "priority": "high" if recent < older else "low",
                })
        return insights

    def _analyze_competitors(self) -> list[dict]:
        """Prueft ob Wettbewerber Aenderungen vorgenommen haben."""
        insights = []
        conn = self.db._connect()
        try:
            rows = conn.execute(
                "SELECT DISTINCT competitor_name FROM competitor_snapshots "
                "ORDER BY id DESC LIMIT 10"
            ).fetchall()
        finally:
            conn.close()

        for row in rows:
            name = row["competitor_name"]
            changes = self.db.detect_competitor_changes(name)
            if changes.get("changed"):
                insights.append({
                    "type": "competitor_move",
                    "description": f"Wettbewerber '{name}' hat Aenderungen: "
                                   f"{', '.join(changes['changes'].keys())}",
                    "data": {"competitor": name, "changes": changes["changes"]},
                    "priority": "high",
                })
        return insights

    def create_feedback_task(self, insight_type: str, description: str,
                             data: dict = None, priority: str = "medium") -> str:
        """Erstellt einen Feedback-Task.

        target_agent wird automatisch aus ROUTING bestimmt.
        task_id Format: "FB-{NNN}-{YYYYMMDD}"
        """
        target_agent = self.ROUTING.get(insight_type, "MKT-02")
        now = datetime.now()

        # Zaehle existierende Tasks fuer ID
        existing = self.db.get_feedback_tasks(limit=9999)
        counter = len(existing) + 1
        task_id = f"FB-{counter:03d}-{now.strftime('%Y%m%d')}"

        data_json = json.dumps(data, default=str) if data else None

        self.db.store_feedback_task(
            task_id=task_id,
            insight_type=insight_type,
            target_agent=target_agent,
            description=description,
            data_json=data_json,
            priority=priority,
        )

        logger.info("Feedback task created: %s → %s (%s)", task_id, target_agent, insight_type)
        return task_id

    def track_feedback_execution(self, task_id: str, result: str) -> bool:
        """Markiert Task als ausgefuehrt mit Ergebnis. Status: open → executed."""
        now = datetime.now().isoformat()
        return self.db.update_feedback_task(
            task_id, status="executed", executed_date=now, result=result,
        )

    def measure_feedback_impact(self, task_id: str) -> dict:
        """Misst ob der Feedback-Task eine Verbesserung gebracht hat.

        Vergleicht Performance-Metriken vor und nach der Umsetzung.
        Status: executed → measured.

        Returns: {"improved": bool, "metric_before": float, "metric_after": float,
                  "change_percent": float}
        """
        tasks = self.db.get_feedback_tasks(limit=9999)
        task = None
        for t in tasks:
            if t.get("task_id") == task_id:
                task = t
                break

        if not task or task.get("status") != "executed":
            return {"improved": False, "metric_before": 0, "metric_after": 0,
                    "change_percent": 0, "error": "Task not found or not executed"}

        # Versuche Performance-Daten zu vergleichen
        data = json.loads(task["data_json"]) if task.get("data_json") else {}
        platform = data.get("platform")
        executed_date = task.get("executed_date", "")

        # Hole Posts vor und nach execution
        all_posts_before = []
        all_posts_after = []

        if platform and executed_date:
            conn = self.db._connect()
            try:
                before = conn.execute(
                    "SELECT AVG(engagements) as avg_eng FROM post_performance "
                    "WHERE platform = ? AND date < ?",
                    (platform, executed_date[:10]),
                ).fetchone()
                after = conn.execute(
                    "SELECT AVG(engagements) as avg_eng FROM post_performance "
                    "WHERE platform = ? AND date >= ?",
                    (platform, executed_date[:10]),
                ).fetchone()
                metric_before = float(before["avg_eng"] or 0)
                metric_after = float(after["avg_eng"] or 0)
            finally:
                conn.close()
        else:
            metric_before = 0.0
            metric_after = 0.0

        change_pct = ((metric_after - metric_before) / metric_before * 100
                      if metric_before > 0 else 0.0)
        improved = metric_after > metric_before

        # Status auf measured setzen
        self.db.update_feedback_task(task_id, status="measured")

        return {
            "improved": improved,
            "metric_before": metric_before,
            "metric_after": metric_after,
            "change_percent": round(change_pct, 2),
        }

    def get_feedback_effectiveness(self, days: int = 30) -> dict:
        """Gesamtbericht: wie effektiv ist der Feedback-Loop."""
        all_tasks = self.db.get_feedback_tasks(limit=9999)

        # Filter by date if possible
        cutoff = (datetime.now() - timedelta(days=days)).isoformat()
        tasks = [t for t in all_tasks
                 if (t.get("created_date") or "") >= cutoff[:10]]

        total = len(tasks)
        executed = sum(1 for t in tasks if t.get("status") in ("executed", "measured"))
        measured = sum(1 for t in tasks if t.get("status") == "measured")
        # Fuer improved: pruefe result
        improved = 0
        for t in tasks:
            if t.get("status") == "measured" and t.get("result"):
                try:
                    r = json.loads(t["result"])
                    if r.get("improved"):
                        improved += 1
                except (json.JSONDecodeError, TypeError):
                    pass

        return {
            "total_tasks": total,
            "executed": executed,
            "measured": measured,
            "improved": improved,
            "effectiveness_rate": round(improved / max(measured, 1) * 100, 1),
        }

    def get_open_tasks(self, target_agent: str = None) -> list[dict]:
        """Offene Tasks, optional gefiltert nach Agent."""
        return self.db.get_feedback_tasks(status="open", target_agent=target_agent)

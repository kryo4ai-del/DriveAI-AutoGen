"""Marketing Ranking Database — SQLite-basierte Metriken-Speicherung.

Deterministisch, kein LLM. Speichert historische Daten fuer Trend-Analysen.
"""

import json
import logging
import os
import sqlite3
from datetime import datetime, timedelta
from typing import Optional

logger = logging.getLogger("factory.marketing.tools.ranking_database")


class RankingDatabase:
    """SQLite-Datenbank fuer Marketing-Metriken und Rankings."""

    DEFAULT_DB_PATH = os.path.join("factory", "marketing", "data", "marketing_metrics.db")

    def __init__(self, db_path: str = None):
        if db_path:
            self.db_path = db_path
        else:
            # Pfad relativ zum Factory-Root aufloesen
            try:
                from factory.marketing.config import MARKETING_ROOT
                root = os.path.dirname(os.path.dirname(MARKETING_ROOT))
            except Exception:
                root = os.path.dirname(os.path.dirname(os.path.dirname(
                    os.path.dirname(os.path.abspath(__file__)))))
            self.db_path = os.path.join(root, self.DEFAULT_DB_PATH)

        os.makedirs(os.path.dirname(self.db_path), exist_ok=True)
        self.init_db()
        logger.info("RankingDatabase initialized: %s", self.db_path)

    def _connect(self) -> sqlite3.Connection:
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        return conn

    def init_db(self) -> None:
        """Erstellt alle Tabellen (CREATE IF NOT EXISTS)."""
        conn = self._connect()
        try:
            conn.executescript("""
                CREATE TABLE IF NOT EXISTS keyword_rankings (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    app_id TEXT NOT NULL,
                    store TEXT NOT NULL,
                    keyword TEXT NOT NULL,
                    position INTEGER,
                    country TEXT DEFAULT 'DE',
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS app_metrics (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    app_id TEXT NOT NULL,
                    store TEXT NOT NULL,
                    metric_type TEXT NOT NULL,
                    value REAL,
                    metadata_json TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS review_log (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    app_id TEXT NOT NULL,
                    store TEXT NOT NULL,
                    review_id TEXT NOT NULL,
                    rating INTEGER,
                    title TEXT,
                    body TEXT,
                    author TEXT,
                    response_text TEXT,
                    response_status TEXT DEFAULT 'pending',
                    stufe INTEGER DEFAULT 0,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS social_metrics (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    platform TEXT NOT NULL,
                    metric_type TEXT NOT NULL,
                    value REAL,
                    metadata_json TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS post_performance (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    platform TEXT NOT NULL,
                    post_id TEXT NOT NULL,
                    content_type TEXT,
                    impressions INTEGER DEFAULT 0,
                    engagements INTEGER DEFAULT 0,
                    likes INTEGER DEFAULT 0,
                    shares INTEGER DEFAULT 0,
                    comments INTEGER DEFAULT 0,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE INDEX IF NOT EXISTS idx_kr_app_keyword ON keyword_rankings(app_id, keyword);
                CREATE INDEX IF NOT EXISTS idx_am_app_type ON app_metrics(app_id, metric_type);
                CREATE INDEX IF NOT EXISTS idx_sm_platform ON social_metrics(platform, metric_type);
                CREATE INDEX IF NOT EXISTS idx_pp_platform ON post_performance(platform, date);
            """)
            conn.commit()
        finally:
            conn.close()

    def store_keyword_rankings(self, app_id: str, store: str,
                               rankings: list[dict], country: str = "DE") -> int:
        """Speichert Keyword-Rankings. Returns: Anzahl gespeicherter Eintraege."""
        today = datetime.now().strftime("%Y-%m-%d")
        conn = self._connect()
        count = 0
        try:
            for r in rankings:
                conn.execute(
                    "INSERT INTO keyword_rankings (date, app_id, store, keyword, position, country) "
                    "VALUES (?, ?, ?, ?, ?, ?)",
                    (today, app_id, store, r["keyword"], r.get("position"), country),
                )
                count += 1
            conn.commit()
        finally:
            conn.close()
        logger.info("Stored %d keyword rankings for %s (%s)", count, app_id, store)
        return count

    def store_app_metrics(self, app_id: str, store: str, metrics: dict) -> int:
        """Speichert App-Metriken (Downloads, Revenue, etc.)."""
        today = datetime.now().strftime("%Y-%m-%d")
        conn = self._connect()
        count = 0
        try:
            for metric_type, data in metrics.items():
                if isinstance(data, dict):
                    value = data.get("daily_avg") or data.get("dau") or data.get("d1") or 0
                    metadata = json.dumps(data)
                else:
                    value = float(data) if data else 0
                    metadata = None
                conn.execute(
                    "INSERT INTO app_metrics (date, app_id, store, metric_type, value, metadata_json) "
                    "VALUES (?, ?, ?, ?, ?, ?)",
                    (today, app_id, store, metric_type, value, metadata),
                )
                count += 1
            conn.commit()
        finally:
            conn.close()
        logger.info("Stored %d app metrics for %s (%s)", count, app_id, store)
        return count

    def store_review(self, app_id: str, store: str, review: dict,
                     response_text: str = None, response_status: str = "pending",
                     stufe: int = 0) -> int:
        """Speichert ein Review mit Response-Status und Stufe."""
        today = datetime.now().strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO review_log (date, app_id, store, review_id, rating, title, body, "
                "author, response_text, response_status, stufe) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (today, app_id, store, review.get("id", ""), review.get("rating", 0),
                 review.get("title", ""), review.get("body", ""), review.get("author", ""),
                 response_text, response_status, stufe),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def store_social_metrics(self, platform: str, metrics: dict) -> int:
        """Speichert Social Media Metriken."""
        today = datetime.now().strftime("%Y-%m-%d")
        conn = self._connect()
        count = 0
        try:
            for metric_type, value in metrics.items():
                if isinstance(value, dict):
                    val = value.get("total") or value.get("count") or 0
                    metadata = json.dumps(value)
                else:
                    val = float(value) if value else 0
                    metadata = None
                conn.execute(
                    "INSERT INTO social_metrics (date, platform, metric_type, value, metadata_json) "
                    "VALUES (?, ?, ?, ?, ?)",
                    (today, platform, metric_type, val, metadata),
                )
                count += 1
            conn.commit()
        finally:
            conn.close()
        logger.info("Stored %d social metrics for %s", count, platform)
        return count

    def store_post_performance(self, platform: str, post_id: str,
                               content_type: str, metrics: dict) -> int:
        """Speichert Post-Performance-Daten."""
        today = datetime.now().strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO post_performance (date, platform, post_id, content_type, "
                "impressions, engagements, likes, shares, comments) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (today, platform, post_id, content_type,
                 metrics.get("impressions", 0), metrics.get("engagements", 0),
                 metrics.get("likes", 0), metrics.get("shares", 0), metrics.get("comments", 0)),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_keyword_trend(self, app_id: str, keyword: str,
                          days: int = 30, country: str = "DE") -> list[dict]:
        """Gibt Keyword-Positions-Verlauf zurueck."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            rows = conn.execute(
                "SELECT date, position, store FROM keyword_rankings "
                "WHERE app_id = ? AND keyword = ? AND country = ? AND date >= ? "
                "ORDER BY date ASC",
                (app_id, keyword, country, cutoff),
            ).fetchall()
            return [{"date": r["date"], "position": r["position"], "store": r["store"]} for r in rows]
        finally:
            conn.close()

    def get_metrics_trend(self, app_id: str, metric_type: str,
                          days: int = 30) -> list[dict]:
        """Gibt Metriken-Verlauf zurueck."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            rows = conn.execute(
                "SELECT date, value, store, metadata_json FROM app_metrics "
                "WHERE app_id = ? AND metric_type = ? AND date >= ? "
                "ORDER BY date ASC",
                (app_id, metric_type, cutoff),
            ).fetchall()
            return [{"date": r["date"], "value": r["value"], "store": r["store"],
                     "metadata": json.loads(r["metadata_json"]) if r["metadata_json"] else None}
                    for r in rows]
        finally:
            conn.close()

    def get_review_stats(self, app_id: str, days: int = 30) -> dict:
        """Review-Statistik: Anzahl pro Rating, Response-Rate, avg Rating."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            rows = conn.execute(
                "SELECT rating, COUNT(*) as cnt FROM review_log "
                "WHERE app_id = ? AND date >= ? GROUP BY rating",
                (app_id, cutoff),
            ).fetchall()

            total = sum(r["cnt"] for r in rows)
            by_rating = {str(r["rating"]): r["cnt"] for r in rows}
            avg = sum(r["rating"] * r["cnt"] for r in rows) / max(total, 1)

            responded = conn.execute(
                "SELECT COUNT(*) as cnt FROM review_log "
                "WHERE app_id = ? AND date >= ? AND response_status = 'responded'",
                (app_id, cutoff),
            ).fetchone()["cnt"]

            return {
                "total": total,
                "by_rating": by_rating,
                "average": round(avg, 2),
                "responded": responded,
                "response_rate": round(responded / max(total, 1) * 100, 1),
            }
        finally:
            conn.close()

    def get_social_trend(self, platform: str, metric_type: str,
                         days: int = 30) -> list[dict]:
        """Social Media Metriken-Verlauf."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            rows = conn.execute(
                "SELECT date, value, metadata_json FROM social_metrics "
                "WHERE platform = ? AND metric_type = ? AND date >= ? "
                "ORDER BY date ASC",
                (platform, metric_type, cutoff),
            ).fetchall()
            return [{"date": r["date"], "value": r["value"],
                     "metadata": json.loads(r["metadata_json"]) if r["metadata_json"] else None}
                    for r in rows]
        finally:
            conn.close()

    def get_top_posts(self, platform: str = None,
                      metric: str = "engagements",
                      limit: int = 10, days: int = 30) -> list[dict]:
        """Top-performende Posts nach Metrik."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            if platform:
                rows = conn.execute(
                    f"SELECT * FROM post_performance WHERE platform = ? AND date >= ? "
                    f"ORDER BY {metric} DESC LIMIT ?",
                    (platform, cutoff, limit),
                ).fetchall()
            else:
                rows = conn.execute(
                    f"SELECT * FROM post_performance WHERE date >= ? "
                    f"ORDER BY {metric} DESC LIMIT ?",
                    (cutoff, limit),
                ).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    def export_for_report(self, app_id: str = None, days: int = 30) -> dict:
        """Exportiert alle relevanten Daten fuer den Report Agent."""
        result = {
            "db_stats": self.get_db_stats(),
            "keyword_trends": {},
            "metric_trends": {},
            "review_stats": {},
            "social_trends": {},
            "top_posts": [],
        }

        if app_id:
            result["review_stats"] = self.get_review_stats(app_id, days)

            # Keyword-Trends fuer bekannte Keywords
            conn = self._connect()
            try:
                keywords = conn.execute(
                    "SELECT DISTINCT keyword FROM keyword_rankings WHERE app_id = ?",
                    (app_id,),
                ).fetchall()
                for row in keywords:
                    kw = row["keyword"]
                    result["keyword_trends"][kw] = self.get_keyword_trend(app_id, kw, days)
            finally:
                conn.close()

            # Metric-Trends
            for mt in ["downloads", "revenue", "sessions", "crashes", "active_devices", "retention"]:
                trend = self.get_metrics_trend(app_id, mt, days)
                if trend:
                    result["metric_trends"][mt] = trend

        # Social Trends
        for platform in ["youtube", "tiktok", "x"]:
            for mt in ["followers", "views", "engagements"]:
                trend = self.get_social_trend(platform, mt, days)
                if trend:
                    result["social_trends"].setdefault(platform, {})[mt] = trend

        result["top_posts"] = self.get_top_posts(limit=10, days=days)

        return result

    def get_db_stats(self) -> dict:
        """Gibt DB-Statistik zurueck: Rows pro Tabelle, DB-Groesse."""
        conn = self._connect()
        try:
            stats = {"tables": {}}
            for table in ["keyword_rankings", "app_metrics", "review_log",
                          "social_metrics", "post_performance"]:
                count = conn.execute(f"SELECT COUNT(*) as cnt FROM {table}").fetchone()["cnt"]
                stats["tables"][table] = count

            stats["total_rows"] = sum(stats["tables"].values())
            stats["db_size_bytes"] = os.path.getsize(self.db_path) if os.path.exists(self.db_path) else 0
            stats["db_path"] = self.db_path
            return stats
        finally:
            conn.close()

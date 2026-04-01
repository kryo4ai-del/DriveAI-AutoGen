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

                CREATE TABLE IF NOT EXISTS trends (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    source TEXT NOT NULL,
                    topic TEXT NOT NULL,
                    description TEXT,
                    relevance_score REAL,
                    urgency TEXT,
                    content_suggestion TEXT,
                    action_taken TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS competitors (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    level TEXT NOT NULL,
                    competitor_name TEXT NOT NULL,
                    category TEXT,
                    store TEXT,
                    store_rating REAL,
                    review_count INTEGER,
                    keyword_overlap TEXT,
                    last_update TEXT,
                    notes TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS competitor_snapshots (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    competitor_name TEXT NOT NULL,
                    listing_text_hash TEXT,
                    rating REAL,
                    review_count INTEGER,
                    version TEXT,
                    metadata_json TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS github_repos (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    owner TEXT NOT NULL,
                    repo TEXT NOT NULL,
                    stars INTEGER,
                    forks INTEGER,
                    open_issues INTEGER,
                    language TEXT,
                    last_push TEXT,
                    description TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS sentiment_data (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    topic TEXT NOT NULL,
                    source TEXT,
                    sentiment_score REAL,
                    sentiment_label TEXT,
                    dominant_narratives TEXT,
                    sample_count INTEGER,
                    confidence REAL,
                    summary TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS factory_mentions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    source TEXT NOT NULL,
                    url TEXT,
                    context TEXT,
                    sentiment TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS hook_library (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    hook_text TEXT NOT NULL,
                    platform TEXT NOT NULL,
                    topic TEXT,
                    category TEXT,
                    times_used INTEGER DEFAULT 0,
                    times_successful INTEGER DEFAULT 0,
                    success_rate REAL DEFAULT 0.0,
                    status TEXT DEFAULT 'hypothesis',
                    created_date TEXT DEFAULT (datetime('now')),
                    last_used TEXT
                );

                CREATE TABLE IF NOT EXISTS format_performance (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    date TEXT NOT NULL,
                    platform TEXT NOT NULL,
                    format_type TEXT NOT NULL,
                    avg_engagement REAL,
                    sample_count INTEGER,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE INDEX IF NOT EXISTS idx_kr_app_keyword ON keyword_rankings(app_id, keyword);
                CREATE INDEX IF NOT EXISTS idx_am_app_type ON app_metrics(app_id, metric_type);
                CREATE INDEX IF NOT EXISTS idx_sm_platform ON social_metrics(platform, metric_type);
                CREATE INDEX IF NOT EXISTS idx_pp_platform ON post_performance(platform, date);
                CREATE INDEX IF NOT EXISTS idx_trends_source ON trends(source, date);
                CREATE INDEX IF NOT EXISTS idx_comp_name ON competitors(competitor_name, date);
                CREATE INDEX IF NOT EXISTS idx_comp_snap ON competitor_snapshots(competitor_name, date);
                CREATE INDEX IF NOT EXISTS idx_gh_repo ON github_repos(owner, repo, date);
                CREATE INDEX IF NOT EXISTS idx_sent_topic ON sentiment_data(topic, date);
                CREATE INDEX IF NOT EXISTS idx_fm_date ON factory_mentions(date);
                CREATE TABLE IF NOT EXISTS press_contacts (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    outlet TEXT NOT NULL,
                    email TEXT,
                    role TEXT,
                    topics TEXT,
                    reach_estimate INTEGER,
                    country TEXT,
                    language TEXT,
                    status TEXT DEFAULT 'new',
                    last_contacted TEXT,
                    notes TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS influencers (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    platform TEXT NOT NULL,
                    handle TEXT,
                    url TEXT,
                    followers INTEGER,
                    topics TEXT,
                    tier TEXT,
                    engagement_rate REAL,
                    country TEXT,
                    language TEXT,
                    status TEXT DEFAULT 'discovered',
                    last_contacted TEXT,
                    last_post_about_us TEXT,
                    notes TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS ab_tests (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    test_name TEXT NOT NULL,
                    hypothesis TEXT,
                    variant_a_desc TEXT,
                    variant_b_desc TEXT,
                    metric TEXT,
                    start_date TEXT,
                    end_date TEXT,
                    winner TEXT,
                    confidence REAL,
                    p_value REAL,
                    learnings TEXT,
                    created_at TEXT DEFAULT (datetime('now'))
                );

                CREATE TABLE IF NOT EXISTS surveys (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL,
                    survey_type TEXT,
                    platforms TEXT,
                    questions_json TEXT,
                    status TEXT DEFAULT 'draft',
                    created_date TEXT DEFAULT (datetime('now')),
                    close_date TEXT,
                    results_json TEXT,
                    analysis TEXT
                );

                CREATE TABLE IF NOT EXISTS feedback_tasks (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    task_id TEXT NOT NULL UNIQUE,
                    insight_type TEXT NOT NULL,
                    target_agent TEXT NOT NULL,
                    description TEXT,
                    data_json TEXT,
                    recommended_action TEXT,
                    priority TEXT DEFAULT 'medium',
                    status TEXT DEFAULT 'open',
                    created_date TEXT DEFAULT (datetime('now')),
                    executed_date TEXT,
                    result TEXT
                );

                CREATE TABLE IF NOT EXISTS marketing_knowledge (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    category TEXT NOT NULL,
                    insight TEXT NOT NULL,
                    evidence TEXT,
                    confidence TEXT DEFAULT 'hypothesis',
                    observations_count INTEGER DEFAULT 1,
                    first_observed TEXT DEFAULT (datetime('now')),
                    last_confirmed TEXT,
                    source_agent TEXT,
                    tags TEXT
                );

                CREATE TABLE IF NOT EXISTS pipeline_runs (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    project_slug TEXT NOT NULL,
                    step_number INTEGER NOT NULL,
                    step_name TEXT NOT NULL,
                    status TEXT DEFAULT 'pending',
                    started_at TEXT,
                    completed_at TEXT,
                    output_path TEXT,
                    error_message TEXT
                );

                CREATE INDEX IF NOT EXISTS idx_hook_platform ON hook_library(platform, status);
                CREATE INDEX IF NOT EXISTS idx_fp_platform ON format_performance(platform, date);
                CREATE INDEX IF NOT EXISTS idx_pc_outlet ON press_contacts(outlet, status);
                CREATE INDEX IF NOT EXISTS idx_inf_platform ON influencers(platform, tier);
                CREATE INDEX IF NOT EXISTS idx_ab_name ON ab_tests(test_name);
                CREATE INDEX IF NOT EXISTS idx_survey_status ON surveys(status);
                CREATE INDEX IF NOT EXISTS idx_ft_status ON feedback_tasks(status);
                CREATE INDEX IF NOT EXISTS idx_ft_agent ON feedback_tasks(target_agent);
                CREATE INDEX IF NOT EXISTS idx_mk_category ON marketing_knowledge(category, confidence);
                CREATE INDEX IF NOT EXISTS idx_pr_slug ON pipeline_runs(project_slug, step_number);
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

    # ── Trends ─────────────────────────────────────────────

    def store_trend(self, source: str, topic: str, description: str = None,
                    relevance_score: float = None, urgency: str = None,
                    content_suggestion: str = None) -> int:
        """Speichert einen Trend. Returns: row id."""
        today = datetime.now().strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO trends (date, source, topic, description, relevance_score, "
                "urgency, content_suggestion) VALUES (?, ?, ?, ?, ?, ?, ?)",
                (today, source, topic, description, relevance_score, urgency, content_suggestion),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_trend_history(self, days: int = 30, source: str = None,
                          min_relevance: float = None) -> list[dict]:
        """Gibt Trend-Verlauf zurueck, optional gefiltert."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            query = "SELECT * FROM trends WHERE date >= ?"
            params: list = [cutoff]
            if source:
                query += " AND source = ?"
                params.append(source)
            if min_relevance is not None:
                query += " AND relevance_score >= ?"
                params.append(min_relevance)
            query += " ORDER BY date DESC, relevance_score DESC"
            rows = conn.execute(query, params).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    # ── Competitors ───────────────────────────────────────

    def store_competitor(self, level: str, competitor_name: str,
                         category: str = None, store: str = None,
                         store_rating: float = None, review_count: int = None,
                         keyword_overlap: list = None, notes: str = None) -> int:
        """Speichert Wettbewerber-Daten."""
        today = datetime.now().strftime("%Y-%m-%d")
        overlap_json = json.dumps(keyword_overlap) if keyword_overlap else None
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO competitors (date, level, competitor_name, category, store, "
                "store_rating, review_count, keyword_overlap, last_update, notes) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (today, level, competitor_name, category, store,
                 store_rating, review_count, overlap_json, today, notes),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def store_competitor_snapshot(self, competitor_name: str,
                                  listing_text_hash: str = None,
                                  rating: float = None, review_count: int = None,
                                  version: str = None, metadata: dict = None) -> int:
        """Speichert einen Snapshot fuer Change-Detection."""
        today = datetime.now().strftime("%Y-%m-%d")
        meta_json = json.dumps(metadata) if metadata else None
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO competitor_snapshots (date, competitor_name, listing_text_hash, "
                "rating, review_count, version, metadata_json) VALUES (?, ?, ?, ?, ?, ?, ?)",
                (today, competitor_name, listing_text_hash, rating, review_count, version, meta_json),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_competitor_snapshots(self, competitor_name: str,
                                 limit: int = 10) -> list[dict]:
        """Gibt die letzten Snapshots eines Wettbewerbers zurueck."""
        conn = self._connect()
        try:
            rows = conn.execute(
                "SELECT * FROM competitor_snapshots WHERE competitor_name = ? "
                "ORDER BY id DESC LIMIT ?",
                (competitor_name, limit),
            ).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    def detect_competitor_changes(self, competitor_name: str) -> dict:
        """Vergleicht die letzten 2 Snapshots.
        Returns: {"changed": bool, "changes": {"rating": [old, new], ...}}
        """
        snapshots = self.get_competitor_snapshots(competitor_name, limit=2)
        if len(snapshots) < 2:
            return {"changed": False, "changes": {}}

        newest, previous = snapshots[0], snapshots[1]
        changes = {}

        for field in ("rating", "review_count", "version", "listing_text_hash"):
            old_val = previous.get(field)
            new_val = newest.get(field)
            if old_val != new_val and old_val is not None and new_val is not None:
                changes[field] = [old_val, new_val]

        return {"changed": bool(changes), "changes": changes}

    # ── GitHub Repos ──────────────────────────────────────

    def store_github_repo(self, owner: str, repo: str, stars: int = None,
                          forks: int = None, open_issues: int = None,
                          language: str = None, last_push: str = None,
                          description: str = None) -> int:
        """Speichert GitHub Repo Snapshot."""
        today = datetime.now().strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO github_repos (date, owner, repo, stars, forks, open_issues, "
                "language, last_push, description) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (today, owner, repo, stars, forks, open_issues, language, last_push, description),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_github_repo_trend(self, owner: str, repo: str,
                               days: int = 30) -> list[dict]:
        """Gibt Star-/Fork-Verlauf eines Repos zurueck."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            rows = conn.execute(
                "SELECT date, stars, forks, open_issues FROM github_repos "
                "WHERE owner = ? AND repo = ? AND date >= ? ORDER BY date ASC",
                (owner, repo, cutoff),
            ).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    # ── Sentiment ─────────────────────────────────────────

    def store_sentiment(self, topic: str, source: str = None,
                        sentiment_score: float = None, sentiment_label: str = None,
                        dominant_narratives: list = None, sample_count: int = None,
                        confidence: float = None, summary: str = None) -> int:
        """Speichert Sentiment-Daten."""
        today = datetime.now().strftime("%Y-%m-%d")
        narr_json = json.dumps(dominant_narratives) if dominant_narratives else None
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO sentiment_data (date, topic, source, sentiment_score, "
                "sentiment_label, dominant_narratives, sample_count, confidence, summary) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (today, topic, source, sentiment_score, sentiment_label,
                 narr_json, sample_count, confidence, summary),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_sentiment_trend(self, topic: str, days: int = 30) -> list[dict]:
        """Gibt Sentiment-Verlauf fuer ein Topic zurueck."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            rows = conn.execute(
                "SELECT * FROM sentiment_data WHERE topic = ? AND date >= ? "
                "ORDER BY date DESC",
                (topic, cutoff),
            ).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    def store_factory_mention(self, source: str, url: str = None,
                               context: str = None, sentiment: str = None) -> int:
        """Speichert eine Factory-Erwaehnung."""
        today = datetime.now().strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO factory_mentions (date, source, url, context, sentiment) "
                "VALUES (?, ?, ?, ?, ?)",
                (today, source, url, context, sentiment),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_factory_mentions(self, days: int = 30) -> list[dict]:
        """Gibt Factory-Erwaehungen zurueck."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            rows = conn.execute(
                "SELECT * FROM factory_mentions WHERE date >= ? ORDER BY date DESC",
                (cutoff,),
            ).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    # ── Hook Library ─────────────────────────────────────

    def store_hook(self, hook_text: str, platform: str,
                   topic: str = None, category: str = None) -> int:
        """Speichert einen Hook in der Bibliothek. Returns: hook_id."""
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO hook_library (hook_text, platform, topic, category) "
                "VALUES (?, ?, ?, ?)",
                (hook_text, platform, topic, category),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def update_hook_usage(self, hook_id: int, successful: bool) -> None:
        """Aktualisiert Hook-Nutzung. Auto-Promotion/Deprecation."""
        conn = self._connect()
        try:
            now = datetime.now().isoformat()
            if successful:
                conn.execute(
                    "UPDATE hook_library SET times_used = times_used + 1, "
                    "times_successful = times_successful + 1, last_used = ? WHERE id = ?",
                    (now, hook_id),
                )
            else:
                conn.execute(
                    "UPDATE hook_library SET times_used = times_used + 1, "
                    "last_used = ? WHERE id = ?",
                    (now, hook_id),
                )
            # Recalculate success_rate
            conn.execute(
                "UPDATE hook_library SET success_rate = "
                "CASE WHEN times_used > 0 THEN CAST(times_successful AS REAL) / times_used ELSE 0 END "
                "WHERE id = ?",
                (hook_id,),
            )
            # Auto-Promotion: 2+ successes → proven
            conn.execute(
                "UPDATE hook_library SET status = 'proven' "
                "WHERE id = ? AND times_successful >= 2 AND status = 'hypothesis'",
                (hook_id,),
            )
            # Auto-Deprecation: 3+ used AND success_rate < 0.3 → deprecated
            conn.execute(
                "UPDATE hook_library SET status = 'deprecated' "
                "WHERE id = ? AND times_used >= 3 AND success_rate < 0.3 AND status != 'deprecated'",
                (hook_id,),
            )
            conn.commit()
        finally:
            conn.close()

    def get_hooks(self, platform: str = None, topic: str = None,
                  status: str = None, limit: int = 10) -> list[dict]:
        """Gibt Hooks zurueck, optional gefiltert."""
        conn = self._connect()
        try:
            query = "SELECT * FROM hook_library WHERE 1=1"
            params: list = []
            if platform:
                query += " AND platform = ?"
                params.append(platform)
            if topic:
                query += " AND topic = ?"
                params.append(topic)
            if status:
                query += " AND status = ?"
                params.append(status)
            query += " ORDER BY success_rate DESC, times_successful DESC LIMIT ?"
            params.append(limit)
            rows = conn.execute(query, params).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    # ── Format Performance ─────────────────────────────────

    def store_format_performance(self, platform: str, format_type: str,
                                  avg_engagement: float = None,
                                  sample_count: int = None) -> int:
        """Speichert Format-Performance. Returns: row id."""
        today = datetime.now().strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO format_performance (date, platform, format_type, "
                "avg_engagement, sample_count) VALUES (?, ?, ?, ?, ?)",
                (today, platform, format_type, avg_engagement, sample_count),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_format_performance(self, platform: str = None,
                                days: int = 30) -> list[dict]:
        """Gibt Format-Performance zurueck."""
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")
        conn = self._connect()
        try:
            query = "SELECT * FROM format_performance WHERE date >= ?"
            params: list = [cutoff]
            if platform:
                query += " AND platform = ?"
                params.append(platform)
            query += " ORDER BY date DESC"
            rows = conn.execute(query, params).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    # ── Press Contacts ─────────────────────────────────────

    def store_press_contact(self, name: str, outlet: str, email: str = None,
                            role: str = "journalist", topics: str = None,
                            reach_estimate: int = None, country: str = "US",
                            language: str = "en", notes: str = None) -> int:
        """Speichert einen Presse-Kontakt. Returns: contact_id."""
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO press_contacts (name, outlet, email, role, topics, "
                "reach_estimate, country, language, notes) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (name, outlet, email, role, topics, reach_estimate, country, language, notes),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def search_press_contacts(self, topic: str = None, country: str = None,
                              role: str = None, status: str = None,
                              limit: int = 50) -> list[dict]:
        """Sucht Presse-Kontakte nach Kriterien."""
        conn = self._connect()
        try:
            query = "SELECT * FROM press_contacts WHERE 1=1"
            params: list = []
            if topic:
                query += " AND topics LIKE ?"
                params.append(f"%{topic}%")
            if country:
                query += " AND country = ?"
                params.append(country)
            if role:
                query += " AND role = ?"
                params.append(role)
            if status:
                query += " AND status = ?"
                params.append(status)
            query += " ORDER BY reach_estimate DESC NULLS LAST LIMIT ?"
            params.append(limit)
            rows = conn.execute(query, params).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    def update_press_contact_status(self, contact_id: int, status: str,
                                    notes: str = None) -> bool:
        """Aktualisiert Status eines Kontakts."""
        conn = self._connect()
        try:
            if notes:
                conn.execute(
                    "UPDATE press_contacts SET status = ?, notes = ?, "
                    "last_contacted = datetime('now') WHERE id = ?",
                    (status, notes, contact_id),
                )
            else:
                conn.execute(
                    "UPDATE press_contacts SET status = ?, "
                    "last_contacted = datetime('now') WHERE id = ?",
                    (status, contact_id),
                )
            conn.commit()
            return True
        except Exception:
            return False
        finally:
            conn.close()

    def get_press_contact_stats(self) -> dict:
        """Uebersicht: Anzahl nach Status, Land, Rolle."""
        conn = self._connect()
        try:
            stats = {"total": 0, "by_status": {}, "by_country": {}, "by_role": {}}
            stats["total"] = conn.execute(
                "SELECT COUNT(*) as cnt FROM press_contacts"
            ).fetchone()["cnt"]
            for row in conn.execute(
                "SELECT status, COUNT(*) as cnt FROM press_contacts GROUP BY status"
            ).fetchall():
                stats["by_status"][row["status"]] = row["cnt"]
            for row in conn.execute(
                "SELECT country, COUNT(*) as cnt FROM press_contacts GROUP BY country"
            ).fetchall():
                stats["by_country"][row["country"]] = row["cnt"]
            for row in conn.execute(
                "SELECT role, COUNT(*) as cnt FROM press_contacts GROUP BY role"
            ).fetchall():
                stats["by_role"][row["role"]] = row["cnt"]
            return stats
        finally:
            conn.close()

    # ── Influencers ────────────────────────────────────────

    def store_influencer(self, name: str, platform: str, handle: str = None,
                         url: str = None, followers: int = 0,
                         topics: str = None, tier: str = None,
                         engagement_rate: float = None, country: str = "US",
                         language: str = "en", notes: str = None) -> int:
        """Speichert einen Influencer. Returns: influencer_id."""
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO influencers (name, platform, handle, url, followers, "
                "topics, tier, engagement_rate, country, language, notes) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (name, platform, handle, url, followers, topics, tier,
                 engagement_rate, country, language, notes),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def search_influencers(self, platform: str = None, topic: str = None,
                           tier: str = None, country: str = None,
                           status: str = None, limit: int = 50) -> list[dict]:
        """Sucht Influencer nach Kriterien."""
        conn = self._connect()
        try:
            query = "SELECT * FROM influencers WHERE 1=1"
            params: list = []
            if platform:
                query += " AND platform = ?"
                params.append(platform)
            if topic:
                query += " AND topics LIKE ?"
                params.append(f"%{topic}%")
            if tier:
                query += " AND tier = ?"
                params.append(tier)
            if country:
                query += " AND country = ?"
                params.append(country)
            if status:
                query += " AND status = ?"
                params.append(status)
            query += " ORDER BY followers DESC LIMIT ?"
            params.append(limit)
            rows = conn.execute(query, params).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    def update_influencer(self, influencer_id: int, **fields) -> bool:
        """Aktualisiert Influencer-Felder."""
        allowed = {"name", "platform", "handle", "url", "followers", "topics",
                    "tier", "engagement_rate", "country", "language", "status",
                    "last_contacted", "last_post_about_us", "notes"}
        updates = {k: v for k, v in fields.items() if k in allowed}
        if not updates:
            return False
        conn = self._connect()
        try:
            set_clause = ", ".join(f"{k} = ?" for k in updates)
            values = list(updates.values()) + [influencer_id]
            conn.execute(
                f"UPDATE influencers SET {set_clause} WHERE id = ?", values,
            )
            conn.commit()
            return True
        except Exception:
            return False
        finally:
            conn.close()

    def get_influencer_stats(self) -> dict:
        """Uebersicht nach Tier, Plattform, Status."""
        conn = self._connect()
        try:
            stats = {"total": 0, "by_tier": {}, "by_platform": {}, "by_status": {}}
            stats["total"] = conn.execute(
                "SELECT COUNT(*) as cnt FROM influencers"
            ).fetchone()["cnt"]
            for row in conn.execute(
                "SELECT tier, COUNT(*) as cnt FROM influencers GROUP BY tier"
            ).fetchall():
                stats["by_tier"][row["tier"] or "unknown"] = row["cnt"]
            for row in conn.execute(
                "SELECT platform, COUNT(*) as cnt FROM influencers GROUP BY platform"
            ).fetchall():
                stats["by_platform"][row["platform"]] = row["cnt"]
            for row in conn.execute(
                "SELECT status, COUNT(*) as cnt FROM influencers GROUP BY status"
            ).fetchall():
                stats["by_status"][row["status"]] = row["cnt"]
            return stats
        finally:
            conn.close()

    def delete_influencer(self, influencer_id: int) -> bool:
        """Loescht einen Influencer (fuer Test-Cleanup)."""
        conn = self._connect()
        try:
            conn.execute("DELETE FROM influencers WHERE id = ?", (influencer_id,))
            conn.commit()
            return True
        except Exception:
            return False
        finally:
            conn.close()

    # ── A/B Tests ─────────────────────────────────────────

    def store_ab_test(self, test_name: str, hypothesis: str = None,
                      variant_a_desc: str = None, variant_b_desc: str = None,
                      metric: str = None, start_date: str = None,
                      end_date: str = None, winner: str = None,
                      confidence: float = None, p_value: float = None,
                      learnings: str = None) -> int:
        """Speichert einen A/B-Test. Returns: test_id."""
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO ab_tests (test_name, hypothesis, variant_a_desc, variant_b_desc, "
                "metric, start_date, end_date, winner, confidence, p_value, learnings) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (test_name, hypothesis, variant_a_desc, variant_b_desc,
                 metric, start_date, end_date, winner, confidence, p_value, learnings),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_ab_test_history(self, test_name: str = None,
                            limit: int = 50) -> list[dict]:
        """Gibt A/B-Test-Verlauf zurueck, optional nach Name gefiltert."""
        conn = self._connect()
        try:
            if test_name:
                rows = conn.execute(
                    "SELECT * FROM ab_tests WHERE test_name = ? ORDER BY id DESC LIMIT ?",
                    (test_name, limit),
                ).fetchall()
            else:
                rows = conn.execute(
                    "SELECT * FROM ab_tests ORDER BY id DESC LIMIT ?",
                    (limit,),
                ).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    # ── Surveys ────────────────────────────────────────────

    def store_survey(self, title: str, survey_type: str = None,
                     platforms: str = None, questions_json: str = None,
                     status: str = "draft", close_date: str = None) -> int:
        """Speichert eine Survey. Returns: survey_id."""
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO surveys (title, survey_type, platforms, questions_json, "
                "status, close_date) VALUES (?, ?, ?, ?, ?, ?)",
                (title, survey_type, platforms, questions_json, status, close_date),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def update_survey(self, survey_id: int, **fields) -> bool:
        """Aktualisiert Survey-Felder."""
        allowed = {"title", "survey_type", "platforms", "questions_json",
                    "status", "close_date", "results_json", "analysis"}
        updates = {k: v for k, v in fields.items() if k in allowed}
        if not updates:
            return False
        conn = self._connect()
        try:
            set_clause = ", ".join(f"{k} = ?" for k in updates)
            values = list(updates.values()) + [survey_id]
            conn.execute(
                f"UPDATE surveys SET {set_clause} WHERE id = ?", values,
            )
            conn.commit()
            return True
        except Exception:
            return False
        finally:
            conn.close()

    def get_surveys(self, status: str = None, survey_type: str = None,
                    limit: int = 50) -> list[dict]:
        """Gibt Surveys zurueck, optional gefiltert."""
        conn = self._connect()
        try:
            query = "SELECT * FROM surveys WHERE 1=1"
            params: list = []
            if status:
                query += " AND status = ?"
                params.append(status)
            if survey_type:
                query += " AND survey_type = ?"
                params.append(survey_type)
            query += " ORDER BY id DESC LIMIT ?"
            params.append(limit)
            rows = conn.execute(query, params).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    # ── Feedback Tasks ─────────────────────────────────────

    def store_feedback_task(self, task_id: str, insight_type: str,
                            target_agent: str, description: str = None,
                            data_json: str = None, recommended_action: str = None,
                            priority: str = "medium") -> int:
        """Speichert einen Feedback-Task. Returns: row id."""
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO feedback_tasks (task_id, insight_type, target_agent, "
                "description, data_json, recommended_action, priority) "
                "VALUES (?, ?, ?, ?, ?, ?, ?)",
                (task_id, insight_type, target_agent, description,
                 data_json, recommended_action, priority),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_feedback_tasks(self, status: str = None,
                           target_agent: str = None,
                           limit: int = 50) -> list[dict]:
        """Gibt Feedback-Tasks zurueck, optional gefiltert."""
        conn = self._connect()
        try:
            query = "SELECT * FROM feedback_tasks WHERE 1=1"
            params: list = []
            if status:
                query += " AND status = ?"
                params.append(status)
            if target_agent:
                query += " AND target_agent = ?"
                params.append(target_agent)
            query += " ORDER BY id DESC LIMIT ?"
            params.append(limit)
            rows = conn.execute(query, params).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    def update_feedback_task(self, task_id: str, **fields) -> bool:
        """Aktualisiert Feedback-Task-Felder."""
        allowed = {"status", "executed_date", "result", "priority",
                    "recommended_action", "description"}
        updates = {k: v for k, v in fields.items() if k in allowed}
        if not updates:
            return False
        conn = self._connect()
        try:
            set_clause = ", ".join(f"{k} = ?" for k in updates)
            values = list(updates.values()) + [task_id]
            conn.execute(
                f"UPDATE feedback_tasks SET {set_clause} WHERE task_id = ?", values,
            )
            conn.commit()
            return True
        except Exception:
            return False
        finally:
            conn.close()

    # ── Marketing Knowledge ────────────────────────────────

    def store_knowledge(self, category: str, insight: str,
                        evidence: str = None, confidence: str = "hypothesis",
                        source_agent: str = None, tags: str = None) -> int:
        """Speichert einen Knowledge-Eintrag. Returns: knowledge_id."""
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO marketing_knowledge (category, insight, evidence, "
                "confidence, source_agent, tags) VALUES (?, ?, ?, ?, ?, ?)",
                (category, insight, evidence, confidence, source_agent, tags),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def get_knowledge(self, category: str = None, confidence: str = None,
                      limit: int = 50) -> list[dict]:
        """Gibt Knowledge-Eintraege zurueck, optional gefiltert."""
        conn = self._connect()
        try:
            query = "SELECT * FROM marketing_knowledge WHERE 1=1"
            params: list = []
            if category:
                query += " AND category = ?"
                params.append(category)
            if confidence:
                query += " AND confidence = ?"
                params.append(confidence)
            query += " ORDER BY observations_count DESC, id DESC LIMIT ?"
            params.append(limit)
            rows = conn.execute(query, params).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    def confirm_knowledge(self, knowledge_id: int) -> dict:
        """Bestaetigt Wissen: observations_count + 1, Auto-Promotion.

        Returns: {"id": int, "confidence": str, "observations_count": int}
        """
        conn = self._connect()
        try:
            now = datetime.now().isoformat()
            conn.execute(
                "UPDATE marketing_knowledge SET observations_count = observations_count + 1, "
                "last_confirmed = ? WHERE id = ?",
                (now, knowledge_id),
            )
            # Auto-Promotion
            conn.execute(
                "UPDATE marketing_knowledge SET confidence = 'confirmed' "
                "WHERE id = ? AND observations_count >= 2 AND confidence = 'hypothesis'",
                (knowledge_id,),
            )
            conn.execute(
                "UPDATE marketing_knowledge SET confidence = 'established' "
                "WHERE id = ? AND observations_count >= 5 AND confidence IN ('hypothesis', 'confirmed')",
                (knowledge_id,),
            )
            conn.commit()
            row = conn.execute(
                "SELECT id, confidence, observations_count FROM marketing_knowledge WHERE id = ?",
                (knowledge_id,),
            ).fetchone()
            return dict(row) if row else {}
        finally:
            conn.close()

    def update_knowledge(self, knowledge_id: int, **fields) -> bool:
        """Aktualisiert Knowledge-Felder."""
        allowed = {"confidence", "evidence", "tags", "source_agent", "insight"}
        updates = {k: v for k, v in fields.items() if k in allowed}
        if not updates:
            return False
        conn = self._connect()
        try:
            set_clause = ", ".join(f"{k} = ?" for k in updates)
            values = list(updates.values()) + [knowledge_id]
            conn.execute(
                f"UPDATE marketing_knowledge SET {set_clause} WHERE id = ?", values,
            )
            conn.commit()
            return True
        except Exception:
            return False
        finally:
            conn.close()

    def search_knowledge(self, keywords: str = None, category: str = None,
                         min_confidence: str = None,
                         limit: int = 20) -> list[dict]:
        """Sucht Knowledge nach Keywords in insight + evidence + tags."""
        conn = self._connect()
        confidence_order = {"hypothesis": 0, "confirmed": 1, "established": 2, "deprecated": -1}
        try:
            query = "SELECT * FROM marketing_knowledge WHERE 1=1"
            params: list = []
            if category:
                query += " AND category = ?"
                params.append(category)
            if keywords:
                query += " AND (insight LIKE ? OR evidence LIKE ? OR tags LIKE ?)"
                like = f"%{keywords}%"
                params.extend([like, like, like])
            if min_confidence and min_confidence in confidence_order:
                min_val = confidence_order[min_confidence]
                valid = [k for k, v in confidence_order.items() if v >= min_val]
                placeholders = ",".join("?" for _ in valid)
                query += f" AND confidence IN ({placeholders})"
                params.extend(valid)
            query += " ORDER BY observations_count DESC LIMIT ?"
            params.append(limit)
            rows = conn.execute(query, params).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    # ── Pipeline Runs ──────────────────────────────────────

    def store_pipeline_run(self, project_slug: str, step_number: int,
                           step_name: str, status: str = "pending",
                           started_at: str = None) -> int:
        """Speichert einen Pipeline-Run-Eintrag. Returns: row id."""
        conn = self._connect()
        try:
            cursor = conn.execute(
                "INSERT INTO pipeline_runs (project_slug, step_number, step_name, "
                "status, started_at) VALUES (?, ?, ?, ?, ?)",
                (project_slug, step_number, step_name, status, started_at),
            )
            conn.commit()
            return cursor.lastrowid
        finally:
            conn.close()

    def update_pipeline_run(self, run_id: int, **fields) -> bool:
        """Aktualisiert Pipeline-Run-Felder."""
        allowed = {"status", "started_at", "completed_at", "output_path", "error_message"}
        updates = {k: v for k, v in fields.items() if k in allowed}
        if not updates:
            return False
        conn = self._connect()
        try:
            set_clause = ", ".join(f"{k} = ?" for k in updates)
            values = list(updates.values()) + [run_id]
            conn.execute(
                f"UPDATE pipeline_runs SET {set_clause} WHERE id = ?", values,
            )
            conn.commit()
            return True
        except Exception:
            return False
        finally:
            conn.close()

    def get_pipeline_runs(self, project_slug: str,
                          limit: int = 50) -> list[dict]:
        """Gibt Pipeline-Runs fuer ein Projekt zurueck."""
        conn = self._connect()
        try:
            rows = conn.execute(
                "SELECT * FROM pipeline_runs WHERE project_slug = ? "
                "ORDER BY step_number ASC, id DESC LIMIT ?",
                (project_slug, limit),
            ).fetchall()
            return [dict(r) for r in rows]
        finally:
            conn.close()

    # ── Stats ──────────────────────────────────────────────

    def get_db_stats(self) -> dict:
        """Gibt DB-Statistik zurueck: Rows pro Tabelle, DB-Groesse."""
        conn = self._connect()
        try:
            stats = {"tables": {}}
            for table in ["keyword_rankings", "app_metrics", "review_log",
                          "social_metrics", "post_performance",
                          "trends", "competitors", "competitor_snapshots",
                          "github_repos", "sentiment_data", "factory_mentions",
                          "hook_library", "format_performance",
                          "press_contacts", "influencers",
                          "ab_tests", "surveys",
                          "feedback_tasks", "marketing_knowledge", "pipeline_runs"]:
                count = conn.execute(f"SELECT COUNT(*) as cnt FROM {table}").fetchone()["cnt"]
                stats["tables"][table] = count

            stats["total_rows"] = sum(stats["tables"].values())
            stats["db_size_bytes"] = os.path.getsize(self.db_path) if os.path.exists(self.db_path) else 0
            stats["db_path"] = self.db_path
            return stats
        finally:
            conn.close()

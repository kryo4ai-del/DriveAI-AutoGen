"""GitHub REST API v3 Adapter — Trackt Open-Source KI-Projekte.

Oeffentliche API, kein Dry-Run noetig. Optional GITHUB_TOKEN fuer hoeheres Rate-Limit.
"""

import logging
import os
import time
from datetime import datetime, timedelta

import requests

logger = logging.getLogger("factory.marketing.adapters.github")


class GitHubAdapter:
    """GitHub REST API v3 Adapter."""

    STATUS = "active"
    PLATFORM = "github"
    API_BASE = "https://api.github.com"

    def __init__(self, dry_run: bool = False):
        # dry_run param accepted for interface compat but ignored — public API
        self.token = os.getenv("GITHUB_TOKEN")
        self.dry_run = False
        self._headers = {"Accept": "application/vnd.github.v3+json"}
        if self.token:
            self._headers["Authorization"] = f"token {self.token}"
            logger.info("GitHub Adapter: Token found (5000 req/h)")
        else:
            logger.info("GitHub Adapter: No token (60 req/h limit)")

    def _request(self, endpoint: str, params: dict = None) -> dict | list | None:
        """GitHub API Request mit Rate-Limiting und Error-Handling."""
        time.sleep(1.0)
        try:
            url = f"{self.API_BASE}{endpoint}"
            response = requests.get(url, headers=self._headers, params=params, timeout=15)

            if response.status_code == 403:
                remaining = response.headers.get("X-RateLimit-Remaining", "?")
                logger.warning("GitHub rate limited. Remaining: %s", remaining)
                return None
            if response.status_code == 404:
                logger.info("GitHub 404: %s", endpoint)
                return None

            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error("GitHub request failed: %s", e)
            return None

    # ── Repo Info ─────────────────────────────────────────

    def get_repo_info(self, owner: str, repo: str) -> dict | None:
        """Repo-Informationen: Stars, Forks, Issues, Description, Language."""
        data = self._request(f"/repos/{owner}/{repo}")
        if not data or not isinstance(data, dict):
            return None

        return {
            "full_name": data.get("full_name", f"{owner}/{repo}"),
            "description": data.get("description", ""),
            "stars": data.get("stargazers_count", 0),
            "forks": data.get("forks_count", 0),
            "open_issues": data.get("open_issues_count", 0),
            "language": data.get("language"),
            "last_push": data.get("pushed_at", ""),
            "created_at": data.get("created_at", ""),
            "topics": data.get("topics", []),
            "license": data.get("license", {}).get("spdx_id") if data.get("license") else None,
        }

    # ── Releases ──────────────────────────────────────────

    def get_repo_releases(self, owner: str, repo: str,
                          limit: int = 5) -> list[dict]:
        """Letzte Releases mit Datum und Tag."""
        data = self._request(f"/repos/{owner}/{repo}/releases", params={"per_page": limit})
        if not data or not isinstance(data, list):
            return []

        return [
            {
                "tag": r.get("tag_name", ""),
                "name": r.get("name", ""),
                "published_at": r.get("published_at", ""),
                "body": (r.get("body") or "")[:500],
            }
            for r in data[:limit]
        ]

    # ── Search ────────────────────────────────────────────

    def search_repos(self, query: str, sort: str = "stars",
                     limit: int = 20) -> list[dict]:
        """Suche nach Repos."""
        data = self._request(
            "/search/repositories",
            params={"q": query, "sort": sort, "per_page": min(limit, 100)},
        )
        if not data or not isinstance(data, dict):
            return []

        return [
            {
                "full_name": r.get("full_name", ""),
                "stars": r.get("stargazers_count", 0),
                "description": (r.get("description") or "")[:200],
                "language": r.get("language"),
            }
            for r in data.get("items", [])[:limit]
        ]

    # ── Trending ──────────────────────────────────────────

    def get_trending_repos(self, language: str = None,
                           since: str = "weekly") -> list[dict]:
        """GitHub Trending Repos via Search API (created recently + sorted by stars)."""
        days_map = {"daily": 1, "weekly": 7, "monthly": 30}
        days = days_map.get(since, 7)
        cutoff = (datetime.now() - timedelta(days=days)).strftime("%Y-%m-%d")

        query = f"created:>{cutoff}"
        if language:
            query += f" language:{language}"

        return self.search_repos(query, sort="stars", limit=20)

    # ── Track Repos ───────────────────────────────────────

    def track_repos(self, repo_list: list[dict]) -> dict:
        """Trackt eine Liste von Repos und speichert in DB."""
        from factory.marketing.tools.ranking_database import RankingDatabase

        db = RankingDatabase()
        result = {"tracked": 0, "star_explosions": 0, "details": []}

        for entry in repo_list:
            owner = entry.get("owner", "")
            repo = entry.get("repo", "")
            if not owner or not repo:
                continue

            info = self.get_repo_info(owner, repo)
            if not info:
                continue

            # Store in DB
            db.store_github_repo(
                owner=owner, repo=repo,
                stars=info["stars"], forks=info["forks"],
                open_issues=info["open_issues"], language=info["language"],
                last_push=info["last_push"], description=info.get("description", ""),
            )

            # Check for star explosion
            trend = db.get_github_repo_trend(owner, repo, days=7)
            change = "stable"
            if len(trend) >= 2:
                prev_stars = trend[-2].get("stars", 0)
                cur_stars = info["stars"]
                if prev_stars > 0 and cur_stars > prev_stars * 1.5:
                    change = f"EXPLOSION ({prev_stars} -> {cur_stars})"
                    result["star_explosions"] += 1
                elif cur_stars > prev_stars:
                    change = f"+{cur_stars - prev_stars}"

            result["details"].append({
                "full_name": info["full_name"],
                "stars": info["stars"],
                "change": change,
            })
            result["tracked"] += 1

        return result

    # ── Rate Limit ────────────────────────────────────────

    def get_rate_limit_status(self) -> dict:
        """Aktuellen Rate-Limit-Status abfragen."""
        data = self._request("/rate_limit")
        if not data:
            return {"limit": 0, "remaining": 0, "reset": "unknown"}

        core = data.get("resources", {}).get("core", {})
        reset_ts = core.get("reset", 0)
        reset_str = datetime.fromtimestamp(reset_ts).isoformat() if reset_ts else "unknown"

        return {
            "limit": core.get("limit", 0),
            "remaining": core.get("remaining", 0),
            "reset": reset_str,
        }

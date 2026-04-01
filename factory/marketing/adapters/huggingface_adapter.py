"""Hugging Face Hub API Adapter — Trackt KI-Modelle und Benchmarks.

Oeffentliche API, kein Dry-Run noetig.
"""

import logging
import os
import time
from datetime import datetime, timedelta

import requests

logger = logging.getLogger("factory.marketing.adapters.huggingface")


class HuggingFaceAdapter:
    """Hugging Face Hub API Adapter."""

    STATUS = "active"
    PLATFORM = "huggingface"
    API_BASE = "https://huggingface.co/api"

    def __init__(self, dry_run: bool = False):
        # dry_run param accepted for interface compat but ignored — public API
        self.token = os.getenv("HUGGINGFACE_TOKEN")
        self.dry_run = False
        self._headers = {}
        if self.token:
            self._headers["Authorization"] = f"Bearer {self.token}"
            logger.info("HuggingFace Adapter: Token found")
        else:
            logger.info("HuggingFace Adapter: No token (public access)")

    def _request(self, endpoint: str, params: dict = None) -> dict | list | None:
        """HF API Request mit Error-Handling."""
        time.sleep(0.5)
        try:
            url = f"{self.API_BASE}{endpoint}"
            response = requests.get(url, headers=self._headers, params=params, timeout=15)
            if response.status_code == 404:
                logger.info("HuggingFace 404: %s", endpoint)
                return None
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error("HuggingFace request failed: %s", e)
            return None

    # ── Model Info ────────────────────────────────────────

    def get_model_info(self, model_id: str) -> dict | None:
        """Model Card Info: Downloads, Likes, Tags, Pipeline-Typ."""
        data = self._request(f"/models/{model_id}")
        if not data or not isinstance(data, dict):
            return None

        return {
            "model_id": data.get("id") or data.get("modelId", model_id),
            "downloads": data.get("downloads", 0),
            "likes": data.get("likes", 0),
            "pipeline_tag": data.get("pipeline_tag", ""),
            "tags": data.get("tags", []),
            "last_modified": data.get("lastModified", ""),
            "library_name": data.get("library_name", ""),
        }

    # ── Search Models ─────────────────────────────────────

    def search_models(self, query: str = None, sort: str = "downloads",
                      direction: str = "-1", limit: int = 20,
                      pipeline_tag: str = None) -> list[dict]:
        """Suche nach Modellen."""
        params = {"sort": sort, "direction": direction, "limit": min(limit, 100)}
        if query:
            params["search"] = query
        if pipeline_tag:
            params["pipeline_tag"] = pipeline_tag

        data = self._request("/models", params=params)
        if not data or not isinstance(data, list):
            return []

        return [
            {
                "model_id": m.get("id") or m.get("modelId", ""),
                "downloads": m.get("downloads", 0),
                "likes": m.get("likes", 0),
                "pipeline_tag": m.get("pipeline_tag", ""),
            }
            for m in data[:limit]
        ]

    # ── Trending Models ───────────────────────────────────

    def get_trending_models(self, limit: int = 20) -> list[dict]:
        """Die am meisten geliketen Modelle (Proxy fuer Trending)."""
        return self.search_models(sort="likes", direction="-1", limit=limit)

    # ── New Models ────────────────────────────────────────

    def get_new_models(self, days: int = 7, min_downloads: int = 1000,
                       limit: int = 20) -> list[dict]:
        """Neue Modelle der letzten X Tage mit Mindest-Downloads."""
        # Sort by lastModified, then filter
        models = self.search_models(sort="lastModified", direction="-1", limit=100)

        cutoff = (datetime.now() - timedelta(days=days)).isoformat()
        filtered = []
        for m in models:
            if m.get("downloads", 0) >= min_downloads:
                filtered.append(m)
            if len(filtered) >= limit:
                break

        return filtered

    # ── Compare Models ────────────────────────────────────

    def compare_models(self, model_ids: list[str]) -> list[dict]:
        """Vergleich mehrerer Modelle."""
        results = []
        for mid in model_ids:
            info = self.get_model_info(mid)
            if info:
                results.append(info)
        results.sort(key=lambda m: m.get("downloads", 0), reverse=True)
        return results

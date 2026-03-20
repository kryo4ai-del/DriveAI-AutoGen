"""Web Research Tool — Phase 1 Pre-Production Pipeline

Provides web search capabilities for research agents.
Uses SerpAPI with caching + direct URL fetching via BeautifulSoup.
"""

import os
import re

import requests
from bs4 import BeautifulSoup
from dotenv import load_dotenv

load_dotenv()

# --- Cache & Stats ---
_cache: dict[str, list[dict]] = {}
_stats = {"total_searches": 0, "cache_hits": 0}

SERPAPI_URL = "https://serpapi.com/search.json"
USER_AGENT = "DriveAI-Factory/1.0 (Research Bot)"


def search_web(query: str, num_results: int = 5) -> list[dict]:
    """Search the web via SerpAPI. Returns list of {title, link, snippet, source}."""
    cache_key = query.strip().lower()

    if cache_key in _cache:
        _stats["cache_hits"] += 1
        print(f"[WebResearch] Cache hit for: {query}")
        return _cache[cache_key]

    api_key = os.getenv("SERPAPI_API_KEY", "")
    if not api_key:
        print("[WebResearch] WARNING: SERPAPI_API_KEY not set — returning empty results")
        return []

    try:
        resp = requests.get(
            SERPAPI_URL,
            params={
                "q": query,
                "api_key": api_key,
                "engine": "google",
                "num": num_results,
            },
            timeout=15,
        )
        resp.raise_for_status()
        data = resp.json()
    except requests.RequestException as e:
        print(f"[WebResearch] ERROR: SerpAPI request failed — {e}")
        return []

    if "error" in data:
        print(f"[WebResearch] ERROR: SerpAPI returned error — {data['error']}")
        return []

    results = []
    for item in data.get("organic_results", [])[:num_results]:
        results.append({
            "title": item.get("title", ""),
            "link": item.get("link", ""),
            "snippet": item.get("snippet", ""),
            "source": item.get("source", ""),
        })

    _stats["total_searches"] += 1
    _cache[cache_key] = results
    return results


def fetch_url(url: str, max_chars: int = 8000) -> str:
    """Fetch and extract text content from a URL."""
    try:
        resp = requests.get(
            url,
            timeout=10,
            headers={"User-Agent": USER_AGENT},
        )
        resp.raise_for_status()
    except requests.RequestException as e:
        print(f"[WebResearch] WARNING: Failed to fetch {url} — {e}")
        return ""

    try:
        soup = BeautifulSoup(resp.text, "html.parser")
        tags = soup.find_all(["p", "h1", "h2", "h3", "h4", "h5", "h6", "li", "td"])
        text = " ".join(tag.get_text(strip=True) for tag in tags)
        text = re.sub(r"\s+", " ", text).strip()
        return text[:max_chars]
    except Exception as e:
        print(f"[WebResearch] WARNING: Failed to parse {url} — {e}")
        return ""


def search_and_fetch(query: str, num_results: int = 3, fetch_top_n: int = 2) -> dict:
    """Search, then fetch full content from top N results."""
    results = search_web(query, num_results=num_results)

    fetched_content = []
    for item in results[:fetch_top_n]:
        content = fetch_url(item["link"])
        fetched_content.append({
            "url": item["link"],
            "title": item["title"],
            "content": content,
        })

    return {
        "query": query,
        "results": results,
        "fetched_content": fetched_content,
    }


def get_search_stats() -> dict:
    """Return search statistics: total_searches, cache_hits, cache_size."""
    return {
        "total_searches": _stats["total_searches"],
        "cache_hits": _stats["cache_hits"],
        "cache_size": len(_cache),
    }

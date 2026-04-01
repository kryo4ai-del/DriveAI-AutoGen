"""TikTok Creative Center Scraper — Trending Sounds, Hashtags, Formate.

Dreistufiger Fallback: Scraping -> SerpAPI -> LLM-Schaetzung.
"""

import json
import logging
import os
import time
from datetime import datetime
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.tiktok_scraper")


class TikTokCreativeScraper:
    """Scrapet TikTok Creative Center fuer Trending-Daten."""

    CREATIVE_CENTER_URL = (
        "https://ads.tiktok.com/business/creativecenter/inspiration/popular/hashtag/"
    )
    SOUNDS_URL = (
        "https://ads.tiktok.com/business/creativecenter/inspiration/popular/music/"
    )

    def __init__(self):
        from factory.marketing.tools.ranking_database import RankingDatabase

        self.db = RankingDatabase()
        self._serpapi_available = bool(os.getenv("SERPAPI_API_KEY"))

    # ── Internal Helpers ──────────────────────────────────

    def _scrape_page(self, url: str) -> str | None:
        """Scrapet eine Seite mit Rate-Limiting und Error-Handling."""
        try:
            import requests

            headers = {
                "User-Agent": (
                    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
                    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
                ),
                "Accept-Language": "en-US,en;q=0.9",
            }
            time.sleep(5)  # Rate Limiting: 5 Sekunden
            response = requests.get(url, headers=headers, timeout=15)
            if response.status_code == 200:
                return response.text
            logger.warning("Scraping returned %d for %s", response.status_code, url)
            return None
        except Exception as e:
            logger.warning("Scraping failed: %s", e)
            return None

    def _serpapi_search(self, query: str) -> dict | None:
        """SerpAPI-Suche mit Fehlerbehandlung."""
        if not self._serpapi_available:
            return None
        try:
            import requests

            params = {
                "engine": "google",
                "q": query,
                "api_key": os.getenv("SERPAPI_API_KEY"),
                "num": 10,
            }
            time.sleep(1)
            response = requests.get("https://serpapi.com/search", params=params, timeout=15)
            if response.status_code == 429:
                logger.warning("SerpAPI rate limited")
                return None
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.warning("SerpAPI search failed: %s", e)
            return None

    def _call_llm(self, prompt: str, max_tokens: int = 2048) -> str:
        """LLM-Call. Tool-Level (kein Agent-ID)."""
        from dotenv import load_dotenv

        load_dotenv(Path(__file__).resolve().parents[3] / ".env")
        try:
            from factory.brain.model_provider import get_model, get_router

            selection = get_model(profile="standard", expected_output_tokens=max_tokens)
            router = get_router()
            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=[{"role": "user", "content": prompt}],
                max_tokens=max_tokens,
                temperature=1.0,
            )
            if response.error:
                raise RuntimeError(response.error)
            return response.content
        except Exception as e:
            logger.error("LLM call failed: %s", e)
            return ""

    def _parse_json_response(self, text: str) -> list:
        """Parst JSON aus LLM-Response."""
        text = text.strip()
        if "```json" in text:
            text = text.split("```json")[1].split("```")[0].strip()
        elif "```" in text:
            text = text.split("```")[1].split("```")[0].strip()
        try:
            data = json.loads(text)
            return data if isinstance(data, list) else [data]
        except json.JSONDecodeError:
            return []

    # ── Trending Hashtags ─────────────────────────────────

    def get_trending_hashtags(self, country: str = "US",
                              period: str = "7d") -> list[dict]:
        """Trending Hashtags abrufen. Dreistufiger Fallback."""
        # Stufe 1: Web-Scraping
        hashtags = self._scrape_hashtags(country, period)
        if hashtags:
            return hashtags

        # Stufe 2: SerpAPI
        hashtags = self._serpapi_hashtags(country)
        if hashtags:
            return hashtags

        # Stufe 3: LLM-Schaetzung
        return self._llm_hashtags(country)

    def _scrape_hashtags(self, country: str, period: str) -> list[dict]:
        """Stufe 1: TikTok Creative Center scrapen."""
        url = f"{self.CREATIVE_CENTER_URL}?countryCode={country}&period={period}"
        html = self._scrape_page(url)
        if not html:
            return []

        try:
            from bs4 import BeautifulSoup

            soup = BeautifulSoup(html, "html.parser")
            results = []

            # TikTok Creative Center uses various selectors
            # Try common patterns for hashtag cards
            cards = soup.select("[class*='hashtag'], [class*='CardPc'], [class*='trending']")
            if not cards:
                # Fallback: look for any structured data
                scripts = soup.select("script[type='application/json']")
                for script in scripts:
                    try:
                        data = json.loads(script.string)
                        if isinstance(data, list):
                            for item in data:
                                if isinstance(item, dict) and "hashtag" in str(item).lower():
                                    name = item.get("hashtag_name") or item.get("name", "")
                                    if name:
                                        results.append({
                                            "hashtag": name,
                                            "views": item.get("views") or item.get("video_views"),
                                            "source": "scraping",
                                        })
                    except (json.JSONDecodeError, TypeError):
                        continue

            for card in cards:
                name_el = card.select_one("[class*='name'], h3, span")
                view_el = card.select_one("[class*='view'], [class*='count']")
                if name_el:
                    name = name_el.get_text(strip=True).lstrip("#")
                    views = None
                    if view_el:
                        view_text = view_el.get_text(strip=True)
                        views = self._parse_view_count(view_text)
                    results.append({"hashtag": name, "views": views, "source": "scraping"})

            if results:
                logger.info("Scraped %d hashtags from TikTok Creative Center", len(results))
            return results
        except Exception as e:
            logger.warning("Hashtag scraping parse failed: %s", e)
            return []

    def _serpapi_hashtags(self, country: str) -> list[dict]:
        """Stufe 2: SerpAPI-Fallback."""
        data = self._serpapi_search(f"TikTok trending hashtags {country} 2026")
        if not data:
            return []

        results = []
        for r in data.get("organic_results", [])[:10]:
            title = r.get("title", "")
            snippet = r.get("snippet", "")
            # Extract hashtags from search results
            text = f"{title} {snippet}"
            import re

            tags = re.findall(r"#(\w+)", text)
            for tag in tags[:3]:
                if tag.lower() not in ("tiktok", "trending", "hashtag", "viral"):
                    results.append({"hashtag": tag, "views": None, "source": "serpapi"})

        # Deduplicate
        seen = set()
        unique = []
        for r in results:
            if r["hashtag"].lower() not in seen:
                seen.add(r["hashtag"].lower())
                unique.append(r)

        if unique:
            logger.info("Found %d hashtags via SerpAPI", len(unique))
        return unique

    def _llm_hashtags(self, country: str) -> list[dict]:
        """Stufe 3: LLM-Schaetzung."""
        prompt = (
            f"Was sind die aktuell wahrscheinlich trendenden TikTok Hashtags "
            f"im Bereich Tech/Gaming/AI fuer {country}? "
            f"Antworte NUR als JSON-Array: [{{\"hashtag\": \"...\", \"views_estimate\": 1000000}}]. "
            f"Gib 10 Hashtags."
        )
        response = self._call_llm(prompt, max_tokens=1024)
        if not response:
            return [{"hashtag": "AIGenerated", "views": None, "source": "llm_estimate"}]

        parsed = self._parse_json_response(response)
        return [
            {"hashtag": h.get("hashtag", "?"), "views": h.get("views_estimate"),
             "source": "llm_estimate"}
            for h in parsed
        ]

    # ── Trending Sounds ───────────────────────────────────

    def get_trending_sounds(self, country: str = "US") -> list[dict]:
        """Trending Sounds. Dreistufiger Fallback."""
        # Stufe 1: Scraping
        html = self._scrape_page(f"{self.SOUNDS_URL}?countryCode={country}&period=7")
        if html:
            sounds = self._parse_sounds_html(html)
            if sounds:
                return sounds

        # Stufe 2: SerpAPI
        data = self._serpapi_search(f"TikTok trending sounds music {country} 2026")
        if data:
            sounds = []
            for r in data.get("organic_results", [])[:5]:
                sounds.append({
                    "sound_name": r.get("title", "Unknown")[:60],
                    "artist": None,
                    "uses": None,
                    "source": "serpapi",
                })
            if sounds:
                return sounds

        # Stufe 3: LLM
        prompt = (
            f"Welche Sounds/Songs trenden gerade auf TikTok ({country})? "
            f"Fokus auf Tech/Gaming Content. "
            f"Antworte NUR als JSON-Array: [{{\"sound_name\": \"...\", \"artist\": \"...\", \"uses_estimate\": 50000}}]. "
            f"Gib 5 Sounds."
        )
        response = self._call_llm(prompt, max_tokens=1024)
        parsed = self._parse_json_response(response) if response else []
        if parsed:
            return [
                {"sound_name": s.get("sound_name", "?"), "artist": s.get("artist"),
                 "uses": s.get("uses_estimate"), "source": "llm_estimate"}
                for s in parsed
            ]
        return [{"sound_name": "Unknown", "artist": None, "uses": None, "source": "llm_estimate"}]

    def _parse_sounds_html(self, html: str) -> list[dict]:
        """Parst Sounds aus Creative Center HTML."""
        try:
            from bs4 import BeautifulSoup

            soup = BeautifulSoup(html, "html.parser")
            results = []
            cards = soup.select("[class*='music'], [class*='sound'], [class*='CardPc']")
            for card in cards:
                name_el = card.select_one("[class*='name'], [class*='title'], h3")
                artist_el = card.select_one("[class*='author'], [class*='artist']")
                if name_el:
                    results.append({
                        "sound_name": name_el.get_text(strip=True),
                        "artist": artist_el.get_text(strip=True) if artist_el else None,
                        "uses": None,
                        "source": "scraping",
                    })
            return results
        except Exception as e:
            logger.warning("Sound HTML parse failed: %s", e)
            return []

    # ── Trending Formats ──────────────────────────────────

    def get_trending_formats(self) -> list[dict]:
        """Welche Video-Formate gerade funktionieren. SerpAPI oder LLM."""
        # SerpAPI first
        data = self._serpapi_search("TikTok content format trends 2026 best performing")
        if data:
            results = []
            for r in data.get("organic_results", [])[:5]:
                results.append({
                    "format": r.get("title", "Unknown")[:60],
                    "description": r.get("snippet", "")[:200],
                    "relevance_for_factory": "check manually",
                    "source": "serpapi",
                })
            if results:
                return results

        # LLM
        prompt = (
            "Welche TikTok Video-Formate funktionieren aktuell am besten? "
            "Fokus auf App-Marketing und Tech Content. "
            "Antworte NUR als JSON-Array: "
            '[{"format": "...", "description": "...", "relevance_for_factory": "..."}]. '
            "Gib 5 Formate."
        )
        response = self._call_llm(prompt, max_tokens=1024)
        parsed = self._parse_json_response(response) if response else []
        return [
            {**f, "source": "llm_estimate"}
            for f in parsed
        ] or [{"format": "Short-form demo", "description": "App demo in 15-30s",
               "relevance_for_factory": "Ideal fuer App-Launches", "source": "llm_estimate"}]

    # ── Factory Evaluation ────────────────────────────────

    def evaluate_for_factory(self, trends: list[dict]) -> list[dict]:
        """LLM bewertet welche TikTok-Trends die Factory nutzen koennte."""
        if not trends:
            return []

        trend_text = json.dumps(trends[:20], ensure_ascii=False, default=str)
        prompt = (
            f"Du bist Marketing-Berater fuer die DriveAI Factory (autonome KI-App-Fabrik). "
            f"Bewerte diese TikTok-Trends:\n{trend_text}\n\n"
            f"Antworte NUR als JSON-Array: "
            f'[{{"trend": "...", "usable": true/false, "suggestion": "...", "priority": "high/medium/low"}}]'
        )

        response = self._call_llm(prompt, max_tokens=2048)
        if not response:
            # Fallback: mark all as medium priority
            return [{"trend": str(t), "usable": True, "suggestion": "Pruefen",
                      "priority": "medium"} for t in trends[:5]]

        return self._parse_json_response(response) or []

    # ── Full Scan ─────────────────────────────────────────

    def run_full_scan(self) -> dict:
        """Fuehrt alle Scans durch und speichert in DB."""
        hashtags = self.get_trending_hashtags("US")
        sounds = self.get_trending_sounds("US")
        formats = self.get_trending_formats()

        # Evaluate
        all_trends = (
            [{"type": "hashtag", **h} for h in hashtags] +
            [{"type": "sound", **s} for s in sounds] +
            [{"type": "format", **f} for f in formats]
        )
        evaluation = self.evaluate_for_factory(all_trends)

        # Store in DB as trends
        stored = 0
        for h in hashtags:
            try:
                self.db.store_trend(
                    source="tiktok",
                    topic=f"#{h.get('hashtag', '?')}",
                    description=f"Views: {h.get('views', 'N/A')}",
                    relevance_score=5.0,  # Default — evaluation refines this
                )
                stored += 1
            except Exception:
                pass

        sources_used = list({
            item.get("source", "unknown")
            for item in hashtags + sounds + formats
        })

        return {
            "hashtags": hashtags,
            "sounds": sounds,
            "formats": formats,
            "factory_evaluation": evaluation,
            "sources_used": sources_used,
            "stored_in_db": stored,
        }

    # ── Util ──────────────────────────────────────────────

    @staticmethod
    def _parse_view_count(text: str) -> int | None:
        """Parst View-Counts wie '1.2B', '500K', '1M'."""
        if not text:
            return None
        text = text.strip().upper().replace(",", "")
        try:
            if text.endswith("B"):
                return int(float(text[:-1]) * 1_000_000_000)
            elif text.endswith("M"):
                return int(float(text[:-1]) * 1_000_000)
            elif text.endswith("K"):
                return int(float(text[:-1]) * 1_000)
            return int(float(text))
        except (ValueError, IndexError):
            return None

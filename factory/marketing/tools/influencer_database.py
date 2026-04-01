"""Influencer-Verwaltung mit automatischer Recherche.

KEIN automatischer Outreach-Versand. Agent erstellt Nachricht, CEO entscheidet.
"""

import json
import logging
import os
import time
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.influencer_database")


class InfluencerDatabase:
    """Influencer-Verwaltung mit automatischer Recherche."""

    def __init__(self):
        from factory.marketing.tools.ranking_database import RankingDatabase
        from factory.marketing.alerts.alert_manager import MarketingAlertManager

        self.db = RankingDatabase()
        self.alerts = MarketingAlertManager()
        self._serpapi_available = bool(os.getenv("SERPAPI_API_KEY"))

    # ── CRUD ──────────────────────────────────────────────

    def add_influencer(self, name: str, platform: str, handle: str = None,
                       followers: int = 0, topics: str = None,
                       tier: str = None, country: str = "US",
                       language: str = "en") -> int:
        """Influencer hinzufuegen. Tier wird automatisch berechnet."""
        if tier is None:
            tier = self._calc_tier(followers)
        return self.db.store_influencer(
            name=name, platform=platform, handle=handle,
            followers=followers, topics=topics, tier=tier,
            country=country, language=language,
        )

    @staticmethod
    def _calc_tier(followers: int) -> str:
        """macro (100k+), micro (10k-100k), nano (1k-10k), sub-nano (<1k)."""
        if followers >= 100000:
            return "macro"
        if followers >= 10000:
            return "micro"
        if followers >= 1000:
            return "nano"
        return "nano"

    def search_influencers(self, platform: str = None, topic: str = None,
                           tier: str = None, country: str = None,
                           status: str = None) -> list[dict]:
        """Filter."""
        return self.db.search_influencers(
            platform=platform, topic=topic, tier=tier,
            country=country, status=status,
        )

    def update_influencer(self, influencer_id: int, **fields) -> bool:
        """Felder aktualisieren."""
        return self.db.update_influencer(influencer_id, **fields)

    def get_influencer_stats(self) -> dict:
        """Uebersicht nach Tier, Plattform, Status."""
        return self.db.get_influencer_stats()

    # ── Auto Discover ─────────────────────────────────────

    def auto_discover(self, topic: str, platform: str = "youtube",
                      limit: int = 20) -> list[dict]:
        """Automatische Recherche. Ergebnisse als Vorschlaege, NICHT in DB."""
        if self._serpapi_available:
            results = self._serpapi_discover(topic, platform, limit)
            if results:
                return results

        return self._llm_discover(topic, platform, limit)

    def _serpapi_discover(self, topic: str, platform: str,
                         limit: int) -> list[dict]:
        """SerpAPI-basierte Influencer-Recherche."""
        try:
            import requests

            platform_map = {
                "youtube": f"top {topic} youtube channels 2026",
                "x": f"top {topic} accounts twitter X 2026",
                "tiktok": f"best {topic} tiktok creators 2026",
            }
            query = platform_map.get(platform, f"best {topic} influencers {platform} 2026")

            params = {
                "engine": "google",
                "q": query,
                "api_key": os.getenv("SERPAPI_API_KEY"),
                "num": 10,
            }
            time.sleep(1)
            response = requests.get(
                "https://serpapi.com/search", params=params, timeout=15,
            )
            if response.status_code != 200:
                return []

            data = response.json()
            results = []
            for r in data.get("organic_results", [])[:limit]:
                title = r.get("title", "")
                results.append({
                    "name": title[:60],
                    "platform": platform,
                    "handle": "",
                    "followers_estimate": 0,
                    "relevance": "discovered via search",
                    "source": "serpapi",
                })
            return results
        except Exception as e:
            logger.warning("SerpAPI influencer discovery failed: %s", e)
            return []

    def _llm_discover(self, topic: str, platform: str,
                      limit: int) -> list[dict]:
        """LLM-basierte Influencer-Recherche."""
        from dotenv import load_dotenv

        load_dotenv(Path(__file__).resolve().parents[3] / ".env")
        try:
            from factory.brain.model_provider import get_model, get_router

            selection = get_model(profile="standard", expected_output_tokens=1024)
            router = get_router()

            prompt = (
                f"Liste {limit} bekannte {platform} Influencer/Creators "
                f"die ueber '{topic}' posten. "
                "Antworte NUR als JSON-Array: "
                '[{"name": "...", "platform": "' + platform + '", "handle": "@...", '
                '"followers_estimate": 0, "relevance": "..."}]'
            )

            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=[{"role": "user", "content": prompt}],
                max_tokens=1024,
                temperature=1.0,
            )
            if response.error:
                raise RuntimeError(response.error)

            text = response.content.strip()
            if "```json" in text:
                text = text.split("```json")[1].split("```")[0].strip()
            elif "```" in text:
                text = text.split("```")[1].split("```")[0].strip()
            results = json.loads(text)
            for r in results:
                r["source"] = "llm"
            return results[:limit]
        except Exception as e:
            logger.warning("LLM influencer discovery failed: %s", e)
            # Ultimate fallback
            return [
                {"name": f"{topic} Creator", "platform": platform,
                 "handle": "", "followers_estimate": 0,
                 "relevance": "LLM fallback", "source": "fallback"},
            ]

    # ── Track Mentions ────────────────────────────────────

    def track_mentions(self, influencer_name: str) -> list[dict]:
        """Prueft ob der Influencer ueber die Factory gepostet hat."""
        if not self._serpapi_available:
            return []

        try:
            import requests

            query = f'"{influencer_name}" "DriveAI"'
            params = {
                "engine": "google",
                "q": query,
                "api_key": os.getenv("SERPAPI_API_KEY"),
                "num": 5,
            }
            time.sleep(1)
            response = requests.get(
                "https://serpapi.com/search", params=params, timeout=15,
            )
            if response.status_code != 200:
                return []

            data = response.json()
            mentions = []
            for r in data.get("organic_results", []):
                mention = {
                    "url": r.get("link", ""),
                    "context": r.get("snippet", "")[:200],
                    "date": r.get("date", ""),
                }
                mentions.append(mention)

            if mentions:
                self.alerts.create_alert(
                    type="info",
                    priority="medium",
                    category="community",
                    source_agent="InfluencerDatabase",
                    title=f"Organische Erwaehnung: {influencer_name}",
                    description=f"{len(mentions)} Erwaehnung(en) von {influencer_name} gefunden",
                )

            return mentions
        except Exception as e:
            logger.warning("Track mentions failed for %s: %s", influencer_name, e)
            return []

    # ── Outreach Brief ────────────────────────────────────

    def create_outreach_brief(self, influencer_id: int) -> str:
        """LLM erstellt personalisierte Outreach-Nachricht. NICHT automatisch gesendet."""
        influencers = self.db.search_influencers(limit=500)
        inf = next((i for i in influencers if i.get("id") == influencer_id), None)
        if not inf:
            return "Influencer nicht gefunden."

        from dotenv import load_dotenv

        load_dotenv(Path(__file__).resolve().parents[3] / ".env")
        try:
            from factory.brain.model_provider import get_model, get_router

            selection = get_model(profile="standard", expected_output_tokens=1024)
            router = get_router()

            prompt = (
                f"Schreibe eine personalisierte Outreach-Nachricht an {inf['name']} "
                f"({inf.get('handle', '?')}) der ueber {inf.get('topics', 'Tech')} "
                f"auf {inf['platform']} postet ({inf.get('followers', 0)} Follower). "
                "Die DriveAI Factory (108 KI-Agents, autonome App-Entwicklung) "
                "will eine Zusammenarbeit anbieten. "
                "Ton: authentisch, kein Spam, zeige echtes Interesse. "
                "Halte es kurz (5-8 Saetze). Markdown-Format."
            )

            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=[{"role": "user", "content": prompt}],
                max_tokens=1024,
                temperature=1.0,
            )
            if response.error:
                raise RuntimeError(response.error)
            return response.content
        except Exception as e:
            logger.error("Outreach brief failed: %s", e)
            return (
                f"# Outreach: {inf['name']}\n\n"
                f"Hi {inf['name']},\n\n"
                "Wir bei DAI-Core haben eine KI-Factory mit 108 Agents gebaut, "
                "die autonom Apps entwickelt. Wuerde gerne mit dir darueber sprechen.\n\n"
                "Beste Gruesse,\nDriveAI Team"
            )

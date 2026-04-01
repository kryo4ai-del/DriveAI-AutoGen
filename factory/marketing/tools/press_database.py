"""Presse-Kontakt-Verwaltung — Outlets, Journalisten, Newsletter.

KEINE echten Email-Adressen automatisch scrapen.
Seed-Daten enthalten nur Outlet-Namen und Kategorien.
"""

import json
import logging
import os
import time
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.press_database")


class PressDatabase:
    """Presse-Kontakt-Verwaltung."""

    def __init__(self):
        from factory.marketing.tools.ranking_database import RankingDatabase

        self.db = RankingDatabase()
        self._serpapi_available = bool(os.getenv("SERPAPI_API_KEY"))

    # ── CRUD ──────────────────────────────────────────────

    def add_contact(self, name: str, outlet: str, email: str = None,
                    role: str = "journalist", topics: str = None,
                    reach_estimate: int = None, country: str = "US",
                    language: str = "en") -> int:
        """Kontakt hinzufuegen. Returns: contact_id."""
        return self.db.store_press_contact(
            name=name, outlet=outlet, email=email, role=role,
            topics=topics, reach_estimate=reach_estimate,
            country=country, language=language,
        )

    def search_contacts(self, topic: str = None, country: str = None,
                        role: str = None, status: str = None) -> list[dict]:
        """Kontakte filtern."""
        return self.db.search_press_contacts(
            topic=topic, country=country, role=role, status=status,
        )

    def get_distribution_list(self, topic: str, countries: list[str] = None,
                              min_reach: int = None) -> list[dict]:
        """Erstellt Verteiler-Liste fuer eine PM."""
        contacts = self.db.search_press_contacts(topic=topic)

        if countries:
            contacts = [c for c in contacts if c.get("country") in countries]
        if min_reach:
            contacts = [c for c in contacts
                        if (c.get("reach_estimate") or 0) >= min_reach]

        return contacts

    def update_contact_status(self, contact_id: int, status: str,
                              notes: str = None) -> bool:
        """Status aktualisieren."""
        return self.db.update_press_contact_status(contact_id, status, notes)

    def get_contact_stats(self) -> dict:
        """Uebersicht: Anzahl nach Status, Land, Rolle."""
        return self.db.get_press_contact_stats()

    def export_for_outreach(self, contact_ids: list[int]) -> list[dict]:
        """Export fuer SMTP-Adapter."""
        all_contacts = self.db.search_press_contacts(limit=500)
        return [c for c in all_contacts if c.get("id") in contact_ids]

    # ── Auto Research ─────────────────────────────────────

    def auto_research_contacts(self, topic: str, country: str = "US",
                               limit: int = 20) -> list[dict]:
        """SerpAPI-Suche nach relevanten Tech-Outlets.

        KEINE Email-Adressen automatisch scrapen.
        Ergebnisse als Vorschlaege (nicht automatisch in DB).
        """
        if self._serpapi_available:
            results = self._serpapi_research(topic, country, limit)
            if results:
                return results

        # LLM Fallback
        results = self._llm_research(topic, country, limit)
        if results:
            return results

        # Ultimate fallback — known outlets
        return self._known_outlets_fallback(topic, country, limit)

    def _serpapi_research(self, topic: str, country: str,
                         limit: int) -> list[dict]:
        """SerpAPI-basierte Recherche."""
        try:
            import requests

            query = f"best {topic} tech journalists {country} 2026"
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
                snippet = r.get("snippet", "")
                results.append({
                    "name": title[:60],
                    "outlet": title.split("-")[-1].strip() if "-" in title else title[:40],
                    "role": "journalist",
                    "topics": topic,
                    "source": "serpapi",
                })
            return results
        except Exception as e:
            logger.warning("SerpAPI press research failed: %s", e)
            return []

    def _llm_research(self, topic: str, country: str,
                      limit: int) -> list[dict]:
        """LLM-basierte Liste bekannter Outlets."""
        from dotenv import load_dotenv

        load_dotenv(Path(__file__).resolve().parents[3] / ".env")
        try:
            from factory.brain.model_provider import get_model, get_router

            selection = get_model(profile="standard", expected_output_tokens=1024)
            router = get_router()

            prompt = (
                f"Liste {limit} bekannte Tech/AI-Journalisten oder Outlets in {country} "
                f"die ueber '{topic}' schreiben. "
                "Antworte NUR als JSON-Array: "
                '[{"name": "Redakteur-Name oder Outlet", "outlet": "Outlet-Name", '
                '"role": "journalist|editor|blogger|newsletter", "topics": "Kommasepariert"}]\n'
                "KEINE Email-Adressen generieren."
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
                r.pop("email", None)  # Safety: remove if LLM hallucinated
            return results[:limit]
        except Exception as e:
            logger.warning("LLM press research failed: %s", e)
            return []

    @staticmethod
    def _known_outlets_fallback(topic: str, country: str,
                                limit: int) -> list[dict]:
        """Hardcoded Fallback bekannter Outlets."""
        outlets = [
            {"name": "TechCrunch AI Team", "outlet": "TechCrunch", "role": "journalist", "topics": "AI,startups", "source": "fallback"},
            {"name": "VentureBeat AI", "outlet": "VentureBeat", "role": "journalist", "topics": "AI,enterprise", "source": "fallback"},
            {"name": "The Verge Tech", "outlet": "The Verge", "role": "editor", "topics": "AI,technology", "source": "fallback"},
            {"name": "Wired AI Coverage", "outlet": "Wired", "role": "journalist", "topics": "AI,technology", "source": "fallback"},
            {"name": "MIT Tech Review", "outlet": "MIT Technology Review", "role": "editor", "topics": "AI,research", "source": "fallback"},
        ]
        return outlets[:limit]

    # ── Seed ──────────────────────────────────────────────

    def seed_initial_contacts(self) -> int:
        """Initiale Seed-Daten. OHNE echte Email-Adressen."""
        seed_data = [
            # US Tech
            {"name": "TechCrunch Editorial", "outlet": "TechCrunch", "role": "editor", "topics": "AI,startups,apps", "reach_estimate": 5000000, "country": "US", "language": "en"},
            {"name": "The Verge Staff", "outlet": "The Verge", "role": "editor", "topics": "AI,technology,apps", "reach_estimate": 4000000, "country": "US", "language": "en"},
            {"name": "Ars Technica Staff", "outlet": "Ars Technica", "role": "editor", "topics": "AI,technology,science", "reach_estimate": 3000000, "country": "US", "language": "en"},
            {"name": "Wired Editorial", "outlet": "Wired", "role": "editor", "topics": "AI,technology,culture", "reach_estimate": 4500000, "country": "US", "language": "en"},
            {"name": "VentureBeat AI Team", "outlet": "VentureBeat", "role": "journalist", "topics": "AI,enterprise,startups", "reach_estimate": 2000000, "country": "US", "language": "en"},
            {"name": "MIT Technology Review", "outlet": "MIT Technology Review", "role": "editor", "topics": "AI,research,technology", "reach_estimate": 3000000, "country": "US", "language": "en"},
            {"name": "The Information Staff", "outlet": "The Information", "role": "journalist", "topics": "AI,startups,enterprise", "reach_estimate": 500000, "country": "US", "language": "en"},
            # DACH
            {"name": "Heise Redaktion", "outlet": "Heise Online", "role": "editor", "topics": "AI,technology,software", "reach_estimate": 2000000, "country": "DE", "language": "de"},
            {"name": "Golem.de Redaktion", "outlet": "Golem.de", "role": "editor", "topics": "AI,technology,gaming", "reach_estimate": 1500000, "country": "DE", "language": "de"},
            {"name": "t3n Redaktion", "outlet": "t3n", "role": "editor", "topics": "AI,startups,digital", "reach_estimate": 1000000, "country": "DE", "language": "de"},
            {"name": "Der Standard Tech", "outlet": "Der Standard", "role": "journalist", "topics": "AI,technology", "reach_estimate": 800000, "country": "AT", "language": "de"},
            # AI-Specific Newsletters
            {"name": "Import AI", "outlet": "Import AI Newsletter", "role": "newsletter", "topics": "AI,research,policy", "reach_estimate": 100000, "country": "US", "language": "en"},
            {"name": "The Batch (Andrew Ng)", "outlet": "The Batch / DeepLearning.AI", "role": "newsletter", "topics": "AI,ML,research", "reach_estimate": 500000, "country": "US", "language": "en"},
            {"name": "Ben's Bites", "outlet": "Ben's Bites", "role": "newsletter", "topics": "AI,startups,tools", "reach_estimate": 200000, "country": "US", "language": "en"},
            {"name": "TLDR AI", "outlet": "TLDR Newsletter", "role": "newsletter", "topics": "AI,technology", "reach_estimate": 300000, "country": "US", "language": "en"},
        ]

        count = 0
        for entry in seed_data:
            self.db.store_press_contact(**entry)
            count += 1

        logger.info("Seeded %d press contacts", count)
        return count

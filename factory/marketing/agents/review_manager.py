"""Review Manager (MKT-10) — Zwei-Stufen-System fuer App Store Reviews.

KRITISCH: Die Stufen-Entscheidung ist eine HARTE Logik basierend auf Rating/Keywords.
NICHT eine LLM-Einschaetzung.

Stufe 1 (autonom): Positive/neutrale Reviews (Rating >= 4, keine Negativ-Keywords)
  → Agent antwortet selbstaendig via LLM

Stufe 2 (CEO-Gate): Negative/kritische Reviews (Rating <= 2, oder Negativ-Keywords)
  → Agent erstellt Gate-Anfrage, antwortet NICHT
"""

import json
import logging
import os
import re
from datetime import datetime
from pathlib import Path
from typing import Optional

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.review_manager")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Review Manager der DriveAI Factory Marketing-Abteilung (MKT-10).

IDENTITAET:
Die Factory IST das Produkt. Du bist die Stimme der Factory gegenueber App-Nutzern.

AUFGABE:
Du beantwortest App Store Reviews. ABER NUR positive/neutrale (Stufe 1).
Negative/kritische Reviews beantwortest du NICHT — dafuer erstellst du eine CEO-Gate-Anfrage.

TON:
- Freundlich, professionell, authentisch
- Danke fuer Feedback (echt gemeint, nicht formuliermaessig)
- Bei Feature-Requests: "Tolles Feedback, wir nehmen das auf"
- Bei Bugs: "Danke fuer den Hinweis, wir schauen uns das an"
- Nie defensiv, nie aggressiv
- Factory-Perspektive: "Unser Team arbeitet staendig an Verbesserungen"

ANTWORT-LAENGE:
- App Store: 2-4 Saetze (Apple-Richtlinien)
- Google Play: 2-5 Saetze (mehr Spielraum)

REGELN:
- Antworte immer auf Deutsch
- Nenne den Nutzer beim Vornamen wenn vorhanden
- Keine Plattituden wie "Wir schaetzen Ihr Feedback sehr"
- Konkret eingehen auf das was der Nutzer sagt
- Nie Versprechungen machen die nicht gehalten werden koennen
"""

# --- Zwei-Stufen-Logik (HARD, kein LLM) ---

# Keywords die Stufe 2 (CEO-Gate) triggern
TIER2_KEYWORDS = [
    # Negativ / Kritisch
    "betrug", "scam", "abzocke", "diebstahl", "luege", "fake",
    "funktioniert nicht", "crashes", "abstuerz", "absturz",
    "geld zurueck", "refund", "erstattung",
    "datenschutz", "privacy", "daten gestohlen", "daten verkauft",
    "anwalt", "rechtsanwalt", "klage", "verklagen",
    "gefaehrlich", "unsicher",
    # Kontrovers
    "diskriminier", "rassist", "sexist",
    "politisch", "propaganda",
    # Wettbewerb-Referenz
    "besser als", "wechsle zu", "alternative",
]


class ReviewManager:
    """Zwei-Stufen-System fuer App Store Reviews."""

    def __init__(self, alert_base_path: str = None) -> None:
        from factory.marketing.config import OUTPUT_PATH

        self.output_path = OUTPUT_PATH
        self.agent_info = self._load_persona()
        self._alert_base_path = alert_base_path
        self._alerts = None
        logger.info("ReviewManager initialized")

    @property
    def alerts(self):
        """Lazy-load AlertManager."""
        if self._alerts is None:
            from factory.marketing.alerts.alert_manager import MarketingAlertManager
            self._alerts = MarketingAlertManager(base_path=self._alert_base_path)
        return self._alerts

    def _load_persona(self) -> dict:
        """Laedt das eigene Persona-File."""
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_review_manager.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-10", "name": "Review Manager"}

    def _call_llm(self, prompt: str, system_msg: str = None, max_tokens: int = 4096) -> str:
        """LLM-Call ueber TheBrain ProviderRouter mit Anthropic-Fallback."""
        if system_msg is None:
            system_msg = SYSTEM_MESSAGE
        try:
            from config.model_router import get_model_for_agent
            from factory.brain.model_provider import get_model, get_router

            agent_id = self.agent_info.get("id", "MKT-10")
            agent_model = get_model_for_agent(agent_id)
            selection = get_model(profile="standard", expected_output_tokens=max_tokens)
            if agent_model and agent_model != selection.get("model"):
                selection["model"] = agent_model
                for _pfx, _prov in [("claude", "anthropic"), ("o3", "openai"),
                                    ("gpt", "openai"), ("gemini", "google"), ("mistral", "mistral")]:
                    if _pfx in agent_model:
                        selection["provider"] = _prov
                        break
            router = get_router()
            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=[
                    {"role": "system", "content": system_msg},
                    {"role": "user", "content": prompt},
                ],
                max_tokens=max_tokens,
                temperature=0.8,
            )
            if response.error:
                raise RuntimeError(response.error)
            cost_str = f", Cost: ${response.cost_usd:.4f}" if response.cost_usd else ""
            logger.info("LLM: %s (%s)%s", selection["model"], selection["provider"], cost_str)
            return response.content
        except ImportError:
            logger.warning("TheBrain not available, trying Anthropic fallback")
            try:
                import anthropic
                from factory.marketing.config import get_fallback_model
                client = anthropic.Anthropic()
                response = client.messages.create(
                    model=get_fallback_model(),
                    max_tokens=max_tokens,
                    system=system_msg,
                    messages=[{"role": "user", "content": prompt}],
                )
                return response.content[0].text
            except Exception as e:
                logger.error("LLM call failed (fallback): %s", e)
                return ""
        except Exception as e:
            logger.error("LLM call failed: %s", e)
            return ""

    # ── Stufen-Logik (HARD, deterministisch) ──────────────────

    def classify_review(self, review: dict) -> dict:
        """Klassifiziert eine Review deterministisch in Stufe 1 oder 2.

        HARD LOGIC — kein LLM:
        - Rating <= 2 → Stufe 2 (CEO-Gate)
        - Rating == 3 + Negativ-Keywords → Stufe 2
        - Negativ-Keywords (unabhaengig vom Rating) → Stufe 2
        - Alles andere → Stufe 1 (autonom)

        Args:
            review: {"rating": int, "title": str, "body": str, "author": str, ...}

        Returns: {
            "tier": 1 | 2,
            "reason": str,
            "triggers": list[str],  # Welche Keywords/Regeln getriggert haben
        }
        """
        rating = review.get("rating", 3)
        title = (review.get("title") or "").lower()
        body = (review.get("body") or "").lower()
        text = f"{title} {body}"

        triggers = []

        # Regel 1: Rating <= 2 → immer Stufe 2
        if rating <= 2:
            triggers.append(f"rating={rating}")

        # Regel 2: Negativ-Keywords checken
        for kw in TIER2_KEYWORDS:
            if kw in text:
                triggers.append(f"keyword:{kw}")

        # Entscheidung
        if triggers:
            # Rating 3 ohne Keywords: Stufe 1 (neutral)
            if rating == 3 and not any(t.startswith("keyword:") for t in triggers):
                return {
                    "tier": 1,
                    "reason": "Neutrale Review (Rating 3, keine Negativ-Keywords)",
                    "triggers": [],
                }
            return {
                "tier": 2,
                "reason": f"CEO-Gate erforderlich: {', '.join(triggers[:3])}",
                "triggers": triggers,
            }

        return {
            "tier": 1,
            "reason": f"Positive/neutrale Review (Rating {rating})",
            "triggers": [],
        }

    def process_review(self, review: dict, store: str = "app_store") -> dict:
        """Verarbeitet eine einzelne Review durch das Zwei-Stufen-System.

        Args:
            review: {"id": str, "rating": int, "title": str, "body": str, "author": str}
            store: "app_store" oder "google_play"

        Returns: {
            "review_id": str,
            "tier": 1 | 2,
            "classification": dict,
            "action": "responded" | "gate_created",
            "response": str | None,  (nur bei Stufe 1)
            "gate_id": str | None,   (nur bei Stufe 2)
        }
        """
        classification = self.classify_review(review)
        result = {
            "review_id": review.get("id", "unknown"),
            "tier": classification["tier"],
            "classification": classification,
            "action": "",
            "response": None,
            "gate_id": None,
        }

        if classification["tier"] == 1:
            # Stufe 1: Autonom antworten via LLM
            response = self._generate_response(review, store)
            result["action"] = "responded"
            result["response"] = response
            logger.info("Tier 1: Auto-responded to review %s (Rating %s)",
                        review.get("id"), review.get("rating"))
        else:
            # Stufe 2: CEO-Gate erstellen, NICHT antworten
            gate_id = self._create_review_gate(review, classification, store)
            result["action"] = "gate_created"
            result["gate_id"] = gate_id
            logger.info("Tier 2: Gate created %s for review %s (Rating %s, triggers: %s)",
                        gate_id, review.get("id"), review.get("rating"),
                        classification["triggers"][:3])

        return result

    def process_batch(self, reviews: list[dict], store: str = "app_store") -> dict:
        """Verarbeitet einen Batch von Reviews.

        Returns: {
            "total": int,
            "tier1_count": int,
            "tier2_count": int,
            "results": list[dict],
            "gates_created": int,
        }
        """
        results = []
        tier1 = 0
        tier2 = 0
        gates = 0

        for review in reviews:
            r = self.process_review(review, store)
            results.append(r)
            if r["tier"] == 1:
                tier1 += 1
            else:
                tier2 += 1
                if r["gate_id"]:
                    gates += 1

        return {
            "total": len(reviews),
            "tier1_count": tier1,
            "tier2_count": tier2,
            "results": results,
            "gates_created": gates,
        }

    def _generate_response(self, review: dict, store: str) -> str:
        """Generiert eine Antwort via LLM (nur Stufe 1)."""
        max_len = "2-4 Saetze" if store == "app_store" else "2-5 Saetze"

        prompt = f"""Schreibe eine Antwort auf diese App Store Review:

Store: {store}
Rating: {review.get('rating')}/5 ⭐
Titel: {review.get('title', 'Kein Titel')}
Text: {review.get('body', '')}
Autor: {review.get('author', 'Unbekannt')}

Regeln:
- Maximal {max_len}
- Auf Deutsch
- Nenne den Autor beim Vornamen wenn moeglich
- Geh konkret auf den Inhalt ein
- Kein "Wir schaetzen Ihr Feedback sehr"
- Freundlich und authentisch

Antworte NUR mit dem Antworttext, keine Erklaerung drumherum."""

        return self._call_llm(prompt, max_tokens=1024)

    def _create_review_gate(self, review: dict, classification: dict, store: str) -> str:
        """Erstellt eine CEO-Gate-Anfrage fuer eine Stufe-2-Review."""
        try:
            gate_id = self.alerts.create_gate_request(
                source_agent="MKT-10",
                title=f"Review Gate: {review.get('title', 'Kein Titel')[:50]}",
                description=(
                    f"Store: {store}\n"
                    f"Rating: {review.get('rating')}/5\n"
                    f"Autor: {review.get('author', 'Unbekannt')}\n"
                    f"Titel: {review.get('title', 'Kein Titel')}\n"
                    f"Text: {review.get('body', '')}\n\n"
                    f"Triggers: {', '.join(classification['triggers'][:5])}\n"
                    f"Grund: {classification['reason']}"
                ),
                options=[
                    {"label": "Antworten", "description": "Review mit vorgeschlagener Antwort beantworten"},
                    {"label": "Ignorieren", "description": "Review nicht beantworten"},
                    {"label": "Eskalieren", "description": "An uebergeordnete Stelle weiterleiten"},
                ],
            )
            return gate_id
        except Exception as e:
            logger.error("Failed to create gate request: %s", e)
            return ""

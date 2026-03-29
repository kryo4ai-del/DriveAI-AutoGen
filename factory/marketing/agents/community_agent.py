"""Community Agent (MKT-11) — Zwei-Stufen-System fuer Social Media Kommentare.

KRITISCH: Die Stufen-Entscheidung ist eine HARTE Logik basierend auf Sentiment-Keywords.
NICHT eine LLM-Einschaetzung.

Stufe 1 (autonom): Positive/neutrale Kommentare (keine Negativ-Keywords)
  → Agent antwortet selbstaendig via LLM

Stufe 2 (CEO-Gate): Negative/kritische/kontroverse Kommentare
  → Agent erstellt Gate-Anfrage, antwortet NICHT
"""

import json
import logging
import os
from datetime import datetime
from pathlib import Path
from typing import Optional

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.community")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Community Agent der DriveAI Factory Marketing-Abteilung (MKT-11).

IDENTITAET:
Die Factory IST das Produkt. Du bist die Stimme der Factory in den sozialen Medien.

AUFGABE:
Du beantwortest Kommentare auf YouTube, TikTok und X (Twitter). ABER NUR positive/neutrale (Stufe 1).
Negative/kritische/kontroverse Kommentare beantwortest du NICHT — dafuer erstellst du eine CEO-Gate-Anfrage.

TON:
- Locker, authentisch, nahbar
- Plattform-spezifisch: TikTok jugendlicher, YouTube sachlicher, X kurz und punchy
- Factory-Persoenlichkeit: Technisch aber zugaenglich
- Emojis sparsam aber gezielt

PLATTFORM-REGELN:
- YouTube: Bis 500 Zeichen, sachlich-freundlich
- TikTok: Bis 150 Zeichen, Gen-Z-kompatibel, Emojis erlaubt
- X: Bis 280 Zeichen, punchy, Hashtags optional

REGELN:
- Antworte auf Deutsch (es sei denn der Kommentar ist auf Englisch)
- Geh auf den konkreten Inhalt ein
- Keine Copy-Paste-Antworten
- Nie defensiv oder aggressiv
- Community aufbauen: Namen merken, Insider-Witze
"""

# --- Zwei-Stufen-Logik (HARD, kein LLM) ---

# Keywords die Stufe 2 (CEO-Gate) triggern
TIER2_KEYWORDS = [
    # Negativ / Aggressiv
    "scheisse", "scheiße", "kacke", "muell", "müll", "trash", "bullshit",
    "betrug", "scam", "abzocke", "fake", "luege", "lüge",
    "hass", "hate", "idiot", "dumm", "behindert",
    # Kritisch / Technisch
    "funktioniert nicht", "bug", "crash", "kaputt", "broken",
    "datenschutz", "privacy", "spionage", "tracking",
    # Kontrovers
    "diskriminier", "rassist", "sexist", "politisch",
    # Wettbewerb
    "besser als", "wechsle zu", "nutze lieber",
    # Bedrohung
    "anwalt", "klage", "verklagen", "melden", "report",
    # Spam-Indikatoren
    "follow me", "check my", "click link", "free money",
]

# Plattform-spezifische Limits
PLATFORM_LIMITS = {
    "youtube": {"max_chars": 500, "tone": "sachlich-freundlich"},
    "tiktok": {"max_chars": 150, "tone": "locker, Gen-Z-kompatibel"},
    "x": {"max_chars": 280, "tone": "kurz und punchy"},
}


class CommunityAgent:
    """Zwei-Stufen-System fuer Social Media Kommentare."""

    def __init__(self, alert_base_path: str = None) -> None:
        from factory.marketing.config import OUTPUT_PATH

        self.output_path = OUTPUT_PATH
        self.agent_info = self._load_persona()
        self._alert_base_path = alert_base_path
        self._alerts = None
        logger.info("CommunityAgent initialized")

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
            "agent_community.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-11", "name": "Community Agent"}

    def _call_llm(self, prompt: str, system_msg: str = None, max_tokens: int = 4096) -> str:
        """LLM-Call ueber TheBrain ProviderRouter mit Anthropic-Fallback."""
        if system_msg is None:
            system_msg = SYSTEM_MESSAGE
        try:
            from config.model_router import get_model_for_agent
            from factory.brain.model_provider import get_model, get_router

            agent_id = self.agent_info.get("id", "MKT-11")
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
                temperature=0.9,
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

    def classify_comment(self, comment: dict) -> dict:
        """Klassifiziert einen Kommentar deterministisch in Stufe 1 oder 2.

        HARD LOGIC — kein LLM:
        - Negativ-Keywords → Stufe 2 (CEO-Gate)
        - Alles andere → Stufe 1 (autonom)

        Args:
            comment: {"text": str, "author": str, "platform": str, ...}

        Returns: {
            "tier": 1 | 2,
            "reason": str,
            "triggers": list[str],
        }
        """
        text = (comment.get("text") or "").lower()
        triggers = []

        # Negativ-Keywords checken
        for kw in TIER2_KEYWORDS:
            if kw in text:
                triggers.append(f"keyword:{kw}")

        if triggers:
            return {
                "tier": 2,
                "reason": f"CEO-Gate erforderlich: {', '.join(triggers[:3])}",
                "triggers": triggers,
            }

        return {
            "tier": 1,
            "reason": "Positiver/neutraler Kommentar",
            "triggers": [],
        }

    def process_comment(self, comment: dict) -> dict:
        """Verarbeitet einen einzelnen Kommentar durch das Zwei-Stufen-System.

        Args:
            comment: {
                "id": str, "text": str, "author": str,
                "platform": str, "post_id": str (optional)
            }

        Returns: {
            "comment_id": str,
            "platform": str,
            "tier": 1 | 2,
            "classification": dict,
            "action": "responded" | "gate_created",
            "response": str | None,  (nur bei Stufe 1)
            "gate_id": str | None,   (nur bei Stufe 2)
        }
        """
        classification = self.classify_comment(comment)
        platform = comment.get("platform", "unknown")
        result = {
            "comment_id": comment.get("id", "unknown"),
            "platform": platform,
            "tier": classification["tier"],
            "classification": classification,
            "action": "",
            "response": None,
            "gate_id": None,
        }

        if classification["tier"] == 1:
            response = self._generate_response(comment)
            result["action"] = "responded"
            result["response"] = response
            logger.info("Tier 1: Auto-responded to %s comment %s",
                        platform, comment.get("id"))
        else:
            gate_id = self._create_comment_gate(comment, classification)
            result["action"] = "gate_created"
            result["gate_id"] = gate_id
            logger.info("Tier 2: Gate created %s for %s comment %s (triggers: %s)",
                        gate_id, platform, comment.get("id"),
                        classification["triggers"][:3])

        return result

    def process_batch(self, comments: list[dict]) -> dict:
        """Verarbeitet einen Batch von Kommentaren.

        Returns: {
            "total": int,
            "tier1_count": int,
            "tier2_count": int,
            "results": list[dict],
            "gates_created": int,
            "by_platform": dict,
        }
        """
        results = []
        tier1 = 0
        tier2 = 0
        gates = 0
        by_platform = {}

        for comment in comments:
            r = self.process_comment(comment)
            results.append(r)

            p = r["platform"]
            by_platform.setdefault(p, {"tier1": 0, "tier2": 0})

            if r["tier"] == 1:
                tier1 += 1
                by_platform[p]["tier1"] += 1
            else:
                tier2 += 1
                by_platform[p]["tier2"] += 1
                if r["gate_id"]:
                    gates += 1

        return {
            "total": len(comments),
            "tier1_count": tier1,
            "tier2_count": tier2,
            "results": results,
            "gates_created": gates,
            "by_platform": by_platform,
        }

    def _generate_response(self, comment: dict) -> str:
        """Generiert eine Antwort via LLM (nur Stufe 1)."""
        platform = comment.get("platform", "youtube")
        limits = PLATFORM_LIMITS.get(platform, PLATFORM_LIMITS["youtube"])

        prompt = f"""Schreibe eine Antwort auf diesen Social Media Kommentar:

Plattform: {platform}
Kommentar: {comment.get('text', '')}
Autor: {comment.get('author', 'Unbekannt')}

Regeln:
- Maximal {limits['max_chars']} Zeichen
- Ton: {limits['tone']}
- Sprache: Deutsch (oder Englisch wenn der Kommentar auf Englisch ist)
- Geh konkret auf den Inhalt ein
- Keine generischen Antworten

Antworte NUR mit dem Antworttext, keine Erklaerung drumherum."""

        return self._call_llm(prompt, max_tokens=512)

    def _create_comment_gate(self, comment: dict, classification: dict) -> str:
        """Erstellt eine CEO-Gate-Anfrage fuer einen Stufe-2-Kommentar."""
        platform = comment.get("platform", "unknown")
        try:
            gate_id = self.alerts.create_gate_request(
                source_agent="MKT-11",
                title=f"Comment Gate [{platform}]: {comment.get('text', '')[:40]}",
                description=(
                    f"Plattform: {platform}\n"
                    f"Autor: {comment.get('author', 'Unbekannt')}\n"
                    f"Kommentar: {comment.get('text', '')}\n"
                    f"Post-ID: {comment.get('post_id', 'N/A')}\n\n"
                    f"Triggers: {', '.join(classification['triggers'][:5])}\n"
                    f"Grund: {classification['reason']}"
                ),
                options=[
                    {"label": "Antworten", "description": "Kommentar mit vorgeschlagener Antwort beantworten"},
                    {"label": "Ignorieren", "description": "Kommentar nicht beantworten"},
                    {"label": "Loeschen", "description": "Kommentar melden/loeschen lassen"},
                    {"label": "Eskalieren", "description": "An uebergeordnete Stelle weiterleiten"},
                ],
            )
            return gate_id
        except Exception as e:
            logger.error("Failed to create gate request: %s", e)
            return ""

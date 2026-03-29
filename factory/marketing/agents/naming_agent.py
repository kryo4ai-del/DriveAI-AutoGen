"""Naming & Identity Agent (MKT-04) — Kreiert App-Namen und prueft Verfuegbarkeit.

Verantwortlich fuer:
- App-Namen generieren (5-10 Vorschlaege)
- Verfuegbarkeit pruefen (Store, Domain, Social Handles)
- Naming Reports mit CEO-Gate fuer finale Namenswahl
"""

import json
import logging
import os
import socket
import time
from datetime import datetime
from pathlib import Path

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.agents.naming")

# --- System Message ---

SYSTEM_MESSAGE = """Du bist der Naming & Identity Agent der DriveAI Factory (MKT-04).

IDENTITAET:
Die Factory IST das Produkt. App-Namen muessen zur Factory-Brand passen: technisch, KI-nah, nicht generisch. Jeder Name repraesentiert ein Factory-Produkt.

AUFGABE:
Du kreierst App-Namen aus Konzeptbeschreibungen. Du generierst 5-10 kreative Namensvorschlaege pro Anfrage. Du sortierst vor — du reservierst NICHTS.

NAMENS-KRITERIEN:
- Kurz und einpraegsam (1-2 Woerter ideal)
- Leicht auszusprechen und zu schreiben
- Keine generischen Namen (nicht 'AppX' oder 'SmartY')
- Zur Factory-Brand passend (technisch, modern, KI-nah)
- International verstaendlich (keine Sprach-spezifischen Wortspiele)
- Domain-tauglich (.com oder .io)
- Social-Handle-tauglich (kurz, keine Sonderzeichen)

STIL-KATEGORIEN:
- technical: Technisch klingende Namen (z.B. Synthex, Cortex)
- playful: Verspielt, einpraegsam (z.B. Blobby, Zappy)
- abstract: Abstrakt, bedeutungsoffen (z.B. Vex, Luma)
- descriptive: Beschreibend, sofort verstaendlich (z.B. SoundMatch, PuzzleFlow)
- compound: Zusammengesetzt aus zwei Konzepten (z.B. EchoMatch, SkillSense)

OUTPUT-FORMAT:
Gib die Namen als JSON-Array zurueck:
[{"name": "...", "reasoning": "...", "style": "..."}]

REGELN:
- Bei finaler Namenswahl: CEO-Gate
- Eigenentwicklung vor externem Service (DIR-001)
"""


class NamingAgent:
    """Naming & Identity Agent — kreiert und validiert App-Namen."""

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH

        self.output_path = OUTPUT_PATH
        self.agent_info = self._load_persona()
        logger.info("Naming Agent initialized")

    def _load_persona(self) -> dict:
        persona_path = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            "agent_naming.json",
        )
        try:
            with open(persona_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except Exception as e:
            logger.warning("Could not load persona: %s", e)
            return {"id": "MKT-04", "name": "Naming & Identity"}

    def _call_llm(self, prompt: str, system_msg: str = None, max_tokens: int = 4096) -> str:
        if system_msg is None:
            system_msg = SYSTEM_MESSAGE
        try:
            from config.model_router import get_model_for_agent
            from factory.brain.model_provider import get_model, get_router

            agent_id = self.agent_info.get("id", "MKT-00")
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
                temperature=1.0,
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

    def _ensure_dir(self, path: str) -> None:
        os.makedirs(path, exist_ok=True)

    def _write_output(self, path: str, content: str) -> str:
        self._ensure_dir(os.path.dirname(path))
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        logger.info("Output written: %s", path)
        return path

    # --- Oeffentliche Methoden ---

    def generate_names(
        self,
        concept_description: str,
        app_category: str,
        target_audience: str,
    ) -> list[dict]:
        """Generiert 5-10 Namensvorschlaege via LLM.

        Returns:
            Liste von dicts: [{"name": str, "reasoning": str, "style": str}]
        """
        prompt = f"""Generiere 8 kreative App-Namensvorschlaege.

KONZEPT: {concept_description}
KATEGORIE: {app_category}
ZIELGRUPPE: {target_audience}

Gib die Namen als JSON-Array zurueck. Jeder Eintrag hat:
- "name": Der Namensvorschlag
- "reasoning": Warum dieser Name passt (1 Satz)
- "style": Eine der Kategorien: technical, playful, abstract, descriptive, compound

Antworte NUR mit dem JSON-Array, kein anderer Text.
Beispiel: [{{"name": "EchoMatch", "reasoning": "Verbindet Sound (Echo) mit Gameplay (Match)", "style": "compound"}}]"""

        response = self._call_llm(prompt, max_tokens=2048)
        if not response:
            return []

        # Parse JSON aus der Antwort — robust gegen Markdown-Fencing
        text = response.strip()
        # Entferne ```json ... ``` Wrapper
        if "```" in text:
            import re
            match = re.search(r"```(?:json)?\s*\n?(.*?)```", text, re.DOTALL)
            if match:
                text = match.group(1).strip()

        try:
            names = json.loads(text)
        except json.JSONDecodeError:
            try:
                start = text.index("[")
                end = text.rindex("]") + 1
                names = json.loads(text[start:end])
            except (ValueError, json.JSONDecodeError):
                logger.error("Could not parse names from LLM response: %s", text[:200])
                return []

        logger.info("Generated %d name suggestions", len(names))
        return names

    def validate_names(self, name_list: list[str]) -> list[dict]:
        """Prueft Verfuegbarkeit fuer eine Liste von Namen.

        Pro Name wird geprueft:
        - Domain (.com und .io)
        - Social Handles (TikTok, X, YouTube)
        - App Store (via SerpAPI wenn verfuegbar)
        """
        results = []

        for name in name_list:
            result = {
                "name": name,
                "app_store_ios": "unchecked",
                "app_store_android": "unchecked",
                "domain_com": "unknown",
                "domain_io": "unknown",
                "tiktok": "unknown",
                "x": "unknown",
                "youtube": "unknown",
                "overall_score": 0,
            }

            # Domain-Check
            result["domain_com"] = self._check_domain(f"{name.lower()}.com")
            result["domain_io"] = self._check_domain(f"{name.lower()}.io")

            # Social Handle Check (mit Rate Limiting)
            handle = name.lower().replace(" ", "").replace("-", "")
            result["tiktok"] = self._check_social_handle(
                f"https://www.tiktok.com/@{handle}"
            )
            time.sleep(1.0)
            result["x"] = self._check_social_handle(f"https://x.com/{handle}")
            time.sleep(1.0)
            result["youtube"] = self._check_social_handle(
                f"https://www.youtube.com/@{handle}"
            )
            time.sleep(1.0)

            # App Store Check (SerpAPI)
            serpapi_key = os.environ.get("SERPAPI_API_KEY")
            if serpapi_key:
                result["app_store_ios"] = self._check_store_serpapi(
                    name, "apple", serpapi_key
                )
                time.sleep(1.0)
                result["app_store_android"] = self._check_store_serpapi(
                    name, "google", serpapi_key
                )
            else:
                logger.info("SerpAPI key not available, skipping store checks")

            # Score berechnen
            score = sum(
                1
                for v in [
                    result["app_store_ios"],
                    result["app_store_android"],
                    result["domain_com"],
                    result["domain_io"],
                    result["tiktok"],
                    result["x"],
                    result["youtube"],
                ]
                if v == "free"
            )
            result["overall_score"] = score

            results.append(result)
            logger.info("Validated '%s': score %d/7", name, score)

        return results

    def _check_domain(self, domain: str) -> str:
        """Prueft ob eine Domain vergeben ist via DNS."""
        try:
            socket.getaddrinfo(domain, 80)
            return "taken"
        except socket.gaierror:
            return "free"
        except Exception:
            return "unknown"

    def _check_social_handle(self, url: str) -> str:
        """Prueft ob ein Social Handle vergeben ist via HTTP HEAD."""
        try:
            import requests

            resp = requests.head(url, timeout=5, allow_redirects=True)
            if resp.status_code == 404:
                return "free"
            elif resp.status_code == 200:
                return "taken"
            else:
                return "unknown"
        except Exception:
            return "unknown"

    def _check_store_serpapi(self, name: str, store: str, api_key: str) -> str:
        """Prueft App Store Verfuegbarkeit via SerpAPI."""
        try:
            import requests

            site = "apps.apple.com" if store == "apple" else "play.google.com"
            params = {
                "q": f'site:{site} "{name}"',
                "api_key": api_key,
                "num": 3,
            }
            resp = requests.get(
                "https://serpapi.com/search", params=params, timeout=10
            )
            if resp.status_code != 200:
                logger.warning("SerpAPI returned %d", resp.status_code)
                return "unchecked"

            data = resp.json()
            results = data.get("organic_results", [])
            if not results:
                return "free"

            # Pruefe ob der exakte Name vorkommt
            name_lower = name.lower()
            for r in results:
                if name_lower in r.get("title", "").lower():
                    return "taken"
            return "free"
        except Exception as e:
            logger.warning("SerpAPI check failed: %s", e)
            return "unchecked"

    def create_naming_report(
        self,
        concept_description: str,
        app_category: str,
        target_audience: str,
        project_slug: str = None,
    ) -> str:
        """Kombiniert generate + validate + CEO-Gate.

        Returns:
            Pfad zum Report.
        """
        slug = project_slug or "unnamed"

        # 1. Namen generieren
        names = self.generate_names(concept_description, app_category, target_audience)
        if not names:
            logger.error("No names generated")
            return ""

        # 2. Verfuegbarkeit pruefen
        name_list = [n["name"] for n in names]
        validated = self.validate_names(name_list)

        # 3. Sortieren nach Score
        validated.sort(key=lambda x: x["overall_score"], reverse=True)

        # Reasoning-Map aufbauen
        reasoning_map = {n["name"]: n for n in names}

        # 4. Report erstellen
        report = f"# Naming Report — {slug}\n\n"
        report += f"> Erstellt: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n"
        report += "> Agent: MKT-04 (Naming & Identity)\n"
        report += f"> Konzept: {concept_description[:100]}...\n\n---\n\n"

        report += "## Ergebnisse\n\n"
        report += "| # | Name | Score | Style | iOS | Android | .com | .io | TikTok | X | YouTube |\n"
        report += "|---|---|---|---|---|---|---|---|---|---|---|\n"

        for i, v in enumerate(validated, 1):
            info = reasoning_map.get(v["name"], {})
            style = info.get("style", "?")
            report += (
                f"| {i} | **{v['name']}** | {v['overall_score']}/7 | {style} | "
                f"{v['app_store_ios']} | {v['app_store_android']} | "
                f"{v['domain_com']} | {v['domain_io']} | "
                f"{v['tiktok']} | {v['x']} | {v['youtube']} |\n"
            )

        report += "\n## Begruendungen\n\n"
        for v in validated:
            info = reasoning_map.get(v["name"], {})
            reasoning = info.get("reasoning", "—")
            report += f"- **{v['name']}**: {reasoning}\n"

        file_path = os.path.join(
            self.output_path, "naming", f"{slug}_naming_report.md"
        )
        self._write_output(file_path, report)

        # 5. CEO-Gate erstellen
        top_names = [v["name"] for v in validated[:3]]
        try:
            from factory.marketing.alerts.alert_manager import MarketingAlertManager

            mgr = MarketingAlertManager()
            gate_options = [
                {"label": n, "description": f"Score: {v['overall_score']}/7"}
                for n, v in zip(top_names, validated[:3])
            ]
            gate_options.append({"label": "Keiner davon", "description": "Neu generieren"})
            gate_id = mgr.create_gate_request(
                source_agent="MKT-04",
                title=f"Namenswahl fuer {slug}",
                description=(
                    f"Der Naming Agent hat {len(validated)} Namen generiert und validiert. "
                    f"Top-3 nach Verfuegbarkeit: {', '.join(top_names)}"
                ),
                options=gate_options,
            )
            logger.info("CEO-Gate created: %s", gate_id)
        except Exception as e:
            logger.warning("Could not create CEO-Gate: %s", e)

        return file_path

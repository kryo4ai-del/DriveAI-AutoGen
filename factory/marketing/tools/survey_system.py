"""Community Survey System — Erstellt und verwaltet Umfragen fuer verschiedene Plattformen.

Formatierung: Deterministisch (Plattform-Limits eingehalten).
Analyse: LLM (Interpretation der Ergebnisse).

Plattform-Limits:
- X (Twitter): 4 Optionen, 280 Zeichen
- Reddit: 6 Optionen, 300 Zeichen Titel
- YouTube Community: 4 Optionen, 65 Zeichen/Option
- General: 10 Optionen, keine Zeichenbegrenzung
"""

import json
import logging
import os
from datetime import datetime
from pathlib import Path
from typing import Optional

from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[3] / ".env")

logger = logging.getLogger("factory.marketing.tools.survey_system")


# Plattform-Limits
PLATFORM_LIMITS = {
    "x": {"max_options": 4, "max_title_chars": 280, "max_option_chars": 25},
    "reddit": {"max_options": 6, "max_title_chars": 300, "max_option_chars": 120},
    "youtube": {"max_options": 4, "max_title_chars": 500, "max_option_chars": 65},
    "general": {"max_options": 10, "max_title_chars": 1000, "max_option_chars": 200},
}


class SurveySystem:
    """Community Survey System — Umfragen erstellen, formatieren und auswerten."""

    def __init__(self) -> None:
        from factory.marketing.config import OUTPUT_PATH
        self.output_path = Path(OUTPUT_PATH)
        logger.info("SurveySystem initialized")

    def _call_llm(self, prompt: str, max_tokens: int = 2048) -> str:
        """LLM-Call fuer Survey-Analyse."""
        try:
            from factory.brain.model_provider import get_model_for_agent, get_router

            selection = get_model_for_agent("MKT-14", expected_output_tokens=max_tokens)
            router = get_router()
            response = router.call(
                model_id=selection["model"],
                provider=selection["provider"],
                messages=[
                    {"role": "system", "content": "Du analysierst Umfrage-Ergebnisse fuer die DriveAI Factory Marketing-Abteilung. Sei praezise und datengetrieben."},
                    {"role": "user", "content": prompt},
                ],
                max_tokens=max_tokens,
                temperature=0.7,
            )
            if response.error:
                raise RuntimeError(response.error)
            return response.content
        except Exception:
            try:
                from factory.brain.model_provider import get_model, get_router

                selection = get_model(profile="standard", expected_output_tokens=max_tokens)
                router = get_router()
                response = router.call(
                    model_id=selection["model"],
                    provider=selection["provider"],
                    messages=[
                        {"role": "system", "content": "Du analysierst Umfrage-Ergebnisse."},
                        {"role": "user", "content": prompt},
                    ],
                    max_tokens=max_tokens,
                    temperature=0.7,
                )
                if response.error:
                    raise RuntimeError(response.error)
                return response.content
            except Exception as e:
                logger.error("LLM call failed: %s", e)
                return f"<<LLM NICHT VERFUEGBAR: {e}>>"

    # ── Survey erstellen (deterministisch) ─────────────────

    def create_survey(self, title: str, questions: list[dict],
                      platforms: list[str] = None,
                      survey_type: str = "feedback") -> dict:
        """Erstellt eine Survey mit Plattform-Validierung.

        Args:
            title: Titel der Umfrage
            questions: Liste von {"question": str, "options": [str, ...]}
            platforms: Ziel-Plattformen (default: ["general"])
            survey_type: 'feedback', 'feature_vote', 'satisfaction', 'market_research'

        Returns:
            Dict mit survey_id, formatted versions, validation.
        """
        if not platforms:
            platforms = ["general"]

        # Formatierte Versionen pro Plattform
        formatted = {}
        validation_errors = []

        for platform in platforms:
            limits = PLATFORM_LIMITS.get(platform, PLATFORM_LIMITS["general"])
            fmt, errors = self._format_for_platform(title, questions, limits, platform)
            formatted[platform] = fmt
            if errors:
                validation_errors.extend(
                    [f"[{platform}] {e}" for e in errors]
                )

        # In DB speichern
        survey_id = None
        try:
            from factory.marketing.tools.ranking_database import RankingDatabase
            db = RankingDatabase()
            survey_id = db.store_survey(
                title=title,
                survey_type=survey_type,
                platforms=",".join(platforms),
                questions_json=json.dumps(questions, ensure_ascii=False),
                status="draft",
            )
        except Exception as e:
            logger.warning("Could not store survey: %s", e)

        return {
            "survey_id": survey_id,
            "title": title,
            "survey_type": survey_type,
            "platforms": platforms,
            "formatted": formatted,
            "questions": questions,
            "validation_errors": validation_errors,
            "valid": len(validation_errors) == 0,
            "created_at": datetime.now().isoformat(),
        }

    def _format_for_platform(self, title: str, questions: list[dict],
                              limits: dict, platform: str) -> tuple[dict, list[str]]:
        """Formatiert Survey fuer eine bestimmte Plattform.

        Returns:
            (formatted_dict, errors_list)
        """
        errors = []
        max_options = limits["max_options"]
        max_title = limits["max_title_chars"]
        max_option = limits["max_option_chars"]

        # Titel validieren
        formatted_title = title
        if len(title) > max_title:
            formatted_title = title[:max_title - 3] + "..."
            errors.append(f"Titel gekuerzt ({len(title)} > {max_title} Zeichen)")

        formatted_questions = []
        for q in questions:
            question_text = q.get("question", "")
            options = q.get("options", [])

            # Optionen limitieren
            if len(options) > max_options:
                errors.append(
                    f"Frage '{question_text[:30]}...' hat {len(options)} Optionen "
                    f"(max {max_options} fuer {platform})"
                )
                options = options[:max_options]

            # Optionen kuerzen
            formatted_options = []
            for opt in options:
                if len(opt) > max_option:
                    formatted_options.append(opt[:max_option - 3] + "...")
                    errors.append(f"Option '{opt[:20]}...' gekuerzt ({len(opt)} > {max_option})")
                else:
                    formatted_options.append(opt)

            formatted_questions.append({
                "question": question_text,
                "options": formatted_options,
            })

        return {
            "title": formatted_title,
            "questions": formatted_questions,
            "platform": platform,
            "limits": limits,
        }, errors

    # ── Survey-Ergebnisse erfassen ────────────────────────

    def record_results(self, survey_id: int, results: dict) -> bool:
        """Speichert Survey-Ergebnisse.

        Args:
            survey_id: DB-ID der Survey
            results: {"question_index": {"option": count, ...}, ...}

        Returns:
            True bei Erfolg.
        """
        try:
            from factory.marketing.tools.ranking_database import RankingDatabase
            db = RankingDatabase()
            return db.update_survey(
                survey_id,
                results_json=json.dumps(results, ensure_ascii=False),
                status="completed",
            )
        except Exception as e:
            logger.warning("Could not record results: %s", e)
            return False

    # ── Survey-Analyse (LLM) ─────────────────────────────

    def analyze_results(self, survey_id: int = None,
                        title: str = None,
                        results: dict = None) -> str:
        """Analysiert Survey-Ergebnisse mit LLM.

        Args:
            survey_id: DB-ID (laedt Daten aus DB)
            title: Titel (optional, fuer Kontext)
            results: Ergebnisse direkt uebergeben

        Returns:
            Analyse-Text (Markdown).
        """
        # Daten laden
        if survey_id and not results:
            try:
                from factory.marketing.tools.ranking_database import RankingDatabase
                db = RankingDatabase()
                surveys = db.get_surveys()
                for s in surveys:
                    if s.get("id") == survey_id:
                        title = title or s.get("title", "Unbekannt")
                        if s.get("results_json"):
                            results = json.loads(s["results_json"])
                        break
            except Exception as e:
                logger.warning("Could not load survey: %s", e)

        if not results:
            return "<<Keine Ergebnisse verfuegbar>>"

        prompt = (
            f"Analysiere die Ergebnisse dieser Umfrage:\\n\\n"
            f"Titel: {title or 'Unbekannt'}\\n"
            f"Ergebnisse:\\n{json.dumps(results, indent=2, ensure_ascii=False)}\\n\\n"
            "Erstelle eine kurze Analyse (max 300 Woerter):\\n"
            "1. Kernaussage: Was sagen die Daten?\\n"
            "2. Ueberraschungen: Was war unerwartet?\\n"
            "3. Handlungsempfehlung: Was sollte die Factory tun?\\n"
            "4. Naechste Fragen: Welche Follow-up Umfragen waeren sinnvoll?\\n"
        )

        analysis = self._call_llm(prompt, max_tokens=1500)

        # Analyse in DB speichern
        if survey_id:
            try:
                from factory.marketing.tools.ranking_database import RankingDatabase
                db = RankingDatabase()
                db.update_survey(survey_id, analysis=analysis)
            except Exception:
                pass

        return analysis

    # ── Vorgefertigte Templates ───────────────────────────

    def get_survey_templates(self) -> dict:
        """Gibt vorgefertigte Survey-Templates zurueck."""
        return {
            "app_feedback": {
                "title": "Wie gefaellt dir {app_name}?",
                "questions": [
                    {
                        "question": "Wie wuerdest du {app_name} bewerten?",
                        "options": ["Sehr gut", "Gut", "OK", "Schlecht"],
                    },
                    {
                        "question": "Welches Feature fehlt dir am meisten?",
                        "options": ["Dark Mode", "Offline-Modus", "Mehr Sprachen", "Bessere Performance"],
                    },
                ],
                "platforms": ["x", "reddit"],
            },
            "feature_vote": {
                "title": "Welches Feature sollen wir als naechstes bauen?",
                "questions": [
                    {
                        "question": "Was hat fuer dich Prioritaet?",
                        "options": ["Feature A", "Feature B", "Feature C", "Bug Fixes"],
                    },
                ],
                "platforms": ["x", "youtube"],
            },
            "market_research": {
                "title": "Wie nutzt du KI-Apps im Alltag?",
                "questions": [
                    {
                        "question": "Welche KI-Apps nutzt du regelmaessig?",
                        "options": ["ChatGPT", "Claude", "Gemini", "Andere", "Keine"],
                    },
                    {
                        "question": "Wofuer nutzt du KI am meisten?",
                        "options": ["Texte schreiben", "Code", "Recherche", "Kreatives", "Analyse"],
                    },
                ],
                "platforms": ["reddit", "x"],
            },
        }

    def get_platform_limits(self) -> dict:
        """Gibt Plattform-Limits zurueck (fuer Tests und UI)."""
        return dict(PLATFORM_LIMITS)

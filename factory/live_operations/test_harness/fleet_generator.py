"""Synthetic Fleet Generator — erzeugt realistische Testdaten.

Registriert Apps in der DB, generiert Metriken-Historie, Reviews,
Support-Tickets und injiziert Szenarien. Alles deterministisch.
"""

import hashlib
import json
import random
import uuid
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Optional

from factory.live_operations.app_registry.database import AppRegistryDB
from factory.live_operations.test_harness.config import (
    APP_FLEET,
    FLEET_DISTRIBUTION,
    HEALTH_STATES,
    HISTORY_DAYS,
    HISTORY_POINTS_PER_DAY,
    POSITIVE_REVIEWS,
    NEGATIVE_REVIEWS,
    MIXED_REVIEWS,
    SUPPORT_CATEGORIES,
    SYNTHETIC_MARKER,
)
from factory.live_operations.test_harness.scenarios import (
    SCENARIOS,
    get_scenario,
    list_scenarios,
)

_PREFIX = "[Fleet Generator]"


def _now_iso() -> str:
    return datetime.now(timezone.utc).isoformat()


def _rand_range(low: float, high: float) -> float:
    """Zufallswert im Bereich [low, high]."""
    return round(random.uniform(low, high), 2)


def _rand_int_range(low: int, high: int) -> int:
    return random.randint(low, high)


def _stable_seed(name: str) -> int:
    """Deterministischer Seed aus App-Name fuer reproduzierbare Daten."""
    return int(hashlib.md5(name.encode()).hexdigest()[:8], 16)


class SyntheticFleetGenerator:
    """Erzeugt eine Fleet synthetischer Apps mit realistischen Daten."""

    def __init__(
        self,
        registry_db: Optional[AppRegistryDB] = None,
        data_dir: Optional[str] = None,
        seed: int = 42,
    ) -> None:
        self._db = registry_db or AppRegistryDB()
        self._data_dir = Path(
            data_dir
            or Path(__file__).resolve().parent.parent / "data" / "synthetic"
        )
        self._data_dir.mkdir(parents=True, exist_ok=True)
        self._seed = seed
        self._generated_apps: list[str] = []

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def generate_fleet(self, count: int = 15) -> dict:
        """Registriert synthetische Apps in der DB.

        Verteilt Apps nach FLEET_DISTRIBUTION auf Health States.
        Returns: Summary mit app_ids und States.
        """
        random.seed(self._seed)

        # Build assignment: welche App bekommt welchen State
        assignments = self._assign_health_states(count)
        results = []

        for i, (app_def, state) in enumerate(assignments):
            app_id = self._register_app(app_def, state)
            if app_id:
                results.append({
                    "app_id": app_id,
                    "name": app_def["name"],
                    "profile": app_def["profile"],
                    "health_state": state,
                })
                self._generated_apps.append(app_id)

        summary = {
            "generated_at": _now_iso(),
            "total": len(results),
            "apps": results,
            "distribution": {
                state: sum(1 for r in results if r["health_state"] == state)
                for state in HEALTH_STATES
            },
        }

        self._save_json("fleet_manifest.json", summary)
        print(f"{_PREFIX} Fleet generiert: {len(results)} Apps")
        return summary

    def generate_metrics_history(self, app_id: Optional[str] = None) -> dict:
        """Generiert HISTORY_DAYS Tage Metriken-Historie.

        Fuer eine bestimmte App oder alle synthetischen Apps.
        """
        apps = self._get_target_apps(app_id)
        total_records = 0

        for app in apps:
            aid = app["app_id"]
            state = self._detect_health_state(app)
            random.seed(_stable_seed(aid))

            records = self._build_metrics_history(aid, state)
            for record in records:
                self._db.add_health_record(aid, record)
                total_records += 1

        summary = {
            "generated_at": _now_iso(),
            "apps_processed": len(apps),
            "total_records": total_records,
            "days": HISTORY_DAYS,
            "points_per_day": HISTORY_POINTS_PER_DAY,
        }
        print(f"{_PREFIX} Metriken-Historie: {total_records} Records fuer {len(apps)} Apps")
        return summary

    def generate_reviews(self, app_id: Optional[str] = None) -> dict:
        """Generiert synthetische Reviews fuer Apps."""
        apps = self._get_target_apps(app_id)
        total_reviews = 0
        all_reviews = {}

        for app in apps:
            aid = app["app_id"]
            state = self._detect_health_state(app)
            random.seed(_stable_seed(aid + "_reviews"))

            reviews = self._build_reviews(aid, app.get("app_name", "Unknown"), state)
            all_reviews[aid] = reviews
            total_reviews += len(reviews)

        # Save reviews to data dir
        self._save_json("synthetic_reviews.json", {
            "generated_at": _now_iso(),
            "total": total_reviews,
            "reviews": all_reviews,
        })

        print(f"{_PREFIX} Reviews: {total_reviews} Reviews fuer {len(apps)} Apps")
        return {"apps_processed": len(apps), "total_reviews": total_reviews}

    def generate_support_tickets(self, app_id: Optional[str] = None) -> dict:
        """Generiert synthetische Support-Tickets."""
        apps = self._get_target_apps(app_id)
        total_tickets = 0
        all_tickets = {}

        for app in apps:
            aid = app["app_id"]
            state = self._detect_health_state(app)
            random.seed(_stable_seed(aid + "_tickets"))

            tickets = self._build_support_tickets(aid, app.get("app_name", "Unknown"), state)
            all_tickets[aid] = tickets
            total_tickets += len(tickets)

        self._save_json("synthetic_tickets.json", {
            "generated_at": _now_iso(),
            "total": total_tickets,
            "tickets": all_tickets,
        })

        print(f"{_PREFIX} Tickets: {total_tickets} Tickets fuer {len(apps)} Apps")
        return {"apps_processed": len(apps), "total_tickets": total_tickets}

    def inject_scenario(self, app_id: str, scenario_name: str) -> dict:
        """Injiziert ein Szenario in eine bestimmte App.

        Ueberschreibt aktuelle Metriken der App mit Szenario-Werten.
        """
        scenario = get_scenario(scenario_name)
        if not scenario:
            available = ", ".join(list_scenarios())
            return {"ok": False, "error": f"Unbekanntes Szenario: {scenario_name}. Verfuegbar: {available}"}

        app = self._db.get_app(app_id)
        if not app:
            return {"ok": False, "error": f"App {app_id} nicht gefunden"}

        overrides = scenario["metric_overrides"]
        updates = {}

        # Apply metric overrides to health score and zone
        if "crash_rate" in overrides:
            cr = overrides["crash_rate"]
            if isinstance(cr, tuple):
                crash_val = _rand_range(*cr)
            else:
                crash_val = float(cr)
            # High crash rate -> low score
            score_impact = max(0, 100 - crash_val * 15)
            updates["health_score"] = round(score_impact, 1)

        if "rating" in overrides:
            rt = overrides["rating"]
            if isinstance(rt, tuple):
                if rt[0] < 0:
                    # Delta-Wert
                    current_rating = 4.0  # Annahme
                    new_rating = max(1.0, current_rating + _rand_range(*rt))
                else:
                    new_rating = _rand_range(*rt)
            else:
                new_rating = float(rt)
            updates["_scenario_rating"] = round(new_rating, 1)

        # Determine new health score from scenario severity
        severity_score_map = {
            "critical": (5.0, 25.0),
            "high": (20.0, 40.0),
            "medium": (35.0, 55.0),
            "low": (60.0, 85.0),
        }
        severity = scenario.get("severity", "medium")
        score_range = severity_score_map.get(severity, (30.0, 50.0))
        new_score = _rand_range(*score_range)

        # Recovery + seasonal_peak -> higher scores
        if scenario_name in ("recovery", "seasonal_peak"):
            new_score = _rand_range(65.0, 90.0)

        zone = "green" if new_score >= 80 else ("yellow" if new_score >= 50 else "red")

        self._db.update_app(app_id, {
            "health_score": new_score,
            "health_zone": zone,
        })

        # Add health record reflecting the scenario
        self._db.add_health_record(app_id, {
            "overall_score": new_score,
            "stability_score": _rand_range(10, 90),
            "satisfaction_score": _rand_range(10, 90),
            "engagement_score": _rand_range(10, 90),
            "revenue_score": _rand_range(10, 90),
            "growth_score": _rand_range(10, 90),
        })

        # Save injection log
        injection = {
            "injected_at": _now_iso(),
            "app_id": app_id,
            "app_name": app.get("app_name", "Unknown"),
            "scenario": scenario_name,
            "description": scenario["description"],
            "expected_action": scenario["expected_action"],
            "new_score": new_score,
            "new_zone": zone,
            "duration_days": scenario.get("duration_days", 7),
        }

        # Append to injection log
        log_path = self._data_dir / "injection_log.jsonl"
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(json.dumps(injection, default=str) + "\n")

        print(f"{_PREFIX} Szenario '{scenario_name}' injiziert in {app.get('app_name', app_id)} -> Score={new_score}, Zone={zone}")
        return {"ok": True, **injection}

    def populate_all(self, count: int = 15) -> dict:
        """Generiert alles: Fleet + Metriken + Reviews + Tickets."""
        fleet = self.generate_fleet(count)
        metrics = self.generate_metrics_history()
        reviews = self.generate_reviews()
        tickets = self.generate_support_tickets()

        summary = {
            "populated_at": _now_iso(),
            "fleet": fleet,
            "metrics": metrics,
            "reviews": reviews,
            "tickets": tickets,
        }

        self._save_json("populate_summary.json", summary)
        print(f"{_PREFIX} Alles populiert: {fleet['total']} Apps, {metrics['total_records']} Records, {reviews['total_reviews']} Reviews, {tickets['total_tickets']} Tickets")
        return summary

    def clear_all(self) -> dict:
        """Entfernt alle synthetischen Daten aus DB und Dateisystem."""
        removed_apps = 0
        apps = self._db.get_all_apps()
        synthetic_ids = [
            a["app_id"] for a in apps
            if a.get("repository_path") == SYNTHETIC_MARKER
        ]

        if synthetic_ids:
            conn = self._db._get_conn()
            for aid in synthetic_ids:
                conn.execute("DELETE FROM health_score_history WHERE app_id = ?", (aid,))
                conn.execute("DELETE FROM action_queue WHERE app_id = ?", (aid,))
                conn.execute("DELETE FROM release_history WHERE app_id = ?", (aid,))
                conn.execute("DELETE FROM apps WHERE app_id = ?", (aid,))
                removed_apps += 1
            conn.commit()
            conn.close()

        # Clean synthetic data files
        removed_files = 0
        if self._data_dir.exists():
            for f in self._data_dir.iterdir():
                if f.is_file():
                    f.unlink()
                    removed_files += 1

        self._generated_apps.clear()

        summary = {
            "cleared_at": _now_iso(),
            "removed_apps": removed_apps,
            "removed_files": removed_files,
        }
        print(f"{_PREFIX} Aufgeraeumt: {removed_apps} Apps, {removed_files} Dateien entfernt")
        return summary

    def get_status(self) -> dict:
        """Zeigt aktuellen Status der synthetischen Fleet."""
        apps = self._db.get_all_apps()
        synthetic = [a for a in apps if a.get("repository_path") == SYNTHETIC_MARKER]

        by_zone = {"green": 0, "yellow": 0, "red": 0}
        by_profile = {}
        for app in synthetic:
            zone = app.get("health_zone", "red")
            by_zone[zone] = by_zone.get(zone, 0) + 1
            profile = app.get("app_profile", "unknown")
            by_profile[profile] = by_profile.get(profile, 0) + 1

        # Check for injection log
        injections = 0
        log_path = self._data_dir / "injection_log.jsonl"
        if log_path.exists():
            with open(log_path, "r", encoding="utf-8") as f:
                injections = sum(1 for _ in f)

        return {
            "status_at": _now_iso(),
            "total_synthetic_apps": len(synthetic),
            "total_real_apps": len(apps) - len(synthetic),
            "by_zone": by_zone,
            "by_profile": by_profile,
            "active_injections": injections,
            "data_dir": str(self._data_dir),
            "apps": [
                {
                    "app_id": a["app_id"],
                    "name": a.get("app_name", "?"),
                    "profile": a.get("app_profile", "?"),
                    "score": a.get("health_score", 0),
                    "zone": a.get("health_zone", "?"),
                }
                for a in synthetic
            ],
        }

    # ------------------------------------------------------------------
    # Internal — App Registration
    # ------------------------------------------------------------------

    def _register_app(self, app_def: dict, health_state: str) -> Optional[str]:
        """Registriert eine App in der DB mit initialem Health State."""
        state = HEALTH_STATES[health_state]
        score = _rand_range(*state["score_range"])
        zone = "green" if score >= 80 else ("yellow" if score >= 50 else "red")

        app_data = {
            "app_name": app_def["name"],
            "bundle_id": app_def["bundle"],
            "package_name": app_def["bundle"],
            "app_profile": app_def["profile"],
            "health_score": score,
            "health_zone": zone,
            "current_version": f"1.{random.randint(0, 9)}.{random.randint(0, 20)}",
            "store_status": "published",
            "monetization_model": "freemium" if app_def["profile"] != "subscription" else "subscription",
            "repository_path": SYNTHETIC_MARKER,  # Marker fuer Cleanup
            "total_releases": random.randint(3, 25),
        }

        # New apps: niedrigere Version, weniger Releases
        if health_state == "new_app":
            app_data["current_version"] = f"1.0.{random.randint(0, 3)}"
            app_data["total_releases"] = random.randint(1, 3)

        try:
            app_id = self._db.add_app(app_data)
            print(f"{_PREFIX}   + {app_def['name']} [{health_state}] Score={score:.1f} Zone={zone}")
            return app_id
        except Exception as e:
            print(f"{_PREFIX}   ! Fehler bei {app_def['name']}: {e}")
            return None

    def _assign_health_states(self, count: int) -> list[tuple[dict, str]]:
        """Verteilt Apps auf Health States nach FLEET_DISTRIBUTION."""
        count = min(count, len(APP_FLEET))
        apps = APP_FLEET[:count]

        assignments = []
        idx = 0
        for state, num in FLEET_DISTRIBUTION.items():
            for _ in range(num):
                if idx < len(apps):
                    assignments.append((apps[idx], state))
                    idx += 1

        # Restliche Apps -> healthy
        while idx < len(apps):
            assignments.append((apps[idx], "healthy"))
            idx += 1

        return assignments

    # ------------------------------------------------------------------
    # Internal — Metrics History
    # ------------------------------------------------------------------

    def _build_metrics_history(self, app_id: str, health_state: str) -> list[dict]:
        """Generiert Metriken-Historie mit realistischer Variation."""
        state = HEALTH_STATES.get(health_state, HEALTH_STATES["warning"])
        records = []
        now = datetime.now(timezone.utc)
        total_points = HISTORY_DAYS * HISTORY_POINTS_PER_DAY

        base_score = _rand_range(*state["score_range"])

        for i in range(total_points):
            # Aeltester Punkt zuerst
            point_time = now - timedelta(hours=(total_points - i) * 6)

            # Kleine Variation pro Datenpunkt (+/- 5%)
            jitter = random.uniform(-5.0, 5.0)
            overall = max(0.0, min(100.0, base_score + jitter))

            # Kategorie-Scores mit aehnlicher Variation
            stability = max(0.0, min(100.0, base_score + random.uniform(-10, 10)))
            satisfaction = max(0.0, min(100.0, base_score + random.uniform(-8, 12)))
            engagement = max(0.0, min(100.0, base_score + random.uniform(-12, 8)))
            revenue = max(0.0, min(100.0, base_score + random.uniform(-10, 10)))
            growth = max(0.0, min(100.0, base_score + random.uniform(-15, 15)))

            records.append({
                "overall_score": round(overall, 1),
                "stability_score": round(stability, 1),
                "satisfaction_score": round(satisfaction, 1),
                "engagement_score": round(engagement, 1),
                "revenue_score": round(revenue, 1),
                "growth_score": round(growth, 1),
            })

        return records

    # ------------------------------------------------------------------
    # Internal — Reviews
    # ------------------------------------------------------------------

    def _build_reviews(self, app_id: str, app_name: str, health_state: str) -> list[dict]:
        """Generiert Reviews passend zum Health State."""
        reviews = []

        # Anzahl Reviews abhaengig vom State
        count_map = {"healthy": (8, 15), "warning": (5, 12), "critical": (10, 20), "new_app": (2, 5)}
        low, high = count_map.get(health_state, (5, 10))
        count = _rand_int_range(low, high)

        # Verteilung positiv/negativ/mixed
        dist_map = {
            "healthy": (0.6, 0.1, 0.3),
            "warning": (0.3, 0.3, 0.4),
            "critical": (0.1, 0.6, 0.3),
            "new_app": (0.5, 0.2, 0.3),
        }
        pos_pct, neg_pct, mix_pct = dist_map.get(health_state, (0.3, 0.3, 0.4))

        now = datetime.now(timezone.utc)
        for i in range(count):
            roll = random.random()
            if roll < pos_pct:
                text = random.choice(POSITIVE_REVIEWS)
                rating = random.choice([4, 5])
            elif roll < pos_pct + neg_pct:
                text = random.choice(NEGATIVE_REVIEWS)
                rating = random.choice([1, 2])
            else:
                text = random.choice(MIXED_REVIEWS)
                rating = 3

            reviews.append({
                "review_id": f"REV-{uuid.uuid4().hex[:8]}",
                "app_id": app_id,
                "app_name": app_name,
                "rating": rating,
                "text": text,
                "date": (now - timedelta(days=random.randint(0, 30))).isoformat(),
                "platform": random.choice(["ios", "android"]),
                "synthetic": True,
            })

        return reviews

    # ------------------------------------------------------------------
    # Internal — Support Tickets
    # ------------------------------------------------------------------

    def _build_support_tickets(self, app_id: str, app_name: str, health_state: str) -> list[dict]:
        """Generiert Support-Tickets passend zum Health State."""
        tickets = []

        count_map = {"healthy": (1, 3), "warning": (3, 7), "critical": (8, 15), "new_app": (1, 3)}
        low, high = count_map.get(health_state, (2, 5))
        count = _rand_int_range(low, high)

        # Kritische Apps -> mehr crash_reports und data_loss
        category_weights = {
            "healthy": {"feature_request": 0.5, "billing_issue": 0.2, "crash_report": 0.1, "performance_complaint": 0.1, "login_problem": 0.05, "data_loss": 0.05},
            "warning": {"crash_report": 0.3, "performance_complaint": 0.25, "feature_request": 0.2, "billing_issue": 0.1, "login_problem": 0.1, "data_loss": 0.05},
            "critical": {"crash_report": 0.4, "data_loss": 0.15, "performance_complaint": 0.2, "login_problem": 0.15, "billing_issue": 0.05, "feature_request": 0.05},
            "new_app": {"feature_request": 0.4, "login_problem": 0.2, "crash_report": 0.15, "performance_complaint": 0.15, "billing_issue": 0.05, "data_loss": 0.05},
        }
        weights = category_weights.get(health_state, category_weights["warning"])

        now = datetime.now(timezone.utc)
        for i in range(count):
            # Weighted category selection
            categories = list(weights.keys())
            probs = list(weights.values())
            category = random.choices(categories, weights=probs, k=1)[0]

            priority_map = {
                "crash_report": "high",
                "data_loss": "critical",
                "performance_complaint": "medium",
                "login_problem": "high",
                "billing_issue": "medium",
                "feature_request": "low",
            }

            tickets.append({
                "ticket_id": f"TKT-{uuid.uuid4().hex[:8]}",
                "app_id": app_id,
                "app_name": app_name,
                "category": category,
                "priority": priority_map.get(category, "medium"),
                "status": random.choice(["open", "open", "in_progress", "resolved"]),
                "created_at": (now - timedelta(days=random.randint(0, 14))).isoformat(),
                "synthetic": True,
            })

        return tickets

    # ------------------------------------------------------------------
    # Internal — Helpers
    # ------------------------------------------------------------------

    def _get_target_apps(self, app_id: Optional[str] = None) -> list[dict]:
        """Gibt Ziel-Apps zurueck: eine bestimmte oder alle synthetischen."""
        if app_id:
            app = self._db.get_app(app_id)
            return [app] if app else []

        apps = self._db.get_all_apps()
        return [a for a in apps if a.get("repository_path") == SYNTHETIC_MARKER]

    def _detect_health_state(self, app: dict) -> str:
        """Erkennt Health State anhand des Scores."""
        score = app.get("health_score", 50.0)
        if score >= 75:
            return "healthy"
        elif score >= 45:
            return "warning"
        elif score >= 10:
            return "critical"
        return "new_app"

    def _save_json(self, filename: str, data: dict) -> Path:
        """Speichert Daten als JSON in data_dir."""
        filepath = self._data_dir / filename
        with open(filepath, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False, default=str)
        return filepath

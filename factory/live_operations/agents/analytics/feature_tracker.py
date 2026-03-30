"""Feature Usage Tracking -- erkennt Star Features, Unused Features und Trends."""


class FeatureTracker:
    """Analysiert Feature-Adoption und erkennt Muster."""

    ADOPTION_STAR_THRESHOLD = 0.50    # >50% = Star Feature
    ADOPTION_UNUSED_THRESHOLD = 0.05  # <5% = Unused Feature

    def __init__(self) -> None:
        pass

    def analyze_feature_usage(self, metrics_history: list[dict]) -> dict:
        """Vollstaendige Feature Usage Analyse."""
        if not metrics_history:
            return {"features": {}, "summary": {}, "recommendations": []}

        # Feature-Daten aus allen Datenpunkten aggregieren
        feature_data = self._aggregate_features(metrics_history)
        if not feature_data:
            return {"features": {}, "summary": {}, "recommendations": []}

        # DAU fuer Adoption-Rate Berechnung
        latest = metrics_history[-1]
        dau = latest.get("firebase_metrics", {}).get("dau", 1)

        features = {}
        for name, data in feature_data.items():
            adoption = data["unique_users"][-1] / max(dau, 1) if data["unique_users"] else 0
            trend = self._track_adoption_trend(name, data)
            category = self._categorize_feature(adoption)

            features[name] = {
                "adoption_rate": round(adoption, 3),
                "trend": trend["direction"],
                "category": category,
                "total_uses_period": sum(data["total_uses"][-7:]) if data["total_uses"] else 0,
                "unique_users_period": data["unique_users"][-1] if data["unique_users"] else 0,
            }

        summary = self._build_summary(features)
        recommendations = self._generate_recommendations(features)

        return {
            "features": features,
            "summary": summary,
            "recommendations": recommendations,
        }

    def _aggregate_features(self, history: list[dict]) -> dict:
        """Aggregiert Feature-Daten aus der History."""
        feature_data = {}

        for entry in history:
            firebase = entry.get("firebase_metrics", {})
            usage = firebase.get("feature_usage", {})
            dau = firebase.get("dau", 1)

            for feature_name, count in usage.items():
                if feature_name not in feature_data:
                    feature_data[feature_name] = {
                        "total_uses": [],
                        "unique_users": [],
                    }
                feature_data[feature_name]["total_uses"].append(count)
                # Estimate unique users as ~40% of total uses (heuristic for stub data)
                feature_data[feature_name]["unique_users"].append(int(count * 0.4))

        return feature_data

    def _track_adoption_trend(self, feature_name: str, data: dict) -> dict:
        """Tracking der Adoption ueber Zeit."""
        users = data.get("unique_users", [])
        if len(users) < 3:
            return {"direction": "insufficient_data", "change": 0}

        recent = users[-3:]
        earlier = users[:3] if len(users) >= 6 else users[:len(users) // 2 + 1]

        avg_recent = sum(recent) / len(recent)
        avg_earlier = sum(earlier) / len(earlier)

        if avg_earlier == 0:
            return {"direction": "stable", "change": 0}

        change = (avg_recent - avg_earlier) / avg_earlier
        if change > 0.15:
            direction = "rising"
        elif change < -0.15:
            direction = "declining"
        else:
            direction = "stable"

        return {"direction": direction, "change": round(change, 3)}

    def _categorize_feature(self, adoption: float) -> str:
        """Kategorisiert ein Feature basierend auf Adoption Rate."""
        if adoption >= self.ADOPTION_STAR_THRESHOLD:
            return "star"
        elif adoption < self.ADOPTION_UNUSED_THRESHOLD:
            return "unused"
        return "normal"

    def _calculate_adoption_rate(self, feature_name: str, data: list[dict],
                                 dau: int = 1) -> float:
        """Berechnet Adoption Rate fuer ein Feature."""
        if not data:
            return 0.0
        latest = data[-1]
        usage = latest.get("firebase_metrics", {}).get("feature_usage", {})
        count = usage.get(feature_name, 0)
        unique_est = int(count * 0.4)
        return min(1.0, unique_est / max(dau, 1))

    def _detect_unused_features(self, features: dict,
                                threshold: float = None) -> list[str]:
        """Features mit Adoption unter Threshold."""
        threshold = threshold or self.ADOPTION_UNUSED_THRESHOLD
        return [name for name, info in features.items()
                if info.get("adoption_rate", 0) < threshold]

    def _detect_star_features(self, features: dict,
                              threshold: float = None) -> list[str]:
        """Features mit Adoption ueber Threshold."""
        threshold = threshold or self.ADOPTION_STAR_THRESHOLD
        return [name for name, info in features.items()
                if info.get("adoption_rate", 0) >= threshold]

    def _build_summary(self, features: dict) -> dict:
        """Baut Summary-Objekt."""
        return {
            "total_features_tracked": len(features),
            "star_features": [n for n, f in features.items() if f["category"] == "star"],
            "unused_features": [n for n, f in features.items() if f["category"] == "unused"],
            "rising_features": [n for n, f in features.items() if f["trend"] == "rising"],
            "declining_features": [n for n, f in features.items() if f["trend"] == "declining"],
        }

    def _generate_recommendations(self, features: dict) -> list[dict]:
        """Generiert Empfehlungen basierend auf Feature-Analyse."""
        recs = []

        for name, info in features.items():
            if info["category"] == "unused":
                recs.append({
                    "feature": name,
                    "type": "unused",
                    "message": f"{name} has only {info['adoption_rate']:.0%} adoption -- poorly placed, poorly explained, or unnecessary?",
                    "suggested_action": f"Make {name} more prominent or consider removing from next update",
                })

            if info["trend"] == "rising" and info["category"] != "star":
                recs.append({
                    "feature": name,
                    "type": "rising",
                    "message": f"{name} adoption is rising -- users want this",
                    "suggested_action": f"Expand {name} and feature it more prominently in onboarding",
                })

            if info["trend"] == "declining" and info["category"] == "star":
                recs.append({
                    "feature": name,
                    "type": "declining_star",
                    "message": f"{name} was a star feature but adoption is declining",
                    "suggested_action": f"Investigate why {name} usage is dropping -- UX regression?",
                })

        return recs

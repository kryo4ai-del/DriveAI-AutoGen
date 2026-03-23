"""Quality scoring system for external services.

Tracks success rate, speed, and optional CEO feedback to produce
a 0.0-10.0 quality score per service. Scores are persisted to JSON
and automatically updated after every ServiceResult.
"""

import json
import logging
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Optional
from datetime import datetime

logger = logging.getLogger(__name__)

SCORE_FILE = "quality_scores.json"

CATEGORY_SPEED_BASELINES = {
    "image": 5000,
    "sound": 3000,
    "video": 15000,
    "animation": 5000,
}

DEFAULT_SCORE = 5.0
RELIABLE_THRESHOLD = 5


@dataclass
class ServiceStats:
    """Accumulated statistics for one service."""
    service_id: str
    total_calls: int = 0
    successful_calls: int = 0
    failed_calls: int = 0
    total_duration_ms: int = 0
    avg_duration_ms: float = 0.0
    last_call: Optional[str] = None
    last_error: Optional[str] = None
    consecutive_failures: int = 0
    ceo_feedback_score: Optional[float] = None
    computed_score: float = DEFAULT_SCORE
    reliable: bool = False


class QualityScorer:
    """Evaluates and persists quality scores for external services."""

    def __init__(self, data_dir: str = None):
        if data_dir is None:
            data_dir = str(Path(__file__).parent)
        self._data_dir = Path(data_dir)
        self._score_file = self._data_dir / SCORE_FILE
        self._stats: dict[str, ServiceStats] = {}
        self._load()

    # ------------------------------------------------------------------
    # Persistence
    # ------------------------------------------------------------------

    def _load(self):
        if not self._score_file.exists():
            self._stats = {}
            return
        try:
            raw = json.loads(self._score_file.read_text(encoding="utf-8"))
            for sid, data in raw.items():
                self._stats[sid] = ServiceStats(**data)
        except (json.JSONDecodeError, TypeError) as e:
            logger.warning("Failed to load quality scores: %s", e)
            self._stats = {}

    def _save(self):
        try:
            self._data_dir.mkdir(parents=True, exist_ok=True)
            payload = {sid: asdict(st) for sid, st in self._stats.items()}
            self._score_file.write_text(
                json.dumps(payload, indent=2, ensure_ascii=False),
                encoding="utf-8",
            )
        except OSError as e:
            logger.error("Failed to save quality scores: %s", e)

    # ------------------------------------------------------------------
    # Recording
    # ------------------------------------------------------------------

    def record_result(self, result, category: str = "image"):
        sid = result.service_id
        if sid not in self._stats:
            self._stats[sid] = ServiceStats(service_id=sid)
        st = self._stats[sid]

        st.total_calls += 1
        st.last_call = datetime.now().isoformat(timespec="seconds")

        if result.success:
            st.successful_calls += 1
            st.consecutive_failures = 0
            st.total_duration_ms += result.duration_ms
            st.avg_duration_ms = st.total_duration_ms / st.successful_calls
        else:
            st.failed_calls += 1
            st.consecutive_failures += 1
            st.last_error = result.error_message

        st.reliable = st.total_calls >= RELIABLE_THRESHOLD
        st.computed_score = self._calculate_score(st, category)
        self._save()

    # ------------------------------------------------------------------
    # Score calculation
    # ------------------------------------------------------------------

    def _calculate_score(self, stats: ServiceStats, category: str) -> float:
        if stats.total_calls == 0:
            return DEFAULT_SCORE

        # 1. Success component (0-10)
        success_rate = stats.successful_calls / stats.total_calls
        success_component = success_rate * 10.0

        # 2. Speed component (0-10)
        baseline = CATEGORY_SPEED_BASELINES.get(category, 5000)
        avg = stats.avg_duration_ms
        if avg <= 0 or stats.successful_calls == 0:
            speed_score = 5.0
        elif avg <= baseline:
            speed_score = 10.0
        elif avg >= baseline * 3:
            speed_score = 0.0
        else:
            speed_score = 10.0 * (1.0 - (avg - baseline) / (baseline * 2))

        # 3. CEO feedback
        ceo = stats.ceo_feedback_score

        # 4. Weighted sum
        if ceo is not None:
            final = success_component * 0.5 + speed_score * 0.3 + ceo * 0.2
        else:
            final = success_component * 0.625 + speed_score * 0.375

        return max(0.0, min(10.0, round(final, 2)))

    # ------------------------------------------------------------------
    # Read
    # ------------------------------------------------------------------

    def get_score(self, service_id: str) -> float:
        st = self._stats.get(service_id)
        return st.computed_score if st else DEFAULT_SCORE

    def get_stats(self, service_id: str) -> Optional[ServiceStats]:
        return self._stats.get(service_id)

    def get_ranking(self, category: str, registry=None) -> list[tuple[str, float]]:
        if registry is not None:
            active = registry.get_active_services(category)
            sids = {s.service_id for s in active}
            ranked = [(sid, st.computed_score) for sid, st in self._stats.items() if sid in sids]
        else:
            ranked = [(sid, st.computed_score) for sid, st in self._stats.items()]
        ranked.sort(key=lambda x: -x[1])
        return ranked

    # ------------------------------------------------------------------
    # Write
    # ------------------------------------------------------------------

    def set_ceo_feedback(self, service_id: str, score: float) -> bool:
        if score < 0.0 or score > 10.0:
            logger.warning("CEO feedback score %.1f out of range [0,10]", score)
            return False
        if service_id not in self._stats:
            self._stats[service_id] = ServiceStats(service_id=service_id)
        self._stats[service_id].ceo_feedback_score = score
        # Recalculate with a default category — the category is only for speed baseline
        # and CEO feedback doesn't change speed, so "image" is fine as default
        self._stats[service_id].computed_score = self._calculate_score(
            self._stats[service_id], "image"
        )
        self._save()
        return True

    def reset_stats(self, service_id: str) -> bool:
        if service_id not in self._stats:
            return False
        self._stats[service_id] = ServiceStats(service_id=service_id)
        self._save()
        return True

    # ------------------------------------------------------------------
    # Display
    # ------------------------------------------------------------------

    def get_summary(self) -> str:
        if not self._stats:
            return "No services tracked yet."
        lines = []
        for sid, st in sorted(self._stats.items(), key=lambda x: -x[1].computed_score):
            rate = (st.successful_calls / st.total_calls * 100) if st.total_calls > 0 else 0
            ceo_str = f" ceo={st.ceo_feedback_score:.1f}" if st.ceo_feedback_score is not None else ""
            lines.append(
                f"  {sid}: score={st.computed_score:.1f} "
                f"calls={st.total_calls} success={rate:.0f}% "
                f"avg={st.avg_duration_ms:.0f}ms "
                f"reliable={st.reliable}{ceo_str}"
            )
        return "\n".join(lines)

"""Self-Healing Utilities — retry_on_failure Decorator + safe_execute.

Wiederverwendbare Error-Recovery-Bausteine fuer das gesamte
Live Operations System.
"""

import functools
import time
import traceback
from datetime import datetime, timezone
from typing import Any, Callable, Optional

_PREFIX = "[Self-Healing]"


def retry_on_failure(
    max_retries: int = 3,
    delay_seconds: float = 1.0,
    backoff_factor: float = 2.0,
    exceptions: tuple = (Exception,),
    fallback: Any = None,
) -> Callable:
    """Decorator: Wiederholt eine Funktion bei Fehler mit exponentiellem Backoff.

    Args:
        max_retries: Maximale Versuche (inkl. erstem)
        delay_seconds: Initiale Wartezeit zwischen Versuchen
        backoff_factor: Multiplikator fuer Wartezeit pro Retry
        exceptions: Tuple der abgefangenen Exception-Typen
        fallback: Rueckgabewert wenn alle Retries fehlschlagen (None = Exception weiterwerfen)

    Usage:
        @retry_on_failure(max_retries=3, delay_seconds=0.5)
        def fragile_operation():
            ...
    """
    def decorator(func: Callable) -> Callable:
        @functools.wraps(func)
        def wrapper(*args, **kwargs):
            last_error = None
            current_delay = delay_seconds

            for attempt in range(1, max_retries + 1):
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    last_error = e
                    if attempt < max_retries:
                        print(f"{_PREFIX} {func.__name__} Versuch {attempt}/{max_retries} "
                              f"fehlgeschlagen: {e}. Retry in {current_delay:.1f}s...")
                        time.sleep(current_delay)
                        current_delay *= backoff_factor
                    else:
                        print(f"{_PREFIX} {func.__name__} alle {max_retries} Versuche "
                              f"fehlgeschlagen: {e}")

            if fallback is not None:
                return fallback
            raise last_error

        return wrapper
    return decorator


def safe_execute(
    func: Callable,
    *args,
    error_value: Any = None,
    log_prefix: str = "",
    **kwargs,
) -> tuple[Any, Optional[str]]:
    """Fuehrt eine Funktion sicher aus und faengt Fehler ab.

    Returns:
        (result, error_message) — error_message ist None bei Erfolg.

    Usage:
        result, err = safe_execute(risky_function, arg1, arg2)
        if err:
            print(f"Fehler: {err}")
    """
    prefix = log_prefix or func.__name__
    try:
        result = func(*args, **kwargs)
        return result, None
    except Exception as e:
        error_msg = f"{prefix}: {type(e).__name__}: {e}"
        print(f"{_PREFIX} {error_msg}")
        return error_value, error_msg


class ErrorLog:
    """In-Memory Error Log fuer Self-Healing Tracking."""

    def __init__(self, max_entries: int = 100) -> None:
        self._entries: list[dict] = []
        self._max = max_entries

    def log(self, component: str, error: str, action: str = "logged", resolved: bool = False) -> None:
        """Loggt einen Fehler."""
        entry = {
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "component": component,
            "error": error,
            "action": action,
            "resolved": resolved,
        }
        self._entries.append(entry)
        if len(self._entries) > self._max:
            self._entries = self._entries[-self._max:]

    def get_recent(self, limit: int = 20) -> list[dict]:
        """Gibt die letzten N Eintraege zurueck."""
        return list(reversed(self._entries[-limit:]))

    def get_unresolved(self) -> list[dict]:
        """Gibt alle ungeloesten Fehler zurueck."""
        return [e for e in self._entries if not e["resolved"]]

    def count_errors(self, component: str | None = None, minutes: int = 60) -> int:
        """Zaehlt Fehler der letzten N Minuten."""
        from datetime import timedelta
        cutoff = datetime.now(timezone.utc) - timedelta(minutes=minutes)
        count = 0
        for e in self._entries:
            try:
                ts = datetime.fromisoformat(e["timestamp"])
                if ts >= cutoff:
                    if component is None or e["component"] == component:
                        count += 1
            except (ValueError, KeyError):
                pass
        return count

    def clear(self) -> None:
        self._entries.clear()

    @property
    def total(self) -> int:
        return len(self._entries)

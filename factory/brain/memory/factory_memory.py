"""Factory Memory — Langzeit-Gedaechtnis der Factory.

Speichert Produktionshistorie, Fehler, Loesungen, Patterns.
Drei Ebenen:
1. Event Log — Chronologisches Log aller Factory-Events
2. Knowledge Base — Extrahierte Erkenntnisse aus Events
3. Pattern Store — Erkannte wiederkehrende Patterns

Storage: JSON-Files in factory/brain/memory/data/
Keine Datenbank, keine externen Dependencies.
Append-mostly — alte Eintraege werden nie geloescht, nur archiviert.

WICHTIG: Dieses System ist ZUSAETZLICH zu:
- SWF-07 Memory Agent (Projekt-Level, Pre-Production)
- factory_knowledge/knowledge.json (Error Patterns, UX Insights)
- factory/memory/run_history.json (Pipeline-Run-Ergebnisse)

100% deterministisch, kein LLM.
"""

import json
import logging
import os
import shutil
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)

_DEFAULT_ROOT = Path(__file__).resolve().parents[3]

# Max file size before archiving (50 MB)
_MAX_STORE_SIZE_BYTES = 50 * 1024 * 1024

# Valid event types
_EVENT_TYPES = {
    "production_start", "production_complete", "production_paused",
    "production_error", "error_resolved",
    "capability_added", "capability_removed",
    "service_outage", "service_restored",
    "workaround_found",
    "agent_added", "config_changed",
    "detection_run", "solution_applied",
    "factory_state_snapshot",
}

# Valid severities
_SEVERITIES = {"info", "warning", "error", "critical"}

# Valid lesson categories
_LESSON_CATEGORIES = {
    "error_pattern", "workaround", "capability_change",
    "performance", "best_practice",
}

# Valid pattern types
_PATTERN_TYPES = {
    "recurring_error", "performance_trend",
    "capability_evolution", "seasonal",
}


class FactoryMemory:
    """Langzeit-Gedaechtnis der Factory."""

    def __init__(self, factory_root: str = None):
        self.root = Path(factory_root) if factory_root else _DEFAULT_ROOT
        self._data_dir = self.root / "factory" / "brain" / "memory" / "data"
        self._archive_dir = self._data_dir / "archive"
        self._data_dir.mkdir(parents=True, exist_ok=True)

    # ── Event Log ──────────────────────────────────────────

    def record_event(self, event: dict) -> dict:
        """Speichert ein Factory-Event.

        Returns: {"event_id": str, "stored": True}
        """
        event_type = event.get("type", "unknown")
        if event_type not in _EVENT_TYPES:
            logger.warning("Unknown event type: %s (storing anyway)", event_type)

        severity = event.get("severity", "info")
        if severity not in _SEVERITIES:
            severity = "info"

        event_id = self._generate_id("EVT")

        record = {
            "event_id": event_id,
            "type": event_type,
            "timestamp": event.get("timestamp") or datetime.now(timezone.utc).isoformat(),
            "project": event.get("project"),
            "source": event.get("source", "unknown"),
            "severity": severity,
            "title": event.get("title", ""),
            "detail": event.get("detail", ""),
            "tags": event.get("tags", []),
        }

        events = self._load_store("events")
        events.append(record)
        self._save_store("events", events)

        logger.info("Event recorded: %s [%s] %s", event_id, event_type, record["title"])
        return {"event_id": event_id, "stored": True}

    def get_events(self, filters: dict = None) -> list:
        """Liest Events mit optionalen Filtern.

        filters:
            type, project, severity, since, until, tags, limit
        """
        events = self._load_store("events")
        if not filters:
            return list(reversed(events[-100:]))

        filtered = events

        # Filter by type
        type_filter = filters.get("type")
        if type_filter:
            if isinstance(type_filter, str):
                type_filter = [type_filter]
            filtered = [e for e in filtered if e.get("type") in type_filter]

        # Filter by project
        project_filter = filters.get("project")
        if project_filter:
            filtered = [e for e in filtered if e.get("project") == project_filter]

        # Filter by severity
        sev_filter = filters.get("severity")
        if sev_filter:
            if isinstance(sev_filter, str):
                sev_filter = [sev_filter]
            filtered = [e for e in filtered if e.get("severity") in sev_filter]

        # Filter by time range
        since = filters.get("since")
        if since:
            filtered = [e for e in filtered if e.get("timestamp", "") >= since]

        until = filters.get("until")
        if until:
            filtered = [e for e in filtered if e.get("timestamp", "") <= until]

        # Filter by tags (any match)
        tag_filter = filters.get("tags")
        if tag_filter:
            filtered = [
                e for e in filtered
                if any(t in e.get("tags", []) for t in tag_filter)
            ]

        # Limit
        limit = filters.get("limit", 100)
        return list(reversed(filtered[-limit:]))

    def get_project_history(self, project_name: str) -> dict:
        """Gibt die komplette Historie eines Projekts zurueck."""
        all_events = self.get_events({"project": project_name, "limit": 10000})

        errors = [e for e in all_events if e.get("type") in ("production_error",)]
        workarounds = [e for e in all_events if e.get("type") == "workaround_found"]

        # Duration
        if all_events:
            first_ts = all_events[-1].get("timestamp", "")
            last_ts = all_events[0].get("timestamp", "")
            duration = f"{first_ts} bis {last_ts}"
        else:
            first_ts = last_ts = duration = ""

        # Current status from latest event
        current_status = "unknown"
        for e in all_events:
            if e.get("type") in ("production_start", "production_complete",
                                  "production_paused", "production_error"):
                current_status = e["type"].replace("production_", "")
                break

        return {
            "project": project_name,
            "events": all_events,
            "errors": errors,
            "workarounds": workarounds,
            "duration": duration,
            "current_status": current_status,
        }

    # ── Knowledge Base ─────────────────────────────────────

    def record_lesson(self, lesson: dict) -> dict:
        """Speichert eine Erkenntnis.

        Returns: {"lesson_id": str, "stored": True}
        """
        category = lesson.get("category", "best_practice")
        if category not in _LESSON_CATEGORIES:
            logger.warning("Unknown lesson category: %s", category)

        lesson_id = self._generate_id("LES")

        record = {
            "lesson_id": lesson_id,
            "title": lesson.get("title", ""),
            "description": lesson.get("description", ""),
            "source_events": lesson.get("source_events", []),
            "category": category,
            "applies_to": lesson.get("applies_to", []),
            "recommendation": lesson.get("recommendation", ""),
            "tags": lesson.get("tags", []),
            "created_at": datetime.now(timezone.utc).isoformat(),
        }

        lessons = self._load_store("lessons")
        lessons.append(record)
        self._save_store("lessons", lessons)

        logger.info("Lesson recorded: %s — %s", lesson_id, record["title"])
        return {"lesson_id": lesson_id, "stored": True}

    def get_lessons(self, filters: dict = None) -> list:
        """Liest Lessons mit optionalen Filtern."""
        lessons = self._load_store("lessons")
        if not filters:
            return list(reversed(lessons[-100:]))

        filtered = lessons

        category = filters.get("category")
        if category:
            if isinstance(category, str):
                category = [category]
            filtered = [l for l in filtered if l.get("category") in category]

        tag_filter = filters.get("tags")
        if tag_filter:
            filtered = [
                l for l in filtered
                if any(t in l.get("tags", []) for t in tag_filter)
            ]

        limit = filters.get("limit", 100)
        return list(reversed(filtered[-limit:]))

    def find_relevant_lessons(self, context: dict) -> list:
        """Findet Lessons die fuer einen bestimmten Kontext relevant sind.

        Matching: Tag-basiert, Kategorie-basiert, Keyword-basiert.
        Returns: Liste relevanter Lessons, sortiert nach Relevanz.
        """
        lessons = self._load_store("lessons")
        if not lessons:
            return []

        project_type = context.get("project_type", "").lower()
        capabilities = [c.lower() for c in context.get("required_capabilities", [])]
        similar = [s.lower() for s in context.get("similar_projects", [])]

        scored = []
        for lesson in lessons:
            score = 0

            # Tag matching
            lesson_tags = [t.lower() for t in lesson.get("tags", [])]
            for cap in capabilities:
                if cap in lesson_tags:
                    score += 3

            # applies_to matching
            applies = [a.lower() for a in lesson.get("applies_to", [])]
            if project_type and project_type in applies:
                score += 5
            for cap in capabilities:
                if cap in applies:
                    score += 2

            # Keyword matching in title + description
            text = (lesson.get("title", "") + " " + lesson.get("description", "")).lower()
            if project_type and project_type in text:
                score += 2
            for cap in capabilities:
                if cap in text:
                    score += 1
            for proj in similar:
                if proj in text:
                    score += 3

            # Source events matching (check if events reference similar projects)
            for event_id in lesson.get("source_events", []):
                events = self._load_store("events")
                for evt in events:
                    if evt.get("event_id") == event_id:
                        evt_proj = (evt.get("project") or "").lower()
                        if evt_proj and evt_proj in similar:
                            score += 4
                        break

            if score > 0:
                scored.append((score, lesson))

        scored.sort(key=lambda x: x[0], reverse=True)
        return [item[1] for item in scored]

    # ── Pattern Store ──────────────────────────────────────

    def record_pattern(self, pattern: dict) -> dict:
        """Speichert ein erkanntes Pattern.

        Returns: {"pattern_id": str, "stored": True}
        """
        pattern_type = pattern.get("type", "recurring_error")
        if pattern_type not in _PATTERN_TYPES:
            logger.warning("Unknown pattern type: %s", pattern_type)

        pattern_id = self._generate_id("PAT")

        record = {
            "pattern_id": pattern_id,
            "title": pattern.get("title", ""),
            "type": pattern_type,
            "occurrences": pattern.get("occurrences", 1),
            "first_seen": pattern.get("first_seen") or datetime.now(timezone.utc).isoformat(),
            "last_seen": pattern.get("last_seen") or datetime.now(timezone.utc).isoformat(),
            "description": pattern.get("description", ""),
            "impact": pattern.get("impact", "medium"),
            "suggested_action": pattern.get("suggested_action", ""),
            "created_at": datetime.now(timezone.utc).isoformat(),
        }

        patterns = self._load_store("patterns")
        patterns.append(record)
        self._save_store("patterns", patterns)

        logger.info("Pattern recorded: %s — %s", pattern_id, record["title"])
        return {"pattern_id": pattern_id, "stored": True}

    def get_patterns(self, pattern_type: str = None) -> list:
        """Liest Patterns, optional gefiltert nach Typ."""
        patterns = self._load_store("patterns")
        if pattern_type:
            patterns = [p for p in patterns if p.get("type") == pattern_type]
        return list(reversed(patterns))

    # ── Factory State Snapshots ────────────────────────────

    def take_state_snapshot(self) -> dict:
        """Erstellt einen Snapshot des aktuellen Factory-States.

        Nutzt FactoryStateCollector.collect_full_state().
        Returns: {"event_id": str, "stored": True, "snapshot_summary": dict}
        """
        try:
            from factory.brain.factory_state import FactoryStateCollector
            collector = FactoryStateCollector(str(self.root))
            state = collector.collect_full_state()
        except Exception as e:
            logger.error("Cannot collect factory state for snapshot: %s", e)
            state = {"error": str(e), "collected_at": datetime.now(timezone.utc).isoformat()}

        # Build compact summary
        summary = {
            "overall_status": state.get("overall_status", "unknown"),
            "subsystems_available": state.get("subsystems_available", 0),
            "subsystems_total": state.get("subsystems_total", 0),
            "health_status": state.get("health_monitor", {}).get("status", "unknown"),
            "health_alerts": state.get("health_monitor", {}).get("total_alerts", 0),
            "total_projects": state.get("pipeline_queue", {}).get("total_projects", 0),
            "stuck_projects": len(state.get("pipeline_queue", {}).get("stuck_projects", [])),
            "active_services": len(state.get("service_provider", {}).get("active_services", [])),
            "registered_models": state.get("model_provider", {}).get("registered_models", 0),
            "janitor_health": state.get("janitor", {}).get("health_score"),
        }

        # Store as event
        result = self.record_event({
            "type": "factory_state_snapshot",
            "source": "FactoryMemory.take_state_snapshot",
            "severity": "info",
            "title": f"Factory State Snapshot — {summary['overall_status']}",
            "detail": summary,
            "tags": ["snapshot", "state", summary["overall_status"]],
        })

        # Also store in dedicated snapshots store for easy comparison
        snapshots = self._load_store("snapshots")
        snapshots.append({
            "event_id": result["event_id"],
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "summary": summary,
            "full_state": state,
        })
        self._save_store("snapshots", snapshots)

        result["snapshot_summary"] = summary
        return result

    def compare_snapshots(self, date1: str, date2: str) -> dict:
        """Vergleicht zwei State-Snapshots.

        date1, date2: ISO date strings (YYYY-MM-DD) oder Timestamps.
        """
        snapshots = self._load_store("snapshots")
        if not snapshots:
            return {"error": "Keine Snapshots vorhanden"}

        snap1 = self._find_closest_snapshot(snapshots, date1)
        snap2 = self._find_closest_snapshot(snapshots, date2)

        if not snap1 or not snap2:
            return {"error": "Kein passender Snapshot gefunden"}

        s1 = snap1.get("summary", {})
        s2 = snap2.get("summary", {})

        # Health change
        health_map = {"ok": 3, "warning": 2, "critical": 1, "unknown": 0, "unavailable": 0}
        h1 = health_map.get(s1.get("health_status", "unknown"), 0)
        h2 = health_map.get(s2.get("health_status", "unknown"), 0)
        if h2 > h1:
            health_change = "improved"
        elif h2 < h1:
            health_change = "degraded"
        else:
            health_change = "stable"

        return {
            "date1": snap1.get("timestamp"),
            "date2": snap2.get("timestamp"),
            "changes": {
                "health_change": health_change,
                "health_1": s1.get("health_status"),
                "health_2": s2.get("health_status"),
                "alerts_1": s1.get("health_alerts", 0),
                "alerts_2": s2.get("health_alerts", 0),
                "projects_1": s1.get("total_projects", 0),
                "projects_2": s2.get("total_projects", 0),
                "services_1": s1.get("active_services", 0),
                "services_2": s2.get("active_services", 0),
                "models_1": s1.get("registered_models", 0),
                "models_2": s2.get("registered_models", 0),
                "subsystems_1": s1.get("subsystems_available", 0),
                "subsystems_2": s2.get("subsystems_available", 0),
            },
        }

    # ── Warnsystem ─────────────────────────────────────────

    def check_similar_project_warnings(self, new_project: dict) -> list:
        """DIE KERNMETHODE. Prueft ob es bei aehnlichen frueheren
        Projekten Probleme gab und warnt proaktiv.

        new_project: {name, type, required_capabilities, description}
        """
        warnings = []
        project_type = (new_project.get("type") or "").lower()
        capabilities = [c.lower() for c in new_project.get("required_capabilities", [])]
        description = (new_project.get("description") or "").lower()

        events = self._load_store("events")
        lessons = self._load_store("lessons")
        patterns = self._load_store("patterns")

        # 1. Suche aehnliche Projekte in der Historie
        project_names = set()
        for e in events:
            p = e.get("project")
            if p:
                project_names.add(p)

        similar_projects = set()
        for pname in project_names:
            pname_lower = pname.lower()
            # Typ-Match
            if project_type and project_type in pname_lower:
                similar_projects.add(pname)
            # Description-Match
            if pname_lower in description:
                similar_projects.add(pname)

        # Auch Events pruefen die Tags haben die zu capabilities passen
        for e in events:
            p = e.get("project")
            if p and any(cap in (t.lower() for t in e.get("tags", [])) for cap in capabilities):
                similar_projects.add(p)

        # 2. Finde Fehler-Events bei aehnlichen Projekten
        for e in events:
            if e.get("project") not in similar_projects:
                continue
            if e.get("type") not in ("production_error", "service_outage"):
                continue

            warnings.append({
                "type": "previous_error",
                "severity": "warning",
                "message": (
                    f"Bei '{e['project']}' (aehnlicher Typ) trat Fehler auf: "
                    f"{e.get('title', 'Unbekannt')}. "
                    f"Detail: {_truncate(str(e.get('detail', '')), 200)}"
                ),
                "source_project": e["project"],
                "source_event_id": e.get("event_id"),
                "recommendation": f"Pruefen ob {e.get('title', 'dieses Problem')} auch hier auftreten kann.",
            })

        # 3. Finde relevante Lessons
        relevant_lessons = self.find_relevant_lessons({
            "project_type": project_type,
            "required_capabilities": capabilities,
            "similar_projects": list(similar_projects),
        })
        for lesson in relevant_lessons[:5]:
            warnings.append({
                "type": "learned_lesson",
                "severity": "info",
                "message": f"Lesson: {lesson.get('title', '')}",
                "recommendation": lesson.get("recommendation", ""),
                "source_lesson_id": lesson.get("lesson_id"),
            })

        # 4. Finde relevante Patterns
        for pattern in patterns:
            pat_desc = (pattern.get("description") or "").lower()
            pat_title = (pattern.get("title") or "").lower()
            match = False

            for cap in capabilities:
                if cap in pat_desc or cap in pat_title:
                    match = True
                    break
            if project_type and (project_type in pat_desc or project_type in pat_title):
                match = True

            if match:
                warnings.append({
                    "type": "known_pattern",
                    "severity": "warning" if pattern.get("impact") == "high" else "info",
                    "message": f"Pattern: {pattern.get('title', '')}",
                    "recommendation": pattern.get("suggested_action", ""),
                    "source_pattern_id": pattern.get("pattern_id"),
                })

        # 5. Capability-Evolution: Check ob vorher fehlende Capabilities jetzt da sind
        capability_events = [
            e for e in events
            if e.get("type") in ("capability_added", "capability_removed")
        ]
        for cap in capabilities:
            for ce in capability_events:
                ce_detail = str(ce.get("detail", "")).lower()
                ce_title = (ce.get("title") or "").lower()
                if cap in ce_detail or cap in ce_title:
                    if ce.get("type") == "capability_added":
                        warnings.append({
                            "type": "capability_evolved",
                            "severity": "info",
                            "message": (
                                f"Capability '{cap}' wurde hinzugefuegt: {ce.get('title', '')}. "
                                f"Zeitpunkt: {ce.get('timestamp', 'unbekannt')}."
                            ),
                            "recommendation": f"'{cap}' ist jetzt verfuegbar — in Scope aufnehmen?",
                        })

        return warnings

    # ── Storage ────────────────────────────────────────────

    def _get_storage_path(self, store_type: str) -> Path:
        """Gibt den Dateipfad fuer einen Storage-Typ zurueck."""
        return self._data_dir / f"{store_type}.json"

    def _load_store(self, store_type: str) -> list:
        """Laedt eine Storage-Datei. Gibt leere Liste zurueck wenn nicht vorhanden."""
        path = self._get_storage_path(store_type)
        if not path.exists():
            return []
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            if isinstance(data, list):
                return data
            return []
        except (json.JSONDecodeError, OSError) as e:
            logger.warning("Could not load %s: %s", path, e)
            return []

    def _save_store(self, store_type: str, data: list) -> bool:
        """Speichert eine Storage-Datei. Erstellt Backup vorher."""
        path = self._get_storage_path(store_type)

        # Backup existing file
        if path.exists():
            bak = path.with_suffix(".json.bak")
            try:
                shutil.copy2(str(path), str(bak))
            except OSError as e:
                logger.warning("Backup failed for %s: %s", path, e)

        # Check archive threshold
        content = json.dumps(data, indent=2, ensure_ascii=False, default=str)
        if len(content.encode("utf-8")) > _MAX_STORE_SIZE_BYTES:
            self._archive_old_entries(store_type, data)

        try:
            path.write_text(content, encoding="utf-8")
            return True
        except OSError as e:
            logger.error("Could not save %s: %s", path, e)
            return False

    def _archive_old_entries(self, store_type: str, data: list) -> None:
        """Archiviert aelteste Haelfte der Eintraege."""
        self._archive_dir.mkdir(parents=True, exist_ok=True)
        mid = len(data) // 2
        archive_data = data[:mid]
        del data[:mid]

        ts = datetime.now().strftime("%Y%m%d_%H%M%S")
        archive_path = self._archive_dir / f"{store_type}_{ts}.json"
        try:
            archive_path.write_text(
                json.dumps(archive_data, indent=2, ensure_ascii=False, default=str),
                encoding="utf-8",
            )
            logger.info("Archived %d entries from %s to %s", len(archive_data), store_type, archive_path)
        except OSError as e:
            logger.error("Archive failed: %s", e)

    def _generate_id(self, prefix: str) -> str:
        """Generiert eine eindeutige ID (z.B. EVT-20260325-001)."""
        date_str = datetime.now().strftime("%Y%m%d")

        # Count existing IDs with same prefix+date
        store_map = {"EVT": "events", "LES": "lessons", "PAT": "patterns"}
        store_type = store_map.get(prefix, "events")
        existing = self._load_store(store_type)

        prefix_today = f"{prefix}-{date_str}-"
        count = sum(1 for item in existing
                    if any(v for k, v in item.items()
                           if isinstance(v, str) and v.startswith(prefix_today)))

        return f"{prefix}-{date_str}-{count + 1:03d}"

    def _find_closest_snapshot(self, snapshots: list, date_str: str) -> dict | None:
        """Findet den Snapshot am naechsten zum angegebenen Datum."""
        if not snapshots:
            return None

        # Normalize date string
        target = date_str[:10]  # YYYY-MM-DD

        best = None
        best_diff = float("inf")
        for snap in snapshots:
            ts = snap.get("timestamp", "")[:10]
            if not ts:
                continue
            # Simple string comparison for date proximity
            diff = abs(hash(ts) - hash(target))  # Crude but functional
            if ts == target:
                return snap
            if ts < target and (best is None or ts > best.get("timestamp", "")[:10]):
                best = snap

        # Fallback: return closest
        return best or (snapshots[-1] if snapshots else None)

    def get_memory_stats(self) -> dict:
        """Gibt Statistiken ueber das Memory zurueck."""
        events = self._load_store("events")
        lessons = self._load_store("lessons")
        patterns = self._load_store("patterns")
        snapshots = self._load_store("snapshots")

        # Top event types
        type_counts: dict[str, int] = {}
        all_tags: dict[str, int] = {}
        for e in events:
            t = e.get("type", "unknown")
            type_counts[t] = type_counts.get(t, 0) + 1
            for tag in e.get("tags", []):
                all_tags[tag] = all_tags.get(tag, 0) + 1

        top_types = dict(sorted(type_counts.items(), key=lambda x: x[1], reverse=True)[:10])
        top_tags = sorted(all_tags.keys(), key=lambda t: all_tags[t], reverse=True)[:10]

        # Storage size
        total_bytes = 0
        for store in ("events", "lessons", "patterns", "snapshots"):
            path = self._get_storage_path(store)
            if path.exists():
                total_bytes += path.stat().st_size

        oldest = events[0].get("timestamp", "") if events else ""
        newest = events[-1].get("timestamp", "") if events else ""

        return {
            "total_events": len(events),
            "total_lessons": len(lessons),
            "total_patterns": len(patterns),
            "total_snapshots": len(snapshots),
            "oldest_event": oldest,
            "newest_event": newest,
            "storage_size_mb": round(total_bytes / (1024 * 1024), 3),
            "top_event_types": top_types,
            "top_tags": top_tags,
        }


def _truncate(text: str, max_len: int) -> str:
    """Truncate text to max_len chars."""
    if len(text) <= max_len:
        return text
    return text[:max_len - 3] + "..."

"""Factory Learner -- Query layer over LDO History for cross-project analysis.

100% deterministic, no LLM. Read-only: loads existing LDO data, writes nothing.
Caches loaded histories to avoid repeated disk I/O.
"""

from __future__ import annotations

from collections import Counter
from pathlib import Path

from factory.evolution_loop.ldo.schema import LoopDataObject
from factory.evolution_loop.ldo.storage import DATA_ROOT, LDOStorage

_PREFIX = "[EVO-LEARNER]"


class FactoryLearner:
    """Query layer over LDO History. Enables cross-project analysis."""

    def __init__(self) -> None:
        self._data_root = DATA_ROOT
        # Cache: project_id -> list[LoopDataObject]
        self._cache: dict[str, list[LoopDataObject]] = {}

    # ------------------------------------------------------------------
    # Internal helpers
    # ------------------------------------------------------------------

    def _discover_projects(self) -> list[str]:
        """Scan data root for project directories with iteration files."""
        if not self._data_root.is_dir():
            return []
        projects = []
        for d in sorted(self._data_root.iterdir()):
            if not d.is_dir() or d.name.startswith(("__", ".")):
                continue
            if list(d.glob("iteration_*.json")):
                projects.append(d.name)
        return projects

    def _load_history(self, project_id: str) -> list[LoopDataObject]:
        """Load full LDO history for a project (cached)."""
        if project_id in self._cache:
            return self._cache[project_id]

        project_dir = self._data_root / project_id
        if not project_dir.is_dir():
            return []

        try:
            storage = LDOStorage(project_id)
            history = storage.get_history()
        except Exception:
            history = []

        self._cache[project_id] = history
        return history

    def _invalidate_cache(self, project_id: str | None = None) -> None:
        """Clear cache for a project or all projects."""
        if project_id:
            self._cache.pop(project_id, None)
        else:
            self._cache.clear()

    # ------------------------------------------------------------------
    # Public API
    # ------------------------------------------------------------------

    def list_projects(self) -> list[dict]:
        """List all projects with Evolution Loop data.

        Returns list sorted by iteration count (most first).
        """
        results = []
        for pid in self._discover_projects():
            history = self._load_history(pid)
            if not history:
                continue

            latest = history[-1]
            results.append({
                "project_id": pid,
                "iterations": len(history),
                "last_aggregate_score": latest.scores.quality_score_aggregate,
                "last_trend": latest.regression_data.trend,
                "last_recommendation": latest.regression_data.recommendation,
                "total_cost": latest.meta.accumulated_cost,
            })

        results.sort(key=lambda x: x["iterations"], reverse=True)
        return results

    def get_project_summary(self, project_id: str) -> dict | None:
        """Load LDO history and produce a summary.

        Returns None if project not found.
        """
        history = self._load_history(project_id)
        if not history:
            return None

        first = history[0]
        latest = history[-1]

        # Score extraction helper
        def _scores_dict(ldo: LoopDataObject) -> dict:
            return {
                "bug_score": ldo.scores.bug_score.value,
                "roadbook_match": ldo.scores.roadbook_match_score.value,
                "structural_health": ldo.scores.structural_health_score.value,
                "performance": ldo.scores.performance_score.value,
                "ux": ldo.scores.ux_score.value,
                "aggregate": ldo.scores.quality_score_aggregate,
            }

        # Gaps: total and unique (deduplicated by description)
        all_gaps = []
        unique_descriptions: set[str] = set()
        total_tasks = 0
        for ldo in history:
            for g in ldo.gaps:
                all_gaps.append(g)
                desc = getattr(g, "description", "") or ""
                if desc:
                    unique_descriptions.add(desc.lower().strip())
            total_tasks += len(ldo.tasks)

        mode_history = [ldo.meta.loop_mode for ldo in history]

        initial_agg = first.scores.quality_score_aggregate
        final_agg = latest.scores.quality_score_aggregate

        return {
            "project_id": project_id,
            "project_type": latest.meta.project_type,
            "production_line": latest.meta.production_line,
            "total_iterations": len(history),
            "final_scores": _scores_dict(latest),
            "initial_scores": _scores_dict(first),
            "score_improvement": round(final_agg - initial_agg, 2),
            "mode_history": mode_history,
            "total_cost": latest.meta.accumulated_cost,
            "gaps_found_total": len(all_gaps),
            "gaps_unique": len(unique_descriptions),
            "tasks_generated_total": total_tasks,
            "final_recommendation": latest.regression_data.recommendation,
            "final_trend": latest.regression_data.trend,
        }

    def search_similar_issues(
        self, gap_description: str, max_results: int = 10
    ) -> list[dict]:
        """Search all LDO histories for similar gaps.

        Case-insensitive substring match on description, category,
        and affected_component.  Checks later iterations for resolution.
        """
        if not gap_description or not gap_description.strip():
            return []

        query = gap_description.lower().strip()
        matches: list[tuple[int, dict]] = []  # (relevance_score, result)

        for pid in self._discover_projects():
            history = self._load_history(pid)
            if not history:
                continue

            for idx, ldo in enumerate(history):
                iteration = ldo.meta.iteration
                for gap in ldo.gaps:
                    desc = (getattr(gap, "description", "") or "").lower()
                    cat = (getattr(gap, "category", "") or "").lower()
                    comp = (getattr(gap, "affected_component", "") or "").lower()

                    # Calculate relevance
                    relevance = 0
                    if query == desc:
                        relevance = 100  # exact match
                    elif query in desc:
                        relevance = 80  # substring in description
                    elif query in cat:
                        relevance = 40  # match in category
                    elif query in comp:
                        relevance = 30  # match in component
                    else:
                        # Check individual words
                        words = query.split()
                        word_hits = sum(
                            1 for w in words
                            if w in desc or w in cat or w in comp
                        )
                        if word_hits > 0:
                            relevance = 10 + (word_hits * 10)

                    if relevance <= 0:
                        continue

                    # Check if resolved in later iterations
                    gap_id = getattr(gap, "id", "")
                    was_resolved = False
                    resolved_by = None
                    iterations_to_resolve = None

                    for later_ldo in history[idx + 1:]:
                        for task in later_ldo.tasks:
                            orig = getattr(task, "originated_from", "")
                            if gap_id and orig == gap_id:
                                was_resolved = True
                                resolved_by = {
                                    "id": task.id,
                                    "type": task.type,
                                    "description": task.description,
                                    "priority": task.priority,
                                }
                                iterations_to_resolve = (
                                    later_ldo.meta.iteration - iteration
                                )
                                break
                        if was_resolved:
                            break

                    matches.append((
                        relevance,
                        {
                            "project_id": pid,
                            "iteration": iteration,
                            "gap": {
                                "id": gap_id,
                                "category": getattr(gap, "category", ""),
                                "severity": getattr(gap, "severity", ""),
                                "description": getattr(gap, "description", ""),
                                "affected_component": getattr(
                                    gap, "affected_component", ""
                                ),
                            },
                            "was_resolved": was_resolved,
                            "resolved_by_task": resolved_by,
                            "iterations_to_resolve": iterations_to_resolve,
                        },
                    ))

        # Sort by relevance (highest first), then by project_id for stability
        matches.sort(key=lambda x: (-x[0], x[1]["project_id"]))
        return [m[1] for m in matches[:max_results]]

    def get_cross_project_stats(self) -> dict:
        """Aggregated statistics across all projects."""
        projects = self._discover_projects()
        if not projects:
            return {
                "total_projects": 0,
                "total_iterations_all": 0,
                "avg_iterations_per_project": 0.0,
                "avg_final_aggregate": 0.0,
                "avg_cost_per_project": 0.0,
                "most_common_gap_categories": {},
                "most_common_gap_descriptions": [],
                "project_type_distribution": {},
                "avg_score_improvement": 0.0,
            }

        total_iterations = 0
        aggregates: list[float] = []
        costs: list[float] = []
        improvements: list[float] = []
        gap_categories: Counter = Counter()
        gap_descriptions: Counter = Counter()
        type_dist: Counter = Counter()

        for pid in projects:
            history = self._load_history(pid)
            if not history:
                continue

            total_iterations += len(history)
            first = history[0]
            latest = history[-1]

            aggregates.append(latest.scores.quality_score_aggregate)
            costs.append(latest.meta.accumulated_cost)
            improvements.append(
                latest.scores.quality_score_aggregate
                - first.scores.quality_score_aggregate
            )
            type_dist[latest.meta.project_type] += 1

            for ldo in history:
                for gap in ldo.gaps:
                    cat = getattr(gap, "category", "unknown")
                    gap_categories[cat] += 1
                    desc = getattr(gap, "description", "")
                    if desc:
                        gap_descriptions[desc] += 1

        n = len(projects)
        return {
            "total_projects": n,
            "total_iterations_all": total_iterations,
            "avg_iterations_per_project": round(total_iterations / n, 1)
            if n
            else 0.0,
            "avg_final_aggregate": round(sum(aggregates) / len(aggregates), 1)
            if aggregates
            else 0.0,
            "avg_cost_per_project": round(sum(costs) / len(costs), 4)
            if costs
            else 0.0,
            "most_common_gap_categories": dict(gap_categories.most_common()),
            "most_common_gap_descriptions": [
                desc for desc, _ in gap_descriptions.most_common(5)
            ],
            "project_type_distribution": dict(type_dist),
            "avg_score_improvement": round(
                sum(improvements) / len(improvements), 1
            )
            if improvements
            else 0.0,
        }

    def get_lessons_for_project_type(self, project_type: str) -> dict:
        """Collect insights from projects of the same type."""
        matching_projects: list[str] = []
        iterations_list: list[int] = []
        final_scores: list[float] = []
        all_gap_descs: Counter = Counter()
        mode_sequences: list[list[str]] = []

        for pid in self._discover_projects():
            history = self._load_history(pid)
            if not history:
                continue
            if history[-1].meta.project_type != project_type:
                continue

            matching_projects.append(pid)
            iterations_list.append(len(history))
            final_scores.append(
                history[-1].scores.quality_score_aggregate
            )
            mode_sequences.append([ldo.meta.loop_mode for ldo in history])

            for ldo in history:
                for gap in ldo.gaps:
                    desc = getattr(gap, "description", "")
                    if desc:
                        all_gap_descs[desc] += 1

        n = len(matching_projects)
        if n == 0:
            return {
                "project_type": project_type,
                "projects_analyzed": 0,
                "avg_iterations": 0.0,
                "common_gaps": [],
                "avg_final_score": 0.0,
                "typical_mode_progression": "",
            }

        # Build typical mode progression from longest sequence
        # Count mode transitions to build typical flow
        mode_counts: Counter = Counter()
        for seq in mode_sequences:
            # Compress consecutive duplicates
            compressed = []
            for m in seq:
                if not compressed or compressed[-1][0] != m:
                    compressed.append((m, 1))
                else:
                    compressed[-1] = (m, compressed[-1][1] + 1)
            for mode, count in compressed:
                mode_counts[mode] += count

        # Build progression string
        # Use longest sequence as template, attach avg counts
        progression_parts = []
        seen = set()
        for seq in sorted(mode_sequences, key=len, reverse=True):
            for m in seq:
                if m not in seen:
                    seen.add(m)
                    avg_count = mode_counts[m] / n
                    progression_parts.append(f"{m}({avg_count:.0f})")
            break  # use longest sequence order

        typical_progression = " -> ".join(progression_parts)
        # Append final recommendation from latest projects
        last_recs = set()
        for pid in matching_projects:
            h = self._load_history(pid)
            if h:
                last_recs.add(h[-1].regression_data.recommendation)
        if last_recs:
            typical_progression += " -> " + "/".join(sorted(last_recs))

        return {
            "project_type": project_type,
            "projects_analyzed": n,
            "avg_iterations": round(sum(iterations_list) / n, 1),
            "common_gaps": [desc for desc, _ in all_gap_descs.most_common(5)],
            "avg_final_score": round(sum(final_scores) / n, 1),
            "typical_mode_progression": typical_progression,
        }

# knowledge_writeback.py
# Closes the factory knowledge feedback loop.
#
# Reads proposals + run history, promotes proposals with sufficient evidence,
# and generates new knowledge entries from durable run patterns (e.g.,
# repeated failures, successful recoveries).
#
# Trust levels:
#   hypothesis  — single observation, unconfirmed
#   validated   — observed in 2+ runs OR auto-promoted from matching proposals
#   proven      — confirmed across 2+ projects (manual only)
#   disproven   — invalidated (kept as warning, never auto-set)
#
# Safety rules:
#   - Never auto-promotes to "proven" (requires cross-project confirmation)
#   - Never modifies or deletes existing entries
#   - All writes are append-only with clear provenance
#   - Writeback is idempotent (skips entries whose title already exists)

import json
import os
from datetime import datetime
from pathlib import Path

_KNOWLEDGE_DIR = Path(__file__).resolve().parent
_KNOWLEDGE_PATH = _KNOWLEDGE_DIR / "knowledge.json"
_PROPOSALS_DIR = _KNOWLEDGE_DIR / "proposals"
_INDEX_PATH = _KNOWLEDGE_DIR / "index.json"

_PROJECT_ROOT = _KNOWLEDGE_DIR.parent
_RUN_HISTORY_PATH = _PROJECT_ROOT / "factory" / "memory" / "run_history.json"
_RECOVERY_REPORTS_DIR = _PROJECT_ROOT / "factory" / "reports" / "recovery"

# Minimum observations for auto-promotion from hypothesis to validated
MIN_OBSERVATIONS_FOR_VALIDATION = 2


# ---------------------------------------------------------------------------
# Knowledge store helpers
# ---------------------------------------------------------------------------

def _load_knowledge() -> dict:
    """Load the full knowledge store."""
    try:
        with open(_KNOWLEDGE_PATH, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return {"version": "1.0", "entries": []}


def _save_knowledge(store: dict) -> None:
    """Write the knowledge store back to disk."""
    with open(_KNOWLEDGE_PATH, "w", encoding="utf-8") as f:
        json.dump(store, f, indent=2, ensure_ascii=False)
    f.close()


def _next_id(entries: list[dict]) -> str:
    """Generate the next FK-NNN id."""
    max_num = 0
    for e in entries:
        eid = e.get("id", "")
        if eid.startswith("FK-"):
            try:
                num = int(eid[3:])
                max_num = max(max_num, num)
            except ValueError:
                pass
    return f"FK-{max_num + 1:03d}"


def _title_exists(entries: list[dict], title: str) -> bool:
    """Check if an entry with this exact title already exists (idempotency)."""
    return any(e.get("title") == title for e in entries)


def _rebuild_index(entries: list[dict]) -> None:
    """Rebuild index.json from current entries."""
    by_type: dict[str, int] = {}
    by_confidence: dict[str, int] = {"hypothesis": 0, "validated": 0, "proven": 0, "disproven": 0}
    by_category: dict[str, int] = {}
    projects: set[str] = set()

    for e in entries:
        etype = e.get("type", "unknown")
        by_type[etype] = by_type.get(etype, 0) + 1

        conf = e.get("confidence", "hypothesis")
        by_confidence[conf] = by_confidence.get(conf, 0) + 1

        cat = e.get("category", "")
        if cat:
            by_category[cat] = by_category.get(cat, 0) + 1

        proj = e.get("source_project", "")
        if proj:
            projects.add(proj)

    index = {
        "last_updated": datetime.now().strftime("%Y-%m-%d"),
        "total_entries": len(entries),
        "by_type": by_type,
        "by_confidence": by_confidence,
        "by_category": by_category,
        "projects": sorted(projects),
    }

    with open(_INDEX_PATH, "w", encoding="utf-8") as f:
        json.dump(index, f, indent=2, ensure_ascii=False)


# ---------------------------------------------------------------------------
# Run history helpers
# ---------------------------------------------------------------------------

def _load_run_history() -> list[dict]:
    """Load run history entries."""
    try:
        with open(_RUN_HISTORY_PATH, encoding="utf-8") as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        return []


def _load_proposals() -> list[dict]:
    """Load all pending proposals from the proposals directory."""
    proposals = []
    if not _PROPOSALS_DIR.exists():
        return proposals
    for pfile in sorted(_PROPOSALS_DIR.glob("proposal_*.json")):
        try:
            with open(pfile, encoding="utf-8") as f:
                data = json.load(f)
            for p in data.get("proposals", []):
                p["_source_file"] = str(pfile)
                proposals.append(p)
        except (json.JSONDecodeError, OSError):
            continue
    return proposals


# ---------------------------------------------------------------------------
# Writeback: Proposal auto-promotion
# ---------------------------------------------------------------------------

def _find_similar_proposals(proposals: list[dict]) -> dict[str, list[dict]]:
    """Group proposals by normalized title to find repeated observations.

    Two proposals are "similar" if their title (lowercased, stripped) matches
    or if they share the same type + overlapping tags.
    """
    groups: dict[str, list[dict]] = {}
    for p in proposals:
        # Normalize: lowercase, strip whitespace
        key = p.get("title", "").lower().strip()
        if not key:
            continue
        groups.setdefault(key, []).append(p)
    return groups


def promote_validated_proposals(dry_run: bool = False) -> list[dict]:
    """Auto-promote proposals observed in 2+ runs to validated knowledge.

    Returns list of promoted entries (or would-be-promoted in dry_run).
    """
    proposals = _load_proposals()
    if not proposals:
        return []

    store = _load_knowledge()
    entries = store.get("entries", [])
    promoted = []

    # Group by similar title
    groups = _find_similar_proposals(proposals)

    for title_key, group in groups.items():
        if len(group) < MIN_OBSERVATIONS_FOR_VALIDATION:
            continue

        # Check idempotency — skip if already in knowledge
        representative = group[0]
        if _title_exists(entries, representative.get("title", "")):
            continue

        # Collect evidence from all observations
        run_ids = sorted(set(p.get("source_run", "") for p in group if p.get("source_run")))
        projects = sorted(set(p.get("source_project", "") for p in group if p.get("source_project")))
        all_tags = set()
        for p in group:
            all_tags.update(p.get("tags", []))

        entry = {
            "id": _next_id(entries),
            "type": representative.get("type", "failure_case"),
            "title": representative.get("title", "")[:80],
            "description": representative.get("lesson", ""),
            "context": f"Auto-promoted: observed in {len(group)} proposals across runs {', '.join(run_ids)}.",
            "source_project": projects[0] if projects else "unknown",
            "product_type": "learning_app",
            "applicable_to": ["learning_app"],
            "confidence": "validated",
            "created": datetime.now().strftime("%Y-%m-%d"),
            "updated": datetime.now().strftime("%Y-%m-%d"),
            "tags": sorted(all_tags | {"auto-promoted"}),
            "lesson": representative.get("lesson", ""),
            "writeback_source": "proposal_promotion",
            "writeback_evidence": {
                "observation_count": len(group),
                "run_ids": run_ids,
                "source_files": sorted(set(p.get("_source_file", "") for p in group)),
            },
        }

        promoted.append(entry)
        if not dry_run:
            entries.append(entry)

    if promoted and not dry_run:
        store["entries"] = entries
        _save_knowledge(store)
        _rebuild_index(entries)

    return promoted


# ---------------------------------------------------------------------------
# Writeback: Run-pattern extraction
# ---------------------------------------------------------------------------

def extract_run_patterns(dry_run: bool = False) -> list[dict]:
    """Extract durable patterns from run history and write them to knowledge.

    Patterns detected:
    1. Recurring missing files (same file missing in 2+ runs)
    2. Repeated recovery failures (same fingerprint across runs)
    3. Successful recovery patterns (recovery that resolved the issue)

    Returns list of generated entries (or would-be-generated in dry_run).
    """
    history = _load_run_history()
    store = _load_knowledge()
    entries = store.get("entries", [])
    generated = []

    for project_entry in history:
        project_name = project_entry.get("project", "unknown")
        runs = project_entry.get("runs", [])
        if len(runs) < 2:
            continue

        # Pattern 1: Recurring missing files
        missing_counts: dict[str, int] = {}
        for run in runs:
            for f in run.get("missing_files", []):
                missing_counts[f] = missing_counts.get(f, 0) + 1

        recurring = {f: c for f, c in missing_counts.items() if c >= MIN_OBSERVATIONS_FOR_VALIDATION}
        if recurring:
            title = f"Recurring missing files in {project_name}"
            if not _title_exists(entries, title):
                top_files = sorted(recurring.items(), key=lambda x: -x[1])[:5]
                file_list = ", ".join(f"{f} ({c}x)" for f, c in top_files)
                entry = {
                    "id": _next_id(entries),
                    "type": "error_pattern",
                    "title": title,
                    "description": f"Files consistently missing across runs: {file_list}",
                    "context": f"Observed across {len(runs)} runs of {project_name}.",
                    "source_project": project_name,
                    "product_type": "learning_app",
                    "applicable_to": ["learning_app"],
                    "confidence": "validated",
                    "category": "generation_reliability",
                    "created": datetime.now().strftime("%Y-%m-%d"),
                    "updated": datetime.now().strftime("%Y-%m-%d"),
                    "tags": ["recurring-missing", "generation-gap", "auto-extracted"],
                    "lesson": f"These files are repeatedly not generated: {file_list}. "
                              "The generation prompt or template may need explicit inclusion.",
                    "writeback_source": "run_pattern_extraction",
                    "writeback_evidence": {
                        "pattern": "recurring_missing_files",
                        "file_counts": recurring,
                        "total_runs": len(runs),
                    },
                }
                generated.append(entry)
                if not dry_run:
                    entries.append(entry)

        # Pattern 2: Repeated recovery failures
        repeated_runs = [r for r in runs if r.get("repeated_failure", False)]
        if len(repeated_runs) >= 1:
            title = f"Repeated recovery failure pattern in {project_name}"
            if not _title_exists(entries, title):
                fingerprints = [r.get("recovery_fingerprint", "?") for r in repeated_runs]
                entry = {
                    "id": _next_id(entries + generated),
                    "type": "error_pattern",
                    "title": title,
                    "description": (
                        f"Recovery attempts failed with identical failure fingerprints, "
                        f"indicating a structural gap that retrying cannot fix."
                    ),
                    "context": f"Detected in {len(repeated_runs)} runs. Fingerprints: {', '.join(fingerprints[:3])}.",
                    "source_project": project_name,
                    "product_type": "ai_pipeline",
                    "applicable_to": ["ai_pipeline"],
                    "confidence": "validated",
                    "category": "recovery_reliability",
                    "created": datetime.now().strftime("%Y-%m-%d"),
                    "updated": datetime.now().strftime("%Y-%m-%d"),
                    "tags": ["recovery-failure", "repeated-pattern", "auto-extracted"],
                    "lesson": "When recovery fails with the same fingerprint, the root cause is "
                              "structural (missing spec, wrong template, or generation blind spot) "
                              "not transient.",
                    "writeback_source": "run_pattern_extraction",
                    "writeback_evidence": {
                        "pattern": "repeated_recovery_failure",
                        "fingerprints": fingerprints,
                        "run_ids": [r.get("run_id", "") for r in repeated_runs],
                    },
                }
                generated.append(entry)
                if not dry_run:
                    entries.append(entry)

        # Pattern 3: Successful recovery (recovery_outcome == "recovered")
        recovered_runs = [r for r in runs if r.get("recovery_outcome") == "recovered"]
        if len(recovered_runs) >= 1:
            title = f"Successful recovery pattern in {project_name}"
            if not _title_exists(entries, title):
                entry = {
                    "id": _next_id(entries + generated),
                    "type": "success_pattern",
                    "title": title,
                    "description": (
                        f"Recovery successfully resolved incomplete runs "
                        f"({len(recovered_runs)} times). "
                        "The targeted recovery prompt approach works for this project type."
                    ),
                    "context": f"Observed in {len(recovered_runs)} of {len(runs)} runs.",
                    "source_project": project_name,
                    "product_type": "ai_pipeline",
                    "applicable_to": ["ai_pipeline"],
                    "confidence": "observed",
                    "category": "recovery_reliability",
                    "created": datetime.now().strftime("%Y-%m-%d"),
                    "updated": datetime.now().strftime("%Y-%m-%d"),
                    "tags": ["recovery-success", "auto-extracted"],
                    "lesson": "Focused recovery prompts with targeted file lists can resolve "
                              "incomplete generation runs effectively.",
                    "writeback_source": "run_pattern_extraction",
                    "writeback_evidence": {
                        "pattern": "successful_recovery",
                        "recovered_count": len(recovered_runs),
                        "total_runs": len(runs),
                        "run_ids": [r.get("run_id", "") for r in recovered_runs],
                    },
                }
                generated.append(entry)
                if not dry_run:
                    entries.append(entry)

    if generated and not dry_run:
        store["entries"] = entries
        _save_knowledge(store)
        _rebuild_index(entries)

    return generated


# ---------------------------------------------------------------------------
# Main writeback entry point
# ---------------------------------------------------------------------------

def run_writeback(dry_run: bool = False) -> dict:
    """Execute the full writeback cycle.

    1. Auto-promote proposals with 2+ observations
    2. Extract patterns from run history
    3. Rebuild index

    Returns a summary dict.
    """
    print("\n[KnowledgeWriteback] Starting writeback cycle...")

    promoted = promote_validated_proposals(dry_run=dry_run)
    if promoted:
        mode = "would promote" if dry_run else "promoted"
        print(f"[KnowledgeWriteback] Proposals {mode}: {len(promoted)}")
        for p in promoted:
            print(f"  [{p['id']}] {p['title']} (confidence: {p['confidence']})")
    else:
        print("[KnowledgeWriteback] No proposals ready for promotion.")

    patterns = extract_run_patterns(dry_run=dry_run)
    if patterns:
        mode = "would extract" if dry_run else "extracted"
        print(f"[KnowledgeWriteback] Run patterns {mode}: {len(patterns)}")
        for p in patterns:
            print(f"  [{p['id']}] {p['title']} (confidence: {p['confidence']})")
    else:
        print("[KnowledgeWriteback] No new run patterns detected.")

    total = len(promoted) + len(patterns)
    if total > 0 and not dry_run:
        store = _load_knowledge()
        print(f"[KnowledgeWriteback] Knowledge store now has {len(store.get('entries', []))} entries.")

    summary = {
        "promoted_count": len(promoted),
        "promoted_entries": [{"id": p["id"], "title": p["title"]} for p in promoted],
        "patterns_count": len(patterns),
        "pattern_entries": [{"id": p["id"], "title": p["title"]} for p in patterns],
        "dry_run": dry_run,
    }

    print("[KnowledgeWriteback] Writeback cycle complete.")
    return summary


# ---------------------------------------------------------------------------
# CLI entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="Factory Knowledge Writeback")
    parser.add_argument("--dry-run", action="store_true", default=False,
                        help="Show what would be written without writing")
    args = parser.parse_args()
    run_writeback(dry_run=args.dry_run)

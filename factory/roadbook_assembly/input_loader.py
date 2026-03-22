"""Input Loader — Reads ALL reports from ALL chapters for Roadbook Assembly.

Loads from:
- Phase 1 (6 reports + CEO-Gate decision)
- Kapitel 3 (5 reports)
- Kapitel 4 (3 reports)
- Kapitel 4.5 (3 reports)
- Kapitel 5 (3 reports + Review decision)

Total: up to 20 reports + 2 decisions.
"""

from pathlib import Path

# Report files per chapter
PHASE1_FILES = {
    "concept_brief": "concept_brief.md",
    "trend_report": "trend_report.md",
    "competitive_report": "competitive_report.md",
    "audience_profile": "audience_profile.md",
    "legal_report": "legal_report.md",
    "risk_assessment": "risk_assessment.md",
    "ceo_gate_decision": "ceo_gate_decision.md",
}

K3_FILES = {
    "platform_strategy": "platform_strategy.md",
    "monetization_report": "monetization_report.md",
    "marketing_strategy": "marketing_strategy.md",
    "release_plan": "release_plan.md",
    "cost_calculation": "cost_calculation.md",
}

K4_FILES = {
    "feature_list": "feature_list.md",
    "feature_prioritization": "feature_prioritization.md",
    "screen_architecture": "screen_architecture.md",
}

K45_FILES = {
    "trend_breaker_report": "trend_breaker_report.md",
    "emotion_architect_report": "emotion_architect_report.md",
    "design_vision_document": "design_vision_document.md",
}

K5_FILES = {
    "asset_discovery": "asset_discovery.md",
    "asset_strategy": "asset_strategy.md",
    "visual_consistency": "visual_consistency.md",
    "review_decision": "review_decision.md",
}


def load_all_reports(
    phase1_dir: str = None, k3_dir: str = None, k4_dir: str = None,
    k45_dir: str = None, k5_dir: str = None,
) -> dict:
    """Load all reports from all 5 chapters.

    Returns dict with all individual reports + grouped convenience strings.
    """
    if not all([phase1_dir, k3_dir, k4_dir, k45_dir, k5_dir]):
        auto = find_latest_runs()
        phase1_dir = phase1_dir or auto[0]
        k3_dir = k3_dir or auto[1]
        k4_dir = k4_dir or auto[2]
        k45_dir = k45_dir or auto[3]
        k5_dir = k5_dir or auto[4]

    dirs = {
        "Phase 1": (Path(phase1_dir), PHASE1_FILES),
        "Kapitel 3": (Path(k3_dir), K3_FILES),
        "Kapitel 4": (Path(k4_dir), K4_FILES),
        "Kapitel 4.5": (Path(k45_dir), K45_FILES),
        "Kapitel 5": (Path(k5_dir), K5_FILES),
    }

    result = {
        "phase1_run_dir": str(Path(phase1_dir).resolve()),
        "k3_run_dir": str(Path(k3_dir).resolve()),
        "k4_run_dir": str(Path(k4_dir).resolve()),
        "k45_run_dir": str(Path(k45_dir).resolve()),
        "k5_run_dir": str(Path(k5_dir).resolve()),
    }

    # Extract title from phase1 dir
    p1_name = Path(phase1_dir).name
    result["idea_title"] = p1_name.split("_", 1)[1] if "_" in p1_name else p1_name

    # Load all reports
    loaded = 0
    total_chars = 0
    for chapter, (base_dir, file_map) in dirs.items():
        if not base_dir.exists():
            print(f"[InputLoader] WARNING: {chapter} Verzeichnis nicht gefunden: {base_dir}")
            for key in file_map:
                result[key] = ""
            continue
        for key, filename in file_map.items():
            filepath = base_dir / filename
            if filepath.exists():
                content = filepath.read_text(encoding="utf-8")
                result[key] = content
                loaded += 1
                total_chars += len(content)
            else:
                result[key] = ""

    # Build grouped convenience strings
    def _group(file_map: dict, header_prefix: str) -> str:
        parts = []
        for key in file_map:
            content = result.get(key, "")
            if content:
                label = key.upper().replace("_", " ")
                parts.append(f"=== {header_prefix}: {label} ===\n{content}")
        return "\n\n".join(parts)

    result["group_phase1"] = _group(PHASE1_FILES, "PHASE 1")
    result["group_k3"] = _group(K3_FILES, "KAPITEL 3")
    result["group_k4"] = _group(K4_FILES, "KAPITEL 4")
    result["group_k45"] = _group(K45_FILES, "KAPITEL 4.5")
    result["group_k5"] = _group(K5_FILES, "KAPITEL 5")

    # All combined
    result["all_reports_combined"] = "\n\n".join(
        result[g] for g in ["group_phase1", "group_k3", "group_k4", "group_k45", "group_k5"] if result.get(g)
    )

    print(f"[InputLoader] Loaded {loaded}/20 reports from 5 chapters, total {total_chars // 1000}k chars")
    return result


def find_latest_runs() -> tuple[str, str, str, str, str]:
    """Find latest runs for all 5 chapters.

    Returns (phase1_dir, k3_dir, k4_dir, k45_dir, k5_dir).
    """
    base = Path("factory")

    p1 = _find_latest_go_run(base / "pre_production" / "output")
    k3 = _find_latest_run(base / "market_strategy" / "output", "Kapitel 3")
    k4 = _find_latest_run(base / "mvp_scope" / "output", "Kapitel 4")
    k45 = _find_latest_run(base / "design_vision" / "output", "Kapitel 4.5")
    k5 = _find_latest_run(base / "visual_audit" / "output", "Kapitel 5")

    return str(p1), str(k3), str(k4), str(k45), str(k5)


def _find_latest_go_run(output_dir: Path) -> Path:
    if not output_dir.exists():
        raise FileNotFoundError(f"Phase 1 Output nicht gefunden: {output_dir}")
    run_dirs = sorted(
        [d for d in output_dir.iterdir() if d.is_dir() and not d.name.startswith(".")],
        reverse=True,
    )
    for run_dir in run_dirs:
        gate = run_dir / "ceo_gate_decision.md"
        if gate.exists() and "GO" in gate.read_text(encoding="utf-8"):
            return run_dir
    raise FileNotFoundError("Kein Phase 1 Run mit GO-Entscheidung gefunden")


def _find_latest_run(output_dir: Path, label: str) -> Path:
    if not output_dir.exists():
        raise FileNotFoundError(f"{label} Output nicht gefunden: {output_dir}")
    run_dirs = sorted(
        [d for d in output_dir.iterdir() if d.is_dir() and not d.name.startswith(".")],
        reverse=True,
    )
    if not run_dirs:
        raise FileNotFoundError(f"Keine {label} Runs gefunden in {output_dir}")
    return run_dirs[0]


def get_split_strategy(agent_name: str) -> dict:
    """Use AutoSplitter to determine optimal call strategy for the given agent."""
    try:
        from factory.brain.model_provider.auto_splitter import AutoSplitter
        from factory.brain.model_provider import get_registry, get_model
        from factory.roadbook_assembly.config import MODEL_SELECTION_CONFIG

        config = MODEL_SELECTION_CONFIG.get(agent_name, {})
        selection = get_model(
            profile=config.get("profile", "dev"),
            expected_output_tokens=config.get("expected_output_tokens", 20000),
        )

        splitter = AutoSplitter(get_registry())
        strategy = splitter.analyze(
            selection["model"],
            selection["provider"],
            expected_output_tokens=config.get("expected_output_tokens", 20000),
        )

        return {
            "recommended_model": selection["model"],
            "recommended_provider": selection["provider"],
            "strategy": f"split_{strategy.call_count}" if strategy.should_split else "single_call",
            "num_calls": strategy.call_count,
            "description": strategy.reason,
        }
    except Exception as e:
        print(f"[Kapitel6] AutoSplitter not available ({e}), defaulting to split_3")
        return {
            "recommended_model": "claude-sonnet-4-6",
            "recommended_provider": "anthropic",
            "strategy": "split_3",
            "num_calls": 3,
            "description": f"Fallback: 3 calls with Sonnet ({e})",
        }

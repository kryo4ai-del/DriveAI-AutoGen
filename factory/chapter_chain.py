"""Chapter Chain Runner — Runs K3 bis K5 sequentiell nach CEO Gate GO.

Wird vom gate-executor.js aufgerufen nachdem CEO Gate GO entschieden wurde.
Aktualisiert project.json nach jedem Kapitel via project_registry.

Usage:
    python -m factory.chapter_chain --slug growmeldai --p1-dir factory/pre_production/output/004_growmeldai
"""

import argparse
import os
import re
import subprocess
import sys
from pathlib import Path

FACTORY_BASE = Path(__file__).resolve().parent.parent


def _find_output_dir(dept_output: str, slug: str) -> str:
    """Find the latest output dir for a slug in a department's output folder."""
    base = FACTORY_BASE / dept_output
    if not base.exists():
        return ""
    candidates = sorted(
        [d for d in base.iterdir() if d.is_dir() and slug in d.name],
        key=lambda d: d.name,
        reverse=True,
    )
    return str(candidates[0]) if candidates else ""


def _extract_run_number(output_dir: str) -> int:
    """Extract run number from dir name like '003_growmeldai'."""
    name = Path(output_dir).name
    match = re.match(r"(\d+)_", name)
    return int(match.group(1)) if match else 0


def _update_registry(slug: str, chapter: str, output_dir: str):
    """Update project.json via shared project_registry."""
    try:
        # Relative path for project.json (relative to FACTORY_BASE)
        rel_dir = output_dir
        try:
            rel_dir = str(Path(output_dir).relative_to(FACTORY_BASE))
        except ValueError:
            pass

        from factory.shared.project_registry import update_project
        update_project(slug, chapter, {
            "status": "complete",
            "run_number": _extract_run_number(output_dir),
            "output_dir": rel_dir,
        })
        print(f"[ChapterChain] project.json updated: {chapter} = complete")
    except Exception as e:
        print(f"[ChapterChain] WARNING: Registry update failed for {chapter}: {e}")


def _run_chapter(cmd: list[str], chapter_label: str) -> bool:
    """Run a chapter pipeline via subprocess. Returns True on success."""
    print(f"\n{'=' * 60}")
    print(f"  [ChapterChain] Starting: {chapter_label}")
    print(f"  Command: {' '.join(cmd)}")
    print("=" * 60)

    result = subprocess.run(
        cmd,
        cwd=str(FACTORY_BASE),
        env={**os.environ, "PYTHONIOENCODING": "utf-8"},
    )

    if result.returncode != 0:
        print(f"\n[ChapterChain] FAILED: {chapter_label} (exit code {result.returncode})")
        return False

    print(f"\n[ChapterChain] DONE: {chapter_label}")
    return True


def run_chain(slug: str, p1_dir: str) -> bool:
    """Run the complete K3 -> K4 -> K4.5 -> K5 chain.

    Args:
        slug: Project slug (e.g. 'growmeldai')
        p1_dir: Phase 1 output directory (relative or absolute)

    Returns:
        True if all chapters completed successfully.
    """
    print("=" * 60)
    print(f"  DriveAI Chapter Chain — {slug}")
    print(f"  Phase 1 Dir: {p1_dir}")
    print(f"  Kapitel: K3 -> K4 -> K4.5 -> K5")
    print("=" * 60)

    # --- K3: Market Strategy ---
    ok = _run_chapter(
        [sys.executable, "-m", "factory.market_strategy.pipeline", "--run-dir", p1_dir],
        "Kapitel 3: Market Strategy",
    )
    if not ok:
        print("[ChapterChain] ABORTED at Kapitel 3")
        return False

    k3_dir = _find_output_dir("factory/market_strategy/output", slug)
    if not k3_dir:
        print("[ChapterChain] ERROR: K3 output dir not found")
        return False
    _update_registry(slug, "kapitel3", k3_dir)

    # --- K4: MVP & Feature Scope ---
    ok = _run_chapter(
        [sys.executable, "-m", "factory.mvp_scope.pipeline",
         "--p1-dir", p1_dir, "--p2-dir", k3_dir],
        "Kapitel 4: MVP & Feature Scope",
    )
    if not ok:
        print("[ChapterChain] ABORTED at Kapitel 4")
        return False

    k4_dir = _find_output_dir("factory/mvp_scope/output", slug)
    if not k4_dir:
        print("[ChapterChain] ERROR: K4 output dir not found")
        return False
    _update_registry(slug, "kapitel4", k4_dir)

    # --- K4.5: Design Vision ---
    ok = _run_chapter(
        [sys.executable, "-m", "factory.design_vision.pipeline",
         "--p1-dir", p1_dir, "--k3-dir", k3_dir, "--k4-dir", k4_dir],
        "Kapitel 4.5: Design Vision",
    )
    if not ok:
        print("[ChapterChain] ABORTED at Kapitel 4.5")
        return False

    k45_dir = _find_output_dir("factory/design_vision/output", slug)
    if not k45_dir:
        print("[ChapterChain] ERROR: K4.5 output dir not found")
        return False
    _update_registry(slug, "kapitel45", k45_dir)

    # --- K5: Visual & Asset Audit ---
    ok = _run_chapter(
        [sys.executable, "-m", "factory.visual_audit.pipeline",
         "--p1-dir", p1_dir, "--k3-dir", k3_dir, "--k4-dir", k4_dir],
        "Kapitel 5: Visual & Asset Audit",
    )
    if not ok:
        print("[ChapterChain] ABORTED at Kapitel 5")
        return False

    k5_dir = _find_output_dir("factory/visual_audit/output", slug)
    if not k5_dir:
        print("[ChapterChain] ERROR: K5 output dir not found")
        return False
    _update_registry(slug, "kapitel5", k5_dir)

    # --- DONE ---
    print("\n" + "=" * 60)
    print("  [ChapterChain] ALL CHAPTERS COMPLETE")
    print(f"  Slug:  {slug}")
    print(f"  K3:    {k3_dir}")
    print(f"  K4:    {k4_dir}")
    print(f"  K4.5:  {k45_dir}")
    print(f"  K5:    {k5_dir}")
    print(f"\n  Status: review_pending (Human Review Gate wartet im Dashboard)")
    print("=" * 60)
    return True


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="DriveAI Chapter Chain — K3 bis K5 sequentiell"
    )
    parser.add_argument("--slug", required=True, help="Project slug (e.g. growmeldai)")
    parser.add_argument("--p1-dir", required=True, help="Phase 1 output directory")
    args = parser.parse_args()

    success = run_chain(args.slug, args.p1_dir)
    sys.exit(0 if success else 1)

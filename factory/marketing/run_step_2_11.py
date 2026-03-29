"""Step 2.11 — Story Briefs + Direktiven fuer weitere Projekte.

Aufruf: python -m factory.marketing.run_step_2_11
"""

import os
import sys

sys.stdout.reconfigure(encoding="utf-8", errors="replace")
sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from pathlib import Path
from dotenv import load_dotenv

load_dotenv(Path(__file__).resolve().parents[2] / ".env")

from factory.marketing.agents.strategy import StrategyAgent
from factory.marketing.input_loader import MarketingInputLoader

loader = MarketingInputLoader()
strategy = StrategyAgent()

projects = loader.get_available_projects()
print(f"\nVerfuegbare Projekte: {projects}")
print("=" * 55)

created = 0
skipped = 0

for slug in projects:
    # Pruefe ob Story Brief bereits existiert
    from factory.marketing.config import BRAND_PATH

    brief_path = os.path.join(BRAND_PATH, "app_stories", slug, "story_brief.md")
    directive_path = os.path.join(BRAND_PATH, "directives", f"{slug}_directive.md")

    if os.path.exists(brief_path) and os.path.exists(directive_path):
        brief_size = os.path.getsize(brief_path)
        dir_size = os.path.getsize(directive_path)
        print(f"\n  {slug}: Story Brief ({brief_size:,}B) + Direktive ({dir_size:,}B) existieren bereits.")
        skipped += 1
        continue

    # Pruefe ob genug Daten vorhanden
    outputs = loader.find_project_outputs(slug)
    dept_count = sum(1 for v in outputs.values() if v is not None)

    if dept_count < 2:
        print(f"\n  {slug}: Zu wenig Daten ({dept_count} Departments), ueberspringe.")
        skipped += 1
        continue

    print(f"\n  {slug}: {dept_count} Departments, erstelle Story Brief + Direktive...")

    try:
        result = strategy.create_app_story_brief(slug)
        if result:
            size = os.path.getsize(result)
            print(f"    OK Story Brief: {result} ({size:,} bytes)")
        else:
            print(f"    FEHLER Story Brief: leeres Ergebnis")
    except Exception as e:
        print(f"    FEHLER Story Brief: {e}")

    try:
        result = strategy.create_marketing_directive(slug)
        if result:
            size = os.path.getsize(result)
            print(f"    OK Direktive: {result} ({size:,} bytes)")
        else:
            print(f"    FEHLER Direktive: leeres Ergebnis")
    except Exception as e:
        print(f"    FEHLER Direktive: {e}")

    created += 1

print(f"\n{'=' * 55}")
print(f"  Step 2.11 abgeschlossen: {created} neu, {skipped} uebersprungen")
print(f"{'=' * 55}")

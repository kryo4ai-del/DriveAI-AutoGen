"""Step 1.8 — Factory-Narrative erstellen.

Ruft StrategyAgent.create_factory_narrative() auf.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), "..", "..", ".env"))

from factory.marketing.agents.strategy import StrategyAgent

agent = StrategyAgent()

# Aktuelle Factory-Fakten (Stand: 26.03.2026)
facts = {
    "agents": 78,
    "active_agents": 71,
    "departments": 14,
    "production_lines": 5,
    "platforms": "iOS, Android, Web, Unity, Python",
    "products_in_pipeline": 4,
    "products": "AskFin (iOS, App Store ready 75%), EchoMatch (Roadbook fertig), SkillSense (Phase 1 done), MemeRun2026 (Pipeline)",
    "cost_per_pipeline_run": "$0.08 (788x guenstiger als Legacy)",
    "roadbook_creation": "4 Minuten, 0.51 EUR",
    "swarm_chapters": "6 (Idee -> Store-ready)",
    "llm_providers": "4 (Anthropic, OpenAI, Google, Mistral) mit 9 Modellen",
    "brain_subsystems": "7 (StateCollector, TaskRouter, ResponseCollector, ProblemDetector, SolutionProposer, GapAnalyzer, ExtensionAdvisor)",
    "factory_memory": "Event Log + Knowledge Base + Pattern Store",
    "key_milestone": "Erste App (AskFin) mit 234 Swift Files autonom produziert, 15 Golden Gates bestanden, 0 Failures",
}

result = agent.create_factory_narrative(factory_facts=facts)

print("\n=== Step 1.8 — Factory-Narrative ===")
if result:
    for version, path in result.items():
        size = os.path.getsize(path) if os.path.exists(path) else 0
        print(f"  [OK] {version}: {path} ({size:,} bytes)")
    print(f"\n  {len(result)} Versionen erstellt.")
else:
    print("  [FAIL] FEHLER: Keine Narrative erstellt.")

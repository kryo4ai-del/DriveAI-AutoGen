"""Step 1.9 — App Story Brief fuer EchoMatch erstellen.

Ruft StrategyAgent.create_app_story_brief() auf.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), "..", "..", ".env"))

from factory.marketing.agents.strategy import StrategyAgent

agent = StrategyAgent()
result = agent.create_app_story_brief("echomatch")

print("\n=== Step 1.9 — App Story Brief (EchoMatch) ===")
if result:
    size = os.path.getsize(result)
    print(f"  [OK] Story Brief erstellt: {result}")
    print(f"  Groesse: {size:,} bytes")
else:
    print("  [FAIL] FEHLER: Kein Story Brief erstellt.")

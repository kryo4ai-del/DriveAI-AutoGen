"""Step 1.10 — Marketing-Direktive fuer EchoMatch erstellen.

Ruft StrategyAgent.create_marketing_directive() auf.
"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from dotenv import load_dotenv
load_dotenv(os.path.join(os.path.dirname(__file__), "..", "..", ".env"))

from factory.marketing.agents.strategy import StrategyAgent

agent = StrategyAgent()
result = agent.create_marketing_directive("echomatch")

print("\n=== Step 1.10 — Marketing-Direktive (EchoMatch) ===")
if result:
    size = os.path.getsize(result)
    print(f"  [OK] Direktive erstellt: {result}")
    print(f"  Groesse: {size:,} bytes")
else:
    print("  [FAIL] FEHLER: Keine Direktive erstellt.")

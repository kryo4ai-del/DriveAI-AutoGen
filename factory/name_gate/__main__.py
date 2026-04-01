"""Entry point for ``python -m factory.name_gate``.

Usage:
    python -m factory.name_gate validate --name EchoMatch --idea "Social matching app"
    python -m factory.name_gate alternatives --idea "Social matching app"
    python -m factory.name_gate status --name EchoMatch
"""

import sys
from pathlib import Path

# Ensure project root is on sys.path so absolute imports work
_PROJECT_ROOT = Path(__file__).resolve().parents[2]
if str(_PROJECT_ROOT) not in sys.path:
    sys.path.insert(0, str(_PROJECT_ROOT))

from factory.name_gate.cli import main

if __name__ == "__main__":
    main()
else:
    # Also run when invoked via python -m factory.name_gate
    main()

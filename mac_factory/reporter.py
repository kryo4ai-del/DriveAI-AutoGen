"""
DriveAI Mac Factory — Reporter

Sends supervisor reports to Windows TheBrain API.
Always saves locally first (best-effort send to Windows).
"""

import os
import json
from pathlib import Path
from datetime import datetime, timezone


class Reporter:
    def __init__(self, windows_url: str = None):
        self.windows_url = windows_url
        if not self.windows_url:
            try:
                import yaml
                config_path = Path(__file__).parent / "config.yaml"
                if config_path.exists():
                    with open(config_path) as f:
                        cfg = yaml.safe_load(f)
                    self.windows_url = cfg.get("thebrain_url", "")
            except Exception:
                self.windows_url = ""

        self.reports_dir = Path(__file__).parent / "supervisor" / "reports"
        self.reports_dir.mkdir(parents=True, exist_ok=True)

    def submit(self, result, project_name: str, report_type: str = "supervised_build") -> dict:
        """
        Builds report, saves locally, sends to Windows (best-effort).
        Returns {local_path, sent_to_windows: bool}
        """
        # Convert result to dict (SupervisorResult or already dict)
        if hasattr(result, "to_dict"):
            result_data = result.to_dict()
        elif isinstance(result, dict):
            result_data = result
        else:
            result_data = {"raw": str(result)}

        report = {
            "source": "mac",
            "project": project_name,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "report_type": report_type,
            "result": result_data,
        }

        # 1. Always save locally
        timestamp = int(datetime.now(timezone.utc).timestamp())
        local_path = self.reports_dir / f"{project_name}_{report_type}_{timestamp}.json"
        try:
            with open(local_path, "w") as f:
                json.dump(report, f, indent=2)
            print(f"[Reporter] Saved local: {local_path.name}")
        except Exception as e:
            print(f"[Reporter] Local save failed: {e}")
            local_path = None

        # 2. Best-effort send to Windows
        sent = False
        if self.windows_url:
            try:
                import requests
                resp = requests.post(
                    f"{self.windows_url}/reports/submit",
                    json=report,
                    timeout=10
                )
                if resp.status_code == 200:
                    sent = True
                    print(f"[Reporter] Sent to Windows")
                else:
                    print(f"[Reporter] Windows returned HTTP {resp.status_code}")
            except Exception as e:
                print(f"[Reporter] Windows unreachable ({type(e).__name__}) - report saved locally only")

        return {
            "local_path": str(local_path) if local_path else "",
            "sent_to_windows": sent,
        }

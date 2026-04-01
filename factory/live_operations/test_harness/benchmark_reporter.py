"""Benchmark Reporter — generiert Markdown-Reports aus Stress-Test-Ergebnissen.

Erzeugt lesbare Reports fuer CEO-Dashboard und Archiv.
"""

import json
from datetime import datetime, timezone
from pathlib import Path


_PREFIX = "[Benchmark Reporter]"


class BenchmarkReporter:
    """Erzeugt Markdown-Reports aus StressTestRunner Ergebnissen."""

    def __init__(self, output_dir: str | None = None) -> None:
        self._output_dir = Path(
            output_dir
            or Path(__file__).resolve().parent.parent / "data" / "benchmarks"
        )
        self._output_dir.mkdir(parents=True, exist_ok=True)

    def generate_report(self, results: dict) -> str:
        """Generiert Markdown-Report und speichert ihn.

        Args:
            results: Output von StressTestRunner.run_all()

        Returns:
            Pfad zum gespeicherten Report.
        """
        lines = []
        lines.append("# Live Operations Stress-Test Report")
        lines.append("")
        lines.append(f"**Datum:** {results.get('run_at', 'unbekannt')}")
        lines.append(f"**Fleet Size:** {results.get('fleet_size', '?')}")
        lines.append(f"**Iterations:** {results.get('iterations', '?')}")
        lines.append(f"**Ergebnis:** {'ALL PASS' if results.get('ok') else 'FAILURES'} "
                      f"({results.get('passed', 0)}/{results.get('total', 0)})")
        lines.append("")

        # Summary Table
        lines.append("## Uebersicht")
        lines.append("")
        lines.append("| Test | Status | Details |")
        lines.append("|------|--------|---------|")

        tests = results.get("tests", {})
        for name, test in tests.items():
            status = "PASS" if test.get("ok") else "FAIL"
            detail = self._get_test_summary(name, test)
            lines.append(f"| {name} | {status} | {detail} |")

        lines.append("")

        # Detail Sections
        if "performance" in tests:
            lines.extend(self._render_performance(tests["performance"]))

        if "memory" in tests:
            lines.extend(self._render_memory(tests["memory"]))

        if "error_cascade" in tests:
            lines.extend(self._render_error_cascade(tests["error_cascade"]))

        if "data_consistency" in tests:
            lines.extend(self._render_data_consistency(tests["data_consistency"]))

        # Footer
        lines.append("---")
        lines.append("*Generiert von BenchmarkReporter (Phase 6)*")

        content = "\n".join(lines)

        # Save
        timestamp = datetime.now(timezone.utc).strftime("%Y%m%d_%H%M%S")
        filename = f"stress_test_{timestamp}.md"
        filepath = self._output_dir / filename
        filepath.write_text(content, encoding="utf-8")

        # Also save JSON
        json_path = self._output_dir / f"stress_test_{timestamp}.json"
        json_path.write_text(
            json.dumps(results, indent=2, default=str, ensure_ascii=False),
            encoding="utf-8",
        )

        print(f"{_PREFIX} Report gespeichert: {filepath}")
        print(f"{_PREFIX} JSON gespeichert: {json_path}")
        return str(filepath)

    # ------------------------------------------------------------------
    # Section Renderers
    # ------------------------------------------------------------------

    def _render_performance(self, test: dict) -> list[str]:
        lines = ["## Performance", ""]
        timings = test.get("timings", {})
        thresholds = test.get("thresholds", {})

        lines.append("| Cycle | Duration | Limit | Status |")
        lines.append("|-------|----------|-------|--------|")

        mapping = {
            "decision_cycle": "Decision Cycle",
            "anomaly_scan": "Anomaly Scan",
            "execution_path": "Execution Path",
        }

        for key, label in mapping.items():
            t = timings.get(key, {})
            dur = t.get("duration_ms", 0)
            limit = thresholds.get(f"{key}_max_ms", 0)
            ok = dur < limit
            lines.append(f"| {label} | {dur}ms | {limit}ms | {'OK' if ok else 'SLOW'} |")

        lines.append("")
        return lines

    def _render_memory(self, test: dict) -> list[str]:
        lines = ["## Memory", ""]
        snapshots = test.get("snapshots", [])

        if snapshots:
            lines.append("| Iteration | Before (MB) | After (MB) | Growth (MB) |")
            lines.append("|-----------|-------------|------------|-------------|")
            for s in snapshots:
                lines.append(f"| {s['iteration']} | {s['mem_before_mb']} | {s['mem_after_mb']} | {s['growth_mb']:+.2f} |")
            lines.append("")

        limits = test.get("limits", {})
        lines.append(f"**Max Single Growth:** {test.get('max_single_growth_mb', '?')} MB "
                      f"(Limit: {limits.get('single_max_mb', '?')} MB)")
        lines.append(f"**Total Growth:** {test.get('total_growth_mb', '?')} MB "
                      f"(Limit: {limits.get('total_max_mb', '?')} MB)")
        lines.append("")
        return lines

    def _render_error_cascade(self, test: dict) -> list[str]:
        lines = ["## Error Cascade", ""]
        lines.append(f"**Total Apps:** {test.get('total_apps', '?')} (inkl. 1 corrupted)")
        lines.append("")

        for phase in ["decision_cycle", "anomaly_scan", "execution_path"]:
            data = test.get(phase, {})
            status = "OK" if data.get("ok") else "FAIL"
            error = data.get("error", "none")
            lines.append(f"- **{phase}:** {status}" + (f" ({error})" if error else ""))

        lines.append("")
        return lines

    def _render_data_consistency(self, test: dict) -> list[str]:
        lines = ["## Data Consistency", ""]
        checks = test.get("checks", {})

        lines.append("| Check | Status | Details |")
        lines.append("|-------|--------|---------|")

        for name, check in checks.items():
            status = "OK" if check.get("ok") else "FAIL"
            detail = ""
            if not check["ok"]:
                if "invalid" in check:
                    detail = f"{len(check['invalid'])} invalid"
                elif "orphans" in check:
                    detail = f"{len(check['orphans'])} orphans"
                elif "expected" in check:
                    detail = f"expected {check['expected']}, got {check['actual']}"
            lines.append(f"| {name} | {status} | {detail} |")

        lines.append("")
        return lines

    # ------------------------------------------------------------------
    # Helpers
    # ------------------------------------------------------------------

    def _get_test_summary(self, name: str, test: dict) -> str:
        if name == "performance":
            timings = test.get("timings", {})
            total_ms = sum(t.get("duration_ms", 0) for t in timings.values())
            return f"Total: {total_ms:.0f}ms"
        elif name == "memory":
            return f"Growth: {test.get('total_growth_mb', '?')}MB"
        elif name == "error_cascade":
            return f"{test.get('total_apps', '?')} apps, corrupted data handled"
        elif name == "data_consistency":
            checks = test.get("checks", {})
            passed = sum(1 for c in checks.values() if c.get("ok"))
            return f"{passed}/{len(checks)} checks"
        return ""

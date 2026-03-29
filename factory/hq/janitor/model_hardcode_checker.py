"""Model Hardcode Checker.

Scannt alle .py-Dateien der Factory nach hardcodierten LLM-Modellnamen.
Agents sollen IMMER ueber TheBrain (ModelRouter/ProviderRouter) oder
get_fallback_model() gehen — nie direkt einen Modellnamen hardcoden.

Findet:
- HARDCODED_MODEL (red): Direkter Modellname in einem Funktionsaufruf
- HARDCODED_FALLBACK (yellow): Modellname in Fallback/Default-Kontext
- MODEL_IN_CONSTANT (yellow): Modellname in Konstante/Config (evtl. gewollt)

Rein deterministisch, kein LLM.

CLI:
    python -m factory.hq.janitor.model_hardcode_checker
"""

import logging
import re
import sys
from pathlib import Path

logger = logging.getLogger(__name__)

PROJECT_ROOT = Path(__file__).resolve().parents[3]

# --- Verzeichnisse zum Scannen ---
SCAN_DIRS = [
    PROJECT_ROOT / "factory",
    PROJECT_ROOT / "agents",
    PROJECT_ROOT / "config",
]

# --- Verzeichnisse/Dateien die uebersprungen werden ---
SKIP_PATTERNS = (
    "__pycache__",
    ".git",
    "node_modules",
    "factory/hq/dashboard",
)

# --- Whitelist: Diese Dateien BRAUCHEN Modellnamen (zentrale Registries) ---
WHITELISTED_PATHS = {
    "factory/brain/model_provider",          # Gesamtes Verzeichnis
    "factory/hq/janitor/model_hardcode_checker.py",  # Eigene Regex-Definitionen
    "config/model_router.py",
    "config/llm_config.py",
}

WHITELISTED_FILES = {
    "config/llm_profiles.json",
    # Department configs — jede hat EINE get_fallback_model() mit hardcoded Default
    "factory/pre_production/config.py",
    "factory/market_strategy/config.py",
    "factory/document_secretary/config.py",
    "factory/marketing/config.py",
    "factory/visual_audit/config.py",
    "factory/design_vision/config.py",
    "factory/mvp_scope/config.py",
    "factory/roadbook_assembly/config.py",
}

# --- Modell-Patterns (kompiliert fuer Performance) ---
MODEL_PATTERNS = {
    "anthropic": re.compile(
        r"""(?:claude-sonnet-|claude-haiku-|claude-opus-|claude-3-|claude-4-)"""
    ),
    "openai": re.compile(
        r"""(?:gpt-4o|gpt-4-|gpt-3\.5|o3-mini|o1-)"""
    ),
    "google": re.compile(
        r"""(?:gemini-pro|gemini-flash|gemini-1\.5|gemini-2)"""
    ),
    "mistral": re.compile(
        r"""(?:mistral-small|mistral-medium|mistral-large|open-mistral)"""
    ),
}

# Generisches Pattern: model = "irgendwas-irgendwas"
GENERIC_MODEL_ASSIGN = re.compile(
    r"""model\s*=\s*["']([a-z][\w]+-[\w./-]+)["']"""
)

# Pattern um String-Literale zu finden die Modellnamen enthalten
STRING_LITERAL = re.compile(r"""["']((?:claude|gpt|gemini|mistral|open-mistral|o3-mini|o1-)[\w./-]*)["']""")

# Kontext-Pattern fuer Severity-Klassifizierung
FALLBACK_CONTEXT = re.compile(
    r"""(?:fallback|default|FALLBACK|DEFAULT|_default_model|backup)""", re.IGNORECASE
)
CONSTANT_CONTEXT = re.compile(
    r"""^[A-Z_]+\s*=|^\s*["'][a-z]""", re.MULTILINE
)
CALL_CONTEXT = re.compile(
    r"""(?:model\s*=|\.create\(|\.call\(|messages\.create|chat\.completions)"""
)


def check_model_hardcodes(config: dict | None = None) -> dict:
    """Scanne die Factory nach hardcodierten Modellnamen.

    Returns:
        dict mit findings, stats, whitelisted_files
    """
    findings = []
    whitelisted = []
    scanned_files = 0
    skipped_files = 0

    for scan_dir in SCAN_DIRS:
        if not scan_dir.exists():
            continue

        for py_file in scan_dir.rglob("*.py"):
            rel = py_file.relative_to(PROJECT_ROOT).as_posix()

            # Skip-Patterns pruefen
            if any(skip in rel for skip in SKIP_PATTERNS):
                skipped_files += 1
                continue

            # Whitelist pruefen
            if _is_whitelisted(rel):
                whitelisted.append(rel)
                continue

            scanned_files += 1

            try:
                content = py_file.read_text(encoding="utf-8", errors="replace")
            except Exception:
                continue

            # Zeile fuer Zeile scannen
            for line_num, line in enumerate(content.splitlines(), start=1):
                # Kommentare ueberspringen
                stripped = line.lstrip()
                if stripped.startswith("#"):
                    continue

                matches = _find_model_strings(line)
                for match_str, provider in matches:
                    severity = _classify_severity(line, stripped)
                    findings.append({
                        "file": rel,
                        "line_number": line_num,
                        "line_content": line.rstrip()[:200],
                        "pattern_matched": match_str,
                        "provider": provider,
                        "severity": severity,
                        "suggested_fix": _get_suggested_fix(severity),
                    })

    # Stats berechnen
    red_count = sum(1 for f in findings if f["severity"] == "red")
    yellow_count = sum(1 for f in findings if f["severity"] == "yellow")

    # Deduplizieren: gleiche Datei+Zeile nur einmal zaehlen
    seen = set()
    deduped = []
    for f in findings:
        key = (f["file"], f["line_number"])
        if key not in seen:
            seen.add(key)
            deduped.append(f)
    findings = deduped
    red_count = sum(1 for f in findings if f["severity"] == "red")
    yellow_count = sum(1 for f in findings if f["severity"] == "yellow")

    logger.info(
        "Model hardcode check: %d files scanned, %d findings (%d red, %d yellow), %d whitelisted",
        scanned_files, len(findings), red_count, yellow_count, len(whitelisted),
    )

    return {
        "findings": findings,
        "stats": {
            "scanned_files": scanned_files,
            "skipped_files": skipped_files,
            "total_findings": len(findings),
            "by_severity": {"red": red_count, "yellow": yellow_count},
        },
        "whitelisted_files": sorted(set(whitelisted)),
    }


def _is_whitelisted(rel_path: str) -> bool:
    """Pruefe ob eine Datei auf der Whitelist steht."""
    for wp in WHITELISTED_PATHS:
        if rel_path.startswith(wp):
            return True
    return rel_path in WHITELISTED_FILES


def _find_model_strings(line: str) -> list[tuple[str, str]]:
    """Finde Modellnamen-Strings in einer Zeile.

    Returns:
        Liste von (match_string, provider_name)
    """
    matches = []

    # Pruefen ob die Zeile ueberhaupt einen String mit Modellnamen enthaelt
    for provider, pattern in MODEL_PATTERNS.items():
        for m in pattern.finditer(line):
            # Sicherstellen dass der Match in einem String-Literal ist
            match_text = m.group(0)
            if _is_in_string_literal(line, m.start()):
                matches.append((match_text, provider))

    # Generisches Pattern: model = "xxx-yyy"
    for m in GENERIC_MODEL_ASSIGN.finditer(line):
        model_name = m.group(1)
        # Nur wenn nicht schon durch spezifische Patterns gefunden
        already_found = any(model_name.startswith(existing[0]) for existing in matches)
        if not already_found:
            # Pruefen ob es wie ein Modellname aussieht (nicht wie ein Dateiname etc.)
            if _looks_like_model_id(model_name):
                matches.append((model_name, "unknown"))

    return matches


def _is_in_string_literal(line: str, pos: int) -> bool:
    """Pruefe ob Position in einem String-Literal liegt."""
    # Einfache Heuristik: Zaehle Anfuehrungszeichen vor der Position
    before = line[:pos]
    single_quotes = before.count("'") - before.count("\\'")
    double_quotes = before.count('"') - before.count('\\"')
    # Wenn ungerade Anzahl = wir sind in einem String
    return (single_quotes % 2 == 1) or (double_quotes % 2 == 1)


def _looks_like_model_id(name: str) -> bool:
    """Pruefe ob ein String wie eine Modell-ID aussieht."""
    # Modell-IDs: claude-xxx, gpt-xxx, gemini-xxx etc.
    model_prefixes = (
        "claude-", "gpt-", "gemini-", "mistral-", "open-mistral",
        "o3-", "o1-", "llama-", "codellama-",
    )
    return any(name.startswith(p) for p in model_prefixes)


def _classify_severity(line: str, stripped: str) -> str:
    """Klassifiziere den Fund nach Schwere.

    - red: HARDCODED_MODEL — direkt in Funktionsaufruf
    - yellow: HARDCODED_FALLBACK oder MODEL_IN_CONSTANT
    """
    # Ist es in einem Funktionsaufruf? → red
    if CALL_CONTEXT.search(line):
        return "red"

    # Fallback/Default Kontext? → yellow
    if FALLBACK_CONTEXT.search(line):
        return "yellow"

    # Konstanten-Definition (UPPERCASE =)? → yellow
    if re.match(r"^\s*[A-Z_]{2,}\s*=", line):
        return "yellow"

    # Default: red (lieber zu streng als zu locker)
    return "red"


def _get_suggested_fix(severity: str) -> str:
    """Generiere Fix-Vorschlag basierend auf Severity."""
    if severity == "red":
        return (
            "Replace with get_model_for_agent(AGENT_ID) from config.model_router "
            "or get_fallback_model() from department config. "
            "Never hardcode model strings in agent code."
        )
    return (
        "Consider using TheBrain's central model routing instead. "
        "If this is an intentional registry/config entry, add the file to the whitelist."
    )


def format_report(result: dict) -> str:
    """Formatiere den Report fuer Konsolenausgabe."""
    lines = []
    lines.append("")
    lines.append("=" * 70)
    lines.append("  MODEL HARDCODE CHECKER — Factory Scan")
    lines.append("=" * 70)
    lines.append("")

    stats = result["stats"]
    lines.append(f"  Scanned:    {stats['scanned_files']} Python files")
    lines.append(f"  Skipped:    {stats['skipped_files']} (excluded dirs)")
    lines.append(f"  Whitelisted: {len(result['whitelisted_files'])} files (TheBrain registry etc.)")
    lines.append(f"  Findings:   {stats['total_findings']}")
    lines.append(f"    RED:      {stats['by_severity']['red']} (hardcoded in function calls)")
    lines.append(f"    YELLOW:   {stats['by_severity']['yellow']} (fallbacks/constants)")
    lines.append("")

    if result["findings"]:
        lines.append("-" * 70)
        lines.append("  FINDINGS:")
        lines.append("-" * 70)

        # Gruppiert nach Datei anzeigen
        by_file: dict[str, list] = {}
        for f in result["findings"]:
            by_file.setdefault(f["file"], []).append(f)

        for filepath in sorted(by_file.keys()):
            file_findings = by_file[filepath]
            lines.append("")
            lines.append(f"  {filepath}")
            for ff in file_findings:
                sev_tag = "RED   " if ff["severity"] == "red" else "YELLOW"
                lines.append(
                    f"    [{sev_tag}] L{ff['line_number']:>4}: "
                    f"{ff['line_content'].strip()[:100]}"
                )
                lines.append(
                    f"             Pattern: {ff['pattern_matched']} ({ff['provider']})"
                )

    if result["whitelisted_files"]:
        lines.append("")
        lines.append("-" * 70)
        lines.append("  WHITELISTED (skipped):")
        lines.append("-" * 70)
        for wf in result["whitelisted_files"]:
            lines.append(f"    {wf}")

    lines.append("")
    lines.append("=" * 70)

    if stats["by_severity"]["red"] > 0:
        lines.append(
            f"  ACTION NEEDED: {stats['by_severity']['red']} hardcoded models should be "
            "replaced with TheBrain routing or get_fallback_model()."
        )
    else:
        lines.append("  All clear — no hardcoded models found.")

    lines.append("=" * 70)
    lines.append("")

    return "\n".join(lines)


def main():
    """Standalone CLI entry point."""
    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    if sys.platform == "win32":
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    result = check_model_hardcodes()
    print(format_report(result))


if __name__ == "__main__":
    main()

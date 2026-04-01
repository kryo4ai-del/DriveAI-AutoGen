"""Press Kit Generator — Generiert Press Kits aus bestehenden Assets.

Deterministisch, kein LLM. Liest bestehende Assets und packt sie zusammen.
"""

import logging
import os
import zipfile
from datetime import datetime
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.press_kit_generator")


class PressKitGenerator:
    """Generiert Press Kits aus bestehenden Assets. Deterministisch."""

    def __init__(self):
        self._factory_root = Path(__file__).resolve().parents[2]  # factory/
        self._marketing_root = Path(__file__).resolve().parents[1]  # factory/marketing/
        self._output_dir = self._marketing_root / "output" / "press_kit"
        self._output_dir.mkdir(parents=True, exist_ok=True)

    # ── Helpers ───────────────────────────────────────────

    def _count_agents(self) -> dict:
        """Zaehlt Agents aus der Registry (NICHT hardcoded!)."""
        try:
            import sys
            sys.path.insert(0, str(self._factory_root.parent))
            from factory.agent_registry import get_all_agents, get_active_agents

            all_agents = get_all_agents()
            active = get_active_agents()
            return {
                "total": len(all_agents),
                "active": len(active),
                "departments": len(set(
                    a.get("department", "unknown") for a in all_agents
                )),
            }
        except Exception as e:
            logger.warning("Could not count agents from registry: %s", e)
            return {"total": "?", "active": "?", "departments": "?"}

    def _read_file_safe(self, path: Path, max_chars: int = 5000) -> str:
        """Liest Datei sicher, gibt Fallback bei Fehler."""
        try:
            if path.exists():
                return path.read_text(encoding="utf-8")[:max_chars]
        except Exception:
            pass
        return ""

    def _count_projects(self) -> int:
        """Zaehlt Projekte im projects/ Verzeichnis."""
        projects_dir = self._factory_root.parent / "projects"
        if projects_dir.exists():
            return len([
                d for d in projects_dir.iterdir()
                if d.is_dir() and not d.name.startswith(".")
            ])
        return 0

    # ── Factory Press Kit ─────────────────────────────────

    def generate_factory_press_kit(self) -> str:
        """Factory Basis-Press-Kit mit aktuellen Zahlen."""
        agents = self._count_agents()
        project_count = self._count_projects()
        date = datetime.now().strftime("%Y-%m-%d")

        # Read narrative
        narrative_path = self._marketing_root / "brand" / "narratives" / "long_version.md"
        narrative = self._read_file_safe(narrative_path)
        if not narrative:
            narrative = (
                "DriveAI Factory ist eine autonome KI-App-Fabrik. "
                "Mehrere KI-Agenten arbeiten zusammen, um von der Idee "
                "zur fertigen App zu gelangen — ohne menschliche Entwickler."
            )

        # Read brand colors from brand_book.json
        brand_info = ""
        brand_json = self._marketing_root / "brand" / "brand_book" / "brand_book.json"
        if brand_json.exists():
            brand_info = "Brand Assets: Siehe brand_book.json fuer Farben, Fonts, Logos."

        kit = f"""# DAI-Core Factory — Press Kit

**Stand:** {date}
**Version:** 1.0

---

## Ueber die Factory

{narrative}

---

## Key Facts

| Fakt | Wert |
|---|---|
| Agents (gesamt) | {agents['total']} |
| Agents (aktiv) | {agents['active']} |
| Departments | {agents['departments']} |
| Projekte in Pipeline | {project_count} |
| Technologie | Python, AutoGen AgentChat v0.4+, Claude AI |
| LLM Provider | Anthropic (Claude Sonnet, Haiku, Opus) |
| Kosten-Beispiel | EchoMatch Roadbook in 4 Min fuer $0.51 |

---

## Was die Factory kann

- **iOS Apps** (Swift/SwiftUI) — vollstaendige App-Generierung
- **Android Apps** (Kotlin) — mit Assembly Line
- **Web Apps** (React/TypeScript) — Frontend + Build
- **Unity Games** — Level, Assets, Sound
- **Marketing** — Content, Videos, Social Media, PR
- **Quality Assurance** — Automatische Tests, Bug Hunting
- **Store Submission** — App Store + Google Play Vorbereitung

---

## Gruender / Team

<<CEO: Bitte manuell ausfuellen>>

---

## Brand Assets

{brand_info if brand_info else "Brand-Farben und Logos auf Anfrage verfuegbar."}

- Primary: Magenta (#E91E8C)
- Secondary: Cyan (#00E5FF)
- Background: Void (#0D0D0D)

---

## Kontakt

- Email: factory@dai-core.ai
- Website: <<Website URL eintragen>>
- GitHub: github.com/kryo4ai-del/DriveAI-AutoGen

---

*Dieses Press Kit wurde automatisch generiert. Agent-Zahlen werden live aus der Registry gelesen.*
"""

        output_path = self._output_dir / "factory_press_kit.md"
        output_path.write_text(kit, encoding="utf-8")
        logger.info("Factory press kit: %s", output_path)
        return str(output_path)

    # ── App Press Kit ─────────────────────────────────────

    def generate_app_press_kit(self, project_slug: str) -> str:
        """App-spezifisches Press Kit."""
        date = datetime.now().strftime("%Y-%m-%d")

        # Read story brief
        story_path = (
            self._marketing_root / "brand" / "app_stories"
            / project_slug / "story_brief.md"
        )
        story = self._read_file_safe(story_path)
        if not story:
            story = f"Story Brief fuer {project_slug} nicht gefunden. Bitte manuell ergaenzen."

        # Screenshots reference
        screenshots_dir = self._marketing_root / "output" / project_slug / "screenshots"
        has_screenshots = screenshots_dir.exists() and any(screenshots_dir.iterdir()) if screenshots_dir.exists() else False

        kit = f"""# {project_slug.title()} — App Press Kit

**Stand:** {date}

---

## App Story

{story}

---

## Screenshots

{"Screenshots verfuegbar in: " + str(screenshots_dir) if has_screenshots else "Screenshots werden bei Bedarf generiert."}

---

## Technische Details

- Generiert von der DAI-Core Factory
- Autonome Entwicklung durch KI-Agents
- Qualitaetssicherung durch QA Department

---

## Kontakt

factory@dai-core.ai

---

*Generiert von PressKitGenerator. Fuer das vollstaendige Factory Press Kit siehe factory_press_kit.md.*
"""

        output_path = self._output_dir / f"{project_slug}_press_kit.md"
        output_path.write_text(kit, encoding="utf-8")
        logger.info("App press kit: %s", output_path)
        return str(output_path)

    # ── Package as ZIP ────────────────────────────────────

    def package_press_kit(self, project_slug: str = None) -> str:
        """Buendelt alles als ZIP."""
        # Ensure factory kit exists
        factory_kit_path = self._output_dir / "factory_press_kit.md"
        if not factory_kit_path.exists():
            self.generate_factory_press_kit()

        slug = project_slug or "factory"
        zip_name = f"press_kit_{slug}.zip"
        zip_path = self._output_dir / zip_name

        with zipfile.ZipFile(zip_path, "w", zipfile.ZIP_DEFLATED) as zf:
            # Factory press kit (always)
            if factory_kit_path.exists():
                zf.write(factory_kit_path, "factory_press_kit.md")

            # App press kit (if slug)
            if project_slug:
                app_kit_path = self._output_dir / f"{project_slug}_press_kit.md"
                if not app_kit_path.exists():
                    self.generate_app_press_kit(project_slug)
                if app_kit_path.exists():
                    zf.write(app_kit_path, f"{project_slug}_press_kit.md")

            # Brand book (if exists)
            brand_md = self._marketing_root / "brand" / "brand_book" / "brand_book.md"
            if brand_md.exists():
                zf.write(brand_md, "brand_book.md")

            # Graphics (if exist for project)
            if project_slug:
                graphics_dir = self._marketing_root / "output" / project_slug / "graphics"
                if graphics_dir.exists():
                    for f in graphics_dir.iterdir():
                        if f.is_file():
                            zf.write(f, f"graphics/{f.name}")

        logger.info("Press kit ZIP: %s (%d files)", zip_path, len(zipfile.ZipFile(zip_path).namelist()))
        return str(zip_path)

    # ── Update ────────────────────────────────────────────

    def update_press_kit(self) -> str:
        """Aktualisiert das Factory Press Kit mit neuesten Zahlen."""
        return self.generate_factory_press_kit()

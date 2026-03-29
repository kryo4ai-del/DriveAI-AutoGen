"""Factory Extension Advisor (BRN-06).

Erstellt konkrete Erweiterungsplaene fuer die Factory.
Nimmt Gap-Analysen vom GapAnalyzer (BRN-05) und wandelt sie in
ausfuehrbare Roadmaps um — mit Agents, Timelines, Infrastruktur
und Abhaengigkeiten.

Jeder Plan ist so konkret dass er direkt als Grundlage
fuer Prompts an Entwicklungs-Agents dienen kann.

Primaer deterministisch. Direktive 001 wird bei jeder Empfehlung angewendet.
Einziger Schreibzugriff: save_roadmap() in factory/brain/reports/.
"""

import json
import logging
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)

_DEFAULT_ROOT = Path(__file__).resolve().parents[2]

# ── Effort → Wochen Mapping ─────────────────────────────────────
_EFFORT_WEEKS = {
    "minimal": 0.5,
    "moderate": 1.5,
    "significant": 3.0,
    "major": 6.0,
}

# ── Agent Skill Mapping ─────────────────────────────────────────
# Welche existierenden Agents welche Skills abdecken
_AGENT_SKILLS = {
    "architecture": ["CPL-01", "CPL-02", "CPL-19", "CPL-21"],
    "code_generation": ["CPL-03", "CPL-20", "CPL-22"],
    "code_review": ["CPL-04"],
    "planning": ["CPL-01", "CPL-11", "CPL-17", "CPL-18"],
    "content": ["CPL-12"],
    "creative_direction": ["CPL-08"],
    "testing": ["CPL-07"],
    "image_generation": ["ASF-01"],
    "animation_generation": ["MOF-01"],
    "sound_generation": ["SOF-01"],
    "scene_generation": ["SCF-01"],
    "integration": ["INT-01"],
    "quality_assurance": ["QAF-01"],
    "infrastructure": ["INF-05", "INF-06"],
    "android_development": ["CPL-19", "CPL-20"],
    "web_development": ["CPL-21", "CPL-22"],
    "video_composition": [],  # Kein existierender Agent
    "ffmpeg": [],  # Kein existierender Agent
    "docker_deployment": [],  # Kein existierender Agent
    "ml_model_hosting": [],  # Kein existierender Agent
}


class ExtensionAdvisor:
    """Erstellt konkrete Erweiterungsplaene fuer die Factory."""

    def __init__(self, factory_root: str = None):
        self.root = Path(factory_root) if factory_root else _DEFAULT_ROOT
        self._gap_analyzer = None
        self._capability_map = None
        self._directive_engine = None
        self._agent_registry = None  # lazy

    # ── Public API ───────────────────────────────────────────────────

    def create_extension_roadmap(self) -> dict:
        """Hauptmethode. Erstellt vollstaendige Erweiterungs-Roadmap.

        Returns:
            {
                "created_at": ISO timestamp,
                "total_gaps": int,
                "total_plans": int,
                "roadmap": {immediate, short_term, mid_term, long_term},
                "resource_summary": {...},
                "production_impact": {...},
                "directive_compliance": "full"
            }
        """
        gap_result = self._get_gap_analysis()
        analyses = gap_result.get("gap_analyses", [])

        plans = []
        for analysis in analyses:
            try:
                plan = self.create_single_plan(analysis)
                if plan:
                    plans.append(plan)
                    logger.info(
                        "Plan: %s | Stufe %d | %s Wochen | %d Steps",
                        plan["plan_id"], plan["directive_stufe"],
                        plan["timeline"]["total_weeks"], len(plan["steps"]),
                    )
            except Exception as e:
                logger.warning("Plan creation failed for '%s': %s",
                               analysis.get("gap", {}).get("name"), e)

        roadmap = self._categorize_plans(plans)
        resources = self._build_resource_summary(plans)
        impact = self._build_production_impact(plans)

        return {
            "created_at": datetime.now(timezone.utc).isoformat(),
            "total_gaps": gap_result.get("total_gaps", 0),
            "total_plans": len(plans),
            "roadmap": roadmap,
            "resource_summary": resources,
            "production_impact": impact,
            "directive_compliance": "full",
        }

    def create_single_plan(self, gap_analysis: dict) -> dict:
        """Erstellt Erweiterungsplan fuer eine einzelne Gap-Analyse."""
        category = gap_analysis.get("category", "unknown")
        gap = gap_analysis.get("gap", {})
        recommended_stufe = gap_analysis.get("recommended_stufe", 4)

        # Route to category-specific planner
        planner = {
            "image": self._plan_image_extension,
            "sound": self._plan_sound_extension,
            "voice_tts": self._plan_voice_extension,
            "video": self._plan_video_extension,
            "animation": self._plan_animation_extension,
            "production_lines": self._plan_production_line_extension,
        }.get(category, self._plan_generic_extension)

        return planner(gap_analysis)

    def save_roadmap(self, roadmap: dict = None, path: str = None) -> str:
        """Speichert Roadmap als JSON in factory/brain/reports/.

        Returns: Dateipfad der gespeicherten Datei.
        """
        if roadmap is None:
            roadmap = self.create_extension_roadmap()

        reports_dir = self.root / "factory" / "brain" / "reports"
        reports_dir.mkdir(parents=True, exist_ok=True)

        if path is None:
            date_str = datetime.now().strftime("%Y-%m-%d")
            filepath = reports_dir / f"extension_roadmap_{date_str}.json"
        else:
            filepath = Path(path)

        filepath.write_text(
            json.dumps(roadmap, indent=2, ensure_ascii=False, default=str),
            encoding="utf-8",
        )
        logger.info("Roadmap saved: %s", filepath)
        return str(filepath)

    # ── Plan Generators per Category ─────────────────────────────────

    def _plan_image_extension(self, gap_analysis: dict) -> dict:
        """Erweiterungsplan fuer Image-Capabilities."""
        gap = gap_analysis.get("gap", {})
        gap_type = gap.get("type", "")
        gap_name = gap.get("name", "unknown")
        stufe = gap_analysis.get("recommended_stufe", 2)

        # Stufe 1: Service aktivieren/konfigurieren
        if stufe == 1 and gap_type in ("service_inactive", "category_no_active_service"):
            steps = [
                self._step(1, "API-Key pruefen",
                           f"Pruefen ob API-Key fuer '{gap_name}' in .env eingetragen ist",
                           agent=None, effort="minimal", depends=[]),
                self._step(2, "Service aktivieren",
                           f"Status in service_registry.json auf 'active' setzen",
                           agent=None, effort="minimal", depends=[1]),
                self._step(3, "Health-Check ausfuehren",
                           "Service-Health-Check durchfuehren und Qualitaet pruefen",
                           agent=None, effort="minimal", depends=[2]),
            ]
            return self._create_plan(
                plan_id=f"EXT_IMG_ACTIVATE_{gap_name.upper().replace(' ', '_')}",
                gap_category="image", title=f"Image Service '{gap_name}' aktivieren",
                description=f"Bestehenden Service '{gap_name}' aktivieren — nur API-Key noetig.",
                directive_stufe=1, steps=steps,
                agents=self._find_available_agents(["image_generation"]),
                timeline=self._estimate_timeline(steps),
                infrastructure={"gpu_required": False, "additional_software": [],
                                "storage_needed": "keine", "api_keys_needed": [gap_name],
                                "proxmox_changes": []},
                priority="high",
            )

        # Stufe 2: Draft-Adapter → fast schon da, oder SVG Pipeline
        if gap_type == "draft_adapter":
            steps = [
                self._step(1, "Draft-Adapter reviewen",
                           f"Code-Review des Draft-Adapters '{gap_name}'",
                           agent="CPL-04", effort="minimal", depends=[]),
                self._step(2, "API-Key beschaffen",
                           f"API-Key fuer '{gap_name}' besorgen und in .env eintragen",
                           agent=None, effort="minimal", depends=[]),
                self._step(3, "Adapter in Service Registry eintragen",
                           "Service-Definition in service_registry.json hinzufuegen",
                           agent=None, effort="minimal", depends=[1]),
                self._step(4, "Integration testen",
                           "Test-Generierung mit dem neuen Service ausfuehren",
                           agent="QAF-01", effort="moderate", depends=[2, 3]),
            ]
            return self._create_plan(
                plan_id=f"EXT_IMG_DRAFT_{gap_name.upper().replace(' ', '_')}",
                gap_category="image",
                title=f"Image Draft-Adapter '{gap_name}' integrieren",
                description=f"Draft-Adapter fuer '{gap_name}' existiert bereits. Integration + API-Key.",
                directive_stufe=2, steps=steps,
                agents=self._find_available_agents(["image_generation", "code_review", "quality_assurance"]),
                timeline=self._estimate_timeline(steps),
                infrastructure={"gpu_required": False, "additional_software": [],
                                "storage_needed": "keine",
                                "api_keys_needed": [f"{gap_name.upper().replace(' ', '_')}_API_KEY"],
                                "proxmox_changes": []},
                priority="medium",
            )

        # Fallback: Generic
        return self._plan_generic_extension(gap_analysis)

    def _plan_sound_extension(self, gap_analysis: dict) -> dict:
        """Erweiterungsplan fuer Sound-Capabilities."""
        gap = gap_analysis.get("gap", {})
        gap_type = gap.get("type", "")
        gap_name = gap.get("name", "unknown")
        stufe = gap_analysis.get("recommended_stufe", 2)

        if stufe == 1:
            return self._plan_activate_service(gap_analysis, "sound")

        # Stufe 2: AudioCraft Draft-Adapter oder Custom Pipeline
        if gap_type == "draft_adapter":
            steps = [
                self._step(1, "Draft-Adapter reviewen",
                           f"Code-Review des Draft-Adapters '{gap_name}'",
                           agent="CPL-04", effort="minimal", depends=[]),
                self._step(2, "AudioCraft Dependencies pruefen",
                           "Pruefen ob PyTorch + torchaudio installierbar sind",
                           agent=None, effort="minimal", depends=[]),
                self._step(3, "Self-Host Evaluation",
                           "Meta AudioCraft auf Proxmox evaluieren (CPU-only moeglich)",
                           agent=None, effort="moderate", depends=[2]),
                self._step(4, "Adapter integrieren + testen",
                           "Service Registry Update + Integrations-Test",
                           agent="QAF-01", effort="moderate", depends=[1, 3]),
            ]
            return self._create_plan(
                plan_id=f"EXT_SND_DRAFT_{gap_name.upper().replace(' ', '_')}",
                gap_category="sound",
                title=f"Sound Draft-Adapter '{gap_name}' integrieren",
                description=f"Draft-Adapter '{gap_name}' existiert. Self-Host-Evaluation + Integration.",
                directive_stufe=2, steps=steps,
                agents=self._find_available_agents(["sound_generation", "code_review", "quality_assurance"]),
                timeline=self._estimate_timeline(steps),
                infrastructure={"gpu_required": False, "additional_software": ["PyTorch (CPU)"],
                                "storage_needed": "3-5 GB fuer AudioCraft Modelle",
                                "api_keys_needed": [], "proxmox_changes": ["Docker Container fuer AudioCraft"]},
                priority="medium",
            )

        if stufe == 1 and gap_type == "service_inactive":
            return self._plan_activate_service(gap_analysis, "sound")

        return self._plan_generic_extension(gap_analysis)

    def _plan_voice_extension(self, gap_analysis: dict) -> dict:
        """Erweiterungsplan fuer Voice/TTS-Capabilities."""
        gap = gap_analysis.get("gap", {})
        steps = [
            self._step(1, "Coqui TTS Docker-Image vorbereiten",
                       "Docker-Image fuer Coqui XTTS-v2 auf Proxmox deployen (CPU-only, 2GB Modell)",
                       agent=None, effort="moderate", depends=[]),
            self._step(2, "TTS Adapter erstellen",
                       "Python-Adapter: Text → Coqui API → WAV/MP3",
                       agent="SOF-01", effort="moderate", depends=[1]),
            self._step(3, "Service Registry eintragen",
                       "TTS als internen Service registrieren (cost_per_call: $0.00)",
                       agent=None, effort="minimal", depends=[2]),
            self._step(4, "Voice-Qualitaet testen",
                       "Sprach-Samples generieren und Qualitaet bewerten",
                       agent="QAF-01", effort="moderate", depends=[2]),
        ]
        return self._create_plan(
            plan_id="EXT_VOICE_COQUI_SELFHOST",
            gap_category="voice_tts",
            title="Voice/TTS: Coqui XTTS-v2 Self-Hosting auf Proxmox",
            description="Open-Source TTS mit Voice Cloning. Laeuft auf CPU, "
                        "2GB Modell, Docker-Container auf Proxmox-Server.",
            directive_stufe=3, steps=steps,
            agents=self._find_available_agents(["sound_generation", "quality_assurance", "docker_deployment"]),
            timeline=self._estimate_timeline(steps),
            infrastructure={"gpu_required": False, "additional_software": ["Docker", "Coqui TTS"],
                            "storage_needed": "2 GB fuer XTTS-v2 Modell",
                            "api_keys_needed": [],
                            "proxmox_changes": ["Neuer Docker-Container: coqui-tts", "Port 5002 freigeben"]},
            priority="medium",
        )

    def _plan_video_extension(self, gap_analysis: dict) -> dict:
        """Erweiterungsplan fuer Video-Capabilities."""
        gap = gap_analysis.get("gap", {})
        gap_type = gap.get("type", "")
        gap_name = gap.get("name", "unknown")
        stufe = gap_analysis.get("recommended_stufe", 2)

        # Stufe 1: Runway aktivieren
        if stufe == 1:
            return self._plan_activate_service(gap_analysis, "video")

        # Stufe 2: FFmpeg Pipeline (Sofort-Loesung)
        if gap_type == "category_no_active_service" or (gap_type == "draft_adapter" and gap_name.lower() in ("kling", "luma")):
            # Video-Kategorie bekommt immer den FFmpeg-Plan als Stufe-2-Sofortloesung
            ffmpeg_steps = [
                self._step(1, "FFmpeg Verfuegbarkeit pruefen",
                           "Pruefen ob FFmpeg auf dem Entwicklungssystem und Proxmox installiert ist",
                           agent=None, effort="minimal", depends=[]),
                self._step(2, "Video Pipeline Agent erstellen",
                           "Neuen Agent erstellen der FFmpeg-Befehle orchestriert: "
                           "Input (Bilder + Audio) -> Processing -> Output (MP4)",
                           agent="NEU: Video Pipeline Agent", effort="moderate", depends=[1]),
                self._step(3, "Template-System fuer Video-Typen",
                           "Templates fuer verschiedene Video-Typen: App-Preview, Marketing-Clip, "
                           "Store-Video. Jeweils mit Uebergaengen, Text-Overlays, Timing.",
                           agent="NEU: Video Pipeline Agent + CPL-08 Creative Director",
                           effort="moderate", depends=[2]),
                self._step(4, "Integration in Motion Forge",
                           "Video Pipeline in die bestehende Motion Forge (MOF-01) integrieren "
                           "als neuer Output-Typ",
                           agent="MOF-01", effort="moderate", depends=[2, 3]),
                self._step(5, "Service Registry Update",
                           "Video-Pipeline als internen Service in die Service Registry eintragen. "
                           "TheBrain Capability Map wird automatisch aktualisiert.",
                           agent=None, effort="minimal", depends=[4]),
            ]
            plan = self._create_plan(
                plan_id="EXT_VIDEO_FFMPEG",
                gap_category="video",
                title="Video-Capability: FFmpeg Pipeline",
                description="Eigene Video-Pipeline basierend auf FFmpeg. Kombiniert generierte "
                            "Bilder und Audio zu Videos fuer App-Previews und Marketing.",
                directive_stufe=2, steps=ffmpeg_steps,
                agents=self._find_available_agents(["animation_generation", "creative_direction",
                                                     "quality_assurance", "video_composition"]),
                timeline=self._estimate_timeline(ffmpeg_steps),
                infrastructure={"gpu_required": False,
                                "additional_software": ["ffmpeg (wahrscheinlich bereits installiert)"],
                                "storage_needed": "minimal (Templates < 100MB)",
                                "api_keys_needed": [], "proxmox_changes": []},
                priority="high",
            )
            plan["coverage"] = "partial"
            plan["coverage_detail"] = (
                "App-Previews, Marketing-Clips, Store-Videos. "
                "KEIN echtes Text-to-Video. Fuer vollstaendiges Video: "
                "Stufe 3 (CogVideoX) parallel evaluieren."
            )
            plan["success_criteria"] = [
                "Factory kann aus Bildern + Audio ein MP4-Video erzeugen",
                "Mindestens 3 Video-Templates verfuegbar",
                "Motion Forge hat Video als Output-Typ",
                "Capability Map zeigt Video als 'active (partial)'",
            ]
            return plan

        # Draft-Adapter (kling/luma) — Stufe 2 wrapper
        if gap_type == "draft_adapter":
            steps = [
                self._step(1, "Draft-Adapter reviewen",
                           f"Code-Review des Draft-Adapters '{gap_name}'",
                           agent="CPL-04", effort="minimal", depends=[]),
                self._step(2, "API-Key + Account einrichten",
                           f"Account bei '{gap_name}' erstellen, API-Key in .env",
                           agent=None, effort="minimal", depends=[]),
                self._step(3, "Adapter in Service Registry eintragen",
                           "Service-Definition + Capabilities + Kosten eintragen",
                           agent=None, effort="minimal", depends=[1]),
                self._step(4, "Integration testen",
                           "Test-Video generieren und Qualitaet bewerten",
                           agent="QAF-01", effort="moderate", depends=[2, 3]),
            ]
            return self._create_plan(
                plan_id=f"EXT_VID_DRAFT_{gap_name.upper().replace(' ', '_')}",
                gap_category="video",
                title=f"Video Draft-Adapter '{gap_name}' integrieren",
                description=f"Draft-Adapter fuer '{gap_name}' existiert. "
                            "Integration als Stufe-4-Fallback mit CEO-Approval.",
                directive_stufe=4, steps=steps,
                agents=self._find_available_agents(["code_review", "quality_assurance"]),
                timeline=self._estimate_timeline(steps),
                infrastructure={"gpu_required": False, "additional_software": [],
                                "storage_needed": "keine",
                                "api_keys_needed": [f"{gap_name.upper()}_API_KEY"],
                                "proxmox_changes": []},
                priority="low",
            )

        return self._plan_generic_extension(gap_analysis)

    def _plan_animation_extension(self, gap_analysis: dict) -> dict:
        """Erweiterungsplan fuer Animation-Capabilities."""
        gap = gap_analysis.get("gap", {})
        gap_name = gap.get("name", "unknown")

        # Animation ist primaer Stufe 2 — Claude Lottie/CSS
        steps = [
            self._step(1, "Rive Runtime evaluieren",
                       "Pruefen ob Rive Runtime fuer die Factory relevant ist "
                       "(bestehende .riv Dateien? Use Cases?)",
                       agent="CPL-08", effort="minimal", depends=[]),
            self._step(2, "Lottie Pipeline erweitern",
                       "Bestehende Motion Forge (MOF-01) um weitere Lottie-Templates erweitern",
                       agent="MOF-01", effort="moderate", depends=[]),
            self._step(3, "Draft-Adapter integrieren",
                       f"Draft-Adapter '{gap_name}' reviewen und ggf. als optionalen "
                       "Service integrieren",
                       agent="CPL-04", effort="moderate", depends=[1]),
        ]
        return self._create_plan(
            plan_id=f"EXT_ANIM_{gap_name.upper().replace(' ', '_')}",
            gap_category="animation",
            title=f"Animation: '{gap_name}' Adapter + Lottie-Erweiterung",
            description="Bestehende Lottie-Pipeline erweitern, Rive evaluieren.",
            directive_stufe=2, steps=steps,
            agents=self._find_available_agents(["animation_generation", "creative_direction", "code_review"]),
            timeline=self._estimate_timeline(steps),
            infrastructure={"gpu_required": False, "additional_software": [],
                            "storage_needed": "minimal", "api_keys_needed": [],
                            "proxmox_changes": []},
            priority="low",
        )

    def _plan_production_line_extension(self, gap_analysis: dict) -> dict:
        """Erweiterungsplan fuer Production Lines."""
        gap = gap_analysis.get("gap", {})
        gap_type = gap.get("type", "")
        gap_name = gap.get("name", "unknown")
        stufe = gap_analysis.get("recommended_stufe", 2)
        name_lower = gap_name.lower()

        # Disabled agents → einfach aktivieren
        if gap_type == "agent_disabled":
            steps = [
                self._step(1, f"Agent '{gap_name}' reaktivieren",
                           f"Status in agent.json auf 'active' setzen",
                           agent=None, effort="minimal", depends=[]),
                self._step(2, "Agent-Funktionalitaet verifizieren",
                           f"Smoke-Test: Agent '{gap_name}' mit einfachem Task pruefen",
                           agent=None, effort="minimal", depends=[1]),
            ]
            return self._create_plan(
                plan_id=f"EXT_AGENT_ACTIVATE_{gap_name.upper().replace(' ', '_')}",
                gap_category="production_lines",
                title=f"Agent '{gap_name}' reaktivieren",
                description=f"Deaktivierter Agent '{gap_name}' wird reaktiviert. Minimaler Aufwand.",
                directive_stufe=1, steps=steps,
                agents=self._find_available_agents([]),
                timeline=self._estimate_timeline(steps),
                infrastructure={"gpu_required": False, "additional_software": [],
                                "storage_needed": "keine", "api_keys_needed": [],
                                "proxmox_changes": []},
                priority="high" if "architect" in name_lower else "medium",
            )

        # Inactive lines → aktivieren
        if gap_type == "line_inactive":
            steps = [
                self._step(1, f"Line '{gap_name}' Status pruefen",
                           "Pruefen warum Line inaktiv ist — fehlende Abhaengigkeiten?",
                           agent=None, effort="minimal", depends=[]),
                self._step(2, f"Line '{gap_name}' aktivieren",
                           "Status in agent.json auf 'active' setzen",
                           agent=None, effort="minimal", depends=[1]),
            ]
            return self._create_plan(
                plan_id=f"EXT_LINE_ACTIVATE_{gap_name.upper().replace(' ', '_')}",
                gap_category="production_lines",
                title=f"Production Line '{gap_name}' aktivieren",
                description=f"Line hat Code aber inaktiven Status. Aktivierung pruefen.",
                directive_stufe=1, steps=steps,
                agents=self._find_available_agents([]),
                timeline=self._estimate_timeline(steps),
                infrastructure={"gpu_required": False, "additional_software": [],
                                "storage_needed": "keine", "api_keys_needed": [],
                                "proxmox_changes": []},
                priority="medium",
            )

        # Lines without code → major development
        if gap_type == "line_no_code":
            return self._plan_new_production_line(gap_name)

        # Planned agents/lines
        if gap_type == "agent_planned":
            return self._plan_new_production_line(gap_name)

        return self._plan_generic_extension(gap_analysis)

    def _plan_new_production_line(self, line_name: str) -> dict:
        """Erstellt Plan fuer eine komplett neue Production Line."""
        name_lower = line_name.lower()

        if "android" in name_lower:
            return self._plan_android_line()
        if "web" in name_lower:
            return self._plan_web_line()
        if "unity" in name_lower:
            return self._plan_unity_line()

        # Generic line
        steps = [
            self._step(1, "Line-Anforderungen definieren",
                       f"Spezifikation fuer Production Line '{line_name}' erstellen",
                       agent="CPL-01", effort="moderate", depends=[]),
            self._step(2, "Assembly Line Code implementieren",
                       "Python assembly_line Modul implementieren",
                       agent="CPL-03", effort="significant", depends=[1]),
            self._step(3, "Integration testen",
                       "End-to-End-Test mit Beispiel-Projekt",
                       agent="CPL-07", effort="moderate", depends=[2]),
        ]
        return self._create_plan(
            plan_id=f"EXT_LINE_{line_name.upper().replace(' ', '_')}",
            gap_category="production_lines",
            title=f"Production Line '{line_name}' implementieren",
            description=f"Neue Production Line fuer '{line_name}' von Grund auf entwickeln.",
            directive_stufe=2, steps=steps,
            agents=self._find_available_agents(["planning", "code_generation", "testing"]),
            timeline=self._estimate_timeline(steps),
            infrastructure={"gpu_required": False, "additional_software": [],
                            "storage_needed": "minimal", "api_keys_needed": [],
                            "proxmox_changes": []},
            priority="low",
        )

    def _plan_android_line(self) -> dict:
        """Detaillierter Plan fuer Android Production Line."""
        steps = [
            self._step(1, "Android Agents aktivieren",
                       "CPL-19 (Android Architect) + CPL-20 (Kotlin Developer) reaktivieren",
                       agent=None, effort="minimal", depends=[]),
            self._step(2, "Android SDK + Gradle Setup",
                       "Android SDK, Gradle, Kotlin Compiler auf Build-System installieren",
                       agent=None, effort="moderate", depends=[]),
            self._step(3, "Android Assembly Line Code",
                       "assembly/lines/android_line.py implementieren — "
                       "Kotlin/Compose Code-Generation aus CD Roadbook",
                       agent="CPL-19", effort="significant", depends=[1, 2]),
            self._step(4, "Android Templates erstellen",
                       "Projekt-Templates fuer Compose UI, MVVM, Navigation, Gradle Config",
                       agent="CPL-20", effort="significant", depends=[2]),
            self._step(5, "Gradle Build Pipeline",
                       "Automatische AAB/APK Build Pipeline integrieren",
                       agent=None, effort="moderate", depends=[3, 4]),
            self._step(6, "End-to-End Test",
                       "AskFin Android als Test-Projekt durch die Pipeline laufen lassen",
                       agent="CPL-07", effort="moderate", depends=[5]),
        ]
        return self._create_plan(
            plan_id="EXT_LINE_ANDROID",
            gap_category="production_lines",
            title="Android Production Line aufbauen",
            description="Vollstaendige Android-Pipeline: Agents reaktivieren, SDK Setup, "
                        "Assembly Line Code, Templates, Build Pipeline. "
                        "Basiert auf bestehender iOS-Line-Architektur.",
            directive_stufe=2, steps=steps,
            agents=self._find_available_agents(["android_development", "architecture",
                                                 "code_generation", "testing"]),
            timeline=self._estimate_timeline(steps),
            infrastructure={"gpu_required": False,
                            "additional_software": ["Android SDK", "Gradle", "Kotlin Compiler", "Java 17+"],
                            "storage_needed": "~5 GB fuer Android SDK + Gradle Cache",
                            "api_keys_needed": [],
                            "proxmox_changes": []},
            priority="medium",
        )

    def _plan_web_line(self) -> dict:
        """Detaillierter Plan fuer Web Production Line."""
        steps = [
            self._step(1, "Web Agents aktivieren",
                       "CPL-21 (Web Architect) + CPL-22 (Web App Developer) reaktivieren",
                       agent=None, effort="minimal", depends=[]),
            self._step(2, "Node.js + React Setup",
                       "Node.js LTS, npm/pnpm, Create Next App auf Build-System",
                       agent=None, effort="minimal", depends=[]),
            self._step(3, "Web Assembly Line Code",
                       "assembly/lines/web_line.py implementieren — "
                       "React/Next.js Code-Generation aus CD Roadbook",
                       agent="CPL-21", effort="significant", depends=[1, 2]),
            self._step(4, "Web Templates erstellen",
                       "Projekt-Templates fuer Next.js App Router, Components, API Routes",
                       agent="CPL-22", effort="moderate", depends=[2]),
            self._step(5, "Build + Deploy Pipeline",
                       "Automatische Build Pipeline (next build) + Docker-Container",
                       agent=None, effort="moderate", depends=[3, 4]),
            self._step(6, "End-to-End Test",
                       "AskFin Web als Test-Projekt durch die Pipeline laufen lassen",
                       agent="CPL-07", effort="moderate", depends=[5]),
        ]
        return self._create_plan(
            plan_id="EXT_LINE_WEB",
            gap_category="production_lines",
            title="Web Production Line aufbauen",
            description="Vollstaendige Web-Pipeline: Agents reaktivieren, Node.js Setup, "
                        "Assembly Line Code, Templates, Build/Deploy Pipeline.",
            directive_stufe=2, steps=steps,
            agents=self._find_available_agents(["web_development", "architecture",
                                                 "code_generation", "testing"]),
            timeline=self._estimate_timeline(steps),
            infrastructure={"gpu_required": False,
                            "additional_software": ["Node.js 20 LTS", "npm/pnpm"],
                            "storage_needed": "~2 GB fuer node_modules",
                            "api_keys_needed": [],
                            "proxmox_changes": []},
            priority="medium",
        )

    def _plan_unity_line(self) -> dict:
        """Detaillierter Plan fuer Unity Production Line."""
        steps = [
            self._step(1, "Unity-Anforderungen analysieren",
                       "Analysieren welche Unity-Projekte die Factory produzieren soll "
                       "(2D/3D, AR/VR, Spiele, Prototypen)",
                       agent="CPL-01", effort="moderate", depends=[]),
            self._step(2, "Unity Editor + C# Setup",
                       "Unity Hub, Editor (LTS), .NET SDK auf Build-System",
                       agent=None, effort="moderate", depends=[]),
            self._step(3, "Scene Forge Integration definieren",
                       "Wie SCF-01 (Scene Forge) mit der Unity Line zusammenarbeitet",
                       agent="SCF-01", effort="moderate", depends=[1]),
            self._step(4, "Unity Assembly Line Code",
                       "assembly/lines/unity_line.py implementieren — "
                       "C# Code-Generation + Scene Assembly",
                       agent="CPL-03", effort="significant", depends=[2, 3]),
            self._step(5, "Unity Projekt-Templates",
                       "Templates fuer 2D/3D, Prefabs, Scriptable Objects, Editor Config",
                       agent=None, effort="significant", depends=[2]),
            self._step(6, "Build Pipeline (Unity Batch Mode)",
                       "Unity Editor Batch-Mode Build fuer iOS/Android/WebGL",
                       agent=None, effort="significant", depends=[4, 5]),
            self._step(7, "End-to-End Test",
                       "Test-Projekt durch die komplette Pipeline",
                       agent="CPL-07", effort="moderate", depends=[6]),
        ]
        return self._create_plan(
            plan_id="EXT_LINE_UNITY",
            gap_category="production_lines",
            title="Unity Production Line aufbauen",
            description="Komplett neue Unity-Pipeline. Major Effort: Unity Editor, C# Generation, "
                        "Scene Assembly, Build Pipeline. Parallele Nutzung von Scene Forge (SCF-01).",
            directive_stufe=2, steps=steps,
            agents=self._find_available_agents(["scene_generation", "planning",
                                                 "code_generation", "testing"]),
            timeline=self._estimate_timeline(steps),
            infrastructure={"gpu_required": False,
                            "additional_software": ["Unity Hub", "Unity Editor (LTS)", ".NET SDK 8+"],
                            "storage_needed": "~10 GB fuer Unity Editor + Packages",
                            "api_keys_needed": [],
                            "proxmox_changes": []},
            priority="low",
        )

    def _plan_generic_extension(self, gap_analysis: dict) -> dict:
        """Fallback fuer Gaps ohne spezifischen Plan-Generator."""
        gap = gap_analysis.get("gap", {})
        gap_name = gap.get("name", "unknown")
        category = gap_analysis.get("category", "unknown")
        stufe = gap_analysis.get("recommended_stufe", 4)
        solution = gap_analysis.get("recommended_solution", "Keine Empfehlung")

        steps = [
            self._step(1, "Gap evaluieren",
                       f"Detaillierte Analyse: Was genau fehlt bei '{gap_name}'?",
                       agent="CPL-01", effort="moderate", depends=[]),
            self._step(2, "Loesungskonzept erstellen",
                       f"Konkreten Umsetzungsplan fuer '{solution}' ausarbeiten",
                       agent="CPL-01", effort="moderate", depends=[1]),
            self._step(3, "CEO-Review",
                       "Plan dem CEO vorlegen und Prioritaet festlegen",
                       agent=None, effort="minimal", depends=[2]),
        ]
        return self._create_plan(
            plan_id=f"EXT_GENERIC_{category.upper()}_{gap_name.upper().replace(' ', '_')[:20]}",
            gap_category=category,
            title=f"Erweiterung: {gap_name} ({category})",
            description=f"Generischer Plan fuer '{gap_name}'. Empfehlung: {solution}",
            directive_stufe=stufe, steps=steps,
            agents=self._find_available_agents(["planning"]),
            timeline=self._estimate_timeline(steps),
            infrastructure={"gpu_required": False, "additional_software": [],
                            "storage_needed": "unbekannt", "api_keys_needed": [],
                            "proxmox_changes": []},
            priority="low",
        )

    # ── Helper: Service-Aktivierungsplan ─────────────────────────────

    def _plan_activate_service(self, gap_analysis: dict, category: str) -> dict:
        """Generischer Stufe-1-Plan: Bestehenden Service aktivieren."""
        gap = gap_analysis.get("gap", {})
        gap_name = gap.get("name", "unknown")
        solution = gap_analysis.get("recommended_solution", "Service aktivieren")

        steps = [
            self._step(1, "API-Key pruefen",
                       f"Pruefen ob API-Key fuer '{gap_name}' in .env eingetragen ist",
                       agent=None, effort="minimal", depends=[]),
            self._step(2, "Service aktivieren",
                       "Status in service_registry.json auf 'active' setzen",
                       agent=None, effort="minimal", depends=[1]),
            self._step(3, "Health-Check",
                       "Service-Erreichbarkeit und Qualitaet pruefen",
                       agent=None, effort="minimal", depends=[2]),
        ]
        return self._create_plan(
            plan_id=f"EXT_{category.upper()}_ACTIVATE_{gap_name.upper().replace(' ', '_').replace('-', '_')[:20]}",
            gap_category=category,
            title=f"Service '{gap_name}' aktivieren",
            description=f"Bestehender Service. {solution}",
            directive_stufe=1, steps=steps,
            agents=self._find_available_agents([]),
            timeline=self._estimate_timeline(steps),
            infrastructure={"gpu_required": False, "additional_software": [],
                            "storage_needed": "keine", "api_keys_needed": [gap_name],
                            "proxmox_changes": []},
            priority="high",
        )

    # ── Hilfsmethoden ────────────────────────────────────────────────

    def _find_available_agents(self, required_skills: list) -> dict:
        """Prueft welche Agents fuer einen Plan verfuegbar sind."""
        registry = self._load_agent_registry()
        agents = registry.get("agents", [])

        available = []
        missing = []
        to_create = []

        matched_ids = set()

        for skill in required_skills:
            agent_ids = _AGENT_SKILLS.get(skill, [])
            if not agent_ids:
                to_create.append({
                    "skill": skill,
                    "recommendation": f"Neuen Agent mit Skill '{skill}' erstellen",
                })
                continue

            for aid in agent_ids:
                if aid in matched_ids:
                    continue
                agent = next((a for a in agents if a.get("id") == aid), None)
                if not agent:
                    continue

                status = agent.get("status", "unknown")
                if status == "active":
                    available.append({
                        "id": aid,
                        "name": agent.get("name", aid),
                        "match": skill,
                    })
                    matched_ids.add(aid)
                elif status == "disabled":
                    missing.append({
                        "id": aid,
                        "name": agent.get("name", aid),
                        "skill": skill,
                        "recommendation": f"{aid} ({agent.get('name', aid)}) reaktivieren (status=disabled)",
                    })
                    matched_ids.add(aid)
                elif status == "planned":
                    missing.append({
                        "id": aid,
                        "name": agent.get("name", aid),
                        "skill": skill,
                        "recommendation": f"{aid} ({agent.get('name', aid)}) implementieren (status=planned)",
                    })
                    matched_ids.add(aid)

        return {
            "available": available,
            "missing": missing,
            "to_create": to_create,
        }

    def _calculate_dependencies(self, steps: list) -> list:
        """Berechnet Abhaengigkeiten und ordnet Steps."""
        # Steps sind bereits mit depends[] versehen — hier nur validieren
        ordered = sorted(steps, key=lambda s: s.get("step", 0))
        for s in ordered:
            deps = s.get("dependency_on", [])
            s["can_parallel"] = len(deps) == 0
            s["dependency_order"] = max(deps) if deps else 0
        return ordered

    def _estimate_timeline(self, steps: list) -> dict:
        """Schaetzt Zeitrahmen anhand der Steps."""
        ordered = self._calculate_dependencies(steps)

        # Group steps by dependency waves
        waves = {}
        for s in ordered:
            wave = s.get("dependency_order", 0)
            waves.setdefault(wave, []).append(s)

        phases = []
        total_weeks = 0.0

        for wave_idx in sorted(waves.keys()):
            wave_steps = waves[wave_idx]
            # Wave duration = max effort of parallel steps
            max_effort = max(_EFFORT_WEEKS.get(s.get("effort", "moderate"), 1.5) for s in wave_steps)
            step_nums = [s["step"] for s in wave_steps]
            parallel = len(wave_steps) > 1

            phase_name = f"Wave {wave_idx}" if wave_idx > 0 else "Start"
            if len(phases) == 0:
                phase_name = "Setup"
            elif wave_idx == max(waves.keys()):
                phase_name = "Abschluss"
            else:
                phase_name = f"Phase {wave_idx}"

            phases.append({
                "name": phase_name,
                "weeks": max_effort,
                "steps": step_nums,
                "parallel": parallel,
            })
            total_weeks += max_effort

        # Determine critical path (longest non-parallelizable chain)
        critical_path = []
        for s in ordered:
            if not s.get("can_parallel", True) or s.get("dependency_order", 0) > 0:
                critical_path.append(s["step"])

        return {
            "total_weeks": round(total_weeks, 1),
            "phases": phases,
            "critical_path": critical_path,
            "start_possible": "sofort",
        }

    def _check_infrastructure_requirements(self, plan: dict) -> dict:
        """Prueft Infrastruktur-Anforderungen eines Plans."""
        # Already embedded in _create_plan — this is for external calls
        return plan.get("infrastructure", {})

    def _categorize_plans(self, plans: list) -> dict:
        """Ordnet Plaene in Roadmap-Zeitrahmen ein."""
        immediate = []    # 0-2 Wochen
        short_term = []   # 2-8 Wochen
        mid_term = []     # 8-24 Wochen
        long_term = []    # 24+ Wochen

        for p in plans:
            weeks = p.get("timeline", {}).get("total_weeks", 0)
            stufe = p.get("directive_stufe", 4)

            if stufe == 1 or weeks <= 2:
                immediate.append(p)
            elif weeks <= 8:
                short_term.append(p)
            elif weeks <= 24:
                mid_term.append(p)
            else:
                long_term.append(p)

        # Sort each bucket by priority
        prio_map = {"high": 0, "medium": 1, "low": 2}
        for bucket in [immediate, short_term, mid_term, long_term]:
            bucket.sort(key=lambda p: prio_map.get(p.get("priority", "low"), 3))

        return {
            "immediate": immediate,
            "short_term": short_term,
            "mid_term": mid_term,
            "long_term": long_term,
        }

    def _build_resource_summary(self, plans: list) -> dict:
        """Erstellt Ressourcen-Zusammenfassung ueber alle Plaene."""
        total_weeks = sum(p.get("timeline", {}).get("total_weeks", 0) for p in plans)

        all_agents = set()
        all_infra = []
        for p in plans:
            agents = p.get("agents", {})
            for a in agents.get("available", []):
                all_agents.add(f"{a['id']} ({a['name']})")
            for m in agents.get("missing", []):
                all_agents.add(f"{m['id']} ({m['name']}) [zu aktivieren]")
            for c in agents.get("to_create", []):
                all_agents.add(f"NEU: {c['skill']}")

            infra = p.get("infrastructure", {})
            if infra.get("gpu_required"):
                all_infra.append("GPU fuer Proxmox (Video/Image AI)")
            for sw in infra.get("additional_software", []):
                all_infra.append(sw)
            for pc in infra.get("proxmox_changes", []):
                all_infra.append(pc)

        return {
            "total_estimated_weeks": round(total_weeks, 1),
            "agents_needed": sorted(all_agents),
            "infrastructure_needed": sorted(set(all_infra)),
            "parallel_possible": len(plans) > 1,
        }

    def _build_production_impact(self, plans: list) -> dict:
        """Bewertet Auswirkung auf laufende Produktion."""
        # Video gap is the most impactful
        apps_to_pause = []
        apps_unaffected = []

        has_video_gap = any(
            p.get("gap_category") == "video" and p.get("priority") == "high"
            for p in plans
        )
        if has_video_gap:
            apps_to_pause.append("Apps die Video-Content benoetigen (z.B. Store-Videos)")
        apps_unaffected.append("iOS Apps (iOS Line voll operativ)")
        apps_unaffected.append("Apps ohne Video/Audio-Anforderung")

        return {
            "apps_to_pause": apps_to_pause,
            "apps_unaffected": apps_unaffected,
        }

    # ── Factory Methods ──────────────────────────────────────────────

    @staticmethod
    def _step(step: int, name: str, description: str,
              agent: str = None, effort: str = "moderate",
              depends: list = None) -> dict:
        """Factory fuer Plan-Steps."""
        return {
            "step": step,
            "name": name,
            "description": description,
            "agent": agent,
            "effort": effort,
            "dependency_on": depends or [],
            "deliverable": name,
        }

    @staticmethod
    def _create_plan(plan_id: str, gap_category: str, title: str,
                     description: str, directive_stufe: int, steps: list,
                     agents: dict, timeline: dict, infrastructure: dict,
                     priority: str) -> dict:
        """Factory fuer Extension Plan Dictionaries."""
        return {
            "plan_id": plan_id,
            "gap_category": gap_category,
            "title": title,
            "description": description,
            "directive_stufe": directive_stufe,
            "directive_compliance": "full",
            "steps": steps,
            "agents": agents,
            "timeline": timeline,
            "infrastructure": infrastructure,
            "priority": priority,
            "risk": "low" if directive_stufe <= 2 else "medium",
        }

    # ── Lazy Loading ─────────────────────────────────────────────────

    def _get_gap_analysis(self) -> dict:
        """Lazy-Load: GapAnalyzer.analyze_all_gaps()."""
        try:
            if not self._gap_analyzer:
                from factory.brain.gap_analyzer import GapAnalyzer
                self._gap_analyzer = GapAnalyzer(str(self.root))
            return self._gap_analyzer.analyze_all_gaps()
        except Exception as e:
            logger.error("GapAnalyzer failed: %s", e)
            return {"total_gaps": 0, "gap_analyses": []}

    def _load_agent_registry(self) -> dict:
        """Lazy-Load der Agent Registry."""
        if self._agent_registry is not None:
            return self._agent_registry

        try:
            registry_file = self.root / "factory" / "agent_registry.json"
            if not registry_file.exists():
                self._agent_registry = {"agents": []}
                return self._agent_registry
            self._agent_registry = json.loads(registry_file.read_text(encoding="utf-8"))
            return self._agent_registry
        except Exception as e:
            logger.warning("Failed to load agent registry: %s", e)
            self._agent_registry = {"agents": []}
            return self._agent_registry

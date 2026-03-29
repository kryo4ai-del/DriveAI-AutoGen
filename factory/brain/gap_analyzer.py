"""Factory Gap Analyzer (BRN-05).

Tiefenanalyse aller Capability-Gaps mit DIR-001 Stufenlogik.
Verwendet eine statische Self-Build Knowledge Base um fuer jeden Gap
zu bewerten, ob und wie die Factory ihn selbst schliessen kann.

4-Stufe-Analyse pro Gap:
  Stufe 1: Eigene Mittel (bestehende Tools/Agents)
  Stufe 2: Selbst entwickeln (neuer Agent/Modul)
  Stufe 3: Open-Source / Self-Hosting (Proxmox)
  Stufe 4: Externer Dienstleister (Uebergangsloesung)

100% deterministisch. Kein LLM. Keine Schreiboperationen.
"""

import json
import logging
from datetime import datetime, timezone
from pathlib import Path

logger = logging.getLogger(__name__)

_DEFAULT_ROOT = Path(__file__).resolve().parents[2]

# ── Self-Build Knowledge Base ────────────────────────────────────
# Statisches Wissen ueber Open-Source-Modelle und Self-Build-Optionen
# pro Capability-Kategorie. Wird fuer Stufe 2/3 Bewertung genutzt.

SELF_BUILD_KNOWLEDGE = {
    "image": {
        "description": "Bild-Generierung (Sprites, Icons, Hintergruende)",
        "stufe_2_options": [
            {
                "name": "Claude Vision + SVG Pipeline",
                "description": "Claude generiert SVG-Code direkt — kein externer Service noetig",
                "effort": "moderate",
                "quality": "gut fuer Icons/UI, limitiert fuer fotorealistische Bilder",
                "already_possible": True,
            },
        ],
        "stufe_3_options": [
            {
                "name": "Stable Diffusion (AUTOMATIC1111/ComfyUI)",
                "description": "Open-Source Image Generation, lokal auf GPU",
                "model_size_gb": 7,
                "min_vram_gb": 8,
                "docker_available": True,
                "proxmox_compatible": True,
                "license": "CreativeML Open RAIL-M",
                "quality": "high — fotorealistisch und stylized",
                "setup_effort": "moderate",
            },
            {
                "name": "FLUX.1 (Black Forest Labs)",
                "description": "Neueste Open-Source Image Generation, SDXL-Nachfolger",
                "model_size_gb": 12,
                "min_vram_gb": 12,
                "docker_available": True,
                "proxmox_compatible": True,
                "license": "Apache 2.0 (schnell) / Non-commercial (dev)",
                "quality": "very high — State-of-the-Art Open Source",
                "setup_effort": "moderate",
            },
        ],
        "stufe_4_fallback": ["DALL-E 3", "Stability AI SDXL", "Recraft v3"],
    },
    "sound": {
        "description": "Sound-Effekte und Musik-Generierung",
        "stufe_2_options": [
            {
                "name": "PyDub + Synthesizer Pipeline",
                "description": "Programmatische Sound-Generierung mit Python (Sinuswellen, Noise, Filter)",
                "effort": "significant",
                "quality": "basic — reicht fuer einfache SFX, nicht fuer Musik",
                "already_possible": True,
            },
        ],
        "stufe_3_options": [
            {
                "name": "Meta AudioCraft (MusicGen + AudioGen)",
                "description": "Open-Source Audio/Musik-Generierung von Meta",
                "model_size_gb": 3.5,
                "min_vram_gb": 8,
                "docker_available": True,
                "proxmox_compatible": True,
                "license": "MIT (AudioGen) / CC-BY-NC (MusicGen)",
                "quality": "high — State-of-the-Art Open Source Audio",
                "setup_effort": "moderate",
            },
            {
                "name": "Bark (Suno Open Source)",
                "description": "Open-Source TTS + Sound Effects",
                "model_size_gb": 5,
                "min_vram_gb": 8,
                "docker_available": True,
                "proxmox_compatible": True,
                "license": "MIT",
                "quality": "moderate — gut fuer SFX, weniger fuer Musik",
                "setup_effort": "minimal",
            },
        ],
        "stufe_4_fallback": ["ElevenLabs", "Suno AI"],
    },
    "voice_tts": {
        "description": "Text-to-Speech / Voice-Over Generierung",
        "stufe_2_options": [
            {
                "name": "pyttsx3 / espeak",
                "description": "Lokale TTS mit System-Stimmen",
                "effort": "minimal",
                "quality": "low — robotisch, nicht fuer Production",
                "already_possible": True,
            },
        ],
        "stufe_3_options": [
            {
                "name": "Coqui TTS / XTTS-v2",
                "description": "Open-Source Multi-Language TTS mit Voice Cloning",
                "model_size_gb": 2,
                "min_vram_gb": 4,
                "docker_available": True,
                "proxmox_compatible": True,
                "license": "MPL-2.0",
                "quality": "high — natuerliche Stimmen, Voice Cloning moeglich",
                "setup_effort": "minimal",
            },
            {
                "name": "Piper TTS",
                "description": "Ultraschnelle lokale TTS, laeuft sogar auf CPU",
                "model_size_gb": 0.1,
                "min_vram_gb": 0,
                "docker_available": True,
                "proxmox_compatible": True,
                "license": "MIT",
                "quality": "moderate — schnell, passabel, CPU-only moeglich",
                "setup_effort": "minimal",
            },
        ],
        "stufe_4_fallback": ["ElevenLabs TTS", "Google Cloud TTS"],
    },
    "video": {
        "description": "Video-Generierung (Cutscenes, Trailer, Promo)",
        "stufe_2_options": [
            {
                "name": "FFmpeg + Pillow Pipeline",
                "description": "Programmatische Video-Erstellung aus Bildern/Animationen",
                "effort": "significant",
                "quality": "basic — Slideshow-artig, keine echte Video-Gen",
                "already_possible": True,
            },
        ],
        "stufe_3_options": [
            {
                "name": "CogVideoX (THUDM)",
                "description": "Open-Source Video Generation, Text/Image-to-Video",
                "model_size_gb": 15,
                "min_vram_gb": 16,
                "docker_available": True,
                "proxmox_compatible": True,
                "license": "Apache 2.0",
                "quality": "moderate — kurze Clips (6s), akzeptable Qualitaet",
                "setup_effort": "significant",
            },
            {
                "name": "Open-Sora (HPC-AI Tech)",
                "description": "Open-Source Sora-Alternative, Video Generation",
                "model_size_gb": 10,
                "min_vram_gb": 24,
                "docker_available": True,
                "proxmox_compatible": True,
                "license": "Apache 2.0",
                "quality": "moderate — bis 16s Videos, experimentell",
                "setup_effort": "significant",
            },
        ],
        "stufe_4_fallback": ["Runway ML Gen-3", "Kling AI", "Luma Dream Machine"],
    },
    "animation": {
        "description": "UI-Animationen (Lottie, Rive, CSS)",
        "stufe_2_options": [
            {
                "name": "Claude Lottie JSON Generator",
                "description": "Claude generiert Lottie-JSON-Animationen direkt",
                "effort": "minimal",
                "quality": "gut — funktionale UI-Animationen",
                "already_possible": True,
            },
            {
                "name": "CSS Animation Generator",
                "description": "Claude generiert CSS @keyframes Animationen",
                "effort": "minimal",
                "quality": "gut — smooth Web-Animationen",
                "already_possible": True,
            },
        ],
        "stufe_3_options": [
            {
                "name": "Rive Runtime (Self-Hosted)",
                "description": "Rive Runtime fuer vorbereitete .riv Animationen",
                "model_size_gb": 0,
                "min_vram_gb": 0,
                "docker_available": False,
                "proxmox_compatible": True,
                "license": "MIT (Runtime)",
                "quality": "high — professionelle Animations-Engine",
                "setup_effort": "moderate",
            },
        ],
        "stufe_4_fallback": [],
    },
    "production_lines": {
        "description": "Production Lines ohne Code oder inaktiv",
        "stufe_2_options": [
            {
                "name": "Assembly Line Code implementieren",
                "description": "Python assembly_line Modul pro Line entwickeln",
                "effort": "significant",
                "quality": "n/a — Infrastruktur, nicht Content",
                "already_possible": True,
            },
        ],
        "stufe_3_options": [],
        "stufe_4_fallback": [],
    },
}

# ── Proxmox Server Specs (fuer Kompatibilitaets-Check) ──────────
_PROXMOX_SPECS = {
    "total_ram_gb": 64,
    "available_ram_gb": 48,
    "total_vram_gb": 0,    # Kein GPU-Passthrough konfiguriert
    "gpu_model": None,      # Noch keine GPU
    "storage_tb": 2,
    "available_storage_tb": 1.5,
    "docker_available": True,
    "os": "Proxmox VE 8.x (Debian 12)",
}


class GapAnalyzer:
    """Tiefenanalyse aller Capability-Gaps mit DIR-001 Stufenlogik."""

    def __init__(self, factory_root: str = None):
        self.root = Path(factory_root) if factory_root else _DEFAULT_ROOT
        self._capability_map = None  # lazy
        self._service_registry = None  # lazy
        self._directive_engine = None  # lazy

    # ── Public API ───────────────────────────────────────────────────

    def analyze_all_gaps(self) -> dict:
        """Hauptmethode. Analysiert alle Gaps aus CapabilityMap mit DIR-001 Logik.

        Returns:
            {
                "analyzed_at": ISO timestamp,
                "total_gaps": int,
                "analyzed_gaps": int,
                "gap_analyses": [GapAnalysis, ...],
                "summary": {
                    "self_solvable": int,
                    "external_only": int,
                    "by_stufe": {1: int, 2: int, 3: int, 4: int},
                    "by_category": {...},
                    "proxmox_feasible": int,
                },
                "knowledge_base_coverage": {...}
            }
        """
        gaps = self._get_gaps()
        analyses = []

        for gap in gaps:
            try:
                analysis = self.analyze_single_gap(gap)
                if analysis:
                    analyses.append(analysis)
            except Exception as e:
                logger.warning("Gap analysis failed for '%s': %s", gap.get("name"), e)
                analyses.append(self._create_fallback_analysis(gap, str(e)))

        analyses = self._prioritize_gaps(analyses)
        summary = self._build_summary(analyses)
        kb_coverage = self.get_knowledge_base_status()

        return {
            "analyzed_at": datetime.now(timezone.utc).isoformat(),
            "total_gaps": len(gaps),
            "analyzed_gaps": len(analyses),
            "gap_analyses": analyses,
            "summary": summary,
            "knowledge_base_coverage": kb_coverage,
        }

    def analyze_single_gap(self, gap: dict) -> dict:
        """Analysiert einen einzelnen Gap durch alle 4 Stufen.

        Parameters:
            gap: Ein Gap-Dict aus CapabilityMap.get_gaps()

        Returns:
            {
                "gap": {original gap data},
                "category": str,
                "stufe_results": {1: {...}, 2: {...}, 3: {...}, 4: {...}},
                "recommended_stufe": int,
                "recommended_solution": str,
                "self_solvable": bool,
                "proxmox_feasible": bool,
                "production_impact": str,
                "directive_compliance": str,
            }
        """
        gap_type = gap.get("type", "unknown")
        gap_name = gap.get("name", "unknown")
        gap_area = gap.get("area", "unknown")
        severity = gap.get("severity", "green")

        # Map gap to knowledge base category
        category = self._map_gap_to_category(gap)

        # Run all 4 Stufen checks
        stufe_1 = self._check_stufe1_internal(gap, category)
        stufe_2 = self._check_stufe2_self_build(gap, category)
        stufe_3 = self._check_stufe3_open_source(gap, category)
        stufe_4 = self._check_stufe4_external(gap, category)

        stufe_results = {1: stufe_1, 2: stufe_2, 3: stufe_3, 4: stufe_4}

        # Determine best stufe (lowest feasible)
        recommended_stufe, recommended_solution = self._determine_best_stufe(stufe_results)
        self_solvable = recommended_stufe <= 3

        # Proxmox feasibility (relevant for Stufe 3)
        proxmox_feasible = stufe_3.get("proxmox_feasible", False)

        # Production impact
        production_impact = self._assess_production_impact(gap, recommended_stufe)

        # Directive compliance label
        if recommended_stufe == 1:
            compliance = "stufe_1_eigene_mittel"
        elif recommended_stufe == 2:
            compliance = "stufe_2_selbst_entwickeln"
        elif recommended_stufe == 3:
            compliance = "stufe_3_open_source"
        else:
            compliance = "stufe_4_extern_uebergang"

        logger.info(
            "Gap '%s' (%s): Stufe %d empfohlen — %s (self_solvable=%s)",
            gap_name, category, recommended_stufe, recommended_solution, self_solvable,
        )

        return self._build_gap_analysis(
            gap=gap,
            category=category,
            stufe_results=stufe_results,
            recommended_stufe=recommended_stufe,
            recommended_solution=recommended_solution,
            self_solvable=self_solvable,
            proxmox_feasible=proxmox_feasible,
            production_impact=production_impact,
            directive_compliance=compliance,
        )

    def get_knowledge_base_status(self) -> dict:
        """Gibt Status der Self-Build Knowledge Base zurueck.

        Returns:
            {
                "categories_covered": int,
                "categories": {category: {options_stufe_2, options_stufe_3, has_fallback}},
                "total_stufe_2_options": int,
                "total_stufe_3_options": int,
            }
        """
        categories = {}
        total_s2 = 0
        total_s3 = 0

        for cat, knowledge in SELF_BUILD_KNOWLEDGE.items():
            s2 = len(knowledge.get("stufe_2_options", []))
            s3 = len(knowledge.get("stufe_3_options", []))
            fallback = len(knowledge.get("stufe_4_fallback", []))
            total_s2 += s2
            total_s3 += s3
            categories[cat] = {
                "description": knowledge.get("description", ""),
                "options_stufe_2": s2,
                "options_stufe_3": s3,
                "has_fallback": fallback > 0,
                "fallback_services": knowledge.get("stufe_4_fallback", []),
            }

        return {
            "categories_covered": len(categories),
            "categories": categories,
            "total_stufe_2_options": total_s2,
            "total_stufe_3_options": total_s3,
        }

    # ── Stufe Checks ─────────────────────────────────────────────────

    def _check_stufe1_internal(self, gap: dict, category: str) -> dict:
        """Stufe 1: Kann die Factory das mit bestehenden Tools loesen?"""
        gap_type = gap.get("type", "")
        gap_name = gap.get("name", "")

        result = {
            "stufe": 1,
            "label": "Eigene Mittel",
            "feasible": False,
            "solution": None,
            "effort": None,
            "details": None,
        }

        # Check for active alternatives in same category (services)
        if gap_type == "category_no_active_service":
            alternatives = self._find_active_alternatives(category)
            if alternatives:
                alt = alternatives[0]
                result["feasible"] = True
                result["solution"] = f"Bestehenden Service '{alt['name']}' konfigurieren"
                result["effort"] = "minimal"
                result["details"] = f"Aktiver Service '{alt['name']}' kann fuer '{category}' genutzt werden"
                return result

        # Check for inactive services that just need API key activation
        if gap_type in ("category_no_active_service", "service_inactive"):
            inactive = self._find_inactive_services(category)
            if inactive:
                svc = inactive[0]
                api_key = svc.get("api_key_env", "UNKNOWN")
                result["feasible"] = True
                result["solution"] = f"Service '{svc['name']}' aktivieren ({api_key} in .env)"
                result["effort"] = "minimal"
                result["details"] = f"Service existiert, nur API-Key '{api_key}' noetig"
                return result

        # Check for draft adapters that are almost ready
        if gap_type == "draft_adapter":
            result["feasible"] = False
            result["solution"] = None
            result["details"] = f"Draft-Adapter '{gap_name}' existiert aber braucht Integration + API-Key"
            return result

        # Agents: disabled agents can be reactivated
        if gap_type == "agent_disabled":
            result["feasible"] = True
            result["solution"] = f"Agent '{gap_name}' reaktivieren (status=active)"
            result["effort"] = "minimal"
            result["details"] = "Agent existiert, nur Status-Aenderung noetig"
            return result

        # Production lines: inactive lines with code
        if gap_type == "line_inactive":
            result["feasible"] = True
            result["solution"] = f"Line '{gap_name}' aktivieren (status=active in agent.json)"
            result["effort"] = "minimal"
            result["details"] = "Line hat Code, nur Status-Aenderung noetig"
            return result

        # Knowledge base: check if already_possible
        knowledge = SELF_BUILD_KNOWLEDGE.get(category, {})
        for opt in knowledge.get("stufe_2_options", []):
            if opt.get("already_possible"):
                result["feasible"] = True
                result["solution"] = f"Bestehende Capability nutzen: {opt['name']}"
                result["effort"] = opt.get("effort", "moderate")
                result["details"] = opt.get("description", "")
                return result

        result["details"] = "Keine bestehende Loesung gefunden"
        return result

    def _check_stufe2_self_build(self, gap: dict, category: str) -> dict:
        """Stufe 2: Koennen wir die Capability selbst entwickeln?"""
        result = {
            "stufe": 2,
            "label": "Selbst entwickeln",
            "feasible": False,
            "options": [],
            "best_option": None,
            "effort": None,
            "details": None,
        }

        knowledge = SELF_BUILD_KNOWLEDGE.get(category, {})
        options = knowledge.get("stufe_2_options", [])

        if not options:
            result["details"] = f"Keine Self-Build-Optionen fuer '{category}' in Knowledge Base"
            return result

        result["feasible"] = True
        result["options"] = options
        result["best_option"] = options[0]["name"]
        result["effort"] = options[0].get("effort", "significant")
        result["details"] = options[0].get("description", "")

        return result

    def _check_stufe3_open_source(self, gap: dict, category: str) -> dict:
        """Stufe 3: Open-Source Self-Hosting auf Proxmox moeglich?"""
        result = {
            "stufe": 3,
            "label": "Open-Source / Self-Hosting",
            "feasible": False,
            "options": [],
            "best_option": None,
            "effort": None,
            "details": None,
            "proxmox_feasible": False,
            "proxmox_checks": [],
        }

        knowledge = SELF_BUILD_KNOWLEDGE.get(category, {})
        options = knowledge.get("stufe_3_options", [])

        if not options:
            result["details"] = f"Keine Open-Source-Optionen fuer '{category}' in Knowledge Base"
            return result

        feasible_options = []
        proxmox_checks = []

        for opt in options:
            check = self._check_proxmox_compatibility(opt)
            proxmox_checks.append(check)

            if check["compatible"]:
                feasible_options.append({
                    **opt,
                    "proxmox_check": check,
                })

        result["options"] = options
        result["proxmox_checks"] = proxmox_checks

        if feasible_options:
            best = feasible_options[0]
            result["feasible"] = True
            result["best_option"] = best["name"]
            result["effort"] = best.get("setup_effort", "significant")
            result["details"] = best.get("description", "")
            result["proxmox_feasible"] = True
        else:
            # Options exist but Proxmox can't handle them (e.g. no GPU)
            result["feasible"] = True  # theoretically feasible, needs hardware
            result["best_option"] = options[0]["name"]
            result["effort"] = "significant"
            result["details"] = (
                f"{options[0]['name']} verfuegbar aber Proxmox-Kompatibilitaet "
                "eingeschraenkt (ggf. GPU noetig)"
            )
            result["proxmox_feasible"] = False

        return result

    def _check_stufe4_external(self, gap: dict, category: str) -> dict:
        """Stufe 4: Welche externen Services gibt es als Notfall-Fallback?"""
        result = {
            "stufe": 4,
            "label": "Externer Dienstleister (Uebergangsloesung)",
            "feasible": False,
            "options": [],
            "details": None,
            "requires_ceo_approval": True,
            "migration_plan_required": True,
        }

        knowledge = SELF_BUILD_KNOWLEDGE.get(category, {})
        fallbacks = knowledge.get("stufe_4_fallback", [])

        # Also check draft adapters
        draft_adapters = self._find_draft_adapters(category)

        if fallbacks or draft_adapters:
            result["feasible"] = True
            result["options"] = []

            for fb in fallbacks:
                result["options"].append({
                    "name": fb,
                    "type": "external_service",
                    "status": "available_as_fallback",
                })

            for da in draft_adapters:
                result["options"].append({
                    "name": da["name"],
                    "type": "draft_adapter",
                    "status": "code_exists_needs_integration",
                    "file": da.get("file", ""),
                })

            result["details"] = (
                f"{len(fallbacks)} externe Services + {len(draft_adapters)} Draft-Adapter verfuegbar. "
                "NUR mit CEO-Approval und Abloese-Plan."
            )
        else:
            result["details"] = f"Keine externen Fallbacks fuer '{category}' bekannt"

        return result

    # ── Helpers ───────────────────────────────────────────────────────

    def _map_gap_to_category(self, gap: dict) -> str:
        """Mappt einen Gap auf eine Knowledge-Base-Kategorie."""
        gap_type = gap.get("type", "")
        gap_name = gap.get("name", "").lower()
        gap_area = gap.get("area", "")

        # Direct category mapping for services
        if gap_type in ("category_no_active_service", "service_inactive"):
            # gap_name IS the category for category_no_active_service
            if gap_name in SELF_BUILD_KNOWLEDGE:
                return gap_name
            # For service_inactive, try to find category from registry
            registry = self._load_service_registry()
            for sid, svc in registry.get("services", {}).items():
                if svc.get("name", "").lower() == gap_name:
                    return svc.get("category", "unknown")

        # Draft adapters
        if gap_type == "draft_adapter":
            draft_map = {
                "black_forest_labs": "image",
                "leonardo": "image",
                "kling": "video",
                "luma": "video",
                "meta_audiocraft": "sound",
                "stability_audio": "sound",
                "rive": "animation",
            }
            return draft_map.get(gap_name.lower(), "unknown")

        # Production lines
        if gap_area == "production_lines" or gap_type in ("line_no_code", "line_inactive"):
            return "production_lines"

        # Forges → map to their output category
        if gap_area == "forges" or gap_type in ("forge_no_orchestrator", "forge_not_operational"):
            forge_name = gap_name.lower()
            if "asset" in forge_name or "image" in forge_name:
                return "image"
            if "sound" in forge_name or "audio" in forge_name:
                return "sound"
            if "motion" in forge_name or "animation" in forge_name:
                return "animation"
            if "video" in forge_name:
                return "video"

        # Agents → generic
        if gap_area == "agents":
            return "production_lines"  # agent gaps are infra, not content

        return "unknown"

    def _check_proxmox_compatibility(self, option: dict) -> dict:
        """Prueft ob eine Self-Host-Option auf dem Proxmox-Server laeuft."""
        specs = _PROXMOX_SPECS
        issues = []
        compatible = True

        # VRAM check
        min_vram = option.get("min_vram_gb", 0)
        if min_vram > 0 and specs["total_vram_gb"] < min_vram:
            issues.append(
                f"GPU mit min. {min_vram}GB VRAM noetig, "
                f"aktuell: {'keine GPU' if not specs['gpu_model'] else specs['gpu_model']}"
            )
            compatible = False

        # RAM check
        model_size = option.get("model_size_gb", 0)
        if model_size > specs["available_ram_gb"]:
            issues.append(
                f"Modell braucht {model_size}GB, verfuegbar: {specs['available_ram_gb']}GB RAM"
            )
            compatible = False

        # Docker check
        if option.get("docker_available") and not specs["docker_available"]:
            issues.append("Docker nicht verfuegbar auf Proxmox")
            compatible = False

        # Storage check
        storage_needed_tb = model_size / 1024  # Convert GB to TB
        if storage_needed_tb > specs["available_storage_tb"]:
            issues.append(
                f"Storage: {model_size}GB noetig, {specs['available_storage_tb']}TB verfuegbar"
            )
            compatible = False

        # CPU-only feasibility: if no GPU but min_vram=0, it runs on CPU
        cpu_only = min_vram == 0
        if not compatible and not cpu_only:
            # Check if CPU-only fallback is acceptable (slower but works)
            if model_size <= specs["available_ram_gb"]:
                issues.append(
                    "CPU-only Modus moeglich (langsamer, aber funktional)"
                )

        return {
            "option": option.get("name", "unknown"),
            "compatible": compatible,
            "cpu_only": cpu_only,
            "issues": issues,
            "server_specs": {
                "ram_gb": specs["total_ram_gb"],
                "vram_gb": specs["total_vram_gb"],
                "gpu": specs["gpu_model"] or "none",
                "docker": specs["docker_available"],
            },
        }

    def _determine_best_stufe(self, stufe_results: dict) -> tuple:
        """Bestimmt die niedrigste machbare Stufe und ihre Loesung.

        Returns:
            (stufe_number, solution_description)
        """
        # Stufe 1: sofort machbar?
        s1 = stufe_results.get(1, {})
        if s1.get("feasible"):
            return 1, s1.get("solution", "Bestehende Mittel nutzen")

        # Stufe 2: selbst entwickeln?
        s2 = stufe_results.get(2, {})
        if s2.get("feasible") and s2.get("best_option"):
            return 2, f"Selbst entwickeln: {s2['best_option']}"

        # Stufe 3: Open Source Self-Host?
        s3 = stufe_results.get(3, {})
        if s3.get("feasible") and s3.get("best_option"):
            proxmox = " (Proxmox-kompatibel)" if s3.get("proxmox_feasible") else " (Hardware-Upgrade noetig)"
            return 3, f"Self-Host: {s3['best_option']}{proxmox}"

        # Stufe 4: Extern als letzter Ausweg
        s4 = stufe_results.get(4, {})
        if s4.get("feasible") and s4.get("options"):
            first = s4["options"][0]["name"]
            return 4, f"Extern (temporaer): {first} — CEO-Approval + Abloese-Plan noetig"

        # Nichts gefunden
        return 4, "Keine Loesung in Knowledge Base — CEO-Entscheidung noetig"

    def _assess_production_impact(self, gap: dict, recommended_stufe: int) -> str:
        """Bewertet den Einfluss des Gaps auf die Produktion."""
        severity = gap.get("severity", "green")
        gap_type = gap.get("type", "")

        if severity == "red":
            if recommended_stufe <= 2:
                return "hoch — blockiert Produktion, aber schnell loesbar (Stufe 1-2)"
            return "hoch — blockiert Produktion, signifikanter Aufwand noetig"

        if severity == "yellow":
            return "mittel — Einschraenkung, Workaround moeglich"

        return "niedrig — keine direkte Produktionsbeeintraechtigung"

    def _build_gap_analysis(self, **kwargs) -> dict:
        """Factory-Methode fuer standardisierte Gap-Analysis-Dicts."""
        return {
            "gap": kwargs["gap"],
            "category": kwargs["category"],
            "stufe_results": kwargs["stufe_results"],
            "recommended_stufe": kwargs["recommended_stufe"],
            "recommended_solution": kwargs["recommended_solution"],
            "self_solvable": kwargs["self_solvable"],
            "proxmox_feasible": kwargs["proxmox_feasible"],
            "production_impact": kwargs["production_impact"],
            "directive_compliance": kwargs["directive_compliance"],
        }

    def _prioritize_gaps(self, analyses: list) -> list:
        """Sortiert Gap-Analysen: RED first, dann nach empfohlener Stufe."""
        severity_order = {"red": 0, "yellow": 1, "green": 2}
        return sorted(analyses, key=lambda a: (
            severity_order.get(a.get("gap", {}).get("severity", "green"), 3),
            a.get("recommended_stufe", 4),
        ))

    def _build_summary(self, analyses: list) -> dict:
        """Baut die Zusammenfassung aller Gap-Analysen."""
        self_solvable = sum(1 for a in analyses if a.get("self_solvable"))
        external_only = sum(1 for a in analyses if not a.get("self_solvable"))
        proxmox_feasible = sum(1 for a in analyses if a.get("proxmox_feasible"))

        by_stufe = {1: 0, 2: 0, 3: 0, 4: 0}
        by_category = {}

        for a in analyses:
            stufe = a.get("recommended_stufe", 4)
            by_stufe[stufe] = by_stufe.get(stufe, 0) + 1

            cat = a.get("category", "unknown")
            by_category.setdefault(cat, []).append({
                "gap_name": a.get("gap", {}).get("name", "?"),
                "stufe": stufe,
                "self_solvable": a.get("self_solvable", False),
            })

        return {
            "self_solvable": self_solvable,
            "external_only": external_only,
            "by_stufe": by_stufe,
            "by_category": by_category,
            "proxmox_feasible": proxmox_feasible,
        }

    def _create_fallback_analysis(self, gap: dict, error: str) -> dict:
        """Erstellt Fallback-Analyse wenn echte Analyse fehlschlaegt."""
        return self._build_gap_analysis(
            gap=gap,
            category="unknown",
            stufe_results={
                1: {"stufe": 1, "feasible": False, "details": f"Analyse-Fehler: {error}"},
                2: {"stufe": 2, "feasible": False, "details": f"Analyse-Fehler: {error}"},
                3: {"stufe": 3, "feasible": False, "details": f"Analyse-Fehler: {error}"},
                4: {"stufe": 4, "feasible": False, "details": f"Analyse-Fehler: {error}"},
            },
            recommended_stufe=4,
            recommended_solution=f"Analyse fehlgeschlagen: {error}",
            self_solvable=False,
            proxmox_feasible=False,
            production_impact="unbekannt — Analyse fehlgeschlagen",
            directive_compliance="stufe_4_extern_uebergang",
        )

    # ── Lazy Data Loading ────────────────────────────────────────────

    def _get_gaps(self) -> list:
        """Lazy-Load: CapabilityMap.get_gaps() aufrufen."""
        try:
            if not self._capability_map:
                from factory.brain.capability_map import CapabilityMap
                self._capability_map = CapabilityMap(str(self.root))
            return self._capability_map.get_gaps()
        except Exception as e:
            logger.error("Failed to get gaps: %s", e)
            return []

    def _load_service_registry(self) -> dict:
        """Lazy-Load der Service Registry."""
        if self._service_registry is not None:
            return self._service_registry

        try:
            registry_file = self.root / "factory" / "brain" / "service_provider" / "service_registry.json"
            if not registry_file.exists():
                registry_file = self.root / "factory" / "brain" / "service_registry.json"
            if not registry_file.exists():
                self._service_registry = {}
                return self._service_registry

            self._service_registry = json.loads(registry_file.read_text(encoding="utf-8"))
            return self._service_registry
        except Exception as e:
            logger.warning("Failed to load service registry: %s", e)
            self._service_registry = {}
            return self._service_registry

    def _find_active_alternatives(self, category: str) -> list:
        """Findet aktive Services in einer Kategorie."""
        registry = self._load_service_registry()
        active = []
        for sid, svc in registry.get("services", {}).items():
            if svc.get("category") == category and svc.get("status") == "active":
                active.append({"id": sid, "name": svc.get("name", sid)})
        return active

    def _find_inactive_services(self, category: str) -> list:
        """Findet inaktive Services in einer Kategorie."""
        registry = self._load_service_registry()
        inactive = []
        for sid, svc in registry.get("services", {}).items():
            if svc.get("category") == category and svc.get("status") == "inactive":
                inactive.append({
                    "id": sid,
                    "name": svc.get("name", sid),
                    "api_key_env": svc.get("api_key_env", ""),
                })
        return inactive

    def _find_draft_adapters(self, category: str) -> list:
        """Findet Draft-Adapter fuer eine Kategorie."""
        draft_map = {
            "image": ["black_forest_labs", "leonardo"],
            "video": ["kling", "luma"],
            "sound": ["meta_audiocraft", "stability_audio"],
            "animation": ["rive"],
        }

        expected = draft_map.get(category, [])
        if not expected:
            return []

        drafts_dir = self.root / "factory" / "brain" / "service_provider" / "adapters" / "drafts"
        if not drafts_dir.exists():
            return []

        found = []
        for name in expected:
            adapter_file = drafts_dir / f"{name}_adapter.py"
            if adapter_file.exists():
                found.append({
                    "name": name.replace("_", " ").title(),
                    "file": str(adapter_file.relative_to(self.root)),
                })

        return found

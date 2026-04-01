"""Marketing Pipeline Runner — Orchestriert den gesamten Marketing-Zyklus.

Deterministisch, kein LLM. Ruft Agents und Tools in der richtigen Reihenfolge auf.
"""

import logging
import time
from datetime import datetime

from factory.marketing.tools.ranking_database import RankingDatabase
from factory.marketing.alerts.alert_manager import MarketingAlertManager
from factory.marketing.config import REPORTS_PATH
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.pipeline_runner")


class MarketingPipelineRunner:
    """Orchestriert den Marketing-Zyklus fuer eine App."""

    STEPS = [
        {"number": 1, "name": "story_brief", "agent": "MKT-02", "method": "create_app_story_brief",
         "module": "factory.marketing.agents.strategy", "class": "StrategyAgent"},
        {"number": 2, "name": "marketing_directive", "agent": "MKT-02", "method": "create_marketing_directive",
         "module": "factory.marketing.agents.strategy", "class": "StrategyAgent"},
        {"number": 3, "name": "social_media_pack", "agent": "MKT-03", "method": "create_social_media_pack",
         "module": "factory.marketing.agents.copywriter", "class": "Copywriter"},
        {"number": 4, "name": "store_listing", "agent": "MKT-03", "method": "create_store_listing",
         "module": "factory.marketing.agents.copywriter", "class": "Copywriter"},
        {"number": 5, "name": "aso_keywords", "agent": "MKT-05", "method": "keyword_research",
         "module": "factory.marketing.agents.aso_agent", "class": "ASOAgent"},
        {"number": 6, "name": "social_graphics", "agent": "MKT-06", "method": "create_social_media_graphics",
         "module": "factory.marketing.agents.visual_designer", "class": "VisualDesigner"},
        {"number": 7, "name": "youtube_thumbnail", "agent": "MKT-06", "method": "create_youtube_thumbnail",
         "module": "factory.marketing.agents.visual_designer", "class": "VisualDesigner"},
        {"number": 8, "name": "video_script", "agent": "MKT-07", "method": "create_video_script",
         "module": "factory.marketing.agents.video_script_agent", "class": "VideoScriptAgent"},
        {"number": 9, "name": "brand_compliance", "agent": "MKT-01", "method": "check_brand_compliance",
         "module": "factory.marketing.agents.brand_guardian", "class": "BrandGuardian"},
        {"number": 10, "name": "press_kit", "agent": "tool", "method": "generate_app_press_kit",
         "module": "factory.marketing.tools.press_kit_generator", "class": "PressKitGenerator"},
        {"number": 11, "name": "case_study", "agent": "MKT-12", "method": "create_case_study",
         "module": "factory.marketing.agents.storytelling_agent", "class": "StorytellingAgent"},
        {"number": 12, "name": "press_release", "agent": "MKT-13", "method": "create_press_release",
         "module": "factory.marketing.agents.pr_agent", "class": "PRAgent"},
    ]

    def __init__(self):
        self.db = RankingDatabase()
        self.alerts = MarketingAlertManager()

    def run_full_cycle(self, project_slug: str, dry_run: bool = True) -> dict:
        """Fuehrt den kompletten Marketing-Zyklus aus.

        Pro Step:
        1. Log: "Starting step N: {name}"
        2. Agent/Tool laden und Methode aufrufen
        3. Ergebnis in DB speichern (pipeline_runs)
        4. Bei Fehler: Alert + status="failed" + weiter mit naechstem Step
        5. Log: "Step N completed" oder "Step N failed"

        WICHTIG: Ein fehlender Step bricht NICHT die ganze Pipeline ab.
        """
        start_time = time.time()
        details = []
        completed = 0
        failed = 0
        skipped = 0

        logger.info("=== Pipeline Start: %s (dry_run=%s) ===", project_slug, dry_run)

        for step in self.STEPS:
            step_num = step["number"]
            step_name = step["name"]
            logger.info("Starting step %d: %s", step_num, step_name)

            # DB-Eintrag erstellen
            now = datetime.now().isoformat()
            run_id = self.db.store_pipeline_run(
                project_slug=project_slug,
                step_number=step_num,
                step_name=step_name,
                status="running",
                started_at=now,
            )

            try:
                output = self._execute_step(step, project_slug, dry_run)
                output_path = str(output) if output else None

                self.db.update_pipeline_run(
                    run_id,
                    status="completed",
                    completed_at=datetime.now().isoformat(),
                    output_path=output_path,
                )
                completed += 1
                details.append({
                    "step": step_num, "name": step_name,
                    "status": "completed", "output": output_path, "error": None,
                })
                logger.info("Step %d completed: %s → %s", step_num, step_name, output_path)

            except Exception as e:
                error_msg = f"{type(e).__name__}: {e}"
                self.db.update_pipeline_run(
                    run_id,
                    status="failed",
                    completed_at=datetime.now().isoformat(),
                    error_message=error_msg,
                )
                failed += 1
                details.append({
                    "step": step_num, "name": step_name,
                    "status": "failed", "output": None, "error": error_msg,
                })
                logger.warning("Step %d failed: %s — %s", step_num, step_name, error_msg)

                # Alert bei Fehler
                try:
                    self.alerts.create_alert(
                        type="pipeline_step_failed",
                        priority="medium",
                        category="pipeline",
                        source_agent=step.get("agent", "pipeline"),
                        title=f"Pipeline Step {step_num} fehlgeschlagen: {step_name}",
                        description=error_msg,
                        data={"project_slug": project_slug, "step": step_num},
                    )
                except Exception:
                    pass  # Alert-Fehler darf Pipeline nicht stoppen

        duration = round(time.time() - start_time, 2)
        logger.info("=== Pipeline Complete: %d/%d steps, %d failed, %.1fs ===",
                     completed, len(self.STEPS), failed, duration)

        return {
            "project_slug": project_slug,
            "steps_total": len(self.STEPS),
            "steps_completed": completed,
            "steps_failed": failed,
            "steps_skipped": skipped,
            "details": details,
            "duration_seconds": duration,
        }

    def _execute_step(self, step: dict, project_slug: str, dry_run: bool):
        """Fuehrt einen einzelnen Step aus."""
        import importlib

        module = importlib.import_module(step["module"])
        cls = getattr(module, step["class"])
        instance = cls()
        method = getattr(instance, step["method"])

        # Spezialbehandlung je nach Methode
        method_name = step["method"]

        if method_name == "check_brand_compliance":
            # BrandGuardian braucht content-Text, nicht project_slug
            # Gib einen Platzhalter-Text
            return method(f"Marketing content for {project_slug}", "social_post")

        if method_name == "create_press_release":
            # PRAgent braucht occasion + key_facts
            return method(
                occasion=f"{project_slug} App Launch",
                key_facts={"app_name": project_slug, "category": "mobile_app"},
            )

        # Standard: Methode mit project_slug aufrufen
        return method(project_slug)

    def run_step(self, project_slug: str, step_number: int,
                 dry_run: bool = True) -> dict:
        """Einzelnen Step ausfuehren."""
        step = None
        for s in self.STEPS:
            if s["number"] == step_number:
                step = s
                break

        if not step:
            return {"error": f"Step {step_number} not found"}

        now = datetime.now().isoformat()
        run_id = self.db.store_pipeline_run(
            project_slug=project_slug,
            step_number=step_number,
            step_name=step["name"],
            status="running",
            started_at=now,
        )

        try:
            output = self._execute_step(step, project_slug, dry_run)
            output_path = str(output) if output else None
            self.db.update_pipeline_run(
                run_id,
                status="completed",
                completed_at=datetime.now().isoformat(),
                output_path=output_path,
            )
            return {"step": step_number, "name": step["name"],
                    "status": "completed", "output": output_path}
        except Exception as e:
            error_msg = f"{type(e).__name__}: {e}"
            self.db.update_pipeline_run(
                run_id,
                status="failed",
                completed_at=datetime.now().isoformat(),
                error_message=error_msg,
            )
            return {"step": step_number, "name": step["name"],
                    "status": "failed", "error": error_msg}

    def get_pipeline_status(self, project_slug: str) -> dict:
        """Welche Steps wurden ausgefuehrt, was steht aus."""
        runs = self.db.get_pipeline_runs(project_slug)

        # Letzten Status pro Step
        by_step: dict[int, dict] = {}
        for run in runs:
            sn = run["step_number"]
            if sn not in by_step:
                by_step[sn] = run

        steps_status = []
        for step in self.STEPS:
            sn = step["number"]
            run = by_step.get(sn)
            steps_status.append({
                "step": sn,
                "name": step["name"],
                "status": run["status"] if run else "not_run",
                "output": run.get("output_path") if run else None,
                "error": run.get("error_message") if run else None,
            })

        completed = sum(1 for s in steps_status if s["status"] == "completed")
        failed = sum(1 for s in steps_status if s["status"] == "failed")
        not_run = sum(1 for s in steps_status if s["status"] == "not_run")

        return {
            "project_slug": project_slug,
            "steps_total": len(self.STEPS),
            "completed": completed,
            "failed": failed,
            "not_run": not_run,
            "steps": steps_status,
        }

    def create_pipeline_report(self, project_slug: str) -> str:
        """Pipeline-Report als Markdown."""
        now = datetime.now()
        date_str = now.strftime("%Y%m%d")
        status = self.get_pipeline_status(project_slug)

        report_dir = Path(REPORTS_PATH) / "pipeline"
        report_dir.mkdir(parents=True, exist_ok=True)
        report_path = report_dir / f"pipeline_{project_slug}_{date_str}.md"

        lines = [
            f"# Marketing Pipeline Report: {project_slug}",
            f"\nGeneriert: {now.strftime('%Y-%m-%d %H:%M')}",
            f"\n## Zusammenfassung",
            f"\n- **Steps gesamt:** {status['steps_total']}",
            f"- **Completed:** {status['completed']}",
            f"- **Failed:** {status['failed']}",
            f"- **Not run:** {status['not_run']}",
            f"\n## Details",
            f"\n| Step | Name | Status | Output |",
            f"|---|---|---|---|",
        ]

        for s in status["steps"]:
            status_icon = {"completed": "OK", "failed": "FAIL", "not_run": "-"}.get(s["status"], "?")
            output = s.get("output") or s.get("error") or "-"
            if len(str(output)) > 60:
                output = str(output)[:57] + "..."
            lines.append(f"| {s['step']} | {s['name']} | {status_icon} | {output} |")

        content = "\n".join(lines)
        report_path.write_text(content, encoding="utf-8")
        logger.info("Pipeline report: %s", report_path)
        return str(report_path)

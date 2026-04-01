"""Community Outreach Templates — Vorgefertigte Templates fuer Community-Posts.

Deterministisch, kein LLM. Templates mit Platzhaltern die mit echten Daten
gefuellt werden.
"""

import logging
import re
from datetime import datetime, timedelta
from pathlib import Path

logger = logging.getLogger("factory.marketing.tools.community_templates")


class CommunityTemplates:
    """Vorgefertigte Templates fuer Community-Posts. Deterministisch."""

    TEMPLATES = {
        "reddit_artificial": {
            "platform": "Reddit r/artificial",
            "format": "text_post",
            "template": (
                "We built {product_name} -- here's how our {agent_count}-agent "
                "factory architecture works\n\n"
                "{description}\n\n"
                "Key stats:\n"
                "- {agent_count} autonomous agents across {dept_count} departments\n"
                "- Cost: {cost_example}\n"
                "- Time: {time_example}\n\n"
                "Happy to answer questions about the architecture."
            ),
            "rules": (
                "No self-promotion without substance. Must provide technical value. "
                "Engage with comments."
            ),
        },
        "reddit_machinelearning": {
            "platform": "Reddit r/MachineLearning",
            "format": "text_post",
            "template": (
                "[P] Autonomous multi-agent factory: {agent_count} agents, "
                "{dept_count} departments, idea-to-store pipeline\n\n"
                "{technical_description}\n\n"
                "Architecture: {architecture_summary}\n\n"
                "Results: {results}"
            ),
            "rules": (
                "Tag with [P] for Project. Highly technical audience. "
                "Include metrics and architecture details."
            ),
        },
        "hacker_news": {
            "platform": "Hacker News",
            "format": "show_hn",
            "template": (
                "Show HN: Autonomous AI factory that builds apps from idea to store "
                "({agent_count} agents)\n\n"
                "{hn_description}"
            ),
            "rules": (
                "Show HN format. Technical, concise. No marketing language. "
                "Comments are everything."
            ),
        },
        "product_hunt": {
            "platform": "Product Hunt",
            "format": "launch",
            "template": (
                "{tagline}\n\n"
                "{ph_description}\n\n"
                "Topics: {topics}"
            ),
            "rules": (
                "Launch early morning PST. Tagline max 60 chars. "
                "Engage with every comment. Maker comment is crucial."
            ),
        },
        "dev_to": {
            "platform": "Dev.to",
            "format": "article",
            "template": (
                "# How we built a marketing department with "
                "{marketing_agent_count} AI agents\n\n"
                "{article_body}"
            ),
            "rules": (
                "Tutorial/blog format. Include code examples. "
                "Tag with #ai #python #automation. Series welcome."
            ),
        },
        "indie_hackers": {
            "platform": "Indie Hackers",
            "format": "post",
            "template": (
                "How an autonomous AI factory disrupts app development\n\n"
                "{ih_description}\n\n"
                "Numbers:\n"
                "- {cost_stats}\n"
                "- {time_stats}\n"
                "- {agent_stats}"
            ),
            "rules": (
                "Founder story angle. Revenue/cost transparency appreciated. "
                "Community is supportive of builders."
            ),
        },
    }

    # ── Template API ───────────────────────────────────────

    def get_template(self, platform: str) -> dict | None:
        """Template abrufen. None wenn Plattform nicht vorhanden."""
        return self.TEMPLATES.get(platform)

    def fill_template(self, platform: str, variables: dict) -> str:
        """Template mit echten Daten fuellen.

        Fehlende Variablen werden als <<MISSING: variable_name>> markiert.
        """
        tmpl = self.TEMPLATES.get(platform)
        if not tmpl:
            return f"<<TEMPLATE NICHT GEFUNDEN: {platform}>>"

        text = tmpl["template"]

        # Alle {variable} Platzhalter finden und ersetzen
        def _replace(match):
            key = match.group(1)
            if key in variables:
                return str(variables[key])
            return f"<<MISSING: {key}>>"

        filled = re.sub(r"\{(\w+)\}", _replace, text)
        return filled

    def get_platform_rules(self, platform: str) -> str:
        """Posting-Regeln der Community."""
        tmpl = self.TEMPLATES.get(platform)
        if tmpl:
            return tmpl["rules"]
        return f"<<KEINE REGELN FUER: {platform}>>"

    def get_all_platforms(self) -> list[str]:
        """Alle verfuegbaren Template-Plattformen."""
        return list(self.TEMPLATES.keys())

    # ── Outreach Calendar ──────────────────────────────────

    def create_outreach_calendar(self, platforms: list[str] = None,
                                 frequency: str = "weekly") -> str:
        """Outreach-Kalender erstellen. Alle Posts gehen ueber CEO-Gate!

        Returns: Pfad zur MD-Datei.
        """
        if platforms is None:
            platforms = list(self.TEMPLATES.keys())

        today = datetime.now()
        weeks = 4 if frequency == "weekly" else 8

        lines = [
            "# Community Outreach Calendar",
            "",
            f"**Erstellt:** {today.strftime('%Y-%m-%d')}",
            f"**Frequenz:** {frequency}",
            f"**Plattformen:** {len(platforms)}",
            "",
            "> **WICHTIG:** Alle Posts gehen ueber CEO-Gate! "
            "Kein Post wird ohne CEO-Freigabe veroeffentlicht.",
            "",
            "## Zeitplan",
            "",
            "| Woche | Datum | Plattform | Format | Thema |",
            "|---|---|---|---|---|",
        ]

        topics = [
            "Factory Architecture Overview",
            "Marketing Department Deep Dive",
            "Cost Comparison: AI vs Traditional",
            "Behind the Scenes: Agent Collaboration",
            "Technical Deep Dive: Multi-Agent Systems",
            "Milestone Update",
            "Community Q&A / AMA",
            "New Feature Announcement",
        ]

        for week in range(weeks):
            date = today + timedelta(weeks=week)
            platform_key = platforms[week % len(platforms)]
            tmpl = self.TEMPLATES.get(platform_key, {})
            topic = topics[week % len(topics)]
            lines.append(
                f"| {week + 1} | {date.strftime('%Y-%m-%d')} | "
                f"{tmpl.get('platform', platform_key)} | "
                f"{tmpl.get('format', 'post')} | {topic} |"
            )

        lines.extend([
            "",
            "## Plattform-Regeln",
            "",
        ])

        for pk in platforms:
            tmpl = self.TEMPLATES.get(pk, {})
            lines.append(f"### {tmpl.get('platform', pk)}")
            lines.append(f"- Format: {tmpl.get('format', 'post')}")
            lines.append(f"- Regeln: {tmpl.get('rules', 'Keine speziellen Regeln')}")
            lines.append("")

        lines.extend([
            "---",
            "",
            "*Generiert von CommunityTemplates. Alle Posts benoetigen CEO-Freigabe via Gate.*",
        ])

        content = "\n".join(lines)

        output_dir = Path(__file__).resolve().parents[1] / "output" / "community"
        output_dir.mkdir(parents=True, exist_ok=True)
        output_path = output_dir / "outreach_calendar.md"
        output_path.write_text(content, encoding="utf-8")
        logger.info("Outreach Calendar: %s", output_path)
        return str(output_path)

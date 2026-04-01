"""SMTP Email Adapter. Default Dry-Run — kein Versand ohne Credentials.

Nutzt Python stdlib (smtplib + email.mime). Keine zusaetzliche Installation noetig.
"""

import logging
import os
import re
import smtplib
import time
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pathlib import Path

logger = logging.getLogger("factory.marketing.adapters.smtp")


class SMTPAdapter:
    """SMTP Email Adapter. Default Dry-Run — kein Versand ohne Credentials."""

    STATUS = "active"
    PLATFORM = "email"

    def __init__(self, dry_run: bool = True):
        self.smtp_host = os.getenv("SMTP_HOST")
        self.smtp_port = int(os.getenv("SMTP_PORT", "587"))
        self.smtp_user = os.getenv("SMTP_USER")
        self.smtp_password = os.getenv("SMTP_PASSWORD")
        self.from_email = os.getenv("SMTP_FROM", "factory@dai-core.ai")
        self._force_dry_run = self.smtp_host is None
        self.dry_run = True if self._force_dry_run else dry_run

        if self._force_dry_run:
            logger.info("SMTP Adapter: No SMTP_HOST — forced dry-run")
        elif self.dry_run:
            logger.info("SMTP Adapter: Dry-run mode (credentials present)")
        else:
            logger.info("SMTP Adapter: LIVE mode — emails will be sent!")

    # ── Markdown to HTML ──────────────────────────────────

    @staticmethod
    def _md_to_html(md: str) -> str:
        """Einfache Markdown->HTML-Konvertierung (Headings, Bold, Paragraphs)."""
        lines = md.strip().split("\n")
        html_parts = []
        for line in lines:
            stripped = line.strip()
            if stripped.startswith("### "):
                html_parts.append(f"<h3>{stripped[4:]}</h3>")
            elif stripped.startswith("## "):
                html_parts.append(f"<h2>{stripped[3:]}</h2>")
            elif stripped.startswith("# "):
                html_parts.append(f"<h1>{stripped[2:]}</h1>")
            elif stripped.startswith("- "):
                html_parts.append(f"<li>{stripped[2:]}</li>")
            elif stripped == "":
                html_parts.append("<br>")
            else:
                # Bold
                converted = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", stripped)
                html_parts.append(f"<p>{converted}</p>")
        body = "\n".join(html_parts)
        return f"<html><body>\n{body}\n</body></html>"

    # ── Build Message ─────────────────────────────────────

    def _build_message(self, to: str, subject: str, body_html: str,
                       body_text: str = None, attachments: list = None) -> MIMEMultipart:
        """Baut MIME-Message."""
        msg = MIMEMultipart("alternative")
        msg["From"] = self.from_email
        msg["To"] = to
        msg["Subject"] = subject

        if body_text:
            msg.attach(MIMEText(body_text, "plain", "utf-8"))
        msg.attach(MIMEText(body_html, "html", "utf-8"))

        if attachments:
            # Switch to mixed for attachments
            outer = MIMEMultipart("mixed")
            outer["From"] = msg["From"]
            outer["To"] = msg["To"]
            outer["Subject"] = msg["Subject"]
            outer.attach(msg)
            for filepath in attachments:
                path = Path(filepath)
                if path.exists():
                    with open(path, "rb") as f:
                        part = MIMEApplication(f.read(), Name=path.name)
                    part["Content-Disposition"] = f'attachment; filename="{path.name}"'
                    outer.attach(part)
                else:
                    logger.warning("Attachment not found: %s", filepath)
            return outer
        return msg

    # ── Send Single ───────────────────────────────────────

    def send_email(self, to: str, subject: str, body_html: str,
                   body_text: str = None, attachments: list = None) -> dict:
        """Sendet eine Email. Dry-Run: loggt statt zu senden."""
        result = {
            "sent": False,
            "dry_run": self.dry_run,
            "to": to,
            "subject": subject,
        }

        attachment_names = []
        if attachments:
            attachment_names = [Path(a).name for a in attachments]
            result["attachments"] = attachment_names

        if self.dry_run:
            logger.info(
                "[DRY-RUN] Email to=%s subject='%s' body_len=%d attachments=%s",
                to, subject, len(body_html), attachment_names,
            )
            result["sent"] = True
            return result

        # Live send
        try:
            msg = self._build_message(to, subject, body_html, body_text, attachments)
            with smtplib.SMTP(self.smtp_host, self.smtp_port, timeout=30) as server:
                server.starttls()
                server.login(self.smtp_user, self.smtp_password)
                server.send_message(msg)
            result["sent"] = True
            logger.info("Email sent to=%s subject='%s'", to, subject)
        except Exception as e:
            logger.error("Email send failed to=%s: %s", to, e)
            result["error"] = str(e)

        return result

    # ── Send Bulk ─────────────────────────────────────────

    def send_bulk(self, recipients_list: list[str], subject: str,
                  body_html: str, body_text: str = None,
                  attachments: list = None, delay_seconds: int = 2) -> dict:
        """Sendet an mehrere Empfaenger mit Pause."""
        result = {"sent": 0, "failed": 0, "details": []}

        for recipient in recipients_list:
            r = self.send_email(recipient, subject, body_html, body_text, attachments)
            if r.get("sent"):
                result["sent"] += 1
            else:
                result["failed"] += 1
            result["details"].append(r)

            if not self.dry_run and delay_seconds > 0:
                time.sleep(delay_seconds)

        return result

    # ── Press Release ─────────────────────────────────────

    def send_press_release(self, contacts: list[dict], press_release_md: str,
                           press_kit_path: str = None) -> dict:
        """Sendet Pressemitteilung an Kontakt-Liste."""
        body_html = self._md_to_html(press_release_md)
        body_text = press_release_md  # Plaintext fallback

        # Subject aus erster Zeile
        first_line = press_release_md.strip().split("\n")[0]
        subject = first_line.lstrip("#").strip()
        if not subject:
            subject = "Pressemitteilung — DAI-Core Factory"

        attachments = [press_kit_path] if press_kit_path else None
        recipients = [c.get("email", "") for c in contacts if c.get("email")]

        if not recipients:
            logger.info("[DRY-RUN] Press release: %d contacts (no emails)", len(contacts))
            return {
                "sent": 0, "contacts": len(contacts),
                "dry_run": self.dry_run, "subject": subject,
                "note": "No email addresses in contacts (expected for seed data)",
            }

        return self.send_bulk(recipients, subject, body_html, body_text, attachments)

    # ── Influencer Outreach ───────────────────────────────

    def send_influencer_outreach(self, contact: dict, message_md: str) -> dict:
        """Personalisierte Email an einen Influencer."""
        email = contact.get("email", "")
        name = contact.get("name", "Unknown")
        subject = f"Collaboration Opportunity — DAI-Core x {name}"

        body_html = self._md_to_html(message_md)

        if not email:
            logger.info(
                "[DRY-RUN] Influencer outreach to=%s (no email): preview=%s",
                name, message_md[:100],
            )
            return {
                "sent": False, "dry_run": True, "to": name,
                "subject": subject, "note": "No email address",
            }

        return self.send_email(email, subject, body_html, body_text=message_md)

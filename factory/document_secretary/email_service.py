"""Email service — sends documents via SMTP. Reuses existing briefings/ config."""

import os
import smtplib
from email import encoders
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from pathlib import Path

from dotenv import load_dotenv

load_dotenv()


def send_document(filepath: str, subject: str, body: str = "") -> bool:
    """Send a .docx document via email.

    Uses SMTP config from .env (BRIEFING_SMTP_* variables).
    Returns True if sent successfully, False otherwise.
    """
    smtp_host = os.getenv("BRIEFING_SMTP_HOST")
    smtp_port = int(os.getenv("BRIEFING_SMTP_PORT", "587"))
    smtp_user = os.getenv("BRIEFING_SMTP_USER")
    smtp_pass = os.getenv("BRIEFING_SMTP_PASS")
    email_from = os.getenv("BRIEFING_SMTP_FROM")
    email_to = os.getenv("BRIEFING_EMAIL_TO")

    if not all([smtp_host, smtp_user, smtp_pass, email_from, email_to]):
        print("[DocumentSecretary] WARNING: SMTP not configured — document saved but not sent")
        return False

    try:
        msg = MIMEMultipart()
        msg["From"] = email_from
        msg["To"] = email_to
        msg["Subject"] = subject

        msg.attach(MIMEText(body or f"Anbei: {Path(filepath).name}", "plain"))

        with open(filepath, "rb") as f:
            part = MIMEBase("application", "pdf")
            part.set_payload(f.read())
            encoders.encode_base64(part)
            part.add_header(
                "Content-Disposition",
                f'attachment; filename="{Path(filepath).name}"',
            )
            msg.attach(part)

        with smtplib.SMTP(smtp_host, smtp_port) as server:
            server.starttls()
            server.login(smtp_user, smtp_pass)
            server.send_message(msg)

        print(f"[DocumentSecretary] Email sent: {subject}")
        return True
    except Exception as e:
        print(f"[DocumentSecretary] ERROR sending email: {e}")
        return False

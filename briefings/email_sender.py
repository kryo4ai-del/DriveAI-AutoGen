# email_sender.py
# Sends daily briefing as HTML email via SMTP.
# Config via environment variables:
#   BRIEFING_SMTP_HOST, BRIEFING_SMTP_PORT, BRIEFING_SMTP_USER,
#   BRIEFING_SMTP_PASS, BRIEFING_EMAIL_FROM, BRIEFING_EMAIL_TO

import logging
import os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

logger = logging.getLogger(__name__)


def send_briefing_email(subject: str, html_body: str) -> bool:
    """Send an HTML email with the daily briefing. Returns True on success."""
    host = os.environ.get("BRIEFING_SMTP_HOST", "")
    port = int(os.environ.get("BRIEFING_SMTP_PORT", "587"))
    user = os.environ.get("BRIEFING_SMTP_USER", "")
    password = os.environ.get("BRIEFING_SMTP_PASS", "")
    from_addr = os.environ.get("BRIEFING_EMAIL_FROM", user)
    to_addr = os.environ.get("BRIEFING_EMAIL_TO", "")

    if not all([host, user, password, to_addr]):
        logger.warning("Email not configured — missing SMTP env vars")
        return False

    msg = MIMEMultipart("alternative")
    msg["Subject"] = subject
    msg["From"] = from_addr
    msg["To"] = to_addr

    # Plain-text fallback
    plain = f"Daily Briefing: {subject}\n\nOpen the HTML version for full details."
    msg.attach(MIMEText(plain, "plain", "utf-8"))
    msg.attach(MIMEText(html_body, "html", "utf-8"))

    try:
        if port == 465:
            # SSL
            with smtplib.SMTP_SSL(host, port, timeout=30) as server:
                server.login(user, password)
                server.sendmail(from_addr, [to_addr], msg.as_string())
        else:
            # STARTTLS
            with smtplib.SMTP(host, port, timeout=30) as server:
                server.starttls()
                server.login(user, password)
                server.sendmail(from_addr, [to_addr], msg.as_string())
        logger.info(f"Briefing email sent to {to_addr}")
        return True
    except Exception as e:
        logger.error(f"Email send failed: {e}")
        return False

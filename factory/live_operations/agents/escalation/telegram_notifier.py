"""Telegram Notifier -- sendet CEO-Eskalationen via Telegram Bot.

Token und Chat-ID werden ueber Umgebungsvariablen konfiguriert:
  DRIVEAI_TELEGRAM_BOT_TOKEN
  DRIVEAI_TELEGRAM_CHAT_ID

Wenn nicht gesetzt, werden Nachrichten nur geloggt (kein Fehler).
"""

import urllib.request
import urllib.parse
import json

from . import config


class TelegramNotifier:
    """Sendet Nachrichten via Telegram Bot API."""

    def __init__(self) -> None:
        self.token = config.TELEGRAM_BOT_TOKEN
        self.chat_id = config.TELEGRAM_CHAT_ID
        self.enabled = config.TELEGRAM_ENABLED

    def send(self, message: str) -> dict:
        """Sendet Nachricht. Returns dict mit sent/error."""
        if not self.enabled:
            print(f"[Telegram] Not configured -- message logged only")
            return {"sent": False, "error": "not_configured", "message": message}

        url = f"https://api.telegram.org/bot{self.token}/sendMessage"
        payload = {
            "chat_id": self.chat_id,
            "text": message,
            "parse_mode": "HTML",
        }

        for attempt in range(config.TELEGRAM_MAX_RETRIES + 1):
            try:
                data = json.dumps(payload).encode("utf-8")
                req = urllib.request.Request(
                    url, data=data,
                    headers={"Content-Type": "application/json"},
                    method="POST",
                )
                with urllib.request.urlopen(req, timeout=config.TELEGRAM_TIMEOUT_SECONDS) as resp:
                    result = json.loads(resp.read().decode("utf-8"))
                    if result.get("ok"):
                        print(f"[Telegram] Message sent successfully")
                        return {"sent": True, "error": None, "message_id": result.get("result", {}).get("message_id")}
                    else:
                        error = result.get("description", "Unknown error")
                        print(f"[Telegram] API error: {error}")
                        return {"sent": False, "error": error}

            except Exception as e:
                if attempt < config.TELEGRAM_MAX_RETRIES:
                    print(f"[Telegram] Attempt {attempt + 1} failed: {e} -- retrying")
                    continue
                print(f"[Telegram] Failed after {attempt + 1} attempts: {e}")
                return {"sent": False, "error": str(e)}

        return {"sent": False, "error": "max_retries_exceeded"}

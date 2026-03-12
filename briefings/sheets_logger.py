# sheets_logger.py
# Appends daily briefing KPIs to a Google Sheet.
# Config:
#   BRIEFING_GSHEET_ID — Google Spreadsheet ID
#   GOOGLE_SERVICE_ACCOUNT_FILE — path to service account JSON credentials
#     (default: /opt/driveai-factory/config/google_sa.json)

import logging
import os

logger = logging.getLogger(__name__)

# Column order for the Sheet (first row = header)
COLUMNS = [
    "date", "briefing_id", "agents", "projects", "active_projects",
    "ideas", "ideas_inbox", "specs", "plans", "opportunities",
    "trends", "improvements", "watch_events", "compliance", "a11y",
    "memory_entries", "total_alerts", "critical_alerts", "summary",
    "actions", "status",
]


def append_to_sheet(row_data: dict) -> bool:
    """Append a briefing row to Google Sheets. Returns True on success."""
    sheet_id = os.environ.get("BRIEFING_GSHEET_ID", "")
    cred_path = os.environ.get(
        "GOOGLE_SERVICE_ACCOUNT_FILE",
        "/opt/driveai-factory/config/google_sa.json",
    )

    if not sheet_id:
        logger.warning("Google Sheets not configured — BRIEFING_GSHEET_ID not set")
        return False

    if not os.path.exists(cred_path):
        logger.warning(f"Google credentials not found: {cred_path}")
        return False

    try:
        import gspread
        from google.oauth2.service_account import Credentials

        scopes = [
            "https://www.googleapis.com/auth/spreadsheets",
            "https://www.googleapis.com/auth/drive",
        ]
        creds = Credentials.from_service_account_file(cred_path, scopes=scopes)
        gc = gspread.authorize(creds)

        sheet = gc.open_by_key(sheet_id).sheet1

        # Ensure header row exists
        existing = sheet.row_values(1)
        if not existing:
            sheet.append_row(COLUMNS)

        # Build row in correct column order
        values = [str(row_data.get(col, "")) for col in COLUMNS]
        sheet.append_row(values)

        logger.info(f"Briefing logged to Google Sheet: {row_data.get('briefing_id', '?')}")
        return True

    except ImportError:
        logger.error("gspread or google-auth not installed — run: pip install gspread google-auth")
        return False
    except Exception as e:
        logger.error(f"Google Sheets append failed: {e}")
        return False

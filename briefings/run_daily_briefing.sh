#!/usr/bin/env bash
# run_daily_briefing.sh — Cron entrypoint for daily briefing generation + delivery.
# Runs at 08:00 UTC via cron. Generates briefing, sends email, logs to Sheets.

set +e
FACTORY_ROOT="/opt/driveai-factory"
LOG_DIR="${FACTORY_ROOT}/briefings/logs"
LOG_FILE="${LOG_DIR}/briefing_$(date +%Y-%m-%d).log"
LATEST_LINK="${FACTORY_ROOT}/briefings/html/latest.html"

mkdir -p "$LOG_DIR"

echo "=== Daily Briefing Run: $(date -u '+%Y-%m-%d %H:%M UTC') ===" >> "$LOG_FILE"

# Load env vars if .env exists
if [ -f "${FACTORY_ROOT}/config/briefing.env" ]; then
    set -a
    source "${FACTORY_ROOT}/config/briefing.env"
    set +a
fi

cd "$FACTORY_ROOT"

# Generate briefing + deliver
python3 -c "
import sys, os
sys.path.insert(0, '$FACTORY_ROOT')
os.chdir('$FACTORY_ROOT')

from briefings.daily_briefing import generate_briefing, to_sheets_row
from briefings.email_sender import send_briefing_email
from briefings.sheets_logger import append_to_sheet
from briefings.briefing_manager import BriefingManager

# 1. Generate
briefing = generate_briefing()
bid = briefing.get('briefing_id', '?')
bdate = briefing.get('briefing_date', '?')
alerts = len(briefing.get('sections', {}).get('alerts', []))
print(f'Generated: {bid} ({bdate}) — {alerts} alerts')

# 2. Email
html_path = os.path.join('$FACTORY_ROOT', briefing.get('html_path', ''))
if os.path.exists(html_path):
    with open(html_path, encoding='utf-8') as f:
        html_body = f.read()
    if send_briefing_email(f'AI App Factory Briefing — {bdate}', html_body):
        print('Email: sent')
    else:
        print('Email: skipped (not configured or failed)')

    # Symlink latest
    latest = '$LATEST_LINK'
    if os.path.islink(latest) or os.path.exists(latest):
        os.remove(latest)
    os.symlink(html_path, latest)
else:
    print(f'HTML not found: {html_path}')

# 3. Google Sheets
row = to_sheets_row(briefing)
if append_to_sheet(row):
    print('Sheets: logged')
else:
    print('Sheets: skipped (not configured or failed)')

# 4. Mark as delivered if email was sent
manager = BriefingManager()
if os.environ.get('BRIEFING_SMTP_HOST'):
    manager.transition(bid, 'delivered')
    print(f'Status: delivered')
else:
    print(f'Status: generated (email not configured)')
" >> "$LOG_FILE" 2>&1

echo "=== Done: $(date -u '+%Y-%m-%d %H:%M UTC') ===" >> "$LOG_FILE"

"""Support Analyzer Configuration."""

RECURRING_MIN_TICKETS = 5        # Minimum tickets for "recurring" issue
RECURRING_WINDOW_DAYS = 7        # Timeframe
CRITICAL_RATIO_THRESHOLD = 0.15  # >15% critical -> alert
TICKETS_PER_DAU_THRESHOLD = 0.01 # >1% DAU writes tickets -> alert

TICKET_CATEGORIES = {
    "crash": ["crash", "freeze", "stuck", "force close", "not responding", "absturz", "einfrieren", "haengt"],
    "bug": ["bug", "error", "wrong", "incorrect", "broken", "doesn't show", "fehler", "kaputt", "falsch"],
    "feature_request": ["wish", "please add", "would love", "suggestion", "can you add", "wuensche", "vorschlag"],
    "how_to": ["how to", "how do i", "where is", "can't find", "help me", "wie kann", "wo finde", "hilfe"],
    "account": ["login", "password", "account", "subscription", "payment", "billing", "anmelden", "passwort", "konto"],
    "performance": ["slow", "lag", "battery", "memory", "storage", "loading", "langsam", "akku", "speicher"],
}

URGENCY_CRITICAL_KEYWORDS = ["always", "every time", "constantly", "100%", "immer", "jedes mal"]
URGENCY_CORE_FEATURES = ["login", "payment", "checkout", "export", "save", "sync"]

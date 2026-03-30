"""Review Analyzer Configuration."""

RATING_TARGET = 4.2              # Minimum target (below -> alert)
PATTERN_MIN_MENTIONS = 3         # Minimum mentions for pattern detection
PATTERN_WINDOW_DAYS = 7          # Timeframe for pattern detection
REVIEW_FETCH_LIMIT = 50          # Max reviews per analysis run
REVIEW_LANGUAGES = ["en", "de"]  # Supported languages

# EN Keywords
KEYWORD_CATEGORIES = {
    "bug_report": ["crash", "bug", "error", "broken", "doesn't work", "not working", "freeze", "stuck", "force close"],
    "feature_request": ["wish", "please add", "would be nice", "missing", "need", "should have", "would love", "suggestion"],
    "praise": ["love", "great", "amazing", "perfect", "best", "awesome", "excellent", "fantastic", "wonderful"],
    "complaint": ["terrible", "worst", "waste", "hate", "awful", "useless", "disappointed", "horrible", "garbage"],
    "question": ["how to", "how do", "can i", "is there", "where is", "help me", "can't find"],
}

# DE Keywords
KEYWORD_CATEGORIES_DE = {
    "bug_report": ["absturz", "fehler", "kaputt", "funktioniert nicht", "haengt", "einfrieren", "absturz"],
    "feature_request": ["wuensche", "bitte hinzufuegen", "fehlt", "waere toll", "vorschlag", "brauche"],
    "praise": ["super", "toll", "genial", "perfekt", "beste", "klasse", "hervorragend", "fantastisch"],
    "complaint": ["schrecklich", "schlecht", "mist", "enttaeuschend", "nutzlos", "katastrophe", "muell"],
    "question": ["wie kann", "wie geht", "wo finde", "gibt es", "hilfe"],
}

# Sentiment keywords
SENTIMENT_POSITIVE = ["love", "great", "amazing", "perfect", "best", "awesome", "excellent", "happy", "super", "toll", "genial"]
SENTIMENT_NEGATIVE = ["hate", "terrible", "worst", "awful", "broken", "crash", "bug", "useless", "schlecht", "mist", "kaputt"]

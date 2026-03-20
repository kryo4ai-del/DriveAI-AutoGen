"""Shared keyword extraction for research agents."""


def extract_keywords(ceo_idea: str) -> dict:
    """Extract key terms from CEO idea for search query building."""
    idea_lower = ceo_idea.lower()

    # Genre detection
    genres = [
        "puzzle", "match-3", "casual", "hyper-casual", "hybrid-casual",
        "rpg", "strategy", "simulation", "racing", "shooter", "adventure",
        "idle", "clicker", "card", "board", "trivia", "word", "action",
    ]
    detected_genre = next((g for g in genres if g in idea_lower), "mobile game")

    # Platform detection
    platforms = []
    if "ios" in idea_lower or "iphone" in idea_lower:
        platforms.append("iOS")
    if "android" in idea_lower:
        platforms.append("Android")
    if "unity" in idea_lower:
        platforms.append("Unity")
    if "web" in idea_lower:
        platforms.append("Web")
    if not platforms:
        platforms = ["iOS", "Android"]

    # Mechanic detection
    mechanics = []
    mechanic_keywords = [
        "match-3", "ai generated", "ai-generated", "narrative",
        "story", "social", "pvp", "coop", "co-op", "battle pass",
        "rewarded ads", "personalization", "procedural", "daily",
    ]
    for kw in mechanic_keywords:
        if kw in idea_lower:
            mechanics.append(kw)

    # Monetization detection
    monetization = []
    money_keywords = [
        "ads", "iap", "in-app", "battle pass", "subscription",
        "premium", "freemium", "hybrid",
    ]
    for kw in money_keywords:
        if kw in idea_lower:
            monetization.append(kw)

    return {
        "genre": detected_genre,
        "platforms": platforms,
        "mechanics": mechanics,
        "monetization": monetization,
        "raw_idea": ceo_idea,
    }

enum class FilterOption(
    val value: String,
    val displayName: String,  // What the user sees
    val emotionalFrame: String  // Motivation boost
) {
    ALL(
        "all",
        "All Categories",
        "Your complete skill map"
    ),
    STRONG(
        "strong",
        "Master Topics",
        "Categories where you're crushing it"
    ),
    GROWTH(  // Renamed from WEAK
        "growth",
        "Ready to Level Up",
        "Categories with the biggest growth potential"
    ),
}
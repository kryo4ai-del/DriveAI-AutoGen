data class RefreshResult(
    val categoriesAfter: List<Category>,
    val progressDeltas: Map<String, Float>,  // categoryId → score change (+5.2%, +3.1%)
    val categoriesImproved: List<String>,    // ["Speed Limits", "Parking"]
    val categoriesNowStrong: List<String>,   // Newly hit 70% threshold
    val overallExamReadiness: Int,           // 42% → 48%
    val celebrationMessage: String,          // "Great! Speed Limits jumped 5 points."
)
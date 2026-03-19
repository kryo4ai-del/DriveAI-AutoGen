data class ReadinessScore(
    // ... existing fields ...
    val categoryScores: Map<String, Int> = emptyMap(),
    // New field: prioritized weak areas with actionable steps
    val recommendedFocus: List<String>? = null  // E.g., ["Traffic Signs", "Speed Limits"]
)

// Or in ViewModel:
fun getRecommendedStudyPath(): List<StudyPathItem> {
    val success = uiState.value as? ReadinessUiState.Success ?: return emptyList()
    return success.score.categoryScores
        .filter { it.value < 70 }
        .sortedBy { it.value }  // Weakest first
        .map { (category, score) ->
            StudyPathItem(
                category = category,
                currentScore = score,
                estimatedMinutesToMastery = (70 - score) * 2  // Heuristic
            )
        }
}
package com.driveai.askfin.data.models

data class ReadinessScore(
    val categoryScores: Map<String, Int> = emptyMap(),
    val recommendedFocus: List<String>? = null
)

data class StudyPathItem(
    val category: String,
    val currentScore: Int,
    val estimatedMinutesToMastery: Int
)

sealed class ReadinessUiState {
    data class Success(val score: ReadinessScore) : ReadinessUiState()
}

class ReadinessViewModel {
    val uiState: kotlinx.coroutines.flow.MutableStateFlow<ReadinessUiState> =
        kotlinx.coroutines.flow.MutableStateFlow(ReadinessUiState.Success(ReadinessScore(categoryScores = emptyMap(), recommendedFocus = null)))

    fun getRecommendedStudyPath(): List<StudyPathItem> {
        val success = uiState.value as? ReadinessUiState.Success ?: return emptyList()
        return success.score.categoryScores
            .filter { entry -> entry.value < 70 }
            .entries
            .sortedBy { entry -> entry.value }
            .map { entry ->
                StudyPathItem(
                    category = entry.key,
                    currentScore = entry.value,
                    estimatedMinutesToMastery = (70 - entry.value) * 2
                )
            }
    }
}
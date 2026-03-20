package com.driveai.askfin.data.models

sealed class TrainingModeUiState {
    data object Loading : TrainingModeUiState()
    data class Ready(
        val questions: List<Question>,
        val currentIndex: Int,
        val selectedAnswerId: String? = null,
        val isAnswerRevealed: Boolean = false,
        val progress: Float = 0f,
    ) : TrainingModeUiState()
    data class Error(val message: String, val throwable: Throwable? = null) : TrainingModeUiState()
    data class Complete(val score: Int, val totalQuestions: Int) : TrainingModeUiState()
}
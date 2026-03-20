package com.driveai.askfin.data.models

import com.driveai.askfin.data.models.Question

sealed class ExamSimulationUiState {
    object Loading : ExamSimulationUiState()
    
    data class Success(
        val currentQuestion: Question,
        val options: List<String>,
        val selectedAnswer: String? = null,
        val isAnswerRevealed: Boolean = false,
        val isCorrect: Boolean? = null,
        val timeRemainingSeconds: Int = 60,
        val questionIndex: Int = 0,
        val totalQuestions: Int = 0
    ) : ExamSimulationUiState()
    
    data class Error(
        val message: String,
        val throwable: Throwable? = null
    ) : ExamSimulationUiState()
}
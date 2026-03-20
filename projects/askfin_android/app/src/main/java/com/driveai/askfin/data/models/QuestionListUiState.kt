package com.driveai.askfin.data.models

import androidx.compose.material3.Text
import androidx.compose.runtime.Composable

// Extend QuestionListUiState:
data class QuestionListUiState(
    val questions: List<String> = emptyList(),
    val filteredQuestions: List<String> = emptyList(),
    val filteredCount: Int = 0,
    val resultSummary: String = ""
)

// Update in applyFilters:
private fun applyFilters(uiState: QuestionListUiState): QuestionListUiState {
    var filtered = uiState.questions
    
    val resultSummary = when {
        filtered.isEmpty() -> "No questions match your filters. Try adjusting difficulty or search."
        filtered.size == 1 -> "1 question found."
        else -> "${filtered.size} questions found."
    }
    
    return uiState.copy(
        filteredQuestions = filtered,
        filteredCount = filtered.size,
        resultSummary = resultSummary
    )
}

// In UI Composable:
@Composable
fun ResultSummaryText(resultSummary: String) {
    Text(resultSummary)
}
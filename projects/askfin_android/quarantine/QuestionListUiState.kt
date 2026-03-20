package com.driveai.askfin.data.models

// Extend QuestionListUiState:
data class QuestionListUiState(
    // ... existing fields ...
    val filteredCount: Int = 0,
    val resultSummary: String = ""  // e.g., "5 questions match your filters"
)

// Update in applyFilters:
private fun applyFilters(...) {
    var filtered = _uiState.value.questions
    // ... filtering logic ...
    
    val resultSummary = when {
        filtered.isEmpty() -> "No questions match your filters. Try adjusting difficulty or search."
        filtered.size == 1 -> "1 question found."
        else -> "${filtered.size} questions found."
    }
    
    _uiState.value = _uiState.value.copy(
        filteredQuestions = filtered,
        filteredCount = filtered.size,
        resultSummary = resultSummary
    )
}

// In UI Composable:
Text(viewModel.uiState.value.resultSummary)
    .announceForAccessibility() // Screen reader announces count
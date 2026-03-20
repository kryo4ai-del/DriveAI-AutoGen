package com.driveai.askfin.ui.viewmodels
import javax.inject.Inject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.launch

data class Answer(
    val timeSpentMs: Long
)

data class TrainingUiState(
    val placeholder: Boolean = false
)

class TrainingViewModel @Inject constructor() : ViewModel() {
    private var questionStartTime = 0L
    private val _uiState = MutableStateFlow(TrainingUiState())

    fun initializeSession() {
        viewModelScope.launch {
            // ... existing code ...
            questionStartTime = System.currentTimeMillis()
            _uiState.value = _uiState.value.copy()
        }
    }
    
    fun submitAnswer(answerText: String, selectedOptionIndex: Int) {
        val timeSpentMs = System.currentTimeMillis() - questionStartTime
        val answer = Answer(
            timeSpentMs = timeSpentMs
        )
    }
    
    fun nextQuestion() {
        viewModelScope.launch {
            // ... transition logic ...
            questionStartTime = System.currentTimeMillis()  // Reset for next Q
        }
    }
}
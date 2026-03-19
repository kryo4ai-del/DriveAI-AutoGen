class TrainingViewModel @Inject constructor(...) : ViewModel() {
    private var questionStartTime = 0L
    
    fun initializeSession(...) {
        viewModelScope.launch {
            // ... existing code ...
            questionStartTime = System.currentTimeMillis()
            _uiState.value = _uiState.value.copy(...)
        }
    }
    
    fun submitAnswer(answerText: String, selectedOptionIndex: Int) {
        val timeSpentMs = System.currentTimeMillis() - questionStartTime
        val answer = Answer(
            timeSpentMs = timeSpentMs,
            // ... other fields ...
        )
    }
    
    fun nextQuestion() {
        viewModelScope.launch {
            // ... transition logic ...
            questionStartTime = System.currentTimeMillis()  // Reset for next Q
        }
    }
}
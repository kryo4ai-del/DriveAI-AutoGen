sealed class ExamResultState {
    // ...
    data class ReadyToRetake(val newExamId: String) : ExamResultState()
}

fun retakeExam() {
    viewModelScope.launch {
        try {
            val newExamId = examRepository.resetExam(examId)
            _state.update {
                ExamResultState.ReadyToRetake(newExamId)
            }
        } catch (e: Exception) {
            _state.update {
                ExamResultState.Error(e.message ?: "Failed to reset exam")
            }
        }
    }
}
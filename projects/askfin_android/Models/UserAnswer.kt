// Store as reference—validation happens at check time
data class UserAnswer(
    val userId: String,
    val questionId: String,
    val selectedAnswerIndex: Int,
    val isCorrect: Boolean,
    val timestamp: Long
) {
    init {
        require(userId.isNotBlank()) { "userId cannot be empty" }
        require(questionId.isNotBlank()) { "questionId cannot be empty" }
        require(selectedAnswerIndex >= 0) { "selectedAnswerIndex cannot be negative" }
        require(timestamp > 0) { "timestamp must be positive" }
    }
    
    // Validation against question happens in service layer:
    // fun validateAgainst(question: Question) { ... }
}
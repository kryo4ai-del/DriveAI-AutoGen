data class UserAnswer(
    val id: String = UUID.randomUUID().toString(),
    val questionId: String,
    val selectedAnswerIndex: Int,
    val isCorrect: Boolean,
    val timestamp: Instant = Instant.now(),
    val userId: String = "",
    val timeSpentSeconds: Int = 0
) {
    init {
        require(id.isNotBlank()) { "Answer ID cannot be blank" }
        require(questionId.isNotBlank()) { "Question ID cannot be blank" }
        require(selectedAnswerIndex >= 0) { "Answer index cannot be negative" }
        require(selectedAnswerIndex < 100) { "Answer index must be < 100 (sanity check)" }
        require(timeSpentSeconds in 0..3600) { "Time spent must be 0-3600 seconds" }
    }
}

// BETTER: Validation at Question level where true constraint lives
fun Question.recordAnswer(
    selectedAnswerIndex: Int,
    timeSpentSeconds: Int = 0,
    userId: String = ""
): Result<UserAnswer> =
    if (selectedAnswerIndex !in answers.indices) {
        Result.failure(
            IllegalArgumentException(
                "Answer index $selectedAnswerIndex invalid for question $id (${answers.size} options)"
            )
        )
    } else {
        Result.success(
            UserAnswer(
                questionId = id,
                selectedAnswerIndex = selectedAnswerIndex,
                isCorrect = selectedAnswerIndex == correctAnswerIndex,
                timeSpentSeconds = timeSpentSeconds,
                userId = userId
            )
        )
    }
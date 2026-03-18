data class Question(
    val id: String,
    val text: String,
    val category: QuestionCategory,
    val answers: List<Answer>,
    val correctAnswerIndex: Int,
    val explanation: String,
    val createdAt: Instant,  // ✅ Require explicit value from persistence layer
    val imageUrl: String? = null,
    val difficulty: DifficultyLevel = DifficultyLevel.MEDIUM
) {
    init {
        require(id.isNotBlank()) { "Question ID cannot be blank" }
        require(text.isNotBlank()) { "Question text cannot be blank" }
        require(answers.isNotEmpty()) { "Question must have at least one answer" }
        require(correctAnswerIndex in answers.indices) { "Correct answer index out of bounds" }
        require(explanation.isNotBlank()) { "Explanation cannot be blank" }
    }

    companion object {
        fun create(
            id: String,
            text: String,
            category: QuestionCategory,
            answers: List<Answer>,
            correctAnswerIndex: Int,
            explanation: String,
            imageUrl: String? = null,
            difficulty: DifficultyLevel = DifficultyLevel.MEDIUM
        ) = Question(
            id = id,
            text = text,
            category = category,
            answers = answers,
            correctAnswerIndex = correctAnswerIndex,
            explanation = explanation,
            createdAt = Instant.now(),  // ✅ Fresh timestamp per creation
            imageUrl = imageUrl,
            difficulty = difficulty
        )
    }
}
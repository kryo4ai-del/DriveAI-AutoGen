interface QuestionRepository {
    suspend fun getQuestions(): Result<List<Question>>
    suspend fun getQuestionsByCategory(
        category: QuestionCategory
    ): Result<List<Question>>
    suspend fun getWeakQuestions(
        userId: String,
        threshold: Int = 3
    ): Result<List<Question>>
}

// Usage (safe):
questionRepository.getQuestions()
    .onSuccess { questions -> updateUI(questions) }
    .onFailure { error -> showErrorMessage("Failed to load questions") }
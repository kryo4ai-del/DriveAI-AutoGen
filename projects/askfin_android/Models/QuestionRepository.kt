interface QuestionRepository {
    
    /**
     * Retrieves all questions from the database.
     * 
     * @return Result containing all available questions.
     *         Empty list is valid (e.g., DB not yet loaded).
     *         Exception in Result.failure only on I/O error.
     */
    suspend fun getQuestions(): Result<List<Question>>
    
    /**
     * Retrieves questions filtered by category with optional pagination.
     * 
     * @param category The question category to filter by
     * @param limit Maximum questions to return (default 20)
     * @param offset Pagination offset (default 0)
     * @return Result containing questions.
     *         Empty list is valid if category has fewer questions.
     *         Exception in Result.failure only on I/O error.
     */
    suspend fun getQuestionsByCategory(
        category: QuestionCategory,
        limit: Int = 20,
        offset: Int = 0
    ): Result<List<Question>>
    
    /**
     * Retrieves a single question by ID.
     * 
     * @param questionId The ID of the question to retrieve
     * @return Result containing the question, or null if not found.
     *         Null is valid (question ID was invalid).
     *         Exception in Result.failure only on I/O error.
     */
    suspend fun getQuestionById(questionId: String): Result<Question?>
    
    /**
     * Retrieves questions where the user has performed poorly (weak spots).
     * 
     * Weakness is determined by frequency of incorrect answers in history.
     * 
     * @param userId The user ID to fetch weak questions for
     * @param limit Maximum questions to return (default 20)
     * @return Result containing weak questions sorted by error frequency.
     *         Empty list is valid (user has no weak spots yet).
     *         Exception in Result.failure only on I/O error.
     */
    suspend fun getWeakQuestions(userId: String, limit: Int = 20): Result<List<Question>>
    
    /**
     * Retrieves randomized questions for daily training.
     * 
     * Questions are selected randomly across all categories.
     * 
     * @param limit Number of questions to fetch (default 10)
     * @return Result containing randomly selected questions.
     *         Empty list is valid only if DB is empty.
     *         Exception in Result.failure only on I/O error.
     */
    suspend fun getDailyTrainingQuestions(limit: Int = 10): Result<List<Question>>
    
    /**
     * Saves a user's answer to persistent storage.
     * 
     * @param userAnswer The user answer to persist
     * @return Result.success if saved, Result.failure with exception on error
     */
    suspend fun saveUserAnswer(userAnswer: UserAnswer): Result<Unit>
    
    /**
     * Saves multiple answers in a single atomic transaction.
     * Used by exam mode to ensure all-or-nothing persistence.
     * 
     * @param answers List of user answers (typically 30 for exam)
     * @return Result.success if ALL saved, Result.failure if ANY failed.
     *         On failure, NO answers are persisted (automatic rollback).
     */
    suspend fun saveUserAnswerBatch(answers: List<UserAnswer>): Result<Unit>
    
    /**
     * Retrieves all saved answers for a specific user.
     * 
     * @param userId The user ID to fetch answers for
     * @return Result containing all user answers in chronological order.
     *         Empty list is valid (user has not answered any questions).
     *         Exception in Result.failure only on I/O error.
     */
    suspend fun getUserAnswerHistory(userId: String): Result<List<UserAnswer>>
    
    /**
     * Clears all in-memory cache (e.g., for refresh operations).
     * Does NOT clear persistent storage.
     * 
     * @return Result.success if cleared, Result.failure on error
     */
    suspend fun clearCache(): Result<Unit>
}
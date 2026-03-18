suspend fun getQuestions(
    category: QuestionCategory? = null,
    limit: Int = 20,
    offset: Int = 0
): Result<List<Question>>

// OR use a query object pattern:
data class QuestionQuery(
    val category: QuestionCategory? = null,
    val difficulty: DifficultyLevel? = null,
    val limit: Int = 20,
    val offset: Int = 0
)

suspend fun getQuestions(query: QuestionQuery): Result<List<Question>>
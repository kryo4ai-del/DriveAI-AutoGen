// ❌ Current
require(timestamp > 0) { "timestamp must be positive" }

// ✅ Better
require(timestamp > 0 && timestamp <= System.currentTimeMillis() + 1000) {
    "timestamp must be valid (not in future)"
}

// ---

// ❌ Current
suspend fun getWeakQuestions(userId: String): List<Question>

// ✅ Better
suspend fun getWeakQuestions(
    userId: String,
    threshold: Int = 3,  // min errors before "weak"
    limit: Int? = null   // pagination support
): List<Question>

// ---

// ❌ Current
require(answers.isNotEmpty()) { "answers list cannot be empty" }

// ✅ Better - allow nullable for DB queries
answers.takeIf { it.isNotEmpty() } ?: emptyList()

// ---

// ✅ Add to Question
companion object {
    fun createWithDefaults(
        id: String,
        text: String,
        category: QuestionCategory
    ) = Question(
        id = id,
        text = text,
        category = category,
        answers = emptyList(),  // Placeholder for lazy loading
        correctAnswerIndex = -1,  // Mark uninitialized
        explanation = ""
    )
}

// ---

// ❌ Current - crashes on DB failure
suspend fun getQuestions(): List<Question>

// ✅ Better - handles errors gracefully
suspend fun getQuestions(): Result<List<Question>>

// Or use Hilt success/failure tracking

// ---

// This will crash because UserAnswer has no userId field
val userAnswers = listOf(
    UserAnswer("Q1", 0, true, System.currentTimeMillis()),
    UserAnswer("Q1", 1, false, System.currentTimeMillis())
)
// Repository cannot distinguish which user gave which answer

// ---

// ❌ BROKEN: Allows timestamp far in future
require(timestamp > 0) { "timestamp must be positive" }

// This passes validation:
UserAnswer("Q1", 0, true, System.currentTimeMillis() + 365 * 24 * 60 * 60 * 1000L)  // 1 year future!

// ---

// ❌ BROKEN: Will load ALL questions into memory
suspend fun getQuestions(): List<Question>
suspend fun getQuestionsByCategory(category: QuestionCategory): List<Question>

// ---

// ❌ BROKEN: No error recovery
suspend fun getQuestions(): List<Question>  // Throws exception if DB unavailable

// Calling code will crash:
val questions = questionRepository.getQuestions()  // Uncaught exception = ANR

// ---

// ❌ Current validation only checks >= 0
require(selectedAnswerIndex >= 0) { "selectedAnswerIndex cannot be negative" }

// This passes, but if question has only 3 answers:
UserAnswer("Q1", 5, true, timestamp)  // selectedAnswerIndex = 5, out of bounds!
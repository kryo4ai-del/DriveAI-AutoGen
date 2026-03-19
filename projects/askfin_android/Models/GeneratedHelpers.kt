require(answers.count { it.isCorrect } >= 1) { "Question must have at least one correct answer" }

// ---

init {
    require(answers.isNotEmpty()) { "Question must have at least one answer" }
    require(answers.any { it.isCorrect }) { "Question must have at least one correct answer" }
    
    // Optional: if single-choice is a requirement
    // require(answers.count { it.isCorrect } == 1) { "Single-choice only: exactly one correct answer" }
    
    require(text.isNotBlank()) { "Question text cannot be blank" }
    if (timeLimit != null) {
        require(timeLimit > 0) { "Time limit must be positive" }
    }
}

// ---

require(selectedAnswerId.isNotBlank()) { "Selected answer ID cannot be blank" }

// ---

suspend fun getQuestionsByCategory(
    category: QuestionCategory,
    limit: Int = 10
): Result<List<Question>>

// ---

suspend fun getPerformanceStats(userId: String): Result<UserPerformanceStats>

// ---

fun getUserPerformanceStatsFlow(userId: String): Flow<Result<UserPerformanceStats>>

// ---

suspend fun getPerformanceStats(
    userId: String,
    since: Instant? = null,
    until: Instant? = null
): Result<UserPerformanceStats>

// ---

val trainingModes: Set<TrainingMode> = TrainingMode.entries.toSet()

// ---

kotlin {
    jvmToolchain(11)  // or verify version
}

// ---

val trainingModes: Set<TrainingMode> = TrainingMode.values().toSet()

// ---

fun getQuestionsByCategoryFlow(category: QuestionCategory): Flow<Result<List<Question>>>

// ---

/**
 * Stream questions by category. Emits Result with errors.
 * Consumers should implement retry logic via .retry {} or .retryWhen() if needed.
 */
fun getQuestionsByCategoryFlow(category: QuestionCategory): Flow<Result<List<Question>>>

// ---

val timestamp: Instant,

// ---

init {
    require(timestamp <= Instant.now()) { "Timestamp cannot be in the future" }
}

// ---

@Test
fun `Answer with blank id throws IllegalArgumentException`() {
    assertThrows<IllegalArgumentException> {
        Answer(id = "  ", text = "Valid", isCorrect = true)
    }
}

// ---

require(answers.count { it.isCorrect } >= 1) { "Question must have at least one correct answer" }

// ---

suspend fun getQuestionsByCategory(
    category: QuestionCategory,
    limit: Int = 10  // ← Hardcoded, no offset
): Result<List<Question>>

// ---

@Query("SELECT * FROM questions WHERE category = :category LIMIT :limit OFFSET :offset")
suspend fun getByCategory(category: String, limit: Int, offset: Int): List<QuestionEntity>

// ---

suspend fun getPerformanceStats(userId: String): Result<UserPerformanceStats>

// ---

suspend fun getPerformanceStats(
    userId: String,
    since: Instant? = null,
    until: Instant? = null
): Result<UserPerformanceStats>

// ---

val timestamp: Instant,  // ← Can be any value

// ---

val trainingModes: Set<TrainingMode> = TrainingMode.entries.toSet()

// ---

// build.gradle.kts
kotlin {
    jvmToolchain(17)  // or 11
}

// Check in code:
val trainingModes: Set<TrainingMode> = 
    if (KotlinVersion.CURRENT >= KotlinVersion(1, 9)) {
        TrainingMode.entries.toSet()
    } else {
        TrainingMode.values().toSet()  // Fallback
    }

// Or just use values() (works all versions):
val trainingModes: Set<TrainingMode> = TrainingMode.values().toSet()

// ---

val trainingModes: Set<TrainingMode> = TrainingMode.values().toSet()

// ---

fun getQuestionsByCategoryFlow(category: QuestionCategory): Flow<Result<List<Question>>>

// ---

/**
 * Stream questions by category.
 * 
 * Emits Result<List<Question>> with errors for network/DB failures.
 * 
 * Consumers MUST implement retry logic:
 *

// ---

inline fun <T> Flow<Result<T>>.withRetry(
    maxRetries: Int = 3,
    crossinline shouldRetry: (Throwable) -> Boolean = { it is IOException }
): Flow<Result<T>> = retryWhen { cause, _ ->
    shouldRetry(cause)
}.catch { emit(Result.failure(it)) }

// ---

// File: com.driveai.askfin/data/models/Pagination.kt
package com.driveai.askfin.data.models

import com.driveai.askfin.data.models.validators.ValidationRules

/**
 * Immutable pagination parameters for query operations.
 * Supports both limit-offset and page-based navigation.
 */
@JvmInline
value class Pagination(
    private val params: Pair<Int, Int> = 20 to 0  // limit to offset
) {
    val limit: Int get() = params.first
    val offset: Int get() = params.second
    
    init {
        require(limit > 0) { "Limit must be positive, got $limit" }
        require(offset >= 0) { "Offset cannot be negative, got $offset" }
    }
    
    /**
     * Advance to next page of results.
     */
    fun nextPage(): Pagination = Pagination(limit to (offset + limit))
    
    /**
     * Create pagination from page number (0-indexed).
     */
    companion object {
        fun page(pageSize: Int = 20, pageNumber: Int = 0): Pagination {
            require(pageSize > 0) { "Page size must be positive" }
            require(pageNumber >= 0) { "Page number cannot be negative" }
            return Pagination(pageSize to (pageNumber * pageSize))
        }
        
        fun default(limit: Int = 20): Pagination = Pagination(limit to 0)
    }
    
    override fun toString(): String = "Pagination(limit=$limit, offset=$offset)"
}

// ---

// Example: Auto-delete UserAnswer older than 1 year (business requirement)
   @Query("DELETE FROM user_answers WHERE timestamp < :cutoffDate")
   suspend fun deleteOldAnswers(cutoffDate: Instant): Int

// ---

// UserProgressRepository interface addition:
   suspend fun deleteUserData(userId: String): Result<Unit>
   // Implementation cascades deletes across UserAnswer, preferences, etc.

// ---

// UserProgressRepository.clearUserProgress() — must persist to database
   suspend fun deleteUserData(userId: String): Result<Unit>
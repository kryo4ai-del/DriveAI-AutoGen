package com.driveai.askfin.data.models

import java.time.Instant
import androidx.room.Query
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.retryWhen
import kotlinx.coroutines.flow.catch
import java.io.IOException
import kotlin.test.Test
import kotlin.test.assertThrows

// Placeholder types for undefined references
enum class QuestionCategory
enum class TrainingMode
data class Question(val id: String = "", val text: String = "", val category: QuestionCategory = QuestionCategory.values().first(), val answers: List<Answer> = emptyList(), val timeLimit: Int? = null)
data class Answer(val id: String, val text: String, val isCorrect: Boolean) {
    init {
        require(id.isNotBlank()) { "Answer ID cannot be blank" }
    }
}
data class UserPerformanceStats(val userId: String = "", val timestamp: Instant = Instant.now())
data class UserAnswer(val userId: String = "", val answerId: String = "", val timestamp: Instant = Instant.now())
sealed class Result<T> {
    data class Success<T>(val data: T) : Result<T>()
    data class Failure<T>(val error: Throwable) : Result<T>()
    companion object {
        fun <T> success(data: T): Result<T> = Success(data)
        fun <T> failure(error: Throwable): Result<T> = Failure(error)
    }
}

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

class QuestionValidator {
    fun validateQuestion(answers: List<Answer>, text: String, timeLimit: Int? = null) {
        require(answers.count { it.isCorrect } >= 1) { "Question must have at least one correct answer" }
        require(answers.isNotEmpty()) { "Question must have at least one answer" }
        require(answers.any { it.isCorrect }) { "Question must have at least one correct answer" }
        require(text.isNotBlank()) { "Question text cannot be blank" }
        if (timeLimit != null) {
            require(timeLimit > 0) { "Time limit must be positive" }
        }
    }
}

class AnswerValidator {
    fun validateAnswer(selectedAnswerId: String) {
        require(selectedAnswerId.isNotBlank()) { "Selected answer ID cannot be blank" }
    }
}

interface QuestionRepository {
    suspend fun getQuestionsByCategory(
        category: QuestionCategory,
        limit: Int = 10
    ): Result<List<Question>>

    suspend fun getPerformanceStats(userId: String): Result<UserPerformanceStats>

    fun getUserPerformanceStatsFlow(userId: String): Flow<Result<UserPerformanceStats>>

    suspend fun getPerformanceStats(
        userId: String,
        since: Instant? = null,
        until: Instant? = null
    ): Result<UserPerformanceStats>

    fun getQuestionsByCategoryFlow(category: QuestionCategory): Flow<Result<List<Question>>>
}

interface UserProgressRepository {
    suspend fun deleteUserData(userId: String): Result<Unit>
}

class UserProgressValidator {
    fun validateTimestamp(timestamp: Instant) {
        require(timestamp <= Instant.now()) { "Timestamp cannot be in the future" }
    }
}

class AnswerTests {
    @Test
    fun `Answer with blank id throws IllegalArgumentException`() {
        assertThrows<IllegalArgumentException> {
            Answer(id = "  ", text = "Valid", isCorrect = true)
        }
    }
}

object TrainingModeHelper {
    val trainingModes: Set<TrainingMode> = TrainingMode.values().toSet()
}

inline fun <T> Flow<Result<T>>.withRetry(
    maxRetries: Int = 3,
    crossinline shouldRetry: (Throwable) -> Boolean = { it is IOException }
): Flow<Result<T>> = retryWhen { cause, _ ->
    shouldRetry(cause)
}.catch { emit(Result.failure(it)) }
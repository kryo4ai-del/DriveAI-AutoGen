package com.driveai.askfin.data.repository

import kotlinx.coroutines.flow.Flow

/**
 * Placeholder data classes for exam domain models.
 */
data class Question(val id: String, val text: String)
data class Answer(val questionId: String, val selectedOption: String)
data class ExamSession(val id: String, val questions: List<Question>, val answers: List<Answer> = emptyList())
data class ExamResult(val sessionId: String, val score: Int, val total: Int)

/**
 * Repository interface for exam operations.
 * Implementations handle persistence (local/remote) and business logic.
 */
interface ExamRepository {
    
    /**
     * Initialize and start a new exam session.
     * @param questions List of questions for this exam
     * @param durationMs Exam duration in milliseconds
     * @return Result containing created ExamSession
     */
    suspend fun startExam(
        questions: List<Question>,
        durationMs: Long
    ): Result<ExamSession>
    
    /**
     * Record a user's answer to a question.
     * @param sessionId Active exam session ID
     * @param questionId Question being answered
     * @param answer User's selected answer
     * @return Result containing updated ExamSession
     */
    suspend fun submitAnswer(
        sessionId: String,
        questionId: String,
        answer: Answer
    ): Result<ExamSession>
    
    /**
     * Mark exam as complete and calculate results.
     * @param sessionId Active exam session ID
     * @return Result containing ExamResult with scoring
     */
    suspend fun completeExam(sessionId: String): Result<ExamResult>
    
    /**
     * Retrieve past exam sessions and results.
     * @param limit Maximum number of results
     * @param offset Pagination offset
     * @return Flow of exam history (supports reactive updates)
     */
    fun getExamHistory(limit: Int = 10, offset: Int = 0): Flow<Result<List<ExamResult>>>
}
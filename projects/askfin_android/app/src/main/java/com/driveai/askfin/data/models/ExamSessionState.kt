package com.driveai.askfin.data.models

import com.driveai.askfin.data.repository.QuestionRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.time.Instant
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

data class ExamSessionState(
    val sessionId: String = UUID.randomUUID().toString(),
    val questions: List<QuestionData> = emptyList(),
    val currentQuestionIndex: Int = 0,
    val answers: Map<String, String?> = emptyMap(), // questionId -> selectedAnswer (null = unanswered)
    val startTime: Instant = Instant.now(),
    val status: ExamStatus = ExamStatus.INITIALIZED,
    val timeRemainingSeconds: Long = 1800L // 30 minutes
)

enum class ExamStatus {
    INITIALIZED, IN_PROGRESS, PAUSED, SUBMITTED, COMPLETED
}

data class CategoryScoreData(
    val category: String,
    val correctAnswers: Int,
    val totalQuestions: Int,
    val unansweredCount: Int = 0
) {
    val incorrectCount: Int
        get() = totalQuestions - correctAnswers - unansweredCount

    val scorePercentage: Float
        get() = if (totalQuestions > 0) (correctAnswers.toFloat() / totalQuestions) * 100f else 0f

    val answerRatePercentage: Float
        get() = if (totalQuestions > 0) {
            ((totalQuestions - unansweredCount).toFloat() / totalQuestions) * 100f
        } else 0f
}

data class QuestionData(
    val id: String = "",
    val category: String = "",
    val correctAnswer: String = ""
)

data class ExamResultData(
    val sessionId: String = "",
    val totalQuestions: Int = 0,
    val correctAnswers: Int = 0,
    val scorePercentage: Float = 0f,
    val categoryBreakdown: List<CategoryScoreData> = emptyList(),
    val timeSpentSeconds: Long = 0L,
    val completedAt: Instant = Instant.now(),
    val unansweredCount: Int = 0
)

data class Result<T>(
    val data: T? = null,
    val exception: Throwable? = null
) {
    val isSuccess: Boolean get() = exception == null
}

enum class QuestionCategory {
    GENERAL
}

/**
 * Manages exam lifecycle: initialization, question navigation, answer tracking, and submission.
 * 
 * Responsibilities:
 * - Load 30 random questions distributed across all categories
 * - Track user answers with nullability distinction (unanswered vs wrong)
 * - Provide score calculation with category breakdown
 * - Integrate with ExamTimerService for time tracking
 */
@Singleton
class ExamSessionManager @Inject constructor(
    private val questionRepository: QuestionRepository
) {
    private val _examState = MutableStateFlow(ExamSessionState())
    val examState: StateFlow<ExamSessionState> = _examState.asStateFlow()

    /**
     * Initialize a 30-question exam with questions distributed across categories.
     * 
     * @throws IllegalArgumentException if no categories exist or insufficient questions
     */
    suspend fun initializeExam(): Result<Unit> = try {
        val allCategories = questionRepository.getAllCategories()
        require(allCategories.isNotEmpty()) { "No exam categories available" }

        val questionsPerCategory = 30 / allCategories.size
        val remainder = 30 % allCategories.size
        val selectedQuestions = mutableListOf<QuestionData>()

        allCategories.forEachIndexed { index: Int, category: QuestionCategory ->
            val count = questionsPerCategory + if (index < remainder) 1 else 0
            val categoryQuestions = questionRepository.getQuestionsByCategory(
                category = category,
                limit = count
            )
            require(categoryQuestions.isNotEmpty()) {
                "Category '${category}' has no questions"
            }
            selectedQuestions.addAll(categoryQuestions.shuffled())
        }

        require(selectedQuestions.size >= 30) {
            "Insufficient questions: ${selectedQuestions.size} < 30"
        }

        _examState.value = ExamSessionState(
            questions = selectedQuestions.shuffled().take(30),
            status = ExamStatus.IN_PROGRESS,
            startTime = Instant.now()
        )
        Result(Unit)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    /**
     * Navigate to the next question if available.
     */
    fun nextQuestion(): Result<Unit> = try {
        val currentState = _examState.value
        if (currentState.currentQuestionIndex < currentState.questions.size - 1) {
            _examState.value = currentState.copy(
                currentQuestionIndex = currentState.currentQuestionIndex + 1
            )
        }
        Result(Unit)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    /**
     * Navigate to the previous question if available.
     */
    fun previousQuestion(): Result<Unit> = try {
        val currentState = _examState.value
        if (currentState.currentQuestionIndex > 0) {
            _examState.value = currentState.copy(
                currentQuestionIndex = currentState.currentQuestionIndex - 1
            )
        }
        Result(Unit)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    /**
     * Jump to a specific question by index.
     * 
     * @throws IllegalArgumentException if index is out of bounds
     */
    fun jumpToQuestion(index: Int): Result<Unit> = try {
        val currentState = _examState.value
        require(index in currentState.questions.indices) {
            "Invalid question index: $index (total: ${currentState.questions.size})"
        }
        _examState.value = currentState.copy(currentQuestionIndex = index)
        Result(Unit)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    /**
     * Record an answer for a specific question.
     */
    fun selectAnswer(questionId: String, selectedAnswer: String?): Result<Unit> = try {
        val currentState = _examState.value
        _examState.value = currentState.copy(
            answers = currentState.answers.toMutableMap().apply {
                put(questionId, selectedAnswer)
            }
        )
        Result(Unit)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    /**
     * Clear the answer for a specific question (mark as unanswered).
     */
    fun clearAnswer(questionId: String): Result<Unit> = try {
        val currentState = _examState.value
        _examState.value = currentState.copy(
            answers = currentState.answers.toMutableMap().apply {
                put(questionId, null)
            }
        )
        Result(Unit)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    /**
     * Pause the exam without losing state.
     */
    fun pauseExam(): Result<Unit> = try {
        _examState.value = _examState.value.copy(status = ExamStatus.PAUSED)
        Result(Unit)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    /**
     * Resume the exam from paused state.
     */
    fun resumeExam(): Result<Unit> = try {
        require(_examState.value.status == ExamStatus.PAUSED) {
            "Cannot resume exam in status: ${_examState.value.status}"
        }
        _examState.value = _examState.value.copy(status = ExamStatus.IN_PROGRESS)
        Result(Unit)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    /**
     * Submit exam and calculate results with category breakdown.
     * Distinguishes between unanswered and incorrect answers.
     * 
     * @return ExamResult with scores and category breakdown
     * @throws IllegalStateException if exam not in progress or paused
     */
    fun submitExam(): Result<ExamResultData> = try {
        val currentState = _examState.value
        require(currentState.status == ExamStatus.IN_PROGRESS || currentState.status == ExamStatus.PAUSED) {
            "Cannot submit exam in status: ${currentState.status}"
        }

        val endTime = Instant.now()
        val totalTimeSeconds = endTime.epochSecond - currentState.startTime.epochSecond

        val categoryScores = mutableMapOf<String, CategoryScoreData>()
        var totalCorrect = 0
        var totalUnanswered = 0

        currentState.questions.forEach { question ->
            val selectedAnswer = currentState.answers[question.id]
            val isCorrect = selectedAnswer != null && selectedAnswer == question.correctAnswer
            val isUnanswered = selectedAnswer == null

            if (isCorrect) totalCorrect++
            if (isUnanswered) totalUnanswered++

            categoryScores.putIfAbsent(question.category, CategoryScoreData(question.category, 0, 0))
            val categoryScore = categoryScores[question.category]!!

            categoryScores[question.category] = categoryScore.copy(
                correctAnswers = if (isCorrect) categoryScore.correctAnswers + 1 else categoryScore.correctAnswers,
                totalQuestions = categoryScore.totalQuestions + 1,
                unansweredCount = if (isUnanswered) categoryScore.unansweredCount + 1 else categoryScore.unansweredCount
            )
        }

        val scorePercentage = (totalCorrect.toFloat() / currentState.questions.size) * 100f

        val examResult = ExamResultData(
            sessionId = currentState.sessionId,
            totalQuestions = currentState.questions.size,
            correctAnswers = totalCorrect,
            scorePercentage = scorePercentage,
            categoryBreakdown = categoryScores.values.toList(),
            timeSpentSeconds = totalTimeSeconds,
            completedAt = endTime,
            unansweredCount = totalUnanswered
        )

        _examState.value = currentState.copy(status = ExamStatus.COMPLETED)

        Result(examResult)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    fun getCurrentQuestion(): QuestionData? {
        val currentState = _examState.value
        return currentState.questions.getOrNull(currentState.currentQuestionIndex)
    }

    fun getAnswerForQuestion(questionId: String): String? =
        _examState.value.answers[questionId]

    fun getAnswers(): Map<String, String?> =
        _examState.value.answers.toMap()

    fun resetExam(): Result<Unit> = try {
        _examState.value = ExamSessionState()
        Result(Unit)
    } catch (e: Throwable) {
        Result(exception = e)
    }

    /**
     * Called by ExamTimerService to sync time state.
     * @internal
     */
    internal fun updateTimeRemaining(secondsRemaining: Long) {
        _examState.value = _examState.value.copy(timeRemainingSeconds = secondsRemaining)
    }

    fun isTimeExpired(): Boolean = _examState.value.timeRemainingSeconds <= 0
}
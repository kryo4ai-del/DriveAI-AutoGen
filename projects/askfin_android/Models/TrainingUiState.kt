package com.driveai.askfin.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.driveai.askfin.domain.models.Question
import com.driveai.askfin.domain.models.TrainingSession
import com.driveai.askfin.domain.models.Answer
import com.driveai.askfin.domain.models.SessionState
import com.driveai.askfin.domain.services.ITrainingSessionService
import com.driveai.askfin.domain.services.IQuestionService
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class TrainingUiState(
    val isLoading: Boolean = false,
    val currentQuestion: Question? = null,
    val questionsRemaining: Int = 0,
    val totalQuestions: Int = 0,
    val currentIndex: Int = 0,
    val sessionState: SessionState = SessionState.NOT_STARTED,
    val userAnswer: Answer? = null,
    val isAnswered: Boolean = false,
    val feedback: String? = null,
    val score: Int = 0,
    val errorMessage: String? = null
)

/**
 * ViewModel for managing training session state and operations.
 *
 * Responsibilities:
 * - Initialize and manage training sessions
 * - Handle answer submission with validation
 * - Track progress and scoring
 * - Manage session lifecycle (pause, resume, abandon)
 * - Persist session data via service layer
 */
@HiltViewModel
    private val questionService: IQuestionService
) : ViewModel() {

    private val _uiState = MutableStateFlow(TrainingUiState())
    val uiState: StateFlow<TrainingUiState> = _uiState.asStateFlow()

    private val _sessionId = MutableStateFlow<String?>(null)
    val sessionId: StateFlow<String?> = _sessionId.asStateFlow()

    private val _navigateToResults = MutableStateFlow(false)
    val navigateToResults: StateFlow<Boolean> = _navigateToResults.asStateFlow()

    private var currentSession: TrainingSession? = null
    private var allQuestions: List<Question> = emptyList()
    private var questionStartTime = 0L

    /**
     * Initialize training session with specified category and difficulty.
     *
     * @param categoryId Identifier of question category
     * @param difficulty Optional difficulty filter (EASY, MEDIUM, HARD)
     * @param limitQuestions Maximum questions to load (default 10)
     */
    fun initializeSession(
        categoryId: String,
        difficulty: String? = null,
        limitQuestions: Int = 10
    ) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            
            try {
                // Load questions for category
                allQuestions = questionService.getQuestionsByCategory(
                    categoryId = categoryId,
                    difficulty = difficulty,
                    limit = limitQuestions
                )

                if (allQuestions.isEmpty()) {
                    _uiState.value = _uiState.value.copy(
                        isLoading = false,
                        errorMessage = "No questions available for this category"
                    )
                    return@launch
                }

                // Create new training session
                currentSession = trainingSessionService.createSession(
                    categoryId = categoryId,
                    questionCount = allQuestions.size
                )
                _sessionId.value = currentSession?.id

                // Initialize first question
                questionStartTime = System.currentTimeMillis()
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    sessionState = SessionState.IN_PROGRESS,
                    totalQuestions = allQuestions.size,
                    questionsRemaining = allQuestions.size,
                    currentIndex = 0,
                    currentQuestion = allQuestions.firstOrNull(),
                    userAnswer = null,
                    isAnswered = false,
                    feedback = null,
                    score = 0
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = e.localizedMessage ?: "Failed to initialize session"
                )
            }
        }
    }

    /**
     * Submit user answer for current question with validation and duplicate-submit protection.
     *
     * Guards against:
     * - Double-submit via rapid taps
     * - Invalid option indices
     * - Answer submission when session inactive
     *
     * @param answerText Full text of answer (if applicable)
     * @param selectedOptionIndex 0-based index of selected option
     */
    fun submitAnswer(answerText: String, selectedOptionIndex: Int) {
        // GUARD: Prevent double-submit synchronously (no race window)
        val currentState = _uiState.value
        if (currentState.isAnswered || currentState.sessionState != SessionState.IN_PROGRESS) {
            return
        }

        val currentQuestion = currentState.currentQuestion
        if (currentQuestion == null) {
            _uiState.value = currentState.copy(
                errorMessage = "No question available"
            )
            return
        }

        // GUARD: Validate option index
        if (selectedOptionIndex !in currentQuestion.options.indices) {
            _uiState.value = currentState.copy(
                errorMessage = "Invalid option selected"
            )
            return
        }

        // Optimistic UI update: disable submit button immediately
        _uiState.value = currentState.copy(isAnswered = true)

        viewModelScope.launch {
            try {
                val timeSpentMs = System.currentTimeMillis() - questionStartTime
                val isCorrect = currentQuestion.correctAnswerIndex == selectedOptionIndex

                val answer = Answer(
                    questionId = currentQuestion.id,
                    selectedOptionIndex = selectedOptionIndex,
                    answerText = answerText,
                    isCorrect = isCorrect,
                    timeSpentMs = timeSpentMs
                )

                // Persist answer
                trainingSessionService.recordAnswer(currentSession!!.id, answer)

                // Generate feedback
                val feedback = if (isCorrect) {
                    "Correct! ${currentQuestion.explanation}"
                } else {
                    "Incorrect. ${currentQuestion.explanation}"
                }

                val newScore = _uiState.value.score + if (isCorrect) 1 else 0

                _uiState.value = _uiState.value.copy(
                    userAnswer = answer,
                    feedback = feedback,
                    score = newScore
                )
            } catch (e: Exception) {
                // Restore submit button on error
                _uiState.value = _uiState.value.copy(
                    isAnswered = false,
                    errorMessage = e.localizedMessage ?: "Failed to submit answer"
                )
            }
        }
    }

    /**
     * Move to next question in session.
     * Automatically completes session if no more questions.
     */
    fun nextQuestion() {
        val session = currentSession ?: run {
            _uiState.value = _uiState.value.copy(
                errorMessage = "Session lost; please restart"
            )
            return
        }

        viewModelScope.launch {
            try {
                val nextIndex = _uiState.value.currentIndex + 1
                val totalQuestions = _uiState.value.totalQuestions

                if (nextIndex >= totalQuestions) {
                    completeSessionFlow(session)
                } else {
                    loadNextQuestion(session, nextIndex)
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    errorMessage = e.localizedMessage ?: "Failed to load next question"
                )
            }
        }
    }

    /**
     * Load and display next question.
     * Resets timer and answer state.
     */
    private suspend fun loadNextQuestion(session: TrainingSession, nextIndex: Int) {
        val nextQuestion = allQuestions.getOrNull(nextIndex)
            ?: run {
                _uiState.value = _uiState.value.copy(
                    errorMessage = "Question not found"
                )
                return
            }

        questionStartTime = System.currentTimeMillis()
        _uiState.value = _uiState.value.copy(
            currentIndex = nextIndex,
            currentQuestion = nextQuestion,
            questionsRemaining = _uiState.value.totalQuestions - nextIndex,
            userAnswer = null,
            isAnswered = false,
            feedback = null
        )
    }

    /**
     * Complete training session.
     * Single coroutine path (no nesting) to avoid scope leaks.
     */
    private suspend fun completeSessionFlow(session: TrainingSession) {
        try {
            trainingSessionService.completeSession(session.id)

            _uiState.value = _uiState.value.copy(
                sessionState = SessionState.COMPLETED,
                currentQuestion = null
            )

            _navigateToResults.value = true
        } catch (e: Exception) {
            _uiState.value = _uiState.value.copy(
                errorMessage = e.localizedMessage ?: "Failed to complete session"
            )
        }
    }

    /**
     * Skip current question without answering.
     * Records skip in session data.
     */
    fun skipQuestion() {
        val session = currentSession ?: return
        val currentQuestion = _uiState.value.currentQuestion ?: return

        viewModelScope.launch {
            try {
                trainingSessionService.recordSkip(session.id, currentQuestion.id)
                nextQuestion()
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    errorMessage = e.localizedMessage ?: "Failed to skip question"
                )
            }
        }
    }

    /**
     * Pause training session.
     * Allows resumption later with progress intact.
     */
    fun pauseSession() {
        val session = currentSession ?: return

        viewModelScope.launch {
            try {
                trainingSessionService.pauseSession(session.id)

                _uiState.value = _uiState.value.copy(
                    sessionState = SessionState.PAUSED
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    errorMessage = e.localizedMessage ?: "Failed to pause session"
                )
            }
        }
    }

    /**
     * Resume paused training session.
     */
    fun resumeSession() {
        val session = currentSession ?: return

        viewModelScope.launch {
            try {
                trainingSessionService.resumeSession(session.id)

                _uiState.value = _uiState.value.copy(
                    sessionState = SessionState.IN_PROGRESS
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    errorMessage = e.localizedMessage ?: "Failed to resume session"
                )
            }
        }
    }

    /**
     * Abandon session without saving progress.
     * Clears all session state.
     */
    fun abandonSession() {
        val session = currentSession ?: return

        viewModelScope.launch {
            try {
                trainingSessionService.abandonSession(session.id)

                _uiState.value = TrainingUiState()
                _sessionId.value = null
                currentSession = null
                allQuestions = emptyList()
                questionStartTime = 0L
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    errorMessage = e.localizedMessage ?: "Failed to abandon session"
                )
            }
        }
    }

    /**
     * Clear error message from UI state.
     */
    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }

    /**
     * Clear navigation flag after handling.
     */
    fun clearNavigateToResults() {
        _navigateToResults.value = false
    }

    /**
     * Auto-pause session on ViewModel destruction.
     * Preserves progress if user navigates away unexpectedly.
     */
    override fun onCleared() {
        super.onCleared()
        currentSession?.let { session ->
            viewModelScope.launch {
                try {
                    if (_uiState.value.sessionState == SessionState.IN_PROGRESS) {
                        trainingSessionService.pauseSession(session.id)
                    }
                } catch (e: Exception) {
                    // Silent failure acceptable on cleanup
                }
            }
        }
    }
}
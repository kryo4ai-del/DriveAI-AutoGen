package com.driveai.askfin.ui.viewmodels

// TrainingModeViewModel.kt - ENHANCED

@HiltViewModel
class TrainingModeViewModel @Inject constructor(
    private val getTrainingQuestionsUseCase: GetTrainingQuestionsUseCase,
) : ViewModel() {

    private val _uiState = MutableStateFlow<TrainingModeUiState>(TrainingModeUiState.Loading)
    val uiState: StateFlow<TrainingModeUiState> = _uiState.asStateFlow()

    private val _selectedAnswerId = MutableStateFlow<String?>(null)
    val selectedAnswerId: StateFlow<String?> = _selectedAnswerId.asStateFlow()

    private val _isAnswerRevealed = MutableStateFlow(false)
    val isAnswerRevealed: StateFlow<Boolean> = _isAnswerRevealed.asStateFlow()

    // Track correct answers per question
    private val _userAnswers = mutableMapOf<Int, String>() // questionIndex -> answerId

    init {
        loadTrainingQuestions()
    }

    private fun loadTrainingQuestions() {
        viewModelScope.launch {
            try {
                val questions = getTrainingQuestionsUseCase()
                
                // Guard: empty questions
                if (questions.isEmpty()) {
                    _uiState.value = TrainingModeUiState.Error(
                        message = "No questions available for training"
                    )
                    return@launch
                }
                
                _uiState.value = TrainingModeUiState.Ready(
                    questions = questions,
                    currentIndex = 0,
                    progress = 0f,
                )
            } catch (e: Exception) {
                _uiState.value = TrainingModeUiState.Error(
                    message = "Failed to load questions: ${e.localizedMessage}",
                    throwable = e,
                )
            }
        }
    }

    fun selectAnswer(answerId: String) {
        if (_isAnswerRevealed.value) return // Prevent changing after reveal
        _selectedAnswerId.value = answerId
    }

    fun revealAnswer() {
        val currentState = _uiState.value
        if (currentState is TrainingModeUiState.Ready) {
            val currentQuestion = currentState.questions[currentState.currentIndex]
            
            // Save user's answer
            _selectedAnswerId.value?.let { answerId ->
                _userAnswers[currentState.currentIndex] = answerId
            }
            
            _isAnswerRevealed.value = true
        }
    }

    fun nextQuestion() {
        val currentState = _uiState.value
        if (currentState !is TrainingModeUiState.Ready) return

        val nextIndex = currentState.currentIndex + 1
        
        if (nextIndex >= currentState.questions.size) {
            // Training complete
            val score = calculateScore(currentState)
            _uiState.value = TrainingModeUiState.Complete(
                score = score,
                totalQuestions = currentState.questions.size,
            )
        } else {
            // Next question
            _uiState.value = currentState.copy(
                currentIndex = nextIndex,
                selectedAnswerId = null,
                isAnswerRevealed = false,
                progress = (nextIndex.toFloat() / currentState.questions.size),
            )
            _selectedAnswerId.value = null
            _isAnswerRevealed.value = false
        }
    }

    fun retry() {
        _userAnswers.clear()
        loadTrainingQuestions()
    }

    // ✅ PROPER SCORE CALCULATION
    private fun calculateScore(state: TrainingModeUiState.Ready): Int {
        return _userAnswers.count { (questionIndex, answerId) ->
            val question = state.questions.getOrNull(questionIndex) ?: return@count false
            val selectedAnswer = question.answers.find { it.id == answerId }
            selectedAnswer?.isCorrect == true
        }
    }
}
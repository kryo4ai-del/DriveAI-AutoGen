package com.driveai.askfin.ui.viewmodels
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.delay

// com.driveai.askfin.ui.viewmodels.ExamSimulationViewModel.kt
@HiltViewModel
class ExamSimulationViewModel @Inject constructor(
    private val examRepository: ExamRepository
) : ViewModel() {
    
    data class ExamSimulationUIState(
        val currentQuestion: Question? = null,
        val questionNumber: Int = 0,
        val totalQuestions: Int = 30,
        val timeRemaining: Int = 2700,
        val selectedAnswerIndex: Int? = null,
        val isAnswerCorrect: Boolean = false,
        val isExamComplete: Boolean = false,
        val score: Int = 0,
        val categoryScores: Map<String, Int> = emptyMap()
    )
    
    private val _uiState = MutableStateFlow(ExamSimulationUIState())
    val uiState: StateFlow<ExamSimulationUIState> = _uiState.asStateFlow()
    
    private var isExamActive = false
    
    fun startExam() {
        viewModelScope.launch {
            isExamActive = true
            _uiState.value = _uiState.value.copy(questionNumber = 1)
            loadQuestion(1)
            startTimer()
        }
    }
    
    fun selectAnswer(index: Int) {
        val question = _uiState.value.currentQuestion ?: return
        val isCorrect = index == question.correctAnswerIndex
        _uiState.value = _uiState.value.copy(
            selectedAnswerIndex = index,
            isAnswerCorrect = isCorrect
        )
        if (isCorrect) updateScore(question.points)
    }
    
    fun nextQuestion() {
        viewModelScope.launch {
            val next = _uiState.value.questionNumber + 1
            _uiState.value = _uiState.value.copy(
                selectedAnswerIndex = null,
                isAnswerCorrect = false,
                questionNumber = next
            )
            if (next <= 30) loadQuestion(next)
        }
    }
    
    fun completeExam() {
        isExamActive = false
        _uiState.value = _uiState.value.copy(isExamComplete = true)
        // Save results to database
        viewModelScope.launch {
            examRepository.saveExamResult(
                score = _uiState.value.score,
                categoryScores = _uiState.value.categoryScores
            )
        }
    }
    
    fun exitExam() {
        isExamActive = false
        _uiState.value = _uiState.value.copy(isExamComplete = false) // Reset
    }
    
    private fun startTimer() {
        var remaining = 2700
        viewModelScope.launch {
            while (remaining > 0 && isExamActive) {
                delay(1000L)
                remaining -= 1
                _uiState.value = _uiState.value.copy(timeRemaining = remaining)
                if (remaining == 0) autoSubmit()
            }
        }
    }
    
    private fun loadQuestion(number: Int) {
        viewModelScope.launch {
            val question = examRepository.getQuestion(number)
            _uiState.value = _uiState.value.copy(currentQuestion = question)
        }
    }
    
    private fun updateScore(points: Int) {
        _uiState.value = _uiState.value.copy(
            score = _uiState.value.score + points
        )
    }
    
    private fun autoSubmit() {
        completeExam()
    }
}
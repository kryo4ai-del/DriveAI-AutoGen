package com.driveai.askfin.ui.viewmodels

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.driveai.askfin.data.models.ExamResult
import com.driveai.askfin.data.models.CategoryBreakdown
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

// Placeholder for ExamRepository
interface ExamRepository {
    suspend fun getExamResult(examId: String): ExamResult
    suspend fun getCategoryBreakdown(examId: String): List<CategoryBreakdown>
    suspend fun createTrainingSession(examId: String, focusCategory: String): String
    suspend fun resetExam(examId: String): String
}

// Placeholder for GapAnalysisUseCase
class GapAnalysisUseCase @Inject constructor() {
    suspend fun analyzeWeaknesses(result: ExamResult, categoryBreakdowns: List<CategoryBreakdown>): List<String> {
        return emptyList()
    }
}

/**
 * Manages exam result display, category breakdown, weakness analysis.
 * Provides navigation to training sessions.
 */
sealed class ExamResultState {
    data object Loading : ExamResultState()
    data class Success(
        val result: ExamResult,
        val categoryBreakdowns: List<CategoryBreakdown>,
        val weaknessCategories: List<String>
    ) : ExamResultState()
    // FIX #5: Navigation signal for training
    data class NavigatingToTraining(val sessionId: String) : ExamResultState()
    // FIX #6: Explicit retake navigation
    data class ReadyToRetake(val newExamId: String) : ExamResultState()
    data class Error(val message: String, val retryable: Boolean = true) : ExamResultState()
}

@HiltViewModel
class ExamResultViewModel @Inject constructor(
    private val examRepository: ExamRepository,
    private val gapAnalysisUseCase: GapAnalysisUseCase,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    // FIX #3: Nullable with guard clause
    private val examId: String? = savedStateHandle.get<String>("examId")

    private val _state = MutableStateFlow<ExamResultState>(ExamResultState.Loading)
    val state: StateFlow<ExamResultState> = _state.asStateFlow()

    init {
        if (examId == null) {
            _state.value = ExamResultState.Error(
                "Missing exam ID. Please restart.",
                retryable = false
            )
        } else {
            loadResult()
        }
    }

    private fun loadResult() {
        val id = examId ?: return

        viewModelScope.launch {
            try {
                val result = examRepository.getExamResult(id)
                val categoryBreakdowns = examRepository.getCategoryBreakdown(id)
                val weaknessCategories = gapAnalysisUseCase.analyzeWeaknesses(
                    result = result,
                    categoryBreakdowns = categoryBreakdowns
                )

                _state.update {
                    ExamResultState.Success(
                        result = result,
                        categoryBreakdowns = categoryBreakdowns,
                        weaknessCategories = weaknessCategories
                    )
                }
            } catch (e: Exception) {
                _state.update {
                    ExamResultState.Error(
                        message = e.message ?: "Failed to load exam result",
                        retryable = true
                    )
                }
            }
        }
    }

    /**
     * FIX #5: Emit navigation signal when training session is created.
     */
    fun navigateToWeaknessTraining(categoryId: String) {
        val id = examId ?: run {
            _state.update {
                ExamResultState.Error("Exam ID lost", retryable = false)
            }
            return
        }

        viewModelScope.launch {
            try {
                val sessionId = examRepository.createTrainingSession(
                    examId = id,
                    focusCategory = categoryId
                )
                _state.update {
                    ExamResultState.NavigatingToTraining(sessionId)
                }
            } catch (e: Exception) {
                _state.update {
                    ExamResultState.Error(
                        message = e.message ?: "Failed to create training session",
                        retryable = true
                    )
                }
            }
        }
    }

    /**
     * FIX #6: Reset exam and emit retake signal (don't reload result).
     */
    fun retakeExam() {
        val id = examId ?: run {
            _state.update {
                ExamResultState.Error("Exam ID lost", retryable = false)
            }
            return
        }

        viewModelScope.launch {
            try {
                val newExamId = examRepository.resetExam(id)
                _state.update {
                    ExamResultState.ReadyToRetake(newExamId)
                }
            } catch (e: Exception) {
                _state.update {
                    ExamResultState.Error(
                        message = e.message ?: "Failed to reset exam",
                        retryable = true
                    )
                }
            }
        }
    }

    fun retryLoadResult() {
        if (_state.value is ExamResultState.Error) {
            loadResult()
        }
    }
}
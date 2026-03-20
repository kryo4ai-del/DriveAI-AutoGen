package com.driveai.askfin.ui.viewmodels
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import androidx.lifecycle.ViewModel
import androidx.lifecycle.SavedStateHandle
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.Job
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch

interface ExamRepository {
    suspend fun getExamById(id: String): Any
}

interface TimerUseCase

sealed class ExamState {
    object Loading : ExamState()
    data class Error(val message: String) : ExamState()
}

@HiltViewModel
class ExamViewModel @Inject constructor(
    private val examRepository: ExamRepository,
    private val timerUseCase: TimerUseCase,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val examId: String? = savedStateHandle.get<String>("examId")

    private val _state = MutableStateFlow<ExamState>(ExamState.Loading)
    val state: StateFlow<ExamState> = _state.asStateFlow()

    private var timerJob: Job? = null

    init {
        if (examId == null) {
            _state.value = ExamState.Error(
                "Missing exam ID. Please navigate from exam list."
            )
        } else {
            loadExam()
        }
    }

    private fun loadExam() {
        val id = examId ?: return  // Guard clause
        viewModelScope.launch {
            try {
                val exam = examRepository.getExamById(id)
                // ...
            } catch (e: Exception) { }
        }
    }

    fun submitExam() {
        val id = examId ?: run {
            _state.update { ExamState.Error("Exam ID lost") }
            return
        }
        // ...
    }
}
package com.driveai.askfin.ui.viewmodels
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import androidx.lifecycle.ViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.launch

interface ReadinessRepository

interface TrainingSessionService

interface ExamScheduleService {
    suspend fun getExamDate(): Long?
}

@HiltViewModel
class ReadinessViewModel @Inject constructor(
    private val readinessRepository: ReadinessRepository,
    private val trainingSessionService: TrainingSessionService,
    private val examScheduleService: ExamScheduleService
) : ViewModel() {

    private val _nextReviewReminder = MutableStateFlow<Long?>(null)
    val nextReviewReminder: StateFlow<Long?> = _nextReviewReminder.asStateFlow()

    init {
        loadReadinessData()
        observeSessionChanges()
        scheduleSpacedRetrieval()
    }

    private fun loadReadinessData() {
        // placeholder
    }

    private fun observeSessionChanges() {
        // placeholder
    }

    private fun scheduleSpacedRetrieval() {
        viewModelScope.launch {
            val examDate = examScheduleService.getExamDate() ?: return@launch
            val daysUntilExam = (examDate - System.currentTimeMillis()) / (24 * 60 * 60 * 1000)
            
            val nextReviewTime = when {
                daysUntilExam > 14 -> System.currentTimeMillis() + (3 * 24 * 60 * 60 * 1000)
                daysUntilExam > 7 -> System.currentTimeMillis() + (1 * 24 * 60 * 60 * 1000)
                daysUntilExam > 3 -> System.currentTimeMillis() + (3 * 60 * 60 * 1000)
                else -> System.currentTimeMillis() + (30 * 60 * 1000)
            }
            
            _nextReviewReminder.value = nextReviewTime
        }
    }
}
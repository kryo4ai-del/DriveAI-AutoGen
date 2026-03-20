package com.driveai.askfin.ui.viewmodels

@HiltViewModel
class ReadinessViewModel @Inject constructor(
    private val readinessRepository: ReadinessRepository,
    private val trainingSessionService: TrainingSessionService,
    private val examScheduleService: ExamScheduleService  // NEW: knows exam date
) : ViewModel() {

    private val _nextReviewReminder = MutableStateFlow<Long?>(null)
    val nextReviewReminder: StateFlow<Long?> = _nextReviewReminder.asStateFlow()

    init {
        loadReadinessData()
        observeSessionChanges()
        scheduleSpacedRetrieval()  // NEW
    }

    private fun scheduleSpacedRetrieval() {
        viewModelScope.launch {
            val examDate = examScheduleService.getExamDate() ?: return@launch
            val daysUntilExam = (examDate - System.currentTimeMillis()) / (24 * 60 * 60 * 1000)
            
            val nextReviewTime = when {
                daysUntilExam > 14 -> System.currentTimeMillis() + (3 * 24 * 60 * 60 * 1000)  // 3 days
                daysUntilExam > 7 -> System.currentTimeMillis() + (1 * 24 * 60 * 60 * 1000)   // 1 day
                daysUntilExam > 3 -> System.currentTimeMillis() + (3 * 60 * 60 * 1000)        // 3 hours
                else -> System.currentTimeMillis() + (30 * 60 * 1000)                         // 30 min
            }
            
            _nextReviewReminder.value = nextReviewTime
        }
    }
}
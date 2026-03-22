@HiltViewModel
class BreathingViewModel @Inject constructor(
    private val sessionRepository: ISessionRepository,
    private val statsService: StatsService
) : ViewModel() {
    
    // Track session state durably
    private val _sessionDurationMs = MutableStateFlow(0L)
    private val _sessionPausedAtMs = MutableStateFlow(0L)
    private var timerJob: Job? = null
    
    fun startBreathing(durationMinutes: Int = 5) {
        val technique = _selectedTechnique.value ?: return
        if (_isActive.value) return
        
        val durationMs = (durationMinutes * 60 * 1000L).also {
            _sessionDurationMs.value = it  // ← STORE duration
        }
        
        _isActive.value = true
        sessionStartTimeMs = System.currentTimeMillis()
        sessionElapsedTimeMs = 0
        
        // Cancel any existing timer job
        timerJob?.cancel()
        
        timerJob = viewModelScope.launch {
            runBreathingSession(technique, durationMs)
        }
    }
    
    fun pauseBreathing() {
        if (!_isActive.value) return
        _sessionPausedAtMs.value = sessionElapsedTimeMs  // ← SAVE elapsed time
        timerJob?.cancel()
        timerJob = null  // ← CLEAR reference
        _isActive.value = false
    }
    
    fun resumeBreathing() {
        val technique = _selectedTechnique.value ?: return
        if (_isActive.value || _sessionDurationMs.value == 0L) return
        
        _isActive.value = true
        val remainingMs = _sessionDurationMs.value - _sessionPausedAtMs.value
        
        // Cancel any orphaned job
        timerJob?.cancel()
        
        timerJob = viewModelScope.launch {
            // Resume from paused position
            var elapsedInSession = _sessionPausedAtMs.value
            while (elapsedInSession < _sessionDurationMs.value && _isActive.value) {
                runBreathingCycle(technique)
                elapsedInSession = sessionElapsedTimeMs
            }
        }
    }
}
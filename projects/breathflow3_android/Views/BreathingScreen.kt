// Create a combined state class
data class BreathingState(
    val progress: Float = 0f,
    val timeRemaining: Int = 0,
    val phase: BreathingPhase = BreathingPhase.IDLE,
    val cyclesCompleted: Int = 0
)

// In ViewModel, emit combined state
private val _breathingState = MutableStateFlow(BreathingState())
val breathingState: StateFlow<BreathingState> = _breathingState.asStateFlow()

private suspend fun runBreathingPhase(
    phase: BreathingPhase,
    durationMs: Int
) {
    _currentPhase.value = phase
    val phaseStartTimeMs = System.currentTimeMillis()
    
    while (_isActive.value) {
        val elapsedInPhaseMs = System.currentTimeMillis() - phaseStartTimeMs
        if (elapsedInPhaseMs >= durationMs) break
        
        val progress = (elapsedInPhaseMs.toFloat() / durationMs).coerceIn(0f, 1f)
        val remaining = ((durationMs - elapsedInPhaseMs) / 1000).toInt()
        
        // ATOMIC UPDATE — all fields synchronized
        _breathingState.value = BreathingState(
            progress = progress,
            timeRemaining = remaining,
            phase = phase,
            cyclesCompleted = _cyclesCompleted.value
        )
        
        delay(16L)
    }
}

// In Composable
@Composable
fun BreathingScreen(...) {
    val state by viewModel.breathingState.collectAsState()
    
    Canvas(...) {
        val radius = 50f * (1f + state.progress * 0.5f)  // Atomic read
        drawCircle(Color.Blue, radius = radius)
    }
}
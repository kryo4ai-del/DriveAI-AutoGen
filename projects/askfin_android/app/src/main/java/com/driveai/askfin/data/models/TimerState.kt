package com.driveai.askfin.data.models

import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject
import javax.inject.Singleton

data class TimerState(
    val remainingSeconds: Long = 1800L, // 30 minutes default
    val isRunning: Boolean = false,
    val isPaused: Boolean = false,
    val totalDurationSeconds: Long = 1800L
)

@Singleton
) {
    private val _timerState = MutableStateFlow(TimerState())
    val timerState: StateFlow<TimerState> = _timerState.asStateFlow()

    private var timerJob: Job? = null
    private val scope = CoroutineScope(Dispatchers.Default)

    /**
     * Start the exam timer with a specified duration in seconds.
     * Default: 30 minutes (1800 seconds).
     */
    fun startTimer(durationSeconds: Long = 1800L) {
        if (timerJob?.isActive == true) return

        _timerState.value = TimerState(
            remainingSeconds = durationSeconds,
            isRunning = true,
            totalDurationSeconds = durationSeconds
        )

        timerJob = scope.launch {
            var secondsRemaining = durationSeconds

            while (secondsRemaining > 0) {
                delay(1000L) // Wait 1 second

                secondsRemaining--
                _timerState.value = _timerState.value.copy(remainingSeconds = secondsRemaining)

                // Sync with ExamService
                examService.updateTimeRemaining(secondsRemaining)

                // Auto-submit when time expires
                if (secondsRemaining == 0L) {
                    pauseTimer()
                    break
                }
            }
        }
    }

    /**
     * Pause the timer without resetting.
     */
    fun pauseTimer() {
        timerJob?.cancel()
        timerJob = null
        _timerState.value = _timerState.value.copy(
            isRunning = false,
            isPaused = true
        )
    }

    /**
     * Resume the timer from paused state.
     */
    fun resumeTimer() {
        if (_timerState.value.isPaused) {
            val remaining = _timerState.value.remainingSeconds
            _timerState.value = _timerState.value.copy(
                isRunning = true,
                isPaused = false
            )

            timerJob = scope.launch {
                var secondsRemaining = remaining

                while (secondsRemaining > 0) {
                    delay(1000L)

                    secondsRemaining--
                    _timerState.value = _timerState.value.copy(remainingSeconds = secondsRemaining)

                    examService.updateTimeRemaining(secondsRemaining)

                    if (secondsRemaining == 0L) {
                        pauseTimer()
                        break
                    }
                }
            }
        }
    }

    /**
     * Stop the timer and reset to initial state.
     */
    fun stopTimer() {
        timerJob?.cancel()
        timerJob = null
        _timerState.value = TimerState()
    }

    /**
     * Reset timer to specified duration.
     */
    fun resetTimer(durationSeconds: Long = 1800L) {
        timerJob?.cancel()
        timerJob = null
        _timerState.value = TimerState(
            remainingSeconds = durationSeconds,
            totalDurationSeconds = durationSeconds
        )
    }

    /**
     * Get the remaining time as a formatted string (MM:SS).
     */
    fun getFormattedTimeRemaining(): String {
        val seconds = _timerState.value.remainingSeconds
        val minutes = seconds / 60
        val secs = seconds % 60
        return String.format("%02d:%02d", minutes, secs)
    }

    /**
     * Get the progress as a percentage (0-100).
     */
    fun getProgressPercentage(): Float {
        val state = _timerState.value
        return if (state.totalDurationSeconds > 0) {
            ((state.totalDurationSeconds - state.remainingSeconds).toFloat() / state.totalDurationSeconds) * 100f
        } else {
            0f
        }
    }

    /**
     * Check if time has expired.
     */
    fun isTimeExpired(): Boolean = _timerState.value.remainingSeconds <= 0

    /**
     * Clean up resources on destroy.
     */
    fun cleanup() {
        timerJob?.cancel()
        scope.coroutineContext.cancelChildren()
    }

    private fun Job?.cancelChildren() {
        (this?.coroutineContext?.get(Job) as? Job)?.let {
            it.cancel()
        }
    }
}
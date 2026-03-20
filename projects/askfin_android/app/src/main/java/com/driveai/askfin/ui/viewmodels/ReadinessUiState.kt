// File: com.driveai.askfin.ui.viewmodels/ReadinessViewModel.kt

package com.driveai.askfin.ui.viewmodels

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.driveai.askfin.data.models.ReadinessScore
import com.driveai.askfin.data.models.Milestone
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import kotlinx.coroutines.launch
import java.util.concurrent.TimeUnit
import javax.inject.Inject

// ============================================================================
// PLACEHOLDER TYPES
// ============================================================================

data class ScoreTrend(val direction: String = "", val delta: Float = 0f)

interface ReadinessRepository {
    suspend fun getReadinessScore(): ReadinessScore
    suspend fun getMilestones(): List<Milestone>
    suspend fun getScoreTrend(): ScoreTrend
}

interface TrainingSessionService {
    val sessionCompletedEvents: Flow<Unit>
    val examCompletedEvents: Flow<Unit>
}

// ============================================================================
// UI STATE
// ============================================================================

sealed class ReadinessUiState {
    object Loading : ReadinessUiState()

    data class Success(
        val score: ReadinessScore,
        val milestones: List<Milestone>,
        val trend: ScoreTrend,
        val isRefreshing: Boolean = false
    ) : ReadinessUiState()

    data class Error(
        val message: String,
        val isRetrying: Boolean = false
    ) : ReadinessUiState()
}

// ============================================================================
// VIEWMODEL
// ============================================================================

@HiltViewModel
class ReadinessViewModel @Inject constructor(
    private val readinessRepository: ReadinessRepository,
    private val trainingSessionService: TrainingSessionService
) : ViewModel() {

    private val _uiState = MutableStateFlow<ReadinessUiState>(ReadinessUiState.Loading)
    val uiState: StateFlow<ReadinessUiState> = _uiState.asStateFlow()

    private val _autoRefreshTrigger = MutableStateFlow<Long>(0L)
    val autoRefreshTrigger: StateFlow<Long> = _autoRefreshTrigger.asStateFlow()

    private val _lastRefreshTime = MutableStateFlow<Long>(0L)
    val lastRefreshTime: StateFlow<Long> = _lastRefreshTime.asStateFlow()

    private val _refreshBlocked = MutableStateFlow(false)
    val refreshBlocked: StateFlow<Boolean> = _refreshBlocked.asStateFlow()

    private companion object {
        private const val TAG = "ReadinessViewModel"
        private val REFRESH_DEBOUNCE_MS = TimeUnit.SECONDS.toMillis(2)
    }

    init {
        loadReadinessData()
        observeSessionChanges()
    }

    // ========================================================================
    // PUBLIC API
    // ========================================================================

    /**
     * Initial load of readiness data. Sets Loading state.
     * Called on ViewModel init.
     */
    fun loadReadinessData() {
        fetchAndUpdate(showLoading = true)
    }

    /**
     * Manual refresh with debounce (2 seconds minimum interval).
     * Does not show Loading spinner; overlays refresh indicator on existing state.
     * Sets [refreshBlocked] if debounce prevents call.
     */
    fun refreshReadinessData() {
        val now = System.currentTimeMillis()
        val lastRefresh = _lastRefreshTime.value

        if (now - lastRefresh < REFRESH_DEBOUNCE_MS) {
            // Debounce active; notify UI and schedule unblock
            _refreshBlocked.value = true
            viewModelScope.launch {
                delay(REFRESH_DEBOUNCE_MS - (now - lastRefresh))
                _refreshBlocked.value = false
            }
            Log.d(TAG, "Refresh debounced; next refresh available in ${REFRESH_DEBOUNCE_MS - (now - lastRefresh)}ms")
            return
        }

        fetchAndUpdate(showLoading = false, triggerSource = "manual_refresh")
    }

    /**
     * Retry on error state.
     */
    fun retry() {
        fetchAndUpdate(showLoading = true)
    }

    // ========================================================================
    // PRIVATE: CORE FETCH LOGIC (DRY)
    // ========================================================================

    /**
     * Single source of truth for fetching and updating readiness data.
     *
     * @param showLoading If true, sets state to Loading before fetch. Used for initial load.
     * @param triggerSource If provided, records auto-refresh trigger and updates trigger timestamp.
     *                       Used for session/exam completion auto-refresh.
     */
    private fun fetchAndUpdate(
        showLoading: Boolean = true,
        triggerSource: String? = null
    ) {
        viewModelScope.launch {
            try {
                if (showLoading) {
                    _uiState.value = ReadinessUiState.Loading
                }

                // Mark as refreshing if auto-triggered
                if (triggerSource != null) {
                    val currentState = _uiState.value
                    if (currentState is ReadinessUiState.Success) {
                        _uiState.value = currentState.copy(isRefreshing = true)
                    }
                }

                // Fetch from repository
                val score = readinessRepository.getReadinessScore()
                val milestones = readinessRepository.getMilestones()
                val trend = readinessRepository.getScoreTrend()

                // Update state
                _uiState.value = ReadinessUiState.Success(
                    score = score,
                    milestones = milestones,
                    trend = trend,
                    isRefreshing = false
                )
                _lastRefreshTime.value = System.currentTimeMillis()

                // Record trigger for downstream listeners (e.g., animations)
                if (triggerSource != null) {
                    _autoRefreshTrigger.value = System.currentTimeMillis()
                    Log.d(TAG, "Auto-refresh successful: $triggerSource")
                }

            } catch (e: Exception) {
                Log.e(TAG, "Failed to fetch readiness data${triggerSource?.let { "($it)" } ?: ""}", e)

                // Preserve last successful state on error; don't overwrite with Error
                val currentState = _uiState.value
                val message = e.message ?: "Unknown error"

                _uiState.value = when (currentState) {
                    is ReadinessUiState.Success -> {
                        // Keep showing data; mark not refreshing
                        currentState.copy(isRefreshing = false)
                    }
                    else -> {
                        // No prior state; show error
                        ReadinessUiState.Error(message = message)
                    }
                }
            }
        }
    }

    // ========================================================================
    // PRIVATE: AUTO-REFRESH OBSERVATION
    // ========================================================================

    /**
     * Observe training session and exam completion events from [TrainingSessionService].
     * Triggers auto-refresh when either event fires.
     *
     * Uses [Flow.launchIn] to properly manage coroutine lifecycle with viewModelScope.
     */
    private fun observeSessionChanges() {
        trainingSessionService.sessionCompletedEvents
            .onEach {
                performAutoRefresh("training_session_completed")
            }
            .launchIn(viewModelScope)

        trainingSessionService.examCompletedEvents
            .onEach {
                performAutoRefresh("exam_completed")
            }
            .launchIn(viewModelScope)
    }

    /**
     * Internal wrapper for auto-refresh. Delegates to [fetchAndUpdate].
     */
    private fun performAutoRefresh(triggerSource: String) {
        fetchAndUpdate(showLoading = false, triggerSource = triggerSource)
    }
}
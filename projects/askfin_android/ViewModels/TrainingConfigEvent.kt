// File: com/driveai/askfin/ui/viewmodels/TrainingConfigViewModel.kt

package com.driveai.askfin.ui.viewmodels

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.driveai.askfin.data.models.TrainingConfig
import com.driveai.askfin.data.repository.TrainingRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * Events emitted when config updates succeed or fail.
 */
sealed class TrainingConfigEvent {
    data class Updated(val config: TrainingConfig) : TrainingConfigEvent()
    data class UpdateFailed(val reason: String) : TrainingConfigEvent()
    object Cleared : TrainingConfigEvent()
}

@HiltViewModel
class TrainingConfigViewModel @Inject constructor(
    private val repository: TrainingRepository
) : ViewModel() {

    // Current configuration
    private val _config = MutableStateFlow(TrainingConfig())
    val config: StateFlow<TrainingConfig> = _config.asStateFlow()

    // UI events (success/error)
    private val _events = MutableSharedFlow<TrainingConfigEvent>()
    val events: SharedFlow<TrainingConfigEvent> = _events.asSharedFlow()

    // Loading state
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    init {
        loadLatestConfig()
    }

    /**
     * Load the most recent config from persistence.
     */
    fun loadLatestConfig() {
        viewModelScope.launch {
            _isLoading.value = true
            try {
                repository.getLatestConfig()
                    .onSuccess { config ->
                        _config.value = config
                        _events.emit(TrainingConfigEvent.Updated(config))
                    }
                    .onFailure { error ->
                        _events.emit(
                            TrainingConfigEvent.UpdateFailed(
                                "Failed to load config: ${error.message}"
                            )
                        )
                    }
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Update configuration with validation.
     * Emits UpdateFailed event if validation fails.
     */
    fun updateConfig(newConfig: TrainingConfig) {
        // Validate before attempting save
        newConfig.validationError()?.let { error ->
            viewModelScope.launch {
                _events.emit(TrainingConfigEvent.UpdateFailed(error))
            }
            return
        }

        viewModelScope.launch {
            _isLoading.value = true
            try {
                repository.saveConfig(newConfig)
                    .onSuccess {
                        _config.value = newConfig
                        _events.emit(TrainingConfigEvent.Updated(newConfig))
                    }
                    .onFailure { error ->
                        _events.emit(
                            TrainingConfigEvent.UpdateFailed(
                                "Failed to save config: ${error.message}"
                            )
                        )
                    }
            } finally {
                _isLoading.value = false
            }
        }
    }

    /**
     * Reset to default configuration.
     */
    fun resetToDefaults() {
        updateConfig(TrainingConfig())
    }
}
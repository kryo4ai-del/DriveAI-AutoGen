package com.driveai.askfin.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.driveai.askfin.domain.repository.SettingsRepository
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SettingsUiState(
    val isDarkMode: Boolean = false,
    val notificationsEnabled: Boolean = true,
    val showClearProgressDialog: Boolean = false,
    val appVersion: String? = null,
    val isClearing: Boolean = false,
    val clearProgressSuccess: Boolean? = null,
    val errorMessage: String? = null,
    val isLoading: Boolean = true
)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    init {
        loadSettings()
    }

    // ✅ FIX #1: Consolidate multiple collectors into single combine()
    private fun loadSettings() {
        viewModelScope.launch {
            try {
                combine(
                    settingsRepository.getDarkModeEnabled(),
                    settingsRepository.getNotificationsEnabled()
                ) { darkMode, notifications ->
                    Pair(darkMode, notifications)
                }.collect { (darkMode, notifications) ->
                    _uiState.value = _uiState.value.copy(
                        isDarkMode = darkMode,
                        notificationsEnabled = notifications
                    )
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    errorMessage = "Failed to load preferences: ${e.message}"
                )
            }
        }

        // ✅ FIX #6: Lazy-load app version with error handling
        viewModelScope.launch {
            try {
                val version = settingsRepository.getAppVersion()
                _uiState.value = _uiState.value.copy(
                    appVersion = version,
                    isLoading = false
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    appVersion = "Unknown",
                    isLoading = false,
                    errorMessage = "Failed to load app version"
                )
            }
        }
    }

    // ✅ FIX #4: Add error handling to toggle functions
    fun toggleDarkMode(enabled: Boolean) {
        viewModelScope.launch {
            try {
                settingsRepository.setDarkModeEnabled(enabled)
                _uiState.value = _uiState.value.copy(isDarkMode = enabled)
            } catch (e: Exception) {
                // Revert UI state on failure
                _uiState.value = _uiState.value.copy(
                    isDarkMode = !enabled,
                    errorMessage = "Failed to save dark mode preference"
                )
            }
        }
    }

    fun toggleNotifications(enabled: Boolean) {
        viewModelScope.launch {
            try {
                settingsRepository.setNotificationsEnabled(enabled)
                _uiState.value = _uiState.value.copy(notificationsEnabled = enabled)
            } catch (e: Exception) {
                // Revert UI state on failure
                _uiState.value = _uiState.value.copy(
                    notificationsEnabled = !enabled,
                    errorMessage = "Failed to save notification preference"
                )
            }
        }
    }

    fun showClearProgressDialog() {
        _uiState.value = _uiState.value.copy(showClearProgressDialog = true)
    }

    fun dismissClearProgressDialog() {
        _uiState.value = _uiState.value.copy(
            showClearProgressDialog = false,
            clearProgressSuccess = null
        )
    }

    // ✅ FIX #2, #3: Auto-dismiss via ViewModel, capture errors, show feedback
    fun clearUserProgress() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(
                isClearing = true,
                errorMessage = null
            )

            try {
                settingsRepository.clearUserProgress()
                _uiState.value = _uiState.value.copy(
                    isClearing = false,
                    clearProgressSuccess = true,
                    showClearProgressDialog = false
                )

                // Auto-dismiss success state after 2 seconds (no LaunchedEffect)
                delay(2000)
                _uiState.value = _uiState.value.copy(clearProgressSuccess = null)
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isClearing = false,
                    clearProgressSuccess = false,
                    errorMessage = e.message ?: "Failed to clear progress"
                )
            }
        }
    }

    // ✅ NEW: Clear error message after showing
    fun clearErrorMessage() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }
}
package com.driveai.askfin.data.models
import java.io.IOException
import kotlinx.coroutines.flow.MutableStateFlow

sealed class ReadinessUiState {
    // ... existing states ...

    data class Error(
        val message: String,
        val isRetrying: Boolean = false,
        val errorCategory: ErrorCategory = ErrorCategory.UNKNOWN,
        val suggestedAction: String? = null  // "Check your connection" or "Retry in 30 seconds"
    ) : ReadinessUiState()
}

enum class ErrorCategory {
    NETWORK, VALIDATION, SERVER, UNKNOWN
}

private val _uiState = MutableStateFlow<ReadinessUiState>(ReadinessUiState.Error(""))

private fun fetchAndUpdate() {
    try { }
    catch (e: IOException) {
        _uiState.value = ReadinessUiState.Error(
            message = "Network unavailable",
            errorCategory = ErrorCategory.NETWORK,
            suggestedAction = "Check your wifi and try again"
        )
    }
    catch (e: IllegalArgumentException) {
        _uiState.value = ReadinessUiState.Error(
            message = "Invalid data received",
            errorCategory = ErrorCategory.VALIDATION,
            suggestedAction = "Restart the app and try again"
        )
    }
}
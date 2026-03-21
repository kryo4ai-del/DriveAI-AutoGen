data class SettingsUiState(
    // ...
    val isLoading: Boolean = true,  // Show spinner initially
)

private fun loadSettings() {
    viewModelScope.launch {
        // ...load settings...
        _uiState.value = _uiState.value.copy(isLoading = false)
    }
}

// In Screen:
if (uiState.isLoading) {
    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
        CircularProgressIndicator()
    }
} else {
    // ... render settings...
}
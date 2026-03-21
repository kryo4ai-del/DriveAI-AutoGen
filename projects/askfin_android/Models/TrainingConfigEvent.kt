// In ViewModel, extend error handling
sealed class TrainingConfigEvent {
    data class Updated(val config: TrainingConfig) : TrainingConfigEvent()
    data class UpdateFailed(
        val reason: String,
        val failedField: String? = null  // NEW: link error to field
    ) : TrainingConfigEvent()
    object Cleared : TrainingConfigEvent()
}

// In Composable
LaunchedEffect(Unit) {
    viewModel.events.collect { event ->
        when (event) {
            is TrainingConfigEvent.UpdateFailed -> {
                // Show persistent error message, not just snackbar
                val duration = SnackbarDuration.Long
                snackbarHostState.showSnackbar(
                    message = event.reason,
                    duration = duration
                )
                // Announce error immediately
                announceForAccessibility(event.reason)
            }
            // ...
        }
    }
}
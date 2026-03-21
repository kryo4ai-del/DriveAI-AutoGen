sealed class ConfigEvent {
    data class Updated(val config: TrainingConfig) : ConfigEvent()
    data class UpdateFailed(val reason: String) : ConfigEvent()
}

fun updateConfig(newConfig: TrainingConfig) {
    if (newConfig.isValid()) {
        _trainingConfig.value = newConfig
        _events.tryEmit(ConfigEvent.Updated(newConfig))
    } else {
        val reason = when {
            newConfig.sessionDuration < 60 -> "Session too short (min 60s)"
            newConfig.sessionDuration > 3600 -> "Session too long (max 1h)"
            newConfig.questionsPerSession < 1 -> "At least 1 question required"
            newConfig.questionsPerSession > 100 -> "Max 100 questions per session"
            else -> "Invalid configuration"
        }
        _events.tryEmit(ConfigEvent.UpdateFailed(reason))
    }
}
sealed class ConfigUpdateResult {
    object Success : ConfigUpdateResult()
    data class Error(val message: String) : ConfigUpdateResult()
}

fun updateConfig(newConfig: TrainingConfig): ConfigUpdateResult =
    if (newConfig.isValid()) {
        _trainingConfig.value = newConfig
        ConfigUpdateResult.Success
    } else {
        ConfigUpdateResult.Error("Invalid session duration or question count")
    }
data class Error(
    val message: String,
    val exception: Throwable? = null,
    val retryable: Boolean = true
) : SkillMapUiState()
import kotlinx.serialization.Serializable

@Serializable
data class TrainingConfig(
    val sessionDuration: Int = 300,
    val questionsPerSession: Int = 10,
    val adaptiveMode: Boolean = true,
    val difficultyLevel: DifficultyLevel = DifficultyLevel.MEDIUM
) {
    init {
        require(sessionDuration in 30..3600) { 
            "sessionDuration must be 30–3600 seconds"
        }
        require(questionsPerSession in 1..100) { 
            "questionsPerSession must be 1–100"
        }
    }
}

@Serializable
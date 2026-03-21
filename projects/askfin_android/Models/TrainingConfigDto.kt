// com.driveai.askfin.data.models.dto
@Serializable
data class TrainingConfigDto(
    val sessionDuration: Int = 300,
    val questionsPerSession: Int = 10,
    val adaptiveMode: Boolean = true,
    val difficultyLevel: String = "MEDIUM"
)
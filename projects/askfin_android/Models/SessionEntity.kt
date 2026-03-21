@Entity(tableName = "training_sessions")
data class SessionEntity(
    @PrimaryKey val id: String,
    val sessionDuration: Int = 300,
    val questionsPerSession: Int = 10,
    val adaptiveMode: Boolean = true,
    val difficultyLevel: DifficultyLevel = DifficultyLevel.MEDIUM,
    val createdAt: Long = System.currentTimeMillis()
)
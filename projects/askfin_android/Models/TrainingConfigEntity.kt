@Entity(tableName = "training_configs")
data class TrainingConfigEntity(
    @PrimaryKey val id: String = UUID.randomUUID().toString(),
    val sessionDuration: Int = 300,
    val questionsPerSession: Int = 10,
    val adaptiveMode: Boolean = true,
    val difficultyLevel: String = DifficultyLevel.MEDIUM.name, // Store as string
    val createdAt: Long = System.currentTimeMillis()
)

fun TrainingConfigEntity.toDomain(): TrainingConfig =
    TrainingConfig(
        sessionDuration,
        questionsPerSession,
        adaptiveMode,
        DifficultyLevel.valueOf(difficultyLevel)
    )
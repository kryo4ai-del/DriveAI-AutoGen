data class UserAnswer(
    val id: String,
    val questionId: String,
    val selectedAnswerId: String,  // ← Which answer user chose
    val isCorrect: Boolean,        // ← Performance data (sensitive in education context)
    val timeSpent: Long,           // ← Behavioral tracking
    val timestamp: Instant,        // ← Temporal metadata
    val trainingMode: TrainingMode,// ← User activity type
    val userId: String             // ← Unique identifier (PII in GDPR terms)
)
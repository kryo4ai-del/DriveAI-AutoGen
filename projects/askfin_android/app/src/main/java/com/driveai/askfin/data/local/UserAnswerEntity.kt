package com.driveai.askfin.data.local

// No TTL, no auto-deletion, no anonymization logic
@Entity(tableName = "user_answers")
data class UserAnswerEntity(
    @PrimaryKey val id: String,
    val userId: String,    // ← Linked to user indefinitely
    val questionId: String,
    val selectedAnswerId: String,
    val isCorrect: Boolean,
    val timeSpent: Long,
    val timestamp: Instant  // ← Only metadata; no retention deadline
)
package com.driveai.askfin.data.models

data class SkillMapUiState(
    // ... existing fields
    val recommendedNextCategory: RecommendedStudy? = null
)

data class RecommendedStudy(
    val categoryName: String,           // "Speed Limits"
    val reason: String,                 // "Due for review" / "Lowest score" / "Exam-critical"
    val priorityLevel: PriorityLevel,   // URGENT / HIGH / MEDIUM
    val estimatedGainPoints: Int,       // "Master this → +8% to exam readiness"
)

enum class PriorityLevel {
    URGENT,   // <50%, exam day approaching
    HIGH,     // 50-69%, exam gap
    MEDIUM,   // 70%+, but high forgetting curve
}
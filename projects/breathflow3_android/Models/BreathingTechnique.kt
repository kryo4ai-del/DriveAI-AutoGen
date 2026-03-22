package com.driveai.breathflow.data.models

enum class BreathingTechnique(
    val displayName: String,
    val description: String,
    val inhaleDurationMs: Int,
    val holdDurationMs: Int,
    val exhaleDurationMs: Int,
    val totalCycleDurationMs: Int
) {
    FOUR_SEVEN_EIGHT(
        displayName = "4-7-8 Breathing",
        description = "Slow, deep breath for calming anxiety",
        inhaleDurationMs = 4000,
        holdDurationMs = 7000,
        exhaleDurationMs = 8000,
        totalCycleDurationMs = 19000
    ),
    BOX_BREATHING(
        displayName = "Box Breathing",
        description = "Equal counts for balance and focus",
        inhaleDurationMs = 4000,
        holdDurationMs = 4000,
        exhaleDurationMs = 4000,
        totalCycleDurationMs = 12000
    ),
    CALM_BREATHING(
        displayName = "Calm Breathing",
        description = "Gentle, natural rhythm for relaxation",
        inhaleDurationMs = 3000,
        holdDurationMs = 2000,
        exhaleDurationMs = 4000,
        totalCycleDurationMs = 9000
    );

    fun getDurationInSeconds(): Int = totalCycleDurationMs / 1000
}

enum class BreathingPhase {
    IDLE,
    INHALE,
    HOLD,
    EXHALE,
    COMPLETE
}

data class SessionRecord(
    val id: String = "",
    val technique: String = "",
    val durationSeconds: Int = 0,
    val cyclesCompleted: Int = 0,
    val timestamp: Long = System.currentTimeMillis(),
    val notes: String = ""
)
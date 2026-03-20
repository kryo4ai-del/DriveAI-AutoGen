package com.driveai.askfin.data.models
import java.time.LocalDateTime

data class ReadinessMilestone(
    val name: String,
    val threshold: Float,
    val achieved: Boolean,
    val achievedAt: LocalDateTime?
) {
    init {
        require(name.isNotBlank()) { "name cannot be blank" }
        require(threshold in 0f..100f) { "threshold must be between 0 and 100" }
        
        // Enforce state consistency both directions
        when {
            achieved && achievedAt == null -> 
                throw IllegalArgumentException("Achieved milestone must have achievedAt timestamp")
            !achieved && achievedAt != null -> 
                throw IllegalArgumentException("Unachieved milestone cannot have achievedAt timestamp")
        }
    }
}
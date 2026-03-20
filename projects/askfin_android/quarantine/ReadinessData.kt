// data/models/ReadinessScore.kt
package com.driveai.askfin.data.models

import java.time.LocalDateTime

data class ReadinessData(
    val overallScore: Float,
    val milestones: List<ReadinessMilestone>,
    val trend: ReadinessTrend,
    val lastUpdated: LocalDateTime
) {
    init {
        require(overallScore in 0f..100f) { 
            "overallScore must be between 0 and 100, got $overallScore" 
        }
    }
}

    val threshold: Float,
    val achieved: Boolean,
    val achievedAt: LocalDateTime? = null
) {
    init {
        require(name.isNotBlank()) { "name cannot be blank" }
        require(threshold in 0f..100f) { 
            "threshold must be between 0 and 100, got $threshold" 
        }
        
        // Enforce state consistency in both directions
        when {
            achieved && achievedAt == null -> 
                throw IllegalArgumentException(
                    "Achieved milestone '$name' must have achievedAt timestamp"
                )
            !achieved && achievedAt != null -> 
                throw IllegalArgumentException(
                    "Unachieved milestone '$name' cannot have achievedAt timestamp"
                )
        }
    }
}

enum class ReadinessTrend {
    IMPROVING,
    STABLE,
    DECLINING
}
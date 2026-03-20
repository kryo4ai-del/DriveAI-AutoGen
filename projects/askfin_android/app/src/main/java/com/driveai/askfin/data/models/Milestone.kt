package com.driveai.askfin.data.models

data class Milestone(
    // ...
    val progress: Int = 0,  // Already present but not set in all cases
    val targetValue: Int = 0  // For competence: target is 50 or 80
)

// Usage: Show "50% Competence: 32/50" before unlock
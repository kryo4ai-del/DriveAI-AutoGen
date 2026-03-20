package com.driveai.askfin.data.models

data class ExamWeightConfig(
    val recentWeight: Double = 0.50,
    val historicalWeight: Double = 0.50,
    val maxHistoricalCount: Int = Int.MAX_VALUE  // Consider all history
)
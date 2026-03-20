package com.driveai.askfin.data.models

data class CompetenceScore(
    val value: Float,
    val confidenceInterval: ConfidenceInterval,
    val sampleSize: Int
) {
    val isSignificant: Boolean get() = sampleSize >= 5
    val marginOfError: Float get() = confidenceInterval.margin
}
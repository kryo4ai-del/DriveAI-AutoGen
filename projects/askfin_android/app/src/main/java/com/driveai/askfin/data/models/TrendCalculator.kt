// domain/TrendCalculator.kt (optional: service layer)
package com.driveai.askfin.data.models

import com.driveai.askfin.data.models.ReadinessTrend
import com.driveai.askfin.data.models.ReadinessScoreHistoryEntity

/**
 * Calculates trend from historical score samples.
 * Extracted to testable function (unit tests don't need mocks).
 */
object TrendCalculator {
    
    private const val THRESHOLD = 5.0f
    private const val MIN_SAMPLES = 2
    
    /**
     * Compare first and last sample in list.
     * Samples should be sorted by timestamp (oldest first).
     */
    fun calculateTrend(samples: List<ReadinessScoreHistoryEntity>): ReadinessTrend {
        if (samples.size < MIN_SAMPLES) return ReadinessTrend.STABLE
        
        val first = samples.first().score
        val last = samples.last().score
        val delta = last - first
        
        return when {
            delta > THRESHOLD -> ReadinessTrend.IMPROVING
            delta < -THRESHOLD -> ReadinessTrend.DECLINING
            else -> ReadinessTrend.STABLE
        }
    }
}
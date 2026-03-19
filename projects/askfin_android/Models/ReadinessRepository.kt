// data/repository/ReadinessRepository.kt
package com.driveai.askfin.data.repository

import com.driveai.askfin.data.models.ReadinessData
import com.driveai.askfin.data.models.ReadinessMilestone
import kotlinx.coroutines.flow.Flow

/**
 * Repository interface for readiness score operations.
 * 
 * **Pattern:** Reactive via Flow (MVVM-preferred).
 * Use [observeReadinessData] in ViewModels with collectAsState().
 * Call [refreshReadinessData] only if you need to force recomputation.
 */
interface ReadinessRepository {
    
    /**
     * Observe readiness data as hot Flow.
     * 
     * - Emits cached value immediately on subscribe
     * - Automatically updates when Room data changes
     * - Respects Compose lifecycle (collectAsState handles cancellation)
     * 
     * ✅ Use this in ViewModels for UI binding
     */
    fun observeReadinessData(): Flow<ReadinessData>
    
    /**
     * Force refresh readiness score and trend from computation.
     * Updates Room database, which triggers [observeReadinessData] emission.
     * 
     * ⚠️ Only call if observeReadinessData() data is stale or explicitly requested by user
     */
    suspend fun refreshReadinessData(): Result<Unit>
    
    /**
     * Update overall readiness score atomically.
     * 
     * - Saves to score history (for trend calculation)
     * - Recalculates trend from historical data
     * - Emits updated ReadinessData via observeReadinessData()
     * 
     * Returns updated [ReadinessData] on success.
     */
    suspend fun updateOverallScore(newScore: Float): Result<ReadinessData>
    
    /**
     * Mark a milestone as achieved atomically.
     * 
     * - Sets achieved=true and achievedAt=LocalDateTime.now()
     * - Updates overall score if milestones affect scoring
     * - Triggers trend recalculation
     * - Returns full [ReadinessData] (not just milestone)
     * 
     * **Transaction:** Milestone update + score recalc must be atomic
     */
    suspend fun achieveMilestone(milestoneName: String): Result<ReadinessData>
    
    /**
     * Get single milestone by name.
     * Use for detail screens; prefer [observeReadinessData] for lists.
     */
    suspend fun getMilestoneByName(name: String): Result<ReadinessMilestone>
    
    /**
     * Clear all readiness data (logout, account reset).
     */
    suspend fun clearReadinessData(): Result<Unit>
}
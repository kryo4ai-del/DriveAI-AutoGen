// File: com.driveai.askfin.domain.service/TrainingSessionService.kt

package com.driveai.askfin.domain

import kotlinx.coroutines.flow.Flow

/**
 * Service for observing training session and exam completion events.
 *
 * Both flows emit Unit (non-null) when their respective event occurs.
 * These are used to trigger auto-refresh of readiness scores.
 */
interface TrainingSessionService {
    /**
     * Emits Unit when a training session completes.
     * Never emits null; subscription is safe without null checks.
     */
    val sessionCompletedEvents: Flow<Unit>

    /**
     * Emits Unit when an exam completes.
     * Never emits null; subscription is safe without null checks.
     */
    val examCompletedEvents: Flow<Unit>
}
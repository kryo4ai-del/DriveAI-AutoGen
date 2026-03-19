package com.driveai.askfin.data.repository

import com.driveai.askfin.data.models.SkillMapData
import com.driveai.askfin.data.models.QuestionCategory
import kotlinx.coroutines.flow.Flow

/**
 * Sealed result type for SkillMap operations.
 * Forces exhaustive when-expression handling in ViewModels.
 */
sealed class SkillMapResult {
    /**
     * Operation succeeded.
     */
    data class Success(val data: SkillMapData) : SkillMapResult()

    /**
     * Skill map not found.
     * Reason: User has no answer history, or data was cleared.
     */
    data class NotFound(val userId: String) : SkillMapResult()

    /**
     * Operation failed with an error.
     */
    data class Error(val exception: Exception) : SkillMapResult()

    /**
     * Convenience function for sealed exhaustiveness in ViewModels.
     */
    inline fun <T> fold(
        onSuccess: (SkillMapData) -> T,
        onNotFound: (String) -> T,
        onError: (Exception) -> T
    ): T = when (this) {
        is Success -> onSuccess(data)
        is NotFound -> onNotFound(userId)
        is Error -> onError(exception)
    }
}

/**
 * Repository contract for skill map operations.
 * Abstracts data sources (local DB, remote, cache) behind a unified interface.
 */
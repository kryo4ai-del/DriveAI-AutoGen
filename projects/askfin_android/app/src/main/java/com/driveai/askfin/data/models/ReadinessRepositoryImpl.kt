package com.driveai.askfin.data.models

import com.driveai.askfin.data.local.ReadinessDao
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

interface ReadinessRepository {
    suspend fun getReadinessScore(): ReadinessScore
    fun observeReadinessScore(): Flow<ReadinessScore>
    suspend fun updateScore(newScore: Int): Result<ReadinessScore>
    suspend fun unlockMilestone(milestoneId: String): Result<Unit>
}

class ReadinessRepositoryImpl(
    private val readinessDao: ReadinessDao
) : ReadinessRepository {

    override suspend fun getReadinessScore(): ReadinessScore {
        return try {
            // Fetch milestones from DB
            val milestoneEntity = readinessDao.getMilestoneById("default")
            val unlockedCount = readinessDao.getUnlockedMilestoneCount()
            
            ReadinessScore(
                currentScore = 0,  // TODO: Fetch from actual source
                milestones = listOf()  // TODO: Map from entity
            )
        } catch (e: Exception) {
            throw ReadinessException("Failed to load readiness score", e)
        }
    }

    override fun observeReadinessScore(): Flow<ReadinessScore> {
        return readinessDao.getUnlockedMilestones().map { entities ->
            ReadinessScore(
                currentScore = 0,  // TODO: Bind to actual data source
                milestones = entities.map { it.toDomain() }
            )
        }
    }

    override suspend fun updateScore(newScore: Int): Result<ReadinessScore> {
        return try {
            // Validate and persist
            val updated = ReadinessScore(currentScore = newScore, milestones = listOf())
            Result.success<ReadinessScore>(updated)
        } catch (e: Exception) {
            Result.failure<ReadinessScore>(ReadinessException("Failed to update score", e))
        }
    }

    override suspend fun unlockMilestone(milestoneId: String): Result<Unit> {
        return try {
            val milestone = readinessDao.getMilestoneById(milestoneId)
                ?: return Result.failure<Unit>(
                    ReadinessException("Milestone not found: $milestoneId")
                )

            val updated = milestone.copy(
                isUnlocked = true,
                unlockedAt = System.currentTimeMillis()
            )
            readinessDao.insertMilestone(updated)
            Result.success<Unit>(Unit)
        } catch (e: Exception) {
            Result.failure<Unit>(ReadinessException("Failed to unlock milestone", e))
        }
    }
}

class ReadinessException(message: String, cause: Throwable? = null) :
    Exception(message, cause)

data class ReadinessScore(
    val currentScore: Int,
    val milestones: List<Any>
)

data class MilestoneEntity(
    val id: String,
    val isUnlocked: Boolean = false,
    val unlockedAt: Long = 0
) {
    fun copy(isUnlocked: Boolean = this.isUnlocked, unlockedAt: Long = this.unlockedAt): MilestoneEntity {
        return MilestoneEntity(id = this.id, isUnlocked = isUnlocked, unlockedAt = unlockedAt)
    }
}

fun MilestoneEntity.toDomain(): Any = this
package com.driveai.askfin.data.repository

import com.driveai.askfin.data.local.ReadinessDao
import com.driveai.askfin.data.models.MilestoneEntity
import com.driveai.askfin.data.models.ReadinessScore
import com.driveai.askfin.data.models.toDomain
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

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
            val updated = ReadinessScore(currentScore = newScore)
            Result.success(updated)
        } catch (e: Exception) {
            Result.failure(ReadinessException("Failed to update score", e))
        }
    }

    override suspend fun unlockMilestone(milestoneId: String): Result<Unit> {
        return try {
            val milestone = readinessDao.getMilestoneById(milestoneId)
                ?: return Result.failure(
                    ReadinessException("Milestone not found: $milestoneId")
                )

            val updated = milestone.copy(
                isUnlocked = true,
                unlockedAt = System.currentTimeMillis()
            )
            readinessDao.insertMilestone(updated)
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(ReadinessException("Failed to unlock milestone", e))
        }
    }
}

class ReadinessException(message: String, cause: Throwable? = null) :
    Exception(message, cause)
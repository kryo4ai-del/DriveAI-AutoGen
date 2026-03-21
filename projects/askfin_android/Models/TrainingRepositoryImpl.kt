// File: com/driveai/askfin/data/repository/TrainingRepositoryImpl.kt

package com.driveai.askfin.data.repository

import com.driveai.askfin.data.local.dao.TrainingConfigDao
import com.driveai.askfin.data.models.TrainingConfig
import com.driveai.askfin.data.local.entities.toEntity
import com.driveai.askfin.data.local.entities.toDomain
import kotlinx.coroutines.flow.first
import javax.inject.Inject

interface TrainingRepository {
    suspend fun saveConfig(config: TrainingConfig): Result<Unit>
    suspend fun getLatestConfig(): Result<TrainingConfig>
}

class TrainingRepositoryImpl @Inject constructor(
    private val dao: TrainingConfigDao
) : TrainingRepository {

    override suspend fun saveConfig(config: TrainingConfig): Result<Unit> = try {
        dao.insertOrUpdate(config.toEntity())
        Result.success(Unit)
    } catch (e: Exception) {
        Result.failure(e)
    }

    override suspend fun getLatestConfig(): Result<TrainingConfig> = try {
        val entity = dao.getLatestConfig().first()
        if (entity != null) {
            Result.success(entity.toDomain())
        } else {
            // No config saved yet, return default
            Result.success(TrainingConfig())
        }
    } catch (e: Exception) {
        Result.failure(e)
    }
}
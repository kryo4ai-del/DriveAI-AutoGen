// File: com/driveai/askfin/data/local/dao/TrainingConfigDao.kt

package com.driveai.askfin.data.local.dao

import androidx.room.*
import com.driveai.askfin.data.local.entities.TrainingConfigEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface TrainingConfigDao {
    
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrUpdate(config: TrainingConfigEntity)

    @Query("SELECT * FROM training_configs WHERE id = :id")
    fun getConfigById(id: Int): Flow<TrainingConfigEntity?>

    @Query("SELECT * FROM training_configs ORDER BY id DESC LIMIT 1")
    fun getLatestConfig(): Flow<TrainingConfigEntity?>

    @Query("DELETE FROM training_configs WHERE id = :id")
    suspend fun deleteConfig(id: Int)
}
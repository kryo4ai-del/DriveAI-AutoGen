package com.driveai.askfin.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.driveai.askfin.data.models.MilestoneEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface ReadinessDao {

    @Query("SELECT * FROM milestones WHERE isUnlocked = 1 ORDER BY unlockedAt DESC LIMIT :limit")
    fun getUnlockedMilestones(limit: Int = 10): Flow<List<MilestoneEntity>>

    @Query("SELECT * FROM milestones WHERE id = :milestoneId")
    suspend fun getMilestoneById(milestoneId: String): MilestoneEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMilestone(milestone: MilestoneEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMilestones(milestones: List<MilestoneEntity>)

    @Query("DELETE FROM milestones WHERE id = :milestoneId")
    suspend fun deleteMilestone(milestoneId: String)

    @Query("SELECT COUNT(*) FROM milestones WHERE isUnlocked = 1")
    fun getUnlockedMilestoneCount(): Flow<Int>
}
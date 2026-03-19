package com.driveai.skillmap.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.driveai.skillmap.data.models.SkillEntity

@Dao
interface SkillMapDao {

    @Query("SELECT * FROM skills ORDER BY category, name")
    suspend fun getAllSkills(): List<SkillEntity>

    @Query("SELECT * FROM skills WHERE id = :skillId")
    suspend fun getSkillById(skillId: String): SkillEntity?

    @Query("SELECT * FROM skills WHERE category = :category")
    suspend fun getSkillsByCategory(category: String): List<SkillEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSkill(skill: SkillEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSkills(skills: List<SkillEntity>)

    @Query("UPDATE skills SET currentLevel = :newLevel, lastUpdated = :timestamp WHERE id = :skillId")
    suspend fun updateSkillLevel(skillId: String, newLevel: Float, timestamp: Long)

    @Query("DELETE FROM skills")
    suspend fun clearAll()
}
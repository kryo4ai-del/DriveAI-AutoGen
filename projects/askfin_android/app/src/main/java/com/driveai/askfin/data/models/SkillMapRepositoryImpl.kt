package com.driveai.askfin.data.models

import com.driveai.askfin.data.local.SkillMapDao
import javax.inject.Inject

interface SkillMapRepository {
    suspend fun getSkills(): List<SkillUiModel>
    suspend fun updateSkill(skillId: String, newLevel: Float)
}

data class SkillUiModel(
    val id: String,
    val name: String,
    val category: String,
    val currentLevel: Float,
    val targetLevel: Float
)

class SkillMapRepositoryImpl @Inject constructor(
    private val skillMapDao: SkillMapDao
) : SkillMapRepository {

    override suspend fun getSkills(): List<SkillUiModel> {
        return skillMapDao.getAllSkills().map { entity ->
            SkillUiModel(
                id = entity.id,
                name = entity.name,
                category = entity.category,
                currentLevel = entity.currentLevel,
                targetLevel = entity.targetLevel
            )
        }
    }

    override suspend fun updateSkill(skillId: String, newLevel: Float) {
        skillMapDao.updateSkillLevel(skillId, newLevel, java.lang.System.currentTimeMillis())
    }
}
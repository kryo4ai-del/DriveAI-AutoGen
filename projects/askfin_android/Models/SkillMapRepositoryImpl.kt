package com.driveai.skillmap.data.repository

import com.driveai.skillmap.data.local.SkillMapDao
import com.driveai.skillmap.data.models.SkillUiModel
import javax.inject.Inject

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
        skillMapDao.updateSkillLevel(skillId, newLevel, System.currentTimeMillis())
    }
}
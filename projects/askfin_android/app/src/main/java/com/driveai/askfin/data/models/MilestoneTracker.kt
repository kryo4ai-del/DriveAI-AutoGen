// com.driveai.askfin.domain.service.MilestoneTracker.kt

package com.driveai.askfin.data.models

import com.driveai.askfin.data.models.SkillMapData
import com.driveai.askfin.data.models.ExamResult
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Tracks user milestones and determines unlock status
 * Milestones:
 * - First Training: completed any practice
 * - First Exam: completed any exam attempt
 * - 50% Competence: reached 50% avg mastery across all skills
 * - 80% Competence: reached 80% avg mastery across all skills
 * - All Categories Practiced: practiced in every skill category
 * - Exam Passed: achieved >= 70% on any exam
 */
@Singleton
class MilestoneTracker @Inject constructor() {

    fun trackMilestones(
        skillMap: SkillMapData,
        examResults: List<ExamResult>
    ): List<Milestone> {
        return listOf(
            trackFirstTraining(skillMap),
            trackFirstExam(examResults),
            track50PercentCompetence(skillMap),
            track80PercentCompetence(skillMap),
            trackAllCategoriesPracticed(skillMap),
            trackExamPassed(examResults)
        )
    }

    private fun trackFirstTraining(skillMap: SkillMapData): Milestone {
        val hasCompleted = skillMap.skills.any { it.practiceHistory.isNotEmpty() }
        val unlockedAt = if (hasCompleted) {
            skillMap.skills
                .flatMap { it.practiceHistory }
                .minOrNull()
        } else {
            null
        }

        return Milestone(
            id = "first_training",
            name = "First Steps",
            description = "Complete your first practice session",
            icon = "🎓",
            unlockedAt = unlockedAt,
            isUnlocked = hasCompleted
        )
    }

    private fun trackFirstExam(examResults: List<ExamResult>): Milestone {
        val hasCompleted = examResults.isNotEmpty()
        val unlockedAt = examResults.minByOrNull { it.completedAt }?.completedAt

        return Milestone(
            id = "first_exam",
            name = "Test Ready",
            description = "Take your first practice exam",
            icon = "📝",
            unlockedAt = unlockedAt,
            isUnlocked = hasCompleted
        )
    }

    private fun track50PercentCompetence(skillMap: SkillMapData): Milestone {
        if (skillMap.skills.isEmpty()) {
            return Milestone(
                id = "competence_50",
                name = "Halfway There",
                description = "Reach 50% competence across all skills",
                icon = "🚀",
                isUnlocked = false,
                progress = 0,
                targetValue = 50
            )
        }

        val avgCompetence = skillMap.skills
            .sumOf { it.masteryLevel.coerceIn(0, 100) } / skillMap.skills.size

        val isUnlocked = avgCompetence >= 50
        val unlockedAt = if (isUnlocked) {
            skillMap.skills
                .flatMap { it.practiceHistory }
                .maxOrNull()
        } else {
            null
        }

        return Milestone(
            id = "competence_50",
            name = "Halfway There",
            description = "Reach 50% competence across all skills",
            icon = "🚀",
            unlockedAt = unlockedAt,
            isUnlocked = isUnlocked,
            progress = avgCompetence,
            targetValue = 50
        )
    }

    private fun track80PercentCompetence(skillMap: SkillMapData): Milestone {
        if (skillMap.skills.isEmpty()) {
            return Milestone(
                id = "competence_80",
                name = "Master of Skills",
                description = "Reach 80% competence across all skills",
                icon = "⭐",
                isUnlocked = false,
                progress = 0,
                targetValue = 80
            )
        }

        val avgCompetence = skillMap.skills
            .sumOf { it.masteryLevel.coerceIn(0, 100) } / skillMap.skills.size

        val isUnlocked = avgCompetence >= 80
        val unlockedAt = if (isUnlocked) {
            skillMap.skills
                .flatMap { it.practiceHistory }
                .maxOrNull()
        } else {
            null
        }

        return Milestone(
            id = "competence_80",
            name = "Master of Skills",
            description = "Reach 80% competence across all skills",
            icon = "⭐",
            unlockedAt = unlockedAt,
            isUnlocked = isUnlocked,
            progress = avgCompetence,
            targetValue = 80
        )
    }

    private fun trackAllCategoriesPracticed(skillMap: SkillMapData): Milestone {
        if (skillMap.skills.isEmpty()) {
            return Milestone(
                id = "all_categories",
                name = "Comprehensive Learner",
                description = "Practice in every skill category",
                icon = "🎯",
                isUnlocked = false,
                progress = 0
            )
        }

        val categoriesWithPractice = skillMap.skills.count { it.practiceHistory.isNotEmpty() }
        val allCategoriesHavePractice = categoriesWithPractice == skillMap.skills.size
        val unlockedAt = if (allCategoriesHavePractice) {
            skillMap.skills
                .mapNotNull { it.practiceHistory.maxOrNull() }
                .maxOrNull()
        } else {
            null
        }

        return Milestone(
            id = "all_categories",
            name = "Comprehensive Learner",
            description = "Practice in every skill category",
            icon = "🎯",
            unlockedAt = unlockedAt,
            isUnlocked = allCategoriesHavePractice,
            progress = (categoriesWithPractice * 100) / skillMap.skills.size
        )
    }

    private fun trackExamPassed(examResults: List<ExamResult>): Milestone {
        val hasPassed = examResults.any { it.scorePercentage >= 70 }
        val unlockedAt = examResults
            .filter { it.scorePercentage >= 70 }
            .minByOrNull { it.completedAt }
            ?.completedAt

        val bestScore = examResults.maxOfOrNull { it.scorePercentage } ?: 0

        return Milestone(
            id = "exam_passed",
            name = "Success!",
            description = "Score 70% or higher on any exam",
            icon = "🏆",
            unlockedAt = unlockedAt,
            isUnlocked = hasPassed,
            progress = bestScore
        )
    }

    /**
     * Get count of unlocked milestones
     */
    fun getUnlockedMilestoneCount(
        skillMap: SkillMapData,
        examResults: List<ExamResult>
    ): Int {
        return trackMilestones(skillMap, examResults).count { it.isUnlocked }
    }

    /**
     * Get next milestone to target (first locked one)
     */
    fun getNextMilestone(
        skillMap: SkillMapData,
        examResults: List<ExamResult>
    ): Milestone? {
        return trackMilestones(skillMap, examResults).firstOrNull { !it.isUnlocked }
    }

    /**
     * Get milestone by ID
     */
    fun getMilestoneById(
        id: String,
        skillMap: SkillMapData,
        examResults: List<ExamResult>
    ): Milestone? {
        return trackMilestones(skillMap, examResults).find { it.id == id }
    }
}

    val name: String,
    val description: String,
    val icon: String,
    val unlockedAt: Long? = null,
    val isUnlocked: Boolean = false,
    val progress: Int = 0,
    val targetValue: Int = 100
) {
    fun progressPercentage(): Int = minOf((progress * 100) / targetValue, 100)
}
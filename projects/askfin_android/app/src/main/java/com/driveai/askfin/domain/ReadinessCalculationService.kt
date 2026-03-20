// com.driveai.askfin.domain.service.ReadinessCalculationService.kt

package com.driveai.askfin.domain

import javax.inject.Inject
import javax.inject.Singleton
import java.util.concurrent.TimeUnit
import kotlin.math.min

data class SkillMapData(
    val skills: List<SkillData>
)

data class SkillData(
    val masteryLevel: Int,
    val practiceHistory: List<Long>
)

data class ExamResult(
    val completedAt: Long,
    val scorePercentage: Int
)

/**
 * Calculates overall readiness score (0-100) based on:
 * - Training competence: 40%
 * - Exam scores: 35%
 * - Consistency: 15%
 * - Coverage: 10%
 */
@Singleton
class ReadinessCalculationService @Inject constructor() {

    /**
     * Compute overall readiness score from skill and exam data
     */
    fun calculateReadinessScore(
        skillMap: SkillMapData,
        examResults: List<ExamResult>
    ): Int {
        require(skillMap.skills.isNotEmpty()) { "SkillMapData must contain at least one skill" }

        val competenceScore = calculateCompetenceScore(skillMap) * 0.40
        val examScore = calculateExamScore(examResults) * 0.35
        val consistencyScore = calculateConsistencyScore(skillMap) * 0.15
        val coverageScore = calculateCoverageScore(skillMap) * 0.10

        return (competenceScore + examScore + consistencyScore + coverageScore).toInt()
    }

    /**
     * Calculate training competence (0-100) from skill mastery levels
     * Average of all skill competences where data exists
     */
    private fun calculateCompetenceScore(skillMap: SkillMapData): Int {
        if (skillMap.skills.isEmpty()) return 0

        val totalCompetence = skillMap.skills.sumOf { skill ->
            skill.masteryLevel.coerceIn(0, 100).toDouble()
        }

        return (totalCompetence / skillMap.skills.size).toInt()
    }

    /**
     * Calculate exam score (0-100) from recent exam results
     * Weighted: recent exams count more (last exam = 50% weight, previous = 50% combined)
     */
    private fun calculateExamScore(examResults: List<ExamResult>): Int {
        if (examResults.isEmpty()) return 0

        val sortedExams = examResults.sortedByDescending { it.completedAt }

        return when {
            sortedExams.size == 1 -> sortedExams[0].scorePercentage.coerceIn(0, 100)
            sortedExams.size >= 2 -> {
                val mostRecent = sortedExams[0].scorePercentage * 0.50
                val average = sortedExams
                    .drop(1)
                    .take(4)
                    .let { previous ->
                        if (previous.isNotEmpty()) {
                            previous.sumOf { it.scorePercentage } / previous.size.toDouble() * 0.50
                        } else {
                            0.0
                        }
                    }
                (mostRecent + average).toInt()
            }
            else -> 0
        }
    }

    /**
     * Calculate consistency (0-100) based on practice frequency
     * Tracks practice days in last 14 days relative to max possible (14 days)
     */
    private fun calculateConsistencyScore(skillMap: SkillMapData): Int {
        val now = System.currentTimeMillis()
        val fourteenDaysAgo = now - TimeUnit.DAYS.toMillis(14)

        val uniquePracticeDays = skillMap.skills
            .flatMap { skill -> skill.practiceHistory }
            .filter { it in fourteenDaysAgo..now }
            .map { it / TimeUnit.DAYS.toMillis(1) }  // Convert to days since epoch
            .toSet()
            .size

        return min((uniquePracticeDays * 100) / 14, 100)
    }

    /**
     * Calculate coverage (0-100) based on categories practiced
     * Measures breadth: how many categories have at least one practice session
     */
    private fun calculateCoverageScore(skillMap: SkillMapData): Int {
        if (skillMap.skills.isEmpty()) return 0

        val categoriesWithPractice = skillMap.skills.count { skill ->
            skill.practiceHistory.isNotEmpty()
        }

        return (categoriesWithPractice * 100) / skillMap.skills.size
    }

    /**
     * Get readiness level description for UI display
     */
    fun getReadinessLevel(score: Int): ReadinessLevel {
        return when {
            score >= 80 -> ReadinessLevel.EXCELLENT
            score >= 65 -> ReadinessLevel.GOOD
            score >= 50 -> ReadinessLevel.FAIR
            score >= 35 -> ReadinessLevel.NEEDS_WORK
            else -> ReadinessLevel.NOT_READY
        }
    }

    /**
     * Get detailed breakdown of readiness components
     */
    fun getReadinessBreakdown(
        skillMap: SkillMapData,
        examResults: List<ExamResult>
    ): ReadinessBreakdown {
        require(skillMap.skills.isNotEmpty()) { "SkillMapData must contain at least one skill" }

        return ReadinessBreakdown(
            competenceScore = calculateCompetenceScore(skillMap),
            examScore = calculateExamScore(examResults),
            consistencyScore = calculateConsistencyScore(skillMap),
            coverageScore = calculateCoverageScore(skillMap)
        )
    }
}

enum class ReadinessLevel {
    EXCELLENT, GOOD, FAIR, NEEDS_WORK, NOT_READY
}

data class ReadinessBreakdown(
    val competenceScore: Int,
    val examScore: Int,
    val consistencyScore: Int,
    val coverageScore: Int
) {
    fun overall(): Int {
        return (competenceScore * 0.40 + examScore * 0.35 + consistencyScore * 0.15 + coverageScore * 0.10).toInt()
    }
}
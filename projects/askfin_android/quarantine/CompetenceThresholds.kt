package com.driveai.askfin.data.models

import javax.inject.Singleton
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers

/**
 * Thresholds for competence classification.
 * Adjust per curriculum requirements.
 */
data class CompetenceThresholds(
    val strongCategoryMin: Float = 75f,         // Score ≥ this = strength
    val weakCategoryMax: Float = 60f,           // Score < this = weakness
    val minimumSampleSize: Int = 5,             // Min answers for significance
    val advancedTierMin: Float = 85f,           // Tier boundaries
    val intermediateTierMin: Float = 70f,
    val beginnerTierMin: Float = 50f,
    val testPassThreshold: Float = 70f,         // Passing score
    val testReadinessMin: Float = 65f,          // Min overall to be "ready"
    val criticalCategoryMin: Float = 70f        // Min for critical categories
) {
    init {
        require(weakCategoryMax < strongCategoryMin) {
            "Weak threshold ($weakCategoryMax) must be < strong threshold ($strongCategoryMin)"
        }
        require(beginnerTierMin < intermediateTierMin && intermediateTierMin < advancedTierMin) {
            "Tier boundaries must be ordered: beginner < intermediate < advanced"
        }
    }
}

@Singleton
class CompetenceAnalyzer(
    private val thresholds: CompetenceThresholds = CompetenceThresholds()
) {
    suspend fun analyzeCompetence(
        answers: List<UserAnswer>,
        categoryMapping: Map<String, QuestionCategory> = emptyMap()
    ): SkillMapProfile = withContext(Dispatchers.Default) {
        require(answers.isNotEmpty()) { "Cannot analyze empty answer history" }

        val categorizedAnswers = groupByCategory(answers, categoryMapping)
        val categoryScores = scoreCategoriesParallel(categorizedAnswers)
        val overallScore = calculateOverallCompetence(categoryScores)

        SkillMapProfile(
            overallCompetence = overallScore,
            categoryScores = categoryScores,
            strongCategories = identifyStrengths(categoryScores),
            weakCategories = identifyWeaknesses(categoryScores),
            recommendedFocus = determineRecommendedFocus(
                identifyWeaknesses(categoryScores)
            ),
            learnerTier = determineLearnerTier(overallScore),
            analysisTimestamp = System.currentTimeMillis()
        )
    }

    private fun calculateOverallCompetence(
        categoryScores: Map<QuestionCategory, CompetenceScore>
    ): CompetenceScore {
        val avgScore = categoryScores.values.map { it.value }.average().toFloat()
        val totalSampleSize = categoryScores.values.sumOf { it.sampleSize }
        return CompetenceScore(
            value = avgScore,
            sampleSize = totalSampleSize,
            isSignificant = totalSampleSize >= thresholds.minimumSampleSize,
            confidenceInterval = ConfidenceInterval(margin = 5f)
        )
    }

    private fun identifyStrengths(
        categoryScores: Map<QuestionCategory, CompetenceScore>
    ): List<CategoryCompetence> {
        return categoryScores
            .filter { (_, score) -> 
                score.value >= thresholds.strongCategoryMin && score.isSignificant
            }
            .map { (category, score) ->
                CategoryCompetence(
                    category = category,
                    score = score.value,
                    confidence = score.confidenceInterval.margin,
                    sampleSize = score.sampleSize,
                    trend = TrendType.IMPROVING,
                    totalAnswered = score.sampleSize,
                    correctAnswers = (score.value / 100 * score.sampleSize).toInt()
                )
            }
            .sortedByDescending { it.score }
    }

    private fun identifyWeaknesses(
        categoryScores: Map<QuestionCategory, CompetenceScore>
    ): List<CategoryCompetence> {
        return categoryScores
            .filter { (_, score) -> 
                score.value < thresholds.weakCategoryMax && score.isSignificant
            }
            .map { (category, score) ->
                CategoryCompetence(
                    category = category,
                    score = score.value,
                    confidence = score.confidenceInterval.margin,
                    sampleSize = score.sampleSize,
                    trend = TrendType.DECLINING,
                    totalAnswered = score.sampleSize,
                    correctAnswers = (score.value / 100 * score.sampleSize).toInt()
                )
            }
            .sortedBy { it.score }
    }

    private fun determineRecommendedFocus(
        weakCategories: List<CategoryCompetence>
    ): List<QuestionCategory> {
        return weakCategories.map { it.category }
    }

    private fun groupByCategory(
        answers: List<UserAnswer>,
        categoryMapping: Map<String, QuestionCategory>
    ): Map<QuestionCategory, List<UserAnswer>> {
        return answers.groupBy { it.category }
            .mapKeys { (categoryStr, _) -> 
                categoryMapping[categoryStr] ?: QuestionCategory.GENERAL
            }
    }

    private fun scoreCategoriesParallel(
        categorizedAnswers: Map<QuestionCategory, List<UserAnswer>>
    ): Map<QuestionCategory, CompetenceScore> {
        return categorizedAnswers.mapValues { (_, answers) ->
            CompetenceScore(
                value = answers.count { it.isCorrect }.toFloat() / answers.size * 100,
                sampleSize = answers.size,
                isSignificant = answers.size >= thresholds.minimumSampleSize,
                confidenceInterval = ConfidenceInterval(margin = 5f)
            )
        }
    }

    private fun determineLearnerTier(score: CompetenceScore): LearnerTier {
        return when {
            score.value >= thresholds.advancedTierMin && score.isSignificant ->
                LearnerTier.ADVANCED
            score.value >= thresholds.intermediateTierMin && score.isSignificant ->
                LearnerTier.INTERMEDIATE
            score.value >= thresholds.beginnerTierMin ->
                LearnerTier.BEGINNER
            else ->
                LearnerTier.NOVICE
        }
    }

    fun assessTestReadiness(
        profile: SkillMapProfile,
        criticalCategories: Set<QuestionCategory> = emptySet()
    ): TestReadiness {
        val overallReady = profile.overallCompetence.value >= thresholds.testReadinessMin
        val criticalReady = if (criticalCategories.isEmpty()) {
            true
        } else {
            criticalCategories.all { cat ->
                val score = profile.categoryScores[cat]
                score?.value?.let { 
                    it >= thresholds.criticalCategoryMin && score.isSignificant
                } ?: false
            }
        }

        return TestReadiness(
            isReady = overallReady && criticalReady,
            overallScore = profile.overallCompetence.value,
            criticalCategoriesReady = criticalReady
        )
    }
}

enum class QuestionCategory {
    GENERAL, MATHEMATICS, SCIENCE, LANGUAGE, HISTORY
}

enum class LearnerTier {
    NOVICE, BEGINNER, INTERMEDIATE, ADVANCED
}

enum class TrendType {
    IMPROVING, DECLINING, STABLE
}

data class UserAnswer(
    val category: String,
    val isCorrect: Boolean
)

data class CompetenceScore(
    val value: Float,
    val sampleSize: Int,
    val isSignificant: Boolean,
    val confidenceInterval: ConfidenceInterval
)

data class ConfidenceInterval(
    val margin: Float
)

data class CategoryCompetence(
    val category: QuestionCategory,
    val score: Float,
    val confidence: Float,
    val sampleSize: Int,
    val trend: TrendType,
    val totalAnswered: Int,
    val correctAnswers: Int
)

data class SkillMapProfile(
    val overallCompetence: CompetenceScore,
    val categoryScores: Map<QuestionCategory, CompetenceScore>,
    val strongCategories: List<CategoryCompetence>,
    val weakCategories: List<CategoryCompetence>,
    val recommendedFocus: List<QuestionCategory>,
    val learnerTier: LearnerTier,
    val analysisTimestamp: Long
)

data class TestReadiness(
    val isReady: Boolean,
    val overallScore: Float,
    val criticalCategoriesReady: Boolean
)
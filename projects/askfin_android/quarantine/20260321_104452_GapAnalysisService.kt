package com.driveai.askfin.domain

import javax.inject.Singleton
import javax.inject.Inject
import javax.inject.Named
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import java.time.Instant

// Placeholder types
interface QuestionRepository

data class ExamResult(
    val sessionId: String,
    val scorePercentage: Float,
    val categoryBreakdown: List<CategoryBreakdown>
)

data class CategoryBreakdown(
    val category: String,
    val percentage: Float,
    val correctAnswers: Int,
    val totalQuestions: Int
)

enum class Severity {
    CRITICAL, HIGH, MEDIUM
}

data class WeakCategory(
    val categoryName: String,
    val scorePercentage: Float,
    val correctAnswers: Int,
    val totalQuestions: Int,
    val severity: Severity
)

data class StrongCategory(
    val categoryName: String,
    val scorePercentage: Float,
    val correctAnswers: Int,
    val totalQuestions: Int
)

data class GapAnalysis(
    val examSessionId: String,
    val overallScore: Float,
    val weakCategories: List<WeakCategory>,
    val strongCategories: List<StrongCategory>,
    val recommendations: List<Recommendation>,
    val estimatedStudyHours: Float,
    val analyzedAt: Instant
)

enum class Priority {
    URGENT, HIGH, MEDIUM
}

data class Recommendation(
    val categoryName: String,
    val priority: Priority,
    val action: String,
    val estimatedHours: Float,
    val topic: String
)

@Singleton
class GapAnalysisService @Inject constructor(
    private val questionRepository: QuestionRepository,
    @Named("CriticalThreshold") private val criticalThreshold: Float = 0.5f,
    @Named("HighThreshold") private val highThreshold: Float = 0.7f,
    @Named("MediumThreshold") private val mediumThreshold: Float = 0.85f
) {
    private val _gapAnalysis = MutableStateFlow<GapAnalysis?>(null)
    val gapAnalysis: StateFlow<GapAnalysis?> = _gapAnalysis.asStateFlow()

    suspend fun analyzeExamResult(examResult: ExamResult): Result<GapAnalysis> = runCatching {
        val weakCategories = mutableListOf<WeakCategory>()
        val strongCategories = mutableListOf<StrongCategory>()

        examResult.categoryBreakdown.forEach { category ->
            val scorePercentage = category.percentage

            when {
                scorePercentage < (criticalThreshold * 100f) -> {
                    weakCategories.add(
                        WeakCategory(
                            categoryName = category.category,
                            scorePercentage = scorePercentage,
                            correctAnswers = category.correctAnswers,
                            totalQuestions = category.totalQuestions,
                            severity = Severity.CRITICAL
                        )
                    )
                }
                scorePercentage < (highThreshold * 100f) -> {
                    weakCategories.add(
                        WeakCategory(
                            categoryName = category.category,
                            scorePercentage = scorePercentage,
                            correctAnswers = category.correctAnswers,
                            totalQuestions = category.totalQuestions,
                            severity = Severity.HIGH
                        )
                    )
                }
                scorePercentage < (mediumThreshold * 100f) -> {
                    weakCategories.add(
                        WeakCategory(
                            categoryName = category.category,
                            scorePercentage = scorePercentage,
                            correctAnswers = category.correctAnswers,
                            totalQuestions = category.totalQuestions,
                            severity = Severity.MEDIUM
                        )
                    )
                }
                else -> {
                    strongCategories.add(
                        StrongCategory(
                            categoryName = category.category,
                            scorePercentage = scorePercentage,
                            correctAnswers = category.correctAnswers,
                            totalQuestions = category.totalQuestions
                        )
                    )
                }
            }
        }

        val recommendations = generateRecommendations(weakCategories)
        val estimatedHours = calculateStudyHours(weakCategories)

        val analysis = GapAnalysis(
            examSessionId = examResult.sessionId,
            overallScore = examResult.scorePercentage,
            weakCategories = weakCategories.sortedBy { it.severity.ordinal },
            strongCategories = strongCategories,
            recommendations = recommendations,
            estimatedStudyHours = estimatedHours,
            analyzedAt = Instant.now()
        )

        _gapAnalysis.value = analysis
        analysis
    }

    private fun generateRecommendations(weakCategories: List<WeakCategory>): List<Recommendation> {
        return weakCategories.flatMap { weak ->
            when (weak.severity) {
                Severity.CRITICAL -> listOf(
                    Recommendation(
                        categoryName = weak.categoryName,
                        priority = Priority.URGENT,
                        action = "Master fundamentals in ${weak.categoryName}",
                        estimatedHours = 4f,
                        topic = "${weak.categoryName} Basics"
                    ),
                    Recommendation(
                        categoryName = weak.categoryName,
                        priority = Priority.URGENT,
                        action = "Review failed questions from practice tests",
                        estimatedHours = 2f,
                        topic = "${weak.categoryName} Question Review"
                    )
                )
                Severity.HIGH -> listOf(
                    Recommendation(
                        categoryName = weak.categoryName,
                        priority = Priority.HIGH,
                        action = "Focus study sessions on ${weak.categoryName}",
                        estimatedHours = 3f,
                        topic = "${weak.categoryName} Depth Study"
                    )
                )
                Severity.MEDIUM -> listOf(
                    Recommendation(
                        categoryName = weak.categoryName,
                        priority = Priority.MEDIUM,
                        action = "Practice more questions in ${weak.categoryName}",
                        estimatedHours = 1.5f,
                        topic = "${weak.categoryName} Practice"
                    )
                )
            }
        }
    }

    private fun calculateStudyHours(weakCategories: List<WeakCategory>): Float {
        return weakCategories.sumOf { category ->
            val deficit = 1.0f - (category.scorePercentage / 100f)
            val baseHours = when (category.severity) {
                Severity.CRITICAL -> 4f
                Severity.HIGH -> 3f
                Severity.MEDIUM -> 1.5f
            }
            (baseHours * deficit).toDouble()
        }.toFloat()
    }
}
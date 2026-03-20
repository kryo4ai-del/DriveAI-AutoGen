package com.driveai.askfin.data.models

import kotlin.system.measureTimeMillis

private lateinit var _uiState: MutableStateFlow<SkillMapUiState>

private fun updateUiState(): SkillMapUiState? {
    var result: SkillMapUiState? = null
    _uiState.update { currentState ->
        val sortedCategories = applyFiltersAndSort(
            categories = emptyList(),
            sortBy = currentState.sortBy,
            filterBy = currentState.filterBy
        )
        
        val recommendation = computeNextStudyRecommendation(sortedCategories, currentState)
        val examReadiness = computeExamReadiness(sortedCategories)
        
        val newState = currentState.copy(
            isLoading = false,
            categories = sortedCategories,
            nextStudyRecommendation = recommendation,
            examReadinessPercent = examReadiness.percent,
            examReadinessStatus = examReadiness.status,
            lastRefresh = System.currentTimeMillis(),
            error = null,
        )
        result = newState
        newState
    }
    return result
}

private fun computeNextStudyRecommendation(
    categories: List<Category>,
    state: SkillMapUiState
): StudyRecommendation? {
    // Logic: rank categories by exam criticality + current score + forgetting curve
    // EXAM_CRITICAL: if category is "required for passing" AND score <70%
    // NEAREST_TO_MASTERY: if 65% ≤ score < 70% (smallest gap to 70%)
    // HIGHEST_FORGETTING_RISK: if score 70%+ but daysSinceReview > spaceInterval (e.g., 7 days)
    // BEST_EXAM_ROI: category that maximizes exam readiness gain per hour studied
    
    val examInfoService = ExamInfoServiceImpl() // Mock: determine which categories matter for exam
    val examCriticalCategories = examInfoService.getCriticalCategories()
    
    // Rank by: (1) exam criticality, (2) gap to 70%, (3) forgetting risk
    val ranked = categories
        .map { cat ->
            val isCritical = cat.id in examCriticalCategories
            val gapTo70 = (70f - cat.competencePercentage).coerceAtLeast(0f)
            val daysSinceReview = computeDaysSinceLastReview(cat.id) // From training log
            val forgettingRisk = if (daysSinceReview > 7) 1.5f else 1.0f
            
            Triple(cat, isCritical, gapTo70 * forgettingRisk)
        }
        .sortedBy { (_, isCritical, score) ->
            // Descending: critical first, then largest gap, then highest forgetting risk
            -(if (isCritical) 100 else 0) - score
        }
    
    val topCategory = ranked.firstOrNull()?.first ?: return null
    
    val reason = when {
        topCategory.competencePercentage < 70f && topCategory.id in examCriticalCategories ->
            RecommendationReason.EXAM_CRITICAL
        topCategory.competencePercentage in 65f..70f ->
            RecommendationReason.NEAREST_TO_MASTERY
        computeDaysSinceLastReview(topCategory.id) > 7 ->
            RecommendationReason.HIGHEST_FORGETTING_RISK
        else ->
            RecommendationReason.BEST_EXAM_ROI
    }
    
    return StudyRecommendation(
        categoryId = topCategory.id,
        categoryName = topCategory.name,
        reason = reason,
        urgency = when {
            topCategory.competencePercentage < 60f -> UrgencyLevel.CRITICAL
            topCategory.competencePercentage < 70f -> UrgencyLevel.HIGH
            else -> UrgencyLevel.MEDIUM
        },
        estimatedGainPoints = estimateExamGain(topCategory),
        estimatedSessionsNeeded = estimateSessionsNeeded(topCategory)
    )
}

private fun computeExamReadiness(categories: List<Category>): ExamReadinessData {
    val percent = if (categories.isNotEmpty()) {
        categories.map { it.competencePercentage }.average().toInt()
    } else {
        0
    }
    val status = when {
        percent < 60 -> ExamReadinessStatus.NOT_READY
        percent < 70 -> ExamReadinessStatus.ALMOST_THERE
        else -> ExamReadinessStatus.EXAM_READY
    }
    return ExamReadinessData(percent, status)
}

private fun applyFiltersAndSort(
    categories: List<Category>,
    sortBy: String,
    filterBy: String
): List<Category> = categories

private fun computeDaysSinceLastReview(categoryId: String): Int = 0

private fun estimateExamGain(category: Category): Int = 0

private fun estimateSessionsNeeded(category: Category): Int = 0

data class ExamReadinessData(val percent: Int, val status: ExamReadinessStatus)

data class CategoryModel(
    val id: String,
    val name: String,
    val competencePercentage: Float
)

data class Category(
    val id: String,
    val name: String,
    val competencePercentage: Float
)

data class StudyRecommendationData(
    val categoryId: String,
    val categoryName: String,
    val reason: RecommendationReason,
    val urgency: UrgencyLevel,
    val estimatedGainPoints: Int,
    val estimatedSessionsNeeded: Int
)

data class StudyRecommendation(
    val categoryId: String,
    val categoryName: String,
    val reason: RecommendationReason,
    val urgency: UrgencyLevel,
    val estimatedGainPoints: Int,
    val estimatedSessionsNeeded: Int
)

data class SkillMapUiState(
    val isLoading: Boolean = false,
    val categories: List<Category> = emptyList(),
    val nextStudyRecommendation: StudyRecommendation? = null,
    val examReadinessPercent: Int = 0,
    val examReadinessStatus: ExamReadinessStatus = ExamReadinessStatus.NOT_READY,
    val lastRefresh: Long = 0,
    val error: String? = null,
    val sortBy: String = "",
    val filterBy: String = ""
) {
    fun copy(
        isLoading: Boolean = this.isLoading,
        categories: List<Category> = this.categories,
        nextStudyRecommendation: StudyRecommendation? = this.nextStudyRecommendation,
        examReadinessPercent: Int = this.examReadinessPercent,
        examReadinessStatus: ExamReadinessStatus = this.examReadinessStatus,
        lastRefresh: Long = this.lastRefresh,
        error: String? = this.error,
        sortBy: String = this.sortBy,
        filterBy: String = this.filterBy
    ) = SkillMapUiState(isLoading, categories, nextStudyRecommendation, examReadinessPercent, examReadinessStatus, lastRefresh, error, sortBy, filterBy)
}

enum class ExamReadinessStatus {
    NOT_READY, ALMOST_THERE, EXAM_READY
}

enum class RecommendationReason {
    EXAM_CRITICAL, NEAREST_TO_MASTERY, HIGHEST_FORGETTING_RISK, BEST_EXAM_ROI
}

enum class UrgencyLevel {
    CRITICAL, HIGH, MEDIUM, LOW
}

interface ExamInfoService {
    fun getCriticalCategories(): List<String>
}

class ExamInfoServiceImpl : ExamInfoService {
    override fun getCriticalCategories(): List<String> = emptyList()
}

class StateHolder {
    private val _uiState = MutableStateFlow(SkillMapUiState())
}

class MutableStateFlow<T>(initialValue: T) {
    private var value = initialValue
    fun update(block: (T) -> T) {
        value = block(value)
    }
}
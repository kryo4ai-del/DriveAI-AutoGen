_uiState.update { currentState ->
    val sortedCategories = applyFiltersAndSort(
        categories,
        sortBy = currentState.sortBy,
        filterBy = currentState.filterBy
    )
    
    val recommendation = computeNextStudyRecommendation(sortedCategories, currentState)
    val examReadiness = computeExamReadiness(sortedCategories)
    
    currentState.copy(
        isLoading = false,
        categories = sortedCategories,
        nextStudyRecommendation = recommendation,
        examReadinessPercent = examReadiness.percent,
        examReadinessStatus = examReadiness.status,
        lastRefresh = System.currentTimeMillis(),
        error = null,
    )
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
    
    val examinfoService = /* injected */ // Mock: determine which categories matter for exam
    val examCriticalCategories = examInfoService.getCriticalCategories()
    
    // Rank by: (1) exam criticality, (2) gap to 70%, (3) forgetting risk
    val ranked = categories
        .map { cat ->
            val isCritical = cat.id in examCriticalCategories
            val gapTo70 = (70f - cat.competencePercentage).coerceAtLeast(0f)
            val daysSinceReview = computeDaysSinceLastReview(cat.id) // From training log
            val forgettingRisk = if (daysSinceReview > 7) 1.5f else 1.0f
            
            Pair(cat, isCritical to gapTo70 to forgettingRisk)
        }
        .sortedBy { (_, (isCritical, gapTo70, forgettingRisk)) ->
            // Descending: critical first, then largest gap, then highest forgetting risk
            -(if (isCritical) 100 else 0) - gapTo70 - forgettingRisk
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
    val percent = categories.map { it.competencePercentage }.average().toInt()
    val status = when {
        percent < 60 -> ExamReadinessStatus.NOT_READY
        percent < 70 -> ExamReadinessStatus.ALMOST_THERE
        else -> ExamReadinessStatus.EXAM_READY
    }
    return ExamReadinessData(percent, status)
}

data class ExamReadinessData(val percent: Int, val status: ExamReadinessStatus)
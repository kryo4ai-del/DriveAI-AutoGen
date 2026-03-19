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
    private val thresholds: CompetenceThresholds = CompetenceThresholds()
) {
    suspend fun analyzeCompetence(
        answers: List<UserAnswer>,
        categoryMapping: Map<String, String> = emptyMap()
    ): SkillMapProfile = withContext(Dispatchers.Default) {
        require(answers.isNotEmpty()) { "Cannot analyze empty answer history" }

        val categorizedAnswers = groupByCategory(answers, categoryMapping)
        val categoryScores = scoreCategoriesParallel(categorizedAnswers)
        val overallScore = calculator.calculateOverallCompetence(categoryScores)

        return SkillMapProfile(
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

    private fun identifyStrengths(
        categoryScores: Map<String, CompetenceScore>
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
                    trend = TrendType.IMPROVING
                )
            }
            .sortedByDescending { it.score }
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
        criticalCategories: Set<String> = emptySet()
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

        // ...
    }
}
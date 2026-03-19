/**
 * Aggregated skill map snapshot for a user.
 * Provides overall competence metrics and category-level breakdowns.
 */
data class SkillMapData(
    val categories: List<CategoryCompetence>,
    val overallCompetence: Float, // 0.0–1.0 scale
    val strongCategories: List<QuestionCategory>, // Top-performing categories
    val weakCategories: List<QuestionCategory>, // Categories needing improvement
    val lastUpdated: java.time.Instant = java.time.Instant.EPOCH
) {
    init {
        // Validate at construction time
        require(overallCompetence in 0.0f..1.0f) {
            "overallCompetence must be in [0.0, 1.0], got $overallCompetence"
        }
        require(categories.isNotEmpty()) {
            "categories list cannot be empty"
        }
        // Validate all CategoryCompetence objects
        categories.forEach { cat ->
            require(cat.isValid()) {
                "CategoryCompetence for ${cat.category} is invalid"
            }
        }

        // Ensure no duplicate categories
        val categorySet = categories.map { it.category }.toSet()
        require(categorySet.size == categories.size) {
            "Duplicate categories detected in categories list"
        }

        // Ensure strongCategories and weakCategories are subsets of all categories
        val strongSet = strongCategories.toSet()
        val weakSet = weakCategories.toSet()

        require(strongSet.all { it in categorySet }) {
            "strongCategories contains categories not in categories list: ${strongSet - categorySet}"
        }
        require(weakSet.all { it in categorySet }) {
            "weakCategories contains categories not in categories list: ${weakSet - categorySet}"
        }

        // Ensure no overlap between strong and weak
        require(strongSet.intersect(weakSet).isEmpty()) {
            "A category cannot be both strong and weak: ${strongSet.intersect(weakSet)}"
        }

        // At least one category should be classified as strong or weak
        require(strongSet.isNotEmpty() || weakSet.isNotEmpty()) {
            "At least one category must be classified as strong or weak"
        }
    }

    /**
     * Computed property: derived overall proficiency level.
     */
    val overallLevel: CompetenceLevel
        get() = CompetenceLevel.fromScore(overallCompetence)
}
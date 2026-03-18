// Remove questionCount from enum
enum class QuestionCategory(
    val displayName: String,
    val iconName: String
) {
    VORFAHRT("Vorfahrt", "ic_priority"),
    VERKEHRSZEICHEN("Verkehrszeichen", "ic_traffic_sign"),
    TECHNIK("Fahrzeugtechnik", "ic_mechanics"),
    VERHALTEN("Verkehrsverhalten", "ic_behavior"),
    UMWELT_ENERGIE("Umwelt & Energie", "ic_environment"),
    FIRST_AID("Erste Hilfe", "ic_first_aid"),
    GEFAHRENLEHRE("Gefahrenlehre", "ic_danger"),
    VERKEHRSREGELN("Verkehrsregeln", "ic_rules"),
    VERTRAEGLICHKEIT("Verträglichkeit", "ic_compatibility")
}

// Add to repository interface

// Separate stats service for UI layer
data class CategoryStats(
    val category: QuestionCategory,
    val totalQuestions: Int,
    val userAttempts: Int,
    val userCorrect: Int,
    val lastUpdated: Instant
)

interface CategoryStatsRepository {
    suspend fun getStats(category: QuestionCategory): Result<CategoryStats>
    suspend fun getAllStats(): Result<Map<QuestionCategory, CategoryStats>>
    suspend fun refreshStats(userId: String): Result<Unit>
}
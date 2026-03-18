// Move to repository or separate stats service
interface QuestionStatsRepository {
    suspend fun getCategoryStats(): Result<Map<QuestionCategory, Int>>
}